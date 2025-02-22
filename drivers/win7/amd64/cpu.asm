TITLE   cpu.asm: Assembly code for the x64 resources

.CODE chipsec_code$__a

PUBLIC DisableInterrupts
PUBLIC WritePortDword
PUBLIC WritePortWord
PUBLIC WritePortByte
PUBLIC ReadPortDword
PUBLIC ReadPortWord
PUBLIC ReadPortByte
PUBLIC WriteHighCMOSByte
PUBLIC WriteLowCMOSByte
PUBLIC SendAPMSMI
PUBLIC WritePCIByte
PUBLIC WritePCIWord
PUBLIC WritePCIDword
PUBLIC ReadPCIByte
PUBLIC ReadPCIWord
PUBLIC ReadPCIDword
PUBLIC _rdmsr
PUBLIC _wrmsr
PUBLIC _load_gdt
PUBLIC _rflags
PUBLIC ReadCR0
PUBLIC ReadCR2
PUBLIC ReadCR3
PUBLIC ReadCR4
PUBLIC ReadCR8
PUBLIC WriteCR0
PUBLIC WriteCR2
PUBLIC WriteCR3
PUBLIC WriteCR4
PUBLIC WriteCR8
PUBLIC hypercall
PUBLIC hypercall_page


;------------------------------------------------------------------------------
; UINT64 _rflags()
;------------------------------------------------------------------------------
_rflags PROC
    pushfq
    pop rax
    ret
_rflags ENDP

;------------------------------------------------------------------------------
; void _store_idtr(
;   unsigned char *address // rcx
;   )
;------------------------------------------------------------------------------
_store_idtr PROC
    sidt fword ptr [rcx]
    ret
_store_idtr ENDP

;------------------------------------------------------------------------------
; void _load_idtr(
;   unsigned char *address // rcx
;   )
;------------------------------------------------------------------------------
_load_idtr PROC
    lidt fword ptr [rcx]
    ret
_load_idtr ENDP

;------------------------------------------------------------------------------
; void _store_gdtr(
;   unsigned char *address // rcx
;   )
;------------------------------------------------------------------------------
_store_gdtr PROC
    sgdt fword ptr [rcx]
    ret
_store_gdtr ENDP

;------------------------------------------------------------------------------
; void _load_gdtr(
;   unsigned char *address // rcx
;   )
;------------------------------------------------------------------------------
_load_gdtr PROC
    lgdt fword ptr [rcx]
    ret
_load_gdtr ENDP

;------------------------------------------------------------------------------
; void _store_ldtr(
;   unsigned char *address // rcx
;   )
;------------------------------------------------------------------------------
_store_ldtr PROC
    ;sldt fword ptr [rcx]
    ret
_store_ldtr ENDP

;------------------------------------------------------------------------------
; void _load_ldtr(
;   unsigned char *address // rcx
;   )
;------------------------------------------------------------------------------
_load_ldtr PROC
    ;lldt fword ptr [rcx]
    ret
_load_ldtr ENDP


;------------------------------------------------------------------------------
; void _load_gdt(
;   unsigned char *value // rcx
;   )
;------------------------------------------------------------------------------
_load_gdt PROC

    sgdt fword ptr [rcx]
    lgdt fword ptr [rcx]

    ret
_load_gdt ENDP

;------------------------------------------------------------------------------
;  void _rdmsr(
;    unsigned int msr_num, // rcx
;    unsigned int* msr_lo, // rdx
;    unsigned int* msr_hi  // r8
;    )
;------------------------------------------------------------------------------
_rdmsr PROC FRAME
    push r10
    .ALLOCSTACK 8
    push r11
    .ALLOCSTACK 8
    push rax
    .ALLOCSTACK 8
    push rdx
    .ALLOCSTACK 8
    .endprolog

    mov r10, rdx ; msr_lo
    mov r11, r8  ; msr_hi

    ; rcx has msr_num
    rdmsr

    ; Write MSR results in edx:eax
    mov dword ptr [r10], eax
    mov dword ptr [r11], edx

    pop rdx
    pop rax
    pop r11
    pop r10

    ret
_rdmsr ENDP

;------------------------------------------------------------------------------
;  void _wrmsr(
;    unsigned int msr_num, // rcx
;    unsigned int msr_hi,  // rdx
;    unsigned int msr_lo   // r8
;    )
;------------------------------------------------------------------------------
_wrmsr PROC FRAME
    push rax
    .ALLOCSTACK 8
    .endprolog

    ; rcx has msr_num
    ; rdx has msr_hi
    ; move msr_lo from r8 to rax
    mov rax, r8
    wrmsr

    pop rax
    ret
_wrmsr ENDP

;------------------------------------------------------------------------------
;  void
;  DisableInterrupts (
;    )
;------------------------------------------------------------------------------
DisableInterrupts PROC
    cli
    ret
DisableInterrupts ENDP

;------------------------------------------------------------------------------
;  void
;  WritePortDword (
;    unsigned int	out_value          // rcx
;    unsigned short	port_num           // rdx
;    )
;------------------------------------------------------------------------------
WritePortDword PROC FRAME
    push rax
    .ALLOCSTACK 8
    .endprolog

    mov rax, rcx
    out dx, rax

    pop rax
    ret
WritePortDword ENDP

;------------------------------------------------------------------------------
;  void
;  WritePortWord (
;    unsigned short	out_value          // rcx
;    unsigned short	port_num           // rdx
;    )
;------------------------------------------------------------------------------
WritePortWord PROC FRAME
    push rax
    .ALLOCSTACK 8
    .endprolog

    mov rax, rcx
    out dx, ax

    pop rax
    ret
WritePortWord ENDP

;------------------------------------------------------------------------------
;  void
;  WritePortByte (
;    unsigned char	out_value          // rcx
;    unsigned short	port_num           // rdx
;    )
;------------------------------------------------------------------------------
WritePortByte PROC FRAME
    push rax
    .ALLOCSTACK 8
    .endprolog

    mov rax, rcx
    out dx, al

    pop rax
    ret
WritePortByte ENDP

;------------------------------------------------------------------------------
;  unsigned int
;  ReadPortDword (
;    unsigned short	port_num           // rcx
;    )
;------------------------------------------------------------------------------
ReadPortDword PROC FRAME
    push rdx
    .ALLOCSTACK 8
    .endprolog

    xor rax, rax
    mov rdx, rcx
    in eax, dx

    pop rdx
    ret
ReadPortDword ENDP

;------------------------------------------------------------------------------
;  unsigned short
;  ReadPortWord (
;    unsigned short	port_num           // rcx
;    )
;------------------------------------------------------------------------------
ReadPortWord PROC FRAME
    push rdx
    .ALLOCSTACK 8
    .endprolog

    xor rax, rax
    mov rdx, rcx
    in ax, dx

    pop rdx
    ret
ReadPortWord ENDP

;------------------------------------------------------------------------------
;  unsigned char
;  ReadPortByte (
;    unsigned short	port_num           // rcx
;    )
;------------------------------------------------------------------------------
ReadPortByte PROC FRAME
    push rdx
    .ALLOCSTACK 8
    .endprolog

    xor rax, rax
    mov rdx, rcx
    in al, dx

    pop rdx
    ret
ReadPortByte ENDP


;------------------------------------------------------------------------------
;  void
;  WriteHighCMOSByte (
;    unsigned char	cmos_off        // rcx
;    unsigned char	val   		// rdx
;    )
;------------------------------------------------------------------------------
WriteHighCMOSByte PROC FRAME
    push rax
    .ALLOCSTACK 8
    .endprolog

    mov rax, rcx
    out 72h, al
    mov rax, rdx
    out 73h, al

    pop rax
    ret
WriteHighCMOSByte ENDP
;------------------------------------------------------------------------------
;  void
;  WriteLowCMOSByte (
;    unsigned char	cmos_off        // rcx
;    unsigned char	val   		// rdx
;    )
;------------------------------------------------------------------------------
WriteLowCMOSByte PROC FRAME
    push rax
    .ALLOCSTACK 8
    .endprolog

    mov rax, rcx
    or al, 80h
    out 70h, al
    mov rax, rdx
    out 71h, al

    pop rax
    ret
WriteLowCMOSByte ENDP


; @TODO: looks incorrect
;------------------------------------------------------------------------------
;  void
;  SendAPMSMI (
;    unsigned int	apm_port_value          // rcx
;    IN   UINT64	rax_value               // rdx
;    )
;------------------------------------------------------------------------------
SendAPMSMI PROC FRAME
    push rax
    .ALLOCSTACK 8
    push rdx
    .ALLOCSTACK 8
    .endprolog

    mov rax, rcx
    mov dx, 0B2h
    out dx, rax

    pop rdx
    pop rax
    ret
SendAPMSMI ENDP

;------------------------------------------------------------------------------
;This function has one argument: swsmi_msg_t structure which contain 7 regs: rcx, rdx, r8, r9, r10, r11, r12:
;    IN   UINT64	smi_code_data
;    IN   UINT64	rax_value
;    IN   UINT64	rbx_value
;    IN   UINT64	rcx_value
;    IN   UINT64	rdx_value
;    IN   UINT64	rsi_value
;    IN   UINT64	rdi_value
;------------------------------------------------------------------------------
;  void
; __swsmi__ (
;    swsmi_msg_t*
;    )
;------------------------------------------------------------------------------
_swsmi PROC FRAME
    push rbx
    .pushreg rbx
    push rsi
    .pushreg rsi
    push rdi
    .pushreg rdi
    .endprolog

    ; setting up GPR (arguments) to SMI handler call
    ; notes:
    ;   RAX will get partially overwritten (AX) by _smi_code_data (which is passed in RCX)
    ;   RDX will get partially overwritten (DX) by the value of APMC port (= 0x00B2)
    mov  r10, rcx        ; //pointer for struct into r10
    xchg rax, [r10+08h]  ; //rax_value overwritten by _smi_code_data
    mov  rax, [r10]      ; //smi_code_data
    xchg rbx, [r10+10h]  ; //rbx value
    xchg rcx, [r10+18h]  ; //rcx value
    xchg rdx, [r10+20h]  ; //rdx value
    xchg rsi, [r10+28h]  ; //rsi value
    xchg rdi, [r10+30h]  ; //rdi value

    ; these OUT instructions will write BYTE value (smi_code_data) to port 0xB3 then port 0xB3 (SW SMI control and data ports)
    ; the writes need to be broken up as some systems will drop the interrupt if the port size is larger than a BYTE
    ror ax, 8
    out 0B3h, al ; 0xB3
    ror ax, 8
    out 0B2h, al ; 0xB2

    ; some SM handlers return data/errorcode in GPRs, need to return this to the caller
    xchg [r10+08h], rax  ; //rax value
    xchg [r10+10h], rbx  ; //rbx value
    xchg [r10+18h], rcx  ; //rcx value
    xchg [r10+20h], rdx  ; //rdx value
    xchg [r10+28h], rsi  ; //rsi value
    xchg [r10+30h], rdi  ; //rdi value
    pop rdi
    pop rsi
    pop rbx
    ret
_swsmi ENDP

;------------------------------------------------------------------------------
;  void
;  WritePCIByte (
;    unsigned int	pci_reg          // rcx
;    unsigned short	cfg_data_port    // rdx
;    unsigned char	byte_value       // r8
;    )
;------------------------------------------------------------------------------
WritePCIByte PROC FRAME
    push rax
    .ALLOCSTACK 8
    push rdx
    .ALLOCSTACK 8
    .endprolog

    cli
    mov rax, rcx  ; pci_reg
    mov dx, 0CF8h
    out dx, rax

    mov rax, r8   ; byte_value
    pop rdx       ; cfg_data_port
    out dx, al
    sti

    pop rax
    ret
WritePCIByte ENDP

;------------------------------------------------------------------------------
;  void
;  WritePCIWord (
;    unsigned int	pci_reg          // rcx
;    unsigned short	cfg_data_port    // rdx
;    unsigned short	word_value       // r8
;    )
;------------------------------------------------------------------------------
WritePCIWord PROC FRAME
    push rax
    .ALLOCSTACK 8
    push rdx
    .ALLOCSTACK 8
    .endprolog

    cli
    mov rax, rcx  ; pci_reg
    mov dx, 0CF8h
    out dx, rax

    mov rax, r8   ; byte_value
    pop rdx       ; cfg_data_port
    out dx, ax
    sti

    pop rax
    ret
WritePCIWord ENDP

;------------------------------------------------------------------------------
;  void
;  WritePCIDword (
;    unsigned int	pci_reg          // rcx
;    unsigned short	cfg_data_port    // rdx
;    unsigned int	dword_value      // r8
;    )
;------------------------------------------------------------------------------
WritePCIDword PROC FRAME
    push rax
    .ALLOCSTACK 8
    push rdx
    .ALLOCSTACK 8
    .endprolog

    cli
    mov rax, rcx  ; pci_reg
    mov dx, 0CF8h
    out dx, rax

    mov rax, r8   ; byte_value
    pop rdx       ; cfg_data_port
    out dx, eax
    sti

    pop rax
    ret
WritePCIDword ENDP



;------------------------------------------------------------------------------
;  unsigned char
;  ReadPCIByte (
;    unsigned int	pci_reg          // rcx
;    unsigned short	cfg_data_port    // rdx
;    )
;------------------------------------------------------------------------------
ReadPCIByte PROC FRAME
    push rdx
    .ALLOCSTACK 8
    .endprolog

    cli
    mov rax, rcx  ; pci_reg
    mov dx, 0CF8h
    out dx, rax

    xor rax, rax
    pop rdx       ; cfg_data_port
    in  al, dx
    sti

    ret
ReadPCIByte ENDP

;------------------------------------------------------------------------------
;  unsigned short
;  ReadPCIWord (
;    unsigned int	pci_reg          // rcx
;    unsigned short	cfg_data_port    // rdx
;    )
;------------------------------------------------------------------------------
ReadPCIWord PROC FRAME
    push rdx
    .ALLOCSTACK 8
    .endprolog

    cli
    mov rax, rcx  ; pci_reg
    mov dx, 0CF8h
    out dx, rax

    xor rax, rax
    pop rdx       ; cfg_data_port
    in  ax, dx
    sti

    ret
ReadPCIWord ENDP

;------------------------------------------------------------------------------
;  unsigned int
;  ReadPCIDword (
;    unsigned int	pci_reg          // rcx
;    unsigned short	cfg_data_port    // rdx
;    )
;------------------------------------------------------------------------------
ReadPCIDword PROC FRAME
    push rdx
    .ALLOCSTACK 8
    .endprolog

    cli
    mov rax, rcx  ; pci_reg
    mov dx, 0CF8h
    out dx, rax

    xor rax, rax
    pop rdx       ; cfg_data_port
    in  eax, dx
    sti

    ret
ReadPCIDword ENDP

ReadCR0 PROC
    xor rax, rax
    mov rax, cr0
    ret
ReadCR0 ENDP

ReadCR2 PROC
    xor rax, rax
    mov rax, cr2
    ret
ReadCR2 ENDP

ReadCR3 PROC
    xor rax, rax
    mov rax, cr3
    ret
ReadCR3 ENDP

ReadCR4 PROC
    xor rax, rax
    mov rax, cr4
    ret
ReadCR4 ENDP

ReadCR8 PROC
    xor rax, rax
    mov rax, cr8
    ret
ReadCR8 ENDP

WriteCR0 PROC
    mov cr0, rcx
    ret
WriteCR0 ENDP

WriteCR2 PROC
    mov cr2, rcx
    ret
WriteCR2 ENDP

WriteCR3 PROC
    mov cr3, rcx
    ret
WriteCR3 ENDP

WriteCR4 PROC
    mov cr4, rcx
    ret
WriteCR4 ENDP

WriteCR8 PROC
    mov cr8, rcx
    ret
WriteCR8 ENDP

;------------------------------------------------------------------------------
;  CPU_REG_TYPE
;  hypercall(
;    CPU_REG_TYPE    rcx_val,                // rcx      +08h
;    CPU_REG_TYPE    rdx_val,                // rdx      +10h
;    CPU_REG_TYPE    r8_val,                 // r8       +18h
;    CPU_REG_TYPE    r9_val,                 // r9       +20h
;    CPU_REG_TYPE    r10_val,                // on stack +28h
;    CPU_REG_TYPE    r11_val,                // on stack +30h
;    CPU_REG_TYPE    rax_val,                // on stack +38h
;    CPU_REG_TYPE    rbx_val,                // on stack +40h
;    CPU_REG_TYPE    rdi_val,                // on stack +48h
;    CPU_REG_TYPE    rsi_val,                // on stack +50h
;    CPU_REG_TYPE    xmm_buffer,             // on stack +58h
;    CPU_REG_TYPE    hypercall_page          // on stack +60h
;    )
;------------------------------------------------------------------------------

hypercall PROC
    push   rsi
    push   rdi
    push   rbx
    mov    r11, qword ptr [rsp + 18h + 58h]
    test   r11, r11
    jz     hypercall_skip_xmm
    pinsrq xmm0, qword ptr [r11 + 000h], 00h
    pinsrq xmm0, qword ptr [r11 + 008h], 01h
    pinsrq xmm1, qword ptr [r11 + 010h], 00h
    pinsrq xmm1, qword ptr [r11 + 018h], 01h
    pinsrq xmm2, qword ptr [r11 + 020h], 00h
    pinsrq xmm2, qword ptr [r11 + 028h], 01h
    pinsrq xmm3, qword ptr [r11 + 030h], 00h
    pinsrq xmm3, qword ptr [r11 + 038h], 01h
    pinsrq xmm4, qword ptr [r11 + 040h], 00h
    pinsrq xmm4, qword ptr [r11 + 048h], 01h
    pinsrq xmm5, qword ptr [r11 + 050h], 00h
    pinsrq xmm5, qword ptr [r11 + 058h], 01h
  hypercall_skip_xmm:
    mov    r10, qword ptr [rsp + 18h + 28h]
    mov    r11, qword ptr [rsp + 18h + 30h]
    mov    rax, qword ptr [rsp + 18h + 38h]
    mov    rbx, qword ptr [rsp + 18h + 40h]
    mov    rdi, qword ptr [rsp + 18h + 48h]
    mov    rsi, qword ptr [rsp + 18h + 50h]
    call   qword ptr [rsp + 18h + 60h]
    pop    rbx
    pop    rdi
    pop    rsi
    ret
hypercall ENDP

;------------------------------------------------------------------------------
;  CPU_REG_TYPE hypercall_page ( )
;------------------------------------------------------------------------------

hypercall_page PROC
    vmcall
    ret
hypercall_page ENDP

END
