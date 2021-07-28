[bits 16]
[org 0x7c00]

boot:
    mov si, beep_msg
    call print

    call is_a20_disabled
    jne .a20_enabled

    mov si, a20_disabled_msg
    call print

    call enable_a20
    call is_a20_disabled
    jne .a20_enabled

    mov si, unable_to_enable_a20_msg
    call print
    jmp $
.a20_enabled:
    mov si, a20_enabled_msg
    call print

    ; A20 enabled, proceed towards protected mode.
    cli

    xor ax, ax
    mov ds, ax              ; Clear ds for lgdt.
    lgdt [gdt_descriptor]

    ; Set protected mode enabled control register bit.
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_start

; output string pointed to by si
print:
    mov ah, 0x0e            ; teletype output
    xor bh, bh              ; page 0
.print_next:
    lodsb                   ; next character
    cmp al, 0
    je .print_done
    int 10h
    jmp .print_next
.print_done:
    ret

; The check is done by storing a value in an address and
; checking if the address 1MiB higher was written to.
is_a20_disabled:
    xor ax, ax
    mov fs, ax
    not ax
    mov gs, ax

    mov di, 0x0600
    mov si, 0x0610

    mov byte [fs:di], 0x00
    mov byte [gs:si], 0xFF
    cmp byte [fs:di], 0xFF
    ret

; Attempts to enable the A20 line using the fast A20 gate method.
; This isn't the most portable method, but it is the most modern
; and convenient one, and it works on VirtualBox where I tested this.
enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

; Set up the global descriptor table, describing the memory segments.
; See https://wiki.osdev.org/GDT for info about the structure of a
; single descriptor.
gdt:
gdt_null:
    dd 0
    dd 0

gdt_code_segment:
    dw 0xFFFF    ; limit (0:15)
    dw 0         ; base  (0:15)
    db 0         ; base  (16:23)
    db 10011010b ; access byte
    db 11001100b ; limit (16:19), flags
    db 0         ; base (part 4)

gdt_data_segment:
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001100b
    db 0
gdt_end:

gdt_descriptor:
        dw gdt_end - gdt - 1
        dd gdt

[bits 32]
protected_start:
    ; Set up segment registers.
    mov ax, 10h             ; Data segment offset in the GDT.
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x80000

    call vga_clear

    mov si, protected_mode_msg
    mov ah, 0x1f
    mov edi, 0
    call vga_print

    mov si, protected_mode_msg
    mov ah, 0x2a
    mov edi, 2
    call vga_print

    mov si, protected_mode_msg
    mov ah, 0xdb
    mov edi, 4
    call vga_print

    jmp $

vga_clear:
    mov edi, 0xb8000
    mov ecx, 80*25
    rep stosw
    ret

; Output string pointed to by SI with the color AH on the row EDI.
; Only prints the string at col 0 right now, and doesn't handle newlines.
vga_print:
    imul edi, 80*2 ; 80 col rows, 2 bytes per character.
    add edi, 0xb8000
.vga_print_next:
    lodsb
    cmp al, 0
    je .vga_print_done
    stosw
    jmp .vga_print_next
.vga_print_done:
    ret

beep_msg db 'beep beep boop!', 0x0a, 0x0d, 0
a20_enabled_msg db 'a20 enabled!', 0x0a, 0x0d, 0
a20_disabled_msg db 'a20 disabled!', 0x0a, 0x0d, 0
unable_to_enable_a20_msg db 'unable to enable a20!', 0x0a, 0x0d, 0
protected_mode_msg db 'beep beep boop from protected mode!', 0

times 510-($-$$) db 0

dw 0xaa55
