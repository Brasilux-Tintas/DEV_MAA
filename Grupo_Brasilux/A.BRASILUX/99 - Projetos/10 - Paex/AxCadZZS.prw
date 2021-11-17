

/*/chaus
+------------------------------------------------------------------------------
| Função | VLDEXC | Autor |Tiago Lucio | Data | |
+------------------------------------------------------------------------------
| Descrição | Cadastro de ocorrencias de De/Para de Itens de Pedido de Venda |
+------------------------------------------------------------------------------
| Uso | Curso ADVPL |
+------------------------------------------------------------------------------
/*/

#include "protheus.ch"

User Function AxCadZZS


Local cAlias := "ZZS"
Local cTitulo := "Cadastro de faixas permitidas para Baixa Automática de OPs"
Local cVldExc := ".t."
//Local cVldAlt := ".t."
dbSelectArea(cAlias)
dbSetOrder(1)
AxCadastro(cAlias,cTitulo,cVldExc,"U_VldAlZZS(cAlias)")
//AxCadastro(cAlias,cTitulo,cVldExc,cVldAlt)

Return Nil



User Function VldAlZZS(cAlias,nReg,nOpc)
Local lRet := .T.
Local aArea :=GetArea()
Local nOpcao := 0
nOpc        := 3        //Opcao de Alteracao
nReg        := aArea[3] //Pegarás o numero do registro

M->ZZS_USUARI:=SUBSTR(CUSUARIO,7,15) 
M->ZZS_DATA:=DATE()
M->ZZS_HORA:=TIME()                                                                                                                          
nOpcao := 1

If nOpcao == 1
MsgInfo("Alteração concluída com sucesso!")
else

MsgInfo(Str(nOpcao))
Endif
//RestArea(aArea)
Return lRet


User Function validZZS(valor)

lRet:=.T.
nRecno:=M->(RECNO())
dbSelectArea("ZZS")

ZZS->(dbGotop())
ZZS->(dbSetOrder(1))	//ZZS_FILIAL, ZZS_CODIGO, R_E_C_N_O_, D_E_L_E_T_

While !(ZZS->(eof()))
	if valor>=ZZS->ZZS_QTMIN .And.  valor<=ZZS->ZZS_QTMAX .And.  nRecno<>ZZS->(RECNO())
		lRet:=.F.
	EndIF
	ZZS->(dbSkip())		
EndDo		


If !lRet
	MsgInfo("Valor inválido. Favor selecione outro valor que já não esteja dentro de outra faixa!")

EndIf

Return lRet