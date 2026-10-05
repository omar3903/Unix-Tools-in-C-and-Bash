/*
 * ticket.c
 * Author: Omar Abdeen
 * Created on: 2024-01-26
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Usage: Return ticket price based on time and age */
int main(){
    // 6 chars so "night" (5 letters and the '\0') fits
    char time[6];
    int age;

    printf("Enter the time: ");
    // %5s stops scanf from writing past the end of time
    if(scanf("%5s", time) != 1){
        return 1;
    }
    printf("Enter the age: ");
    if(scanf("%d", &age) != 1 || age < 0){
        printf("Invalid age\n");
        return 1;
    }

    if(age < 4){
        printf("free\n");
    // at this point age >= 4
    } else if (strcmp(time, "day") == 0){
        printf("$8\n");
    } else if (strcmp(time, "night") == 0){
        if(4 <= age && age <= 16){
            printf("$12\n");
        } else if(17 <= age && age <= 54){
            printf("$15\n");
        } else if(age >= 55){
            printf("$13\n");
        }
    } else {
        printf("Invalid time, enter day or night\n");
    }
    return 0;
}
