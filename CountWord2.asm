TITLE Count Word Program
; Program CountWord(CountWord.asm)
; This program computes the number of words in a user given input.
; Last update : 10 / 18 / 16
; Wilkerson, Alexander

INCLUDE Irvine32.inc

.data
     UserInfo BYTE "This program iterates over a given string and counts the number of words inside of it.",0Dh,0Ah,0
     PromptUser BYTE "Enter a string of words to be counted: ",0
     Result BYTE "Number of words in string: ",0
     
     buffer BYTE 500 DUP(0)             ; input buffer
     byteCount DWORD ?                  ; holds counter for buffer

.code
main PROC
     call Clrscr

     mov edx,OFFSET UserInfo
     call WriteString
     call Crlf

     mov edx,OFFSET PromptUser
     call WriteString

     mov edx, OFFSET buffer             ; points to the buffer
     mov ecx, SIZEOF buffer             ; max size chars
     call ReadString                    ; get user input string
     mov byteCount, eax                 ; number of chars
     call WriteString                   ; prints user input
     call Crlf

; put input string on stack
     mov ecx,byteCount
     mov esi,0
     mov ebx,0                ; use ebx as boolean on char
     mov edx,0                ; use edx to count words

L1:  movzx eax,buffer[esi]              ; get char
     inc esi
     cmp eax,32                         ; if the char is a space char
     je L2
     cmp ebx,0
     je L4
     jmp L3

L4:  inc edx
     mov ebx,1
     jmp L3

L2:  mov ebx,0

L3:  loop L1
     
     mov eax,edx
     call WriteDec
     call Crlf
     call WaitMsg

     exit
main ENDP
END main
