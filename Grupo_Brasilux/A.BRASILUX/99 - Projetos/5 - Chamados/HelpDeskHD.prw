#include "rwmake.ch"
#include "ap5mail.ch"
#Include "PROTHEUS.CH"
#include "topconn.ch"
#include "font.ch"    

User Function HELPDESKHD()
//Local cQuery
Private aRotina   := {} 
Private cTpcham   := DetSetOcor() //Setor Ocorrência (01-Infra, 03-TI, 05-rh)
Private cAmail    := cPara :=""
Private cCadastro := "HELP DESK"
PRIVATE oObjBrow  := Nil
PRIVATE cRotina   := "HELPDESK"
Private cCodUsr   := RetCodUsr()
//Private cAcessos  := Posicione("SZW", 4, xFilial("SZW")+cRotina+__cUserID+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")
Private _cAlias1   := "Z06"                    // Alias da Enchoice.
Private _cAlias2   := "Z07" 
PRIVATE _cFiltro  := ""
Private aCores	  :={{ "Z06_STATUS=='1'"	, 'ENABLE     '	},;  // Aberto
					{  "Z06_STATUS=='2'" 	, 'BR_VERMELHO'	},;  // Encerrar
					{  "Z06_STATUS=='3'" 	, 'BR_AZUL    '	},;  // Pendente Tec
					{  "Z06_STATUS=='4'" 	, 'BR_BRANCO  '	},;  // Pendente User
					{  "Z06_STATUS=='5'" 	, 'BR_LARANJA'	}}   // Pendente User

Private lPodeAlterar := PodeAlterar() //Tem permissão de alterar chamado?

/*
TcRefresh(RetSqlName("Z06"))
TcRefresh(RetSqlName("Z07"))
TcRefresh(RetSqlName("SZH"))
*/
AAdd(aRotina, {"Pesquisar"              , "AxPesqui"       , 0, 1})
AAdd(aRotina, {"Visualizar"             , "u_HD3Manut(2)"  , 0, 2})
AAdd(aRotina, {"Incluir"                , "u_HD3Manut(3)"  , 0, 3})
AAdd(aRotina, {"Responder"              , "u_HD3Manut(4)"  , 0, 4})
AAdd(aRotina, {"Encerrar"               , "u_HD3Manut(6)"  , 0, 6})
AAdd(aRotina, {"Imprimir"               , "u_HD3Imprim"    , 0, 7})
AAdd(aRotina, {"Legenda"                , "U_HD3Leng"      , 0, 8})
AAdd(aRotina, {"Conhecimento"           , "MsDocument"     , 0, 4})
AAdd(aRotina, {"Todos em Aberto"        , "u_HD3FILT(1)"   , 0,10})
AAdd(aRotina, {"Meus cham em Aberto"    , "u_HD3FILT(4)"   , 0,10})
AAdd(aRotina, {"Todos Encerrados "      , "u_HD3FILT(2)"   , 0,10})
AAdd(aRotina, {"Todos os Meus Chamados" , "u_HD3FILT(5)"   , 0,10})
AAdd(aRotina, {"Meu Setor"			    , "u_HD3FILT(6)"   , 0,10})
AAdd(aRotina, {"Encaminhar p/ Aprovacao", "u_HD3Manut(7)"      , 0,10})
AAdd(aRotina, {"Liberar"			    , "u_HD3Manut(8)"   , 0,10})
AAdd(aRotina, {"Acesso Rotina"          , "u_BRSEN002"     , 0, 5})
AAdd(aRotina, {"Limpar Filtro"          , "u_HD3All"       , 0,10})



If !VldAcesso(cRotina)
   	MsgBox("Acesso não autorizado, verifique com seu superior sobre o acesso a abertura de chamados !---->"+funname(),"Atenção","Alert")
  	Return 
Endif 


dbSelectArea(_cAlias1)
dbsetorder(1)
dbGoTop()
	
	oObjBrow := FWMBrowse():New()
	oObjBrow:SetAlias("Z06")
	oObjBrow:SetMenuDef(cRotina)
	oObjBrow:SetWalkThru(.F.)
	oObjBrow:SetUseFilter(.T.)
	if type("oObjBrow:lDetails") != "U"
		oObjBrow:lDetails := .F.
	endif 
	oObjBrow:AddLegend( 'Z06->Z06_STATUS == "1"' , 'ENABLE'       , "Cham Aberto  ")
	oObjBrow:AddLegend( 'Z06->Z06_STATUS == "3"' , 'BR_AZUL'      , "Pendente Tec")
	oObjBrow:AddLegend( 'Z06->Z06_STATUS == "2"' , 'BR_VERMELHO'  , "Encerrado    ")
	oObjBrow:AddLegend( 'Z06->Z06_STATUS == "4"' , 'BR_BRANCO'    , "Pendente User ")
   	oObjBrow:AddLegend( 'Z06->Z06_STATUS == "5"' , 'BR_LARANJA'   , "Aguardando Liberar ")
   
	oObjBrow:Activate()
	
	EndFilBrw("Z06")     

Return Nil

User Function HD3Manut(nOpc)

//Local i        := 0
Local cLinOK   := "AllwaysTrue"
Local cTudoOK  := "u_HD3TudOK"
Local nOpcE    := nOpc
Local nOpcG    := nOpc
Local cFieldOK := "AllwaysTrue"
Local lVirtual := .T.
Local nLinhas  := 99
Local nFreeze  := 0
Local lRet     := .T.
Private aCols        := {}
Private aHeader      := {}
Private aCpoEnchoice := {}
Private aAltEnchoice := {}
Private aAlt         := {}

dbSelectArea(_cAlias1)
tipocham()
If nOpc == 7
	encamCham()
	Return Nil
ElseIf nOpc == 8
	libCham()
	Return Nil
EndIf

If	( (nOpc==4 .Or. nOpc==6 .or. nOpc==2 ) .And. (Z06->Z06_STATUS == '1'.or.Z06->Z06_STATUS == '2'.or.Z06->Z06_STATUS == '3'.or.Z06->Z06_STATUS == '4') .and. (__CUSERID != Z06->Z06_SOLCHA) .and. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0) ) .AND. cTpcham <> substr(Z06->Z06_SETOCO,1,2)
	 alert('Chamado não pode ser acessado.')
	 Return 
elseif ( (nOpc==4 .Or. nOpc==6 ) .And. Z06->Z06_STATUS == '2' )
		alert('Este chamado está ENCERRADO.')
		Return 
else
	If (nOpc==4 .or. nOpc==5 .or. nOpc==6 )  
		IF Empty(Z06->Z06_TECALO) .OR. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .OR. ((cTpcham  == substr(Z06->Z06_SETOCO,1,2)) .and. (Z06->Z06_TECALO == __CUSERID)) .OR. (__CUSERID == Z06->Z06_SOLCHA) .OR. lPodeAlterar
		//if (  (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .OR. (cTpcham  == substr(Z06->Z06_SETOCO,1,2)) .and. ((Z06->Z06_TECALO == __CUSERID).or.( Empty(Z06->Z06_TECALO)))  ) .or.(__CUSERID == Z06->Z06_SOLCHA) 
			RegToMemory(_cAlias1, (nOpc==3))
			// Cria variaveis de memoria dos campos da tabela Filho.
			RegToMemory(_cAlias2, (nOpc==3))
			CriaHeader(nOpc)
			CriaCols(nOpc)
			lRet := Modelo3(cCadastro, _cAlias1, _cAlias2, aCpoEnchoice, cLinOK, cTudoOK, nOpcE, nOpcG, cFieldOK, lVirtual, nLinhas, aAltEnchoice	, nFreeze,,{0,0,600,700},200)
			If lRet
				If  nOpc == 3
					If MsgYesNo("Confirma a gravação dos dados?", cCadastro)
						Processa({||GrvDados()}, cCadastro, "Gravando os dados, aguarde...")
					EndIf
				ElseIf nOpc == 4 
					If MsgYesNo("Confirma a ALTERAÇÃO do chamado?", cCadastro)
						Processa({||AltDados(nOpc)}, cCadastro, "Alterando os dados, aguarde...")
					EndIf  
				ElseIf nOpc == 6
					If MsgYesNo("Deseja ENCERRAR o chamado", cCadastro)
						Processa({||solucEnc()}, cCadastro, "Encerrando, aguarde...")
					EndIf     
				EndIf
			Else
				RollBackSX8()
			EndIf 
		else
			alert(" Voce não pode alterar esse chamado")
			return
		endif
	else
		RegToMemory(_cAlias1, (nOpc==3))
		RegToMemory(_cAlias2, (nOpc==3))
		CriaHeader(nOpc)
		CriaCols(nOpc)
		lRet := Modelo3(cCadastro, _cAlias1, _cAlias2, aCpoEnchoice, cLinOK, cTudoOK, nOpcE, nOpcG, cFieldOK, lVirtual, nLinhas, aAltEnchoice	, nFreeze,,{0,0,600,700},200)
		If lRet
			If nOpc == 3
				If MsgYesNo("Confirma a gravação dos dados?", cCadastro)
					Processa({||GrvDados()}, cCadastro, "Gravando os dados, aguarde...")
				EndIf
			ElseIf nOpc == 4 
				If MsgYesNo("Confirma a ALTERAÇÃO do chamado?", cCadastro)
					Processa({||AltDados(nOpc)}, cCadastro, "Alterando os dados, aguarde...")
				EndIf
			ElseIf nOpc == 6
				If MsgYesNo("Deseja ENCERRAR o chamado", cCadastro)
					Processa({||solucEnc()}, cCadastro, "Encerrando, aguarde...")
				EndIf     
			EndIf 
		Else
			RollBackSX8()
		EndIf 
	endif
endif
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function CriaHeader(nOpc)
       Local _lOpen     := .F. //LGS#20200211 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
       Local _nRetUsr   := PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr())
       PRIVATE aItems, oList, nList
       aHeader      := {}
       aCpoEnchoice := {}
       aAltEnchoice := {}
       
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200211 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //Private  cCat := Z06_SET
       // aHeader é igual ao do Modelo2.
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek(_cAlias2)
       While !SX3->(EOF()) .And. SX3->X3_Arquivo == _cAlias2
             If X3Uso(SX3->X3_Usado)    .And.;                  // O Campo é usado.
                cNivel >= SX3->X3_Nivel .And. ;
                Trim(SX3->X3_Campo) $"Z07_USER/Z07_HRA/Z07_DATA/Z07_DESCRI"
                AAdd(aHeader, {Trim(SX3->X3_Titulo),;
                               SX3->X3_Campo       ,;
                               SX3->X3_Picture     ,;
                 	           SX3->X3_Tamanho     ,;
                               SX3->X3_Decimal     ,;
                               SX3->X3_Valid       ,;
                               SX3->X3_Usado       ,;
                               SX3->X3_Tipo        ,;
                               SX3->X3_Arquivo     ,;
                               SX3->X3_Context})
             EndIf
             SX3->(dbSkip())
       End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek(_cAlias2) )
       While !( _cAliasSX3 )->( EOF() ) .And. ( _cAliasSX3 )->( X3_Arquivo ) == _cAlias2
             If X3Uso( ( _cAliasSX3 )->( X3_Usado ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_Nivel ) .And. Trim( ( _cAliasSX3 )->( X3_Campo ) ) $"Z07_USER/Z07_HRA/Z07_DATA/Z07_DESCRI"
                AAdd( aHeader, { Trim( ( _cAliasSX3 )->( X3_Titulo ) ),;
                                       ( _cAliasSX3 )->( X3_Campo )   ,;
                                       ( _cAliasSX3 )->( X3_Picture ) ,;
                 	                   ( _cAliasSX3 )->( X3_Tamanho ) ,;
                                       ( _cAliasSX3 )->( X3_Decimal ) ,;
                                       ( _cAliasSX3 )->( X3_Valid )   ,;
                                       ( _cAliasSX3 )->( X3_Usado )   ,;
                                       ( _cAliasSX3 )->( X3_Tipo )    ,;
                                       ( _cAliasSX3 )->( X3_Arquivo ) ,;
                                       ( _cAliasSX3 )->( X3_Context ) } )
             EndIf
             ( _cAliasSX3 )->( dbSkip() )
       End
       /********************************************************************************************************************************/
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek(_cAlias1)
       While !SX3->(EOF()) .And. SX3->X3_Arquivo == _cAlias1
             If X3Uso(SX3->X3_Usado) .and. cNivel >= SX3->X3_Nivel      // O Campo é usado.
                //cNivel >= SX3->X3_Nivel                         // Nivel do Usuario é maior que o Nivel do Campo.
                // Campos da Enchoice.      
                AAdd(aCpoEnchoice, X3_CAMPO) 
                if (nOpc == 4 .and. SX3->X3_CAMPO = "Z06_SET" .and. Empty(Z06->Z06_SET)) .or. nOpc!= 4 
                   AAdd(aAltEnchoice, X3_CAMPO)
                endif
                if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. SX3->X3_CAMPO = "Z06_CLASSI"
                   AAdd(aAltEnchoice, X3_CAMPO)
                endif
                if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. SX3->X3_CAMPO = "Z06_TECALO"
                   AAdd(aAltEnchoice, X3_CAMPO)
                endif  
                if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. SX3->X3_CAMPO = "Z06_PROJTO"
                   AAdd(aAltEnchoice, X3_CAMPO)
                endif 
                if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. SX3->X3_CAMPO = "Z06_SETOCO"
                   AAdd(aAltEnchoice, X3_CAMPO) 
                endif
                if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. SX3->X3_CAMPO = "Z06_SOLCHA"
                   AAdd(aAltEnchoice, X3_CAMPO) 
                endif
                if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. SX3->X3_CAMPO = "Z06_TPCHAM"
                   AAdd(aAltEnchoice, X3_CAMPO) 
                endif
             EndIf
             SX3->(dbSkip())
       End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek(_cAlias1) )
       While !( _cAliasSX3 )->( EOF() ) .And. ( _cAliasSX3 )->( X3_Arquivo ) == _cAlias1
             If X3Uso( ( _cAliasSX3 )->( X3_Usado ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_Nivel )      // O Campo é usado.
                //cNivel >= SX3->X3_Nivel                         // Nivel do Usuario é maior que o Nivel do Campo.
                // Campos da Enchoice.
                   AAdd(aCpoEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) ) 
                if (nOpc == 4 .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_SET" .and. Empty(Z06->Z06_SET)) .or. nOpc!= 4 
                   AAdd(aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) )
                endif
                //if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_CLASSI"
                if (( _nRetUsr = 0) .OR. lPodeAlterar) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_CLASSI"
                   AAdd(aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) )
                endif
                //if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_TECALO"
                if (( _nRetUsr = 0) .OR. lPodeAlterar) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_TECALO"
                   AAdd(aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) )
                endif  
                //if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_PROJTO"
                if (( _nRetUsr = 0) .OR. lPodeAlterar) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_PROJTO"
                   AAdd(aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) )
                endif 
                //if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_SETOCO"
                if (( _nRetUsr = 0) .OR. lPodeAlterar) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_SETOCO"
                   AAdd(aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) ) 
                endif
                //if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_SOLCHA"
                if (( _nRetUsr = 0) .OR. lPodeAlterar) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_SOLCHA"
                   AAdd(aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) ) 
                endif
                //if (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_TPCHAM"
                if (( _nRetUsr = 0) .OR. lPodeAlterar) .and. ( _cAliasSX3 )->( X3_CAMPO ) = "Z06_TPCHAM"
                   AAdd(aAltEnchoice, ( _cAliasSX3 )->( X3_CAMPO ) ) 
                endif
             EndIf
             ( _cAliasSX3 )->( dbSkip() )
       End
       dbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function CriaCols(nOpc)

Local nQtdCpo := 0
Local i       := 0
Local nCols   := 0

nQtdCpo := Len(aHeader)
aCols   := {}
aAlt    := {}

If nOpc == 3     // Inclusao.

   AAdd(aCols, Array(nQtdCpo+1))

   For i := 1 To nQtdCpo
       aCols[1][i] := CriaVar(aHeader[i][2])
   Next
   aCols[1][nQtdCpo+1] := .F.
 Else
   dbSelectArea("Z07")
   dbSETORDER(1)
   dbSeek(xFilial("Z07") + ("Z06")->Z06_NUMCHA)

   While !EOF() .And. Z07->Z07_Filial == xFilial("Z07") .And. Z07->Z07_CODIGO == Z06->Z06_NUMCHA

      AAdd(aCols, Array(nQtdCpo+1))
      nCols++

      For i := 1 To nQtdCpo
          If aHeader[i][10] <> "V"
             aCols[nCols][i] := &(_cAlias2 +"->" + aHeader[i][2]) //FieldGet(FieldPos(aHeader[i][2]))
           Else
             aCols[nCols][i] := CriaVar(aHeader[i][2], .T.)
          EndIf
      Next

      aCols[nCols][nQtdCpo+1] := .F.

      AAdd(aAlt, Recno())

      dbSelectArea("Z07")
      dbSkip()
   End                                                                             	
EndIf
 
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function GrvDados()

Local bCampo := {|nField| Field(nField)}
Local i      := 0
Local y      := 0
Local cSetOcorr 
//Local nItem  := 0
ProcRegua(Len(aCols) + FCount())
// Grava o registro da tabela Pai, obtendo o valor de cada campo
// a partir da var. de memoria correspondente.
dbSelectArea(_cAlias1)
RecLock(_cAlias1, .T.)

Z06->Z06_SOLCHA := M->Z06_SOLCHA

For i := 1 To FCount()
    IncProc()
    If "FILIAL" $ FieldName(i)
       FieldPut(i, xFilial(_cAlias1))
    ELSEIF "Z06_NUMCHA" $ FieldName(i)
    	Z06->Z06_NUMCHA:= U_NUMSEQLOTE("Z06",6)
    Else
    	if ("Z06_STATUS" $ FieldName(i)) .and. !EMPTY(M->Z06_TECALO) 
			Z06->Z06_STATUS := "4"  
		else
       		FieldPut(i, M->&(Eval(bCampo,i)))
       endif
    EndIf
Next    

MSUnlock()     
// Grava os registros da tabela Filho.
dbSelectArea(_cAlias2)
dbSETORDER(1)
	
For i := 1 To Len(aCols)

    IncProc()
    If !aCols[i][Len(aHeader)+1]       // A linha nao esta deletada, logo, pode gravar.
       RecLock(_cAlias2, .T.)
       Z07->Z07_Filial := xFilial("Z07")
       Z07->Z07_CODIGO := Z06->Z06_NUMCHA
       For y := 1 To Len(aHeader)   
           FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
       Next
       	Z07->Z07_DESCRI :="Abertura"
       MSUnlock()
    EndIf
Next

cSetOcorr := substr(Z06->Z06_SETOCO,1,2)
tipocham()
cAssunto := Z06->Z06_NUMCHA+" - Novo chamado....Aberto por: "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),0,30)+" Ramal " +Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, " ZH_RAMAL")
cTexEnc := Z06->Z06_OCORRE
point:= 7

HD3Mail(cAssunto,cTexEnc,cPara,"",alltrim(UsrRetMail(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_GERENTE"))))

/* //Cleber(20/05/20)
do case
case (cSetOcorr == "01")
	cAssunto := Z06->Z06_NUMCHA+" - Novo chamado. Aberto por: "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),0,30) +" Ramal "+Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, " ZH_RAMAL")      
	cTexEnc := Z06_OCORRE
	HD3Mail(cAssunto,cTexEnc,cPara,"",7,alltrim(UsrRetMail(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_GERENTE")))) 
case (cSetOcorr == "02")
	cAssunto := Z06->Z06_NUMCHA+" - Novo chamado....Aberto por: "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),0,30)+" Ramal " +Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, " ZH_RAMAL")
	cTexEnc := Z06_OCORRE
	point:= 3
	HD3Mail(cAssunto,cTexEnc,cPara,"",point,alltrim(UsrRetMail(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_GERENTE"))))
case (cSetOcorr == "03")
	cAssunto := Z06->Z06_NUMCHA+" - Novo chamado....Aberto por: "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),0,30) +" Ramal "+Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, " ZH_RAMAL")                                           
	cTexEnc :=  Z06_OCORRE    
	point := 3
	HD3Mail(cAssunto,cTexEnc,cPara,"",point,alltrim(UsrRetMail(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_GERENTE")))) 
case (cSetOcorr == "04")
	cAssunto := Z06->Z06_NUMCHA+" - Novo chamado....Aberto por: "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),0,30)+" Ramal " +Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, " ZH_RAMAL")
	cTexEnc := Z06_OCORRE         
	point := 7
	HD3Mail(cAssunto,cTexEnc,cPara,cAmail,point,alltrim(UsrRetMail(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_GERENTE"))))
case (cSetOcorr == "05")
	cAssunto := Z06->Z06_NUMCHA+" - Novo chamado....Aberto por: "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),0,30)+" Ramal " +Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, " ZH_RAMAL")
	cTexEnc := Z06_OCORRE         
	point := 7
	HD3Mail(cAssunto,cTexEnc,cPara,cAmail,point,alltrim(UsrRetMail(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_GERENTE"))))
otherwise
	cAssunto := Z06->Z06_NUMCHA+" - Novo chamado....Aberto por: "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),0,30)+" Ramal " +Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, " ZH_RAMAL")
	cTexEnc := Z06_OCORRE         
	point := 7
	HD3Mail(cAssunto,cTexEnc,cPara,cAmail,point,alltrim(UsrRetMail(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_GERENTE"))))
endcase	
*/	
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static Function AltDados(cTexEnc,point)
Local  i      := 0
Local  y      := 0
Private nItem  := 0
Private getAdm := 0
Private getMensagem 
Private ConvData 
PRivate flag := 0

ProcRegua(Len(aCols) + FCount())

dbSelectArea(_cAlias1)
RecLock(_cAlias1, .F.) 
/*
if M->Z06_CLASSI == "1"
	M->Z06_CLASSI := "Baixa"
elseif M->Z06_CLASSI == "2"	
	M->Z06_CLASSI := "Media"
elseif M->Z06_CLASSI == "3"	
	M->Z06_CLASSI := "Alta"
endif
*/          
tipocham()           

If (Z06->Z06_SETOCO != M->Z06_SETOCO) .OR. (Z06->Z06_SOLCHA != M->Z06_SOLCHA)
	Z06->Z06_SETOCO := M->Z06_SETOCO                           
	Z06->Z06_SOLCHA := M->Z06_SOLCHA
Else
	if  (( PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .OR. lPodeAlterar) .and. Empty(M->Z06_TECALO) //.OR. cTpcham > "03"       
	     M->Z06_TECALO := __cUserId                                                 
	elseif (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .and. !Empty(M->Z06_TECALO)
		Z06->Z06_TECALO := M->Z06_TECALO
	endif
	if __CUSERID == Z06->Z06_SOLCHA  .and. Z06_STATUS != "2"
		M->Z06_STATUS := '3'
	elseif (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .or. (cTpcham == substr(Z06->Z06_SETOCO,1,2)) .and. Z06_STATUS != "2"
		M->Z06_STATUS := '4'
	endif
EndIf

For i := 1 To FCount()
    IncProc()    

    If "FILIAL" $ FieldName(i)
       FieldPut(i, xFilial(_cAlias1))
     Else
       FieldPut(i, M->&(fieldname(i)))
    EndIf
 Next   
//Z06->Z06_PROCED := substr(cAvlCham,1,1)
MSUnlock()  

//------------------------------------------------------------------E-Mail-----------------------------------------------------------------------------------
ConvData:= substr(dtos(Z06->Z06_DTABER),7,2)+"/"+substr(dtos(Z06->Z06_DTABER),5,2)+"/"+substr(dtos(Z06->Z06_DTABER),1,4)
cTexto :=("Chamado: "+ Z06->Z06_NUMCHA +" "+" "+" Solicitante: "+Z06->Z06_SOLCHA+ " - "+ UsrRetName(Z06->Z06_SOLCHA)+" "+" "+ " Data: "+ ConvData +" "+" "+" Hora: "+Z06->Z06_HRABER +CHR(13)+CHR(10)+ " Ocorrencia: "+Z06->Z06_OCORRE+CHR(13)+CHR(10))    
//-----------------------------------------------------------------------------------------------------------------------------------------------------------

dbSelectArea(_cAlias2)
DBSETORDER(1)

nItem := Len(aAlt) + 1

For i := 1 To Len(aCols) 

    If i <= Len(aAlt)

       dbGoTo(aAlt[i])            
       
       If aCols[i][Len(aHeader)+1]
          dbDelete()
        Else
          For y := 1 To Len(aHeader)
                
          Next               
          	ConvData:= substr(dtos(Z07->Z07_DATA),7,2)+"/"+substr(dtos(Z07->Z07_DATA),5,2)+"/"+substr(dtos(Z07->Z07_DATA),1,4)
           	cTexto := (cTexto +CHR(13)+CHR(10)+"Usuario: "+Z07->Z07_USER+" - "+UsrRetName(Z07->Z07_USER)+" "+" "+" Data: "+ConvData+" "+" "+" Hora: "+Z07->Z07_HRA +CHR(13)+CHR(10)+" Mensagem: "+Z07->Z07_DESCRI +CHR(13)+CHR(10)) 
	   
			if((Z06->Z06_SOLCHA != Z07_USER) .And. flag == 0)
	          	getAdm := Z07->Z07_USER 
	          	flag := 1
          	endif
       EndIf
     Else
       If !aCols[i][Len(aHeader)+1]
          RecLock(_cAlias2, .T.)
       
          For y := 1 To Len(aHeader)
        
              FieldPut(FieldPos(Trim(aHeader[y][2])), aCols[i][y])
        	 	
		    Next
          (_cAlias2)->Z07_Filial := xFilial(_cAlias2)
          (_cAlias2)->Z07_CODIGO := (_cAlias1)->Z06_NUMCHA
          getMensagem := Z07_DESCRI        
          
          ConvData:= substr(dtos(Z07->Z07_DATA),7,2)+"/"+substr(dtos(Z07->Z07_DATA),5,2)+"/"+substr(dtos(Z07->Z07_DATA),1,4)
          cTexto := (cTexto +CHR(13)+CHR(10)+"Usuario: "+Z07->Z07_USER+" - "+UsrRetName(Z07->Z07_USER)+" "+" "+"   Data: "+ConvData+" "+" "+"  Hora: "+Z07->Z07_HRA+CHR(13)+CHR(10)+ "  Mensagem:"+Z07->Z07_DESCRI +CHR(13)+CHR(10)) 
          
          MSUnlock()
          nItem++
       EndIf
    EndIf
Next
if(point == 1) 
	  	dbSelectArea("Z06")   
		dbSetOrder(1)        
		RecLock(_cAlias1, .F.)
   		Z06->Z06_STATUS := "2"
		IF EMPTY(Z06->Z06_PREVIS) .OR. (Z06->Z06_PREVIS = CTOD("31/12/2049"))
			Z06->Z06_PREVIS := DATE()
		ENDIF 
   		MSUnlock()                    
	    cTexEnc := cTexEnc+cTexto
	 	point :=2
    	cAssunto := Z06_NUMCHA
    	cPara+=	alltrim(UsrRetMail(getAdm))	  
	    HD3Mail(cAssunto,cTexEnc,cPara,"","") 
	    return
endif

if (__CUSERID == Z06->Z06_SOLCHA)
	    tipocham()
		cAssunto := Z06_NUMCHA
		HD3Mail(cAssunto,cTexto,cPara,cAmail,"")
	
elseif (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) = 0) .OR. (cTpcham == substr(Z06->Z06_SETOCO,1,2))
   		tipocham()
        cAssunto := Z06_NUMCHA
  		HD3Mail(cAssunto,cTexto,cPara,cAmail,"")
					
endif
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------//     
Static Function EncDados(cEnc,cAvlCham)
Local ConvData :=""
//Local cTexto:="", ConvData  
Private cTexEnc:="", point:= 1

	ConvData:= substr(dtos(Z06->Z06_DTABER),7,2)+"/"+substr(dtos(Z06->Z06_DTABER),5,2)+"/"+substr(dtos(Z06->Z06_DTABER),1,4)
  
   if !EMPTY(cEnc) 	
		/*
	   	dbSelectArea("Z06")   
		RecLock("Z06", .F.)
   		Z06->Z06_STATUS := "2"
        Z06->Z06_PROCED := substr(cAvlCham,1,1)
		IF EMPTY(Z06->Z06_PREVIS) .OR. (Z06->Z06_PREVIS = CTOD("31/12/2049"))
			Z06->Z06_PREVIS := DATE()
		ENDIF 
     	MSUnlock() 
        */
   		M->Z06_STATUS := "2"
        M->Z06_PROCED := substr(cAvlCham,1,1)
		IF EMPTY(M->Z06_PREVIS) .OR. (M->Z06_PREVIS = CTOD("31/12/2049"))
			M->Z06_PREVIS := DATE()
		ENDIF 
		   	   
   		dbSelectArea("Z07")   
		RecLock("Z07", .t.)
        Z07->Z07_Filial := xFilial("Z07")
        Z07->Z07_DESCRI := cEnc
  	    Z07->Z07_HRA  := TIME()
     	Z07->Z07_DATA := DDATABASE
     	Z07->Z07_USER :=__cUserId
     	Z07->Z07_CODIGO := Z06_NUMCHA
      	MSUnlock() 
     else
   	 ALERT("Preencher o campo")
   	 return 	
   endif
 ConvData:= substr(dtos(Z07->Z07_DATA),7,2)+"/"+substr(dtos(Z07->Z07_DATA),5,2)+"/"+substr(dtos(Z07->Z07_DATA),1,4)
 cTexEnc:= "CHAMADO ENCERRADO"+CHR(13)+CHR(10)+"Encerrado: "+ConvData+" - "+Z07_HRA+CHR(13)+CHR(10)+"Por: "+__cUserId+" - "+USRRETNAME(__cUserId)+CHR(13)+CHR(10)+"Chamado: "+Z06_NUMCHA+" - "+Z06_OCORRE+CHR(13)+CHR(10)+"Solução: "+cEnc+CHR(13)+CHR(10)+CHR(13)+CHR(10)
 cTexEnc:= cTexEnc + CHR(13)+CHR(10)+ replicate("_",120)+CHR(13)+CHR(10)

 AltDados(cTexEnc,point)
Return Nil
//----------------------------------------------------------------------------------------------------------------------------------------------------------//     
User Function HD3TudOK()

Local lRet := .T.
Local i    := 0
Local nDel := 0

For i := 1 To Len(aCols)
    If aCols[i][Len(aHeader)+1]
       nDel++
    EndIf
Next

If nDel == Len(aCols)
   MsgInfo("Para excluir todos os itens, utilize a opção EXCLUIR", cCadastro)
   lRet := .F.
EndIf

Return lRet

User Function HD3Leng()

Local	aLegenda  := {	{'ENABLE'		,'Aberto'},;
						{'BR_AZUL'		,'Pendente(Tecnico)'},;
						{'BR_BRANCO'	,'Pendente(Usuario)'},;
						{'BR_VERMELHO'	,'Encerrado'}}

		BrwLegenda(cCadastro,'Legenda',aLegenda)                                   
		
Return .T.
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
/*Static FUNCTION HD3SREL
LOCAL aEntidade := {}

AADD( aEntidade, { "Z06", { "Z06_NUMCHA" }, { || Z06->Z06_NUMCHA } } )

Return aEntidade */
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
Static FUNCTION HD3Mail(cAssunto,cTexto,cPara,cAmail,cCopia)    
local cCC := cCopia
local cSolicitante := alltrim(UsrRetMail(Z06->Z06_SOLCHA))
dbselectarea("Z06")

if empty(cPara)
	cPara := alltrim(UsrRetMail(Z06_SOLCHA))
endif 
if empty(cPara)
	cPara := "ti@brasilux.com.br"
endif 

if !empty(cSolicitante) .and. !(cSolicitante $ cPara)
	cPara += ","+cSolicitante
endif 

if !empty(cAmail) .and. !(alltrim(cAmail) $ cPara) .and. !(alltrim(cAmail) $ cCC)
	if !empty(cCC)
		cCC += ","
	endif
	cCC += cAmail
endif 

/*
If point < 7
	if (point == 2 )
		cAmail := alltrim(UsrRetMail(RetCodUsr(Z06_TECALO)))
		cPara := alltrim(UsrRetMail(Z06_SOLCHA))
	elseif (point == 3 )
		cPara := "ti@brasilux.com.br"
		cAmail :=""
	elseif Empty(cAmail)	
		cAmail := alltrim(UsrRetMail(RetCodUsr()))
	endif
	If cPara <> alltrim(UsrRetMail(Z06_SOLCHA))
		if !empty(cCC)
			cCC += ","
		endif 
		cCC += alltrim(UsrRetMail(Z06_SOLCHA))
	EndIf        
	if !empty(cCC)
		cCC += ","
	endif 
	cCC += cAmail
	if !empty(alltrim(Z06->Z06_EMAIL))
		cCC += " , "+alltrim(Z06->Z06_EMAIL)
	endif 
EndIf
*/
U_EnvMail(cAssunto,cTexto,cPara,cCC,"") 


Return nil

//---------------------------------------------------------------------------------------------------------------------------------------------------
User Function HD3FILT(nStatus)
LOCAL aArea := GetArea()
Local nOrdem,nReg,lReg,cStatus,cSetOcorr
Local lRet := .t.

cStatus := alltrim(str(nStatus))
cSetOcorr := DetSetOcor()

	
dbselectarea("Z06")        
nOrdem := IndexOrd() 
if !eof() .and. !bof()
	lReg := .t.
	nReg := recno()
else
	lReg := .f.
endif 
			
if oObjBrow:Filtrate()
	oObjBrow:DeleteFilter("Status") 
	if lReg
		dbgoto(nReg)
	endif  
endif   
SET FILTER TO

dbselectarea("Z06")        
dbgotop()
dbseek(xFilial("Z06"))

    oObjBrow:CleanExFilter()
	oObjBrow:DeleteFilter("Status")  
	
	if cStatus == "1" 
		_cFiltro := '(Z06_STATUS != "2")'  
	elseif cStatus	== "2"                                                
 		_cFiltro := 'Z06_STATUS == "2"'
	elseif cStatus	== "3"                                                
		_cFiltro := 'Z06_STATUS == "3"'
	elseif cStatus	== "4"                                                
		_cFiltro := '(Z06_STATUS != "2") .and. (Z06_SOLCHA = "'+__cUserId+'" .or. Z06_TECALO = "'+__cUserId+'")'
	elseif cStatus	== "5"                                                
		_cFiltro := '(Z06_SOLCHA = "'+__cUserId+'") .or. (Z06_TECALO = "'+__cUserId+'")' 
	elseIf cStatus == "6"
		IF !EMPTY(cSetOcorr)
			_cFiltro :=	'(substr(Z06->Z06_SETOCO,1,2) == "'+cSetOcorr+'") '
		ENDIF 
	endif  	 
    
    oObjBrow:AddFilter("Status",_cFiltro,,.t.,,,,"Status") 
    oObjBrow:ExecuteFilter() //LGS#20191025 - Adequação a release 12.1.25

RestArea( aArea ) 
    
Return(lRet)
//----------------------------------------------------------------------------------------------------------------------------------------------------------//
User Function HD3All()
	
dbselectarea("Z06")
		
			if oObjBrow:Filtrate()
				nReg := recno()
				oObjBrow:DeleteFilter("Status") 
				dbgoto(nReg)
			endif
 
 		SET FILTER TO 			           
	Return

static Function solucEnc()
Private aTeste,oDlg, oButton, cEnc :=space(200), oEnc, cAvlCham, oAvlCham
private mAberOcor,flag :=0
cAvlCham := ""

DEFINE MSDIALOG oDlg TITLE "Encerramento" FROM 000, 000 TO 200, 300 PIXEL
@ 020, 020 SAY "Solução" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 030, 020 MSGET oENC VAR cENC SIZE 100, 010 OF oDlg  COLORS 0, 16777215 PIXEL When .t.
@ 045, 020 SAY "O Chamado procede?" SIZE 052, 007 OF oDlg COLORS 0, 10 PIXEL
@ 055, 020 MSCOMBOBOX oAvlCham VAR cAvlCham ITEMS{"1=SIM","2=NAO"} SIZE 040, 040 OF oDlg COLORS 0, 10 PIXEL
@ 080, 060 Button "Encerrar" Size 030, 012 PIXEL OF oDlg Action(EncDados(cEnc,cAvlCham),oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

return                                          
Return Nil


Static function tipocham()
Local cSetOcorr
//dbSelectArea("Z06")
//dbsetorder(1)
cSetOcorr := substr(Z06->Z06_SETOCO,1,2)
do case
case (cSetOcorr == "01")
	cPara  := "ti.infra@brasilux.com.br"
	cAmail := ""
case (cSetOcorr == "02")
  	cPara  := "ti@brasilux.com.br"
	cAmail := ""

case (cSetOcorr == "03")
   	cPara  := "ti@brasilux.com.br"
   	cAmail := ""
case (cSetOcorr == "05")
   	cPara  := "rhchamados@brasilux.com.br"
   	cAmail := ""
otherwise
   	cPara  := "ti@brasilux.com.br"
   	cAmail := ""
endcase 

Return()


//---------------------------------------------------------------------------------------------------------------------------------------------------------------------

Static function encamCham()
If Z06_STATUS == '1' .AND.(PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) == 0)
	dbSelectArea("Z06")
	dbSETORDER(1)
	dbSeek(xFilial("Z06") +Z06->Z06_NUMCHA)
	RecLock("Z06", .F.)
		Z06->Z06_STATUS := '5'
	MSUnlock()             
	dbSelectArea("SZH")
	dbSETORDER(1)
	dbSeek(xFilial("SZH")+Z06->Z06_SOLCHA)
	if found()
		cPara := substr(Posicione("SZH", 1, xFilial("SZH")+ZH_GERENTE, "ZH_EMAIL"),1,30)
		cAssunto:= "Liberação de chamado"	
		cTexEnc :="O chamado "+Z06->Z06_NUMCHA+" criado por "+substr(Posicione("SZH", 1, xFilial("SZH")+Z06->Z06_SOLCHA, "ZH_NOME"),1,30)+" precisa de sua liberação. "	
		HD3Mail(cAssunto,cTexEnc,cPara,"","")
	endIf
Else
	alert('Ação bloqueada')
EndIf
Return() 

Static function libCham()
Local cSetOcorr
dbSelectArea("Z06")
dbSETORDER(1)                    	
dbSeek(xFilial("Z06") +Z06->Z06_NUMCHA)

dbSelectArea("SZH")
dbSETORDER(1)
dbSeek(xFilial("SZH")+Z06->Z06_SOLCHA)

If __CUSERID == ALLTRIM(SZH->ZH_GERENTE) .AND. Z06->Z06_STATUS == '5' 
	RecLock("Z06", .F.)                                                                                 	
		Z06->Z06_STATUS := '1'
		Z06->Z06_APROVA := substr(Posicione("SZH", 1, xFilial("SZH")+__CUSERID, "ZH_NOME"),1,30)
	MSUnlock()
	cSetOcorr := substr(Z06->Z06_SETOCO,1,2)
	do case
	case cSetOcorr == "03"
 		cPara := "ti@brasilux.com.br"
	case cSetOcorr ==  "01"	
 		cPara := "infra@brasilux.com.br"
 	case cSetOcorr == "05"
 		cPara := "rhchamados@brasilux.com.br"
 	endcase
	cAssunto:= "Chamado Liberado"	
	cTexEnc :="O chamado "+Z06->Z06_NUMCHA+" foi liberado por "+substr(Z06->Z06_APROVA,1,30)+" "	
	HD3Mail(cAssunto,cTexEnc,cPara,"","")
Else 
		alert('Ação bloqueada')
EndIf
Return() 

//(23/10/2019 - Cleber) Função que verifica se usuário está autorizado a executar rotina passada como parâmetro
Static Function VldAcesso(cPRWRotina)
LOCAL aArea := GetArea()
LOCAL cQuery 
Local lRet := .t.

if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),__CUSERID) <> 0 
	If SELECT("TMPACL") > 0
		TMPACL->(DbcloseArea())
	Endif

	cQuery := "SELECT SUBSTRING(ZW_ACESSOS,1,1) AS ACESSO FROM SZW010 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND "+;
	"(ZW_USUARIO = '"+__CUSERID+"') AND (ZW_ROTINA = '"+ALLTRIM(cPRWRotina)+"')"
	TCQuery cQuery ALIAS "TMPACL" NEW
   	DbSelectArea("TMPACL")
   	IF EOF() .OR. BOF()
   		lRet := .f.
   	ELSE
   		IF TMPACL->ACESSO != "*"
   			lRet := .f.
   		ENDIF 
	ENDIF
	If SELECT("TMPACL") > 0
		TMPACL->(DbcloseArea())
	Endif
endif 

RestArea( aArea ) 
return(lRet)  

Static Function DetSetOcor()
LOCAL aArea := GetArea()
Local cSetOcorr
//****Verificar setor de ocorrência que pertence usuário logado

	If SELECT("TMPACL") > 0
		TMPACL->(DbcloseArea())
	Endif
	cQuery := "SELECT ZH_SETOCO FROM SZH010 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND "+;
	"(ZH_CODIGO = '"+__CUSERID+"')"
	TCQuery cQuery ALIAS "TMPACL" NEW
   	DbSelectArea("TMPACL")
   	IF !EOF() .AND. !BOF()
   		cSetOcorr := ALLTRIM(TMPACL->ZH_SETOCO) 
	ENDIF
	If SELECT("TMPACL") > 0
		TMPACL->(DbcloseArea())
	Endif



//****Fim Verificar setor de ocorrência do usuário logado
RestArea( aArea ) 
return(cSetOcorr)

//(23/07/2020 - Cleber) Função que verifica se usuário pode alterar chamados
Static Function PodeAlterar(cPRWRotina)
LOCAL aArea := GetArea()
LOCAL cQuery 
Local lRet := .T.

if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),__CUSERID) = 0 
	lRet := .t.
else
	
	If SELECT("TMPACL") > 0
		TMPACL->(DbcloseArea())
	Endif

	cQuery := "SELECT ZH_ADMINCH FROM SZH010 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND "+;
	"(ZH_CODIGO = '"+__CUSERID+"')"
	TCQuery cQuery ALIAS "TMPACL" NEW
   	DbSelectArea("TMPACL")
   	IF !EOF() .AND. !BOF()
   		lRet := IIF(TMPACL->ZH_ADMINCH = "S",.T.,.F.)
	ENDIF
	If SELECT("TMPACL") > 0
		TMPACL->(DbcloseArea())
	Endif
endif 

RestArea( aArea ) 
return(lRet)  
