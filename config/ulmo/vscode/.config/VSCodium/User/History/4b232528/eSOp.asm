.386
.model flat, stdcall
option casemap :none

include masm32rt.inc

.data
    szCourierNew db "Courier New",0
    ; Arrays for a, b, c values
    a_values dd -4, 38, -2, 38, 4
    b_values dd -5, 4, -3, -15, 2
    c_values dd -20, 40, -12, -28, 4
    
    ; Window class and title
    szClassName db "FormulaWindowClass",0
    szWindowTitle db "Formula Calculator",0
    
    ; Strings for output
    formula db "Formula: (-15*a + b - c/4) / (b*a - 8)",0
    values db "Values: a = %d, b = %d, c = %d",0
    expression db "Expression: (-15*%d + %d - %d/4) / (%d*%d - 8)",0
    intermediate_result db "Intermediate result: %d",0
    final_result db "Final result: %d",0
    division_by_zero db "Error: Division by zero!",0
    separator db "==================",0
    newline db 13,10,0
    
    ; Output buffer
    output_buffer db 2048 dup(0)
    current_pos dd 0
    
    ; Font
    hFont dd ?

.code
AppendText proc text:DWORD
    invoke lstrlen, text
    add eax, [current_pos]
    .if eax < sizeof output_buffer
        invoke lstrcat, addr output_buffer, text
        invoke lstrcat, addr output_buffer, addr newline
        invoke lstrlen, text
        add eax, 2 ; for CRLF
        add [current_pos], eax
    .endif
    ret
AppendText endp

CalculateAndDisplay proc hWnd:HWND
    local temp_buf[256]:byte
    local numerator:DWORD
    local denominator:DWORD
    local intermediate:DWORD
    local final:DWORD
    
    mov [current_pos], 0
    mov byte ptr [output_buffer], 0
    
    ; Append formula
    invoke AppendText, addr formula
    invoke AppendText, addr separator
    
    mov esi, 0 ; index counter
    
    .while esi < 5
        ; Get current values
        mov eax, [a_values + esi*4]
        mov ebx, [b_values + esi*4]
        mov ecx, [c_values + esi*4]

        push eax
        push ebx
        push ecx
        
        ; Print values
        invoke wsprintf, addr temp_buf, addr values, eax, ebx, ecx
        invoke AppendText, addr temp_buf
        
        pop eax
        pop ebx
        pop ecx

        push eax
        push ebx
        push ecx

        ; Print expression - use the actual values
        invoke wsprintf, addr temp_buf, addr expression, eax, ebx, ecx, ebx, eax
        invoke AppendText, addr temp_buf

        pop eax
        pop ebx
        pop ecx
        
        push eax
        push ebx
        push ecx

        ; Calculate denominator (b*a - 8)
        mov edx, ebx
        imul edx, eax            ; b*a
        sub edx, 8               ; b*a - 8
        mov denominator, edx
        
        ; Check for division by zero
        .if edx == 0
            invoke AppendText, addr division_by_zero
        .else
            ; Calculate numerator (-15*a + b - c/4)
            mov edi, eax             ; save a
            mov eax, -15
            imul edi                 ; -15*a
            mov numerator, eax       ; save -15*a
            mov eax, ebx             ; b
            add numerator, eax      ; -15*a + b
            mov eax, ecx             ; c
            cdq
            mov ecx, 4
            idiv ecx                 ; c/4
            sub numerator, eax      ; -15*a + b - c/4
            
            ; Divide numerator by denominator
            mov eax, numerator
            cdq
            idiv denominator         ; (-15*a + b - c/4) / (b*a - 8)
            mov intermediate, eax

            push eax
            push ebx
            push ecx
            
            ; Print intermediate result
            invoke wsprintf, addr temp_buf, addr intermediate_result, intermediate
            invoke AppendText, addr temp_buf

            pop ecx
            pop ebx
            pop eax
            
            ; Calculate final result
            test eax, 1              ; check if odd
            .if !ZERO?
                ; Odd result - multiply by 5
                mov edx, eax
                imul edx, 5
                mov final, edx
            .else
                ; Even result - divide by 2
                mov edx, eax
                sar edx, 1           ; signed divide by 2
                mov final, edx
            .endif
            
            ; Print final result
            invoke wsprintf, addr temp_buf, addr final_result, final
            invoke AppendText, addr temp_buf
        .endif
        
        ; Add separator
        invoke AppendText, addr separator
        
        ; Next iteration
        inc esi
    .endw
    
    ; Update the window
    invoke InvalidateRect, hWnd, NULL, TRUE
    ret
CalculateAndDisplay endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    local ps:PAINTSTRUCT
    local hdc:HDC
    local rect:RECT
    local hOldFont:DWORD
    
    .if uMsg == WM_CREATE
        ; Create font
        invoke CreateFont, 14, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, 
                          DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, 
                          DEFAULT_QUALITY, DEFAULT_PITCH or FF_DONTCARE, 
                          addr szCourierNew
        mov hFont, eax
        
        ; Calculate and prepare display
        invoke CalculateAndDisplay, hWnd
        
    .elseif uMsg == WM_PAINT
        invoke BeginPaint, hWnd, addr ps
        mov hdc, eax
        
        ; Set font
        invoke SelectObject, hdc, hFont
        mov hOldFont, eax
        
        ; Get client area
        invoke GetClientRect, hWnd, addr rect
        
        ; Draw text
        invoke DrawText, hdc, addr output_buffer, -1, addr rect, 
                        DT_LEFT or DT_TOP or DT_WORDBREAK
        
        ; Restore old font
        invoke SelectObject, hdc, hOldFont
        
        invoke EndPaint, hWnd, addr ps
        
    .elseif uMsg == WM_DESTROY
        ; Delete font
        invoke DeleteObject, hFont
        invoke PostQuitMessage, 0
    .else
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    
    xor eax, eax
    ret
WndProc endp

WinMain proc
    local wc:WNDCLASSEX
    local hWnd:HWND
    local msg:MSG
    
    ; Register window class
    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    push NULL
    pop wc.hInstance
    mov wc.hIcon, NULL
    mov wc.hCursor, NULL
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset szClassName
    mov wc.hIconSm, NULL
    
    invoke RegisterClassEx, addr wc
    
    ; Create window
    invoke CreateWindowEx, 0, addr szClassName, addr szWindowTitle, 
                         WS_OVERLAPPEDWINDOW, 
                         CW_USEDEFAULT, CW_USEDEFAULT, 600, 500, 
                         NULL, NULL, NULL, NULL
    mov hWnd, eax
    
    ; Show window
    invoke ShowWindow, hWnd, SW_SHOWNORMAL
    invoke UpdateWindow, hWnd
    
    ; Message loop
    .while TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
        .break .if eax == 0
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
    .endw
    
    mov eax, msg.wParam
    ret
WinMain endp

start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke WinMain
    invoke ExitProcess, 0
    
.data?
    hInstance HINSTANCE ?
end start