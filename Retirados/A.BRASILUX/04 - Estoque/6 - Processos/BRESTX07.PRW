#include "protheus.ch"
#include "topconn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
  ±±ºPrograma  ³ BRESTX07 ºAutor  ³ Cleber Orati       º Data ³  03/06/20   º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºDesc.     ³ Processa a Arbitragem do Estoque da Brasilux Matriz, Resinaº±±
  ±±º, Depósitos Fechados e Dissoltex                                       º±±
  ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
  ±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
  ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
  ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
  - MV_PAR01 - MES
  - MV_PAR02 - ANO
 */
User Function BRESTX07()
     Private cPerg     := "BRESTX07"
     Private cRotina   := "BRESTX07"

if !u_VldAcesso(funname())
	MsgAlert("Acesso não autorizado!---->"+funname())
	return 
endif 

if !((alltrim(cNumEmp) == "01010101") .OR. (alltrim(cNumEmp) == "01010104") .OR. (alltrim(cNumEmp) == "01010106") .OR. (alltrim(cNumEmp) == "01010107") .OR. (alltrim(cNumEmp) == "01060101") )
	MsgAlert("Permitido apenas na Brasilux/Matriz, Resina, Depositos ou Dissoltex!")
	return
endif 


PESTX07_1(cPerg)
If !Pergunte(cPerg, .t.)
   Return
Endif
     
Processa({|| ESTX07_1()})
     
Return

/*****************************************************************************************************************/
/*** ESTX03_1 - Processa de acordo com parâmetros.                                                             ***/
/*****************************************************************************************************************/
Static Function ESTX07_1()
Local cAno,cDia,cMes,nMes,dFechto,cFechto,nAno,cQuery,dUltFechto

//Det. últ dia do Mês pra fechamento
nAno := mv_par02
nMes := mv_par01
if (abs(year(date()) - nAno) > 1)
   MsgAlert("Ano de Fechamento INVÁLIDO!! Corrija.")
   RETURN
endif 
//Considerar apenas depois do mês 04/2020 quando foi transferido para o sistema
if (nAno <= 2020) .and. (nMes < 4)
   MsgAlert("Mês/Ano de Fechamento INVÁLIDO!! Corrija.")
   RETURN
endif 


if (nMes > 12) .or. (nMes < 1)
   MsgAlert("Mês de Fechamento INVÁLIDO!! Corrija.")
   RETURN
endif 

nMes++
if nMes == 13
   nAno++
endif
cDia := "01"
cAno := padl(alltrim(str(nAno)),4,"0")
cMes := padl(alltrim(str(nMes)),2,"0")
dFechto := ctod(cDia+"/"+cMes+"/"+cAno) -1
dUltFechto := supergetmv("MV_ULMES",.f.,ctod(space(8)))
if empty(dUltFechto) .or. (dFechto > dUltFechto)
   MsgAlert("Estoque ainda não foi fechado!!")
   RETURN
endif 

cFechto := DTOS(dFechto)

// PROCESSA ARBITRAGEM
ProcRegua(10)
IncProc("Processando Arbitragem Fechto...")
cQuery := "EXEC dbo.ARBITRARSB9 '"+xFilial("SB9")+"','"+cFechto+"','"+__CUSERID+"'"
TCQUERY cQuery NEW ALIAS "TCQ"
If SELECT("TCQ") > 0
   DbSelectArea("TCQ")
   IF TCQ->RETORNO == 0
      MsgAlert(TCQ->MENSERRO)
   ELSE
      MsgAlert("Arbitragem de Estoque Finalizada!"+TCQ->MENSERRO)
   ENDIF

	TCQ->(DbcloseArea())
Endif

Return

/*****************************************************************************************************************/
/*** PESTX07_1 - Ajusta parâmetros.                                                                            ***/
/*****************************************************************************************************************/
Static Function PESTX07_1(cPerg)
Local aHelp := {}
AAdd(aHelp, {{"Mes Fechamento"},  {"Mes Fechamento"}, {"Mes Fechamento"}})
AAdd(aHelp, {{"Ano Fechamento"},  {"Ano Fechamento"}, {"Ano Fechamento"}})

u_xPutSX1(cPerg,"01","Mes          ?" ,"Mes          ?","Mes          ?","mv_ch1","N",2,0,0,"G","",""   ,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],cPerg)
u_xPutSX1(cPerg,"02","Ano          ?" ,"Ano          ?","Ano          ?","mv_ch2","N",4,0,0,"G","",""   ,"","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],cPerg)

Return
