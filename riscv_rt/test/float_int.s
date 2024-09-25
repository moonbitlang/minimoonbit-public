.global minimbt_main

minimbt_main:
    li a0, 1
    call mincaml_float_of_int
    call mincaml_int_of_float
    call mincaml_print_int
    li a0, 0
    li a7, 93
    ecall
