#INCLUDE 'PROTHEUS.CH'                                          
#include "ap5mail.ch"                                                     	

 
/*/{Protheus.doc} MT261TDOK
//TODO Descrição auto-gerada.
@author 
@since 
@version 1.0
@return ${return}, ${return_description}

@type function
25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
/*/
User Function  MT261TDOK()
     Local _cAlias := Alias()
     Local aArea   := U_PegaArea({"SB2","SZH"})
     Local cAuxDoc,cFlag,cTexto,i,cAssunto,saldoAtual,saldoEmpenhado,saldoDisponivel,cProdDif,_cNumSeri
     u_zcfga01( 'MT261TDOK' ) //LGS#2021119 - Gravação de log de utilização da rotina
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        cAuxDoc := M->CDOCUMENTO    
        cProdDif := ""   
        cFlag := 0
        cTexto :="Os produtos abaixo possuem saldo disponível e não necessitavam de transferência - "
        cTexto += iif(xFilial("SB2") = '060101',"DISSOLTEX","BRASILUX")

        DbSelectArea("SB2")
        DbSetorder(1)
        For i:= 1 To Len(aCols) 
            if !aCols[i][Len(aHeader)+1] //Se não for registro deletado  
               _cNumSeri := alltrim(aCols[i][11]) //D3_NUMSERI -> Forma de identificar se o movimento não vem dos apontamentos que preenchem esse campo com o nro da OP
               If empty(_cNumSeri) .and. !(alltrim(aCols[i][1]) == alltrim(aCols[i][6]))    
                  cProdDif += "Código "+alltrim(aCols[i][1])+" transferido para o código "+alltrim(aCols[i][6])+" na quantidade "+Transform(aCols[i][16],"@E 99999.99")+CHR(13)+CHR(10)
               Endif
               If aCols[i][9] == "R1" .OR. aCols[i][9] == "R2"
                  If !aCols[i][Len(aHeader)+1]
                     DbSeek(xFilial("SB2")+(aCols[i][6]+aCols[i][9]))
                     If Found()
                        if (SaldoSb2() - aCols[i][16]) > 0
                           saldoAtual 		:= (B2_QATU - aCols[i][16])
                           saldoEmpenhado 	:= B2_QEMP
                           saldoDisponivel := (saldosb2() -aCols[i][16])
                           cFlag := 1
                           cTexto+= CHR(13)+CHR(10)
                           cTexto+= CHR(13)+CHR(10)+"Produto -> "+B2_COD+ " quantidade transferida para "+aCols[i][9]+" -->  "+Transform(aCols[i][16],"@E 99999.99")
                           cTexto+= CHR(13)+CHR(10)+"Antes da Transferência : "+Transform(saldoAtual,     "@E 99999.99")
                           cTexto+= CHR(13)+CHR(10)+"Saldo Total Empenhado  : "+Transform(saldoEmpenhado, "@E 99999.99")
                           cTexto+= CHR(13)+CHR(10)+"Saldo Disponível       : "+Transform(saldoDisponivel,"@E 99999.99")
                        Endif                                                    	
                     EndIf
                  EndIf
                  DbSelectArea("SB2")
                  dbSkip()
               EndIf
            Endif
        Next          
        cNomePor := ""
        DBSELECTAREA("SZH")
        dbsetorder(1)
        dbseek(xFilial("SZH")+__cUserId)
        if found() 
           IF SZH->ZH_MSBLQL != "1" //Quando é rotina AUTOMÁTICA a variável __cUserId não vem correta!
              cNomePor := SZH->ZH_NOME
           ENDIF
        Endif 
        If cFlag == 1      
           If !empty(cNomePor)
              cTexto+=CHR(13)+CHR(10)+"Transferido por: "+ cNomePor
           Endif 
           cAssunto := "TRANSFERÊNCIA P/ ALMOXARIFADO PRODUÇÃO (R1 OU R2) DOC-> "+M->CDOCUMENTO
           HDMail(cAssunto,cTexto)
        Endif
        If !empty(cProdDif)
           cTexto := "Efetuada Transferência entre produtos de CÓDIGOS DIFERENTES"+CHR(13)+CHR(10)+cProdDif
           If !empty(cNomePor)
              cTexto+=CHR(13)+CHR(10)+"Transferido por: "+ cNomePor
           Endif 
           cAssunto := "TRANSFERÊNCIA ENTRE CÓDIGOS DIFERENTES DE PRODUTOS, DOC-> "+M->CDOCUMENTO
           HDMail(cAssunto,cTexto)
        Endif
        U_VoltaArea(aArea)
        If !empty( _cAlias )
           dbselectarea( _cAlias )
        Endif
     Endif
Return

Static FUNCTION HDMail(cAssunto,cTexto)
       Local cPara,cCC,cArquivo
       //dbselectarea("Z06")
       cPara    :="materiais@brasilux.com.br"
       cCC      := "" 
       cArquivo := ''
       U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo)
Return nil  
