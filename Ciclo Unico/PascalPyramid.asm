main:
addi a1, zero, 13 # numero total de linhas
addi a2, zero, 0 # endereço de inicio de leitura
addi a3, zero, 17 # endereço de inicio para escrever
addi s1, zero, 1 # numero 1
addi s2, zero, 0 # linha atual
addi s3, zero, 0 # contador de posição
# preencher primeira coluna
while:
addi s2, s2, 1
sw s1, 0(a2)
beq a1, s2, p1
addi a2, a2, 16
jal while
#inicializar mais variaveis
p1:
addi t0, zero, 0 # indica quantos numeros eu terei na linha
addi a2, zero, 0 # voltar pro enderço de inicio de leitura
addi s2, zero, 1 # colcoar o contador de linha na segunda linha (1)
#fazer as contas
p2:
add t0, zero, s2  # ver quantos numeros terei na linha
beq t0, s3, p3
#pegar os 2 ultimos valores da linha de cima em relação a possição
lw t1, 0(a2)
addi a2, a2, 1
lw t2, 0(a2)
#calcular valor atual e escrever
add t3, t1, t2 
sw t3, 0(a3)
#atualizar
addi s3, s3, 1
addi a3, a3, 1
jal p2	
p3:
addi s2, s2, 1  # vou pra proxima linha
beq s2, a1, fim
sub a2, a2, t0   # voltar pro primeiro endereço da linha
sub a3, a3, t0 # voltar pro segundo endereço da linha
#atualizar
addi a3, a3, 16  # ir pra linha de baixo para escrever(ja ta na possição 1)
addi a2, a2, 16  #ir pra linha de baixo para ler
addi s3, zero, 0 #zerei o contador
jal p2	
fim:
