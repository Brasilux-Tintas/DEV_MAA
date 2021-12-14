#Include 'Protheus.ch'
#Include 'tdsbirt.ch'
#Include 'birtdataset.ch'

User Function BRMultas()

Local oReport

DEFINE REPORT oReport NAME Relatoriomultas TITLE "Relatório Multas Transito" ASKPAR EXCLUSIVE

ACTIVATE REPORT oReport LAYOUT Relatoriomultas FORMAT HTML 

Return