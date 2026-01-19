.386
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
    
    ; Floating point constants - using dt for higher precision in calculations
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
    local numerator:REAL10    ; Using REAL10 (80-bit) for calculations
    local denominator:REAL10
    local result:REAL10
    local intermediate:REAL10
    local final_result_val:REAL8  ; REAL8 (64-bit) for display output
    
    mov [current_pos], 0
    mov byte ptr [output_buffer], 0
    invoke AppendText, addr formula
    invoke AppendText, addr separator
    
    mov esi, 0
    .while esi < 6
        ; Calculate index for current iteration
        mov ebx, esi    ; Save original index in ebx
        shl esi, 3      ; esi = esi * 8 (size of QWORD/dq)
        
        ; Format values string
        invoke wsprintf, addr temp_buf, addr values, 
                       dword ptr [netyaga_a_vals + esi], dword ptr [netyaga_a_vals + esi + 4],
                       dword ptr [netyaga_b_vals + esi], dword ptr [netyaga_b_vals + esi + 4],
                       dword ptr [netyaga_c_vals + esi], dword ptr [netyaga_c_vals + esi + 4],
                       dword ptr [netyaga_d_vals + esi], dword ptr [netyaga_d_vals + esi + 4]
        invoke AppendText, addr temp_buf
        
        ; Format expression string
        invoke wsprintf, addr temp_buf, addr expression,
                       dword ptr [netyaga_c_vals + esi], dword ptr [netyaga_c_vals + esi + 4],
                       dword ptr [netyaga_b_vals + esi], dword ptr [netyaga_b_vals + esi + 4],
                       dword ptr [netyaga_d_vals + esi], dword ptr [netyaga_d_vals + esi + 4],
                       dword ptr [netyaga_a_vals + esi], dword ptr [netyaga_a_vals + esi + 4]
        invoke AppendText, addr temp_buf

        ; Check if c > 0 for logarithm
        fld qword ptr [netyaga_c_vals + esi]  ; Load c as REAL8 (dq)
        ftst                                  ; Test if c > 0
        fstsw ax
        sahf
        jbe log_error                         ; Jump if c <= 0

        ; Calculate numerator: (4*lg(c) - b/2 + 23)
        ; Load c and convert to log10(c)
        fld qword ptr [netyaga_c_vals + esi]  ; Load c as REAL8 (dq)
        fldlg2                               ; Load log10(2)
        fxch                                 ; Swap to get c, log10(2)
        fyl2x                                ; Compute log10(c)
        
        ; Multiply by 4 using extended precision
        fld tbyte ptr [fp_four]              ; Load 4.0 as REAL10 (dt)
        fmulp st(1), st(0)                   ; 4*log10(c)
        
        ; Compute b/2 using extended precision
        fld qword ptr [netyaga_b_vals + esi] ; Load b as REAL8 (dq)
        fld tbyte ptr [fp_two]               ; Load 2.0 as REAL10 (dt)
        fdivp st(1), st(0)                   ; b/2 with extended precision
        
        ; Subtract b/2 from 4*log10(c)
        fsubp st(1), st(0)                   ; 4*lg(c) - b/2
        
        ; Add 23
        fld tbyte ptr [fp_twenty_three]      ; Load 23.0 as REAL10 (dt)
        faddp st(1), st(0)                   ; 4*lg(c) - b/2 + 23
        fstp tbyte ptr [numerator]           ; Store as REAL10 (dt)
        
        ; Calculate denominator: d - a + 1
        fld qword ptr [netyaga_d_vals + esi] ; Load d as REAL8 (dq)
        fld qword ptr [netyaga_a_vals + esi] ; Load a as REAL8 (dq)
        fsubp st(1), st(0)                   ; d - a
        fld tbyte ptr [fp_one]               ; Load 1.0 as REAL10 (dt)
        faddp st(1), st(0)                   ; (d - a) + 1
        fstp tbyte ptr [denominator]         ; Store as REAL10 (dt)
        
        ; Check for division by zero
        fld tbyte ptr [denominator]
        ftst
        fstsw ax
        sahf
        je div_zero_error
        
        ; Compute result = numerator / denominator with extended precision
        fld tbyte ptr [numerator]
        fld tbyte ptr [denominator]
        fdivp st(1), st(0)
        fstp tbyte ptr [result]              ; Store result as REAL10 (dt)
        
        ; Display intermediate result (convert to REAL8 for display)
        fld tbyte ptr [numerator]
        fstp qword ptr [final_result_val]    ; Convert to REAL8 for display
        invoke wsprintf, addr temp_buf, addr intermediate_result,
                       dword ptr [final_result_val], dword ptr [final_result_val + 4]
        invoke AppendText, addr temp_buf
        
        ; Convert final result to double for display
        fld tbyte ptr [result]
        fstp qword ptr [final_result_val]    ; Convert from REAL10 to REAL8
        invoke wsprintf, addr temp_buf, addr final_result,
                       dword ptr [final_result_val], dword ptr [final_result_val + 4]
        invoke AppendText, addr temp_buf
        
        jmp next_iteration
        
    log_error:
        fstp st(0)  ; Clear FPU stack
        invoke AppendText, addr log_viol
        jmp next_iteration
        
    div_zero_error:
        fstp st(0)  ; Clear FPU stack
        invoke AppendText, addr division_by_zero
        
    next_iteration:
        invoke AppendText, addr separator
        mov esi, ebx    ; Restore original index from ebx
        inc esi         ; Increment for next iteration
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
    mov wc.hInstance, hInstance    ; Use the proper hInstance
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
                         NULL, NULL, hInstance, NULL    ; Pass hInstance here
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
    invoke GetModuleHandle, NULL    ; Get module handle first
    mov hInstance, eax              ; Store it
    invoke WinMain                  ; Then call WinMain
    invoke ExitProcess, 0
    
.data?
    hInstance HINSTANCE ?
end start