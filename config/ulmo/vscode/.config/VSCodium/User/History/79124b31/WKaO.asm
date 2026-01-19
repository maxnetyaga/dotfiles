.386
.model flat, stdcall
option casemap :none
include masm32rt.inc

.data
    szCourierNew db "Courier New",0
    netyaga_a_vals dq 1.123, 1.123, 1000.123, 1000.123, 1.123, 1.123
    netyaga_b_vals dq 1.234, 1000.234, 1.234, 1000.234, 1.234, 1.234
    netyaga_c_vals dq 100.234, 100.234, 100.234, 100.234, 100.234, -1.234
    netyaga_d_vals dq 5.123, 5.123, 5.123, 5.123, 5.123, 5.123
    szClassName db "FormulaWindowClass",0
    szWindowTitle db "Formula Calculator",0
    formula db "Formula: (4*lg(c) - b/2 + 23) / (d - a + 1)",0
    values db "Values: a = %.3f, b = %.3f, c = %.3f, d = %.3f",0
    expression db "Expression: (4*lg(%.3f) - %.3f/2 + 23) / (%.3f - %.3f + 1)",0
    intermediate_result db "Intermediate result: %.6f",0
    final_result db "Final result: %.6f",0
    division_by_zero db "Error: Division by zero!",0
    log_viol db "Error: c must be positive for logarithm!",0
    separator db "==================",0
    newline db 13,10,0
    output_buffer db 2048 dup(0)
    current_pos dd 0
    hFont dd ?
    
    ; Floating point constants
    fp_one dt 1.0
    fp_two dt 2.0
    fp_four dt 4.0
    fp_twenty_three dt 23.0
    
.code
AppendText proc text:DWORD
    invoke lstrlen, text
    add eax, [current_pos]
    .if eax < sizeof output_buffer
        invoke lstrcat, addr output_buffer, text
        invoke lstrcat, addr output_buffer, addr newline
        invoke lstrlen, text
        add eax, 2
        add [current_pos], eax
    .endif
    ret
AppendText endp

CalculateAndDisplay proc hWnd:HWND
    local temp_buf[256]:byte
    local numerator:REAL10
    local denominator:REAL10
    local result:REAL10
    local temp:REAL10
    local final_result_val:REAL8
    
    mov [current_pos], 0
    mov byte ptr [output_buffer], 0
    invoke AppendText, addr formula
    invoke AppendText, addr separator
    
    mov esi, 0
    .while esi < 6
        ; Load current values
        mov ecx, esi
        shl esi, 3            ; esi = esi *8
        lea esi, [esi + ecx*2] ; esi = esi*8 + esi*2 → esi*10

        fld tbyte ptr [netyaga_a_vals + esi]
        fld tbyte ptr [netyaga_b_vals + esi]
        fld tbyte ptr [netyaga_c_vals + esi]
        fld tbyte ptr [netyaga_d_vals + esi]

        ; Display expression
        lea eax, [temp_buf]       ; Get address of local variable
        push eax
        lea eax, [values]     ; Get address of expression string
        push eax

        ; Push all float components (same as before)
        push dword ptr [netyaga_a_vals + esi + 8]
        push dword ptr [netyaga_a_vals + esi + 4]
        push dword ptr [netyaga_a_vals + esi]

        push dword ptr [netyaga_d_vals + esi + 8]
        push dword ptr [netyaga_d_vals + esi + 4]
        push dword ptr [netyaga_d_vals + esi]

        push dword ptr [netyaga_b_vals + esi + 8]
        push dword ptr [netyaga_b_vals + esi + 4]
        push dword ptr [netyaga_b_vals + esi]

        push dword ptr [netyaga_c_vals + esi + 8]
        push dword ptr [netyaga_c_vals + esi + 4]
        push dword ptr [netyaga_c_vals + esi]

        call wsprintf
        add esp, 52 ; Clean up stack

        lea eax, [temp_buf]
        push eax
        call AppendText
        add esp, 4

        ; Display expression
        lea eax, [temp_buf]       ; Get address of local variable
        push eax
        lea eax, [expression]     ; Get address of expression string
        push eax

        ; Push all float components (same as before)
        push dword ptr [netyaga_a_vals + esi + 8]
        push dword ptr [netyaga_a_vals + esi + 4]
        push dword ptr [netyaga_a_vals + esi]

        push dword ptr [netyaga_d_vals + esi + 8]
        push dword ptr [netyaga_d_vals + esi + 4]
        push dword ptr [netyaga_d_vals + esi]

        push dword ptr [netyaga_b_vals + esi + 8]
        push dword ptr [netyaga_b_vals + esi + 4]
        push dword ptr [netyaga_b_vals + esi]

        push dword ptr [netyaga_c_vals + esi + 8]
        push dword ptr [netyaga_c_vals + esi + 4]
        push dword ptr [netyaga_c_vals + esi]

        call wsprintf
        add esp, 52 ; Clean up stack

        lea eax, [temp_buf]
        push eax
        call AppendText
        add esp, 4

        ; Check if c > 0 for logarithm
        fld tbyte ptr [netyaga_c_vals + esi]
        ftst
        fstsw ax
        sahf
        jbe log_error

        fld tbyte ptr [netyaga_c_vals + esi]   ; Load c (REAL10)
        fldlg2                                 ; log10(2)
        fxch st(1)                             ; c, log10(2)
        fyl2x                                  ; log10(c)

        ; Multiply by 4
        fld tbyte ptr [fp_four]                ; 4.0
        fmulp st(1), st(0)                     ; 4*log10(c)

        ; Compute b/2
        fld tbyte ptr [netyaga_b_vals + esi]   ; b
        fld tbyte ptr [fp_two]                 ; 2.0
        fdivp st(1), st(0)                     ; b/2

        ; Subtract
        fsubp st(1), st(0)                     ; 4*lg(c) - b/2

        ; Add 23
        fld tbyte ptr [fp_twenty_three]        ; 23.0
        faddp st(1), st(0)                     ; +23
        fstp tbyte ptr [numerator]             ; store numerator (REAL10)

        ; Calculate denominator: d - a + 1
        fld tbyte ptr [netyaga_d_vals + esi]   ; d
        fld tbyte ptr [netyaga_a_vals + esi]   ; a
        fsubp st(1), st(0)                     ; d - a
        fld tbyte ptr [fp_one]                 ; 1.0
        faddp st(1), st(0)                     ; (d - a) + 1
        fstp tbyte ptr [denominator]           ; store denominator (REAL10)

        ; Check for division by zero
        fld tbyte ptr [denominator]
        ftst
        fstsw ax
        sahf
        je div_zero_error

        ; Compute result = numerator / denominator
        fld tbyte ptr [numerator]
        fld tbyte ptr [denominator]
        fdivp st(1), st(0)
        fstp tbyte ptr [result]                ; store final result (REAL10)

        ; Display intermediate result
        invoke wsprintf, addr temp_buf, addr intermediate_result,
                        dword ptr [result], dword ptr [result + 4], dword ptr [result + 8]
        invoke AppendText, addr temp_buf

        ; Convert to double for final result
        fld result
        fstp final_result_val
        
        ; Display final result
        invoke wsprintf, addr temp_buf, addr final_result,
                        dword ptr [final_result_val], dword ptr [final_result_val + 4]
        invoke AppendText, addr temp_buf
        
        jmp next_iteration
        
    log_error:
        invoke AppendText, addr log_viol
        jmp next_iteration
        
    div_zero_error:
        invoke AppendText, addr division_by_zero
        
    next_iteration:
        invoke AppendText, addr separator
        inc esi
    .endw
    
    invoke InvalidateRect, hWnd, NULL, TRUE
    ret
CalculateAndDisplay endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    local ps:PAINTSTRUCT
    local hdc:HDC
    local rect:RECT
    local hOldFont:DWORD
    
    .if uMsg == WM_CREATE
        invoke CreateFont, 14, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                          DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                          DEFAULT_QUALITY, DEFAULT_PITCH or FF_DONTCARE,
                          addr szCourierNew
        mov hFont, eax
        invoke CalculateAndDisplay, hWnd
    .elseif uMsg == WM_PAINT
        invoke BeginPaint, hWnd, addr ps
        mov hdc, eax
        invoke SelectObject, hdc, hFont
        mov hOldFont, eax
        invoke GetClientRect, hWnd, addr rect
        invoke DrawText, hdc, addr output_buffer, -1, addr rect,
                        DT_LEFT or DT_TOP or DT_WORDBREAK
        invoke SelectObject, hdc, hOldFont
        invoke EndPaint, hWnd, addr ps
    .elseif uMsg == WM_DESTROY
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
    invoke CreateWindowEx, 0, addr szClassName, addr szWindowTitle,
                         WS_OVERLAPPEDWINDOW,
                         CW_USEDEFAULT, CW_USEDEFAULT, 600, 500,
                         NULL, NULL, NULL, NULL
    mov hWnd, eax
    
    invoke ShowWindow, hWnd, SW_SHOWNORMAL
    invoke UpdateWindow, hWnd
    
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