#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFATR54 º Autor ³ Cleber Orati       º Data ³  16/12/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faturamento em Litros - Diversos                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFATR54()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Fat em Litros - Diversos"
     Local titulo        := "Fat em Litros - Diversos"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     Local aOrd          := {}
     Local cLitroKg := "Litragem"
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRFATR54" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 15
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFATR54"
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR54" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SF2"
     Private mv_par18 := 1    
	if !u_VldAcesso(funname())
      	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	return 
  	endif 

	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)


	 wnrel:="BRFATR54"
	
     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif  
     

     //nTipo := If(aReturn[4] == 1, 15, 18)

cLitrokg := iif(MV_PAR15 == 2,"Qtde Kg ","Litragem")
DO CASE
CASE MV_PAR14 == 1 // UF x Litragem
	Titulo := "UF x "+cLitrokg 
	Cabec1 := "                                                                                                                    UF                                                                      "+cLitrokg+"      VLR TOTAL    MEDIA"
CASE MV_PAR14 == 2 // Cliente x Litragem
	Titulo := "Cliente x "+cLitrokg
	Cabec1 := "                                                                                                                                       CLIENTE                                              "+cLitrokg+"      VLR TOTAL    MEDIA"
CASE MV_PAR14 == 3 // Repr x Cidade x Cliente x Litr
	//              0         1         2         3        4         5         6         7         8         9         10       11         12       13        14        15        16        17        18        19         20      21
	//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Titulo := "Repr x Cidade x Cliente x "+cLitrokg                                                                                                                               //                  999,999,999.9 999,999,999.99 9,999.99
	Cabec1 := "REPRESENTANTE                                                       CIDADE                                          UF TIPO CONSUMIDOR CLIENTE                                              "+cLitrokg+"      VLR TOTAL    MEDIA"
CASE MV_PAR14 == 4 // Repr x Cota de Segmento x Segmento x Litragem
	Titulo := "Repr x Cota de Segmento x Segmento x "+cLitrokg   																					//999,999,999.99
	Cabec1 := "REPRESENTANTE                                                                                                          TIPO CONSUMIDOR           COTA                                       "+cLitrokg+"      VLR TOTAL    MEDIA"
CASE MV_PAR14 == 5 // Repr. x Linha x Litragem
	Titulo := "Repr. x Linha x "+cLitrokg
	Cabec1 := "REPRESENTANTE                                   LINHA                                                                                                                                       "+cLitrokg+"      VLR TOTAL    MEDIA"
ENDCASE 		
Cabec2 := ""
Processa({|| FATR54_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ FATR54_1 º Autor ³ Luís G. de Souza   º Data ³  16/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FATR54_1(Cabec1, Cabec2, Titulo, nLin)
       Local cAux,cQuery,nMedia,nVolume,nTotal,nVolG1,nTotG1,nVolG2,nTotG2,nPosRegua,nQualGrupo,lPassaregua,cUm,cFatB6
       //Local cQry1 := ""
       //Local cQry2 := ""
       //Local cQry3 := ""                  // 1234567890123456                       1234567890123456                       1234567890123456                       1234567890123456    12345
	

do case
case mv_par15 == 1
	cUm := "'L'"
case mv_par15 == 2
	cUm := "'K','KG'"
case mv_par15 == 3
	cUm := "'K','KG','L'"
otherwise 	 
	cUm := "'L'"
endcase 
//cUm := iif(mv_par15 == 2,"'K','KG'","'L'")    
cFatB6 = iif(MV_PAR18 == 1, "0.7","1.0")
cQuery := "WITH TMP AS ("+;
"SELECT F2_VEND1 AS VEND,MAX(A3_NOME) AS NOME,MAX(F2_CLAS) AS CLAS,"+;
"COTA = CASE WHEN F2_CLAS = 'C' THEN MAX(A3_COTA1) WHEN F2_CLAS = 'I' THEN MAX(A3_COTA2) WHEN F2_CLAS = 'N' THEN MAX(A3_COTA3) WHEN F2_CLAS = 'V' THEN MAX(A3_COTA) WHEN F2_CLAS = 'D' THEN MAX(A3_COTA4) ELSE 0 END,"+;
"F2_CLIENTE AS CODCLI,D2_EST AS UF,F2_CODCID AS CODCID,SUBSTRING(D2_COD,1,10) AS CODPRO,"+;
"SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN "+cFatB6+" ELSE 1.0 END)) AS VALMERC,"+;
"VOLUME = SUM(CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END) "+;
"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = F2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (F2_VEND1 = A3_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "+;
"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND ((D2_UM IN ("+cUm+")) OR (D2_SEGUM IN ("+cUm+"))) AND ((F4_DUPLIC <> 'N') "
if MV_PAR18 == 1
	cQuery += "OR (D2_TES = '519')"
endif
cQuery += ") AND (D2_EMISSAO BETWEEN '"+dtos(mv_par11)+"' AND '"+dtos(mv_par12)+"') "
if !empty(MV_PAR01)
	cQuery += "AND (LEN(D2_COD) = 12) AND "+U_ParamSql("SUBSTRING(D2_COD,4,2)",MV_PAR01)+" "
endif
if !empty(MV_PAR03) 
	cQuery += "AND (D2_COD BETWEEN '"+ALLTRIM(MV_PAR02)+"' AND '"+ALLTRIM(MV_PAR03)+"') "
endif 	
if !empty(MV_PAR05) 
	cQuery += "AND (D2_CLIENTE BETWEEN '"+ALLTRIM(MV_PAR04)+"' AND '"+ALLTRIM(MV_PAR05)+"') "
endif 	
if !empty(MV_PAR07) 
	cQuery += "AND (F2_VEND1 BETWEEN '"+ALLTRIM(MV_PAR06)+"' AND '"+ALLTRIM(MV_PAR07)+"') "
endif 	
//Chamado 007514, tirar códigos de repres. especificos do Glaidon 
if __cUserId = "000282"
	cQuery += "AND (F2_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
endif 

if !empty(MV_PAR09) 
	cQuery += "AND (F2_CODCID BETWEEN '"+ALLTRIM(MV_PAR08)+"' AND '"+ALLTRIM(MV_PAR09)+"') "
endif 	
If !empty(mv_par10)
	cQuery += " AND (F2_CLAS = '"+alltrim(mv_par10)+"') "
Endif
if !empty(MV_PAR13)   
	cAux := U_RegiaoGeo(MV_PAR13)
	if !empty(cAux)
		cQuery += "AND (D2_EST IN ("+cAux+")) "
	endif 
endif		                           

IF !empty(MV_PAR16)
	cQuery += "AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR16)+")) "
ENDIF

if !empty(MV_PAR17)
	cQuery += "AND "+U_ParamSql("A1_EST",MV_PAR17)+" "
endif

cQuery += "GROUP BY F2_VEND1,F2_CLIENTE,F2_CLAS,D2_EST,F2_CODCID,SUBSTRING(D2_COD,1,10) "+;
"UNION ALL "+;
"SELECT F2_VEND1 AS VEND,MAX(A3_NOME) AS NOME,MAX(F2_CLAS) AS CLAS,"+;
"COTA = CASE WHEN F2_CLAS = 'C' THEN MAX(A3_COTA1) WHEN F2_CLAS = 'I' THEN MAX(A3_COTA2) WHEN F2_CLAS = 'N' THEN MAX(A3_COTA3) WHEN F2_CLAS = 'V' THEN MAX(A3_COTA) WHEN F2_CLAS = 'D' THEN MAX(A3_COTA4) ELSE 0 END,"+;
"F2_CLIENTE AS CODCLI,F2_EST AS UF,F2_CODCID AS CODCID,SUBSTRING(D1_COD,1,10) AS CODPRO, "+;
"-1.0*SUM(D1_TOTAL) AS VALMERC,"+;
"VOLUME = -1.0*SUM(CASE WHEN D1_UM IN ("+cUm+") THEN D1_QUANT WHEN D1_SEGUM IN ("+cUm+") THEN D1_QTSEGUM ELSE 0 END) "+;
"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D1_SERIORI = F2_SERIE) AND (D1_NFORI = F2_DOC) AND (D1_FORNECE = F2_CLIENTE) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (F2_CLIENTE = A1_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D1_TES = F4_CODIGO) "+;
"LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 WITH (NOLOCK) ON (SA3.D_E_L_E_T_ <> '*') AND (A3_FILIAL = '"+xFilial("SA3")+"') AND (F2_VEND1 = A3_COD) "+;
"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND ((D1_UM IN ("+cUm+")) OR (D1_SEGUM IN ("+cUm+"))) AND (F4_DUPLIC = 'S') AND "+;
"(D1_DTDIGIT BETWEEN '"+dtos(mv_par11)+"' AND '"+dtos(mv_par12)+"') "
if !empty(MV_PAR01)
	cQuery += "AND (LEN(D1_COD) = 12) AND "+U_ParamSql("SUBSTRING(D1_COD,4,2)",MV_PAR01)+" "
endif
if !empty(MV_PAR03) 
	cQuery += "AND (D1_COD BETWEEN '"+ALLTRIM(MV_PAR02)+"' AND '"+ALLTRIM(MV_PAR03)+"') "
endif 	
if !empty(MV_PAR05) 
	cQuery += "AND (D1_FORNECE BETWEEN '"+ALLTRIM(MV_PAR04)+"' AND '"+ALLTRIM(MV_PAR05)+"') "
endif 	               
if !empty(MV_PAR07) 
	cQuery += "AND (F2_VEND1 BETWEEN '"+ALLTRIM(MV_PAR06)+"' AND '"+ALLTRIM(MV_PAR07)+"') "
endif 	
//Chamado 007514, tirar códigos de repres. especificos do Glaidon 
if __cUserId = "000282"
	cQuery += "AND (F2_VEND1 NOT IN ('000250','000444','000303','000333','000438','000276')) "
endif 
if !empty(MV_PAR09) 
	cQuery += "AND (F2_CODCID BETWEEN '"+ALLTRIM(MV_PAR08)+"' AND '"+ALLTRIM(MV_PAR09)+"') "
endif 	
If !empty(mv_par10)
	cQuery += " AND (F2_CLAS = '"+alltrim(mv_par10)+"') "
Endif
if !empty(MV_PAR13)   
	cAux := U_RegiaoGeo(MV_PAR13)
	if !empty(cAux)
		cQuery += "AND (F2_EST IN ("+cAux+")) "
	endif 
endif		                           

IF !empty(MV_PAR16)
	cQuery += "AND ((A1_SATIV2 = '') OR ("+U_ParamSql("A1_SATIV2",MV_PAR16)+")) "
ENDIF

if !empty(MV_PAR17)
	cQuery += "AND "+U_ParamSql("A1_EST",MV_PAR17)+" "
endif

cQuery += "GROUP BY F2_VEND1,F2_CLIENTE,F2_EST,F2_CLAS,F2_CODCID,SUBSTRING(D1_COD,1,10)), TMP2 AS ("+;
"SELECT VEND,MAX(NOME) AS NOME,MAX(CLAS) AS CLAS,MAX(COTA) AS COTA,CODCLI,UF,CODCID,CODPRO,SUM(VOLUME) AS VOLUME,SUM(VALMERC) AS VALMERC FROM "+;
"TMP GROUP BY VEND,CODCLI,UF,CODCID,CODPRO) "	

DO CASE
CASE MV_PAR14 == 1 // UF x Litragem
	cQuery += "SELECT UF,SUM(VOLUME) AS VOLUME,SUM(VALMERC) AS VALMERC FROM TMP2 GROUP BY UF ORDER BY VOLUME DESC,UF"
CASE MV_PAR14 == 2 // Cliente x Litragem
	cQuery += "SELECT CODCLI,MAX(A1_NOME) AS RAZAO,SUM(VOLUME) AS VOLUME,SUM(VALMERC) AS VALMERC FROM TMP2 "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = TMP2.CODCLI) "+;
	"GROUP BY CODCLI "+;
	"ORDER BY VOLUME DESC,CODCLI"
CASE MV_PAR14 == 3 // Repr x Cidade x Cliente x Litr
	cQuery += "SELECT VEND,MAX(NOME) AS NOME,CODCID,MAX(Z7_NOME) AS CIDADE,MAX(UF) AS UF,CODCLI,MAX(A1_NOME) AS RAZAO,"+;
	"SUM(VOLUME) AS VOLUME,SUM(VALMERC) AS VALMERC FROM TMP2 "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_COD = TMP2.CODCLI) "+;
	"LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (Z7_FILIAL = '"+xFilial("SZ7")+"') AND (Z7_COD = TMP2.CODCID) "+;
	"GROUP BY VEND,CODCID,CODCLI "+;
	"ORDER BY VEND,CODCID,CODCLI"
	
CASE MV_PAR14 == 4 // Repr x Cota de Segmento x Segmento x Litragem
	cQuery += "SELECT VEND,MAX(NOME) AS NOME,CLAS,MAX(COTA) AS COTA,SUM(VOLUME) AS VOLUME,SUM(VALMERC) AS VALMERC FROM TMP2 "+;
	"GROUP BY VEND,CLAS "+;
	"ORDER BY VEND,CLAS"
CASE MV_PAR14 == 5 // Repr. x Linha x Litragem
	cQuery += "SELECT VEND,MAX(NOME) AS NOME,SUBSTRING(CODPRO,4,2) AS LINHA,SUM(VOLUME) AS VOLUME,SUM(VALMERC) AS VALMERC FROM TMP2 "+;
	"GROUP BY VEND,SUBSTRING(CODPRO,4,2) "+;
	"ORDER BY VEND,LINHA"
ENDCASE 		
       
TCQuery cQuery ALIAS "TCQ" NEW  
dbselectarea("TCQ")
DbGoTop()

cGrupo1 := ""
cGrupo2 := ""
cGrupo3 := ""
DO CASE
CASE MV_PAR14 == 3 // Repr x Cidade x Cliente x Litr
	cGrupo1 := IIF(!EOF("TCQ"),TCQ->CODCID,"")
	cGrupo2 := IIF(!EOF("TCQ"),TCQ->VEND,"")
CASE MV_PAR14 == 4 // Repr x Cota de Segmento x Segmento x Litragem
	cGrupo1 := IIF(!EOF("TCQ"),TCQ->VEND,"")
CASE MV_PAR14 == 5 // Repr. x Linha x Litragem
	cGrupo1 := IIF(!EOF("TCQ"),TCQ->VEND,"")
ENDCASE 		



nQtdRec := 30
nVolume := 0
nTotal := 0
nVolG1 := 0
nTotG1 := 0
nVolG2 := 0
nTotG2 := 0
nVolG3 := 0
nTotG3 := 0
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
	DO CASE
	CASE MV_PAR14 == 3 // Repr x Cidade x Cliente x Litr    
		DO CASE
		CASE !(TCQ->VEND == cGrupo2)
			lPassaregua := .t.
			nPosRegua := 0
			cMens := "TOTAL PARA O CÓD REPRESENTANTE: "+cGrupo2+" ===========>"
			cGrupo1 := TCQ->CODCID
			cGrupo2 := TCQ->VEND
			nQualGrupo := 2
		CASE !(TCQ->CODCID == cGrupo1)
			lPassaregua := .t.
			nPosRegua := 68
			cMens := "TOTAL PARA O CÓD CIDADE: "+cGrupo1+" ===========>"
			cGrupo1 := TCQ->CODCID
			cGrupo2 := TCQ->VEND
			nQualGrupo := 1
		ENDCASE
	CASE MV_PAR14 == 4 // Repr x Cota de Segmento x Segmento x Litragem
		DO CASE
		CASE !(TCQ->VEND == cGrupo1)
			lPassaregua := .t.
			nPosRegua := 0
			cMens := "TOTAL PARA O CÓD REPRESENTANTE: "+cGrupo1+" ===========>"
			cGrupo1 := TCQ->VEND
			nQualGrupo := 1
		ENDCASE 
	CASE MV_PAR14 == 5 // Repr. x Linha x Litragem
		DO CASE
		CASE !(TCQ->VEND == cGrupo1)
			lPassaregua := .t.
			nPosRegua := 0
			cMens := "TOTAL PARA O CÓD REPRESENTANTE: "+cGrupo1+" ===========>"
			cGrupo1 := TCQ->VEND
			nQualGrupo := 1
		ENDCASE 
	ENDCASE 		

	if lPassaregua
		@ nLin, nPosRegua PSAY Replicate("-", 220-nPosRegua)
		nLin++
		If (nLin+2) > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
			nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
			nLin += 1
		Endif     
		do case
		case nQualGrupo == 1
			nAuxVol := nVolG1
			nAuxTot := nTotG1 
			nVolG1 := 0
			nTotG1 := 0
		case nQualGrupo == 2
			nAuxVol := nVolG2
			nAuxTot := nTotG2
			nVolG2 := 0
			nTotG2 := 0
			nVolG1 := 0
			nTotG1 := 0
		endcase
      
		@ nLin, nPosRegua PSAY cMens
		@ nLin, 183 PSAY nAuxVol PICTURE "@E 999,999,999.9"
		@ nLin, 197 PSAY nAuxTot PICTURE "@E 999,999,999.99"
		nMedia := round(iif(nAuxVol <> 0,nAuxTot/nAuxVol,0),2)
		@ nLin, 212 PSAY nMedia PICTURE "@E 9,999.99"
		nLin++
		@ nLin, nPosRegua PSAY Replicate("-", 220-nPosRegua)
		nLin++
	endif 

	IF MV_PAR14 >= 3
		@ nLin, 000 PSAY TCQ->VEND+"-"+SUBSTR(TCQ->NOME,1,40)
	ENDIF
	IF MV_PAR14 == 5
		@ nLin, 048 PSAY TCQ->LINHA+"-"+Posicione("SZ1", 1, xFilial("SZ1")+TCQ->LINHA, "Z1_DESCR")
	ENDIF 
	
	IF MV_PAR14 == 3	
		@ nLin, 068 PSAY TCQ->CODCID+"-"+SUBSTR(TCQ->CIDADE,1,40)
	ENDIF 
	IF (MV_PAR14 == 1) .OR. (MV_PAR14 == 3)
		@ nLin, 116 PSAY TCQ->UF
	ENDIF
	IF MV_PAR14 == 4
		@ nLin, 119 PSAY SUBSTR(U_TipoCons(TCQ->CLAS),1,15)
		@ nLin, 135 PSAY TCQ->COTA PICTURE "@E 999,999,999.99"
	ENDIF 
	
	IF (MV_PAR14 == 2) .OR. (MV_PAR14 == 3)
		@ nLin, 135 PSAY TCQ->CODCLI+"-"+SUBSTR(TCQ->RAZAO,1,40)
	ENDIF 

	@ nLin, 183 PSAY TCQ->VOLUME PICTURE "@E 999,999,999.9"
	@ nLin, 197 PSAY TCQ->VALMERC PICTURE "@E 999,999,999.99"
	nMedia := round(iif(TCQ->VOLUME <> 0,TCQ->VALMERC/TCQ->VOLUME,0),2)
	@ nLin, 212 PSAY nMedia PICTURE "@E 9,999.99"
	
	nVolume += TCQ->VOLUME
	nVolG2 += TCQ->VOLUME
	nVolG1 += TCQ->VOLUME

	nTotal += TCQ->VALMERC
	nTotG2 += TCQ->VALMERC
	nTotG1 += TCQ->VALMERC

	dbselectarea("TCQ")
	dbskip()
ENDDO 	

nLin++
If (nLin+2) > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	nLin += 1
Endif                

@ nLin, 000 PSAY Replicate("=", 220)
nLin++
@ nLin, 080 PSAY 'TOTAL GERAL ===>>>>>>'
@ nLin, 183 PSAY nVolume PICTURE "@E 999,999,999.9"
@ nLin, 197 PSAY nTotal PICTURE "@E 999,999,999.99"
nMedia := round(iif(nVolume <> 0,nTotal/nVolume,0),2)
@ nLin, 212 PSAY nMedia PICTURE "@E 9,999.99"
nLin++
@ nLin, 000 PSAY Replicate("=", 220)
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

Static Function CriaSX1(cPerg)

Local aHelp := {}
local aHelpIng,aHelpEsp
   
aHelp := {} 
AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})

	U_xPutSx1(cPerg, "01",   "Linha(s) Produto"   , "Linha(s) Produto"   , "Linha(s) Produto"   , "mv_ch1", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
	U_xPutSx1(cPerg, "02",   "Do Produto         ", "Do Produto         ", "Do Produto         ", "mv_ch3", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par02", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "03",   "Até o Produto      ", "Até o Produto      ", "Até o Produto      ", "mv_ch4", "C", 15, 0, 0, "G", " ", "SB1", " ", " ", "mv_par03", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "04",   "Do Cliente         ", "Do Cliente         ", "Do Cliente         ", "mv_ch5", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par04", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "05",   "Até o Cliente      ", "Até o Cliente      ", "Até o Cliente      ", "mv_ch6", "C",  6, 0, 0, "G", " ", "SA1", " ", " ", "mv_par05", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "06",   "Do Representante   ", "Do Representante   ", "Do Representante   ", "mv_ch7", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par06", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "07",   "Até o Representante", "Até o Representante", "Até o Representante", "mv_ch8", "C",  6, 0, 0, "G", " ", "SA3", " ", " ", "mv_par07", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "08",   "Da Cidade          ", "Da Cidade          ", "Da Cidade          ", "mv_ch9", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par08", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "09",   "Até a Cidade       ", "Até a Cidade       ", "Até a Cidade       ", "mv_cha", "C",  6, 0, 0, "G", " ", "SZ7", " ", " ", "mv_par09", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "10",   "Tipo Consumidor (Segmento)", "Tipo Consumidor (Segmento)", "Tipo Consumidor (Segmento)", "mv_chb", "C",  2, 0, 0, "G", " ", "ZV" , " ", " ", "mv_par10", "", "", ""        , ""    , "", ""     , ""     , "", ""     , ""     , "", ""     , Nil , Nil     , Nil,cPerg)
	U_xPutSx1(cPerg, "11",   "Do Periodo         ", "Do Periodo         ", "Do Periodo         ", "mv_chc", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par11", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "12",   "Até o Periodo      ", "Até o Periodo      ", "Até o Periodo      ", "mv_chd", "D",  8, 0, 0, "G", " ",   " ", " ", " ", "mv_par12", ""                , " ", " "     , " "   , ""                , " "     , " "     , ""                , " "     , " "     , ""                , " "     , " "     , ""            ,  " ",  " "     , Nil  , Nil     , Nil     ,cPerg)
	U_xPutSx1(cPerg, "13",   "Região Geográf?","Região Geográf?","Região Geográf?","mv_che","C",2,0,0,"G","","ZE","","","mv_par13","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)

	aHelp := {} 
			//	"Informe a data inicial para gerar as    " 
	Aadd( aHelp,"Padrão 1: UF x Litragem " )
	Aadd( aHelp,"Padrão 2: Cliente x Litragem" )
	Aadd( aHelp,"Padrão 3: Repr x Cidade x Cliente x Litr" )
	Aadd( aHelp,"agem")
	Aadd( aHelp,"Padrão 4: Repr x Cota de Segmento x Segm")
	Aadd( aHelp,"ento x Litragem" )
	Aadd( aHelp,"Padrão 5: Repr. x Linha x Litragem" )
	aHelpIng := aHelpEsp := aHelp
	U_xPutSx1(cPerg, "14",   "Padrão Relatório   ", "Padrão Relatório   ", "Padrão Relatório   ", "mv_chf", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par14", "Por UF" , "Por UF", "Por UF", "","por Cliente", "por Cliente","por Cliente", "ReprxCidxCli","ReprxCidxCli","ReprxCidxCli", "Repr x Cota", "Repr x Cota", "Repr x Cota" , "Repr x Linha" ,  "Repr x Linha",  "Repr x Linha"  , aHelp  , aHelp     , aHelp  ,cPerg)

	aHelp := {} 
	Aadd( aHelp,"Fat. em Litros ou Kg??" )
   	U_xPutSx1(cPerg, "15",   "Litro ou Kg", "Litro ou Kg", "Litro ou Kg", "mv_chg", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par15", "Litros"       , "Litros", "Litros", "","Kilogramas", "Kilogramas","Kilogramas", "L+KG","L+KG","L+KG", "", "", ""     , "5" ,  "",  ""  , aHelp,aHelp,aHelp     ,cPerg)
	U_xPutSx1(cPerg, "16",   "Segmento(s)        ", "Segmento(s)        ", "Segmento(s)        ", "mv_chh", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_Par16","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	U_xPutSx1(cPerg, "17",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_chi", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par17","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)
	u_xPutSx1(cPerg, "18",           "Inclui B6?" ,"Inclui B6?"          ,"Inclui B6?"          ,"mv_chj" , "N", 6 , 0 ,1, "C"  ,"", "","","","MV_PAR18","1-Sim","1-Sim","1-Sim","","2-Não","2-Não","2-Não","","","","","","","","","","Inclui B6?","Inclui B6?","Inclui B6?",cPerg)


Return

