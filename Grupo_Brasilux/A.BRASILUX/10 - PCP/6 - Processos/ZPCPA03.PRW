#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ZPCPA03
Chamada principal do programa de Log de apontamentos
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 08/07/2020
/*/
User Function ZPCPA03( )
     Local oBrowse

     oBrowse := FWMBrowse():New()
     oBrowse:SetAlias("ZZA")
     oBrowse:Activate()

Return

/*/{Protheus.doc} ZPCPA03X
Função para direcionamento das chamadas
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 08/07/2020
@param _nParam, numérico, parametro da opção de chamada do menu.
@return return_type, return_description
/*/
User Function ZPCPA03X( _nParam )
     Local _aButtons := { { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, {.F., Nil}, { .F., "Confirmar" }, { .T., "Cancelar" }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil } }
     If _nParam == 1     //Arquivar OPs
        ZPCPA03_A()
     elseIf _nParam == 2 //Apontamentos
        FWExecView( "Apontamentos", "ZPCPA03", MODEL_OPERATION_VIEW, , { || .T. }, , 0, , { || .T. } )
     elseIf _nParam == 3 //Apontamentos x Baixas
            FWExecView( "Apontamentos x Baixas", "ZPCPA04", MODEL_OPERATION_VIEW  , , { || .T. }, , 0, _aButtons, { || .T. } )
     elseIf _nParam == 4 //Manutenção de Usuários
            _aButtons := { { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, {.F., Nil}, { .T., "Salvar" }, { .T., "Cancelar" }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil }, { .F., Nil } }
            FWExecView( "Apontamentos x Baixas", "ZPCPA08", MODEL_OPERATION_UPDATE  , , { || .T. }, , 0, _aButtons, { || .T. } )
            //FWExecView( "Manutenção de Responsáveis", "ZPCPA05", MODEL_OPERATION_UPDATE, , { || .T. }, , 0, _aButtons, { || .T. } )
     elseIf _nParam == 5 //Parametrização do Apontamento
            MessageBox('Opção em desenvolvimento', 'Atenção', 64)
     elseIf _nParam == 6 //Parametrização do Apontamento
            ZPCPA03_P()
     Endif
Return

/*/{Protheus.doc} fRecebOp
Tela para apontamento de Ordem de Produção para marcação de arquivamento pelo PCP.
@type function
@version 1.0
@author Luís Gustavo
@since 01/07/2020
/*/
Static Function ZPCPA03_A()
       Private cGet1Tr   := Space(11)

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±	
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFontTr1", "oFontTr2", "oDlg1Tr", "oSay1Tr", "oSay2Tr", "oSay3Tr", "oGet1Tr")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oFontTr1  := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
       oFontTr2  := TFont():New( "MS Sans Serif", 0, -19, , .F., 0, , 400, .F., .F., , , , , , )
       oDlg1Tr   := MSDialog():New( 258, 232, 383, 570, "Arquiva Ordens de Produção", , , .F., , , , , , .T., , , .T. )
       oSay1Tr   := TSay():New( 023, 008, {|| "O.P..:"     }, oDlg1Tr, , oFontTr1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 032, 012)
       oGet1Tr   := TGet():New( 020, 047, {|u| If(PCount() > 0, cGet1Tr := u, cGet1Tr)}, oDlg1Tr, 088, 018, '@!'             , , CLR_BLACK, CLR_WHITE, oFontTr1, , , .T., "", , , .F., .F., , .F. , .F., ""      ,"cGet1Tr", , )
       oGet1Tr:bLostFocus := { || fArquivaOp( Alltrim( cGet1Tr ) ) }
       oBtn1Tr   := TButton():New( 046, 122, "Confirma", oDlg1Tr, { || fArquivaOp( Alltrim( cGet1Tr ) ) }, 048, 014, , oFontTr2, , .T., , "", , , , .F. )
       oDlg1Tr:Activate( , , , .T.)
Return

/*/{Protheus.doc} fArquivaOp
Valida e marca a Ordem de Produção recebida pelo PCP, como devolvida pela produção e arquivada
@type function
@version 1.0
@author Luís Gustavo
@since 01/07/2020
@param cNumOp, character, Numero da ordem de produção para arquivamento
/*/
Static Function fArquivaOp( cNumOp )
       Local lOpFechada := .t.

       If Empty( cGet1Tr )
          oGet1Tr:SetFocus()
          Return
       ElseIf Len( Alltrim( cGet1Tr ) ) == 6
              cGet1Tr := Alltrim( cGet1Tr ) + '01001'
       Endif	

       DbSelectArea("ZZA")
       ZZA->( DbSetOrder(2) )
       If !ZZA->( DbSeek( xFilial("ZZA") + cNumOp ) )
          Messagebox( "Ordem de produção Inexistente ou Excluída !! ", "Atenção...", 48 )
       ElseIf Posicione( "SB1", 1, xFilial("SB1") + ZZA->ZZA_PRODUT, "B1_TIPO" ) <> 'PI'
              Messagebox( "Confira apenas as ordens de produção principal (Produtos intermediários) !!", "Atenção...", 48 )
       Else
          If ZZA->ZZA_ENVIA $ 'S'
             Messagebox( "Ordem de produção devolvida anteriormente !!", "Atenção...", 48 )
             oGet1Tr:SetFocus()
             Return
          Else
             DbSelectArea("SC2")
             SC2->( DbSetOrder(13) )
             If SC2->( DbSeek( xFilial("SC2") + Alltrim( ZZA->ZZA_LOTE ) ) )
                While !Eof() .and. SC2->C2_FILIAL == ZZA->ZZA_FILIAL  .and. Alltrim( SC2->C2_LOTE ) == Alltrim( ZZA->ZZA_LOTE )
                      If Empty( SC2->C2_DATRF )
                         lOpFechada := .f.
                      Endif
                      DbSelectArea("SC2")
                      DbSkip()        	
                Enddo
             Endif
             If lOpFechada
                RecLock("ZZA", .f.)
                   ZZA->ZZA_ENVIA  := 'S' 
                   ZZA->ZZA_DTENV  := dDatabase
                   ZZA->ZZA_HENV   := Time()
                   ZZA->ZZA_RENV   := Alltrim( cUserName )
                MsUnLock()
             Else
                Messagebox( "Lote possui ordens de produção em aberto. Favor encerrar antes de Arquivar!!", "Atenção...", 48 )
             Endif
          Endif
       Endif
       DbSelectArea("ZZA")
       DbSetOrder(1)
       cGet1Tr := Space(11)
       oGet1Tr:SetFocus()
Return

Static Function MODELDEF()
       Local oModel
       Local oStrZZA := FWFormStrut( 1, 'ZZA' )
       Local oStrOPE := FWFormStrut( 1, 'ZZA' )
       Local oStrZZF := FWFormStrut( 1, 'ZZF' )
       Local oStrZZG := FWFormStrut( 1, 'ZZG' )

       DbSelectArea("ZZA")
       oModel := MPFormModel():New( 'MD_APT_MAT' )
       oModel:SetDescription( 'Apontamento' )

       oModel:AddFields( 'MASTERZZA', , oStrZZA )

       //Dados das Operações
       oModel:AddGrid( 'DETAILZZA', 'MASTERZZA', oStrOPE )
       oModel:getModel( 'DETAILZZA'):SetDescription( 'Dados das Operações' )
       oModel:SetRelation( 'DETAILZZA', { { 'ZZA_FILIAL', FWxFilial("ZZA") }, { 'ZZA_ORDEM', 'ZZA_ORDEM'} }, ZZA->(IndexKey( 2 ) ) )

       //Dados dos Materiais
       oModel:AddGrid( 'DETAILZZF', 'MASTERZZA', oStrZZF )
       oModel:getModel( 'DETAILZZF'):SetDescription( 'Dados dos Materiais' )
       oModel:SetRelation( 'DETAILZZF', { { 'ZZF_FILIAL', FWxFilial("ZZF") }, { 'ZZF_LOTE', 'ZZA_LOTE'} }, ZZF->(IndexKey( 2 ) ) )

       //Dados dos Operadores
       oModel:AddGrid( 'DETAILZZG', 'MASTERZZA', oStrZZG )
       oModel:getModel( 'DETAILZZG'):SetDescription( 'Dados dos Operadores' )
       oModel:SetRelation( 'DETAILZZG', { { 'ZZG_FILIAL', FWxFilial("ZZG") }, { 'ZZG_LOTE', 'ZZA_LOTE'} }, ZZG->(IndexKey( 2 ) ) )

       oModel:SetPrimaryKey( { 'ZZA_ORDEM' } )
Return oModel

Static Function VIEWDEF()
       Local oView
       Local oModel  := ModelDef()
       Local oStrZZA := FWFormStrut( 2, 'ZZA' )
       Local oStrOPE := FWFormStrut( 2, 'ZZA' )
       Local oStrZZF := FWFormStrut( 2, 'ZZF' )
       Local oStrZZG := FWFormStrut( 2, 'ZZG' )


       DbSelectArea("ZZA")
       //Campos retirados do cabeçalho
       oStrZZA:RemoveField( 'ZZA_FLAG'   )
       oStrZZA:RemoveField( 'ZZA_DTLOG'  )
       oStrZZA:RemoveField( 'ZZA_HORA'   )
       oStrZZA:RemoveField( 'ZZA_OPERAC' )
       oStrZZA:RemoveField( 'ZZA_HELP'   )
       oStrZZA:RemoveField( 'ZZA_FLAG'   )
       oStrZZA:RemoveField( 'ZZA_QUANT'  )
       oStrZZA:RemoveField( 'ZZA_DTINI'  )
       oStrZZA:RemoveField( 'ZZA_HINI'   )
       oStrZZA:RemoveField( 'ZZA_TARA'   )
       oStrZZA:RemoveField( 'ZZA_ID'     )
       oStrZZA:RemoveField( 'ZZA_DTPES'  )
       oStrZZA:RemoveField( 'ZZA_HPES'   )
       oStrZZA:RemoveField( 'ZZA_PESPES' )
       oStrZZA:RemoveField( 'ZZA_DTCOL'  )
       oStrZZA:RemoveField( 'ZZA_HCOL'   )
       oStrZZA:RemoveField( 'ZZA_PESCOL' )
       oStrZZA:RemoveField( 'ZZA_DTFIM'  )
       oStrZZA:RemoveField( 'ZZA_HFIM'   )
       oStrZZA:RemoveField( 'ZZA_PESFIN' )
       oStrZZA:RemoveField( 'ZZA_PESESP' )
       oStrZZA:RemoveField( 'ZZA_PESLAB' )
       oStrZZA:RemoveField( 'ZZA_TPENVA' )
       oStrZZA:RemoveField( 'ZZA_SEQENV' )
       oStrZZA:RemoveField( 'ZZA_ENVIA'  )
       oStrZZA:RemoveField( 'ZZA_HENV'   )
       oStrZZA:RemoveField( 'ZZA_RENV'   )
       oStrZZA:RemoveField( 'ZZA_DTENV'  )
       oStrZZA:RemoveField( 'ZZA_RAMPA'  )
       oStrZZA:RemoveField( 'ZZA_SOBRA'  )
       oStrZZA:RemoveField( 'ZZA_PERDA'  )
       oStrZZA:RemoveField( 'ZZA_SP'     )
       oStrZZA:RemoveField( 'ZZA_LIBLAB' )
       oStrZZA:RemoveField( 'ZZA_PROSOB' )
       oStrZZA:RemoveField( 'ZZA_GEROCO' )
       oStrZZA:RemoveField( 'ZZA_PESAPU' )
       oStrZZA:RemoveField( 'ZZA_PESAPB' )
       oStrOPE:SetProperty( 'ZZA_CAMPO', MVC_VIEW_TITULO, 'Local de Fabricação' )

       //Campos retirados das operações
       oStrOPE:RemoveField( 'ZZA_ORDEM'   )
       oStrOPE:RemoveField( 'ZZA_LOTE'    )
       oStrOPE:RemoveField( 'ZZA_PRODUT'  )
       oStrOPE:RemoveField( 'ZZA_FLAG'    )
       oStrOPE:RemoveField( 'ZZA_ID'      )
       oStrOPE:RemoveField( 'ZZA_TPENVA' )
       oStrOPE:RemoveField( 'ZZA_SEQENV' )
       oStrOPE:RemoveField( 'ZZA_ENVIA'  )
       oStrOPE:RemoveField( 'ZZA_HENV'   )
       oStrOPE:RemoveField( 'ZZA_RENV'   )
       oStrOPE:RemoveField( 'ZZA_DTENV'  )
       oStrOPE:RemoveField( 'ZZA_RAMPA'  )
       oStrOPE:RemoveField( 'ZZA_SOBRA'  )
       oStrOPE:RemoveField( 'ZZA_PERDA'  )
       oStrOPE:RemoveField( 'ZZA_SP'     )
       oStrOPE:RemoveField( 'ZZA_DTPES'  )
       oStrOPE:RemoveField( 'ZZA_HPES'   )
       oStrOPE:RemoveField( 'ZZA_DTCOL'  )
       oStrOPE:RemoveField( 'ZZA_HCOL'   )
       oStrOPE:RemoveField( 'ZZA_PESFIN' )
       oStrOPE:RemoveField( 'ZZA_DTLOG'  )
       oStrOPE:RemoveField( 'ZZA_HORA'   )
       oStrOPE:RemoveField( 'ZZA_HELP'   )
       oStrOPE:RemoveField( 'ZZA_CAMPO'  )
       oStrOPE:RemoveField( 'ZZA_LIBLAB' )
       oStrOPE:RemoveField( 'ZZA_PROSOB' )
       oStrOPE:RemoveField( 'ZZA_GEROCO' )
       oStrOPE:SetProperty( 'ZZA_OPERAC', MVC_VIEW_ORDEM, '01' )
       oStrOPE:SetProperty( 'ZZA_DTINI' , MVC_VIEW_ORDEM, '02' )
       oStrOPE:SetProperty( 'ZZA_HINI'  , MVC_VIEW_ORDEM, '03' )
       oStrOPE:SetProperty( 'ZZA_DTFIM' , MVC_VIEW_ORDEM, '04' )
       oStrOPE:SetProperty( 'ZZA_HFIM'  , MVC_VIEW_ORDEM, '05' )
       oStrOPE:SetProperty( 'ZZA_TARA'  , MVC_VIEW_ORDEM, '06' )
       oStrOPE:SetProperty( 'ZZA_PESPES', MVC_VIEW_ORDEM, '07' )
       oStrOPE:SetProperty( 'ZZA_PESCOL', MVC_VIEW_ORDEM, '08' )
       oStrOPE:SetProperty( 'ZZA_TARA'  , MVC_VIEW_ORDEM, '09' )
       oStrOPE:SetProperty( 'ZZA_PESESP', MVC_VIEW_ORDEM, '10' )
       oStrOPE:SetProperty( 'ZZA_QUANT' , MVC_VIEW_ORDEM, '11' )
       oStrOPE:SetProperty( 'ZZA_PESLAB', MVC_VIEW_ORDEM, '12' )

       //Campos retirados dos empenhos
       oStrZZF:RemoveField( 'ZZF_ORDEM'  )
       oStrZZF:RemoveField( 'ZZF_LOTE'   )
       oStrZZF:RemoveField( 'ZZF_TPEMP'  )
       oStrZZF:RemoveField( 'ZZF_XHABIL' )
       oStrZZF:SetProperty( 'ZZF_OPERAC', MVC_VIEW_ORDEM, '01' )

       //Campos retirados dos operadores
       oStrZZG:RemoveField( 'ZZG_ORDEM'  )
       oStrZZG:RemoveField( 'ZZG_LOTE'   )
       oStrZZG:RemoveField( 'ZZG_LOTE'   )
       oStrZZG:RemoveField( 'ZZG_PROENV' )
       oStrZZG:RemoveField( 'ZZG_SEQENV' )
       oStrZZG:SetProperty( 'ZZG_OPERAC', MVC_VIEW_ORDEM, '01' )


       oView := FWFormView():New()
       oView:SetModel( oModel )

       oView:AddField( 'FORM_ZZA', oStrZZA, 'MASTERZZA')
       oView:AddGrid( 'FORM_OPE', oStrOPE, 'DETAILZZA' )
       oView:AddGrid( 'FORM_MAT', oStrZZF, 'DETAILZZF' )
       oView:AddGrid( 'FORM_FUN', oStrZZG, 'DETAILZZG' )

       oView:CreateHorizontalBox( 'BOX_FORM_ZZA', 10)
       oView:CreateHorizontalBox( 'BOX_FORM_OPE', 25)
       oView:CreateHorizontalBox( 'BOX_FORM_MAT', 40 )
       oView:CreateHorizontalBox( 'BOX_FORM_FUN', 25 )

       oView:SetOwnerView( 'FORM_ZZA', 'BOX_FORM_ZZA' )
       oView:SetOwnerView( 'FORM_OPE', 'BOX_FORM_OPE' )
       oView:SetOwnerView( 'FORM_MAT', 'BOX_FORM_MAT' )
       oView:SetOwnerView( 'FORM_FUN', 'BOX_FORM_FUN' )

       oView:EnableTitleView( 'FORM_OPE', 'Dados das Operações'  )
       oView:EnableTitleView( 'FORM_MAT', 'Dados dos Materiais'  )
       oView:EnableTitleView( 'FORM_FUN', 'Dados dos Operadores' )

Return oView


Static Function ZPCPA03_P()
       //Local _cAcsPar := GetMV( "ZP_PAR0020" )

       //If _cAcsPar $ __cUserID
          oModal := FWDialogModal():New()
          oModal:SetEscClose(.T.)
          oModal:setTitle("Parametrização do ambiente produtivo")
          oModal:setSize( 300, 700 )
          oModal:createDialog()


          oModal:Activate()
       //Endif
Return
