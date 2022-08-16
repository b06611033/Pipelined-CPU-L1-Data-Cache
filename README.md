# Pipelined CPU + L1 Data Cache
## Description
**Pipelined CPU with:**
>
**Off-chip Data Memory**\
• Size: 16KB\
• Data width: 32 Bytes\
• Memory access latency: 10 cycles (send an ack when finish 
access)\
**L1 Data Cache**\
• Size: 1KB\
• Associative: 2-way\
• Replacement policy: LRU\
• Cache line size: 32 Bytes\
• Write hit policy: write back\
• Write miss policy: write allocate\
• offset: 5 bits, index: 4 bits, tag: 23 bits
## System Architecture
![k](https://user-images.githubusercontent.com/52776608/170442020-e13b4c70-9b9e-478f-8029-42739c517591.png)
## Data Path
![p](https://user-images.githubusercontent.com/52776608/170442040-915fae37-475f-431e-a4e5-91bffa9f06e0.png)
## Supported Instructions
* and rd, rs1, rs2 (bitwise and)
* xor rd, rs1, rs2 (bitwise exclusive or)
* sll rd, rs1, rs2 (shift left logically)
* add rd, rs1, rs2 (addition)
* sub rd, rs1, rs2 (subtraction)
* mul rd, rs1, rs2 (multiplication)
* addi rd, rs1, imm (addition)
* srai rd, rs1, imm (shift right arithmetically)
* lw rd, imm(rs1) (load word)
* sw rs1, imm(rs2) (store word)
* beq rs1, rs2, imm (branch)
