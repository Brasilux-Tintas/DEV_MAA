#Include 'Protheus.ch'
#Include 'tdsbirt.ch'
#Include 'birtdataset.ch'

User Function BRProAliq()

Local oReport

DEFINE REPORT oReport NAME Produtoaliq4 TITLE "Relatório de Produtos com Alíquota de ICMS 4%" ASKPAR EXCLUSIVE

ACTIVATE REPORT oReport LAYOUT Produtoaliq4 FORMAT HTML 

Return	
