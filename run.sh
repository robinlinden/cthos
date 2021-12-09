#!/bin/sh

set -ex

mkdir -p build
nasm -o build/boot.bin boot.asm
gcc -fno-pie -m32 -ffreestanding -c kernel.c -o build/kernel.o
ld -melf_i386 -Ttext 0x7e00 --oformat binary -o build/kernel.bin build/kernel.o
cat build/boot.bin build/kernel.bin >build/os.bin
qemu-system-x86_64 -drive file=build/os.bin,index=0,media=disk,format=raw
