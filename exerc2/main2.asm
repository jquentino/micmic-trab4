;On linux, you could run this code with the following command:
;$ nasm -felf64 main2.asm && ld main2.o && ./a.out
;

section .data
path_image_color db "lena_color.bmp", 0
path_outimg_bright db  "lena_brightness.bmp", 0
len equ 786486
const equ 55
; const db 5

section .bss
fd_out resb 1
fd_in resb 1
color_img resb len
bright_img resb len

section	.text
   global _start         ;must be declared for using gcc
	
_start:                    ; informa o linker sobre o procedimento de entrada

;Abrindo a imagem colorida
    mov     rax, 5                   ; chamada de sistema (sys_open)
    mov     rbx, path_image_color    ; nome do arquivo
    mov     rcx, 0                   ; apenas para leitura
    mov     rdx, 664o                ; leitura e escrita para usuario e grupo, somente leitura para os demais (sufixo 'o' para base octal)
    int     0x80
    mov     [fd_in], rax             ; salva o descrito do arquivo que retornou

;Lendo a imagem  e salvando em color_img 
    mov     rax, 3                  ; chamada de sistema (sys_read)
    mov     rbx, [fd_in]            ; descritor do arquivo
    mov     rcx, color_img          ; buffer que recebe os dados lidos
    mov     rdx, len                ; numero de bytes
    int     0x80

;Fecha o arquivo
    mov     rax, 6                  ; chamada de sistema (sys_close)
    mov     rbx, [fd_in]            ; descritor do arquivo
    int     0x80

;Copiar o cabeçalho para a imagem de saida
    mov     rax, color_img 
    mov     rcx, bright_img
    mov     r9, 0

header_loop:
    mov     r8, [rax]
    mov     [rcx], r8
    inc     rax
    inc     rcx
    inc     r9
    cmp     r9, 47
    jne     header_loop

; Converte imagem colorida para preto e branco
    mov     rax, color_img + 54
    mov     rcx, bright_img + 54

brightness_loop:
    mov     r10b, [rax]   ; r10b recebe azul (B) + brilho
    add     r10b, const
    
    mov     r11b, [rax+1]   ; r11b recebe verde (G) + brilho
    add     r11b, const

    mov     r12b, [rax+2]   ; r12b recebe vermelho (R) + brilho
    add     r12b, const

    mov     [rcx], r10b
    mov     [rcx+1], r11b
    mov     [rcx+2], r12b

    add     rax, 3
    add     rcx, 3

    cmp     rax, bright_img
    jne     brightness_loop

   ; cria o arquivo para armazenar a imagem cinza
    mov     rax, 8            
    mov     rbx, path_outimg_bright    
    mov     rcx, 664o
    int     0x80     
    mov     [fd_out], rax
    
   ; escreve a imagem cinza no arquivo
    mov     rax, 4            ; chamada de sistema (sys_write)
    mov     rbx, [fd_out]     ; descritor do arquivo
    mov     rcx, bright_img     ; conteudo a ser escrito
    mov     rdx, len          ; numero de bytes
    int     0x80

   ; fecha o arquivo da imagem cinza
    mov     rax, 6            ; chamada de sistema (sys_close)
    mov     rbx, [fd_out]     ; descritor do arquivo
    int     0x80

    ; encerra o programa
    mov     rax, 0            ; chamada de sistema (sys_exit)
    int     0x80
