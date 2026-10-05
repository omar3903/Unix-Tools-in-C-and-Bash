/*
 * triangle.c
 * Author: Omar Abdeen
 * Created on: 2024-01-26
 */
#include <stdio.h>
#include <stdlib.h>

/*
 * This is a factorial function. helper function for BinomialCoefficient
 * long long, not int: row 14 needs 13!, which is 6,227,020,800 and past the int limit
*/
long long Factorial(int base){
    long long result = 1;
    int i = base;

    while(i > 1){
        result *= i;
        i--;
    }
    return result;
}

/*
 * This function merely implements the formula of the getting the binomial coefficient of n and k using helper function Factorial
*/
long long BinomialCoefficient(int n, int k){

    return Factorial(n) / (Factorial(k) * Factorial(n - k));
}

/*
* This is the main function of the program. Print the Pascal's Triangle.
*/
int main(){
    int value;

    // scan for integer input, if invalid input is detected, then terminate.
    printf("Please enter a value for the Pascal triangle\n");
    if(scanf("%d", &value) != 1 || value > 14 || value <= 0){
        printf("Invalid input. Please enter a positive Integer less than 15.\n");
        return 1;
    }
    // matrix nested for-loop to print pascal's triangle.
    for(int i = 0; i < value; i++){
        for(int j = 0; j <= i; j++){
            // Pascal's triangle is the collection of arrays of the binomial coefficients of each row.
            printf("%lld    ", BinomialCoefficient(i, j));
        }
        printf("\n");
    }
    return 0;
}
