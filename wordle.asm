.MODEL SMALL

.STACK 64

; Constants for Video Modes
MODE_12 EQU 12H    ; 640x480, 16 colors (VGA)
BIOS_VIDEO_INT EQU 10H

.MODEL SMALL

.STACK 64

; Constants for Video Modes
MODE_12 EQU 12H    ; 640x480, 16 colors (VGA)
BIOS_VIDEO_INT EQU 10H
DOS_INT EQU 21H

; external procedure that draws all boxes
EXTRN DrawBoxes:NEAR

; -------------------------------------------------------
; flow summary (current build)
; - switch to graphics mode
; - call drawboxes (draws one row of 5 boxes)
; - wait for key, restore mode, exit
; -------------------------------------------------------

.DATA
    saveMode DB ?          ; to save the original video mode

.CODE
main PROC
    MOV saveMode, AL   ; Save it in AL

    MOV AH, 00H        ; Set Video Mode
    MOV AL, MODE_12
    INT BIOS_VIDEO_INT

    ; draw all boxes (separate module)
    CALL DrawBoxes
    
    ; program exit
    ; wait for a keystroke to keep the image visible
    MOV AH, 00H
    INT 16H            ; Waits for any key press

    ; restore original video mode
    MOV AH, 00H        ; Set Video Mode
    MOV AL, saveMode   ; Load the saved mode
    INT BIOS_VIDEO_INT

    ; exit program 
    MOV AX, 4C00H
    INT DOS_INT

main ENDP
END main
