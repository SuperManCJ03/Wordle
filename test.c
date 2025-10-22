#include <stdio.h>
#include <stdlib.h>

// Corresponds to the .DATA section
#define BUF_SIZE 20
char BUFFER[BUF_SIZE]; // 20-byte storage (DB BUF_SIZE DUP (?))
int IDX = 0;           // current index (DW 0)

// Corresponds to the .CODE section and MAIN PROC
int main() {
    char input_char;

    // --- READ CHAR BY CHAR (READ_LOOP) ---
    // In Assembly:
    // MOV AH, 01H ; UNBUFFERED INPUT
    // INT 21H     ; AL = char, echoed

    // The 'do-while' loop is used to ensure at least one character read,
    // and mimics the 'JMP READ_LOOP' structure.
    do {
        // Read an unbuffered character and echo it to the screen,
        // similar to INT 21H, AH=01H.
        // We read it, and it's automatically echoed by the terminal/OS.
        input_char = getchar();

        // CMP AL, 13 (CR?) / JE PRINT_LOOP
        // Check for Carriage Return (Enter key)
        if (input_char == '\r' || input_char == '\n') {
            break; // Exit the read loop and jump to print
        }

        // Check if the buffer is full before storing
        if (IDX < BUF_SIZE) {
            // STORE AL INTO BUFFER[IDX]
            // MOV BX, IDX / MOV BUFFER[BX], AL
            BUFFER[IDX] = input_char;

            // INC IDX
            IDX++;
        }
        // else: If buffer is full, subsequent chars are just echoed but not stored.

    } while (1); // JMP READ_LOOP equivalent

    // Print a newline for better output formatting after the input loop ends
    // (since the user likely pressed 'Enter').
    putchar('\n');

    // --- PRINT_LOOP ---
    // MOV CX, IDX ; number of chars stored
    // MOV SI, OFFSET BUFFER

    // A standard C for loop is used for iteration.
    // The loop runs 'IDX' times, which is the number of characters stored.
    for (int i = 0; i < IDX; i++) {
        // PRINT_CHARS:
        // MOV DL, [SI]
        // MOV AH, 02H / INT 21H
        // INC SI
        // LOOP PRINT_CHARS

        // Print the character from the buffer at the current index 'i'
        putchar(BUFFER[i]);
    }

    // MOV AH, 4CH ; EXIT / INT 21H
    return EXIT_SUCCESS; // Standard C way to exit the program successfully
}