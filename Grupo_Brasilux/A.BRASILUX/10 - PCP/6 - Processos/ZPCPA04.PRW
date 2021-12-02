#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

User Function ZPCPA04(  )
     Local oBrowse
     u_zcfga01( 'ZPCPA04' ) //LGS#2021201 - Gravação de log de utilização da rotina
     oBrowse := FWMBrowse():New()
     oBrowse:SetAlias("ZZA")
     oBrowse:Activate()

Return


Static Function MODELDEF()
       Local oModel
       Local oStrZZA := FWFormStrut( 1, 'ZZA' )
       Local oStrSC2 := FWFormStrut( 1, 'SC2' )
       Local oStrOPE := FWFormStrut( 1, 'ZZA' )
       Local oStrSH6 := FWFormStrut( 1, 'SH6' )
       Local oStrZZF := FWFormStrut( 1, 'ZZF' )
       Local oStrSD4 := FWFormStrut( 1, 'SD4' )
       Local oStrSD3 := FWFormStrut( 1, 'SD3' )

       oStrSH6:aFields[21][11] := ""

       DbSelectArea("ZZA")
       oModel := MPFormModel():New( 'MD_APT_MAT' )
       oModel:SetDescription( 'Apontamento' )
       oModel:AddFields( 'MASTERZZA', , oStrZZA )

       //Dados da Ordem de produção
       oModel:AddGrid( 'DETAILSC2', 'MASTERZZA', oStrSC2 )
       oModel:getModel( 'DETAILSC2'):SetDescription( 'Dados das Ordens' )
       oModel:SetRelation( 'DETAILSC2', { { 'C2_FILIAL', FWxFilial("SC2") }, { 'C2_LOTE', 'ZZA_LOTE'} }, SC2->(IndexKey( 13 ) ) )
       oStrSC2:AddField(                    ;
                        AllTrim('')        ,; // [01] C Titulo do campo
                        AllTrim('')        ,; // [02] C ToolTip do campo
                        'C2_X_LEGEN'       ,; // [03] C identificador (ID) do Field
                        'C'                ,; // [04] C Tipo do campo
                        50                 ,; // [05] N Tamanho do campo
                        0                  ,; // [06] N Decimal do campo
                        NIL                ,; // [07] B Code-block de validação do campo
                        NIL                ,; // [08] B Code-block de validação When do campo
                        NIL                ,; // [09] A Lista de valores permitido do campo
                        NIL                ,; // [10] L Indica se o campo tem preenchimento obrigatório
                        { || fSC2Legend() },; // [11] B Code-block de inicializacao do campo
                        NIL                ,; // [12] L Indica se trata de um campo chave
                        NIL                ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T.                 ) // [14] L Indica se o campo é virtual

       //Dados das Operações
       oModel:AddGrid( 'DETAILZZA', 'MASTERZZA', oStrOPE )
       oModel:getModel( 'DETAILZZA'):SetDescription( 'Dados das Operações' )
       oModel:SetRelation( 'DETAILZZA', { { 'ZZA_FILIAL', FWxFilial("ZZA") }, { 'ZZA_ORDEM', 'ZZA_ORDEM'} }, ZZA->(IndexKey( 2 ) ) )

       //Baixas por operações
       oModel:AddGrid( 'DETAILSH6', 'MASTERZZA', oStrSH6 )
       oModel:getModel( 'DETAILSH6'):SetDescription( 'Dados das Baixas' )
       oModel:SetRelation( 'DETAILSH6', { { 'H6_FILIAL', FWxFilial("SH6") }, { 'H6_OP', 'ZZA_ORDEM'} }, SH6->(IndexKey( 1 ) ) )

       //Dados dos Materiais
       oModel:AddGrid( 'DETAILZZF', 'MASTERZZA', oStrZZF )
       oModel:getModel( 'DETAILZZF'):SetDescription( 'Dados dos Materiais' )
       oModel:SetRelation( 'DETAILZZF', { { 'ZZF_FILIAL', FWxFilial("ZZF") }, { 'ZZF_LOTE', 'ZZA_LOTE'} }, ZZF->(IndexKey( 2 ) ) )

       //Dados dos empenhos
       oModel:AddGrid( 'DETAILSD4', 'MASTERZZA', oStrSD4 )
       oModel:getModel( 'DETAILSD4'):SetDescription( 'Dados dos Empenhos' )
       oModel:SetRelation( 'DETAILSD4', { { 'D4_FILIAL', FWxFilial("SD4") }, { 'D4_OP', 'ZZA_ORDEM'} }, SD4->(IndexKey( 2 ) ) )

       //Dados dos movimentos
       oModel:AddGrid( 'DETAILSD3', 'MASTERZZA', oStrSD3 )
       oModel:getModel( 'DETAILSD3'):SetDescription( 'Dados dos Movimentos' )
       oModel:SetRelation( 'DETAILSD3', { { 'D3_FILIAL', FWxFilial("SD3") }, { 'D3_OP', 'ZZA_ORDEM'} }, SD3->(IndexKey( 1 ) ) )

       oModel:SetPrimaryKey( { 'ZZA_ORDEM' } )
Return oModel

Static Function VIEWDEF()
       Local oView
       Local oModel  := ModelDef()
       Local oStrZZA := FWFormStrut( 2, 'ZZA' )
       Local oStrSC2 := FWFormStrut( 2, 'SC2' )
       Local oStrOPE := FWFormStrut( 2, 'ZZA' )
       Local oStrSH6 := FWFormStrut( 2, 'SH6' )
       Local oStrZZF := FWFormStrut( 2, 'ZZF' )
       Local oStrSD4 := FWFormStrut( 2, 'SD4' )
       Local oStrSD3 := FWFormStrut( 2, 'SD3' )

       DbSelectArea("ZZA")

       //Ajuste nos campos do cabeçalho
       oStrZZA:RemoveField( 'ZZA_FLAG'   ) ; oStrZZA:RemoveField( 'ZZA_DTLOG'  ) ; oStrZZA:RemoveField( 'ZZA_HORA'   )
       oStrZZA:RemoveField( 'ZZA_OPERAC' ) ; oStrZZA:RemoveField( 'ZZA_HELP'   ) ; oStrZZA:RemoveField( 'ZZA_FLAG'   )
       oStrZZA:RemoveField( 'ZZA_QUANT'  ) ; oStrZZA:RemoveField( 'ZZA_DTINI'  ) ; oStrZZA:RemoveField( 'ZZA_HINI'   )
       oStrZZA:RemoveField( 'ZZA_TARA'   ) ; oStrZZA:RemoveField( 'ZZA_ID'     ) ; oStrZZA:RemoveField( 'ZZA_DTPES'  )
       oStrZZA:RemoveField( 'ZZA_HPES'   ) ; oStrZZA:RemoveField( 'ZZA_PESPES' ) ; oStrZZA:RemoveField( 'ZZA_DTCOL'  )
       oStrZZA:RemoveField( 'ZZA_HCOL'   ) ; oStrZZA:RemoveField( 'ZZA_PESCOL' ) ; oStrZZA:RemoveField( 'ZZA_DTFIM'  )
       oStrZZA:RemoveField( 'ZZA_HFIM'   ) ; oStrZZA:RemoveField( 'ZZA_PESFIN' ) ; oStrZZA:RemoveField( 'ZZA_PESESP' )
       oStrZZA:RemoveField( 'ZZA_PESLAB' ) ; oStrZZA:RemoveField( 'ZZA_TPENVA' ) ; oStrZZA:RemoveField( 'ZZA_SEQENV' )
       oStrZZA:RemoveField( 'ZZA_ENVIA'  ) ; oStrZZA:RemoveField( 'ZZA_HENV'   ) ; oStrZZA:RemoveField( 'ZZA_RENV'   )
       oStrZZA:RemoveField( 'ZZA_DTENV'  ) ; oStrZZA:RemoveField( 'ZZA_RAMPA'  ) ; oStrZZA:RemoveField( 'ZZA_SOBRA'  )
       oStrZZA:RemoveField( 'ZZA_PERDA'  ) ; oStrZZA:RemoveField( 'ZZA_SP'     ) ; oStrZZA:RemoveField( 'ZZA_LIBLAB' )
       oStrZZA:RemoveField( 'ZZA_PROSOB' ) ; oStrZZA:RemoveField( 'ZZA_GEROCO' ) ; oStrZZA:RemoveField( 'ZZA_PESAPU' )
       oStrZZA:RemoveField( 'ZZA_PESAPB' )
       oStrOPE:SetProperty( 'ZZA_CAMPO', MVC_VIEW_TITULO, 'Local de Fabricação' )

       //Ajustes nos campos da Ordem de Produção
       oStrSC2:AddField(              ; // Ord. Tipo Desc.
                        'C2_X_LEGEN' ,; // [01] C   Nome do Campo
                        "00"         ,; // [02] C   Ordem
                        AllTrim( '' ),; // [03] C   Titulo do campo
                        AllTrim( '' ),; // [04] C   Descricao do campo
                        { 'Legenda' },; // [05] A   Array com Help
                        'C'          ,; // [06] C   Tipo do campo
                        '@BMP'       ,; // [07] C   Picture
                        NIL          ,; // [08] B   Bloco de Picture Var
                        ''           ,; // [09] C   Consulta F3
                        .T.          ,; // [10] L   Indica se o campo é alteravel
                        NIL          ,; // [11] C   Pasta do campo
                        NIL          ,; // [12] C   Agrupamento do campo
                        NIL          ,; // [13] A   Lista de valores permitido do campo (Combo)
                        NIL          ,; // [14] N   Tamanho maximo da maior opção do combo
                        NIL          ,; // [15] C   Inicializador de Browse
                        .T.          ,; // [16] L   Indica se o campo é virtual
                        NIL          ,; // [17] C   Picture Variavel
                        NIL           ) // [18] L   Indica pulo de linha após o campo

       //Campos retirados das operações
       oStrOPE:RemoveField( 'ZZA_ORDEM'  ) ; oStrOPE:RemoveField( 'ZZA_LOTE'   ) ; oStrOPE:RemoveField( 'ZZA_PRODUT' )
       oStrOPE:RemoveField( 'ZZA_FLAG'   ) ; oStrOPE:RemoveField( 'ZZA_ID'     ) ; oStrOPE:RemoveField( 'ZZA_TPENVA' )
       oStrOPE:RemoveField( 'ZZA_SEQENV' ) ; oStrOPE:RemoveField( 'ZZA_ENVIA'  ) ; oStrOPE:RemoveField( 'ZZA_HENV'   )
       oStrOPE:RemoveField( 'ZZA_RENV'   ) ; oStrOPE:RemoveField( 'ZZA_DTENV'  ) ; oStrOPE:RemoveField( 'ZZA_RAMPA'  )
       oStrOPE:RemoveField( 'ZZA_SOBRA'  ) ; oStrOPE:RemoveField( 'ZZA_PERDA'  ) ; oStrOPE:RemoveField( 'ZZA_SP'     )
       oStrOPE:RemoveField( 'ZZA_DTPES'  ) ; oStrOPE:RemoveField( 'ZZA_HPES'   ) ; oStrOPE:RemoveField( 'ZZA_DTCOL'  )
       oStrOPE:RemoveField( 'ZZA_HCOL'   ) ; oStrOPE:RemoveField( 'ZZA_PESFIN' ) ; oStrOPE:RemoveField( 'ZZA_DTLOG'  )
       oStrOPE:RemoveField( 'ZZA_HORA'   ) ; oStrOPE:RemoveField( 'ZZA_HELP'   ) ; oStrOPE:RemoveField( 'ZZA_CAMPO'  )
       oStrOPE:RemoveField( 'ZZA_LIBLAB' ) ; oStrOPE:RemoveField( 'ZZA_PROSOB' ) ; oStrOPE:RemoveField( 'ZZA_GEROCO' )
       oStrOPE:SetProperty( 'ZZA_OPERAC', MVC_VIEW_ORDEM, '01' ) ; oStrOPE:SetProperty( 'ZZA_DTINI' , MVC_VIEW_ORDEM, '02' )
       oStrOPE:SetProperty( 'ZZA_HINI'  , MVC_VIEW_ORDEM, '03' ) ; oStrOPE:SetProperty( 'ZZA_DTFIM' , MVC_VIEW_ORDEM, '04' )
       oStrOPE:SetProperty( 'ZZA_HFIM'  , MVC_VIEW_ORDEM, '05' ) ; oStrOPE:SetProperty( 'ZZA_TARA'  , MVC_VIEW_ORDEM, '06' )
       oStrOPE:SetProperty( 'ZZA_PESPES', MVC_VIEW_ORDEM, '07' ) ; oStrOPE:SetProperty( 'ZZA_PESCOL', MVC_VIEW_ORDEM, '08' )
       oStrOPE:SetProperty( 'ZZA_TARA'  , MVC_VIEW_ORDEM, '09' ) ; oStrOPE:SetProperty( 'ZZA_PESESP', MVC_VIEW_ORDEM, '10' )
       oStrOPE:SetProperty( 'ZZA_QUANT' , MVC_VIEW_ORDEM, '11' ) ; oStrOPE:SetProperty( 'ZZA_PESLAB', MVC_VIEW_ORDEM, '12' )

       //Campos retirados dos apontamentos
       //oStrSH6:RemoveField( 'H6_MOTIVO' ) ; oStrSH6:RemoveField( 'H6_DESCRI' )
       oStrSH6:aFields[21][11] := ""
       oStrSH6:RemoveField( 'H6_OP'      ) ; oStrSH6:RemoveField( 'H6_PRODUTO' ) ; oStrSH6:RemoveField( 'H6_RECURSO'  )
       oStrSH6:RemoveField( 'H6_FERRAM'  ) ; oStrSH6:RemoveField( 'H6_DESDOBR' ) ; oStrSH6:RemoveField( 'H6_OPERADO'  )
       oStrSH6:RemoveField( 'H6_PERDANT' ) ; oStrSH6:RemoveField( 'H6_SEQ'     ) ; oStrSH6:RemoveField( 'H6_POTENCIA' )
       oStrSH6:RemoveField( 'H6_RATEIO'  ) ; oStrSH6:RemoveField( 'H6_STATUS'  ) ; oStrSH6:RemoveField( 'H6_PERIMP'   )
  
       //Campos retirados dos empenhos
       oStrZZF:RemoveField( 'ZZF_ORDEM'  ) ; oStrZZF:RemoveField( 'ZZF_LOTE'   ) ; oStrZZF:RemoveField( 'ZZF_TPEMP'  )
       oStrZZF:RemoveField( 'ZZF_XHABIL' )
       oStrZZF:SetProperty( 'ZZF_OPERAC', MVC_VIEW_ORDEM, '01' )

       oView := FWFormView():New()
       oView:SetModel( oModel )
       oView:addUserButton( 'Legenda', 'NOTE', { || fMostraLeg() } )

       oView:AddField( 'FORM_ZZA', oStrZZA, 'MASTERZZA')
       oView:AddGrid( 'FORM_SC2', oStrSC2, 'DETAILSC2' )
       oView:AddGrid( 'FORM_OPE', oStrOPE, 'DETAILZZA' )
       oView:AddGrid( 'FORM_SH6', oStrSH6, 'DETAILSH6' )
       oView:AddGrid( 'FORM_MAT', oStrZZF, 'DETAILZZF' )
       oView:AddGrid( 'FORM_SD4', oStrSD4, 'DETAILSD4' )
       oView:AddGrid( 'FORM_SD3', oStrSD3, 'DETAILSD3' )

       oView:CreateHorizontalBox( 'BOX_FORM_ZZA', 10)
       oView:CreateHorizontalBox( 'BOX_FORM_SC2', 20)
       oView:CreateHorizontalBox( 'BOX_FORM_OPE', 35)
       oView:CreateVerticalBox( 'BOXOPE_ESQ', 49, 'BOX_FORM_OPE' )
       oView:CreateVerticalBox( 'BOXOPE_CEN', 01, 'BOX_FORM_OPE' )
       oView:CreateVerticalBox( 'BOXOPE_DIR', 50, 'BOX_FORM_OPE' )

       oView:CreateHorizontalBox( 'BOX_FORM_MAT', 35)
       oView:CreateVerticalBox( 'BOXMAT_ESQ', 32, 'BOX_FORM_MAT' )
       oView:CreateVerticalBox( 'BOXMAT_ESC', 01, 'BOX_FORM_MAT' )
       oView:CreateVerticalBox( 'BOXMAT_CEN', 34, 'BOX_FORM_MAT' )
       oView:CreateVerticalBox( 'BOXMAT_DIC', 01, 'BOX_FORM_MAT' )
       oView:CreateVerticalBox( 'BOXMAT_DIR', 32, 'BOX_FORM_MAT' )

       oView:SetOwnerView( 'FORM_ZZA', 'BOX_FORM_ZZA' )
       oView:SetOwnerView( 'FORM_SC2', 'BOX_FORM_SC2' )

       oView:SetOwnerView( 'FORM_OPE', 'BOXOPE_ESQ' )
       oView:SetOwnerView( 'FORM_SH6', 'BOXOPE_DIR' )

       oView:SetOwnerView( 'FORM_MAT', 'BOXMAT_ESQ' )
       oView:SetOwnerView( 'FORM_SD4', 'BOXMAT_CEN' )
       oView:SetOwnerView( 'FORM_SD3', 'BOXMAT_DIR' )

       oView:EnableTitleView( 'FORM_SC2', 'Dados da Ordem de Produção' )
       oView:EnableTitleView( 'FORM_OPE', 'Dados das Operações' )
       oView:EnableTitleView( 'FORM_SH6', 'Dados das Baixas'    )
       oView:EnableTitleView( 'FORM_MAT', 'Empenhos Apontados'  )
       oView:EnableTitleView( 'FORM_SD4', 'Empenhos da Ordem'   )
       oView:EnableTitleView( 'FORM_SD3', 'Dados dos Movimentos')
Return oView

Static Function fSC2Legend()
       Local aAreaSC2   := SC2->(GetArea())
       Local cRet       := ""
       Local cAliasTemp := ""
       Local cQuery     := ""
       Local nRegSD3    := 0   //Contador da tabela SD3
       Local nRegSH6    := 0           //Contador da tabela SH6
       Local dEmissao   := dDatabase

       cAliasTemp := "SD3TMP"
       cQuery     := "SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
       cQuery     += "FROM " + RetSqlName('SD3')
       cQuery     += "WHERE D3_FILIAL   = '" + SC2->C2_FILIAL + "' "
       cQuery     += "  AND D3_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "' "
       cQuery     += "  AND D3_ESTORNO <> 'S' "
       cQuery     += "  AND D_E_L_E_T_  = ' ' "
       cQuery     += "GROUP BY D3_EMISSAO "
       cQuery     := ChangeQuery( cQuery )
       dbUseArea ( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasTemp, .F., .T. )
       If !SD3TMP->(Eof())
          dEmissao := STOD( SD3TMP->EMISSAO )
          nRegSD3  := SD3TMP->RegSD3
       EndIf

       cAliasTemp := "SH6TMP"
       cQuery     := "SELECT COUNT(*) AS RegSH6 "
       cQuery     += "FROM " + RetSqlName('SH6')
       cQuery     += "WHERE H6_FILIAL   = '" + xFilial('SH6')+ "' "
       cQuery     += "  AND H6_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "' "
       cQuery     += "  AND D_E_L_E_T_  = ' ' "
       cQuery     := ChangeQuery( cQuery )
       dbUseArea ( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasTemp, .F., .T. )

       If !SH6TMP->(Eof())
          nRegSH6 := SH6TMP->RegSH6
       EndIf

       Do Case
          Case SC2->C2_TPOP == "P" //Prevista
               cRet := "BR_AMARELO"
          Case SC2->C2_TPOP == "F" .And.  Empty( SC2->C2_DATRF ) .And. ( nRegSD3 < 1 .And. nRegSH6 < 1 ) .And. (Max(dDataBase - SC2->C2_DATPRI,0) < If(SC2->C2_DIASOCI==0,1,SC2->C2_DIASOCI))    //Em aberto
               cRet := "BR_VERDE"
          Case SC2->C2_TPOP == "F" .And.  Empty( SC2->C2_DATRF ) .And. ( nRegSD3 > 0 .Or.  nRegSH6 > 0 ) .And. (Max((ddatabase - dEmissao),0) > If(SC2->C2_DIASOCI >= 0,-1,SC2->C2_DIASOCI))     //Iniciada
               cRet := "BR_LARANJA"
          Case SC2->C2_TPOP == "F" .And.  Empty( SC2->C2_DATRF ) .And. ( Max( ( ddatabase - dEmissao ), 0 ) > SC2->C2_DIASOCI .Or. Max( ( ddatabase - SC2->C2_DATPRI ), 0 ) >= SC2->C2_DIASOCI ) //Ociosa
               cRet := "BR_CINZA"
          Case SC2->C2_TPOP == "F" .And. !Empty( SC2->C2_DATRF ) .And. SC2->( C2_QUJE <  C2_QUANT )  //Enc.Parcialmente
               cRet := "BR_AZUL"
          Case SC2->C2_TPOP == "F" .And. !Empty( SC2->C2_DATRF ) .And. SC2->( C2_QUJE >= C2_QUANT ) //Enc.Totalmente
               cRet := "BR_VERMELHO"
       EndCase

       SD3TMP->(DbCloseArea())
       SH6TMP->(DbCloseArea())

       RestArea(aAreaSC2)
Return cRet

Static Function fMostraLeg()
     Local aLegenda := {}
     
     //Monta as cores
     aAdd( aLegenda, { "BR_AMARELO" , "Prevista"               } )
     aAdd( aLegenda, { "BR_VERDE"   , "Em aberto"              } )
     aAdd( aLegenda, { "BR_LARANJA" , "Iniciada"               } )
     aAdd( aLegenda, { "BR_CINZA"   , "Ociosa"                 } )
     aAdd( aLegenda, { "BR_AZUL"    , "Encerrada Parcialmente" } )
     aAdd( aLegenda, { "BR_VERMELHO", "Encerrada Totalmente"   } )
         
     BrwLegenda( "Ordem de produção", "Situação", aLegenda )

Return
