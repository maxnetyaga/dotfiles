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