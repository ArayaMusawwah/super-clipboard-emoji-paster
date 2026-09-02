#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <linux/uinput.h>
#include <signal.h>

#define SOCKET_PATH "/tmp/smart_paste.sock"

static int uinput_fd = -1;
static int server_sock = -1;

static void emit_event(int fd, int type, int code, int val) {
    struct input_event ie;
    memset(&ie, 0, sizeof(ie));
    ie.type = type;
    ie.code = code;
    ie.value = val;
    write(fd, &ie, sizeof(ie));
}

static void trigger_paste(void) {
    if (uinput_fd < 0) return;
    
    // Tekan Left Ctrl + V
    emit_event(uinput_fd, EV_KEY, KEY_LEFTCTRL, 1);
    emit_event(uinput_fd, EV_KEY, KEY_V, 1);
    emit_event(uinput_fd, EV_SYN, SYN_REPORT, 0);

    usleep(25000); // 25ms hold

    // Lepas V + Left Ctrl
    emit_event(uinput_fd, EV_KEY, KEY_V, 0);
    emit_event(uinput_fd, EV_KEY, KEY_LEFTCTRL, 0);
    emit_event(uinput_fd, EV_SYN, SYN_REPORT, 0);
}

static void cleanup(int signum) {
    (void)signum;
    if (uinput_fd >= 0) {
        ioctl(uinput_fd, UI_DEV_DESTROY);
        close(uinput_fd);
    }
    if (server_sock >= 0) {
        close(server_sock);
    }
    unlink(SOCKET_PATH);
    exit(0);
}

int main(void) {
    signal(SIGINT, cleanup);
    signal(SIGTERM, cleanup);

    uinput_fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (uinput_fd < 0) {
        perror("open /dev/uinput");
        return 1;
    }

    ioctl(uinput_fd, UI_SET_EVBIT, EV_KEY);
    ioctl(uinput_fd, UI_SET_KEYBIT, KEY_LEFTCTRL);
    ioctl(uinput_fd, UI_SET_KEYBIT, KEY_V);

    struct uinput_setup usetup;
    memset(&usetup, 0, sizeof(usetup));
    usetup.id.bustype = BUS_USB;
    usetup.id.vendor = 0x1234;
    usetup.id.product = 0x5678;
    strcpy(usetup.name, "smart-paste-daemon");

    ioctl(uinput_fd, UI_DEV_SETUP, &usetup);
    ioctl(uinput_fd, UI_DEV_CREATE);

    unlink(SOCKET_PATH);
    server_sock = socket(AF_UNIX, SOCK_DGRAM, 0);
    if (server_sock < 0) {
        perror("socket");
        return 1;
    }

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, SOCKET_PATH, sizeof(addr.sun_path) - 1);

    if (bind(server_sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        perror("bind");
        return 1;
    }

    chmod(SOCKET_PATH, 0666);

    char buf[16];
    while (1) {
        ssize_t n = recvfrom(server_sock, buf, sizeof(buf) - 1, 0, NULL, NULL);
        if (n > 0) {
            trigger_paste();
        }
    }

    cleanup(0);
    return 0;
}
