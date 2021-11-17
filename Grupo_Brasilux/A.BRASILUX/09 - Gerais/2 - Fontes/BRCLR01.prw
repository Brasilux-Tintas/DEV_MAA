#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Translate MSGBOX( => IW_MsgBox(

User Function BRCLR01()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define Variaveis                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Controle Licença Produto x Quantidade "
PRIVATE cDesc1 := ""
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
PRIVATE nomeprog:="BRCLR01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRCLR01"
PRIVATE flag := 0
PRIVATE cParam, cCountTotal :=0, cContEnc:= 0.0,cCountPen:= 0,cUsername
PRIVATE cCountEnc:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
        MsgBox("Acesso não autorizado!", "Atenção...", "STOP")
        Return
    Endif

//CriaSX1(cPerg) //LGS#20200207 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="BRCLR01"            //Nome Default do relatorio em Disco

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
// Funçào....: RPTDETAIL    Data....: 22/08/14         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cQuery :="SELECT Z10_CODIGO, Z10_FABRIC,Z10_DESCRI, Z10_QTDLIC,Z10_TOLIC FROM "+RetSqlName("Z10")+" Z10 WITH (NOLOCK)"
	cQuery +="WHERE Z10.D_E_L_E_T_ <> '*' AND (Z10_FILIAL = '"+XFILIAL("Z10")+"') AND (Z10_FABRIC BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"') "
	IF MV_PAR03 = 1
	cQuery +=" AND Z10_STATUS = '2' " 
	ELSEIF MV_PAR03 = 2
	cQuery +=" AND Z10_STATUS = '3' " 
	ENDIF
	cQuery +=" ORDER BY Z10_FABRIC"
	                                                       
	TCQuery cQuery NEW ALIAS "TEC"
	
	SetRegua(RECCOUNT())
   
	_nLin := 07
 	
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    cCount := 0
    
    
		cFABRIC := TEC->Z10_FABRIC
	while !EOF()                                                                           

	
		@ _nLin,000 psay POSICIONE("SX5",1,XFILIAL("SX5")+"ZF"+TEC->Z10_FABRIC,"X5_DESCRI")                 
		_nLin++
		@ _nLin,000 psay replicate("_",80)
		_nLin++
		@ _nLin,000 psay "Codigo"
		@ _nLin,008 psay "Descrição"
		@ _nLin,059 psay "T.Licença"
		@ _nLin,070 psay "Disponivel"
		_nLin++
		@ _nLin,000 psay replicate("-",80)
		_nLin++
		
		while !EOF() .AND. (cFABRIC == TEC->Z10_FABRIC)
			@ _nLin,000 psay TEC->Z10_CODIGO
	 		@ _nLin,008 psay TEC->Z10_DESCRI
	 		@ _nLin,062 psay transform(TEC->Z10_QTDLIC,"E@ 9999")
	 		@ _nLin,070 psay transform(TEC->Z10_TOLIC ,"E@ 9999")
	 		_nLin++	 		                                                 
	  		dbSelectArea("TEC")   
		    dbSkip()
		EndDo  
		@ _nLin,000 psay replicate("_",80)
	    cFABRIC := TEC->Z10_FABRIC
	    _nLin++
	EndDo
	dbselectarea("TEC")
	dbclosearea()
	
Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

//LGS#20200207 - Adequação de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)
       Local j, i
       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}
	
    		   // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
      	PutSX1(cPerg, "01","De Fabricante"  ,"","","mv_ch1","C",2,0,0,"G","","ZF","","","MV_PAR01","","","","","","","","","","","","","","","","",NIL,NIL,NIL,"")
	   	PutSX1(cPerg, "02","Até Fabricante" ,"","","mv_ch2","C",2,0,0,"G","","ZF","","","MV_PAR02","        ","","","","     ","","","     ","","","","","","","","",NIL,NIL,NIL,"")
	   	PutSX1(cPerg, "03","Tipo de Licença","","","mv_ch3","N",1,0,0,"C","","  ","","","MV_PAR03","Esgotada","","","","Baixa","","","Todos","","","","","","","","",NIL,NIL,NIL,"")
	   
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return*/