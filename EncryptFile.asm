TITLE Encrypt File Program               (EncryptFile.asm)
; Program EncryptFile(EncryptFile.asm)
; This program encrypts a file using simple symettric
; encryption using the XOR instruction.
; Last update : 11 / 16 / 16
; Wilkerson, Alexander

INCLUDE Irvine32.inc

FILE_NAME_BUFFER_MAX     = 128     ; file name max buffer size
KEY_BUFFER_MAX           = 10      ; max key buffer size
FILE_BUFFER_MAX          = 5000    ; file buffer size

.data
sKeyPrompt          BYTE      "Enter key of length 1 to 10: ",0
sFilePrompt         BYTE      "Enter file to be encrypted: ",0
sFileDoesNotExist   BYTE      "File does not exist.",0
sErrorCreate        BYTE      "Error creating output file.",0
sTaskCompleted      BYTE      "Task completed.",0

fileHandle          DWORD     ?

fileNameBuffer      BYTE      FILE_NAME_BUFFER_MAX+1 DUP(0)
fileNameBufferSize  DWORD     ?

fileName            BYTE      FILE_NAME_BUFFER_MAX+1 DUP(0)
fileNameSize        DWORD     ?

keyBuffer           BYTE      KEY_BUFFER_MAX+1 DUP(0)
keyBufferSize       DWORD     ?

fileBuffer          BYTE      FILE_BUFFER_MAX DUP(?)
bytesRead           DWORD     ?

error               BYTE      0

.code
main PROC

	call InputFileName		          ; input the file name
     mov edx,OFFSET fileNameBuffer
     call WriteString                   ; prompt user for file name
     call Crlf
     call InputKey                      ; get encoding key

     call ImportFile                    ; open file
     cmp error,1                        ; check for error
     je Ending

     call SplitPath                     ; find file name and create new one

     call TranslateBuffer               ; encrypt

     mov edx,OFFSET fileNameBuffer      ; create output
     call CreateOutputFile
     cmp eax,INVALID_HANDLE_VALUE
     jne Cont
     ; if error
     mov edx,OFFSET sErrorCreate   
     call WriteString                   ; display error 
     call Crlf
     call WriteWindowsMsg               ; error code
     call Crlf

Cont:
     mov fileHandle,eax                 ; write buffer to file
     mov edx,OFFSET fileBuffer
     mov ecx,bytesRead
     call WriteToFile
     cmp eax,0
     jne Cont2

     ; if error, write error code and end
     call WriteWindowsMsg
     call Crlf
     jmp Ending

Cont2:
     mov eax,fileHandle                 ; close the file
     call CloseFile
     mov edx,OFFSET sTaskCompleted
     call WriteString                   ; confirm success
     call Crlf

Ending :
     call WaitMsg

	exit
main ENDP

;-----------------------------------------------------
InputFileName PROC
;
; Asks the user to enter a file name from the
; keyboard. Saves the file name and its length
; in variables.
; Receives: nothing. Returns: nothing
;-----------------------------------------------------
	pushad
	mov  edx,OFFSET sFilePrompt	     ; display a prompt
	call WriteString
	mov  ecx,FILE_NAME_BUFFER_MAX      ; maximum character count
	mov  edx,OFFSET fileNameBuffer   	; point to the buffer
	call ReadString         		     ; input the string
	mov  fileNameBufferSize,eax        ; save the length
	call Crlf
	popad
	ret
InputFileName ENDP

; ---------------------------------------------------- -
InputKey PROC
;
; Asks the user to enter a key from the
; keyboard.Saves the key and its length
; in variables.
; Receives: nothing.Returns : nothing
; ---------------------------------------------------- -
     pushad
     mov  edx, OFFSET sKeyPrompt        ; display a prompt
     call WriteString
     mov  ecx, KEY_BUFFER_MAX           ; maximum character count
     mov  edx, OFFSET keyBuffer         ; point to the buffer
     call ReadString                    ; input the string
     mov  keyBufferSize, eax            ; save the length
     call Crlf
     popad
     ret
InputKey ENDP

; ---------------------------------------------------- -
ImportFile PROC
; opens the file, then reads the file to the file buffer
;
;
; Receives: nothing.Returns : nothing
; ---------------------------------------------------- -
     pushad
     mov edx,OFFSET fileNameBuffer
     call OpenInputFile                      ; open file
     cmp eax,INVALID_HANDLE_VALUE
     je FileDoesNotExist

     ; if file opens
     mov fileHandle,eax
     mov edx,OFFSET fileBuffer               ; set file buffer
     mov ecx,FILE_BUFFER_MAX
     call ReadFromFile                       ; read file
     jc FileError                            ; if carry flag set, jump to error
     mov bytesRead,eax                       ; else save number of bytes read
     jmp CloseFileLabel

FileError:
     mov error,1
     call WriteWindowsMsg     ; error reading file, exit function
     jmp ImportFileReturn

FileDoesNotExist:
     mov error,1              ; error, file does not exist
     call WriteWindowsMsg     ; display error code
     call Crlf
     mov edx,OFFSET sFileDoesNotExist
     call WriteString
     call Crlf
     jmp ImportFileReturn     ; exit

CloseFileLabel:
     mov eax,fileHandle
     call CloseFile           ; close file
ImportFileReturn:
     popad
     ret
ImportFile ENDP

; ---------------------------------------------------- -
TranslateBuffer PROC
;
; Translates the file by exclusive - ORing each byte
; with the key input.
; Receives: nothing.Returns : nothing
; ---------------------------------------------------- -
     pushad
     cmp bytesRead,0
     je ReturnTranslateBuffer
     mov  ecx,bytesRead          ; loop counter
     mov  esi,0                  ; index 0 in buffer
     mov  ebx,0                  ; index for key
L1 :
     cmp ebx,keyBufferSize
     jne Continue
     mov ebx,0
     
Continue:
     mov dl,keyBuffer[ebx]         ; move char to dl register
     xor  fileBuffer[esi], dl      ; xor file with key
     inc esi                                                  ; point to next byte
     inc ebx
     loop L1

ReturnTranslateBuffer:
     popad
     ret
TranslateBuffer ENDP

; ---------------------------------------------------- -
SplitPath PROC
;
; This procedure reads the input user file name from
; the end of the string until a \ is found then injects "En_"
; in front of the file.
; Receives: nothing.Returns : nothing
; ---------------------------------------------------- -
     pushad
     mov ecx,fileNameBufferSize

L2:
     cmp fileNameBuffer[ecx],05Ch       ; if '\' is found
     je BackslashFound
     loop L2

     jmp BackslashNotFound

BackslashFound:
     inc ecx                            ; increment the count
BackslashNotFound:
     mov edx,ecx                        ; use edx for counter
     mov ecx,fileNameBufferSize         ; if backslash not found, counter will be 0
     sub ecx,edx                        ; set ecx to difference of fileNameBufferSize and current ecx
     mov esi,0                          ; set new counter
L3:
     mov al,fileNameBuffer[edx]         ; loop through and get filename AFTER
     mov fileName[esi],al               ; backslash, then set it to
     inc edx                            ; fileName
     inc esi
     loop L3

     mov fileName[esi],0                ; insert null character at end
     mov fileNameSize,esi               ; of fileName

     mov ebx,fileNameSize               ; sif fileNameSize is the same size as
     cmp ebx,fileNameBufferSize         ; fileNameBufferSize no path dir
     jne FullPath
     mov edx,0                          ; set null char at end
     jmp ReturnSplitPath                ; return 

FullPath:
     mov ebx,fileNameBufferSize         ; set ebx to the difference of fileNameBufferSize
     sub ebx,fileNameSize               ; and fileNameSize

ReturnSplitPath:
     mov fileNameBuffer[ebx],'E'        ; insert En_ to the beginning of fileName
     inc ebx
     mov fileNameBuffer[ebx],'n'
     inc ebx
     mov fileNameBuffer[ebx],'_'
     inc ebx
     mov ecx,fileNameSize
     mov esi,0
L5:
     mov al,fileName[esi]               ; loop through fileName
     mov fileNameBuffer[ebx],al         ; and add to end of fileName path
     inc ebx
     inc esi
     loop L5
     mov fileNameBuffer[ebx],0
     popad
     ret
     
SplitPath ENDP

END main
