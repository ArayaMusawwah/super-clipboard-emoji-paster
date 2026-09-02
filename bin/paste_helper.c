#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/uinput.h>

static void emit_event(int fd, int type, int code, int val) {
    struct input_event ie;
    memset(&ie, 0, sizeof(ie));
    ie.type = type;
    ie.code = code;
    ie.value = val;
    write(fd, &ie, sizeof(ie));
}

int main(void) {
    int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd < 0) {
        perror("open /dev/uinput");
        return 1;
    }

    ioctl(fd, UI_SET_EVBIT, EV_KEY);
    ioctl(fd, UI_SET_KEYBIT, KEY_LEFTCTRL);
    ioctl(fd, UI_SET_KEYBIT, KEY_V);

    struct uinput_setup usetup;
    memset(&usetup, 0, sizeof(usetup));
    usetup.id.bustype = BUS_USB;
    usetup.id.vendor = 0x1;
    usetup.id.product = 0x1;
    strcpy(usetup.name, "smart-paste-vdev");

    ioctl(fd, UI_DEV_SETUP, &usetup);
    ioctl(fd, UI_DEV_CREATE);

    // Short sync delay for kernel input subsystem
    usleep(15000); // 15ms

    // Press Ctrl + V
    emit_event(fd, EV_KEY, KEY_LEFTCTRL, 1);
    emit_event(fd, EV_KEY, KEY_V, 1);
    emit_event(fd, EV_SYN, SYN_REPORT, 0);

    // Hold time
    usleep(10000); // 10ms

    // Release Ctrl + V
    emit_event(fd, EV_KEY, KEY_V, 0);
    emit_event(fd, EV_KEY, KEY_LEFTCTRL, 0);
    emit_event(fd, EV_SYN, SYN_REPORT, 0);

    usleep(5000); // 5ms before teardown
    ioctl(fd, UI_DEV_DESTROY);
    close(fd);
    return 0;
}
