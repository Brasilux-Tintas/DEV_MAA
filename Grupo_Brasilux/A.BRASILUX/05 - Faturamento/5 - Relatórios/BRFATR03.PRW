#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"   

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFATR03     Data....: 02/08/12         //
// Autor.....: Cleber Orati Domingues                  //
// Descriçao.: REL VOLUMES DO BORDERO                  //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////  
//                                                     //
// Variaveis utilizadas para parametros                //         
//                                                     //        
/////////////////////////////////////////////////////////

User Function BRFATR03()     
Local cPerg
SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")
SetPrvt("MV_PAR01,MV_PAR02")

     u_zcfga01( 'BRFATR03' ) //LGS#2021201 - Gravação de log de utilização da rotina

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="P"
limite   :=80
titulo   :="VOLUMES POR EMBALAGENS"
cDesc1   :=PADC("Este programa ira emitir o Rel. Volumes por Embalagem",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFATR03"
nLastKey := 0
lContinua:=.T.
nLin    := 0
nCol     := 0
wnrel    := "BRFATR03"
nTipo    := 15
m_pag    := 01     
//               0       1           2        3           4       5          6  *       7  *       8  *     9           10        11      12        13
//           01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
cCabec1  := "EMBALAGEM                  QTDE             VOLUMES                                  
cCabec2  := ""   
cCabec3  := ""
nTamNf   := 80     // Apenas Informativo
cString  := "SZA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     
 if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
	

cPerg    := "BRFATR03"
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
Local cBord,cAuxEmba,cCliente,cPedido,_i,cTranspor
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
nQtdeLin = 70 // Nro máx de linhas por página
nLin = 07      
cBord := mv_par01           
dbselectarea("SZA")
dbseek(xFilial("SZA")+cBord)
do while !eof() .and. (SZA->ZA_FILIAL == xFilial("SZA")) .AND. (SZA->ZA_CODIGO >= mv_par01) .AND. (SZA->ZA_CODIGO <= mv_par02)
	If nLastKey == 27
		exit
	Endif
           
	dbselectarea("SZB")
	dbseek(xFilial("SZB")+SZA->ZA_CODIGO,.T.)
	do while !eof() .and. (SZB->ZB_FILIAL == xFilial("SZB")) .AND. (SZB->ZB_CODIGO == SZA->ZA_CODIGO)   
		If nLastKey == 27
			exit
		Endif
		
		// Mensagens de Embalagens
		cCliente := ""      
		cPedido := ""   
		cTranspor := ""
		dbselectarea("SC5")
		dbseek(xFilial("SC5")+SUBSTR(SZB->ZB_PEDIDO,3,6))
		if found() 
			cPedido := SC5->C5_NUM
			cCliente := SC5->C5_CLIENTE
			dbselectarea("SA1")
			dbseek(xFilial("SA1")+cCliente)
			if found()
				cCliente += "-"+ALLTRIM(A1_NOME)
			ENDIF                 
			if !empty(SC5->C5_TRANSP)
				dbselectarea("SA4")
				dbseek(xFilial("SA4")+SC5->C5_TRANSP)
				if found() .and. !(SUBSTR(SA4->A4_CGC,1,8) == "72770878")
					cTranspor := SC5->C5_TRANSP+"-"+ALLTRIM(SA4->A4_NOME)
				endif
			endif
			if empty(cTranspor) .AND. !empty(SC5->C5_REDESP)
				dbselectarea("SA4")
				dbseek(xFilial("SA4")+SC5->C5_REDESP)
				if found() .and. !(SUBSTR(SA4->A4_CGC,1,8) == "72770878")
					cTranspor := SC5->C5_REDESP+"-"+ALLTRIM(SA4->A4_NOME)
				endif
			endif
			
		endif 
		
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
    	   
		dbselectarea("SZB")
    	dbskip()
    	IncRegua()
  	End					

	dbselectarea("SZA")
	dbskip()
   	IncRegua()
 end 
	
chkpulapag()
nLin++

/*

cQuery := "EXEC DRE '"+dtos(mv_par01)+"','"+dtos(mv_par02)+"','"+alltrim(MV_PAR03)+"'"

TCQuery cQuery NEW ALIAS "TCQ" 

dbSelectArea("TCQ")
dbgotop()
*/  

	
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
/* DESABILITADO EM FUNÇÃO DA RELEASE 12.1.25
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
