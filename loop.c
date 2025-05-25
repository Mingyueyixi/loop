# include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 使用说明：
// 命令行输入：loop xxx
// 该程序会从命令行接收字符串作为命令，并循环执行该命令，直到命令的退出码为0或达到最大重试次数（1024次）

#define MAX_RETRIES 1024
#define COMMAND_SIZE 4096

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "loop usage: \n");
        fprintf(stderr, "loop command [args...]\n");
        fprintf(stderr, "example: loop echo hello world\n");
        fprintf(stderr, "the command: 'echo hello world' will be executed 1024 times.\n");
        return 1;
    }

    int retries = 0;
    int exit_code;

    // 构建命令字符串
    char command[COMMAND_SIZE] = "";
    for (int i = 1; i < argc; i++) {
        strncat(command, argv[i], COMMAND_SIZE - strlen(command) - 1);
        if (i < argc - 1) {
            strncat(command, " ", COMMAND_SIZE - strlen(command) - 1);
        }
    }

    while (retries < MAX_RETRIES) {
        exit_code = system(command);
        if (exit_code == 0) {
            break;
        }
        retries++;
    }

    if (retries == MAX_RETRIES) {
        fprintf(stderr, "failed to execute command after %d retries.\n", MAX_RETRIES);
    }

    return 0;
}