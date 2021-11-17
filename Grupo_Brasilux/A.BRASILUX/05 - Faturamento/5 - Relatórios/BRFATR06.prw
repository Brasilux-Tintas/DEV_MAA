#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR06 º Autor ³ Luís G. de Souza   º Data ³  09/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Bordero de despacho x Volume.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR06()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Relação de despacho x Volume"
     //Local cPict         := ""
     Local titulo        := "Relação de despacho x Volume"
     Local nLin          := 80
     Local Cabec1        := "EMBALAGEM          QTDE           VOLUMES"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR06" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "FATR06"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR06" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SZA"
     
     if !u_VldAcesso(funname())
      	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	return 
     endif 

     DbSelectArea("SZA")
     DbSetOrder(1)

     //VldPerg()
     Pergunte(cPerg, .F.)

     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     Processa({|| FATR06_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR06_1 º Autor ³ Luís G. de Souza   º Data ³  09/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA. A funcao FATR06_1   º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR06_1(Cabec1,Cabec2,Titulo,nLin)
       Local cQry1 := ""
       Local cQry2 := ""
       Local nQtdRec :=0
       Local cRetVol :=""
       Local nRetVol :=0
       Local nY


       cQry1 := "" ; cQry2 := ""
       cQry1 += "SELECT SZB.ZB_CODIGO AS CODIGO, SUBSTRING(SZB.ZB_PEDIDO,3, 6) AS PEDIDO, SF2.F2_DOC AS NFISCAL, SC5.C5_CLIENTE AS CLIENTE, SC5.C5_LOJACLI AS LOJA "
       cQry2 += "SELECT COUNT(*) AS QTDREC "
       cQry1 += "FROM "+RetSqlName("SZA")+" SZA "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB ON SZA.ZA_FILIAL = SZB.ZB_FILIAL AND SZA.ZA_CODIGO = SZB.ZB_CODIGO AND SZB.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 ON SZB.ZB_FILIAL = SF2.F2_FILIAL AND SUBSTRING(SZB.ZB_PEDIDO, 3, 6) = SF2.F2_PEDIDO AND SF2.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON SZB.ZB_FILIAL = SC5.C5_FILIAL AND SUBSTRING(SZB.ZB_PEDIDO, 3, 6) = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
       cQry1 += "  AND SZA.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZA.ZA_CODIGO  = '"+mv_par01+"' "
       cQry2 += cQry1
       cQry1 += "ORDER BY SZB.ZB_CODIGO, 3 "
       TCQuery cQry1 ALIAS "TCQ" NEW
       TCQuery cQry2 ALIAS "QTD" NEW
       DbSelectArea("QTD")
       nQtdRec := QTD->QTDREC
       DbSelectArea("QTD")
       DbCloseArea()
       
       DbSelectArea("TCQ")

       ProcRegua(nQtdRec)

       DbGoTop()
       While !EOF()
             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin += 1
             Endif
             IncProc('Processando pedido: '+TCQ->PEDIDO)

			 //Cleber (18/10/10) -> Verificar se rel. de volumes estão coerentes antes     
			 //U_VerificaVolumes(TCQ->PEDIDO) //Cleber(27/08/2015) -> retirado

             //0         1         2         3         4         5         6         7         8
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789
             //PEDIDO: 999999 N. FISCAL: 999999999 - CLIENTE: 999999-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
             @ nLin, 000 PSAY "PEDIDO: "+TCQ->PEDIDO+" N. FISCAL: "+TCQ->NFISCAL+" - CLIENTE: "+TCQ->CLIENTE+"-"+SubStr(Posicione("SA1", 1, xFilial("SA1")+TCQ->CLIENTE+TCQ->LOJA, "A1_NOME"), 1, 25)+""
               nLin += 1 // Avanca a linha de impressao
             @ nLin, 000 PSAY Replicate("-", 79)
               nLin += 1
             cRetVol := ""
             cRetVol := fDetVol()
             
             nRetVol := MlCount(Alltrim(cRetVol))
             For nY := 1 To nRetVol
                 cLinVol := MEMOLINE(cRetVol, 79, nY)
                 @ nLin, 000 PSAY cLinVol
                 nLin += 1
                 If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                    nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    nLin += 1
                 Endif
             Next
             @ nLin, 000 PSAY Replicate("=", 79)
             nLin += 2
             DbSelectArea("TCQ")
             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       SET DEVICE TO SCREEN

       If aReturn[5]==1
          DbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

Return

/******************************************************************************************************************/
/*** VLDPERG  - Gera perguntas para paramentros do relatório.                                                   ***/
/******************************************************************************************************************/
/* DESABILITADO RELEASE 12.1.25
Static Function VldPerg()
       PutSX1("FATR06    ", "01",   "Bordero", "", "", "mv_ch1", "C", 6, 0, 0, "G", " ", "", " ", " ", "mv_par01", "Sim", " ", " "     , " "   , "Não"           , " "     , " "     , "Ambos"       , " "     , " "     , " "    , " "     , " "     , " "          ,  " "     ,  " "     , Nil  , Nil     , Nil     , "FATR06" )
Return
*/
Static Function fDetVol()
       Local cUniMed := ""
       //Local lTemEmb := .f.
       //Local cCodCom := ""
       //Local nQtdCom := 0.0
       //Local lAchouE := .f.
       //Local cDesEmb := ""
       //Local nVarEmb := 0.0
       //Local nRelVol := 0
       //Local nQtdVol := 0
       //Local nAuxEmb := 0
       Local nAuxTam := 0
       Local cAuxMen := ""
       //Local cRetVol := ""
       Local nColuna := 45
       Local cMenEmb := ""
       DbSelectArea("ZZO")
       DbSetOrder(1)


       DbSeek(xFilial("ZZO")+TCQ->PEDIDO, .F.)
       If FOUND()
          nAuxTam := Len(cMenEmb) % nColuna //Resto
          If nAuxTam > 0
             cMenEmb := Space(nColuna - nAuxTam) + cMenEmb
          Endif
          //                      999,999	        999,999
          //         0         1         2         3         4         5
          //          12345678901234567890123456789012345678901234567890123456789
          //cMenEmb := "EMBALAGEM          QTDE           VOLUMES"
          //cMenEmb := cMenEmb + Space(nColuna - Len(cMenEmb))+chr(13)+chr(10)
       Endif

       While !Eof() .and. (xFilial("ZZO") == ZZO->ZZO_FILIAL) .and. (ZZO->ZZO_PEDIDO == TCQ->PEDIDO)
       		cUniMed := "Diversos"
       		DbSelectArea("SZ5")
         	DbSeek(xFilial("SZ5")+ZZO->ZZO_EMBA, .t.)
          	If Found()
           		cUniMed := Alltrim(SZ5->Z5_DESCR)
			Endif
           cAuxMen := SubStr(cUniMed, 1, 16)
           cAuxMen := cAuxMen + Space(16 - Len(cAuxMen))
           cAuxMen += Transform(ZZO->ZZO_QTDE, "999,999")
           cAuxMen := cAuxMen+Space(34 - Len(cAuxMen))
           cAuxMen += Transform(ZZO->ZZO_QTDVOL, "999,999")
           cAuxMen += Space(nColuna - Len(cAuxMen))
           cMenEmb += cAuxMen+chr(13)+chr(10)   
           dbselectarea("ZZO")
           dbskip()
       enddo 
Return(cMenEmb)