global long_mode_start
bits 64
section .text

long_mode_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; print `OK`
	mov dword [0xb8000], 0x2f4b2f4f
	hlt