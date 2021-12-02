#include "protheus.ch"
#include "topconn.ch"
#Translate MSGBOX( => IW_MsgBox(
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFIN005 บ Autor ณ Edmar Rodrigo      บ Data ณ  31/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao dos Boletos de Cobranca dos Bancos:              บฑฑ
ฑฑบ          ณ Brasil e Bradesco                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BRFIN005()
Local aOrd := {}
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Boletos Pre Impressos"
Local cPict          := ""
Local titulo       := "Boletos Pre Impressos"
Local nLinha       := 0
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local lRet         := .T.
Private cPerg        := "BRFN05"
Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "BRFIN005" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "BRFIN005"

 if !u_VldAcesso(funname())
      MsgBox("Acesso nใo autorizado!---->"+funname(),"Aten็ใo","Alert")
      return 
  endif 
     u_zcfga01( 'BRFIN005' ) //LGS#2021202 - Grava็ใo de log de utiliza็ใo da rotina
ValidPerg()
Pergunte(cPerg,.F.)

dbSelectArea("SEA")
dbSetOrder(1)
wnrel := SetPrint("SEA",NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"SEA")

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณEdmar Rodrigo       บ Data ณ  31/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo)
Local nOrdem, nTitulos
Local cQry,lAvista
Local aTitulos := {}
Local nLinha   := 0

cQry := " SELECT * FROM "+RetSqlName("SEA")+" SEA WITH (NOLOCK) WHERE "
cQry += " SEA.EA_NUMBOR = '"+mv_par01+"' "
cQry += " AND SEA.D_E_L_E_T_ <> '*' "
cQry += " ORDER BY SEA.EA_PREFIXO,SEA.EA_NUM,SEA.EA_PARCELA,SEA.EA_PORTADO"

TCQuery cQry New Alias "TMP"
dbselectarea("SC5")
dbsetorder(1)
DbSelectArea("TMP")
SetRegua(RecCount())
dbGoTop()

DbSelectArea("TMP")
While !Eof() .AND. TMP->EA_NUMBOR == mv_par01
	AADD(aTitulos,{TMP->EA_PREFIXO,TMP->EA_NUM,TMP->EA_PARCELA,TMP->EA_PORTADO})
	TMP->(DbSkip())
EndDo
//SfTstPrn(aReturn,nLinha) // Testa a impressora
SetPrc(0,0)
For nTitulos:= 1 To Len(aTitulos)
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+aTitulos[nTitulos][1]+aTitulos[nTitulos][2]+aTitulos[nTitulos][3])
	While !Eof() .and.  SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA == aTitulos[nTitulos][1]+aTitulos[nTitulos][2]+aTitulos[nTitulos][3]
		IF     aTitulos[nTitulos][4] == "237" // Bradesco
			If lAbortPrint
				@nLinha,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			//nLinha += 3
			@ nLinha, 000 PSAY CHR(15)
			@ nLinha, 005 PSAY "PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO"
			@ nLinha, 086 PSAY IF(SE1->E1_EMISSAO == SE1->E1_VENCREA,"C/ APRESENTACAO",SE1->E1_VENCREA)
			nLinha+= 3
			@ nLinha, 005 PSAY SE1->E1_EMISSAO
			@ nLinha, 016 PSAY SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+SE1->E1_PARCELA
			@ nLinha, 048 PSAY "B" // Especie Doc
			@ nLinha, 058 PSAY "N" // Aceite
			@ nLinha, 069 PSAY dDataBase
			nLinha +=2
			@ nLinha, 045 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
			@ nLinha, 086 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
			nLinha += 3
			@ nLinha, 010 PSAY "COBRAR R$ " + Transform((SE1->E1_VALOR * .0033),"@R 999.99") + " POR DIA DE ATRASO"
			nLinha += 2
			@ nLinha, 010 PSAY "** APOS VENCIMENTO PAGAVEL SOMENTE NO BRADESCO"
			nLinha+= 4
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			@ nLinha, 010 PSAY SA1->A1_NOME
			nLinha+= 1
			@ nLinha, 010 PSAY IF(LEN(SA1->A1_CGC) > 11,"C.N.P.J. " + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),"C.P.F." + Transform(SA1->A1_CGC,"@R 999.999.999-99") ) + chr(18)
			nLinha+=9
			IncRegua()
		ELSEIF aTitulos[nTitulos][4] == "001" // Brasil
			If lAbortPrint
				@nLinha,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			nLinha += 2
			@ nLinha, 000 PSAY CHR(15)
			lAvista = .f.
			dbselectarea("SC5")
			dbseek(xFilial("SC5")+SE1->E1_PEDIDO)
			if found() .and. (SC5->C5_CONDPAG == "001") // Se for venda เ vista
				lAvista = .t.
			endif
			@ nLinha, 091 PSAY IF(lAvista,"C/ APRESENTACAO",SE1->E1_VENCREA)
			nLinha+= 3
			@ nLinha, 005 PSAY SE1->E1_EMISSAO
			@ nLinha, 016 PSAY SE1->E1_PREFIXO+alltrim(SE1->E1_NUM)+SE1->E1_PARCELA
			@ nLinha, 053 PSAY "B" // Especie Doc
			@ nLinha, 063 PSAY "N" // Aceite
			@ nLinha, 072 PSAY dDataBase
			nLinha +=2
			@ nLinha, 045 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
			@ nLinha, 090 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
//			nLinha += 8     
			IF !lAvista
				nLinha += 3
				@ nLinha, 010 PSAY "COBRAR R$ " + Transform((SE1->E1_VALOR * .0033),"@R 999.99") + " POR DIA DE ATRASO"
				nLinha += 2
				@ nLinha, 010 PSAY "** APOS VENCIMENTO PAGAVEL SOMENTE NO B. BRASIL"
			ELSE
				nLinha += 5
			endif 
			nLinha += 2
			@ nLinha, 090 PSAY Transform(SE1->E1_VALOR,"@E 999,999,999.99")
			nLinha++
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			@ nLinha, 010 PSAY AllTrim(SA1->A1_NOME)
			nLinha++
			@ nLinha, 010 PSAY AllTrim(SA1->A1_ENDCOB)
			nLinha++
			@ nLinha, 010 PSAY Transform(SA1->A1_CEP,"@R 99999-999") + "  " + AllTrim(SA1->A1_MUN) + "  " +AllTrim(SA1->A1_EST)
			nLinha++
			@ nLinha, 010 PSAY IF(LEN(SA1->A1_CGC) > 11,"C.N.P.J. " + Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),"C.P.F." + Transform(SA1->A1_CGC,"@R 999.999.999-99") ) + chr(18)
			nLinha+=6
			IncRegua()
		EndIf
		DbSelectArea("SE1")
		SE1->(DbSkip())
	EndDo
	
Next nTitulos
DbSelectArea("TMP")
DbCloseArea()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

Static Function SfTstPrn(aReturn,nLinha)
Local nOpc

If aReturn[5]==2 .or. aReturn[5]==3
	
	nOpc       := 1
	While .T.
		
		SetPrc(0,0)
		@ nLinha , 000 PSAY CHR(255)+CHR(15)+"-"
		@ nLinha , 004 PSAY "*"
		@ nLinha , 022 PSAY "."
		@ nLinha , 086 PSAY "-"
		IF MsgBox("O Boleto esta posicionado ? ","TESTE DE IMPRESSAO","YESNO")
			nOpc := 1
		ElseIF MsgBox("Deseja tentar Novamente ? ","ATENCAO","YESNO")
			nOpc := 2
		Else
			nOpc := 3
		Endif
		
		Do Case
			Case nOpc==1
				lContinua:=.T.
				Exit
			Case nOpc==2
				Loop
			Case nOpc==3
				lContinua:=.F.
		EndCase
	End
Endif

Return()        

Static Function ValidPerg()
Local i, j
local _sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Bordero Nro. ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
