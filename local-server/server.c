#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>

int main(int argc, const char *argv[]) {
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    return 0;
}