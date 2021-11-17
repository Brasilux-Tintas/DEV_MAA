#INCLUDE "TOPCONN.CH"                                                               
#INCLUDE "PROTHEUS.CH"
#Translate MSGBOX( => IW_MsgBox(

User Function HistxCus()

PRIVATE aRotina   := {}
PRIVATE cCadastro := "Transacoes"
PRIVATE cFiltro   := "Z05_COD"                                           
PRIVATE cRotina   := "TesteCad"
PRIVATE cFiltBM   := ""
PRIVATE oObjBrow  := Nil
PRIVATE _cFiltro  := ""

If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
        MsgBox("Acesso não autorizado!", "Atenção...", "STOP")
        Return
    Endif

AAdd(aRotina,{"Visualizar"	 , "AxVisual" , 0, 3})
AAdd(aRotina,{"Relatorio"	 , "u_ImpHisCus", 0, 4})

	dbSelectArea("Z05")
	dbSetOrder(1)
	dbGoTop()
	
	_cFiltro   := cFiltBM                                  
	if empty(_cFiltro)
//		_cFiltro := ".T."
	endif 

	DbSelectArea("Z05")
	dbgotop()

    mBrowse( 6,1,22,75,"Z05", , , , , , ) //, , , , , , , ,_cFilSql
Return

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//							                                     Imprimir																				   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function ImpHisCus()  

PRIVATE CbTxt
PRIVATE Titulo := "Histórico Custo Mat. Prima"
PRIVATE cDesc1 := ""
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := "  "
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="HistCusto"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="HistCusto" 


//CriaSX1(cPerg) //LGS#20200130 - Adequação a release 12.1.25
Pergunte(cPerg,.F.)

wnrel:="HistCusto"            //Nome Default do relatorio em Disco
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

Static Function RptDetail()
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := "WITH DIAS AS (SELECT Z05_COD,MAX(Z05_DIA) AS DIA FROM "+RetSqlName("Z05")+" Z05 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND "
cQuery += "(Z05_FILIAL = '"+XFILIAL("Z05")+"') AND (Z05_DIA <= '"+dtos(mv_par01)+"') AND (Z05_COD BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') GROUP BY Z05_COD), PRECOS AS (SELECT "
cQuery += "DIAS.Z05_COD AS CODPRO,Z05.Z05_PRECO AS PRECO FROM DIAS "
cQuery += "LEFT OUTER JOIN "+RetSqlName("Z05")+" Z05 WITH (NOLOCK) ON (Z05.D_E_L_E_T_ <> '*') AND "
cQuery += "(Z05.Z05_FILIAL = '"+XFILIAL("Z05")+"') AND (Z05.Z05_COD = DIAS.Z05_COD) AND (Z05.Z05_DIA = DIAS.DIA)) "
cQuery += "SELECT B1_COD AS CODPRO,B1_DESC AS DESCRICAO,B1_TIPO AS TIPO,B1_UM AS UM,ISNULL(PRECOS.PRECO,B1_UPRC) AS PRECO FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
cQuery += "LEFT OUTER JOIN PRECOS ON (PRECOS.CODPRO = B1_COD) " 
cQuery += "WHERE (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+XFILIAL("SB1")+"') AND (B1_TIPO = 'MP') AND (B1_COD BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') "
cQuery += "ORDER BY CODPRO"
     
TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT())

Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)

dbSelectArea("Z05")
dbgotop()
dbselectarea("TCQ")
dbgotop()

_nLin := 07
 

    @ _nLin,025 psay "CUSTOS DO DIA "+ substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),3,2)
    _nLin++          
	_nLin++ 
	@ _nLin,000 psay replicate("_",80)  
	_nLin++  
	    @ _nLin,000 psay "CODIGO"
   		@ _nLin,016 psay "DESCRICAO"
    	@ _nLin,049 psay "TIPO"
   		@ _nLin,057 psay "UM"
    	@ _nLin,067 psay "PRECO"
    	@ _nLin,000 psay replicate("_",80)   
   	_nLin++     
While !eof()
   
   	 @ _nLin,000 psay TCQ->CODPRO
	 @ _nLin,016 psay TCQ->DESCRICAO
	 @ _nLin,049 psay TCQ->TIPO
	 @ _nLin,057 psay TCQ->UM
     @ _nLin,062 psay transform(TCQ->PRECO,"@E 9,999,999.9999")
	 _nLin++		 
   	
   	 if _nLin > 55
	 	@ _nLin,000 psay replicate("_",80)
	 	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	 	_nLin := 06
	    @ _nLin,000 psay replicate("_",80)  
	    _nLin++ 
	 	@ _nLin,000 psay "CODIGO"
   		@ _nLin,016 psay "DESCRICAO"
    	@ _nLin,049 psay "TIPO"
   		@ _nLin,057 psay "UN"
    	@ _nLin,067 psay "PRECO"
	    @ _nLin,000 psay replicate("_",80)   
   		_nLin++     

	 	
	 endif
		    
     dbSelectArea("TCQ")   
     dbSkip()
	
endDo

dbselectarea("TCQ")
dbclosearea()

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------CriaSX1---------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//LGS#20200130 - Adequação a release 12.1.25
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Filtar por data"},  {""}, {""}})

AAdd(aHelp, {{"Filtrar de Codigo"},  {""}, {""}})

AAdd(aHelp, {{"Filtrar ate Codigo"},  {""}, {""}})
      

PutSX1(cPerg,"01","dia Data" ,"","","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

PutSX1(cPerg,"02","de Codigo" ,"","","mv_ch2","C",15,00,00,"G","","SB1","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

PutSX1(cPerg,"03","ate Codigo" ,"","","mv_ch3","C",15,00,00,"G","","SB1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")


	Return
Return*/