#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#Include 'birtdataset.ch'
 
  
User Function BRCodBar()
  
Local oReport
 
DEFINE USER_REPORT  oReport NAME codBarBR TITLE "CODIGO DE BARRA" ASKPAR EXCLUSIVE
  
ACTIVATE REPORT oReport LAYOUT codBarBR FORMAT HTML
 
Return