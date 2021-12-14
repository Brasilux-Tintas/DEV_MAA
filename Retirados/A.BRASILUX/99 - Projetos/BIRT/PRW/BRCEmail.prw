#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#Include 'birtdataset.ch'
  
User Function BRCEmail()
  
Local oReport
 
DEFINE USER_REPORT  oReport NAME emailClient TITLE "Email Cliente x Vendedor" ASKPAR EXCLUSIVE
  
ACTIVATE REPORT oReport LAYOUT emailClient FORMAT HTML
 
Return