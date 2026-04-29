//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} zVid0094
Exemplo de como abrir um arquivo dtc (ctree) via programação
@type user function
@author Atilio
@since 19/01/2024
/*/
 
User Function zVid0094()
    Local aArea     := FWGetArea()
    Local cRDD      := "CTREECDX"
   // Local cRDD      := "DBFCDX"
    Local cAliasArq := GetNextAlias()
    Local cArquiAtu := "\zebra\ctree\sxb9901.dtc"
    Local cMensagem := ""
    Local nI        := 0
 
    //Somente se o arquivo existir
    If File(cArquiAtu)
 
        //Abre o arquivo CTREE
        DbUseArea(.T., cRDD, cArquiAtu, cAliasArq, .F., .F.)
 
        //Se tiver dados, exibe uma mensagem
        If ! (cAliasArq)->(EoF())
            cMensagem := "Arquivo " + cArquiAtu + " aberto com sucesso!" + CRLF + CRLF
            cMensagem += "Agora você pode fazer laços de repetição e usar comandos como DbSkip." + CRLF + CRLF
            ShowLog(cMensagem)
            while .NOT. (cAliasArq)->(EoF()) 
                SXB->(dbSetOrder(1))
                RecLock("SXB",.T.)
                For nI:=1 to (cAliasArq)->(FCount())
                    cCampo := (cAliasArq)->(FieldGet(nI))
                    SXB->(FieldPut(nI, cCampo))
                Next
                SXB->(MsUnLock())                
                (cAliasArq)->(DbSkip())
            End
            alert("FIM!")
        //Senão, avisa que não encontrou informações
        Else
            FWAlertInfo("Não tem dados!", "Arquivo: " + cArquiAtu)
        EndIf
        (cAliasArq)->(DbCloseArea())
    EndIf
 
    FWRestArea(aArea)
Return
