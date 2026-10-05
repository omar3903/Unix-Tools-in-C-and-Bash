/*
 * filecopy.c
 * Author: Omar Abdeen
 * Created on: 2024-01-26
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Usage: Copy contents of file input 1 to file input 2 .*/
int main(int argc, char* argv[]){
    FILE *in_file_ptr, *out_file_ptr;
    // int, not char, so EOF (-1) can't be mistaken for a real byte in the file
    int char_read;
    char response_str[1024];

    // Both an input and an output file are needed
    if(argc != 3){
        printf("Insufficient parameters passed.\n");
        exit(1);
    }
    // File pointers. Open the input first, so a missing input doesn't leave an empty output file behind
    in_file_ptr = fopen(argv[1], "r");
    if(in_file_ptr == NULL){
        printf("Error in opening files.\n");
        exit(1);
    }
    out_file_ptr = fopen(argv[2], "w");
    // Error loading files
    if(out_file_ptr == NULL){
        printf("Error in opening files.\n");
        fclose(in_file_ptr);
        exit(1);
    }

    // EOF represents End Of File. not exactly \n
    while((char_read = getc(in_file_ptr)) != EOF){
        putc(char_read, out_file_ptr);
    }
    // getc also returns EOF when reading fails, so check for read and write errors too
    if(ferror(in_file_ptr) || ferror(out_file_ptr)){
        printf("Error while copying the file.\n");
        fclose(in_file_ptr);
        fclose(out_file_ptr);
        exit(1);
    }
    fclose(in_file_ptr);
    fclose(out_file_ptr);

    // setting up the success response. snprintf stops at the end of the buffer, strcat could write past it with long file names
    snprintf(response_str, sizeof(response_str), "The contents of file %s have been successfully copied into the %s file.\n", argv[1], argv[2]);
    printf("%s", response_str);
    return 0;
}
