#include "print.h"

struct Char
{
    uint8_t charcode;
    uint8_t colorcode;
};

struct Char *buffer = (struct Char *)0xb8000;

int current_index = 0;

uint8_t current_color = PRINT_COLOR_WHITE | PRINT_COLOR_BLACK << 4;

int NUM_ROWS = 25;
int NUM_COLOMS = 80;

static const struct Char empty_char = (struct Char){
    charcode : ' ',
    colorcode : PRINT_COLOR_BLACK
};

void print_newline()
{
    current_index -= current_index % NUM_COLOMS;
    current_index += NUM_COLOMS;
    if (current_index >= NUM_COLOMS * NUM_ROWS)
    {
        current_index = 0;
    }
}

void print_clear_row(uint8_t index)
{
    for (int i = 0; i < NUM_COLOMS; i++)
    {
        buffer[index + i] = empty_char;
    }
}

void print_clear()
{

    for (int i = 0; i < NUM_COLOMS * NUM_ROWS; i++)
    {
        buffer[i] = empty_char;
    }
}

void print_char(char c)
{
    if (c == '\n')
    {
        print_newline();
        return;
    }

    struct Char character;
    character.colorcode = current_color;
    character.charcode = c;
    buffer[current_index] = character;
    current_index++;
    if (current_index == NUM_COLOMS * NUM_ROWS)
    {
        current_index = 0;
    }
}
void print_str(char *string)
{
    while (*string != 0)
    {
        print_char(*string);
        string++;
    }
}

void print_set_color(uint8_t foreground, uint8_t background)
{
    current_color = foreground | background << 4;
}