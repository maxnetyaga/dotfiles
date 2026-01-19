.386
.model flat, stdcall
option casemap:none
include masm32rt.inc
.data
    ; a1_netyaga db "AS@GBYEm]QAOV_X", 0
    a1_netyaga db 20 dup(0)
    a1_crypt db 3eh, 2dh, 04h, 21h, 35h, 1ah, 05h, 27h, 77h, 7fh, 5dh, 0ch, 21h, 03h, 1ch, 20h, 05h, 28h, 05h, 0
    a2 db "NLwRBuwCFMnSOfhYdOd", 0
    netyaga_a2_netyaga db 50h, 61h, 73h, 73h, 77h, 6Fh, 72h, 64h, 20h, 69h, 73h, 20h, 63h, 6Fh, 72h, 72h, 65h, 63h, 74h, 21h, 0  
    a3_netyaga db "wrong", 0 
    a4_netyaga db "wrong", 0 
    b1_netyaga dw 41fh, 435h, 440h, 441h, 43eh, 43dh, 430h, 43bh, 44ch, 43dh, 456h, 20h, 434h, 430h, 43dh, 456h, 20h, 441h, 442h, 443h, 434h, 435h, 43dh, 442h, 430h, 0
    b2_netyaga dw 41dh, 435h, 442h, 44fh, 433h, 430h, 20h, 41ch, 430h, 43ah, 441h, 438h, 43ch, 20h, 41ah, 43eh, 441h, 442h, 44fh, 43dh, 442h, 438h, 43dh, 43eh, 432h, 438h, 447h, 13, 0
    b3_netyaga dw 414h, 430h, 442h, 430h, 20h, 43dh, 430h, 440h, 43eh, 434h, 436h, 435h, 43dh, 43dh, 44fh, 3ah, 20h, 30h, 35h, 2eh, 30h, 37h, 2eh, 32h, 30h, 30h, 35h, 13, 0
    b4_netyaga dw 41dh, 43eh, 43ch, 435h, 440h, 20h, 437h, 430h, 43bh, 456h, 43ah, 43eh, 432h, 43eh, 457h, 20h, 43ah, 43dh, 438h, 436h, 43ah, 438h, 3ah, 20h, 43dh, 435h, 43ch, 430h, 454h, 20h, 3ah, 28h, 13, 0
    b5_netyaga dw 413h, 440h, 443h, 43fh, 430h, 3ah, 20h, 406h, 41ch, 2dh, 33h, 34h, 0
.data?
    netyaga_c1_netyaga db 64 dup (?)  
dcrp_mcr macro
    lea esi, a1_crypt
    lea edi, a2
    lea ebx, a1_netyaga
    ; comment in dcrp_mcr
    ;; hidden_comment_in_dcrp_mcr
    xor_l:
        mov al, [esi]
        mov cl, [edi]
        xor al, cl
        mov [ebx], al
        inc esi
        inc edi
        inc ebx
        cmp byte ptr [esi], 0
        jne xor_l
        mov byte ptr [ebx], 0
endm
lst_inf_ macro x, y 
    invoke MessageBoxW, 0, addr x, addr y, 0
    ; thng_to_show_here
    ;; hidden_thng_show_&ere
endm
cmpr__ macro xx, yy
    LOCAL locai
    ;;local-label-for-local-in-local
    ;local
    locai:
        invoke lstrcmp, addr xx, addr yy
endm
.code
x2 proc h1:dword, u1:dword, w1:dword, l1:dword
    .if u1 == 10h  
        invoke ExitProcess, 0
    .endif
        .if w1 == 8
                invoke GetDlgItemText, h1, 1983, addr netyaga_c1_netyaga, 64
                ;invoke lstrcmp, offset a1_netyaga, offset netyaga_c1_netyaga
                cmpr__ a1_netyaga, netyaga_c1_netyaga
                .if EAX == 0
                ; invoke MessageBoxW, 0, offset b2_netyaga, offset b1_netyaga, 0
                lst_inf_ b2_netyaga, b1_netyaga
                lst_inf_ b3_netyaga, b1_netyaga
                lst_inf_ b4_netyaga, b1_netyaga
                lst_inf_ b5_netyaga, b1_netyaga
                .else
                invoke MessageBox, 0, offset a4_netyaga, offset a3_netyaga, 0
                .endif
        .endif
    return 0
x2 endp
WinMain:
    dcrp_mcr
    Dialog "password_for_netyaga", "Courier New", 14, WS_SYSMENU, 3, 100, 100, 100, 100, 4466
    DlgStatic "put_p_here", 0, 0, 0, 100, 20, 445
    DlgEdit 0, 0, 10, 100, 20, 1983
    DlgButton "press_show_here", 0, 0, 30, 100, 20, 8
    CallModalDialog 0, 0, x2, NULL
end WinMain