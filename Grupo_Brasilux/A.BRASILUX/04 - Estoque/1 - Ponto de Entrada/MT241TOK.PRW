#INCLUDE 'PROTHEUS.CH'                                          
#include "ap5mail.ch"                                                     	
 
/*/{Protheus.doc} MT241TOK
//TODO Descrição auto-gerada.
@author 
@since 
@version 1.0
@return ${return}, ${return_description}

@type function
25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
/*/
User Function MT241TOK()
     Local cAlias := Alias()
     Local aArea := U_PegaArea({"SB2"})
     Local cAuxDoc, cFlag, cTexto, i, cAssunto, saldoAtual, saldoEmpenhado, saldoDisponivel

     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        cAuxDoc := M->CDOCUMENTO
        cFlag := 0
        If xFilial("SB2") == '060101'
           cTexto :="Produto(s) com saldo disponivel positivo transferido na DISSOLTEX"
        Else
           cTexto :="Produto(s) com saldo disponivel positivo transferido na BRASILUX"
        EndIf
        If M->CTM == "570" .OR. M->CTM == "560"
           DbSelectArea("SB2")
           DbSetorder(1)
           For i:= 1 To Len(aCols)
               If !aCols[i][Len(aHeader)+1]
                  DbSeek(xFilial("SB2")+(aCols[i][1]+"99"))                            
                  If Found()
                     If SaldoSb2() > 0
                        saldoAtual      := B2_QATU
                        saldoEmpenhado  := B2_QEMP
                        saldoDisponivel := saldosb2()
                        cFlag := 1
                        cTexto+= CHR(13)+CHR(10)+"Codigo produto:  "+B2_COD+ " quantidade transferida:  "+Transform(aCols[i][3],"@E 99999.99")
                        cTexto+= CHR(13)+CHR(10)+"Saldo atual: "+Transform(saldoAtual,"@E 99999.99")
                        cTexto+= CHR(13)+CHR(10)+"Saldo empenhado: "+Transform(saldoEmpenhado,"@E 99999.99")
                        cTexto+= CHR(13)+CHR(10)+"Saldo disponivel: "+Transform(saldoDisponivel,"@E 99999.99")
                     Endif
                  EndIf
               EndIf
               DbSelectArea("SB2")
               dbSkip()
           Next
        EndIf
        If cFlag == 1
           cTexto+=CHR(13)+CHR(10)+"Transferido por: "+ Posicione("SZH", 1, xFilial("SZH")+__cUserId, "ZH_NOME")
           cAssunto := "NUMERO DE TRANSFERENCIA: "+M->CDOCUMENTO
           HDMail(cAssunto,cTexto)
        Endif
        U_VoltaArea(aArea)
        If !empty(cAlias)
           Dbselectarea(cAlias)
        Endif
     Endif
Return

Static FUNCTION HDMail( cAssunto, cTexto )
       Local cPara, cCC, cArquivo
       //dbselectarea("Z06")
       cPara    := "materiais@brasilux.com.br"
       cCC      := "" 
       cArquivo := ''
       U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo)
Return nil