/*
 * word_count.c
 * Author: Omar Abdeen
 * Created on: 2024-02-12
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(){
    FILE *txt_file_ptr;
    char input_str[5], txt_str[100];
    printf("This program counts the number of lines and words of a file\n");
    
    do
    {
        printf("Enter f for entering file name, q to quit: ");
        // %4s and %99s keep the input inside the arrays. End of input (Ctrl+D) quits instead of looping forever
        if(scanf("%4s", input_str) != 1){
            break;
        }

        if(strcmp(input_str, "f") == 0){
            printf("Enter file name: ");
            if(scanf("%99s", txt_str) != 1){
                break;
            }
            txt_file_ptr = fopen(txt_str, "r");
            if(txt_file_ptr == NULL){
                printf("%s cannot be opened\n\n", txt_str);
            }else{
                printf("Content of %s:\n\n", txt_str);
                // for more efficiency, create variables only in "f" mode when file is ready
                // also bigger files are more efficient with fgets rather than fgetc
                char curr_line[10000];
                int words = 0, lines = 0;
                float avg_words_per_line = 0.0;
                while(fgets(curr_line, 10000, txt_file_ptr) != NULL){
                    printf("%s", curr_line);
                    char *curr_str_token = strtok(curr_line, " \n\t ");
                    lines++;
                    while(curr_str_token != NULL){
                        words++;
                        // strtok(NULL) continues reading the line if not null
                        curr_str_token = strtok(NULL, " \n\t ");
                    }
                }
                // at this point end of file is reached.
                printf("\nNumber of lines of %s: %d\n", txt_str, lines);
                printf("Number of words of %s: %d\n", txt_str, words);
                if(lines == 0){
                    printf("Average number of words per line of %s: 0\n", txt_str);
                }else{
                    avg_words_per_line = (float) words / lines;
                    printf("Average number of words per line of %s: %.2f\n", txt_str, avg_words_per_line);
                
                }
                fclose(txt_file_ptr);
            }
        // a wrong command, tell the user and show the menu again
        }else if(strcmp(input_str, "q") != 0){
            printf("%s is not a command. Enter f or q\n\n", input_str);
        }
    } while (strcmp(input_str, "q") != 0);
    printf("Good bye\n");
    return 0;
    }