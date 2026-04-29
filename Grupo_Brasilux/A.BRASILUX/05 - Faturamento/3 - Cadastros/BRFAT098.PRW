#include "protheus.ch"
#include 'tbiconn.ch'
#include "rwmake.ch"
#include "topconn.ch"
#include 'DIRECTRY.CH'       
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRFAT098  บAutor ณ Cleber O. Dominguesบ Data ณ  04/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo incluir notas de entrada ref. a transfer๊ncias      บฑฑ
ฑฑบ          ณ da Matriz que foram bipadas no dep๓sito                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TECNICAS LTDA                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRFAT098() 
	if substr(cNumEmp,1,2) != "01"
		MsgBox("Esta opera็ใo s๓ pode ser executada na empresa 01-BRASILUX!", "Aten็ใo!", "STOP")
		return
	endif 

	if !(cNumEmp $ "01010106-01010107") //
		MsgBox("Esta opera็ใo SOMENTE pode ser executada no dep๓sito!", "Aten็ใo!", "STOP")
		return
	endif 
     u_zcfga01( 'BRFAT098' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Entradas de NF Transfer๊ncia"

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
     @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_BRFT098(1)} )
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 23,016 SAY "Inclusใo de NF Entrada de Transfer๊ncias."
     @ 08,10 TO 84,222
     ACTIVATE DIALOG oDlg1 CENTERED


Return

User Function BRFT098(nOrigem)
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
	MsgRun("Processando...","Aguarde...",{|| BRFT98(nOrigem) } )
	Close(oDlg1)
else
	aTables := {"SC5","SC6","SB1","SA2","SA1","SD1","SF1","SF2","SD2","SZY","SB2","SF4"} 
	for i := 1 to 2  
		_cFilial := iif(i == 1,"010106","010107")
		RpcClearEnv() //Limpa o ambiente, liberando a licen็a e fechando as conex๕es
		RpcSetType(3) //seta tipo de consumo de licen็a

		PREPARE ENVIRONMENT EMPRESA "01" FILIAL _cFilial MODULO "COM" TABLES "SC7","SD1","SB1","SA2","SD1","SF1","SZY","SB2","SF4"

		bErro := {|e| SCHERRO_1(e)}    

  		RpcMyErro()
		ErrorBlock(bErro)

		if !KillApp()
 			BRFT98(nOrigem)
 		endif 
		RpcClearEnv() //Limpa o ambiente, liberando a licen็a e fechando as conex๕es
	next 
endif 
return(nil)

Static Function BRFT98(nOrigem)
	Local aPed, aPedRel, aItensPed, nQtdeItens, lSucesso, cAux, cMensErro, cQuery
	Local cTcq,cMens,cErros,lErro,cCC,cPara,cAuxMail,aArea,cCgc,nReg             
	Local cArqBloq, aBloq,_cAreaBloq,nRegM0            
	Private lMsErroAuto
	Private lMsHelpAuto := .f.
	aArea := U_PegaArea({"SM0","SD1","SF1","SA2","SA1","SA3","SB2","SB1","SC5","SC6"})
	dbselectarea("SM0")
	nRegM0 := 0
	if !eof() .and. !bof()
		nRegM0 := recno()
	endif 
	lErro = .f.

// Verificar se tem algu้m usando a rotina
	cArqBloq := "BRFAT098"+Substr(ALLTRIM(cNumEmp),3,6) //Cleber (13/02/20)  -> Reajuste da fun็ใo  BloqProg
	aBloq := U_BloqProg(cArqBloq) //Retorna matriz com primeira coluna verdadeiro ou falso se tแ bloqueado e segunda coluna com nome de quem estแ bloqueando ou nome da แrea de trabalho gerada
   	if aBloq[1,1] //Jแ estava bloqueado?
   		cAux := "O programa jแ estแ sendo usado por: "+aBloq[1,2]
   		If nOrigem = 1
			Messagebox(cAux,"Aten็ใo!",48) 		
		else
			FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', cAux, 0 )
		endif 
		Return
	endif

	_cAreaBloq := aBloq[1,4]


/*
	If !Empty( Alltrim( GetMV( 'ZP_PAR0013' ) ) )
	   cAux := "O programa jแ estแ sendo usado por: " + Alltrim( GetMV( 'ZP_PAR0013' ) )
       If nOrigem == 1
          MessageBox( cAux, "Aten็ใo!", 16 )
       Else
          FwLogMSG( "WARN", , 'SIGACOM', funname(), '', '01', cAux, {} )
       Endif
       Return
    Else
       PutMV( "ZP_PAR0013", Iif( nOrigem == 1, RTRIM( cUserName ), "AGENDAMENTO" ) )
    Endif
*/

    cErros := ""
	lErro := .f.
                  
	cTcq := U_NovoCursor()
	cQuery := "WITH TMP AS (SELECT DISTINCT Z14_RECNO AS REG "+;
	"FROM "+RetSqlName("Z14")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (Z14_PROCES = 'F') AND (Z14_OPERAC = 'CONFDEP')) "+;
	"SELECT TMP.REG,SF2.D_E_L_E_T_ AS DELF2,F2_FILIAL AS FILIAL,F2_SERIE,F2_DOC,D2_ITEM,F2_EMISSAO,F2_CGC,"+;
	"D2_COD,D2_QUANT,D2_PRCVEN,D2_TOTAL,F2_CLIENTE,F2_CHVNFE,D2_CLASFIS AS CST "+;
	"FROM TMP "+;
	"LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (TMP.REG = SF2.R_E_C_N_O_) "+;
	"LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = F2_FILIAL) AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "+;
	"WHERE (TMP.REG IS NOT NULL) "+;
	"ORDER BY REG,FILIAL,F2_CLIENTE,F2_SERIE,F2_DOC,D2_ITEM"

	TCQuery cQuery NEW ALIAS (cTcq)
	lSucesso := .t.
	dbselectarea(cTcq)
	dbgotop()
	do while lSucesso .and. !eof()   
		nReg := (cTcq)->REG
		IF empty((cTcq)->DELF2)
			dbselectarea("SM0")
			dbsetorder(1)
			dbseek(cNumEmp)
			if !found()    
				lSucesso := .f.
				cMensErro := "Nใo encontrada a empresa "+cnumemp
				if nOrigem == 1
					Alert(cMensErro)
				else  
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
					//ConOut(cMensErro)
				endif     
				exit 
			endif     
			if nRegM0 > 0
				dbselectarea("SM0")
				dbgoto(nRegM0)
			endif 
	
			if !(ALLTRIM(SM0->M0_CGC) == ALLTRIM((cTcq)->F2_CGC))
				//Nota nใo ้ destinada เ empresa corrente
				dbselectarea(cTcq)                       
				dbskip()
				loop
			endif 
	
			dbselectarea("SM0")
			dbseek(substr(cNumEmp,1,2)+(cTcq)->FILIAL)
			if !found() 
				lSucesso := .f.
				cMensErro := "Nใo encontrada a filial "+(cTcq)->FILIAL
				if nOrigem == 1
					Alert(cMensErro)
				else  
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
					//ConOut(cMensErro)
				endif     
				exit 
			endif     
	          
			cCgc := alltrim(SM0->M0_CGC)
			if nRegM0 > 0
				dbselectarea("SM0")
				dbgoto(nRegM0)
			endif 
		
			aPed       := {}
			aItensPed  := {} 

			dbselectarea("SA2")	
			dbsetorder(3)
			dbseek(xFilial("SA2")+cCgc,.t.)
			do while lSucesso .and. !eof() .and. (SA2->A2_FILIAL == xFilial("SA2")) .AND. (ALLTRIM(SA2->A2_CGC) == cCgc) .AND. (SA2->A2_MSBLQL = "1")
				dbskip()
			enddo
			IF EOF() .OR. (!EOF() .AND. !(ALLTRIM(SA2->A2_CGC) == cCgc))
				lSucesso := .f.
				lErro := .t.
				cMensErro := "Nใo encontrado o CGC "+cCgc+" no cadastro de Fornecedores!"
				if nOrigem == 1
					Alert(cMensErro)
				else  
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
					//ConOut(cMensErro)
				endif     
				exit 
			endif    
		
			dbselectarea("SF1") 
			dbsetorder(1)  //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
			dbseek(xFilial("SF1")+PADL(ALLTRIM((cTcq)->F2_DOC),9,"0")+PADR(ALLTRIM((cTcq)->F2_SERIE),3," ")+SA2->A2_COD+SA2->A2_LOJA+"N")
			if found()  //Nota fiscal jแ cadastrada!!!                                                                                   
				//Conout("Nota fiscal "+(cTcq)->F2_DOC+" jแ cadastrada!!! ")
				cMensErro := "Nota fiscal "+(cTcq)->F2_DOC+" jแ cadastrada!!! "
				if nOrigem == 1           
					Alert(cMensErro)
				else
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
				endif 
				dbselectarea(cTcq)
				do while lSucesso .and. !eof() .and. ((cTcq)->REG == nReg)
					dbskip()
				enddo
			else 
	
				aAdd(aPed, {"F1_TIPO"      , "N" })
				aAdd(aPed, {"F1_FORMUL"    , "N"})
				aAdd(aPed, {"F1_DOC"       , PADL(ALLTRIM((cTcq)->F2_DOC),9,"0")})
				aAdd(aPed, {"F1_SERIE"     , (cTcq)->F2_SERIE})
				aAdd(aPed, {"F1_EMISSAO"   , ctod(substr((cTcq)->F2_EMISSAO,7,2)+"/"+substr((cTcq)->F2_EMISSAO,5,2)+"/"+substr((cTcq)->F2_EMISSAO,1,4))})
				aAdd(aPed, {"F1_FORNECE"   , SA2->A2_COD})
				aadd(aPed, {"F1_LOJA"      , SA2->A2_LOJA})
				aadd(aPed, {"F1_EST"       , SA2->A2_EST})
				//aadd(aPed, {"F1_COND","001"})
				aAdd(aPed, {"F1_ESPECIE"   , "SPED"})   
				aAdd(aPed, {"F1_CHVNFE"    ,  (cTcq)->F2_CHVNFE})   

				dbselectarea(cTcq)
				do while lSucesso .and. !eof() .and. ((cTcq)->REG == nReg)
					dbselectarea("SB1")
					dbsetorder(1)
					dbseek(xFilial("SB1")+(cTcq)->D2_COD)
					if found() .and. (SB1->B1_MSBLQL = "1")
						cQuery := "INSERT INTO PRODBLOQ (FILIAL,PRODUTO,PROGRAMA) VALUES (SELECT '"+xFilial("SB1")+"','"+SB1->B1_COD+"','BRFAT098')
						TCSqlExec(cQuery)
						reclock("SB1",.F.)
							SB1->B1_MSBLQL := "2"
						msunlock()
					endif 
				
					nQtdeItens++ 
					aPedRel := {}   
					aAdd(aPedRel, {"D1_COD"     , (cTcq)->D2_COD        , Nil})
					aAdd(aPedRel, {"D1_QUANT"   , (cTcq)->D2_QUANT      , Nil})
					aAdd(aPedRel, {"D1_VUNIT"   , (cTcq)->D2_PRCVEN     , Nil})
					aAdd(aPedRel, {"D1_TOTAL"   , (cTcq)->D2_TOTAL      , Nil})
					aAdd(aPedRel, {"D1_TES"     , "227"                 , Nil})
					aAdd(aPedRel, {"D1_CLASFIS" , (cTcq)->CST           , Nil})
					aadd(aItensPed, aPedRel)
					
					dbselectarea(cTcq)
					dbskip()
				enddo 
		
				lMsErroAuto := .f.
				lMsHelpAuto := .T.
				cMens := "Incluindo NF "+aPed[3,2]+"..."		
				DbSelectArea("SF1")     
				if nOrigem == 1           
					MsgRun(cMens, "Aguarde", {|| MsExecAuto( { |x, y| MATA103(x, y) }, aPed, aItensPed ) } )
				else
					FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMens, 0 )
					//Conout(cMens)
					MsExecAuto( { |x, y| MATA103(x, y) }, aPed, aItensPed) 
				endif 	
			
				If lMsErroAuto   
					cMensErro := "Nao foi possํvel incluir NF "+aPed[3,2]+chr(13)+chr(10)+MostraErro()   
					cErros += cMensErro+chr(13)+chr(10)
					lErro := .t.
					if nOrigem == 1
//						MsgBox(cMensErro, "Aten็ใo!", "STOP")
  //					MostraErro()
  					else  
  						FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cMensErro, 0 )
  						//ConOut(cMensErro)
  					endif  
  				Endif
  			endif 
  		else //IF empty((cTcq)->DELF2)
  			dbselectarea(cTcq)
  			do while lSucesso .and. !eof() .and. ((cTcq)->REG == nReg)
  				dbskip()
  			enddo
  		endif 
  		if lSucesso .and. !lErro
  			cQuery := "UPDATE "+RetSqlName("Z14")+" SET Z14_PROCES = 'T' WHERE "+;
  			"(D_E_L_E_T_ <> '*') AND (Z14_PROCES = 'F') AND (Z14_OPERAC = 'CONFDEP') AND (Z14_RECNO = "+ALLTRIM(STR(nReg))+")"
  			TCSqlExec(cQuery)
  		endif 
  		dbselectarea(cTcq)
  	enddo 

  	dbselectarea(cTcq)
  	dbCloseArea()

     DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da fun็ใo  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da fun็ใo  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da fun็ใo  BloqProg

//	PutMV( "ZP_PAR0013", '' ) //Cleber (13/02/20)  -> Reajuste da fun็ใo  BloqProg

    IF nOrigem == 2
        /*** ADEQUAวรO DE RELEASE PROTHEUS 12.1.25 ***/
        FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "FIM da inclusใo das notas de transfer๊ncia para o dep๓sito fechado" + Time(), 0 )
        RESET ENVIRONMENT
    ENDIF 


	cQuery := "UPDATE "+RetSqlName("SB1")+" SET B1_MSBLQL = '1' FROM PRODBLOQ "+;
	"LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = PRODBLOQ.FILIAL) AND (B1_COD = PRODBLOQ.PRODUTO) "+;
	"WHERE (PRODBLOQ.PROGRAMA = 'BRFAT098') ; "+;
	"DELETE FROM PRODBLOQ WHERE PROGRAMA = 'BRFAT098'"
	TCSqlExec(cQuery)


	if lErro        
		cCC      := ''
		cPara := alltrim(UsrRetMail(__cUserId))
		cAuxMail := alltrim(UsrRetMail("000000"))
		if !(cPara == cAuxMail)
			cCC := cAuxMail
		endif 
		U_EnvMail("BRFAT098 - Erros Entradas Transf. Dep๓sito",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
	endif 

	U_VoltaArea(aArea)
       	
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
                 cMensErro := "*** Alias does not exist "+e:Operation
                 //ConOut("   *** Alias does not exist "+e:Operation)
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
