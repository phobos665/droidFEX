%ifdef CONFIG
{
  "RegData": {
    "RAX": "0x1122334455667788",
    "RBX": "0x1122334455667788",
    "RCX": "0x1",
    "RDX": "0x1",
    "RSI": "0x1122334455667788",
    "RDI": "0x1122334455667788"
  },
  "Env": {
    "FEX_TSOENABLED": "1",
    "FEX_HALFBARRIERTSOENABLED": "0",
    "FEX_TSOAUTOMIGATRION": "0"
  }
}
%endif

; Without half-barrier TSO the JIT doesn't reserve a barrier slot before TSO stores, so the SIGBUS handler must
; rerun only the backpatched store. Rerunning from the previous instruction would apply the lea a second time.
mov r15, 0xe000_0000
mov rax, 0x1122334455667788
mov rcx, 0
mov rdx, 0

; Unaligned store across a 16-byte granule
lea rcx, [rcx + 1]
mov qword [r15 + 15], rax

; Unaligned store across a 64-byte granule
lea rdx, [rdx + 1]
mov qword [r15 + 127], rax

mov rbx, qword [r15 + 15]
mov rsi, qword [r15 + 127]
mov rdi, qword [r15 + 15]
hlt
