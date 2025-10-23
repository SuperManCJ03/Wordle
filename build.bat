@ECHO OFF
TASM mainModu\wordle.asm
TASM services\drawbox.asm

TLINK wordle.obj+drawbox.obj
wordle