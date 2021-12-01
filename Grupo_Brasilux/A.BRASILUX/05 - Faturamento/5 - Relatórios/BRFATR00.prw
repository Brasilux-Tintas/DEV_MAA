#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

User Function BRFATR00()     
Private tamanho,limite,cDesc1,cDesc2,cDesc3,cCabec,cCabec1,cCabec2,cCabec3
Private aReturn,nomeprog,cPerg,nLastKey,nLin,nCol,wnrel,nTipo
Private mv_par01,MV_PAR02,m_pag,nTamNf
     u_zcfga01( 'BRFATR00' ) //LGS#2021201 - GravaГЦo de log de utilizaГЦo da rotina
m_pag = 01
tamanho  :="M"
titulo   :=" borderТ de despacho por produto"
cDesc1   :=PADC("Relatorio de borderТ de despacho por produto com projeГЦo de saldo",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR00"
cPerg    :="BRFATR00"
nLastKey := 0
nLin    := 0
nCol     := 0
wnrel    := "BRFATR00"
nTipo    := 15
//																    9999 999,999.9			   9,999	       999,999.9  999,999.9	
//               0       1           2        3           4       5          6  *       7  *       8  *     9        10        11
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "Codigo        DescriГЦo                                Qtde     Saldo Lote-Prod Qtde OP Alm-Fat Sld-Alm-Fat Sld-Alm-30 Pallet"
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 132     // Apenas Informativo
cString  := "SZB"

	if !u_VldAcesso(funname())
      MsgBox("Acesso nЦo autorizado!---->"+funname(),"AtenГЦo","Alert")
      return 
  	endif 

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//ValidPerg(cPerg)
Pergunte(cPerg,.F.)   


wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica Posicao do Formulario na Impressora                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio do Processamento do Relatorio                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	RptStatus({|| RptDetail()})
Return

Static Function RptDetail()
Local cQuery,nPesoTotal,nValorTotal,cFilterUser

if empty(mv_par01) .and. empty(mv_par02)
	MsgBox("Preencha o Nro do BorderТ OU o Nro do Pedido!","AtenГЦo","Alert")
	return
endif

if !empty(mv_par01) .and. !empty(mv_par02)
	MsgBox("Preencha APENAS o Nro do BorderТ OU o Nro do Pedido!","AtenГЦo","Alert")
	return
endif

cFilterUser := U_TRATAFILTRO(aReturn[7]) // Chama Func. p/ tratar filtro p/ SQL Server
//Cleber (16/12/2019) -> Mudando o MAX(C6_LOCAL) para que se possa enxergar pedidos com mesmo produto e locais diferentes
cQuery := "WITH TMP AS (SELECT C6_PRODUTO AS CODPRO,MAX(B1_DESC) AS DESCRICAO,SUM(C6_QTDVEN) AS QTDEBOR,"+;
"SUM(CASE WHEN C6_NOTA = '' THEN C6_QTDVEN ELSE 0 END) AS REQ,C6_LOCAL AS LOCC6,"+;
"MAX(ISNULL(B2_30.B2_QATU,0)) AS SALDO30,"+;
"LOTE = ISNULL((SELECT TOP 1 C2_LOTE AS LOTE FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) WHERE (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_DATRF = '') AND (C2_PRODUTO = SC6.C6_PRODUTO) ORDER BY LOTE),''), "+;
"PALLET = ISNULL((SELECT TOP 1 ZZK_CODIGO "+;
"FROM "+RetSqlName("ZZK")+" ZZK WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH (NOLOCK) ON (ZZJ.D_E_L_E_T_ <> '*') AND (ZZJ_FILIAL = ZZK_FILIAL) AND (ZZJ_CODIGO = ZZK_CODIGO) "+;
"WHERE (ZZK_FILIAL = '"+xFilial("ZZK")+"') AND (ZZK_PRODUT = SC6.C6_PRODUTO) AND (ZZJ_LOCORI = '') "+;
"ORDER BY ZZK.R_E_C_N_O_ DESC ),'') "
if !empty(mv_par01)
	cQuery += "FROM "+RetSqlName("SZB")+" SZB WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (RIGHT(ZB_PEDIDO,6) = C6_NUM) "
else
	cQuery += "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "
endif 
cQuery += "LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (C6_TES = F4_CODIGO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (C6_PRODUTO = B1_COD) "+;
"LEFT OUTER JOIN "+RetSqlName("SB2")+" B2_30 WITH (NOLOCK) ON (B2_30.D_E_L_E_T_ <> '*') AND (B2_30.B2_FILIAL = '"+xFilial("SB2")+"') AND (C6_PRODUTO = B2_30.B2_COD) AND (B2_30.B2_LOCAL = '30') "
if !empty(mv_par01)
	cQuery += "WHERE (SZB.D_E_L_E_T_ <> '*') AND (ZB_FILIAL = '"+xFilial("SZB")+"') AND (ZB_CODIGO = '"+MV_PAR01+"') "
else
	cQuery += "WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = '"+MV_PAR02+"') "
endif     
cQuery += "AND (F4_ESTOQUE <> 'N') "
cQuery += "GROUP BY C6_PRODUTO,C6_LOCAL) "+;
"SELECT TMP.*,SB2.B2_QATU AS QLOCPAD,ISNULL(C2_QUANT,0) AS QTDEOP,SB2.B2_QATU - TMP.REQ AS SALDO,ORDEM = CASE WHEN SB2.B2_QATU < TMP.REQ THEN '' ELSE LOTE END "+;
"FROM TMP "+;
"LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (SB2.B2_FILIAL = '"+xFilial("SB2")+"') AND (TMP.CODPRO = SB2.B2_COD) AND (TMP.LOCC6 = SB2.B2_LOCAL) "+;
"LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON (SC2.D_E_L_E_T_ <> '*') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_LOTE > '') AND (C2_LOTE = TMP.LOTE) AND (C2_PRODUTO = TMP.CODPRO) "+;
"ORDER BY ORDEM,SALDO,LOCC6"

 TCQuery cQuery NEW ALIAS "TCQ" 
    
dbSelectArea("TCQ")
dbgotop()
  
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa  regua de impressao                            Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  SetRegua(Reccount())
  Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
  nLin = 07
  nPesoTotal := 0
  nValorTotal := 0
  While ! EoF()         
    	If nlin >= 60
    		nLin+=1
    		@nLin,000 psay replicate("_",nTamNf)
      		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      		nLin := 07    
    	Endif       

    	nLin+=1
    	@nLin,000 psay ALLTRIM(TCQ->CODPRO)
    	@nLin,014 psay SUBSTR(ALLTRIM(TCQ->DESCRICAO),1,40)
    	@nLin,055 psay transform(TCQ->QTDEBOR,"@E 9999")
    	@nLin,060 psay transform(TCQ->SALDO,"@E 999,999.9")
    	@nLin,070 psay TCQ->LOTE
    	@nLin,082 psay transform(TCQ->QTDEOP,"@E 9,999")     
    	@nLin,088 psay TCQ->LOCC6  
    	@nLin,098 psay transform(TCQ->QLOCPAD,"999,999.9")
    	@nLin,109 psay transform(TCQ->SALDO30,"999,999.9")
    	@nLin,119 psay TCQ->PALLET      
    	
    	dbselectarea("TCQ")
    	dbskip()
    	IncRegua()

  	End
	If (nlin+3) >= 60
   		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
   		nLin := 07
   	Endif        
   	 
   	nLin++
   	@nLin,000 psay replicate("_",nTamNf)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                      FIM DA IMPRESSAO                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


dbSelectArea("TCQ")
dbCloseArea()

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                   FUNCOES ESPECIFICAS                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

/*
Static Function ValidPerg(cPerg)
Local _sAlias
Local aHelp1
_sAlias := Alias()

aHelp1 := {}
aAdd( aHelp1, "Informe o numero do bordero de des-" )
aAdd( aHelp1, "pacho.Deixe em branco p/ desconsiderar")
PutSX1(cPerg,"01","Bordero?" ,"Bordero?","Bordero?","mv_ch1","C",6,00,00,"G","","SZA","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp1,aHelp1,aHelp1,"")

aHelp1 := {}
aAdd( aHelp1, "Informe o numero do pedido. Deixe   " )
aAdd( aHelp1, "em branco p/ desconsiderar          " )
PutSX1(cPerg,"02","Pedido?" ,"Pedido?","Pedido?","mv_ch2","C",6,00,00,"G","","SC5","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp1,aHelp1,aHelp1,"")

dbSelectArea(_sAlias)
Return
*/
