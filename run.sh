#!/bin/sh

set -ex

mkdir -p build
nasm -o build/boot.bin boot.asm
qemu-system-x86_64 -drive file=build/boot.bin,index=0,media=disk,format=raw
