#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BREXPR09()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "REL QUADRANTES OCUPADOS / SP"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := "ENDEREÇO         NUMPED  CODCLI  RAZÃO                     DATA          PALLET"
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "BREXPR09"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "BREXPR09"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
//CriaSX1(cPerg)  //LGS#20200210 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "BREXPR09"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery :="SELECT ZZU_ENDERE, ZZU_PEDIDO, ZZU_CODCLI, A1_NOME, ZZU_DTINCL,ZZU_PALLET "
cQuery +="FROM "+RetSqlName("ZZU")+" ZZU WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("ZZT")+" ZZT WITH (NOLOCK) ON ZZT.D_E_L_E_T_ <> '*' AND (ZZU_FILIAL = ZZT_FILIAL) AND ZZT_CODIGO = ZZU_ENDERE "
cQuery +="LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.D_E_L_E_T_ <> '*' AND ZZU_CODCLI  = A1_COD "
cQuery +="WHERE (ZZU_FILIAL = '"+xFilial("ZZU")+"') AND ZZU.D_E_L_E_T_ <> '*' AND ZZT_STATUS <> '1' AND (ZZU_DTINCL BETWEEN ('"+dTos(MV_PAR01)+"') AND ('"+dTos(MV_PAR02)+"')) AND "
If MV_PAR03 == 1
	cQuery +="ZZT_TIPO = '1' "
elseif MV_PAR03 == 2            
	cQuery +="ZZT_TIPO = '2' "
else       
	cQuery +="ZZT_TIPO = '3' "
EndIf
If MV_PAR04 == 1
	cQuery +="ORDER BY ZZU_DTINCL"
Else
	cQuery +="ORDER BY ZZU_ENDERE"
Endif
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT( )) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)                       
While !Eof()
	if _nLin > 55                                                                    	
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	endif 
	@ _nLin,000 psay TCQ->ZZU_ENDERE
	@ _nLin,017 psay TCQ->ZZU_PEDIDO
	@ _nLin,025 psay TCQ->ZZU_CODCLI
	@ _nLin,033 psay SUBSTR(TCQ->A1_NOME,0,25)
	@ _nLin,060 psay SUBSTR(TCQ->ZZU_DTINCL,7,2)+"/"+SUBSTR(TCQ->ZZU_DTINCL,5,2)+"/"+SUBSTR(TCQ->ZZU_DTINCL,0,4)
	@ _nLin,072 psay Transform(TCQ->ZZU_PALLET,"@E 9.999")
	@ _nLin++
   	dbselectarea("TCQ")
 	dbskip()
EndDo
	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 08
	endif
	
	dbSelectArea("TCQ")
    dbCloseArea( )

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return

//LGS#20200210 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"de Emissao"}  ,  {""}, {""}})
AAdd(aHelp, {{"ate Emissao"} ,  {""}, {""}})
AAdd(aHelp, {{"de Tipo"}  ,  {""}, {""}})
AAdd(aHelp, {{"Ordenar por"}  ,  {""}, {""}})

//(<cGrupo>,<cOrdem>,<Pergunt>,< cPergSpa>,< cPergEng>,< cVar>,< cTipo>,< nTamanho>,[ nDecimal],[ nPreSel],<cGSC>,[ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","de data: "  ,"","","mv_ch1","D",8 ,00,00,"G","",""   ,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate data: " ,"","","mv_ch2","D",8 ,00,00,"G","",""   ,"","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Tipo: " ,"","","mv_ch3","N",1 ,00,00,"C","",""   ,"","","MV_PAR03","Pequeno","","","","Normal","","","Doca","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Ordernar por: " ,"","","mv_ch4","N",1 ,00,00,"C","",""   ,"","","MV_PAR04","Data","","","","Endereco","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
Return*/