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
±±ºPrograma  ³ BRCOM011  ºAutor ³ Cleber Orati       º Data ³  27/10/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função incluir notas de entrada nos depósitos fechados     º±±
±±º          ³ de compras ref. a entrega no depósito de nf emitida na matriz º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCOM011() 
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
     u_zcfga01( 'BRCOM011' ) //LGS#2021118 - Gravação de log de utilização da rotina
     If !(alltrim(_cNumEmp) == "01010106") .and. !(alltrim(_cNumEmp) == "01010107")
        cMens1 := "Acesso deverá ser feito no Depósito Fechado!"
        MessageBox( cMens1, "Atenção", 48 )
        return
     Endif 
	

    @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Entradas de NFs TES 227"

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
    @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_BRCO011(1)} )
    @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
    @ 23,016 SAY "Inclusão de NFs TES 227."
    @ 08,10 TO 84,222
    ACTIVATE DIALOG oDlg1 CENTERED

Return

User Function BRCO011(nOrigem)
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
		MsgRun("Processando...","Aguarde...",{|| BRCO11(nOrigem) } )
		Close(oDlg1)
	else
		aTables := {"SC5","SC6","SB1","SA2","SA1","SD1","SF1","SF2","SD2","SZY","SB2","SF4"} 
		for i := 1 to 1  
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
				BRCO11(nOrigem)
			endif 
		
			RESET ENVIRONMENT 
			//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
		next 
	endif
	 
return(nil)

Static Function BRCO11(nOrigem)

	Local aPed, aPedRel, aItensPed, nQtdeItens, lSucesso, cAux, cMensErro, dUlMes, lMudouUlmes
	Local _cDoc,_cSerie, _cFornec, cOrig,cMens,cErros,lErro,cCC,cPara,cQuery,_cFilial
	Local cArqBloq, aBloq,_cAreaBloq,_cLojaF,_cChvnf,lIncluiNf,nVlrUn,nVlrTot,cTcq            
	Private lMsErroAuto
	Private lMsHelpAuto := .f.
	lErro = .f.
	_cFilial := alltrim(FWCodFil())

// Verificar se tem alguém usando a rotina
	cArqBloq := "BRCOM011"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
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

	cOrig := U_NovoCursor()
	cQuery := "SELECT DISTINCT SD1.D1_FILIAL AS FILIAL,SD1.D1_DOC AS NRONF,SD1.D1_SERIE AS SERIE,SD1.D1_FORNECE AS FORNECE,SD1.D1_LOJA AS LOJA "+; 
	"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (SF1.F1_FILIAL = SD1.D1_FILIAL) AND (SD1.D1_SERIE = SF1.F1_SERIE) AND (SD1.D1_DOC = SF1.F1_DOC) AND (SD1.D1_FORNECE = SF1.F1_FORNECE) AND (SD1.D1_LOJA = SF1.F1_LOJA) AND (SD1.D1_TIPO = SF1.F1_TIPO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF1")+" F1D WITH (NOLOCK) ON (F1D.D_E_L_E_T_ <> '*') AND (F1D.F1_FILIAL = '"+xFilial("SF1")+"') AND (SD1.D1_SERIE = F1D.F1_SERIE) AND (SD1.D1_DOC = F1D.F1_DOC) AND (SD1.D1_FORNECE = F1D.F1_FORNECE) AND (SD1.D1_TIPO = F1D.F1_TIPO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (A2_COD = SD1.D1_FORNECE) "+;
	"WHERE (SD1.D_E_L_E_T_ <> '*') AND (SD1.D1_FILIAL IN ('010101','010104')) AND (SD1.D1_TIPO = 'N') AND (A2_EST <> 'EX') AND "+;
	"(SF1.F1_STATUS > '') AND (A2_CGC NOT LIKE '72770878%') AND (SF1.F1_DEPOSI = 'S') AND (F1D.R_E_C_N_O_ IS NULL) "+;
	"ORDER BY FILIAL, FORNECE,SERIE,NRONF"
	TCQuery cQuery NEW ALIAS (cOrig)

	lSucesso := .t.
	dbselectarea(cOrig)
	dbgotop()
	do while lSucesso .and. !eof()  
		cTcq := U_NovoCursor()   
		cQuery := "SELECT D1_FILIAL AS FILIAL,D1_COD,D1_QUANT,D1_TOTAL,D1_VALIPI,SF1.F1_CHVNFE,F1_EMISSAO AS EMISSAO,F1_ESPECIE "+;
		"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (SF1.F1_FILIAL = SD1.D1_FILIAL) AND (SD1.D1_SERIE = SF1.F1_SERIE) AND (SD1.D1_DOC = SF1.F1_DOC) AND (SD1.D1_FORNECE = SF1.F1_FORNECE) AND (SD1.D1_TIPO = SF1.F1_TIPO) "+;
		"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+(cOrig)->FILIAL+"') AND (D1_SERIE = '"+(cOrig)->SERIE+"') AND (D1_DOC = '"+;
		(cOrig)->NRONF+"') AND (D1_FORNECE = '"+(cOrig)->FORNECE+"') AND (D1_LOJA = '"+(cOrig)->LOJA+"')"
		TCQuery cQuery NEW ALIAS (cTcq)
		dbselectarea("SA2")	
		dbsetorder(1)
		dbselectarea(cTcq)
		dbgotop()
		do while lSucesso .and. !eof()
			aPed       := {}
			aItensPed  := {} 
			//_cFilial := (cTcq)->FILIAL	  	
			_cDoc := (cOrig)->NRONF
			_cSerie := (cOrig)->SERIE 
			_cFornec := (cOrig)->FORNECE
			_cLojaF := (cOrig)->LOJA
			//_cPedVend := (cTcq)->C5_PEDDEP
			_cChvnf := alltrim( (cTcq)->F1_CHVNFE )
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
				aAdd(aPed, {"F1_DOC"    , PADL(ALLTRIM(_cDoc),9,"0")})
				aAdd(aPed, {"F1_SERIE"    , _cSerie})
				aAdd(aPed, {"F1_EMISSAO"    , ctod(substr((cTcq)->EMISSAO,7,2)+"/"+substr((cTcq)->EMISSAO,5,2)+"/"+substr((cTcq)->EMISSAO,1,4))})
				aAdd(aPed, {"F1_FORNECE"    , _cFornec})
				aadd(aPed, {"F1_LOJA"   , _cLojaF})
				aadd(aPed, {"F1_EST"   , SA2->A2_EST})
	//		aadd(aPed, {"F1_COND","001"})
				aAdd(aPed, {"F1_ESPECIE"    , (cTcq)->F1_ESPECIE})   
				aAdd(aPed, {"F1_CHVNFE"    ,  _cChvnf})   
			endif
			nQtdeItens := 0
			dbselectarea(cTcq)
			do while lSucesso .and. !eof()
				dbselectarea("SB1")
				dbsetorder(1)
				dbseek(xFilial("SB1")+(cTcq)->D1_COD)
				if found() .and. (SB1->B1_MSBLQL = "1")
					cQuery := "INSERT INTO PRODBLOQ (FILIAL,PRODUTO,PROGRAMA) VALUES (SELECT '"+xFilial("SB1")+"','"+SB1->B1_COD+"','BRCOM011')
					TCSqlExec(cQuery)
					reclock("SB1",.F.)
					SB1->B1_MSBLQL := "2"
					msunlock()
				endif 


				nQtdeItens++ 
				aPedRel := {}   
				nVlrUn := ROUND( ( (cTcq)->D1_TOTAL + (cTcq)->D1_VALIPI )/ (cTcq)->D1_QUANT ,TamSx3("D1_VUNIT")[2] )
				nVlrTot := round(nVlrUn * (cTcq)->D1_QUANT , TamSx3("D1_TOTAL")[2] )
				aAdd(aPedRel, {"D1_COD"   , (cTcq)->D1_COD                       , Nil})
				aAdd(aPedRel, {"D1_QUANT"   , (cTcq)->D1_QUANT                       , Nil})
				aAdd(aPedRel, {"D1_VUNIT"   , nVlrUn                       , Nil})
				aAdd(aPedRel, {"D1_TOTAL"   , nVlrTot                      , Nil})
				aAdd(aPedRel, {"D1_TES"     , "227"                       , Nil})
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

		dbselectarea(cOrig)
		dbskip()
	enddo 
	dbselectarea(cOrig)
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
	"WHERE (PRODBLOQ.PROGRAMA = 'BRCOM011') ; "+;
	"DELETE FROM PRODBLOQ WHERE PROGRAMA = 'BRCOM011'"
	TCSqlExec(cQuery)


	if lErro        
		cCC      := 'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		U_EnvMail("BRCOM011 - Erros Entradas Simbolicas",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
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
