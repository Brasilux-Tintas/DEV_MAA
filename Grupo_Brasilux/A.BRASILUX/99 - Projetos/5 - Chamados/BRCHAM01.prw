#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Translate MSGBOX( => IW_MsgBox(

User Function BRCHAM01()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define Variaveis                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
//LOCAL cCatOcorr 
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
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRCHAM01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRCHAM01"
PRIVATE flag := 0
PRIVATE cParam, cCountTotal :=0, cContEnc:= 0.0,cCountPen:= 0
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

wnrel:="BRCHAM01"            //Nome Default do relatorio em Disco

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
//Local nTotal := 0,cGrupo,cTitGrupo
//Local _nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := "SELECT COUNT(R_E_C_N_O_) AS QTDE "
cQuery += "FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) "
cQuery += "WHERE (Z06.D_E_L_E_T_ <> '*') AND (Z06_FILIAL = '"+XFILIAL("Z06")+"') "
IF !empty(MV_PAR03) 
	cQuery += "AND (Z06_DTABER BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"')"
ENDIF 

TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(TCQ->QTDE) 

dbSelectArea("TCQ")
dbgotop()


DO CASE
CASE MV_PAR01 == 1	 
	cTit := "Relatorio estatistico CHAMADO x SETOR OCORRENCIA de "+	substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),3,2)+" até "+substr(dtos(mv_par03),7,2)+"/"+substr(dtos(mv_par03),5,2)+"/"+substr(dtos(mv_par03),3,2)
	cGrupo := "Z06_SETOCO"
	cTitGrupo := "Setores Ocorencia"
	cQuery := "SELECT Z06_SETOCO AS GRUPO,MAX(Z09_DESCRI) AS DESCR,COUNT(Z06.R_E_C_N_O_) AS TOTALCHAM,"+;
	"SUM(CASE WHEN Z06_STATUS = '2' THEN 1 ELSE 0 END) AS ENCERRADOS,"+;
	"SUM(CASE WHEN Z06_STATUS <> '2' THEN 1 ELSE 0 END) AS EMABERTO "+;
	"FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("Z09")+" Z09 WITH (NOLOCK) ON (Z09.D_E_L_E_T_ <> '*') AND (Z09_FILIAL = '"+xFilial("Z09")+"') AND (Z09_CODOCO = Z06_SETOCO) "
CASE MV_PAR01 == 2	 
	cTit := "Relatorio estatistico CHAMADO x TECNICO de "+	substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),3,2)+" até "+substr(dtos(mv_par03),7,2)+"/"+substr(dtos(mv_par03),5,2)+"/"+substr(dtos(mv_par03),3,2)
	cGrupo := "Z06_TECALO"
	cTitGrupo := "Tecnico"
	cQuery :="SELECT Z06_TECALO AS GRUPO,MAX(ZH_NOME) AS DESCR,COUNT(Z06.R_E_C_N_O_) AS TOTALCHAM, "
	cQuery+= "SUM(CASE WHEN Z06_STATUS = '2' THEN 1 ELSE 0 END) AS ENCERRADOS, " 
	cQuery+= "SUM(CASE WHEN Z06_STATUS <> '2' THEN 1 ELSE 0 END) AS EMABERTO "
	cQuery+= "FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SZH")+" SZH WITH (NOLOCK) ON (SZH.D_E_L_E_T_ <> '*') AND (ZH_FILIAL = '"+xFilial("SZH")+"') AND (Z06_TECALO = ZH_CODIGO) "
CASE MV_PAR01 == 3	 
	cTit := "Relatorio estatistico CHAMADO x SETOR  de "+	substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),3,2)+" até "+substr(dtos(mv_par03),7,2)+"/"+substr(dtos(mv_par03),5,2)+"/"+substr(dtos(mv_par03),3,2)
	cGrupo := "Z06_SET"
	cTitGrupo := "Setores"
	cQuery :="SELECT Z06_SET AS GRUPO,MAX(X5_DESCRI) AS DESCR,COUNT(Z06.R_E_C_N_O_) AS TOTALCHAM, "
	cQuery+= "SUM(CASE WHEN Z06_STATUS = '2' THEN 1 ELSE 0 END) AS ENCERRADOS, " 
	cQuery+= "SUM(CASE WHEN Z06_STATUS <> '2' THEN 1 ELSE 0 END) AS EMABERTO "
	cQuery+= "FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ <> '*') AND (X5_FILIAL = '"+xFilial("SX5")+"') AND (X5_TABELA = 'ZK') AND (Z06_SET = X5_CHAVE) "
CASE MV_PAR01 == 4
	cTit := "Relatorio estatistico CHAMADO x Solicitante  de "+	substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),3,2)+" até "+substr(dtos(mv_par03),7,2)+"/"+substr(dtos(mv_par03),5,2)+"/"+substr(dtos(mv_par03),3,2)
	cGrupo := "Z06_SOLCHA"
	cTitGrupo := "Solicitante"
	cQuery :="SELECT Z06_SOLCHA AS GRUPO,MAX(ZH_NOME) AS DESCR,COUNT(Z06.R_E_C_N_O_) AS TOTALCHAM, "
	cQuery+= "SUM(CASE WHEN Z06_STATUS = '2' THEN 1 ELSE 0 END) AS ENCERRADOS, " 
	cQuery+= "SUM(CASE WHEN Z06_STATUS <> '2' THEN 1 ELSE 0 END) AS EMABERTO "
	cQuery+= "FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SZH")+" SZH WITH (NOLOCK) ON (SZH.D_E_L_E_T_ <> '*') AND (ZH_FILIAL = '"+xFilial("SZH")+"') AND (Z06_SOLCHA = ZH_CODIGO) "
ENDCASE	

cQuery += "WHERE (Z06.D_E_L_E_T_ <> '*') AND (Z06_FILIAL = '"+XFILIAL("Z06")+"') "
IF !EMPTY(MV_PAR03)
	cQuery += " AND (Z06_DTABER BETWEEN '"+dtos(mv_par02)+"' AND '"+dtos(mv_par03)+"') "
ENDIF      
cQuery += "GROUP BY "+cGrupo+" ORDER BY TOTALCHAM DESC"

TCQuery cQuery NEW ALIAS "TEC"
	
//SetRegua(RECCOUNT("TEC"))

dbSelectArea("TEC")
dbgotop()
   
	_nLin := 07
 	
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	@ _nLin,040 psay  cTit
    _nLin++  
    @ _nLin,000 psay replicate("_",132)
	_nLin++  
	@ _nLin,003 psay  cTitGrupo 
    @ _nLin,070 psay  "Total chamado"  
	@ _nLin,085 psay  "Chamados Pend"
	//                     9,999,999
	@ _nLin,099 psay  "Chamados Enc."
	@ _nLin,000 psay replicate("_",132)
	_nLin++ 
	while !EOF()  
		  if _nLin > 55.AND. !EOF()
			@ _nLin,000 psay replicate("_",132)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 07
		endif                           //POSICIONE("SX5",1,XFILIAL("SX5")+"ZK"+TEC->Z06_SET,"X5_DESCRI")                 
		  @ _nLin,003 psay alltrim(TEC->GRUPO)+"-"+ALLTRIM(TEC->DESCR)
		  @ _nLin,074 psay TEC->TOTALCHAM PICTURE "@E 9,999,999"
	      cCountTotal+= TEC->TOTALCHAM
	      @ _nLin,089 psay TEC->EMABERTO PICTURE "@E 9,999,999"
		  cCountPen+= TEC->EMABERTO
	      @ _nLin,103 psay  TEC->ENCERRADOS PICTURE "@E 9,999,999"
		  cCountEnc += TEC->ENCERRADOS
	      _nLin++
	      dbSelectArea("TEC")
		  dbSkip()   
	enddo  
  	@ _nLin,000 psay replicate("_",132)
	_nLin++
	@ _nLin,035 psay "Total"
	@ _nLin,073 psay cCountTotal PICTURE "@E 99,999,999"
	@ _nLin,088 psay cCountPen  PICTURE "@E 99,999,999"
	@ _nLin,102 psay cCountEnc  PICTURE "@E 99,999,999"
		
	dbselectarea("TEC")
	dbclosearea()
	dbselectarea("TCQ")
	dbclosearea()
	

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)
       _sAlias := Alias()
       cPerg := PADR(cPerg, 10)


       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
      	PutSX1(cPerg, "01","Agrupar por", "Agrupar por"  , "Agrupar por","mv_ch1","N",1,0,1,"C","","","","","MV_PAR01","Ocorrencia", " ", " ", " ", "Tecnico", " ", " ", "Setor", " ", " ", "Solicitante", " ", " ", "", " ", " ", Nil, Nil, Nil, cPerg )
 	    PutSX1(cPerg, "02","de Data"         ,"de Data"            ,"de Data"          ,"mv_ch2","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",NIL,NIL,NIL,"")
	    PutSX1(cPerg, "03","ate Data"        ,"ate Data"           ,"ate Data"         ,"mv_ch3","D",8,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",NIL,NIL,NIL,"")

	if !empty(_sAlias)
      DbSelectArea(_sAlias)
 	endif 
Return*/