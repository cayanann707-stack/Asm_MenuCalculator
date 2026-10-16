section .data
    menu_msg    db "----------------------------------", 10
                db "MENU", 10
                db "[A]dd", 10
                db "[S]ubtract", 10
                db "[M]ultiply", 10
                db "[D]ivide", 10
                db "----------------------------------", 10
                db "Enter your choice: ", 0
    menu_len    equ $ - menu_msg

    prompt1     db "Enter first number: ", 0
    prompt1_len equ $ - prompt1

    prompt2     db "Enter second number: ", 0
    prompt2_len equ $ - prompt2

    res_msg     db "The result is: ", 0
    res_len     equ $ - res_msg

    again_msg   db 10, "Do you want to try again (Y/N): ", 0
    again_len   equ $ - again_msg

    clear_cmd   db 0x1B, "[2J", 0x1B, "[H"
    clear_len   equ $ - clear_cmd

    newline     db 10

section .bss
    choice      resb 2
    num_str     resb 5
    num1        resd 1
    num2        resd 1
    result      resd 1
    buffer      resb 10

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, clear_cmd
    mov edx, clear_len
    int 0x80

menu_loop:
    mov eax, 4
    mov ebx, 1
    mov ecx, menu_msg
    mov edx, menu_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, choice
    mov edx, 2
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt1
    mov edx, prompt1_len
    int 0x80

    call read_int
    mov [num1], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, prompt2
    mov edx, prompt2_len
    int 0x80

    call read_int
    mov [num2], eax

    mov al, [choice]
    or al, 0x20

    cmp al, 'a'
    je do_add
    cmp al, 's'
    je do_sub
    cmp al, 'm'
    je do_mul
    cmp al, 'd'
    je do_div
    jmp invalid_choice

do_add:
    mov eax, [num1]
    add eax, [num2]
    mov [result], eax
    jmp print_result

do_sub:
    mov eax, [num1]
    sub eax, [num2]
    mov [result], eax
    jmp print_result

do_mul:
    mov eax, [num1]
    imul eax, [num2]
    mov [result], eax
    jmp print_result

do_div:
    mov edx, 0
    mov eax, [num1]
    mov ebx, [num2]
    cmp ebx, 0
    je invalid_choice
    idiv ebx
    mov [result], eax
    jmp print_result

invalid_choice:
    mov dword [result], 0
    jmp ask_again

print_result:
    mov eax, 4
    mov ebx, 1
    mov ecx, res_msg
    mov edx, res_len
    int 0x80

    mov eax, [result]
    call print_int

ask_again:
    mov eax, 4
    mov ebx, 1
    mov ecx, again_msg
    mov edx, again_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, choice
    mov edx, 2
    int 0x80

    mov al, [choice]
    or al, 0x20
    cmp al, 'y'
    je _start

exit_program:
    mov eax, 1
    mov ebx, 0
    int 0x80

read_int:
    mov eax, 3
    mov ebx, 0
    mov ecx, num_str
    mov edx, 5
    int 0x80

    mov esi, num_str
    xor eax, eax
    xor ecx, ecx
    xor edx, edx
.loop_parse:
    cmp edx, 2
    je .done_parse
    mov cl, [esi]
    cmp cl, 10
    je .done_parse
    cmp cl, 0
    je .done_parse
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc edx
    inc esi
    jmp .loop_parse
.done_parse:
    ret

print_int:
    mov edi, buffer + 9
    mov byte [edi], 0
    mov ebx, 10
.loop_convert:
    dec edi
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    cmp eax, 0
    jne .loop_convert

    mov ecx, edi
    mov esi, buffer + 10
    sub esi, edi
    mov edx, esi
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
