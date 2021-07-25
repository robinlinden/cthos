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
    jmp $

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

beep_msg db 'beep beep boop!', 0x0a, 0x0d, 0
a20_enabled_msg db 'a20 enabled!', 0x0a, 0x0d, 0
a20_disabled_msg db 'a20 disabled!', 0x0a, 0x0d, 0
unable_to_enable_a20_msg db 'unable to enable a20!', 0x0a, 0x0d, 0

times 510-($-$$) db 0

dw 0xaa55
