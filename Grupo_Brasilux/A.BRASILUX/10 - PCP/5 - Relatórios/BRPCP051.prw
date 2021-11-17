#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Relatório para consulta tabela SBC para acompanhamento dos   ³
//  apontamentos de perda 										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function BRPCP051()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Consulta Envase de Ordens de Produção"
PRIVATE cDesc1 := "Este relatorio ira emitir a relação de O.P's"
PRIVATE cDesc2 := "envasadas por funcionário com apontamento de perda"
PRIVATE cDesc3 := ""
PRIVATE cCabec1  := "  CODIGO          LOTE       QTD PREV   QTD ENV   DATA /HORA INICIO    DATA /HORA FIM              FUNCIONÁRIO            "
PRIVATE cCabec2  := ""                                                                                                                         
private nTipo := 18
PRIVATE Tamanho:= "M"
PRIVATE Limite := 132
PRIVATE cString:= ""
private m_pag    := 01  
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }			
PRIVATE nomeprog:="BRPCP051"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRPCP051"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//CriaSX1(cPerg)  //LGS#20200131 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Da linha ?          99                ³
//³ mv_par02        	// Até linha ?         99                ³ 
//³ mv_par03        	// Do produto  ?       XXXXXXXXXXXXXXX   ³
//³ mv_par04        	// Até o produto ?     XXXXXXXXXXXXXXX   ³
//³ mv_par05        	// Da data  ?          99/99/99          ³
//³ mv_par06        	// Até a data ?        99/99/99          ³ 
//³ mv_par07        	// Do Matricula ?      9999              ³
//³ mv_par08        	// Até a Matricula ?   9999              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="BRPCP051"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

Return


/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: RPTDETAIL    Data....: 01/03/02         //
// Autor.....: Renato P. Zuccolotto                    //
// Descriçao.: Seleciona os dados                      //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////

Static Function RptDetail()

Private _nLin:= 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    //CONSULTA                                                                                                      
    
	cQuery :="SELECT ZZG_FILMAT,ZZG_NOME,ZZG_LOTE,ZZG_PROENV,C2_QUANT,ZZA_QUANT,ZZA_DTINI, ZZA_HINI,ZZA_DTFIM,ZZA_HFIM "+;
 		"FROM "+RETSQLNAME("ZZG")+" ZZG "+; 
		"LEFT OUTER JOIN "+RETSQLNAME("ZZA")+ " ZZA ON (ZZA.D_E_L_E_T_ <> '*') AND (ZZA_FILIAL = ZZG_FILIAL) AND (ZZG_PROENV = ZZA_PRODUT) AND (ZZG_LOTE = ZZA_LOTE) AND (ZZG_SEQENV = ZZA_SEQENV) "+; 
		"LEFT OUTER JOIN "+RETSQLNAME("SC2")+ " SC2 ON (SC2.D_E_L_E_T_ <> '*') AND (ZZG_FILIAL = C2_FILIAL) AND (ZZG_LOTE = C2_LOTE) AND (ZZG_PROENV = C2_PRODUTO) "+;
		"WHERE (ZZG.D_E_L_E_T_ <> '*') AND (ZZG_FILIAL = '"+xFilial("ZZG")+"') AND (ZZG_TPUSER = 'E') "+;
		"AND (SUBSTRING(ZZG_PROENV, 4, 2)>= '"+MV_PAR01+"') AND (SUBSTRING(ZZG_PROENV, 4, 2)<='"+MV_PAR02+"')  "+;
		"AND (ZZG_PROENV >= '"+MV_PAR03+"') AND (ZZG_PROENV <='"+MV_PAR04+"') "+;
		"AND ZZA_DTINI BETWEEN  '"+DTOS(MV_PAR05)+"' AND    '"+DTOS(MV_PAR06)+"' "+;
		"AND ZZG_FILMAT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "+;
 	  	"ORDER BY ZZG_LOTE DESC,ZZG_SEQENV " 
    
	  	TCQuery cQuery NEW ALIAS "TCQ" 
	    
//	  	"AND (ZZG_FILMAT >= "'01'"'"+MV_PAR07+"') AND (ZZG_FILMAT<= '"+xFilial("ZZG")+MV_PAR08+"') "+;

SetRegua(RECCOUNT())
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			

//dbSelectarea("SB1")
//dbSetorder(1)
dbSelectarea("TCQ")
dbGotop()

While !Eof()
	If _nLin > 70
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin :=07
	Endif 
 //  CODIGO          LOTE       QTD PREV   QTD ENV   DATA /HORA INICIO    DATA /HORA FIM              FUNCIONÁRIO              
 //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 //0         1         2         3         4         5         6         7         8         9         10        11        12        13 
 	@ _nLin,002 psay TCQ->ZZG_PROENV               							     										//CODIGO PRODUTO
    // 	dbSeek(TCQ->ZZG_PROENV)
	// 	@ _nLin,016 psay Substr(SB1->B1_DESC),1,40)   								    								//DESCRICAO
	@ _nLin,016 psay TCQ->ZZG_LOTE                 								    									//LOTE
	@ _nLin,024 psay (TCQ->C2_QUANT)  PICTURE "@E 99,999.99"					    									//QTDE PREVISTA
	@ _nLin,035 psay (TCQ->ZZA_QUANT) PICTURE "@E 99,999.99"					    									//QTDE ENVASADA
	@ _nLin,046 psay Substr((TCQ->ZZA_DTINI),7,2)+"/"+Substr((TCQ->ZZA_DTINI),5,2)+"/"+Substr((TCQ->ZZA_DTINI),1,4)		//DATA INICIO
	@ _nLin,058 psay Substr((TCQ->ZZA_HINI),1,2)+":"+Substr((TCQ->ZZA_HINI),3,2)										//HORA INICIO
	@ _nLin,067 psay Substr((TCQ->ZZA_DTFIM),7,2)+"/"+Substr((TCQ->ZZA_DTFIM),5,2)+"/"+Substr((TCQ->ZZA_DTFIM),1,4)		//DATA FIM
 	If !empty(TCQ->ZZA_HFIM)
  		@ _nLin,079 psay Substr((TCQ->ZZA_HFIM),1,2)+":"+Substr((TCQ->ZZA_HFIM),3,2)									//HORA FIM
	EndIf
//	@ _nLin,079 psay (TCQ->) PICTURE "@E 9,999.99" 						     											//PERDA 
	@ _nLin,096 psay Substr((TCQ->ZZG_NOME),1,25) 							    										//NOME FUNCIONÁRIO
	_nLin++
	
	dbSelectArea("TCQ")
	dbSkip()
EndDo

dbSelectarea("TCQ")
dbClosearea()

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
Endif

Return

//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
Static Function CriaSx1(cPerg)

Local aHelp := {}

//            Texto do help em português, inglês, espanhol
AAdd(aHelp, {{"Informe a linha  do produto"}, {""}, {""}})
AAdd(aHelp, {{"Informe a linha  do produto"}, {""}, {""}})
AAdd(aHelp, {{"Informe o código do produto"}, {""}, {""}})
AAdd(aHelp, {{"Informe o código do produto"}, {""}, {""}})
AAdd(aHelp, {{"Informe a data Inicial a ser consultada"}, {""}, {""}})
AAdd(aHelp, {{"Informe a data final a ser consultada"}, {""}, {""}})
AAdd(aHelp, {{"Informe a Matricula do funcionário"}, {""}, {""}})
AAdd(aHelp, {{"Informe a Matricula do funcionário"}, {""}, {""}})

PutSX1(cPerg,"01","Da Linha      ? "    ,"","","mv_ch1","C",02,00,00,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Até a Linha   ? "    ,"","","mv_ch2","C",02,00,00,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Do Produto    ? "    ,"","","mv_ch3","C",15,00,00,"G","","SB1","","","mv_par03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
PutSX1(cPerg,"04","Até o Produto ? "    ,"","","mv_ch4","C",15,00,00,"G","","SB1","","","mv_par04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
PutSX1(cPerg,"05","Data Inicial  ? "    ,"","","mv_ch5","D",08,00,00,"G","",""   ,"","","mv_par05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
PutSX1(cPerg,"06","Até a data    ? "    ,"","","mv_ch6","D",08,00,00,"G","",""   ,"","","mv_par06","","","","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[6,3],"")
PutSX1(cPerg,"07","Do Funcionário? "    ,"","","mv_ch7","C",06,00,00,"G","",""   ,"","","mv_par07","","","","","","","","","","","","","","","","",aHelp[7,1],aHelp[7,2],aHelp[7,3],"")
PutSX1(cPerg,"08","Até Funcionário?"    ,"","","mv_ch8","C",06,00,00,"G","",""   ,"","","mv_par08","","","","","","","","","","","","","","","","",aHelp[8,1],aHelp[8,2],aHelp[8,3],"") 
       
//aadd(aRegs, {cPerg, '01', 'Do Funcionario ? ', ' ', ' ', 'mv_ch1', 'C',06,00,00, 'G', '          ', 'mv_par01', '         ', ' ', ' ', ' ', ' ', '    ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'SRA', 'S', ' ', ' ' } )
Return*/

