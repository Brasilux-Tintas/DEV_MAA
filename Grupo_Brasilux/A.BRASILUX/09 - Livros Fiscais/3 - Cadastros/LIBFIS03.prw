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
±±ºPrograma  ³ LIBFIS03  ºAutor ³ Cleber Orati       º Data ³  30/07/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar lctos para bloco C113 do Sped FISCAL. Necessário dar º±±
±±º          ³ entrada na nota de venda com saída pelo dep. fechado para  º±±
±±º          ³ referenciar a chave na nota de remessa simbólica .         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA-> Depósito Fechado           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function LIBFIS03()  
private oDlg1

	if cNumEmp != "01010106" // "0106"
		MsgBox("Esta operação só pode ser executada no depósito!", "Atenção!", "STOP")
		return
	endif 
     u_zcfga01( 'LIBFIS03' ) //LGS#2021201 - Gravação de log de utilização da rotina
     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Referenciar NFs p/ Bloco C113 Sped" //"Gerar Pedidos Rem. Simbólica"

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
     @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_LBFIS03(1)} )
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 23,016 SAY "Referenciar NFs p/ Bloco C113 Sped"
     @ 08,10 TO 84,222
     ACTIVATE DIALOG oDlg1 CENTERED

Return

User Function LBFIS03(nOrigem)
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
  
	MsgRun("Processando...","Aguarde...",{|| LBFI03(nOrigem) } )
	Close(oDlg1)

Else



	RESET ENVIRONMENT
	RpcSetType(3) //seta tipo de consumo de licença
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010106" MODULO "FIS" TABLES "SX2","SC5","SC6","SC9","SB1","SB2","SA1","SA2","SF4","SD1","SF2","SD2","SD1","SF1","SF3","SFT"

	//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
	//RpcSetType(3) //seta tipo de consumo de licença

    cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    cAuxMens += "-- INICIO INCLUSÃO DE NFS BLOCO C113 SPED NO DEPÓSITO  - LIBFIS03"+ CHR( 13 ) + CHR( 10 )
    cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )


	bErro := {|e| SCHERRO_1(e)}    

  	//RpcMyErro()
	ErrorBlock(bErro)

	if !KillApp()
 		LBFI03(nOrigem)
 	endif 

    cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    cAuxMens += "-- FINAL DA INCLUSÃO DE NFS BLOCO C113 SPED NO DEPÓSITO  - LIBFIS03"+ CHR( 13 ) + CHR( 10 )
    cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
    FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )

   	//ConOut("-- FINAL DA INCLUSÃO DE PEDIDOS NO DEPÓSITO - BRFAT095")
   	
   	RESET ENVIRONMENT
	
	//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões

Endif 


Return(nil)

Static Function LBFI03(nOrigem)
Local _cData,cAux,cQuery,cErros,lErro,_aArea
Local aPed, aPedRel, aItensPed, nQtdeItens, lSucesso, cMensErro 
Local _cDoc,_cSerie, _cFornec, cTcq,cMens,cCC,cPara
Local cArqBloq, aBloq,_cAreaBloq,_cLoja             
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

/*
	Local nSaldo,cItem,nQtde,nVlrUnit
	Local aPed, aPedRel, nQtdeItens, aItensPed,aAux,lErro,;
		cMensErro, aStrut, cObs,lSucesso,aArea,nOrdM0,cCgc,cErros,;
       	cCC,cPara,cAuxMail,nContPed,cCodBor,_cPed,nPreco,cTmp, cCliente
	Local cArqBloq, aBloq,_cAreaBloq             
    Private INCLUI := .f.
    Private ALTERA := .t.
    Private lSugere := .f.
    Private oTempTable
    Private aCols , aHeadGrade, aColsGrade, aHeader
*/
	_aArea := U_PegaArea({"SM0","SD1","SF1","SA2","SA1","SA3","SB2","SB1","SC5","SC6"})
	lErro := .f.
	cErros := ""
 

// Verificar se tem alguém usando a rotina
	cArqBloq := "LIBFIS03"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
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

    //Pegar mês anterior
    /*
    nAno := year(dDataBase)
    nMes := month(dDataBase) - 1
    if nMes == 0
        nMes := 12
        nAno := nAno - 1
    endif
    cMes := substr(dtos(ctod("01"+"/"+strzero(nMes,2)+"/"+strzero(nAno,4))),1,6)
    */
    _cData := dtos(dDataBase - 50)
    _cFornec := "00354"


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
    //DbSelectArea(cCursorTemp)
    //DbSetOrder(1)
IF nOrigem = 1
    ProcRegua( 100 )
ENDIF  
    cTcq := U_NovoCursor()
 /*
    cQuery := "SELECT DISTINCT F2_SERIE AS SERIE,F2_DOC AS NRONF,F2_CHVNFE AS CHAVE, "+;
    "F2_EMISSAO,F2_VALBRUT,D2DEP.D2_SERIE AS SERIEO,D2DEP.D2_DOC AS NFO "+;
    "FROM "+RetSqlName("SD2")+" D2DEP WITH (NOLOCK) "+;
    "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = D2_FILIAL) AND (C5_NUM = D2_PEDIDO) "+;
    "LEFT OUTER JOIN "+RetSqlName("SD2")+" D2MAT WITH (NOLOCK) ON (D2MAT.D_E_L_E_T_ <> '*') AND (D2MAT.D2_FILIAL = C5_FILDEP) AND (D2MAT.D2_PEDIDO = C5_PEDDEP) "+;
    "LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2MAT.D2_FILIAL) AND (F2_SERIE = D2MAT.D2_SERIE) AND (F2_DOC = D2MAT.D2_DOC) "+;
    "WHERE (D2DEP.D_E_L_E_T_ <> '*') AND (D2DEP.D2_FILIAL = '"+xFilial("SD2")+"') AND (C5_PEDDEP > '') AND (SF2.R_E_C_N_O_ IS NOT NULL) AND "+;
    "(D2DEP.D2_EMISSAO LIKE '"+cMes+"%') ORDER BY SERIE,NRONF "
    */
//(SF1.R_E_C_N_O_ IS NULL) AND 
//    "LEFT OUTER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON (SF1.D_E_L_E_T_ <> '*') AND (F1_FORNECE = '00354') AND (F1_FILIAL = D2DEP.D2_FILIAL) AND (F1_SERIE = F2_SERIE) AND (F1_DOC = F2_DOC) "+;

cQuery := "WITH TMP AS (SELECT DISTINCT D2_DOC AS NFO,D2_SERIE AS SERIEO,C5_PEDDEP AS PEDIDO,C5_FILDEP AS FILDEP "+;
"FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "+;
"LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = D2_FILIAL) AND (C5_NUM = D2_PEDIDO) "+;
"WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+xFilial("SD2")+"') AND (C5_PEDDEP > '') AND (C5_FILDEP > '') AND (D2_EMISSAO >= '"+_cData+"')) "+;
"SELECT DISTINCT TMP.*,F2_SERIE AS SERIE,F2_DOC AS NRONF,F2_CHVNFE AS CHAVE,F2_EMISSAO,F2_VALBRUT "+;
"FROM TMP "+;
"LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = FILDEP) AND (D2_PEDIDO = PEDIDO) "+;
"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = D2_FILIAL) AND (F2_SERIE = D2_SERIE) AND (F2_DOC = D2_DOC) AND (F2_CLIENTE = D2_CLIENTE) AND (F2_LOJA = D2_LOJA) "+;
"WHERE SF2.R_E_C_N_O_ IS NOT NULL "+;
"ORDER BY SERIE,NRONF"

	TCQuery cQuery NEW ALIAS (cTcq)
	lSucesso := .t.
	dbselectarea(cTcq)
	dbgotop()
	do while lSucesso .and. !eof()       
		aPed       := {}
		aItensPed  := {} 
		_cDoc := (cTcq)->NRONF
		_cSerie := (cTcq)->SERIE 
        lMsErroAuto := .f.
        lMsHelpAuto := .T.
		

		dbselectarea("SA2")	
		dbsetorder(1)
		dbseek(xFilial("SA2")+_cFornec,.t.)
		if !found()
			lSucesso := .f.
			cMensErro := "Nao foi possível incluir NF "+_cDoc+"/"+_cSerie+". Nao encontrado o Fornecedor "+_cFornec+"!!"   
			cErros += cMensErro+chr(13)+chr(10)
			lErro := .t.
			if nOrigem == 1
				Alert(cMensErro)
			else  
				FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
				//ConOut(cMensErro)
			endif 
			exit 			
		endif
		_cLoja := SA2->A2_LOJA 	
		Begin Transaction

        dbselectarea("SF1")	
        dbsetorder(1)	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
        dbseek(xFilial("SF1")+padr(_cDoc,TamSx3("F1_DOC")[1]," ")+padr(_cSerie,TamSx3("F1_SERIE")[1]," ")+SA2->A2_COD+SA2->A2_LOJA+"N")
        IF !found()
            aAdd(aPed, {"F1_TIPO"    , "N" })
            aAdd(aPed, {"F1_FORMUL"    , "N"})
            aAdd(aPed, {"F1_DOC"    , _cDoc})
            aAdd(aPed, {"F1_SERIE"    , _cSerie})
            aAdd(aPed, {"F1_EMISSAO"    , ctod(substr((cTcq)->F2_EMISSAO,7,2)+"/"+substr((cTcq)->F2_EMISSAO,5,2)+"/"+substr((cTcq)->F2_EMISSAO,1,4))})
            aAdd(aPed, {"F1_FORNECE"    , SA2->A2_COD})
            aadd(aPed, {"F1_LOJA"   , SA2->A2_LOJA})
            aadd(aPed, {"F1_EST"   , SA2->A2_EST})
            aAdd(aPed, {"F1_ESPECIE"    , "SPED"})   
            aAdd(aPed, {"F1_CHVNFE"    ,  (cTcq)->CHAVE})   

			dbselectarea("SB1")
			dbsetorder(1)
			dbseek(xFilial("SB1")+"ZZP500")
			if found() .and. (SB1->B1_MSBLQL = "1")
				cQuery := "INSERT INTO PRODBLOQ (FILIAL,PRODUTO,PROGRAMA) VALUES (SELECT '"+xFilial("SB1")+"','"+SB1->B1_COD+"','LIBFIS03')
				TCSqlExec(cQuery)
				reclock("SB1",.F.)
				SB1->B1_MSBLQL := "2"
				msunlock()
			endif 
				
			nQtdeItens++ 
			aPedRel := {}   
			aAdd(aPedRel, {"D1_COD"     , "ZZP500"                  , Nil})
			aAdd(aPedRel, {"D1_QUANT"   , 1                         , Nil})
			aAdd(aPedRel, {"D1_VUNIT"   , (cTcq)->F2_VALBRUT        , Nil})
			aAdd(aPedRel, {"D1_TOTAL"   , (cTcq)->F2_VALBRUT        , Nil})
			aAdd(aPedRel, {"D1_TES"     , "265"                     , Nil})
			aAdd(aPedRel, {"D1_CLASFIS" , '000'      , Nil})
			aadd(aItensPed, aPedRel)
		
            DbSelectArea("SF1")     
            cMens := "Incluindo NF "+_cDoc+"..."		

            if nOrigem == 1           
                MsgRun(cMens, "Aguarde", {|| MsExecAuto( { |x, y| MATA103(x, y) }, aPed, aItensPed ) } )
            else
                //Conout(cMens)
                FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMens, 0 )
                MsExecAuto( { |x, y| MATA103(x, y) }, aPed, aItensPed) 
            endif 	

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
            Endif 
        Endif
        If !lMsErroAuto 
            cMens := "Incluindo Complemento NF "+_cDoc+"..."		

            if nOrigem == 1           
                IncProc(cMens) 
            else
                //Conout(cMens)
                FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', cMens, 0 )
            endif 	

            dbselectarea("CDD")
            dbsetorder(1) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF                                                          
            dbseek(xFilial("CDD")+"S"+padr((cTcq)->NFO,TamSx3("CDD_DOC")[1]," ")+padr((cTcq)->SERIEO,TamSx3("CDD_SERIE")[1]," ")+padr(_cFornec,TamSx3("CDD_CLIFOR")[1]," ")+_cLoja+padr(_cDoc,TamSx3("CDD_DOCREF")[1]," ")+padr(_cSerie,TamSx3("CDD_SERREF")[1]," ")+padr(_cFornec,TamSx3("CDD_PARREF")[1]," ")+_cLoja)
            if !found() 
			    reclock("CDD",.T.)
                CDD->CDD_FILIAL := xFilial("CDD")
                CDD->CDD_TPMOV := "S"
                CDD->CDD_DOC := (cTcq)->NFO 
                CDD->CDD_SERIE := (cTcq)->SERIEO
                CDD->CDD_CLIFOR := _cFornec
                CDD->CDD_LOJA := _cLoja
                CDD->CDD_DOCREF := _cDoc
                CDD->CDD_SERREF := _cSerie
                CDD->CDD_PARREF := _cFornec
                CDD->CDD_LOJREF := _cLoja
                CDD->CDD_IFCOMP := "000043"
                CDD->CDD_CHVNFE := (cTcq)->CHAVE
                CDD->CDD_SDOC := (cTcq)->SERIEO
                CDD->CDD_SDOCRF := _cSerie
                CDD->CDD_ENTSAI := "1"
            else
                reclock("CDD",.f.)
                CDD->CDD_IFCOMP := "000043"
                CDD->CDD_CHVNFE := (cTcq)->CHAVE
                CDD->CDD_SDOC := (cTcq)->SERIEO
                CDD->CDD_SDOCRF := _cSerie
                CDD->CDD_ENTSAI := "1"
            endif 


			msunlock()
            
		Endif
        End Transaction
		dbselectarea(cTcq)
        dbskip()
	enddo 

	dbselectarea(cTcq)
	dbCloseArea()

     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg


    IF nOrigem == 2
        /*** ADEQUAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "FIM da geração do bloco C113" + Time(), 0 )
     ENDIF 

	cQuery := "UPDATE "+RetSqlName("SB1")+" SET B1_MSBLQL = '1' FROM PRODBLOQ "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = PRODBLOQ.FILIAL) AND (B1_COD = PRODBLOQ.PRODUTO) "+;
	"WHERE (PRODBLOQ.PROGRAMA = 'LIBFIS03') ; "+;
	"DELETE FROM PRODBLOQ WHERE PROGRAMA = 'LIBFIS03'"
	TCSqlExec(cQuery)


	if lErro        
		cCC      := 'contabilidade@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		U_EnvMail("LIBFIS03 - Erros Geração Bloco C113",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
	endif 

    IF nOrigem == 2
        /*** ADEQUAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "FIM da GERAÇÃO BLOCO C113" + Time(), 0 )
        RESET ENVIRONMENT
     ENDIF 
     
	U_VoltaArea(_aArea)
       	
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


