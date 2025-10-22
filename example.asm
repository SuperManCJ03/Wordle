; Filename: BUFECHO.ASM
; Assembler: TASM (Turbo Assembler)
; Purpose: Reads a line of input, stores it in a buffer, and prints it.

.MODEL TINY ; Use the TINY model for a .COM executable (Code and Data in one segment)
.CODE       ; Start of the code segment

ORG 100H    ; Code starts at offset 100h for .COM programs

; --- Data Definitions ---
BUF_SIZE EQU 20
BUFFER DB BUF_SIZE DUP (?) ; Character array (20 uninitialized bytes)
IDX    DW 0               ; Index variable (2-byte Word initialized to 0)

MAIN PROC
    ; --- DO-WHILE LOOP (Character Input and Storage) ---
INPUT_LOOP:
    ; 1. input_char = getchar();
    
    MOV AH, 07H      ; DOS Function: Direct Character Input without Echo
    INT 21H          ; AL now holds the input character (input_char)
    
    ; 2. if (input_char == '\r' || input_char == '\n') { break; }
    
    CMP AL, 0DH      ; Compare input_char with Carriage Return (\r)
    JE END_INPUT     ; If AL == '\r', exit the loop
    
    CMP AL, 0AH      ; Compare input_char with Line Feed (\n)
    JE END_INPUT     ; If AL == '\n', exit the loop

    ; 3. if (IDX < BUF_SIZE) { ... }
    
    MOV BX, IDX      ; Load current index value into BX
    CMP BX, BUF_SIZE ; Compare index (BX) with BUF_SIZE (20)
    JGE INPUT_LOOP   ; If BX >= BUF_SIZE, skip storage and continue the loop

    ; 4. BUFFER[IDX] = input_char;
    
    MOV BYTE PTR [BUFFER + BX], AL ; Store AL at BUFFER address + offset BX

    ; 5. IDX++;
    
    INC IDX          ; Increment the index variable (2-byte Word)

    JMP INPUT_LOOP   ; Continue the loop
    
END_INPUT:
    
    ; --- Print Newline (putchar('\n')) ---
    
    MOV DL, 0AH      ; Load Line Feed character (\n) into DL
    MOV AH, 02H      ; DOS Function: Display Character
    INT 21H          ; Print the character (newline)

    ; --- FOR LOOP (Print Buffer Contents) ---
    
    MOV CX, 0        ; Initialize loop counter i = 0 (using CX for i)
    MOV BX, IDX      ; Load loop limit (IDX) into BX (Note: BX is used for limit here)
    
PRINT_LOOP:
    CMP CX, BX       ; Compare i (CX) with IDX limit (BX)
    JGE END_PROGRAM  ; If CX >= BX, exit the loop

    ; 1. putchar(BUFFER[i]);
    
    ; The address of BUFFER + i is [BUFFER + CX]
    MOV DL, BYTE PTR [BUFFER + CX] ; Load character BUFFER[i] into DL
    MOV AH, 02H                    ; DOS Function: Display Character
    INT 21H                        ; Print the character

    ; 2. i++
    
    INC CX           ; Increment the loop counter (i)
    JMP PRINT_LOOP   ; Continue the loop

END_PROGRAM:
    ; --- return EXIT_SUCCESS; ---
    
    MOV AH, 4CH      ; DOS Function: Terminate Program
    MOV AL, 00H      ; Set return code to 0 (EXIT_SUCCESS)
    INT 21H          ; Execute the termination
    
MAIN ENDP
END MAIN           ; End of program