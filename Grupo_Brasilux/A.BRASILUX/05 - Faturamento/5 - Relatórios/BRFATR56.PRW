#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFATR56 บ Autor ณ Cleber Orati       บ Data ณ  22/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Positiva็ใo de Clientes                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFATR56()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Resumo de Vendas"
     //Local cPict         := ""
     Local titulo        := "Positiva็ใo de Clientes"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFATR56" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFATR56"

     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR56" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SF2"   
     Private mv_par10,mv_par11,mv_par12,mv_par13
         
	if !u_VldAcesso(funname())
      	MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      	return 
  	endif 
     u_zcfga01( 'BRFATR56' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
	//CriaSX1(cPerg)
	Pergunte(cPerg,.F.)


	 wnrel:="BRFATR56"
	
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
	//              0         1         2         3        4         5         6         7         8         9         10       11         12       13        14        15        16        17        18        19         20      21
	//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Titulo := "Carteira Clientes Ativa x Cli Faturados" //       9,999,999,999    9,999,999,999 
	Cabec1 := "REPRESENTANTE                                       Qtde Ativos   Qtde Faturados"
CASE MV_PAR11 == 2 // Cliente x Litragem
	//              0         1         2         3        4         5         6         7         8         9         10       11         12       13        14        15        16        17        18        19         20      21
	//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Titulo := "Clientes Efetivados"               //             9,999,999,999 
	Cabec1 := "REPRESENTANTE                                        Efetivados"
ENDCASE 		
Cabec2 := ""
Processa({|| FATR56_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FATR56_1 บ Autor ณ Cleber Orati       บ Data ณ  18/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FATR56_1(Cabec1, Cabec2, Titulo, nLin)
       Local cAux,cQuery,nQtde1,nQtde2
	

dbselectarea("SA3")
dbsetorder(1)   


IF MV_PAR11 == 1     
	cQuery := "WITH CLIENTES AS (SELECT F2_VEND1 AS VEND,F2_CLIENTE AS CODCLI "+;
	"FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+; 
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_CLIENTE = A1_COD) "+;
	"WHERE (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_TIPO = 'N') AND (F2_DUPL > 0) "
	IF !EMPTY(MV_PAR02)
		cQuery += "AND (F2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
	endif
	IF !EMPTY(MV_PAR04)
		cQuery += "AND (F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
	endif
	//Chamado 007514, tirar c๓digos de repres. especificos do Glaidon 
	if __cUserId = "000282"
		cQuery += "AND (F2_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
	endif 
	IF !EMPTY(MV_PAR06)
		cQuery += "AND (F2_CODCID BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
	endif
	IF !EMPTY(MV_PAR07)
		cQuery += "AND (F2_CLAS = '"+ALLTRIM(mv_par07)+"') "
	endif                                                   
	if !empty(MV_PAR10)   
		cAux := U_RegiaoGeo(MV_PAR10)
		if !empty(cAux)
			cQuery += "AND (F2_EST IN ("+cAux+")) "
		endif 
	endif		                           
	if !empty(MV_PAR12)
		cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR12)+") "
	endif
	if !empty(MV_PAR13)
		cQuery += "AND "+U_ParamSql("A1_EST",MV_PAR13)+" "
	endif

	cQuery += "GROUP BY F2_VEND1,F2_CLIENTE HAVING MAX(F2_EMISSAO) >= CONVERT(VARCHAR,GETDATE()-90,112)),"+;
	"TMP1 AS (SELECT VEND,COUNT(CODCLI) AS QTATIVOS FROM CLIENTES GROUP BY VEND),"+;
	"TMP2 AS (SELECT DISTINCT F2_VEND1 AS VEND,F2_CLIENTE AS CODCLI "+;
	"FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_CLIENTE = A1_COD) "+;
	"WHERE (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_TIPO = 'N') AND "+;
	"(F2_DUPL > 0) "
	IF !EMPTY(MV_PAR02)
		cQuery += "AND (F2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
	endif
	IF !EMPTY(MV_PAR04)
		cQuery += "AND (F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
	endif
	//Chamado 007514, tirar c๓digos de repres. especificos do Glaidon 
	if __cUserId = "000282"
		cQuery += "AND (F2_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
	endif 
	IF !EMPTY(MV_PAR06)
		cQuery += "AND (F2_CODCID BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
	endif
	IF !EMPTY(MV_PAR07)
		cQuery += "AND (F2_CLAS = '"+ALLTRIM(mv_par07)+"') "
	endif                                                   
	IF !EMPTY(MV_PAR09)
		cQuery += "AND (F2_EMISSAO BETWEEN '"+dtos(mv_par08)+"' AND '"+dtos(mv_par09)+"') "
	ENDIF
	if !empty(MV_PAR10)   
		cAux := U_RegiaoGeo(MV_PAR10)
		if !empty(cAux)
			cQuery += "AND (F2_EST IN ("+cAux+")) "
		endif 
	endif		                           
	if !empty(MV_PAR12)
		cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR12)+") "
	endif
	if !empty(MV_PAR13)
		cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR13)+") "
	endif
	cQuery += "),"+;
	"TMP3 AS ("+;
	"SELECT VEND,COUNT(CODCLI) AS QTFAT FROM TMP2 GROUP BY VEND) "+;
	"SELECT SA3.A3_COD AS VEND,ISNULL(TMP1.QTATIVOS,0) AS QTATIVOS,ISNULL(TMP3.QTFAT,0) AS QTFAT "+;
	"FROM "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN TMP1 ON (TMP1.VEND = A3_COD) "+;
	"LEFT OUTER JOIN TMP3 ON (TMP3.VEND = A3_COD) "+;
	"WHERE (ISNULL(TMP1.QTATIVOS,0) > 0) OR (ISNULL(TMP3.QTFAT,0) > 0) "+;
	"ORDER BY VEND"
ELSE
	cQuery := "WITH CLIENTES AS (SELECT F2_VEND1 AS VEND,F2_CLIENTE AS CODCLI "+;
	"FROM "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_CLIENTE = A1_COD) "+;
	"WHERE (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_TIPO = 'N') AND (F2_DUPL > 0) "
	IF !EMPTY(MV_PAR02)
		cQuery += "AND (F2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
	endif
	IF !EMPTY(MV_PAR04)
		cQuery += "AND (F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
	endif
	//Chamado 007514, tirar c๓digos de repres. especificos do Glaidon 
	if __cUserId = "000282"
		cQuery += "AND (F2_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
	endif 
	IF !EMPTY(MV_PAR06)
		cQuery += "AND (F2_CODCID BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
	endif
	IF !EMPTY(MV_PAR07)
		cQuery += "AND (F2_CLAS = '"+ALLTRIM(mv_par07)+"') "
	endif                                                   
	if !empty(MV_PAR10)   
		cAux := U_RegiaoGeo(MV_PAR10)
		if !empty(cAux)
			cQuery += "AND (F2_EST IN ("+cAux+")) "
		endif 
	endif		                           
	if !empty(MV_PAR12)
		cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR12)+") "
	endif
	if !empty(MV_PAR13)
		cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR13)+") "
	endif
	cQuery += "GROUP BY F2_VEND1,F2_CLIENTE HAVING MIN(F2_EMISSAO) BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"') "+;
	"SELECT VEND,COUNT(CODCLI) AS QTATIVOS FROM CLIENTES GROUP BY VEND "

ENDIF 
TCQuery cQuery ALIAS "TCQ" NEW  
dbselectarea("TCQ")
DbGoTop()



nQtdRec := 30
nQtde1 := 0
nQtde2 := 0
ProcRegua(nQtdRec)
DbSelectArea("TCQ")
DbGoTop()
While !Eof()
	nLin++
	If nLin > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
		nLin += 1
	Endif                
	If lAbortPrint
		@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	dbselectarea("SA3")
	dbseek(xFilial("SA3")+TCQ->VEND)
	@ nLin, 000 PSAY TCQ->VEND+"-"+IIF(found(),SUBSTR(SA3->A3_NOME,1,40)," ")
	@ nLin, 050 PSAY TCQ->QTATIVOS PICTURE "@E 9,999,999,999"
	IF MV_PAR11 == 1
		@ nLin, 067 PSAY TCQ->QTFAT PICTURE "@E 9,999,999,999"   
		nQtde2 += TCQ->QTFAT
    ENDIF 
	
	nQtde1 += TCQ->QTATIVOS
	dbselectarea("TCQ")
	dbskip()
ENDDO 	

nLin++
If (nLin+2) > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	nLin += 1
Endif                

@ nLin, 000 PSAY Replicate("=", 80)
nLin++
@ nLin, 000 PSAY 'TOTAL GERAL ===>>>>>>'
@ nLin, 050 PSAY nQtde1 PICTURE "@E 9,999,999,999"
IF MV_PAR11 == 1
	@ nLin, 067 PSAY nQtde2 PICTURE "@E 9,999,999,999"
endif 
nLin++
@ nLin, 000 PSAY Replicate("=", 80)
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
/*** VLDPERG  - Gera perguntas para paramentros do relat๓rio.                                                   ***/
/******************************************************************************************************************/
/* DESABILITADO RELEASE 12.1.25
Static Function CriaSX1(cPerg)

	PutSX1(cPerg, "01",   "Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch1", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par01", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "02",   "At้ o Cliente      ", "At้ o Cliente      ", "At้ o Cliente      ", "mv_ch2", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "03",   "Do Representante   ", "Do Representante   ", "Do Representante   ", "mv_ch3", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "04",   "At้ o Representante", "At้ o Representante", "At้ o Representante", "mv_ch4", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "05",   "Da Cidade          ", "Da Cidade          ", "Da Cidade          ", "mv_ch5", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "06",   "At้ a Cidade       ", "At้ a Cidade       ", "At้ a Cidade       ", "mv_ch6", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "07",   "Tipo Consumidor (Segmento)", "Tipo Consumidor (Segmento)", "Tipo Consumidor (Segmento)", "mv_ch7", "C",  2, 0, 0, "G", " ", "ZV" , " ", " ", "mv_par07", "", "", ""        , ""    , "", ""     , ""     , "", ""     , ""     , "", ""     , Nil , Nil     , Nil,cPerg)
	PutSX1(cPerg, "08",   "Do Periodo         ", "Do Periodo         ", "Do Periodo         ", "mv_ch8", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par08", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "09",   "At้ o Periodo      ", "At้ o Periodo      ", "At้ o Periodo      ", "mv_ch9", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par09", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	PutSx1(cPerg, "10",   "Regiใo Geogrแf?","Regiใo Geogrแf?","Regiใo Geogrแf?","mv_cha","C",2,0,0,"G","","ZE","","","mv_par10","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "11",   "Padrใo Relat๓rio   ", "Padrใo Relat๓rio   ", "Padrใo Relat๓rio   ", "mv_chb", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par11", "Carteira x Fat."       , "Carteira x Fat.", "Carteira x Fat.", "","Cli. Efetivados", "Cli. Efetivados","Cli. Efetivados", "","","", "", "", ""     , "" ,  "",  ""  , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "12",	  "Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_chc", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_par12","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "13",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_chd", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par13","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)

Return
*/
