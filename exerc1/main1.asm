;On linux, you could run this code with the following command:
;$ nasm -felf64 main1.asm && ld main1.o && ./a.out
;
section .data
path_image_color db "lena_color.bmp", 0
path_outimg_gray db  "lena_gray.bmp", 0
len equ 786486

section .bss
fd_out resb 1
fd_in resb 1
color_img resb len
gray_img resb len

section	.text
   global _start
	
_start:   

;Abrindo a imagem colorida
    mov     rax, 5                   ; chamada de sistema (sys_open)
    mov     rbx, path_image_color    ; nome do arquivo
    mov     rcx, 0                   ; apenas para leitura
    mov     rdx, 664o                ; leitura e escrita para usuario e grupo, somente leitura para os demais (sufixo 'o' para base octal)
    int     0x80
    mov     [fd_in], rax             ; salva o descrito do arquivo que retornou

;Lendo a imagem  e salvando em color_img 
    mov     rax, 3                   ; chamada de sistema (sys_read)
    mov     rbx, [fd_in]             ; descritor do arquivo
    mov     rcx, color_img           ; buffer que recebe os dados lidos
    mov     rdx, len                 ; numero de bytes
    int     0x80

;Fecha o arquivo
    mov     rax, 6                   ; chamada de sistema (sys_close)
    mov     rbx, [fd_in]             ; descritor do arquivo
    int     0x80

;Copiar o cabeçalho para a imagem cinza
    mov     rax, color_img 
    mov     rcx, gray_img
    mov     r9, 0

header_loop:
    mov     r8, [rax]
    mov     [rcx], r8
    inc     rax
    inc     rcx
    inc     r9
    cmp     r9, 47
    jne     header_loop

; Converte imagem colorida para cinza
    mov     rax, color_img + 54
    mov     rcx, gray_img + 54

turngray_loop:
    mov     r10b, [rax]     ; r10b recebe azul (B)
    shr     r10b, 2         ; r10b recebe B/4

    mov     r11b, [rax+1]   ; r11b recebe verde (G)
    shr     r11b, 1         ; r11b recebe G/2

    mov     r12b, [rax+2]   ; r12b recebe vermelho (R)
    shr     r12b, 2         ; r12b recebe R/4

    add     r10b, r11b      ; |
    add     r10b, r12b      ; | B/4 + G/2 + R/4

    mov     [rcx], r10b
    mov     [rcx+1], r10b
    mov     [rcx+2], r10b

    add     rax, 3
    add     rcx, 3

    cmp     rax, gray_img
    jne     turngray_loop

   ; cria o arquivo para armazenar a imagem cinza
    mov     rax, 8            
    mov     rbx, path_outimg_gray    
    mov     rcx, 664o
    int     0x80     
    mov     [fd_out], rax
    
   ; escreve a imagem cinza no arquivo
    mov     rax, 4            ; chamada de sistema (sys_write)
    mov     rbx, [fd_out]     ; descritor do arquivo
    mov     rcx, gray_img     ; conteudo a ser escrito
    mov     rdx, len          ; numero de bytes
    int     0x80

   ; fecha o arquivo da imagem cinza
    mov     rax, 6            ; chamada de sistema (sys_close)
    mov     rbx, [fd_out]     ; descritor do arquivo
    int     0x80

    ; encerra o programa
    mov     rax, 0            ; chamada de sistema (sys_exit)
    int     0x80