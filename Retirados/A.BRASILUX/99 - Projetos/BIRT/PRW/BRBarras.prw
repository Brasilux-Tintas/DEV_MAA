#Include 'Protheus.ch'
#Include 'tdsbirt.ch'
#Include 'birtdataset.ch'

User Function BRBarras()

Local oReport

DEFINE REPORT oReport NAME Codigobarra TITLE "Relatório de Códigos de Barras" ASKPAR EXCLUSIVE

ACTIVATE REPORT oReport LAYOUT Codigobarra FORMAT HTML 
 
Return