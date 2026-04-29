#include 'totvs.ch'
#Include "Protheus.ch"
 
/*/{Protheus.doc} API_NOMES
Função de API_NOMES
@type function
@author Nelieder M Corneta
@since 22/09/2023
@version 1.0
/*/


User Function API_NOMES()
Local aArray,aNomes := {}

//Definindo o arquivo a ser lido
oFile := FWFileReader():New("\ws_logs\salesforce\nomes.txt")
 
//Se o arquivo pode ser aberto
If (oFile:Open())
 
        While (oFile:HasLine())
                 
            //Buscando o texto da linha atual
            cLinAtu := AllTrim(oFile:GetLine())
            aArray := strtokarr (alltrim(cLinAtu), ";")
            If len(aArray) > 0
                aAdd(aNomes, {AllTrim(aArray[1]) , AllTrim(aArray[2])})
            EndIF    
            aArray := {} 
        EndDo
     
    //Fecha o arquivo e finaliza o processamento
    oFile:Close()
EndIf

return(aNomes)
