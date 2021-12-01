#include "rwmake.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRESTX04 º Autor ³ Cleber Orati       º Data ³  27/07/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relação de Notas Fiscais com Frete CIF                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Empresas do Grupo BRASILUX                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR20()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de notas fiscais emitidas com frete CIF.            "
     Local cDesc3        := ""
     //Local cPict         := ""
     Local titulo        := "Notas Fiscais com Frete CIF  "
     Local nLin          := 80
     Local Cabec1        := "TRANSPORTADORA                        PEDIDO NRO NF    CLIENTE                                               VALOR NF VLR DO FRETE"
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := space(10)
     Private limite      := 132
     PRIVATE nTamNf   := 132     // Apenas Informativo
     Private tamanho     := "M"
     Private nomeprog    := "BRFATR20" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private _cPerg       := "BRFATR20"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR20" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SC5"
     Private MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08
     
     if !u_VldAcesso(funname())
      	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	return 
     endif 
     u_zcfga01( 'BRFATR20' ) //LGS#2021201 - Gravação de log de utilização da rotina
     dbSelectArea("SC5")
     dbSetOrder(1)
     //CriaSX1(_cPerg)
     Pergunte(_cPerg,.F.)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta a interface padrao com o usuario...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     wnrel := SetPrint(cString, NomeProg, _cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4]==1,15,18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     RptStatus({|| FATR20_1(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR20_1 º Autor ³ Luís G. de Souza   º Data ³  09/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR20_1(Cabec1,Cabec2,Titulo,nLin)
Local cQuery,nFreTransp,nTotalFrete,nTotalNf,nTotalPNf,nQtdePNf,nQtdeNf,cTransp,nVlrFrete,nPercFrete
dbSelectArea(cString)
dbSetOrder(1)

SetRegua(100)
       
       
cQuery := "SELECT C5_NUM AS PEDIDO,C5_CLIENTE AS CODCLI,A1_CODCID,A1_NOME AS RAZAO,C5_REDESP AS CODTRA,A4_NOME AS NOMETRA,"+;
"C5_SERIE AS SERIE,C5_NOTA AS NRONF,C5_PBRUTO,C5_EMISSAO,EMISNF = CASE WHEN F2_EMISSAO IS NOT NULL THEN F2_EMISSAO ELSE '' END,"+;
"A4_FREPERC,A4_FREPED,A4_FRETX,"+;
"VALORNF = CASE WHEN SF2.R_E_C_N_O_ IS NOT NULL THEN F2_VALBRUT ELSE 0 END "
if (SA4->(FieldPos("A4_ICMFRET")) > 0) 
	cQuery += ",A4_ICMFRET "
endif
cQuery += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON (SA4.D_E_L_E_T_ = '') AND (SA4.A4_FILIAL = '"+xFilial("SA4")+"') AND (A4_COD = C5_REDESP) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ = '') AND (SA1.A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = C5_CLIENTE) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ = '') AND (F2_FILIAL = C5_FILIAL) AND (F2_CLIENTE = C5_CLIENTE) AND (F2_SERIE = C5_SERIE) AND (F2_DOC = C5_NOTA) "+;
"WHERE (SC5.D_E_L_E_T_ = '') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_TPFRETE = 'C') AND (C5_XVLRFRE > 0.0) "+; 
"AND (C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') AND (C5_REDESP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
IF !empty(MV_PAR02) .and. (MV_PAR02 >= MV_PAR01)
	cQuery += "AND (F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "
ENDIF

IF !empty(MV_PAR07) .and. (MV_PAR08 >= MV_PAR07)
	cQuery += "AND (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"') "
ENDIF
cQuery += "ORDER BY CODTRA,EMISNF,C5_EMISSAO,RAZAO,CODCLI,PEDIDO"
TCQuery cQuery ALIAS "TCQ" NEW
nFreTransp := 0
nTotalFrete := 0
nTotalNf := 0
nTotalPNf := 0
nQtdePNf := 0
nQtdeNf := 0
cTransp := ""
dbselectarea("Z15")
dbsetorder(1) //Cod Transp+Cod Cidade    
dbselectarea("SA4")
dbsetorder(1)                                             
DbSelectArea("TCQ")
DbGoTop()
if !eof() .and. !bof()
	cTransp := alltrim(TCQ->CODTRA)
endif 
While !EOF()
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif


	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif

	if !(cTransp == alltrim(TCQ->CODTRA))
		@ nLin, 000 PSAY REPLICATE("-",132)
		nLin++
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		@ nLin,104 psay nTotalPNf Picture "@E 99,999,999.99"
		@ nLin,118 psay nFreTransp Picture "@E 99,999,999.99"
		@ nLin,000 psay "Qtde de Pedidos para a Transportadora: " 
		@ nLin,039 psay nQtdePNf Picture "@E 999,999"
		cTransp := alltrim(TCQ->CODTRA)
		nFreTransp := 0
		nTotalPNf := 0
		nQtdePNf := 0
		nLin++
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
	endif


	nVlrFrete := 0.0
	IF !EMPTY(ALLTRIM(TCQ->NRONF))
		dbselectarea("Z15")
		dbseek(xFilial("Z15")+TCQ->CODTRA+TCQ->A1_CODCID)
		if found()
			nPercFrete := Z15->Z15_ADVALO
			nVlrFrete += Z15->Z15_VLRFPE
     		IF TCQ->C5_PBRUTO > Z15->Z15_PESLIM
     			nVlrFrete += Z15->Z15_VLREXC*(TCQ->C5_PBRUTO - Z15->Z15_PESLIM)
     		ENDIF
    		nPercFrete += TCQ->A4_FREPERC 
     		nVlrFrete += TCQ->C5_PBRUTO*TCQ->A4_FREPED 
     		nVlrFrete += TCQ->A4_FRETX
     		nVlrFrete += (nPercFrete*TCQ->VALORNF/100.0)
     	endif
     	if (SA4->(FieldPos("A4_ICMFRET")) > 0) 
     		IF TCQ->A4_ICMFRET > 0.0
     			nVlrFrete := round(nVlrFrete/TCQ->A4_ICMFRET,2) // Indice de icms de frete. Por ex., se for agregar 7% então A4_ICMFRET será 0.93
     		ENDIF
     	endif
     ENDIF

	nFreTransp += nVlrFrete
	nTotalFrete += nVlrFrete
	nTotalNf += TCQ->VALORNF
	nTotalPNf += TCQ->VALORNF
	nQtdePNf ++
	nQtdeNf ++



	//   0         1         2        3          4           5         6         7         8         9        10        11        12        13
	//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
   //"TRANSPORTADORA                        PEDIDO NRO NF    CLIENTE                                               VALOR NF VLR DO FRETE      
	@ nLin,000 psay TCQ->CODTRA+"-"+substr(TCQ->NOMETRA,1,30)
	@ nLin,038 psay TCQ->PEDIDO
	@ nLin,045 psay ALLTRIM(TCQ->NRONF)+"-"+ALLTRIM(TCQ->SERIE)
	@ nLin,055 psay TCQ->CODCLI+'-'+SUBSTR(TCQ->RAZAO,1,40)
	@ nLin,104 psay TCQ->VALORNF Picture "@E 99,999,999.99"
	@ nLin,118 psay nVlrFrete Picture "@E 99,999,999.99"
	nLin++
	
	DbSelectArea("TCQ")
	dbskip()
	
EndDo
       DbSelectArea("TCQ")
       DbCloseArea()


		@ nLin, 000 PSAY REPLICATE("-",132)
		nLin++
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif
		@ nLin,104 psay nTotalNf Picture "@E 99,999,999.99"
		@ nLin,118 psay nTotalFrete Picture "@E 99,999,999.99"
		@ nLin,000 psay "Quantidade Total de Pedidos--------> " 
		@ nLin,037 psay nQtdePNf Picture "@E 9,999,999"

       
       SET DEVICE TO SCREEN

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()
Return

/*/
Programa  : CRIASX1   Autor:  
Data      : 10/10/18
Descricao : Grava Perguntas
/*/

/* DESABILITADO EM FUNÇÃO DA RELEASE 12.1.25
Static Function CriaSX1(_cPerg)

Local aHelp := {}

//            Texto do help em português                , inglês, espanhol
AAdd(aHelp, {{"Dt NF de"},  {"Dt NF de"}, {"Dt NF de"}})
AAdd(aHelp, {{"Dt NF ate"},  {"Dt NF ate"}, {"Dt NF ate"}})
AAdd(aHelp, {{"Transp. de"},  {"Transp. de"}, {"Transp. de"}})
AAdd(aHelp, {{"Transp. ate"},  {"Transp. ate"}, {"Transp. ate"}})
AAdd(aHelp, {{"Pedido de"},  {"Pedido de"}, {"Pedido de"}})
AAdd(aHelp, {{"Pedido ate"},  {"Pedido ate"}, {"Pedido ate"}})
AAdd(aHelp, {{"Dt Pedido de"},  {"Dt Pedido de"}, {"Dt Pedido de"}})
AAdd(aHelp, {{"Dt Pedido ate"},  {"Dt Pedido ate"}, {"Dt Pedido ate"}})
//xPutSX1(cPerg,"01",  "Dt NF de?"  ,"Dt NF de?","Dt NF de?","mv_ch1","D",8,00,00,"G","","SC5"   ,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)

xPutSX1(_cPerg,"01",  "Dt NF de?"  ,"Dt NF de?","Dt NF de?","mv_ch1","D",8,00,00,"G","",""   ,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],_cPerg)
xPutSX1(_cPerg,"02",  "Dt NF ate?"  ,"Dt NF ate?","Dt NF ate?","mv_ch2","D",8,00,00,"G","",""   ,"","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],_cPerg)
xPutSX1(_cPerg,"03",  "Transp. de?"  ,"Transp. de?","Transp. de?","mv_ch3","C",6,00,00,"G","","SA4"   ,"","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],_cPerg)
xPutSX1(_cPerg,"04",  "Transp. ate?"  ,"Transp. ate?","Transp. ate?","mv_ch4","C",6,00,00,"G","","SA4"   ,"","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],_cPerg)
xPutSX1(_cPerg,"05",  "Pedido de?"  ,"Pedido de?","Pedido de?","mv_ch5","C",6,00,00,"G","","SC5"   ,"","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],_cPerg)
xPutSX1(_cPerg,"06",  "Pedido ate?"  ,"Pedido ate?","Pedido ate?","mv_ch6","C",6,00,00,"G","","SC5"   ,"","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],_cPerg)
xPutSX1(_cPerg,"07",  "Dt Pedido de?"  ,"Dt Pedido de?","Dt Pedido de?","mv_ch7","D",8,00,00,"G","",""   ,"","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp[7,1],aHelp[7,2],aHelp[7,3],_cPerg)
xPutSX1(_cPerg,"08",  "Dt Pedido ate?"  ,"Dt Pedido ate?","Dt Pedido ate?","mv_ch8","D",8,00,00,"G","",""   ,"","","MV_PAR08","","","","","","","","","","","","","","","","",aHelp[8,1],aHelp[8,2],aHelp[8,3],_cPerg)

Return

Static Function xPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,; 
     cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,; 
     cF3, cGrpSxg,cPyme,; 
     cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,; 
     cDef02,cDefSpa2,cDefEng2,; 
     cDef03,cDefSpa3,cDefEng3,; 
     cDef04,cDefSpa4,cDefEng4,; 
     cDef05,cDefSpa5,cDefEng5,; 
     aHelpPor,aHelpEng,aHelpSpa,cHelp) 

LOCAL aArea := GetArea() 
Local cKey 
Local lPort := .f. 
Local lSpa := .f. 
Local lIngl := .f. 

cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

cPyme    := Iif( cPyme           == Nil, " ", cPyme          ) 
cF3      := Iif( cF3           == NIl, " ", cF3          ) 
cGrpSxg := Iif( cGrpSxg     == Nil, " ", cGrpSxg     ) 
cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01      ) 
cHelp      := Iif( cHelp          == Nil, "" , cHelp          ) 

dbSelectArea( "SX1" ) 
dbSetOrder( 1 ) 

// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes. 
// RFC - 15/03/2007 
cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

If !( DbSeek( cGrupo + cOrdem )) 

    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
     cPerSpa     := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
     cPerEng     := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

     Reclock( "SX1" , .T. ) 

     Replace X1_GRUPO   With cGrupo 
     Replace X1_ORDEM   With cOrdem 
     Replace X1_PERGUNT With cPergunt 
     Replace X1_PERSPA With cPerSpa 
     Replace X1_PERENG With cPerEng 
     Replace X1_VARIAVL With cVar 
     Replace X1_TIPO    With cTipo 
     Replace X1_TAMANHO With nTamanho 
     Replace X1_DECIMAL With nDecimal 
     Replace X1_PRESEL With nPresel 
     Replace X1_GSC     With cGSC 
     Replace X1_VALID   With cValid 

     Replace X1_VAR01   With cVar01 

     Replace X1_F3      With cF3 
     Replace X1_GRPSXG With cGrpSxg 

     If SX1->(Fieldpos("X1_PYME")) > 0 
          If cPyme != Nil 
               Replace X1_PYME With cPyme 
          Endif 
     Endif 

     Replace X1_CNT01   With cCnt01 
     If cGSC == "C"               // Mult Escolha 
          Replace X1_DEF01   With cDef01 
          Replace X1_DEFSPA1 With cDefSpa1 
          Replace X1_DEFENG1 With cDefEng1 

          Replace X1_DEF02   With cDef02 
          Replace X1_DEFSPA2 With cDefSpa2 
          Replace X1_DEFENG2 With cDefEng2 

          Replace X1_DEF03   With cDef03 
          Replace X1_DEFSPA3 With cDefSpa3 
          Replace X1_DEFENG3 With cDefEng3 

          Replace X1_DEF04   With cDef04 
          Replace X1_DEFSPA4 With cDefSpa4 
          Replace X1_DEFENG4 With cDefEng4 

          Replace X1_DEF05   With cDef05 
          Replace X1_DEFSPA5 With cDefSpa5 
          Replace X1_DEFENG5 With cDefEng5 
     Endif 

     Replace X1_HELP With cHelp 

     PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa) 

     MsUnlock() 
Else 

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
   lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
   lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

   If lPort .Or. lSpa .Or. lIngl 
          RecLock("SX1",.F.) 
          If lPort 
        SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
          EndIf 
          If lSpa 
               SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
          EndIf 
          If lIngl 
               SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
          EndIf 
          SX1->(MsUnLock()) 
     EndIf 
Endif 

RestArea( aArea ) 

Return
*/
