#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP025 ºAutor  ³ Fernando Roquete   º Data ³  23/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Custo x Produto                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros

mv_par01  -  Produto De ?
mv_par02  -  Produto Ate ?
mv_par03  -  Tipo De ?
mv_par04  -  Tipo Ate ?
mv_par05  -  Lista itens Zerados/Negativos ?(1 - Sim # 2 - Não)
mv_par06  -  Quantidade de PI maio que ?
mv_par07  -  Tipo de Saldo (1 - Atual # 2 - Ult. Fechamento)
*/
User Function BRPCP025()     
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Define Variaveis Ambientais                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

     Private cPerg,mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06
     CbTxt    := ""
     CbCont   := 0
     nOrdem   := 0
     Alfa     := 0
     Z        := 0
     M        := 0
     tamanho  := "M"
     limite   := 200
     titulo   := "RELACAO DE CUSTO/PRODUTO "
     cDesc1   := PADC("Este programa ira emitir o Rel. Custo do Produto",74)
     cDesc2   := ""
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Rel. Custo/Produto",27)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRPCP025"
     cPerg    := "BRPC25"
     nLastKey := 0
     lContinua:= .T.
     _nLin    := 90
     nCol     := 60
     wnrel    := "BRPCP025"
     nTipo    := 18
     m_pag    := 01
     //          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
     cCabec1  :=" COD.PRODUTO        DESCRICAO                               TIPO  UN  ALMOX           QTD       CUSTO UNIT         CUSTO TOTAL"
     //cCabec1  :=""
     cCabec2  :=""   
     cCabec3  :=""

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Tamanho do Formulario  (em Linhas)                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     nTamNf   :=83     // Apenas Informativo

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica as perguntas selecionadas, busca o padrao                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     cString  :="SB1"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     //ValidPerg()  //LGS#20200204 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg,.F.)   

     wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,,Tamanho)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     #IFDEF WINDOWS
            RptStatus({|| RptDetail()})
            Return
            Static Function RptDetail()
     #ENDIF

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     cQuery := "SELECT * FROM "+RetSqlName("SB1")+" A" 
     cQuery := cQuery + " WHERE A.B1_FILIAL = '"+xFilial("SB1")+"'"
     cQuery := cQuery + " AND A.B1_COD  BETWEEN '"+Mv_Par01+"' AND '"+Mv_Par02+"'"
     cQuery := cQuery + " AND A.B1_TIPO BETWEEN '"+Mv_Par03+"' AND '"+Mv_Par04+"'"
     cQuery := cQuery + " AND A.B1_UM   BETWEEN '"+Mv_Par08+"' AND '"+Mv_Par09+"'"
     cQuery := cQuery + " AND (A.D_E_L_E_T_ <> '*')"
     cQuery := cQuery + " ORDER BY A.B1_FILIAL,A.B1_COD "

     TCQuery cQuery NEW ALIAS "TCQ" 

     _TotQtd := 0.00
     _TotCus := 0.00
     _nMVICMPAD := GETMV("MV_ICMPAD")
     _dMVULMES  := GETMV("MV_ULMES")
     //  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
     //  _nLin:= 10 
  
     dbselectarea("SZ1")   
     dbsetorder(1)

     dbSelectArea("TCQ")
     dbgotop()

     SetRegua(Reccount())
     While !EoF()      
           If mv_par07 == 1 // Saldo Atual
              cQry1 := ""
              If TCQ->B1_TIPO $ 'MP'
                 cQry1 += "SELECT SB2.B2_FILIAL, SB2.B2_COD, SUM(SB2.B2_QATU) AS B2_QATU "
                 cQry1 += "FROM SB2"+cEmpAnt+"0 SB2 "
                 cQry1 += "WHERE SB2.B2_FILIAL  = '"+xFilial("SB2")+"' "
                 cQry1 += "  AND SB2.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SB2.B2_COD     = '"+TCQ->B1_COD+"' "
                 cQry1 += "GROUP BY SB2.B2_FILIAL, SB2.B2_COD "
              Else
                 cQry1 += "SELECT SB2.B2_FILIAL, SB2.B2_COD, SUM(SB2.B2_QATU) AS B2_QATU "
                 cQry1 += "FROM SB2"+cEmpAnt+"0 SB2 "
                 cQry1 += "WHERE SB2.B2_FILIAL  = '"+xFilial("SB2")+"' "
                 cQry1 += "  AND SB2.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SB2.B2_COD     = '"+TCQ->B1_COD+"' "
                 cQry1 += "  AND SB2.B2_LOCAL   IN('03','02') "
                 cQry1 += "GROUP BY SB2.B2_FILIAL, SB2.B2_COD "
              Endif
              TCQuery cQry1 ALIAS "TMP" NEW
              
              //dbSelectArea("SB2")
              //dbSetorder(1)
              //dbSeek(xFilial("SB2")+TCQ->B1_COD,.F.)
              DbSelectArea("TMP")
              DbGoTop()
              While !EoF() .And. TMP->B2_FILIAL == xFilial("SB2") .And. TMP->B2_COD == TCQ->B1_COD
                    If _nlin >= 60
                       Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                       _nLin:= 08 
                    Endif

                    If (((mv_par05 == 2) .and. (TMP->B2_QATU > 0)) .or. (mv_par05 # 2))
                       nCusto = TCQ->B1_UPRC
                       If TCQ->B1_TIPO == "PI" .OR. (TCQ->B1_TIPO == "PA")
                          nLucro := Iif(TCQ->B1_ESTOQUE == "S", TCQ->B1_LUCRO, TCQ->B1_LUCRO2)
                          DbSelectarea("SZ1")
                          DbSeek(xFilial("SZ1")+SubStr(TCQ->B1_COD,4,2))
                          If Found()
                             nComissao := SZ1->Z1_COMISSA
                          Else
                             nComissao := TCQ->B1_COMIS
                          Endif
                          //LGS#20200206 - Adequação de release 12.1.25 e posteriores
                          //nPercInc = TCQ->B1_PERINT+nLucro+nComissao+GETMV("MV_ICMPAD") // Somar 18% ICMS
                          nPercInc = TCQ->B1_PERINT + nLucro + nComissao + _nMVICMPAD // Somar 18% ICMS
                          nCusto := TCQ->B1_CUSTOR/(1-(nPercInc/100)) 
                          If TCQ->B1_TIPO == "PI"
                             nCusto := nCusto*0.56  // 56% do preço de venda do PI
                          Else
                             nCusto := nCusto*0.7 // 70% do preço de venda à vista do PA
                          Endif
                       Endif

                       nTotal := Round(TMP->B2_QATU*nCusto,2)
                       If ((TCQ->B1_TIPO == "PI") .and. (TMP->B2_QATU > mv_par06)) .or. (TCQ->B1_TIPO # "PI")
                          @ _nlin,001 PSAY TCQ->B1_COD     Picture "@R XXX99.99.999-99"
                          @ _nlin,020 PSAY TCQ->B1_DESC    Picture "@!"
                          @ _nlin,060 PSAY TCQ->B1_TIPO    Picture "@!"
                          @ _nlin,065 PSAY TCQ->B1_UM      Picture "@!"
                          @ _nlin,070 PSAY TCQ->B1_LOCPAD  Picture "99"
                          @ _nlin,075 PSAY TMP->B2_QATU    Picture "@E 999,999,999.99"  
                          @ _nlin,090 PSAY nCusto          Picture "@E 999,999,999.9999"
                          @ _nlin,110 PSAY nTotal          Picture "@E 999,999,999.9999"

                          _TotQtd := _TotQtd+TMP->B2_QATU
                          _TotCus := _TotCus+Round(TMP->B2_QATU*nCusto,2)
                          _nlin++  
                       Endif
                    Endif                                        
                    DbSelectArea("TMP")
                    DbSkip()
              EndDo       
              DbSelectArea("TMP")
              DbCloseArea()
           Else //Saldo do fechamento.
              cQry1 := ""
              If TCQ->B1_TIPO $ 'MP'
                 cQry1 += "SELECT SB9.B9_FILIAL, SB9.B9_COD, SUM(SB9.B9_QINI) AS B9_QINI, SUM(SB9.B9_VINI1) AS B9_VINI1 "
                 cQry1 += "FROM "+RetSqlName("SB9")+" SB9 "
                 cQry1 += "WHERE SB9.B9_FILIAL  = '"+xFilial("SB9")+"' "
                 cQry1 += "  AND SB9.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SB9.B9_COD     = '"+TCQ->B1_COD+"' "
                 //LGS#20200206 - Adequação de release 12.1.25 e posteriores
                 //cQry1 += "  AND SB9.B9_DATA    = '"+DTOS(GETMV("MV_ULMES"))+"' "
                 cQry1 += "  AND SB9.B9_DATA    = '" + DTOS( _dMVULMES ) + "' "
                 cQry1 += "GROUP BY SB9.B9_FILIAL, SB9.B9_COD "
              Else
                 cQry1 += "SELECT SB9.B9_FILIAL, SB9.B9_COD, SUM(SB9.B9_QINI) AS B9_QINI, SUM(SB9.B9_VINI1) AS B9_VINI1 "
                 cQry1 += "FROM "+RetSqlName("SB9")+" SB9 "
                 cQry1 += "WHERE SB9.B9_FILIAL  = '"+xFilial("SB9")+"' "
                 cQry1 += "  AND SB9.D_E_L_E_T_ = '' "
                 cQry1 += "  AND SB9.B9_COD     = '"+TCQ->B1_COD+"' "
                 cQry1 += "  AND SB9.B9_LOCAL   IN('03', '02') "
                 //LGS#20200206 - Adequação de release 12.1.25 e posteriores
                 //cQry1 += "  AND SB9.B9_DATA    = '"+DTOS(GETMV("MV_ULMES"))+"' "
                 cQry1 += "  AND SB9.B9_DATA    = '" + DTOS( _dMVULMES ) + "' "
                 cQry1 += "GROUP BY SB9.B9_FILIAL, SB9.B9_COD "
              Endif
              TCQuery cQry1 ALIAS "TMP" NEW
              //DbSelectArea("SB9")
              //DbSetOrder(1)
              //DbSeek(xFilial("SB9")+TCQ->B1_COD,.F.)
              DbSelectArea("TMP")
              DbGoTop()
              While !EoF() .And. TMP->B9_FILIAL == xFilial("SB9") .And. TMP->B9_COD == TCQ->B1_COD
                    //If DTOS(GETMV("MV_ULMES")) > DTOS(SB9->B9_DATA)
                    //   DbSkip()
                    //   Loop
                    //Endif
                    If _nlin >= 60
                       Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                       _nLin:= 08 
                    Endif
                    If (((mv_par05 == 2) .and. (TMP->B9_QINI > 0)) .or. (mv_par05 # 2))
                       nCusto = (TMP->B9_VINI1 / TMP->B9_QINI)
                       If TCQ->B1_TIPO == "PI" .OR. (TCQ->B1_TIPO == "PA")
                          nLucro := iif(TCQ->B1_ESTOQUE == "S", TCQ->B1_LUCRO, TCQ->B1_LUCRO2)
                          DbSelectArea("SZ1")
                          DbSeek(xFilial("SZ1")+substr(TCQ->B1_COD,4,2))
                          If Found()
                             nComissao := SZ1->Z1_COMISSA
                          Else
                             nComissao := TCQ->B1_COMIS
                          Endif
                          //LGS#20200206 - Adequação de release 12.1.25 e posteriores
                          //nPercInc = TCQ->B1_PERINT+nLucro+nComissao+GETMV("MV_ICMPAD") // Somar 18% ICMS
                          nPercInc = TCQ->B1_PERINT + nLucro + nComissao + _nMVICMPAD // Somar 18% ICMS
                          nCusto := TCQ->B1_CUSTOR/(1-(nPercInc/100)) 
                          If TCQ->B1_TIPO == "PI"
                             nCusto := nCusto*0.56  // 56% do preço de venda do PI
                          Else
                             nCusto := nCusto*0.7 // 70% do preço de venda à vista do PA
                          Endif
                       Endif

                       nTotal := Round(TMP->B9_QINI*nCusto,2)
                       If ((TCQ->B1_TIPO == "PI") .and. (TMP->B9_QINI > mv_par06)) .or. (TCQ->B1_TIPO # "PI")
                          @ _nlin,001 PSAY TCQ->B1_COD     Picture "@R XXX99.99.999-99"
                          @ _nlin,020 PSAY TCQ->B1_DESC    Picture "@!"
                          @ _nlin,060 PSAY TCQ->B1_TIPO    Picture "@!"
                          @ _nlin,065 PSAY TCQ->B1_UM      Picture "@!"
                          @ _nlin,070 PSAY TCQ->B1_LOCPAD  Picture "99"
                          @ _nlin,075 PSAY TMP->B9_QINI    Picture "@E 999,999,999.99"  
                          @ _nlin,090 PSAY nCusto          Picture "@E 999,999,999.9999"
                          @ _nlin,110 PSAY nTotal          Picture "@E 999,999,999.9999"

                          _TotQtd := _TotQtd+TMP->B9_QINI
                          _TotCus := _TotCus+Round(TMP->B9_QINI*nCusto,2)
                          _nlin++  
                       Endif
                    Endif                                        
                    dbSelectArea("TMP")
                    dbSkip()
              EndDo
              dbSelectArea("TMP")
              DbCloseArea()
           Endif
           DbSelectArea("TCQ")              
           DbSkip()
     Enddo
  
     If (_TotQtd # 0.00) .Or. (_TotCus # 0.00)
        @ _nlin,001 PSAY "TOTAL"
        @ _nlin,075 PSAY _TotQtd Picture "@E 999,999,999.99"
        @ _nlin,110 PSAY _TotCus Picture "@E 999,999,999.9999"
     Endif 
     Roda(cbcont,cbtxt,tamanho)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³                      FIM DA IMPRESSAO                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     DbSelectArea("TCQ")
     DbCloseArea()

     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        dbcommitAll()
        ourspool(wnrel)
     Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICA                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Programa: VALIDPERG   Autor:  Fernando Roquete     
Data:     05/06/01
Descricao:Grava Perguntas
/*/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs:={}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Cod.Produto    De  ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       AADD(aRegs,{cPerg,"02","Cod.Produto    Ate ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       AADD(aRegs,{cPerg,"03","Tipo Produto   De  ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       AADD(aRegs,{cPerg,"04","Tipo Produto   Ate ?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       AADD(aRegs,{cPerg,"05","Lista Zerados/Negat?","","","mv_ch5","C",03,0,0,"C","","mv_par05","SIM","","","","","NAO","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"06","Qtd PI maior que   ?","","","mv_ch6","N",06,2,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"07","Tipo de Saldo      ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Atual","","","","","Ult. Fechamento","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"08","Da unidade         ?","","","mv_ch1","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SAH",""})
       AADD(aRegs,{cPerg,"09","Ate unidade        ?","","","mv_ch2","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SAH",""})

       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next

       dbSelectArea(_sAlias)
Return */

/*Static Function fgets(nArq,nTamArq)
       Local nCont,cRet,nLidos
       cRet = ""
       nCont = 0
       cComp = ""  
       cCharAnt = ""       
       cChar = ""  
       nLidos = 0
       While (cComp != (chr(13)+chr(10))) .and. (cChar != chr(1))
             cCharAnt = cChar
             fread(nArq,@cChar,1)
             cRet += cChar
             cComp = cCharAnt+cChar
             nLidos++	 
       Enddo

Return(cRet)  */

/*Static Function cton(cValor)
       Local nValor,i,nPos,nVal1,nVal2,cAux
       For i = 1 to Len(cValor)
           nPos = i
           If SubStr(cValor,i,1) $ ",."
              Exit
           Endif
       Next
       nVal1 = 0
       nVal2 = 0
       If nPos < Len(cValor)
          nVal1 = Val(SubStr(cValor,1,nPos - 1))
          cAux = "1"
          For i = 1 to (Len(cValor) - nPos)
              cAux += "0"
          Next
          nVal2 = Val(SubStr(cValor,nPos + 1,Len(cValor) - nPos))/Val(cAux)
       Else
          nVal1 = val(cValor)
       Endif

       nValor = nVal1+nVal2

Return(nValor)*/