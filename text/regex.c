/*
 * regex.c
 * Author: Omar Abdeen
 * Created on: 2024-02-27
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// Since we are not using exec() and fork() no need to include unistd.h or sys/wait.h. However system() alone is less safe.

/*
 * system() runs the command through the shell, so a file name like "x; rm -rf ~" would run as a command of its own.
 * Only letters, numbers, '.', '_', '-' and '/' are allowed in file names, which the shell treats as plain text.
*/
int SafeFileName(const char *name){
    // grep would read a name starting with '-' as an option
    if(name[0] == '-'){
        return 0;
    }
    for(int i = 0; name[i] != '\0'; i++){
        char c = name[i];
        if(!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '.' || c == '_' || c == '-' || c == '/')){
            return 0;
        }
    }
    return 1;
}

int main(){
    char input_str[255], output_str[255];
    FILE *input_file;

    printf("Enter the name of the input file: ");
    // %254s keeps the name inside input_str
    if(scanf("%254s", input_str) != 1){
        return 1;
    }
    input_file = fopen(input_str, "r");
    if(input_file == NULL){
        fprintf(stderr, "Error opening input file: No such file or directory\n");
        exit(1);
    }
    fclose(input_file);

    printf("Enter the name of the output file for valid emails: ");
    if(scanf("%254s", output_str) != 1){
        return 1;
    }
    if(!SafeFileName(input_str) || !SafeFileName(output_str)){
        fprintf(stderr, "File names can only use letters, numbers, '.', '_', '-' and '/'\n");
        exit(1);
    }

    // big enough for the regex and both file names. snprintf stops at the end of the buffer, strcat could write past it
    char grep_command[1000];
    char valid_response[300];
    // usernames: letters, numbers, _ + and -, with single periods between the parts. then @, the domain, and a 2+ letter ending
    snprintf(grep_command, sizeof(grep_command), "grep -Eo \"^[a-zA-Z0-9_+-]+([.][a-zA-Z0-9_+-]+)*@[A-Za-z0-9-]+([.][A-Za-z0-9-]+)*\\.[A-Za-z]{2,}$\" %s > %s", input_str, output_str);
    snprintf(valid_response, sizeof(valid_response), "Valid emails extracted and saved to %s\n", output_str);

    // now we just execute a regular command line statement to our output file. if exists it overwrites else it creates a new file
    int success = system(grep_command);
    // fail
    if(success < 0){
        fprintf(stderr, "Failed to execute command\n");
        exit(1);
    // grep exits with 0 when it found emails and 1 when it found none, both mean it ran fine
    }else if(WIFEXITED(success) && WEXITSTATUS(success) <= 1){ // Successful execution
        printf("%s", valid_response);
    }else{ // executed but an error occured
        fprintf(stderr, "An error occured along the way\n");
        exit(1);
    }
    return 0;
}
