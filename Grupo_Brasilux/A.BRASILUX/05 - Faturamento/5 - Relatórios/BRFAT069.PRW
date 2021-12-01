#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT069 ºAutor  ³ Cleber O. Dominguesº Data ³  09/04/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Produtos vendidos, por Litro                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Variaveis utilizadas para parametros
mv_par01     // Dt. Lib. de
mv_par02     // Dt. Lib Ate
mv_par03     // Repres. de
mv_par04     // Repres. Até
mv_par05     // Linha
*/
User Function BRFAT069()


     Local cDesc1  := PADC("Este programa ira emitir o relatório de produtos faturados em litros.", 74)
     Local cDesc2  := PADC("de acordo com os parametros informados pelo usuario.", 74)
     Local cDesc3  := PADC(" ", 74)
     Local titulo  := "PRODUTOS FATURADOS(EM LITROS)"
     Local nLin    := 0
     Local cCabec1 := ""
     Local cCabec2 := ""
     Local aOrd    := {}

     Private lEnd        := .F.
     Private lAbortPrint := .F.
     Private limite      := 80
     Private tamanho     := "P"
     Private nomeprog    := "BRFAT069" // Coloque aqui o nome do programa para impressao no cabecalho
     Private nTipo       := 18
     Private aReturn     := { "Especial", 1, "Administracao", 1, 2, 1, "", 1 }
     Private nLastKey    := 0
     Private cPerg       := "BRFT69"
     Private cbtxt       := Space(10)
     Private cbcont      := 00
     Private CONTFL      := 01
     Private m_pag       := 01
     Private wnrel       := "BRFAT069" // Coloque aqui o nome do arquivo usado para impressao em disco
     Private cString     := "SD2"

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Envia controle para a funcao SETPRINT                        ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 if !u_VldAcesso(funname())
         MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      	 return 
	 endif 
     u_zcfga01( 'BRFAT069' ) //LGS#2021201 - Gravação de log de utilização da rotina
     ValidPerg()
     Pergunte(cPerg, .F.)   

     wnrel := SetPrint(cString, wnrel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .f., Tamanho, ,.F.)

     If nLastKey == 27
        Return
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Verifica Posicao do Formulario na Impressora                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     SetDefault(aReturn, cString)

     If nLastKey == 27
        Return
     Endif

     nTipo := If(aReturn[4] == 1, 15, 18)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Inicio do Processamento do Relatorio                         ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Processa({|| RunReport(cCabec1, cCabec2, Titulo, nLin) }, Titulo)
Return

Static Function RunReport(cCabec1, cCabec2, Titulo, nLin)
    
    Local cEmpresa, cProduto, nSomaVol, cUm,cQuery
    cEmpresa := SubStr(cnumemp, 1, 2)

	cUm := iif(mv_par08 == 1,"'L'",iif(mv_par08 == 2,"'K','KG'","'K','KG','L'"))    
    cQuery :=          "WITH TMP AS ("
	//Saídas
	cQuery += "SELECT D2_COD AS PRODUTO,SUM(D2_QUANT) AS QTDE,MAX(B1_DESC) AS DESCR,"+;
	"VOLUME = SUM(CASE WHEN D2_UM IN ("+cUm+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUm+") THEN D2_QTSEGUM ELSE 0 END) "+;
	"FROM  "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
	IF !empty(mv_par04)
	     cQuery := cQuery + "LEFT OUTER JOIN  "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = F2_FILIAL) AND (F2_DOC = D2_DOC) AND (D2_SERIE = F2_SERIE) AND (D2_CLIENTE = F2_CLIENTE) "
	ENDIF 	    
	cQuery := cQuery + "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "
	cQuery := cQuery + "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D2_FILIAL = B1_FILIAL) AND (D2_COD = B1_COD) "
	cQuery := cQuery + " WHERE (SD2.D_E_L_E_T_ <> '*') AND (SD2.D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND "+;
	"((D2_UM IN ("+cUm+")) OR (D2_SEGUM IN ("+cUm+"))) AND "
	cQuery := cQuery + "((F4_DUPLIC <> 'N') OR (D2_TES = '519')) AND "
	If !Empty(mv_par05)
		cQuery := cQuery + "(LEN(D2_COD) = 12) AND "+U_ParamSql("SUBSTRING(D2_COD,4,2)",MV_PAR05)+" AND "
	Endif
	If mv_par06 == 1
       	cQuery += "(B1_ESTOQUE = 'S') AND "
	endif
	If mv_par07 == 1
 		cQuery += "(LEN(D2_COD) = 12) AND "
	endif
	IF !empty(mv_par04)
     	cQuery := cQuery + " (SF2.F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') AND "
 	ENDIF
	cQuery := cQuery + "(SD2.D2_EMISSAO BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"') "
	cQuery := cQuery + "GROUP BY D2_COD "

	cQuery += "UNION ALL "
	//Devoluções
	cQuery += "SELECT D1_COD AS PRODUTO,SUM(D1_QUANT) AS QTDE,MAX(B1_DESC) AS DESCR,"+;
	"VOLUME = -1*SUM(CASE WHEN D1_UM IN ("+cUm+") THEN D1_QUANT WHEN D1_SEGUM IN ("+cUm+") THEN D1_QTSEGUM ELSE 0 END) "+;
	"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
	IF !empty(mv_par04)
	     cQuery := cQuery + "LEFT OUTER JOIN  "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D1_FILIAL = F2_FILIAL) AND (D1_NFORI = F2_DOC) AND (D1_SERIORI = F2_SERIE) AND (D1_FORNECE = F2_CLIENTE) "
	ENDIF 	    
	cQuery := cQuery + "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D1_TES = F4_CODIGO) "
	cQuery := cQuery + "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = B1_FILIAL) AND (D1_COD = B1_COD) "
	cQuery := cQuery + " WHERE (SD1.D_E_L_E_T_ <> '*') AND (SD1.D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'D') AND "+;
	"((D1_UM IN ("+cUm+")) OR (D1_SEGUM IN ("+cUm+"))) AND (F4_DUPLIC <> 'N') AND "
	If !Empty(mv_par05)
		cQuery := cQuery + "(LEN(D1_COD) = 12) AND "+U_ParamSql("SUBSTRING(D1_COD,4,2)",MV_PAR05)+" AND "
	Endif
	If mv_par06 == 1
       	cQuery += "(B1_ESTOQUE = 'S') AND "
	endif
	If mv_par07 == 1
 		cQuery += "(LEN(D1_COD) = 12) AND "
	endif
	IF !empty(mv_par04)
     	cQuery := cQuery + "(SF2.F2_VEND1 BETWEEN '"+mv_par03+"' AND '"+mv_par04+"') AND "
 	ENDIF
	cQuery := cQuery + "(SD1.D1_DTDIGIT BETWEEN '"+DTOS(Mv_Par01)+"' AND '"+DTOS(Mv_Par02)+"') "
	cQuery := cQuery + "GROUP BY D1_COD), TMP1 AS ("+;
	"SELECT PRODUTO,MAX(DESCR) AS DESCRICAO,SUM(QTDE) AS QTDE,SUM(VOLUME) AS VOLUMED,MAX(B2_LOCALIZ) AS LOCALIZ "+;
	"FROM TMP "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (TMP.PRODUTO = B1_COD) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B2_FILIAL = B1_FILIAL) AND (B2_COD = B1_COD) AND (B2_LOCAL = B1_LOCPAD) "+;
	"GROUP BY PRODUTO HAVING SUM(VOLUME) <> 0), "+;
	"TMP2 AS (SELECT SUBSTRING(PRODUTO,1,10) AS RAIZ,SUM(VOLUMED) AS VOLUME,SUM(QTDE) AS QTDE FROM TMP1 GROUP BY SUBSTRING(PRODUTO,1,10)) "+;
	"SELECT TMP2.RAIZ,TMP1.PRODUTO,TMP1.DESCRICAO,TMP1.QTDE AS QTDE1,TMP1.VOLUMED AS VOLUME1,TMP2.VOLUME,TMP1.LOCALIZ,"+;
	"TMP2.QTDE FROM TMP1,TMP2 "+;
	"WHERE TMP2.RAIZ = SUBSTRING(TMP1.PRODUTO,1,10) ORDER BY TMP2.VOLUME DESC,TMP2.RAIZ "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TCQ",.T.,.T.)
	//TCQuery cQuery NEW ALIAS "TCQ" 
	/*
     aTcq = {}    
     AADD(aTcq,{"RAIZ","C",10,0})
     AADD(aTcq,{"PRODUTO","C",15,0})
     AADD(aTcq,{"DESCRICAO","C",80,0})
     AADD(aTcq,{"LOCALIZ","C",20,0})
     AADD(aTcq,{"VOLUME","N",13,2})
     AADD(aTcq,{"QTDE","N",12,1})
	

	cArq := U_NovoArqTrab("dtc")
	cNomeAlias := U_NovoCursor()
	dbcreate(cArq+".dtc",aTcq,"CTREECDX")     
	USE (cArq+".dtc") ALIAS &cNomeAlias VIA "CTREECDX" NEW 


	dbselectarea('TCQ')
	dbgotop()
	while !eof()
		cProduto = substr(TCQ->PRODUTO,1,10)
		dbselectarea("TCQ")
//		nVolume = iif(LEN(ALLTRIM(TCQ->PRODUTO)) == 12,0,TCQ->VOLUME)
		nVolume := 0
		nCont := 0
		while !eof() .and. (alltrim(cProduto) == alltrim(substr(tcq->produto,1,10))) 
				nCont++ 
				nVolume += TCQ->VOLUME   
				dbselectarea(cNomeAlias)
				reclock(cNomeAlias,.t.)
				replace produto with TCQ->PRODUTO
				replace raiz with substr(cProduto,1,10)
				replace qtde with tcq->qtde
				REPLACE descricao with substr(tcq->descricao,1,30)
				replace localiz with tcq->localiz
				msunlock()
				if nCont == 1
					nReg := recno()
				endif 
			dbselectarea("TCQ")
			dbskip()
		enddo
		dbselectarea(cNomeAlias)
		dbgoto(nReg)
		while !eof() .and. (alltrim(cProduto) == alltrim((cNomeAlias)->raiz)) 
			reclock(cNomeAlias,.f.)
			replace volume with round(nVolume,1)
			msunlock()
			dbskip()
		enddo 
		dbselectarea("TCQ")
	enddo
	dbSelectArea("TCQ")
	dbclosearea()
*/

//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//														     9,999,999.99	
cCabec2  := "Produto         Descricao                       "+padl("Qtde("+iif(mv_par08 == 1,"Litros","KG")+")",12," ")
cCabec1  := "NF's EMITIDAS ENTRE "+dtoc(mv_par01) +" ATE "+dtoc(mv_par02)
cCabec1 += IF(!EMPTY(mv_par04),", REPR. DE "+mv_par03+" ATE' "+mv_par04,"")

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
nLin = 08
/*
dbSelectArea(cNomeAlias)
index on volume tag volume desc
DbSetIndex(cArq)
DbSetOrder(1)
dbgotop()
*/  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
dbselectarea("TCQ")
dbgotop()

nSomaVol = 0
ProcRegua(Reccount())
While ! EoF()         
  	if nLin > 60
  		nLin++
  		@nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08
	endif
	cProduto = ALLTRIM(TCQ->RAIZ)

   	nLin++
   	@nLin,00 psay cProduto picture "@R XXX99.99.999"
 	@nLin,16 psay SUBSTR(TCQ->DESCRICAO,1,30)
   	@nLin,48 psay TCQ->VOLUME picture "@E 9,999,999.99"
   	nSomaVol += TCQ->VOLUME
	
	while !eof() .and. (alltrim(cProduto) == ALLTRIM(TCQ->RAIZ))
	  	if nLin > 60
  			nLin++
  			@nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			nLin := 08
		endif
		nLin++
		@nLin,16 psay TCQ->PRODUTO picture "@R XXX99.99.999.99"
		@nLin,32 psay TCQ->QTDE1 picture "@E 999,999"
		@nLin,40 psay alltrim(TCQ->localiz)
		dbselectarea("TCQ")
		dbskip()
		IncProc()		   	
	enddo
					
   	dbselectarea("TCQ")
Enddo

  	if (nLin+3) > 60
  		nLin++
  		@nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		nLin := 08
	endif

  nLin++
  	@nLin,00 psay replicate("_",80)
  	nLin++
	@nLin,46 psay nSomaVol picture "@E 999,999,999.99"
  nLin++
  	@nLin,00 psay replicate("_",80)
  		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TCQ")
dbCloseArea()
/*
if file(cArq+".dtc")
	cAux = cArq+".dtc"
	delete file &cAux
endif
if file(cArq+".cdx")
	cAux = cArq+".cdx"
	delete file &cAux
endif

if file(cArq+".idx")
	cAux = cArq+".idx"
	delete file &cAux
endif

if file(cArq+".ntx")
	cAux = cArq+".ntx"
	delete file &cAux
endif
*/
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Programa  : VALIDPERG   Autor:  M
Data      : 28/03/02
Descricao : Grava Perguntas
/*/
Static Function ValidPerg()
       Local aHelp := {}
       cPerg := PADR(cPerg, 10)
	   AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       U_xPutSx1(cPerg, "01",   "Linha(s) Produto"   , "Linha(s) Produto"   , "Linha(s) Produto"   , "mv_ch1", "C", 99,00,00, "G",  "", "",  "",  "", "mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
       U_xPutSx1(cPerg,"01","Data Emissao de   ?","Data Emissao de   ?","Data Emissao de   ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","")
       U_xPutSx1(cPerg,"02","Data Emissao Ate' ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","")
       U_xPutSx1(cPerg,"03","Repres. De        ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA3","")
       U_xPutSx1(cPerg,"04","Repres Ate        ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA3","")
       U_xPutSx1(cPerg,"05","Linha(s) Produto"    ,"Linha(s) Produto","Linha(s) Produto","mv_ch5","C",99,00,00,"G","","","","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
	   U_xPutSx1(cPerg,"06","Somente Estoque   ?","","","mv_ch6","N",01,0,2,"C","","mv_par06","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","")
       U_xPutSx1(cPerg, "07"  ,  "Somente Tintas     ?", "Somente Tintas     ?", "Somente Tintas     ?", "mv_ch7", "N",  1, 0, 1, "C"  , "","","","", "mv_par07","Sim", "Si", "Yes"   , ""   , "Não", "No", "No", "", "", "" , "", "", "", "", "", "",{},{},{}, "" )
	   U_xPutSx1(cPerg, "08",  "Litro ou Kg", "Litro ou Kg", "Litro ou Kg", "mv_ch8", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par08", "Litros"       , "Litros", "Litros", "","Kilogramas", "Kilogramas","Kilogramas", "","","", "", "", ""     , "5" ,  "",  ""  , {},{},{}     ,cPerg)
       
Return

