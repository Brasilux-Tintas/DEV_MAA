#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#Include 'birtdataset.ch'
  
User Function BRMetLif()
  
Local oReport
 
DEFINE USER_REPORT  oReport NAME MetLifR TITLE "Seguro MetLife" ASKPAR EXCLUSIVE
  
ACTIVATE REPORT oReport LAYOUT MetLifR FORMAT HTML
 
Return