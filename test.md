
| Opcode | Register S ($s) | Register T ($t) | Register D ($d) | Funct |
|--------|-----------------|-----------------|-----------------|-------|
| 4 bit  | 3 bit           | 3 bit           | 3 bit           | 3 bit |

| Opcode | Register S ($s) | Register T ($t) | Immediate (imm) |
|--------|-----------------|-----------------|-----------------|
| 4 bit  | 3 bit           | 3 bit           |  6 bits signed  |

| Opcode | Register S ($s) | Immediate (imm) |
|--------|-----------------|-----------------|
| 4 bit  | 3 bit           |  12 bits signed |

| Instruction | Opcode/Funct | Syntax          | Operation                 |
|-------------|--------------|-----------------|---------------------------|
| R-Type      |              |                 |                           |
| add         | 000          | f $d, $s, $t    | $d = $s + $t              |
| sub         | 001          | f $d, $s, $t    | $d = $s - $t              |
| jr          | 010          | o labelR        | pc = $s                   |
| mthi        | 100          | f $s            | hi = $s                   |
| mtlo        | 101          | f $s            | lo = $s                   |
| mfhi        | 110          | f $d            | $d = hi                   |
| mflo        | 111          | f $d            | $d = lo                   |
| I-Type      |              |                 |                           |
| lw          | 0001         | o $t, i ($s)    | $t = MEM [$s + i << 2]     |
| sw          | 0010         | o $t, i ($s)    | MEM [$s + i × 2] = $t     |
| beq         | 0011         | o $s, $t, label | if ($s == $t) pc += i × 2 |
| addi        | 0100         | f $d, $s, i     | $d = $s + SE(i)           |
| J-Type      |              |                 |                           |
| j           | 1000         | o label         | pc += i × 2               |
| jal         | 1001         | o label         | $7 = pc; pc += i × 2      |
