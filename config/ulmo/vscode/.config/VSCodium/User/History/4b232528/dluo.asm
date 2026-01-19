.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\lib\kernel32.lib
include \masm32\lib\user32.lib

; Function prototype for dwtoa
PROTO dwtoa PROTO :DWORD, :DWORD

.data
array_a DWORD -4, 38, -2, 38, 4
array_b DWORD -5, 4, -3, -15, 2
array_c DWORD -20, 40, -12, -28, 4
formula db "(-15*a + b - c/4) / (b*a - 8)", 0
array_label db "Array: ", 0
a_label db "a = ", 0
b_label db ", b = ", 0
c_label db ", c = ", 0
expression_label db "Expression: ", 0
result_label db "Result: ", 0
final_result_label db "Final Result: ", 0
division_by_zero_msg db "Error: Division by zero!", 0
output_buffer db 256 dup(0)
caption db "Array Calculations", 0

.code
start:
    mov esi, offset array_a ; Point esi to the beginning of array_a
    mov edi, offset array_b ; Point edi to the beginning of array_b
    mov ebx, offset array_c ; Point ebx to the beginning of array_c
    mov ecx, 5          ; Loop counter

process_array:
    ; Get the values for a, b, and c
    mov eax, [esi]      ; a
    mov edx, [edi]      ; b
    mov esi, offset formula ; Reset esi to the formula string for AppendString

    ; Prepare the output string
    mov esi, offset formula
    call AppendString
    call AppendNewline

    mov esi, offset array_label
    call AppendString
    mov esi, offset a_label
    call AppendString
    mov eax, [esi - offset a_label - offset array_label + offset array_a] ; Get 'a' again
    call AppendInteger

    mov esi, offset b_label
    call AppendString
    mov eax, [esi - offset b_label - offset array_label + offset array_b] ; Get 'b' again
    call AppendInteger

    mov esi, offset c_label
    call AppendString
    mov eax, [esi - offset c_label - offset array_label + offset array_c] ; Get 'c' again
    call AppendInteger

    call AppendNewline

    mov esi, offset expression_label
    call AppendString
    mov esi, offset "(-15*"
    call AppendString
    mov eax, [esi - offset "(-15*" - offset expression_label + offset array_a] ; Get 'a' again
    call AppendInteger
    mov esi, offset " + "
    call AppendString
    mov eax, [esi - offset " + " - offset expression_label + offset array_b] ; Get 'b' again
    call AppendInteger
    mov esi, offset " - "
    call AppendString
    mov eax, [esi - offset " - " - offset expression_label + offset array_c] ; Get 'c' again
    call AppendInteger
    mov esi, offset "/4) / ("
    call AppendString
    mov eax, [esi - offset "/4) / (" - offset expression_label + offset array_b] ; Get 'b' again
    call AppendInteger
    mov esi, offset "*"
    call AppendString
    mov eax, [esi - offset "*" - offset expression_label + offset array_a] ; Get 'a' again
    call AppendInteger
    mov esi, offset " - 8)"
    call AppendString

    call AppendNewline

    ; Calculate the numerator: -15 * a + b - c / 4
    mov edi, -15
    mov eax, [esi - offset " - 8)" - offset expression_label + offset array_a] ; Get 'a'
    imul eax, edi       ; eax = -15 * a
    add eax, [esi - offset " - 8)" - offset expression_label + offset array_b] ; Add 'b'
    mov ecx, [esi - offset " - 8)" - offset expression_label + offset array_c] ; Get 'c'
    cwd                 ; Convert ecx:eax to double word for division
    mov ebx, 4
    idiv ebx            ; eax = c / 4
    sub eax, edi        ; eax = -15 * a + b - c / 4 (numerator)
    push eax            ; Save numerator

    ; Calculate the denominator: b * a - 8
    mov ebx, [esi - offset " - 8)" - offset expression_label + offset array_b] ; Get 'b'
    imul ebx, [esi - offset " - 8)" - offset expression_label + offset array_a] ; Multiply by 'a'
    sub ebx, 8          ; ebx = b * a - 8 (denominator)

    ; Check for division by zero
    cmp ebx, 0
    je division_error

    ; Perform the division
    pop eax             ; Restore numerator
    cwd                 ; Convert eax to double word for division
    idiv ebx            ; eax = numerator / denominator (intermediate result)

    ; Append intermediate result
    mov esi, offset result_label
    call AppendString
    call AppendInteger
    call AppendNewline

    ; Calculate the final result
    mov edx, eax        ; Copy intermediate result to edx
    and edx, 1          ; Check if edx (LSB) is 1 (odd)
    jnz odd_result

    ; Even result: divide by 2
    shr eax, 1          ; eax = eax / 2
    jmp final_result_append

odd_result:
    ; Odd result: multiply by 5
    mov ebx, 5
    imul eax, ebx       ; eax = eax * 5

final_result_append:
    mov esi, offset final_result_label
    call AppendString
    call AppendInteger
    call AppendNewline
    call DisplayMessage
    jmp next_array

division_error:
    mov esi, offset division_by_zero_msg
    call AppendString
    call AppendNewline
    call DisplayMessage

next_array:
    add esi, 4          ; Move to the next 'a' value
    add edi, 4          ; Move to the next 'b' value
    add ebx, 4          ; Move to the next 'c' value
    loop process_array

    invoke ExitProcess, 0

; Helper procedure to append a string to the output buffer
AppendString PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    mov esi, [ebp + 8]  ; Address of the string to append
    mov edi, offset output_buffer
    mov ecx, -1
    repne scasb         ; Find the end of the current buffer
    dec edi             ; Point to the null terminator
copy_string:
    lodsb               ; Load a byte from esi to al
    stosb               ; Store al to edi
    cmp al, 0           ; Check for null terminator
    jne copy_string
    pop edi
    pop esi
    pop ebp
    ret
AppendString ENDP

; Helper procedure to append an integer to the output buffer
AppendInteger PROC
    push ebp
    mov ebp, esp
    push eax
    push edi
    mov eax, [ebp + 8]  ; Integer to append
    mov edi, offset output_buffer
    mov ecx, -1
    repne scasb         ; Find the end of the current buffer
    dec edi             ; Point to the null terminator
    push edi
    invoke dwtoa, eax, esp ; Convert integer to string in stack
    pop esi
copy_integer:
    lodsb
    stosb
    cmp al, 0
    jne copy_integer
    pop edi
    pop eax
    pop ebp
    ret
AppendInteger ENDP

; Helper procedure to append a newline to the output buffer
AppendNewline PROC
    push ebp
    mov ebp, esp
    push esi
    push edi
    mov esi, offset crlf
    mov edi, offset output_buffer
    mov ecx, -1
    repne scasb         ; Find the end of the current buffer
    dec edi             ; Point to the null terminator
copy_newline:
    lodsb
    stosb
    cmp al, 0
    jne copy_newline
    pop edi
    pop esi
    pop ebp
    ret
AppendNewline ENDP

; Helper procedure to display the message box
DisplayMessage PROC
    push ebp
    mov ebp, esp
    invoke MessageBox, NULL, addr output_buffer, addr caption, MB_OK
    mov byte ptr output_buffer, 0 ; Clear the buffer for the next message
    pop ebp
    ret
DisplayMessage ENDP

; Import the dwtoa function from kernel32.dll
includelib \masm32\lib\kernel32.lib
extrn dwtoa:PROC

end start