#include <stdio.h>
#include <stdbool.h>

void print_binary(int number, int bits)
{
    for (int i = bits - 1; i >= 0; i--)
    {
        int8_t shifted = number >> i;
        putchar(shifted & 1 ? '1' : '0');
    }
}

bool is_even(int number) { return (number & 1) != 1; }
int  align_to_4(int x)   { return x & ~3; }

int main()
{
    int8_t number = 10;

    print_binary(number, 8);
    char *message = is_even(number) ? "even" : "odd";
    printf(" is %s!\n", message);

    printf(
        "%d rounded down to the closest multiple of 4 is %d.\n",
        number, align_to_4(number)
    );

    return 0;
}