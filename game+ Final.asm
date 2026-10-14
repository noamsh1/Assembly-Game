IDEAL
MODEL small
STACK 100h
DATASEG
	isGame db 1
	isDemo db 0
	isMultiplayer db 0
	BACKGROUND_COLOR equ 0 ; black
	PLAYER_X equ 154
	PLAYER_Y equ 94
	PLAYER_LENGTH_X equ 13
	PLAYER_LENGTH_Y equ 13
	PLAYER_COLOR equ 1 ; blue
	SHIELD_COLOR equ 2 ; green
	shieldSide dw ?
	SHIELD_2_DISTANCE_FROM_PLAYER equ 25
	shield2Side dw ?
	bulletSpawnSide dw ? ; up - 0, right - 1, down - 2, left - 3
	bulletColor dw 4
	BULLET_SPAWN_UP_DOWN_X equ 159
	BULLET_SPAWN_UP_Y equ 0
	BULLET_SPAWN_RIGHT_X equ 315
	BULLET_SPAWN_RIGHT_LEFT_Y equ 99
	BULLET_SPAWN_DOWN_Y equ 195
	BULLET_SPAWN_LEFT_X equ 0
	BULLET_LENGTH equ 5
	BULLET_WIDTH equ 3
	bulletX dw ?
	bulletY dw ?
	bulletSide dw ?
	currentRandomNum dw ?
	SEQUENCE_SEED equ 0E2A9h
	currentSequenceValue dw 0
	Clock equ [es:6Ch]
	SCORE_INC_SOUND_NOTE equ 0E24h
	SCORE_INC_SOUND_TICKS equ 1
	PLAYER_HIT_SOUND_NOTE equ 7121h
	PLAYER_HIT_SOUND_TICKS equ 9
	currentTick dw ?
	INITIAL_SPEED equ 2
	MAX_SPEED equ 12
	BULLET_COUNT_MULTIPLIER equ 5
	bulletDistanceFromPlayer dw ?
	currentDistanceFromPlayer dw ?
	bulletSpeed dw ?
	score dw ?
	MAX_SCORE equ 9999
	targetScoreForSpeedInc dw ?
	scoreMessage db "Score: $"
	scoreArray db 4 dup('0')
	
	startMessage db "",13,10
				 db "", 13,10
				 db "", 13,10
				 db "", 13,10
				 db "", 13,10
				 db "    ____        ____     __     ____  __           __  ", 13,10
				 db "   / __ )__  __/ / /__  / /_   / __ )/ /___  _____/ /__", 13,10
				 db "  / __  / / / / / / _ \/ __/  / __  / / __ \/ ___/ //_/", 13,10
				 db " / /_/ / /_/ / / /  __/ /_   / /_/ / / /_/ / /__/ ,<   ", 13,10
				 db "/_____/\__,_/_/_/\___/\__/  /_____/_/\____/\___/_/|_|  ", 13,10
				 db "", 13,10
				 db "", 13,10
				 db "Rules: Move the shield around the player to block the bullets.", 13,10
				 db "", 13,10				 
				 db "Controls: Use w,a,s,d (w - up, d - right, s - down, a - left)", 13,10
				 db "", 13,10
				 db "", 13,10
				 db "Press P to play", 13,10
				 db "Press D for demo", 13,10
				 db "Press M for multiplayer (second player uses i,j,k,l keys)", 13,10
				 db "Press Esc to exit", 13,10
				 db "$", 13,10
				 
	gameOverMessage db "",13,10
					db "",13,10
					db "",13,10
					db "",13,10
					db "",13,10
					db "   _________    __  _________   ____ _    ____________ ",13,10
					db "  / ____/   |  /  |/  / ____/  / __ \ |  / / ____/ __ \",13,10
					db " / / __/ /| | / /|_/ / __/    / / / / | / / __/ / /_/ /",13,10
					db "/ /_/ / ___ |/ /  / / /___   / /_/ /| |/ / /___/ _, _/ ",13,10
					db "\____/_/  |_/_/  /_/_____/   \____/ |___/_____/_/ |_|  ",13,10
					db "",13,10
					db "",13,10
					db "$"
	gameOverInstruc db "",13,10
					db "",13,10
					db "",13,10					
					db "Press P to play again",13,10
					db "Press M to play multiplayer",13,10					
					db "Press Esc to exit",13,10
					db "$"
CODESEG

proc PrintPixel
	; parameters: [color], [y], [x]
	PrintPixelColor equ [bp + 8]
	PrintPixelY equ [bp + 6]
	PrintPixelX equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	push bx
	push cx
	push dx
	mov bh,0h
	mov cx, PrintPixelX
	mov dx, PrintPixelY
	mov ax, PrintPixelColor
	mov ah,0ch
	int 10h
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
	endp PrintPixel

proc HorizontalLine
	; parameters: [color], [y], [lengthX], [x]
	HorizLineColor equ [bp + 10]
	HorizLineY equ [bp + 8]
	HorizLineLength equ [bp + 6]
	HorizLineX equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push cx
	push ax
	mov cx, HorizLineLength
	mov ax, HorizLineX
HorizontalPixelLoop:
	push HorizLineColor
	push HorizLineY
	push ax
	call PrintPixel
	inc ax
	loop HorizontalPixelLoop
	; restore registers
	pop ax
	pop cx
	pop bp
	ret 8
	endp HorizontalLine
	
proc VerticalLine
	; parameters: [color], [x], [LengthY], [y]
	VerticalColor equ [bp + 10]
	VerticalLineX equ [bp + 8]
	VerticalLineLength equ [bp + 6]
	VerticalLineY equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push cx
	push ax
	mov cx, VerticalLineLength
	mov ax, VerticalLineY
	VerticalPixelLoop:
		push VerticalColor
		push ax
		push VerticalLineX
		call PrintPixel
		inc ax
		loop VerticalPixelLoop
	; restore registers
	pop ax
	pop cx
	pop bp
	ret 8
	endp VerticalLine

proc Rectangle
	; parameters: [color], [x], [y], [lengthX], [lengthY]
	; The point is the left and up vertex
	RectangleColor equ [bp + 12]
	RectanglePointX equ [bp + 10]
	RectanglePointY equ [bp + 8]
	RectangleLengthX equ [bp + 6]
	RectangleLengthY equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	push bx
	push cx
	push dx
	mov ax, RectanglePointX
	mov bx, RectangleLengthX
	mov dx, RectanglePointY
	mov cx, RectangleLengthY
	RectanglePixelLoop:
		push RectangleColor
		push dx
		push bx
		push ax
		call HorizontalLine
		inc dx
		loop RectanglePixelLoop
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10
	endp Rectangle
	
proc RandomNum
	; parameters: none
	; save registers
	push ax
	push cx
	push dx
	; square current random number
	mov ax, [currentRandomNum]
	mul ax
	; calculate next iteration of Weyl sequence
	mov cx, [currentSequenceValue]
    add cx, SEQUENCE_SEED  
	mov [currentSequenceValue], cx
    ; add Weyl sequence
	add ax, cx
    ; get lower byte of random number from higher byte of ax
    mov al, ah
	; get higher byte of random number from lower byte of dx
    mov ah, dl  
	mov [currentRandomNum], ax
    ; use the 2 lower bits of the new random number stored in ax
	and al, 00000011b
	xor ah, ah
	mov [bulletSpawnSide], ax
	; restore registers
	pop dx
	pop cx
	pop ax
	ret
	endp RandomNum

proc DrawShield
	; parameters: [color], [side]
	DrawShieldColor equ [bp + 6]
	DrawShieldSide equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	mov ax, DrawShieldSide
	push DrawShieldColor
DrawShieldCheckUp:
	cmp ax, 0
	jne DrawShieldCheckRight
	mov ax, PLAYER_Y
	dec ax
	push ax
	push PLAYER_LENGTH_X
	push PLAYER_X
	call HorizontalLine
	jmp ExitDrawShield
DrawShieldCheckRight:
	cmp ax, 1
	jne DrawShieldCheckDown
	mov ax, PLAYER_X
	add ax, PLAYER_LENGTH_X
	push ax
	push PLAYER_LENGTH_Y
	push PLAYER_Y
	call VerticalLine
	jmp ExitDrawShield
DrawShieldCheckDown:
	cmp ax, 2
	jne DrawShieldLeft
	mov ax, PLAYER_Y
	add ax, PLAYER_LENGTH_Y
	push ax
	push PLAYER_LENGTH_X
	push PLAYER_X
	call HorizontalLine
	jmp ExitDrawShield
DrawShieldLeft:
	mov ax, PLAYER_X
	dec ax
	push ax
	push PLAYER_LENGTH_Y
	push PLAYER_Y
	call VerticalLine
ExitDrawShield:
	; restore registers
	pop ax
	pop bp
	ret 4
	endp DrawShield

proc DrawShield2
	; parameters: [color], [side]
	DrawShield2Color equ [bp + 6]
	DrawShield2Side equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	mov ax, DrawShield2Side
	push DrawShield2Color
DrawShield2CheckUp:
	cmp ax, 0
	jne DrawShield2CheckRight
	mov ax, PLAYER_Y
	dec ax
	sub ax, SHIELD_2_DISTANCE_FROM_PLAYER
	push ax
	push PLAYER_LENGTH_X
	push PLAYER_X
	call HorizontalLine
	jmp ExitDrawShield2
DrawShield2CheckRight:
	cmp ax, 1
	jne DrawShield2CheckDown
	mov ax, PLAYER_X
	add ax, PLAYER_LENGTH_X
	add ax, SHIELD_2_DISTANCE_FROM_PLAYER
	push ax
	push PLAYER_LENGTH_Y
	push PLAYER_Y
	call VerticalLine
	jmp ExitDrawShield2
DrawShield2CheckDown:
	cmp ax, 2
	jne DrawShield2Left
	mov ax, PLAYER_Y
	add ax, PLAYER_LENGTH_Y
	add ax, SHIELD_2_DISTANCE_FROM_PLAYER
	push ax
	push PLAYER_LENGTH_X
	push PLAYER_X
	call HorizontalLine
	jmp ExitDrawShield2
DrawShield2Left:
	mov ax, PLAYER_X
	dec ax
	sub ax, SHIELD_2_DISTANCE_FROM_PLAYER
	push ax
	push PLAYER_LENGTH_Y
	push PLAYER_Y
	call VerticalLine
ExitDrawShield2:
	; restore registers
	pop ax
	pop bp
	ret 4
	endp DrawShield2
	
proc MoveShield
	; parameters: [side], [shieldNum]
	MoveShieldSide equ [bp + 6]
	MoveShieldNum equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	; check which shield need to be moved
	mov ax, MoveShieldNum
	cmp ax, 2
	je MoveShield2
	; move shield 1
	; erase the current shield
	push BACKGROUND_COLOR
	push [shieldSide]
	call DrawShield
	; draw the new shield
	push SHIELD_COLOR
	push MoveShieldSide
	call DrawShield
	; update shieldSide
	mov ax, MoveShieldSide
	mov [shieldSide], ax
	jmp ExitMoveShield
MoveShield2:
	; erase the current shield
	push BACKGROUND_COLOR
	push [shield2Side]
	call DrawShield2
	; draw the new shield
	push SHIELD_COLOR
	push MoveShieldSide
	call DrawShield2
	; update shieldSide
	mov ax, MoveShieldSide
	mov [shield2Side], ax
ExitMoveShield:
	; restore registers
	pop ax
	pop bp
	ret 4
	endp MoveShield
	
proc AddBullet
	; paremeters: [side]
	SpawnSide equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	push bx
	push dx
	mov dx, SpawnSide
	push [bulletColor]
CheckUp:
	cmp dx, 0
	jne CheckRight
	; print the bullet on the up spawn
	push BULLET_SPAWN_UP_DOWN_X
	push BULLET_SPAWN_UP_Y
	push BULLET_WIDTH
	push BULLET_LENGTH
	call Rectangle
	mov ax, BULLET_SPAWN_UP_DOWN_X
	mov bx, BULLET_SPAWN_UP_Y
	jmp EndAddBullet
CheckRight:
	cmp dx, 1
	jne CheckDown
	; print the bullet on the right spawn
	push BULLET_SPAWN_RIGHT_X
	push BULLET_SPAWN_RIGHT_LEFT_Y
	push BULLET_LENGTH
	push BULLET_WIDTH
	call Rectangle
	mov ax, BULLET_SPAWN_RIGHT_X
	mov bx, BULLET_SPAWN_RIGHT_LEFT_Y
	jmp EndAddBullet
CheckDown:
	cmp dx, 2
	jne Left
	; print the bullet on the down spawn
	push BULLET_SPAWN_UP_DOWN_X
	push BULLET_SPAWN_DOWN_Y
	push BULLET_WIDTH
	push BULLET_LENGTH
	call Rectangle
	mov ax, BULLET_SPAWN_UP_DOWN_X
	mov bx, BULLET_SPAWN_DOWN_Y
	jmp EndAddBullet
Left:
	; print the bullet on the left spawn
	push BULLET_SPAWN_LEFT_X
	push BULLET_SPAWN_RIGHT_LEFT_Y
	push BULLET_LENGTH
	push BULLET_WIDTH
	call Rectangle
	mov ax, BULLET_SPAWN_LEFT_X
	mov bx, BULLET_SPAWN_RIGHT_LEFT_Y
EndAddBullet:
	mov [bulletSide], dx
	mov [bulletX], ax
	mov [bulletY], bx
	; restore registers
	pop dx
	pop bx
	pop ax
	pop bp
	ret 2
	endp AddBullet

proc SpawnBullet
	; parameters: none
	call RandomNum
	push [bulletSpawnSide]
	call AddBullet
	cmp [isDemo], 1
	jne EndSpawnBullet
	; demo mode
	push [bulletSpawnSide]
	push 1
	call MoveShield
EndSpawnBullet:
	ret
	endp SpawnBullet
	
proc MoveBullet
	; parameters: [bulletSpeed], [side], [y], [x]
	MovementSpeed equ [bp + 10]
	MoveBulletSide equ [bp + 8]
	MoveBulletY equ [bp + 6]
	MoveBulletX equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	push bx
	push cx
	push dx
	mov ax, MoveBulletX
	mov bx, MoveBulletY
	mov cx, MovementSpeed
	mov dx, MoveBulletSide
	; checking which side the bullet is coming from
CheckMoveDown:
	cmp dx, 0
	jne CheckMoveLeft
MoveDownLoop:
	; erasing the last row
	push BACKGROUND_COLOR
	push bx
	push BULLET_WIDTH
	push MoveBulletX
	call HorizontalLine
	; adding a row
	add bx, BULLET_LENGTH
	push [bulletColor]
	push bx
	push BULLET_WIDTH
	push MoveBulletX
	call HorizontalLine
	sub bx, BULLET_LENGTH
	inc bx
	loop MoveDownLoop
	jmp ExitMoveBullet
CheckMoveLeft:
	cmp dx, 1
	jne CheckMoveUp
MoveLeftLoop:
	; erasing the last column
	add ax, BULLET_LENGTH
	dec ax
	push BACKGROUND_COLOR
	push ax
	push BULLET_WIDTH
	push MoveBulletY
	call VerticalLine
	; adding a column
	sub ax, BULLET_LENGTH
	push [bulletColor]
	push ax
	push BULLET_WIDTH
	push MoveBulletY
	call VerticalLine
	loop MoveLeftLoop
	jmp ExitMoveBullet
CheckMoveUp:
	cmp dx, 2
	jne MoveRight
MoveUpLoop:
	; erasing the last row
	add bx, BULLET_LENGTH
	dec bx
	push BACKGROUND_COLOR
	push bx
	push BULLET_WIDTH
	push MoveBulletX
	call HorizontalLine
	; adding a row
	sub bx, BULLET_LENGTH
	push [bulletColor]
	push bx
	push BULLET_WIDTH
	push MoveBulletX
	call HorizontalLine
	loop MoveUpLoop
	jmp ExitMoveBullet
MoveRight:
	; erasing the last column
	push BACKGROUND_COLOR
	push ax
	push BULLET_WIDTH
	push MoveBulletY
	call VerticalLine
	; adding a column
	add ax, BULLET_LENGTH
	push [bulletColor]
	push ax
	push BULLET_WIDTH
	push MoveBulletY
	call VerticalLine
	sub ax, BULLET_LENGTH
	inc ax
	loop MoveRight
ExitMoveBullet:
	mov [bulletSide], dx
	mov [bulletX], ax
	mov [bulletY], bx
	; restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 8
	endp MoveBullet
	
proc CheckDistanceFromPlayer
	; parameters: [bulletSide], [moveDistance], [bulletX], [bulletY]
	CheckDisBulletSide equ [bp + 10]
	CheckDisMoveDistance equ [bp + 8]
	CheckDisBulletX equ [bp + 6]
	CheckDisBulletY equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	push bx
	push dx
	mov dx, CheckDisBulletSide
CheckDisMoveDown:
	cmp dx, 0
	jne CheckDisMoveLeft
	mov ax, PLAYER_Y
	dec ax
	mov bx, CheckDisBulletY
	add bx, BULLET_LENGTH
	add bx, CheckDisMoveDistance
	jmp ExitCheckDis
CheckDisMoveLeft:
	cmp dx, 1
	jne CheckDisMoveUp
	mov ax, CheckDisBulletX
	sub ax, CheckDisMoveDistance
	mov bx, PLAYER_X
	add bx, PLAYER_LENGTH_X
	jmp ExitCheckDis
CheckDisMoveUp:
	cmp dx, 2
	jne CheckDisMoveRight
	mov ax, CheckDisBulletY
	sub ax, CheckDisMoveDistance
	mov bx, PLAYER_Y
	add bx, PLAYER_LENGTH_Y
	jmp ExitCheckDis
CheckDisMoveRight:
	mov ax, PLAYER_X
	dec ax
	mov bx, CheckDisBulletX
	add bx, BULLET_LENGTH
	add bx, CheckDisMoveDistance
ExitCheckDis:
	sub ax, bx
	mov [bulletDistanceFromPlayer], ax
	; restore registers
	pop dx
	pop bx
	pop ax
	pop bp
	ret 8
	endp CheckDistanceFromPlayer

proc EraseBullet
	; parameters: none
	push bp
	mov bp, sp
	; save registers
	push ax
	; erasing the bullet
	push BACKGROUND_COLOR
	push [bulletX]
	push [bulletY]
EraseUp:
	cmp [bulletSide], 0
	jne EraseRight
	push BULLET_WIDTH
	push BULLET_LENGTH
	jmp EndEraseBullet
EraseRight:
	cmp [bulletSide], 1
	jne EraseDown
	push BULLET_LENGTH
	push BULLET_WIDTH
	jmp EndEraseBullet
EraseDown:
	cmp [bulletSide], 2
	jne EraseLeft
	push BULLET_WIDTH
	push BULLET_LENGTH
	jmp EndEraseBullet
EraseLeft:
	push BULLET_LENGTH
	push BULLET_WIDTH
	jmp EndEraseBullet
EndEraseBullet:
	call Rectangle
	; restore registers
	pop ax
	pop bp
	ret
	endp EraseBullet
	
proc PrintScore
	; parameters: none
	; save registers
	push ax
	push dx
	push cx
	push di
	; return to the start of the line
	mov dl, 13
	mov ah, 2
	int 21h
	; print scoreMessage
	mov dx, offset scoreMessage
	mov ah, 9
	int 21h
	; print scoreArray
	mov cx, 4
	mov di, offset scoreArray
ScoreArrayLoop:
	mov dl, [di]
	mov ah, 2
	int 21h
	inc di
	loop ScoreArrayLoop
	; restore registers
	pop di
	pop cx
	pop dx
	pop ax
	ret
	endp PrintScore
	
proc UpdateScoreArray
	; parameters: none
CheckOnes:
	cmp [scoreArray + 3], '9'
	je CheckTens
	; first digit isn't 9
	inc [scoreArray + 3]
	jmp EndUpdateScoreArray
CheckTens:
	; the first digit is 9
	cmp [scoreArray + 2], '9'
	je CheckHundreds
	; the second digit isn't 9
	inc [scoreArray + 2]
	mov [scoreArray + 3], '0'
	jmp EndUpdateScoreArray
CheckHundreds:
	; the first and second digits are 9
	cmp [scoreArray + 1], '9'
	je CheckThousands
	; third digit isn't 9
	inc [scoreArray + 1]
	mov [scoreArray + 2], '0'
	mov [scoreArray + 3], '0'
	jmp EndUpdateScoreArray
CheckThousands:
	; first, second and third digits are 9
	inc [scoreArray]
	mov [scoreArray + 1], '0'
	mov [scoreArray + 2], '0'
	mov [scoreArray + 3], '0'
EndUpdateScoreArray:
	ret
	endp UpdateScoreArray
	
proc TryIncSpeed
	; parameters: none
	; save registers
	push ax
	push dx
	; check if max speed reached
	mov ax, MAX_SPEED
	cmp ax, [bulletSpeed]
	je EndTryIncSpeed
	; check if target score for speed increase is reached
	mov ax, [score]
	cmp ax, [targetScoreForSpeedInc]
	jne EndTryIncSpeed
	; increase speed
	inc [bulletSpeed]
	; update target score for speed increase
	; targetScoreForSpeedInc += Multiplier * bulletSpeed
	mov ax, BULLET_COUNT_MULTIPLIER
	mul [bulletSpeed]
	add [targetScoreForSpeedInc], ax
EndTryIncSpeed:
	; restore registers
	pop dx
	pop ax
	ret
	endp TryIncSpeed

proc UpdateScore
	; parameters: none
	inc [score]
	call UpdateScoreArray
	call PrintScore
	; play score inc sound
	push SCORE_INC_SOUND_NOTE
	push SCORE_INC_SOUND_TICKS
	call PlaySound
	; check if speed increase is needed
	call TryIncSpeed
	cmp [score], MAX_SCORE
	jne EndUpdateScore
	; Player wins
	mov [isGame], 0
EndUpdateScore:
	ret
	endp UpdateScore
	
proc PlaySound
	; parameters: [note], [ticks]
	PlaySoundNote equ [bp + 6]
	PlaySoundTicks equ [bp + 4]
	push bp
	mov bp, sp
	; save registers
	push ax
	; open speaker
	in al, 61h
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play the note
	mov ax, PlaySoundNote
	; Sending lower byte
	out 42h, al 
	mov al, ah
	; Sending upper byte
	out 42h, al 
	; waiting for given number of ticks
	mov cx, PlaySoundTicks
PlaySoundDelayLoop:
	mov ax, Clock
PlaySoundCheckTick:
	cmp ax, Clock
	je PlaySoundCheckTick
	loop PlaySoundDelayLoop
	; close the speaker
	in al, 61h
	and al, 11111100b
	out 61h, al
	; restore registers
	pop ax
	pop bp
	ret 4
	endp PlaySound

start:
	mov ax, @data
	mov ds, ax
; Initialize es
	mov ax, 40h
	mov es, ax
; Clear the screen
	mov ax, 3
	int 10h
; Print start screen
	mov dx, offset startMessage
	mov ah, 9
	int 21h
; wait for start input
StartInputLoop:
	mov ah, 0
	int 16h
	cmp al, 'p'
	je StartGame
	cmp al, 'd'
	je StartDemo
	cmp al, 'm'
	je StartMultiplayer
	cmp al, 27 ; Esc
	jne StartInputLoop ; other key was pressed
	jmp exit
StartDemo:
	mov [isDemo], 1
	jmp StartGame
StartMultiplayer:
	mov [isMultiplayer], 1
StartGame:
; Graphic mode
	mov ax, 13h
	int 10h
; Initialize for play again
	mov [isGame], 1
	mov [score], 0
	xor di, di
	mov di, offset scoreArray
	mov cx, 4
InitializeScoreArrayLoop:
	mov [byte ptr di], '0'
	inc di
	loop InitializeScoreArrayLoop
	
	xor cx, cx
	xor di, di
; Initialize random number
	mov ax, Clock
	mov [currentRandomNum], ax
; Initialize bulletSpeed
	mov ax, INITIAL_SPEED
	mov [bulletSpeed], ax
; Initialize targetScoreForSpeedInc
	mov bx, BULLET_COUNT_MULTIPLIER	
	mul bx
	mov [targetScoreForSpeedInc], ax
; Print the player
	push PLAYER_COLOR
	push PLAYER_X
	push PLAYER_Y
	push PLAYER_LENGTH_X
	push PLAYER_LENGTH_Y
	call Rectangle
; Print the shield
	mov [shieldSide], 0
	push SHIELD_COLOR
	push [shieldSide]
	call DrawShield
; Check if Multiplayer mode is on
	cmp [isMultiplayer], 1
	jne SpawnFirstBullet
; Print the second shield
	mov [shield2Side], 0
	push SHIELD_COLOR
	push [shield2Side]
	call DrawShield2
SpawnFirstBullet:
	xor ax, ax
	call SpawnBullet
; printing Score
	call PrintScore
; waiting for first tick
	mov ax, Clock
FirstTickLoop:
	cmp ax , Clock
	je FirstTickLoop
	; the first change has passed
	mov ax, Clock
	mov [currentTick], ax
	
GameLoop:
; check if a key is pressed
	mov ah, 1
	int 16h
	jnz CheckInput
	jmp Continue
; key is pressed
CheckInput:
	mov ah, 0
	int 16h
	; check shield movement keys
	cmp al, 'w'
	je WPressed
	cmp al, 'a'
	je APressed
	cmp al, 's'
	je SPressed
	cmp al, 'd'
	je DPressed
	; check if multiplayer is on
	cmp [isMultiplayer], 1
	jne CheckEsc
	; check multiplayer input keys
	cmp al, 'i'
	jne CheckJ
	jmp IPressed
CheckJ:
	cmp al, 'j'
	jne CheckK
	jmp JPressed
CheckK:
	cmp al, 'k'
	jne CheckL
	jmp KPressed
CheckL:
	cmp al, 'l'
	jne CheckEsc
	jmp LPressed
CheckEsc:
	cmp al, 27 ; Esc
	je EscPressed
	; some other key was pressed
	jmp Continue
EscPressed:
	jmp ExitGameLoop
WPressed:
	push 0
	push 1
	call MoveShield
	jmp Continue
APressed:
	push 3
	push 1
	call MoveShield
	jmp Continue
SPressed:
	push 2
	push 1
	call MoveShield
	jmp Continue
DPressed:
	push 1
	push 1
	call MoveShield
	jmp Continue
IPressed:
	push 0
	push 2
	call MoveShield
	jmp Continue
JPressed:
	push 3
	push 2
	call MoveShield
	jmp Continue
KPressed:
	push 2
	push 2
	call MoveShield
	jmp Continue
LPressed:
	push 1
	push 2
	call MoveShield
	jmp Continue

Continue:
	mov ax, Clock
	cmp ax, [currentTick]
	jne TickChanged
	jmp CheckingGameLoop
TickChanged:
	mov [currentTick], ax
	; checking if multiplayer is on
	cmp [isMultiplayer], 1
	jne CheckDistanceFromPlayerLabel
	; check bullet distance from player before move
	push [bulletSide]
	push 0
	push [bulletX]
	push [bulletY]
	call CheckDistanceFromPlayer
	mov ax, [bulletDistanceFromPlayer]
	mov [currentDistanceFromPlayer], ax
	; checking bullet distance from player after move
CheckDistanceFromPlayerLabel:
	push [bulletSide]
	push [bulletSpeed]
	push [bulletX]
	push [bulletY]
	call CheckDistanceFromPlayer
	cmp [isMultiplayer], 1
	jne CheckProximity
	; multiplayer - check bullet relative to shield 2
	cmp [currentDistanceFromPlayer], SHIELD_2_DISTANCE_FROM_PLAYER
	jle CheckBulletOnShield2
	cmp [bulletDistanceFromPlayer], SHIELD_2_DISTANCE_FROM_PLAYER
	jle BulletBeforeShield2
	; the bullet is far from shield 2
	jmp SimpleMovement
BulletBeforeShield2:
	mov ax, [bulletSide]
	cmp [shield2Side], ax
	je Shield2Hit
	; shield is not there, continue movement
	jmp SimpleMovement
Shield2Hit:
	mov ax, [bulletSpeed]
	add ax, [bulletDistanceFromPlayer]
	add ax, SHIELD_2_DISTANCE_FROM_PLAYER
	dec ax
	; checking if bullet needs to move
	cmp ax, SHIELD_2_DISTANCE_FROM_PLAYER
	je MoveBulletToShield2
	; bullet is touching shield 2
	jmp EraseBulletLabel
MoveBulletToShield2:
	; bullet needs to move
	push ax
	push [bulletSide]
	push [bulletY]
	push [bulletX]
	call MoveBullet
	jmp EraseBulletLabel
CheckBulletOnShield2:	
	mov ax, SHIELD_2_DISTANCE_FROM_PLAYER
	sub ax, BULLET_LENGTH
	cmp [currentDistanceFromPlayer], ax
	jle CheckProximity
	; bullet is on shield 2 position
	mov ax, [bulletSide]
	cmp [shield2Side], ax
	je EraseBulletLabel
	; bullet is not on shield 2
	jmp SimpleMovement
CheckProximity:
	cmp [bulletDistanceFromPlayer], 0
	jg SimpleMovement
	; the bullet touches the player
	; checking if the shield is blocking
	mov ax, [bulletSide]
	cmp ax, [shieldSide]
	je ShieldHit
	; bullet hit the player
	mov [isGame], 0
	mov ax, [bulletSpeed]
	add ax, [bulletDistanceFromPlayer]
	add ax, 6

	push ax
	push [bulletSide]
	push [bulletY]
	push [bulletX]
	call MoveBullet
	push PLAYER_HIT_SOUND_NOTE
	push PLAYER_HIT_SOUND_TICKS
	call PlaySound
	jmp CheckingGameLoop
ShieldHit:
	mov ax, [bulletSpeed]
	add ax, [bulletDistanceFromPlayer]
	dec ax
	; checking if bullet needs to move
	cmp ax, 0
	je EraseBulletLabel
	; bullet needs to move
	push ax
	push [bulletSide]
	push [bulletY]
	push [bulletX]
	call MoveBullet
EraseBulletLabel:
	call EraseBullet
	; update the Score
	call UpdateScore
	; spawn a new bullet
	call SpawnBullet
	jmp RedrawShield2
SimpleMovement:
	push [bulletSpeed]
	push [bulletSide]
	push [bulletY]
	push [bulletX]
	call MoveBullet
RedrawShield2:
	cmp [isMultiplayer], 1
	jne CheckingGameLoop
	; redraw shield 2
	push SHIELD_COLOR
	push [shield2Side]
	call DrawShield2
CheckingGameLoop:
	cmp [isGame], 1
	jne ExitGameLoop
	jmp GameLoop
	
ExitGameLoop:
; wait 1 second before switching to game over screen
	mov cx, 18
DelayLoop:
	mov ax, Clock
CheckTick:
	cmp ax, Clock
	je CheckTick
	loop DelayLoop
; Return to text mode
	mov ah, 0
	mov al, 2
	int 10h
; print game over screen
	mov dx, offset gameOverMessage
	mov ah, 9
	int 21h
	call PrintScore
	mov dx, offset gameOverInstruc
	mov ah, 9
	int 21h
GameOverInputLoop:
; Wait for key press
	mov ah, 0
	int 16h
	cmp al, 'p'
	je PlayAgain
	cmp al, 'm'
	je MultiplayerAgain
	cmp al, 27 ; Esc
	je exit
	; other key was pressed
	jmp GameOverInputLoop
MultiplayerAgain:
	jmp StartMultiplayer
PlayAgain:
	; making sure demo mode is off
	mov [isDemo], 0
	; making sure multiplayer mode is off
	mov [isMultiplayer], 0
	jmp StartGame
exit:
	mov ax, 4c00h
	int 21h
END start