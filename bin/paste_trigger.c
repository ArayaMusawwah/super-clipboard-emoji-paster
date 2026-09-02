#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SOCKET_PATH "/tmp/smart_paste.sock"

int main(void) {
    int sock = socket(AF_UNIX, SOCK_DGRAM, 0);
    if (sock < 0) return 1;

    struct sockaddr_un addr;
    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, SOCKET_PATH, sizeof(addr.sun_path) - 1);

    const char msg[] = "p";
    sendto(sock, msg, sizeof(msg), 0, (struct sockaddr*)&addr, sizeof(addr));
    close(sock);
    return 0;
}
