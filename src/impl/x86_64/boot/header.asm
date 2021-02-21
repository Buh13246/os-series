section .multiboot2_header
multiboot_header_start:
    ; magic number for multiboot2
    dd 0xe85250d6
    ; architecture mode (0= 32 BIT Protected)
    dd 0x0
    ; header length
    dd (multiboot_header_end - multiboot_header_start)
    ; checksum
    dd 0x100000000 - ( 0xe85250d6 + 0x0 + (multiboot_header_end - multiboot_header_start))

    ; tag section https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Header-tags

    ; end tag
    dw 0
    dw 0
    dd 8
multiboot_header_end: