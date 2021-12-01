#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBRFAT040  บAutor  ณ Marcos C.D. Vieira บ Data ณ  27/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gerar arquivo texto para GNRE's                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TECNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Parametros: mv_par01    // Da Data de Emissao
            mv_par02    // Reprocessamento(S/N)
*/
User Function BRFAT040()
     Private cPERG := "BRFT40"
     u_zcfga01( 'BRFAT040' ) //LGS#2021130 - Grava็ใo de log de utiliza็ใo da rotina    
     VldPerg()             // Verifica as perguntas selecionadas 
     Pergunte(cPerg, .F.)  // Pergunta no SX1

     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Gerar Arquivo TXT para GNRE's"
     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte("BRFT40")
     @ 91,168 BMPBUTTON TYPE 1 ACTION ExecBlock("FAT040_1", .f., .f.)
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 23,16 SAY "Este programa tem como objetivo gerar um arquivo do tipo .TXT  "
     @ 33,16 SAY "dos registros gerados sem Inscricao Estadual Subst.Tributario  "
     @ 43,16 SAY "O arquivo sera gerado no diretorio AP5\SIGAADV o seu nome sera "
     @ 53,16 SAY "composto da seguinte maneira: SIST+dia+mes da data atual.TXT.  "
     @ 8,10 TO 84,222
     ACTIVATE DIALOG oDlg1
Return

/*******************************************************************************/
/*** VldPerg  - Atualiza arquivo de perguntas (SX1)                          ***/
/*** Autor: Marcos C. D. Vieira                                              ***/
/*** Data : 25/07/01                                                         ***/
/*** Altera็๕es:                                                             ***/
/*******************************************************************************/
Static Function VldPerg()  
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       aRegs := {}
       cPerg := PADR(cPerg,10)
       aAdd(aRegs,{cPerg, "01", "Data Emissao de       ?", "", "", "mv_ch1", "D", 08, 0, 0, "G", "NaoVazio", "mv_par01", ""	  , ""   , ""   , "", "", ""   , ""   , ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "02", "Reprocessamento       ?", "", "", "mv_ch2", "N", 01, 0, 2, "C", ""        , "mv_par02", "Sim", "Si" , "Yes", "", "", "Nao", "No" , "No" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return

/*******************************************************************************/
/*** FAT040_1 - Gera arquivo texto para GNREดs                               ***/
/*** Autor: Marcos C. D. Vieira                                              ***/
/*** Data : 12/09/01                                                         ***/
/*** Altera็๕es: 11/05/07 - Luํs Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT041 para FAT040_1 dentro  ***/
/***                        do programa BRFAT040                             ***/
/*******************************************************************************/
User Function FAT040_1()
     Local nArea1  := Alias()
     Local nRecno1 := Recno()
     Local nIndex1 := IndexOrd()
     Local nRecno  := 1
     Local cAux    := Space(20)
     Local cQuery  := ""

     cEmis01 := SubStr(DTOS(MV_PAR01), 5, 2)+SubStr(DTOS(MV_PAR01), 1, 4)
     cEmis02 := SubStr(DTOS(MV_PAR02), 5, 2)+SubStr(DTOS(MV_PAR02), 1, 4)

     cQuery += "SELECT * "
     cQuery += " FROM "+RetSqlName("SZ9")+" SZ9"
     cQuery += " WHERE SZ9.Z9_FILIAL = '"+xFilial("SZ9")+"' AND "
     cQuery += " SZ9.Z9_EMISSAO BETWEEN '"+cEmis01+"' AND '"+cEmis02+"' AND "
     cQuery += " SZ9.Z9_FLGGERA = ' ' AND "        
     cQuery += " SZ9.Z9_IEST = '                    ' AND "
     cQuery += " SZ9.D_E_L_E_T_ <> '*' "
     cQuery += " ORDER BY SZ9.Z9_NF, SZ9.Z9_SERIENF "
     TCQUERY cQuery NEW ALIAS "TMP"
     DbSelectArea("TMP")
     DbGoTop()

     If Eof()
        DbSelectArea("TMP")
        DbCloseArea("TMP")
        MsgStop("Nao ha registros com estes parametros")
        Return
     Endif

     cAux  := SubStr(DTOC(dDataBase), 1, 2)+SubStr(DTOC(dDataBase), 4, 2)              
     cArq  := "F:\AP5\SIGAADV\SIST"+cAux+".TXT"
     hFile := fCreate(cArq)
     If hFile < 0
        MsgBox("Nใo foi possํvel gerar arquivo!", "Aten็ใo...", "STOP")
        DbSelectArea("TMP")
        DbCloseArea("TMP")
        Return
     Endif                
     TMP->(DbGoTop())
     While !Eof() 
           cAux    := SUBSTR(TMP->Z9_DTVENC,7,2)+"/"+SUBSTR(TMP->Z9_DTVENC,5,2)+"/"+SUBSTR(TMP->Z9_DTVENC,3,2)
           cBLinha := "" 
           cBLinha := cBLinha + AllTrim(TMP->Z9_UF)+CHR(9)                     
           cBLinha := cBLinha + AllTrim(TMP->Z9_RECEIT)+CHR(9)                                  
           cBLinha := cBLinha + AllTrim(TMP->Z9_CNPJCPF)+CHR(9)                     
           cBLinha := cBLinha + AllTrim(TMP->Z9_DOCORI)+CHR(9)                                
           cBLinha := cBLinha + AllTrim(TMP->Z9_REF)+CHR(9)                     
           cBLinha := cBLinha + TransForm(TMP->Z9_VLPRINC,"@E 999999999.99")+CHR(9) 
           cBLinha := cBLinha + TransForm(TMP->Z9_ATUAMON,"@E 999999999.99")+CHR(9)
           cBLinha := cBLinha + TransForm(TMP->Z9_JUROS,  "@E 999999999.99")+CHR(9)
           cBLinha := cBLinha + TransForm(TMP->Z9_MULTA,  "@E 999999999.99")+CHR(9)
           cBLinha := cBLinha + TransForm(TMP->Z9_TOTAREC,"@E 999999999.99")+CHR(9)
           cBLinha := cBLinha + cAux+CHR(9)                                
           cBLinha := cBLinha + AllTrim(TMP->Z9_CONVENI)+CHR(9)                     
           cBLinha := cBLinha + AllTrim(TMP->Z9_RAZSOC)+CHR(9)                                
           cBLinha := cBLinha + AllTrim(TMP->Z9_IEST)+CHR(9)                                
           cBLinha := cBLinha + AllTrim(TMP->Z9_END)+CHR(9)
           cBLinha := cBLinha + AllTrim(TMP->Z9_MUNICIP)+CHR(9)                     
           cBLinha := cBLinha + AllTrim(TMP->Z9_EST)+CHR(9)                                
           cBLinha := cBLinha + SubStr(TMP->Z9_CEP,1,5)+"-"+SubStr(TMP->Z9_CEP,6,3)+CHR(9)                     
           cBLinha := cBLinha + AllTrim(TMP->Z9_TEL)+CHR(9)                                
           cBLinha := cBLinha + AllTrim(TMP->Z9_INFO)+"NF NRO "+Z9_NF+CHR(9)                                
           cBLinha := cBLinha + Iif(!Empty(Z9_PRODUTO),AllTrim(TMP->Z9_PRODUTO),"3")
           cBLinha := cBLinha + CHR(13)+CHR(10)

           FWrite(hFile, cBLInha, Len(cBLinha))

           DbSelectArea("SZ9")
           DbSetOrder(1)
           DbSeek(xFILIAL("SZ9")+TMP->Z9_NF+TMP->Z9_SERIENF)
           If Found()
              Reclock("SZ9",.F.)
                 SZ9->Z9_DTGERA  := dDATABASE   
                 SZ9->Z9_FLGGERA := "S"
              MsUnLock()
           EndIf

           DbSelectArea("TMP")
           DbSkip() 
     Enddo
     fClose(hFile)
     MsgBox("Nome do arquivo gerado "+cArq+CHR(13)+CHR(10)+"estแ localizado na pasta F:\AP5\SIGAADV."+CHR(13)+CHR(10))

     DbSelectArea("TMP")
     DbCloseArea("TMP")
     	
     DbSelectArea(nArea1)
     DbSetOrder(nIndex1)
     DbGoto(nRecno1)     	
Return
