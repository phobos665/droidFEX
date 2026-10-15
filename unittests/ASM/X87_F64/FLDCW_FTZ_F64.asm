%ifdef CONFIG
{
  "Env": { "FEX_X87REDUCEDPRECISION" : "1" },
  "RegData": {
    "RAX": "0x0",
    "RBX": "0x0",
    "RCX": "0x0"
  }
}
%endif

; In reduced precision mode x87 control word updates used to write FCW bit 12 (or zero)
; into FPCR.FZ, silently clearing the SSE flush-to-zero mode set through MXCSR.
; Each result below is 1e-30f * 1e-10f, a denormal that must flush to zero.

; Enable MXCSR.FTZ
stmxcsr [rel .mxcsr]
or dword [rel .mxcsr], (1 << 15)
ldmxcsr [rel .mxcsr]

; fldcw must leave FTZ alone
fldcw [rel .fcw]
movss xmm0, [rel .small_a]
mulss xmm0, [rel .small_b]
movd eax, xmm0

; fninit must leave FTZ alone
fninit
movss xmm1, [rel .small_a]
mulss xmm1, [rel .small_b]
movd ebx, xmm1

; frstor must leave FTZ alone
fnsave [rel .x87state]
frstor [rel .x87state]
movss xmm2, [rel .small_a]
mulss xmm2, [rel .small_b]
movd ecx, xmm2

hlt

align 16
.x87state:
times 108 db 0
.mxcsr:
dd 0
.fcw:
dw 0x037F
align 4
.small_a:
dd 0x0DA24260 ; 1e-30
.small_b:
dd 0x2EDBE6FF ; 1e-10
