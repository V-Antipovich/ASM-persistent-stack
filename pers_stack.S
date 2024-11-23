.intel_syntax noprefix
.global main
.text
main:
    // globals:
    // current version
    mov rbx, 0
    // ptr to array of arrays
    lea r12, [rip + arrarr]
    // ptr to array of lengths
    lea r13, [rip + arrlengths]
go:
    // input operation type
    xor rdi, rdi
    call readi32
    jc end
    // saved for now, gonna need later
    xor r8, r8
    mov r8d, eax
    push r8

    // input version we gonna touch
    call readi32
    pop r8
    xor rdi, rdi
    mov edi, eax
    
    cmp r8, 0
    je call_stack_push
    call stack_pop
    jmp go
end:
    call finish

call_stack_push:
    inc rbx
    call stack_push
    jmp go

stack_push:
    push rbp
    mov rbp, rsp
    // rdi = ver
    push rdi
    // in rax there is x we will need to push
    call readi32
    pop rdi
    push rax
    // arrlength[ver] = rip + arrlength + ver*4
    shl rdi, 2
    mov r8, r13
    // ptr to arrlength[ver]
    xor r9, r9
    add r8, rdi
    // arrlength[ver] = len
    mov r9d, dword ptr [r8]
    push r9
    shr rdi, 2
    // we also need to increment length of new array
    mov r8, r13
    // and simultaneously we will put x on place it needs to have
    mov r9, r12
    shl rbx, 2
    // we shift by 4 * rbx in lengths array
    add r8, rbx
    mov rax, 1000
    mul rbx
    // ... and by 4000 * rbx in arrarr
    add r9, rax
    shr rbx, 2
    // poped old length
    pop r11
    // new is one el bigger
    inc r11d
    mov dword ptr [r8], r11d
    dec r11d
    // and now we put arr[new_ver][old_len] = x
    shl r11, 2
    add r9, r11
    shr r11, 2
    pop rax
    mov dword ptr [r9], eax
    push r11
    // now we need to copy all elements from arrarr[ver] to arrarr[rbx]
    /* for that, we have func copy_i_j:
        rdi: ptr to arrarr[ver]
        rsi: ptr to arrarr[rbx]
        rdx: len of arrarr[ver]
    */
    mov rax, 4000
    // *= 1000
    mul rdi
    xor r10, r10
    mov r10, r12
    // arrarr[ver] = rip + arrarr + ver * 4000
    add r10, rax
    
    mov rax, 4000
    mul rbx
    xor r11, r11
    mov r11, r12
    // arrarr[new_ver] = rip + arrarr + rbx * 4000
    add r11, rax

    // build args for callning copy_i_j
    mov rdi, r10
    mov rsi, r11
    pop rdx

    push rdi
    push rsi
    push rdx
    call copy_i_j 
    pop rdx
    pop rsi
    pop rdi
        
    mov rsp, rbp
    pop rbp
    ret

stack_pop:
    push rbp
    mov rbp, rsp
    push rdi
    shl rdi, 2
    // get length...
    mov r8, r13
    xor r9, r9
    add r8, rdi
    shr rdi, 2
    // arrlength[ver] = len
    mov r9d, dword ptr [r8]
    cmp r9d, 0
    je empty_pop
    inc rbx
    // ... so we can get last element
    dec r9
    shl r9, 2
    mov r8, r12
    mov rax, 4000
    mul rdi
    add r8, rax
    add r8, r9
    // here last element
    movsx rdi, dword ptr [r8]
    shr r9, 2
    // push r8
    push r9
    call writei32
    pop rdx
    // also we need to set new length
    mov r8, r13
    shl rbx, 2
    add r8, rbx
    shr rbx, 2
    mov dword ptr [r8], edx
    mov rdi, r12
    pop r8 // ver
    push rdx
    mov rax, 4000
    mul r8
    add rdi, rax

    mov rsi, r12
    mov rax, 4000
    mul rbx
    add rsi, rax
    pop rdx
    // mov rdx, rcx
    // by this moment somewhere I lost rdx
    // mul kills it. Can we save rcx instead?
    call copy_i_j

    mov rsp, rbp
    pop rbp
    ret

empty_pop:
    mov edi, -1
    call writei32
    pop rdi

    mov rsp, rbp
    pop rbp
    ret

copy_i_j:
    push rbp
    mov rbp, rsp
    xor rcx, rcx

copy_i_j_loop:
    cmp rcx, rdx
    jge copy_i_j_end
    xor rax, rax
    mov eax, dword ptr [rdi + rcx * 4]
    mov dword ptr [rsi + rcx * 4], eax
    inc rcx
    jmp copy_i_j_loop

copy_i_j_end:
    mov rsp, rbp
    pop rbp
    ret

.data
arrarr: .fill 4000000
arrlengths: .fill 4000
