#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR55 º Autor ³ Cleber Orati       º Data ³  16/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Resumo de Vendas                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR55()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Resumo de Vendas"
     //Local cPict         := ""
     Local titulo        := "Resumo de Vendas"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 132
     Private tamanho     := "M"
     Private nomeprog    := "BRFATR55" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFATR55"

     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR55" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SC5"
     Private mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par08,mv_par09,mv_par10,mv_par11,mv_par12,mv_par13
         
	if !u_VldAcesso(funname())
      	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	return 
  	endif 
     u_zcfga01( 'BRFATR55' ) //LGS#2021201 - Gravação de log de utilização da rotina
	//CriaSX1(cPerg)
	Pergunte(cPerg,.F.)


	 wnrel:="BRFATR55"
	
     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif  
     

DO CASE
CASE MV_PAR11 == 1 
	Titulo := "Qtde Ped x Representante" 
	Cabec1 := "REPRESENTANTE                                                                                      QTDE PED  VALOR PEDIDO   VLR MEDIO"
CASE MV_PAR11 == 2 // Cliente x Litragem
	//              0         1         2         3        4         5         6         7         8         9         10       11         12       13        14        15        16        17        18        19         20      21
	//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Titulo := "Pedido Médio x Cliente x Repres"                                                               //9,999,999 999,999,999.99 999,999.99             
	Cabec1 := "REPRESENTANTE                                   CLIENTE                                           QTDE PED  VALOR PEDIDO   VLR MEDIO"
ENDCASE 		
Cabec2 := ""
Processa({|| FATR55_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR55_1 º Autor ³ Cleber Orati       º Data ³  18/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR55_1(Cabec1, Cabec2, Titulo, nLin)
       Local cAux,cQuery,nMedia,nTotal,nQtde,nTotG1,nPosRegua,nAuxTot,nAuxQtde,nQtG1
	

dbselectarea("SA3")
dbsetorder(1)
cQuery := "SELECT C5_VEND1 AS VEND"+iif(MV_PAR11 == 2,",C5_CLIENTE AS CODCLI,MAX(A1_NOME) AS RAZAO","")+",COUNT(SC5.R_E_C_N_O_) AS QTDEPED,"+;
"SUM(C5_VLRDUP/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS VALORPED "+;
"FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+; 
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (C5_CLIENTE = A1_COD) "+;
"WHERE (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_VLRDUP > 0) AND "+;
"(C5_TIPO = 'N') AND (C5_APROVA <> '2') "
IF !EMPTY(MV_PAR02)
	cQuery += "AND (C5_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
endif
IF !EMPTY(MV_PAR04)
	cQuery += "AND (C5_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
endif
//Chamado 007514, tirar códigos de repres. especificos do Glaidon 
if __cUserId = "000282"
	cQuery += "AND (C5_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
endif 
IF !EMPTY(MV_PAR06)
	cQuery += "AND (A1_CODCID BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
endif
IF !EMPTY(MV_PAR07)
	cQuery += "AND (A1_CLAS = '"+ALLTRIM(mv_par07)+"') "
endif                                                   
IF !EMPTY(MV_PAR09)
	cQuery += "AND (C5_EMISSAO BETWEEN '"+dtos(mv_par08)+"' AND '"+dtos(mv_par09)+"') "
ENDIF
if !empty(MV_PAR10)   
	cAux := U_RegiaoGeo(MV_PAR10)
	if !empty(cAux)
		cQuery += "AND (A1_EST IN ("+cAux+")) "
	endif 
endif		                           
if !empty(MV_PAR12)
	cQuery += "AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR12)+")) "
endif
if !empty(MV_PAR13)
	cQuery += "AND "+U_ParamSql("A1_EST",MV_PAR13)+" "
endif

cQuery += "GROUP BY C5_VEND1"+iif(MV_PAR11 == 2,",C5_CLIENTE "," ")+;
"ORDER BY "+iif(MV_PAR11 == 2,"VEND,","")+"VALORPED DESC"
       
TCQuery cQuery ALIAS "TCQ" NEW  
dbselectarea("TCQ")
DbGoTop()

cGrupo1 := ""
cGrupo2 := ""
cGrupo3 := ""
IF MV_PAR11 == 2 // "Pedido Médio x Cliente x Repres"
	cGrupo1 := IIF(!EOF("TCQ"),TCQ->VEND,"")
ENDIF

nQtdRec := 30
nTotal := 0
nQtde := 0
nTotG1 := 0     
nQtG1 := 0
ProcRegua(nQtdRec)
DbSelectArea("TCQ")
DbGoTop()
While !Eof()
	nLin++
	If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
		nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
		nLin += 1
	Endif                
	If lAbortPrint
		@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	lPassaregua := .f.
	nPosRegua := 0
	IF MV_PAR11 == 2 .AND. !(TCQ->VEND == cGrupo1) //"Pedido Médio x Cliente x Repres"
		lPassaregua := .t.
		nPosRegua := 0
		cMens := "TOTAL PARA O CÓD REPRESENTANTE: "+cGrupo1+" ===========>"
		cGrupo1 := TCQ->VEND
	ENDIF 
	if lPassaregua
		@ nLin, nPosRegua PSAY Replicate("-", 132-nPosRegua)
		nLin++
		If (nLin+2) > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
			nLin += 1
		Endif     
		nAuxTot := nTotG1 
		nAuxQtde := nQtG1 
		nTotG1 := 0
		nQtG1 := 0
      

		@ nLin, nPosRegua PSAY cMens
		@ nLin, 97 PSAY nAuxQtde PICTURE "@E 9,999,999"
		@ nLin, 107 PSAY nAuxTot PICTURE "@E 999,999,999.99"
		nMedia := round(iif(nAuxQtde <> 0,nAuxTot/nAuxQtde,0),2)
		@ nLin, 122 PSAY nMedia PICTURE "@E 999,999.99"
		nLin++
		@ nLin, nPosRegua PSAY Replicate("-", 132-nPosRegua)
		nLin++
	endif 

	dbselectarea("SA3")
	dbseek(xFilial("SA3")+TCQ->VEND)
	@ nLin, 000 PSAY TCQ->VEND+"-"+IIF(found(),SUBSTR(SA3->A3_NOME,1,40)," ")

	IF MV_PAR11 == 2
		@ nLin, 048 PSAY TCQ->CODCLI+"-"+SUBSTR(TCQ->RAZAO,1,40)
	ENDIF 
	
	@ nLin, 097 PSAY TCQ->QTDEPED PICTURE "@E 9,999,999"
	@ nLin, 107 PSAY TCQ->VALORPED PICTURE "@E 999,999,999.99"
	nMedia := round(iif(TCQ->QTDEPED <> 0,TCQ->VALORPED/TCQ->QTDEPED,0),2)
	@ nLin, 122 PSAY nMedia PICTURE "@E 999,999.99"
	
	nTotG1 += TCQ->VALORPED
	nQtG1 += TCQ->QTDEPED

	nTotal += TCQ->VALORPED
	nQtde += TCQ->QTDEPED

	dbselectarea("TCQ")
	dbskip()
ENDDO 	

nLin++
If (nLin+2) > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	nLin += 1
Endif                

@ nLin, 000 PSAY Replicate("=", 132)
nLin++
@ nLin, 040 PSAY 'TOTAL GERAL ===>>>>>>'
@ nLin, 097 PSAY nQtde PICTURE "@E 9,999,999"
@ nLin, 107 PSAY nTotal PICTURE "@E 999,999,999.99"
nMedia := round(iif(nQtde <> 0,nTotal/nQtde,0),2)
@ nLin, 122 PSAY nMedia PICTURE "@E 999,999.99"
nLin++
@ nLin, 000 PSAY Replicate("=", 132)
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
Static Function CriaSX1(cPerg)

	PutSX1(cPerg, "01",   "Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch1", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par01", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "02",   "Até o Cliente      ", "Até o Cliente      ", "Até o Cliente      ", "mv_ch2", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "03",   "Do Representante   ", "Do Representante   ", "Do Representante   ", "mv_ch3", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "04",   "Até o Representante", "Até o Representante", "Até o Representante", "mv_ch4", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "05",   "Da Cidade          ", "Da Cidade          ", "Da Cidade          ", "mv_ch5", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "06",   "Até a Cidade       ", "Até a Cidade       ", "Até a Cidade       ", "mv_ch6", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "07",   "Tipo Consumidor (Segmento)", "Tipo Consumidor (Segmento)", "Tipo Consumidor (Segmento)", "mv_ch7", "C",  2, 0, 0, "G", " ", "ZV" , " ", " ", "mv_par07", "", "", ""        , ""    , "", ""     , ""     , "", ""     , ""     , "", ""     , Nil , Nil     , Nil,cPerg)
	PutSX1(cPerg, "08",   "Do Periodo         ", "Do Periodo         ", "Do Periodo         ", "mv_ch8", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par08", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "09",   "Até o Periodo      ", "Até o Periodo      ", "Até o Periodo      ", "mv_ch9", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par09", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSx1(cPerg, "10",   "Região Geográf?"    ,"Região Geográf?","Região Geográf?","mv_cha","C",2,0,0,"G","","ZE","","","mv_par10","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "11",   "Padrão Relatório   ", "Padrão Relatório   ", "Padrão Relatório   ", "mv_chb", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par11", "Qtde Ped x Repr"       , "Qtde Ped x Repr", "Qtde Ped x Repr", "","Méd x Cli x Repr", "Méd x Cli x Repr","Méd x Cli x Repr", "","","", "", "", ""     , "" ,  "",  ""  , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "12",	  "Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_chc", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_par12","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "13",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_chd", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par13","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)

Return
*/
