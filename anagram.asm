%ifndef SYS_EQUAL
%define SYS_EQUAL
    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
 
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000

    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif


;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
    push    rax
    push    rcx
    push    rsi
    push    rdx
    push    rdi

    mov     rdi, rsi
    call    GetStrlen
    mov     rax, sys_write  
    mov     rdi, stdout
    syscall 
    
    pop     rdi
    pop     rdx
    pop     rsi
    pop     rcx
    pop     rax
    ret
;-------------------------------------------
; rsi : zero terminated string start 
GetStrlen:
    push    rbx
    push    rcx
    push    rax  

    xor     rcx, rcx
    not     rcx
    xor     rax, rax
    cld
    repne   scasb
    not     rcx
    lea     rdx, [rcx -1]  ; length in rdx

    pop     rax
    pop     rcx
    pop     rbx
    ret
;

section .data
    true db 'True', 0
    false db 'False', 0
    newline db 10 ; define newline character as byte 10
section .bss
    s2 resq 101
    s1 resq 101
    len1 resb 8
    len2 resb 8

section .text
    global _start

_start:
    xor rcx, rcx
    xor r9, r9
    xor r8, r8
loop:
    xor rax, rax
    ; get input
    call getc
    cmp rax, NL
    je l
    
    sub rax, 97
    ;call writeNum
    ;call newLine
    mov r9, rax
    mov r8, [s1+rax*8]
    inc r8
    mov rax, r8
    ;call writeNum
    ;call newLine
    mov [s1+r9*8], r8
    
    
    inc rcx
    jmp loop
l:
mov [len1],rcx
xor rcx,rcx
xor r8, r8
xor r9, r9
loop2:
    xor rax, rax
    ; get input
    call getc
    cmp rax, NL
    je p
    
    sub rax, 97
    ;call writeNum
    ;call newLine
    mov r9, rax
    mov r8, [s2+rax*8]
    inc r8
    mov rax, r8
    ;call writeNum
    ;call newLine
    mov [s2+r9*8], r8
    
    inc rcx
    jmp loop2
p:
mov [len2], rcx
mov r10, [len1]
mov r11, [len2]
mov rax, r10
;call writeNum
mov rax, r11
;call newLine
;call writeNum
cmp r10, r11
jne printno
xor rcx, rcx
mov rbx, [len1]
comp:
    mov r8, [s1+rcx*8]
    cmp r8, [s2+rcx*8]
    jne printno
    inc rcx
    cmp rcx, rbx
    je printyes
    jmp comp
printyes:
    mov rsi, true
    call printString
    call newLine
    jmp Exit
printno:
    mov rsi, false
    call printString
    call newLine
Exit:
    ; Exit program
    mov rax, 1
    xor rbx, rbx
    int 0x80