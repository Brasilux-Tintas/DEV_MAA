#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#Include 'birtdataset.ch'
  
User Function BRLaudo()
  
Local oReport
 
DEFINE USER_REPORT  oReport NAME brlaudo TITLE "Certificado de Qualidade" ASKPAR EXCLUSIVE
  
ACTIVATE REPORT oReport LAYOUT brlaudo FORMAT HTML
 
Return