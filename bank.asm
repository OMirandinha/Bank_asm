.model small
.stack 100h

.data
    prompt_menu db "Welcome to the Bank! Please choose an option:", 13, 10
    prompt_balance db "1. Check Balance", 13, 10
    prompt_deposit db "2. Deposit Money", 13, 10
    prompt_withdraw db "3. Withdraw Money", 13, 10
    prompt_exit db "4. Exit", 13, 10
    prompt_option db "Choose an option (1-4): $", 0
    prompt_amount db "Enter amount: $", 0

    balance dw 1000      ; Initial balance is 1000 units
    message_balance db "Your balance is: $", 13, 10, "$"
    message_deposit db "Deposited $", 13, 10, "$"
    message_withdraw db "Withdrew $", 13, 10, "$"
    message_insufficient db "Insufficient balance.", 13, 10, "$"
    message_exit db "Exiting the program. Goodbye!", 13, 10, "$"
    newline db 13, 10, "$"

.code
start:
    ; Initialize the data segment
    mov ax, @data
    mov ds, ax
    
    ; Display main menu and prompt user for choice
main_menu:
    call display_menu

    ; Get user input for option
    call get_option

    ; Process user input
    cmp al, '1'          ; Check if option 1 (Check Balance)
    je check_balance
    cmp al, '2'          ; Check if option 2 (Deposit Money)
    je deposit_money
    cmp al, '3'          ; Check if option 3 (Withdraw Money)
    je withdraw_money
    cmp al, '4'          ; Check if option 4 (Exit)
    je exit_program

    ; If input is invalid, loop back to main menu
    jmp main_menu

check_balance:
    ; Display the balance message
    call display_balance
    ; Return to the menu after displaying balance
    jmp main_menu

deposit_money:
    ; Prompt user for amount to deposit
    call prompt_amount_input
    ; Add the deposit to balance
    call deposit
    ; Return to the menu after depositing money
    jmp main_menu

withdraw_money:
    ; Prompt user for amount to withdraw
    call prompt_amount_input
    ; Attempt to withdraw the money
    call withdraw
    ; Return to the menu after withdrawing money
    jmp main_menu

exit_program:
    ; Display exit message and exit
    call display_exit_message
    ; Terminate the program
    mov ah, 4ch
    int 21h

;-------------------------------------------------------
; Display main menu
;-------------------------------------------------------
display_menu proc
    ; Display prompt for menu options
    mov ah, 09h
    lea dx, prompt_menu
    int 21h
    lea dx, prompt_balance
    int 21h
    lea dx, prompt_deposit
    int 21h
    lea dx, prompt_withdraw
    int 21h
    lea dx, prompt_exit
    int 21h
    lea dx, prompt_option
    int 21h
    ret
display_menu endp

;-------------------------------------------------------
; Get the user input for menu option
;-------------------------------------------------------
get_option proc
    ; Wait for user input (option 1-4)
    mov ah, 01h
    int 21h             ; Get character from input
    ret
get_option endp

;-------------------------------------------------------
; Display the current balance
;-------------------------------------------------------
display_balance proc
    ; Display "Your balance is: $"
    mov ah, 09h
    lea dx, message_balance
    int 21h
    
    ; Display current balance
    mov ax, balance
    call print_number
    
    ret
display_balance endp

;-------------------------------------------------------
; Deposit the specified amount to balance
;-------------------------------------------------------
deposit proc
    ; Add the deposit to balance
    mov ax, balance
    add ax, [amount_input]  ; Deposit amount
    mov balance, ax
    ; Display "Deposited $<amount>"
    mov ah, 09h
    lea dx, message_deposit
    int 21h
    mov ax, [amount_input]
    call print_number
    ret
deposit endp

;-------------------------------------------------------
; Withdraw the specified amount from balance
;-------------------------------------------------------
withdraw proc
    ; Compare if the balance is enough
    mov ax, balance
    cmp ax, [amount_input]
    jl insufficient_funds   ; If not enough, go to insufficient funds

    ; Withdraw the amount
    sub ax, [amount_input]
    mov balance, ax
    ; Display "Withdrew $<amount>"
    mov ah, 09h
    lea dx, message_withdraw
    int 21h
    mov ax, [amount_input]
    call print_number
    ret

insufficient_funds:
    ; Display insufficient balance message
    mov ah, 09h
    lea dx, message_insufficient
    int 21h
    ret
withdraw endp

;-------------------------------------------------------
; Prompt for the amount to deposit/withdraw
;-------------------------------------------------------
prompt_amount_input proc
    ; Display the "Enter amount: $" prompt
    mov ah, 09h
    lea dx, prompt_amount
    int 21h

    ; Get the amount input (numeric input)
    call get_numeric_input
    ret
prompt_amount_input endp

;-------------------------------------------------------
; Get numeric input (for amount deposit or withdraw)
;-------------------------------------------------------
get_numeric_input proc
    ; Get user input (only one byte, assuming it's a valid number)
    mov ah, 01h
    int 21h             ; Get character from input
    sub al, '0'         ; Convert ASCII to integer
    mov [amount_input], al
    ret
get_numeric_input endp

;-------------------------------------------------------
; Print a number (used for displaying balance/amount)
;-------------------------------------------------------
print_number proc
    ; Convert number to ASCII and print
    add ax, '0'         ; Convert number to ASCII
    mov dl, al
    mov ah, 02h
    int 21h
    ret
print_number endp

;-------------------------------------------------------
; Display the exit message
;-------------------------------------------------------
display_exit_message proc
    ; Display exit message
    mov ah, 09h
    lea dx, message_exit
    int 21h
    ret
display_exit_message endp

.data
amount_input db 0    ; Used for storing amount input