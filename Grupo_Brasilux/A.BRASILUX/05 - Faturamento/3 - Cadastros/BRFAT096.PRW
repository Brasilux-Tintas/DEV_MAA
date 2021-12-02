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
±±ºPrograma  ³ BRFAT096  ºAutor ³ Cleber O. Dominguesº Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função incluir notas de entrada de notas de remessa        º±±
±±º          ³ simbólica geradas pelo depósito fechado                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT096() 
Local cMens1
	If substr(cNumEmp,1,2) != "01"
		MsgBox("Esta operação só pode ser executada na empresa 01-BRASILUX!", "Atenção!", "STOP")
		Return
	Endif 

     If !u_VldAcesso(funname())
        MessageBox( "Acesso não autorizado!---->" + FunName(), "Atenção", 48 )
        Return 
     Endif 
  
     If !(alltrim(cNumEmp) == "01010101") .and. !(alltrim(cNumEmp) == "01010104")
        cMens1 := "Acesso deverá ser feito na empresa Brasilux/Matriz ou Resina!"
        MessageBox( cMens1, "Atenção", 48 )
        return
     Endif 
     u_zcfga01( 'BRFAT096' ) //LGS#2021201 - Gravação de log de utilização da rotina

    @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Entradas de NF Rem Simbólica"

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
    @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_BRFT096(1)} )
    @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
    @ 23,016 SAY "Inclusão de NF Entrada de Remessa Simbólica."
    @ 08,10 TO 84,222
    ACTIVATE DIALOG oDlg1 CENTERED

Return

User Function BRFT096(nOrigem)

	Local bErro,i,_cFilial
	Local aTables   
	DEFAULT nOrigem := 2

/* nOrigem:	1-Console
			2-Schedule
*/			

	if ValType(nOrigem) <> "N"
		nOrigem := 2
	endif 
	

	if nOrigem == 1
		MsgRun("Processando...","Aguarde...",{|| BRFT96(nOrigem) } )
		Close(oDlg1)
	else
		aTables := {"SC5","SC6","SB1","SA2","SA1","SD1","SF1","SF2","SD2","SZY","SB2","SF4"} 
		for i := 1 to 2  
			_cFilial := iif(i == 1,"010101","010104")
			//Limpa o ambiente, liberando a licença e fechando as conexões
			//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
			RESET ENVIRONMENT
			RpcSetType(3) //seta tipo de consumo de licença

			//RpcSetEnv( "01",_cFilial,'Administrador' ,'851296' , "COM" , , aTables, , , ,  )
			PREPARE ENVIRONMENT EMPRESA "01" FILIAL _cFilial MODULO "COM" TABLES "SC5","SC6","SB1","SA2","SA1","SD1","SF1","SF2","SD2","SZY","SB2","SF4"
			
			bErro := {|e| SCHERRO_1(e)}    

			RpcMyErro()
			ErrorBlock(bErro)

			if !KillApp()
				BRFT96(nOrigem)
			endif 
		
			RESET ENVIRONMENT 
			//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
		next 
	endif
	 
return(nil)

Static Function BRFT96(nOrigem)

	Local aPed, aPedRel, aItensPed, nQtdeItens, lSucesso, cAux, cMensErro, dUlMes, lMudouUlmes
	Local _cDoc,_cSerie, _cCliente, cTcq,cMens,cErros,lErro,cCC,cPara,cQuery
	Local cArqBloq, aBloq,_cAreaBloq,_cLojaF,_cPedVend,_cChvnf,_cNfsSemChaves,lIncluiNf            
	Private lMsErroAuto
	Private lMsHelpAuto := .f.
	lErro = .f.

// Verificar se tem alguém usando a rotina
	cArqBloq := "BRFAT096"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
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

//Cleber (13/02/20)  -> Reajuste da função  BloqProg
/*
	If !Empty( Alltrim( GetMV( 'ZP_PAR0012' ) ) )
	   cAux := "O programa já está sendo usado por: " + Alltrim( GetMV( 'ZP_PAR0012' ) )
       If nOrigem == 1
          MessageBox( cAux, "Atenção!", 16 )
       Else
          FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', cAux, {} )
       Endif
       Return
    Else
       PutMV( "ZP_PAR0012", Iif( nOrigem == 1, RTRIM( cUserName ), "AGENDAMENTO" ) )
    Endif
*/    

	cErros := ""
	lErro := .f.
                  
	dUlMes := GETMV("MV_ULMES")
/*	if dUlMes > (dDataBase-41)
		PUTMV("MV_ULMES",dDataBase-41)
		lMudouUlmes := .t.
	else
		lMudouUlmes := .f.
	endif 
*/	
	_cNfsSemChaves := ""

	cTcq := U_NovoCursor()
	cQuery := "SELECT C5_FILDEP AS FILIAL,C5_PEDDEP,D2_SERIE,D2_DOC,D2_ITEM,D2_EMISSAO,D2_COD,D2_QUANT,D2_PRCVEN,D2_TOTAL,D2_CLIENTE,SF2.F2_CHVNFE,D2_CLASFIS AS CST,ISNULL(SF1.R_E_C_N_O_,0) AS REGF1 "+;
	"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = SF2.F2_FILIAL) AND (D2_SERIE = SF2.F2_SERIE) AND (D2_DOC = SF2.F2_DOC) AND (D2_CLIENTE = SF2.F2_CLIENTE) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (D2_FILIAL = C5_FILIAL) AND (D2_PEDIDO = C5_NUM) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = C5_FILDEP) AND (SF1.F1_FORNECE = '05200') AND (D2_SERIE = F1_SERIE) AND (('000'+D2_DOC) = F1_DOC) "+;
	"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '010106') AND (D2_TES = '828') AND (C5_FILDEP = '"+xFilial("SC5")+"') AND "+;
	"(D2_EMISSAO >= '"+dtos(dDatabase-40)+"') "+;
	"ORDER BY FILIAL,D2_CLIENTE,D2_SERIE,D2_DOC,D2_ITEM"

//	"(SF2.F2_CHVNFE > '') AND (SF1.R_E_C_N_O_ IS NULL) AND "+;

	TCQuery cQuery NEW ALIAS (cTcq)
	lSucesso := .t.
	dbselectarea(cTcq)
	dbgotop()
	do while lSucesso .and. !eof()       
		aPed       := {}
		aItensPed  := {} 
		_cFilial := (cTcq)->FILIAL	  	
		_cDoc := (cTcq)->D2_DOC
		_cSerie := (cTcq)->D2_SERIE 
		_cCliente := (cTcq)->D2_CLIENTE
		_cPedVend := (cTcq)->C5_PEDDEP
		_cChvnf := alltrim( (cTcq)->F2_CHVNFE )
		lIncluiNf := .t.

		if empty(_cChvnf)
			lIncluiNf := .f.
			if !empty(_cNfsSemChaves)
				_cNfsSemChaves += ","
			endif 
			_cNfsSemChaves += _cDoc+"/"+_cSerie
		endif 
		IF (cTcq)->REGF1 > 0
			lIncluiNf := .f.
		ENDIF 
		dbselectarea("SA2")	
		dbsetorder(1)
		dbseek(xFilial("SA2")+"05200",.t.)
		if !found()
			lSucesso := .f.
			cMensErro := "Nao foi possível incluir NF "+_cDoc+"/"+_cSerie+". Nao encontrado o Fornecedor 05200!!"   
			cErros += cMensErro+chr(13)+chr(10)
			lErro := .t.
			if nOrigem == 1
				Alert(cMensErro)
			else  
				FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
				//ConOut(cMensErro)
			endif 
			exit 	
		else
			_cLojaF := SA2->A2_LOJA		
		endif

		if lIncluiNf
							
			aAdd(aPed, {"F1_TIPO"    , "N" })
			aAdd(aPed, {"F1_FORMUL"    , "N"})
			aAdd(aPed, {"F1_DOC"    , PADL(ALLTRIM(_cDoc),9,"0")})
			aAdd(aPed, {"F1_SERIE"    , _cSerie})
			aAdd(aPed, {"F1_EMISSAO"    , ctod(substr((cTcq)->D2_EMISSAO,7,2)+"/"+substr((cTcq)->D2_EMISSAO,5,2)+"/"+substr((cTcq)->D2_EMISSAO,1,4))})
			aAdd(aPed, {"F1_FORNECE"    , SA2->A2_COD})
			aadd(aPed, {"F1_LOJA"   , SA2->A2_LOJA})
			aadd(aPed, {"F1_EST"   , SA2->A2_EST})
	//		aadd(aPed, {"F1_COND","001"})
			aAdd(aPed, {"F1_ESPECIE"    , "SPED"})   
			aAdd(aPed, {"F1_CHVNFE"    ,  (cTcq)->F2_CHVNFE})   
		endif

//		aadd(aPed, {"E2_NATUREZ","00001"})
			
		do while lSucesso .and. !eof() .and. ((cTcq)->FILIAL == _cFilial) .AND. ((cTcq)->D2_DOC == _cDoc) .AND. ((cTcq)->D2_SERIE == _cSerie) .AND. ((cTcq)->D2_CLIENTE == _cCliente)
			if lIncluiNf
				dbselectarea("SB1")
				dbsetorder(1)
				dbseek(xFilial("SB1")+(cTcq)->D2_COD)
				if found() .and. (SB1->B1_MSBLQL = "1")
					cQuery := "INSERT INTO PRODBLOQ (FILIAL,PRODUTO,PROGRAMA) VALUES (SELECT '"+xFilial("SB1")+"','"+SB1->B1_COD+"','BRFAT096')
					TCSqlExec(cQuery)
					reclock("SB1",.F.)
					SB1->B1_MSBLQL := "2"
					msunlock()
				endif 
					
				nQtdeItens++ 
				aPedRel := {}   
				aAdd(aPedRel, {"D1_COD"   , (cTcq)->D2_COD                       , Nil})
				aAdd(aPedRel, {"D1_QUANT"   , (cTcq)->D2_QUANT                       , Nil})
				aAdd(aPedRel, {"D1_VUNIT"   , (cTcq)->D2_PRCVEN                       , Nil})
				aAdd(aPedRel, {"D1_TOTAL"   , (cTcq)->D2_TOTAL                       , Nil})
				aAdd(aPedRel, {"D1_TES"     , "129"                       , Nil})
				aAdd(aPedRel, {"D1_CLASFIS" , (cTcq)->CST      , Nil})
				aadd(aItensPed, aPedRel)
			endif 
			dbselectarea(cTcq)
			dbskip()
		enddo 
			
		if lIncluiNf
			lMsErroAuto := .f.
			lMsHelpAuto := .T.
			DbSelectArea("SF1") 
			cMens := "Incluindo NF "+_cDoc+"..."		
		/*
			if lMudouUlmes
				PUTMV("MV_ULMES",dDataBase-41)
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
	//				MostraErro()
				else  
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
					//ConOut(cMensErro)
				endif 
			endif
		endif // fim if lIncluiNf
	
		if lSucesso
			//Registro C113 do Sped Fiscal
			if !empty(_cPedVend)
				cMens := "Incluindo Complemento NF "+_cDoc+"..."		

				if nOrigem == 1           
					IncProc(cMens) 
				else
					//Conout(cMens)
					FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', cMens, 0 )
				endif 	

				dbselectarea("SF2")
				DbOrderNickName("SF2001") //F2_FILIAL+F2_PEDIDO  
				dbseek(xFilial("SF2")+_cPedVend)  
				if !found()
					lErro := .t.
					if !empty(cErros)
						cErros += chr(13)+chr(10)
					endif 
					cErros += "Não encontrada a NF de Venda ref. à Remessa Simbólica "+_cDoc+"/"+_cSerie+", pedido nro "+_cPedVend+"."
				else 

					dbselectarea("CDD")
					dbsetorder(1) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF                                                          
					dbseek(xFilial("CDD")+"E"+padr(PADL(ALLTRIM(_cDoc),9,"0"),TamSx3("CDD_DOC")[1]," ")+padr(alltrim(_cSerie),TamSx3("CDD_SERIE")[1]," ")+padr("05200",TamSx3("CDD_CLIFOR")[1]," ")+_cLojaF+padr(SF2->F2_DOC,TamSx3("CDD_DOCREF")[1]," ")+padr(SF2->F2_SERIE,TamSx3("CDD_SERREF")[1]," ")+padr(SF2->F2_CLIENTE,TamSx3("CDD_PARREF")[1]," ")+SF2->F2_LOJA)
					if !found() 
						reclock("CDD",.T.)
						CDD->CDD_FILIAL := xFilial("CDD")
						CDD->CDD_TPMOV := "E"
						CDD->CDD_DOC := PADL(ALLTRIM(_cDoc),9,"0")
						CDD->CDD_SERIE := _cSerie
						CDD->CDD_CLIFOR := "05200"
						CDD->CDD_LOJA := _cLojaF
						CDD->CDD_DOCREF := SF2->F2_DOC
						CDD->CDD_SERREF := SF2->F2_SERIE
						CDD->CDD_PARREF := SF2->F2_CLIENTE
						CDD->CDD_LOJREF := SF2->F2_LOJA
						CDD->CDD_IFCOMP := "000043"
						CDD->CDD_CHVNFE := SF2->F2_CHVNFE
						CDD->CDD_SDOC := _cSerie
						CDD->CDD_SDOCRF := SF2->F2_SERIE
						CDD->CDD_ENTSAI := "2"
					else
						reclock("CDD",.f.)
						CDD->CDD_IFCOMP := "000043"
						CDD->CDD_CHVNFE := SF2->F2_CHVNFE
						CDD->CDD_SDOC := _cSerie
						CDD->CDD_SDOCRF := SF2->F2_SERIE
						CDD->CDD_ENTSAI := "2"
					endif 

					msunlock()
				endif
			endif 

		Endif

		dbselectarea(cTcq)
	enddo 
	/*
	if lMudouUlmes 
		PUTMV("MV_ULMES",dUlMes)
	endif 
	*/
	dbselectarea(cTcq)
	dbCloseArea()

     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg


//	PutMV( "ZP_PAR0012", '' ) //ZP_PAR0012

    IF nOrigem == 2
        /*** ADEQUAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "FIM da inclusão das notas simbólias geradas pelo depósito" + Time(), 0 )
     ENDIF 

	cQuery := "UPDATE "+RetSqlName("SB1")+" SET B1_MSBLQL = '1' FROM PRODBLOQ "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = PRODBLOQ.FILIAL) AND (B1_COD = PRODBLOQ.PRODUTO) "+;
	"WHERE (PRODBLOQ.PROGRAMA = 'BRFAT096') ; "+;
	"DELETE FROM PRODBLOQ WHERE PROGRAMA = 'BRFAT096'"
	TCSqlExec(cQuery)

	if !empty(_cNfsSemChaves)
		lErro := .t.
		if !empty(cErros)
			cErros += chr(13)+chr(10)
		endif 
		cErros += "As seguintes Nfs de Saída do Dep. Guarulhos estão sem Chave: "+_cNfsSemChaves
	endif 

	if lErro        
		cCC      := 'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		/*
		cAuxMail := alltrim(UsrRetMail("000000"))
		if !(cPara == cAuxMail)
			cCC := cAuxMail
		endif 
		*/
		U_EnvMail("BRFAT096 - Erros Entradas Simbolicas",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
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
