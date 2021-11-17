#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function HD3IMPRIM()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define Variaveis                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio Chamados"
PRIVATE cDesc1 := "Este relatorio ira Dialogos do Chamado "
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="HD3IMPRIM"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="HD3IMPRIM"
PRIVATE flag := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaSX1(cPerg)
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="HD3IMPRIM"            //Nome Default do relatorio em Disco

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
// Funçào....: RPTDETAIL    Data....: 03/10/13         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Local _nX
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := "SELECT Z07_USER as Usuario,Z07_CODIGO as codigo, Z07_DESCRI as Descricao, Z07_DATA as cData, Z07_HRA as Hora, Z07_CODIGO as CODIGO, Z06_HRABER,Z06_NUMCHA, Z06_DTABER, Z06_SOLCHA,Z06_TECALO, Z06_OCORRE, Z06_CLASSI "
cQuery += "FROM "+RetSqlName("Z07")+" Z07 WITH (NOLOCK) "
cQuery += "LEFT OUTER JOIN "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) ON (Z06.D_E_L_E_T_ <> '*') AND (Z07_CODIGO = Z06_NUMCHA) "
cQuery += "WHERE (Z07.D_E_L_E_T_ <> '*') AND (Z07_FILIAL = '"+XFILIAL("Z07")+"') AND (Z06_NUMCHA BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"') AND "
cQuery += "(Z06_SOLCHA BETWEEN '"+(MV_PAR03)+"' AND '"+(MV_PAR04)+"') AND  (Z06_TECALO BETWEEN '"+(MV_PAR06)+"' AND '"+(MV_PAR07)+"') AND (Z06_DTABER BETWEEN '"+dtos(MV_PAR08)+"' AND '"+dtos(MV_PAR09)+"' ) "
if MV_PAR05 < 5
cQuery += " AND Z06_STATUS =  '"+alltrim(str(MV_PAR05))+"'
endif
cQuery += " ORDER BY Z06_NUMCHA, Z07_HRA"
     
TCQuery cQuery NEW ALIAS "TCQ"
  
SetRegua(RECCOUNT())

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

dbSelectArea("Z06")
dbgotop()
dbselectarea("TCQ")
dbgotop()

_nLin := 07

While !eof()

	While !eof() .And. (TCQ->Z06_NUMCHA == Z06->Z06_NUMCHA) .and. Z06->Z06_FILIAL == xFilial("Z06")
        flag :=2
	  	@ _nLin,002 psay TCQ->Z06_NUMCHA 
	    @ _nLin,010 psay substr(TCQ->Z06_DTABER,7,2)+"/"+substr(TCQ->Z06_DTABER,5,2)+"/"+substr(TCQ->Z06_DTABER,3,2)
	 	@ _nLin,020 psay TCQ->Z06_HRABER
	    @ _nLin,039 psay Z06->Z06_CLASSI
 
	 	_nLin++
	    @ _nLin,002 psay "Solicitante: "+UsrRetName(TCQ->Z06_SOLCHA)
	 	@ _nLin,042 psay "Tecnico: "+UsrRetName(TCQ->Z06_TECALO)  
	 	_nLin++
	 	_nLinhas := MlCount(Z06->Z06_OCORRE,75)
		For _nX := 1 To _nLinhas
		@ _nLin,003 PSAY MemoLine(Z06->Z06_OCORRE,75,_nX)
		++_nLin
		Next _nX
	  
		@ _nLin,000 psay replicate("_",80)
	
		While !eof() .And. (Z06->Z06_NUMCHA == TCQ->Codigo) .and. Z06->Z06_FILIAL == xFilial("Z06")
		      _nLin++
		      
		     @ _nLin,009 psay substr(TCQ->cData,7,2)+"/"+substr(TCQ->cData,5,2)+"/"+substr(TCQ->cData,3,2)
		  	 @ _nLin,020 psay TCQ->Hora
			 @ _nLin,028 psay UsrRetName(TCQ->Usuario)
			 _nLin++     
			 @ _nLin,003 psay "Ocorrencia: "+substr(TCQ->Descricao,0,65) 
			 _nLin++     
			 @ _nLin,003 psay substr(TCQ->Descricao,66,75)
			 _nLin++     
			 @ _nLin,003 psay substr(TCQ->Descricao,141,75)
			 _nLin++ 
			 @ _nLin,003 psay substr(TCQ->Descricao,216,75)
			 _nLin++
			 if _nLin > 55
			 	@ _nLin,000 psay replicate("_",80)
			 	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			 	_nLin := 08
			 endif                          
			 		 
  		     dbSelectArea("TCQ")   
		     dbSkip()
		     
		     if !eof() .And. (Z06->Z06_NUMCHA == TCQ->Codigo) .and. Z06->Z06_FILIAL == xFilial("Z06")
			 	@ _nLin,000 psay replicate("-",80)
			 else
			 	@ _nLin,000 psay replicate("_",80)
			 endif         
		enddo		
    	
	endDo 
     dbSelectArea("Z06")
	dbSkip()
    
	if (!eof() .And. (TCQ->Z06_NUMCHA == Z06->Z06_NUMCHA) .and. Z06->Z06_FILIAL == xFilial("Z06")) .and. flag>1
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 07
	endif
endDo

dbselectarea("TCQ")
dbclosearea( )

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Informar Quais chamados deseja filtrar"},  {""}, {""}})

AAdd(aHelp, {{"Informe quais solicitantes deseja filtrar"},  {""}, {""}})

AAdd(aHelp, {{"Informar qual status deseja filtrar"},  {""}, {""}})
      

PutSX1(cPerg,"01","de Chamado" ,"","","mv_ch1","C",6,00,00,"G","","Z06","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

PutSX1(cPerg,"02","ate Chamado" ,"","","mv_ch2","C",6,00,00,"G","","Z06","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

PutSX1(cPerg,"03","de Solicitante" ,"","","mv_ch3","C",6,00,00,"G","","USR","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

PutSX1(cPerg,"04","ate Solicitante" ,"","","mv_ch4","C",6,00,00,"G","","USR","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

PutSX1(cPerg,"05","Status" ,"","","mv_ch5","N",1,00,00,"C","","","","","","Aberto","","","","Encerrado","","","Pendente Tec","","","Pendente User","","","Todos","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")

PutSX1(cPerg,"06","de Tecnico" ,"","","mv_ch6","C",6,00,00,"G","","USR","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

PutSX1(cPerg,"07","ate Tecnico" ,"","","mv_ch7","C",6,00,00,"G","","USR","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

PutSX1(cPerg,"08","de Data" ,"","","mv_ch8","D",8,00,00,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

PutSX1(cPerg,"09","ate Data" ,"","","mv_ch9","C",1,00,00,"G","","","","","MV_PAR09","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")

Return*/