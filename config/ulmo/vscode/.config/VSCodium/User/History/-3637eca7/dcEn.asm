.386
.model flat, stdcall
option casemap:none
include masm32rt.inc

.data
    a1 db "password123", 0
    a2 db 50h, 61h, 73h, 73h, 77h, 6Fh, 72h, 64h, 20h, 69h, 73h, 20h, 63h, 6Fh, 72h, 72h, 65h, 63h, 74h, 21h, 0  
    a3 db "wrong", 0 
    a4 db "wrong", 0 
    b1 dw 41fh, 435h, 440h, 441h, 43eh, 43dh, 430h, 43bh, 44ch, 43dh, 456h, 20h, 434h, 430h, 43dh, 456h, 20h, 441h, 442h, 443h, 434h, 435h, 43dh, 442h, 430h, 0
    b2 dw 41dh, 435h, 442h, 44fh, 433h, 430h, 20h, 41ch, 430h, 43ah, 441h, 438h, 43ch, 20h, 41ah, 43eh, 441h, 442h, 44fh, 43dh, 442h, 438h, 43dh, 43eh, 432h, 438h, 447h, 13, 10
            dw 414h, 430h, 442h, 430h, 20h, 43dh, 430h, 440h, 43eh, 434h, 436h, 435h, 43dh, 43dh, 44fh, 3ah, 20h, 30h, 35h, 2eh, 30h, 37h, 2eh, 32h, 30h, 30h, 35h, 13, 10
            dw 41dh, 43eh, 43ch, 435h, 440h, 20h, 437h, 430h, 43bh, 456h, 43ah, 43eh, 432h, 43eh, 457h, 20h, 43ah, 43dh, 438h, 436h, 43ah, 438h, 3ah, 20h, 43dh, 435h, 43ch, 430h, 454h, 20h, 3ah, 28h, 13, 10
            dw 413h, 440h, 443h, 43fh, 430h, 3ah, 20h, 406h, 41ch, 2dh, 33h, 34h, 0
.data?
    c1 db 64 dup (?)  
.code
x2 proc h1:dword, u1:dword, w1:dword, l1:dword
    .if u1 == 111h  
        .if w1 == 1  
            invoke GetDlgItemText, h1, 1983, addr c1, 64
            invoke lstrcmp, offset a1, offset c1
            .if EAX == 0
                invoke MessageBoxW, 0, offset b2, offset b1, 0
            .else
                invoke MessageBox, 0, offset a4, offset a3, 0
            .endif
        .endif
    .elseif u1 == 10h  
        invoke ExitProcess, 0
    .endif
    return 0
x2 endp
start:
    Dialog "password_for_netyaga", "Courier New", 14, WS_SYSMENU, 3, 100, 100, 100, 100, 4466
    DlgStatic "put_password_for_netyaga", SS_CENTER, 10, 15, 100, 10, 445
    DlgEdit 0, 10, 40, 180, 25, 1983
    DlgButton "OK", WS_TABSTOP, 110, 80, 70, 30, 1  
    CallModalDialog 0, 0, x2, NULL
end start