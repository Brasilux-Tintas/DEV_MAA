#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFAT099()
     Local _lPAR0041 := GETMV("ZP_PAR0041")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Minuta de Despacho"
PRIVATE cDesc1 := "Este relatorio ira emitir a relacao de Recibos"
PRIVATE cDesc2 := "de Despacho para as transportadoras."
PRIVATE cDesc3 := ""
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""   
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SF2"
private m_pag    := 01  
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }			
PRIVATE nomeprog:="BRFAT099"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRFAT099"
     
If _lPAR0041
   U_ZFATR01()
   Return
Endif
	if !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
		return 
	endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//CriaSX1(cPerg)
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Qual Serie De Nota Fiscal ?              ³
//³ mv_par02        	// Da Nota Fiscal ?                         ³ 
//³ mv_par03        	// Ate a Nota Fiscal ?                      ³
//³ mv_par04        	// Do Bordero de Desp ?                     ³ 
//³ mv_par05        	// Ate Bordedo de Desp                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="BRFAT099"            //Nome Default do relatorio em Disco

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
//                                                     //
// Funçào....: RPTDETAIL    Data....: 01/03/02         //
// Autor.....: Renato P. Zuccolotto                    //
// Descriçao.: Seleciona os dados                      //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////

Static Function RptDetail()
Local cQuery        := ""
Local 	_nCont		:= 0
Local lNormal
Private _nLin 		:= 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



	cQuery:="SELECT F2_FILIAL,F2_DOC,F2_CLIENTE,F2_LOJA,F2_VALBRUT,F2_PBRUTO,F2_PLIQUI,F2_VALMERC,F2_VALIPI,F2_FRETE,F2_PEDIDO,F2_SEGURO,F2_ICMSRET,F2_ESPECI1,F2_ESPECI2,F2_ESPECI3,F2_ESPECI4,F2_VOLUME1,F2_TIPO,F2_REDESP,F2_SERIE,F2_PEDIDO,ZB_PEDIDO,ZG_LOCALIZ "
	cQuery+="FROM "+RETSQLNAME("SF2")+" SF2 WITH (NOLOCK) "
	cQuery+="LEFT OUTER JOIN "+RETSQLNAME("SZB")+" SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND  (ZB_FILIAL = F2_FILIAL) AND (F2_PEDIDO = SUBSTRING(ZB_PEDIDO,3,6)) "
	cQuery+="LEFT OUTER JOIN "+RETSQLNAME("SZG")+" SZG WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND  (ZG_FILIAL = F2_FILIAL) AND (F2_PEDIDO = SUBSTRING(ZG_PEDIDO,3,6)) "
	cQuery+="WHERE (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (F2_SERIE = '"+MV_PAR01+"') AND  (F2_DOC BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"') AND (ZB_CODIGO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"') AND ZB_CODIGO <> '' "
	cQuery+="ORDER BY F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA"


  	TCQuery cQuery NEW ALIAS "TCQ" 

SetRegua(RECCOUNT())
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			

dbselectarea("SA1")
dbsetorder(1)
dbselectarea("SA2")
dbsetorder(1)
dbselectarea("TCQ")
dbgotop()

While !eof()
	_nCont++ 
	if _nCont > 5
		_nCont := 1
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 07
	endif 
 ////imprimir dados minuta

	lNormal := !(TCQ->F2_TIPO $ "DB")
	
	IF lNormal
		dbselectarea("SA1")
		dbseek(xFilial("SA1")+TCQ->F2_CLIENTE)
	ELSE
		dbselectarea("SA2")
		dbseek(xFilial("SA2")+TCQ->F2_CLIENTE)
	ENDIF 		
	
 	_nLin++
 	@ _nLin,000 psay "NF : "+SUBSTR(TCQ->F2_DOC,1,7)+"SERIE :"+SUBSTR(TCQ->F2_SERIE,1,1)   
 	@ _nLin,022 psay "VALOR :" 
	@ _nLin,029 psay (TCQ->F2_VALMERC+TCQ->F2_VALIPI+TCQ->F2_FRETE+TCQ->F2_SEGURO+TCQ->F2_ICMSRET) PICTURE "@E 99,999,999.99"
 	@ _nLin,046 psay "PEDIDO :"+TCQ->F2_PEDIDO+"  -  "+TCQ->ZG_LOCALIZ
 	_nLin++          
	@ _nLin,000 psay "CLIENTE : "+substr(If(lNormal,SA1->A1_NOME,SA2->A2_NOME ),1,40)
	@ _nLin,055 psay "|DATA: "
	_nLin++
	If lNormal
		If empty( SA1->A1_ENDENT )
			@ _nLin,000 psay "ENDEREÇO: "+SA1->A1_END			 
	  	Else
		  	@ _nLin,000 psay "ENDEREÇO: "+SA1->A1_ENDENT		  
	  	EndIf
   	Else
    	@ _nLin,000 psay "ENDEREÇO: "+SA2->A2_END				
   	EndIf
    @ _nLin,055 psay "|ASSINATURA: "
	_nLin++
	@ _nLin,000 psay "BAIRRO..: "+If( lNormal,SA1->A1_BAIRRO,SA2->A2_BAIRRO )		    
	@ _nLin,049 psay "CIDADE :"+alltrim(If( lNormal,SA1->A1_MUN, SA2->A2_MUN ))+"-"+If( lNormal,SA1->A1_EST, SA2->A2_EST )
	_nLin++
	
	dbSelectArea("SA4")
	dbSeek(xFilial("SA4")+TCQ->F2_REDESP)	 	
	@ _nLin,000 psay "TRANP...: "+A4_NOME
	_nLin++
	@ _nLin,000 psay "END.....: "+A4_END
	_nLin++                            
	@ _nLin,000 psay "PESO BRUTO : "+ transform(TCQ->F2_PBRUTO,"@E 999,999.9")
	@ _nLin,024 psay "PESO LIQUIDO : "+ transform(TCQ->F2_PLIQUI,"@E 999,999.9")
	@ _nLin,052 psay "VOLUMES : "+ transform(TCQ->F2_VOLUME1,"@E 999,999")
	_nLin = _nLin +2
	@ _nLin,000 psay "CONFERÊNCIA  : "
	@ _nLin,037 psay "DESPACHO  : "

   _nLin = _nLin + 2
	@ _nLin,000 PSAY replicate("-",80)
	
	dbSelectArea("TCQ")
	dbSkip()
EndDo
dbselectarea("TCQ")
dbclosearea()

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

/*/
Programa  : CRIASX1   Autor:  
Data      : 01/03/02
Descricao : Grava Perguntas
/*/
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//            Texto do help em português                , inglês, espanhol
AAdd(aHelp, {{"Informe a Serie da Nota"},  {""}, {""}})
AAdd(aHelp, {{"Informe a primeira nota Fiscal"}, {""}, {""}})
AAdd(aHelp, {{"Informe a ultima nota Fiscal"}, {""}, {""}})
AAdd(aHelp, {{"Informe o primeiro Bordero"}, {""}, {""}})
AAdd(aHelp, {{"Informe o ultimo Bordero"}, {""}, {""}})

PutSX1(cPerg,"01","Serie da Nota?"   ,"","","mv_ch1","C",01,00,00,"G","","",   "","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Da Nota Fiscal?"  ,"","","mv_ch2","C",06,00,00,"G","",""   ,"","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Ate Nota Fiscal?" ,"","","mv_ch3","C",06,00,00,"G","",""   ,"","","mv_Par03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Do Bordero?"      ,"","","mv_ch4","C",06,00,00,"G","",""   ,"","","mv_Par04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Ate Bordero?"     ,"","","mv_ch5","C",06,00,00,"G","",""   ,"","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")

Return
*/
