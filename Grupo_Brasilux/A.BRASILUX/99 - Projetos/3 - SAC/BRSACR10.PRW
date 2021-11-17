#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRSACR10     Data....: 14/12/11         //
// Autor.....:                                         //
// Descriçao.: Relatorio de SACS por produto           //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////
//                                                     //
// Variaveis utilizadas para parametros                //
//                                                     //
// mv_par01     // Do Produto                          //
// mv_par02     // Até o Produto                       //
// mv_par03     // Emissao De                          //
// mv_par04     // Emissao Ate                         //
// mv_par05     // Sacs (Abertos/Fechados/Todos)       //
// mv_par06     // Assunto                             //
/////////////////////////////////////////////////////////

User Function BRSACR10()


SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M,CQUERY1")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,NOMEPROG,CPERG,CQUERY")
SetPrvt("NLASTKEY,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")


CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="G"
limite   :=132
titulo   :="RELAÇÃO DE SAC'S POR PRODUTO"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Sacs por Produto",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Sacs Por Produto",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRSACR10"
cPerg    :="BRSACR10"
nLastKey := 0
lContinua:=.T.
_nLin    := 90
nCol     := 80
wnrel    := "BRSACR10"
nTipo    := 18
m_pag    := 01
//           0         10        20        30        40        50        60        70        80        90      100       110       120       130
//           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
cCabec1  := "SAC     CLIENTE                                QTD ORI. QTD DEVL.    N.F                OCORRÊNCIA  "
cCabec2  := " "
cCabec3  := " "
nTamNf   := 80     // Apenas Informativo
_nCont   := 80
cString  := "SZR"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             

     // Tamanho da pagina A4 em pixels 
     // Largura: 595 x Altura: 842 Retrato    - SetPortrait()
     // Largura: 595 x Altura: 842 Paisagem   - SetLandscape()
     

//CriaSx1(cPerg)  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})
Return

Static Function RptDetail()

Private _cProd		:= ""
Private _nLin 		:= 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cQuery := "" 
 	cQuery +="SELECT ZR_NUM, ZQ_CLIENTE, A1_NOME, ZR_OCORREN, ZR_PRODUTO, ZR_QTDORIG, ZR_QTDDEV, ZR_PEDIDO,ZR_NUMNF, ZR_ASSUNTO, ZQ_ATENDEN "
    cQuery +=	" FROM "+RETSQLNAME("SZR")+" SZR WITH (NOLOCK) "
 	cQuery +=	" LEFT OUTER JOIN "+ RETSQLNAME("SZQ")+" SZQ WITH (NOLOCK) ON ZR_FILIAL = ZQ_FILIAL AND ZR_NUM = ZQ_NUM AND SZR.D_E_L_E_T_ ='' "
  	cQuery +=	" LEFT OUTER JOIN "+ RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) ON ZQ_CLIENTE = A1_COD  AND SA1.D_E_L_E_T_ ='' " 
  	cQuery +=	" WHERE (ZR_PRODUTO >= '"+MV_PAR01+"') AND (ZR_PRODUTO <='"+MV_PAR02+"') "
  	cQuery +=	" AND   (SZR.D_E_L_E_T_ ='' ) "
	cQuery +=	" AND   (ZR_FILIAL = '"+XFILIAL("SZR")+"')"
  	cQuery +=	" AND   (ZQ_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND  '"+DTOS(MV_PAR04)+"') "
	If mv_par05 == 1 	
 		 cQuery +=  " AND (ZQ_DTFIM <>'') "      //Encerrados
	Endif
	If !Empty(mv_par06)
		cQuery +=  " AND (ZR_OCORREN ='"+MV_PAR06+"') "    //Ocorrência
	Endif
	cQuery +=  	" ORDER BY ZR_PRODUTO, ZR_OCORREN, ZR_NUM "
	TCQuery cQuery NEW ALIAS "TCQ" 
    
SetRegua(RECCOUNT())
dbselectarea("TCQ")

dbgotop()

dbselectarea("SB1")
dbsetorder(1)

While !eof()
	_nCont++ 
	if _nCont > 60
		_nCont := 1
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 08
	endif                                                                                         amaeste

  //           012345678901234567890123456789012345678901234567890123456789012345678901234567890
//cCabec1  := "SAC   CLIENTE                             QTDE          N.F         OCORRENCIA  "
	If TCQ->ZR_PRODUTO <> _cProd
		_cProd = ""	
		_cProd := TCQ->ZR_PRODUTO
		dbselectarea("SB1")
		dbseek(xFilial("SB1")+TCQ->ZR_PRODUTO, .t.)
			If Found()
				_nLin++
				@ _nLin,000 psay "PRODUTO..: "+TCQ->ZR_PRODUTO+" - "+SUBSTR(SB1->B1_DESC,1,35)
    			_nLin++
    		Endif
    Endif
 	_nLin++
 	@ _nLin,000 psay TCQ->ZR_NUM   
 	@ _nLin,007 psay TCQ->ZQ_CLIENTE+" - "+SUBSTR(TCQ->A1_NOME,1,35)
	@ _nLin,052 psay TCQ->ZR_QTDORIG picture "@E 9999"
	@ _nLin,059 psay TCQ->ZR_QTDDEV  picture "@E 9999"
	@ _nLin,068 psay TCQ->ZR_NUMNF
   	@ _nLin,088 psay TCQ->ZR_OCORREN+" - "+SUBSTR(Posicione("SU9", 1, xFilial("SU9")+TCQ->ZR_ASSUNTO+TCQ->ZR_OCORREN, "U9_DESC"),1,40) 				
 	_nLin++                            

	If _nLin >= 70
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 08
	Endif
	@ _nLin,000 PSAY replicate("-",130)
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
Programa  : IMPCABEC   Autor:  Renato P.Zuccolotto
Data      : 01/03/02
Descricao : Imprime o cabecalho do Agrupamento
/*

Static Function ImpCabec()

_nLin++               
If _nlin >= 57
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 07
Endif
@ _nLin,000 PSAY replicate("=",80)
_nLin++


Return


Programa  : CRIASX1   Autor:  
Data      : 01/03/02
Descricao : Grava Perguntas
*/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//            Texto do help em português                             ,inglês, espanhol
AAdd(aHelp, {{"Informe o código do Produto"},                           {""}, {""}})
AAdd(aHelp, {{"Informe o código do Produto"},                           {""}, {""}})
AAdd(aHelp, {{"Informe a data inicial "},                               {""}, {""}})
AAdd(aHelp, {{"Informe a data final "},                                 {""}, {""}})
AAdd(aHelp, {{"Informe se são todos os Sacs ou somente os encerrados"}, {""}, {""}})
AAdd(aHelp, {{"Informe a ocrrência para filtrar apenas uma          "}, {""}, {""}})

PutSX1(cPerg,"01","Do Produto ?   "                  ,"","","mv_ch1","C",15,00,00,"G","",     "SB1",  "","","mv_Par01","","",   "","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Até o Produto? "                  ,"","","mv_ch2","C",15,00,00,"G","",     "SB1",  "","","mv_Par02","","",   "","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Da data?       "                  ,"","","mv_ch3","D",08,00,00,"G","",        "",  "","","mv_Par03","","",   "","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Até a data?    "                  ,"","","mv_ch4","D",08,00,00,"G","",        "",  "","","mv_Par04","","",   "","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Somente encerrados? Todos?"       ,"","","mv_ch5","N",01,00,00,"C","",        "",  "","","mv_Par05","Encerrados","",   "","","","Todos","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
PutSX1(cPerg,"06","Somente Ocorrência ?      "       ,"","","mv_ch6","C",06,00,00,"G","",     "SU9",  "","","mv_Par06","","",   "","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],"")
  
//PutSX1(cPerg,"05","Filtra Sacs Encerrados Zerados?"     ,"","","mv_ch5","N",01,00,00,"C","","mv_par05","Sim"           ,"","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
       

Return*/