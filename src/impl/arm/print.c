#include "print.h"

void print_clear()
{
}
void print_char(char character)
{
	uart_putc(character);
}
void print_str(char *string)
{
	uart_puts(string);
}
void print_set_color(uint8_t foreground, uint8_t background)
{
}
