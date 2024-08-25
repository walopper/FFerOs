[org 0x7c00] 			; Tell the assembler where this code will be loaded


;;;;;;;;;;; Hello usando rutina

mov ah, 0x0e 			; int 10/ ah = 0eh -> scrolling teletype BIOS routine
mov al, 'F'			; Move the character to the al (where is expected to be found to print it)
int 0x10			; Execute interruption 0x10 (needed to execute the function)
mov al, 'e'
int 0x10
mov al, 'r'
int 0x10 
mov al, 'O'
int 0x10
mov al, 'S'
int 0x10
mov al, 0x0a 			; newline char
int 0x10
mov al, 0x0d 			; carriage return
int 0x10

;;;;;; Crea el hello world pero con una función

mov bx, HELLO_MSG 		; Use BX as a parameter to our function, so
call print_string 		; we can specify the address of a string.
call print_string_nl		; print line

;mov bx, GOODBYE_MSG
;call print_string
;call print_string_nl

mov dx, 0x12fe			; Imprime en hexadecimal como ejemplo
call print_hex
call print_string_nl

;;;;;;;;;; Read from Disk

; dl <- drive number. Our caller sets it as a parameter and gets it from BIOS
; (0 = floppy, 1 = floppy2, 0x80 = hdd, 0x81 = hdd2)

mov [BOOT_DRIVE], dl 		; BIOS stores our boot drive in DL , so it ’s

mov bx, BOOT_DRIVE_MSG		; imprime el boot drive original
call print_string
mov bx, BOOT_DRIVE		; Imprime el boot drive
call print_hex
call print_string_nl

mov bp, 0x8000 			; Here we set our stack safely out of the
mov sp, bp 			; way , at 0 x8000

mov bx, 0x9000 			; Load 5 sectors to 0x0000 (ES):0x9000 (BX)
mov dh, 5 			; from the boot disk.
mov dl, 0			; tenía esto pero se lo saque porque tiene dentro un 0x12FE [BOOT_DRIVE], el 0 representa floppy 1
call disk_load

mov dx, [0x9000] 		; Print out the first loaded word , which
call print_hex 			; we expect to be 0xdada , stored
				; at address 0x9000

mov dx, [0x9000 + 512] 		; Also , print the first word from the
call print_hex 			; 2nd loaded sector : should be 0xface
call print_string_nl

mov bx, GOODBYE_MSG
call print_string
call print_string_nl

call switch_to_pm 		; Note that we never return from here.

;;;;;;;;;; Infinite Jump

jmp $ 				; Jump to the current address forever.
				; to a new memory address to continue execution.
				; In our case , jump to the address of the current
				; instruction.

;;;;;;;;;;;;; Functions
%include "print.asm"
%include "print_hex.asm"	; Lo saco porque no tengo espacio para poner el magic number
%include "disk_load.asm"
%include "gdt.asm"
%include "print_string_pm.asm"
%include "switch_to_pm.asm"

;;;;;;;;;;;;; Data 16 bits

HELLO_MSG:
db 'Iniciando... ' , 0          ; <-- The zero on the end tells our routin
                                ; when to stop printing characters.
GOODBYE_MSG:
db 'Saliendo del Modo Real', 0

BOOT_DRIVE_MSG:
db 'Boot Drive: ', 0

;;;;;;;;;;;; Global variables
BOOT_DRIVE:
db 0

[bits 32]
; This is where we arrive after switching to and initialising protected mode.
BEGIN_PM:
mov ebx, MSG_PROT_MODE
call print_string_pm		; Use our 32 - bit print routine.
jmp $ 				; Hang.

;;;;;;;;;;;;; Data 32 bits

MSG_PROT_MODE db "Ready 32 - bit", 0

;;;;;;;;;;; PADDING

times 510-($-$$) db 0 		; When compiled , our program must fit into 512 bytes ,
				; with the last two bytes being the magic number ,
				; so here , tell our assembly compiler to pad out our
				; program with enough zero bytes (db 0) to bring us to the
				; 510 th byte.

dw 0xaa55 			; Last two bytes ( one word ) form the magic number ,
				; so BIOS knows we are a boot sector.


; We know that BIOS will load only the first 512 - byte sector from the disk ,
; so if we purposely add a few more sectors to our code by repeating some
; familiar numbers , we can prove to ourselfs that we actually loaded those
; additional two sectors from the disk we booted from.
times 256 dw 0xdada
times 256 dw 0xface
