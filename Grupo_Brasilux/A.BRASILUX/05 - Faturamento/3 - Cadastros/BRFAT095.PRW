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
±±ºPrograma  ³ BRFAT095  ºAutor ³ Cleber O. Dominguesº Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função gerar lctos de remessa simbólica das empresas para  º±±
±±º          ³ seu depósito fechado                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT095()  
private oDlg1

	if cNumEmp != "01010106" // "0106"
		MsgBox("Esta operação só pode ser executada no depósito!", "Atenção!", "STOP")
		return
	endif 

     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Gerar Pedidos Rem. Simbólica"

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
     @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_BRFT095(1)} )
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 23,016 SAY "Geração de pedidos de Remessa Simbólica."
     @ 08,10 TO 84,222
     ACTIVATE DIALOG oDlg1 CENTERED

Return

User Function BRFT095(nOrigem)
/* nOrigem:	1-Console
			2-Schedule
*/			
Local bErro
//Local aTables    := {"SC5","SC6","SC9","SB1","SB2","SA1","SA2","SF4","SD1"}  
Local cAuxMens  := ""
DEFAULT nOrigem := 2

if ValType(nOrigem) <> "N"
	nOrigem := 2
endif 


If nOrigem == 1                                                                
  
	MsgRun("Processando...","Aguarde...",{|| BRFT95(nOrigem) } )
	Close(oDlg1)

Else



	RESET ENVIRONMENT
	RpcSetType(3) //seta tipo de consumo de licença
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010106" MODULO "FAT" TABLES "SX2","SC5","SC6","SC9","SB1","SB2","SA1","SA2","SF4","SD1"

	//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
	//RpcSetType(3) //seta tipo de consumo de licença
	//RpcSetEnv( "01","010106",'Administrador' ,'843952' , "FAT" , , aTables, , , ,  )


    cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    cAuxMens += "-- INICIO INCLUSÃO DE PEDIDOS NO DEPÓSITO  - BRFAT095"+ CHR( 13 ) + CHR( 10 )
    cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )

   	//ConOut("-- INICIO INCLUSÃO DE PEDIDOS NO DEPÓSITO  - BRFAT095")

	bErro := {|e| SCHERRO_1(e)}    

  	//RpcMyErro()
	ErrorBlock(bErro)

	if !KillApp()
 		BRFT95(nOrigem)
 	endif 

    cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    cAuxMens += "-- FINAL DA INCLUSÃO DE PEDIDOS NO DEPÓSITO - BRFAT095"+ CHR( 13 ) + CHR( 10 )
    cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )

   	//ConOut("-- FINAL DA INCLUSÃO DE PEDIDOS NO DEPÓSITO - BRFAT095")
   	
   	RESET ENVIRONMENT
	
	//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões

Endif 


Return(nil)

Static Function BRFT95(nOrigem)

	Local cAux,cQuery,nSaldo,cItem,nQtde,nVlrUnit
	Local aPed, aPedRel, nQtdeItens, aItensPed,aAux,lErro,;
		cMensErro, aStrut, cObs,lSucesso,aArea,nOrdM0,cCgc,cErros,;
       	cCC,cPara,cAuxMail,nContPed,cCodBor,_cPed,nPreco,cTmp, cCliente
	Local cArqBloq, aBloq,_cAreaBloq             
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
 
	// DESABILITADO EM ADEQUAÇÃO DA RELEASE 12.1.25 AMAESTER

	// Verificar se tem alguém usando a rotina
	//cArqBloq := "FT95"+substr(cNumEmp,1,2)+xFilial("SC5")+".DTC"
	//aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })     
	//if file(cArqBloq)
	//	fErase(cArqBloq)
	//Endif              
	//_cAreaBloq := U_NovoCursor()
	//if file(cArqBloq)
	// 	Use (cArqBloq) Alias (_cAreaBloq) VIA "CTREECDX" New 
	// 	dbselectarea(_cAreaBloq)
	// 	if !eof() .and. !bof()  
	// 		cAux := "O programa já está sendo usado por: "+(_cAreaBloq)->usuario
	//		if nOrigem = 1
	//			MsgBox(cAux, "Atenção!", "STOP")
	//		else
	//			ConOut(cAux)
	//		endif 
	// 		dbclosearea()
	// 		return
	// 	endif
	//endif

// Verificar se tem alguém usando a rotina
	cArqBloq := "BRFAT095"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
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


/*
	If !Empty( Alltrim( GetMV( 'ZP_PAR0011' ) ) )
	   cAux := "O programa já está sendo usado por: " + Alltrim( GetMV( 'ZP_PAR0011' ) )
       If nOrigem == 1
          MessageBox( cAux, "Atenção!", 16 )
       Else
          FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', cAux, 0 )
       Endif
       Return
    Else
       PutMV( "ZP_PAR0011", Iif( nOrigem == 1, RTRIM( cUserName ), "AGENDAMENTO" ) )
    Endif
*/
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

    aStrut := {}
    aadd(aStrut,{"REGD1" , "C", 10, 0})     
    aadd(aStrut,{"QTDE"  , "N", 13, 4})
    // ADEQUAÇÃO DA RELEASE 12.1.25
    /*
    cArqTemp := U_NovoArqTrab("dtc") 
    dbcreate(cArqTemp+".dtc", aStrut, "CTREECDX")      
     
    cCursorTemp := U_NovoCursor()
    Use (cArqTemp+".dtc") Alias (cCursorTemp) VIA "CTREECDX" New Exclusive
    cKey01  := "REGD1"
    cInd01  := cArqTemp+"_1" //"SC"+SubStr(cNomArq, 8, 6)+"_1"
     
     
    DbCreateIndex(cInd01, cKey01, {||cKey01} )
    DbClearIndex()
    DbSetIndex(cInd01)
    */
     
    oTempTable := FWTemporaryTable():New( "TMP" )
    oTemptable:SetFields( aStrut )
    oTempTable:AddIndex( "cInd01", { "REGD1" } )
    oTempTable:Create()
    DbSelectArea( "TMP" )
    DbSetOrder(1)

    //DbSelectArea(cCursorTemp)
    //DbSetOrder(1)
     
    cTmp := U_NovoCursor()
     
    cQuery = "WITH TMP AS (SELECT DISTINCT D2_FILIAL AS FILIAL,D2_PEDIDO AS PEDIDO,D2_DOC AS NF,D2_SERIE AS SERIE "+;
    "FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
    "WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '010101') AND (D2_SERIE = '1') AND (D2_EMISSAO > '"+DTOS(dDataBase-31)+"') AND (D2_TIPO = 'N')) "+;
    "SELECT TMP.* FROM TMP "+;
    "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = FILIAL) AND (C5_NUM = PEDIDO) "+;
    "LEFT OUTER JOIN "+RetSqlName("SC5")+" C5DEP WITH (NOLOCK) ON (C5DEP.D_E_L_E_T_ <> '*') AND (C5DEP.C5_FILIAL = '010106') AND (SC5.C5_FILIAL = C5DEP.C5_FILDEP) AND (SC5.C5_NUM = C5DEP.C5_PEDDEP) "+;
    "WHERE (SC5.C5_DEPOSI = 'S') AND (C5DEP.R_E_C_N_O_ IS NULL) "+;
    "ORDER BY FILIAL,PEDIDO"
    TCQuery cQuery NEW ALIAS (cTmp)

    lSucesso := .t.
    nContPed := 0 
    dbselectarea(cTmp)
    dbgotop()
    do while lSucesso .and. !eof()     
     	aPed       := {}
     	aItensPed  := {} 
     	DbSelectArea ("SM0") 
     	nOrdM0 := IndexOrd() 
     	nRegM0 := recno()
	
     	dbsetorder(1)
     	SM0->(DbGoTop())
     	DbSeek(substr(cNumEmp,1,2)+(cTmp)->FILIAL, .f.)
     	if !found()
     		lSucesso := .f.                            
     		cMensErro := "Não encontrada a filial "+(cTmp)->FILIAL+" no cad. SM0!"
     		if nOrigem == 1
     			Messagebox(cMensErro, "Aviso", 48)  								
     		else
     			FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
     			//ConOut(cAuxMens)
     		endif 
     		dbsetorder(nOrdM0)
     		if nRegM0 > 0
     			dbgoto(nRegM0)
     		endif 
     		EXIT
     	ENDIF  
     	
     	cCgc := ALLTRIM(SM0->M0_cgc)
     	DbSelectArea ("SM0") 
     	dbsetorder(nOrdM0)
     	if nRegM0 > 0
     		dbgoto(nRegM0)
     	endif 

     	dbselectarea("SA2")
     	dbsetorder(3)
     	dbseek(xFilial("SA2")+cCgc)
     	cCliente := ""
     	do while lSucesso .and. !eof() .and. (SA2->A2_FILIAL == xFilial("SA2")) .AND. (alltrim(SA2->A2_CGC) == cCgc)
     		IF SA2->A2_MSBLQL <> "1"
     			cCliente := SA2->A2_COD
     			exit
     		endif
     		dbselectarea("SA2")
     		dbskip()
     	enddo 
     	if empty(cCliente)
     		lSucesso := .f.                            
     		cMensErro := "Não encontrada a empresa de CGC "+cCgc+" no cad. de Fornecedores!"
     		if nOrigem == 1
     			Messagebox(cMensErro, "Aviso", 48)  								
     		else
     			FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
     			//ConOut(cMensErro)
     		endif 
     		EXIT 
     	endif 
		
     	cObs = "Remessa Simbolica Ref. NF Origem nro "+(cTmp)->NF+iif(!empty((cTmp)->SERIE)," Serie "+(cTmp)->SERIE,"")
     	//ATENÇÃO! Ao incluir item, observar o seek em SC5 abaixo!!!!
     	aAdd(aPed, {"C5_TIPO"    , "B"                               , NIL})
     	aAdd(aPed, {"C5_FILDEP" , (cTmp)->FILIAL             , NIL})
     	aAdd(aPed, {"C5_PEDDEP"  ,  (cTmp)->PEDIDO             , NIL})
     	aAdd(aPed, {"C5_CLIENTE" , cCliente             , NIL})
     	aAdd(aPed, {"C5_CONDPAG" , "001"             , NIL})
     	aAdd(aPed, {"C5_EMISSAO" , dDataBase                         , NIL})
     	aAdd(aPed, {"C5_TRANSP"  , "00250"             , .F.})
     	aAdd(aPed, {"C5_REDESP"  , ""             , .F.})
     	aAdd(aPed, {"C5_TPFRETE" , "C"                               , NIL})       
     	aAdd(aPed, {"C5_DEPOSI"  , "S"                               , NIL})       
     	aAdd(aPed, {"C5_OBSNF"   , cObs, NIL})

     	dbselectarea("SD1")
     	dbsetorder(7) //D1_FILIAL+D1_COD+D1_LOCAL+DTOS(D1_DTDIGIT)+D1_NUMSEQ                                                                                                            
     	nQtdeItens := 0
     	dbselectarea("SC6")
     	dbsetorder(1)
     	dbseek((cTmp)->FILIAL+(cTmp)->PEDIDO,.t.)
     	do while lSucesso .and. !eof() .and. (alltrim(SC6->C6_FILIAL) == alltrim((cTmp)->FILIAL)) .AND.(alltrim(SC6->C6_NUM) == alltrim((cTmp)->PEDIDO))
     		nSaldo := SC6->C6_QTDVEN  
     		cItem := alltrim(SC6->C6_ITEM)
     		dbselectarea("SB1")
     		dbseek(xFilial("SB1")+SC6->C6_PRODUTO)
     		if !found()
     			lSucesso = .f.
     			lErro := .t.
     			cMensErro := "Produto "+SC6->C6_PRODUTO+" NÃO ENCONTRADO, Pedido Origem: "+(cTmp)->FILIAL+"-"+(cTmp)->PEDIDO
     			cErros += cMensErro+chr(13)+chr(10)
     			if nOrigem == 1
     				//MsgBox(cMensErro, "Aviso", "INFO")  								
     			else
     				FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
     				//ConOut(cMensErro)
     			endif 
     			exit 
     		endif 
     		//Desbloquear produto    
     		IF (SB1->B1_MSBLQL = "1") .OR. (SB1->B1_VEND = "N")
     			dbselectarea("SB1")
     			reclock("SB1",.F.)
     			SB1->B1_MSBLQL := "2"   
     			SB1->B1_VEND = "S"
     			msunlock()
     		ENDIF 
			
     		nQtde := nSaldo
     		nVlrUnit := U_CustoPro(SC6->C6_PRODUTO,(cTmp)->FILIAL)
     		nQtdeItens++ 
     		aPedRel := {}     
     		If nQtdeItens < 100
     			cAux = Alltrim(Str(nQtdeItens))
     			If Len(cAux) == 1
     				cAux = "0"+cAux
     			Endif
     		Else
     			cAux = Alltrim(Str(nQtdeItens))
     			cAux = SubStr(cAux, Len(cAux), 1)
     			cAux = Chr(Int((nQtdeItens - 100)/10)+65) + cAux
     		Endif  
		
     		dbselectarea("SB2")
     		dbsetorder(1)
     		dbseek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
     		if !found()
     			CriaSb2(SC6->C6_PRODUTO,SC6->C6_LOCAL)
     		endif  

     		aAdd(aPedRel, {"C6_ITEM"   , cAux                , Nil})
     		aadd(aPedRel, {"C6_PRODUTO", SC6->C6_PRODUTO     , NIL})
     		aadd(aPedRel, {"C6_LOCAL", SC6->C6_LOCAL     , NIL})
     		aadd(aPedRel, {"C6_QTDVEN" , nQtde, NIL})
     		nPreco := nVlrUnit
     		nAux := round(nQtde*nPreco,TamSx3("C6_VALOR")[2])
     		aadd(aPedRel, {"C6_PRCVEN" , nPreco , NIL})
     		aadd(aPedRel, {"C6_TES"    , "828", NIL})
     		aadd(aItensPed, aPedRel)       

     		dbselectarea("SC6")
     		dbskip()
     	enddo 
		
     	if !lSucesso
     		exit
     	endif 

     	dbselectarea("SC6")   
     	dbsetorder(1)
     	dbseek(xFilial("SC6"))
     	if (nQtdeItens == 0) // Não pode incluir se não existem itens  
     		cMensErro := "Pedido "+(cTmp)->PEDIDO+" da Filial "+(cTmp)->FILIAL+" ESTÁ VAZIO!!!"    
     		lErro := .t.
     		cErros += cMensErro+chr(13)+chr(10)
     		if nOrigem == 1
     			//MsgBox(cMensErro, "Aviso", "INFO")  								
     		else
     			FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
     			//ConOut(cMensErro)
     		endif 

     		dbselectarea(cTmp)
     		dbskip()
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
     		cMensErro := "Nao foi possível incluir pedido "+(cTmp)->PEDIDO+" da Filial "+(cTmp)->FILIAL+chr(13)+chr(10)+MostraErro()   
     		cErros += cMensErro+chr(13)+chr(10)
		
//     		if nOrigem == 1
//     			MostraErro()
//     		else  
			FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
//				ConOut(cMensErro)
//			endif 
			dbselectarea(cTmp)
			dbskip()
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
			if nContPed == 1    
				dbselectarea("SZA")
				dbsetorder(1)
	 		
				cCodBor := U_NumSeqLot("SZA", TamSx3("ZA_CODIGO")[1]) //GetSXENum("SZA", "ZA_CODIGO")
				dbselectarea("SZA")
				reclock("SZA",.t.)    
					SZA->ZA_FILIAL := xFilial("SZA")	 		
					SZA->ZA_CODIGO := cCodBor
					SZA->ZA_EMISSAO := date()
					SZA->ZA_DESCR := "REMESSAS SIMBOLICAS DEPOSITO"	 		
				msunlock()
			endif      
		
			dbselectarea("SZB")
			reclock("SZB",.t.)
				SZB->ZB_FILIAL := xFilial("SZA")
				SZB->ZB_CODIGO := cCodBor
				SZB->ZB_PEDIDO := "01"+_cPed
			msunlock()		
		
		Endif
		dbselectarea(cTmp)
		dbskip()     
	enddo 

	dbselectarea(cTmp)
	dbCloseArea()

	dbselectarea("TMP")
	dbclosearea()     
/*
	aEval(Directory("tmp*.dtc"), { |aFile| FERASE(aFile[F_NAME]) })     
	aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })      
*/
	if lErro        
		cCC      := 'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		/*
		cAuxMail := alltrim(UsrRetMail("000000"))
		if !(cPara == cAuxMail)
			cCC := cAuxMail
		endif 
		*/
		U_EnvMail("BRFAT095 - Erros Remessas Simbolicas",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
	endif 
		cTmp := U_NovoCursor()
		cQuery = "SELECT C5_NUM AS PEDIDO FROM "+Retsqlname("SC5")+" SC5 WITH (NOLOCK) "+;
		"WHERE (D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_LIBEROK <> 'S') AND (C5_DEPOSI = 'S') AND (C5_PEDDEP > '') "+;
		"ORDER BY C5_NUM"
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
				reclock("SC5",.F.)
					SC5->C5_APROVA = "1"
				msunlock()
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Liberar pedido                                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				U_fPedLib()
			endif
			dbselectarea(cTmp)
			dbskip()
		enddo 

	dbselectarea(cTmp)
	dbCloseArea()

	
//	PutMV( "ZP_PAR0011", '' )

    IF nOrigem == 2
        /*** ADEQUAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "FIM da inclusão dos pedidos de remessa simbólica no depósito" + Time(), 0 )
        //RESET ENVIRONMENT
     ENDIF 
     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg

	U_VoltaArea(aArea)
       	
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


