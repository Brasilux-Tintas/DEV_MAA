#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFATR57 บ Autor ณ Cleber Orati       บ Data ณ  23/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ped Faturados x em Carteira                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFATR57()
     Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
     Local cDesc2        := "de acordo com os parametros informados pelo usuario."
     Local cDesc3        := "Resumo de Vendas"
     //Local cPict         := ""
     Local titulo        := "Ped Faturados x em Carteira"
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
     Private nomeprog    := "BRFATR57" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
     Private nLastKey    := 0
     Private cPerg       := "BRFATR57"
     //Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFATR57" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SC5"
	Private	MV_PAR10,MV_PAR11,MV_PAR12
         
	if !u_VldAcesso(funname())
      	MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      	return 
  	endif 
     u_zcfga01( 'BRFATR57' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
	//CriaSX1(cPerg)
	Pergunte(cPerg,.F.)


	 wnrel:="BRFATR57"
	
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
	Titulo := "Pedidos Faturados x Pedidos em Carteira" //                        999,999,999,99                                                    
	Cabec1 := "REPRESENTANTE                                   PEDIDO EMISSAO              VALOR CLIENTE                                  FATURADO?"
Cabec2 := ""
Processa({|| FATR57_1(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ FATR57_1 บ Autor ณ Cleber Orati       บ Data ณ  18/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FATR57_1(Cabec1, Cabec2, Titulo, nLin)
Local cAux,cQuery,nSoma,nSomaFN,cRepr,cFat,nSomaF,nSomaN

dbselectarea("SA3")
dbsetorder(1)   

cQuery := "SELECT C5_VEND1 AS VEND,C5_NUM AS PEDIDO,C5_EMISSAO AS EMISSAO,C5_VLRDUP,C5_CLIENTE,A1_NOME,C5_NOTA "+;
"FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (C5_CLIENTE = A1_COD) "+;
"WHERE (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_TIPO = 'N') AND (C5_VLRDUP > 0) AND (C5_APROVA <> '2') "
IF !EMPTY(MV_PAR02)
	cQuery += "AND (C5_CLIENTE BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
endif
IF !EMPTY(MV_PAR04)
	cQuery += "AND (C5_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') "
endif
//Chamado 007514, tirar c๓digos de repres. especificos do Glaidon 
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
	cQuery += "AND (C5_EMISSAO BETWEEN '"+DTOS(mv_par08)+"' AND '"+DTOS(mv_par09)+"') "
endif
if !empty(MV_PAR10)   
	cAux := U_RegiaoGeo(MV_PAR10)
	if !empty(cAux)
		cQuery += "AND (A1_EST IN ("+cAux+")) "
	endif 
endif		                           
if !empty(MV_PAR11)
	cQuery += "AND ("+U_ParamSql("A1_SATIV2",MV_PAR11)+") "
endif
if !empty(MV_PAR12)
	cQuery += "AND "+U_ParamSql("A1_EST",MV_PAR12)+" "
endif


cQuery += "ORDER BY VEND,C5_NOTA,PEDIDO"
TCQuery cQuery ALIAS "TCQ" NEW  
dbselectarea("TCQ")
DbGoTop()



nQtdRec := 30
nSoma := 0
nSomaF := 0
nSomaN := 0
nSomaT := 0
nSomaFN := 0
ProcRegua(nQtdRec)
DbSelectArea("TCQ")
DbGoTop()
if !eof() .and. !bof()
	cRepr := TCQ->VEND
	cFat := IIF(!EMPTY(TCQ->C5_NOTA),"S","N")
else
	cRepr := ""
	cFat := ""
endif 	
While !Eof()
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

	@ nLin, 048 PSAY TCQ->PEDIDO 
	@ nLin, 055 PSAY SUBSTR(TCQ->EMISSAO,7,2)+"/"+SUBSTR(TCQ->EMISSAO,5,2) +'/'+SUBSTR(TCQ->EMISSAO,1,4)
	@ nLin, 067 PSAY TCQ->C5_VLRDUP PICTURE "@E 999,999,999.99" 
	@ nLin, 082 PSAY TCQ->C5_CLIENTE+'-'+SUBSTR(TCQ->A1_NOME,1,40)
	@ nLin, 131 PSAY IIF(!EMPTY(TCQ->C5_NOTA),"S","N")
	 
    nSoma += TCQ->C5_VLRDUP
    nSomaF += IIF(!EMPTY(TCQ->C5_NOTA),TCQ->C5_VLRDUP,0)
    nSomaN += IIF(!EMPTY(TCQ->C5_NOTA),0,TCQ->C5_VLRDUP)
    nSomaFN += TCQ->C5_VLRDUP
    nSomaT += TCQ->C5_VLRDUP

	dbselectarea("TCQ")
	dbskip()

	nLin++
	if eof() .or. (!eof() .and. !((TCQ->VEND+IIF(!EMPTY(TCQ->C5_NOTA),"S","N")) == (cRepr+cFat)))
	
		if (nLin+3) > 60
			nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
			nLin += 1
		endif 
		@ nLin, 005 PSAY Replicate("-", 76)
		nLin++                       
		@ nLin, 005 PSAY "TOTAL "+iif(cFat = "S","FATURADO ","SEM FATURAR ")+" ====>>>>>"
		@ nLin, 067 PSAY nSomaFN PICTURE "@E 999,999,999.99" 
		nLin++                       
		@ nLin, 005 PSAY Replicate("-", 76)
		nLin++                       
		cFat := IIF(!EMPTY(TCQ->C5_NOTA),"S","N")     
		nSomaFN := 0
	endif 
	if eof() .or. (!eof() .and. !(TCQ->VEND == cRepr))
		if (nLin+2) > 60
			nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
			nLin += 1
		endif 
		@ nLin, 000 PSAY "TOTAL PARA O REPRESENTANTE =====>>>>>"
		@ nLin, 067 PSAY nSoma PICTURE "@E 999,999,999.99" 
		nLin++                       
		@ nLin, 000 PSAY Replicate("=", limite)
		nLin++     
		cRepr := TCQ->VEND
		nSoma := 0
	endif 

ENDDO 	

If (nLin+4) > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
	nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	nLin += 1
Endif                

@ nLin, 000 PSAY Replicate("=", limite)
nLin++
@ nLin, 000 PSAY 'TOTAL NAO FATURADO ===>>>>>>'
@ nLin, 067 PSAY nSomaN PICTURE "@E 999,999,999.99" 
nLin++
@ nLin, 000 PSAY 'TOTAL FATURADO     ===>>>>>>'
@ nLin, 067 PSAY nSomaF PICTURE "@E 999,999,999.99" 
nLin++
@ nLin, 000 PSAY 'TOTAL GERAL        ===>>>>>>'
@ nLin, 067 PSAY nSomaT PICTURE "@E 999,999,999.99" 
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
	PutSX1(cPerg, "11",   "Segmento(s)    ","Segmento(s)    ", "Segmento(s)   ","mv_chb", "C", 99,00,00, "G",  "", "T3",  "",  "", "mv_par11","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
	PutSX1(cPerg, "12",   "Estado(s)          ", "Estado(s)          ", "Estado(s)          ", "mv_chc", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par12","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil ,cPerg)

Return
*/
