include masm32rt.inc
public netyaga_d_vals, netyaga_a_vals, fp_one
extern NetyagaDenominatorNetyaga:proto

.data?
    hInstance HINSTANCE ?
    numerator_1 dt ?
    numerator_2 dt ?
    denominator_1 dt ?
.data
    szCourierNew db "Courier New",0
    netyaga_a_vals dq 1.123, 1.123, 1000.123, 1000.123, 1.123, 1.123
    netyaga_b_vals dq 1.234, 1000.234, 1.234, 1000.234, 1.234, 1.234
    netyaga_c_vals dq 100.234, 100.234, 100.234, 100.234, 100.234, -1.234
    netyaga_d_vals dq 5.123, 5.123, 5.123, 5.123, 0.123, 5.123
    szClassName db "FormulaWindowClass",0
    szWindowTitle db "Formula Calculator",0
    formula db "Formula: (4*lg(c) - b/2 + 23) / (d - a + 1)",0
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


    fp_one dq 1.0
    fp_two dt 2.0
    fp_four dt 4.0
    fp_twenty_three dt 23.0


    str_a_val db 32 dup(0)
    str_b_val db 32 dup(0)
    str_c_val db 32 dup(0)
    str_d_val db 32 dup(0)
    str_intermediate db 32 dup(0)
    str_result db 32 dup(0)
    fp_format db "%.3f",0

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
NumeratorFirstPart proc
    fld REAL8 ptr [ecx]
    fldlg2
    fxch
    fyl2x
    fld REAL10 ptr [edx]
    fmul
    fstp numerator_1
    mov ecx, offset numerator_1
    fclex
    ret
NumeratorFirstPart endp
NumeratorSecondPart proc
    push ebp
    mov ebp, esp
    mov ecx, [ebp+16]
    mov edx, dword ptr [ebp+12]
    fld REAL8 ptr [ecx]
    fld REAL10 ptr [edx]
    fdivp st(1), st(0)
    mov edx, [ebp+8]
    fld REAL10 ptr [edx]
    faddp st(1), st(0)
    mov esp, ebp
    pop ebp
    ret 12
NumeratorSecondPart endp
CalculateAndDisplay proc hWnd:HWND
    local temp_buf[256]:byte
    local numerator:REAL10
    local denominator:REAL10
    local result:REAL10
    local intermediate:REAL10
    local final_result_val:REAL8

    mov [current_pos], 0
    mov byte ptr [output_buffer], 0
    invoke AppendText, addr formula
    invoke AppendText, addr separator

    mov esi, 0
    .while esi < 6
        finit

        mov ebx, esi
        shl esi, 3


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

        fld netyaga_c_vals[esi]
        ftst
        fstsw ax
        sahf
        jbe log_error


        lea ecx, [netyaga_c_vals+esi]
        mov edx, offset fp_four
        call NumeratorFirstPart
        fld REAL10 ptr [ecx]
        fstp numerator_1

        lea edx, [netyaga_b_vals+esi]
        push edx
        push offset fp_two
        push offset fp_twenty_three
        call NumeratorSecondPart
        fstp numerator_2

        call NetyagaDenominatorNetyaga
        fstp denominator_1

        fld numerator_2
        fld numerator_1
        fsubp st(1), st(0)
        fld denominator_1
        fxch
        fdivp st(1), st(0)
        fstp [final_result_val]

        invoke FloatToStr, final_result_val, addr str_result
        invoke wsprintf, addr temp_buf, addr final_result, addr str_result
        invoke AppendText, addr temp_buf

        jmp next_iteration

    log_error:
        fstp st(0)
        invoke AppendText, addr log_viol
        jmp next_iteration

    div_zero_error:
        fstp st(0)
        invoke AppendText, addr division_by_zero

    next_iteration:
        invoke AppendText, addr separator
        fstp st(0)
        mov esi, ebx
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
    push hInstance
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
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke WinMain
    invoke ExitProcess, 0

end start