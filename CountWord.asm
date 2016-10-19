TITLE Count Word Program
; Program CountWord(CountWord.asm)
; This program computes the number of words in a user given input.
; Last update : 10 / 19 / 16
; Wilkerson, Alexander

INCLUDE Irvine32.inc

.data
     PromptUser BYTE "Enter your string: ",0
     Result BYTE "Your string had ",0
     Single BYTE " word.",0
     NotSingle BYTE " words.",0
     RepeatPrompt BYTE "Repeat? (Y/N) ",0
     NothingEntered BYTE "Nothing entered.",0
     
     buffer BYTE 500 DUP(0)             ; input buffer
     byteCount DWORD ?                  ; holds counter for buffer

     char BYTE ?

     numWords DWORD ?                   ; holds the number of words counted

.code
main PROC
Beginning:
     call Clrscr

     mov edx,OFFSET PromptUser
     call WriteString

     mov edx, OFFSET buffer             ; points to the buffer
     mov ecx, SIZEOF buffer             ; max size chars
     call ReadString                    ; get user input string
     mov byteCount, eax                 ; number of chars
     cmp eax,0                          ; if nothing is entered
     je NoInputError                    ; jump to print error

; put input string on stack
     mov ecx,byteCount        ; size of input string for loop
     mov esi,0                ; string iterator
     mov ebx,0                ; use ebx as boolean on char
     mov edx,0                ; use edx to count words

L1:  movzx eax,buffer[esi]    ; get char
     inc esi                  ; increase string iterator
     cmp eax,32               ; if the char is a space char
     je L2
     cmp ebx,0                ; if ebx boolean is 0
     je L4
     jmp L3                   ; else loop

; if ebx boolean is not set
L4:  inc edx        ; increase the word count
     mov ebx,1      ; set ebx boolean
     jmp L3         ; loop

; change ebx boolean to 0
L2:  mov ebx,0

L3:  loop L1

     mov numWords,edx    ; store the number of words
     
; write the result of how many words there are
     mov edx,OFFSET Result
     call WriteString
     mov eax,numWords
     call WriteDec
     cmp eax,1                ; if count is 1
     je SingleWord            ; print word instead of words
     jne NotSingleWord        ; else print words
SingleWord:
     mov edx,OFFSET Single    ; word
     jmp WriteOut
NotSingleWord:
     mov edx,OFFSET NotSingle ; words
WriteOut:
     call WriteString
     call Crlf
RepeatLabel:
     mov edx,OFFSET RepeatPrompt   ; prompt user to repeat
     call WriteString
     call ReadChar       ; read single key user input
     cmp al,'Y'          ; if Y
     je Beginning        ; restart
     cmp al,'y'          ; if y
     je Beginning        ; restart

     exit                ; else, exit

NoInputError:
     mov edx,OFFSET NothingEntered
     call WriteString
     call Crlf
     jmp RepeatLabel

main ENDP
END main
