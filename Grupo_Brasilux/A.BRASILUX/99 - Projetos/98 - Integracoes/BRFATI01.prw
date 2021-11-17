//#include 'brasilux.ch'
#include "protheus.ch"
#include 'topconn.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFATI01  ºAutor  ³ Luís G. de Souza   º Data ³  20/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Integração do Microsiga com planilhas do Excel.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFATI01()
     cTempoIni := Time()
     If !ApOleClient( 'MsExcel' )
        MsgStop( 'MsExcel nao instalado' )
        Return
     EndIf
     Processa({ || FATI01_1(cTempoIni)})
Return()

Static Function FATI01_1(cTempoIni)
       Local   cQry1    := ""
       Local   cQry2    := ""
       Local   cQry3    := ""
       Local   aPosic   := {}
       //Local   cDirDocs := MsDocPath()
       Local   aStru    := {}
       //Local   cArquivo := CriaTrab(, .F.)
       Local   cArquivo := GetNextAlias()
       //Local   cPath    := AllTrim(GetTempPath())
       //Local   oExcelApp
       //Local   nX       := 0
       Private aItens   := {}
       Private oTempTbl01
       
       aStru := { {"ESTADO", "C", 02, 0} }

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //dbCreate(cDirDocs+"\"+cArquivo, aStru)
       //dbUseArea(.T., , cDirDocs+"\"+cArquivo, cArquivo, .F., .F.)
       oTempTbl01 := FWTemporaryTable():New( cArquivo )
       oTempTbl01:SetFields( aStru )
       oTempTbl01:Create()

       cQry1 += "SELECT ESTADO+REPRESENTANTE+CLIENTE AS CHAVE, MESANO, ESTADO, REPRESENTANTE, CLIENTE, SUM(QUANTIDADE) AS QUANTIDADE, SUM(VALOR) AS VALOR "
       cQry2 += "SELECT COUNT(*) AS QTDREC "
       cQry3 += "FROM RESULTADO_2007 WITH (NOLOCK) "
       cQry2 += cQry3       
       TCQuery cQry2 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       nQtdRec := TCQ->QTDREC / 4
       nConRec := 0
       ProcRegua(nQtdRec)
       DbSelectArea("TCQ")
       DbCloseArea()
       cQry3 += "GROUP BY ESTADO+REPRESENTANTE+CLIENTE, ESTADO, REPRESENTANTE, CLIENTE, MESANO "
       cQry1 += cQry3
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       cMsgTeste := "Tempo Inicio: "+cTempoIni+Chr(13)+Chr(10)
       cMsgTeste += "Tempo 1     : "+Time()+Chr(13)+Chr(10)
       MsgStop(cMsgTeste)
       While !Eof() .AND. LEN(AITENS) < 1000
             If aScan(aPosic, {|x| x[1] == TCQ->CHAVE}) == 0
                aAdd(aPosic, {TCQ->CHAVE})
                nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
                aAdd(aItens, { TCQ->ESTADO, TCQ->REPRESENTANTE, TCQ->CLIENTE, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
             Else
                nPos := aScan(aPosic, {|x| x[1] == TCQ->CHAVE})
             Endif
             nIni := 4
             nSal := 3

             aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 0) ] += TCQ->QUANTIDADE
             aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 1) ] += TCQ->VALOR
             aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 2) ] += ( aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 1) ] / aItens[nPos][( ( nIni + (nSal * ( Val( SubStr( TCQ->MESANO, 1, 2 ) ) - 1 ) ) ) + 0) ] )
             nConRec += 1
             IncProc(StrZero(nConRec, 5)+"/"+StrZero(Int(nQtdRec), 5))
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       cMsgTeste += "Tempo 2     : "+Time()
       MsgStop(cMsgTeste)
       //For nY := 1 To 1000
       //    RecLock(cArquivo, .T.)
       //       (cArquivo)->ESTADO     := aItens[nY][1]
       //    MsUnLock()
       //Next
       //DbSelectArea(cArquivo)
       //DbCloseArea()
       //cMsgTeste += "Tempo 3     : "+Time()
 
       //CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )

       //oExcelApp := MsExcel():New()
       //oExcelApp:WorkBooks:Open( cPath+cArquivo+".DBF" ) // Abre uma planilha
       //oExcelApp:SetVisible(.T.)

       DbSelectArea("TCQ")
       DbCloseArea()

       DbSelectArea( cArquivo )
       DbCloseArea()
       oTempTbl01:Delete()
Return(aItens)
//TCQ->ESTADO+TCQ->REPRESENTANTE+TCQ->CLIENTE, TCQ->ESTADO, TCQ->REPRESENTANTE, TCQ->CLIENTE, QTD01, FAT01, MED01, QTD02, FAT02, MED02, QTD03, FAT03, MED03, QTD04, FAT04, MED04, QTD05, FAT05, MED05, QTD06, FAT06, MED06, QTD07, FAT07, MED07, QTD08, FAT08, MED08, QTD09, FAT09, MED09, QTD10, FAT10, MED10, QTD11, FAT11, MED11, QTD12, FAT12, MED12