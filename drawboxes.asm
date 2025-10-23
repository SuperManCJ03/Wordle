; draws a row of 5 boxes in mode 12h (640x480x16)
; uses bios int 10h, ah=0ch to plot pixels
; assumes ds is set by caller; no parameters needed

.MODEL SMALL

; box settings
BOX_WIDTH  EQU 75
BOX_HEIGHT EQU 70
BOX_GAP    EQU 15
START_X    EQU 100
START_Y    EQU 65
BOX_COLOR  EQU 0Eh    ; yellow/high-intensity

.CODE
PUBLIC DrawBoxes
DrawBoxes PROC NEAR

    ; setup for pixel drawing (int 10h, ah=0ch)
    MOV AH, 0Ch
    MOV AL, BOX_COLOR  ; color
    MOV BH, 0          ; video page 0

    ; main 5-box loop
    MOV BX, 5          ; loop counter (5 boxes)
    MOV SI, START_X    ; current x_start
    MOV DI, START_Y    ; current y_start (fixed for this row)

OUTER_BOX_LOOP:
    ; reset y_start each iteration
    MOV DI, START_Y

    PUSH BX                    ; save outer loop counter

    ; compute ends
    MOV CX, SI                 ; cx = x_start
    ADD CX, BOX_WIDTH          ; cx = x_end

    MOV DX, DI                 ; dx = y_start
    ADD DX, BOX_HEIGHT         ; dx = y_end

    MOV DI, CX                 ; di = x_end
    MOV BP, DX                 ; bp = y_end

    ; safety: set pixel params again
    MOV AH, 0Ch
    MOV AL, BOX_COLOR
    MOV BH, 0

    ; top edge: y = start_y, x = [si .. di)
    MOV DX, START_Y
    MOV CX, SI
TOP_LINE_LOOP:
    CMP CX, DI
    JAE END_TOP_LINE
    INT 10h
    INC CX
    JMP TOP_LINE_LOOP
END_TOP_LINE:

    ; bottom edge: y = y_end, x = [si .. di)
    MOV DX, BP
    MOV CX, SI
BOTTOM_LINE_LOOP:
    CMP CX, DI
    JAE END_BOTTOM_LINE
    INT 10h
    INC CX
    JMP BOTTOM_LINE_LOOP
END_BOTTOM_LINE:

    ; left edge: x = x_start, y = [start_y .. y_end)
    MOV CX, SI
    MOV DX, START_Y
LEFT_LINE_LOOP:
    CMP DX, BP
    JAE END_LEFT_LINE
    INT 10h
    INC DX
    JMP LEFT_LINE_LOOP
END_LEFT_LINE:

    ; right edge: x = x_end, y = [start_y .. y_end)
    MOV CX, DI
    MOV DX, START_Y
RIGHT_LINE_LOOP:
    CMP DX, BP
    JAE END_RIGHT_LINE
    INT 10h
    INC DX
    JMP RIGHT_LINE_LOOP
END_RIGHT_LINE:

    ; advance x for next box
    ADD SI, BOX_WIDTH
    ADD SI, BOX_GAP

    POP BX
    DEC BX
    JNE OUTER_BOX_LOOP

    RET
DrawBoxes ENDP

END
