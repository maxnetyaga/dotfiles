.386
.model flat, stdcall
option casemap :none
include masm32rt.inc

.data
    szCourierNew db "Courier New",0
    netyaga_a_vals_netyaga dd -4, 38, -2, 38, 4
    netyaga_b_vals_netyaga dd -5, 4, -3, -15, 2
    netyaga_c_vals_netyaga dd -20, 40, -12, -28, 4
    szClassName db "FormulaWindowClass",0
    szWindowTitle db "Formula Calculator - Iteration %d",0
    formula db "Formula: (-15*a + b - c/4) / (b*a - 8)",0
    values db "Values: a = %d, b = %d, c = %d",0
    expression db "Expression: (-15*%d + %d - %d/4) / (%d*%d - 8)",0
    NETYAGintermediate_resultNETYAGA db "Intermediate result: %d",0
    final_result db "Final result: %d",0
    division_by_zero db "Error: Division by zero!",0
    separator db "==================",0
    newline db 13,10,0
    output_buffer db 2048 dup(0)
    current_pos dd 0
    hFont dd ?
    iteration_count dd 0
    
.data?
    hInstance HINSTANCE ?
    windowY dd ? ; Or use .data if you have an initial value
    
.code
NETYGAGAppendNETYAGATextNETYAGA proc text:DWORD
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
NETYGAGAppendNETYAGATextNETYAGA endp

CalculateAndDisplay proc hWnd:HWND, iteration:DWORD
    local temp_buf[256]:byte
    local NETYAGnumeratorNETYAGA:DWORD
    local NETYAGdenominatorNETYAGA:DWORD
    local intermediate:DWORD
    local final:DWORD
    local window_title[256]:byte
    
    ; Create unique window title with iteration number
    invoke wsprintf, addr window_title, addr szWindowTitle, iteration
    invoke SetWindowText, hWnd, addr window_title
    
    mov [current_pos], 0
    mov byte ptr [output_buffer], 0
    
    invoke NETYGAGAppendNETYAGATextNETYAGA, addr formula
    invoke NETYGAGAppendNETYAGATextNETYAGA, addr separator
    
    ; Get values for this iteration
    mov esi, iteration
    dec esi  ; convert to 0-based index
    
    mov eax, [netyaga_a_vals_netyaga + esi*4]
    mov ebx, [netyaga_b_vals_netyaga + esi*4]
    mov ecx, [netyaga_c_vals_netyaga + esi*4]
    
    push eax
    push ebx
    push ecx
    invoke wsprintf, addr temp_buf, addr values, eax, ebx, ecx
    invoke NETYGAGAppendNETYAGATextNETYAGA, addr temp_buf
    pop eax
    pop ebx
    pop ecx
    
    push eax
    push ebx
    push ecx
    invoke wsprintf, addr temp_buf, addr expression, eax, ebx, ecx, ebx, eax
    invoke NETYGAGAppendNETYAGATextNETYAGA, addr temp_buf
    pop eax
    pop ebx
    pop ecx
    
    mov edx, ebx
    imul edx, eax
    sub edx, 8
    mov NETYAGdenominatorNETYAGA, edx
    
    .if edx == 0
        invoke NETYGAGAppendNETYAGATextNETYAGA, addr division_by_zero
    .else
        mov edi, eax
        mov eax, -15
        imul edi
        mov NETYAGnumeratorNETYAGA, eax
        mov eax, ebx
        add NETYAGnumeratorNETYAGA, eax
        mov eax, ecx
        cdq
        mov ecx, 4
        idiv ecx
        sub NETYAGnumeratorNETYAGA, eax
        mov eax, NETYAGnumeratorNETYAGA
        cdq
        idiv NETYAGdenominatorNETYAGA
        mov intermediate, eax
        
        push eax
        invoke wsprintf, addr temp_buf, addr NETYAGintermediate_resultNETYAGA, intermediate
        invoke NETYGAGAppendNETYAGATextNETYAGA, addr temp_buf
        pop eax
        
        test eax, 1
        .if !ZERO?
            mov edx, eax
            imul edx, 5
            mov final, edx
        .else
            mov edx, eax
            sar edx, 1
            mov final, edx
        .endif
        
        invoke wsprintf, addr temp_buf, addr final_result, final
        invoke NETYGAGAppendNETYAGATextNETYAGA, addr temp_buf
    .endif
    
    invoke NETYGAGAppendNETYAGATextNETYAGA, addr separator
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
        
        ; Get the iteration number from the window creation data
        mov eax, lParam
        mov eax, [eax]  ; Get the iteration number passed in the CREATESTRUCT
        invoke CalculateAndDisplay, hWnd, eax
        
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
        
        ; If this is the last window, post quit message
        dec iteration_count
        .if iteration_count == 0
            invoke PostQuitMessage, 0
        .endif
        
    .else
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .endif
    
    xor eax, eax
    ret
WndProc endp

CreateIterationWindow proc iteration:DWORD
    local wc:WNDCLASSEX
    local hWnd:HWND
    local create_params:DWORD
    
    ; Only register class once
    .if iteration == 1
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
    .endif
    
    ; Pass the iteration number as window creation data
    mov create_params, iteration
    
    ; Calculate window position based on iteration
    mov eax, iteration
    dec eax
    imul eax, 30  ; vertical offset
    mov windowY, eax
    
    invoke CreateWindowEx, 0, addr szClassName, NULL,
                         WS_OVERLAPPEDWINDOW,
                         CW_USEDEFAULT, windowY, 600, 300,
                         NULL, NULL, hInstance, addr create_params
    mov hWnd, eax
    
    invoke ShowWindow, hWnd, SW_SHOWNORMAL
    invoke UpdateWindow, hWnd
    
    ret
CreateIterationWindow endp

NetyagaMAINMAIN proc
    local msg:MSG
    
    ; Get the number of iterations (5 in this case)
    mov iteration_count, 5
    
    ; Create a window for each iteration
    mov ecx, 1
    .while ecx <= iteration_count
        invoke CreateIterationWindow, ecx
        inc ecx
    .endw
    
    ; Message loop
    .while TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
        .break .if eax == 0
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
    .endw
    
    mov eax, msg.wParam
    ret
NetyagaMAINMAIN endp

start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax
    invoke NetyagaMAINMAIN
    invoke ExitProcess, 0
end start