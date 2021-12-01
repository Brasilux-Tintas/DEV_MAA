#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BRFATRX0()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define Variaveis                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Últ. Compra p/ Repr"
PRIVATE cDesc1 := "Este relatorio ira emitir a Relacao "
PRIVATE cDesc2 := "de Ult. Compra por Representante"
PRIVATE cDesc3 := "" 
PRIVATE cCabec1  := "COD PROD            DESCRICAO                           ULT COMPRA   VLR COMPRA"
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRFATRX0"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRFATRX0"
     
  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRFATRX0' ) //LGS#2021201 - Gravação de log de utilização da rotina
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaSX1(cPerg)
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:="BRFATRX0"            //Nome Default do relatorio em Disco

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
Local cRepres
Local cCliente,cNomeVend
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cQuery := "SELECT A1_VEND AS REPRES,CODCLI,A1_NOME AS RAZAO,A1_END AS ENDERECO,A1_MUN AS CIDADE,A1_EST AS UF,CODPRO, "+;
		 "B1_DESC AS DESCRPRO,ULTCOMPRA,VALORPAGO FROM " +;
		 "(SELECT D2_CLIENTE AS CODCLI,D2_COD AS CODPRO,D2_EMISSAO AS ULTCOMPRA,D2_PRCVEN AS VALORPAGO, "+;
		 "ROW_NUMBER() OVER (PARTITION BY D2_CLIENTE,D2_COD ORDER BY D2_CLIENTE,D2_COD,D2_EMISSAO DESC) AS ITEM "+;
		 "FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
		 "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (D2_TES = F4_CODIGO) "+;
		 "WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND (F4_DUPLIC <> 'N') "
	IF !EMPTY(MV_PAR04) .AND. (MV_PAR04 >= MV_PAR03)
		 cQuery += "AND (D2_CLIENTE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
	ENDIF 
	IF !EMPTY(MV_PAR06) .AND. (MV_PAR06 >= MV_PAR05)
		 cQuery += "AND (D2_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') "
	ENDIF 
		 cQuery += ") TEMP "+;
		 "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (CODCLI = A1_COD) "+;
		 "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (CODPRO = B1_COD) "+; 
		 "WHERE (ITEM = 1) "
	IF !EMPTY(MV_PAR02) .AND. (MV_PAR02 >= MV_PAR01)
		 cQuery += "AND (A1_VEND BETWEEN  '"+MV_PAR01+"' AND '"+MV_PAR02+"') "
	ENDIF 
		 cQuery += " AND "+;
		 "(ULTCOMPRA BETWEEN '"+dtos(MV_PAR07)+"' AND '"+dtos(MV_PAR08)+"') "+; 
		 "ORDER BY REPRES,CODCLI,CODPRO "

TCQuery cQuery NEW ALIAS "TCQ"         
dbselectarea("SA3")	
dbsetorder(1)
	dbSelectArea("TCQ")
  	dbgotop()
cRepres:=TCQ->REPRES
cCliente := TCQ->CODCLI
 	While ! EoF()         
		cRepres := TCQ->REPRES       
		dbselectarea("SA3")
		dbseek(xFilial("SA3")+cRepres)
		cNomeVend := iif(found(),SA3->A3_NOME,"")
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 07    
    	nLin++
    	@nLin,00 psay replicate("-",80)
       	nLin++                                                               
		@nLin,00 psay("Repres:  "+TCQ->REPRES+'-'+cNomeVend)
		nLin++
    	@nLin,00 psay replicate("-",80)
    	            
	    dbselectarea("TCQ")         
		    	  while !eof() .AND. (TCQ->REPRES == cRepres)
					cCliente := TCQ->CODCLI
				    If nlin >= 55
			    		nLin+=1
			 	   		@nLin,000 psay replicate("_",80)
				    	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			    		nLin := 07    
				    Endif        
			    	nLin++			    	
					@nLin,05 psay "Cliente: "+TCQ->CODCLI+"-"+TCQ->RAZAO
					nLin++        
					@nLin,05 psay TCQ->ENDERECO 
					@nLin,55 psay alltrim(TCQ->CIDADE)+"-"+alltrim(TCQ->UF)
					nLin++
					@nLin,00 psay replicate("-",80)
    	   			
					dbselectarea("TCQ")
			 		//dbSkip()
			 		   
			 		   while !eof() .AND. (TCQ->CODCLI == cCliente)
					      If nlin > 55
					        nLin+=1
				 	        @nLin,000 psay replicate("_",80)
					        Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
				            nLin := 07    
				          Endif        
				          nLin++
					      @nLin,00 psay TCQ->CODPRO 
					      @nLin,19 psay TCQ->DESCRPRO
					      @nLin,55 psay substr(TCQ->ULTCOMPRA,7,2)+"/"+substr(TCQ->ULTCOMPRA,5,2)+"/"+substr(TCQ->ULTCOMPRA,3,2)
					      @nLin,67 psay TCQ->VALORPAGO picture "@E 9,999,999.99"
						  dbselectarea("TCQ")
						  dbSkip()	
				 	   Enddo
				 	nLin++
    				@nLin,00 psay replicate("-",80)
    	   		  Enddo
 			Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TCQ")
dbCloseArea()

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


Static Function CriaSX1(cPerg)

Local aHelp := {}

//Texto do help em portugues  ,     ingles, espanhol

AAdd(aHelp, {{"Informe de Repres"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Repres "},  {""}, {""}})
AAdd(aHelp, {{"Informe do Cliente"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Cliente"},  {""}, {""}})
AAdd(aHelp, {{"Informe do Produto"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Produto"},  {""}, {""}})
AAdd(aHelp, {{"Informe de Ult Compra"},  {""}, {""}})
AAdd(aHelp, {{"Informe ate Ult Compra"},  {""}, {""}})

u_xPutSX1(cPerg,"01","Repres de ? " ,"","","mv_ch1","C",6,00,00,"G","","SA3","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
u_xPutSX1(cPerg,"02","Repres ate ? " ,"","","mv_ch2","C",6,00,00,"G","","SA3","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
u_xPutSX1(cPerg,"03","Cliente de " ,"","","mv_ch3","C",6,00,00,"G","","SA1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")
u_xPutSX1(cPerg,"04","Cliente ate " ,"","","mv_ch4","C",6,00,00,"G","","SA1","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")
u_xPutSX1(cPerg,"05","Produto de" ,"","","mv_ch5","C",15,00,00,"G","","SB1","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")
u_xPutSX1(cPerg,"06","Produto ate " ,"","","mv_ch6","C",15,00,00,"G","","SB1","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp[6,1],aHelp[6,2],aHelp[5,3],"")
u_xPutSX1(cPerg,"07","Ult Compra de " ,"","","mv_ch7","D",8,00,00,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp[7,1],aHelp[7,2],aHelp[7,3],"")
u_xPutSX1(cPerg,"08","Ult Compra ate " ,"","","mv_ch8","D",8,00,00,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelp[8,1],aHelp[8,2],aHelp[8,3],"")

Return
