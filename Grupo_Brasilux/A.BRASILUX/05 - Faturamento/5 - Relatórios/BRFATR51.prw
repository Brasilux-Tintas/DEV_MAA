#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFATR51     Data....: 02/08/12         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: REL VOLUMES DO BORDERO                  //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
/////////////////////////////////////////////////////////

User Function BRFATR51()     

Local cPerg
Private MV_PAR01
Private MV_PAR02
Private CbTxt    :=""
Private CbCont   :=0
Private nOrdem   :=0
Private Alfa     :=0
Private Z        :=0
Private M        :=0
Private tamanho  :="P"
Private limite   :=80
Private titulo   :="VOLUMES POR EMBALAGENS"
Private cDesc1   :=PADC("Este programa ira emitir o Rel. Volumes por Embalagem",74)
Private cDesc2   :=""
Private cDesc3   :=PADC(" ",74)
Private cCabPro  :=""
Private cNatureza:=""
Private aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
Private nomeprog :="BRFATR51"
Private nLastKey := 0
Private lContinua:=.T.
Private nLin    := 0
Private nCol     := 0
Private wnrel    := "BRFATR51"
Private nTipo    := 15
Private m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Private cCabec   :=""
Private cCabec1  := "EMBALAGEM                  QTDE             VOLUMES                                  
Private cCabec2  := ""   
Private cCabec3  := ""
Private nTamNf   := 80     // Apenas Informativo
Private cString  := "SZA"
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cPerg    := "BRFATR51"
//ValidPerg(cPerg)
Pergunte(cPerg,.F.)   
cCabec   :=PADC("VOLUMES POR EMBALAGEM",limite," ")

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

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

Local cQuery,cBord,cAuxEmba,cCliente,cPedido,_i,cTranspor,nVolTotal
Local aAux := {}   
Private nQtdeLin

dbselectarea("SA1")
dbsetorder(1)
dbselectarea("SA4")
dbsetorder(1)
dbselectarea("SC5")
dbsetorder(1)
dbselectarea("SZA")
dbsetorder(1)
dbselectarea("SZB")
dbsetorder(1)
dbselectarea("SZ5")
dbsetorder(1)
dbselectarea("ZZO")
dbsetorder(1)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(val(mv_par02)-val(mv_par01)+1)
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
nQtdeLin := 70 // Nro máx de linhas por página
nLin  := 07      
cBord := mv_par01           

cQuery := ""
cQuery += " SELECT SZA.ZA_FILIAL, SZA.ZA_CODIGO,  SA4.A4_COD , SA4.A4_NOME, SA4.A4_CGC, SA1.A1_COD, SA1.A1_NOME, SC5.C5_TRANSP, SC5.C5_REDESP, SC5.C5_NUM  "
cQuery += "	FROM "+RetSqlName("SZB")+"  SZB WITH (NOLOCK)"
cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SC5.C5_FILIAL = SZB.ZB_FILIAL AND SC5.C5_NUM = SUBSTRING(SZB.ZB_PEDIDO,3,6) AND SC5.D_E_L_E_T_ ='' "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.D_E_L_E_T_ ='' "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON SZA.ZA_FILIAL = SZB.ZB_FILIAL AND SZA.ZA_CODIGO = SZB.ZB_CODIGO AND SZA.D_E_L_E_T_ ='' "
cQuery += " LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 WITH (NOLOCK) ON SA4.A4_COD = SC5.C5_REDESP AND SA4.D_E_L_E_T_ ='' "
cQuery += " WHERE SZB.D_E_L_E_T_ ='' AND SZA.ZA_FILIAL ='"+xFilial("SZA")+"' AND SZA.ZA_CODIGO BETWEEN '"+Alltrim(MV_PAR01)+"' AND '"+Alltrim(MV_PAR02)+"' "
cQuery += " ORDER BY SA4.A4_NOME, SZB.ZB_PEDIDO " 
TCQuery cQuery NEW ALIAS "TCQ" 

nVolTotal := 0
dbSelectArea("TCQ")
dbgotop()

do while !eof() .and. (TCQ->ZA_FILIAL == xFilial("SZA")) .AND. (TCQ->ZA_CODIGO >= mv_par01) .AND. (TCQ->ZA_CODIGO <= mv_par02)
	If nLastKey == 27
		exit
	Endif
           
	// Mensagens de Embalagens
	cCliente := ""      
	cPedido  := ""   
	cTranspor:= ""
	cPedido  := TCQ->C5_NUM
	cCliente := TCQ->A1_COD
	cCliente += "-"+ALLTRIM(TCQ->A1_NOME)
	If Empty(cTranspor) .AND. !Empty(TCQ->C5_REDESP) .and. !(SUBSTR(TCQ->A4_CGC,1,8) == "72770878")
		cTranspor := TCQ->C5_REDESP+"-"+ALLTRIM(TCQ->A4_NOME)
	ElseIf !Empty(TCQ->C5_TRANSP) .and. !(SUBSTR(TCQ->A4_CGC,1,8) == "72770878")
		cTranspor := TCQ->C5_TRANSP+"-"+ALLTRIM(TCQ->A4_NOME)
	Elseif (SUBSTR(TCQ->A4_CGC,1,8) == "72770878") 
		cTranspor := ''			
	Endif
	
	dbselectarea("ZZO")
	dbseek(xFilial("ZZO")+cPedido,.t.)
/*		if found()       
			aadd(aAux,{"EMBALAGEM","QTDE","VOLUMES"})
   		endif 
*/   	   
	aAux := {}
	while !eof() .and. (xFilial("ZZO") == ZZO->ZZO_FILIAL) .AND. (ZZO->ZZO_PEDIDO == cPedido)
		cAuxEmba := padr("Diversos",16)
		dbselectarea("SZ5")
	  	dbseek(xFilial("SZ5")+ZZO->ZZO_EMBA)
	   	if found()
	   		cAuxEmba := alltrim(SZ5->Z5_DESCR)
	   	ENDIF 
	   	aadd(aAux,{SubStr(substr(ZZO->ZZO_EMBA,1,2)+"-"+Alltrim(SubStr(cAuxEmba,1,18)), 1, 16),Transform(ZZO->ZZO_QTDE,"999,999"),Transform(ZZO->ZZO_QTDVOL, "999,999")})
 		nVolTotal += ZZO->ZZO_QTDVOL

		dbselectarea("ZZO")
   		dbskip()
	enddo 
  	if len(aAux) > 0 
  		@nLin,000 psay replicate("=",limite)
  		chkpulapag()
  		nLin++
  					
		@nLin,000 psay "PEDIDO "+cPedido+" "+cCliente
  		chkpulapag()
  		nLin++
		@nLin,000 psay "Transpor.: "+cTranspor
  		chkpulapag()
  		nLin++
		for _i := 1 to len(aAux)    
			@nLin,000 psay aAux[_i,1]
  			@nLin,027 psay aAux[_i,2]
  			@nLin,044 psay aAux[_i,3]
			chkpulapag()
  			nLin++
  		next 
  		@nLin,000 psay replicate("=",limite)
  		chkpulapag()
  		nLin++

	endif 
    	   
	dbselectarea("TCQ")
	dbskip()
   	IncRegua()
end 

	
chkpulapag()
nLin++

@nLin,000 psay "TOTAL GERAL DE VOLUMES => "
@nLin,042 psay nVolTotal picture "9,999,999"

dbSelectArea("TCQ")
dbclosearea()

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                   FUNCOES ESPECIFICA                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* DESABILITADO RELEASE 12.1.25
Static Function ValidPerg(cPergP)
Local _sAlias,cPerg
_sAlias := Alias()
cPerg := PADR(cPergP,10)

       PutSX1(cPerg, "01",  "Bord Despacho de ?", "Bord Despacho de ?", "Bord Despacho de ?", "mv_ch1", "C",  6, 0, 0, "G", " ", "SZA", " ", " ", "mv_par01", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )
       PutSX1(cPerg, "02",  "Bord Despacho ate ?", "Bord Despacho ate ?", "Bord Despacho ate ?", "mv_ch2", "C",  6, 0, 0, "G", " ", "SZA", " ", " ", "mv_par02", ""                , " "        , " "     , " "   , ""                 , " "        , " "        , ""                , " "     , " "     , " "               , " "     , " "     , " "           ,  " ",  " "     , Nil  , Nil     , Nil     , cPerg )

dbSelectArea(_sAlias)
Return
*/
Static Function chkpulapag()
	If nlin >= nQtdeLin
 		nLin+=1
   		@nLin,000 psay replicate("_",limite)
     	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
      	nLin := 07
   	Endif    

return