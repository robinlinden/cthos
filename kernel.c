static void vga_print(char const *str, int row);

int _start() {
    vga_print("Hello from C!", 1);
    while (1) {}
}

static void vga_print(char const *str, int row) {
    volatile char *video = (volatile char *)0xb8000 + row * 80 * 2;
    for (char c = *str++; c != '\0'; c = *str++) {
        *video++ = c;
        *video++ = 0x1f;
    }
}
