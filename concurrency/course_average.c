/*
Author: Omar Abdeen
Date: 4/8/2024
*/

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

// Note: the GradTA processes take turns so the averages print in order (1 to 6).
// The two TA threads inside each GradTA still work on their assignments at the same time.


struct TA{
    // 10 assignment grades for students, with an average
    int assignments[10];
    float avg;
};

// Thread function
void* average(void* curr_arg) {
    float total = 0;
    struct TA *curr_assignments = (struct TA*) curr_arg;
    for (int i = 0; i < 10; i++) {
        total += curr_assignments->assignments[i];
    }
    curr_assignments->avg = (float) total / 10;
    // Exit thread
    pthread_exit(NULL);
}

// Returns 0 if the file had all 60 grades, 1 if it ran out early
int process_grades(FILE *open_file, int input_matrix[3][2][10]) {
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 6; j++) {
            // First index for chapter, second index for assignment, if j is even then its the first assignment and vice versa.
            if (fscanf(open_file, "%d", &input_matrix[j / 2][j % 2][i]) != 1) {
                return 1;
            }
        }
    }
    return 0;
}

int main(int argc, char *argv[]) {
    // Invalid input check
    if (argv == NULL || argc != 2) {
        printf("Usage: ./course_average [sample_in_grades.txt]\n");
        return 1;
    }
    // Reading the input file
    FILE *file = fopen(argv[1], "r");
    if (file == NULL) {
        printf("Error opening the file. Try Again\n");
        return 1;
    }
    int student_matrix[3][2][10];
    if (process_grades(file, student_matrix) != 0) {
        printf("The file needs 10 rows of 6 grades\n");
        fclose(file);
        return 1;
    }
    fclose(file);

    for (int i = 0; i < 3; i++) {
        pid_t pid = fork();
        // Failure to create process
        if (pid < 0){
            printf("Failed to Fork\n");
            return 1;
        }
        else if (pid == 0) {
            // Each TA gets two threads to work on the 2 assignments they're given
            pthread_t TA_threads[2];
            struct TA curr_assignments[2];

            for (int j = 0; j < 2; j++) {
                for (int k = 0; k < 10; k++) {
                    curr_assignments[j].assignments[k] = student_matrix[i][j][k];
                }
                pthread_create(&TA_threads[j], NULL, average, (void*) &curr_assignments[j]);
            }

            pthread_join(TA_threads[0], NULL);
            pthread_join(TA_threads[1], NULL);
            printf("Assignment %d - Average = %.6f\n", (i * 2) + 1, curr_assignments[0].avg);
            printf("Assignment %d - Average = %.6f\n", (i * 2) + 2, curr_assignments[1].avg);

            return 0;
        }
        // Wait for this "GradTA" process to finish before starting the next one, so the output stays in order
        waitpid(pid, NULL, 0);
    }

    return 0;
}
