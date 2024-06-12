The Little-Endian Computer Architecture serves as the foundation for the development of the 16-bit NITC-RISC19 computer for teaching. It (NITC-RISC19) is an 8-register, 16-bit computer system. It uses registers R0 to R7 for general purposes, where R7 is $ra. 

Notably, the architecture makes use of a special register file with two registers hi and lo, with one read port and one write port, operated with 3 control signals spregwrite (activated when the register file is written), readhilo (activated when the register file is read) and spra (activated when the operated register is hi, and deactivated when the operated register is lo).

The NITC-RISC19 is relatively simple, but it is general enough to solve complex problems with three machine-code instruction formats (R, I, and J type) and a total of 13 instructions shown below.

# Instruction Formats

## R Type Instruction format

| Opcode | Register S ($s) | Register T ($t) | Register D ($d) | Funct       |
|--------|-----------------|-----------------|-----------------|-------------|
| 4 bit  | 3 bit           | 3 bit           | 3 bit           | 3 bit       |

## I Type Instruction Format

| Opcode | Register S ($s) | Register T ($t) | Immediate (imm)               |
|--------|-----------------|-----------------|-------------------------------|
| 4 bit  | 3 bit           | 3 bit           |  6 bits signed                |

## J Type Instruction format

| Opcode | Register S ($s) | Immediate (imm)                                 |
|--------|-----------------|-------------------------------------------------|
| 4 bit  | 3 bit           |  12 bits signed                                 |

# Instruction Reference

## R Type Instruction Format

| Instruction | Opcode/Funct | Syntax          | Operation                   |
|-------------|--------------|-----------------|-----------------------------|
| add         | 000          | f $d, $s, $t    | $d = $s + $t                |
| sub         | 001          | f $d, $s, $t    | $d = $s - $t                |
| jr          | 010          | o labelR        | pc = $s                     |
| mthi        | 100          | f $s            | hi = $s                     |
| mtlo        | 101          | f $s            | lo = $s                     |
| mfhi        | 110          | f $d            | $d = hi                     |
| mflo        | 111          | f $d            | $d = lo                     |

## I Type Instruction Format

| Instruction | Opcode/Funct | Syntax          | Operation                   |
|-------------|--------------|-----------------|-----------------------------|
| lw          | 0001         | o $t, i ($s)    | $t = MEM [$s + i << 2]      |
| sw          | 0010         | o $t, i ($s)    | MEM [$s + i << 2] = $t      |
| beq         | 0011         | o $s, $t, label | if ($s == $t) pc += i << 2  |
| addi        | 0100         | f $d, $s, i     | $d = $s + SE(i)             |

## J Type Instruction Format
| Instruction | Opcode/Funct | Syntax          | Operation                   |
|-------------|--------------|-----------------|-----------------------------|
| j           | 1000         | o label         | pc += i << 2                |
| jal         | 1001         | o label         | $7 = pc; pc += i << 2       |
