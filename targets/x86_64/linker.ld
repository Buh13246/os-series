ENTRY(start)

SECTIONS
{
    . = 1M;

    .boot :
    {
        KEEP(*(.multiboot2_header))
    }

    .text :
    {
        *(.text)
    }

    .bss :
    {
        *(.bss)
    }
}