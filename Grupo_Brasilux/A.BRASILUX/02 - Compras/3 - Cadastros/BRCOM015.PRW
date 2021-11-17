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
±±ºPrograma  ³ BRCOM015  ºAutor ³ Cleber Orati       º Data ³  06/11/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função incluir automaticamente nfs de materiais dos depósi-º±±
±±º          ³ tos fechados - TES 216                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCOM015() 
Local cMens1,_cGrpEmp,_cFilial,_cNumEmp,lAchouNf,cCliente,cLoja,cTcq,nRegF2
Private lOut,lOk,_oPT00005,cCodBar

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
  
     If !(alltrim(_cNumEmp) == "01010101") .and. !(alltrim(_cNumEmp) == "01010104")
        cMens1 := "Acesso deverá ser feito na Brasilux Matriz ou Resina!"
        MessageBox( cMens1, "Atenção", 48 )
        return
     Endif 


cCliente := iif(_cFilial == "010101","00354","00401")	
cLoja := "01"
lOut := .f. //Sair do programa
cBuffer := ""
cCodBar := space(44)


Do While .T.
	_oPT00005 := nil
	cCodBar := padr(cCodBar,44," ")
	DEFINE MSDIALOG _oPT00005 FROM  50, 050 TO 400,500 TITLE OemToAnsi('Entrar com a Chave da NFe ou o Nro da NF') PIXEL	
	
	@ 003,005 Say OemToAnsi("Chave da NFe NFE") Size 040,030
	
	@ 003,060 Get cCodBar  Picture "@!S80"  Size 150,030 // Valid AchaFile(@cArquivo)
	@ 135,110 Button OemToAnsi("Ok")  Size 036,016 Action (_oPT00005:End())
	@ 135,160 Button OemToAnsi("Sair")   Size 036,016 Action Fecha()
	
	Activate Dialog _oPT00005 CENTERED
	
	if lOut
		exit
	endif 
	

	cCodBar := alltrim(cCodBar)
	lAchouNf := .f.
	dbselectarea("SF2")
	dbsetorder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                                                                                                                             
	do case 
	case len(cCodBar) == 44
		cTcq := U_NovoCursor()
		cQuery := "SELECT R_E_C_N_O_ AS REG "+;
		"FROM "+RetSqlName("SF2")+" SF2 WHERE (D_E_L_E_T_ <> '*') AND (F2_FILIAL = '010106') AND (F2_CHVNFE = '"+cCodBar+"')" 
		TCQuery cQuery NEW ALIAS (cTcq)
		dbselectarea(cTcq)
		if !eof() .and. !bof()
			dbselectarea("SF2")
			dbgoto((cTcq)->reg)
			if !eof() .and. !bof() 
				nRegF2 := recno()
			 	if  nRegF2 == (cTcq)->reg 
					lAchouNf := .t.
				endif
			endif 
		endif 
		dbselectarea(cTcq)
		dbCloseArea()

	case (len(cCodBar) == 9) .or. (len(cCodBar) == 6)
		dbseek("010106"+padr(cCodBar,TamSx3("F2_DOC")[1]," ")+padr("1",TamSx3("F2_SERIE")[1]," ")+padr(cCliente,TamSx3("F2_CLIENTE")[1]," ")+cLoja)
		lAchouNf := found()
	endcase 
	if !lAchouNf
		Messagebox("Não encontrada NF no Depósito!","Atenção!",48) 	
	else
		BRCO15()
	endif 

	loop 
Enddo

Return

Static Function Fecha()
	cCodBar := ""
	Close(_oPT00005)     
	lOut := .t.
Return(.t.)




Static Function BRCO15()
Local lErro,_cFilial,cArqBloq,aBloq,cAux,_cAreaBloq,cErros,dUlMes,lMudouUlmes,cCliente,cTcq,cQuery,lSucesso,aPed,aItensPed
Local _cDoc,_cSerie,_cFornec,_cLojaF,cEspecie,_cFilNf,_cTab,lIncluiNf,cMensErro,_cUf,nQtdeItens,aPedRel,nVlrUn,nVlrTot,_cTipo,_cTipoPro
Local nLinVlrUn ,_nDec,_cItem
Private lMsErroAuto
Private lMsHelpAuto := .f.

	lErro = .f.
	_cFilial := alltrim(FWCodFil())

// Verificar se tem alguém usando a rotina
	cArqBloq := "BRCOM015"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
	aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
   	if aBloq[1,1] //Já estava bloqueado?
   		cAux := "O programa já está sendo usado por: "+aBloq[1,2]
			Messagebox(cAux,"Atenção!",48) 		
		//else
		//	FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', cAux, 0 )
		//endif 
		Return
	endif


	_cAreaBloq := aBloq[1,4]

	cErros := ""
	lErro := .f.

	/*              
	dUlMes := GETMV("MV_ULMES")
	if dUlMes > (dDataBase)
		lMudouUlmes := .t.
	else
		lMudouUlmes := .f.
	endif 

*/
	cCliente := SF2->F2_CLIENTE
	_cTipo := SF2->F2_TIPO
	cTcq := U_NovoCursor()
	cQuery := "SELECT D2_COD,D2_QUANT,D2_PRCVEN,D2_NFORI,D2_SERIORI,D2_ITEMORI "+;
	"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
	"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '010106') AND (D2_CLIENTE = '"+ALLTRIM(SF2->F2_CLIENTE)+"') AND (D2_LOJA = '"+SF2->F2_LOJA+"') AND "+;
	"(D2_SERIE = '"+ALLTRIM(SF2->F2_SERIE)+"') AND (D2_DOC = '"+ALLTRIM(SF2->F2_DOC)+"') AND (D2_TIPO = '"+SF2->F2_TIPO+"')"
	TCQuery cQuery NEW ALIAS (cTcq)

	lSucesso := .t.
	dbselectarea("SA2")	
	dbsetorder(1)
	dbselectarea(cTcq)
	aPed       := {}
	aItensPed  := {} 
	_cFilNf := "010106"	  	
	_cDoc := padl(alltrim(SF2->F2_DOC),TamSx3("F1_DOC")[1],"0")
	_cSerie := padr(alltrim(SF2->F2_SERIE),TamSx3("F1_SERIE")[1]," ")
	_cTab := iif(alltrim(SF2->F2_TIPO) $ "D-B","SA1","SA2")
	cAux := iif(_cTab == "SA2","05200","023818")
	_cFornec := padr(cAux,TamSx3( iif(_cTab == "SA2","A2_COD","A1_COD"))[1]," ")
	_cLojaF := "01"
	cEspecie := ALLTRIM(SF2->F2_ESPECIE)
	_cChvnf := alltrim( SF2->F2_CHVNFE )
	lIncluiNf := .t.
	dbselectarea("SF1")
	dbsetorder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	dbseek(xFilial("SF1")+_cDoc+_cSerie+_cFornec+_cLojaF+SF2->F2_TIPO)
	if found()
		lIncluiNf := .f.
		Messagebox("Nota Fiscal "+_cDoc+"/"+_cSerie+" JÁ EXISTE!!","Atenção!",48) 
	else 

		dbselectarea(_cTab)	
		dbseek(xFilial(_cTab)+_cFornec+_cLojaF,.t.)
		if !found()
			lIncluiNf := .f.
			lSucesso := .f.
			cMensErro := "Nao foi possível incluir NF "+_cDoc+"/"+_cSerie+". Nao encontrado o "+iif(_cTab == "SA1","Fornecedor ","Cliente ")+_cFornec+"!!"   
			cErros += cMensErro+chr(13)+chr(10)
			lErro := .t.
			Messagebox(cMensErro,"Atenção!",48) 	
		endif
	endif 

	if lIncluiNf
		_cUf := iif(_cTab == "SA2",SA2->A2_EST,SA1->A1_EST)
							
		aAdd(aPed, {"F1_TIPO"    , _cTipo })
		aAdd(aPed, {"F1_FORMUL"    , "N"})
		aAdd(aPed, {"F1_DOC"    , _cDoc})
		aAdd(aPed, {"F1_SERIE"    , _cSerie})
		aAdd(aPed, {"F1_EMISSAO"    , SF2->F2_EMISSAO})
		aAdd(aPed, {"F1_FORNECE"    , _cFornec})
		aadd(aPed, {"F1_LOJA"   , _cLojaF})
		aadd(aPed, {"F1_EST"   , _cUf})
		aAdd(aPed, {"F1_ESPECIE"    , cEspecie})   
		aAdd(aPed, {"F1_CHVNFE"    ,  _cChvnf})   
		nQtdeItens := 0
		dbselectarea("SD2")
		dbsetorder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                                                                                                                                                                                                                  
		dbselectarea(cTcq)
		dbgotop()
		do while lSucesso .and. !eof()  
			_cTipoPro := ""
			dbselectarea("SB1")
			dbsetorder(1)
			dbseek(xFilial("SB1")+(cTcq)->D2_COD)
			if found()
				_cTipoPro := alltrim(SB1->B1_TIPO)
				if (SB1->B1_MSBLQL = "1")
					cQuery := "INSERT INTO PRODBLOQ (FILIAL,PRODUTO,PROGRAMA) VALUES (SELECT '"+xFilial("SB1")+"','"+SB1->B1_COD+"','BRCOM015')
					TCSqlExec(cQuery)
					reclock("SB1",.F.)
					SB1->B1_MSBLQL := "2"
					msunlock()
				endif
			endif 
			nQtdeItens++ 
			aPedRel := {}   
			_nDec := TamSx3("D1_VUNIT")[2]
			nVlrUn := NOROUND(  (cTcq)->D2_PRCVEN  ,_nDec )
			_nDec := TamSx3("D1_TOTAL")[2]
			nVlrTot := round(nVlrUn * (cTcq)->D2_QUANT , _nDec )
			aAdd(aPedRel, {"D1_TIPO"   , _cTipo                       , Nil})
			aAdd(aPedRel, {"D1_COD"   , (cTcq)->D2_COD                , Nil})
			aAdd(aPedRel, {"D1_QUANT"   , (cTcq)->D2_QUANT           , Nil})
			nLinVlrUn := 4 //Guardar linha do valor unitário p/ corrigir caso seja devolução, valores não estão sendo fidedignos nas entradas do depósito
			aAdd(aPedRel, {"D1_VUNIT"   , nVlrUn                      , NIL})
			aAdd(aPedRel, {"D1_TOTAL"   , nVlrTot                     , NIL})
			aAdd(aPedRel, {"D1_TES"     , "216"                       , Nil})
			
			IF (_cFilial == "010101") .and. (_cTipo = "D") 
				DO CASE
				CASE (_cTipoPro == "PA") //Chamado 020305, forçar almoxarifado D1 para PA´s nas devoluções
					aAdd(aPedRel, {"D1_LOCAL"     , "D1"                       , Nil})
				CASE (_cTipoPro == "MC") //Chamado 023503			
					aAdd(aPedRel, {"D1_LOCAL"     , "R0"                       , Nil})
				ENDCASE 
			ENDIF 

			if (_cTipo = "D") .and. (!empty((cTcq)->D2_NFORI) .and. (!empty((cTcq)->D2_SERIORI)))
//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM    
/*
     			_cItem = Alltrim(Str(nQtdeItens))
     			_cItem = SubStr(_cItem, Len(_cItem), 1)
     			_cItem = Chr(Int((nQtdeItens - 100)/10)+65) + _cItem
*/
				_cItem := ALLTRIM( (cTcq)->D2_ITEMORI)
				IF LEN(_cItem) > 2
					_cItem := ConvItemD2(_cItem)
					/*
					cAux := right("000100",len(_cItem))
					if _cItem < cAux
						_cItem := right(_cItem,2)
					else 
						_cItem = SubStr(_cItem, Len(_cItem), 1)
						_cItem = Chr(Int((nQtdeItens - 100)/10)+65) + _cItem
					endif 
					*/
				ENDIF 



				dbselectarea("SD2")
				dbseek(xFilial("SD2")+(cTcq)->D2_NFORI+(cTcq)->D2_SERIORI+_cFornec+_cLojaF+(cTcq)->D2_COD+_cItem)
				if !found()
					lSucesso = .f.
					do case 
					case (len(alltrim((cTcq)->D2_NFORI)) == 6)
						dbseek(xFilial("SD2")+"000"+alltrim((cTcq)->D2_NFORI)+(cTcq)->D2_SERIORI+_cFornec+_cLojaF+(cTcq)->D2_COD+_cItem)
						if found()
							lSucesso := .t.
						endif 
					case (len(alltrim((cTcq)->D2_NFORI)) == 9) .and. (substr((cTcq)->D2_NFORI,1,3) == "000")
						cAux := padr(substr((cTcq)->D2_NFORI,4,6),TamSx3("D2_NFORI")[1]," ")
						dbseek(xFilial("SD2")+cAux+(cTcq)->D2_SERIORI+_cFornec+_cLojaF+(cTcq)->D2_COD+_cItem)
						if found()
							lSucesso := .t.
						endif 
					endcase 
				endif 
				if lSucesso
					aAdd(aPedRel, {"D1_NFORI"     , SD2->D2_DOC                       , NIL})
					aAdd(aPedRel, {"D1_SERIORI"   , SD2->D2_SERIE                     , NIL})
					aAdd(aPedRel, {"D1_ITEMORI"   , SD2->D2_ITEM                      , NIL})
					//Correção de vlr unit com valor da nf da empresa local
					aPedRel[nLinVlrUn,2] := SD2->D2_PRCVEN //,TamSx3("D1_VUNIT")[2] 
					aPedRel[nLinVlrUn+1,2] := noround(SD2->D2_PRCVEN * (cTcq)->D2_QUANT , TamSx3("D1_TOTAL")[2] )

				else 
					MsgBox("Não Encontrada a NF de Origem "+alltrim((cTcq)->D2_NFORI)+" p/ o Produto "+(cTcq)->D2_COD+", item "+(cTcq)->D2_ITEMORI+" !", "Atenção!", "STOP")
				endif 
			endif
			aadd(aItensPed, aPedRel)
			dbselectarea(cTcq)
			dbskip()
		enddo 
		lIncluiNf := lSucesso 
	endif //if lIncluiNf
	if lIncluiNf
		lMsErroAuto := .f.
		lMsHelpAuto := .T.
		DbSelectArea("SF1") 
		cMens := "Incluindo NF "+_cDoc+", Fornecedor "+_cFornec+" ..."		
		/*
		if lMudouUlmes
			PUTMV("MV_ULMES",dDataBase)
		endif 
*/

		MsgRun(cMens, "Aguarde", {|| MsExecAuto( { |x, y| MATA103(x, y) }, aPed, aItensPed ) } )
/*
		if lMudouUlmes
			PUTMV("MV_ULMES",dUlMes)
		endif 
		*/
		If lMsErroAuto   
			cMensErro := "Nao foi possível incluir NF "+_cDoc+"/"+_cSerie+chr(13)+chr(10)+MostraErro()   
			cErros += cMensErro+chr(13)+chr(10)
			lErro := .t.
			lSucesso := .f.
			MsgBox(cMensErro, "Atenção!", "STOP")
		else
			MsgBox("NF "+alltrim(_cDoc)+"/"+alltrim(_cSerie)+" inserida com SUCESSO!", "OK!", "INFO")
		endif

	endif //if lIncluiNf
	dbselectarea(cTcq)
	dbCloseArea()
/*
	if lMudouUlmes 
		PUTMV("MV_ULMES",dUlMes)
	endif 
*/


     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg



	cQuery := "UPDATE "+RetSqlName("SB1")+" SET B1_MSBLQL = '1' FROM PRODBLOQ "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = PRODBLOQ.FILIAL) AND (B1_COD = PRODBLOQ.PRODUTO) "+;
	"WHERE (PRODBLOQ.PROGRAMA = 'BRCOM015') ; "+;
	"DELETE FROM PRODBLOQ WHERE PROGRAMA = 'BRCOM015'"
	TCSqlExec(cQuery)


	if lErro        
		cCC      := "contabilidade@brasilux.com.br" //'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		U_EnvMail("BRCOM015 - Erros Entradas Simbolicas",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
	endif 

       	
return

Static Function ConvItemD2(_cItem)
Local _cRet,cAux,i,nCont,nItem,nAux,cDig


cAux := right("000100",len(_cItem))
if _cItem < cAux
	_cRet := right(_cItem,2)
else 
	nCont := 100
	nAux := 100
	nItem := val(_cItem)
	_cRet := "9A"
	cDig := "A"
	nAdic := 65
	do while nCont < nItem
		nCont++ 
		nAux++
		_cRet := substr(_cRet,1,1)
		cDig := chr(nAux - 100 + nAdic)
		_cRet += cDig 
		if nCont == nItem	
			exit 
		endif 
		if cDig == "Z"
			nAux := 99
			nAdic := 48
			cAux := substr(_cRet,1,1)
			_cRet := iif(cAux == "9","A",chr(asc(substr(_cRet,1,1))+1))
		endif
		if cDig == "9"
			nAux := 99
			nAdic := 65
			cAux := substr(_cRet,1,1)
			//_cRet := iif(cAux == "9","A",chr(asc(substr(_cRet,1,1))+1))
		endif
	enddo 

endif 

return(_cRet)
