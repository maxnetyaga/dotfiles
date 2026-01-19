include masm32rt.inc

.data?
    hInstance HINSTANCE ?        ; Moved to top to ensure it's defined before use

.data
    szCourierNew db "Courier New",0
    netyaga_a_vals dq 1.123, 1.123, 1000.123, 1000.123, 1.123, 1.123
    netyaga_b_vals dq 1.234, 1000.234, 1.234, 1000.234, 1.234, 1.234
    netyaga_c_vals dq 100.234, 100.234, 100.234, 100.234, 100.234, -1.234
    netyaga_d_vals dq 5.123, 5.123, 5.123, 5.123, 0.123, 5.123
    szClassName db "FormulaWindowClass",0
    szWindowTitle db "Formula Calculator",0
    formula db "Formula: (4*lg(c) - b/2 + 23) / (d - a + 1)",0
    
    ; Fixed format strings to use proper formatting
    values db "Values: a = %s, b = %s, c = %s, d = %s",0
    expression db "Expression: (4*lg(%s) - %s/2 + 23) / (%s - %s + 1)",0
    intermediate_result db "Intermediate result: %s",0
    final_result db "Final result: %s",0
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
    
    ; Add buffers for string representations of floating-point values
    str_a_val db 32 dup(0)
    str_b_val db 32 dup(0)
    str_c_val db 32 dup(0)
    str_d_val db 32 dup(0)
    str_intermediate db 32 dup(0)
    str_result db 32 dup(0)
    fp_format db "%.3f",0   ; Format for floating point conversion
    
.code
; New procedure to convert floating point to string


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
    local numerator:REAL10    ; Using REAL10 for all calculations
    local denominator:REAL10
    local result:REAL10
    local final_result_val:REAL8  ; Only convert to REAL8 for display
    
    mov [current_pos], 0
    mov byte ptr [output_buffer], 0
    invoke AppendText, addr formula
    invoke AppendText, addr separator
    
    mov esi, 0
    .while esi < 6
        ; Calculate index for current iteration
        mov ebx, esi    ; Save original index in ebx
        shl esi, 3      ; esi = esi * 8 (size of QWORD/dq)
        
        ; Display values
        invoke FloatToStr, qword ptr [netyaga_a_vals + esi], addr str_a_val
        invoke FloatToStr, qword ptr [netyaga_b_vals + esi], addr str_b_val
        invoke FloatToStr, qword ptr [netyaga_c_vals + esi], addr str_c_val
        invoke FloatToStr, qword ptr [netyaga_d_vals + esi], addr str_d_val
        
        invoke wsprintf, addr temp_buf, addr values, 
                       addr str_a_val, addr str_b_val, 
                       addr str_c_val, addr str_d_val
        invoke AppendText, addr temp_buf
        
        invoke wsprintf, addr temp_buf, addr expression,
                       addr str_c_val, addr str_b_val,
                       addr str_d_val, addr str_a_val
        invoke AppendText, addr temp_buf

        ; Check if c > 0 for logarithm
        fld qword ptr [netyaga_c_vals + esi]  ; Load c
        ftst                      
        fstsw ax
        sahf
        jbe log_error             ; Jump if c <= 0

        ; Calculate numerator: (4*lg(c) - b/2 + 23)
        fld qword ptr [netyaga_c_vals + esi]  ; Load c
        fldlg2                   ; log10(2)
        fxch                     ; c, log10(2)
        fyl2x                    ; log10(c)
        
        fld fp_four              ; 4.0
        fmulp                    ; 4*log10(c)
        
        fld qword ptr [netyaga_b_vals + esi] ; Load b
        fld fp_two                ; 2.0
        fdivp                    ; b/2
        
        fsubp                    ; 4*lg(c) - b/2
        
        fld fp_twenty_three      ; 23.0
        faddp                    ; 4*lg(c) - b/2 + 23
        fstp numerator           ; Store numerator
        
        ; Calculate denominator: d - a + 1
        fld qword ptr [netyaga_d_vals + esi] ; Load d
        fld qword ptr [netyaga_a_vals + esi] ; Load a
        fsubp                    ; d - a
        fld fp_one               ; 1.0
        faddp                    ; (d - a) + 1
        fstp denominator         ; Store denominator
        
        ; Check for division by zero
        fld denominator
        ftst
        fstsw ax
        sahf
        je div_zero_error
        
        ; Compute result = numerator / denominator
        fld numerator
        fld denominator
        fdivp
        fstp result              ; Store result
        
        ; Convert final result to double for display
        fld result
        fstp final_result_val    ; Convert from REAL10 to REAL8
        
        ; Display result
        invoke FloatToStr, final_result_val, addr str_result
        invoke wsprintf, addr temp_buf, addr final_result, addr str_result
        invoke AppendText, addr temp_buf
        
        jmp next_iteration
        
    log_error:
        finit                    ; Clear FPU stack completely
        invoke AppendText, addr log_viol
        jmp next_iteration
        
    div_zero_error:
        finit                    ; Clear FPU stack completely
        invoke AppendText, addr division_by_zero
        
    next_iteration:
        invoke AppendText, addr separator
        mov esi, ebx             ; Restore original index
        inc esi                  ; Next iteration
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
    push hInstance    ; Fix: Use push/pop instead of direct mov with memory operand
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
                         NULL, NULL, hInstance, NULL
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
    
end start