@echo on
set filename=%1

tasm /zi %filename%.asm
tlink /v %filename%.obj
%filename%.exe
