.global mincaml_main

mincaml_main:
    li a0, 1024
    call mincaml_malloc
    li t0, 777
    sw t0, 0(a0)
    lw a0, 0(a0)
    call mincaml_print_int
    li a7, 93
    ecall
