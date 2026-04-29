#include 'tbiconn.ch'
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include 'DIRECTRY.CH'       
#INCLUDE "AP5MAIL.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRCOM013  ºAutor ³ Cleber Oratiº        Data ³  29/10/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função gerar lctos de remessa simbólica das compras para  º±±
±±º          ³ seu depósito fechado                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCOM013()  
Local _cEmpr,_cFilial,_cNumEmp,_cGrpEmp
private oDlg1
	_cEmpr := alltrim(FWCodEmp())
	_cGrpEmp := alltrim(FWGrpCompany())
	_cFilial := alltrim(FWCodFil())
	_cNumEmp := _cGrpEmp+_cFilial
	if !(_cNumEmp == "01010101") .and. !(_cNumEmp == "01010104")
		MsgBox("Esta operação só pode ser executada na Brasilux/Matriz ou Resina!", "Atenção!", "STOP")
		return
	endif 
     u_zcfga01( 'BRCOM013' ) //LGS#2021118 - Gravação de log de utilização da rotina
     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Remessa Simbolica de Compras"

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
     @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_BRCO013(1)} )
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 23,016 SAY "Remessa Simbolica de Compras."
     @ 08,10 TO 84,222
     ACTIVATE DIALOG oDlg1 CENTERED

Return

User Function BRCO013(nOrigem)
/* nOrigem:	1-Console
			2-Schedule
*/			
Local bErro,i,_cFilial
//Local aTables    := {"SC5","SC6","SC9","SB1","SB2","SA1","SA2","SF4","SD1"}  
Local cAuxMens  := ""
DEFAULT nOrigem := 2

if ValType(nOrigem) <> "N"
	nOrigem := 2
endif 


If nOrigem == 1                                                                
  
	MsgRun("Processando...","Aguarde...",{|| BRCO13(nOrigem) } )
	Close(oDlg1)

Else

	FOR i := 1 to 2

		_cFilial := iif(i == 1,"010101","010104")

		RESET ENVIRONMENT
		RpcSetType(3) //seta tipo de consumo de licença
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL _cFilial MODULO "FAT" TABLES "SX2","SC5","SC6","SC9","SB1","SB2","SA1","SA2","SF4","SD1"

		//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
		//RpcSetType(3) //seta tipo de consumo de licença

		cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
		cAuxMens += "-- INICIO INCLUSÃO DE PEDIDOS FILIAL "+_cFilial+" - BRCOM013"+ CHR( 13 ) + CHR( 10 )
		cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
		FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )

		//ConOut("-- INICIO INCLUSÃO DE PEDIDOS P/ DEPÓSITO  - BRCOM013")

		bErro := {|e| SCHERRO_1(e)}    

		//RpcMyErro()
		ErrorBlock(bErro)

		if !KillApp()
			BRCO13(nOrigem)
		endif 

		cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
		cAuxMens += "-- FINAL DA INCLUSÃO DE PEDIDOS FILIAL "+_cFilial+" - BRCOM013"+ CHR( 13 ) + CHR( 10 )
		cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
		FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', cAuxMens, 0 )

		
		RESET ENVIRONMENT
		//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
	NEXT	

Endif 


Return(nil)

Static Function BRCO13(nOrigem)

	Local cAux,cQuery,nQtde,nVlrUnit,_cFilial,_cLocal,_cItem
	Local aPed, aPedRel, nQtdeItens, aItensPed,aAux,lErro,;
		cMensErro,  cObs,lSucesso,aArea,cErros,;
       	cCC,cPara,nContPed,_cPed,cTmp, cCliente
	Local cArqBloq, aBloq,_cAreaBloq,nRegF2			//,aStrut,cCodBor             
    Private lMsErroAuto
    Private lMsHelpAuto := .f.
    Private INCLUI := .f.
    Private ALTERA := .t.
    Private lSugere := .f.
    Private oTempTable
    Private aCols , aHeadGrade, aColsGrade, aHeader

	aArea := U_PegaArea({"SM0","SD1","SA2","SA1","SA3","SB2","SB1","SC5","SC6"})
	lErro := .f.
	cErros := ""
	_cFilial := alltrim(FWCodFil())

// Verificar se tem alguém usando a rotina
	cArqBloq := "BRCOM013"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
	aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada
   	if aBloq[1,1] //Já estava bloqueado?
   		cAux := "O programa já está sendo usado por: "+aBloq[1,2]
   		If nOrigem = 1
			Messagebox(cAux,"Atenção!",48) 		
		else
			FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', cAux, 0 )
		endif 
		Return
	endif


	_cAreaBloq := aBloq[1,4]


    DbSelectarea("SA3")
    DbSetOrder(1)
    DbSelectarea("SA2")
    DbSetOrder(1)
    DbSelectArea("SA1")
    DbSetOrder(1)
    DbSelectArea("SB2")
    DbSetOrder(1)
    DbSelectArea("SB5")
    DbSetOrder(1)
    DbSelectArea("SC5")
    DbSetOrder(1)
    DbSelectArea("SD1")
    DbSetOrder(1)
    DbSelectArea("SF1")
    DbSetOrder(1)
    DbSelectArea("SF4")
    DbSetOrder(1)
    DbSelectArea("SG1")
    DbSetOrder(1)
    DbSelectArea("SZ1")
    DbSetOrder(1)
    DbSelectArea("SZ5")
    DbSetOrder(1)
    DbSelectArea("ZZO")
    DbSetOrder(1)
    DbSelectArea("SC6")
    DbSetOrder(1)

 /*
    aStrut := {}
    aadd(aStrut,{"REGD1" , "C", 10, 0})     
    aadd(aStrut,{"QTDE"  , "N", 13, 4})
     
    oTempTable := FWTemporaryTable():New( "TMP" )
    oTemptable:SetFields( aStrut )
    oTempTable:AddIndex( "cInd01", { "REGD1" } )
    oTempTable:Create()
    DbSelectArea( "TMP" )
    DbSetOrder(1)
*/
     
    cTmp := U_NovoCursor()
     
    cQuery = "SELECT SF1.R_E_C_N_O_ AS REGF2,SD1.R_E_C_N_O_ AS REGD1,D1_DOC AS NF,D1_SERIE AS SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM,"+;
	"D1_QUANT,D1_TOTAL,D1_VALIPI,ISNULL(A2_NOME,'') AS RAZAO "+;                                                                                                     
	"FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FILIAL = D1_FILIAL) AND (D1_DOC = F1_DOC) AND (D1_SERIE = F1_SERIE) AND (D1_FORNECE = F1_FORNECE) AND (D1_LOJA = F1_LOJA) AND (F1_TIPO = D1_TIPO) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (A2_FILIAL = '"+xFilial("SA2")+"') AND (D1_FORNECE = A2_COD) AND (D1_LOJA = A2_LOJA) "+;
	"LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON (SC6.D_E_L_E_T_ <> '*') AND (C6_XREGD1D = SD1.R_E_C_N_O_) "+;
	"WHERE (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+xFilial("SD1")+"') AND (D1_TIPO = 'N') AND (F1_STATUS > '') AND (F1_DEPOSI = 'S') AND "+;
	"(SC6.R_E_C_N_O_ IS NULL) "+;
	"ORDER BY REGF2,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM "
    TCQuery cQuery NEW ALIAS (cTmp)

    lSucesso := .t.
    nContPed := 0 
    dbselectarea(cTmp)
    dbgotop()
    do while lSucesso .and. !eof()    
		nRegF2 := (cTmp)->REGF2 
     	aPed       := {}
     	aItensPed  := {} 

 		cCliente := "023818" //Depósito Guarulhos
     	cObs = "Remessa Simbolica Ref. NF Fornecedor Origem nro "+(cTmp)->NF+iif(!empty((cTmp)->SERIE)," Serie "+(cTmp)->SERIE,"")+", Fornecedor: "+(cTmp)->D1_FORNECE+;
		"-"+ALLTRIM(  (cTmp)->RAZAO )
     	//ATENÇÃO! Ao incluir item, observar o seek em SC5 abaixo!!!!
     	aAdd(aPed, {"C5_TIPO"    , "N"                               , nil})
     	aAdd(aPed, {"C5_CLIENTE" , cCliente             , nil})
     	aAdd(aPed, {"C5_CONDPAG" , "001"             , nil})
     	aAdd(aPed, {"C5_EMISSAO" , dDataBase                         , nil})
     	aAdd(aPed, {"C5_TRANSP"  , "00250"             , .F.}) //VLR .F.
     	aAdd(aPed, {"C5_REDESP"  , ""             , .F.}) //VLR .F.
     	aAdd(aPed, {"C5_TPFRETE" , "C"                               , nil})       
     	aAdd(aPed, {"C5_DEPOSI"  , "N"                               , nil})       
     	aAdd(aPed, {"C5_OBSNF"   , cObs, nil})


     	dbselectarea("SD1")
     	dbsetorder(7) //D1_FILIAL+D1_COD+D1_LOCAL+DTOS(D1_DTDIGIT)+D1_NUMSEQ                                                                                                            
     	nQtdeItens := 0
     	dbselectarea(cTmp)
     	do while lSucesso .and. !eof() .and. (nRegF2 == (cTmp)->REGF2)
     		dbselectarea("SB1")
     		dbseek(xFilial("SB1")+(cTmp)->D1_COD)
     		if !found()
     			lSucesso = .f.
     			lErro := .t.
     			cMensErro := "Produto "+(cTmp)->D1_COD+" NÃO ENCONTRADO! "+cObs
     			cErros += cMensErro+chr(13)+chr(10)
     			if nOrigem == 1
				 	MessageBox( cMensErro, "Atenção", 48 )
     			else
     				FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', cMensErro, 0 )
     			endif 
     			exit 
			else
				do case 
					case SB1->B1_TIPO = "MP"
						_cLocal := "01"
					case SB1->B1_TIPO = "PI"
						_cLocal := "02"
					case SB1->B1_TIPO = "PA"
						_cLocal := "03"
					case SB1->B1_TIPO = "MC"
						_cLocal := "04"
					otherwise
						_cLocal := iif(!EMPTY(SB1->B1_LOCPAD) .AND. (LEN(ALLTRIM(SB1->B1_LOCPAD))== 2) .AND. (SUBSTR(SB1->B1_LOCPAD,1,1) == "0"),SB1->B1_LOCPAD,"01")
				endcase

     		endif 
     		//Desbloquear produto    
     		IF (SB1->B1_MSBLQL = "1") .OR. (SB1->B1_VEND = "N")
     			dbselectarea("SB1")
     			reclock("SB1",.F.)
     			SB1->B1_MSBLQL := "2"   
     			SB1->B1_VEND = "S"
     			msunlock()
     		ENDIF 
			
     		nQtde := (cTmp)->D1_QUANT

     		nVlrUnit := ROUND( ( (cTmp)->D1_TOTAL + (cTmp)->D1_VALIPI )/ nQtde ,TamSx3("C6_PRCVEN")[2] )
     		nQtdeItens++ 
     		aPedRel := {}     
     		If nQtdeItens < 100
     			_cItem = Alltrim(Str(nQtdeItens))
     			If Len(_cItem) == 1
     				_cItem = "0"+_cItem
     			Endif
     		Else
     			_cItem = Alltrim(Str(nQtdeItens))
     			_cItem = SubStr(_cItem, Len(_cItem), 1)
     			_cItem = Chr(Int((nQtdeItens - 100)/10)+65) + _cItem
     		Endif  
		
     		dbselectarea("SB2")
     		dbsetorder(1)
     		dbseek(xFilial("SB2")+(cTmp)->D1_COD+_cLocal)
     		if !found()
     			CriaSb2((cTmp)->D1_COD,_cLocal)
     		endif  

     		aAdd(aPedRel, {"C6_ITEM"   , _cItem                , nil})
     		aadd(aPedRel, {"C6_PRODUTO", (cTmp)->D1_COD     , nil})
     		aadd(aPedRel, {"C6_LOCAL", _cLocal     , nil})
     		aadd(aPedRel, {"C6_QTDVEN" , nQtde, nil})
     		aadd(aPedRel, {"C6_PRCVEN" , nVlrUnit , nil})
     		aadd(aPedRel, {"C6_XREGD1D" , (cTmp)->REGD1 , nil})
     		aadd(aPedRel, {"C6_TES"    , "824", nil})
     		aadd(aItensPed, aPedRel)       

     		dbselectarea(cTmp)
     		dbskip()
     	enddo 
		
     	if !lSucesso
     		exit
     	endif 

     	dbselectarea("SC6")   
     	dbsetorder(1)
     	dbseek(xFilial("SC6"))
     	if (nQtdeItens == 0) // Não pode incluir se não existem itens  
     		cMensErro := "NF "+(cTmp)->NF+", Serie "+(cTmp)->SERIE+", Fornec "+(cTmp)->D1_FORNECE+", da Filial "+_cFilial+" ESTÁ VAZIO!!!"    
     		lErro := .t.
     		cErros += cMensErro+chr(13)+chr(10)
     		if nOrigem == 1
     			MessageBox( cMensErro, "Atenção", 48 ) 								
     		else
     			FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
     			//ConOut(cMensErro)
     		endif 

     		dbselectarea(cTmp)
     		loop
     	endif 
	
     	aAux := aItensPed
     	lMsErroAuto := .f.
     	lMsHelpAuto := .f.
     	DbSelectArea("SC5")   
     	dbsetorder(1) 
     	dbseek(xFilial("SC5"))
     	if nOrigem == 1
     		MsgRun("Incluindo pedido(s)...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aPed, aAux, 3 ) } )
     	else
     		MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aPed, aAux, 3 ) 
     	endif 	
	
     	If lMsErroAuto                                                                                 
     		lErro := .t.
     		cMensErro := "Nao foi possível incluir NF "+(cTmp)->NF+", Serie "+(cTmp)->SERIE+", Fornec "+(cTmp)->D1_FORNECE+", da Filial "+_cFilial+chr(13)+chr(10)+MostraErro()   
     		cErros += cMensErro+chr(13)+chr(10)
		
     		if nOrigem == 1
     			//MostraErro()
				MessageBox( cMensErro, "Atenção", 48 ) 
     		else  
				FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', cMensErro, 0 )
			endif 
			dbselectarea(cTmp)
			loop
		else
			nContPed++
			_cPed := SC5->C5_NUM
			reclock("SC5",.F.)
			SC5->C5_APROVA = "1"
			msunlock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Liberar pedido                                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			U_fPedLib()
			/*
			if nContPed == 1    
				dbselectarea("SZA")
				dbsetorder(1)
	 		
				cCodBor := U_NumSeqLot("SZA", TamSx3("ZA_CODIGO")[1]) //GetSXENum("SZA", "ZA_CODIGO")
				dbselectarea("SZA")
				reclock("SZA",.t.)    
					SZA->ZA_FILIAL := xFilial("SZA")	 		
					SZA->ZA_CODIGO := cCodBor
					SZA->ZA_EMISSAO := date()
					SZA->ZA_DESCR := "REMESSAS SIMBOLICAS COMPRAS"	 		
				msunlock()
			endif      
		
			dbselectarea("SZB")
			reclock("SZB",.t.)
				SZB->ZB_FILIAL := xFilial("SZA")
				SZB->ZB_CODIGO := cCodBor
				SZB->ZB_PEDIDO := "01"+_cPed
			msunlock()		
			*/
		Endif
		dbselectarea(cTmp)
	enddo 

	dbselectarea(cTmp)
	dbCloseArea()


	if lErro        
		cCC      := "contabilidade@brasilux.com.br" //'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		/*
		cAuxMail := alltrim(UsrRetMail("000000"))
		if !(cPara == cAuxMail)
			cCC := cAuxMail
		endif 
		*/
		U_EnvMail("BRCOM013 - Erros Remessas Simbolicas",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
	endif 
		cTmp := U_NovoCursor()
		cQuery = "SELECT DISTINCT C6_NUM AS PEDIDO "+;
		"FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
		"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = C6_FILIAL) AND (C5_NUM = C6_NUM) "+;
		"WHERE (SC6.D_E_L_E_T_ <> '*') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C5_LIBEROK <> 'S') AND (C6_XREGD1D > 0.0) "+;
		"ORDER BY PEDIDO "
		TCQuery cQuery NEW ALIAS (cTmp) 
		dbselectarea(cTmp)
		dbgotop()
		do while !eof()
			dbselectarea("SC6")
			dbsetorder(1)
			dbseek(xFilial("SC6")+(cTmp)->PEDIDO,.f.)
			dbselectarea("SC5")
			dbsetorder(1)
			dbseek(xFilial("SC5")+(cTmp)->PEDIDO,.t.)
			if found()  
				IF SC5->C5_APROVA <> "1"
					reclock("SC5",.F.)
					SC5->C5_APROVA = "1"
					msunlock()
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Liberar pedido                                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					U_fPedLib()
				ENDIF
			endif
			dbselectarea(cTmp)
			dbskip()
		enddo 

	dbselectarea(cTmp)
	dbCloseArea()


     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg

	U_VoltaArea(aArea)

       IF nOrigem == 2
        /*** ADEQUAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "FIM da inclusão dos pedidos de remessa simbólica P/ depósito" + Time(), 0 )
        //RESET ENVIRONMENT
     ENDIF     	
Return

/**************************************************************************************/
/*** SCHERRO_1 - Tratamento dos erros ocorridos.                                     ***/
/**************************************************************************************/
STATIC Function SCHERRO_1(e)
       
       Local cAuxMens:=""
       
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
             cAuxMens := "*** Alias does not exist "+e:Operation
             FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
             Return
          Endif
       Endif
       //ConOut("   ***"+SCHERRO_2(e))
       __QUIT()
Return(Nil)
                               
/**************************************************************************************/
/*** SCHERRO_2 - Exibe a mensagem de erro na tela do server.                         ***/
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


