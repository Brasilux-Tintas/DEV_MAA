#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#Include 'birtdataset.ch'
  
User Function TPR15()
  
Local oReport
 
DEFINE USER_REPORT  oReport NAME TPR15 TITLE "Analise do saldo de terceiros - sintético" ASKPAR EXCLUSIVE
  
ACTIVATE REPORT oReport LAYOUT TPR15 FORMAT HTML
 
Return