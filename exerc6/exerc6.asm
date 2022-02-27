
section .text
        global _start
        
_start:
     push    1
     push    2
     push    3
     call    _function

     mov     ebx, eax
     mov     eax, 1
     int     0x80
     
_function:
    push    ebp
    mov     ebp, esp
    sub     esp, 16
    
    mov     eax, dword[ebp+8]
    add     eax, 1
    mov     dword[ebp-4], eax
    
    mov     eax, dword[ebp+12]
    add     eax, 5
    mov     dword[ebp-8], eax

    mov     eax, dword[ebp+16]
    add     eax, 2
    mov     dword[ebp-12], eax

    mov     eax, dword[ebp-8]
    mov     edx, dword[ebp-4]
    lea     eax, [edx+eax]
    add     eax, dword[ebp-12]
    mov     dword[ebp-16], eax

    mov     eax, dword[ebp-4]
    imul    eax, dword[ebp-8]
    imul    eax, dword[ebp-12]
    add     eax, dword[ebp-16]
    
    leave
    ret

