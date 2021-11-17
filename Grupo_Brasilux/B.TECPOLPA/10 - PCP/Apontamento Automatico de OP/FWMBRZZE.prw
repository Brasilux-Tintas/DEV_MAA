#include "totvs.ch"
#include "fwmvcdef.ch"
#include "fwbrowse.ch"
#include "topconn.ch"

user Function FWMBRZZE()

Local oBrw
//Local oColumn
Local cMarca	:= GetMark()
Local lInvert	:= .F.
//Local aArea		:= GetArea()
Local _cAlias	:= GetNextAlias()
//Local _cQry		:= ""
Local _cUpd		:= ""

_cUpd :="	UPDATE "+RetSqlName("ZZE")
_cUpd +="	SET ZZE_OK = '' "
_cUpd +="	WHERE "
_cUpd +="	ZZE_OK <> '' "
TCSQLEXEC(_cUpd)
TCSQLEXEC("Commit")

//Instaciamento
oBrw := FWMBrowse():New()

//tabela que será utilizada
oBrw:SetAlias( "ZZE" )
//oBrw:SetOrder(0)

//Titulo
oBrw:SetDescription( "Corrigir OP" )

//Legenda
//oBrw:AddLegend( "ZZE_RESOLV == '1'", "GREEN", "Resolvido" )
//oBrw:AddLegend( "ZZE_RESOLV == '2'" , "RED" , "Pendente" )

//Filtro somente as OP´s pendentes
oBrw:SetFilterDefault( "ZZE_RESOLV != '1'" )

// Cria uma coluna de marca/desmarca
oBrw:AddMarkColumns( { || If( AllTrim(("ZZE")->ZZE_OK) <> "", "LBOK", "LBNO" ) } , ;
					 { || AddMarcaca(cMarca ,lInvert,,_cAlias,oBrw), /*oBrw:Refresh(.T.)*/ } , ;
					 { || AddMarcaca(cMarca ,lInvert,.T.,_cAlias,oBrw), /*oBrw:Refresh( .T. )*/ } ) //Coluna de marcacao
					 

oBrw:AddButton("Corrige OP"	, { || U_APONTAOP(_cAlias), oBrw:Refresh(.T.)},,,, .F., 2 )

//ativa
oBrw:Activate()

Return

Static Function AddMarcaca(cMarca,lInvert,lAll,_cAlias,oBrw)

//Local nReg
Local aArea := GetArea()
Default lAll := .F.

	If lAll //Se o usuario marcar todos os registros
		DBSelectArea("ZZE")
		ZZE->(DBGoTop())
		While ZZE->(!Eof())
			//Verifica todas as posicoes, invertendo as marcacoes
			RecLock("ZZE", .F.)
			ZZE->ZZE_OK := IIF(Empty(ZZE->ZZE_OK),cMarca,"")
			ZZE->(MsUnLock())
			ZZE->(DBSkip())
		ENDDO
	Else //Se o usuario marcar apenas um registro
		RecLock("ZZE", .F.)
		ZZE->ZZE_OK := IIF(Empty(ZZE->ZZE_OK),cMarca,"")
		ZZE->(MsUnLock())
	Endif
	
	//oBrw:SetEditCell(!Empty(ZZE->ZZE_OK))
	oBrw:Refresh()
	RestArea(aArea)
Return .T.