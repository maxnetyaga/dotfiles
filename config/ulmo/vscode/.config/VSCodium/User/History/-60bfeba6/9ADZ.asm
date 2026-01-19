.386
.model flat, stdcall
option casemap:none
include masm32rt.inc

; === Макрос 1: Виведення повідомлень у MessageBox ===
ShowMessage MACRO msgText
    ; Показати повідомлення в MessageBox
    invoke MessageBox, 0, msgText, chr$("Info"), MB_OK
ENDM

; === Макрос 2: XOR-Шифрування (використовується в WinMain) ===
EncryptInput MACRO sourceKey, sourceData, outputBuffer
    LOCAL enc_loop
    lea esi, sourceKey
    lea edi, sourceData
    lea ebx, outputBuffer
enc_loop:
    mov al, [esi]
    mov cl, [edi]
    xor al, cl
    mov [ebx], al
    inc esi
    inc edi
    inc ebx
    cmp byte ptr [esi], 0
    jne enc_loop
    mov byte ptr [ebx], 0
ENDM

; === Макрос 3: Порівняння пароля ===
CompareHashedPassword MACRO original, input
    LOCAL @equal, @not_equal
    invoke lstrcmp, original, input
    .if eax == 0
        jmp @equal
    .else
        jmp @not_equal
    .endif
@equal:
    invoke MessageBoxW, 0, offset b2_netyaga, offset b1_netyaga, 0
    jmp @done
@not_equal:
    ShowMessage offset a4_netyaga
@done:
ENDM

.data
    a1_netyaga db 20 dup(0)
    a1_crypt db 3eh, 2dh, 04h, 21h, 35h, 1ah, 05h, 27h, 77h, 7fh, 5dh, 0ch, 21h, 03h, 1ch, 20h, 05h, 28h, 05h, 0
    a2 db "NLwRBuwCFMnSOfhYdOd", 0
    netyaga_a2_netyaga db "Password is correct!", 0
    a3_netyaga db "wrong", 0
    a4_netyaga db "Wrong password!", 0
    b1_netyaga dw "Пароль", 0
    b2_netyaga dw "Все правильно, залікова: КН123456", 0

.data?
    netyaga_c1_netyaga db 64 dup (?)  ; буфер для введення користувача

.code

x2 proc h1:dword, u1:dword, w1:dword, l1:dword
    .if u1 == WM_CLOSE
        invoke ExitProcess, 0
    .endif

    .if w1 == 8
        invoke GetDlgItemText, h1, 1983, addr netyaga_c1_netyaga, 64
        CompareHashedPassword offset a1_netyaga, offset netyaga_c1_netyaga
    .endif

    return 0
x2 endp

WinMain:
    EncryptInput a1_crypt, a2, a1_netyaga
    ; Використання макросу ShowMessage для різних полів:
    ShowMessage chr$("Прізвище: Іваненко")
    ShowMessage chr$("Ім’я: Олександр")
    ShowMessage chr$("По батькові: Сергійович")
    ShowMessage chr$("Номер залікової: КН123456")
    ShowMessage chr$("Дата народження: 05.07.2005")

    Dialog "password_for_netyaga", "Courier New", 14, WS_SYSMENU, 3, 100, 100, 100, 100, 4466
    DlgStatic "Введіть пароль:", 0, 0, 0, 100, 20, 445
    DlgEdit 0, 0, 10, 100, 20, 1983
    DlgButton "Перевірити", 0, 0, 30, 100, 20, 8
    CallModalDialog 0, 0, x2, NULL

end WinMain
