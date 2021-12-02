#include "rwmake.ch"
#include "ap5mail.ch"                                                     	
#Include "PROTHEUS.CH"
#include "topconn.ch"
#include "font.ch"    

User Function BRTRANR1()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio de Ficha de Transporte"
PRIVATE cDesc1 := "Relatorio informa sacs existentes sob o lote"
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= ""
PRIVATE Limite := 220
PRIVATE cString:= "Z12"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRTRANR1"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg1   :="BRTRANR1"
PRIVATE cPerg2  :="BRTRANR2"
PRIVATE recd
   
Private oDlg, oButton, cEnc :=space(200), oEnc, cAvlCham, oAvlCham
     u_zcfga01( 'BRTRANR1' ) //LGS#2021201 - Gravação de log de utilização da rotina
cAvlCham := ""

DEFINE MSDIALOG oDlg TITLE "Estilo de relatorio" FROM 000, 000 TO 150, 250 PIXEL   

@ 010, 020 SAY "Tipo de relatorio" SIZE 052, 007 OF oDlg COLORS 0, 10 PIXEL
@ 025, 020 MSCOMBOBOX oAvlCham VAR recd ITEMS{"1=Especifico","2=Geral"} SIZE 060, 060 OF oDlg COLORS 0, 10 PIXEL
@ 050, 060 Button "Continuar" Size 030, 012 PIXEL OF oDlg Action(brrelt01(recd),oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED    

Return

Static Function brrelt01(recd)
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*
if recd = "1"
	CriaSX1(cPerg1)
	Pergunte(cPerg1,.F.) 
elseif recd = "2"
	CriaSX1(cPerg2)
	Pergunte(cPerg2,.F.) 
endif*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="BRTRANR1"            //Nome Default do relatorio em Disco

if recd = "1"
	wnrel:=SetPrint(cString,wnrel,cPerg1,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
elseif recd = "2"
	wnrel:=SetPrint(cString,wnrel,cPerg2,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
endif
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
// Funçào....: RPTDETAIL    Data....: 21/05/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               
cQuery :="SELECT Z12_CODIGO, Z12_TRANSP, Z12_PLACA, Z12_MOTORI, Z12_MOPP, Z12_KIT, Z12_DTENT, Z12_DTSAID, Z12_HRENT, Z12_HRSAID, Z13_SERIE, Z13_NF, ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), Z12_OBS)),'') AS OBSF "
cQuery +="FROM " +RetSqlName("Z12")+" Z12 WITH (NOLOCK) "
cQuery +="LEFT OUTER JOIN "+RetSqlName("Z13")+" Z13 WITH(NOLOCK) ON Z12_FILIAL ='"+xFilial("Z13")+"' AND Z13_CODIGO = Z12_CODIGO AND Z13.D_E_L_E_T_ ='' "
cQuery +=" WHERE Z12.D_E_L_E_T_ ='' AND Z12_DTENT BETWEEN ('"+dtos(MV_PAR01)+"') AND ('"+dtos(MV_PAR02)+"') AND Z12_DTSAID BETWEEN ('"+dtos(MV_PAR03)+"') AND ('"+dtos(MV_PAR04)+"') "
if (recd) = "1"
	cQuery +=" AND Z12_TRANSP = ('"+(MV_PAR05)+"')"
endif
cQuery +=" ORDER BY Z12_TRANSP, Z12_DTENT"

TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT())  

cNome := POSICIONE("SA4",1,XFILIAL("SA4")+TCQ->Z12_TRANSP,"A4_NOME")
  
if recd = "1" 
	cCabec1 :="Relatorio especifico da Transportadora: "+cNome
	Tamanho:= "P"
elseif recd = "2"
	cCabec1 :="Motorista                         Transportadora                                    Placa     Data Entrada   Hora Entrada   Data saida     Hora Saida  Kit   MOPP     Cod. Transp"
	Tamanho:= "G"
endif
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

       
_nLin := 08
LimLinha := 70
flag:=0
dbselectarea("TCQ")
dbgotop()   
dbSelectArea("Z13")
dbgotop()   

if recd = "1" 
While !eof()
	 While !eof() .AND. TCQ->Z12_TRANSP = MV_PAR05 .AND. TCQ->Z12_CODIGO = Z13->Z13_CODIGO
     	if _nLin > LimLinha
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)               
			_nLin := 08	    
	 	endif
     	@_nLin,000 psay "Motorista "+TCQ->Z12_MOTORI
     	@_nLin++
     	@_nLin,000 psay "Transportadora "+cNome
     	@_nLin++
     	@_nLin,000 psay "Placa "+TCQ->Z12_PLACA     		
     	@_nLin++                               
     	@_nLin,000 psay "Data Entrada "+SubStr(TCQ->Z12_DTENT, 7, 2)+'/'+SubStr(TCQ->Z12_DTENT, 5, 2)+'/'+SubStr(TCQ->Z12_DTENT, 3, 2)
     	@_nLin,050 psay "Hora Entrada "+SubStr(TCQ->Z12_HRENT,1,2)+':'+SubStr(TCQ->Z12_HRENT,3,2)
     	@_nLin++                               
     	@_nLin,000 psay "Kit "+iif(TCQ->Z12_KIT = "1","Sim","Não") 
     	@_nLin,050 psay "MOPP "+iif(TCQ->Z12_MOPP = "1","Sim","Não")
     	@_nLin++
   	  	@_nLin++   
	    @_nLin,000 psay "Obs.: "+substr(alltrim(TCQ->OBSF),1,65)     		
     	@_nLin++                               
     	@_nLin,000 psay substr(TCQ->OBSF,66,70)     			
     	@_nLin++                               
     	@_nLin,000 psay substr(TCQ->OBSF,137,70)     		
     	@_nLin++    		                   
     	@_nLin,000 psay substr(TCQ->OBSF,208,70)     		
     	@_nLin++    		
		@_nLin++    		
     	@_nLin,000 psay "Data Entrada "+SubStr(TCQ->Z12_DTSAID, 7, 2)+'/'+SubStr(TCQ->Z12_DTSAID, 5, 2)+'/'+SubStr(TCQ->Z12_DTSAID, 3, 2)
     	@_nLin,050 psay "Hora Entrada "+SubStr(TCQ->Z12_HRSAID,1,2)+':'+SubStr(TCQ->Z12_HRSAID,3,2)
     	While !eof() .AND.(TCQ->Z12_CODIGO == Z13->Z13_CODIGO)
 			if flag = 0 
 				@_nLin++
 				@ _nLin,000 psay replicate("_",80)
				@_nLin++
 			 	@_nLin,000 psay "Nota Fiscal"
 				@_nLin,050 psay "Serie da Nota"
 				@_nLin++
 			    flag := 1
			endif
			@_nLin,000 psay TCQ->Z13_NF
			@_nLin,050 psay TCQ->Z13_SERIE
			@_nLin++
			dbSelectArea("TCQ")
   			dbSkip()
     	enddo
        if !Eof()
	   		@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)               
			_nLin := 08
			flag := 0
		endif         
  enddo
  dbSelectArea("Z13")
  dbSkip()
enddo
else          

cQuery2 := "SELECT Z12_CODIGO, Z12_TRANSP, Z12_PLACA, Z12_MOTORI, Z12_MOPP, Z12_KIT, Z12_DTENT, Z12_DTSAID, Z12_HRENT, Z12_HRSAID "  
cQuery2 += "FROM " +RetSqlName("Z12")+" Z12 WITH (NOLOCK) "
cQuery2 +=" WHERE Z12.D_E_L_E_T_ ='' AND Z12_DTENT BETWEEN ('"+dtos(MV_PAR01)+"') AND ('"+dtos(MV_PAR02)+"') AND Z12_DTSAID BETWEEN ('"+dtos(MV_PAR03)+"') AND ('"+dtos(MV_PAR04)+"')
cQuery2 += "ORDER BY Z12_TRANSP"
 
TCQuery cQuery2 NEW ALIAS "TCQ2"
 
SetRegua(RECCOUNT()) 
cTransp := TCQ2->Z12_TRANSP 
cNome2 := POSICIONE("SA4",1,XFILIAL("SA4")+TCQ2->Z12_TRANSP,"A4_NOME")      

		While !eof()
		if _nLin > LimLinha
	   		@ _nLin,000 psay replicate("_",220)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)               
			_nLin := 08
			flag := 0
		endif        
		While !eof() .AND. TCQ2->Z12_TRANSP = cTransp
			@_nLin,000 psay TCQ2->Z12_MOTORI
	     	@_nLin,035 psay cNome2
	     	@_nLin,085 psay TCQ2->Z12_PLACA     
     		@_nLin,095 psay SubStr(TCQ2->Z12_DTENT, 7, 2)+'/'+SubStr(TCQ2->Z12_DTENT, 5, 2)+'/'+SubStr(TCQ2->Z12_DTENT, 3, 2) 
	     	@_nLin,110 psay SubStr(TCQ2->Z12_HRENT,1,2)+':'+SubStr(TCQ2->Z12_HRENT,3,2)
	     	@_nLin,125 psay SubStr(TCQ2->Z12_DTSAID, 7, 2)+'/'+SubStr(TCQ2->Z12_DTSAID, 5, 2)+'/'+SubStr(TCQ2->Z12_DTSAID, 3, 2)
     		@_nLin,140 psay SubStr(TCQ2->Z12_HRSAID,1,2)+':'+SubStr(TCQ2->Z12_HRSAID,3,2) 
     		@_nLin,152 psay iif(TCQ2->Z12_KIT = "1","Sim","Não") 
     		@_nLin,158 psay iif(TCQ2->Z12_MOPP = "1","Sim","Não")    
			@_nLin,167 psay TCQ2->Z12_TRANSP    		
	     	_nLin++
			dbSelectArea("TCQ2")
   			dbSkip()  
   			if TCQ2->Z12_TRANSP != Z12->Z12_TRANSP
				@ _nLin,000 psay replicate("-",220)
				@ _nLin++
				@ _nLin++
			endif                                                                                        
		enddo 
	cNome2 := POSICIONE("SA4",1,XFILIAL("SA4")+TCQ2->Z12_TRANSP,"A4_NOME")   
	cTransp := TCQ2->Z12_TRANSP
	enddo
endif

if recd = "2"	
	dbselectarea("TCQ2")
	dbclosearea()
endif
	dbselectarea("TCQ")
	dbclosearea()
	
Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif
Return

//-------------------------------------------------------------------------------------------------------------------              
//-------------------------------------------------------------------------------------------------------------------
//LGS#20200204 - Adequação de release 12.1.25 e posteriores
/*              
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol
if cPerg = "BRTRANR1"
	AAdd(aHelp, {{"Transportadora"},  {""}, {""}})
	AAdd(aHelp, {{"Data de entrada de?"},  {""}, {""}})
	AAdd(aHelp, {{"Data de entrada até"},  {""}, {""}})
	AAdd(aHelp, {{"Data de saida de"},  {""}, {""}})
	AAdd(aHelp, {{"Data de saida até"},  {""}, {""}})
	
	//( < cGrupo>, < cOrdem>, < cPergunt>, < cPergSpa>, < cPergEng>, < cVar>, < cTipo>, < nTamanho>, [ nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
	PutSX1(cPerg1,"01","Data entrada de? " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
	PutSX1(cPerg1,"02","Data entrada ate? " ,"","","mv_ch3","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
	PutSX1(cPerg1,"03","Data saida de " ,"","","mv_ch4","D",8,00,00,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
	PutSX1(cPerg1,"04","Data saida ate " ,"","","mv_ch5","D",8,00,00,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
	PutSX1(cPerg1,"05","Transportadora " ,"","","mv_ch1","C",5,00,00,"G","","SA4","","","MV_PAR05","Especifico","","","","Geral","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
elseif cPerg = "BRTRANR2"
	AAdd(aHelp, {{"Data de entrada de?"},  {""}, {""}})
	AAdd(aHelp, {{"Data de entrada até"},  {""}, {""}})
	AAdd(aHelp, {{"Data de saida de"},  {""}, {""}})
	AAdd(aHelp, {{"Data de saida até"},  {""}, {""}})
	//( < cGrupo>, < cOrdem>, < cPergunt>, < cPergSpa>, < cPergEng>, < cVar>, < cTipo>, < nTamanho>, [ nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
	PutSX1(cPerg2,"01","Data entrada de? " ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
	PutSX1(cPerg2,"02","Data entrada ate? " ,"","","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
	PutSX1(cPerg2,"03","Data saida de " ,"","","mv_ch3","D",8,00,00,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
	PutSX1(cPerg2,"04","Data saida ate " ,"","","mv_ch4	","D",8,00,00,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
endif
Return
*/
//-------------------------------------------------------------------------------------------------------------------              
