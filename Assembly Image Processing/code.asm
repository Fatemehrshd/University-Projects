; %include 'in_out.asm'
section .data
    output_filename                             db                      "output.txt", 0
    FD                                          dq                      0
    FD_output                                   dq                      0
    output_chars                                dq                      0
    
    bufferlen                                   equ                     1000000

    pixels                                      dq                      0
    new_pixels                                  dq                      0
    new_height                                  dq                      0
    new_width                                   dq                      0
    new_dim_value                               dq                      0 
    pooling_size                                dq                      0
    array                   times   bufferlen   dq                      -1
    tmp_array               times   bufferlen   dq                      -1
    resized_array           times   bufferlen   dq                      -1
    convolved_array         times   bufferlen   dq                      0
    pooled_array            times   bufferlen   dq                      0
    grayscale_array         times   bufferlen   dq                      0
    
   
    sharpening_filter   dq              0, -1, 0, -1, 5, -1, 0, -1, 0
    ;edge_filter        dq              -1, 0, 1, -1, 0, 1, -1, 0, 1
    emboss_filter       dq              -2, -1, 0, -1, 1, 1, 0, 1, 2
    filter              dq              0, 0, 0, 0, 0, 0, 0, 0, 0

    
    error_create        db      "error in creating file             ", NL, 0
    error_close         db      "error in closing file              ", NL, 0
    error_write         db      "error in writing file              ", NL, 0
    error_open          db      "error in opening file              ", NL, 0
    error_open_dir      db      "error in opening dir               ", NL, 0
    error_append        db      "error in appending file            ", NL, 0
    error_delete        db      "error in deleting file             ", NL, 0
    error_read          db      "error in reading file              ", NL, 0
    error_print         db      "error in printing file             ", NL, 0
    error_seek          db      "error in seeking file              ", NL, 0
    error_create_dir    db      "error in creating directory        ", NL, 0
    
    suces_create        db      "file created and opened for R/W    ", NL, 0
    suces_create_dir    db      "dir created and opened for R/W     ", NL, 0
    suces_close         db      "file closed                        ", NL, 0
    suces_write         db      "written to file                    ", NL, 0
    suces_open          db      "file opend for R/W                 ", NL, 0
    suces_open_dir      db      "dir opened for R/W                 ", NL, 0
    suces_append        db      "file opened for appending          ", NL, 0
    suces_delete        db      "file deleted                       ", NL, 0
    suces_read          db      "reading file                       ", NL, 0
    suces_seek          db      "seeking file                       ", NL, 0
    suces_conv          db      "Convolved                          ", NL, 0
    suces_noise         db      "Noise added                        ", NL, 0

    menu                db "Choose the option:                      ", NL, 0
    opt1                db "1. Opening                              ", NL, 0
    opt2                db "2. Reshaping                            ", NL, 0
    opt3                db "3. Resizing                             ", NL, 0
    opt4                db "4. Convolution Filters                  ", NL, 0
    opt5                db "5. Pooling                              ", NL, 0
    opt6                db "6. Noise                                ", NL, 0
    opt7                db "7. Show the image                       ", NL, 0
    opt8                db "8. Gray Scale                           ", NL, 0
    opt9                db "9. Save to file                         ", NL, 0
    opt0                db "0. Exit                                 ", NL, 0

    GetFileName_str                     db "Enter text file name:                                       ", 0
    PrintFileContent                    db "Do you want to see the file content?(1 agree, 0 disagree):  ", 0
    new_dim                             db "Enter the new dimention you want:                           ", 0
    new_height_str                      db "Enter new height:                                           ", 0
    new_width_str                       db "Enter new width:                                            ", 0
    pool_size_str                       db "Enter pool size:                                            ", 0
    get_filter_num                      db "1. Sharpening    2. Emboss                                  ", NL, 0
    channel_str                         db "--Channel--                                                 ", NL, 0
    invalid_filter_num                  db "Invalid filter num. Try again.                              ", NL, 0
    show_convolved_str                  db "1. Show convolved matrix 0. Skip                            ", NL, 0
    invalid_dim                         db "Entered dimention value is invalid.                         ", NL, 0

section .bss
    width                               resq                                                            1
    height                              resq                                                            1
    dim                                 resq                                                            1
    buffer                              resb                                                            bufferlen 
    tmp_array_str                       resb                                                            bufferlen
    fileName                            resb                                                            100
    tmp                                 resq                                                            10

    row_ratio   resq 1       ; Row ratio
    col_ratio   resq 1       ; Column ratio
    orig_x      resq 1       ; X coordinate in original image
    orig_y      resq 1       ; Y coordinate in original image
    new_x       resq 1      ; X coordinate in new image
    new_y       resq 1      ; Y coordinate in new image
    

section .text
    global _start

GetFileName:
    mov rbx, 0
    GetFileName_loop:
        xor rax, rax
        call getc
        cmp al, 10
        je GetFileName_end
        mov byte [fileName + rbx], al
        inc rbx
        jmp GetFileName_loop
    GetFileName_end:
        ret


String2Num:
   ; convert string buffer to num
   push rsi
   push rdi
   push rax
   push rdx
   push rbx
   push rcx
   push r15
   push r14
   mov rsi, buffer
   mov rdi, array
   xor rax, rax
   xor rcx, rcx
   mov r14, 0

Convert2Num_loop:
   movzx rdx, byte [rsi]
   cmp rdx, 32
   je SaveValue
   cmp rdx, 10
   je SaveValue
   cmp rdx, 0
   je String2Num_ret

   sub rdx, 48
   imul rax, rax, 10
   
   add rax, rdx
   
   GoNext:
      inc rsi
      jmp Convert2Num_loop
   SaveValue:
      mov [rdi], rax
      add rdi, 8
      xor rax, rax
      jmp GoNext


String2Num_ret:
   mov [rdi], rax
   pop r14
   pop r15
   pop rcx
   pop rbx
   pop rdx
   pop rax
   pop rdi
   pop rsi
   ret

PrintMenu:
   mov rsi, menu
   call printString
   mov rsi, opt1
   call printString
   mov rsi, opt2
   call printString
   mov rsi, opt3
   call printString
   mov rsi, opt4
   call printString
   mov rsi, opt5
   call printString
   mov rsi, opt6
   call printString
   mov rsi, opt7
   call printString
   mov rsi, opt8
   call printString
   mov rsi, opt9
   call printString
   mov rsi, opt0
   call printString
ret

GetOption:
   call readNum
ret

CopyArray:
    ; rsi: src address, rdi: dest address
    push r8
    push rax
    push rbx
    push rcx
    mov r8, 0
    mov rax, [new_height]
    mov rbx, [new_width]
    mov rdx, 0
    mul rbx
    mov rbx, [new_dim_value]
    mov rdx, 0
    mul rbx
    mov rcx, rax
    ;mov [pixels], rcx
    mov [new_pixels], rcx
    copy_loop:
        cmp r8, [new_pixels]
        je CopyArray_end
        ;xor rbx, rbx
        mov rbx, [rsi + (r8 + 3) * 8]
        mov [rdi + r8 * 8], rbx
        inc r8
        jmp copy_loop
    CopyArray_end:
        cmp r8, [pixels]
        je CopyArray_ret
        mov qword [rdi + r8 * 8], -1
        inc r8
        jmp CopyArray_end
    CopyArray_ret:
        pop rcx
        pop rbx
        pop rax
        pop r8
        ret

; ------------------------------- start -------------------------------

_start:
    ; Get filename from user
    mov rsi, GetFileName_str
    call printString
    call GetFileName

_start_menu:
    ; Print menu
    call PrintMenu

    Menu:
    call readNum

    cmp rax, 1
    je Opening
    cmp rax, 2
    je Reshaping
    cmp rax, 3
    je Resizing
    cmp rax, 4
    je Convolution
    cmp rax, 5
    je Pooling
    cmp rax, 6
    je Noise
    cmp rax, 7
    je ShowingResult
    cmp rax, 8
    je GrayScale
    cmp rax, 9
    je SaveToFile
    cmp rax, 0
    je Exit
; --------------------------------------------------------------------
; -------------------------- Option 1: Open --------------------------
; --------------------------------------------------------------------
Opening:
    ; open file
    mov rdi, fileName
    call openFile
    mov [FD], rax

    ; read file
    mov rdi, [FD]
    mov rsi, buffer
    mov rdx, bufferlen
    call readFile

    ; print file content
    push rsi
    mov rsi, PrintFileContent
    call printString
    pop rsi
    call readNum
    cmp rax, 0
    je Opening_close
    mov rdi, rsi
    call printString

    ; close file
    Opening_close:
        mov rdi, [FD]
        call closeFile
        call String2Num

        push rbx
        push rdi
        mov rdi, array
       
        mov rbx, [rdi]
        mov [height], rbx
        mov [new_height], rbx
        add rdi, 8

        mov rbx, [rdi]
        mov [width], rbx
        mov [new_width], rbx
        add rdi, 8
        
        mov rbx, [rdi]
        mov [dim], rbx
        mov [new_dim_value], rbx
        add rdi, 8
        
        ; count all pixels
        mov rax, [height]
        mov rbx, [width]
        mul rbx
        mov rbx, [dim]
        mul rbx
        mov [pixels], rax
        mov [new_pixels], rax

        push rsi
        push rcx

        mov rsi, array
        mov rdi, tmp_array
        call CopyArray
        
        pop rcx
        pop rsi
        pop rdi
        pop rbx
        jmp _start_menu

; --------------------------------------------------------------------
; ------------------------- Option 2: Reshape ------------------------
; --------------------------------------------------------------------
Reshaping:
    mov rdi, fileName
    call openFile
    mov rcx, 0

    mov rsi, new_dim
    call printString

    ; get new dimention
    push rax
    call readNum
    mov [new_dim_value], rax
    cmp rax, 3
    jle GetChannels

    ; if entered dim > 3
    mov rsi, invalid_dim
    call printString
    pop rax
    jmp _start_menu

   GetChannels:
   push rax
   push rbx
   mov rax, [height]
   mov rbx, [width]
   mul rbx
   mov rbx, [new_dim_value]
   mul rbx
   mov r14, rax ; r14 -> h * w * new_dim
   mov [new_pixels], r14

    GetChannels_loop:
        cmp r14, [pixels]
        je GetChannels_ret
        mov qword [tmp_array + r14 * 8], 0
        inc r14
        jmp GetChannels_loop
   
GetChannels_ret:
   mov rdi, [FD]
   call closeFile
   
   pop rbx
   pop rax
   jmp _start_menu




; --------------------------------------------------------------------
; ------------------------- Option 3: Resize -------------------------
; --------------------------------------------------------------------
Resizing:
    push rsi
    push rax
    push rbx
    push rdx
    push rcx
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    ; get new height
    mov rsi, new_height_str
    call printString
    call readNum
    mov [new_height], rax

    ; get new width
    mov rsi, new_width_str
    call printString
    call readNum
    mov [new_width], rax

    mov rbx, [new_height]
    mov rdx, 0
    mul rbx ; h * w
    mov rbx, [new_dim_value]
    mov rdx, 0
    mul rbx ; h * w * d
    mov [new_pixels], rax
    
    mov r8, 0 ; ind
    makeZero_loop:
        cmp r8, [new_pixels]
        je init_continue
        mov qword [resized_array + r8 * 8], 0
        inc r8
        jmp makeZero_loop

    init_continue: 
        ; row ratio
        mov rax, [height]
        mov rbx, [new_height]
        mov rdx, 0
        div rbx
        mov r15, rax ; r15 -> row_ratio
        
        ; col ratio
        mov rax, [width]
        mov rbx, [new_width]
        mov rdx, 0
        div rbx
        mov r14, rax ; r14 -> col_ratio

        mov r13, 0 ; i = 0
        resize_outerLoop:
            cmp r13, [new_height]
            je resize_outerLoop_end
            mov r12, 0 ; j = 0
            resize_innerLoop:
                cmp r12, [new_width]
                je resize_innerLoop_end
                mov rax, r13
                mov rdx, 0
                mul r15
                mov r11, rax ; r11 -> original_i
                mov rax, r12
                mov rdx, 0
                mul r14
                mov r10, rax ; r10 -> original_j


                mov r9, [height] ; r9 -> height
                dec r9
                cmp r11, r9 ; r11 -> original_i
                jg changeMinHeight

            changeMin_continue:
                mov r8, [width] ; r8 -> width
                dec r8
                cmp r10, r8
                jg changeMinWidth
                jle changeMin_continue2

                changeMinHeight:
                    mov r11, r9
                    jmp changeMin_continue

                changeMinWidth:
                    mov r10, r8
                changeMin_continue2:        

                mov rax, r11
                mov rbx, [width]
                mov rdx, 0
                mul rbx
                add rax, r10 ; rax -> [original_i, original_j]
                mov r9, [array + (rax + 3)*8] ; r9 -> array[original_i, original_j]
                
                mov rax, r13
                mov rbx, [new_width]
                mov rdx, 0
                mul rbx
                add rax, r12 ; rax -> [i, j]
                mov [resized_array + rax * 8], r9 ; resized[i, j] -> array[original_i, original_j]

                ; go next iteration
                inc r12
                jmp resize_innerLoop

            resize_innerLoop_end:
                mov r12, 0
                inc r13
                jmp resize_outerLoop
        resize_outerLoop_end:
            
            call CopyResized
            pop r8
            pop r9
            pop r10
            pop r11
            pop r12
            pop r13
            pop r14
            pop r15
            pop rcx
            pop rdx
            pop rbx
            pop rax
            pop rsi
            jmp _start_menu

CopyResized: ; not checked
    mov r8, 0
    CopyResized_loop:
        cmp r8, [new_pixels]
        je CopyResized_zero
        mov rbx, [resized_array + r8 * 8]
        mov [tmp_array + r8 * 8], rbx
        inc r8
        jmp CopyResized_loop
    CopyResized_zero:
        cmp r8, [pixels]
        je CopyResized_end
        mov qword [tmp_array + r8 * 8], 0
        inc r8
        jmp CopyResized_zero
    CopyResized_end:
        ret

; --------------------------------------------------------------------
; ---------------------- Option 4: Convolution -----------------------
; --------------------------------------------------------------------
Convolution:
    ; matrix -> tmp_array, filter -> filter
    push rsi
    push rdi
    push rax
    push rbx
    push rdx
    push rcx
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8

    ; get filter num from user
    mov rsi, get_filter_num
    call printString
    call readNum
    ;call PrintSharp

    cmp rax, 1
    je Sharpening_copy
    cmp rax, 2
    je Emboss_copy
    mov rsi, invalid_filter_num
    call printString
    jmp Convolution

    Sharpening_copy:
        mov rcx, 0
        Sharpening_loop:
            cmp rcx, 9
            je Convolution_start
            
            mov rbx, [sharpening_filter + rcx * 8]
            mov [filter + rcx * 8], rbx
            ;mov rax, rbx
            ;call writeNum
            ;call newLine
            ;call newLine
            inc rcx
            jmp Sharpening_loop
    
    Emboss_copy:
        mov rcx, 0
        Emboss_loop:
            cmp rcx, 9
            je Convolution_start
            mov rbx, [emboss_filter + rcx * 8]
            mov [filter + rcx * 8], rbx
            inc rcx
            jmp Emboss_loop

    Convolution_start:
    ; matrix_rows -> new_height, matrix_cols -> new_width
    ; filter_rows -> 3,      filter_cols -> 3
    ; output_rows == matrix_rows - filter_rows + 1 -> r8
    ; output_cols == matrix_cols - filter_cols + 1 -> r9
    mov r8, [new_height]
    sub r8, 3
    add r8, 1 ; r8 == output_rows

    mov r9, [new_width]
    sub r9, 3
    add r9, 1 ; r9 -> output_cols

    ; updated number of pixels
    mov rax, r8
    mul r9
    mov [new_pixels], rax

    ; i -> r10, j -> r11, k -> r12, l -> r13
    mov r10, 0 ; i
    loop1:
        cmp r10, r8 ; i < range(output_rows)
        je loop1_end
        mov r11, 0 ; j
        loop2:
            cmp r11, r9 ; j < range(output_cols)
            je loop2_end
            mov r15, 0 ; r15 -> sum
            mov r12, 0 ; k
            loop3:
                cmp r12, 3 ; k < range(filter_rows)
                je loop3_end
                mov r13, 0 ; l
                loop4:
                    cmp r13, 3 ; l < range(filter_cols)
                    je loop4_end
                    ; sum += matrix[i + k][j + l] * filter [k][l]

                    ; [i + k][j + l]
                    mov r14, r10 ; i
                    add r14, r12 ; i + k
                    mov rax, [new_width]
                    mul r14
                    add rax, r11 ; j
                    add rax, r13 ; j + l
                    mov rbx, rax
                
                    ; matrix[i + k][j + l]
                    mov rcx, [tmp_array + rbx * 8] ; rcx -> matrix[i + k][j + l]

                    ; filter [k][l]
                    xor rax, rax
                    mov rax, r12 ; k
                    imul rax, rax, 3
                    add rax, r13 ; l
                    mov rbx, rax
                    ;xor rax, rax
                    mov rax, [filter + rbx * 8] ; rax -> filter [k][l]

                    mul rcx

                    add r15, rax ; r15 -> sum += matrix[i + k][j + l] * filter [k][l]
                    inc r13
                    jmp loop4
                    
                loop4_end:
                inc r12
                jmp loop3

            loop3_end:
                ; output [i][j] = sum
                mov rax, r10 ; r14!!
                mul r9
                add rax, r11 ; [i][j]
                mov rbx, rax
                mov [convolved_array + rbx * 8], r15 ; output [i][j] = sum
                inc r11
                jmp loop2

        loop2_end:
            inc r10
            jmp loop1
    loop1_end:
        mov rsi, convolved_array
        mov rdi, tmp_array
        call CopyArrayConvolved
        mov rsi, suces_conv
        call printString

        mov [new_height], r8
        mov [new_width], r9
        mov rax, r8
        mul r9
        mov [new_pixels], rax

        pop r8
        pop r9
        pop r10
        pop r11
        pop r12
        pop r13
        pop r14
        pop r15
        pop rcx
        pop rdx
        pop rbx
        pop rax
        pop rsi

        jmp _start_menu

CopyArrayConvolved:
    ; rsi -> convolved_array, rdi -> tmp_array
    push r8
    mov r8, 0
    CopyArrayConvolved_loop:
        cmp r8, bufferlen
        je CopyArrayConvolved_end
        mov rax, [convolved_array + r8 * 8]
        mov [tmp_array + r8 * 8], rax
        inc r8
        jmp CopyArrayConvolved_loop

    CopyArrayConvolved_end:
        pop r8
ret
; --------------------------------------------------------------------
; -------------------------- Option 5: Pool --------------------------
; --------------------------------------------------------------------
Pooling:
    ; matrix: tmp_array, pooling_size
    mov rsi, pool_size_str
    call printString

    call readNum
    mov [pooling_size], rax

    ; rows -> new_height
    ; cols -> new_width

    ; output_rows -> rows // pooling_size -> r8
    mov rax, [new_height]
    mov rbx, [pooling_size]
    mov rdx, 0
    div rbx
    mov r8, rax ; r8 -> output_rows

    ; output_cols -> cols // pooling_size -> r9
    mov rax, [new_width]
    mov rbx, [pooling_size]
    mov rdx, 0
    div rbx
    mov r9, rax ; r9 -> output_cols

    ; i -> r10
    mov r10, 0
    loop1_pool:
        cmp r10, r8 ; i < output_rows
        je loop1_pool_end
        ; j -> r11
        mov r11, 0
        loop2_pool:
            cmp r11, r9 ; j < output_cols
            je loop2_pool_end
            ; row_start = i * pooling_size -> r12
            mov rax, r10
            mov rbx, [pooling_size]
            mul rbx
            mov r12, rax

            ; col_start = j * pooling_size -> r13
            mov rax, r11
            mov rbx, [pooling_size]
            mul rbx
            mov r13, rax

            ; max_value = matrix[row_start][col_start] -> rcx
            mov rax, r12
            mov rbx, [new_width]
            mul rbx
            add rax, r13
            mov rbx, rax
            mov rcx, [tmp_array + rbx * 8] ; rcx -> matrix[row_start][col_start]

            ; r -> r14
            mov r14, 0
            loop3_pool:
                cmp r14, [pooling_size]
                je loop3_pool_end
                ; c -> r15 
                mov r15, 0
                loop4_pool:
                    cmp r15, [pooling_size]
                    je loop4_pool_end
                    call findMax ; rcx -> max_value
                    inc r15
                    jmp loop4_pool
                    ; max_value = max(max_value, matrix[row_start + r][col_start + c])

                loop4_pool_end:
                    inc r14
                    jmp loop3_pool

            loop3_pool_end:
                mov rax, r10
                mul r8 ; i * w
                add rax, r11 ; i * w + j
                mov rbx, rax
                mov [pooled_array + rbx * 8], rcx
                inc r11
                jmp loop2_pool

        loop2_pool_end:
            inc r10
            jmp loop1_pool
    loop1_pool_end:
        mov [new_height], r8
        mov [new_width], r9
        mov rax, r8
        mul r9
        mov [new_pixels], rax
        call PoolCopy
        jmp _start_menu

PoolCopy:
    push r8
    mov r8, 0
    PoolCopy_loop:
        cmp r8, bufferlen
        je PoolCopy_end
        mov rbx, [pooled_array + r8 * 8]
        mov [tmp_array + r8 * 8], rbx
        inc r8
        jmp PoolCopy_loop
    PoolCopy_end:
        pop r8
    ret


findMax:
    ; max_value -> rcx
    ; row_start -> r12
    ; col_start -> r13
    ; r -> r14
    ; c -> r15
    push r8
    push r9
    push r10
    push r11
    push rax
    push rbx
    push rdx
    ; max(rcx, tmp_array[row_start + r][col_start + c])
    mov rax, r12
    add rax, r14 ; row_start + r
    mov rbx, [new_width]
    mul rbx
    add rax, r13
    add rax, r15 ; rax -> [row_start + r][col_start + c]
    mov rbx, rax
    mov rax, [tmp_array + rbx * 8] ; rax -> tmp_array[row_start + r][col_start + c]
    
    cmp rcx, rax
    jge findMax_end
    mov rcx, rax

    findMax_end:
        pop rdx
        pop rbx
        pop rax
        pop r11
        pop r10
        pop r9
        pop r8
    ret

; --------------------------------------------------------------------
; ------------------------- Option 6: Noise --------------------------
; --------------------------------------------------------------------
Noise:
    ; choose 1/3 pixels and change the values
    ; 1/6 salt
    ; 1/6 pepper
    mov rax, [new_pixels]
    mov rbx, 6
    mov rdx, 0
    div rbx
    cmp rax, 1
    jl ChangeOnePixel
    mov r15, rax ; r15 -> number of salt pixels
    ;push r8
    mov r8, 0
    Noise_salt_loop:
        cmp r8, r15
        je Noise_salt_end
        call GenerateRandom ; random index -> rax
        mov qword [tmp_array + rax * 8], 255
        inc r8
        jmp Noise_salt_loop

    Noise_salt_end:
        mov r8, 0

    Noise_pepper_loop:
        cmp r8, r15
        je Noise_end
        call GenerateRandom
        mov qword [tmp_array + rax * 8], 0
        inc r8
        jmp Noise_pepper_loop

    Noise_end:
        mov rsi, suces_noise
        call printString
        jmp _start_menu


ChangeOnePixel:
    call GenerateRandom ; random index -> rax
    mov qword [tmp_array + rax * 8], 255
    jmp Noise_end

GenerateRandom:
    ; return: random index -> rax
    rdrand rax                  ; Generate random number -> rax
    jc rand_generated           ; Jump if carry flag is set (success)
    ret

rand_generated:
    ; reduce random number to the specified range -> rax
    push r8
    push r9
    push r10

    mov r8, [new_pixels] ; max
    mov r9, 0 ; min
    mov r10, r8
    sub r10, r9
    inc r10

    xor rdx, rdx

    div r10

    mov rax, rdx

    pop r10
    pop r9
    pop r8
ret
; --------------------------------------------------------------------
; -------------------------- Option 7: Show --------------------------
; --------------------------------------------------------------------
ShowingResult:
    mov r8, 0
    ShowingResult_loop:
        cmp r8, [new_pixels]
        je ShowingResult_end
        mov rax, [tmp_array + r8 * 8]
        call writeNum
        call PrintSpace
        inc r8
        mov rax, r8
        mov rbx, [new_width]
        mov rdx, 0
        div rbx
        cmp rdx, 0
        jne ShowingResult_loop
        call newLine
        jmp ShowingResult_loop

ShowingResult_end:
    call newLine
    jmp _start_menu
; --------------------------------------------------------------------
; ----------------------- Option 8: Gray Scale -----------------------
; --------------------------------------------------------------------
GrayScale:
    mov r8, [new_width]
    mov rax, [new_height]
    mul r8 ; rax -> new_heigh * new_width
    mov rcx, rax
    mov qword [new_dim_value], 1
    mov [new_pixels], rcx
    mov r9, 0
    GrayScale_loop:
        cmp r9, rcx
        je GrayScale_end
        mov rax, [tmp_array + r9 * 8]
        mov rbx, 299
        mov rdx, 0
        mul rbx
        mov rbx, rax ; rbx -> red * 299

        mov rax, rcx
        add rax, r9
        mov r10, rax
        mov rax, [tmp_array + r10 * 8]
        mov r11, 587
        mul r11
        add rbx, rax ; rbx -> red * 299 + green * 587

        mov rax, rcx
        add rax, r9
        add rax, r9
        mov r10, rax
        mov rax, [tmp_array + r10 * 8]
        mov r11, 114
        mul r11
        add rbx, rax ; rbx -> red * 299 + green * 587 + blue * 114

        mov rax, rbx
        mov rbx, 1000
        mov rdx, 0
        div rbx
        mov [grayscale_array + r9 * 8], rax

        inc r9
        jmp GrayScale_loop
    
    GrayScale_end:
        mov r8, 0
        GrayScale_copy_loop:
            cmp r8, rcx
            je GrayScale_copy_end
            mov rbx, [grayscale_array + r8 * 8]
            mov [tmp_array + r8 * 8], rbx
            inc r8
            jmp GrayScale_copy_loop
        GrayScale_copy_end:
            jmp _start_menu


; --------------------------------------------------------------------
; -------------------------- Option 9: Save --------------------------
; --------------------------------------------------------------------
SaveToFile:
    ; create file
    mov rdi, output_filename
    call createFile
    mov [FD_output], rax

    mov r13, 0

    mov rax, [new_height]
    call Convert2String

    mov rax, [new_width]
    call Convert2String

    mov rax, [new_dim_value]
    call Convert2String

    mov bl, 10
    mov byte [tmp_array_str + r13], bl
    inc r13

    call Int2String

    
    mov rdi, [FD_output]
    mov rdx, [output_chars]
    mov rsi, tmp_array_str
    call writeFile

    mov rdi, [FD_output]
    mov rdx, 1
    mov rsi, new_height

    mov rdi, [FD_output]
    call closeFile
    jmp _start_menu


Convert2String:
    ; rax: int value
    mov r10, 10
    mov r11, 0
    convert_loop:
        cmp rax, 0
        je convert_end
        mov rdx, 0
        div r10
        add rdx, 48
        mov [tmp + r11 * 8], rdx
        inc r11
        jmp convert_loop
    convert_end:
        cmp r11, 0
        je isZero
        mov r12, r11
        convert_copy_loop:
            cmp r12, 0
            je convert_copy_end
            mov rbx, 0
            dec r12
            mov rbx, [tmp + r12 * 8]
            mov byte [tmp_array_str + r13], bl
            inc r13
            jmp convert_copy_loop
        convert_copy_end:
            mov bl, 32
            mov byte [tmp_array_str + r13], bl
            inc r13
            ret

        isZero:
            mov byte [tmp_array_str + r13], 48
            inc r13
            jmp convert_copy_end


Int2String:
    mov rax, [new_width]
    mul qword [new_height]
    mul qword [new_dim_value]
    mov rcx, rax ; rcx -> number of all pixel values
    mov [new_pixels], rcx
    mov r8, 0
    Int2String_loop:
        cmp r8, rcx
        je Int2String_end
        mov rax, [tmp_array + r8 * 8]        
        call Convert2String

        GoNext_Int2String:
            inc r8
            jmp Int2String_loop

    Int2String_end:
        mov qword [output_chars], r13
        ret
; --------------------------------------------------------------------
; -------------------------- Option 0: Exit --------------------------
; --------------------------------------------------------------------
Exit:
    mov rax, sys_exit
    xor rdi, rdi
    syscall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



%ifndef SYS_EQUAL
%define SYS_EQUAL

    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777


    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
	PROT_NONE	  equ   0x0
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000


    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20
    ;bufferlen     equ   99999

%endif


  %ifndef NOWZARI_IN_OUT
%define NOWZARI_IN_OUT


;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
   push    rax
   push    rcx
   push    rsi
   push    rdx
   push    rdi

   mov     rdi, rsi
   call    GetStrlen
   mov     rax, sys_write  
   mov     rdi, stdout
   syscall 
   
   pop     rdi
   pop     rdx
   pop     rsi
   pop     rcx
   pop     rax
   ret

;-------------------------------------------

PrintSpace:
    push   rax
    mov    rax, Space
    call   putc
    pop    rax
    ret
;-------------------------------------------
; rdi : zero terminated string start 
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
         repne   scasb
   not     rcx
   lea     rdx, [rcx -1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret
;-------------------------------------------
;-------------------------------------------




; rdi : file name; rsi : file permission
createFile:
    mov     rax, sys_create
    mov     rsi, sys_IRUSR | sys_IWUSR 
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     createerror
    mov     rsi, suces_create           
    call    printString
    ret
createerror:
    mov     rsi, error_create
    call    printString
    ret


;----------------------------------------------------
; rdi : file name; rsi : file access mode 
; rdx: file permission, do not need
openFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR     
    syscall
    cmp     rax, -1   ; file descriptor in rax
    jle     openerror
    mov     rsi, suces_open
    call    printString
    ret
openerror:
    mov     rsi, error_open
    ;call    printString
    ret
;----------------------------------------------------
; rdi point to file name
appendFile:
    mov     rax, sys_open
    mov     rsi, O_RDWR | O_APPEND
    syscall
    cmp     rax, -1     ; file descriptor in rax
    jle     appenderror
    mov     rsi, suces_append
    ;call    printString
    ret
appenderror:
    mov     rsi, error_append
    ;call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
writeFile:
    mov     rax, sys_write
    syscall
    cmp     rax, -1         ; number of written byte
    jle     writeerror
    mov     rsi, suces_write
    call    printString
    ret
writeerror:
    mov     rsi, error_write
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi : buffer ; rdx : length
readFile:
    mov     rax, sys_read
    syscall
    cmp     rax, -1           ; number of read byte
    jle     readerror
    mov     byte [rsi+rax], 0 ; add a  zero ??????????????
    push    rsi
    mov     rsi, suces_read
    call    printString
    pop     rsi
    ret
readerror:
    mov     rsi, error_read
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor
closeFile:
    mov     rax, sys_close
    syscall
    cmp     rax, -1      ; 0 successful
    jle     closeerror
    mov     rsi, suces_close
    call    printString
    ret
closeerror:
    mov     rsi, error_close
    call    printString
    ret

;----------------------------------------------------
; rdi : file name
deleteFile:
    mov     rax, sys_unlink
    syscall
    cmp     rax, -1      ; 0 successful
    jle     deleterror
    mov     rsi, suces_delete
    call    printString
    ret
deleterror:
    mov     rsi, error_delete
    call    printString
    ret
;----------------------------------------------------
; rdi : file descriptor ; rsi: offset ; rdx : whence
seekFile:
    mov     rax, sys_lseek
    syscall
    cmp     rax, -1
    jle     seekerror
    mov     rsi, suces_seek
    call    printString
    ret
seekerror:
    mov     rsi, error_seek
    call    printString
    ret

;----------------------------------------------------


%endif