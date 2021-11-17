#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRQMTR01()
 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
 //Ё Define Variaveis                                             Ё
 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE CbTxt
PRIVATE Titulo := "Instrumentos Calibrar"
PRIVATE cDesc1 := "Este relatorio ira emitir a relacao de Instrumentos "
PRIVATE cDesc2 := "a calibrar."
PRIVATE cDesc3 := ""
					//   0          1           2         3         4         5         6       7         8        9          10      11        12        13         14        15       16        17         18        19      20           21         22
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := "Codigo       Descricao                   Revisao     Status        Escala           Nome Departamento          Fabricante        Departamento    Ult Calib      Prox Calib    Localizacao        Responsavel    Freq  Venc.Mes"
PRIVATE cCabec2  := ""                           
private nTipo := 18                                                            
PRIVATE Tamanho:= "G"
PRIVATE Limite := 220
PRIVATE cString:= "QM2"
private m_pag    := 01  
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }			
PRIVATE nomeprog:="BRQMTR01"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRQMTR01"


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//CriaSX1(cPerg)  //LGS#20200204 - AdequaГЦo de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

wnrel:="BRQMTR01"            //Nome Default do relatorio em Disco

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

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio do Processamento do Relatorio                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

RptStatus({|| RptDetail()})

return


/////////////////////////////////////////////////////////
//                                                     //
// FunГЮo....: RPTDETAIL    Data....: 03/10/13         //
// Autor.....: Marcelo J. A. de Paiva                  //
//                                                     //
/////////////////////////////////////////////////////////

Static Function RptDetail()

Local 	_nCont		:= 0
//Local lNormal
Private _nLin 		:= 7

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa  regua de impressao                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


	cQuery:= "SELECT QM2_INSTR, QM2_DESCR, QM2_REVINS, "+; 
				"CASE "+; 
				"WHEN QM2_STATUS ='M' THEN 'MANUTENCAO' "+; 
				"WHEN QM2_STATUS ='D' THEN 'DEFEITO' "+;
				"WHEN QM2_STATUS ='A' THEN 'ATIVO' "+;
				"WHEN QM2_STATUS ='R' THEN 'RESERVA' "+;
				"WHEN QM2_STATUS ='I' THEN 'INATIVO' "+;
				"WHEN QM2_STATUS ='0' THEN 'MALHA' "+;
				"ELSE QM2_STATUS "+;
				"END AS T_STATUS, "+;
				"QMR_ESCALA, QM2_FABR, QM2_DEPTO, QAD_DESC, "+;
				"ISNULL((SUBSTRING(QM6_DATA,7,2)+'/'+SUBSTRING(QM6_DATA,5,2)+'/'+SUBSTRING(QM6_DATA,1,4)),'S/CALIBRACAO') AS 'DT_ULT_CALIB', "+; 
				"QM2_FREQAF, SUBSTRING(QM2_VALDAF,7,2)+'/'+SUBSTRING(QM2_VALDAF,5,2)+'/'+SUBSTRING(QM2_VALDAF,1,4) AS 'DT_PROX_CALIB', "+;
				"QAA_NOME,(DATEDIFF(MONTH,GETDATE(),QM2_VALDAF)) AS 'VENCIDO_MESES', QM2_LOCAL "+;   
				"FROM " +RetSqlName("QM2")+ " QM2 WITH (NOLOCK) "+;
				"LEFT OUTER JOIN " +RetSqlName("QMP")+ " QMP WITH (NOLOCK) ON (QM2_STATUS = QMP_STATUS) AND QMP.D_E_L_E_T_ ='' "+;
				"LEFT OUTER JOIN " +RetSqlName("QAA")+ " QAA WITH (NOLOCK) ON (QM2_FILIAL = QAA_FILIAL) AND (QM2_RESP = QAA_MAT) AND (QAA.D_E_L_E_T_ ='') "+;
				"LEFT OUTER JOIN " +RetSqlName("QAD")+ " QAD WITH (NOLOCK) ON (QM2_DEPTO = QAD_CUSTO) AND (QAD.D_E_L_E_T_ ='') "+;
				"LEFT OUTER JOIN " +RetSqlName("QM6")+ " QM6 WITH (NOLOCK) ON (QM2_INSTR = QM6_INSTR) AND (QM2_REVINS = QM6_REVINS) AND (QM6.D_E_L_E_T_ ='') "+;
				"LEFT OUTER JOIN " +RetSqlName("QMR")+ " QMR WITH (NOLOCK) ON (QM2_INSTR = QMR_INSTR) AND (QM2_REVINS = QMR_REVINS) AND (QMR.D_E_L_E_T_ ='') "+;
				"WHERE (QM2.D_E_L_E_T_ = '') AND (QM2_FILIAL = '"+xFilial("QM2")+"') AND (QMP_ATUAL ='S') AND (DATEDIFF(DAY,GETDATE(),QM2_VALDAF) < 60) "+;
				iif(!empty(MV_PAR03)," AND (QM2_STATUS = '"+MV_PAR03+"')","")+ " AND (QM2_INSTR >= '"+MV_PAR01+"')AND (QM2_INSTR <= '"+MV_PAR02+"') AND ((DATEDIFF(MONTH,GETDATE(),QM2_VALDAF)) <= '"+alltrim(str(MV_PAR04))+"')"+;
				"ORDER BY QM2_VALDAF, QM2_LOCAL "

TCQuery cQuery NEW ALIAS "TCQ"         

SetRegua(RECCOUNT())
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			

dbselectarea("TCQ")
dbgotop()

While !eof()
	_nCont++ 
	if _nCont > 20
	@ _nLin,000 psay replicate("_",220)
		_nCont := 1
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 07
	endif 


///imprimir dados Metrologia

 	_nLin++
 	@ _nLin,000 psay TCQ->QM2_INSTR
 	@ _nLin,014 psay TCQ->QM2_DESCR
    @ _nLin,047 psay TCQ->QM2_REVINS
    @ _nLin,054 psay TCQ->T_STATUS 
    @ _nLin,068 psay TCQ->QMR_ESCALA   
    @ _nLin,085 psay TCQ->QAD_DESC
    @ _nLin,112 psay TCQ->QM2_FABR 
 	@ _nLin,130 psay TCQ->QM2_DEPTO 
    @ _nLin,145 psay TCQ->DT_ULT_CALIB      
    @ _nLin,160 psay TCQ->DT_PROX_CALIB
    @ _nLin,173 psay TCQ->QM2_LOCAL
	@ _nLin,193 psay substr(TCQ->QAA_NOME,1,6)+ " "+ substr(TCQ->QAA_NOME,23,29)
    @ _nLin,209 psay transform(TCQ->QM2_FREQAF,"@E 9,999")
	@ _nLin,213	 psay +transform(TCQ->VENCIDO_MESES,"@E 9,999")
	_nLin++
	_nLin++
	@ _nLin,000 psay replicate("-",220)

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
Programa  : CRIASX1   Autor:  MARCELO PAIVA
Data      : 04/10/13
Descricao : Grava Perguntas
/*/
//LGS#20200204 - AdequaГЦo de release 12.1.25 e posteriores
/*
Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol
AAdd(aHelp, {{"Informe de Codigo"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Codigo"}, {""}, {""}})
AAdd(aHelp, {{"Informe Status "},  {""}, {""}})
AAdd(aHelp, {{"Vencimento menor que Mes"},  {""}, {""}})


PutSX1(cPerg,"01","do Codigo" ,"","","mv_ch1","C",15,00,00,"G","","QM2","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","ate Codigo","","","mv_ch2","C",15,00,00,"G","","QM2","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Status","","","mv_ch3","C",1,00,00,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Vencimento","","","mv_ch4","N",3,00,00,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")

Return
*/