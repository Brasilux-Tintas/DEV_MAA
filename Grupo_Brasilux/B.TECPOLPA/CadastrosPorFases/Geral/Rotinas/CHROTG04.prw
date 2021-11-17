#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"



/**	   ValCposU
***    Funcao valida se o usuario preencheu os campos a ele designados,  
***    conforme regras definidas na tabela SZP
***    Dyego Figueiredo - Chaus - 10/08/2015
***/



User Function CHROTG04(tipo)
     Local aAreaAtu   := GetArea()
     Local lRet       := .T.      
     Local i, iVar
     Local aCampos    := " " 
     Local _cAliasSX3 := GetNextAlias()
     Local _lOpen

     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200206 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0
     
     If !_lOpen //LGS#20200206 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir o dicionário SX3.", "Atenção...", 16 )
        Return lRet
     Endif

     If tipo == "F" .And. /*getMv("MV_XHABCH1")  .And. */ Type("_ObrCpsF") != "U"  //.And. AllTrim(_campo) $ _CliCpos
        iVar := Replace(_ObrCpsF, ",", ";")  
     Elseif tipo == "P" .And. /*getMv("MV_XHABCH1")  .And. */ Type("_ObrCpsP") != "U"  //.And. AllTrim(_campo) $ _CliCpos
            iVar := Replace(_ObrCpsP, ",", ";")  
     Elseif tipo == "C" .And. /*getMv("MV_XHABCH1")  .And. */ Type("_ObrCpsC") != "U"  //.And. AllTrim(_campo) $ _CliCpos
            iVar := Replace(_ObrCpsC, ",", ";")  
     Else
        return lRet
     Endif

     iVar := Replace(iVar, ".", ";")
     iVar := Replace(iVar, "-", ";")
     iVar := Replace(iVar, " ", "")

     aCampos := Separa(iVar,";",.T.)   
	
     _cTitulo :=   ""
     _folder := ""
     For i:= 1 to Len(aCampos)  
         /********************************************************************************************************************************/
         /*** BLOCO ALTERADO EM 14/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
         /*DbSelectArea("SX3")
         SX3->(DbSetOrder(2))
         If SX3->(DbSeek( aCampos[i]))
            _cTitulo := SX3->(X3_TITULO)
            _folder  := SX3->X3_FOLDER
         Else 
            loop // se nao achou o campo , pula 
         Endif*/
         DbSelectArea( _cAliasSX3 )
         ( _cAliasSX3 )->( DbSetOrder(2) )
         If ( _cAliasSX3 )->(DbSeek( aCampos[i]))
            _cTitulo := ( _cAliasSX3 )->( X3_TITULO )
            _folder  := ( _cAliasSX3 )->( X3_FOLDER )
         Else 
            loop // se nao achou o campo , pula 
         Endif 
         If Empty(AllTrim(aCampos[i]))   
            loop
         Endif
         If Upper(Substr(AllTrim(aCampos[i]),4, 9)) != "FILIAL"  .And. Empty(&("M->"+AllTrim(aCampos[i])))  
            MsgBox("É obrigatório o preenchimento do campo: " + AllTrim(_cTitulo) +" ("+ aCampos[i] + ") - Folder " + Alltrim(_folder), "Atenção", "ALERT")
            lRet :=  .F.  
            exit
         Endif  
     Next i
     IF lRet	
        _tabela := ""
        If tipo == "P"
           _tabela := "B1" 
        ElseIf tipo == "C"
               _tabela := "A1"
        ElseIf tipo == "F"
               _tabela := "A2"
        Endif
        cEtapa := &('M->' + _tabela + '_XCETAPA')
        If Empty(cEtapa) 
           cEtapa := U_CHROTG15(tipo)
        Endif
        lRet := checkCond(tipo,  cEtapa)  
     Endif

     DbSelectArea( _cAliasSX3 )
     DbCloseArea()
     RestArea( aAreaAtu )
Return  lRet   


//checa condicao
Static Function checkCond(_cTipo, _cEtapa)  

local lRet := .T.
                 
	dbSelectArea("SZQ")
		//ZQ_FILIAL+ZQ_TIPO+ZQ_CODET+ZQ_SETOR                                                                                                                             
		SZQ->(dbSetOrder(1))
		If SZQ->(dbSeek(xFilial("SZQ") + _cTipo + AllTrim(_cEtapa)))
		
			cCondicao := SZQ->ZQ_COND001
			
			if inclui .or. altera
				cCondicao := StrTran( cCondicao, "SB1", "M" )
				cCondicao := StrTran( cCondicao, "SA1", "M" )
				cCondicao := StrTran( cCondicao, "SA2", "M" )
			endif
			
			//Verifica se existe uma condicao para executar a etapa	
			If !Empty(cCondicao)
			
				//Se a condicao for atendida, levando em consideracao os campos da SB1 a etapa sera checada, caso contrario nao
				If &(cCondicao)
				
					lRet := .T.					
				
				Else
					MsgBox("É obrigatório: " + AllTrim(SZQ->ZQ_COND001) , "Atenção ChRoG04.prw ", "ALERT")
					lRet := .F.	
				EndIf
			
				//Caso nao tenha uma condicao para executar a etapa a mesma eh dada como obrigatoria a passagem pelo cadastro de produto
			Else
				
				lRet := .T.
			
			EndIf
				
		EndIf
		
Return	lRet	