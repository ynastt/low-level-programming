;лабораторная работа 2
;11 вариант
;Определить количество элементов массива, значения которых превышают заданное 

assume CS:code, DS:data

data segment 
arr dw 7,4,9,5,3,8,1,7,9,10 ; в массиве 6 чисел больше заданного (value)
val dw 5		    ; заданное число
msg db 10 dup(0), "$"	    ; ИСПРАВИЛА выделила под строку больше одного символа
data ends

sseg segment stack
db 100h dup (?)
sseg ends

code segment
start:      
mov AX, data		; установка в ds адpеса 
mov DS, AX		; сегмента данных

mov SI, offset arr 	; адрес массива
cld			; направление df=0  
xor BX, BX		;обнуление счетчика для чисел
mov CX, 10		;количество повторение = длина массива

find:
	lodsw 		;загружаем символ
	cmp val, AX
	jb op1		;если val < ax переходим на метку
	jmp ml		;чтобы управление не передалось случайно метке op1
	op1: 
		inc BX
	ml:
	loop find	;работает пока cx != 0
	
;=======вывод результата в 10 сс========
mov ax, bx
mov DI, offset msg
push DI
mov BX, 10			; основание системы счисления
xor CX, CX 			; обнуление счетчика цифр
inDec: 	
	xor DX, DX 		; обнуляем dx
	div BX			; делим число на основание сс. В остатке - последняя цифра. ax - частное, dx - остаток
	add DL, 30h 		; в dl будет находится код символа цифры, и чтобы получить в al именно код символа, нужно прибавить код символа "0", который равен 30h 
	push DX			; сохраним цифру из остатка в стек
	inc CX			
	or AX, AX 		; проверка ax == 0
	jne inDec		; переход по адресу inDec, если частное не ноль  (продолжаем до конца числа)

makeStr:
	pop AX			; извлекаем цифру
	mov [DI], AL		; перемещаем цифру в строку (по адресу из DI)
	inc DI				
	dec CX				
	or CX, CX
	jne makeStr

mov AH, 09h			; 09h - вывод всех символов строки (она хранится в DX) до символа "$"
pop DI				; получили адрес начала строки
mov DX, DI			
int 21h	

mov AX, 4C00h   ;завершение программы
int 21h
code ends
end start
