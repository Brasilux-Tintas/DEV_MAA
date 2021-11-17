#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFATR25()
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Define Variaveis                                             ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
PRIVATE CbTxt
PRIVATE Titulo	:= "Rel Acompanhamento Tinta Po"
PRIVATE cDesc1	:=""
PRIVATE cDesc2	:=""
PRIVATE cDesc3 	:= "" 
PRIVATE cCabec1 := "Pedido  QtdVen Codigo        Descricao                       Qtde  Dt Aprov. DiasAp Estq   Programa   Prev Desp   Carga  Qtd Op Ab"
PRIVATE cCabec2 := ""  
PRIVATE nTipo 	:= 18
PRIVATE Tamanho	:= "M"
PRIVATE Limite 	:= 132
PRIVATE cString	:= "SA1"
PRIVATE m_pag   := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BRFATR25"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BRFATR25"

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Verifica as perguntas selecionadas                           ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU
    
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)
//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Envia controle para a funcao SETPRINT                        ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

wnrel:= "BRFATR25"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Inicio do Processamento do Relatorio                         ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funcao....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
Local cQuery := ""
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA¢¯
//©ø Inicializa  regua de impressao                            ©ø
//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU

cQuery :=" SELECT SC6.C6_NUM, SC6.C6_PRODUTO, SB1.B1_DESC, ISNULL(ZZC.ZZC_CARGA,'') AS ZZC_CARGA,CASE WHEN(LEN(B2_LOCALIZ)<>'') THEN '*' ELSE '' END AS B2_LOCALIZ, SB1.B1_ESTOQUE AS ESTOQUE, "
cQuery +=" ISNULL(SUBSTRING(ZA_PREVDSP,7,2)+'/'+SUBSTRING(ZA_PREVDSP,5,2)+'/'+SUBSTRING(ZA_PREVDSP,1,4),'') AS ZA_PREVDSP,ISNULL(SUM(ZZC.ZZC_QUANTI - ZZC.ZZC_RETIRA),SC6.C6_QTDVEN) AS ZZC_QUANTI, "
cQuery +=" CASE WHEN C5_DTAPR ='' THEN 0 ELSE DATEDIFF(D,C5_DTAPR,GETDATE()) END AS 'DIASAPROVADOS', ISNULL(SUM(SC2.C2_QUANT - SC2.C2_QUJE),0) AS 'OPEMABERTO', "
cQuery +=" SUBSTRING(SC5.C5_PEDPROG,7,2)+'/'+SUBSTRING(SC5.C5_PEDPROG,5,2)+'/'+SUBSTRING(SC5.C5_PEDPROG,1,4) AS C5_PEDPROG, C5_DTAPR AS DATLOG,C6_QTDVEN "
cQuery +=" FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("ZZC")+" ZZC WITH (NOLOCK) ON (ZZC.ZZC_FILIAL = SC6.C6_FILIAL) AND (ZZC.ZZC_PEDIDO = SC6.C6_NUM) AND (ZZC.ZZC_PRODUT = SC6.C6_PRODUTO) AND (ZZC.D_E_L_E_T_ ='') AND (ZZC.ZZC_SEPARA = 'N') "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.B1_FILIAL = SC6.C6_FILIAL) AND (SB1.B1_COD = SC6.C6_PRODUTO) AND (SB1.D_E_L_E_T_ ='') "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON (SZA.ZA_FILIAL = ZZC.ZZC_FILIAL) AND (SZA.ZA_CODIGO = ZZC.ZZC_CARGA) AND (SZA.D_E_L_E_T_ ='') "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.B2_FILIAL = SB1.B1_FILIAL) AND (SB2.B2_COD = SB1.B1_COD) AND (SB2.B2_LOCAL = SB1.B1_LOCPAD) AND (SB2.D_E_L_E_T_ ='') "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.C5_FILIAL = SC6.C6_FILIAL) AND (SC5.C5_NUM = SC6.C6_NUM) AND (SC5.D_E_L_E_T_ ='') "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON (SC2.C2_FILIAL = SC6.C6_FILIAL) AND (SC2.C2_PRODUTO = SC6.C6_PRODUTO) AND (SC2.D_E_L_E_T_ ='') AND (SC2.C2_DATRF   = '') "
cQuery +=" WHERE (SC6.C6_FILIAL = '"+xFilial("SC6")+"') AND (SC6.D_E_L_E_T_ = '') AND (SB1.B1_TIPO IN('PI','PA')) "
cQuery +=" AND (SUBSTRING(SC6.C6_PRODUTO, 4, 2) IN('97','98','99')) AND (SC6.C6_NOTA ='') AND (SB1.B1_LOCPAD IN('03','P1')) "
cQuery +=" AND (SC6.C6_PRODUTO BETWEEN ('"+(MV_PAR02)+"') AND ('"+(MV_PAR03)+"') ) "

If MV_PAR04 = 1
	cQuery +=" AND SUBSTRING(SC6.C6_PRODUTO,11,2) NOT IN('38') "
Endif
If MV_PAR05 = 1
	cQuery +=" AND C5_DTAPR <> '' "
Endif

cQuery +=" GROUP BY ZZC.ZZC_BORDER , SC6.C6_NUM, SC6.C6_PRODUTO, ZZC.ZZC_CARGA, SB1.B1_DESC, ZZC.ZZC_PRODUT, ZA_PREVDSP, B2_LOCALIZ, SC6.C6_QTDVEN, ZZC_QUANTI, ZZC_RETIRA, C5_PEDPROG,C5_DTAPR, C6_QTDVEN, SB1.B1_ESTOQUE "
If MV_PAR01 = 1
	cQuery +=" ORDER BY ZZC.ZZC_CARGA, ZZC.ZZC_PRODUT "
ElseIf MV_PAR01 = 2
	cQuery +=" ORDER BY DIASAPROVADOS DESC, SC6.C6_NUM "
ElseIf MV_PAR01 = 3
	cQuery +=" ORDER BY ZZC.ZZC_PRODUT, SC6.C6_NUM "
EndIf

TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT())
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 08
While !Eof()
	if _nLin > 60                                                                    	
		@ _nLin,000 psay replicate("_",132)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	endif 
	@ _nLin,000 psay TCQ->C6_NUM
  	@ _nLin,009 psay TCQ->C6_QTDVEN
  	@ _nLin,015 psay TCQ->C6_PRODUTO
	@ _nLin,029 psay SUBSTR(TCQ->B1_DESC,0,30)
	@ _nLin,061 psay TCQ->ZZC_QUANTI
	@ _nLin,067 psay Substr(TCQ->DATLOG,7,2)+"/"+Substr(TCQ->DATLOG,5,2)+"/"+Substr(TCQ->DATLOG,3,2) 
	@ _nLin,078 psay TCQ->DIASAPROVADOS
	If TCQ->ESTOQUE !=' '
		@ _nLin,084 psay "*" 
	EndIf
	@ _nLin,089 psay TCQ->C5_PEDPROG
	@ _nLin,102 psay TCQ->ZA_PREVDSP
	@ _nLin,115 psay TCQ->ZZC_CARGA
	@ _nLin,125 psay TCQ->OPEMABERTO
	 
	
	@ _nLin++
	dbselectarea("TCQ")
	dbskip()          
	if Eof()
		@ _nLin,000 psay replicate("_",132)
	endif 
EndDo
	dbSelectArea("TCQ")
    dbCloseArea()
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

/* DESABILITADO RELEASE 12.1.25
Static Function CriaSX1(cPerg)	

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"Ordem da consulta"},  {""}, {""}})
AAdd(aHelp, {{"de Produto"},  {""}, {""}})
AAdd(aHelp, {{"ate Produto"},  {""}, {""}})
AAdd(aHelp, {{"Filtra Amostras ?"},  {""}, {""}})                                           
AAdd(aHelp, {{"Filtra pedidos aprovados ?"},  {""}, {""}})                                           

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Ordenar por:    			 " ,"","","mv_ch1","N", 1,00,00 ,"C","","","","","MV_PAR01","Bordero","","","","Data Descrescente","","","Produto","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","de Produto:     			 " ,"","","mv_ch2","C",15,00,00 ,"G","","SB1","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","ate Produto:    			 " ,"","","mv_ch3","C",15,00,00 ,"G","","SB1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Filtra Amostra? 			 " ,"","","mv_ch4","N", 1,00,00 ,"C","","","","","MV_PAR04","Sim","","","","Nao","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Filtra pedidos aprovados? " ,"","","mv_ch5","N", 1,00,00 ,"C","","","","","MV_PAR05","Sim","","","","Nao","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")

Return
*/