use16                       ;Генерировать 16-битный код
include 'macro.inc'
org 100h                    ;Программа начинается с адреса 100h
    jmp start               ;Перепрыгнуть данные
;-------------------------------------------------------------------------------
; Данные
char1 db 2,?,2 dup('$')
char2 db 'X'
file_name db 'str.txt',0
s_error   db 'Error!',13,10,'$'
s_file    db '----[ file "newfile.txt" ]$'
endline   db 13,10,'$'
s_pak     db 'Press any key...$'
buffer    rb 81             ;80 + 1 байт для символа конца строки '$'
handle    rw 1              ;Дескриптор файла
file_name2 db 'newfile.txt',0
size 	  db 19
handle2   rw 1
;-------------------------------------------------------------------------------
; Код
start:
	mov dx, char1 
   	mov ah,0Ah 
	int 21h
	
	
	;input.asm
    mov ah,3Dh              ;Функция DOS 3Dh (открытие файла)
    xor al,al               ;Режим открытия - только чтение
    mov dx,file_name        ;Имя файла
    xor cx,cx               ;Нет атрибутов - обычный файл
    int 21h                 ;Обращение к функции DOS
    jnc @F                  ;Если нет ошибки, то продолжаем
    call error_msg          ;Иначе вывод сообщения об ошибке
    jmp exit                ;Выход из программы
@@: mov [handle],ax         ;Сохранение дескриптора файла

    mov bx,ax               ;Дескриптор файла
    mov ah,3Fh              ;Функция DOS 3Fh (чтение из файла)
    mov dx,buffer           ;Адрес буфера для данных
    mov cx,80               ;Максимальное кол-во читаемых байтов
    int 21h                 ;Обращение к функции DOS
    jnc @F                  ;Если нет ошибки, то продолжаем
    call error_msg          ;Вывод сообщения об ошибке
    jmp close_file          ;Закрыть файл и выйти из программы

@@: mov bx,buffer
    add bx,ax               ;В AX количество прочитанных байтов
    mov byte[bx],'$'        ;Добавление символа '$'

    mov ah,9
    mov dx,s_file
    int 21h                 ;Вывод строки с именем файла

    mov cx,56
    call line               ;Вывод линии

    mov ah,9
    mov bx,char1 
    add bx,2
    mov si,buffer 
    replace si, bx, char2
    mov dx,buffer
    int 21h                 ;Вывод содержимого файла
    mov dx,endline
    int 21h                 ;Вывод перехода на новую строку

    mov cx,80
    call line               ;Вывод линии
	;output.asm
	mov ah,3Ch              ;Функция DOS 3Ch (создание файла)
    mov dx,file_name2        ;Имя файла
    xor cx,cx               ;Нет атрибутов - обычный файл
    int 21h                 ;Обращение к функции DOS
    jnc @F                  ;Если нет ошибки, то продолжаем
    call error_msg          ;Иначе вывод сообщения об ошибке
    jmp exit                ;Выход из программы
@@: mov [handle2],ax         ;Сохранение дескриптора файла
 
    mov bx,ax               ;Дескриптор файла
    mov ah,40h              ;Функция DOS 40h (запись в файл)
    mov dx,buffer			;Адрес буфера с данными
    movzx cx,[size]         ;Размер данных
    int 21h                 ;Обращение к функции DOS
    jnc close_file          ;Если нет ошибки, то закрыть файл
    call error_msg          ;Вывод сообщения об ошибке





close_file:
    mov ah,3Eh              ;Функция DOS 3Eh (закрытие файла)
    mov bx,[handle]         ;Дескриптор
    int 21h                 ;Обращение к функции DOS
    jnc exit                ;Если нет ошибки, то выход из программы
    call error_msg          ;Вывод сообщения об ошибке

exit:
    mov ah,9
    mov dx,s_pak
    int 21h                 ;Вывод строки 'Press any key...'
    mov ah,8                ;\
    int 21h                 ;/ Ввод символа без эха
    mov ax,4C00h            ;\
    int 21h                 ;/ Завершение программы

;-------------------------------------------------------------------------------
; Процедура вывода сообщения об ошибке
error_msg:
    mov ah,9
    mov dx,s_error
    int 21h                 ;Вывод сообщения об ошибке
    ret
;-------------------------------------------------------------------------------
; Вывод линии
; CX - количество символов
line:
    mov ah,2                ;Функция DOS 02h (вывод символа)
    mov dl,'-'              ;Символ
@@: int 21h                 ;Обращение к функции DOS
    loop @B                 ;Команда цикла
    ret