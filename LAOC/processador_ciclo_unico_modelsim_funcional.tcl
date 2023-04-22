# Universidade Federal de Minas Gerais
# Escola de Engenharia
# Departamento de Engenharia Eletrônica
# Autoria: Professor Ricardo de Oliveira Duarte
#
# Este arquivo é um script para compilação e simulação funcional de arquivos vhd testbench no ModelSim-Altera
# Este script foi construído usando-se como base o documento obtido na Internet em: https://www.doulos.com/knowhow/tcltk/examples/modelsim/
# ModelSimSE general compile script version 1.1
# Copyright (c) Doulos June 2004, SD
#
# Para executar este script, abra o Modelsim e da janela Transcript execute o comando: do este_arquivo.tcl
# OBSERVAÇÃO: Todos os arquivos vhd, inclusive o testbench (tb_dut.vhd) deverão estar na mesma pasta para executar este script.
#
## MODIFIQUE SOMENTE O CONTEÚDO DA SEÇÃO EM DESTAQUE COM LINHAS CONTÍNUAS COM O SÍMBOLO DE COMENTÁRIO EM TCL
## MODIFIQUE TAMBÉM O TEMPO FINAL DE SIMULAÇÃO DEPOIS DO ÚLTIMO COMENTÁRIO NO FINAL DESTE ARQUIVO
## O RESTANTE DO SCRIPT NÃO PRECISA SER MODIFICADO !!
##########################################################################################################################################
# A variável TCl library_file_list é uma lista bidimensional. A primeira dimensão determina a biblioteca que vai ser criadas no projeto.
# No exemplo abaixo a biblitecas se chama: design_library
# A segunda dimensão consiste numa lista de arquivos fonte vhd que serão compilados e comporão a respectiva biblioteca a qual 
# pertencem. A ordem que os arquivos vhd aparecem nas listas é importante. Os arquivos vhd que não possuem componentes devem
# vir primeiro, em seguida os arquivos vhd que declaram o uso de componentes já existentes na lista e por fim o vhd que contém
# a entidade de mais alto nível.
set library_file_list {
	design_library {
		banco_de_registradores.vhd
		memi.vhd
		pc.vhd
		somador.vhd
		ula.vhd
		unidade_de_controle_ciclo_unico.vhd
		via_de_dados_ciclo_unico.vhd
		processador_ciclo_unico.vhd
		tb_processador_ciclo_unico.vhd
	}
}

# A variável TCL top_level conterá a entidade de mais alto nível do projeto a ser simulado no ModelSim
set top_level design_library.tb_processador_ciclo_unico

# A variável TCL wave_patterns pode conter uma lista de sinais ou padrões que vão ser carregados na janela Wave do ModelSim.
# Para exibir todos os sinais do testbench basta incluir somente /* no interior da lista, assim como foi feito a seguir.
set wave_patterns { /* }

# A variável TCL wave_radices também é uma lista bidimensional. O primeiro elemento da lista é o a base (RADIX) de representação do sinal
# O segundo elemento é uma lista de sinais que serão exibidos segundo o radix (base) definida.
# Podem existir zero, um ou mais elementos na lista. Espaço é o símbolo delimitador entre um sinal e outro. 
set wave_radices {
hexadecimal {Leds_vermelhos_saida_tb Led_verde_zero_tb Led_verde_negativo_tb Chave_reset_tb Clock_tb}
}
##########################################################################################################################################

# Compila todos os arquivos fonte que ainda não foram compilados ou que tiveram seu arquivo fonte modiicado recentemente e cria a biblioteca.
set time_now [clock seconds]
if [catch {set last_compile_time}] {
  set last_compile_time 0
}
foreach {library file_list} $library_file_list {
  vlib $library
  vmap work $library
  foreach file $file_list {
    if { $last_compile_time < [file mtime $file] } {
      if [regexp {.vhdl?$} $file] {
        vcom -93 $file
      } else {
        vlog $file
      }
      set last_compile_time 0
    }
  }
}
set last_compile_time $time_now

# Carrega a simulação
eval vsim $top_level

# Se formas de onda existirem, elas serão incluídas como sinais na janela Wave do ModelSim.
if [llength $wave_patterns] {
	noview wave
	foreach pattern $wave_patterns {
		add wave $pattern
	}
	configure wave -signalnamewidth 1
	foreach {radix signals} $wave_radices {
		foreach signal $signals {
			catch {property wave -radix $radix $signal}
		}
	}
	configure wave -namecolwidth 189
	configure wave -valuecolwidth 137
	configure wave -justifyvalue left
	configure wave -signalnamewidth 0
	configure wave -snapdistance 10
	configure wave -datasetprefix 0
	configure wave -rowmargin 4
	configure wave -childrowmargin 2
	configure wave -gridoffset 0
	configure wave -gridperiod 1
	configure wave -griddelta 40
	configure wave -timeline 0
	configure wave -timelineunits ns
	update
}

## RODA A SIMULAÇÃO POR 480 ns
## MODIFIQUE O COMANDO A SEGUIR CONFORME SUA NECESSIDADE
run 480 ns

## ALTERE O VALOR DO TEMPO FINAL DA JANELA DE SIMULAÇÃO DO DUT CONFORME SUA NECESSIDADE
WaveRestoreZoom {0 ns} {480 ns}