#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Translate MSGBOX( => IW_MsgBox(

User Function BRCHAM03()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define Variaveis                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio chamado Solicitante x Pendente "
PRIVATE cDesc1 := ""
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := "Nro.Chamada  Solicitante                     Situação        Data         Hora"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRCHAM03"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRCHAM03"
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

//CriaSX1(cPerg)  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="BRCHAM03"            //Nome Default do relatorio em Disco

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
	cQuery :="SELECT MAX(Z06_SOLCHA)as SOLICIT, Z06_NUMCHA, MAX(Z07_HRA)as HORA, MAX(Z07_DATA)as DTA" 
	cQuery +=" FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK)"	
  	cQuery +=" LEFT OUTER JOIN "+RetSqlName("Z07")+" Z07 WITH (NOLOCK) ON (Z07.D_E_L_E_T_ <> '*') AND (Z07_CODIGO = Z06_NUMCHA)"
	cQuery +=" WHERE Z06.D_E_L_E_T_ <> '*' AND Z06_STATUS = '4' AND (Z07_FILIAL = '"+XFILIAL("Z06")+"') AND (Z06_SOLCHA BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+"')"
	cQuery +=" GROUP BY Z06_NUMCHA, Z06_SOLCHA"
	                                                       
	TCQuery cQuery NEW ALIAS "TEC"
	
	SetRegua(RECCOUNT())
   
	_nLin := 08
 	
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    cCount := 0
	cSolcha := TEC->SOLICIT
	while !EOF()
	  if !empty(TEC->SOLICIT).AND.(cSolcha == TEC->SOLICIT)
			while (cSolcha == TEC->SOLICIT)
			@ _nLin,000 psay TEC->Z06_NUMCHA
			//LGS#20200211 - Adequação de release 12.1.25 e posteriores
			//@ _nLin,008 psay UsrFullName(TEC->SOLICIT)
			@ _nLin,008 psay fBusName( TEC->SOLICIT )
			@ _nLin,045 psay "Pendente desde"
			@ _nLin,061 psay substr(TEC->DTA,7,2)+"/"+substr(TEC->DTA,5,2)+"/"+substr(TEC->DTA,3,2)+" as "
			@ _nLin,074 psay TEC->HORA
			cCount++
			_nLin++									 	
  		      dbSelectArea("TEC")   
		      dbSkip()
		     
		    enddo
		    cSolcha := TEC->SOLICIT
		endif 
	enddo	
	@ _nLin,000 psay replicate("_",80)
	_nLin++									 	
  	@ _nLin,003 psay "Total de chamados pendentes: "
	@ _nLin,035 psay cCount
		
	dbselectarea("TEC")
	dbclosearea()
	
Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

Static Function fBusName( _nCodigo )
Return UsrFullName( _nCodigo )

//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)
       Local i, j
       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
      	PutSX1(cPerg, "01","De solicitante" ,"","","mv_ch1","C",6,0,0,"G","","SZH","","","MV_PAR01","","","","","","","","","","","","","","","","",NIL,NIL,NIL,"")
	 	PutSX1(cPerg, "02","Até solicitante" ,"","","mv_ch2","C",6,0,0,"G","","SZH","","","MV_PAR02","","","","","","","","","","","","","","","","",NIL,NIL,NIL,"")
	   
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