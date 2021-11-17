#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBRFAT043  บAutor  ณ Marcos C. D. Vieiraบ Data ณ  02/10/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gerar arquivo txt para GNRE's com Inscricao Estadual       บฑฑ
ฑฑบ          ณ Substituto Tributario.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TECNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRFAT043()
     Private cPerg

     cPerg   := "BRFT43"

     VldPerg()            // Verifica as perguntas selecionadas
     Pergunte(cPerg, .F.) // Pergunta no SX1

     @ 96,042 TO 323,505 DIALOG oDlg1 TITLE "Gerar Arquivo TXT para GNRE's"
     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte("BRFT43")
     @ 91,168 BMPBUTTON TYPE 1 ACTION ExecBlock("FAT043_1", .f., .f.) 
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 23,016 SAY "Este programa tem como objetivo gerar um arquivo do tipo .TXT  "
     @ 33,016 SAY "dos registros gerados com Inscricao Estadual Subst.Tributario  "
     @ 43,016 SAY "O arquivo sera gerado no diretorio AP5\SIGAADV o seu nome sera "
     @ 53,016 SAY "composto da seguinte maneira: CIST+dia+mes da data atual.TXT.  "
     @ 08,10 TO 84,222
     ACTIVATE DIALOG oDlg1
Return

/*******************************************************************************/
/*** VldPerg  - Atualiza็ใo do arquivo de perguntas SX1                      ***/
/*** Autor: Marcos C. D. Vieira                                              ***/
/*** Data : 02/10/01                                                         ***/
/*******************************************************************************/
Static Function VldPerg()  
       Local _sAlias := Alias()
       Local aRegs   := {}
       Local i, j

       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aAdd(aRegs, {cPerg, "01", "Mes de competencia?" , "", "", "mv_ch1", "D", 08, 0, 0, "G", "naovazio", "mv_par01", ""	  , ""   ,""	  , "", "", ""	  , ""   , ""	  , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs, {cPerg, "02", "Gravar Arq. em    ?" , "", "", "mv_ch2", "C", 60, 0, 0, "G", ""        , "mv_par02", ""     , ""   ,""      , "", "", ""    , ""   , ""     , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

       For i := 1 to Len(aRegs)
           If !DbSeek(cPerg+aRegs[i][2])
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
/*** FAT043_1 - Chamada da rotina pela fun็ใo PROCESSA                       ***/
/*** Autor: Marcos C. D. Vieira                                              ***/
/*** Data : 02/10/01                                                         ***/
/*** Altera็๕es: 11/06/02 - Cleber Orati Domingues                           ***/
/*******************************************************************************/

User Function BRFAT044()  
     Local cQUERY   := ""
     Local cAuxMes
     Local cAuxUf, cNf, cSerie, hfile, cArq, cReceit, cInfo
     Local xAuxRef, nMulta, nJuros, cBLinha, nValPrinc, nAtuaMon, cIest, cConveni
     Local cAux     := Space(20) 
     Local nArea1   := Alias()
     Local nRecno1  := Recno()
     Local nIndex1  := IndexOrd()
     Local nRecno   := 1   
     Local cMesComp := SubStr(dTos(mv_par01), 5, 2)+SubStr(dTos(mv_par01), 1, 4)

     cQuery += "SELECT * "
     cQuery += " FROM "+RetSqlName("SZ0")+" SZ0 "
     cQuery += " WHERE SZ0.Z0_FILIAL = '"+xFilial("SZ0")+"' AND "
     cQuery += " SZ0.Z0_EMISSAO = '"+cMesComp+"' AND "
     cQuery += " SZ0.D_E_L_E_T_ <> '*' "
     cQuery += " ORDER BY SZ0.Z0_UF, SZ0.Z0_NF, SZ0.Z0_SERIENF "
     TCQUERY cQuery ALIAS "TMP" NEW
     DbSelectArea("TMP")
     DbGoTop()

     If Eof()
        DbSelectArea("TMP")
        DbCloseArea("TMP")
        MsgStop("Nใo hแ registros com estes parไmetros.")
        Return
     Endif   

     cAux  := SubStr(dToc(dDataBase), 1, 2)+SubStr(dToc(dDataBase), 4, 2)
     cArq  := Alltrim(mv_par02)+"\CIST"+cAux+".TXT"
     hFile := fCreate(cArq)
     TMP->(DbGoTop())
     While !Eof()
           cAuxUF    := TMP->Z0_UF
           nValPrinc := 0.00
           nAtuaMon  := 0.00
           nJuros    := 0.00
           nMulta    := 0.00
           nTotArec  := 0.00
           cSerie    := " "
           While !Eof() .AND. TMP->Z0_UF == cAuxUF
                 nValPrinc := nValPrinc + TMP->Z0_VLPRINC
                 nAtuaMon  := nAtuaMon  + TMP->Z0_ATUAMON
                 nJuros    := nJuros    + TMP->Z0_JUROS
                 nMulta    := nMulta    + TMP->Z0_MULTA
                 nTotArec  := nTotArec  + TMP->Z0_TOTAREC
                 cNF       := TMP->Z0_NF
                 cSERIE    := TMP->Z0_SERIENF
                 DbSelectArea("SZ0")
                 DbSetorder(1)
                 DbSeek(xFILIAL("SZ0")+TMP->Z0_NF+TMP->Z0_SERIENF)
                 If Found()
                    Reclock("SZ0", .F.)
                       SZ0->Z0_DTGERA  := dDATABASE   
                       SZ0->Z0_FLGGERA := "S"
                    MsUnLock()
                 EndIf
                 DbSelectArea("TMP")
                 DbSkip()
           Enddo
           If cAuxUf == SM0->M0_ESTCOB   // Nใo gera GNRE p/ o pr๓prio estado pois gera-se GARE
              DbSelectArea("TMP")
              Loop
           Endif
           //xAuxRef := "1"+SUBSTR(DTOC(dDATABASE),4,2)+"20"+SUBSTR(DTOC(dDATABASE),7,2)
           xAuxRef  := "1"+cMesComp
           cReceit  := "100048"
           cBLinha  := ""
           cBLinha  := cBLinha + AllTrim(cAuxUf)+CHR(9)
           cBLinha  := cBLinha + cReceit+CHR(9)
           cBLinha  := cBLinha + AllTrim(SM0->M0_CGC)+CHR(9)
           cBLinha  := cBLinha + "**********"+CHR(9)
           cBLinha  := cBLinha + xAuxRef+CHR(9)
           cBLinha  := cBLinha + Transform(nVALPRINC,"@E 999999999.99")+CHR(9)
           cBLinha  := cBLinha + Transform(nATUAMON,"@E 999999999.99")+CHR(9)
           cBLinha  := cBLinha + Transform(nJUROS,  "@E 999999999.99")+CHR(9)
           cBLinha  := cBLinha + Transform(nMULTA,  "@E 999999999.99")+CHR(9)
           cBLinha  := cBLinha + Transform(nTOTAREC,"@E 999999999.99")+CHR(9)
           cBLinha  := cBLinha + substr(dtos(dDATABASE),7,2)+"/"+substr(dtos(dDATABASE),5,2)+"/"+substr(dtos(dDATABASE),1,4)+CHR(9)
           cConveni := "CONVENIO ICMS 52/17 - TINTAS"
           cBLinha  := cBLinha + cConveni+CHR(9)
           cBLinha  := cBLinha + AllTrim(ALLTRIM(SM0->M0_NOMECOM))+CHR(9)
           cIest    := ""
           DbSelectArea("SZ8")
           DbSetOrder(1) //Z8_FILIAL+Z8_EST+Z8_TIPOCLI
           DbSeek(xFilial("SZ8")+cAuxUf, .t.)
           If Found()
              cIest := alltrim(SZ8->Z8_IEST)
           Endif
           cBLinha  := cBLinha + AllTrim(cIest)+CHR(9)
           cBLinha  := cBLinha + ALLTRIM(SM0->M0_ENDCOB)+CHR(9)
           cBLinha  := cBLinha + AllTrim(SM0->M0_CIDCOB)+CHR(9)
           cBLinha  := cBLinha + AllTrim(SM0->M0_ESTCOB)+CHR(9)
           cBLinha  := cBLinha + SubStr(SM0->M0_CEPCOB,1,5)+"-"+SubStr(SM0->M0_CEPCOB,6,3)+CHR(9)
           cBLinha  := cBLinha + AllTrim(SM0->M0_TEL)+CHR(9)
           cInfo    := "TINTAS, VERNIZES E OUTRAS MERCADORIAS DA INDUSTRIA QUIMICA"
           cBLinha  := cBLinha + AllTrim(cInfo)+CHR(9)
           cBLinha  := cBLinha + "3"
           cBLinha  := cBLinha + CHR(13)+CHR(10)
           FWrite(hFile,cBLInha,len(cBLinha))

           cAuxMes  := SubStr(cMesComp, 1, 2)+SubStr(cMesComp, 5, 2)
           DbSelectArea("SZ9")
           DbSetOrder(1)
           DbSeek(xFILIAL("SZ9")+cAuxUf+cAuxMes)
           If !Found()
              Reclock("SZ9", .T.)
           Else
              Reclock("SZ9", .F.)
           EndIf
           SZ9->Z9_FILIAL  := xFilial("SZ9")
           SZ9->Z9_NF      := cAuxUf+cAuxMes
           SZ9->Z9_SERIENF := cSerie
           SZ9->Z9_UF      := cAuxUf
           SZ9->Z9_RECEIT  := cReceit
           SZ9->Z9_CNPJCPF := SM0->M0_CGC
           SZ9->Z9_REF     := xAuxRef
           SZ9->Z9_VLPRINC := nVALPRINC
           SZ9->Z9_ATUAMON := nATUAMON
           SZ9->Z9_JUROS   := nJUROS
           SZ9->Z9_MULTA   := nMULTA
           SZ9->Z9_TOTAREC := nTOTAREC
           SZ9->Z9_DTVENC  := dDATABASE
           SZ9->Z9_CONVENI := cConveni
           SZ9->Z9_RAZSOC  := SM0->M0_NOMECOM
           SZ9->Z9_IEST    := cIest
           SZ9->Z9_END     := alltrim(SM0->M0_ENDCOB)
           SZ9->Z9_MUNICIP := AllTrim(SM0->M0_CIDCOB)
           SZ9->Z9_EST     := AllTrim(SM0->M0_ESTCOB)
           SZ9->Z9_CEP     := SM0->M0_CEPCOB
           SZ9->Z9_TEL     := AllTrim(SM0->M0_TEL)
           SZ9->Z9_INFO    := cInfo
           SZ9->Z9_EMISSAO := cMesComp
           SZ9->Z9_DTGERA  := dDATABASE
           SZ9->Z9_FLGGERA := "S"
           MsUnLock()
           DbSelectArea("TMP")
     Enddo
     fClose(hFile)
     MsgBox("Nome do arquivo gerado "+cArq+CHR(13)+CHR(10)+"Esta localizado na pasta AP5\SIGAADV"+CHR(13)+CHR(10), "Aten็ใo...", "INFO")

     DbSelectArea("TMP")
     DbCloseArea("TMP")

     DbSelectArea(nArea1)
     DbSetOrder(nIndex1)
     DbGoto(nRecno1)
Return