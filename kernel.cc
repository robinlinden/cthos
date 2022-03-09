namespace {
void vga_print(char const *str, int row);
} // namespace

extern "C" {

int _start() {
    vga_print("Hello from C++!", 1);
    while (1) {}
}

} // extern "C"

namespace {

class VideoRam {
public:
    static void put_char(char c, int row, int col, char color = 0x1f) {
        static volatile char *const video_memory_{(char *)0xb8000};
        *(video_memory_ + row * 80 * 2 + col * 2) = c;
        *(video_memory_ + row * 80 * 2 + col * 2 + 1) = color;
    }
};

void vga_print(char const *str, int row) {
    int col = 0;
    for (char c = *str++; c != '\0'; c = *str++) {
        VideoRam::put_char(c, row, col);
        ++col;
    }
}

} // namespace
