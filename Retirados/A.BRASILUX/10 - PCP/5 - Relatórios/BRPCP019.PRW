#IFNDEF WINDOWS
        #DEFINE PSAY SAY
#ENDIF
#include "rwmake.ch"        
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP019 ºAutor  ³ Fernando Roquete   º Data ³  23/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relação de Custo                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
- Variaveis utilizadas para parametros

mv_par01  -  Produto De
mv_par02  -  Produto Ate
mv_par03  -  Tipo De
mv_par04  -  Tipo Ate
mv_par05  -  Lista Zerados/Negativos (1 - Sim # 2 - Não)
*/
User Function BRPCP019()     
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Define Variaveis Ambientais                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

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
     nomeprog := "BRPCP019"
     cPerg    := "BRPC19"
     nLastKey := 0
     lContinua:= .T.
     _nLin    := 90
     nCol     := 60
     wnrel    := "BRPCP019"
     nTipo    := 18
     m_pag    := 01
     //          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
     cCabec1  := " COD.PRODUTO        DESCRICAO                               TIPO  UN  ALMOX           QTD       CUSTO UNIT         CUSTO TOTAL"
     //cCabec1  := ""
     cCabec2  := ""   
     cCabec3  := ""
     
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
     Pergunte("BRPC19",.F.)   

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
     Local cQualLucro
     Local _nValMO    := 0                  //LGS#20200206 - Adequação de release 12.1.25 e posteriores
     Local _nValCO    := 0                  //LGS#20200206 - Adequação de release 12.1.25 e posteriores
     Local _nValLU    := 0                  //LGS#20200206 - Adequação de release 12.1.25 e posteriores
     Local _nMVICMPAD := GETMV("MV_ICMPAD") //LGS#20200207 - Adequação de release 12.1.25 e posteriores
     
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicializa  regua de impressao                            ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     cQuery := "SELECT * FROM "+RetSqlName("SB1")+" A WITH (NOLOCK)" 
     cQuery := cQuery + " WHERE A.B1_FILIAL = '"+xFilial("SB1")+"'"
     cQuery := cQuery + " AND A.B1_COD  BETWEEN '"+Mv_Par01+"' AND '"+Mv_Par02+"'"
     cQuery := cQuery + " AND A.B1_TIPO BETWEEN '"+Mv_Par03+"' AND '"+Mv_Par04+"'"   
     cQuery := cQuery + " AND (A.D_E_L_E_T_ <> '*')"
     cQuery := cQuery + " ORDER BY A.B1_FILIAL,A.B1_COD "

     TCQuery cQuery NEW ALIAS "TCQ" 

     _TotQtd :=0.00
     _TotCus :=0.00
    
     //  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
     //  _nLin:= 10 

	
     dbSelectArea("SB1")
     dbsetorder(1)
  
     dbSelectArea("TCQ")
     dbgotop()
  
     SetRegua(Reccount())
     While ! EoF()
           cQry1 := ""
           cQry1 += "SELECT SB2.B2_FILIAL, SB2.B2_COD, SUM(SB2.B2_QATU) AS B2_QATU "
           cQry1 += "FROM SB2"+cEmpAnt+"0 SB2 "
           cQry1 += "WHERE SB2.B2_FILIAL  = '"+xFilial("SB2")+"' "
           cQry1 += "  AND SB2.D_E_L_E_T_ = '' "
           cQry1 += "  AND SB2.B2_COD     = '"+TCQ->B1_COD+"' "
           cQry1 += "GROUP BY SB2.B2_FILIAL, SB2.B2_COD "
           TCQuery cQry1 ALIAS "TMP" NEW
           
           //DbSelectArea("SB2")
           //DbSetorder(1)
           //DbSeek(xFilial("SB2")+TCQ->B1_COD,.F.)
           DbSelectArea("TMP")
           DbGoTop()
           While !EoF() .And. TMP->B2_FILIAL == xFilial("SB2") .And. TMP->B2_COD == TCQ->B1_COD
                 If _nlin >= 60
                    Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
                    _nLin:= 08 
                 Endif
                 If ((mv_par05 == 2) .and. (TMP->B2_QATU > 0)) .or. (mv_par05 # 2)
                    @ _nlin,001 PSAY TCQ->B1_COD    Picture "@R XXX99.99.999-99"
                    @ _nlin,020 PSAY TCQ->B1_DESC   Picture "@!"
                    @ _nlin,060 PSAY TCQ->B1_TIPO   
                    @ _nlin,065 PSAY TCQ->B1_UM     
                    @ _nlin,070 PSAY TCQ->B1_LOCPAD 
                    @ _nlin,075 PSAY TMP->B2_QATU   Picture "@E 999,999,999.99"  
                    //nCusto = SB2->B2_CM1  -- Alterado para Ultimo preço em 02/10/03 - Rui solicitou.
                    nCusto := TCQ->B1_UPRC
                    If TCQ->B1_TIPO == "PI" .OR. (TCQ->B1_TIPO == "PA")
                       dbselectarea("SB1")
                       dbseek(xFilial("SB1")+TCQ->B1_COD)
                       if found()
                          // Calcular Preço de Venda, Tirando Percentuais, exceto GGF
                          cPlanilha = "BRASILUX.PDV"
                          Do Case
                             Case cnumemp == "01010101"
                                  cPlanilha = "BRASILUX.PDV"
                             Case cnumemp == "01010104"
                                  cPlanilha = "RESINA.PDV"		
                             Case cnumemp == "03010101"
                                  cPlanilha = "BRASITEC.PDV"
                             Case cnumemp == "01060101"
                                  cPlanilha = "DISSOLTE.PDV"
                             Case cnumemp == "0501"
                                  cPlanilha = "UNIONSUR.PDV"
                          EndCase
                          cQualLucro := iif(TCQ->B1_ESTOQUE == "S","LU","L2")
                          nPercInc = 0

                          nArq = fopen(cPlanilha)
                          nLidos = 0
                          If nArq > 0 
                             FSEEK(nArq,0,0)
                             nTamArq:=FSEEK(nArq,0,2)
                             FSEEK(nArq,0,0)
                             While nLidos < nTamArq
                                   cLinha = fgets(nArq,nTamArq)
                                   If substr(cLinha,5,13) == "GASTOS GERAIS"
                                      nPercInc = cton(alltrim(substr(cLinha,35,10)))
                                   Endif
                                   nLidos += len(cLinha)+2
                             End
                             fclose(nArq)
                          Endif
                          aArray = {}
                          aadd(aArray,{"","","",SB1->B1_COD})
                          //LGS#20200206 - Adequação de release 12.1.25 e posteriores
                          _nValMO := EXECBLOCK( "BRPCP011", .F., .F., "MO" )
                          _nValCO := EXECBLOCK( "BRPCP011", .F., .F., "CO" )
                          _nValLU := EXECBLOCK( "BRPCP011", .F., .F., cQualLucro )
                          //nCusto = SB1->B1_CUSTOR + EXECBLOCK("BRPCP011",.F.,.F.,"MO") + (SB1->B1_CUSTOR/(1 - (SB1->B1_PERINT/100) - (GETMV("MV_ICMPAD")/100) - EXECBLOCK("BRPCP011",.F.,.F.,cQualLucro) - EXECBLOCK("BRPCP011",.F.,.F.,"CO")))*(nPercInc/100)
                          nCusto = SB1->B1_CUSTOR + _nValMO + ( SB1->B1_CUSTOR / (1 - ( SB1->B1_PERINT / 100 ) - ( _nMVICMPAD / 100 ) - _nValLU - _nValCO ) ) * ( nPercInc / 100 )
                       Endif
                    Endif
                    @ _nlin,090 PSAY nCusto   Picture "@E 999,999,999.9999"
                    @ _nlin,110 PSAY Round(TMP->B2_QATU*nCusto,2) Picture "@E 999,999,999.9999"
      
                    _TotQtd := _TotQtd+TMP->B2_QATU
                    _TotCus := _TotCus+Round(TMP->B2_QATU*nCusto,2)
                    _nlin++  
                 Endif                                        
                 DbSelectArea("TMP")
                 DbSkip()
           Enddo
           DbSelectArea("TMP")
           DbCloseArea()
           DbSelectArea("TCQ")              
           Dbskip()
     EndDo

     If (_TotQtd # 0.00) .Or. (_TotCus # 0.00)
        @ _nlin,001 PSAY "TOTAL"
        @ _nlin,075 PSAY _TotQtd Picture "@E 999,999,999.99"
        @ _nlin,110 PSAY _TotCus Picture "@E 999,999,999.9999"
     Endif 
     //Roda(cbcont,cbtxt,tamanho)
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³                      FIM DA IMPRESSAO                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


     DbSelectArea("TCQ")
     DbCloseArea()
     DbSelectArea("SB1")
     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        dbcommitAll()
        ourspool(wnrel)
     Endif
Return

/*/
Programa: VALIDPERG   Autor:  Fernando Roquete     
Data:     05/06/01
Descricao:Grava Perguntas
/*/
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs:={}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Cod.Produto    De   ?", "", "", "mv_ch1", "C", 15, 0, 0, "G", "", "mv_par01", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       AADD(aRegs,{cPerg,"02","Cod.Produto    Ate  ?", "", "", "mv_ch2", "C", 15, 0, 0, "G", "", "mv_par02", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SB1", ""})
       AADD(aRegs,{cPerg,"03","Tipo Produto   De   ?", "", "", "mv_ch3", "C", 02, 0, 0, "G", "", "mv_par03", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , ""})
       AADD(aRegs,{cPerg,"04","Tipo Produto   Ate  ?", "", "", "mv_ch4", "C", 02, 0, 0, "G", "", "mv_par04", ""   , "", "", "", "", ""   , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "02" , ""})
       AADD(aRegs,{cPerg,"05","Lista Zerados/Negat ?", "", "", "mv_ch5", "C", 03, 0, 0, "C", "", "mv_par05", "SIM", "", "", "", "", "NAO", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})

       For i := 1 to Len(aRegs)
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
Return*/

Static Function fgets(nArq,nTamArq)
       Local nCont,cRet,nLidos
       cRet = ""
       nCont = 0
       cComp = ""  
       cCharAnt = ""       
       cChar = ""  
       nLidos = 0
       while (cComp != (chr(13)+chr(10))) .and. (cChar != chr(1))
             cCharAnt = cChar
             fread(nArq,@cChar,1)
             cRet += cChar
             cComp = cCharAnt+cChar
             nLidos++	 
       End
Return(cRet)  

Static Function cton(cValor)
       Local nValor,i,nPos,nVal1,nVal2,cAux
       For i = 1 to len(cValor)
           nPos = i
           If Substr(cValor,i,1) $ ",."
              exit
           Endif
       Next
       nVal1 = 0
       nVal2 = 0
       If nPos < len(cValor)
          nVal1 = val(substr(cValor,1,nPos - 1))
          cAux = "1"
          For i = 1 to (len(cValor) - nPos)
              cAux += "0"
          Next
          nVal2 = val(substr(cValor,nPos + 1,len(cValor) - nPos))/val(cAux)
       Else
          nVal1 = val(cValor)
       Endif
       nValor = nVal1+nVal2
Return(nValor)