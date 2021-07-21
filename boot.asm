[bits 16]
[org 0x7c00]

boot:
    mov si, beep_msg
    call print
    jmp $

; output string pointed to by si
print:
    mov ah, 0x0e            ; teletype output
    xor bh, bh              ; page 0
.next:
    lodsb                   ; next character
    cmp al, 0
    je .done
    int 10h
    jmp .next
.done:
    ret

beep_msg db 'beep beep boop!', 0

times 510-($-$$) db 0

dw 0xaa55
