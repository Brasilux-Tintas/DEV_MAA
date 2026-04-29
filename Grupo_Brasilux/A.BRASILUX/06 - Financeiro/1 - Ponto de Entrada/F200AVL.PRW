#include "totvs.ch"
#include "fileio.ch"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFun็ใo    ณ F200AVL บ Autor ณ Nelieder Corneta   บ Data ณ  08/08/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ O Array passado como parโmetro permitirแ que               บฑฑ
ฑฑบ qualquer exce็ใo ou necessidade seja tratada                          บฑฑ
ฑฑบ PE que filtro titulos deletatos no retorno                            บฑฑ
ฑฑบ https://tdn.totvs.com/pages/releaseview.action?pageId=6071394         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


USER FUNCTION F200AVL()
private  cPrefixo  := ''
private  cTitulo   := ''
private  cParcela  := ''
private  retorna   := .T.
private  TxtMail   := ''

cPrefixo := PADR( SUBSTR(paramixb[1][1],1,3) ,TamSx3("E1_PREFIXO")[1] )
cTitulo  := PADR( SUBSTR(paramixb[1][1],4,6) ,TamSx3("E1_NUM")[1] )
cParcela := PADR( SUBSTR(paramixb[1][1],10,1),TamSx3("E1_PARCELA")[1] )

If ((alltrim(FWGrpCompany())) == '11')
    Return(.T.)
EndIf 



DbSelectArea("SE1")
DbSetOrder(1)
If	dbSeek(xFilial("SE1") + cPrefixo + cTitulo + cParcela + 'NF')
	retorna := .T.
Else
	TxtMail := "FA200AVL.PRW - Titulo "+cPrefixo+" - "+cTitulo+" - "+cParcela+"nใo localizado"
	U_EnvMail(TxtMail,TxtMail,"neliedercorneta@brasilux.com.br","","")
    retorna := .F.
Endif


return(retorna)
