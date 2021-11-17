#include "Protheus.ch"                                                                                                                 
#include "colors.ch"                                                                                 
#INCLUDE "topconn.ch"                                                                                  
#include 'DIRECTRY.CH'                                                                                                                                
#include 'rwmake.ch'                                                                                                                           
                                                                                                                                       
User Function BRSACA01()
     Private cCadastro := "ATENDIMENTO AO CLIENTE(SAC)"                                             
     Private cRotUsu   := 'BRSACA01  '                                             
     Private cCodUsr    := RetCodUsr()
     Private lFilUtil  := .t.
     Private cDepUsu   := ""
     Private cTipFil   := ""
     Private cVlrOpcB  := ''
     Private aEnvSac   := fBusEnvSac()                                     
     Private nOpcRot   := 0 //Opção do Roteiro do sistema
     Private nOpc      
     Private oObjBrow  := Nil   // Funcionamento do Filtro
   	 Private aIndexSZQ := {}	// Funcionamento do Filtro
     //adicionado dyego
     Private nGetOSac   := {"SIM", "NAO"}   
     Private nGetPSac   := {"SPED", "NFE"}   
     Private cDepart    :=	Substr(Posicione("SZW", 4, xFilial("SZW")+cRotUsu+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO"),1,3)
	 erroTrans := .F.	
     
     If !u_fVerAcsUsr(cRotUsu, 1, , @cDepUsu, @cTipFil)
        MsgStop("Usuário sem acesso a essa opção.", "Atenção")
        Return
     Endif

     Private aRotina   := { {"Pesquisar"  , "AxPesqui"  , 0, 1} ,;
                            {"Visualizar" , "u_SACA01_1", 0, 2}  }

     If u_fVerAcsUsr(cRotUsu, 2) .and. cDepart $ 'INF.ATE.DIR'
        If cDepart $ 'DIR' .and. __CUSERID $ '000071.000023' .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) = 0) //u_fRetGrupoUser() $ '000000'
              aAdd(aRotina, { OemToAnsi("Atendimento"), "u_SACA01_2", 0, 3} )
              aAdd(aRotina, { OemToAnsi("Excluir"    ), "u_SACA01_3", 0, 4} )
              aAdd(aRotina, { OemToAnsi("Parecer"    ), "u_SACA01_3", 0, 6} )
              aAdd(aRotina, { OemToAnsi("Encerra"    ), "u_SACA01_3", 0, 6} )
              nOpcRot := 1 //Para Usuários do atendimento, informatica e diretoria aonde Diretoria, Cleber e Gustavo tem opção do parecer.
        Else              
           aAdd(aRotina, { OemToAnsi("Atendimento"), "u_SACA01_2", 0, 3} )
           aAdd(aRotina, { OemToAnsi("Excluir"    ), "u_SACA01_3", 0, 4} )
           aAdd(aRotina, { OemToAnsi("Encerra"    ), "u_SACA01_3", 0, 6} )
           nOpcRot := 2 //Para outros usuários do atendimento cujos pareceres (diagnostico/solução) são dados na tela principal.
        Endif
     ElseIf u_fVerAcsUsr(cRotUsu, 4)  .or. cDepart $ 'FIN'
            aAdd(aRotina, { OemToAnsi("Parecer")      ,"u_SACA01_3", 0, 6} )
			aAdd(aRotina, { OemToAnsi("Encerra")      ,"u_SACA01_3", 0, 6} )
            nOpcRot := 3 //Para usuários que não são do atendimento, diretoria ou informatica e informam seus pareceres.
     Endif
     
     //aAdd(aRotina, { OemToAnsi("Pendentes")           , 'U_SACA01_R'      , 0, 9} )
     aadd(aRotina, { OemToAnsi("Mostrar Pendentes")       , 'U_SACA01_F(1,1)' , 0, 0} )
     aadd(aRotina, { OemToAnsi("Mostrar Todos os Abetos") , 'U_SACA01_F(1,2)' , 0, 0} )
     aadd(aRotina, { OemToAnsi("Desligar Filtro")         , 'U_SACA01_F(2)'   , 0, 0} )
     
     If (cDepart $ 'DIR' .or. __CUSERID $ '000071.000023') .or. cDepUsu $ 'INF.ATE'
        aAdd(aRotina, { OemToAnsi("Vencimento")       , 'U_SACA01_V'      , 0, 9} )
     Endif                                                                                           
     
     aAdd(aRotina, { OemToAnsi("Ficha")                ,'U_BRSACR07'      , 0, 9} )
     aAdd(aRotina, { OemToAnsi("Imprime sac")          ,'U_BRSACR01(1)'   , 0, 9} )
     aAdd(aRotina, { OemToAnsi("Imp. Aut. Devolução")  ,'U_BRSACA02(1)'   , 0, 9} )
     //aAdd(aRotina, { OemToAnsi("Romaneio de Coleta")   ,'U_BRSACR02(1)'   , 0, 9} )
     //aAdd(aRotina, { OemToAnsi("E-mail representante") ,'U_SACX02_4()'    , 0, 9} )
     aAdd(aRotina, { OemToAnsi("Banco de Conhecimento"),'MsDocument'      , 0, 4} )
     aAdd(aRotina, { OemToAnsi("Legenda")              ,'U_SACA01_L'      , 0, 9} )

     If __CUSERID $ '000000.000071.000092.000023' .or. (PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),cCodUsr) = 0) //u_fRetGrupoUser() $ '000000'
        aAdd(aRotina, { OemToAnsi("Acessos")      , 'U_SENA01(cRotUsu)'  , 0, 6} )
     Endif

     Private cDelFunc  := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

     Private aCores   := { { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'D')", 'BR_AZUL'    },; //SAC com Diretoria
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'C')", 'BR_AMARELO' },; //SAC com Comercial
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'F')", 'BR_PINK'    },; //SAC com Financeiro
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'T')", 'BR_MARRON'  },; //SAC com Técnico
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'P')", 'BR_MARRON'  },; //SAC com Produção                           
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'E')", 'BR_PRETO'   },; //SAC com Expedição
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'S')", 'BR_CINZA '  },; //SAC com Suprimentos- Compras
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'V')", 'BR_CINZA '  },; //SAC com Depósito SP - Viamix
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'R')", 'BR_LARANJA' },; //SAC com Recebimento
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '-')", 'BTCALC'     },; //SAC com Contabilidade
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '#')", 'INSTRUME'   },; //SAC com Manutencao
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'A')", 'ENABLE'     },; //SAC com Atendente
                           { "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'M')", 'BR_BRANCO'  },; //Atendimento com Resposta
                           { "(ZQ_STATUS == '2'                     )", 'DISABLE'    } } //SAC encerrado

     
     Private cString := "SZQ"

     DbSelectArea("SZQ")
     DbSetOrder(1)

     DbSelectArea(cString)

     //mBrowse( 6, 1, 22, 75, cString,       ,,,              , , aCores, , , , , .t.)   // desativado para funcionamento do filtro

	 oObjBrow := FWMBrowse():New()
	 oObjBrow:SetAlias("SZQ")		// Indica o Alias da tabela utilizada no Browse
	 oObjBrow:SetMenuDef(cRotUsu)
	 oObjBrow:SetWalkThru(.F.)
	 oObjBrow:SetUseFilter(.T.)
	 if type("oObjBrow:lDetails") != "U"
		 oObjBrow:lDetails := .F.
	 endif 
	 oObjBrow:SetExecuteDef(2)		// Elemento do aRotina executado no duplo clique
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'D')" , 'BR_AZUL'    , "Sac com Diretoria       " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'C')" , 'BR_AMARELO' , "Sac com Comercial       " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'F')" , 'BR_PINK'    , "Sac com Financeiro      " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'T')" , 'BR_MARRON'  , "Sac com Técnico         " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'P')" , 'BR_MARRON'  , "Sac com Produção        " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'E')" , 'BR_PRETO'   , "Sac com Expedição       " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'V')" , 'BR_CINZA'   , "Sac com Depósito SP     " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '#')" , 'INSTRUME'   , "Sac com Manutenção     " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'S')" , 'BR_CINZA'   , "Sac com Supri. Compras  " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'R')" , 'BR_LARANJA' , "Sac com Recebimento     " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == '-')" , 'BTCALC'     , "Sac com Contabilidade   " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'A')" , 'ENABLE'     , "Sac com Atendente       " )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '1' .AND. ZQ_FLAG == 'M')" , 'BR_BRANCO'  , "Atendimento com Resposta" )
	 oObjBrow:AddLegend( "(ZQ_STATUS == '2')                     " , 'DISABLE'    , "Sac Encerrado           " )
	 oObjBrow:Activate()	
 	 EndFilBrw("SZQ",aIndexSZQ)     

	 If Select("TMPCLO")<>0
		dbselectarea("TMPCLO")
		dbclosearea()
	 Endif 
	 If Select("TMPHIS")<>0
	 	dbselectarea("TMPHIS")
		dbclosearea()
	 Endif 
	 If Select("TMPLOT")<>0
		dbselectarea("TMPLOT")
		dbclosearea()
	 Endif 
	 If Select("TMPSEL")<>0
		dbselectarea("TMPSEL")
		dbclosearea()
	 Endif 
	 If Select("TMPLOG")<>0
		dbselectarea("TMPLOG")
		dbclosearea()
	 Endif 
	 If Select("TMPABE")<>0
		dbselectarea("TMPABE")
		dbclosearea()
	 Endif 
	 aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })     
	 aEval(Directory("tmp*.fpt"), { |aFile| FERASE(aFile[F_NAME]) })     
	 aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })     
     
Return
                                                                                                             
User Function SACA01_G()
    
    Local cQuery
    
	cQuery :=''
	cQuery = " SELECT ZQ_NUM, ZQ_CLIENTE, A1_NOME,SUBSTRING(SZQ.ZQ_DATA,7,2)+'/'+SUBSTRING(SZQ.ZQ_DATA,5,2)+'/'+SUBSTRING(SZQ.ZQ_DATA,1,4),ZQ_ATENDEN, ZQ_RESP "
	cQuery = cQuery + " FROM "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) "+;
	"LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK)ON (SA1.A1_FILIAL = '"+xFilial("SA1")+"') AND SZQ.ZQ_CLIENTE = SA1.A1_COD AND SA1.D_E_L_E_T_ ='' "
	cQuery = cQuery + " WHERE SZQ.D_E_L_E_T_ ='' AND  (SZQ.ZQ_FILIAL ='"+xFilial("SZQ")+"') AND (SZQ.ZQ_STATUS <>'2') AND (SZQ.ZQ_FLAG ='"+SubStr(cDepart, 1, 1)+"') ORDER BY SZQ.ZQ_NUM "
	TCQUERY cQuery NEW ALIAS "SZQ"
	
	DbSelectArea("SZQ")
 	DbSetOrder(1)
 	DbGotop()

	If !Eof()
	     mBrowse( 6, 1, 22, 75, "SZQ",       ,,, , , aCores, , , , , .f.)
    Endif    
Return
/*
User Function SACA01_F()
 
     Local _cFiltro := ""
     DbSelectArea("SZQ")
     Set Filter To
     
     lFilUtil := .t.
     
     If lFilUtil
     	_cFiltro := '(ZQ_FILIAL == "'+xFilial("SZQ")+'") .AND. (ZQ_STATUS <> "2") .AND. (ZQ_FLAG = "'+SubStr(cDepUsu, 1, 1)+'") '
        Set Filter To &(_cFiltro)
   	 Endif
     
     DbSeek(xFilial("SZQ"))
     
Return()
*/
User Function SACA01_H()
 
     Local _cFiltro := ""
     DbSelectArea("SZQ")
     Set Filter To
     
     lFilUtil := .f.  
     
     If lFilUtil
     	_cFiltro := '(ZQ_FILIAL == "'+xFilial("SZQ")+'") '
        Set Filter To &(_cFiltro)
   	 Endif
     
     DbSeek(xFilial("SZQ"))
     
Return()

User Function SACA01_3(cAlias, nRecno, nOpc)
     If nOpcRot == 1
        If nOpc == 4 //Excluir
           nOpc := 5
        ElseIf nOpc == 5 //Parecer
               nOpc := 6
        ElseIf nOpc == 6 //Encerra
               nOpc := 8
        Endif
     ElseIf nOpcRot == 2
            If nOpc == 4 //Excluir
               nOpc := 5
            ElseIf nOpc == 5 //Encerra
                   nOpc := 8
            Endif
     ElseIf nOpcRot == 3
            If nOpc == 3
            	nOpc := 6 //Parecer
            Elseif  nOpc ==4
            	nOpc := 8 //Encerra
            Endif
     Endif
     u_SACA01_1(cAlias, nRecno, nOpc)
	Return

User Function SACA01_2(cAlias, nRecno, nOpc)
     Local nOpcS   := 0
     Local nOpcE   := 0
     Local aVetOpc := {}
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private nRMe1Sel

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFon1Sel", "oDlg1Sel", "oRMe1Sel", "oBtn1Sel", "oBtn2Sel")
     
     If (SZQ->ZQ_STATUS $ '1' .and. SZQ->ZQ_FLAG $ 'A.M') .or. (Empty(SZQ->ZQ_STATUS))
        aVetOpc := {"Novo SAC", "Altera SAC"}
        nOpcE   := 1
     ElseIf SZQ->ZQ_STATUS $ '2'
            If u_fVerAcsUsr(cRotUsu, 2)
               aAdd(aVetOpc, "Novo SAC")
            Endif
            If u_fVerAcsUsr(cRotUsu, 3)
               aAdd(aVetOpc, "Re-Abre SAC")
            Endif
            nOpcE   := 2
     ElseIf SZQ->ZQ_STATUS $ '1' .and. !SZQ->ZQ_FLAG $ 'A.M' .and. cDepart $ 'DIR.ATE.INF'
            //MsgStop("Atenção esse SAC não pode ser alterado.")
            //Return
            If u_fVerAcsUsr(cRotUsu, 2)
               aAdd(aVetOpc, "Novo SAC")
               aAdd(aVetOpc, "Altera SAC")
            Endif
            nOpcE := 1
            //u_SACA01_1(cAlias, nRecno, 3)
     Endif
     If Len(aVetOpc) > 0
        /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
        ±± Definicao do Dialog e todos os seus componentes.                        ±±
        Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
        oFon1Sel   := TFont():New( "MS Sans Serif",0,-16,,.T.,0,,700,.F.,.F.,,,,,, )
        oDlg1Sel   := MSDialog():New( 091,232,263,442,"Selecione a opção",,,.F.,,,,,,.T.,,oFon1Sel,.T. )
        GoRM1Sel   := TGroup():New( 004,004,060,096,"",oDlg1Sel,CLR_BLACK,CLR_WHITE,.T.,.F. )
        oRMe1Sel   := TRadMenu():New( 008,010,aVetOpc,{|u| If(PCount()>0,nRMe1Sel:=u,nRMe1Sel)},oDlg1Sel,,,CLR_BLACK,CLR_WHITE,"",,,072,18,,.F.,.F.,.T. )
        oBtn1Sel   := TButton():New( 064,059,"Sair"     , oDlg1Sel,{ || oDlg1Sel:End()            }, 037,012,,,,.T.,,"",,,,.F. )
        oBtn2Sel   := TButton():New( 064,004,"Confirma" , oDlg1Sel,{ || nOpcS := 1, oDlg1Sel:End()}, 037,012,,,,.T.,,"",,,,.F. )

        oDlg1Sel:Activate(,,,.T.)
        If nOpcS == 1
           If nOpcE == 1
              If nRMe1Sel == 1
                 nOpc := 3
              Else
                 nOpc := 4
              Endif
           Else
              If nRMe1Sel == 1
                 nOpc := 3
              Else
                 nOpc := 4
              Endif
           Endif
           u_SACA01_1(cAlias, nRecno, nOpc)
        Endif
     Endif
Return

User Function SACA01_1(cAlias, nRecno, nOpc)
     Local aFol1Sac := Iif(nOpc == 6, Iif(nOpc == 6 .and. SZQ->ZQ_FLAG $ 'R.M.A', {"Itens", "Custos", "Parecer", "Histórico", "Devolução", "Resumo" }, {"Itens", "Custos", "Parecer", "Histórico","Resumo"} ), {"Itens", "Custos", "Diagnóstico/Solução", "Histórico","Resumo"})
     Local nOpcSac  := Iif(nOpc == 2 .or. nOpc == 6, 0, Iif(nOpc == 4 .and. SZQ->ZQ_FLAG $ 'A.M', GD_INSERT+GD_DELETE+GD_UPDATE, GD_INSERT+GD_DELETE+GD_UPDATE))
     Local nY
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cGet1Sac   := Iif(nOpc == 3, U_NUMSEQLOT("SZQ", 6), SZQ->ZQ_NUM )
     Private dGet2Sac   := Iif(nOpc == 3, dDataBase                 , SZQ->ZQ_DATA )
     Private cGet3Sac   := Iif(nOpc == 3, space(6)                  , SZQ->ZQ_CLIENTE )
     Private cGet4Sac   := Iif(nOpc == 3, Space(40)                 , Posicione("SA1", 1, xFilial("SA1")+cGet3Sac, "A1_NOME") )
     Private cGet5Sac   := Iif(nOpc == 3, Space(20)                 , Posicione("SA1", 1, xFilial("SA1")+cGet3Sac, "A1_DDD")+'-'+Posicione("SA1", 1, xFilial("SA1")+cGet3Sac, "A1_TEL") )
     Private cGet6Sac   := Iif(nOpc == 3, Space(20)                 , Posicione("SA1", 1, xFilial("SA1")+cGet3Sac, "A1_CONTATO") )
     Private cGet7Sac   := Iif(nOpc == 3, cUserName                 , SZQ->ZQ_ATENDEN)
     Private cGet8Sac   := Iif(nOpc == 3, Time()                    , SZQ->ZQ_HINI)
     Private cGet9Sac   := Iif(nOpc == 3, Space(3)                  , Iif(Len(Alltrim(Posicione("AC9", 2, xFilial("AC9")+'SZQ'+xFilial("SZQ")+SZQ->ZQ_NUM, "AC9_CODENT"))) <>0, "SIM","NÃO"))
     Private cGetASac   := Iif(nOpc == 3, Space(6)                  , Posicione("SZR", 1, xFilial("SZR")+SZQ->ZQ_NUM  , "ZR_ASSUNTO") )
     Private cGetBSac   := Iif(nOpc == 3, Space(15)                 , Posicione("SX5", 1, xFilial("SX5")+'T1'+cGetASac, "X5_DESCRI") )
     Private cGetCSac   := Iif(nOpc == 3, Space(6)                  , Posicione("SZR", 1, xFilial("SZR")+SZQ->ZQ_NUM  , "ZR_OCORREN") )
     Private cGetDSac   := Iif(nOpc == 3, Space(30)                 , Posicione("SU9", 1, xFilial("SU9")+cGetASac+cGetCSac, "U9_DESC") )
     Private nGetESac   := Iif(nOpc == 3, 0                         , SZQ->ZQ_CUSDEV)
     Private nGetFSac   := Iif(nOpc == 3, 0                         , SZQ->ZQ_CUSFRE)
     Private nGetGSac   := Iif(nOpc == 3, 0                         , SZQ->ZQ_CUSFIN)
     Private nGetHSac   := Iif(nOpc == 3, 0                         , SZQ->ZQ_CUSDEV + SZQ->ZQ_CUSFRE + SZQ->ZQ_CUSFIN)
     Private cMul1Sac   := Iif(nOpc == 3,                           , Posicione("SZS", 1, xFilial("SZS")+SZQ->ZQ_NUM, "ZS_PARECER") )
     Private cSay1Sac   := Space(1)
     Private cSay2Sac   := Space(1)
     Private cSay3Sac   := Space(1)
     Private cSay4Sac   := Space(1)
     Private cSay5Sac   := Space(1)
     Private cSay6Sac   := Space(1)
     Private cSay7Sac   := Space(1)
     Private cSay8Sac   := Space(1)
     Private cSayASac   := Space(1)
     Private cSayCSac   := Space(1)
     Private aPageSac   := {}
//   Private nCBo1Sac   := Iif(nOpc == 3, 'Reclamação', Iif(SZQ->ZQ_TIPOSAC == '1', 'Reclamação', 'Sugestão') )
     Private nCBo1Sac   := Iif(nOpc == 3, 'Reclamação', Iif(SZQ->ZQ_TIPOSAC == '1', 'Reclamação', Iif(SZQ->ZQ_TIPOSAC == '2', 'Sugestão', Iif(SZQ->ZQ_TIPOSAC == '3', 'Comodato', Iif(SZQ->ZQ_TIPOSAC == '4', 'Outros', 'Interno') ) ) ) )
     Private nCBo3Sac   := Iif(nOpc == 3, 'Sem Dev.', Iif(SZQ->ZQ_TPABAT == '2', 'NCC', Iif(SZQ->ZQ_TPABAT == '3', 'AB-', Iif(SZQ->ZQ_TPABAT == '4', 'NCC e AB-', '1') ) ) )
     Private cOpcBPro   := ''
     Private aCpoAGd    := {}
     Private aCoBrw1Sac := {}
     Private aHoBrw1Sac := {}
     Private noBrw1Sac  := 0
     Private aCoBrw2Sac := {}
     Private aHoBrw2Sac := {}
     Private aHoBrw3Sac := {}
     Private noBrw2Sac  := 0
     Private aCpoAGd2   := {}
     Private nGetISac   := CToD("  /  /  ")
     Private oMul1Sac
     Private cMul2Sac
     Private oMul2Sac
     Private cMul3Sac
     Private oMul3Sac
     Private nCBo2Sac
     //Devolução (Folder 5)
     Private oSayKSac   := Space(1)
     Private oGetESac
     Private nGetKSac   := space(09)
     Private nGetQSac   := space(45)
     Private cGetRSac   := space(100)
     Private oSayLSac   := Space(1)
     Private oGetLSac
     Private nGetLSac   := space(03)
     Private oSayMSac   := Space(1)
     Private oGetMSac
     Private nGetMSac   := CToD("  /  /  ")
     Private oSayNSac
     Private cSayNSac   := Iif(nOpc == 3, Space(15), Iif(Empty( Alltrim(SZQ->ZQ_FNC) ), Space(15), TransForm(Alltrim(SZQ->ZQ_FNC), "@R 99999999999/9999") ) )
     Private oBtn1Dev
     Private oBtn2Dev
     Private oBtn3Dev
     Private oBtn4Dev     
     Private oBtn5Dev
     Private oBtn6Dev
     //adicionado dyego
     Private oGetOSac
     //Resumo (Folder 6)
     Private oSayRSac   
     Private oGetRSac
     Private nGetRSac  
     Private oSaySSac   
     Private oGetSSac
     Private nGetSSac  
     Private oSayTSac   
     Private oGetTSac
     Private nGetTSac  
     Private oSayUSac   
     Private oGetUSac
     Private nGetUSac  
     Private oSayVSac   
     Private oGetVSac
     Private nGetVSac  
     Private oSayXSac   
     Private oGetXSac
     Private nGetXSac  
     Private oSayYSac   
     Private oGetYSac
     Private nGetYSac
     Private oTempTbl01
     Private oTempTbl02
     Private oTempTbl03
     Private oTempTbl04
     Private oTempTbl05

     // inicializando
     _cCombo2 := nGetPSac[1]
     _cCombo := nGetOSac[2]

     If nOpc == 3 // INCLUSÃO NOVO SAC
        //LGS#20200211 - Adequação de release 12.1.25 e posteriores
        //Set Key VK_F4 TO ShowF4("F")
        SetKey( VK_F4, { || ShowF4("F") } )
        //Set Key VK_F5 TO ShowF5()
        SetKey( VK_F5, { || ShowF5() } )
        // alterado dyego
        aCpoAGd := {"ZR_PRODUTO", "ZR_QTD", "ZR_LOTE", "ZR_QAPRRET","ZR_QTDABAT"}
     ElseIf nOpc == 4 //ALTERAÇÃO / RE-ABERTURA DE SAC
            //LGS#20200211 - Adequação de release 12.1.25 e posteriores
            //Set Key VK_F4 TO ShowF4("F")
            SetKey( VK_F4, { || ShowF4("F") } )
            //Set Key VK_F5 TO ShowF5()
            SetKey( VK_F5, { || ShowF5() } )
            If SZQ->ZQ_STATUS == '1' 
               If !SZQ->ZQ_FLAG   $ 'A.M'
                  If !cDepart $ 'ATE.INF.DIR'
                     MsgStop("O Status desse SAC não permite a alteração.")
                     Return
                  Endif                                       
                  //alterado dyego
                  aCpoAGd := {"ZR_PRODUTO", "ZR_QTD", "ZR_LOTE", "ZR_QAPRRET","ZR_QTDABAT"}
               Else
                  //alterado dyego
                  aCpoAGd := {"ZR_PRODUTO", "ZR_QTD", "ZR_LOTE", "ZR_QAPRRET","ZR_QTDABAT"}
               Endif
            Else
               If !cDepart $ 'ATE.INF.DIR' //Re-abre o SAC
                  MsgStop("Esse SAC já se encontra encerrado. Contactar Atendimento")
                  Return
               Else
                  //alterado dyego
                  aCpoAGd := {"ZR_PRODUTO", "ZR_QTD", "ZR_LOTE", "ZR_QAPRRET","ZR_QTDABAT"}
               Endif
            Endif
     ElseIf nOpc == 5 //EXCLUSÃO DO SAC
            If SZQ->ZQ_STATUS == '1' 
               If !SZQ->ZQ_FLAG $ 'A.M'
                  MsgStop("O Status desse SAC não permite a exclusão.")
                  Return
               Endif
            Else
               MsgStop("Esse SAC já se encontra encerrado.")
               Return
            Endif
     ElseIf nOpc == 6 //PARECER DO SAC                                                                      
            If SZQ->ZQ_STATUS == '2'
               MsgStop("O Status desse SAC não permite informar o parecer.")
               Return
            Else
               nPosSAC := aScan( aEnvSac, { |x| Alltrim(x[1])== cDepart} )
               If nPosSAC > 0
                  If aEnvSac[nPosSAC][1] == cDepart
                     If !aEnvSac[nPosSAC][2] $ SZQ->ZQ_FLAG
                        MsgStop("O Status desse SAC não permite informar o parecer.")
                        Return
                     Endif
                  Else
                     MsgStop("O Status desse SAC não permite informar o parecer.")
                     Return
                  Endif
               Else
                  If !SZQ->ZQ_FLAG $ 'A.M'
                     If !cDepart == 'INF'
                        MsgStop("O Status do departamento do usuário não permite informar o parecer.")
                        Return
                     Endif
                  Else
                     MsgStop("O Status desse SAC não permite informar o parecer.")
                     Return
                  Endif
               Endif
            Endif
     ElseIf nOpc == 8 //ENCERRAMENTO DO SAC
            If SZQ->ZQ_STATUS == '1' 
               If !SZQ->ZQ_FLAG $ 'A.M.F'
                  MsgStop("O Status desse SAC não permite o encerramento.")
                  Return
               Endif
               cVarATE := ""
               cVarDIA := ""
               DbSelectArea("SZS")
               DbSetOrder(1)
               DbSeek(xFilial("SZS")+cGet1Sac, .t.)
               If Found()
                  While !Eof() .and. SZS->ZS_NUM == cGet1Sac
                        If SZS->ZS_LOG $ 'ATE'
                           cVarATE += SZS->ZS_PARECER
                           cVarATE += CHR(13)+CHR(10)
                           cVarATE += CHR(13)+CHR(10)
                        ElseIf SZS->ZS_LOG $ 'DIA'
                               cVarDIA += SZS->ZS_PARECER
                               cVarDIA += CHR(13)+CHR(10)
                               cVarDIA += CHR(13)+CHR(10)
                        Endif
                        DbSelectArea("SZS")
                        DbSkip()
                  EndDo
               Endif
               If !Empty(Alltrim(cVarDIA))
                  cMul2Sac := cVarDIA
               Else
                  If !Empty(Alltrim(cVarATE))
                     cMul2Sac := cVarATE
                  Endif
               Endif
            Else
               MsgStop("Esse SAC já se encontra encerrado.")
               Return
            Endif
     Endif

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFon1Sac", "oFon2Sac", "oDlg1Sac", "oBtn1Sac", "oBtn2Sac", "oBtn3Sac", "oBtn4Sac", "oBtn5Sac", "oBtn6Sac")
     SetPrvt("oGrp2Sac", "oSay1Sac", "oSay2Sac", "oSay3Sac", "oGet1Sac", "oGet2Sac", "oCBo1Sac", "oGrp3Sac", "oSay4Sac")
     SetPrvt("oGet3Sac", "oGet4Sac", "oGet5Sac", "oGet6Sac", "oGrp4Sac", "oSay6Sac", "oSay7Sac", "oSay8Sac", "oGet7Sac")
     SetPrvt("oFld1Sac", "cMul1Sac", "oBrw1Sac", "oSayASac", "oGetASac", "oGetBSac", "oSayCSac", "oGetCSac", "oGetDSac")
     SetPrvt("oCBo2Sac", "oSay9Sac", "oGet9Sac", "oCBo3Sac", "oSayDSac")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFon1Sac   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oFon2Sac   := TFont():New( "MS Sans Serif", 0, -13, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1Sac   := MSDialog():New( 091, 232, 650, 955, "Atendimento ao Cliente", , , .F., , , , , , .T., , , .T. )

         oGrp1Sac   := TGroup():New( 000, 004, 156, 360, "Atendimento", oDlg1Sac, CLR_HBLUE, CLR_WHITE, .T., .F. )
         oGrp2Sac   := TGroup():New( 008, 008, 033, 356, "Dados do Sac", oGrp1Sac, CLR_RED, CLR_WHITE, .T., .F. )
         oSay1Sac   := TSay():New( 018, 010, {||"Numero:"}             , oGrp2Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 008)
         oGet1Sac   := TGet():New( 016, 042, {|u| If(PCount() > 0, cGet1Sac := u, cGet1Sac)}, oGrp2Sac, 032, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "cGet1Sac", , )
         oSay2Sac   := TSay():New( 018, 082, {||"Data:"}               , oGrp2Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 008)
         oGet2Sac   := TGet():New( 016, 104, {|u| If(PCount() > 0, dGet2Sac := u, dGet2Sac)}, oGrp2Sac, 044, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "dGet2Sac", , )

	     oSayDSac   := TSay():New( 018, 152, {||"Tp. Desconto:"}       , oGrp2Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 008)
    	 oCBo3Sac   := TComboBox():New( 016, 203, {|u| If(PCount() > 0, nCBo3Sac := u, nCBo3Sac)}, {"Sem Dev.","NCC", "AB-", "NCC e AB-"}, 050, 012, oGrp2Sac, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Sac, "", , , , , , , nCBo3Sac )

         oSay3Sac   := TSay():New( 018, 260, {||"Tp. SAC:"}            , oGrp2Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
         oCBo1Sac   := TComboBox():New( 016, 294, {|u| If(PCount() > 0, nCBo1Sac := u, nCBo1Sac)}, {"", "Reclamação", "Sugestão", "Comodato","Outros", "Interno"}, 060, 012, oGrp2Sac, , , , CLR_BLACK, CLR_WHITE, .T., oFon2Sac, "", , , , , , , nCBo1Sac )
         oGrp3Sac   := TGroup():New( 035, 008, 060, 356, "Dados do Cliente", oGrp1Sac, CLR_RED, CLR_WHITE, .T., .F. )
         oSay4Sac   := TSay():New( 045, 010, {||"Codigo:"}             , oGrp3Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 008)
         oGet3Sac   := TGet():New( 043, 042, {|u| If(PCount() > 0, cGet3Sac := u, cGet3Sac)}, oGrp3Sac, 032, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc==3, .F., .T.), .F., "CLI"   , "cGet3Sac", , ) //Código
         oGet3Sac:bValid := { || fValClient() }
         oGet4Sac   := TGet():New( 043, 088, {|u| If(PCount() > 0, cGet4Sac := u, cGet4Sac)}, oGrp3Sac, 090, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T.                   , .F., ""      , "cGet4Sac", , ) //Nome
         oSay5Sac   := TSay():New( 045, 186, {||"Fone:"}               , oGrp3Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 008)
         oGet5Sac   := TGet():New( 043, 210, {|u| If(PCount() > 0, cGet5Sac := u, cGet5Sac)}, oGrp3Sac, 064, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T.                   , .F., ""      , "cGet5Sac", , ) //Telefone
         oGet6Sac   := TGet():New( 043, 280, {|u| If(PCount() > 0, cGet6Sac := u, cGet6Sac)}, oGrp3Sac, 068, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc==3, .F., .T.), .F., ""      , "cGet6Sac", , ) //Contato
         oGrp4Sac   := TGroup():New( 062, 008, 152, 356, "Dados do Atendimento", oGrp1Sac, CLR_RED, CLR_WHITE, .T., .F. )
         oSay6Sac   := TSay():New( 072, 010, {||"Atendente:"}          , oGrp4Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 008)
         oGet7Sac   := TGet():New( 070, 054, {|u| If(PCount() > 0, cGet7Sac := u, cGet7Sac)}, oGrp4Sac, 076, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "cGet7Sac", , )
         oSay7Sac   := TSay():New( 072, 146, {||"Hr. Inicio:"}         , oGrp4Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008) 
         oGet8Sac   := TGet():New( 070, 186, {|u| If(PCount() > 0, cGet8Sac := u, cGet8Sac)}, oGrp4Sac, 036, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "cGet8Sac", , )
         oSayASac   := TSay():New( 088, 010, {||"Assunto:"}            , oGrp4Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 008)
         oGetASac   := TGet():New( 086, 042, {|u| If(PCount() > 0, cGetASac := u, cGetASac)}, oGrp4Sac, 028, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc==3, .F., .F.), .F., "T1"    , "cGetASac", , )    //Iif(nOpc==3, .F., .T.)
         oSay9Sac   := TSay():New( 072, 245, {||"Anexo:"}              , oGrp4Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 036, 008)
         oGet9Sac   := TGet():New( 070, 275, {|u| If(PCount() > 0, cGet9Sac := u, cGet9Sac)}, oGrp4Sac, 025, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T.                   , .F., ""      , "cGet9Sac", , ) //Anexo
         oGetASac:bValid := { || fValAssunt() }
         oGetBSac   := TGet():New( 086, 088, {|u| If(PCount() > 0, cGetBSac := u, cGetBSac)}, oGrp4Sac, 060, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T.                   , .F., ""      , "cGetBSac", , )
         oSayCSac   := TSay():New( 088, 155, {||"Ocorrência:"}         , oGrp4Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 008)
         oGetCSac   := TGet():New( 086, 200, {|u| If(PCount() > 0, cGetCSac := u, cGetCSac)}, oGrp4Sac, 028, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc==3, .F., .F.), .F., "SU9XXY", "cGetCSac", , )
         oGetCSac:bValid := { || fValOcorre() }
         oGetDSac   := TGet():New( 086, 246, {|u| If(PCount() > 0, cGetDSac := u, cGetDSac)}, oGrp4Sac, 100, 010, '', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T.                   , .F., ""      , "cGetDSac", , )
         oSay8Sac   := TSay():New( 102, 010, {||"Ocorrência/Problema:"}, oGrp4Sac, , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 080, 008)
         oMul1Sac   := TMultiGet():New( 110, 010, {|u| If(PCount() > 0, cMul1Sac := u, cMul1Sac)}, oGrp4Sac, 344, 040, oFon2Sac, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., Iif(nOpc==3, .F., .T.), , , .F., , )
     oFol1Sac   := TFolder():New( 160, 004, aFol1Sac, aPageSac, oDlg1Sac, , , , .T., .F., 356, 100, )
               
     //Folder 1
     MHoBrw1Sac()
     MCoBrw1Sac(nOpc)

   	//incluso por dyego   inicio   - RETIRADO POR DETERMINACAO DO GUSTAVO                               
	/*If (SZQ->ZQ_FLAG $ 'R' .and. nOpc == 6 )   .OR. @cDepUsu $ 'RECEBIMENTO'                             
      oBrw1Sac   := MsNewGetDados():New(001, 002, 1, 1, nOpcSAC, 'AllwaysTrue()', 'AllwaysTrue()', '+ZR_SEQITEM', aCpoAGd, 1, 999, 'u_fSacFVal("V")', '', 'AllwaysTrue()', oFol1Sac:aDialogs[1], aHoBrw1Sac, aCoBrw1Sac, {|| u_GChanSAC() } ) //.Disable()
   	 Else
        oBrw1Sac   := MsNewGetDados():New(001, 002, 85, 354, nOpcSAC, 'AllwaysTrue()', 'AllwaysTrue()', '+ZR_SEQITEM', aCpoAGd, 1, 999, 'u_fSacFVal("V")', '', 'AllwaysTrue()', oFol1Sac:aDialogs[1], aHoBrw1Sac, aCoBrw1Sac, {|| u_GChanSAC() } )  
	 Endif //fim
     */
     
	 oBrw1Sac   := MsNewGetDados():New(001, 002, 85, 354, nOpcSAC, 'AllwaysTrue()', 'AllwaysTrue()', '+ZR_SEQITEM', aCpoAGd, 1, 999, 'u_fSacFVal("V")', '', 'AllwaysTrue()', oFol1Sac:aDialogs[1], aHoBrw1Sac, aCoBrw1Sac, {|| u_GChanSAC() } )  

     If nOpc <> 2 .and. SZQ->ZQ_FLAG $ 'T'
        oBtn3Sac   := TButton():New( 264, 183, "FNC"   , oDlg1Sac, {|| fGeraFNC()}     , 056, 012, , oFon1Sac, , .T., , "", , , , .F. )
        If !Empty(cSayNSac)
           oBtn3Sac:lReadOnly := .t.
        Endif
     Endif   
     If (nOpc == 3 .or. nOpc == 4) .and. (cDepart == 'ATE')
	     oCBo1Sac:lReadOnly := .f.  
         oCBo3Sac:lReadOnly := .f.  	
     Else
	     oCBo1Sac:lReadOnly := .t.  
         oCBo3Sac:lReadOnly := .t.  	
	 Endif
     oSayNSac   := TSay():New( 264, 010, {|| cSayNSac }, oDlg1Sac, , oFon2Sac, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 080, 008)
     If nOpc == 2 .or. nOpc == 3 .or. nOpc == 4 .or. nOpc == 6 .or. nOpc == 8 .or. nOpc == 5
        oBtn5Sac   := TButton():New( 264, 243, "Confirma"  , oDlg1Sac, {|| fGravaSAC(nOpc)}, 056, 012, , oFon1Sac, , .T., , "", , , , .F. )
        oBtn6Sac   := TButton():New( 264, 303, "Sair"      , oDlg1Sac, {|| oDlg1Sac:End() }, 056, 012, , oFon1Sac, , .T., , "", , , , .F. )
     Else
        If SZQ->ZQ_STATUS == 'A.M'
           oBtn2Sac   := TButton():New( 264, 123, "Encaminhar", oDlg1Sac,                     , 056, 012, , oFon1Sac, , .T., , "", , , , .F. )
	    Endif
	 Endif
     
     //Folder 2
     oSayESac   := TSay():New( 003, 002, {||"Custo Devolução:"}          , oFol1Sac:aDialogs[2], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
     oGetESac   := TGet():New( 001, 072, {|u| If(PCount() > 0, nGetESac := u, nGetESac)}, oFol1Sac:aDialogs[2], 060, 010, '@E 999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetESac", , )
     oSayFSac   := TSay():New( 003, 155, {||"Custo Frete:"    }          , oFol1Sac:aDialogs[2], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
     oGetFSac   := TGet():New( 001, 227, {|u| If(PCount() > 0, nGetFSac := u, nGetFSac)}, oFol1Sac:aDialogs[2], 060, 010, '@E 999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .F., .F., "", "nGetFSac", , )
     oSayGSac   := TSay():New( 018, 002, {||"Custo Financeiro:"}         , oFol1Sac:aDialogs[2], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
     oGetGSac   := TGet():New( 016, 072, {|u| If(PCount() > 0, nGetGSac := u, nGetGSac)}, oFol1Sac:aDialogs[2], 060, 010, '@E 999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .F., .F., "", "nGetGSac", , )
     oSayHSac   := TSay():New( 018, 155, {||"Custo Total:"    }          , oFol1Sac:aDialogs[2], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
     oGetHSac   := TGet():New( 016, 227, {|u| If(PCount() > 0, nGetHSac := u, nGetHSac)}, oFol1Sac:aDialogs[2], 060, 010, '@E 999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetHSac", , )
     oGetFSac:bLostFocus := {|| nGetHSac := nGetESac + nGetFSac + nGetGSac }
     oGetGSac:bLostFocus := {|| nGetHSac := nGetESac + nGetFSac + nGetGSac }

     //Folder 3
     oMul2Sac   := TMultiGet():New( 003, 002, {|u| If(PCount() > 0, cMul2Sac := u, cMul2Sac)}, oFol1Sac:aDialogs[3], 349, 060, oFon2Sac, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., Iif(nOpc==3 .or. nOpc==4 .or. nOpc==6 .or. nOpc==8, .F., .T.), , , .F., , )
     oSayISac   := TSay():New( 070, 002, {||"Data Resposta:"    }        , oFol1Sac:aDialogs[3], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
     oGetISac   := TGet():New( 067, 072, {|u| If(PCount() > 0, nGetISac := u, nGetISac)}, oFol1Sac:aDialogs[3], 060, 010, ''             , , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetISac", , )
     If SZQ->ZQ_FLAG $ 'D.C'
        aParSac := {"", "Autoriza", "Não Autoriza"}
     Endif
     If SZQ->ZQ_FLAG $ 'A.T.E.V.F.P.M.S.#.-'
        aParSac := {"", "Procede", "Não Procede"}
        nGetISac := dDataBase
     Endif
     If SZQ->ZQ_FLAG $ 'A.D.C.T.E.V.F.P.M.S.#.-'
        oSayJSac   := TSay():New( 070, 155, {||"Parecer:"    }        , oFol1Sac:aDialogs[3], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
        oCBo2Sac   := TComboBox():New( 067, 227, {|u| If(PCount() > 0, nCBo2Sac := u, nCBo2Sac)}, aParSac, 072, 010, oFol1Sac:aDialogs[3], , , , CLR_BLACK, CLR_WHITE, .T., oFon2Sac, "", , , , , , , nCBo2Sac )
        If nOpc == 2
           oCBo1Sac:lReadOnly := .t.  
           oCBo2Sac:lReadOnly := .t.  
           oCBo3Sac:lReadOnly := .t.  
        Endif
     Endif
     
     //Folder 4
     If nOpc == 3
        oFol1Sac:aDialogs[3]:lActive := .f.
        oFol1Sac:aDialogs[4]:lActive := .f.
        oFol1Sac:aDialogs[5]:lActive := .f.
     Else
        oMul3Sac  := TMultiGet():New( 052, 002, {|u| If(PCount() > 0, cMul3Sac := u, cMul3Sac)}, oFol1Sac:aDialogs[4], 349, 030, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .T., , , .F., ,  )
        oTbl1His()
        DbSelectArea("TMPHIS")
        oBrw1His   := MsSelect():New( "TMPHIS","MARC","",{{"CLOG","","Log",""},{"DTLG","","Data",""},{"HORA","","Hora",""},{"RESP","","Responsavel",""}, {"PRCD","","Procede",""}},.F.,,{003, 002, 050, 349},,, oFol1Sac:aDialogs[4] ) 
        oBrw1His:oBrowse:bChange := { || cMul3Sac := TMPHIS->PARE, oMul3Sac:Refresh() }
     Endif
           
     
     //Folder 5
     If SZQ->ZQ_FLAG $ 'R' .and. nOpc == 6     
     	
        oFol1Sac:bChange := {|| fTrocFold() }
        oSayKSac   := TSay():New( 003, 124, {||"Num. NF:"}, oFol1Sac:aDialogs[5], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 008)
        oGetKSac   := TGet():New( 001, 159, {|u| If(PCount() > 0, nGetKSac := u, nGetKSac)}, oFol1Sac:aDialogs[5], 045, 010, '@R 999999999', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 5 .or. nOpc == 8, .T., .F.), .F., "", "nGetKSac", , )
        oGetKSac:lReadOnly := Iif(SZQ->ZQ_GEREST $ 'S', .T., .F.)
        oSayLSac   := TSay():New( 003, 212, {||"Série:"}    , oFol1Sac:aDialogs[5], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 030, 008)
        oGetLSac   := TGet():New( 001, 235, {|u| If(PCount() > 0, nGetLSac := u, nGetLSac)}, oFol1Sac:aDialogs[5], 030, 010, '@!', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 5 .or. nOpc == 8, .T., .F.), .F., "", "nGetLSac", , )
        oGetLSac:lReadOnly := Iif(SZQ->ZQ_GEREST $ 'S', .T., .F.)
        oSayMSac   := TSay():New( 003, 266, {||"Emissão:"}    , oFol1Sac:aDialogs[5], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 008)
        oGetMSac   := TGet():New( 001, 301, {|u| If(PCount() > 0, nGetMSac := u, nGetMSac)}, oFol1Sac:aDialogs[5], 050, 010, '@!', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 5 .or. nOpc == 8, .T., .F.), .F., "", "nGetMSac", , )
        oGetMSac:lReadOnly := Iif(SZQ->ZQ_GEREST $ 'S', .T., .F.)
      
     	// incluso dyego oGetOSac         290 320
        //ESPECIE SPED ou NFE
		
        oSayRSac   := TSay():New( 016, 001, {||"Men Nota:"}, oFol1Sac:aDialogs[5], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 008)
        oGetRSac   := TGet():New( 014, 038, {|u| If(PCount() > 0, cGetRSac := u, cGetRSac)}, oFol1Sac:aDialogs[5], 100, 010, '@!', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 5 .or. nOpc == 8, .T., .F.), .F., "", "cGetRSac", , )

        oSayQSac   := TSay():New( 016, 140, {||"Chv NFE:"}, oFol1Sac:aDialogs[5], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 008)
        oGetQSac   := TGet():New( 014, 174, {|u| If(PCount() > 0, nGetQSac := u, nGetQSac)}, oFol1Sac:aDialogs[5], 180, 010, '@R 999999999999999999999999999999999999999999999', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , Iif(nOpc == 2 .or. nOpc == 5 .or. nOpc == 8, .T., .F.), .F., "", "nGetQSac", , )


	//(_cCombo $ 'SIM', oGetPSac := 'SPED', oGetPSac := "NFE")        
        
        oSayOSac   := TSay():New( 003, 	001, {||"For. P.:"}    , oFol1Sac:aDialogs[5], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 008)
	  	oGetOSac := TComboBox():New(001,028,{|u|if(PCount()>0,_cCombo:=u,_cCombo)}, nGetOSac,30,20,oFol1Sac:aDialogs[5] ,,{||oGetKSac:lReadOnly := Iif(_cCombo $ 'SIM', .T., .F.),oGetLSac:lReadOnly := Iif(_cCombo $ 'SIM', .T., .F.),oGetMSac:lReadOnly := Iif(_cCombo $ 'SIM', .T., .F.),oGetPSac:lReadOnly := Iif(_cCombo $ 'SIM', .T., .F.),oGetQSac:lReadOnly := Iif(_cCombo $ 'SIM', .T., .F.),nGetQSac:= space(45),  Iif(_cCombo $ 'SIM', _cCombo2 := "SPED", _cCombo2 := _cCombo2 )   },,,,.T.,,,,,,,,,"nGetOSac")
    	oSayPSac   := TSay():New( 003,  059, {||"Especie:"}    , oFol1Sac:aDialogs[5], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 040, 008)
	  	oGetPSac := TComboBox():New(001,091,{|u|if(PCount()>0,_cCombo2:=u,_cCombo2)}, nGetPSac,30,20,oFol1Sac:aDialogs[5] ,,{||oGetQSac:lReadOnly := Iif(_cCombo2 $ 'SPED', .F., .T.), nGetQSac:= space(45)},,,,.T.,,,,,,,,,"nGetPSac")

    
	  //	oGetOSac := TComboBox():New(001,320,{|u|if(PCount()>0,nGetOSac[1]:=u,nGetOSac[1])}, nGetOSac,30,20,oFol1Sac:aDialogs[5] ,,{||Alert('Mudou item da combo')},,,,.T.,,,,,,,,,"nGetOSac")
        
        oGetOSac:lReadOnly := Iif(SZQ->ZQ_GEREST $ 'S', .T., .F.)
        
        //Campos que poderão ser alterados na entrada da NF
		//alterado Dyego
        aCpoAGd2 := {"ZR_ITEMDEV", "ZR_QTDDEV","ZR_QTNFREC","ZR_QTESTOQ", "ZR_QTPERDA",  "ZR_QTREAPR" , "ZR_TES", "ZR_CF"}
        //aCpoAGd2 := {"ZR_ITEMDEV", "ZR_LOCDEV", "ZR_QTDDEV","ZR_QTNFREC","ZR_QTESTOQ", "ZR_QTPERDA",  "ZR_QTREAPR" , "ZR_TES", "ZR_CF"}
                       
        //Montagem do aHeader aHoBrw2Sac
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Item'     , 'D1_ITEM'    , '999'                , 003, 0, "", "", 'C', "", "" } )
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Produto'  , 'ZR_PRODUTO' , '@!R XXX99.99.999-99', 015, 0, "", "", 'C', "", "" } )
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Descrição', 'ZR_DESCPRO' , '@!'                 , 030, 0, "", "", 'C', "", "" } )
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Devol.?'  , 'ZR_ITEMDEV' , '@!'                 , 030, 0, "", "", 'C', "", "" } )
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Local'    , 'ZR_LOCDEV'  , ''                   , 002, 0, "", "", 'C', "", "" } )
        noBrw2Sac++
        //Aadd(aHoBrw2Sac,{'Qtd. SAC' , 'ZR_QTD'     , '@E 9999'            , 004, 0, "", "", 'N', "", "" } ) 
		//noBrw2Sac++
        //Aadd(aHoBrw2Sac,{'Qtd. Dev.', 'ZR_QTDDEV'  , '@E 9999'            , 004, 0, "", "", 'N', "", "" } ) 
        //noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Lote'     , 'ZR_LOTE'    , '@!'                 , 002, 0, "", "", 'C', "", "" } )
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'It. SAC'  , 'ZR_SEQITEM' , 'XX'                 , 002, 0, "", "", 'C', "", "" } )
	 	noBrw2Sac++
		Aadd(aHoBrw2Sac,{'Qtd. Receb. NF.', 'ZR_QTNFREC', PesqPict("SZR","ZR_QTNFREC")  	, 004, 0, "", "", 'N', "", "" } )
        noBrw2Sac++
	 	Aadd(aHoBrw2Sac,{'Qtd. Est. PA.', 'ZR_QTESTOQ'  , PesqPict("SZR","ZR_QTESTOQ")      , 004, 0, "", "", 'N', "", "" } )
        noBrw2Sac++
	 	Aadd(aHoBrw2Sac,{'Qtd. Reaprov.', 'ZR_QTREAPR'  , PesqPict("SZR","ZR_QTREAPR")      , 004, 0, "", "", 'N', "", "" } )
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Qtd. Perda', 'ZR_QTPERDA'  	, PesqPict("SZR","ZR_QTPERDA")      , 004, 0, "", "", 'N', "", "" } ) 
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'Tipo Entrada', 'ZR_TES'  , '@9  '          , 003, 0, "", "", 'N', "", "" } )
        noBrw2Sac++
        Aadd(aHoBrw2Sac,{'C.F.O.P.', 'ZR_CF'  , '@9    '          , 004, 0, "", "", 'N', "", "" } )
        //   noBrw2Sac++
        
        //Montagem do aCols
        nPosSEQ := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_SEQITEM" } )
        nPosPRO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } )
        nPosDES := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_DESCPRO" } )
        nPosQTD := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
        nPosLOT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_LOTE"    } )   

  		//incluso dyego
        nPosNNF := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } )
        nPosSNF := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_SERNF"   } ) 
        nPosItDev := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMORI"   } ) 

	    cLojCli := Posicione("SA1", 1, xFilial("SA1")+cGet3SAC, "A1_LOJA")

        If SZQ->ZQ_GEREST $ 'S'
            nOpcDEV := nOpcSAC
        Else
            For nY := 1 To Len(aCoBrw1Sac)
           		cNfOri  	:= (oBrw1Sac:aCols[nY][nPosNNF])
				cSerOri 	:= (oBrw1Sac:aCols[nY][nPosSNF])
				cItemDev 	:= (oBrw1Sac:aCols[nY][nPosItDev])
        		cCodPro 	:= (oBrw1Sac:aCols[nY][nPosPRO])
        		_tesVenda  := Posicione("SD2", 3, xFilial("SD2")+cNfOri+cSerOri+cGet3SAC+cLojCli+cCodPro+cItemDev, "D2_TES") 
     			_nTEs := Posicione("SF4", 1, xFilial("SF4")+ _tesVenda, "F4_TESDV")            
                _est  := Posicione("SD2", 3, xFilial("SD2")+cNfOri+cSerOri+cGet3SAC+cLojCli+cCodPro+cItemDev, "D2_EST")     
                //alterado dyego - inclusao de 0,0,0,0 no final
             	//  aAdd(aCoBrw2Sac, {StrZero(nY, 3), aCoBrw1Sac[nY][nPosPRO], aCoBrw1Sac[nY][nPosDES], '2', '  ', aCoBrw1Sac[nY][nPosQTD], 0, aCoBrw1Sac[nY][nPosLOT], aCoBrw1Sac[nY][nPosSEQ],.f.})
                aAdd(aCoBrw2Sac, {StrZero(nY, 3), aCoBrw1Sac[nY][nPosPRO], aCoBrw1Sac[nY][nPosDES], '2', armazPA(),                             aCoBrw1Sac[nY][nPosLOT], aCoBrw1Sac[nY][nPosSEQ], 0,0,0,0, _nTEs, retCFOP(_nTEs, _est),.f.})
            Next
            nOpcDEV := GD_UPDATE
        Endif
        nQtdIDe := Len(aCoBrw2Sac)
        //oBrw2Sac   := MsNewGetDados():New(014, 002, 85, 354, nOpcDEV, 'u_SACA01_B("L")', 'AllwaysTrue()', '+D1_ITEM', aCpoAGd2, 1, nQtdIDe, 'u_SACA01_B("C")', '', 'AllwaysTrue()', oFol1Sac:aDialogs[5], aHoBrw2Sac, aCoBrw2Sac,  )
        
        oBrw2Sac   := MsNewGetDados():New(028, 002, 85, 354, nOpcDEV, 'u_SACA01_B("L")', 'AllwaysTrue()', '+D1_ITEM', aCpoAGd2, 1, nQtdIDe, 'u_SACA01_B("C")', '', 'AllwaysTrue()', oFol1Sac:aDialogs[5], aHoBrw2Sac, aCoBrw2Sac,  )
        oBtn1Dev   := TButton():New( 264, 083, "Gera NF", oDlg1Sac, { || MsgRun("Executando, aguarde...","Processamento",{|| fGravNFSAC()  } ) } , 036, 012, , , , .T., , "", , , , .F. )
        oBtn3Dev   := TButton():New( 264, 125, "Replace", oDlg1Sac, { || MsgRun("Atualizando Grid Devolução... !","Processamento",{|| fEstReplac()  } ) } , 036, 012, , , , .T., , "", , , , .F. )
        oBtn4Dev   := TButton():New( 264, 167, "Reaprov.",oDlg1Sac, { || MsgRun("Atualizando Grid Devolução... !","Processamento",{|| fReaReplac()  } ) } , 036, 012, , , , .T., , "", , , , .F. )
		If cGet1Sac $ GetMv("MV_XREAPRO") //'023317.023253.023303.023325.023273.023302.023109.023308'
			oBtn4Dev:lVisible := .t.
		Endif	
        oBtn1Dev:lVisible := .f.
        oBtn3Dev:lVisible := .f.
        oBtn4Dev:lVisible := .f.
        //alterado dyego
        //oBtn2Dev   := TButton():New( 264, 133, "Dividir", oDlg1Sac, {|| fDivIteSAC() }, 036, 012, , , , .T., , "", , , , .F. )
        //oBtn2Dev:lVisible := .f.
     Endif
     
     //Folder 6
     If SZQ->ZQ_FLAG $ 'F.R.C.M.A.V.D.E.T.S.#.-' //.and. (nOpc == 6 .or. nOpc == 4)
         oFol1Sac:bChange := {|| fTrocFold() }
     	 If nOpc ==6 .AND. SZQ->ZQ_FLAG $ 'R'
     	 	z:=6
     	 Else
     	 	z:=5
     	 Endif
     	 oBtn5Dev   := TButton():New( 070, 249, "Gera Espelho.", oFol1Sac:aDialogs[z],{ || MsgRun("Gerando planilha Excel (Espelho da Nota)... !","Processamento",{|| fGeraEspel(1)  } ) } , 045, 012, , , , .T., , "", , , , .f. )
	     oBtn5Dev:lVisible := .t.   

     	 oBtn6Dev   := TButton():New( 070, 299, "Romaneio.", oFol1Sac:aDialogs[z],{ || MsgRun("Gerando Romaneio de Coleta !","Processamento",{|| fGeraRoman()  } ) } , 045, 012, , , , .T., , "", , , , .f. )
	     oBtn6Dev:lVisible := .t.
	     
	     oSayRSac   := TSay():New( 010, 002, {||"Valor dos Produtos:"}    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
	     oSaySSac   := TSay():New( 010, 155, {||"Base Calc ICMS:"    }    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
	     oSayTSac   := TSay():New( 025, 002, {||"Valor do ICMS:"     }    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
	     oSayUSac   := TSay():New( 025, 155, {||"Valor do IPI:"      }    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
	     oSayVSac   := TSay():New( 040, 002, {||"Valor ICMS Subst.:" }    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
	     oSayXSac   := TSay():New( 040, 155, {||"Base ICMS Subst.:"  }    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
	     oSayYSac   := TSay():New( 055, 002, {||"Total da Nota:"     }    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 070, 008)
	     //oSayZSac   := TSay():New( 070, 002, {||"*** ROTINA EM FASE DE HOMOLOGAÇÃO ***"     }    , oFol1Sac:aDialogs[z], , oFon2Sac, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 180, 008)
	     
	     oGetRSac   := TGet():New( 008, 072, {|u| If(PCount() > 0, nGetRSac := u, nGetRSac)}, oFol1Sac:aDialogs[z], 060, 010, '@E 9999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetRSac", , )
	     oGetSSac   := TGet():New( 008, 227, {|u| If(PCount() > 0, nGetSSac := u, nGetSSac)}, oFol1Sac:aDialogs[z], 060, 010, '@E 9999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetSSac", , )
	     oGetTSac   := TGet():New( 024, 072, {|u| If(PCount() > 0, nGetTSac := u, nGetTSac)}, oFol1Sac:aDialogs[z], 060, 010, '@E 9999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetTSac", , )
	     oGetUSac   := TGet():New( 024, 227, {|u| If(PCount() > 0, nGetUSac := u, nGetUSac)}, oFol1Sac:aDialogs[z], 060, 010, '@E 9999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetUSac", , )
	     oGetVSac   := TGet():New( 038, 072, {|u| If(PCount() > 0, nGetVSac := u, nGetVSac)}, oFol1Sac:aDialogs[z], 060, 010, '@E 9999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetVSac", , )
	     oGetXSac   := TGet():New( 038, 227, {|u| If(PCount() > 0, nGetXSac := u, nGetXSac)}, oFol1Sac:aDialogs[z], 060, 010, '@E 9999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetXSac", , )
	     oGetYSac   := TGet():New( 053, 072, {|u| If(PCount() > 0, nGetYSac := u, nGetYSac)}, oFol1Sac:aDialogs[z], 060, 010, '@E 9999,999.99', , CLR_BLACK, CLR_WHITE, oFon2Sac, , , .T., "", , , .F., .F., , .T., .F., "", "nGetYSac", , )
	 Endif	

     oCBo1Sac:SetFocus()
     oDlg1Sac:Activate(, , , .T.)

     If nOpc <> 3
        DbSelectArea("TMPHIS")
        DbCloseArea()
        oTempTbl03:Delete()
     Endif
Return


/*
ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Ä Function  ³ fReaReplac()  - ROTINA PREENCHE DADOS NA ABA DEVOLUÇÃO PARA SACS  Ä
Ä		    '023317.023253.023303.023325.023273.023302.023109.023308' ARATINTAS Ä
Ä		      André 23/07/14                 GetMv("MV_XREAPRO")	            Ä
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/
Static Function fReaReplac()
       Local nY
    Local nPosQTD     := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
    Local nPosQAPRRT  := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QAPRRET" } ) 
    //Local nPosQTREAPR := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTREAPR" } )


    If Len(oBrw2SAC:aCols) < 50
        MsgStop("Funcionalidade disponível apenas para Sacs Maiores que 50 Itens", "Atenção")
    	Return
    Endif
    
    oBtn4Dev:lVisible := .f.    
    For nY := 1 To (Len(oBrw2SAC:aCols))
    	If !oBrw2SAC:aCols[nY][Len(aHoBrw2SAC)+1] //.AND. oBrw2Sac:aCols[nY][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_ITEMDEV'})] $ '1'
 	  		// DEVOLVIDO
 	  		oBrw2SAC:aCols[nY][4]  =  "1"
			// LOCAL DEVOLUÇÃO
			oBrw2SAC:aCols[nY][05] =  '13'
 	  		// QTD NF RECEBIDA
        	oBrw2SAC:aCols[nY][8]  =  oBrw1Sac:aCols[nY][nPosQTD]
			// REAPROVEITAMENTO
			oBrw2SAC:aCols[nY][10] =  oBrw1Sac:aCols[nY][nPosQAPRRT]
		Endif
	Next
    oBrw2SAC:oBrowse:Refresh()
Return

/*
ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Ä Function  ³ fEstReplac()  - ROTINA PREENCHE DADOS NA ABA DEVOLUÇÃO PARA SACS Ä
Ä		      MAIORES DO QUE 50 ITENS PARA FACILITAR A CONFERÊNCIA DO RECEBIM.	Ä
Ä		      André 17/07/14													Ä
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/
Static Function fEstReplac()
       Local nY
    Local nPosQTD := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
    Local nPosQAPRRT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QAPRRET" } )   
    
    If Len(oBrw2SAC:aCols) < 50
        MsgStop("Funcionalidade disponível apenas para Sacs Maiores que 50 Itens", "Atenção")
        Return
    Endif

    For nY := 1 To (Len(oBrw2SAC:aCols))
    	If !oBrw2SAC:aCols[nY][Len(aHoBrw2SAC)+1] //.AND. oBrw2Sac:aCols[nY][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_ITEMDEV'})] $ '1'
 	  		// DEVOLVIDO
 	  		oBrw2SAC:aCols[nY][4]  =  "1"
 	  		// QTD NF RECEBIDA
        	oBrw2SAC:aCols[nY][8]  =  oBrw1Sac:aCols[nY][nPosQTD]
			// QTDE EST PA
			oBrw2SAC:aCols[nY][9]  =  oBrw1Sac:aCols[nY][nPosQAPRRT]
			// PERDA
			oBrw2SAC:aCols[nY][11] = (oBrw1Sac:aCols[nY][nPosQTD] - oBrw1Sac:aCols[nY][nPosQAPRRT])
		Endif
	Next
    oBrw2SAC:oBrowse:Refresh()
Return


/*
ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Ä Function  ³ FGeraRoman()    - RELATORIO PARA AUXILIO DO MOTORISTA / CLIENTE   Ä
Ä		      PARA FACILITAR A CONFERÊNCIA NA COLETA / ENTREGA DAS DEVOLUÇÕES	Ä
Ä		      André 12/08/14													Ä 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/
Static Function FGeraRoman()
	
	U_BRSACR02(1)

	RecLock("SZS", .t.)
    	SZS->ZS_FILIAL  := xFilial("SZS")
        SZS->ZS_NUM     := cGet1Sac
        SZS->ZS_DATA    := dDataBase
        SZS->ZS_HORA    := Time()
        SZS->ZS_LOG     := 'IMP'
        SZS->ZS_RESP    := cUserName
        SZS->ZS_DEPTO   := cDepart
   		SZS->ZS_PARECER := 'IMP - IMPRESSÃO DO ROMANEIO DE COLETA ' 
   	dbselectarea("SZS")
    SZS->(MsUnLock())

Return
/*
ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Ä Function  ³ FGeraEspel()   - ROTINA PREENCHE EM EXCEL OS DADOS PARA GERAÇÃO   Ä
Ä		      DE ESPELHO DE NOTA PARA FACILITAR CONFERÊNCIA E AUXILIAR CLIENTES	Ä
Ä		      André 28/07/14													Ä 
Ä 1  GERA ESPELHO DE NOTA PARA CLIENTES // 2 CARREGA VALORES DO RESUMO DA NOTA  Ä
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/
Static Function FGeraEspel(nOpcRes)
    Local cQry  	 := ""
    Local cQry1 	 := ""
	Local cCFOPEnt   := ""
	Local aMatDad    := {} 
    Local aCabExcel  := {}

    If Len(oBrw1SAC:aCols) <1
    	Return
    Endif
	If nOpcRes =1
	    If !ApOleClient("MSExcel") // testa a interação com o excel.
   			MsgStop("Microsoft Excel não instalado!","Atenção")
		   	Return 
		EndIf
	    If nGetRSac =0 
   			MsgStop("Impossível gerar Planilha com valores zerados!","Atenção")
		   	Return 
	    Endif
	    If Empty(cGet1Sac)
    	    MsgStop("Escolha o Sac Antes de tentar Gerar o Espelho da Nota!", "Atenção")
	 	    Return	
	    Endif
	    If SZQ->ZQ_STATUS ='2'
	        MsgStop("Este Sac já encontra-se encerrado!", "Atenção")
	 	    Return	
	    Endif	
    
	    cQry :=""
		cQry +=" SELECT D2_QTDEDEV,B1_PESBRU,D2_QUANT,D2_COD, RTRIM(ISNULL(Z1_DESCR,''))+' - '+RTRIM(B1_DESC)+' '+ISNULL(Z5_DESCR,'') AS DESCRICAO, D2_POSIPI, D2_CLASFIS AS CST, D2_CF AS CFOP, ZR_QTD AS 'QTDPRETENDIDA',
		cQry +=" D2_PRCVEN, ROUND(ZR_QTD * D2_PRCVEN,2) AS D2_TOTAL, ROUND((D2_BASEICM/(D2_QUANT/ZR_QTD)),2) AS D2_BASEICM, ROUND((D2_VALICM/(D2_QUANT/ZR_QTD)),2) AS D2_VALICM, 
		cQry +=" ROUND((D2_VALIPI/(D2_QUANT/ZR_QTD)),2) AS D2_VALIPI, D2_PICM, D2_IPI, ZR_NUMNF, ZR_SERNF, F4_DUPLIC, F4_TESDV, ROUND((D2_BRICMS/(D2_QUANT/ZR_QTD)),2) AS D2_BASICMSUB, ROUND((D2_ICMSRET/(D2_QUANT/ZR_QTD)),2) AS D2_VALICMSRET "
		cQry +=" FROM "+RetSqlName("SZR")+" SZR WITH(NOLOCK) "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH(NOLOCK) ON D2_FILIAL = '"+xFilial("SD2")+"' AND ZR_NUMNF = D2_DOC AND ZR_SERNF = D2_SERIE AND ZR_PRODUTO = D2_COD AND ZR_ITEMORI = D2_ITEM AND SD2.D_E_L_E_T_ ='' "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' AND (ZR_PRODUTO = B1_COD) AND SB1.D_E_L_E_T_ ='' "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' AND D2_TES = F4_CODIGO AND SF4.D_E_L_E_T_ ='' "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH(NOLOCK) ON Z5_FILIAL = '"+xFilial("SZ5")+"' AND (SUBSTRING(D2_COD,11,2) = Z5_EMB) AND SZ5.D_E_L_E_T_ = ''  "
		cQry +=" LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH(NOLOCK) ON Z1_FILIAL = '"+xFilial("SZ1")+"' AND (SUBSTRING(ZR_PRODUTO,4,2) = Z1_LINHA) AND SZ1.D_E_L_E_T_ = '' "
		cQry +=" WHERE (SZR.D_E_L_E_T_ ='') "
		cQry +=" AND (ZR_FILIAL ='"+xFilial("SZR")+"') "
		cQry +=" AND ZR_NUM ='"+cGet1Sac+"'"
		cQry +=" ORDER BY SZR.ZR_SEQITEM  "

	    TCQuery cQry ALIAS 'TCQ' NEW
    
		DbSelectArea("TCQ")
		dbgotop()
        dTotalPeso := 0
	    aMatDad := {}
	    While !Eof()
	      	cCFOPEnt := Posicione("SF4", 1, xFilial("SF4")+TCQ->F4_TESDV, "F4_CF")  // buscar cfop da tes de devolução 
	      	aadd(aMatDad, { CHR(160)+(TCQ->D2_COD)						 				, ;
	          				CHR(160)+Alltrim(TCQ->DESCRICAO)               				, ;
	                        CHR(160)+Alltrim(TCQ->D2_POSIPI)            				, ;
    	                    CHR(160)+Alltrim(TCQ->CST)               					, ;
        	                CHR(160)+Alltrim(cCFOPEnt)               					, ;
            	            Transform(TCQ->QTDPRETENDIDA,	"@E 9999")     				, ;
                	        Transform(TCQ->D2_PRCVEN,	 	"@E 999,999,999.99999999")	, ;
                    	    Transform(TCQ->D2_TOTAL,	 	"@E 999,999,999.99")	    , ;
	                        Transform(TCQ->D2_BASEICM,	 	"@E 999,999.99")    	 	, ;  
    	                    Transform(TCQ->D2_VALICM,	 	"@E 999,999.99")  	 		, ;
        	                Transform(TCQ->D2_VALIPI,	 	"@E 999,999.99")  	  		, ;
    	                    Transform(TCQ->D2_BASICMSUB,	"@E 999,999.99")  	 		, ;  // INCLUIDO D2_BASEICMSUB 
        	                Transform(TCQ->D2_VALICMSRET,	"@E 999,999.99")  	  		, ;  // INCLUIDO D2_VALICMSRET
	                        Transform(TCQ->D2_PICM,	     	"@E 99.99")	 				, ;
    	                    Transform(TCQ->D2_IPI,	     	"@E 99.99")      	  		, ;
        	                CHR(160)+Alltrim(TCQ->ZR_NUMNF)            					, ;
            	            CHR(160)+Alltrim(TCQ->ZR_SERNF)            					, ;
                	        CHR(160)+Alltrim(TCQ->F4_DUPLIC)               				, ;
                    	    ''															} )//IIF(Alltrim(TCQ->F4_DUPLIC) $ 'S', CHR(160)+'SIM',CHR(160)+'NAO')   } )
	       					dTotalPeso+= TCQ->QTDPRETENDIDA * B1_PESBRU
	       	DbSelectArea("TCQ")
		    DbSkip()

	    Enddo
    
	    DbSelectArea("TCQ")
 		DbCloseArea()
	Endif

    cQry1 := ""
	cQry1 +=" SELECT ROUND(SUM(ZR_QTD * D2_PRCVEN),2)AS VALPRODUTOS, "
    cQry1 +="   ROUND(SUM(D2_BASEICM/(D2_QUANT/ZR_QTD)),2) AS BSCALCICMS, "
    cQry1 +="   ROUND(SUM(D2_VALICM /(D2_QUANT/ZR_QTD)),2) AS VALORICMS, "
    cQry1 +="   ROUND(SUM(D2_VALIPI /(D2_QUANT/ZR_QTD)),2) AS VALORIPI, "
    cQry1 +="   ROUND(SUM(D2_ICMSRET/(D2_QUANT/ZR_QTD)),2) AS VALORICMSSUBST, "
    cQry1 +="   ROUND(SUM(D2_BRICMS /(D2_QUANT/ZR_QTD)),2) AS BASECALCICMSSUBST, " 
    cQry1 +="   ROUND((SUM(ZR_QTD * D2_PRCVEN)+SUM(D2_VALIPI /(D2_QUANT/ZR_QTD))+SUM(D2_ICMSRET/(D2_QUANT/ZR_QTD))),2) AS TOTALDANOTA "
	cQry1 +=" FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK) " 
	cQry1 +=" LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH(NOLOCK) ON F4_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO AND SF4.D_E_L_E_T_ ='' "
	cQry1 +=" LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR WITH(NOLOCK) ON ZR_FILIAL = D2_FILIAL AND ZR_NUMNF = D2_DOC AND ZR_SERNF = D2_SERIE AND ZR_PRODUTO = D2_COD AND ZR_ITEMORI = D2_ITEM AND SZR.D_E_L_E_T_ ='' "
	cQry1 +=" WHERE SD2.D_E_L_E_T_ ='' "
	cQry1 +=" AND ZR_FILIAL ='"+xFilial("SZR")+"'"
	cQry1 +=" AND ZR_NUM ='"+cGet1Sac+"'"  
	cQry1 +=" AND ZR_QTD > 0 " // PARA CASOS DE NCC E AB- QUE GRAVA QTDE 0
		

    TCQuery cQry1 ALIAS 'TCR' NEW
    DbSelectArea("TCR")
	DbGotop()               

   	If nOpcRes =1
	   	If !Eof()
		   	aCabExcel := {}
			AADD(aCabExcel, {"CODIGO"       	,"C", 12, 0}) 
			AADD(aCabExcel, {"DESCRIÇÃO"    	,"C", 50, 0}) 
			AADD(aCabExcel, {"NCM"          	,"C", 12, 0}) 
			AADD(aCabExcel, {"CST"          	,"C", 04, 0}) 
			AADD(aCabExcel, {"CFOP"         	,"C", 04, 0}) 
			AADD(aCabExcel, {"QTD. A DEV."  	,"N", 04, 0})
			AADD(aCabExcel, {"VLR. UNIT."   	,"N", 10, 5})
			AADD(aCabExcel, {"VLR. TOTAL"   	,"N", 08, 2})
			AADD(aCabExcel, {"BASE ICMS "   	,"N", 08, 2})
			AADD(aCabExcel, {"VLR. ICMS "   	,"N", 08, 2})
			AADD(aCabExcel, {"VLR. IPI  "   	,"N", 08, 2})
			AADD(aCabExcel, {"BASE ICMS SUB."	,"N", 08, 2}) // incluido
			AADD(aCabExcel, {"VLR ICMS SUB. "  	,"N", 08, 2}) // incluido
			AADD(aCabExcel, {"ALIQ. ICMS"  		,"N", 04, 2})
			AADD(aCabExcel, {"ALIQ. IPI "  		,"N", 04, 2})
			AADD(aCabExcel, {"NF. ORIG"    		,"C", 06, 0}) 
			AADD(aCabExcel, {"SERIE OR. "  		,"C", 01, 0}) 
			AADD(aCabExcel, {"GEROU FIN."  		,"C", 04, 0}) 

			DlgToExcel({ {"CABECALHO", "* RELATÓRIO DE SUGESTÃO PARA AUXILIO NA EMISSÃO DE NOTA FISCAL DE DEVOLUÇÃO *", {"SAC"   ,"CLIENTE","EMISSÃO","VALOR PROD."   ,"BASE CALC ICMS" ,"VLR. ICMS"   ,"VLR. IPI"   ,"VLR. ICMS SUBST." ,"BASE ICMS SUBST."    ,"TOTAL DA NOTA","PESO BRUTO TOTAL"},;
 								 				   		   												  	   			{CHR(160)+cGet1Sac,cGet4Sac ,Ddatabase,TCR->VALPRODUTOS,TCR->BSCALCICMS  ,TCR->VALORICMS,TCR->VALORIPI,TCR->VALORICMSSUBST,TCR->BASECALCICMSSUBST,TCR->TOTALDANOTA,dTotalPeso}},;
					     {"GETDADOS", "ITENS DA NOTA FISCAL * ESTE RELATÓRIO NÃO EXCLUI A NECESSIDADE DE EMITIR A NOTA FISCAL DE ACORDO COM AS PARTICULARIDADES FISCAIS DE SUA EMPRESA *"+;
							CHR(160)+CHR(13)+CHR(10)+"ATENÇÃO! Os CFOPs AQUI INFORMADOS SÃO DE ENTRADA, ALTERAR PARA CFOPs  DE SAÍDA DE ACORDO COM A PARTICULARIDADES DE VOSSA EMPRESA",;
					      aCabExcel,aMatDad} })			


	    Endif
    
    	RecLock("SZS", .t.)
	    	SZS->ZS_FILIAL  := xFilial("SZS")
	        SZS->ZS_NUM     := cGet1Sac
	        SZS->ZS_DATA    := dDataBase
	        SZS->ZS_HORA    := Time()
	        SZS->ZS_LOG     := 'IMP'
	        SZS->ZS_RESP    := cUserName
       	 	SZS->ZS_DEPTO   := cDepart
			SZS->ZS_PARECER := 'IMP - GERAÇÃO DA PRÉ-NOTA DE AUXILIO AS DEVOLUÇÕES '
		dbselectarea("SZS")
	    MsUnLock()
    Endif
    DbSelectArea("TCR")
	If nOpcRes =2
		If !Eof()
			nGetRSac := ROUND(TCR->VALPRODUTOS,2) 		;oGetRSac:Refresh()
			nGetSSac := ROUND(TCR->BSCALCICMS,2)		;oGetSSac:Refresh()
			nGetTSac := ROUND(TCR->VALORICMS,2)   		;oGetTSac:Refresh()
			nGetUSac := ROUND(TCR->VALORIPI,2)    		;oGetUSac:Refresh()
			nGetVSac := ROUND(TCR->VALORICMSSUBST,2)	;oGetVSac:Refresh()
			nGetXSac := ROUND(TCR->BASECALCICMSSUBST,2)	;oGetXSac:Refresh()
			nGetYSac := ROUND(TCR->TOTALDANOTA,2)		;oGetYSac:Refresh()
		Endif
	Endif
    DbSelectArea("TCR")                                          
 	DbCloseArea()
Return

User Function GChanSAC()
     Local nPosPro 	   := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } )
     Local nPosVal 	   := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_DTVALID" } )
     //Local nPosQtdAbat := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QDTABAT" } )
     If Empty(oBrw1Sac:aCols[oBrw1Sac:oBrowse:nAt][nPosPro])
        oBrw1Sac:aCols[oBrw1Sac:oBrowse:nAt][nPosVal] := Ctod("  /  /  ")
     Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1Sac() - Monta aHeader da MsNewGetDados para o Alias: SZR
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1Sac()
       Local _lOpen        := .F. //LGS#20200211 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200211 - Adequação para release 12.1.25
       
       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200211 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200211 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX3")
       DbSetOrder(1)
       DbSeek("SZR")
       While !Eof() .and. SX3->X3_ARQUIVO == "SZR"
             If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL 
             	// alterado dyego
                If AllTRIM(SX3->X3_CAMPO) $ 'ZR_SEQITEM.ZR_PRODUTO.ZR_DESCPRO.ZR_QTD.ZR_QTDORIG.ZR_PEDIDO.ZR_NUMNF.ZR_SERNF.ZR_VUORI.ZR_VTORI.ZR_LOTE.ZR_DTVALID.ZR_QTDPRO.ZR_RETEN.ZR_ITEMDEV.ZR_QAPRRET.ZR_ITEMORI.ZR_QTDABAT'
                   noBrw1Sac++
                   Aadd(aHoBrw1Sac, { Trim(( _cAliasSX3 )->( X3_TITULO )), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", "", SX3->X3_TIPO, "", "" } )
                Endif
             EndIf
             DbSkip()
       EndDo*/
       DbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(1) )
       ( _cAliasSX3 )->( DbSeek("SZR") )
       While !Eof() .and. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZR"
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .and. cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) 
             	// alterado dyego
                If AllTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ 'ZR_SEQITEM.ZR_PRODUTO.ZR_DESCPRO.ZR_QTD.ZR_QTDORIG.ZR_PEDIDO.ZR_NUMNF.ZR_SERNF.ZR_VUORI.ZR_VTORI.ZR_LOTE.ZR_DTVALID.ZR_QTDPRO.ZR_RETEN.ZR_ITEMDEV.ZR_QAPRRET.ZR_ITEMORI.ZR_QTDABAT'
                   noBrw1Sac++
                   Aadd( aHoBrw1Sac, { ( _cAliasSX3 )->( X3_TITULO ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
                Endif
             EndIf
             DbSkip()
       EndDo       
       /********************************************************************************************************************************/
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1Sac() - Monta aCols da MsNewGetDados para o Alias: SZR
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MCoBrw1Sac(nOpc)
       //Local aAux := {}
       Local nI
       If nOpc == 3
          aAdd(aCoBrw1Sac, Array(noBrw1Sac + 1) )
          For nI := 1 To noBrw1Sac
              aCoBrw1Sac[1][nI] := CriaVar(aHoBrw1Sac[nI][2])
          Next
          aCoBrw1Sac[1][1]           := "01"
          aCoBrw1Sac[1][noBrw1Sac+1] := .F.
       Else
          DbSelectArea("SZR")
          DbSetOrder(1)
          
          If Found()
             While !Eof() .and. (SZR->ZR_FILIAL == SZQ->ZQ_FILIAL) .and. (SZR->ZR_NUM == SZQ->ZQ_NUM)
                   aAdd(aCoBrw1Sac, Array(noBrw1Sac + 1) )
                   For nI := 1 To noBrw1Sac
                       If aHoBrw1Sac[nI][10] $ 'V'
                          aCoBrw1Sac[Len(aCoBrw1Sac)][nI] := CriaVar(aHoBrw1Sac[nI][2])
                       Else
                          aCoBrw1Sac[Len(aCoBrw1Sac)][nI] := FieldGet(FieldPos(aHoBrw1Sac[nI][2]))
                          If Alltrim(aHoBrw1Sac[nI][2]) $ 'ZR_DESCPRO'
                             aCoBrw1Sac[Len(aCoBrw1Sac)][nI] := Posicione("SB1", 1, xFilial("SB1")+aCoBrw1Sac[Len(aCoBrw1Sac)][nI-1], "B1_DESC")
                          Endif
                       Endif
                   Next
                   aCoBrw1Sac[Len(aCoBrw1Sac)][noBrw1Sac + 1] := .f.
                   DbSelectArea("SZR")
                   DbSkip()
             EndDo
          Endif
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fGravaSac() - Gravação dos dados do SAC                          
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fGravaSac(nOpc)  

       Local nPosSEQ := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_SEQITEM" } )
       Local nPosPRO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } )
       Local nPosQTD := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
       
       //alterado dyego
       Local nPosQAPRRT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QAPRRET" } )   
       Local nPosITEMOR := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMORI" } )   

       Local nPosQTDABA := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDABAT" } )   
             
       
       //Local nPosQTNFRE := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTNFREC" } )  
       //Local nPosQTESTO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTESTOQ" } )  
       //Local nPosQTPERD := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTPERDA" } )  
       //Local nPosQTREAP := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTREAPR" } )  
       
       Local nPosQTO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDORIG" } )
       Local nPosPED := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_PEDIDO"  } )
       Local nPosNNF := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } )
       Local nPosSNF := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_SERNF"   } )
       Local nPosVUO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_VUORI"   } )
       Local nPosVUT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_VTORI"   } )
       Local nPosLOT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_LOTE"    } )
       Local nPosVLD := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_DTVALID" } )
       Local nPosQTP := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDPRO"  } )
       Local nPosRET := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_RETEN"   } )
       Local nPosDEV := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMDEV" } ) 

       Local nY
       Local _cOcorrAnt := Posicione("SZR", 1, xFilial("SZR")+SZS->ZS_NUM  , "ZR_OCORREN")
       Local _cAssunAnt := Posicione("SZR", 1, xFilial("SZR")+SZS->ZS_NUM  , "ZR_ASSUNTO") 
   
       If nOpc == 2 //Visualizar
          oDlg1Sac:End()
          //WFMessenger( cUserName, 'lgsouza', 'Encaminhamento de SAC', 'Opção 2: Sac encaminhado para: '+cDepUsu, '0' )
       ElseIf nOpc == 3 //Gravar Atendimento
              //Verificações antes do encerramento do SAC
              //Preenchimento do tipo do SAC
              If Empty(nCBo1Sac)
                 MsgStop("Atenção, o 'Tipo de SAC' não foi preenchido.")
                 Return
              Endif
              //Preenchimento do tipo de Desconto
              If Empty(nCBo3Sac)
                 MsgStop("Atenção, o 'Tipo de Desconto' não foi preenchido.")
                 Return
              Endif
              //Preenchimento do Cliente
              If Empty(cGet3Sac)
                 MsgStop("Atenção, o 'Código do Cliente' não foi preenchido.")
                 Return
              Endif
              //Preenchimento do Contado Cliente
              If Empty(cGet6Sac)
                 MsgStop("Atenção, o 'Contato no Cliente' não foi preenchido.")
                 Return
              Endif
              //Preenchimento do Assunto
              If Empty(cGetASac)
                 MsgStop("Atenção, o 'Código do Assunto' não foi preenchido.")
                 Return
              Endif
              //Preenchimento da Ocorrência
              If Empty(cGetCSac)
                 MsgStop("Atenção, o 'Código da Ocorrência' não foi preenchido.")
                 Return
              Endif
              //Preenchimento do Problema/Ocorrência
              If Empty(cMul1Sac)
                 MsgStop("Atenção, a 'Ocorrência/Problema' não foi preenchido.")
                 Return
              Endif
              //Preenchimento dos itens
              If Len(oBrw1Sac:aCols) <= 0 .or. Empty(oBrw1Sac:aCols[1][nPosPRO])
                 MsgStop("Atenção, não existem itens cadastrado para esse SAC.")
                 Return
              Else
                 lExiIZr := .f. // Controla Itens digitados com quantidade igual a zero
                 For nY := 1 To Len(oBrw1Sac:aCols)
                     If oBrw1Sac:aCols[nY][nPosQTD] <= 0 .and. !oBrw1Sac:aCols[nY][Len(oBrw1Sac:aHeader)+1]  
                        If !Alltrim(nCBo3Sac) $ 'NCC e AB-' 
	                        lExiIZr := .T.
    					Endif
                     Endif
                 Next
                 If lExiIZr
                    MsgStop("Atenção, existe item cadastrado com quantidade igual a zero.")
                    Return
                 Endif
              Endif
              //Encaminha SAC
              aRetEnc := fEncamSac(nOpc)
              cDepEnc := aRetEnc[1]
              nRetEnc := aRetEnc[2]
              Begin Transaction
                    //Gravar SZR - Itens
                    For nY := 1 To Len(oBrw1Sac:aCols)
                        If !Empty(oBrw1Sac:aCols[nY][nPosPRO]) 
                           If !oBrw1Sac:aCols[nY][Len(oBrw1Sac:aHeader)+1] 
                              RecLock("SZR", .t.)
                                 SZR->ZR_FILIAL  := xFilial("SZR")
                                 SZR->ZR_NUM     := cGet1Sac
                                 SZR->ZR_ASSUNTO := cGetASac
                                 SZR->ZR_OCORREN := cGetCSac
                                 SZR->ZR_SEQITEM := oBrw1Sac:aCols[nY][nPosSEQ]
                                 SZR->ZR_PRODUTO := oBrw1Sac:aCols[nY][nPosPRO]
                                 SZR->ZR_QTD     := oBrw1Sac:aCols[nY][nPosQTD]
                                 SZR->ZR_QTDORIG := oBrw1Sac:aCols[nY][nPosQTO]
                                 SZR->ZR_PEDIDO  := oBrw1Sac:aCols[nY][nPosPED]
                                 SZR->ZR_NUMNF   := oBrw1Sac:aCols[nY][nPosNNF]
                                 SZR->ZR_SERNF   := oBrw1Sac:aCols[nY][nPosSNF]
                                 SZR->ZR_VUORI   := oBrw1Sac:aCols[nY][nPosVUO]
                                 SZR->ZR_VTORI   := oBrw1Sac:aCols[nY][nPosVUT]
                                 SZR->ZR_LOTE    := oBrw1Sac:aCols[nY][nPosLOT]
                                 SZR->ZR_DTVALID := oBrw1Sac:aCols[nY][nPosVLD]
                                 SZR->ZR_QTDPRO  := oBrw1Sac:aCols[nY][nPosQTP]
                                 SZR->ZR_RETEN   := oBrw1Sac:aCols[nY][nPosRET]
                                 SZR->ZR_ITEMDEV := oBrw1Sac:aCols[nY][nPosDEV]
                          
                                 //alterado dyego                  
                                 SZR->ZR_QAPRRET := oBrw1Sac:aCols[nY][nPosQAPRRT]    
                                 SZR->ZR_ITEMORI := oBrw1Sac:aCols[nY][nPosITEMOR]    
                     
                                 SZR->ZR_QTDABAT := oBrw1Sac:aCols[nY][nPosQTDABA]    
                                
                                 //SZR->ZR_QTNFREC := oBrw1Sac:aCols[nY][nPosQTNFRE]
                                 //SZR->ZR_QTESTOQ := oBrw1Sac:aCols[nY][nPosQTESTO]
                                 //SZR->ZR_QTPERDA := oBrw1Sac:aCols[nY][nPosQTPERD]
                                 //SZR->ZR_QTREAPR := oBrw1Sac:aCols[nY][nPosQTREAP]
                          
                              dbselectarea("SZR")
                              MsUnLock()
                           Endif
                        Endif
                    Next
                    //Gravar SZQ - Cabeçalho
                    RecLock("SZQ", .t.)
                       SZQ->ZQ_FILIAL  := xFilial("SZQ")
                       SZQ->ZQ_NUM     := cGet1Sac
                       SZQ->ZQ_DATA    := dGet2Sac
                       SZQ->ZQ_TIPOSAC := Iif(nCBo1Sac == 'Reclamação', '1', Iif(nCBo1Sac == 'Sugestão', '2', Iif(nCBo1Sac == 'Comodato', '3', Iif(nCBo1Sac == 'Outros', '4', '5') ) ) ) 
//                     SZQ->ZQ_TIPOSAC := Iif(nCBo1Sac == 'Reclamação', '1', '2')
                       SZQ->ZQ_CLIENTE := cGet3Sac
                       SZQ->ZQ_CONTATO := cGet6Sac
                       SZQ->ZQ_ATENDEN := cGet7Sac
                       SZQ->ZQ_HINI    := cGet8Sac
                       SZQ->ZQ_STATUS  := '1'
                       SZQ->ZQ_FLAG    := Iif( 'Manter' $ cDepEnc, 'A.M', SubStr(cDepEnc, 1, 1) )
                       SZQ->ZQ_CUSDEV  := nGetESac
                       SZQ->ZQ_CUSFRE  := nGetFSac
                       SZQ->ZQ_CUSFIN  := nGetGSac 
                       SZQ->ZQ_TPABAT  := Iif(nCBo3Sac == 'Sem Dev.', '1', Iif(nCBo3Sac == 'NCC', '2', Iif(nCBo3Sac == 'AB-', '3', '4') ) )
                    dbselectarea("SZQ")
                    MsUnLock()
                    //Gravar SZS - Histórico
                    RecLock("SZS", .t.) //Grava abertura
                       SZS->ZS_FILIAL  := xFilial("SZS")
                       SZS->ZS_NUM     := cGet1Sac
                       SZS->ZS_DATA    := dGet2Sac
                       SZS->ZS_HORA    := cGet8Sac
                       SZS->ZS_LOG     := 'ABE'
                       SZS->ZS_RESP    := cUserName
                       SZS->ZS_DEPTO   := cDepart
                       SZS->ZS_PARECER := cMul1Sac    //Parecer tela principal do Problema
                    dbselectarea("SZS")
                    MsUnLock()
                    If !'Manter' $ cDepEnc //Encaminhamento caso o SAC for para outro departamento. Grava qual departamento. Não tem parecer.
                       RecLock("SZS", .t.)
                          SZS->ZS_FILIAL  := xFilial("SZS")
                          SZS->ZS_NUM     := cGet1Sac
                          SZS->ZS_DATA    := dGet2Sac
                          SZS->ZS_HORA    := cGet8Sac
                          SZS->ZS_LOG     := 'ENC'
                          SZS->ZS_RESP    := cUserName
                          SZS->ZS_DEPTO   := cDepart
                          SZS->ZS_PARECER := ''
                       dbselectarea("SZS")
                       MsUnLock()
                       RecLock("SZQ", .f.)
                          SZQ->ZQ_FLAG    := Iif( 'Manter' $ cDepEnc, 'A.M', SubStr(cDepEnc, 1, 1) )
                       	  SZQ->ZQ_TIPOSAC := Iif(nCBo1Sac == 'Reclamação', '1', Iif(nCBo1Sac == 'Sugestão', '2', Iif(nCBo1Sac == 'Comodato', '3', Iif(nCBo1Sac == 'Outros', '4', '5') ) ) )
                          SZQ->ZQ_TPABAT  := Iif(nCBo3Sac == 'Sem Dev.', '1', Iif(nCBo3Sac == 'NCC', '2', Iif(nCBo3Sac == 'AB-', '3', '4') ) )
                       dbselectarea("SZQ") 	
                       MsUnLock()
                    Endif
              
              End Transaction
              //WFMessenger( cUserName, 'lgsouza', 'Encaminhamento de SAC', 'Inclusão: Sac encaminhado para: '+cDepUsu, '0' )
              //Finaliza Tela
              oDlg1Sac:End()
       ElseIf nOpc == 4
              //Encaminha SAC
              aRetEnc := fEncamSac(nOpc)
              cDepEnc := aRetEnc[1]
              nRetEnc := aRetEnc[2]
              //Histórico de Alteração
              RecLock("SZS", .t.)
                 SZS->ZS_FILIAL  := xFilial("SZS")
                 SZS->ZS_NUM     := cGet1Sac
                 SZS->ZS_DATA    := dDataBase
                 SZS->ZS_HORA    := Time()
                 SZS->ZS_LOG     := 'ALT'
                 SZS->ZS_RESP    := cUserName
                 SZS->ZS_DEPTO   := cDepart
	           	 If (!Empty(_cOcorrAnt)) .and. (Alltrim(_cOcorrAnt) <> Alltrim(cGetCSac))
               		SZS->ZS_PARECER :=Dtoc(dDatabase) +' - RECLASSIFICAÇÃO DE OCORRÊNCIA - ANTERIOR : '+ _cOcorrAnt + ' - ' +Substr(Posicione("SU9", 1, xFilial("SU9")+_cAssunAnt+_cOcorrAnt, "U9_DESC"),1,35) 
             	 Else
	                SZS->ZS_PARECER := ''
	             Endif   
	          dbselectarea("SZS")
              MsUnLock()
   	 	      
              //Diagnóstico/Solução
                //1º)Verifica se já existe Diagnóstico/Solução
              //nRecDia := 0
              //DbSelectArea("SZS")
              //DbSetOrder(1)
              //DbSeek(xFilial("SZS")+cGet1Sac, .t.)
              //While !Eof() .and. SZS->ZS_NUM == cGet1Sac
              //      If SZS->ZS_LOG $ 'DIA'
              //         nRecDia := RecNo()
              //      Endif
              //      DbSelectArea("SZS")
              //      DbSkip()
              //EndDo
              
              //Solicitado pela Janaina para que cada gravação de Diagnóstico fosse separada e não juntas como estava. 10/03/2011 - 08:20
              //If nRecDia == 0 //Se For igual a Zero não existe Diagnótico/Solução
                 If !Empty(cMul2SAC) //Verifica se o Diagnótico/Solução foi digitado
                    RecLock("SZS", .t.) //Grava Diagnótico/Solução
                       SZS->ZS_FILIAL  := xFilial("SZS")
                       SZS->ZS_NUM     := cGet1Sac
                       SZS->ZS_DATA    := dDataBase
                       SZS->ZS_HORA    := Time()
                       SZS->ZS_LOG     := 'DIA'
                       SZS->ZS_RESP    := cUserName
                       SZS->ZS_DEPTO   := cDepart
                       If (!Empty(_cOcorrAnt)) .and. (Alltrim(_cOcorrAnt) <> Alltrim(cGetCSac))
           					cAuxSac := cMul2Sac + Chr(13)+Chr(10)
           					cAuxSac += Dtoc(dDatabase) +' - RECLASSIFICAÇÃO DE OCORRÊNCIA - ANTERIOR : '+ _cOcorrAnt + ' - ' +Substr(Posicione("SU9", 1, xFilial("SU9")+_cAssunAnt+_cOcorrAnt, "U9_DESC"),1,35) 
           					SZS->ZS_PARECER := cAuxSac
             	 	   Else
                            SZS->ZS_PARECER := cMul2Sac
                       Endif
                       IF (SZQ->ZQ_FLAG) $ 'D.C.E.V.T.F.M.P.S.#.-' .and. !Empty(nCBo2Sac) 
                 		    SZS->ZS_PROCEDE:= Iif(SubStr(nCBo2Sac, 1, 1) == "N", "N", "S") 
                 	   Endif
                 	dbselectarea("SZS")
                    MsUnLock()
                 Endif
              If nRetEnc <> 0
                 If !'Manter' $ cDepEnc
                    RecLock("SZS", .t.)
                       SZS->ZS_FILIAL  := xFilial("SZS")
                       SZS->ZS_NUM     := cGet1Sac
                       SZS->ZS_DATA    := dDataBase
                       SZS->ZS_HORA    := time()
                       SZS->ZS_LOG     := 'ENC'
                       SZS->ZS_RESP    := cUserName
                       SZS->ZS_DEPTO   := cDepart
                       If (!Empty(_cOcorrAnt)) .and. (Alltrim(_cOcorrAnt) <> Alltrim(cGetCSac))
               				SZS->ZS_PARECER :=Dtoc(dDatabase) +' - RECLASSIFICAÇÃO DE OCORRÊNCIA - ANTERIOR : '+ _cOcorrAnt + ' - ' +Substr(Posicione("SU9", 1, xFilial("SU9")+_cAssunAnt+_cOcorrAnt, "U9_DESC"),1,35) 
             	 	   Else
                            SZS->ZS_PARECER :=''
                       Endif
                    dbselectarea("SZS")
                    MsUnLock()
                 Endif
              Endif
              //Ajustar SZR
              For nY := 1 To Len(oBrw1Sac:aCols)
                  DbSelectArea("SZR")
                  DbSetOrder(1)
                  DbSeek(xFilial("SZR")+cGet1Sac+oBrw1Sac:aCols[nY][nPosSEQ], .t.)
                  If Found()
                     If !oBrw1Sac:aCols[nY][Len(oBrw1Sac:aHeader)+1] 
                        RecLock("SZR", .f.)
                           SZR->ZR_PRODUTO := oBrw1Sac:aCols[nY][nPosPRO]
                           SZR->ZR_QTD     := oBrw1Sac:aCols[nY][nPosQTD]
                           SZR->ZR_QTDORIG := oBrw1Sac:aCols[nY][nPosQTO]
                           SZR->ZR_PEDIDO  := oBrw1Sac:aCols[nY][nPosPED]
                           SZR->ZR_NUMNF   := oBrw1Sac:aCols[nY][nPosNNF]
                           SZR->ZR_SERNF   := oBrw1Sac:aCols[nY][nPosSNF]
                           SZR->ZR_VUORI   := oBrw1Sac:aCols[nY][nPosVUO]
                           SZR->ZR_VTORI   := oBrw1Sac:aCols[nY][nPosVUT]
                           SZR->ZR_LOTE    := oBrw1Sac:aCols[nY][nPosLOT]
                           SZR->ZR_DTVALID := oBrw1Sac:aCols[nY][nPosVLD]
                           SZR->ZR_QTDPRO  := oBrw1Sac:aCols[nY][nPosQTP]
                           SZR->ZR_RETEN   := oBrw1Sac:aCols[nY][nPosRET]
                           SZR->ZR_ITEMDEV := oBrw1Sac:aCols[nY][nPosDEV]
    	      	 	   	   SZR->ZR_ASSUNTO := cGetASac
    				   	   SZR->ZR_OCORREN := cGetCSac
    				   	   
    				   	   //alterado dyego                  
               			   SZR->ZR_QAPRRET := oBrw1Sac:aCols[nY][nPosQAPRRT]    
               			   
               			   //altera dyego 2014.07.16
                           SZR->ZR_ITEMORI := oBrw1Sac:aCols[nY][nPosITEMOR] 
                           SZR->ZR_QTDABAT := oBrw1Sac:aCols[nY][nPosQTDABA]
                        dbselectarea("SZR")      
                        MsUnLock()
                     Else
                        RecLock("SZR", .f.)
                           DbDelete()
                        dbselectarea("SZR")
                        MsUnLock()
                     Endif
                  Else
                     If !oBrw1Sac:aCols[nY][Len(oBrw1Sac:aHeader)+1]
                        RecLock("SZR", .t.)
                           SZR->ZR_FILIAL  := xFilial("SZR")
                           SZR->ZR_NUM     := cGet1Sac
                           SZR->ZR_ASSUNTO := cGetASac
                           SZR->ZR_OCORREN := cGetCSac
                           SZR->ZR_SEQITEM := oBrw1Sac:aCols[nY][nPosSEQ]
                           SZR->ZR_PRODUTO := oBrw1Sac:aCols[nY][nPosPRO]
                           SZR->ZR_QTD     := oBrw1Sac:aCols[nY][nPosQTD]
                           SZR->ZR_QTDORIG := oBrw1Sac:aCols[nY][nPosQTO]
                           SZR->ZR_PEDIDO  := oBrw1Sac:aCols[nY][nPosPED]
                           SZR->ZR_NUMNF   := oBrw1Sac:aCols[nY][nPosNNF]
                           SZR->ZR_SERNF   := oBrw1Sac:aCols[nY][nPosSNF]
                           SZR->ZR_VUORI   := oBrw1Sac:aCols[nY][nPosVUO]
                           SZR->ZR_VTORI   := oBrw1Sac:aCols[nY][nPosVUT]
                           SZR->ZR_LOTE    := oBrw1Sac:aCols[nY][nPosLOT]
                           SZR->ZR_DTVALID := oBrw1Sac:aCols[nY][nPosVLD]
                           SZR->ZR_QTDPRO  := oBrw1Sac:aCols[nY][nPosQTP]
                           SZR->ZR_RETEN   := oBrw1Sac:aCols[nY][nPosRET]
                           SZR->ZR_ITEMDEV := oBrw1Sac:aCols[nY][nPosDEV]
                            //alterado dyego                  
               			   SZR->ZR_QAPRRET := oBrw1Sac:aCols[nY][nPosQAPRRT]   
               			    //altera dyego 2014.07.16
                           SZR->ZR_ITEMORI := oBrw1Sac:aCols[nY][nPosITEMOR]

                           SZR->ZR_QTDABAT := oBrw1Sac:aCols[nY][nPosQTDABA]   
                        dbselectarea("SZR")
                        MsUnLock()
                     Endif
                  Endif
              Next
              //Ajustar SZQ
              RecLock("SZQ", .f.)
                 If SZQ->ZQ_STATUS == '2'
                    SZQ->ZQ_STATUS := '1'
                 Endif
                 If nRetEnc <> 0
                    SZQ->ZQ_FLAG := Iif( 'Manter' $ cDepEnc, Iif(SZQ->ZQ_FLAG $ 'A.M', 'M', SZQ->ZQ_FLAG ), Iif('Atendimento' $ cDepEnc, "A",  SubStr(cDepEnc, 1, 1) ) )
                 Endif
                 SZQ->ZQ_TIPOSAC := Iif(nCBo1Sac == 'Reclamação', '1', Iif(nCBo1Sac == 'Sugestão', '2', Iif(nCBo1Sac == 'Comodato', '3', Iif(nCBo1Sac == 'Outros', '4', '5') ) ) )
                 SZQ->ZQ_TPABAT  := Iif(nCBo3Sac == 'Sem Dev.', '1', Iif(nCBo3Sac == 'NCC', '2', Iif(nCBo3Sac == 'AB-', '3', '4') ) )
              dbselectarea("SZQ") 	 
              MsUnLock()
              //WFMessenger( cUserName, 'lgsouza', 'Encaminhamento de SAC', 'Alteração: Sac encaminhado para: '+cDepUsu, '0' )
              oDlg1Sac:End()
       ElseIf nOpc == 5
              //Excluir Itens
              DbSelectArea("SZR")
              DbSetOrder(1)
              DbSeek(xFilial("SZR")+cGet1Sac, .t.)
              If Found()
                  While !Eof() .and. SZR->ZR_NUM == cGet1Sac
                      RecLock("SZR", .f.)
                          DbDelete()
                      MsUnLock()
                      DbSelectArea("SZR")
                      DbSkip()
                  EndDo                                                                                           
              Endif
              //Excluir Cabeçalho
              DbSelectArea("SZQ")
              RecLock("SZQ", .f.)
                 DbDelete()
              MsUnLock()
              //Excluir Histórico
              DbSelectArea("SZS")
              DbSetOrder(1)
              DbSeek(xFilial('SZS')+cGet1Sac, .t.)
              If Found()
                  While !Eof() .and. SZS->ZS_NUM == cGet1Sac
                      RecLock("SZS", .f.)
                          DbDelete()
                      MsUnLock()
                      DbSelectArea("SZS")
                      DbSkip()
                  EndDo
              Endif
              //WFMessenger( cUserName, 'lgsouza', 'Encaminhamento de SAC', 'Exclusão: Sac encaminhado para: '+cDepUsu, '0' )
              oDlg1Sac:End()
       ElseIf nOpc == 6
              //Se for Recebimento Verificar se foi incluida NFD
              If SZQ->ZQ_FLAG $ 'D.C'
                 If Empty(nCBo2Sac)
                    MsgStop('Atenção, não foi informado se autoriza ou não o SAC.')
                    Return
                 Endif
              Endif
              If SZQ->ZQ_FLAG $ 'E.V.T.F.M.P.S.#.-'
                 If Empty(nCBo2Sac)
                    MsgStop('Atenção, não foi informado se o SAC procede ou não.')
                    Return
                 Endif
              Endif
              If Empty(cMul2Sac)
                 MsgStop('Atenção, não foi informado o parecer do SAC.')
                 Return
              Endif
                                      
              //incluido por dyego 
              //valida se a quantidade da nota recebida é igual a quantidade do sac
              // e a quantidade dos itens recebidos fisicamente sao semelhantes aos itens aprovados no sac
              If SZQ->ZQ_FLAG $ 'R'
                 IF !ValidaSAC()
                 	 Return
                 EndIf
              Endif
              aRetEnc := fEncamSac(nOpc)
              cDepEnc := aRetEnc[1]
              nRetEnc := aRetEnc[2]
              Begin Transaction
                    aDevol := {}
                    If SZQ->ZQ_FLAG $ 'R'
                       For nY := 1 To Len(oBrw2SAC:aCols)
                           If !oBrw2SAC:aCols[nY][Len(aHoBrw2SAC)+1]
                              If oBrw2SAC:aCols[nY][4] $ '1'
                                // aAdd(aDevol, {oBrw2SAC:aCols[nY][9], oBrw2SAC:aCols[nY][5], oBrw2SAC:aCols[nY][7]})
                                //alterado por dyego 
                                 aAdd(aDevol, {oBrw2SAC:aCols[nY][7], oBrw2SAC:aCols[nY][5], 0, oBrw2SAC:aCols[nY][8], oBrw2SAC:aCols[nY][9], oBrw2SAC:aCols[nY][10], oBrw2SAC:aCols[nY][11], oBrw2SAC:aCols[nY][12], oBrw2SAC:aCols[nY][13]})
                              Endif
                           Endif
                       Next
                    Endif
                    If Len(aDevol) > 0
                       For nY := 1 To Len(aDevol)
//                           cQry1 := "UPDATE SZR010 SET ZR_QTDDEV = "+TransForm(aDevol[nY][3], "@E 9999")+", ZR_LOCDEV2 = '"+aDevol[nY][2]+"' WHERE ZR_FILIAL = '"+xFilial("SZQ")+"' AND ZR_NUM = '"+SZQ->ZQ_NUM+"' AND ZR_SEQITEM = '"+aDevol[nY][1]+"' "'
                           
                           
                           //UPDATE SZR010 SET     
                           //alterado dyego
                           cQry1 := "UPDATE "+RetSqlName("SZR")+" SET "     
                           cQry1 +=	"  ZR_QTDDEV  = "+StrTran(TransForm(aDevol[nY][3], '@E 9999999.9999'), ",", ".")+", " //cQry1 +=	"  ZR_QTDDEV  = "+TransForm(aDevol[nY][3] ,"@E 99,999,999.9999")+", "
                           cQry1 +=	"  ZR_QTNFREC = "+StrTran(TransForm(aDevol[nY][4], '@E 9999999.9999'), ",", ".")+", " //cQry1 +=	"  ZR_QTNFREC = "+TransForm(aDevol[nY][4], "@E 99,999,999.9999")+", "
                           cQry1 +=	"  ZR_QTESTOQ = "+StrTran(TransForm(aDevol[nY][5], '@E 9999999.9999'), ",", ".")+", " //cQry1 +=	"  ZR_QTESTOQ = "+TransForm(aDevol[nY][5], "@E 99,999,999.9999")+", "
                           cQry1 +=	"  ZR_QTREAPR = "+StrTran(TransForm(aDevol[nY][6], '@E 9999999.9999'), ",", ".")+", " //cQry1 +=	"  ZR_QTREAPR = "+TransForm(aDevol[nY][6], "@E 99,999,999.9999")+", "
                           cQry1 +=	"  ZR_QTPERDA = "+StrTran(TransForm(aDevol[nY][7], '@E 9999999.9999'), ",", ".")+", " //cQry1 +=	"  ZR_QTPERDA = "+TransForm(aDevol[nY][7], "@E 99,999,999.9999")+", "
                           cQry1 +=	"  ZR_TES 	  = '"+(aDevol[nY][8])+"' , "
                           cQry1 +=	"  ZR_CF 	  = '"+(aDevol[nY][9])+"' , "
                           cQry1 +=	"  ZR_LOCDEV2 = '"+Alltrim(aDevol[nY][2])+"'"       
                       	   cQry1 +=	" WHERE ZR_FILIAL = '"+xFilial("SZQ")+"'"  
                       	   cQry1 +=	" AND D_E_L_E_T_ ='' "
                       	   cQry1 += " AND ZR_NUM = '"+SZQ->ZQ_NUM+"' 
                       	   cQry1 += " AND ZR_SEQITEM = '"+aDevol[nY][1]+"' "
                       				
						   XXX := TCSQLExec(cQry1)		
					       If XXX <> 0
					       	   cNomArq := 'C:\TEMP\ERR'+DTOS(MsDate())+SubStr(Time(), 1, 2)+SubStr(Time(), 4, 2)+'.ERR'
           						MemoWrit(cNomArq, cQry1)
					       Endif
                       				
                          // TCSQLExec(cQry1)
                       Next
                       //fGravNFSAC()
                    Endif
                    //Gravar SZS - Histórico
                    RecLock("SZS", .t.)
                       SZS->ZS_FILIAL  := xFilial("SZS")
                       SZS->ZS_NUM     := cGet1Sac
                       SZS->ZS_DATA    := dDataBase
                       SZS->ZS_HORA    := Time()
                       SZS->ZS_LOG     := cDepart
                       SZS->ZS_RESP    := cUserName
                       SZS->ZS_DEPTO   := cDepart
              	 	   If (!Empty(_cOcorrAnt)) .and. (Alltrim(_cOcorrAnt) <> Alltrim(cGetCSac))
           			   		cAuxSac := IIF(Empty(cMul2Sac),'',(cMul2Sac + Chr(13)+Chr(10)))
                 			cAuxSac += Dtoc(dDatabase) +' - RECLASSIFICAÇÃO DE OCORRÊNCIA - ANTERIOR : '+ _cOcorrAnt + ' - ' +Substr(Posicione("SU9", 1, xFilial("SU9")+_cAssunAnt+_cOcorrAnt, "U9_DESC"),1,35) 
                 	    	SZS->ZS_PARECER := cAuxSac
                 			For nY := 1 To Len(oBrw1Sac:aCols)
                 				RecLock("SZR", .f.) //Alteração da Ocorrência
                 			   		SZR->ZR_ASSUNTO := cGetASac
                 			   		SZR->ZR_OCORREN := cGetCSac
                 			   	dbselectarea("SZR")
                				MsUnLock()
                 			Next
					   Else
                       		SZS->ZS_PARECER := cMul2Sac
       				   Endif
                       IF (SZQ->ZQ_FLAG) $ 'D.C.E.V.T.F.M.P.S.#.-' .and. !Empty(nCBo2Sac) 
                       		SZS->ZS_PROCEDE := Iif(SubStr(nCBo2Sac, 1, 1) == "N", "N", "S") 
                       Endif
                       If cDepart ='DIR' .AND. (SubStr(nCBo2Sac, 1, 1) == "A") .AND. (SZQ->ZQ_TPABAT $ '2.3.4')
				           _emailCOB := emailCobr()
				           u_WFAbatSac(_emailCOB,cGet1Sac)	
               		   Endif	
               		dbselectarea("SZS")
                    MsUnLock()
                    If !'Manter' $ cDepEnc
                       RecLock("SZS", .t.)
                          SZS->ZS_FILIAL  := xFilial("SZS")
                          SZS->ZS_NUM     := cGet1Sac
                          SZS->ZS_DATA    := dDataBase
                          SZS->ZS_HORA    := Time()
                          SZS->ZS_LOG     := 'ENC'
                          SZS->ZS_RESP    := cUserName
                          SZS->ZS_DEPTO   := 'ATE'
                          SZS->ZS_PARECER := ''
                       dbselectarea("SZS")
                       MsUnLock()
                       RecLock("SZQ", .f.)
                          SZQ->ZQ_FLAG := 'A'
                       dbselectarea("SZQ")
                       MsUnLock()
                    Endif
              End Transaction
              //WFMessenger( cUserName, 'lgsouza', 'Encaminhamento de SAC', 'Opção 6: Sac encaminhado para: '+cDepUsu, '0' )
              oDlg1Sac:End()
       ElseIf nOpc == 8   //ENCERRAR
              If Empty(cMul2Sac)
                 If !MsgYesNo("SAC não possui diagnóstico/solução para ser encerrado. Encerra mesmo assim?")
                    Return
                 Endif
              Endif
              If SZQ->ZQ_FLAG $ 'D.C'
                 If Empty(nCBo2Sac)
                    MsgStop('Atenção, não foi informado se autoriza ou não o SAC.')
                    Return
                 Endif
              Endif
              If SZQ->ZQ_FLAG $ 'A.E.V.T.F.M.P.S.#.-'
                 If Empty(nCBo2Sac)
                    MsgStop('Atenção, não foi informado se o SAC procede ou não.')
                    Return
                 Endif
              Endif
              RecLock("SZS", .t.)
                 SZS->ZS_FILIAL  := xFilial("SZS")
                 SZS->ZS_NUM     := cGet1Sac
                 SZS->ZS_DATA    := dDataBase
                 SZS->ZS_HORA    := Time()
                 SZS->ZS_LOG     := 'FIM'
                 SZS->ZS_RESP    := cUserName
                 SZS->ZS_DEPTO   := cDepart
                 SZS->ZS_PARECER := cMul2Sac
                 IF (SZQ->ZQ_FLAG) $ 'A.E.V.T.F.M.P.S.#.-' .and. !Empty(nCBo2Sac) 
                 	SZS->ZS_PROCEDE:= Iif(SubStr(nCBo2Sac, 1, 1) == "N", "N", "S") 
                 Endif
              dbselectarea("SZS")
              MsUnLock()
              RecLock("SZQ", .f.)
                  SZQ->ZQ_STATUS := '2'
                  SZQ->ZQ_PROCEDE:= Substr(SZS->ZS_PROCEDE, 1, 1)
				  SZQ->ZQ_TIPOSAC := Iif(nCBo1Sac == 'Reclamação', '1', Iif(nCBo1Sac == 'Sugestão', '2', Iif(nCBo1Sac == 'Comodato', '3', Iif(nCBo1Sac == 'Outros', '4', '5') ) ) )	
				  SZQ->ZQ_TPABAT  := Iif(nCBo3Sac == 'Sem Dev.', '1', Iif(nCBo3Sac == 'NCC', '2', Iif(nCBo3Sac == 'AB-', '3', '4') ) ) 	
              dbselectarea("SZQ")
              MsUnLock()
              //WFMessenger( cUserName, 'lgsouza', 'Encaminhamento de SAC', 'Opção 8: Sac encaminhado para: '+cDepUsu, '0' )
              oDlg1Sac:End()
       Endif         
       if cGetCSac = '100119' .AND. nOpc == 3
       		cCodUser:= RetCodUsr()
		 	cPara:= "eliana@brasilux.com.br"
			cAssunto := SZR->ZR_NUM+" - Novo SAC. Aberto por: " +substr(Posicione("SZH", 1, xFilial("SZH")+cCodUser, "ZH_NOME"),0,30) +" Ramal 	"+Posicione("SZH", 1, xFilial("SZH")+cCodUser, " ZH_RAMAL")      
			cTexEnc := cMul1Sac
			HD3Mail(cAssunto,cTexEnc,cPara) 
	   endIf
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValClient() - Valida Digitação do código do Cliente
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fValClient()
       If Empty(cGet3Sac)
          MsgStop("Código do cliente não pode ser vazio, verifique!!!!")
          cGet3Sac := space(06)
          cGet4Sac := space(40)
          cGet5Sac := space(20)
          cGet6Sac := space(20)
          oGet3Sac:SetFocus()
          oGet3Sac:Refresh()
          Return .f.
       Else
          DbSelectArea("SA1")
          DbSetOrder(1)
          DbSeek(xFilial("SA1")+cGet3Sac, .t.)
          If Found()
             cGet4Sac := SA1->A1_NOME
             cGet5Sac := SA1->A1_DDD+'-'+SA1->A1_TEL
             cGet6Sac := SA1->A1_CONTATO
             //oGet3Sac:lReadOnly := .T.
          Else
             MsgStop("Cliente não encontrado, verifique!!!!")
             cGet3Sac := space(06)
             cGet4Sac := space(40)
             cGet5Sac := space(20)
             cGet6Sac := space(20)
             oGet3Sac:SetFocus()
          Endif
          oGet3Sac:Refresh()
          oGet4Sac:Refresh()
          oGet5Sac:Refresh()
          oGet6Sac:Refresh()
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValAssunt() - Valida Digitação do código do Assunto
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fValAssunt()
       Local _aRetInf := FwGetSX5( 'T1', cGetASac )
       
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea("SX5")
       DbSetOrder(1)
       DbSeek(xFilial("SX5")+'T1'+cGetASac, .t.)
       If Found()
          cGetBSac := RTRIM(SX5->X5_DESCRI)
          oGetCSac:SetFocus()
       Else
          MsgStop("Assunto não encontrado, verifique!!!!")
          cGetASac := space(06)
          cGetBSac := space(30)
          oGetASac:SetFocus()
       Endif*/
       If Len( _aRetInf ) > 0
          cGetBSac := RTRIM( _aRetInf[1][4] )
          oGetCSac:SetFocus()
       Else
          MsgStop("Assunto não encontrado, verifique!!!!")
          cGetASac := space(06)
          cGetBSac := space(30)
          oGetASac:SetFocus()
       Endif
       oGetASac:Refresh()
       oGetBSac:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValOcorre() - Valida Digitação do código da Ocorrência
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fValOcorre()
       If Empty(cGetCSac)
          oGetASac:Refresh()
       Else
          DbSelectArea("SU9")
          DbSetOrder(1)
          DbSeek(xFilial("SU9")+cGetASac+cGetCSac, .t.)
          If Found()
             cGetDSac := RTRIM(SU9->U9_DESC)
             oMul1Sac:SetFocus()
          Else
             MsgStop("Ocorrência não encontrada, verifique!!!!")
             cGetCSac := space(06)
             cGetDSac := space(30)
             oGetCSac:SetFocus()
          Endif
          oGetCSac:Refresh()
          oGetDSac:Refresh()
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fEncamSac() - Encaminhamento de SAC
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fEncamSac(nOpc)
       Local nOpcEnc   := 0
       Private nRMenu1E
       Private aVetEnc := {}

       SetPrvt("oDlg1Enc", "oRMenu1E", "oBtn1Enc", "oBtn2Enc", "oGRMen1E")

       If nOpc == 3
          aVetEnc := {"Diretoria", "Comercial", "Financeiro", "Tecnico", "Expedição", "Viamix - Depósito SP", "Recebimento", "Produção" ,"Suprimentos - Compras", "#Manutencao","-Contabilidade",  "Manter Pendente"}
          nRMenu1E := Len(aVetEnc)
       Else
          If SZQ->ZQ_FLAG $ 'A.M'
             aVetEnc := {"Diretoria", "Comercial", "Financeiro", "Tecnico", "Expedição", "Viamix - Depósito SP", "Recebimento", "Produção", "Suprimentos - Compras", "#Manutencao","-Contabilidade", "Manter Pendente"}
             nRMenu1E := Len(aVetEnc)
          Else
             If cDepart $ 'DIR.ATE.INF'
                aVetEnc := {"Atendimento", "Diretoria", "Comercial", "Financeiro", "Tecnico", "Expedição", "Viamix - Depósito SP", "Recebimento", "Produção", "Suprimentos - Compras", "#Manutencao","-Contabilidade"}
                nRMenu1E := Len(aVetEnc)
             Else
                aVetEnc := {"Atendimento", "Manter Pendente"}
                nRMenu1E := Len(aVetEnc)
             Endif
          Endif
       Endif
       oDlg1Enc  := MSDialog():New( 001, 001, 250, 199, "Encaminhamento", , , .F., , , , , , .T., , , .T. )
       oGRMen1E  := TGroup():New( 004, 004, 109, 102, "", oDlg1Enc, CLR_BLACK, CLR_WHITE, .T., .F. )
       oRMenu1E  := TRadMenu():New( 008, 008, aVetEnc, {|u| If(PCount() > 0, nRMenu1E := u, nRMenu1E)}, oDlg1Enc, , , CLR_BLACK, CLR_WHITE, "", , , 070, 16, , .F., .F., .T. )
       oBtn1Enc  := TButton():New( 110, 004, "Confirma", oDlg1Enc, { || nOpcEnc := 1, oDlg1Enc:End() }, 037, 012, , , , .T., , "", , , , .F. )
       oBtn2Enc  := TButton():New( 110, 045, "Sair"    , oDlg1Enc, { || nOpcEnc := 0, oDlg1Enc:End() }, 037, 012, , , , .T., , "", , , , .F. )

       oDlg1Enc:Activate(, , , .T.)
       
       If (aVetEnc[nRMenu1E] <> 'Man' .AND. aVetEnc[nRMenu1E] <> 'Ate') .AND. nOpcEnc = 1 
       	  chamMail(aVetEnc[nRMenu1E])
       EndIf
Return({aVetEnc[nRMenu1E], nOpcEnc})

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fSacFVal() - Função para validação de campos da MsNewGetDados
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function fSacFVal(cSacFVal)
     Local nPosPro    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } )
     Local nPosLot    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_LOTE"    } )
     Local nPosQTP    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTDPRO"  } )
     Local nPosRet    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_RETEN"   } )
     Local nPosVld    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_DTVALID" } )
     Local nPosQtO    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTDORIG" } )
     //Local nPosVUO    := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VUORI"   } )
     //Local nPosVUT 	  := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_VTORI"   } )
     Local nPosQTDABA := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDABAT" } )
     Local nPosQTD    := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
     Local nPosQAPRRT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QAPRRET" } ) 
     Local lPeloSel   := .f.

     If Empty(cGet3Sac)
     	MsgStop("Atenção, código do cliente não preenchido.")
     	Return
     Endif
     If __ReadVar $ 'M->ZR_PRODUTO'
        If cVlrOpcB $ 'FC.DC'
           lPeloSel := .t.
           cVlrOpcB := 'F'
           oGet3Sac:lReadOnly := .T.
        Endif
        If !cVlrOpcB $ 'F'
           If Empty(M->ZR_PRODUTO)
              MsgStop("Favor digitar um código de produto!")
              Return(.f.)
           Else
              DbSelectArea("SB1")
              DbSetOrder(1)
              DbSeek(xFilial("SB1")+M->ZR_PRODUTO, .t.)
              If !Found()
                 MsgStop("Produto não encontrado, favor digitar um código de produto valido!")
                 Return(.f.)
              Else
                 If SubStr(SB1->B1_COD, 1, 3) $ 'DIV'
                    ShowF4("D")
                 Else
                    aRet := ShowF4("P")
                    If !aRet[1]
                       If aRet[2] $ 'D'
                          MsgStop("Atenção, esse produto não possui vendas para esse cliente.")
                       Endif
                       M->ZR_PRODUTO := space(15)
                       aCols[n][3]   := space(30)
                       Return .f.
                    Endif
                 Endif
              Endif
           Endif
        Endif
        If lPeloSel
           cVlrOpcB := ""
        Endif
     ElseIf Alltrim(__ReadVar) == 'M->ZR_QTD'
            If M->ZR_QTD > aCols[oBrw1Sac:nAt][nPosQtO]
               MsgStop("A quantidade devolvida não pode ser maior do que a original.")
               Return .f.
            Endif
     ElseIf __ReadVar $ 'M->ZR_LOTE'
            If aCols[n][nPosPro] $ 'DIV' .or. Empty(aCols[n][nPosPro])
               M->ZR_LOTE        := space(06)
               aCols[n][nPosLot] := space(06)
            Else
               cQry1 := ""
               cQry1 += "SELECT SC2.C2_LOTE, SC2.C2_EMISSAO, SC2.C2_DATPRF, SC2.C2_DATRF, SC2.C2_QUJE, SZ1.Z1_VALIDAD, ISNULL(ZZ1.ZZ1_RETENC, '') AS ZZ1_RETENC "
               cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
               cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"' AND SZ1.Z1_LINHA = SUBSTRING(SC2.C2_PRODUTO, 4, 2) AND SZ1.D_E_L_E_T_ = '' "
               cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZ1")+" ZZ1 WITH (NOLOCK) ON ZZ1.ZZ1_FILIAL = SC2.C2_FILIAL AND ZZ1.ZZ1_LOTE = SC2.C2_LOTE AND ZZ1.D_E_L_E_T_ = '' "
               cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
               cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
               cQry1 += "  AND SC2.C2_PRODUTO = '"+aCols[n][nPosPro]+"' "
               cQry1 += "  AND SC2.C2_LOTE    = '"+M->ZR_LOTE+"' "
               TCQuery cQry1 ALIAS "TCQ" NEW
               DbSelectArea("TCQ")
               cNumLot := TCQ->C2_LOTE
               dDatVal := STOD(TCQ->C2_DATPRF) + (TCQ->Z1_VALIDAD * 30)
               nQtdPro := TCQ->C2_QUJE
               cCodRet := TCQ->ZZ1_RETENC
               DbSelectArea("TCQ")
               DbCloseArea()
               If !Empty(cNumLot)
                  M->ZR_LOTE        := cNumLot
                  aCols[n][nPosLot] := cNumLot
                  aCols[n][nPosVld] := dDatVal
                  aCols[n][nPosQTP] := nQtdPro
                  aCols[n][nPosRet] := cCodRet
                  //Verificar se esse lote já possui SAC.
                  fVerLote()
               Else
                  MsgStop("Esse lote não existe para esse produto!")
                  M->ZR_LOTE        := space(06)
                  aCols[n][nPosLot] := space(06)
               Endif
               DbSelectArea("SZR")
            Endif
     Endif
     If Alltrim(__ReadVar) == 'M->ZR_QTDABAT' 
     	If (nCBo3Sac == 'NCC') .or. (nCBo3Sac ='') 
     		aCols[n][nPosQTDABA] := 0 //zerar o campo qtde abatimento quando o tipo de desconto for ncc
	     	M->ZR_QTDABAT 	 	 := 0
	     	//oBrw1Sac:aCols[oBrw1Sac:oBrowse:nAt][nPosQtdAba] :=0  //zerar o campo qtde abatimento quando o tipo de desconto for ncc
    	Elseif (nCBo3Sac == 'AB-')
    		aCols[n][nPosQTD] 	 := 0   // zerar as quantidades qdo for AB-
    		aCols[n][nPosQAPRRT] := 0
        Elseif (nCBo3Sac == 'NCC e AB-')
    		If (M->ZR_QTDABAT + aCols[n][nPosQTD]) > aCols[oBrw1Sac:nAt][nPosQtO]
	     		MsgStop("A quantidade devolvida não pode ser maior do que a original.")
	     		aCols[n][nPosQTDABA] := 0 //zerar o campo qtde abatimento quando o tipo de desconto for ncc
		     	M->ZR_QTDABAT 	 	 := 0
               	Return .f.
    		Endif
        Endif
     	oBrw1SAC:oBrowse:Refresh()
     Endif

     
Return .t.

Static Function ShowF4(cOpcBPro)
       Local aRet
       cOpcBPro := Iif(Empty(cOpcBPro), Iif(__ReadVar $ 'M->ZR_PRODUTO' .and. Alltrim(M->ZR_PRODUTO) == 'DIV', 'D', "F"), cOpcBPro)
       If __ReadVar $ 'M->ZR_PRODUTO'
          aRet := SACViewSD2(M->ZR_PRODUTO, cOpcBPro)
          If !aRet[1]
             M->ZM_PRODUTO := Space(15)
          Endif
       EndIf
Return aRet

Static Function SACViewSD2(cProduto, cOpcBPro)
       Local   aRet   := {}
       Private aCores := { { "JADEV == 0 .AND. FINAN =='S'    " , "BR_VERDE"   },;
                           { "JADEV <  QTDOR .AND. FINAN =='S'" , "BR_AMARELO" },;
                           { "JADEV >= QTDOR .AND. FINAN =='N'" , "BR_VERMELHO"},;
                           { "JADEV == 0 .AND. FINAN =='N'    " , "BR_AZUL"    },;
                           { "JADEV <  QTDOR .AND. FINAN =='N'" , "BR_BRANCO"  },;
                           { "JADEV >= QTDOR .AND. FINAN =='N'" , "BR_PINK"}   }

       DbSelectArea("SZQ")
       Private cMarca     := GetMark()
       Private cGet1Sel   := Space(1)
       Private cSay1Sel   := Space(1)
       Private nCBox1Sl   := ""
       Private oTempTBL
       cVlrOpcB   := cOpcBPro
       
       SetPrvt("oDlg1Sel", "oBrw1Sel", "oBtn1Sel", "oBtn2Sel", "oFont1Sl", "oSay1Sel", "oCBox1Sl", "oGet1Sel")
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       lRet := oTbl1Sel(cProduto, cOpcBPro)
       If lRet
          oFont1Sl   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
          oDlg1Sel   := MSDialog():New( 077, 223, 354, 985, "Relação de Produtos Comprados para abertura do SAC", , , .F., , , , , , .T., , , .T. )
          DbSelectArea("TMPSEL")
          DbSetOrder(1)
          If cOpcBPro $ 'F.P'
             oBrw1Sel   := MsSelect():New( "TMPSEL", "SELEC", "", { {"SELEC", "", "", ""}, {"PRODU", "", "Produto", ""}, {"DESCP", "", "Descrição", ""}, {"ITEMN", "", "Item", ""}, {"NOTAF", "", "Nota", ""}, {"SERIE", "", "Serie", ""}, {"EMISS", "", "Emissao", ""}, {"QUANT", "", "Quantidade", "@E 99,999.99"}, {"VLRUN", "", "Valor Unit.", "@E 999,999.9999"}, {"VLRTO", "", "Valor Total", "@E 999,999,999.9999"}, {"JADEV", "", "Ja Devol.", "@E 99,999.99"}, {"FINAN", "", "Financeiro", ""}}, .F., cMarca, {004, 004, 112, 372}, , , oDlg1Sel, , aCores)
          Else
             oBrw1Sel   := MsSelect():New( "TMPSEL", "SELEC", "", { {"SELEC", "", "", ""}, {"PRODU", "", "Produto", ""}, {"DESCP", "", "Descrição", ""}                                                                                                                                                                                                                                                                                                           }, .F., cMarca, {004, 004, 112, 372}, , , oDlg1Sel, , )
          Endif
          oBrw1Sel:bAval               := {||TMPSELMark(cOpcBPro)}
          oBrw1Sel:oBrowse:lHasMark    := .T.
          oBrw1Sel:oBrowse:lCanAllmark := .F.
          
          oSay1Sel   := TSay():New( 117, 004, {||"Ordem:"}, oDlg1Sel, , oFont1Sl, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 008)
          If cOpcBPro $ 'F.P'
             aVetOrd    := {"Emissão", "Produto", "Nota+Serie"}
             cGet1Sel   := Ctod('  /  /  ')
          Else
             aVetOrd    := {"Produto"}
             cGet1Sel   := space(15)
          Endif
          oCBox1Sl   := TComboBox():New( 116, 040, {|u| If(PCount() > 0, nCBox1Sl := u, nCBox1Sl)}, aVetOrd, 060, 014, oDlg1Sel, , , , CLR_BLACK, CLR_WHITE, .T., oFont1Sl, "", , , , , , , nCBox1Sl )
          If cOpcBPro $ 'F.P'
             oCBox1Sl:bChange := {|| fTrocaIndi() }
          Endif
          oGet1Sel   := TGet():New( 116, 104, { |u| If(PCount() > 0, cGet1Sel := u, cGet1Sel)}, oDlg1Sel, 124, 012, '', , CLR_BLACK, CLR_WHITE, oFont1Sl, , , .T., "", , , .F., .F., , .F., .F., "", "cGet1Sel", , )
          oGet1Sel:bLostFocus := { || DbSelectArea("TMPSEL"), DbSetOrder(oCBox1Sl:nAt), DbSeek( Iif(oCBox1Sl:nAt == 1, dtos(cGet1Sel), cGet1Sel), .t. ), oBrw1Sel:oBrowse:Refresh() }
          
          oBtn1Sel   := TButton():New( 116, 298, "Sair"    , oDlg1Sel, { || aRet := {.f., 'S'}, oDlg1Sel:End()         }, 037, 012, , , , .T., , "", , , , .F. )
          oBtn2Sel   := TButton():New( 116, 250, "Confirma", oDlg1Sel, { || aRet := {.t., 'S'}, fConfirSel(cOpcBPro) }, 037, 012, , , , .T., , "", , , , .F. )
		  oBtn3Sel	 := TButton():New( 116, 346, "Legenda" , oDlg1Sel, { || aRet := {.t., 'S'}, LLegDevolu() 			   }, 037, 012, , , , .T., , "", , , , .F. )
          oDlg1Sel:Activate(,,,.T.)
          If Len(aRet) == 0
             aRet := {.f., 'S'}
          Endif
       Else
          aCols[n][2] := space(15)
          aCols[n][3] := space(30)
          oBrw1Sac:oBrowse:Refresh()
          aRet := {.f., 'D'}
       Endif
       DbSelectArea("TMPSEL")
       DbCloseArea()
       oTempTbl04:Delete()
       DbSelectArea("SZR")
Return aRet

Static Function LLegDevolu()

Local oDlg
Private oBMp1   //Gerou Financeiro
Private oBMp2	//Gerou Financeiro
Private oBMp3	//Gerou Financeiro

Private oBMp4	//Não Gerou Financeiro
Private oBMp5	//Não Gerou Financeiro
Private oBMp6	//Não Gerou Financeiro

Private oFnt
Private oSay 
	DEFINE MSDIALOG oDlg FROM 0,0 TO 178,315 PIXEL TITLE 'Legenda Devolução'
	
	oFnt := TFont():New('COMICS',,16,.T.,,,,,.T.,.F.)
	oSay := TSay():New(12,20,{|| ' - Totalmente Liberado   (Gerou FIN)'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	oSay := TSay():New(25,20,{|| ' - Parcialmente Liberado (Gerou FIN)'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	oSay := TSay():New(37,20,{|| ' - Totalmente Devolvido  (Gerou FIN)'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	oSay := TSay():New(50,20,{|| ' - Totalmente Liberado   (Ñ Ger FIN)'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	oSay := TSay():New(62,20,{|| ' - Parcialmente Liberado (Ñ Ger FIN)'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	oSay := TSay():New(74,20,{|| ' - Totalmente Devolvido  (Ñ Ger FIN)'},oDlg,,oFnt,,,,.T.,CLR_BLACK,CLR_BLACK)
	
	oBMP1 := tBitMap():Create(oDlg)
	oBMP1:SetBMP('BR_VERDE')
	oBMP1:nLeft := 18
	oBMP1:nTop  := 25
	oBMP1:lAutoSize := .T.

	oBMP2 := tBitMap():Create(oDlg)
	oBMP2:SetBMP('BR_AMARELO')
	oBMP2:nLeft := 18
	oBMP2:nTop  := 50
	oBMP2:lAutoSize := .T.	

	oBMP3 := tBitMap():Create(oDlg)
	oBMP3:SetBMP('BR_VERMELHO')
	oBMP3:nLeft := 18
	oBMP3:nTop  := 75
	oBMP3:lAutoSize := .T.	

	oBMP4 := tBitMap():Create(oDlg)
	oBMP4:SetBMP('BR_AZUL')
	oBMP4:nLeft := 18
	oBMP4:nTop  := 100
	oBMP4:lAutoSize := .T.

	oBMP5 := tBitMap():Create(oDlg)
	oBMP5:SetBMP('BR_BRANCO')
	oBMP5:nLeft := 18
	oBMP5:nTop  := 125
	oBMP5:lAutoSize := .T.	

	oBMP6 := tBitMap():Create(oDlg)
	oBMP6:SetBMP('BR_PINK')
	oBMP6:nLeft := 18
	oBMP6:nTop  := 150
	oBMP6:lAutoSize := .T.	
	
	ACTIVATE MSDIALOG oDlg CENTERED
		
Return nil		

Static Function ShowF5()
       If !__ReadVar $ 'M->ZR_LOTE'
          Return
       Endif
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg1Lot","oBrw1Lot","oBtn1Lot")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oDlg1Lot   := MSDialog():New( 091,232,631,831,"Consulta de Lotes X Produto do Cliente",,,.F.,,,,,,.T.,,,.T. )
       oTbl1Lot()
       DbSelectArea("TMPLOT")
       DbSetOrder(1)
       oBrw1Lot   := MsSelect():New( "TMPLOT","","",{{"LOTE","","Lote",""},{"EMIS","","Emissao",""},{"PROD","","Producao",""},{"VALI","","Validade",""},{"QTDP","","Produzido",""},{"RETE","","Retencao",""}},.F.,,{004,004,244,292},,, oDlg1Lot ) 
       oBtn1Lot   := TButton():New( 248,254,"Sair",oDlg1Lot, {|| oDlg1Lot:End() },037,012,,,,.T.,,"",,,,.F. )

       oDlg1Lot:Activate(,,,.T.)
       DbSelectArea("TMPLOT")
       DbCloseArea()
       oTempTbl05:Delete()
       DbSelectArea("SZR")
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Lot() - Cria temporario para o Alias: TMPLOT
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Lot()
       Local nPosPro := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } )
       Local aFds := {}
       //Local cTmp

       Aadd( aFds, {"LOTE", "C", 006, 000} )
       Aadd( aFds, {"EMIS", "D", 001, 000} )
       Aadd( aFds, {"PREV", "D", 008, 000} )
       Aadd( aFds, {"PROD", "D", 001, 000} )
       Aadd( aFds, {"VALI", "D", 008, 000} )
       Aadd( aFds, {"QTDP", "N", 006, 000} )
       Aadd( aFds, {"RETE", "C", 006, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 09/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*cTmp := CriaTrab( aFds, .T. )
         Use (cTmp) Alias TMPLOT New Exclusive
         Index On LOTE To (cTmp)
       */
       //cTmp := U_NovoArqTrab("dbf")
       //dbcreate(cTmp+".dbf",aFds,"DBFCDXADS")
       //USE (cTmp+".dbf") ALIAS TMPLOT VIA "DBFCDXADS" NEW
       //DbCreateIndex(cTmp+"_1.cdx", "LOTE", {||"LOTE"} )
       //DbClearInd()
       //DbSetIndex(cTmp+"_1")
       oTempTbl05 := FWTemporaryTable():New( "TMPLOT" )
       oTempTbl05:SetFields( aFds )
       oTempTbl05:AddIndex( "cInd01", { "LOTE"    } )
       oTempTbl05:Create()
       /********************************************************************************************************************************/
       DbSetOrder(1)

       cQry1 := ""
       cQry1 += "SELECT SC2.C2_LOTE, SC2.C2_EMISSAO, SC2.C2_DATPRF, SC2.C2_DATRF, SC2.C2_QUJE, SZ1.Z1_VALIDAD, ISNULL(ZZ1.ZZ1_RETENC, '') AS ZZ1_RETENC "
       cQry1 += "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"' AND SZ1.Z1_LINHA = SUBSTRING(SC2.C2_PRODUTO, 4, 2) AND SZ1.D_E_L_E_T_ = '' "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("ZZ1")+" ZZ1 WITH (NOLOCK) ON ZZ1.ZZ1_FILIAL = SC2.C2_FILIAL AND ZZ1.ZZ1_LOTE = SC2.C2_LOTE AND ZZ1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' "
       cQry1 += "  AND SC2.D_E_L_E_T_ = '' "
       cQry1 += "  AND SC2.C2_PRODUTO = '"+aCols[n][nPosPro]+"' "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMPLOT", .t.)
                TMPLOT->LOTE := TCQ->C2_LOTE
                TMPLOT->EMIS := STOD(TCQ->C2_EMISSAO)
                TMPLOT->PREV := STOD(TCQ->C2_DATPRF)
                TMPLOT->PROD := STOD(TCQ->C2_DATRF)
                TMPLOT->VALI := STOD(TCQ->C2_DATPRF) + (TCQ->Z1_VALIDAD * 30)
                TMPLOT->QTDP := TCQ->C2_QUJE
                TMPLOT->RETE := TCQ->ZZ1_RETENC
             dbselectarea("TMPLOT")
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPLOT")
       oTempTbl05:Delete()
       DbGoTop()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Sel() - Cria temporario para o Alias: TMPSEL
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Sel(cProduto, cOpcBPro)
       Local nY
       Local nPosCOD := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } )
       Local nPosDOC := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } )
       Local nPosSER := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_SERNF"   } )
       Local nPosQtd := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
       //Local nPosQtO := aScan(aHeader, {|x| Alltrim(x[2]) == "ZR_QTDORIG" } )
       Local aFds    := {}
       //Local cTmp
       If cOpcBPro $ 'D'
          Aadd( aFds, {"SELEC" , "C", 002, 000} )
          Aadd( aFds, {"PRODU" , "C", 015, 000} )
          Aadd( aFds, {"DESCP" , "C", 030, 000} )
       Else
          Aadd( aFds, {"SELEC" , "C", 002, 000} )
          Aadd( aFds, {"PRODU" , "C", 015, 000} )
          Aadd( aFds, {"DESCP" , "C", 030, 000} )
          Aadd( aFds, {"ITEMN" , "C", 002, 000} )
          Aadd( aFds, {"NOTAF" , "C", 009, 000} )
          Aadd( aFds, {"SERIE" , "C", 003, 000} )
          Aadd( aFds, {"EMISS" , "D", 001, 000} )
          Aadd( aFds, {"QUANT" , "N", 009, 002} )
          Aadd( aFds, {"VLRUN" , "N", 010, 002} )
          Aadd( aFds, {"VLRTO" , "N", 014, 002} )
          Aadd( aFds, {"JADEV" , "N", 009, 002} )
          Aadd( aFds, {"PEDID" , "C", 006, 000} )
          Aadd( aFds, {"QTDOR" , "N", 009, 002} )
          Aadd( aFds, {"FINAN" , "C", 001, 000} )
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 09/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*
       cTmp := CriaTrab( aFds, .T. )
       Use (cTmp) Alias TMPSEL New Exclusive
       */
	   //cTmp := U_NovoArqTrab("dbf")
	   //dbcreate(cTmp+".dbf",aFds,"DBFCDXADS")
	   //USE (cTmp+".dbf") ALIAS TMPSEL VIA "DBFCDXADS" NEW
       oTempTbl04 := FWTemporaryTable():New( "TMPSEL" )
       oTempTbl04:SetFields( aFds )
       If cOpcBPro $ 'D'
          //Index On PRODU       Tag &("TMPSEL1") To (cTmp)
          //DbCreateIndex(cTmp+"_1.cdx", "PRODU", {||"PRODU"} )
          //DbClearInd()
          //DbSetIndex(cTmp+"_1")
          oTempTbl04:AddIndex( "cInd01", { "PRODU" } )
       Else
          //DbCreateIndex(cTmp+"_1.cdx", "DTOS(EMISS)", {||"DTOS(EMISS)"} )
          //DbCreateIndex(cTmp+"_2.cdx", "PRODU", {||"PRODU"} )
          //DbCreateIndex(cTmp+"_3.cdx", "NOTAF+SERIE", {||"NOTAF+SERIE"} )
          //DbClearInd()
          //DbSetIndex(cTmp+"_1")
          //DbSetIndex(cTmp+"_2")
          //DbSetIndex(cTmp+"_3")
          oTempTbl04:AddIndex( "cInd01", { "EMISS"    } )
          oTempTbl04:AddIndex( "cInd02", { "PRODU"          } )
          oTempTbl04:AddIndex( "cInd03", { "NOTAF", "SERIE" } )
          /*Index On DTOS(EMISS) Tag &("TMPSEL1") To (cTmp)
            Index On PRODU       Tag &("TMPSEL2") To (cTmp)
            Index On NOTAF+SERIE Tag &("TMPSEL3") To (cTmp)*/
       Endif
       oTempTbl04:Create()
       /********************************************************************************************************************************/
       DbSetOrder(1)

       cQry1 := ""
       cQry1 += " SELECT SD2.D2_COD, SD2.D2_DESCRI, SD2.D2_ITEM, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_QTDEDEV, SD2.D2_PEDIDO, SF4.F4_DUPLIC "
       cQry1 += " FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
       cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL ='"+xFilial("SF4")+"' AND SD2.D2_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_ ='' "
       cQry1 += " WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"' "
       cQry1 += "  AND SD2.D_E_L_E_T_ = '' "
       //cQry1 += "  AND SD2.D2_SERIE <> 'F' "  permitir registro de sac com serie f (em 11/02/16)
       cQry1 += "  AND SD2.D2_CLIENTE = '"+cGet3Sac+"' "
       If cOpcBPro $ 'P'
          cQry1 += "  AND SD2.D2_COD     = '"+cProduto+"' "
          cQry1 += "ORDER BY SD2.D2_EMISSAO"
       ElseIf cOpcBPro $ 'F'
              cQry1 += "ORDER BY SD2.D2_EMISSAO"
       ElseIf cOpcBPro $ 'D'
              cQry1 := ""
              cQry1 += "SELECT SB1.B1_COD, SB1.B1_DESC "
              cQry1 += "FROM SB1010 SB1 WITH (NOLOCK) "
              cQry1 += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
              cQry1 += "  AND SB1.D_E_L_E_T_ = '' "
              cQry1 += "  AND SUBSTRING(SB1.B1_COD, 1, 3) = 'DIV' "
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
               
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             lJaDigit := .f.
             //Tem que se criar exceção para itens que foram add anteriormente
             nQtdItem := 0
             For nY := 1 TO Len(aCols)
                 If !cOpcBPro $ 'D'
                    If Alltrim(TCQ->D2_COD) $ Alltrim(aCols[nY][nPosCOD]) 
                       If TCQ->D2_DOC $ aCols[nY][nPosDOC] .and. TCQ->D2_SERIE $ aCols[nY][nPosSER]
                          lJaDigit := .t.
                          nQtdItem += aCols[nY][nPosQTD]
                          //nQtdItem += aCols[nY][nPosQtO]
                       Endif
                    Endif
                 Endif
             Next
             //If !lJaDigit
                RecLock("TMPSEL", .t.)
                   If cOpcBPro $ 'F.P'
                      TMPSEL->PRODU := TCQ->D2_COD
                      TMPSEL->DESCP := TCQ->D2_DESCRI
                      TMPSEL->ITEMN := TCQ->D2_ITEM
                      TMPSEL->NOTAF := TCQ->D2_DOC
                      TMPSEL->SERIE := TCQ->D2_SERIE
                      TMPSEL->EMISS := Stod(TCQ->D2_EMISSAO)
                      TMPSEL->QUANT := Iif(lJaDigit, (TCQ->D2_QUANT - nQtdItem - TCQ->D2_QTDEDEV), (TCQ->D2_QUANT- TCQ->D2_QTDEDEV))
                      TMPSEL->VLRUN := TCQ->D2_PRCVEN
                      TMPSEL->VLRTO := TCQ->D2_TOTAL
                     // TMPSEL->JADEV := nQtdItem
                      TMPSEL->JADEV := (TCQ->D2_QTDEDEV + nQtdItem) //CONSIDERAR SALDO JÁ LANÇADO DENTRO DO PRÓPRIO SAC
                      TMPSEL->PEDID := TCQ->D2_PEDIDO
                      TMPSEL->QTDOR := TCQ->D2_QUANT
					  TMPSEL->FINAN := TCQ->F4_DUPLIC
                   Else
                      TMPSEL->PRODU := TCQ->B1_COD
                      TMPSEL->DESCP := TCQ->B1_DESC
                   Endif
                dbselectarea("TMPSEL")
                MsUnLock()
             //Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPSEL")
       DbGoTop()
       If TMPSEL->(RecCount()) <= 0
          Return .f.
       Endif
Return .t.

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPSELMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function TMPSELMark(cOpcBPro)
       Local lDesMarca := TMPSEL->(IsMark("SELEC", cMarca))

       RecLock("TMPSEL", .F.)
       If lDesmarca
          TMPSEL->SELEC := "  "
       Else
          If cOpcBPro $ 'D'
             TMPSEL->SELEC := cMarca
          Else
             If TMPSEL->JADEV >= TMPSEL->QTDOR
                MsgStop("Item já foi totalmente devolvido, não pode ser marcado.")
             Else
                TMPSEL->SELEC := cMarca
             Endif
          Endif
       Endif
       TMPSEL->(MsUnlock())
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fTrocaIndi() - Funcao para trocar indice do browse
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fTrocaIndi()
       DbSelectArea("TMPSEL")
       //DbSetOrder(oCBox1Sl:nAt)
       DbGoTop()
       //If oCBox1Sl:nAt == 1     
       //   cGet1Sel := Ctod('  /  /  ')
       //ElseIf oCBox1Sl:nAt == 2
       //       cGet1Sel := Space(15)
       //Else
       //   cGet1Sel := Space(12)
       //Endif 
       oBrw1Sel:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fConfirSel()   - Funcao para confirmar seleção de produtos x Nota
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fConfirSel(cOpcBPro)
       Local nI
local aAuxSel,nSeqItem,lUmVazio,_nY   
	nSeqItem := 0      
	lUmVazio := .f.
       aAuxSel := {}
       DbSelectArea("TMPSEL")
       DbGoTop()
       While !Eof()
             If MarKed("SELEC")
                If cOpcBPro $ 'D'
                   aAdd(aAuxSel, { TMPSEL->PRODU, TMPSEL->DESCP } )
                Else
                   //aAdd(aAuxSel, { TMPSEL->PRODU, TMPSEL->DESCP, (TMPSEL->QUANT - TMPSEL->JADEV), TMPSEL->PEDID, TMPSEL->NOTAF, TMPSEL->SERIE, TMPSEL->VLRUN, TMPSEL->VLRUN * (TMPSEL->QUANT - TMPSEL->JADEV) } )
                  
                  // aAdd(aAuxSel, { TMPSEL->PRODU, TMPSEL->DESCP, TMPSEL->QUANT, TMPSEL->PEDID, TMPSEL->NOTAF, TMPSEL->SERIE, TMPSEL->VLRUN, TMPSEL->VLRUN * (TMPSEL->QUANT) } )
                 //alterado dyego
                 aAdd(aAuxSel, { TMPSEL->PRODU, TMPSEL->DESCP, TMPSEL->QUANT, 0, TMPSEL->PEDID, TMPSEL->NOTAF, TMPSEL->SERIE, TMPSEL->VLRUN, (TMPSEL->VLRTO) ,TMPSEL->ITEMN, TMPSEL->QTDOR } )
                Endif
             Endif
             DbSelectArea("TMPSEL")
             DbSkip()
       EndDo
       DbSelectArea("TMPSEL")
       DbGoTop()
       lUmVazio := .f.
       If Len(aCols) > 1
          nSeqItem := Len(aCols) + 1
       Else
          If Len(aCols) == 1
             If Empty(aCols[1][2]) //Verifica se o código do produto é vazio
                nSeqItem := Iif( Empty(aCols[1][1]), 1, Val(aCols[1][1]) )
                lUmVazio := .t.
             Else
                //If Alltrim(M->ZR_PRODUTO) <> Alltrim(aCols[1][2]) // se for alteração de produto, não incluir nova linha.
				//	nSeqItem := aCols[1][1]  
				//Else
	                nSeqItem := Len(aCols) + 1
	   			//Endif
             Endif
          Else
             nSeqItem := 1
          Endif
       Endif
       For _nY := 1 To Len(aAuxSel)
           If lUmVazio .and. _nY == 1
              If cOpcBPro $ 'D'
                 M->ZR_PRODUTO := aAuxSel[_nY][1]
                 aCols[1][02]  := aAuxSel[_nY][1]
                 aCols[1][03]  := aAuxSel[_nY][2]
                 aCols[1][04]  := 1
                 aCols[1][05]  := 1
              Else
                 M->ZR_PRODUTO := aAuxSel[_nY][1]
                 aCols[1][02]  := aAuxSel[_nY][1]
                 aCols[1][03]  := aAuxSel[_nY][2]
                 aCols[1][04]  := aAuxSel[_nY][3] 
                 aCols[1][05]  := aAuxSel[_nY][11] //aCols[1][04]  := aAuxSel[_nY][3]
                 aCols[1][06]  := aAuxSel[_nY][4]
                 aCols[1][07]  := aAuxSel[_nY][5]
                 aCols[1][08]  := aAuxSel[_nY][6]
                 aCols[1][09]  := aAuxSel[_nY][7]
                 aCols[1][10]  := aAuxSel[_nY][8]
                 aCols[1][11]  := aAuxSel[_nY][9]                  
                 aCols[1][17]  := aAuxSel[_nY][10] //dyego
                 nSeqItem += 1
              Endif
           Else
              If Empty(aCols[Len(aCols)][2])
                 If cOpcBPro $ 'D'
                    M->ZR_PRODUTO := aAuxSel[_nY][1]
                    aCols[Len(aCols)][02]  := aAuxSel[_nY][1]
                    aCols[Len(aCols)][03]  := aAuxSel[_nY][2]
                    aCols[Len(aCols)][04]  := 1
                    aCols[Len(aCols)][05]  := 1
                 Else
                    M->ZR_PRODUTO := aAuxSel[_nY][1]
                    aCols[Len(aCols)][02]  := aAuxSel[_nY][1]
                    aCols[Len(aCols)][03]  := aAuxSel[_nY][2]
                    aCols[Len(aCols)][04]  := aAuxSel[_nY][3]
                    aCols[Len(aCols)][05]  := aAuxSel[_nY][3]
                    aCols[Len(aCols)][06]  := aAuxSel[_nY][4]
                    aCols[Len(aCols)][07]  := aAuxSel[_nY][5]
                    aCols[Len(aCols)][08]  := aAuxSel[_nY][6]
                    aCols[Len(aCols)][09]  := aAuxSel[_nY][7]
                    aCols[Len(aCols)][10]  := aAuxSel[_nY][8]
                 	aCols[Len(aCols)][17]  := aAuxSel[_nY][10] //dyego
                 Endif
              Else
                 aAdd(aCols, Array(noBrw1Sac + 1) )
                 For nI := 1 To noBrw1Sac
                     aCols[Len(aCols)][nI] := CriaVar(aHoBrw1Sac[nI][2])
                 Next
                 If cOpcBPro $ 'D'
                    aCols[Len(aCols)][01]          := StrZero(nSeqItem, 2)
                    aCols[Len(aCols)][02]          := aAuxSel[_nY][1]
                    aCols[Len(aCols)][03]          := aAuxSel[_nY][2]
                    aCols[Len(aCols)][04]          := 1
                    aCols[Len(aCols)][05]          := 1
                 Else
                    aCols[Len(aCols)][01]          := StrZero(nSeqItem, 2)
                    aCols[Len(aCols)][02]          := aAuxSel[_nY][1]
                    aCols[Len(aCols)][03]          := aAuxSel[_nY][2]
                    aCols[Len(aCols)][04]          := aAuxSel[_nY][3]
                    aCols[Len(aCols)][05]          := aAuxSel[_nY][3]
                    aCols[Len(aCols)][06]          := aAuxSel[_nY][4]
                    aCols[Len(aCols)][07]          := aAuxSel[_nY][5]
                    aCols[Len(aCols)][08]          := aAuxSel[_nY][6]
                    aCols[Len(aCols)][09]          := aAuxSel[_nY][7]
                    aCols[Len(aCols)][10]          := aAuxSel[_nY][8]
					aCols[Len(aCols)][17]  		   := aAuxSel[_nY][10] //dyego                    
                    aCols[Len(aCols)][noBrw1Sac+1] := .F.
                    nSeqItem += 1
                 Endif
              Endif
           Endif
       Next
       oBrw1Sac:oBrowse:Refresh()
       oDlg1Sel:End()
       cVlrOpcB += 'C'
Return .t.

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1His() - Cria temporario para o Alias: TMPHIS
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1His()
       Local aFds := {}
       //Local cTmp

       aAdd( aFds , {"MARC"    ,"C",002,000} )
       aAdd( aFds , {"CLOG"    ,"C",015,000} )
       aAdd( aFds , {"DTLG"    ,"D",008,000} )
       aAdd( aFds , {"HORA"    ,"C",008,000} )
       aAdd( aFds , {"RESP"    ,"C",020,000} )
       aAdd( aFds , {"PARE"    ,"M",010,000} )
       aAdd( aFds , {"PRCD"    ,"C",001,000} )
       aAdd( aFds , {"CHAV"    ,"C",016,000} ) //LGS#20191209 - Campo criado para gravar a Hora invertida para indexação - adequação a release 12.1.25

       //cTmp := CriaTrab( aFds, .T. )

//       cTmp := U_NovoArqTrab("dbf") //CriaTrab( , .f. )
//       DbCreate(cTmp+".dbf", aFds, "DBFCDXADS")
       //Use (cTmp) Alias TMPHIS New Exclusive
//       USE (cTmp+".dbf") ALIAS TMPHIS VIA "DBFCDXADS" NEW
//       Index On DTOS(DTLG)+HORA To (cTmp+"_1") DESC
       //       DbCreateIndex(cTmp+"_1.cdx", "DTOS(DTLG)+HORA", { || "(DTOS(DTLG)+HORA) DESC" } , .f.)
//       DbClearInd()
//       DbSetIndex(cTmp+"_1")
//       DbSetOrder(1)

       //DbCreateIndex('SYSTEM\'+SubStr(cTmp, 1, 7)+"2.dbf", 'CLOG'           , { || SubStr(CLOG, 1, 1) }, .f.)
       //DbClearIndex()
       //DbSetIndex(SubStr(cTmp, 1, 7)+"1")
       //DbSetIndex(SubStr(cTmp, 1, 7)+"2")
       //DbSetOrder(1)
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 23/09/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       oTempTbl03 := FWTemporaryTable():New( "TMPHIS" )
       oTempTbl03:SetFields( aFds )
       oTempTbl03:AddIndex( "cInd01", { "CHAV" } )
       oTempTbl03:Create()
       DbSelectArea( "TMPHIS" )
       DbSetOrder(1)
       /********************************************************************************************************************************/
       cQry1 := ""
       cQry1 += "SELECT SZS.ZS_LOG, SZS.ZS_DATA, SZS.ZS_HORA, SZS.ZS_RESP, SZS.ZS_PROCEDE, SZS.ZS_REUTIL, SZS.ZS_ESTOQUE, "
       cQry1 += "RTRIM(CONVERT(VARCHAR(2046),CONVERT(VARBINARY(2046), SZS.ZS_PARECER))) AS ZS_PARECER "
       cQry1 += "FROM SZS010 SZS WITH (NOLOCK) "
       cQry1 += "WHERE SZS.ZS_FILIAL  = '"+xFilial("SZS")+"' "
       cQry1 += "  AND SZS.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZS.ZS_LOG NOT IN('ENC', 'ALT') "
       cQry1 += "  AND SZS.ZS_NUM     = '"+SZQ->ZQ_NUM+"' "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMPHIS", .t.)
                TMPHIS->CLOG := Iif(TCQ->ZS_LOG $ 'ABE', 'Abertura', Iif(TCQ->ZS_LOG $ 'ENC', 'Encaminhado', Iif(TCQ->ZS_LOG $ 'DIR', 'Diretoria', Iif(TCQ->ZS_LOG $ 'COM', 'Comercial', Iif(TCQ->ZS_LOG $ 'FIN', 'Financeiro', Iif(TCQ->ZS_LOG $ 'TEC', 'Técnico', Iif(TCQ->ZS_LOG $ 'EXP', 'Expedição',Iif(TCQ->ZS_LOG $ 'REC', 'Recebimento', Iif(TCQ->ZS_LOG $ 'VIA', 'Deposito', Iif(TCQ->ZS_LOG $ 'FIM', 'Encerrado', Iif(TCQ->ZS_LOG $ 'ATE', 'Atendimento', Iif(TCQ->ZS_LOG $ 'ALT', 'Alterado', Iif(TCQ->ZS_LOG $ 'DIA', 'Diagnóstico', Iif(TCQ->ZS_LOG $ 'IMP', 'Impressão', Iif(TCQ->ZS_LOG $ 'SUP', 'Suprimentos', Iif(TCQ->ZS_LOG $ 'REA', 'Re-abertura', Iif(TCQ->ZS_LOG $ 'PRO', 'Produção', Iif(TCQ->ZS_LOG $ '#MA', '#Manutencao', Iif(TCQ->ZS_LOG $ '-CO', '-Contabilidade', TCQ->ZS_LOG)))))))))))))))))))
                TMPHIS->DTLG := STOD(TCQ->ZS_DATA)
                TMPHIS->HORA := TCQ->ZS_HORA
                TMPHIS->RESP := TCQ->ZS_RESP
                TMPHIS->PARE := TCQ->ZS_PARECER
                TMPHIS->PRCD := TCQ->ZS_PROCEDE
                TMPHIS->CHAV := Inverte( TCQ->ZS_DATA + TCQ->ZS_HORA )
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPHIS")
       DbGoTop()          
       cMul3Sac := TMPHIS->PARE
       oMul3Sac:Refresh()
Return

Static Function fVerLote()
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Private cMGe1Log  

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oDlg1CLO", "oBrw1CLO", "oBrw1Log", "oMGe1Log")
       If oTbl1Clo()
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Definicao do Dialog e todos os seus componentes.                        ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          oDlg1CLO   := MSDialog():New( 151,297,412,1010,"Consulta Lotes com SAC",,,.F.,,,,,,.T.,,,.T. )
       
          DbSelectArea("TMPCLO")
          DbSetOrder(1)
          oBrw1CLO   := MsSelect():New( "TMPCLO","","",{{"NSAC","","SAC",""},{"DSAC","","Data",""}},.F.,,{004,004,120,108},,, oDlg1CLO ) 
          oBrw1CLO:oBrowse:bChange := { || oTbl1Log("2")}
          oMGe1Log   := TMultiGet():New( 068,112,{|u| If(PCount()>0,cMGe1Log:=u,cMGe1Log)},oDlg1CLO,236,052,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.T.,,,.F.,,  )
          oTbl1Log("1")
          DbSelectArea("TMPLOG")
          oBrw1Log   := MsSelect():New( "TMPLOG","","",{{"CLOG","","Log",""},{"RESP","","Responsavel",""},{"DTLG","","Data",""},{"HORA","","Hora",""}},.F.,,{004,112,064,348},,, oDlg1CLO ) 
          oBrw1Log:oBrowse:bChange := { || cMGe1Log := TMPLOG->PARE, oMGe1Log:Refresh() }
          oDlg1CLO:Activate(,,,.T.)
          DbSelectArea("TMPCLO")
          DbCloseArea()
          oTempTbl01:Delete()
          DbSelectArea("TMPLOG")
          DbCloseArea()
          oTempTbl02:Delete()
       Endif
       DbSelectArea("SZR")
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Clo() - Cria temporario para o Alias: TMPCLO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Clo()
       Local aFds     := {}
       //Local cTmp
       Local nQtdReg := 0

       aAdd( aFds , {"NSAC", "C", 006, 000} )
       aAdd( aFds , {"DSAC", "D", 008, 000} )
       //aAdd( aFds , {"PROC", "C", 001, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 09/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*cTmp := CriaTrab( aFds, .T. )
         Use (cTmp) Alias TMPCLO New Exclusive
         Index On NSAC To (cTmp)
       */       
       //*****************************************
       //   cTmp := U_NovoArqTrab("dbf")
       //   dbcreate(cTmp+".dbf",aFds,"DBFCDXADS")
       //   USE (cTmp+".dbf") ALIAS TMPCLO VIA "DBFCDXADS" NEW
	   //	DbCreateIndex(cTmp+"_1.cdx", "NSAC", {||"NSAC"} )
       //   DbClearInd()
       //   DbSetIndex(cTmp+"_1")
       //*****************************************   
       oTempTbl01 := FWTemporaryTable():New( "TMPCLO" )
       oTempTbl01:SetFields( aFds )
       oTempTbl01:AddIndex( "cInd01", { "NSAC" } )
       oTempTbl01:Create()
       /********************************************************************************************************************************/
       DbSetOrder(1)
       cQry1 := ""                   
       cQry1 += "SELECT SZR.ZR_NUM, SZQ.ZQ_DATA "
       cQry1 += "FROM "+RetSqlName("SZR")+" SZR WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN SZQ010 SZQ WITH (NOLOCK) ON SZQ.ZQ_FILIAL = SZR.ZR_FILIAL AND SZQ.ZQ_NUM = SZR.ZR_NUM AND SZQ.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SZR.ZR_FILIAL  = '"+xFilial("SZR")+"' "
       cQry1 += "  AND SZR.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZR.ZR_LOTE    = '"+M->ZR_LOTE+"' "
       cQry1 += "ORDER BY SZQ.ZQ_DATA DESC "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMPCLO", .t.)
                nQtdReg += 1
                TMPCLO->NSAC := TCQ->ZR_NUM
                TMPCLO->DSAC := STOD(TCQ->ZQ_DATA)
             dbselectarea("TMPCLO")
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       If nQtdReg <= 0
          lRet := .f.
          DbSelectArea("TMPCLO")
          DbCloseArea()
          oTempTbl01:Delete()
          DbSelectArea("SZR")
       Else
          lRet := .t.
       Endif
Return(lRet)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Log() - Cria temporario para o Alias: TMPLOG
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Log(cOpcLog)
       Local aFds := {}
       //Local cTmp
       If cOpcLog == '1'
          aAdd( aFds, {"CLOG", "C", 020, 000} )
          aAdd( aFds, {"RESP", "C", 020, 000} )
          aAdd( aFds, {"DTLG", "D", 008, 000} )
          aAdd( aFds, {"HORA", "C", 008, 000} )
          aAdd( aFds, {"PARE", "M", 010, 000} )
          aAdd( aFds, {"HRIN", "C", 008, 000} ) //LGS#20191209 - Campo criado para gravar a Hora invertida para indexação - adequação a release 12.1.25

          /********************************************************************************************************************************/
          /*** BLOCO ALTERADO EM 09/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
          /*
          cTmp := CriaTrab( aFds, .T. )
          Use (cTmp) Alias TMPLOG New Exclusive
          Index On DTOS(DTLG)+HORA To (cTmp) DESC
          */
          //cTmp := U_NovoArqTrab("dbf")
          //dbcreate(cTmp+".dbf",aFds,"DBFCDXADS")
          //USE (cTmp+".dbf") EXCLUSIVE ALIAS TMPLOG VIA "DBFCDXADS" NEW
          //Index On DTOS(DTLG)+HORA To (cTmp+"_1") DESC
          //DbCreateIndex(cTmp+"_1.cdx", "DTOS(DTLG)+HORA DESC", {||"DTOS(DTLG)+HORA DESC"} )
          //DbClearInd()
          //DbSetIndex(cTmp+"_1")
          oTempTbl02 := FWTemporaryTable():New( "TMPLOG" )
          oTempTbl02:SetFields( aFds )
          oTempTbl02:AddIndex( "cInd01", { "DTLG", "HRIN" } )
          oTempTbl02:Create()
          /********************************************************************************************************************************/
          DbSetOrder(1)
       Else
          DbSelectArea("TMPLOG")
          //Zap
          //LGS#20191209 - Substituido comandoZAP devido a utilização de função do banco.
          TCSqlExec("DELETE FROM " + oTempTbl02:GetRealName() )
          DbSelectArea("TMPLOG")
       Endif
       cQry1 := ""
       cQry1 += "SELECT SZS.ZS_LOG, SZS.ZS_DATA, SZS.ZS_HORA, SZS.ZS_RESP, SZS.ZS_PROCEDE, SZS.ZS_REUTIL, SZS.ZS_ESTOQUE, "
       cQry1 += "RTRIM(CONVERT(VARCHAR(2046),CONVERT(VARBINARY(2046), SZS.ZS_PARECER))) AS ZS_PARECER "
       cQry1 += "FROM SZS010 SZS WITH (NOLOCK) "
       cQry1 += "WHERE SZS.ZS_FILIAL  = '"+xFilial("SZS")+"' "
       cQry1 += "  AND SZS.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZS.ZS_NUM     = '"+TMPCLO->NSAC+"' "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMPLOG", .t.)
                TMPLOG->CLOG := Iif(TCQ->ZS_LOG $ 'ABE', 'Abertura', Iif(TCQ->ZS_LOG $ 'ENC', 'Encaminhado', Iif(TCQ->ZS_LOG $ 'DIR', 'Diretoria', Iif(TCQ->ZS_LOG $ 'COM', 'Comercial', Iif(TCQ->ZS_LOG $ 'FIN', 'Financeiro', Iif(TCQ->ZS_LOG $ 'TEC', 'Técnico', Iif(TCQ->ZS_LOG $ 'EXP', 'Expedição',Iif(TCQ->ZS_LOG $ 'VIA', 'Deposito', Iif(TCQ->ZS_LOG $ 'SUP', 'Suprimentos', Iif(TCQ->ZS_LOG $ 'REC', 'Recebimento', Iif(TCQ->ZS_LOG $ 'FIM', 'Encerrado', Iif(TCQ->ZS_LOG $ 'ATE', 'Atendimento', Iif(TCQ->ZS_LOG $ 'ALT', 'Alterado', Iif(TCQ->ZS_LOG $ '#MA', '#Manutencao', Iif(TCQ->ZS_LOG $ '-CO', '-Contabilidade', TCQ->ZS_LOG)))))))))))))))
                TMPLOG->DTLG := STOD(TCQ->ZS_DATA)
                TMPLOG->HORA := TCQ->ZS_HORA
                TMPLOG->RESP := TCQ->ZS_RESP
                TMPLOG->PARE := TCQ->ZS_PARECER
                TMPLOG->HRIN := Inverte( TCQ->ZS_HORA )
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPLOG")
       DbGoTop()
       cMGe1Log := TMPLOG->PARE
       oMGe1Log:Refresh()
       If cOpcLog == '2'
          oBrw1Log:oBrowse:Refresh()
       Endif
Return

User Function ChgUsrIn()
     Local aPswDet
     Local cPswFile := "sigapss.spf"
     Local cPswId   := ""
     Local cPswName := ""
     Local cPswPwd  := ""
     Local cPswDet  := ""
     Local cUserId  := "000000" //Administrador
     Local lEncrypt := .f.
     Local nPswRec  := 0

     Begin Sequence
           //Procuro pelo ID do usuário
           If ( ( nPswRec := spf_seek(cPswFile, "1U"+cUserId, 1) ) <= 0 )
              //Usuário não localizado
              Break
           Endif
           If Type( "cEmpAnt" ) <> "C"
              Private cEmpAnt := "01"
           Endif
           If Type( "cFilAnt" ) <> "C"
              Private cFilAnt := "01"
           Endif
           //Obtendo informações do usuário retornadas por referencia na variável cPswRet
           spf_GetFields( @cPswFile, @nPswRec, @cPswId, @cPswName, @cPswPwd, @cPswDet)
           //Converte o conteudo da string cPswDet em um Array
           aPswDet := Str2Array( cPswDet, lEncrypt )
           //Decriptando a senha antiga para obter o tamanho valido para a senha
           cOldPsw := PswEncript( APSWDET_USER_PWD, 1 )
           //Encriptando a senha para o novo usuário
           cNewPsw := PswEncript( Padr( APSWDET_USER_ID, Len( cOldPsw ) ), 0 )
           //Atribuindo a nova senha ao novo usuário
     End Sequence
Return Nil

Static Function fBusEnvSac()
       Local _aRetInfPt := FWGetSX5( "ZS" )
       Local _aRetInfEs := FWGetSX5( "ZS", , "es" )
       Local _nX
       aEnvSac := {}

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 11/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*DbSelectArea('SX5')
       DbSetOrder(1)
       DbSeek(xFilial("SX5")+'ZS', .T.)
       If Found()
          While !Eof() .and. SX5->X5_TABELA $ 'ZS'
                aAdd(aEnvSac, {ALLTRIM(SX5->X5_CHAVE), ALLTRIM(SX5->X5_DESCRI), ALLTRIM(SX5->X5_DESCSPA) })
                DbSelectArea('SX5')
                DbSkip()
          EndDo
       Endif*/
       For _nX := 1 To Len( _aRetInfPt )
           aAdd( aEnvSac, { ALLTRIM( _aRetInfPt[_nX][3] ), ALLTRIM( _aRetInfPt[_nX][4] ), ALLTRIM( _aRetInfEs[_nX][4] ) })
       Next
Return(aEnvSac)

/*****************************************************************************************/
/*** SACA01_L - Mostra a legenda com cores correspondentes.                            ***/
/*****************************************************************************************/
User Function SACA01_L()
     Local cCadastro := OemToAnsi('Serviço de Atendimento ao Cliente')
     BrwLegenda(cCadastro,"Status",{ {"ENABLE"     ,"Atendimento"                } ,;
                                     {"BR_AZUL"    ,"Análise Diretoria"          } ,;
                                     {"BR_AMARELO" ,"Análise Comercial"          } ,;
                                     {"BR_PINK"    ,"Análise Financeira"         } ,; 
                                     {"BR_MARRON"  ,"Análise Técnica ou Produção"} ,;
                                     {"BR_PRETO"   ,"Análise Expedição"          } ,;
                                     {"BR_CINZA"   ,"Análise Depósito SP"        } ,;
                                     {"INSTRUME"   ,"Análise Manutenção"         } ,;
                                     {"BR_LARANJA" ,"Análise Recebimento"        } ,;
                                     {"BR_BRANCO"  ,"Atendimento com resposta"   } ,;
                                     {"DISABLE"    ,"Encerrado"                  } })

Return(.t.)

/*Static Function fBuscaNum()
	Local cNumSac := space(06)
    cQry1 := ""
       cQry1 += "SELECT TOP 1 SZQ.ZQ_NUM "
       cQry1 += "FROM "+RetSqlName("SZQ")+" SZQ WITH (NOLOCK) "
       cQry1 += "WHERE SZQ.ZQ_FILIAL  = '"+xFilial("SZQ")+"' "
       cQry1 += "  AND SZQ.D_E_L_E_T_ = '' "
       cQry1 += "ORDER BY SZQ.R_E_C_N_O_ DESC "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       cNumSac := Soma1( TCQ->ZQ_NUM )
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("SZQ")
Return cNumSac*/

User Function fSACsAbe(cNumSac)
     Local cQry1  := ""
     Local aArea  := GetArea()
     Local nPrazo := 0
     Local nY

     cQry1 += "SELECT SZS.ZS_NUM, SZS.ZS_LOG, MIN(SZS.ZS_DATA) AS ZS_DATA "
     cQry1 += "FROM SZS010 SZS "
     cQry1 += "WHERE SZS.ZS_FILIAL = '"+xFilial("SZS")+"' "
     cQry1 += "  AND SZS.D_E_L_E_T_ = '' "
     cQry1 += "  AND SZS.ZS_NUM     = '"+cNumSac+"' "
//     cQry1 += "  AND SZS.ZS_LOG IN('ATE', 'DIA', 'FIN', 'REC', 'VIA') "
     cQry1 += "  AND SZS.ZS_LOG IN('DIA', 'FIN', 'REC') "
     cQry1 += "GROUP BY SZS.ZS_NUM, SZS.ZS_LOG "
     cQry1 += "ORDER BY SZS.ZS_NUM "
     TCQuery cQry1 ALIAS "TCQ" New
     DbSelectArea("TCQ")
     dDatRes := STOD(TCQ->ZS_DATA)
     DbSelectArea("TCQ")
     DbCloseArea()
     nAuxDia := 0
     If Empty(dDatRes)
        dDatIni := SZQ->ZQ_DATA
        For nY := 1 To 5
            If CDOW(dDatIni + nY) $ 'Saturday.Monday'
               nAuxDia += 1
            Endif
        Next
        dDatAux := DataValida(SZQ->ZQ_DATA + 5 + nAuxDia)
        nPrazo  := dDataBase - dDatAux
        If nPrazo == 0
           nPrazo := 9999
        Endif
     Endif
     DbSelectArea(aArea[1])
Return(nPrazo)


User Function SACA01_R()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private oTempTbl06
     SetPrvt("oDlg1PE", "oBrw1PE")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oDlg1PE   := MSDialog():New( 091,232,698,927,"Sacs Pendentes por Departamento",,,.F.,,,,,,.T.,,,.T. )
     oTbl1PE()
     DbSelectArea("TMPPE")
     DbSetOrder(1)
     oBrw1PE   := MsSelect():New( "TMPPE","","",{{"NUM","","Numero","999999"},{"CLIE","","Cliente","999999"},{"Nome","","Nome","@!"},{"DTAB","","DT. Abertura",""},{"RESP","","Responsável",""},{"PRAZ","","Prazo",""}},.F.,,{004,004,292,336},,, oDlg1PE ) 

     oDlg1PE:Activate(,,,.T.)
     DbSelectArea("TMPPE")
     DbCloseArea()
     oTempTbl06:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1PE() - Cria temporario para o Alias: TMPPE
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1PE()
       Local aPede  := {}
       //Local cTmp
       Local cQry1 := ""
       Local cQry2 := ""
       Local cDepto:= ""
       Aadd( aPede , {"NUM"  , "C", 006, 000} )
       Aadd( aPede , {"CLIE" , "C", 006, 000} )
       Aadd( aPede , {"NOME" , "C", 030, 000} )
       Aadd( aPede , {"DTAB" , "D", 008, 000} )
       Aadd( aPede , {"PRAZ" , "N", 004, 000} )
       Aadd( aPede , {"RESP" , "C", 012, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 09/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
	   //cTmp := U_NovoArqTrab("dbf")
	   //dbcreate(cTmp+".dbf",aPede,"DBFCDXADS")
	   //USE (cTmp+".dbf") ALIAS TMPPE VIA "DBFCDXADS" NEW
	   //Index On NUM To (cTmp+"_1") 
  	   //DbClearInd()
	   //DbSetIndex(cTmp+"_1")
       oTempTbl06 := FWTemporaryTable():New( "TMPPE" )
       oTempTbl06:SetFields( aPede )
       oTempTbl06:AddIndex( "cInd01", { "NUM" } )
       oTempTbl06:Create()
       /********************************************************************************************************************************/
	   DbSetOrder(1)

       If Substr(cDepart,1,1) =='A'  // Trazer para os Atendentes, os sac do departamento Atendimento  + os sacs que foram Atendimento com Resposta (Flag A + M)
          cDepto :="A','M"
       Else
          cDepto :=Iif(Len(Alltrim(Posicione("SZW", 4, xFilial("SZW")+cRotUsu+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO")))>0,Substr(Posicione("SZW", 4, xFilial("SZW")+cRotUsu+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO"),1,3),SubStr(cDepart, 1, 3))
       Endif
       cQry1 := ""
       cQry1 += " SELECT ZQ_NUM, ZQ_CLIENTE, A1_NOME, ZQ_DATA, ZQ_ATENDEN, ZQ_RESP "
       cQry1 += " FROM "+RetSqlName("SZQ")+" SZQ LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 ON SZQ.ZQ_CLIENTE = SA1.A1_COD AND SA1.D_E_L_E_T_ ='' "
	   cQry1 += " WHERE SZQ.D_E_L_E_T_ ='' AND  (SZQ.ZQ_FILIAL ='"+xFilial("SZQ")+"') AND (SZQ.ZQ_STATUS <>'2') AND (SZQ.ZQ_FLAG IN ('"+Substr(cDepto,1,1)+"')) "
       cQry1 += " ORDER BY SZQ.ZQ_NUM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             //Busca dados do prazo
             nPrazo := 0
             cQry2 := ""
             cQry2 += "SELECT SZS.ZS_NUM, SZS.ZS_LOG, MIN(SZS.ZS_DATA) AS ZS_DATA "
             cQry2 += "FROM SZS010 SZS WITH (NOLOCK) "
             cQry2 += "WHERE SZS.ZS_FILIAL = '"+xFilial("SZS")+"' "
             cQry2 += "  AND SZS.D_E_L_E_T_ = '' "
             cQry2 += "  AND SZS.ZS_NUM     = '"+TCQ->ZQ_NUM+"' "
             cQry2 += "  AND SZS.ZS_LOG IN('ATE', 'DIA') "
             cQry2 += "GROUP BY SZS.ZS_NUM, SZS.ZS_LOG "
             cQry2 += "ORDER BY SZS.ZS_NUM "
             TCQuery cQry2 ALIAS "PRZ" New
             DbSelectArea("PRZ")
             dDatRes := STOD(PRZ->ZS_DATA)
             DbSelectArea("PRZ")
             DbCloseArea()
             If Empty(dDatRes)
                dDatAux := DataValida(STOD(TCQ->ZQ_DATA) + 5)
                nPrazo  := dDataBase - dDatAux
             Endif
             RecLock("TMPPE", .t.)
             	TMPPE->NUM   := TCQ->ZQ_NUM
                TMPPE->CLIE  := TCQ->ZQ_CLIENTE
                TMPPE->NOME  := TCQ->A1_NOME
                TMPPE->DTAB  := sTod(TCQ->ZQ_DATA)
				TMPPE->RESP  := Iif(Substr(cDepto,1,3) $ 'DIR', 'DIRETORIA', Iif(Substr(cDepto,1,3) $ 'COM', 'COMERCIAL', Iif(Substr(cDepto,1,3) $ 'FIN', 'FINANCEIRO', Iif(Substr(cDepto,1,3) $ 'TEC', 'TÉCNICO', Iif(Substr(cDepto,1,3) $ 'EXP', 'EXPEDIÇÃO',Iif(Substr(cDepto,1,3) $ 'REC', 'RECEBIMENTO', Iif(Substr(cDepto,1,3) $ 'VIA', 'DEPÓSITO', Iif(Substr(cDepto,1,3) $ 'ATE', 'ATENDIMENTO', Iif(Substr(cDepto,1,3)$ 'PRO', 'PRODUÇÃO', Iif(Substr(cDepto,1,3)$ 'DIA', 'DIAGNÓSTICO', Iif(Substr(cDepto,1,3)$ '#MA', '#Manutencao', Iif(Substr(cDepto,1,3)$ '-CO', '-CONTABILIDADE', Substr(cDepart,1,3)))))))))))))
                TMPPE->PRAZ  := nPrazo
             dbselectarea("TMPPE")
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPPE")
       DbGoTop()
Return

User Function SACA01_V()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private oTempTbl07
     SetPrvt("oDlg1Abe", "oBrw1Abe")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oDlg1Abe   := MSDialog():New( 091,232,698,927,"SAC sem resposta",,,.F.,,,,,,.T.,,,.T. )
     oTbl1Abe()
     DbSelectArea("TMPABE")
     DbSetOrder(1)
     oBrw1Abe   := MsSelect():New( "TMPABE","","",{{"NUME","","Numero","999999"},{"CLIE","","Cliente","999999"},{"Nome","","Nome","@!"},{"DTAB","","DT. Abertura",""},{"PRAZ","","Prazo",""}},.F.,,{004,004,292,336},,, oDlg1Abe ) 

     oDlg1Abe:Activate(,,,.T.)
     DbSelectArea("TMPABE")
     DbCloseArea()
     oTempTbl07:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1Abe() - Cria temporario para o Alias: TMPABE
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1Abe()
       Local aFds  := {}
       //Local cTmp
       Local cQry1 := ""
       Local cQry2 := ""

       Aadd( aFds , {"NUME", "C", 006, 000} )
       Aadd( aFds , {"CLIE", "C", 006, 000} )
       Aadd( aFds , {"NOME", "C", 030, 000} )
       Aadd( aFds , {"DTAB", "D", 008, 000} )
       Aadd( aFds , {"PRAZ", "N", 004, 000} )
       Aadd( aFds , {"PRZI", "C", 004, 000} ) //LGS#20191209 - Campo criado para gravar a Hora invertida para indexação - adequação a release 12.1.25

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 09/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*cTmp := CriaTrab( aFds, .T. )
         Use (cTmp) Alias TMPABE New Exclusive
         Index On STR(PRAZ, 0) Tag &("TMPABE1") To (cTmp) DESC
       */
	   //cTmp := U_NovoArqTrab("dbf")
	   //Dbcreate(cTmp+".dbf",aFds,"DBFCDXADS")
	   //USE (cTmp+".dbf") ALIAS TMPABE VIA "DBFCDXADS" NEW
	   //Index On STR(PRAZ, 0) To (cTmp+"_1") DESC
  	   //DbClearInd()
	   //DbSetIndex(cTmp+"_1")
       oTempTbl07 := FWTemporaryTable():New( "TMPABE" )
       oTempTbl07:SetFields( aFds )
       oTempTbl07:AddIndex( "cInd01", { "PRZI" } )
       oTempTbl07:Create()
       /********************************************************************************************************************************/
	   DbSetOrder(1)

       cQry1 := ""
       cQry1 += "SELECT SZQ.ZQ_NUM, SZQ.ZQ_CLIENTE, SA1.A1_NOME, SZQ.ZQ_DATA "
       cQry1 += "FROM SZQ010 SZQ WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN SA1010 SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = SZQ.ZQ_CLIENTE AND SA1.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SZQ.ZQ_FILIAL = '"+xFilial("SZQ")+"' "
       cQry1 += "  AND SZQ.D_E_L_E_T_ = '' "
       cQry1 += "  AND SZQ.ZQ_STATUS = '1' "
       cQry1 += "ORDER BY SZQ.ZQ_NUM "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             /**********************************************/
             //Busca dados do prazo
             nPrazo := 0
             cQry2 := ""
             cQry2 += "SELECT SZS.ZS_NUM, SZS.ZS_LOG, MIN(SZS.ZS_DATA) AS ZS_DATA "
             cQry2 += "FROM SZS010 SZS WITH (NOLOCK) "
             cQry2 += "WHERE SZS.ZS_FILIAL = '"+xFilial("SZS")+"' "
             cQry2 += "  AND SZS.D_E_L_E_T_ = '' "
             cQry2 += "  AND SZS.ZS_NUM     = '"+TCQ->ZQ_NUM+"' "
             //cQry2 += "  AND SZS.ZS_LOG IN('DIR', 'COM', 'FIN', 'TEC', 'ATC', 'EXP', 'REC') "
             cQry2 += "  AND SZS.ZS_LOG IN('ATE', 'DIA') "
             cQry2 += "GROUP BY SZS.ZS_NUM, SZS.ZS_LOG "
             cQry2 += "ORDER BY SZS.ZS_NUM "
             TCQuery cQry2 ALIAS "PRZ" New
             DbSelectArea("PRZ")
             dDatRes := STOD(PRZ->ZS_DATA)
             DbSelectArea("PRZ")
             DbCloseArea()
             If Empty(dDatRes)
                dDatAux := DataValida(STOD(TCQ->ZQ_DATA) + 5)
                nPrazo  := dDataBase - dDatAux
                If nPrazo == 0
                   nPrazo := 9999
                Endif
             Endif
             /**********************************************/
             If nPrazo > 0
                RecLock("TMPABE", .t.)
                   TMPABE->NUME := TCQ->ZQ_NUM
                   TMPABE->CLIE := TCQ->ZQ_CLIENTE
                   TMPABE->NOME := TCQ->A1_NOME
                   TMPABE->DTAB := sTod(TCQ->ZQ_DATA)
                   TMPABE->PRAZ := nPrazo
                   TMPABE->PRZI := Inverte( Str( nPrazo, 0 ) )
                MsUnLock()
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPABE")
       DbGoTop()
Return

Static Function fGeraFNC()
       Local nY
       Local cFilmat :=''

	   If !MsgYesNo("Confirma geração de Ficha de Não conformindade para este SAC ?")
    	   Return
	   Endif
	
	   DbSelectArea("QAA")
       DbSetOrder(6)
       DbSeek(Upper(cUserName), .t.)
       If Found()
          cCodMat := QAA->QAA_MAT
          cFilMat := QAA->QAA_FILIAL
       Else
          cCodMat := ''
       Endif
       //Gravar na tabela QI2 Ficha
       RecLock("QI2", .T.)
          QI2->QI2_FILIAL := xFilial("QI2")
          QI2->QI2_FNC    := GETQNCSEQ('QI2', 'QI2_FNC') //Código da FNC
          QI2->QI2_REV    := '00'                        //Revisão da FNC
          QI2->QI2_TPFIC  := '2'                         //Tipo da Ficha - 1=Não Conformidade Potencial; 2=Não Conformidade Existente; 3=Melhoria
          QI2->QI2_PRIORI := '2'                         //Prioridade    - 1=Baixa; 2=Média; 3=Alta
          QI2->QI2_STATUS := '1'                         //Status        - 1=Registrada
          QI2->QI2_DESCR  := 'SAC: '+cGet1Sac+' ASS./OCO.: '+cGetASac+'/'+cGetcSac+'-'+SubStr(cGetDSac, 1, 13)
          QI2->QI2_ANO    := StrZero(Year(dGet2Sac), 4)  //Ano da Ficha de Não Conformidade
          QI2->QI2_CODORI := '000002'                    //Codigo de Origem - 000002-Reclamação do Cliente
          QI2->QI2_OCORRE := dGet2Sac                    //Data da Ocorrência
          /***********************************************/
          dDatIni := dGet2Sac
          nAuxDia := 0
          For nY := 1 To 5
              If CDOW(dDatIni + nY) $ 'Saturday.Monday'
                 nAuxDia += 1
              Endif
          Next
          dDatAux := DataValida(SZQ->ZQ_DATA + 5 + nAuxDia)
          nPrazo  := dDataBase - dDatAux
          /***********************************************/
          QI2->QI2_CONPRE := dDatAux                     //Data de Previsão para resposta
          QI2->QI2_DOCUME := 'S'                         //Documentado
          QI2->QI2_FILORI := xFilial("QI2")              //Filial Origem
          QI2->QI2_FILDEP := xFilial("QI2")              //Filial Departamento Destino
          QI2->QI2_FILRES := cFilMat                     //Filial Responsável
//          QI2->QI2_FILRES := SubStr(cCodMat, 3, 2)     //Filial Responsável
          QI2->QI2_MATRES := cCodMat                     //Codigo da Matricula
          QI2->QI2_REGIST := dDataBase                   //Data do registro
          QI2->QI2_SIGILO := 'N'                         //Ficha em Sigilo
          /********************************************************************************************************************************************/
          QI2->QI2_CODCLI := cGet3Sac                    //Codigo do Cliente
          QI2->QI2_LOJCLI := '01'                        //Loja do Cliente
          QI2->QI2_CONTAT := cGet5Sac                    //Contato
          QI2->QI2_FONE   := cGet6Sac                    //Fone 
          /********************************************************************************************************************************************/
          QI2->QI2_ORIGEM := 'QNC'
          QI2->QI2_DDETA  := MSMM(QI2_DDETA, , , cMul1Sac, 1, , , "QI2", "QI2_DDETA" )
       dbselectarea("QI2")
       MsUnLock()
       //Gravar na tabela SZQ numero da Ficha
       DbSelectArea("SZQ")
 	   DbSetOrder(1)
 	   DbGotop()
       DbSeek(xFilial("SZQ")+cGet1Sac, .t.)
       If Found()
       	  RecLock("SZQ", .F.)
              SZQ->ZQ_FNC := QI2->QI2_FNC
          dbselectarea("SZQ")
          MsUnLock()
   	   Endif	
       //Mostrar numero da Ficha na tela principal.
       MessageBox("FNC gerada com Sucesso", "Atenção...",48)
     
       cSayNSac := TransForm(SZQ->ZQ_FNC, "@R 99999999999/9999")
       oSayNSac:cCaption := TransForm(SZQ->ZQ_FNC, "@R 99999999999/9999")
       //Inibir botão caso tenha ficha gravada.
       oBtn3Sac:lReadOnly := .t.
Return

Static Function fTrocFold()
	
	If oFol1Sac:nOption == 5 .AND. oFol1Sac:aPrompts[5] == "Devolução"
    	oBtn1Dev:lVisible := .t.
		oBtn3Dev:lVisible := .t.
   		If cGet1Sac $ GetMv("MV_XREAPRO") //'023317.023253.023303.023325.023273.023302.023109.023308' //ARATINTAS
			oBtn4Dev:lVisible := .t.	          
   		Else
			oBtn4Dev:lVisible := .f.
		Endif	                    
        //alterado dyego
        //oBtn2Dev:lVisible := .t.
    Endif
    If oFol1Sac:nOption == 6 .or. oFol1Sac:aPrompts[5] == "Resumo"
		fGeraEspel(2)
	Endif
	
Return .t.


User Function SACA01_B(cValBrw)
     If cValBrw $ 'L' //Verificação da Linha
        If oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_ITEMDEV'})] $ '1'
           If Empty(oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_LOCDEV'})])
              MsgAlert('Atenção, LOCAL não pode ser em branco.')
              Return(.f.)
           Endif
           //alterado dyego
           //If oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'})] <= 0.0
           //   MsgAlert('Atenção, QTD. DEV. não pode ser zero.')
           //   Return(.f.)
           //Endif
        Endif
     ElseIf cValBrw $ 'C'
            If Alltrim(__ReadVar) $ 'M->ZR_LOCDEV'
               If !ExistCpo("SX5", '99'+M->ZR_LOCDEV)
                  MsgStop("Armazem inválido!")
                  oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_LOCDEV'})] := space(02)
                  M->ZR_LOCDEV := space(02)
                  Return(.f.)
               Else
                  oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_LOCDEV'})] := M->ZR_LOCDEV
               Endif
            ElseIf Alltrim(__ReadVar) $ 'M->ZR_QTDDEV'
                   If M->ZR_QTDDEV <= 0 .or. M->ZR_QTDDEV > oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_QTD'})]
                      MsgStop("Quantidade inválida!")
                      oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'})] := 0
                      M->ZR_QTDDEV := 0
                   Else
                      oBrw2SAC:aCols[oBrw2SAC:nAt][aScan(aHoBrw2SAC, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'})] := M->ZR_QTDDEV
                   Endif
            Endif
     Endif
Return .t.

/*Static Function fDivIteSAC()
       If !oBrw2SAC:aCols[oBrw2SAC:nAt][Len(aHoBrw2SAC)+1]
          If !Empty(oBrw2SAC:aCols[oBrw2SAC:nAt][2])
             If oBrw2SAC:aCols[oBrw2SAC:nAt][7] >= oBrw2SAC:aCols[oBrw2SAC:nAt][6] .or. oBrw2SAC:aCols[oBrw2SAC:nAt][7] == 0
                MsgStop("Item não pode ser dividido")
                Return
             Endif
             aAdd(oBrw2SAC:aCols, {StrZero(Len(oBrw2SAC:aCols)+1, 3), oBrw2SAC:aCols[oBrw2SAC:nAt][2], oBrw2SAC:aCols[oBrw2SAC:nAt][3], '2', space(02), oBrw2SAC:aCols[oBrw2SAC:nAt][6] - oBrw2SAC:aCols[oBrw2SAC:nAt][7], 0.0, oBrw2SAC:aCols[oBrw2SAC:nAt][8], oBrw2SAC:aCols[oBrw2SAC:nAt][9], .f.})
             oBrw2SAC:nAt := Len(oBrw2SAC:aCols)
             oBrw2SAC:oBrowse:Refresh()
          Endif
       Endif
Return*/

Static Function fGravNFSAC()
       Local nTotalD1      :=0
       Local nTotalSub     :=0
       Local nTotBaSub     :=0
       Local nCont         :=0
       Local erroTrans     := .f.
       Local nZ
       Private lMsErroAuto := .F. 
       Private _aCabec     := {}
       Private _aItem1     := {}                 
       Private _aItens     := {} 
	   Private aProdBloq   := {} 
       Private _aItTransf   := {} 
       Private _aItPerda    := {}
       Private _cNFiscal 	:= space(9)
       Private _cSerie  	:= space(3)
         
       _txtTransf  := ""
       _txtNfPerda := ""
       _txtNfDev   := ""
       
       If nCBo3Sac == 'AB-'
          MsgStop("Não é permitida geração de nota fiscal quando o tipo de desconto do Sac é apenas Abatimento. Verifique!!!")
          Return
       Endif         

       If (Empty(nGetKSAC) .or. Empty(nGetMSAC) ) .and. _cCombo != 'SIM'
          MsgStop("Atenção, Numero da Nota ou Data de Emissão estão com seu conteúdo vazio. Verifique!!!")
          Return
       Endif         
       
       For nZ := 1 To Len(oBrw2Sac:aCols)
          If oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_ITEMDEV'})] $ '1'
       	      nCont := (nCont +1)
       	  Endif
       Next		

       If !nCont > 0
          MsgStop("Atenção, nenhum produto esta marcado como devolvido = SIM. Verifique!!!")
          Return
       Endif         
               
       If  _cCombo == 'SIM'
	       _cSerie := '4'
       		//LJ720NOTA(@_cSerie, @_cNFiscal) // pega numero da NF de entrada.
       	   //SX3->(DbSetOrder(1))
		   //If (SX3->(dbSeek("SD9")))
		    //   _cNFiscal := MA461NumNf(.T.,_cSerie)
		   //EndIf 
       Endif   

       If !ValidaSAC()
       	   Return 
       Endif
       
       //incluso dyego
       nPosNNF   := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } )
       nPosSNF   := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_SERNF"   } ) 
       nPosItDev := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMORI" } ) 
       nPosVlUni := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_VUORI"   } ) 

       nPosQOri  := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDORIG" } ) 

       cLojCli := Posicione("SA1", 1, xFilial("SA1")+cGet3SAC, "A1_LOJA")
       cEstCli := Posicione("SA1", 1, xFilial("SA1")+cGet3SAC, "A1_EST")
       
       //incluso dyego            
       //If(_cCombo == 'SIM')   
       //		aAdd(_aCabec,  {"F1_FORMUL"     , "S"        , Nil}) 
       //Endif                                                                  
       
       aAdd(_aCabec,  {"F1_FILIAL"  	, xFilial("SF1") 			 			, Nil})
       aAdd(_aCabec,  {"F1_TIPO"    	, "D"            			  			, Nil})
       aAdd(_aCabec,  {"F1_DOC"     	, IIF(_cCombo == 'SIM',_cNFiscal , TransForm(Alltrim(nGetKSAC), "@!")) /*nGetKSAC*/        , Nil})
       aAdd(_aCabec,  {"F1_SERIE"   	, IIF(_cCombo == 'SIM',_cSerie , TransForm(Alltrim(nGetLSAC), "@!")) /*nGetLSAC*/         , Nil})
       If(_cCombo == 'SIM')   
       	   aAdd(_aCabec,  {"F1_EMISSAO" , dDataBase      			  			, Nil})
       Else                                                                  
		   aAdd(_aCabec,  {"F1_EMISSAO" , nGetMSac      			   			, Nil})//alterado André 17-07-14 - Pegar data da Emissão no campo correspondente qdo não for formulário próprio.
       Endif
       aAdd(_aCabec,  {"F1_ESPECIE" 	, _cCombo2           					, Nil})
       aAdd(_aCabec,  {"F1_DTDIGIT" 	, dDataBase      						, Nil})
       aAdd(_aCabec,  {"F1_FORMUL"  	, IIF(_cCombo == 'SIM', "S", " ")		, Nil})
       aAdd(_aCabec,  {"F1_FORNECE" 	, cGet3SAC       						, Nil})
       aAdd(_aCabec,  {"F1_LOJA"    	, cLojCli        						, Nil}) 
       aAdd(_aCabec,  {"F1_EST"     	, cEstCli        						, Nil}) 
       aAdd(_aCabec,  {"F1_MENNOTA"   	, Substr(Alltrim(cGetRSac),1,100)		, Nil}) 
       aAdd(_aCabec,  {"F1_CHVNFE"  	, IIF(_cCombo2 == 'SPED', nGetQSac, " "), Nil}) 
		
	   cQuery := ""
       
       For nZ := 1 To Len(oBrw2Sac:aCols)
           If oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_ITEMDEV'})] $ '1'// .AND. oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_QTNFREC'})] > 0
				If !oBrw2Sac:aCols[nZ][noBrw2Sac+1]
              		nVlrUni := 0   
              		//alterado dyego
              		//If Posicione("SB1", 1, xFilial("SB1")+oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_TIPO") $ 'MP.GG'
                 	//	nVlrUni := Posicione("SB1", 1, xFilial("SB1")+oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_UPRC")
              		//Else
                 	//	If Posicione("SB1", 1, xFilial("SB1")+oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_ESTOQUE") $ 'S'
                    //		nVlrUni := Posicione("SB1", 1, xFilial("SB1")+oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B1_PRV1")
                 	//	Else
                    //		nVlrUni := Posicione("SB5", 1, xFilial("SB5")+oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})], "B5_PRV2")
                 	//	Endif
              		//Endif
              		cCodPro := oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_PRODUTO'})]
              		//nQtdDev := oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_QTDDEV'}) ]
              		nQtdDev := oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_QTNFREC'})]
              		cTesEnt := oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_TES'}) ]
              		cCFOEnt := oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_CF'}) ]
                 	cItemDev  := oBrw1Sac:aCols[nZ][nPosItDev] 
                 	 
                	//incluso dyego
              		If  (oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_QTREAPR'}) ]) > 0    
              	        _qtdDev :=  (oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_QTREAPR'}) ])
              			aAdd(_aItTransf,  {cCodPro  ,_qtdDev}) 
            		EndIf
            		
            		//incluso dyego
              		If  (oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_QTPERDA'}) ]) > 0    
              	        _qtdPerda :=  (oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_QTPERDA'}) ])
              	        _nPreco :=  oBrw1Sac:aCols[nZ][nPosVlUni]
              			aAdd(_aItPerda,  {cCodPro  ,_qtdPerda,_nPreco}) 
            		EndIf
            		
              		//cTesEnt := '082'
              		//cCFOEnt := '000' //Iif(Posicione("SA1", 1, xFilial("SA1")+SZQ->ZQ_CLIENTE, "A1_EST") $ 'SP', '1', '2')+SubStr(Posicione("SF4", 1, xFilial("SF4")+'082', "F4_CF"), 2, 3)

              		DbSelectArea("SB1")
              		DbSetOrder(1)
              		DbSeek(xFilial("SB1")+cCodPro, .t.)
              		cUniMed := SB1->B1_UM
              		cTipPro := SB1->B1_TIPO
              		cLocPro := oBrw2Sac:aCols[nZ][5]  
              		
              		// adicionado dyego
			      	cNfOri  := (oBrw1Sac:aCols[nZ][nPosNNF])
			      	cSerOri := (oBrw1Sac:aCols[nZ][nPosSNF])
			        

    				// 3 - D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_                     
                 	//nVlrUni  := oBrw1Sac:aCols[nZ][nPosVlUni]
                 	nQtdOri :=  Posicione("SD2", 3, xFilial("SD2")+cNfOri+cSerOri+cGet3SAC+cLojCli+cCodPro+cItemDev, "D2_QUANT")
                 	nVlrUni  := Posicione("SD2", 3, xFilial("SD2")+cNfOri+cSerOri+cGet3SAC+cLojCli+cCodPro+cItemDev, "D2_PRCVEN")      
                 	nBaseSub := Posicione("SD2", 3, xFilial("SD2")+cNfOri+cSerOri+cGet3SAC+cLojCli+cCodPro+cItemDev, "D2_BRICMS") 
                 	nVlrSubs := Posicione("SD2", 3, xFilial("SD2")+cNfOri+cSerOri+cGet3SAC+cLojCli+cCodPro+cItemDev, "D2_ICMSRET")  
                    
                    nTotBaSub:= (nBaseSub / ( nQtdOri / nQtdDev))   // BASE ICMSSUBS
                    nTotalSub:= (nVlrSubs / ( nQtdOri / nQtdDev))   // FAZENDO CONTA DO ICMS SUBST POR CONTA DE DEVOLUÇÃO PARCIAL ESTADO MT (EXCEÇÕES) - ANDRÉ 08/09/14  
       
                    nTotalD1 := ((nVlrUni) * (nQtdDev))
              		_aItem1 := {   {"D1_FORMUL"  , IIF(_cCombo == 'SIM', "S", " ") 		 , NIL},; //incluido dyego  
              					      {"D1_COD"    , cCodPro                          		 , NIL},;
                  		         {"D1_ITEM"   , StrZero(nZ, TamSX3("D1_ITEM")[1])		 , NIL},;
                				      {"D1_DOC"    , IIF(_cCombo == 'SIM',_cNFiscal, TransForm(Alltrim(nGetKSAC), "@!")),NIL},;    //alterado dyego{"D1_DOC"    , cGet1SAC                         , NIL},;
                  		         {"D1_SERIE"  , IIF(_cCombo == 'SIM',_cSerie  , TransForm(Alltrim(nGetLSAC), "@!")),NIL},; 
                  		         {"D1_UM"     , cUniMed                          		 , NIL},;
                 	               {"D1_QUANT"  , nQtdDev                          		 , NIL},;
            	                  {"D1_VUNIT"  , nVlrUni                          		 , NIL},;
                                 {"D1_PICM"   , 0                                		 , NIL},; 
                                 {"D1_TOTAL"  , round(nTotalD1,TAMSX3("D1_TOTAL")[2])   , NIL},;
                 	               {"D1_VALICM" , 0                                		 , NIL},;
                	               {"D1_TES"    , cTesEnt                          		 , NIL},;
                  		         {"D1_CF"     , cCFOEnt                          		 , NIL},;
                  		         {"D1_RATEIO" , ""                               		 , NIL},;
 		                           {"D1_FORNECE", cGet3SAC                         		 , NIL},;
                	               {"D1_LOJA"   , cLojCli                          		 , NIL},;
        		                     {"D1_EMISSAO", Iif(_cCombo =='SIM',dDataBase, nGetMSac) , NIL},; //alterado André 17-07-14 - Pegar data da Emissão no campo correspondente qdo não for formulário próprio.
        		                     {"D1_DTDIGIT", dDataBase                        		 , NIL},;
		                           {"D1_TIPO"   , "N"                              		 , NIL},;
   		                        {"D1_TP"     , cTipPro                          		 , NIL},;
    		                        {"D1_LOCAL"  , cLocPro                          		 , NIL},;                
    		                        {"D1_ENDER"  , endArmzRcb()                     		 , NIL},;//incluido dyego
    		                        {"D1_NFORI"  , cNfOri                           		 , NIL},;//incluido dyego
       		                     {"D1_SERIORI", cSerOri                          		 , NIL},;//incluido dyego  
       		                     {"D1_ITEMORI", cItemDev                         		 , NIL}, ;//incluido dyego  
                 	               {"D1_BRICMS" , round(nTotBaSub, TAMSX3("D1_BRICMS")[2]), NIL},;
                 	               {"D1_ICMSRET", round(nTotalSub,TAMSX3("D1_ICMSRET")[2]), NIL};
    		                        }
        		    aAdd(_aItens, _aItem1)
    		    Endif
       	   Endif
       Next
       nModulo     :=  2   
       lMsErroAuto := .F.
       erroTrans   := .F.

       BEGIN TRANSACTION //incluido dyego
       FLibProdBl(cGet1Sac,1) //desbloquear possíveis produtos bloqueados
       MSExecAuto({|x, y, z| MATA103(x, y, z)}, _aCabec, _aItens, 3)
       If lMsErroAuto          
           erroTrans := .T.
           If Aviso("Pergunta", "Devolução não gerada. Deseja visualizar o log?", {"Sim","Nao"}, 1, "Atencao") = 1  
               _ocorreErr := .F.    
               DisarmTransaction()  //incluido dyego
               erroTrans := .T.
               MostraErro()
           Endif
           nModulo := 13
       Else             
	   	   IF _cCombo == 'SIM'
		       cQuery := ""
			   cQuery += " SELECT TOP 1 F1_DOC "
       		   cQuery += " FROM "+RetSqlName("SF1")+" WITH (NOLOCK) WHERE D_E_L_E_T_ = '' "
			   cQuery += "	AND (F1_FILIAL 	= '"+xFilial("SF1")+"')"
			   cQuery += "	AND F1_EMISSAO 	= '"+DtoS(dDataBase)+"'"
			   cQuery += "	AND F1_SERIE	= '"+_cSerie+"'"
			   cQuery += "	AND F1_FORNECE 	= '"+cGet3SAC+"'"     
			   cQuery += " ORDER BY R_E_C_N_O_ DESC "
   		       TCQUERY cQuery NEW ALIAS "NOTA"
			   DbSelectArea("NOTA")
		 	   DbGotop()
			   If !Eof()
			     _cNFiscal := NOTA->F1_DOC
		       Endif
		       DbCloseArea()  
		   Endif

           nModulo := 13
           aGrvIte := {}
           For nZ := 1 To Len(oBrw2Sac:aCols)
               If !oBrw2Sac:aCols[nZ][noBrw2SAC+1]
                   DbSelectArea("SZR")
                   DbSetOrder(1)
                   //DbSeek(xFilial("SZR")+cGet1SAC+oBrw2Sac:aCols[nZ][9], .t.)
                   //alterado dyego
                   DbSeek(xFilial("SZR")+cGet1SAC+oBrw2Sac:aCols[nZ][7], .t.)
                   If Found()
                       //nPos := aScan(aGrvIte, {|x| x[1] == xFilial("SZR")+cGet1SAC+oBrw2SAC:aCols[nZ][9]})      
                       //alterado dyego
                       nPos := aScan(aGrvIte, {|x| x[1] == xFilial("SZR")+cGet1SAC+oBrw2SAC:aCols[nZ][7]})
                       If nPos == 0
                       //aAdd(aGrvIte, {xFilial("SZR")+cGet1SAC+oBrw2SAC:aCols[nZ][9], oBrw2SAC:aCols[nZ][5], StrZero(oBrw2SAC:aCols[nZ][7], 4)} ) 
                       //dyego
                           aAdd(aGrvIte, {xFilial("SZR")+cGet1SAC+oBrw2SAC:aCols[nZ][7], oBrw2SAC:aCols[nZ][5], StrZero(oBrw2SAC:aCols[nZ][8], 4)} )
                       Else
                           aGrvIte[nPos][2] += '.'+oBrw1:aCols[nZ][4]
                           aGrvIte[nPos][3] += '.'+StrZero(oBrw1:aCols[nZ][6], 4)
                       Endif
                   Endif
               Endif
           Next
           For nZ := 1 To Len(aGrvIte)
                DbSelectArea("SZR")
                DbSetOrder(1)
                DbSeek(aGrvIte[nZ][1], .t.)
                If Found()
                    RecLock("SZR", .f.)
                        SZR->ZR_ITEMDEV := oBrw2Sac:aCols[nZ][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_ITEMDEV'})]  // gravar se o item foi devolvido
                        SZR->ZR_LOCDEV2 := aGrvIte[nZ][2]
	                        SZR->ZR_QTDDEV2 := aGrvIte[nZ][3]
	                dbselectarea("SZR")
                    MsUnLock()
                Endif
            Next
            // faz a transferencia de armazem    
            If len(_aItTransf)>0
				_txtTransf := transfArma(_aItTransf)           
            Endif        
            If len(_aItPerda)>0
		   		_txtNfPerda := movInterno(_aItPerda) // 	nfPerda(_aItPerda)           
            Endif        
       Endif

       If erroTrans 
           DisarmTransaction()  //incluido dyego
       Else
   	       FLibProdBl(cGet1Sac,2) //bloquear produtos que foram desbloqueados para geração da nota     
	   Endif	

       END TRANSACTION //incluso dyego
        
       IF !erroTrans
           _txtNfDev  := "NF Devolução gerada! NF: " + IIF(_cCombo == 'SIM',_cNFiscal , TransForm(Alltrim(nGetKSAC), "@!")) +" Serie: "+ IIF(_cCombo == 'SIM',_cSerie , TransForm(Alltrim(nGetLSAC), "@!"))  
           _txtNfDev := Dtoc(dDatabase) +  Chr(13) + Chr(10)  + "1->" +  _txtNfDev+ Chr(13) + Chr(10) +"2->"+ _txtTransf + Chr(13) + Chr(10)   +"3->"+ _txtNfPerda  

	       //Histórico de Alteração
	       RecLock("SZS", .t.)
	       SZS->ZS_FILIAL  := xFilial("SZS")
	       SZS->ZS_NUM     := cGet1Sac
	       SZS->ZS_DATA    := dDataBase
	       SZS->ZS_HORA    := Time()
	       SZS->ZS_LOG     := 'REC' //'ALT'
	       SZS->ZS_RESP    := cUserName
	       SZS->ZS_DEPTO   := cDepart
	       SZS->ZS_PARECER :=_txtNfDev  
	       dbselectarea("SZS")
	       MsUnLock()
    
           MSGINFO(_txtNfDev, "OK")    
             
           //dispara o email informando que tem mercadoria no armazem de reaproveitamento 
           _emailPCP :=emailPCP()
           u_WFDevSac(_emailPCP)
              
       Endif
Return


Static Function FLibProdBl(cGet1Sac,nOpc)
       Local nY
If nOpc =1 // DESBLOQUEAR PRODUTOS PARA ENTRADA DA NOTA
    aProdBloq :={}
    
	cQuery :=""
	cQuery +=" SELECT DISTINCT(B1_COD) FROM "+RetSqlName("SZR")+" SZR WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
	cQuery +=" ON (ZR_FILIAL = B1_FILIAL) AND (ZR_PRODUTO = B1_COD) AND SB1.D_E_L_E_T_ ='' " 
	cQuery +=" WHERE SZR.D_E_L_E_T_ ='' "
	cQuery +=" AND ZR_NUM ='"+Alltrim(cGet1Sac)+"' "
	cQuery +=" AND B1_MSBLQL ='1' "
	cQuery +=" AND B1_FILIAL ='"+xFilial("SB1")+"'"

	TCQuery cQuery ALIAS "TCQ" New
	DbSelectArea("TCQ")
    
    While !Eof()
        aAdd(aProdBloq, {Alltrim(TCQ->B1_COD)} )
		DbSelectArea("TCQ")
        DbSkip()
    Enddo
	DbSelectArea("TCQ")
    DbCloseArea()
	If Len(aProdBloq) >0
	    cQry1 := ""
	    cQry1 := " UPDATE "+RetSqlName("SB1")+" SET B1_MSBLQL = '2' "     
	  	cQry1 += " FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) "
	  	cQry1 += " LEFT OUTER JOIN "+RetSqlName("SZR")+" SZR WITH (NOLOCK) ON (ZR_FILIAL = B1_FILIAL) AND (ZR_PRODUTO = B1_COD) AND SB1.D_E_L_E_T_ ='' "
		cQry1 += " WHERE SZR.D_E_L_E_T_ ='' "
		cQry1 += " AND ZR_NUM ='"+Alltrim(cGet1Sac)+"' "
		cQry1 += " AND B1_MSBLQL ='1' "
		cQry1 += " AND B1_FILIAL = '"+xFilial("SB1")+"'"
	    TCSQLExec(cQry1) 
    Endif

Elseif nOpc =2  // BLOQUEAR NOVAMENTE OS PRODUTOS APÓS GERAÇÃO DA NOTA
	If Len(aProdBloq) >0
		For nY := 1 to Len(aProdBloq)
	        cQry1 := ""
	        cQry1 := " UPDATE "+RetSqlName("SB1")+" 
	        cQry1 += " SET B1_MSBLQL  = '1' "     
        	cQry1 += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
           	cQry1 += " AND B1_MSBLQL ='2' "
            cQry1 += " AND (D_E_L_E_T_ ='') AND B1_COD ='"+aProdBloq[nY][1]+"'"
            TCSQLExec(cQry1)
        Next
	Endif	
Endif
Return      
 /*

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fCon1Usu() - CONFIRMAÇÃO DOS ACESSOS
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function fConfUsu()
       Local nY
       Local nX
       cRot1SZW := Stuff(cRot1SZW, 1, Len(cGet1Sen), cGet1Sen)
       For nY := 1 To Len(oBrw1Usu:aCols)
           If oBrw1Usu:aCols[nY][noBrw1Usu+1]
              DbSelectArea("SZW")
              DbSetOrder(4)
              DbSeek(xFilial("SZW")+cRot1SZW+oBrw1Usu:aCols[nY][1], .t.)
              If Found()
                 RecLock("SZW", .f.)
                    DbDelete()
                dbselectarea("SZW")
                msunlock()
              Endif
           Else
              DbSelectArea("SZW")
              DbSetOrder(4)
              DbSeek(xFilial("SZW")+cRot1SZW+oBrw1Usu:aCols[nY][1], .t.)
              If Found()
                 RecLock("SZW", .f.)
                    SZW->ZW_DTALTER := dDataBase
                    SZW->ZW_USERALT := cUserName
                    SZW->ZW_DEPTO   := oBrw1Usu:aCols[nY][3]
              Else
                 RecLock("SZW", .t.)
                    SZW->ZW_FILIAL  := xFilial('SZW')
                    SZW->ZW_EMPFIL  := SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2)
                    SZW->ZW_DTINCLU := dDataBase
                    SZW->ZW_USERINC := cUserName
                    SZW->ZW_ROTINA  := cRot1SZW
                    SZW->ZW_USUARIO := oBrw1Usu:aCols[nY][1]
                    SZW->ZW_DEPTO   := oBrw1Usu:aCols[nY][3]
              Endif
              cAcesso := space(10)
              aPosica := {}
              For nX := 4 To Len(oBrw1Usu:aHeader)
                  aAdd(aPosica, {SubStr(oBrw1Usu:aHeader[nX][1], 1, 2), Iif(oBrw1Usu:aCols[nY][nX] $ 'S', '*', '') } )
              Next
              For nX := 1 To Len(aPosica)
                  cAcesso := Stuff(cAcesso, Val( aPosica[nX][1] ), 1, aPosica[nX][2])
              Next
              SZW->ZW_ACESSOS := cAcesso
              dbselectarea("SZW")
              msunlock()
           Endif
       Next
Return*/

// Permitir ou não a exclusão do Anexo 

User Function MsDocVst()

Local aArea	:= GetArea()
Local cAlias	:= ParamIxb[1]
Local nReg	    := ParamIxb[2]
Local lRet		:= .T.

DbSelectArea(cAlias)
DbGoTo(nReg)

// Verificar se o Sac já foi encerrado para não permitir inclusão ou exclusão de documentos....
//If cAlias $ 'SZQ'
 //	If SZQ->ZQ_STATUS =='2'
  //		MsgInfo("Não é possível incluir / alterar / excluir documentos para esse SAC, pois o mesmo já foi encerrado.")
//		lRet := .F.
 //	Endif
//Endif
RestArea(aArea)

Return lRet
   

/**
*	verifica se o parametro existe, senao cria 
*   
*/     
Static Function armazPA()

lArmazem:= space(2)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZR")+"MV_ARMPA" ))     
    //lArmazem := SX6->X6_CONTEUD
	lArmazem := GetMV( "MV_ARMPA" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZR") 
	SX6->X6_VAR  := "MV_ARMPA"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "Almoxerifado Padrao de Produto Acabado."
	SX6->X6_DSCSPA  := "Almoxerifado Padrao de Produto Acabado."
	SX6->X6_DSCENG  := "Almoxerifado Padrao de Produto Acabado."
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	SX6->X6_CONTEUD := "D1"
	SX6->X6_CONTENG := "D1"
	SX6->X6_CONTSPA := "D1"
	SX6->(MsUnLock())   */
	
	lArmazem:= "D1" 
	  
Endif			  

//SX2->(MsUnlock())
//SX6->(DbCloseArea())


Return  lArmazem

/**
*	verifica se o parametro existe, senao cria 
*   
*/     
Static Function emailPCP()

lArmazem:= space(50)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZR")+"MV_MAILPCP" ))     
    //lArmazem := SX6->X6_CONTEUD
    lArmazem := GetMV( "MV_MAILPCP" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZR") 
	SX6->X6_VAR  := "MV_MAILPCP"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "Email do responsavel do PCP para envio do worflow."
	SX6->X6_DSCSPA  := "Email do responsavel do PCP para envio do worflow."
	SX6->X6_DSCENG  := "Email do responsavel do PCP para envio do worflow."
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	SX6->X6_CONTEUD := "gustavo@brasilux.com.br; tiagobianchi@brasilux.com.br"
	SX6->X6_CONTENG := "gustavo@brasilux.com.br; tiagobianchi@brasilux.com.br"
	SX6->X6_CONTSPA := "gustavo@brasilux.com.br; tiagobianchi@brasilux.com.br"
	SX6->(MsUnLock())   */
	
	lArmazem:= "brasiluxtintas@brasilux.com.br"
	  
Endif			  

//SX2->(MsUnlock())
//SX6->(DbCloseArea())

Return  lArmazem



// FUNÇÃO PARA ENVIO DO WORKFLOW NO MOMENTO DA APROVAÇÃO DO ABATIMENTO GERADO VIA SAC.
Static Function EmailCobr()

cEmailCob:= space(60)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZQ")+"MV_MAILCOB" ))     
    //cEmailCob := SX6->X6_CONTEUD
    cEmailCob := GetMV( "MV_MAILCOB" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZQ") 
	SX6->X6_VAR  := "MV_MAILCOB"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "Emails para envio do workflow de abatimentos aprovados em SAC."
	SX6->X6_DSCSPA  := "Emails para envio do workflow de abatimentos aprovados em SAC."
	SX6->X6_DSCENG  := "Emails para envio do workflow de abatimentos aprovados em SAC."
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	SX6->X6_CONTEUD := "cobranca@brasilux.com.br"
	SX6->X6_CONTENG := "cobranca@brasilux.com.br"
	SX6->X6_CONTSPA := "cobranca@brasilux.com.br"
	SX6->(MsUnLock()) */  
	
	cEmailCob:= "brasiluxtintas@brasilux.com.br"
	  
Endif			  

//SX2->(MsUnlock())

Return  cEmailCob



/**
*	verifica se o parametro existe, senao cria 
*   
*/     
Static Function armazReapr()

lArmazem:= space(2)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZR")+"MV_REAPROV" ))     
    //lArmazem := SX6->X6_CONTEUD
	lArmazem := GetMV( "MV_REAPROV" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZR") 
	SX6->X6_VAR  := "MV_REAPROV"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "Almoxerifado Padrao de Produto p/ Reaproveitamento."
	SX6->X6_DSCSPA  := "Almoxerifado Padrao de Produto p/ Reaproveitamento."
	SX6->X6_DSCENG  := "Almoxerifado Padrao de Produto p/ Reaproveitamento."
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	SX6->X6_CONTEUD := "13"
	SX6->X6_CONTENG := "13"
	SX6->X6_CONTSPA := "13"
	SX6->(MsUnLock())   */
	
	lArmazem:= "03" 
	  
Endif			  

SX2->(MsUnlock())
//SX6->(DbCloseArea())


Return  lArmazem

/**
*	verifica se o parametro existe, senao cria 
*   
*/     
Static Function paramCC()

lArmazem:= space(2)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZR")+"MV_CCTRANS" ))      
    //lArmazem := SX6->X6_CONTEUD
	lArmazem := GetMV( "MV_CCTRANS" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZR") 
	SX6->X6_VAR  := "MV_CCTRANS"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "Centro de Custo Padrao p/ Movimento Interno de Perda"
	SX6->X6_DSCSPA  := "Centro de Custo Padrao p/ Movimento Interno de Perda"
	SX6->X6_DSCENG  := "Centro de Custo Padrao p/ Movimento Interno de Perda"
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	
	_cc := ""
	if xfilial("SZR") == '010101' 
		_cc := '148D1001'
	elseif xfilial("SZR") == '010104'
		_cc := '148F1001'
	elseif xfilial("SZR") == '060101' 
		_cc:= '148R1001'
	endif
	
	SX6->X6_CONTEUD := _cc
	SX6->X6_CONTENG := _cc
	SX6->X6_CONTSPA := _cc
	SX6->(MsUnLock())  */ 
	                               
	lArmazem:= _cc          
	
	
	  
Endif			  

//SX2->(MsUnlock())
//SX6->(DbCloseArea())


Return  lArmazem
  

/**
*	verifica se o parametro existe, senao cria 
*   Parametro do armazem de reaproveitamento  
*/     
Static Function endArmzRcb()

lArmazem:= space(2)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZR")+"MV_ARMZRCB" ))      
    //lArmazem := SX6->X6_CONTEUD
	lArmazem := GetMV( "MV_ARMZRCB" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZR") 
	SX6->X6_VAR  := "MV_ARMZRCB"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "Endereco Fisico Padrao de Recebimento"
	SX6->X6_DSCSPA  := "Endereco Fisico Padrao de Recebimento"
	SX6->X6_DSCENG  := "Endereco Fisico Padrao de Recebimento"
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	SX6->X6_CONTEUD := "F1RCBP01A"
	SX6->X6_CONTENG := "F1RCBP01A"
	SX6->X6_CONTSPA := "F1RCBP01A"
	SX6->(MsUnLock())   */
	                               
	lArmazem:= "F1RCBP01A"          
		
	  
Endif			  

SX2->(MsUnlock())
//SX6->(DbCloseArea())

Return  lArmazem

/**
*	verifica se o parametro existe, senao cria 
*   Parametro do armazem de reaproveitamento  
*/     
Static Function endArmzRpv()

lArmazem:= space(2)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZR")+"MV_ARMZRPV" ))      
    //lArmazem := SX6->X6_CONTEUD
	lArmazem := GetMV( "MV_ARMZRPV" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZR") 
	SX6->X6_VAR  := "MV_ARMZRPV"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "Endereco Fisico Padrao de Reaproveitamento"
	SX6->X6_DSCSPA  := "Endereco Fisico Padrao de Reaproveitamento"
	SX6->X6_DSCENG  := "Endereco Fisico Padrao de Reaproveitamento"
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	SX6->X6_CONTEUD := "F1RPVP01A"
	SX6->X6_CONTENG := "F1RPVP01A"
	SX6->X6_CONTSPA := "F1RPVP01A"
	SX6->(MsUnLock())*/   
	                               
	lArmazem:= "F1RPVP01A"          
Endif			  

//SX2->(MsUnlock())
//SX6->(DbCloseArea())


Return  lArmazem


/**
*	verifica se o parametro existe, senao cria 
*   
*/     
Static Function paramTM()

lArmazem:= space(2)   
	  
dbSelectArea("SX6")                    
SX6->(dbSetOrder(1))
If SX6->(dbSeek(xfilial("SZR")+"MV_TMTRANS" ))     
    //lArmazem := SX6->X6_CONTEUD
	lArmazem := GetMV( "MV_TMTRANS" )  //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
Else 
	SX6->(dbSetOrder(1))	
    //LGS#20200211 - Adequação de release 12.1.25 e posteriores - Acesso direto ao dicionário descontinuado
	/*RecLock( "SX6", .T. )
	SX6->X6_FIL  := xfilial("SZR") 
	SX6->X6_VAR  := "MV_TMTRANS"
	SX6->X6_TIPO := "C"
	SX6->X6_DESCRIC := "TM Padrao p/ Movimento Interno de Perda"
	SX6->X6_DSCSPA  := "TM Padrao p/ Movimento Interno de Perda"
	SX6->X6_DSCENG  := "TM Padrao p/ Movimento Interno de Perda"
	SX6->X6_DESC1   := " " 
	SX6->X6_DSCSPA1 := " " 
	SX6->X6_DSCENG1 := " " 
	SX6->X6_DESC2   := " "
	SX6->X6_DSCSPA2 := " " 
	SX6->X6_DSCENG2 := " "
	SX6->X6_CONTEUD := "700"
	SX6->X6_CONTENG := "700"
	SX6->X6_CONTSPA := "700"
	SX6->(MsUnLock()) */  
	
	lArmazem:= "700"
	  
Endif			  

//SX2->(MsUnlock())
//SX6->(DbCloseArea())


Return  lArmazem



Static Function ValidaSAC()
    Local nY
	//Local nPosSEQ := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_SEQITEM" } )
    //Local nPosPRO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_PRODUTO" } )
    Local nPosQTD := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTD"     } )
    //alterado dyego
    Local nPosQAPRRT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QAPRRET" } )   
        
    //Local nPosQTO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDORIG" } )
    //Local nPosPED := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_PEDIDO"  } )
    Local nPosNNF := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_NUMNF"   } )
    Local nPosSNF := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_SERNF"   } )
    //Local nPosVUO := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_VUORI"   } )
    //Local nPosVUT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_VTORI"   } )
    //Local nPosLOT := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_LOTE"    } )
    //Local nPosVLD := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_DTVALID" } )
    //Local nPosQTP := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDPRO"  } )
    //Local nPosRET := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_RETEN"   } )
    //Local nPosDEV := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_ITEMDEV" } )

	//Local nPosQDTABA := aScan(oBrw1Sac:aHeader, {|x| Alltrim(x[2]) == "ZR_QTDABAT" } )       
    lRet := .T.                   
    
    _NFAnt := ""
    _NFAtu := ""    
    
    _SerieAnt := ""
    _SerieAtu := ""    
    
            
    For nY := 1 To Len(oBrw2SAC:aCols)
    	If !oBrw2SAC:aCols[nY][Len(aHoBrw2SAC)+1] .AND. oBrw2Sac:aCols[nY][aScan(aHoBrw2Sac, {|x| Alltrim(Upper(x[2])) == 'ZR_ITEMDEV'})] $ '1'
     		// QTD NF RECEBIDA
        	If oBrw2SAC:aCols[nY][8] <>  oBrw1Sac:aCols[nY][nPosQTD]
         		MsgStop('Atenção, a quantidade da nota é diferente do que foi aprovado no SAC. Produto: ' + alltrim(oBrw2SAC:aCols[nY][3]) +" Item: "+ alltrim(oBrw2SAC:aCols[nY][1])) //nPosSEQ
           		lRet := .F.
           		Exit
			Endif 
							          
			//VERIFICA A QUANTIDADE FISICA
			If (oBrw2SAC:aCols[nY][9]+oBrw2SAC:aCols[nY][10]) <>  oBrw1Sac:aCols[nY][nPosQAPRRT]
	  			MsgStop('Atenção, a quantidade fisica é diferente do que foi aprovado no SAC.Produto: ' + alltrim(oBrw2SAC:aCols[nY][3]) +" Item: "+ alltrim(oBrw2SAC:aCols[nY][1])) 
	     		lRet := .F.
	     		Exit
			Endif 
									
			//VERIFICA A QUANTIDADE DE PERDA
			If (oBrw2SAC:aCols[nY][11]) <>  (  oBrw1Sac:aCols[nY][nPosQTD] - oBrw1Sac:aCols[nY][nPosQAPRRT]   )
	 			MsgStop('Atenção, a quantidade perda é diferente do que foi aprovado no SAC. Produto: ' + alltrim(oBrw2SAC:aCols[nY][3]) +" Item: "+ alltrim(oBrw2SAC:aCols[nY][1]))
	            lRet := .F.
	            Exit
			Endif
		                          
			_NFAtu 		:=	oBrw1Sac:aCols[nY][nPosNNF]
			_SerieAtu 	:=	oBrw1Sac:aCols[nY][nPosSNF]
			
			 
			//VALIDA SE FOR FORMULARIO PROPRIO SE HA MAIS DE UMA NOTA
		  //	If ( _cCombo == 'SIM'  .and. nY > 1 .and.  !(_NFAnt ==  _NFAtu .and. _SerieAnt == _SerieAtu) ) 
	 	//		MsgStop('Atenção, havendo devolução em formulário próprio, não é permitido mais de uma nota de devolução. Solicite ao SAC que deixe apenas os itens da nota referente ao formulário próprio. NF(1):  ' + 	_NFAnt    +" NF(2): "+ _NFAtu )
	     //       lRet := .F.
	      //      Exit
		//	Endif
		    
		    //VERIFICA O TIPO DE ENTRADA
			If ( EMPTY(oBrw2SAC:aCols[nY][12])  )
	 			MsgStop('Atenção, é necessário preecher o campo "Tipo de Entrada". Produto ' + alltrim(oBrw2SAC:aCols[nY][3]) +" Item: "+ alltrim(oBrw2SAC:aCols[nY][1]))
	            lRet := .F.
	            Exit
			Endif
		  
		    //VERIFICA O CF
			If ( EMPTY(oBrw2SAC:aCols[nY][13])  )
	 			MsgStop('Atenção, é necessário preecher o campo "C.F.O.P.". Produto ' + alltrim(oBrw2SAC:aCols[nY][3]) +" Item: "+ alltrim(oBrw2SAC:aCols[nY][1]))
	            lRet := .F.
	            Exit
			Endif
		    
			_NFAnt 	  :=   _NFAtu
    		_SerieAnt := _SerieAtu
					
       	Endif
	Next
                 
Return lRet   


/**
Faz a transferencia de armazens dos produtos avariados
*/            
Static Function TransfArma(aCols)

Local aAuto 		:= {}
Local aItem			:= {}
Local cStrErr     := ""
Local cNumDoc     := NextNumero("SD3",2,"D3_DOC",.T.)
Local nI          := 0
Local nOpcAuto		:= 3 
Local cProduto // Cod Produto
Local cDescProd // Descrição do produto
Local cUM // Unidade de medida
Local cArmOri     := armazPA() // Armazem origem
Local cArmDest    := armazReapr()	 // Armazem destino
Local cLote	      := "" // Lote
Local nQuant // Quantidade
PRIVATE aRegSD3   := {} 
Private lMsErroAuto := .F.

//Local cEndDest := endArmzRpv() // Endereço destino
//Local cNumSer  := "" // Numero de série
//Local cEndOri  := endArmzRcb() // Endereço de origem
//Local cObs   	:= "" // Observação
//Local cValidade:= criavar('D3_DTVALID') // Validade


//cCusMed  := GetMv("MV_CUSMED")  

/*
If cCusMed == "O"
   PRIVATE nHdlPrv    // Endereco do arquivo de contra prova dos lanctos cont.
   PRIVATE lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
   PRIVATE cLoteEst    // Numero do lote para lancamentos do estoque

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   dbSelectArea("SX5")
   SX5->(dbSeek(xFilial("SX5")+"09EST"))
   cLoteEst:=IIf(Found(),Trim(X5Descri()),"EST ")
   PRIVATE nTotal := 0  // Total dos lancamentos contabeis
   PRIVATE cArquivo  // Nome do arquivo contra prova
EndIf
*/

_texto := "" 
_erro := .F.

For nI:=1 To Len(aCols)     
//	PutMv("MV_ESTNEG" , "N")

	SB1->(DBSEEK(xFilial("SB1") + aCols[nI][1] ))
	
	cProduto := aCols[nI][1]
	cDescProd := SB1->B1_DESC
	cUm := SB1->B1_UM
	nQuant := aCols[nI][2]
	
	IF !SB2->(DBSEEK(xFilial("SB2") + aCols[nI][1] + cArmDest ))
	   CriaSB2( cProduto, cArmDest)
	ENDIF
	
	aAuto     := {}
   aItem     := {}
	aadd(aAuto,{cNumDoc,dDataBase})  	
	aadd(aItem,	cProduto) 		 		   //D3_COD		
	aadd(aItem,	cDescProd)     			//D3_DESCRI				
	aadd(aItem,	cUm)  		 			   //D3_UM		
	aadd(aItem,	cArmOri)      			   //D3_LOCAL		
	aadd(aItem,	"")			   			//D3_LOCALIZ		
	aadd(aItem,	cProduto) 				   //D3_COD		
	aadd(aItem,	cDescProd)     			//D3_DESCRI				
	aadd(aItem,	cUm)  		  			   //D3_UM		
	aadd(aItem,	cArmDest)  		  		   //D3_LOCAL		
	aadd(aItem,	"")				   		//D3_LOCALIZ		
	aadd(aItem,	criavar("D3_NUMSERI"))	//D3_NUMSERI		
	aadd(aItem,	cLote)					   //D3_LOTECTL  		
	aadd(aItem,	"")         			   //D3_NUMLOTE		
	aadd(aItem,	criavar("D3_DTVALID"))  //D3_DTVALID					
	aadd(aItem,	0)						      //D3_POTENCI		
	aadd(aItem,	nQuant) 				      //D3_QUANT		
	aadd(aItem, criavar("D3_QTSEGUM"))	//D3_QTSEGUM
	aadd(aItem, criavar("D3_ESTORNO"))  //D3_ESTORNO
	aadd(aItem, criavar("D3_NUMSEQ"))   //D3_NUMSEQ 
	aadd(aItem, "")						   //D3_LOTECTL
	aadd(aItem,	criavar("D3_DTVALID"))  //D3_DTVALID					
	aadd(aItem,	"")						   //D3_ITEMGRD
	aadd(aItem,criavar("D3_OBSERVA"))   //D3_OBSERVA  

	lMsErroAuto := .f.
   aadd(aAuto,aItem)
	MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)				
		
	If lMsErroAuto			
	  	cStrErr := MemoLine( MemoRead( NomeAutoLog() ), 30, 1)
	   _erro := .T.
   	MostraErro()		
	Endif

   /* retirado em 05/05/2021 pois identificado que a transferência originada por essa função distorce o custo médio do produto

 	If !a260Processa(cProduto,cArmOri,nQuant,cNumDoc,DATE(),nQuant,cLote,Nil,cValidade,cNumSer,cEndOri,cProduto,cArmDest,cEndDest,,,,,,,,,,,,,,,,,,,,,) //,cEndDest,.T.,Nil,Nil,"MATA260",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
    	_erro := .T. 
   Endif         
   */

next nI

If _erro
 	erroTrans := .T.
Else		       
 	_texto  := "Foi gerada a Tranferencia de Armazem, documento: " + cNumDoc
Endif
//PutMv("MV_ESTNEG" , "N")                                                                      

Return _texto
                

/*Static Function nfPerda(aCols)
     Local aCabec     := {} 
     Local aItens     := {}
     //Local aLogErr      := {}
     Local nI
     //Local cNumPed      := GetSX8Num("SC5","C5_NUM")
     
     Local cNumPed := NextNumero("SC5",2,"C5_NUM",.T.)

	 Private lMsErroAuto     := .F.
     Private lMsHelpAuto     := .T.     

      
     _txtRet := ""
     
     
  	// Cabecalho
     Aadd(aCabec,{"C5_NUM",     cNumPed,Nil}) // Numero do Pedido 
     Aadd(aCabec,{"C5_TIPO","N",Nil}) // Tipo do Pedido
     Aadd(aCabec,{"C5_CLIENTE","000521",Nil}) // Codigo do Cliente
     Aadd(aCabec,{"C5_LOJACLI","01",Nil}) // Loja do Cliente
     Aadd(aCabec,{"C5_CLIENT","000521",Nil}) // Codigo do Cliente para entrega
     Aadd(aCabec,{"C5_LOJAENT","01",Nil}) // Loja para entrega
     Aadd(aCabec,{"C5_TIPOCLI","I",     Nil}) // Tipo do Cliente
     Aadd(aCabec,{"C5_CONDPAG","001",Nil}) // Condicao de pagamanto
     Aadd(aCabec,{"C5_EMISSAO",dDatabase,Nil}) // Data de Emissao
     Aadd(aCabec,{"C5_MOEDA",1,Nil}) // Moeda

   
     
     For nI:=1 To Len(aCols)     
          
     	cProduto := aCols[nI][1]
	
		nQuant := aCols[nI][2]
	    nPreco := aCols[nI][3]
	       
		SB1->(DBSEEK(xFilial("SB1") + aCols[nI][1] ))	
		cUm := SB1->B1_UM

     	Aadd(aItens,{{"C6_ITEM",strzero(nI, 2) ,Nil},; // Numero do Item no Pedido
			      {"C6_PRODUTO",cProduto,Nil},; // Codigo do Produto
			      {"C6_UM",cUm,Nil},; // Unidade de Medida Primar.
			      {"C6_QTDVEN",nQuant,Nil},; // Quantidade Vendida
			      {"C6_PRCVEN",nPreco,Nil},; // Preco Venda
			      {"C6_PRUNIT",nPreco,Nil},; // Preco Unitario
			      {"C6_VALOR",nQuant*nPreco,Nil},; // Valor Total do Item 
			      {"C6_TES","950",Nil},; // Tipo de Entrada/Saida do Item
			      {"C6_LOCAL",armazPA(),Nil},; // Almoxarifado 
			      {"C6_CLI","000521",Nil},; // Cliente 
			      {"C6_ENTREG",dDataBase,Nil}}) // Data da Entrega
			
			     
     next nI     
          
     begin transaction
	     MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3) 
	     
	     If lMsErroAuto
	             MostraErro()
	             DisarmTransaction() 
	             erroTrans := .T.
	     Else
           		_txtRet := "Foi gerado o pedido de venda: " + cNumPed
	    EndIf 
        
    End Transaction
Return _txtRet*/

Static Function movInterno(aCols)
Local nI                 
_cTm := paramTM() 
_cCC := paramCC()
_cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
_cTxtRet := "" 

_aItem2 := {}
_aCab2  :={	{"D3_TM"        ,_cTm     	, NIL},;           
			{"D3_DOC"   	,_cNumDoc   , NIL},; 
          	{"D3_EMISSAO"   ,ddatabase  , NIL},; 
          	{"D3_CC"        ,_cCC       , NIL}} 

For nI:=1 To Len(aCols)     
          
     	cProduto := aCols[nI][1]
	
		nQuant := aCols[nI][2]
	    nPreco := aCols[nI][3]
	                         
		aAdd(_aItem2,{ 	{"D3_COD"    , cProduto        ,NIL},; 
          		{"D3_QUANT"          , nQuant          ,NIL},;
          		{"D3_LOCALIZ"        , endArmzRcb()    ,NIL},; 
          		{"D3_LOCAL"          , armazPA()       ,NIL}}) //,;
          		   
          	
          		 
          	
next nI

begin transaction
          		
MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab2,_aItem2,3) 

If lMsErroAuto 
     Mostraerro() 
     DisarmTransaction() 
	 erroTrans := .T.	

Else     
	_cTxtRet := "Foi gerado o movimento interno: " + _cNumDoc
 
Endif
            
end transaction
          
Return   _cTxtRet         
                                                                                                     

     
Static Function retCFOP(_tes, _est)

_cf := space(4)

If SF4->(dbSetOrder(1), dbSeek(xFilial("SF4")+_tes))

	If _est == "EX"
		_cf := "7"+SubStr(SF4->F4_CF,2,3)
	ElseIf _est  == 'SP'
		_cf := "1"+SubStr(SF4->F4_CF,2,3)
	ElseIf _est  <> 'SP'
		_cf := "2"+SubStr(SF4->F4_CF,2,3)	
	Else
		_cf := SF4->F4_CF
	Endif  
	

	
Endif 

Return   _cf

/*Static Function enderecar(aCols)
Local nI                 
_cTm := paramTM() 
_cCC := paramCC()
_cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
_cTxtRet := "" 

_aItem2 := {}
_aCab2  :={	{"DA_FILIAL"        ,_cTm     	, NIL},;           
			{"DA_DOC"   	,_cNumDoc   , NIL},; 
          	{"DA_DATA"   ,ddatabase  , NIL},;      
          	{"DA_SERIE"   ,ddatabase  , NIL},;  
          	{"DA_CLIFOR"   ,ddatabase  , NIL},; 
          	{"D3_CC"        ,_cCC       , NIL}} 

For nI:=1 To Len(aCols)     
          
     	cProduto := aCols[nI][1]
	
		nQuant := aCols[nI][2]
	    nPreco := aCols[nI][3]
	                         
		aAdd(_aItem2,{ 	{"DB_PRODUTO"    , cProduto        ,NIL},; 
          		{"DB_QUANT"          , nQuant          ,NIL},;
          		{"DB_LOCALIZ"        , endArmzRcb()    ,NIL},; 
          		{"DB_LOCAL"          , armazPA()       ,NIL}}) //,;
          		   
          	
          		 
          	
next nI

begin transaction
          		
MSExecAuto({|x,y,z| MATA265(x,y,z)},_aCab2,_aItem2,3) 

If lMsErroAuto 
     Mostraerro() 
     DisarmTransaction() 
	 erroTrans := .T.	

Else     
	_cTxtRet := "Foi gerado o movimento interno: " + _cNumDoc
 
Endif
            
end transaction
          
Return   _cTxtRet*/         
                        
/*
ÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Ä Function  ³ SACA01_F() - CRIAÇÃO DO FILTRO PARA ATUALIZAÇÃO DO BROWSE DE      Ä
Ä		      ACORDO COM O DEPARTAMENTO DO USUÁRIO								Ä
Ä		      André 13/08/14													Ä 
Ä nOnOff  -- 1 LIGA FILTRO, 2 DESLIGA											Ä	 
Ä nOpcFil -- 1 FILTRA PENDENTES, 2 TODOS OS SACS ABERTOS                        Ä 
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/
User Function SACA01_F(nOnOff,nOpcFil)
    Local _cFiltro   := ""
    Local cDepart    :=	Substr(Posicione("SZW", 4, xFilial("SZW")+cRotUsu+cCodUsr+SUBSTR(cNumEmp,1,2)+SUBSTR(cNumEmp,FWSizeFilial()+1,2), "ZW_DEPTO"),1,3)

    If nOnOff ==1 
	  	If !Empty(_cFiltro)
   			_cFiltro += " .AND. "
   		Endif 
	   	If nOpcFil == 1 // Filtra Pendentes
			Do Case
            	Case Substr(cDepart,1,1) =='D'//Case Substr(cDepUsu,1,1) =='D'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'D')" // 'BR_AZUL'    },; //SAC com Diretoria
				Case Substr(cDepart,1,1) =='C'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'C')"// 'BR_AMARELO' },; //SAC com Comercial
				Case Substr(cDepart,1,1) =='F'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'F')"// 'BR_PINK'    },; //SAC com Financeiro
				Case Substr(cDepart,1,1) =='T'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'T')"// 'BR_MARRON'  },; //SAC com Técnico
				Case Substr(cDepart,1,1) =='P'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'P')"// 'BR_MARRON'  },; //SAC com Produção                           
				Case Substr(cDepart,1,1) =='S'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'S')"// 'BR_CINZA'   },; //SAC com Suprimentos - Compras
				Case Substr(cDepart,1,1) =='-'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ '-')"// 'BTCALC'   },; //SAC  Contabilidade
				Case Substr(cDepart,1,1) =='#'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ '#')"// 'INSTRUME'   },; //SAC Manutencao
				Case Substr(cDepart,1,1) =='E'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'E')"// 'BR_PRETO'   },; //SAC com Expedição
				Case Substr(cDepart,1,1) =='V'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'V')"// 'BR_CINZA '  },; //SAC com Depósito SP - Viamix
				Case Substr(cDepart,1,1) =='R'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'R')"// 'BR_LARANJA' },; //SAC com Recebimento
				Otherwise //(cDepUsu,1,1) =='A'
					_cFiltro += "(ZQ_STATUS == '1' .AND. ZQ_FLAG $ 'A.M')"// 'ENABLE' / BR_BRANCA   },; //SAC com Atendente e Sac com Resposta
			EndCase
		    oObjBrow:CleanExFilter()
			oObjBrow:DeleteFilter("Sacs Abertos") 
			oObjBrow:AddFilter("Pendentes do Depto",_cFiltro,,.t.,,,,"Pendentes do Depto") 	
	    	oObjBrow:SetUseFilter(.T.)
	    	oObjBrow:ExecuteFilter (.T.) // executa o filtro 			
			nReg := recno()
			DbGoto(nReg)
	    	oObjBroW:GoTo(nReg)
	   	Elseif nOpcFil == 2 // Filtra Todos os Abertos
	   		_cFiltro += '(ZQ_STATUS = "1") '        		
		    oObjBrow:CleanExFilter()
			oObjBrow:DeleteFilter("Pendentes do Depto") 
			oObjBrow:AddFilter("Sacs Abertos",_cFiltro,,.t.,,,,"Sacs Abertos")
			oObjBrow:SetUseFilter(.T.)			
			nReg := recno()
			DbGoto(nReg)
	    	oObjBroW:GoTo(nReg)
	   	Endif
	Elseif nOnOff == 2  // Desliga Filtro
		If oObjBrow:Filtrate()
			nReg := recno()
	    	oObjBrow:CleanExFilter()
			oObjBrow:DeleteFilter("Sacs Abertos") 
			oObjBrow:DeleteFilter("Pendentes do Depto")
		    oObjBrow:GetFilterDefault()
		    oObjBrow:SetUseFilter(.F.)
			DbGoto(nReg)
	    	oObjBroW:GoTo(nReg)
        Endif
	Endif     	
	Dbselectarea("SZQ")
	DbGotop()
Return

	
Static FUNCTION HD3Mail(cAssunto,cTexto,cPara) 

cCC      := "tiagobianchi@brasilux.com.br,michelly@brasilux.com.br"
				cArquivo := ''
				U_EnvMail(cAssunto,cTexto,cPara,cCC,cArquivo) 
Return nil

static Function chamMail(posicao)
Local cQuery
Local cAssunto
Local cTexto
Local cPara
Local cCC := " "

cQuery :=" SELECT ZW_FILIAL, ZW_ROTINA, ZW_USUARIO, ZH_NOME, ZH_EMAIL,ZW_DEPTO, X5_DESCENG "
cQuery +=" FROM "+RetSqlName("SZW")+" SZW "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '"+xFilial("SX5")+"' AND ZW_DEPTO = X5_CHAVE AND X5_TABELA = 'ZS' AND SX5.D_E_L_E_T_ ='' "
cQuery +=" LEFT OUTER JOIN "+RetSqlName("SZH")+" SZH ON ZH_FILIAL = '"+xFilial("SZH")+"' AND ZH_CODIGO = ZW_USUARIO AND SZH.D_E_L_E_T_ ='' "
cQuery +=" WHERE ZW_ROTINA ='BRSACA01' AND SZW.D_E_L_E_T_ ='' AND ZH_EMAIL <> '' AND X5_DESCENG IS NOT NULL AND ZW_FILIAL = '"+xFilial("SZW")+"'"
If Substr(posicao,0,3) = 'Dir'
	cQuery +=" AND ZW_DEPTO = 'DIR' "
ElseIf Substr(posicao,0,3) = 'Com'
	cQuery +=" AND ZW_DEPTO = 'COM' "
ElseIf Substr(posicao,0,3) = 'Fin'
	cQuery +=" AND ZW_DEPTO = 'FIN' "
ElseIf Substr(posicao,0,3) = 'Tec'            	
	cQuery +=" AND ZW_DEPTO = 'TEC' "
ElseIf Substr(posicao,0,3) = 'Exp'
	cQuery +=" AND ZW_DEPTO = 'EXP' "
ElseIf Substr(posicao,0,3) = 'Via'
	cQuery +=" AND ZW_DEPTO = 'VIA' "
ElseIf Substr(posicao,0,3) = '-Co'
	cQuery +=" AND ZW_DEPTO = '-CO' "
ElseIf Substr(posicao,0,3) = '#Ma'
	cQuery +=" AND ZW_DEPTO = '#MA' "
ElseIf Substr(posicao,0,3) = 'Rec'
	cQuery +=" AND ZW_DEPTO = 'REC' "
ElseIf Substr(posicao,0,3) = 'Pro'
	cQuery +=" AND ZW_DEPTO = 'PRO' "
ElseIf Substr(posicao,0,3) = 'Sup'
	cQuery +=" AND ZW_DEPTO = 'SUP' "
Else
	cQuery +=" AND ZW_DEPTO = 'ATE' "
EndIf

cQuery +=" ORDER BY ZW_FILIAL, ZW_DEPTO"
TCQUERY cQuery NEW ALIAS "TCQ"

DbSelectArea("TCQ")
DbGotop()
cPara:= TCQ->ZH_EMAIL
cAssunto := "FOI ENCAMINHADO UM NOVO SAC PARA O DEPARTAMENTO"
cTexto := "O SAC "+cGet1Sac+" FILIAL "+xFilial("SZS")+" CLIENTE "+cGet3Sac+" "+cGet4Sac+" FOI ENCAMINHADO PARA SEU DEPARTAMENTO"

dbselectarea("TCQ")
dbskip()
While !Eof()
	cCC += SUBSTR(TCQ->ZH_EMAIL,0,35)+";"
	dbselectarea("TCQ")
	dbskip()
EndDo
U_EnvMail(cAssunto,cTexto,cPara,cCC)
dbSelectArea("TCQ")
dbCloseArea()
Return
