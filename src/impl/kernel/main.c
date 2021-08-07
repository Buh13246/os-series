#include "print.h"
#include "kernel.h"
#include "osinfo.h"

void main()
{
	print_clear();
	print_str("first test\ndoes this also work????\nand maybe this???\n");
	print_str("Here some ASCII ART\n");
	print_str("------------------------\n");
	print_str("|   MateOS ");
	print_str(ARCH);
	print_str(" BUILD   |\n");
	print_str("|                      |\n");
	print_str("|   Writen By:         |\n");
	print_str("|   - Philipp Wellner  |\n");
	print_str("|   - casept           |\n");
	print_str("------------------------\n");
	print_str("Hallooo......\n");
	print_str("!\n");
}