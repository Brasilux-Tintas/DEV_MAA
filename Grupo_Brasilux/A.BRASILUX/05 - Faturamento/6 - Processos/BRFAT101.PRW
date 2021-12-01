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
±±ºPrograma  ³ BRFAT101  ºAutor ³ Cleber O. Dominguesº Data ³  09/10/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para salvar pedidos que estão com o campo C5_DEPOSI º±±
±±º          ³ em branco. Pedidos que vêm do MasterSales de filiais dife- º±±
±±º          ³ rentes o ambiente é aberto apenas para Matriz e quando     º±±
±±º          ³ entra de uma vez pedidos misturados não identifica rentes o ambiente é aberto apenas para Matriz e quando     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT101() 
Local cMens1,_cGrpEmp,_cFilial,_cNumEmp

	_cGrpEmp := FWGrpCompany()
	_cFilial := FWCodFil()
	_cNumEmp := alltrim(_cGrpEmp)+alltrim(_cFilial)

	If _cGrpEmp != "01"
		MsgBox("Esta operação só pode ser executada na empresa 01-BRASILUX!", "Atenção!", "STOP")
		Return
	Endif 

     If !u_VldAcesso(funname())
        MessageBox( "Acesso não autorizado!---->" + FunName(), "Atenção", 48 )
        Return 
     Endif 
  
     If !(alltrim(_cNumEmp) == "01010101") .and. !(alltrim(_cNumEmp) == "01060101")
        cMens1 := "Acesso deverá ser feito na empresa Brasilux/Matriz ou Dissoltex!"
        MessageBox( cMens1, "Atenção", 48 )
        return
     Endif 
     u_zcfga01( 'BRFAT101' ) //LGS#2021130 - Gravação de log de utilização da rotina    

    @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Remarcação Dep. Fechado."

//     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
    @ 91,168 BMPBUTTON TYPE 1 ACTION Processa( {|lEnd| U_BRFT101(1)} )
    @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
    @ 23,016 SAY "Remarcação Dep. Fechado."
    @ 08,10 TO 84,222
    ACTIVATE DIALOG oDlg1 CENTERED

Return

User Function BRFT101(nOrigem)

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
		MsgRun("Processando...","Aguarde...",{|| FT101(nOrigem) } )
		Close(oDlg1)
	else
		aTables := {"SC5","SC6","SB1","SA2","SA1","SD1","SF1","SF2","SD2","SC9","SB2","SF4"} 
		for i := 1 to 2  
			_cFilial := iif(i == 1,"010101","060101")
			//Limpa o ambiente, liberando a licença e fechando as conexões
			//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
			RESET ENVIRONMENT
			RpcSetType(3) //seta tipo de consumo de licença

			//RpcSetEnv( "01",_cFilial,'Administrador' ,'851296' , "FAT" , , aTables, , , ,  )
			PREPARE ENVIRONMENT EMPRESA "01" FILIAL _cFilial MODULO "FAT" TABLES "SC5","SC6","SB1","SA2","SA1","SD1","SF1","SF2","SD2","SC9","SB2","SF4"
			
			bErro := {|e| SCHERRO_1(e)}    

			RpcMyErro()
			ErrorBlock(bErro)

			if !KillApp()
				FT101(nOrigem)
			endif 
		
			RESET ENVIRONMENT 
			//RpcClearEnv() //Limpa o ambiente, liberando a licença e fechando as conexões
		next 
//		FT101(nOrigem)
	endif
	 
return(nil)

Static Function FT101(nOrigem)
	Local aAux, aItens2,lSucesso, cAux 
	Local cTcq,cErros,lErro,cCC,cPara,cQuery
	Local cArqBloq, aBloq,_cAreaBloq,_cGrpEmp,_cFilial,_cNumEmp             
	Local aCab2 := {}
	Local nTam1
	Private lMsErroAuto
	Private lMsHelpAuto := .f.
	lErro = .f.



	_cGrpEmp := FWGrpCompany()
	_cFilial := FWCodFil()
	_cNumEmp := alltrim(_cGrpEmp)+alltrim(_cFilial)

// Verificar se tem alguém usando a rotina
	cArqBloq := "BRFAT101"+_cFilial //Cleber (13/02/20)  -> Reajuste da função  BloqProg
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

	cErros := ""
	lSucesso := .t.
                  


	cTcq := U_NovoCursor()
	cQuery := "SELECT C5_NUM AS PEDIDO FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+;
	"WHERE (D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_DEPOSI = '') AND "+;
	"(C5_EMISSAO >= '"+DTOS(dDatabase-5)+"')"
	TCQuery cQuery NEW ALIAS (cTcq)
	lSucesso := .t.

dbselectarea(cTcq)
dbgotop()
do while lSucesso .AND. !EOF() 
	_cPed := (cTcq)->PEDIDO

	dbselectarea("SC5")
	dbsetorder(1)
	dbseek(xFilial("SC5")+_cPed)
	if found()
		nTam1 := TamSX3("C6_PRCVEN")[2]
	 	_cFilial := ALLTRIM(SC5->C5_FILIAL)
		aCab2 := U_DetCposTab("SC5","C5_NUM-C5_FILIAL")
		aItens2 := {} 
		dbselectarea("SC6")
		dbsetorder(1)  
		dbseek(xFilial("SC6")+_cPed,.t.)
		do while lSucesso .and. !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == _cFilial) .AND. (alltrim(SC6->C6_NUM) == _cPed)
				
				aAux := U_DetCposTab("SC6","C6_FILIAL-C6_ITEM-C6_NUM-C6_BLOQUEI-C6_BLQ-C6_GEROUPV-C6_QTDEMP-C6_QTDEMP2-C6_QTDENT-C6_QTDENT2-C6_QTDLIB-C6_QTDLIB2-C6_QTDRESE-C6_SLDALIB-C6_SUGENTR-C6_TRT")
				aadd(aAux,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
				aadd(aAux,{"AUTDELETA","N",Nil})
				aadd(aItens2,aAux)		
				dbselectarea("SC6")
				dbskip()
		enddo 
		aadd(aCab2,{"C5_NUM"   ,_cPed,Nil}) 
		//aadd(aCab2,{"C5_RASTR"   ,"X_",Nil}) 
			 	
		lMsErroAuto := .f.
		lMsHelpAuto := .f.
		MsgRun("Remarcando dep fech... "+_cPed+"...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab2, aItens2, 4 ) } )
		If lMsErroAuto
            lSucesso := .f.
   			If nOrigem = 1
				 MostraErro()	
			else
				FwLogMSG( "WARN", , 'SIGAFAT', funname(), '', '01', "Erro alterar pedido "+_cPed, 0 )
			endif 

        Endif
	endif
	
	dbselectarea(cTcq)
	dbskip()
enddo 

dbselectarea(cTcq)
dbclosearea()

DbSelectArea(_cAreaBloq) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg



    IF nOrigem == 2
        FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', "FIM da Remarcação Dep. Fechado." + Time(), 0 )
     ENDIF 

	if !lSucesso
		cCC      := 'cleber@brasilux.com.br'
		cPara := alltrim(UsrRetMail(__cUserId))
		/*
		cAuxMail := alltrim(UsrRetMail("000000"))
		if !(cPara == cAuxMail)
			cCC := cAuxMail
		endif 
		*/
		U_EnvMail("BRFAT101 - Remarcação Dep. Fechado",cErros,cPara,cCC,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
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
                               

