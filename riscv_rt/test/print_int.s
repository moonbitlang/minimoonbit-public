.global mincaml_main

mincaml_main:
    li a0, 666
    call mincaml_print_int
    li a0, 0
    li a7, 93
    ecall
