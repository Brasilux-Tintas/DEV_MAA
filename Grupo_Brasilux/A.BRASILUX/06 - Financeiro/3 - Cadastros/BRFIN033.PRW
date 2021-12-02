#include "protheus.ch"
#include 'tbiconn.ch'
#include "rwmake.ch"
#include "topconn.ch"
#include 'DIRECTRY.CH'       
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN033  ºAutor ³ Cleber Orati       º Data ³  16/11/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para ajuste manual de comissões no Protheus        -º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN033() 
Local cMens1,_cGrpEmp,_cFilial,_cNumEmp,cTcq,cAux,cDia,nMes,nAno,cMes,cAno,nSucesso
Private lOut,lOk,_oPT00005,cVend,nPercComis,_cData,_dData,cNomeVend,nReg,cUserLga,_cUsuario,_dUltAlt
     u_zcfga01( 'BRFIN033' ) //LGS#2021202 - Gravação de log de utilização da rotina
	_cGrpEmp := alltrim(FWGrpCompany())
	_cFilial := alltrim(FWCodFil())
	_cNumEmp := _cGrpEmp+_cFilial

	If _cGrpEmp != "01"
		MsgBox("Esta operação só pode ser executada na empresa 01-BRASILUX!", "Atenção!", "STOP")
		Return
	Endif 

     If !u_VldAcesso(funname())
        MessageBox( "Acesso não autorizado!---->" + FunName(), "Atenção", 48 )
        Return 
     Endif 
  
     If !(alltrim(_cNumEmp) == "01010101") .and. !(alltrim(_cNumEmp) == "01010104") .and. !(alltrim(_cNumEmp) == "01060101")
        cMens1 := "Acesso deverá ser feito na Brasilux Matriz, Resina ou Dissoltex!"
        MessageBox( cMens1, "Atenção", 48 )
        return
     Endif 

cMens1 := ""
lOut := .f. //Sair do programa
cVend := space(6)
nPercComis := 0.0
cTcq := U_NovoCursor()
cQuery := "SELECT CONVERT(VARCHAR(8),GETDATE(),112) AS DIA "
TCQuery cQuery NEW ALIAS (cTcq)
_cData := (cTcq)->DIA 
dbselectarea(cTcq)
dbCloseArea()
cAux := substr(_cData,7,2)
cDia := iif(cAux < "15","15","01")
if cDia == "15"
	_cData := substr(_cData,1,6)+cDia 
	_dData := ctod(substr(_cData,7,2)+"/"+substr(_cData,5,2)+"/"+substr(_cData,1,4)) 
else
	nMes := val(substr(_cData,5,2))+1
	nAno := val(substr(_cData,1,4))
	if nMes == 13
		nMes := 1
		nAno++ 
	endif 
	cMes := padl(alltrim(str(nMes)),2,"0")
	cAno := padl(alltrim(str(nAno)),4,"0")
	_cData := cAno+cMes+cDia
	_dData := ctod(cDia+"/"+cMes+"/"+substr(_cData,1,4)) - 1
endif 

_cData := dtos(_dData)

Do While .T.
	_oPT00005 := nil
	cNomeVend := space(40)
	nPercComis := 0.0
	nReg := 0
	cUserLga := space(17)
	_cUsuario := ""
	_dUltAlt := ctod("  /  /  ")
	DEFINE MSDIALOG _oPT00005 FROM  50, 050 TO 400,500 TITLE OemToAnsi('Alterar Comissão de Representante') PIXEL	

	@ 003,005 Say OemToAnsi("Data da Comis.:") Size 040,030
	@ 003,060 Get _dData Size 040,030 when .f.
	
	@ 020,005 Say OemToAnsi("Cód. Repres.:") Size 040,030
	@ 020,060 Get cVend  Picture "@!S80"  Size 040,030 Valid DetComis()
	@ 020,100 Get cNomeVend When .f. Size 120,030
	@ 037,005 Say OemToAnsi("Comissão(%) :") Size 040,030
	@ 037,060 Get nPercComis Picture "@E 999.99"  Size 040,030 Valid (nPercComis <= 5.0) 
	@ 054,005 Say OemToAnsi("Últ Alteração:") Size 040,030
	@ 054,060 Get _cUsuario  Picture "@!S80"  Size 040,030 when .f.
	@ 054,100 Get _dUltAlt when .f. Size 040,030 
	@ 135,110 Button OemToAnsi("Grava")  Size 036,016 Action (_oPT00005:End())
	@ 135,160 Button OemToAnsi("Sair")   Size 036,016 Action Fecha()
	
	Activate Dialog _oPT00005 CENTERED
	
	if lOut
		exit
	endif 

	if nReg == 0
		Messagebox("Nenhum registro encontrado!","Atenção!",48) 
		loop 
	endif 
	nSucesso := 1
	dbselectarea("SE3")
	dbgoto(nReg)
	cAux := SE3->E3_AJUSTE
	reclock("SE3",.F.)
	SE3->E3_AJUSTE := cAux //Forçar gravar E3_USERLGA pra passar pra storage procedure gravar
	msunlock()
	cTcq := U_NovoCursor()
	cQuery := "EXEC dbo.AJUSTAR_COMISSAO '"+xFilial("SE3")+"','"+_cData+"','"+cVend+"',"+alltrim(str(nPercComis,6,2))+",'"+SE3->E3_USERLGA+"'"
	TCQuery cQuery NEW ALIAS (cTcq)
	dbselectarea(cTcq)
	if !eof() .and. !bof()
		nSucesso := (cTcq)->retorno
		cMens1 := (cTcq)->menserro
	endif 
	if nSucesso == 0
		Messagebox(cMens1,"Erro!",48) 
	else 
		messagebox("Comissão Alterada com SUCESSO","OK",64)	
	endif 
	dbselectarea(cTcq)
	dbCloseArea()
Enddo

Return

Static Function Fecha()
	cCodBar := ""
	Close(_oPT00005)     
	lOut := .t.
Return(.t.)

Static Function DetComis()
Local cQuery
if !empty(alltrim(cVend))
	cQuery := "SELECT TOP 1 E3_PORC AS COMIS,R_E_C_N_O_ AS REG,E3_USERLGA AS USERLGA FROM "+RetSqlName("SE3")+" WHERE (D_E_L_E_T_ <> '*') AND (E3_FILIAL = '"+xFilial("SE3")+"') AND "+;
	"(E3_DATA = '"+_cData+"') AND (E3_VEND = '"+cVend+"') AND (E3_PREFIXO <> 'IMP')"
	TCQuery cQuery NEW ALIAS "TMP"
	SELECT TMP
	IF !eof() .and. !bof()
		nPercComis := TMP->COMIS
		nReg := TMP->REG
		cUserLga := TMP->USERLGA
		dbselectarea("SE3")
		dbgoto(TMP->REG)
		if !eof() .and. !bof()
			_cUsuario := FWLeUserlg("E3_USERLGA",1)
			_dUltAlt := FWLeUserlg("E3_USERLGA",2)
		endif 
	ENDIF
	select TMP
	DBCLOSEAREA()
	dbselectarea("SA3")
	dbsetorder(1)
	dbseek(xFilial("SA3")+cVend)
	if found()
		cNomeVend := SA3->A3_NOME
	endif
endif 
return(.t.)
