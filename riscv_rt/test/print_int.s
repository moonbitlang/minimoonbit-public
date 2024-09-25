.global minimbt_main

minimbt_main:
    li a0, 666
    call mincaml_print_int
    li a0, 0
    li a7, 93
    ecall
