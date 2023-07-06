main:
addi a1, zero, 13 # numero total de linhas
addi a2, zero, 0 # endere?o de inicio de leitura
addi s2, zero, 0 # linha atual
addi s1, zero, 1 # numero 1
addi a3, zero, 17 # endere?o de inicio para escrever
addi s3, zero, 0 # contador de posi??o
# preencher primeira coluna
while:
addi s2, s2, 1
sw s1, 0(a2)
nop
nop
beq a1, s2, p1
nop
addi a2, a2, 16
nop
nop
beq zero, zero, while

#inicializar mais variaveis
p1:
addi t0, zero, 0 # indica quantos numeros eu terei na linha
addi s2, zero, 1 # colcoar o contador de linha na segunda linha (1)
addi a2, zero, 0 # voltar pro ender?o de inicio de leitura
nop
nop
nop
#fazer as contas
p2:
add t0, zero, s2  # ver quantos numeros terei na linha
nop
nop
nop
beq t0, s3, p3
nop
#pegar os 2 ultimos valores da linha de cima em rela??o a possi??o
lw t1, 0(a2)
nop
nop
addi a2, a2, 1
nop
nop
nop
lw t2, 0(a2)
nop
nop
#calcular valor atual e escrever
add t3, t1, t2 
nop
nop
nop
sw t3, 0(a3)
nop
#atualizar
addi s3, s3, 1
addi a3, a3, 1
beq zero, zero, p2
p3:
addi s2, s2, 1  # vou pra proxima linha
nop
nop
nop
beq s2, a1, fim
nop
sub a2, a2, t0   # voltar pro primeiro endere?o da linha
sub a3, a3, t0 # voltar pro segundo endere?o da linha
nop
nop
#atualizar
addi a2, a2, 16  #ir pra linha de baixo para ler
addi a3, a3, 16  # ir pra linha de baixo para escrever(ja ta na possi??o 1)
addi s3, zero, 0 #zerei o contador
beq zero, zero, p2
fim:

