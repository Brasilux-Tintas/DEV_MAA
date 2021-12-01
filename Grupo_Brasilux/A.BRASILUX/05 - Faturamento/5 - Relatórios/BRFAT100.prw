#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT100     Data....: 22/03/17         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: Chamado 005542 Relação de Entregas na   //
//			   Região								   //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
// mv_par01     // Per. de                             //
// mv_par02     // Per Ate                             //
// mv_par01     // Repr. de                            //
// mv_par02     // Repr. Ate                           //
/////////////////////////////////////////////////////////

User Function BRFAT100()                           
PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     u_zcfga01( 'BRFAT100' ) //LGS#2021201 - Gravação de log de utilização da rotina
CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="G"
limite   :=220
titulo   :="RELACAO DE ENTREGAS"
cDesc1   :=PADC("Este programa ira emitir a Rel. de Entregas por Transport e Cliente",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Rel. Entregas",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT100"
cPerg    :="BRFAT100"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFAT100"
nTipo    := 18
m_pag    := 01     
nTamNf   := 132     // Apenas Informativo
cString  := "SF2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

if !u_VldAcesso(funname())
	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
	return 
endif 

//ValidPerg()
Pergunte(cPerg,.F.)   

//               0       1           2        3           4       5         6        7           8        9         10       11        12
//           0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := ""
cCabec2  := "Nro NF  Razão Social                                      Qtde Vol      P. Bruto       Vlr Merc DATA FAT BORDERÔ UF CIDADE"
cCabec3  := ""

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

cCabec1  := "PERIODO DE "+dtoc(mv_par01)+" ATE "+dtoc(mv_par02)

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

	LOCAL nQtdeNfC,nQtdeNfT,nVolc,nVolT,nVlrC,nVlrT,nPesoC,nPesoT,cCliente,cQuery
	Local aFds := {}
	Local cTmp,nQtdeBor,cOrdem
	Private oTempTbl

	cQuery := "WITH TMP AS (SELECT D2_DOC AS NRONF,D2_SERIE AS SERIE,MAX(D2_EMISSAO) AS EMISSAO,MAX(D2_PEDIDO) AS PEDIDO,ISNULL(ZB_CODIGO,'') AS NUMBOR, "+;
	"D2_CLIENTE AS CLIENTE,MAX(A1_NOME) AS NOME,MAX(F2_CODCID) AS CODCID,SUM(D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END)) AS VALMERC, "+;
	"MAX(F2_VOLUME1) AS QTDEVOL,MAX(F2_PBRUTO) AS PBRUTO "+;
	"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = D2_PEDIDO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (D2_CLIENTE = A1_COD) "+;
	"LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH (NOLOCK) ON (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = '"+xFilial("SZB")+"') AND (ZB_PEDIDO = ('"+substr(cNumemp,1,2)+"'+D2_PEDIDO)) "+;
	"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND (D2_ESTOQUE = 'S') "+;
	"AND (D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') "

	IF !EMPTY(MV_PAR04)
		cQuery += "AND (F2_TRANSP BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
	ENDIF 

	IF !EMPTY(MV_PAR06)
		cQuery += "AND (F2_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') "
	ENDIF 
	
	if !empty(MV_PAR08)
		cQuery += "AND (F2_VEND1 BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') "
	ENDIF 

	if !empty(MV_PAR09)
		cQuery += "AND (F2_CODCID = '"+MV_PAR09+"') "
	endif  

	cQuery += "GROUP BY D2_SERIE,D2_DOC,D2_CLIENTE,ZB_CODIGO), "+;
	"CLIBOR AS (SELECT DISTINCT CLIENTE,NUMBOR FROM TMP),"+;
	"CLIQTDBOR AS (SELECT CLIENTE,COUNT(*) AS QTDBOR FROM CLIBOR GROUP BY CLIENTE) "+;
	"SELECT TMP.*,CLIQTDBOR.QTDBOR,Z7_EST AS UF,Z7_NOME AS CIDADE FROM TMP "+;
	"LEFT OUTER JOIN CLIQTDBOR ON TMP.CLIENTE = CLIQTDBOR.CLIENTE "+;
	"LEFT OUTER JOIN "+RetSqlName("SZ7")+" SZ7 WITH (NOLOCK) ON (SZ7.D_E_L_E_T_ <> '*') AND (Z7_FILIAL = '"+xFilial("SZ7")+"') AND (TMP.CODCID = Z7_COD) "+;
	"ORDER BY "
	DO CASE
		CASE MV_PAR10 == 2
			cQuery += "UF,CIDADE,QTDBOR DESC,NOME,TMP.CLIENTE,NUMBOR,SERIE,NRONF"
		CASE MV_PAR10 == 3
			cQuery += "NOME,TMP.CLIENTE,SERIE,NRONF"
		OTHERWISE
			cQuery += "QTDBOR DESC,NOME,TMP.CLIENTE,NUMBOR,SERIE,NRONF"
	ENDCASE
		
		
	//"ORDER BY NOME,CLIENTE,SERIE,NRONF"
 
 
 	TCQuery cQuery NEW ALIAS "TCQ"  
 
	//Criar tabela temporária pra contagem de borderôs
    aAdd( aFds , {"BORDERO", "C", 006, 000} )

    /*  DESABILITADO RELEASE 12.1.25
    cTmp := U_NovoArqTrab("dtc") 
    dbcreate(cTmp+".dtc", aFds, "CTREECDX")
    Use (cTmp+".dtc") Alias "TMP" VIA "CTREECDX" New Exclusive
    Index On BORDERO To (cTmp)  
    DBSETORDER(1)*/
      
    /*** BLOCO ALTERADO EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
    oTempTbl := FWTemporaryTable():New( "TMP" )
    oTempTbl:SetFields( aFds )
    oTempTbl:AddIndex( "cInd01", { "BORDERO" } )
    oTempTbl:Create()
    DbSelectArea( "TMP" )
    DbSetOrder(1)
       
	DBSELECTAREA("SZB")
	dbsetorder(2)    
	
//	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
// 	nLin := 08
  	dbSelectArea("TCQ")
  	dbgotop()
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	SetRegua(Reccount())     
  	//nQtdeNfC,nQtdeNfT,nVolc,nVolT,nVlrC,nVlrT,nPesoC,nPesoT
  	nQtdeNfT := 0
  	nVolT := 0
	nVlrT := 0     
	nPesoT := 0   
	nQtdeBor := 0
	nQtdBorC := 0
	nLin := 9 
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	While ! EoF()         
	    If nlin >= 60
   	  		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	   	  	nLin := 09
  	 	Endif         
   	   	cCliente = TCQ->CLIENTE     
       
       	nQtdeNfC := 0      
       	nQtdBorC := 0
		nVolc := 0
		nVlrC := 0
		nPesoC := 0
    	dbselectarea("TCQ")
    	while !eof() .AND. (TCQ->CLIENTE == cCliente)
    		If nlin >= 60
 	   			@nLin,000 psay replicate("_",limite)
	      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
    	  		nLin := 09
	    	Endif         

	      	@nLin,00 psay ALLTRIM(TCQ->NRONF)
    		@nLin,08 psay SUBSTR(TCQ->CLIENTE+"-"+TCQ->NOME,1,47)
    		@nLin,56 psay TCQ->QTDEVOL picture "@E 99,999,999"
    		@nLin,67 psay TCQ->PBRUTO picture "@E 999,999,999.9"
    		@nLin,81 psay TCQ->VALMERC picture "@E 999,999,999.99"
	      	@nLin,96 psay SUBSTR(TCQ->EMISSAO,7,2)+"/"+SUBSTR(TCQ->EMISSAO,5,2)+"/"+SUBSTR(TCQ->EMISSAO,3,2)
	      	@nLin,105 psay TCQ->NUMBOR
	      	@nLin,113 psay TCQ->UF
	      	@nLin,116 psay TCQ->CIDADE
	      	
    		nLin++
    		
	    	
			nQtdeNfC++
	       	nQtdBorC := TCQ->QTDBOR

			nVolc += TCQ->QTDEVOL
			nVlrC += TCQ->VALMERC
			nPesoC += TCQ->PBRUTO	    	 

			dbselectarea("TMP")
	  		dbseek(TCQ->NUMBOR)
   			if !found()
        	   nQtdeBor++
    	       RecLock("TMP", .t.)
        	   TMP->BORDERO := TCQ->NUMBOR      
        	   MsUnLock()
			endif

			dbselectarea("TCQ")
 			dbskip()
 			IncRegua()
 		Enddo     
		@nLin,000 psay replicate("_",limite)
		nLin++ 
	  	nQtdeNfT += nQtdeNfC
  		nVolT += nVolc
		nVlrT += nVlrC   
		nPesoT += nPesoC

    	If (nLin >= iif((nQtdeNfC > 1),58,60))
 	   		@nLin,000 psay replicate("_",limite)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 09  
    	Endif    
		if (nQtdeNfC > 1)     	    
			@nLin,08 psay cCliente+"->TOTAIS=>  Qtde Nf's : "
			@nLin,39 psay nQtdeNfC picture "@E 999,999"
	   		@nLin,56 psay nVolc picture "@E 99,999,999"
   			@nLin,67 psay nPesoC picture "@E 999,999,999.9"
   			@nLin,81 psay nVlrC picture "@E 999,999,999.99"     
		    @nLin,96 psay "Qtde de Borderôs: "
		    @nLin,117 psay nQtdBorC picture "@E 9,999"
			nLin++ 
			@nLin,000 psay replicate("_",limite)
    	   	nLin++
   		endif
		dbselectarea("TCQ")
	Enddo
	If nlin >= 58
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  		nLin := 09
 	endif
	@nLin,000 psay replicate("=",limite)
   	nLin++
	@nLin,00 psay "Qtde Nf's Total => "
	@nLin,37 psay nQtdeNfT picture "@E 9,999,999"
 	@nLin,56 psay nVolT picture "@E 99,999,999"
   	@nLin,67 psay nPesoT picture "@E 999,999,999.9"
   	@nLin,81 psay nVlrT picture "@E 999,999,999.99"
	@nLin,96 psay "Total de Borderôs: "
   	@nLin,117 psay nQtdeBor picture "@E 9,999"
   	nLin++

	@nLin,000 psay replicate("=",limite)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	dbSelectArea("TCQ")
	dbCloseArea()
	DbSelectArea("TMP")
	DbCloseArea()

	If ValType (oTempTbl)=="O"
		oTempTbl:Delete()
	Endif

	Set Device To Screen
	If aReturn[5] == 1
		Set Printer TO
		dbcommitAll()
		ourspool(wnrel)
	Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICAS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
Programa  : VALIDPERG   Autor: 
Descricao : Grava Perguntas
/*/
/*
Static Function ValidPerg()
Local _sAlias := Alias()
Local aHelp := {}



dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}
//            Texto do help em português    , inglês, espanhol
AAdd(aHelp, {{"Data Inicial de Emissao da NF"},  {"Data Inicial de Emissao da NF"}, {"Data Inicial de Emissao da NF"}})
AAdd(aHelp, {{"Data Final de Emissao da NF"},  {"Data Final de Emissao da NF"}, {"Data Final de Emissao da NF"}})

//SX1 (<cGrupo>, <cOrdem>, <cPergunt>, <cPergSpa>, <cPergEng>, <cVar>, <cTipo>, <nTamanho>, [nDecimal], [ nPreSel], < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme], < cVar01>, [ cDef01], [ cDefSpa1], [ cDefEng1], [ cCnt01], [ cDef02], [ cDefSpa2], [ cDefEng2], [ cDef03], [ cDefSpa3], [ cDefEng3], [ cDef04], [ cDefSpa4], [ cDefEng4], [ cDef05], [ cDefSpa5], [ cDefEng5], [ aHelpPor], [ aHelpEng], [ aHelpSpa], [ cHelp] ) --> Nil
PutSX1(cPerg,"01","Data Emissao De  ?" ,"Data Emissao De  ?","Data Emissao De  ?","mv_ch1","D",8,00,00,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSX1(cPerg,"02","Data Emissao Ate ?" ,"Data Emissao Ate ?","Data Emissao Ate ?","mv_ch2","D",8,00,00,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")
PutSX1(cPerg,"03","Transp de ? " ,"Transp de ? ","Transp de ? ","mv_ch3","C",6,00,00,"G","","SA4","","","MV_PAR03","","","","","","","","","","","","","","","","", Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"04","Transp ate ?" ,"Transp ate ?","Transp ate ?","mv_ch4","C",6,00,00,"G","","SA4","","","MV_PAR04","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"05","Cliente de "  ,"Cliente de ","Cliente de ","mv_ch5","C",6,00,00,"G","","SA1","","","MV_PAR05","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"06","Cliente ate " ,"Cliente ate ","Cliente ate ","mv_ch6","C",6,00,00,"G","","SA1","","","MV_PAR06","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"07","Repres de "   ,"Repres de ","Repres de ","mv_ch7","C",6,00,00,"G","","SA3","","","MV_PAR07","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
PutSX1(cPerg,"08","Repres ate "  ,"Repres ate ","Repres ate ","mv_ch8","C",6,00,00,"G","","SA3","","","MV_PAR08","","","","","","","","","","","","","","","","",Nil  , Nil     , Nil,cPerg)
aHelp := {}
AAdd(aHelp, {{"Cód. Cidade. BRANCO = TODAS"},  {"Cód. Cidade. BRANCO = TODAS"}, {"Cód. Cidade. BRANCO = TODAS"}})
PutSX1(cPerg,"09","Cidade: "  ,"Cidade: ","Cidade: ","mv_ch9","C",6,00,00,"G","","SZ7","","","MV_PAR09","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
aHelp := {}
AAdd(aHelp, {{"Defina a Ordem do Relatorio"},  {"Defina a Ordem do Relatorio"}, {"Defina a Ordem do Relatorio"}})
PutSX1(cPerg,"10","Ordem de "          ,"Ordem de"            ,"Ordem de"            ,"mv_cha","N",1,0,00,"C","","","","","MV_PAR10","Qtde Bord/Cli"   ,"Qtde Bord/Cli"    ,"Qtde Bord/Cli"    ,"","Cidade"          ,"Cidade"           ,"Cidade"           ,"Nome Cliente"     ,"Nome Cliente"          ,"Nome Cliente"          ,""                 ,""                      ,""                      ,""             ,""       ,""            ,aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)

dbSelectArea(_sAlias)
Return
*/
