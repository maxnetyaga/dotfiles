.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
    ; Arrays for a, b, c values
    a_values dd -4, 38, -2, 38, 4
    b_values dd -5, 4, -3, -15, 2
    c_values dd -20, 40, -12, -28, 4
    
    ; Strings for output
    formula db "Formula: (-15*a + b - c/4) / (b*a - 8)", 13, 10, 0
    values db "Values: a = %d, b = %d, c = %d", 13, 10, 0
    expression db "Expression: (-15*%d + %d - %d/4) / (%d*%d - 8)", 13, 10, 0
    intermediate_result db "Intermediate result: %d", 13, 10, 0
    final_result db "Final result: %d", 13, 10, 0
    division_by_zero db "Error: Division by zero!", 13, 10, 0
    separator db "------------------------", 13, 10, 0
    
    output_buffer db 512 dup(0)
    
.code
start:
    ; Initialize counter and pointers
    mov esi, 0                  ; index counter
    mov edi, offset output_buffer
    
    ; Print formula once
    invoke szCatStr, edi, addr formula
    invoke StdOut, edi
    mov edi, offset output_buffer
    invoke szCatStr, edi, addr separator
    invoke StdOut, edi
    mov edi, offset output_buffer
    
    ; Process each set of values
    .while esi < 5
        ; Get current values
        mov eax, [a_values + esi*4]
        mov ebx, [b_values + esi*4]
        mov ecx, [c_values + esi*4]
        
        ; Print values
        invoke wsprintf, edi, addr values, eax, ebx, ecx
        invoke StdOut, edi
        mov edi, offset output_buffer
        
        ; Print expression with substituted values
        invoke wsprintf, edi, addr expression, eax, ebx, ecx, ebx, eax
        invoke StdOut, edi
        mov edi, offset output_buffer
        
        ; Calculate denominator (b*a - 8)
        mov edx, ebx
        imul edx, eax            ; b*a
        sub edx, 8               ; b*a - 8
        
        ; Check for division by zero
        test edx, edx
        jz zero_division
        
        ; Calculate numerator (-15*a + b - c/4)
        mov ebp, eax             ; save a
        mov eax, -15
        imul ebp                 ; -15*a
        mov ebp, eax             ; save -15*a
        mov eax, ebx             ; b
        add ebp, eax             ; -15*a + b
        mov eax, ecx             ; c
        cdq
        mov ecx, 4
        idiv ecx                 ; c/4
        sub ebp, eax             ; -15*a + b - c/4
        
        ; Divide numerator by denominator
        mov eax, ebp
        cdq
        idiv edx                 ; (-15*a + b - c/4) / (b*a - 8)
        
        ; Print intermediate result
        invoke wsprintf, edi, addr intermediate_result, eax
        invoke StdOut, edi
        mov edi, offset output_buffer
        
        ; Calculate final result
        test eax, 1              ; check if odd
        jnz odd_result
        ; Even result - divide by 2
        mov edx, eax
        sar edx, 1               ; signed divide by 2
        jmp print_final
    odd_result:
        ; Odd result - multiply by 5
        mov edx, eax
        imul edx, 5
    print_final:
        invoke wsprintf, edi, addr final_result, edx
        invoke StdOut, edi
        mov edi, offset output_buffer
        jmp next_iteration
        
    zero_division:
        invoke szCatStr, edi, addr division_by_zero
        invoke StdOut, edi
        mov edi, offset output_buffer
        
    next_iteration:
        ; Print separator
        invoke szCatStr, edi, addr separator
        invoke StdOut, edi
        mov edi, offset output_buffer
        
        ; Move to next set of values
        inc esi
    .endw
    
    ; Exit program
    invoke ExitProcess, 0
end start