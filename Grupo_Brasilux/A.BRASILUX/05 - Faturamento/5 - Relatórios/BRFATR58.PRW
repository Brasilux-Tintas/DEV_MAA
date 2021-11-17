#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFATR58 บ Autor ณ Cleber Orati       บ Data ณ  23/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Clientes com Brasimix                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFATR58()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Resumo de Vendas"
     //Local cPict         := ""
     Local titulo        := "Clientes com Brasimix - ฺlt. 2 Anos"
     Local nLin          := 80
     Local Cabec1        := ""
     Local Cabec2        := ""
     //Local imprime       := .T.
     Local aOrd          := {}
     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private CbTxt       := ""
     Private limite      := 220
     Private tamanho     := "G"
     Private nomeprog    := "BRFATR58" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFATR58"
     //Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR58" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SD2"
     Private MV_PAR10,MV_PAR11,MV_PAR12,MV_PAR13
         
	if !u_VldAcesso(funname())
      	MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      	return 
  	endif 

	//CriaSX1(cPerg)
	Pergunte(cPerg,.F.)


	 wnrel:="BRFATR58"
	
     wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

     If nLastKey == 27
        Return
     Endif

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif  
     

	//              0         1         2         3        4         5         6         7         8         9         10       11         12       13        14        15        16        17        18        19         20      21
	//         0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Titulo := "Clientes Com Sistema Brasimix - ฺlt. 2 anos" //                        999,999,999,99                                                    
if mv_par11 == 1
	Cabec1 := "UF CIDADE                                          REPRESENTANTE                                       CLIENTE                                         ฺLT COMPRA"
else 
	Cabec1 := "REPRESENTANTE                                       UF CIDADE                                          CLIENTE                                         ฺLT COMPRA"
endif 
Cabec2 := ""
Processa({|| FATR58_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FATR58_1 บ Autor ณ Cleber Orati       บ Data ณ  18/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FATR58_1(Cabec1, Cabec2, Titulo, nLin)

Local cAux,cQuery,cGrupo1,cGrupo2,cGrupo3,nTotal,nCont1,nCont2,nCont3,nCol1,nCol2,nCol3

dbselectarea("SA3")
dbsetorder(1)   
dbselectarea("SZ7")
dbsetorder(1)   

cQuery := "SELECT DISTINCT D2_CLIENTE AS CODCLI,A1_VEND AS VEND,A1_NOME AS RAZAO,A1_CODCID AS CODCID,"+;
"Z7_NOME AS CIDADE,Z7_EST AS UF,A1_ULTCOM AS ULTCOM "+;  
"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (A1_CODCID = Z7_COD) "+;
"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (LEN(D2_COD) = 12) AND (SUBSTRING(D2_COD,4,2) = '00') AND "+;
"(D2_TIPO = 'N') AND (D2_ESTOQUE = 'S') AND (D2_EMISSAO >= CONVERT(VARCHAR,GETDATE()-720,112))"
IF !EMPTY(MV_PAR02)
	cQuery += "AND (D2_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
endif
IF !EMPTY(MV_PAR04)
	cQuery += "AND (A1_VEND BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
endif
//Chamado 007514, tirar c๓digos de repres. especificos do Glaidon 
if __cUserId = "000282"
	cQuery += "AND (A1_VEND NOT IN ('000250','000444','000303','000333','000438','000276')) "
endif 
IF !EMPTY(MV_PAR06)
	cQuery += "AND (A1_CODCID BETWEEN '"+mv_par05+"' AND '"+mv_par06+"') "
endif
IF !EMPTY(MV_PAR07)
	cQuery += "AND (A1_CLAS = '"+ALLTRIM(mv_par07)+"') "
endif                                                   
IF !EMPTY(MV_PAR09)
	cQuery += "AND (D2_EMISSAO BETWEEN '"+DTOS(mv_par08)+"' AND '"+DTOS(mv_par09)+"') "
endif
if !empty(MV_PAR10)   
	cAux := U_RegiaoGeo(MV_PAR10)
	if !empty(cAux)
		cQuery += "AND (A1_EST IN ("+cAux+")) "
	endif 
endif		                           
if !empty(MV_PAR12)
	cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR12)+") "
endif
if !empty(MV_PAR13)
	cQuery += "AND ("+U_ParamSql("A1_EST",MV_PAR13)+") "
endif

cQuery += "ORDER BY "  
if MV_PAR11 == 1
	cQuery += "UF,CIDADE,VEND"
ELSE
	cQuery += "VEND,UF,CIDADE"
ENDIF 
cQuery += ",ULTCOM"
TCQuery cQuery ALIAS "TCQ" NEW  

cGrupo1 := ""
cGrupo2 := ""
cGrupo3 := ""
DO CASE
CASE MV_PAR11 == 1 // UF,CIDADE,VEND
	cGrupo1 := IIF(!EOF("TCQ"),TCQ->UF,"")
	cGrupo2 := IIF(!EOF("TCQ"),TCQ->CODCID,"")
	cGrupo3 := IIF(!EOF("TCQ"),TCQ->VEND,"")
CASE MV_PAR11 == 2 // VEND,UF,CIDADE
	cGrupo1 := IIF(!EOF("TCQ"),TCQ->VEND,"")
	cGrupo2 := IIF(!EOF("TCQ"),TCQ->UF,"")
	cGrupo3 := IIF(!EOF("TCQ"),TCQ->CODCID,"")
ENDCASE 		


dbselectarea("TCQ")
DbGoTop()

nQtdRec := 30  
nCont1 := 0
nCont2 := 0
nCont3 := 0
nTotal := 0
ProcRegua(nQtdRec)
DbSelectArea("TCQ")
DbGoTop()
While !Eof()
	If nLin > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
		nLin += 1
	Endif                
	If lAbortPrint
		@ nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
			

	nTotal++
	nCont1++
	nCont2++
	nCont3++

	IF MV_PAR11 == 1
		@ nLin, 000 PSAY TCQ->UF 
		@ nLin, 003 PSAY TCQ->CIDADE 
		dbselectarea("SA3")
		dbseek(xFilial("SA3")+TCQ->VEND)
		@ nLin, 051 PSAY TCQ->VEND+"-"+IIF(found(),SUBSTR(SA3->A3_NOME,1,40)," ")
	ELSE 
		dbselectarea("SA3")
		dbseek(xFilial("SA3")+TCQ->VEND)
		@ nLin, 000 PSAY TCQ->VEND+"-"+IIF(found(),SUBSTR(SA3->A3_NOME,1,40)," ")
		@ nLin, 052 PSAY TCQ->UF 
		@ nLin, 055 PSAY TCQ->CIDADE 
	ENDIF 

	@ nLin, 103 PSAY TCQ->CODCLI+'-'+SUBSTR(TCQ->RAZAO,1,40)
	@ nLin, 151 PSAY SUBSTR(TCQ->ULTCOM,7,2)+"/"+SUBSTR(TCQ->ULTCOM,5,2) +'/'+SUBSTR(TCQ->ULTCOM,1,4)
	nLin++

	dbselectarea("TCQ")
	dbskip()


	lPassouRegua := .f.
	cMens1 := ""
	cMens2 := ""
	cMens3 := ""
	nCont := 0
	DO CASE
	CASE MV_PAR11 == 1 // UF,CIDADE,VEND   
		if eof() .or. (!eof() .and. !((TCQ->UF+TCQ->CODCID+TCQ->VEND) == (cGrupo1+cGrupo2+cGrupo3)))
			if !lPassouRegua
				lPassouRegua := .t.
				nCont += 2
			endif 
			nCont++ 
			cMens1 := "QTDE DE CLIENTES P/ O REPR "+cGrupo3+", CIDADE DE "+ALLTRIM(Posicione("SZ7", 1, xFilial("SZ7")+cGrupo2, "Z7_NOME"))+"-"+cGrupo1+ " : "+alltrim(transform(nCont3,"@E 9,999,999"))
			nCont3 := 0
			cGrupo3 := IIF(!EOF("TCQ"),TCQ->VEND,"") 
			nCol1 := 51
		endif 
		if eof() .or. (!eof() .and. !((TCQ->UF+TCQ->CODCID) == (cGrupo1+cGrupo2)))
			if !lPassouRegua
				lPassouRegua := .t.
				nCont += 2
			endif 
			nCont++ 
			cMens2 := "QTDE DE CLIENTES P/ A CIDADE DE "+ALLTRIM(Posicione("SZ7", 1, xFilial("SZ7")+cGrupo2, "Z7_NOME"))+"-"+cGrupo1+" : "+alltrim(transform(nCont2,"@E 9,999,999"))
			nCont2 := 0
			cGrupo2 := IIF(!EOF("TCQ"),TCQ->CODCID,"")
			nCol2 := 3
		endif 

		if eof() .or. (!eof() .and. !(TCQ->UF == cGrupo1))
			if !lPassouRegua
				lPassouRegua := .t.
				nCont += 2
			endif 
			cMens3 := "QTDE DE CLIENTES P/ A UF "+cGrupo1+" : "+alltrim(transform(nCont1,"@E 9,999,999"))
			nCont++ 
			nCont1 := 0
			cGrupo1 := IIF(!EOF("TCQ"),TCQ->UF,"")
			nCol3 := 0
		endif 

	CASE MV_PAR11 == 2 // VEND,UF,CIDADE
		if eof() .or. (!eof() .and. !((TCQ->VEND+TCQ->UF+TCQ->CODCID) == (cGrupo1+cGrupo2+cGrupo3)))
			if !lPassouRegua
				lPassouRegua := .t.
				nCont += 2
			endif 
//			cMens1 := "QTDE DE CLIENTES P/ A CIDADE DE "+cGrupo3+" : "+alltrim(transform(nCont3,"@E 9,999,999"))
			cMens1 := "QTDE DE CLIENTES P/ A CIDADE DE "+ALLTRIM(Posicione("SZ7", 1, xFilial("SZ7")+cGrupo3, "Z7_NOME"))+"-"+cGrupo2+", REPRES "+cGrupo1+" : "+alltrim(transform(nCont3,"@E 9,999,999"))
			nCont++ 
			nCont3 := 0
			cGrupo3 := IIF(!EOF("TCQ"),TCQ->CODCID,"")
			nCol1 := 55
		endif 
		if eof() .or. (!eof() .and. !((TCQ->VEND+TCQ->UF) == (cGrupo1+cGrupo2)))
			if !lPassouRegua
				lPassouRegua := .t.
				nCont += 2
			endif 
			cMens2 := "QTDE DE CLIENTES P/ A UF "+cGrupo2+", REPRES "+cGrupo1+" : "+alltrim(transform(nCont2,"@E 9,999,999"))
			nCont2 := 0
			nCont++ 
			cGrupo2 := IIF(!EOF("TCQ"),TCQ->UF,"")
			nCol2 := 52
		endif 

		if eof() .or. (!eof() .and. !(TCQ->VEND == cGrupo1))
			if !lPassouRegua
				lPassouRegua := .t.
				nCont += 2
			endif 
			cMens3 := "QTDE DE CLIENTES P/ O REPR "+cGrupo1+" : "+alltrim(transform(nCont1,"@E 9,999,999"))
			nCont1 := 0
			nCont++ 
			cGrupo1 := IIF(!EOF("TCQ"),TCQ->VEND,"")
			nCol3 := 0
		endif 

	ENDCASE 		
		
	if nCont > 0    
		If (nLin+nCont) > 60 
			nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
			nLin++
		Endif                
		@ nLin,000 psay replicate("-",limite)
		nLin++ 

		if !empty(cMens1)
			@ nLin,nCol1 psay cMens1
			nLin++ 
		endif 
		if !empty(cMens2)
			@ nLin,nCol2 psay cMens2
			nLin++ 
		endif 
		if !empty(cMens3)
			@ nLin,nCol3 psay cMens3
			nLin++ 
		endif 
		@ nLin,000 psay replicate(iif(!empty(cMens3),"=","-"),limite)
		nLin++ 
	endif 		
				
	DO CASE
	CASE MV_PAR11 == 1 // UF,CIDADE,VEND
		cGrupo1 := IIF(!EOF("TCQ"),TCQ->UF,"")
		cGrupo2 := IIF(!EOF("TCQ"),TCQ->CODCID,"")
		cGrupo3 := IIF(!EOF("TCQ"),TCQ->VEND,"")
	CASE MV_PAR11 == 2 // VEND,UF,CIDADE
		cGrupo1 := IIF(!EOF("TCQ"),TCQ->VEND,"")
		cGrupo2 := IIF(!EOF("TCQ"),TCQ->UF,"")
		cGrupo3 := IIF(!EOF("TCQ"),TCQ->CODCID,"")
	ENDCASE 		

ENDDO 	

If (nLin+2) > 60 
	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	nLin += 1
Endif                

@ nLin, 000 PSAY Replicate("=", limite)
nLin++
@ nLin, 000 PSAY 'QTDE TOTAL DE CLIENTES ===>>>>>>'+alltrim(transform(nTotal,"@E 9,999,999"))
nLin++
@ nLin, 000 PSAY Replicate("=", limite)
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
/*
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
	PutSX1(cPerg, "11",   "Ordenar por", "Ordenar por", "Ordenar por", "mv_chb", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par11", "UF/Cidade/Repr"       , "UF/Cidade/Repr", "UF/Cidade/Repr", "","Repr/UF/Cidade", "Repr/UF/Cidade","Repr/UF/Cidade", "","","", "", "", ""     , "" ,  "",  ""  , Nil  , Nil     , Nil     ,cPerg)
	PutSX1(cPerg, "12",   "Segmento(s)","Segmento(s) ", "Segmento(s)","mv_chc", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_par12","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "13",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_chd", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par13","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)

Return
*/