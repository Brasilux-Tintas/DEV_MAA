#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "font.ch"
#include "error.ch"
#include "tbiconn.ch"

//GERAÇÃO DO NÚMERO DA ORDEM DE SEPARAÇÃO
//Cleber (14/10/2021) -> Ajuste para verificar se clicou em Cancelar
User Function TCGORDEM(nOpc)

// nOpc ( 1 - Gera Ordem Separação  2 - Estorna Ordem de separação )

Local cQry1   :=""
Local cQry2   :=""
Local cQry3   :=""
Local cPerg   :="TCGORDEM"
Local cCodSeq :=""
Local lResp

lResp := Pergunte(cPerg,.T.)
if !lResp 
	RETURN 
endif 
MV_PAR01 := alltrim(MV_PAR01)
MV_PAR02 := ALLTRIM(MV_PAR02)

if  !(Len(MV_PAR01) == 11) .or. !(Len(MV_PAR02) == 11) .or. !(Substr(MV_PAR01,1,6) == Substr(MV_PAR02,1,6)) 
  	MsgInfo("Dados inválidos! Verifique os parametros !!!", 'Atenção!')
	RETURN 
endif 

do case 
case nOpc == 1
// gera ordem de separação

			cQry1 := ""
			cQry1 += " SELECT TOP 1 SC2.C2_XORDSEP "
			cQry1 += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
			cQry1 += " WHERE SC2.C2_FILIAL = '"+xFilial("SC2")+"'"
			cQry1 += " AND SC2.D_E_L_E_T_ = '' "
			cQry1 += " AND C2_XOP BETWEEN('"+MV_PAR01+"') AND ('"+MV_PAR02+"') "
			cQry1 += " AND C2_XORDSEP <> '' "
			cQry1 += " ORDER BY SC2.C2_XORDSEP DESC "

			TCQUERY cQry1 ALIAS "TCQ" NEW
			DbSelectArea("TCQ")
			DbGoTop()

			If !TCQ->(eof())
				MsgInfo("Já Existe Ordem de Separação criada para o range especificado de Ops. Da Op "+MV_PAR01+" até "+MV_PAR02+" !!!", 'Atenção')		
				DbSelectArea("TCQ")
				DbCloseArea()
				Return
			Endif
			
			DbSelectArea("TCQ")
			DbCloseArea()

			cQry1 := ""
			cQry1 += " SELECT TOP 1 SC2.C2_XORDSEP "
			cQry1 += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
			cQry1 += " WHERE (SC2.D_E_L_E_T_ = '') AND (SC2.C2_FILIAL = '"+xFilial("SC2")+"')"
			cQry1 += " ORDER BY SC2.C2_XORDSEP DESC "

			TCQUERY cQry1 ALIAS "TCQ" NEW
			cCodSeq := '000001'
			DbSelectArea("TCQ")
			DbGoTop()
			IF !eof() .and. !bof()
				cCodSeq := Iif(Empty(TCQ->C2_XORDSEP),'000001', StrZero(Val(SubStr(TCQ->C2_XORDSEP, 1, 6))+1, 6))
			Endif
					
			DbSelectArea("TCQ")
			DbCloseArea()
		
			cQry2 := ""
			cQry2 += "UPDATE "+RetSqlName("SC2")+" SET C2_XORDSEP ='"+cCodSeq+"', C2_XSTATUS ='1' WHERE (C2_FILIAL ='"+xFilial("SC2")+"') AND (D_E_L_E_T_ = '') AND (C2_XOP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"')" 
			TCSQLExec(cQry2)		
			
			MsgInfo("Ordem de separação "+cCodSeq+" gerada com Sucesso !!!", 'Atenção')

case nOpc == 2
// estorno ordem de separação

    	cQry1 := ""
    	cQry1 += " SELECT TOP 1 SC2.C2_XORDSEP "
    	cQry1 += " FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
    	cQry1 += " WHERE (SC2.C2_FILIAL = '"+xFilial("SC2")+"')"
    	cQry1 += " AND (SC2.D_E_L_E_T_ = '') "
    	cQry1 += " AND C2_XOP BETWEEN('"+MV_PAR01+"' AND '"+MV_PAR02+"') "
    	cQry1 += " AND (C2_XORDSEP <> '') "
    	cQry1 += " ORDER BY SC2.C2_XORDSEP DESC "

   		TCQUERY cQry1 ALIAS "TCQ" NEW
   		DbSelectArea("TCQ")
   		DbGoTop()

   		If TCQ->(eof())
   			MsgInfo("O range de Ops informadas "+MV_PAR01+" até "+MV_PAR02+" não possuem ordem de separação, verifique os parametros !!!", 'Atenção')		
   			DbSelectArea("TCQ")
   			DbCloseArea()
   			Return
   		Endif
   		
   		If MsgYesNo("Confirma a operação de estorno da Ordem de Separação '"+(TCQ->C2_XORDSEP)+"' ?", 'Estorno Ordem de Separação')	  
   			
   			Begin Transaction
   				cQry1 := ""
   				cQry1 += " UPDATE "+RetSqlName("CB0")+" SET CB0_OP ='', CB0_XORDSE ='', CB0_XUSRPR ='', CB0_XDTPRO= '', CB0_XHRPRO ='', CB0_XUSRSE ='', CB0_XDTSEP ='', CB0_XHRSEP ='', CB0_XSTATU ='' "
   				cQry1 += " FROM "+RetSqlName("CB0")+" CB0 LEFT OUTER JOIN "+RetSqlName("SD4")+" SD4 ON D4_FILIAL = CB0_FILIAL AND D4_OP = CB0_OP AND D4_COD = CB0_CODPRO AND D4_LOTECTL = CB0_LOTE AND SD4.D_E_L_E_T_ ='' "
   				cQry1 += " WHERE (CB0.D_E_L_E_T_ = '') AND (CB0_FILIAL ='"+xFilial("CB0")+"') AND (CB0_XORDSE = '"+TCQ->C2_XORDSEP+"')"
   				//AND CB0_OP BETWEEN('"+MV_PAR01+"') AND ('"+MV_PAR02+"') AND CB0_XORDSE ='"+(TCQ->C2_XORDSEP)+"'"         	        	
   				TCSQLExec(cQry1)
   				
   				cQry2 := ""
   				cQry2 += " UPDATE "+RetSqlName("SD4")+" SET D4_XSTATUS ='' FROM "+RetSqlName("SD4")+" SD4 LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = D4_FILIAL AND C2_XOP = D4_OP AND SC2.D_E_L_E_T_ ='' "
   				cQry2 += " WHERE (SD4.D_E_L_E_T_ ='') AND (D4_FILIAL = '"+xFilial("SD4")+"') AND (C2_XORDSEP = '"+TCQ->C2_XORDSEP+"')"
   				//AND D4_OP BETWEEN('"+MV_PAR01+"') AND ('"+MV_PAR02+"') AND C2_XORDSEP ='"+(TCQ->C2_XORDSEP)+"'"
   				TCSQLExec(cQry2)		

   				cQry3 := ""
   				cQry3 += " UPDATE "+RetSqlName("SC2")+" SET C2_XORDSEP ='', C2_XSTATUS ='' WHERE (D_E_L_E_T_ = '') AND (C2_FILIAL = '"+xFilial("SC2")+"') AND (C2_XORDSEP ='"+TCQ->C2_XORDSEP+"')" 
   				TCSQLExec(cQry3)		
        	End Transaction
        	MsgInfo("Ordem de separação "+TCQ->C2_XORDSEP+" estornada com Sucesso !!!", 'Estorno Ordem de Separação')
        Endif
                
        DbSelectArea("TCQ")
   		DbCloseArea()

endcase 

Return
