#!/bin/sh

set -ex

mkdir -p build
nasm -o build/boot boot.asm
qemu-system-x86_64 build/boot
