.MODEL SMALL

.STACK 64

; Constants for Video Modes
MODE_12 EQU 12H    ; 640x480, 16 colors (VGA)
BIOS_VIDEO_INT EQU 10H
DOS_INT EQU 21H

.DATA
    saveMode DB ?          ; To save the original video mode

    ; Box Dimensions and Gap Constants
    BOX_WIDTH EQU 75       ; Width of the box
    BOX_HEIGHT EQU 70      ; Height of the box
    BOX_GAP EQU 15         ; Horizontal gap between boxes

    ; Initial Box Coordinates
    START_X DW 100          ; Initial X coordinate for the first box
    START_Y DW 65          ; Fixed Y coordinate for the top edge
    BOX_COLOR DB 0EH       ; Yellow/High-Intensity

.CODE
main PROC

    MOV AX, @DATA
    MOV DS, AX

    ; 1. Save and Switch to graphics mode (Mode 12h: 640x480, 16 colors)
    MOV AH, 0FH        ; Get Current Video Mode
    INT BIOS_VIDEO_INT
    MOV saveMode, AL   ; Save it in AL

    MOV AH, 00H        ; Set Video Mode
    MOV AL, MODE_12
    INT BIOS_VIDEO_INT

    ; ------------------------------
    ; Setup for Drawing
    
    ; Setup for pixel drawing function (INT 10h, AH=0Ch)
    MOV AH, 0CH
    MOV AL, BOX_COLOR  ; Set the color (Yellow)
    MOV BH, 0          ; Video Page 0
    
    ; ------------------------------
    ; Main 5-Box Loop Initialization
    
    MOV BX, 5          ; BX = Loop counter (5 boxes total)
    MOV SI, START_X    ; SI holds the current X_start (starts at 75)
    MOV DI, START_Y    ; DI holds the fixed Y_start (65)

OUTER_BOX_LOOP:

    MOV DI, START_Y    ; Reset the height value of the box to the initial value each loop
    
    ; Calculate the current box boundaries using SI (X_start) and DI (Y_start)
    ; X_start = SI
    ; Y_start = DI
    ; X_end = SI + BOX_WIDTH
    ; Y_end = DI + BOX_HEIGHT
    
    PUSH BX                    ; Save outer loop counter BX

    ; Calculate X_end and Y_end and store them in CX and DX temporarily
    MOV CX, SI                 ; CX = X_start (SI)
    ADD CX, BOX_WIDTH          ; CX = X_end
    
    MOV DX, DI                 ; DX = Y_start (DI)
    ADD DX, BOX_HEIGHT         ; DX = Y_end
    
    ; Store the calculated end coordinates in DI (X_end) and BP (Y_end)
    MOV DI, CX                 ; DI now holds X_end
    MOV BP, DX                 ; BP now holds Y_end

    ; The calculated ends are now stored in DI (X_end) and BP (Y_end)
    ; This avoids unreliable stack indexing (e.g., [SP+12])

    ; Set pixel draw parameters again (safety first)
    MOV AH, 0CH
    MOV AL, BOX_COLOR
    MOV BH, 0
    
    ; ---------------------------------------------------------------------------------
    ; 1. Draw TOP Line: Y fixed at Y_start (START_Y), X loops X_start (SI) to X_end (DI)
    
    MOV DX, START_Y            ; DX = Fixed Y (Row)
    MOV CX, SI                 ; CX = X_start (Column)


; draws the top edge of the box, from left to right
TOP_LINE_LOOP:
    CMP CX, DI                 ; Compare X (CX) with X_end (DI)
    JAE END_TOP_LINE           ; Jump if CX >= DI (Jump if Above or Equal)
    
    INT BIOS_VIDEO_INT         ; Draw pixel (CX, DX)
    
    INC CX                     ; X++
    JMP TOP_LINE_LOOP
    
END_TOP_LINE:

    ; -----------------------------------------------------------------------------
    ; 2. Draw BOTTOM Line: Y fixed at Y_end (BP), X loops X_start (SI) to X_end (DI)
    
    MOV DX, BP                 ; DX = Fixed Y (Y_end)
    MOV CX, SI                 ; CX = X_start (Column)
    

; draws the bottom edge, from left to right
BOTTOM_LINE_LOOP:
    CMP CX, DI                 ; Compare X (CX) with X_end (DI)
    JAE END_BOTTOM_LINE        ; Jump if CX >= DI
    
    INT BIOS_VIDEO_INT         ; Draw pixel (CX, DX)
    
    INC CX                     ; X++
    JMP BOTTOM_LINE_LOOP
    
END_BOTTOM_LINE:

    ; -----------------------------------------------------------------------------
    ; 3. Draw LEFT Line: X fixed at X_start (SI), Y loops Y_start (DI) to Y_end (BP)
    
    MOV CX, SI                 ; CX = Fixed X (Column)
    MOV DX, START_Y            ; DX = Y_start (Row)


; draws the left edge, from top to bottom
LEFT_LINE_LOOP:
    CMP DX, BP                 ; Compare Y (DX) with Y_end (BP)
    JAE END_LEFT_LINE          ; Jump if DX >= BP
    
    INT BIOS_VIDEO_INT         ; Draw pixel (CX, DX)
    
    INC DX                     ; Y++
    JMP LEFT_LINE_LOOP
    
END_LEFT_LINE:

    ; -----------------------------------------------------------------------------
    ; 4. Draw RIGHT Line: X fixed at X_end (DI), Y loops Y_start (DI) to Y_end (BP)
    
    MOV CX, DI                 ; CX = Fixed X (X_end)
    MOV DX, START_Y            ; DX = Y_start (Row)

; draws the right edge, from top to bottom
RIGHT_LINE_LOOP:
    CMP DX, BP                 ; Compare Y (DX) with Y_end (BP)
    JAE END_RIGHT_LINE         ; Jump if DX >= BP
    
    INT BIOS_VIDEO_INT         ; Draw pixel (CX, DX)
    
    INC DX                     ; Y++
    JMP RIGHT_LINE_LOOP
    
END_RIGHT_LINE:

    ; Update X position for the next box
    ADD SI, BOX_WIDTH          ; SI = SI + 75 (move past the box)
    ADD SI, BOX_GAP            ; SI = SI + 15 (add the gap)
    
    POP BX                     ; Restore outer loop counter BX
    DEC BX                     ; Decrement the loop counter
    JNE OUTER_BOX_LOOP         ; Jump if counter (BX) is not zero.
    
    ; Program Exit
    
    ; 3. Wait for a keystroke to keep the image visible
    MOV AH, 00H
    INT 16H            ; Waits for any key press

    ; 4. Restore original video mode
    MOV AH, 00H        ; Set Video Mode
    MOV AL, saveMode   ; Load the saved mode
    INT BIOS_VIDEO_INT

    ; 5. Exit Program 
    MOV AX, 4C00H
    INT DOS_INT

main ENDP
END main
