.model small
.stack 200h

; ============================================================
.data
    msg_welcome  db 0Dh,0Ah
                 db '======================================',0Dh,0Ah
                 db '     WELCOME TO NOVAPAY BANK ATM      ',0Dh,0Ah
                 db '======================================',0Dh,0Ah,'$'

    msg_pin      db 0Dh,0Ah,'Enter 4-digit PIN: $'
    msg_newline  db 0Dh,0Ah,'$'
    msg_wrong    db 0Dh,0Ah,'Wrong PIN! $'
    msg_rem      db ' attempt(s) remaining.',0Dh,0Ah,'$'
    msg_locked   db 0Dh,0Ah,'Account locked. Contact NovaPay Bank.',0Dh,0Ah,'$'

    msg_menu     db 0Dh,0Ah
                 db '--------------------------------------',0Dh,0Ah
                 db ' 1. Check Balance',0Dh,0Ah
                 db ' 2. Withdraw Cash',0Dh,0Ah
                 db ' 3. Deposit Cash',0Dh,0Ah
                 db ' 4. Exit',0Dh,0Ah
                 db '--------------------------------------',0Dh,0Ah
                 db 'Enter your choice: $'

    msg_bal      db 0Dh,0Ah,'Your Current Balance: Rs. $'
    msg_wdraw    db 0Dh,0Ah,'Enter amount to withdraw: $'
    msg_dep      db 0Dh,0Ah,'Enter amount to deposit:  $'
    msg_ok       db 0Dh,0Ah,'Transaction Successful!',0Dh,0Ah,'$'
    msg_insuff   db 0Dh,0Ah,'Insufficient Balance!',0Dh,0Ah,'$'
    msg_invalid  db 0Dh,0Ah,'Invalid choice, please try again.',0Dh,0Ah,'$'
    msg_thanks   db 0Dh,0Ah,'Thank you for using NovaPay Bank ATM!',0Dh,0Ah,'$'

    ; ---- 32-bit balance: value = bal_hi * 65536 + bal_lo ----
    bal_lo       dw 5000          ; low  word of balance
    bal_hi       dw 0             ; high word of balance

    ; ---- 32-bit input accumulator ----
    tmp_lo       dw 0
    tmp_hi       dw 0

    ; ---- PIN storage (array of 4 bytes) & attempt counter ----
    pin_buf      db 4 dup(0)      ; Week 7 : array declaration
    attempts     db 3

    ; ---- Constant used for division in PrintNumber32 ----
    ten          dw 10

; ============================================================
.code

; ============================================================
; main  –  program entry point
; ============================================================
main proc
    ; Week 2 : MOV to initialise segment register
    mov  ax, @data
    mov  ds, ax

    ; Display welcome banner
    lea  dx, msg_welcome
    mov  ah, 09h
    int  21h

    ; Call PIN-check procedure (Week 9 : user-defined PROC)
    call CheckPIN
    cmp  al, 1                    ; Week 3 : CMP
    jne  quit                     ; Week 6 : conditional jump

menu_loop:
    lea  dx, msg_menu
    mov  ah, 09h
    int  21h

    mov  ah, 01h                  ; int 21h – read character with echo
    int  21h

    ; Week 13 : PUSH / POP to save AX across the newline print
    push ax
    lea  dx, msg_newline
    mov  ah, 09h
    int  21h
    pop  ax

    ; Week 2 : SUB to convert ASCII digit ? numeric value
    sub  al, '0'
    cmp  al, 1                    ; Week 3/6 : CMP + JE chain
    je   do_bal
    cmp  al, 2
    je   do_wdraw
    cmp  al, 3
    je   do_dep
    cmp  al, 4
    je   quit

    ; Invalid key
    lea  dx, msg_invalid
    mov  ah, 09h
    int  21h
    jmp  menu_loop

do_bal:
    call PrintBalance             ; Week 9 : procedure call
    jmp  menu_loop

do_wdraw:
    lea  dx, msg_wdraw
    mov  ah, 09h
    int  21h
    call InputNumber32            ; DX:AX = amount entered

    ; 32-bit compare:  amount (DX:AX) > balance (bal_hi:bal_lo)?
    ; Week 3/6 : CMP with JA / JB for unsigned comparison
    cmp  dx, bal_hi
    ja   no_funds
    jb   ok_wdraw
    cmp  ax, bal_lo
    ja   no_funds

ok_wdraw:
    ; Week 2 : SUB (32-bit: SUB lo word, then SBB hi word with borrow flag)
    sub  bal_lo, ax
    sbb  bal_hi, dx
    lea  dx, msg_ok
    mov  ah, 09h
    int  21h
    jmp  menu_loop

no_funds:
    lea  dx, msg_insuff
    mov  ah, 09h
    int  21h
    jmp  menu_loop

do_dep:
    lea  dx, msg_dep
    mov  ah, 09h
    int  21h
    call InputNumber32            ; DX:AX = amount entered

    ; Week 2 : ADD (32-bit: ADD lo word, then ADC hi word with carry flag)
    add  bal_lo, ax
    adc  bal_hi, dx
    lea  dx, msg_ok
    mov  ah, 09h
    int  21h
    jmp  menu_loop

quit:
    lea  dx, msg_thanks
    mov  ah, 09h
    int  21h
    mov  ah, 4Ch                  ; int 21h – terminate program
    int  21h
main endp


; ============================================================
;  CheckPIN
;   Reads a 4-digit PIN with '*' masking.
;   Uses:  Week 7 (array pin_buf + LOOP),
;          Week 9 (PROC / RET),
;          Week 13 (PUSH/POP)
;   Returns: AL = 1 (correct PIN) or 0 (account locked)
; ============================================================
CheckPIN proc
    mov  attempts, 3              ; initialise attempt counter

pin_try:
    lea  dx, msg_pin
    mov  ah, 09h
    int  21h

    ; Read 4 characters into pin_buf array using LOOP (Week 7)
    mov  cx, 4                    ; loop counter  (Week 7 : LOOP)
    lea  si, pin_buf              ; SI points to start of array

pin_rd:
    mov  ah, 08h                  ; int 21h – read key WITHOUT echo
    int  21h
    mov  [si], al                 ; store byte in array element
    inc  si                       ; advance array pointer

    ; Print '*' in place of the character (Week 2 : MOV + int 21h)
    mov  dl, '*'
    mov  ah, 02h
    int  21h
    loop pin_rd                   ; Week 7 : LOOP instruction

    ; Newline after the four stars
    lea  dx, msg_newline
    mov  ah, 09h
    int  21h

    ; Compare PIN == "1234"  (Week 3 : CMP, Week 6 : JNE)
    cmp  byte ptr pin_buf[0], '1'
    jne  pin_bad
    cmp  byte ptr pin_buf[1], '2'
    jne  pin_bad
    cmp  byte ptr pin_buf[2], '3'
    jne  pin_bad
    cmp  byte ptr pin_buf[3], '4'
    jne  pin_bad

    mov  al, 1                    ; PIN correct
    ret

pin_bad:
    ; Week 2 : SUB (decrement attempts)
    dec  attempts
    cmp  attempts, 0              ; Week 3 : CMP
    je   pin_locked               ; Week 6 : JE

    ; Show "Wrong PIN! X attempt(s) remaining."
    lea  dx, msg_wrong
    mov  ah, 09h
    int  21h

    ; Week 2 : MOV + ADD to convert count ? ASCII digit
    mov  dl, attempts
    add  dl, '0'
    mov  ah, 02h
    int  21h

    lea  dx, msg_rem
    mov  ah, 09h
    int  21h
    jmp  pin_try                  ; Week 6 : unconditional JMP

pin_locked:
    lea  dx, msg_locked
    mov  ah, 09h
    int  21h
    mov  al, 0                    ; PIN failed – account locked
    ret
CheckPIN endp


; ============================================================
;  PrintBalance
;   Displays the current 32-bit balance.
;   Week 9  : PROC / RET
; ============================================================
PrintBalance proc
    lea  dx, msg_bal
    mov  ah, 09h
    int  21h
    ; Load 32-bit balance into DX:AX and print
    mov  ax, bal_lo
    mov  dx, bal_hi
    call PrintNumber32            ; Week 9 : nested procedure call
    ret
PrintBalance endp


; ============================================================
;  InputNumber32
;   Reads decimal digits until Enter (0Dh).
;   Accumulates result as 32-bit value in tmp_hi:tmp_lo.
;   Returns DX:AX = value entered.
;
;   Topics used:
;     Week 2  : MOV, MUL, ADD, SUB, int 21h
;     Week 6  : CMP + conditional jumps (JE, JB, JA)
;     Week 9  : PROC / RET
;     Week 13 : PUSH / POP  (preserve BX, CX, SI)
; ============================================================
InputNumber32 proc
    ; Week 13 : PUSH registers onto stack before use
    push bx
    push cx
    push si

    ; Initialise 32-bit accumulator to 0
    mov  tmp_lo, 0
    mov  tmp_hi, 0

in_loop:
    mov  ah, 01h                  ; int 21h – read char with echo
    int  21h

    cmp  al, 0Dh                  ; Week 3/6 : CMP + JE — Enter key?
    je   in_done

    cmp  al, '0'                  ; ignore non-digit characters
    jb   in_loop
    cmp  al, '9'
    ja   in_loop

    ; Week 2 : SUB – convert ASCII ? digit value 0-9
    sub  al, '0'
    xor  ah, ah                   ; zero AH so AX = digit
    mov  si, ax                   ; save digit in SI

    ; ---- 32-bit multiply: tmp = tmp * 10 + digit ----
    ;  Low word:  tmp_lo * 10
    mov  ax, tmp_lo
    mov  cx, 10
    mul  cx                       ; Week 2 : MUL - DX:AX = tmp_lo * 10
    mov  bx, dx                   ; BX holds carry from low multiplication
    mov  tmp_lo, ax               ; store new low word

    ;  High word: tmp_hi * 10  +  carry from low
    mov  ax, tmp_hi
    mul  cx                       ; Week 2 : MUL - DX:AX = tmp_hi * 10
    add  ax, bx                   ; Week 2 : ADD carry in
    mov  tmp_hi, ax               ; store new high word

    ; Add digit to low word, propagate carry to high word
    add  tmp_lo, si               ; Week 2 : ADD
    adc  tmp_hi, 0                ; ADC propagates carry flag (Week 6 : flag use)

    jmp  in_loop                  ; Week 6 : unconditional JMP

in_done:
    ; Print newline after input
    push ax
    lea  dx, msg_newline
    mov  ah, 09h
    int  21h
    pop  ax

    ; Return result in DX:AX
    mov  ax, tmp_lo
    mov  dx, tmp_hi

    ; Week 13 : POP registers — restore in reverse order
    pop  si
    pop  cx
    pop  bx
    ret
InputNumber32 endp


; ============================================================
;  PrintNumber32
;   Prints a 32-bit unsigned integer supplied in DX:AX.
;   Algorithm: repeatedly divide by 10, push remainders
;              (digits), then pop & print in correct order.
;
;   Topics used:
;     Week 2  : MOV, DIV, ADD, XOR, int 21h
;     Week 6  : CMP + JNZ, LOOP
;     Week 9  : PROC / RET
;     Week 13 : PUSH / POP  (digit stack + register save)
; ============================================================
PrintNumber32 proc
    ; Week 13 : save all registers we will use
    push ax
    push bx
    push cx
    push dx
    push si

    ; Move 32-bit value into SI (low) and BX (high)
    ; so AX and DX are free for DIV
    mov  si, ax                   ; SI = low word
    mov  bx, dx                   ; BX = high word

    xor  cx, cx                   ; CX = digit counter

pn_loop:
    ; ---- Divide 32-bit number BX:SI by 10 ----

    ; Stage 1 – divide the high word
    mov  ax, bx
    xor  dx, dx                   ; zero DX before 16-bit DIV
    div  ten                      ; Week 2 : DIV — AX = quotient, DX = remainder
    mov  bx, ax                   ; BX = new high quotient

    ; Stage 2 – divide (remainder * 65536 + low word) by 10
    ;           DX already holds the remainder from Stage 1
    mov  ax, si                   ; AX = low word
    div  ten                      ; Week 2 : DIV — AX = quotient, DX = digit (0-9)
    mov  si, ax                   ; SI = new low quotient

    ; Week 13 : PUSH digit onto the stack (so we print MSB first later)
    push dx
    inc  cx                       ; count digits

    ; Continue while quotient BX:SI != 0
    mov  ax, bx
    or   ax, si                   ; Week 3 : logical OR to test both words
    jnz  pn_loop                  ; Week 6 : JNZ – jump if not zero

pn_print:
    ; Week 13 : POP digit from stack (LIFO ? correct print order)
    pop  dx
    add  dl, '0'                  ; Week 2 : ADD – convert digit ? ASCII
    mov  ah, 02h                  ; int 21h – print character
    int  21h
    loop pn_print                 ; Week 7 : LOOP

    ; Week 13 : restore all saved registers (reverse order)
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    ret
PrintNumber32 endp

end main