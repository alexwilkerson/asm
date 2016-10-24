TITLE Fibonacci Program
; Program Fibonacci(Fibonacci.asm)
; This program calculates the Fibonacci number of a user given index
; Last update : 10 / 20 / 16
; Wilkerson, Alexander

INCLUDE Irvine32.inc

.data
     UserInfo BYTE "This program recursively computes the Fibonacci number of a given index.",0Dh,0Ah,0
     PromptUser BYTE "Enter an index number to get the Fibonacci number: ",0
     Result BYTE "The result is: ",0

     InputSign BYTE 0

.code
main PROC
     call Clrscr

; print what the program does
     mov edx,OFFSET UserInfo
     call WriteString
     call Crlf

; prompt user for index number
     mov edx,OFFSET PromptUser
     call WriteString
     
; read user input
     call ReadInt
     cmp eax,0
     jl negative         ; if user input is negative, jump to negative
     jmp cont

negative:
; if user inputs negative index number, convert number to positive and
; save the sign in InputSign
     not eax
     inc eax
     inc InputSign

cont:
     push eax            ; push user input onto stack
     mov edx,0           ; use edx register as accumulator for recursive function
     call Fibonacci      ; call recursive function
     mov eax,edx         ; move accumulator into eax register

     mov edx, OFFSET Result   ; print result
     call WriteString

     cmp InputSign,0     ; if input was positive
     je notNeg           ; jump to notNeg
     neg eax             ; otherwise, make result negative
     call WriteInt       ; write using WriteInt, which accounts for signed numbers
     jmp finish          ; jump to end

notNeg:
     call WriteDec       ; use WriteDec for unsigned numbers, because it's prettier

finish:
     call Crlf

     call WaitMsg        ; to see result
     
     exit
main ENDP

Fibonacci PROC
     push ebp                 ; set up stack using call convention
     mov ebp,esp
     mov eax,[ebp+8]
     
; if given number 0, return
     cmp eax,0
     je ReturnFib
; if given number one
     cmp eax,1
     jne OverOne    ; not 1, jump to over one
     inc edx        ; increment edx register (accumulator)
     jmp ReturnFib  ; return

OverOne:
     dec eax        ; call Fibonacci n - 1
     push eax
     call Fibonacci
     dec eax        ; call Fibonacci n - 2
     push eax
     call Fibonacci
     inc eax        ; restore eax to n
     inc eax
     
ReturnFib:
     pop ebp        ; restore ebp
     ret 4          ; cleanup stack frame

Fibonacci ENDP

END main
