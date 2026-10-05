/*
 * shell.c
 * Author: Omar Abdeen
 * Created on: 2024-02-12
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// run in WSL, or UNIX-environment
#include <sys/wait.h>
#include <unistd.h>

int main(){

    while(1){
        char curr_user_command[1000], *arguments[50];
        int args = 0;
        printf("myshell> ");
        // print the prompt now, so a forked child never gets a copy of it waiting in its output buffer
        fflush(stdout);
        // fgets gives NULL at the end of input (Ctrl+D). quit like q, instead of running the last command again forever
        if(fgets(curr_user_command, 1000, stdin) == NULL){
            printf("\n");
            break;
        }
        // length until first encounter of \n
        int end_of_command = strcspn(curr_user_command, "\n");
        // indicate end of reading, macro null pointer with strings
        curr_user_command[end_of_command] = '\0';

        // quit or no command. end or restart
        if(strcmp(curr_user_command, "q") == 0){
            break;
        }else if (strcmp(curr_user_command, "") == 0){
            // repeat
            continue;
        }

        // split the command into arguments before forking, so a line of only spaces never reaches execvp
        char *curr_command_token = strtok(curr_user_command, " \t");
        while(curr_command_token != NULL && args < 49){
            arguments[args] = curr_command_token;
            args++;
            curr_command_token = strtok(NULL, " \t");
        }
        arguments[args] = NULL;
        // only spaces were entered. repeat
        if(args == 0){
            continue;
        }

        pid_t pid = fork();
        if(pid == 0){
            int exec_status = execvp(arguments[0], arguments);
            if (exec_status == -1){
                printf("Failed to execute command.\n");
            }
            exit(1);
        }else if(pid > 0){
            wait(NULL);
        }else{
            printf("Failed to fork new process.\n");
            exit(1);
        }

    }
    return 0;
}
