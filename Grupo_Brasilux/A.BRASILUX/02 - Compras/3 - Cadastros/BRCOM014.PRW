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
±±ºPrograma  ³ BRCOM014  ºAutor ³ Cleber Orati       º Data ³  27/10/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função incluir notas de entrada nos depósitos fechados     º±±
±±º          ³ de remessas simbolicas de compras ref. a entrega no depósito º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCOM014() 
Local cMens1,_cGrpEmp,_cFilial,_cNumEmp
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
  
     If !(alltrim(_cNumEmp) == "01010106") .and. !(alltrim(_cNumEmp) == "01010107")
        cMens1 := "Acesso deverá ser feito no Depósito Fechado!"
        MessageBox( cMens1, "Atenção", 48 )
        return
     Endif 
	

    @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Entradas de NFs TES 282"

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
    @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_BRCO014(1)} )
    @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
    @ 23,016 SAY "Inclusão de NFs TES 282."
    @ 08,10 TO 84,222
    ACTIVATE DIALOG oDlg1 CENTERED

Return

User Function BRCO014(nOrigem)
Local bErro,i,_cFilial
Local aTables   

DEFAULT nOrigem := 2

/* 
nOrigem:	1-Console
			2-Schedule
*/			

	if ValType(nOrigem) <> "N"
		nOrigem := 2
	endif 
	

	if nOrigem == 1
		MsgRun("Processando...","Aguarde...",{|| BRCO14(nOrigem) } )
		Close(oDlg1)
	else
		aTables := {"SC5","SC6","SB1","SA2","SA1","SD1","SF1","SF2","SD2","SZY","SB2","SF4"} 
		for i := 1 to 2  
			_cFilial := iif(i == 1,"010106","010107")
			//Limpa o ambiente, liberando a licença e fechando as conexões
			//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
			RESET ENVIRONMENT
			RpcSetType(3) //seta tipo de consumo de licença

			//RpcSetEnv( "01",_cFilial,'Administrador' ,'851296' , "COM" , , aTables, , , ,  )
			PREPARE ENVIRONMENT EMPRESA "01" FILIAL _cFilial MODULO "COM" TABLES "SC7","SD1","SB1","SA2","SD1","SF1","SZY","SB2","SF4"
			
			bErro := {|e| SCHERRO_1(e)}    

			RpcMyErro()
			ErrorBlock(bErro)

			if !KillApp()
				BRCO14(nOrigem)
			endif 
		
			RESET ENVIRONMENT 
			//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
		next 
	endif
	 
return(nil)

Static Function BRCO14(nOrigem)

	Local aPed, aPedRel, aItensPed, nQtdeItens, lSucesso, cAux, cMensErro, dUlMes, lMudouUlmes
	Local _cDoc,_cSerie, _cFornec, cMens,cErros,lErro,cCC,cPara,cQuery,_cFilial,cCliente,cEspecie
	Local cArqBloq, aBloq,_cAreaBloq,_cLojaF,_cChvnf,lIncluiNf,nVlrUn,nVlrTot,cTcq,_cFilNf            
	Private lMsErroAuto
	Private lMsHelpAuto := .f.
	lErro = .f.
	_cFilial := alltrim(FWCodFil())

// Verificar se tem alguém usando a rotina
	cArqBloq := "BRCOM014"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
	aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
   	if aBloq[1,1] //Já estava bloqueado?
   		cAux := "O programa já está sendo usado por: "+aBloq[1,2]
   		If nOrigem = 1
			Messagebox(cAux,"Atenção!",48) 		
		else
			FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', cAux, 0 )
		endif 
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
	cCliente := iif(_cFilial == "010106","023818","035163")

	cTcq := U_NovoCursor()
	cQuery := "SELECT D2_FILIAL AS FILIAL,D2_DOC AS NRONF,D2_SERIE AS SERIE,FORNECE = '00354' ,D2_COD,D2_QUANT,D2_PRCVEN,SF2.F2_CHVNFE,F2_EMISSAO AS EMISSAO,F2_ESPECIE "+;
	"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = D2_FILIAL) AND (C6_NUM = D2_PEDIDO) AND (C6_ITEM = D2_ITEMPV) "+;	
	"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (F2_DOC = D2_DOC) AND (F2_SERIE = D2_SERIE) AND (F2_CLIENTE = D2_CLIENTE) AND (F2_LOJA = D2_LOJA) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = '010106') AND (F1_SERIE = D2_SERIE) AND (F1_DOC = D2_DOC) AND (F1_FORNECE = '00354') "+;
	"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '010101') AND (D2_CLIENTE = '"+cCliente+"') AND (C6_XREGD1D > 0) AND (SF1.R_E_C_N_O_ IS NULL) "+;
	"UNION ALL "+;
	"SELECT D2_FILIAL AS FILIAL,D2_DOC AS NRONF,D2_SERIE AS SERIE,FORNECE = '00401' ,D2_COD,D2_QUANT,D2_PRCVEN,SF2.F2_CHVNFE,F2_EMISSAO AS EMISSAO,F2_ESPECIE "+;
	"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = D2_FILIAL) AND (C6_NUM = D2_PEDIDO) AND (C6_ITEM = D2_ITEMPV) "+;	
	"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (F2_DOC = D2_DOC) AND (F2_SERIE = D2_SERIE) AND (F2_CLIENTE = D2_CLIENTE) AND (F2_LOJA = D2_LOJA) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = '010106') AND (F1_SERIE = D2_SERIE) AND (F1_DOC = D2_DOC) AND (F1_FORNECE = '00401') "+;
	"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '010104') AND (D2_CLIENTE = '"+cCliente+"') AND (C6_XREGD1D > 0) AND (SF1.R_E_C_N_O_ IS NULL) "+;
	"ORDER BY FILIAL,SERIE,NRONF,FORNECE"
	TCQuery cQuery NEW ALIAS (cTcq)

	lSucesso := .t.
	dbselectarea(cTcq)
	dbgotop()
	do while lSucesso .and. !eof()  
		dbselectarea("SA2")	
		dbsetorder(1)
		dbselectarea(cTcq)
		aPed       := {}
		aItensPed  := {} 
		_cFilNf := (cTcq)->FILIAL	  	
		_cDoc := (cTcq)->NRONF
		_cSerie := (cTcq)->SERIE 
		_cFornec := padr((cTcq)->FORNECE,TamSx3("A2_COD")[1]," ")
		_cLojaF := "01"
		cEspecie := ALLTRIM((cTcq)->F2_ESPECIE)
		IF EMPTY(cEspecie)
			cEspecie := "NFE"
		ENDIF 
			//_cPedVend := (cTcq)->C5_PEDDEP
		_cChvnf := alltrim( (cTcq)->F2_CHVNFE )
		lIncluiNf := .t.

		dbselectarea("SA2")	
		dbseek(xFilial("SA2")+_cFornec+_cLojaF,.t.)
		if !found()
				lIncluiNf := .f.
				lSucesso := .f.
				cMensErro := "Nao foi possível incluir NF "+_cDoc+"/"+_cSerie+". Nao encontrado o Fornecedor "+_cFornec+"!!"   
				cErros += cMensErro+chr(13)+chr(10)
				lErro := .t.
				if nOrigem == 1
					Alert(cMensErro)
				else  
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
				endif 
				exit 	
		endif

		if lIncluiNf
							
			aAdd(aPed, {"F1_TIPO"    , "N" })
			aAdd(aPed, {"F1_FORMUL"    , "N"})
			aAdd(aPed, {"F1_DOC"    , _cDoc})
			aAdd(aPed, {"F1_SERIE"    , _cSerie})
			aAdd(aPed, {"F1_EMISSAO"    , ctod(substr((cTcq)->EMISSAO,7,2)+"/"+substr((cTcq)->EMISSAO,5,2)+"/"+substr((cTcq)->EMISSAO,1,4))})
			aAdd(aPed, {"F1_FORNECE"    , _cFornec})
			aadd(aPed, {"F1_LOJA"   , _cLojaF})
			aadd(aPed, {"F1_EST"   , SA2->A2_EST})
	//		aadd(aPed, {"F1_COND","001"})
			aAdd(aPed, {"F1_ESPECIE"    , cEspecie})   
			aAdd(aPed, {"F1_CHVNFE"    ,  _cChvnf})   
		endif
		nQtdeItens := 0
		dbselectarea(cTcq)
		do while lSucesso .and. !eof() .and. (_cFilNf == (cTcq)->FILIAL) .and. (alltrim(_cSerie) == alltrim((cTcq)->SERIE)) .and. (alltrim(_cDoc) == alltrim((cTcq)->NRONF)) .AND. (alltrim(_cFornec) == alltrim((cTcq)->FORNECE))
				dbselectarea("SB1")
				dbsetorder(1)
				dbseek(xFilial("SB1")+(cTcq)->D2_COD)
				if found() .and. (SB1->B1_MSBLQL = "1")
					cQuery := "INSERT INTO PRODBLOQ (FILIAL,PRODUTO,PROGRAMA) VALUES (SELECT '"+xFilial("SB1")+"','"+SB1->B1_COD+"','BRCOM014')
					TCSqlExec(cQuery)
					reclock("SB1",.F.)
					SB1->B1_MSBLQL := "2"
					msunlock()
				endif 


				nQtdeItens++ 
				aPedRel := {}   
				nVlrUn := ROUND(  (cTcq)->D2_PRCVEN  ,TamSx3("D1_VUNIT")[2] )
				nVlrTot := round(nVlrUn * (cTcq)->D2_QUANT , TamSx3("D1_TOTAL")[2] )
				aAdd(aPedRel, {"D1_COD"   , (cTcq)->D2_COD                       , Nil})
				aAdd(aPedRel, {"D1_QUANT"   , (cTcq)->D2_QUANT                       , Nil})
				aAdd(aPedRel, {"D1_VUNIT"   , nVlrUn                       , Nil})
				aAdd(aPedRel, {"D1_TOTAL"   , nVlrTot                      , Nil})
				aAdd(aPedRel, {"D1_TES"     , "282"                       , Nil})
				//aAdd(aPedRel, {"D1_CLASFIS" , (cTcq)->CST      , Nil})
				aadd(aItensPed, aPedRel)
				dbselectarea(cTcq)
				dbskip()
		enddo 
			
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
				if nOrigem == 1           
					MsgRun(cMens, "Aguarde", {|| MsExecAuto( { |x, y| MATA103(x, y) }, aPed, aItensPed ) } )
				else
					//Conout(cMens)
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMens, 0 )
					MsExecAuto( { |x, y| MATA103(x, y) }, aPed, aItensPed) 
				endif 	
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
					if nOrigem == 1
						MsgBox(cMensErro, "Atenção!", "STOP")
						//MostraErro()
					else  
						FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
						//ConOut(cMensErro)
					endif 
				endif
		endif // fim if lIncluiNf

		dbselectarea(cTcq)

	enddo 
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



    IF nOrigem == 2
        /*** ADEQUAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "FIM da inclusão das notas de compra no depósito" + Time(), 0 )
     ENDIF 

	cQuery := "UPDATE "+RetSqlName("SB1")+" SET B1_MSBLQL = '1' FROM PRODBLOQ "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = PRODBLOQ.FILIAL) AND (B1_COD = PRODBLOQ.PRODUTO) "+;
	"WHERE (PRODBLOQ.PROGRAMA = 'BRCOM014') ; "+;
	"DELETE FROM PRODBLOQ WHERE PROGRAMA = 'BRCOM014'"
	TCSqlExec(cQuery)


	if lErro        
		cCC      := 'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		U_EnvMail("BRCOM014 - Erros Entradas Simbolicas",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
	endif 

       	
return

/**************************************************************************************/
/*** SCHERRO_1 - Tratamento dos erros ocorridos.                                     ***/
/**************************************************************************************/
STATIC Function SCHERRO_1(e)
       Local cMensErro :=""
       If KillApp() 
          Return
       Endif
       If e:GenCode == EG_JOB
          Sleep(60000)
          Break
       Else
          If (e:GenCode == EG_ZERODIV)
             Return(0)
          ElseIf (e:GenCode == EG_NOALIAS)
                 //ConOut("   *** Alias does not exist "+e:Operation)
                 cMensErro := "*** Alias does not exist "+e:Operation
                 FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
                 Return
          Endif
       Endif
       //ConOut("   ***"+SCHERRO_2(e))
       __QUIT()
Return(Nil)
                               
/**************************************************************************************/
/*** SCHERRO_2 - Exibi a mensagem de erro na tela do server.                         ***/
/**************************************************************************************/
/*
STATIC Function SCHERRO_2(e)
       Local cMessage := If( Empty(e:osCode), If(e:Severity > ES_WARNING, "Error ", "Warning "), "DOS Error "+nTrim(e:osCode)+" )" )
       cMessage += If( ValType(e:SubSystem) == "C", e:SubSystem, "???")
       If ValType(e:Description) == "C"
          cMessage += " "+e:Description
       Endif
       cMessage += If( !Empty(e:FileName), ": "+e:FileName, If( !Empty(e:Operation), ": "+e:Operation, "") )
Return(cMessage)
*/
