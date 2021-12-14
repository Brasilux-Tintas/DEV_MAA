#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#Include 'birtdataset.ch'
  
User Function BRClient()
Local oReport
Private cCliente
cCliente := "000001" 
DEFINE USER_REPORT  oReport NAME Cliente TITLE "Produto Cliente" ASKPAR EXCLUSIVE
  
ACTIVATE REPORT oReport LAYOUT Cliente FORMAT HTML
 
Return