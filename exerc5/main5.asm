;On linux, you could run this code with the following command:
;$ nasm -felf64 main5.asm && ld main5.o && ./a.out
;
section .data
path_image_color db "lena_color.bmp", 0
path_outimg_blur db  "lena_blur.bmp", 0
len equ 786486

section .bss
fd_out resb 1
fd_in resb 1
color_image resb len
blur_image resb len

section	.text
   global _start
	
_start:   

;Abrindo a imagem cinza
    mov     rax, 5                   ; chamada de sistema (sys_open)
    mov     rbx, path_image_color     ; nome do arquivo
    mov     rcx, 0                   ; apenas para leitura
    mov     rdx, 664o                ; leitura e escrita para usuario e grupo, somente leitura para os demais (sufixo 'o' para base octal)
    int     0x80
    mov     [fd_in], rax             ; salva o descrito do arquivo que retornou

;Lendo a imagem  e salvando em color_image 
    mov     rax, 3                   ; chamada de sistema (sys_read)
    mov     rbx, [fd_in]             ; descritor do arquivo
    mov     rcx, color_image          ; buffer que recebe os dados lidos
    mov     rdx, len                 ; numero de bytes
    int     0x80

;Fecha o arquivo
    mov     rax, 6                   ; chamada de sistema (sys_close)
    mov     rbx, [fd_in]             ; descritor do arquivo
    int     0x80

;Copiar o cabeçalho para a imagem cinza
    mov     rax, color_image 
    mov     rcx, blur_image
    mov     r9, 0

header_loop:
    mov     r8, [rax]
    mov     [rcx], r8
    inc     rax
    inc     rcx
    inc     r9
    cmp     r9, 47
    jne     header_loop

;  Borra a imagem

    mov     rax, color_image + 54 + 3 ;Pula o cabeçalho e o primeiro pixel 
    mov     rcx, blur_image + 54  + 3

turnblur_loop:
    mov     r10b, [rax]     ; r10b recebe o canal de cor do pixel do meio
    shl     r10b, 1         ; canal do pixel do meio tem o valor dobrado

    mov     r11b, [rax-3]   ; r11b recebe o canal do pixel de trás
    
    mov     r12b, [rax+3]   ; r12b recebe o canal do pixel da frente
    
    add     r10b, r11b      ; | Média ponderada das cores
    add     r10b, r12b      ; | 
    shr     r10b, 2         ; |

    mov     [rcx], r10b       ;| Armazena o resultado no canal de cor 

    add     rax, 1
    add     rcx, 1

    cmp     rax, blur_image
    jne     turnblur_loop

   ; cria o arquivo para armazenar a imagem borrada
    mov     rax, 8            
    mov     rbx, path_outimg_blur    
    mov     rcx, 664o
    int     0x80     
    mov     [fd_out], rax
    
   ; escreve a imagem borrada no arquivo
    mov     rax, 4            ; chamada de sistema (sys_write)
    mov     rbx, [fd_out]     ; descritor do arquivo
    mov     rcx, blur_image   ; conteudo a ser escrito
    mov     rdx, len          ; numero de bytes
    int     0x80

   ; fecha o arquivo da imagem borrada
    mov     rax, 6            ; chamada de sistema (sys_close)
    mov     rbx, [fd_out]     ; descritor do arquivo
    int     0x80

    ; encerra o programa
    mov     rax, 0            ; chamada de sistema (sys_exit)
    int     0x80