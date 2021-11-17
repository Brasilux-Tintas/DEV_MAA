#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT060     Data....: 01/03/02         //
// Autor.....:                                         //
// Descriçao.: Relatorio de Comissoes                  //
// Uso.......: Todas as Empresas 					   //
//                                                     //
// Últ. Alteração: Cleber Orati Domingues(19/08/02)    //
// Estava consid. perc. único de comissão p/ todos os  //
// itens(supondo que todos foram compensados, o que    //
// não é verdade, devido a cheques liquidados          //
// 13/02/04->Uso de Query p/ melhorar performance      //
/////////////////////////////////////////////////////////
//                                                     //
// Variaveis utilizadas para parametros                //
//                                                     //
// mv_par01     // Vendedor De                         //
// mv_par02     // Vendedor Ate                        //
// mv_par03     // Emissao DE   (excluido)             //
// mv_par04     // Emissao Ate  (excluido)             //
// mv_par03     // Pagamento de                        //
// mv_par04     // Pagamento Até                       //
/////////////////////////////////////////////////////////

User Function BRFAT060()


SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

CbTxt    :=""
CbCont   :=0
nOrdem   :=0
Alfa     :=0
Z        :=0
M        :=0
tamanho  :="P"
limite   :=132
titulo   :="COMISSOES DE VENDEDORES"
cDesc1   :=PADC("Este programa ira emitir o Rel. de Comissoes de Vendedores",74)
cDesc2   :=""
cDesc3   :=PADC(" ",74)
cCabec   :=PADC("Comissoes de Vendedores",27)
cCabPro  :=""
cNatureza:=""
aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog :="BRFAT060"
cPerg    :="BRFT60"
nLastKey := 0
lContinua:=.T.
_nLin    := 90
nCol     := 60
wnrel    := "BRFAT060"
nTipo    := 18
m_pag    := 01
//           0         10        20        30        40        50        60        70        80         
//           012345678901234567890123456789012345678901234567890123456789012345678901234567890
cCabec1  := "TITULO           CLIENTE                         VLR BASE               COMISSAO"
cCabec2  := " "
cCabec3  := " "
nTamNf   := 80     // Apenas Informativo
cString  := "SE3"

  if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ValidPerg()
Pergunte("BRFT60",.F.)

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

/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: RPTDETAIL    Data....: 01/03/02         //
// Autor.....: Renato P. Zuccolotto                    //
// Descriçao.: Seleciona os dados                      //
// Uso.......: Todas as Empresas 					   //
//                                                     //
/////////////////////////////////////////////////////////

Static Function RptDetail()

Local 	_cVend		:= "" 
Local 	_nComis		:= 0
Local 	_nCont		:= 0
Local 	nPercComis := 0
Private _nLin 		:= 7
Private	_nTotVlr    := 0
Private	_nTotComis	:= 0
Private	_nTotVlrSolv    := 0
Private	nTotComisSolv	:= 0
Private _nPercAtu	:= 0
Private nVlrComisComp := 0  // Vlr. da Comissão Compensada
Private _nVlrComp := 0 //Vlr. Parcial da Comissão Compensada
Private	_cSolv		:= ""
Private _nTotCampanha,nVlrCampanha,nTotDistrib,nVlrDistrib,nSomaBase,nTotVariavel,nVlrVariavel


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(val(mv_par02) - val(mv_par01))

  cQuery = "SELECT ISNULL(X5_DESCRI,'N') AS SOLV,ISNULL(C5_XCONF,'F') AS CAMPANHA,ISNULL(A1_CLAS,'X') AS TIPOCLI,"+;
  "ORDEM = CASE WHEN (E3_FILIAL = '060101') AND (E3_PREFIXO = 'IMP') THEN '0' ELSE '1' END,"+;
  "E3_VEND,E3_PREFIXO,E3_EMISSAO,E3_NUM,E3_PARCELA,E3_BASE,E3_COMP,"+;
  "E3_PORC,E3_PORCANT,E3_CODCLI "+;
  "FROM "+RetSqlName("SE3")+" SE3 WITH (NOLOCK) "+;
  "LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 WITH (NOLOCK) ON (SX5.D_E_L_E_T_ <> '*') AND (E3_FILIAL = X5_FILIAL) AND (X5_TABELA = '96') AND (E3_PEDIDO = X5_CHAVE) "+;
  "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = E3_FILIAL) AND (C5_NUM = E3_PEDIDO) "+;
  "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (E3_CODCLI = A1_COD) AND (E3_LOJA = A1_LOJA) "+;
  "WHERE (SE3.D_E_L_E_T_ <> '*') AND (E3_FILIAL = '"+xFilial("SE3")+"') AND "+;   
  "(LEN(E3_DATA) > 0) AND "+;
  "(E3_VEND >= '"+mv_par01+"') AND (E3_VEND <= '"+mv_par02+"') AND "+;
  "(E3_DATA >= '"+DTOS(mv_par03)+"') AND (E3_DATA <= '"+DTOS(mv_par04)+"') "+;
  "ORDER BY E3_VEND,SOLV,ORDEM,E3_PREFIXO,E3_NUM,E3_PARCELA"
  TCQuery cQuery NEW ALIAS "TCQ" 

//  "(E3_EMISSAO >= '"+DTOS(mv_par03)+"') AND (E3_EMISSAO <= '"+DTOS(mv_par04)+"') AND "+;

nTotCampanha := 0
nVlrCampanha := 0
nTotDistrib := 0
nVlrDistrib := 0
nSomaBase := 0
nTotVariavel := 0
nVlrVariavel := 0

dbselectarea("SX5")
dbsetorder(1)

dbselectarea("SA1")
dbsetorder(1)
dbselectarea("TCQ")
dbgotop()
While !eof()
		_nCont++
		If (_cVend <> TCQ->E3_VEND) .or. !(alltrim(_cSolv) == alltrim(TCQ->SOLV))
			If (_nCont <> 1)
				ImpRodape(_cVend <> TCQ->E3_VEND)
			EndIf
			_nLin := 08
			Cabec(iif(alltrim(TCQ->SOLV) == "S","**THINNER**","")+titulo+iif(alltrim(TCQ->SOLV) == "S","**THINNER**",""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
			ImpCabec()
			_nVlrComp := 0
			_nTotVlr    := 0
			if _cVend <> TCQ->E3_VEND
				nVlrComisComp := 0
				_nTotComis	:= 0    
				_nTotVlrSolv  := 0
				nTotComisSolv	:= 0    
				nTotCampanha := 0
				nVlrCampanha := 0
				nTotDistrib := 0
				nVlrDistrib := 0
				nSomaBase := 0
				nTotVariavel := 0
				nVlrVariavel := 0

			endif 
			_cSolv	:= alltrim(TCQ->SOLV)
		  	_cVend  := TCQ->E3_VEND
			IncRegua()
		EndIf
		@ _nLin,000 PSAY iif(!empty(ALLTRIM(TCQ->E3_PREFIXO)),ALLTRIM(TCQ->E3_PREFIXO)+"-","")+TCQ->E3_NUM+iif(!Empty(TCQ->E3_PARCELA),"/"+TCQ->E3_PARCELA,"")

		dbselectarea("SA1")
		dbseek(xFilial("SA1")+TCQ->E3_CODCLI)
		if found()
			@ _nLin,017 PSAY substr(SA1->A1_NOME,1,29)+"-"+sa1->a1_clas
		endif
		@ _nLin,049 PSAY TCQ->E3_BASE picture "@E 999,999.99"
		//nPercComis := IIF(TCQ->E3_COMP == "S",TCQ->E3_PORCANT,TCQ->E3_PORC) //Cleber(26/03/21) -> Tirar comissão apurada, mostrar comissão efetiva
		nPercComis := TCQ->E3_PORC
		_nComis	:= (TCQ->E3_BASE*nPercComis)/100
		@ _nLin,060 PSAY _nComis picture "@E 999,999.99"
		@ _nLin,070 psay "("+transform(nPercComis,"9999.99")+"%)"

		nVlrComisComp += (TCQ->E3_BASE*TCQ->E3_PORC)/100
		_nVlrComp += (TCQ->E3_BASE*TCQ->E3_PORC)/100
		nSomaBase += TCQ->E3_BASE

		//Totais em pág. separadas entre Thinner e o resto
		_nTotVlr	+= iif(_cSolv == "S",0,TCQ->E3_BASE)
		_nTotComis	+= iif(_cSolv == "S",0,_nComis)
		_nTotVlrSolv += iif(_cSolv == "S",TCQ->E3_BASE,0)
		nTotComisSolv += iif(_cSolv == "S",_nComis,0)

		if TCQ->CAMPANHA = "T"
			nTotCampanha += TCQ->E3_BASE
			nVlrCampanha += (TCQ->E3_BASE*TCQ->E3_PORC)/100
		endif 
		if TCQ->TIPOCLI = "D"
			nTotDistrib += TCQ->E3_BASE
			nVlrDistrib += (TCQ->E3_BASE*TCQ->E3_PORC)/100
		endif 
		if !(_cSolv == "S") .and. !(TCQ->TIPOCLI = "D") .and. !(TCQ->CAMPANHA = "T")
			nTotVariavel += TCQ->E3_BASE
			nVlrVariavel += (TCQ->E3_BASE*TCQ->E3_PORC)/100
		endif 

		_nLin++
		If _nlin >= 57
			Cabec(iif(alltrim(TCQ->SOLV) == "S","**THINNER**","")+titulo+iif(alltrim(TCQ->SOLV) == "S","**THINNER**",""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 08
		Endif
	dbSelectArea("TCQ")
	dbSkip()
EndDo
ImpRodape(.t.)

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
Programa  : IMPCABEC   Autor:  Renato P.Zuccolotto
Data      : 01/03/02
Descricao : Imprime o cabecalho do Agrupamento
/*/

Static Function ImpCabec()

_nLin++               
If _nlin >= 57
	Cabec(iif(alltrim(TCQ->SOLV) == "S","**THINNER**","")+titulo+iif(alltrim(TCQ->SOLV) == "S","**THINNER**",""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif
@ _nLin,000 PSAY replicate("=",80)
_nLin++
If _nlin >= 57
	Cabec(iif(alltrim(TCQ->SOLV) == "S","**THINNER**","")+titulo+iif(alltrim(TCQ->SOLV) == "S","**THINNER**",""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif
DbSelectArea("SA3")
DbSetOrder(1)
DbSeek(xFilial("SA3")+TCQ->E3_VEND)
_cNomVend	:= SA3->A3_NOME
@ _nLin,000 PSAY TCQ->E3_VEND+" - "+_cNomVend
_nLin++
If _nlin >= 57
	Cabec(iif(alltrim(TCQ->SOLV) == "S","**THINNER**","")+titulo+iif(alltrim(TCQ->SOLV) == "S","**THINNER**",""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif
@ _nLin,000 PSAY replicate("=",80)
_nLin+=2
If _nlin >= 57
	Cabec(iif(alltrim(TCQ->SOLV) == "S","**THINNER**","")+titulo+iif(alltrim(TCQ->SOLV) == "S","**THINNER**",""),cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif

Return

/*/
Programa  : IMPRODAPE   Autor:  Renato P.Zuccolotto
Data      : 01/03/02
Descricao : Imprime os totais por Vendedor.
/*/

Static Function ImpRodape(lResume)
Local nIR,nVlr,nComis
_nLin+=2
If _nlin >= 57
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif                             
@ _nLin,000 PSAY replicate("-",80)
_nLin++
If _nlin >= 57
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif   

nVlr := iif(_cSolv = "S",_nTotVlrSolv,_nTotVlr)
nComis := iif(_cSolv = "S",nTotComisSolv,_nTotComis)

@ _nLin,000 PSAY "TOTAIS "+iif(_cSolv = "S","(**THINNER**)","")+" -->"    
@ _nLin,046 PSAY nVlr picture "@E 99,999,999.99"
@ _nLin,060 PSAY nComis picture "@E 999,999.99"
@ _nLin,070 psay "("+transform((nComis/nVlr)*100,"9999.99")+"%)"
_nLin++
If _nlin >= 57
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif  
/*
@ _nLin,000 PSAY replicate("-",80)
_nLin++
*/
If _nlin >= 57
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	_nLin := 08
Endif   
@ _nLin,000 PSAY iif(_cSolv = "S","VALOR COMPENS THINNER -->","VALOR COMPENS COMIS -->")
@ _nLin,030 PSAY _nVlrComp picture "@E 99,999,999.99"
@ _nLin,045 PSAY "("+transform((_nVlrComp/nVlr)*100,"@E 9999.99")+"%)"


if lResume

	if (nTotComisSolv != 0) .and. (_nTotComis != 0) .and. (nTotComisSolv <> _nTotComis)
		_nLin++
		If _nlin >= 57
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 08
		Endif  
		@ _nLin,000 PSAY replicate("-",80)
		_nLin++
		If _nlin >= 57
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 08
		Endif   
		@ _nLin,000 PSAY "TOTAL COMIS COMPENS -->"
		@ _nLin,030 PSAY nVlrComisComp picture "@E 99,999,999.99"
		@ _nLin,045 PSAY "("+transform((nVlrComisComp/nSomaBase)*100,"@E 9999.99")+"%)"
	endif 
	nIR := round(nVlrComisComp*0.015,2) // Descontar 1.5% de IR, caso o valor seja >= 10,00

	_nLin++
	If _nlin >= 57
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
		_nLin := 08
	Endif                             
//	@ _nLin,000 PSAY replicate("-",80)
	if nIR >= 10
		_nLin++
		If _nlin >= 57
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 08
		Endif                             
		@ _nLin,000 PSAY "VALOR DO I.R. ------>"
		@ _nLin,030 PSAY nIR picture "@E 99,999,999.99"
		@ _nLin,045 PSAY "("+transform(1.5,"@E 9999.99")+"%)"
		_nLin++
		If _nlin >= 57
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 08
		Endif                             
		@ _nLin,000 PSAY "VALOR LIQUIDO ------>"
		@ _nLin,030 PSAY nVlrComisComp - nIR picture "@E 99,999,999.99"
		_nLin++
		If _nlin >= 57
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 08
		Endif                             
		@ _nLin,000 PSAY replicate("-",80)
	endif 	

		IF nTotCampanha > 0
		//
			_nLin++
			If _nlin >= 57
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
				_nLin := 08
			Endif  
			@ _nLin,000 PSAY replicate("-",80)
			_nLin++
			If _nlin >= 57
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
				_nLin := 08
			Endif   

			@ _nLin,000 PSAY "VALOR CAMPANHA      -->"
			@ _nLin,030 PSAY nVlrCampanha picture "@E 99,999,999.99"
			@ _nLin,045 PSAY "("+transform((nVlrCampanha/nTotCampanha)*100,"@E 9999.99")+"%)"
		//
		ENDIF 

		IF nTotDistrib > 0
		//
			_nLin++
			If _nlin >= 57
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
				_nLin := 08
			Endif  

			@ _nLin,000 PSAY "VALOR COM/DISTRIBUI -->"
			@ _nLin,030 PSAY nVlrDistrib picture "@E 99,999,999.99"
			@ _nLin,045 PSAY "("+transform((nVlrDistrib/nTotDistrib)*100,"@E 9999.99")+"%)"
		//
		ENDIF 

		IF nTotVariavel > 0
		//
			_nLin++
			If _nlin >= 57
				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
				_nLin := 08
			Endif  

			@ _nLin,000 PSAY "COMISSAO VARIAVEL(PADRAO)-->"
			@ _nLin,030 PSAY nVlrVariavel picture "@E 99,999,999.99"
			@ _nLin,045 PSAY "("+transform((nVlrVariavel/nTotVariavel)*100,"@E 9999.99")+"%)"
		//
		ENDIF 
		_nLin++
		If _nlin >= 57
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 08
		Endif  
		@ _nLin,000 PSAY replicate("-",55)


	
//	endif 	



endif 

Return

/*/
Programa  : VALIDPERG   Autor:  
Data      : 01/03/02
Descricao : Grava Perguntas
/*/

Static Function ValidPerg()
Local _sAlias,i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Vendedor De  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Vendedor Ate ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Dt Pgto De   ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Dt Pgto Ate  ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})

/*
AADD(aRegs,{cPerg,"03","Emissao De   ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Emissao Ate  ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
*/
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return
