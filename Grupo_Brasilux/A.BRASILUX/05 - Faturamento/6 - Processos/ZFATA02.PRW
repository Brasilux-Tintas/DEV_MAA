#include 'totvs.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} ZFINF02
Liberação de pedidos de vendas.
@type function
@version  v2021.001
@author Luís Gustavo de Souza
@since 28/09/2021
/*/
User Function ZFATA02()
     Local _aArea       := GetArea()

     RestArea( _aArea )
Return

/*/{Protheus.doc} ModelDef
Modelo do objeto
@type function
@version  v2021.01
@author Luís Gustavo de Souza
@since 27/10/2021
@return variant, Retorna o objeto do modelo
/*/
Static Function ModelDef()
       Local oModel as Object
       Local oStr1  as Object
       Local oStr2  as Object
       Local oStr3  as Object

       u_zcfga01( "ZFATA02" )

       oStr1 := MontaCab( 1 )
       oStr2 := MontaCab( 3 )
       oStr3 := MontaCab( 5 )

       oModel := MPFormModel():New( "LIBERA", , { |oModel| fPosValid( oModel ) }, { |oModel| FGrava(oModel) } )
       oModel:SetDescription( "Liberação de Pedidos" )
       oModel:addFields( 'MASTERPED', , oStr1, , , { |oModel| FLCab( oModel ) } )
       oModel:getModel( 'MASTERPED' ):SetDescription( 'Pedido de Vendas' )

       oModel:AddGrid( "GRIDPEDIDO", "MASTERPED", oStr2, /*{ || FLinePre() }*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, { |oModel, _lCopy| fLItem( oModel, _lCopy ) } )
       oModel:getModel( 'GRIDPEDIDO' ):SetDescription( 'Pedidos a Liberar' )
       oModel:getModel( 'GRIDPEDIDO' ):SetNoInsertLine( .T. )
       oModel:getModel( 'GRIDPEDIDO' ):SetNoDeleteLine( .T. )

       oModel:AddGrid( "GRIDVALOR", "MASTERPED", oStr3, /*{ || FLinePre() }*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, { |oModel, _lCopy| fLValor( oModel, _lCopy ) } )
       oModel:getModel( 'GRIDVALOR' ):SetDescription( 'Valores Totais' )
       oModel:getModel( 'GRIDVALOR' ):SetNoInsertLine( .T. )
       oModel:getModel( 'GRIDVALOR' ):SetNoDeleteLine( .T. )

       oModel:GetModel( 'GRIDPEDIDO' ):SetUseOldGrid( .T. )
       oModel:getModel( 'GRIDVALOR' ):SetUseOldGrid( .T. )
Return oModel

/*/{Protheus.doc} ViewDef
View da funcionalidade de liberação de pedidos
@type function
@version  V2021.01
@author Luís Gustavo de Souza
@since 12/11/2021
@return Object, Retorna os dados da view
/*/
Static Function ViewDef()
       Local oView      as Object
       Local oModel     as Object
       Local oStr1      as Object
       Local oStr2      as Object
       Local oStr3      as Object
       Private _oTable1 as Object
       Private _oTable2 as Object
       Private _oTable3 as Object
       //Private bPesquisar := { |oView| FWMsgRun( , { || fPesPed(oView) }, "Aguarde...", "Pesquisando"           ) }
       bHistorico := { |oView| FWMsgRun( , { || fHisPed(oView) }, "Aguarde...", "Processando histórico" ) }
       bItensPedi := { |oView| FWMsgRun( , { || fItePed(oView) }, "Aguarde...", "Processando itens"     ) }
       bDadosPedi := { |oView| FWMsgRun( , { || fDadPed(oView) }, "Aguarde...", "Dados do pedido"       ) }
       bPlanilhaF := { |oView| FWMsgRun( , { || fPlaFin(oView) }, "Aguarde...", "Montando planilha"     ) }
       bTitAberto := { |oView| FWMsgRun( , { || fTAbFin(oView) }, "Aguarde...", "Consutando titulos"    ) }
       bTitRecebi := { |oView| FWMsgRun( , { || fTReFin(oView) }, "Aguarde...", "Consutando titulos"    ) }
       bDadosClie := { |oView| FWMsgRun( , { || fDadCli(oView) }, "Aguarde...", "Dados do Cliente"      ) }

       oModel := ModelDef()
       
       oStr1  := MontaCab( 2 )
       oStr2  := MontaCab( 4 )
       oStr3  := MontaCab( 6 )
       
       oStr2:SetProperty( 'CLIENTE' , MVC_VIEW_WIDTH, 350 )
       oStr2:SetProperty( 'CONDICAO', MVC_VIEW_WIDTH, 200 )
       oStr2:SetProperty( 'VENDEDOR', MVC_VIEW_WIDTH, 350 )
       oStr2:SetProperty( 'TRANSPOR', MVC_VIEW_WIDTH, 350 )
       oStr3:SetProperty( 'VALIPI', MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'VALSUB', MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'VALMAR', MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'PERMAR', MVC_VIEW_WIDTH, 090 )
       oStr3:SetProperty( 'VALLUC', MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'PERLUC', MVC_VIEW_WIDTH, 090 )
       oStr3:SetProperty( 'VALCOM', MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'PERCOM', MVC_VIEW_WIDTH, 090 )
       oView := FWFormView():New()
       oView:SetModel( oModel )
       
       //Inclusão do Field do formulário
       oView:AddField( 'FORM_PED' , oStr1, 'MASTERPED' )
       oView:CreateHorizontalBox( 'BOX_FORM_PED', 0 )
       oView:SetOwnerView( 'FORM_PED', 'BOX_FORM_PED' )

       //Inclusão dos Grids na View
       oView:AddGrid( "VIEW_PED" , oStr2, "GRIDPEDIDO" )
       oView:CreateHorizontalBox( 'BOX_FORM_ITE', 36 )
       oView:SetOwnerView( 'VIEW_PED', 'BOX_FORM_ITE' )
       oView:EnableTitleView( 'VIEW_PED', 'Pedidos a Liberar')

       oView:AddOtherObject( 'COMPLEMENTO', { | oPanel | fComple(oPanel) }, { || }, { |oPanel| fComple(oPanel) } )
       oView:CreateHorizontalBox( 'BOX_FORM_DAD', 06 )
       oView:SetOwnerView( 'COMPLEMENTO', 'BOX_FORM_DAD' )

       oView:AddGrid( "VIEW_VAL" , oStr3, "GRIDVALOR" )
       oView:CreateHorizontalBox( 'BOX_FORM_VAL', 16 )
       oView:SetOwnerView( 'VIEW_VAL', 'BOX_FORM_VAL' )
       oView:EnableTitleView( 'VIEW_VAL', 'Valores do Pedido')
       
       oView:CreateHorizontalBox( 'BOX_FORM_COM', 42 )
       oView:CreateVerticalBox( 'BOX_ESQ', 30, "BOX_FORM_COM" )
       oView:CreateVerticalBox( 'BOX_CEN', 35, "BOX_FORM_COM" )
       oView:CreateVerticalBox( 'BOX_DIR', 35, "BOX_FORM_COM" )
       oView:AddOtherObject( 'APROVADORES', { | oPanel | fAprova(oPanel) }, { || }, { |oPanel| fAprova(oPanel) } )
       oView:SetOwnerView( 'APROVADORES', 'BOX_ESQ' )
       oView:EnableTitleView( 'APROVADORES', 'Aprovadores')
       oView:AddOtherObject( 'RESTRIOES', { | oPanel | fRestri( oPanel ) }, { || } )
       oView:SetOwnerView( 'RESTRIOES', 'BOX_CEN' )
       oView:EnableTitleView( 'RESTRIOES', 'Restrições')
       oView:AddOtherObject( 'OBSERVACOES', { | oPanel | fObserv( oPanel ) }, { || } )
       oView:SetOwnerView( 'OBSERVACOES', 'BOX_DIR' )
       oView:EnableTitleView( 'OBSERVACOES', 'Observações')

       oView:SetViewProperty( 'VIEW_PED', "CHANGELINE", { { | _oView, _cAction, _aParam | fChangePED( _oView, _cAction, _aParam ) } } )

       //oView:AddUserButton( "Pesquisar pedido - (F2)"   , 'PEDIDO', { |oView| FWMsgRun( , { || fPesPed(oView) }, "Aguarde...", "Pesquisando"           ) } )
       oView:AddUserButton( "Histórico do Pedido - (F2)", 'PEDIDO', { |oView| FWMsgRun( , { || fHisPed(oView) }, "Aguarde...", "Processando histórico" ) } )
       oView:AddUserButton( "Itens do Pedido - (F4)"    , 'PEDIDO', { |oView| FWMsgRun( , { || fItePed(oView) }, "Aguarde...", "Processando itens"     ) } )
       oView:AddUserButton( "Dados do Pedido - (F5)"    , 'PEDIDO', { |oView| FWMsgRun( , { || fDadPed(oView) }, "Aguarde...", "Gerando consulta"      ) } )
       oView:AddUserButton( "Planilha Financeira - (F6)", 'PEDIDO', { |oView| FWMsgRun( , { || fPlaFin(oView) }, "Aguarde...", "Montando planilha"     ) } )
       oView:AddUserButton( "Titulos em aberto - (F7)"  , 'PEDIDO', { |oView| FWMsgRun( , { || fTAbFin(oView) }, "Aguarde...", "Consutando titulos"    ) } )
       oView:AddUserButton( "Titulos recebidos - (F8)"  , 'PEDIDO', { |oView| FWMsgRun( , { || fTReFin(oView) }, "Aguarde...", "Consutando titulos"    ) } )
       oView:AddUserButton( "Dados do Cliente - (F9)"   , 'PEDIDO', { |oView| FWMsgRun( , { || fDadCli(oView) }, "Aguarde...", "Consutando cliente"    ) } )

       oView:SetCloseOnOk( { || .F. } ) 

       //SetKey( VK_F2, bPesquisar )
       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F9, bDadosClie )

Return oView

/*/{Protheus.doc} MontaCab
Monta arquivos temporários da rotina
@type function
@version  v2021.01
@author Luís Gustavo de Souza
@since 12/11/2021
@param _nOpc, Numeric, variável que indica qual estrutura será montada.
@return Object, Objeto com a estrutura do arquivo.
/*/
Static function MontaCab( _nOpc )
       Local oStruct  as Object
       Local _aCampos as Array

       If _nOpc == 1
          oStruct  := FWFormModelStruct():New()
          _aCampos := {}
          aAdd( _aCampos, { 'PEDIDO'   , 'C', TamSx3("C5_NUM")[1] , TamSx3("C5_NUM")[2]  } )
          fMontaTMP( _aCampos, 'CABPED', _oTable1 )
          oStruct:AddTable( 'CABPED', { 'PEDIDO'  }, 'Pedido de Vendas' )
          oStruct:AddField( 'Pedido', 'Pedido de Vendas', 'PEDIDO', 'C', TamSx3("C5_NUM")[1] , , , , , , , .T. )
       ElseIf _nOpc == 2
              oStruct := FWFormViewStruct():New()
              oStruct:AddField( 'PEDIDO'    , '1', 'Pedido'           , 'Pedido'           , , 'Get'  ,     , , , .F. )
       ElseIf _nOpc == 3
              oStruct  := FWFormModelStruct():New()
              _aCampos := {}
              aAdd( _aCampos, { 'PEDIDO'   , 'C', TamSx3("C5_NUM")[1]     , TamSx3("C5_NUM")[2]     } )
              aAdd( _aCampos, { 'EMISSAO'  , 'D', TamSx3("C5_EMISSAO")[1] , TamSx3("C5_EMISSAO")[2] } )
              aAdd( _aCampos, { 'DTALTER'  , 'D', TamSx3("C5_EMISSAO")[1] , TamSx3("C5_EMISSAO")[2] } )
              aAdd( _aCampos, { 'CLIENTE'  , 'C',                      52 ,                       0 } )
              aAdd( _aCampos, { 'CONDICAO' , 'C',                      40 ,                       0 } )
              aAdd( _aCampos, { 'BOLETO'   , 'C',                       1 ,                       0 } )
              aAdd( _aCampos, { 'VENDEDOR' , 'C',                      50 ,                       0 } )
              aAdd( _aCampos, { 'TRANSPOR' , 'C',                      50 ,                       0 } )
              aAdd( _aCampos, { 'DTULTCOM' , 'D', TamSx3("C5_EMISSAO")[1] , TamSx3("C5_EMISSAO")[2] } )
              aAdd( _aCampos, { 'DTPRICOM' , 'D', TamSx3("C5_EMISSAO")[1] , TamSx3("C5_EMISSAO")[2] } )
              aAdd( _aCampos, { 'RISCO'    , 'C',                       1 ,                       0 } )
              aAdd( _aCampos, { 'USRALT'   , 'C',                      25 ,                       0 } )
              aAdd( _aCampos, { 'TPVENDA'  , 'C',                       1 ,                       0 } )
              aAdd( _aCampos, { 'OBSPED'   , 'C',                       6 ,                       0 } )
              aAdd( _aCampos, { 'OBSSC5'   , 'C',                       6 ,                       0 } )
              aAdd( _aCampos, { 'LIBCAD'   , 'L',                       1 ,                       0 } )
              aAdd( _aCampos, { 'USRCAD'   , 'C',                      25 ,                       0 } )
              aAdd( _aCampos, { 'LIBPED'   , 'L',                       1 ,                       0 } )
              aAdd( _aCampos, { 'USRPED'   , 'C',                      25 ,                       0 } )
              aAdd( _aCampos, { 'LIBCRE'   , 'L',                       1 ,                       0 } )
              aAdd( _aCampos, { 'USRCRE'   , 'C',                      25 ,                       0 } )
              aAdd( _aCampos, { 'LIBDIR'   , 'L',                       1 ,                       0 } )
              aAdd( _aCampos, { 'USRDIR'   , 'C',                      25 ,                       0 } )
              aAdd( _aCampos, { 'APROVA'   , 'C',                       1 ,                       0 } )
              aAdd( _aCampos, { 'USRAPR'   , 'C',                      25 ,                       0 } )
              aAdd( _aCampos, { 'RESTRICAO', 'M',                      10 ,                       0 } )
              fMontaTMP( _aCampos, 'ITEPED', _oTable2 )
              oStruct:AddTable( 'CABPED', { 'PEDIDO'  }, 'Pedido de Vendas' )
              oStruct:AddField( 'Pedido'      , 'Pedido de Vendas'   , 'PEDIDO'   , 'C', TamSx3("C5_NUM")[1]    , , , , ,    , , .T. )
              oStruct:AddField( 'Emissão'     , 'Dt.Emissão'         , 'EMISSAO'  , 'D', TamSx3("C5_EMISSAO")[1], , , , ,    , , .T. )
              oStruct:AddField( 'Alteração'   , 'Dt.Alteração'       , 'DTALTER'  , 'D', TamSx3("C5_EMISSAO")[1], , , , ,    , , .T. )
              oStruct:AddField( 'Cliente'     , 'Cliente'            , 'CLIENTE'  , 'C',                      52, , , , ,    , , .T. )
              oStruct:AddField( 'Cond.Pgto.'  , 'Condição Pgto.'     , 'CONDICAO' , 'C',                      40, , , , ,    , , .T. )
              oStruct:AddField( 'Boleto?'     , 'Boleto?'            , 'BOLETO'   , 'C',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Vendedor'    , 'Vendedor'           , 'VENDEDOR' , 'C',                      50, , , , ,    , , .T. )
              oStruct:AddField( 'Transp.'     , 'Transportadora'     , 'TRANSPOR' , 'C',                      50, , , , ,    , , .T. )
              oStruct:AddField( 'Dt.Ult.Com.' , 'Dt. Ultima Comp.'   , 'DTULTCOM' , 'D', TamSx3("C5_EMISSAO")[1], , , , ,    , , .T. )
              oStruct:AddField( 'Dt.Pri.Com.' , 'Dt.Primeira Com.'   , 'DTPRICOM' , 'D', TamSx3("C5_EMISSAO")[1], , , , ,    , , .T. )
              oStruct:AddField( 'Risco'       , 'Risco do Cliente'   , 'RISCO'    , 'C',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Ultima Alt.' , 'Usuário Alteração'  , 'USRALT'   , 'C',                      25, , , , ,    , , .T. )
              oStruct:AddField( 'Tipo Venda'  , 'Tipo de Venda'      , 'TPVENDA'  , 'C',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Observação'  , 'Observação'         , 'OBSPED'   , 'C',                       6, , , , ,    , , .T. )
              oStruct:AddField( 'Obs'         , 'Obs.'               , 'OBSSC5'   , 'C',                       6, , , , ,    , , .T. )
              oStruct:AddField( 'Libera Cad.' , 'Liberação Cadastro' , 'LIBCAD'   , 'L',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Cad.', 'Usuário Cadastro'   , 'USRCAD'   , 'C',                      25, , , , ,    , , .T. )
              oStruct:AddField( 'Libera Ped.' , 'Liberação Pedido'   , 'LIBPED'   , 'L',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Ped.', 'Usuário Pedido'     , 'USRPED'   , 'C',                      25, , , , ,    , , .T. )
              oStruct:AddField( 'Libera Cre.' , 'Liberação Credito'  , 'LIBCRE'   , 'L',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Cre.', 'Usuário Credito'    , 'USRCRE'   , 'C',                      25, , , , ,    , , .T. )
              oStruct:AddField( 'Libera Dir.' , 'Liberação Diretoria', 'LIBDIR'   , 'L',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Dir.', 'Usuário Diretoria'  , 'USRDIR'   , 'C',                      25, , , , ,    , , .T. )
              oStruct:AddField( 'Aprovado'    , 'Aprovado'           , 'APROVA'   , 'C',                       1, , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Apr.', 'Usuário Aprovador'  , 'USRAPR'   , 'C',                      25, , , , ,    , , .T. )
              oStruct:AddField( 'Restricao'   , 'Restricao'          , 'RESTRICAO', 'M',                      10, , , , ,    , , .T. )
       ElseIf _nOpc == 4
              oStruct := FWFormViewStruct():New()
              oStruct:AddField( 'PEDIDO'  , '02', 'Pedido'        , 'Pedido'         ,                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'EMISSAO' , '03', 'Emissão'       , 'Dt.Emissão'     ,                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'DTALTER' , '04', 'Alteração'     , 'Dt.Alteração'   ,                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'CLIENTE' , '05', 'Cliente'       , 'Cliente'        ,                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'CONDICAO', '06', 'Cond.Pgto.'    , 'Condição Pgto.' ,                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'BOLETO'  , '07', 'Boleto?'       , 'Boleto'         ,                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'VENDEDOR', '08', 'Vendedor'      , 'Vendedor'       ,                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'DTULTCOM', '10', 'Dt.Ult.Comp.'  , 'Dt.Ultima Comp.',                , 'Get',    ,   ,    , .F. )
              oStruct:AddField( 'TRANSPOR', '09', 'Transportadora', 'Transportadora' ,                , 'Get',    ,   ,    , .F. )
       ElseIf _nOpc == 5
              oStruct  := FWFormModelStruct():New()
              _aCampos := {}
              aAdd( _aCampos, { 'VALMERC', 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'VALIPI' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'VALSUB' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'VALTOT' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'VALMAR' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'PERMAR' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'VALLUC' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'PERLUC' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'VALCOM' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              aAdd( _aCampos, { 'PERCOM' , 'N', TamSx3("C6_VALOR")[1] , TamSx3("C6_VALOR")[2] } )
              fMontaTMP( _aCampos, 'TOTPED', _oTable3 )
              oStruct:AddField( 'Mercadoria', 'Valor Mercadoria' , 'VALMERC', 'N' , 18, 2 )
              oStruct:AddField( 'IPI'       , 'IPI'              , 'VALIPI' , 'N' , 18, 2 )
              oStruct:AddField( 'Sub.ST.'   , 'Subst. Tributaria', 'VALSUB' , 'N' , 18, 2 )
              oStruct:AddField( 'Total'     , 'Valor Total'      , 'VALTOT' , 'N' , 18, 2 )
              oStruct:AddField( 'Lucro'     , 'Valor Lucro'      , 'VALLUC' , 'N' , 18, 2 )
              oStruct:AddField( '% Lucro'   , '% Lucro'          , 'PERLUC' , 'N' , 10, 2 )
              oStruct:AddField( 'Comissão'  , 'Valor Comissão'   , 'VALCOM' , 'N' , 18, 2 )
              oStruct:AddField( '% Comissão', '% Comissão'       , 'PERCOM' , 'N' , 10, 2 )
              oStruct:AddField( 'Margem R$' , 'Margem Bruta (R$)', 'VALMAR' , 'N' , 18, 2 )
              oStruct:AddField( 'Margem %'  , 'Margem Bruta (%)' , 'PERMAR' , 'N' , 18, 2 )
       ElseIf _nOpc == 6
              oStruct := FWFormViewStruct():New()
              oStruct:AddField( 'VALMERC', '01', 'Mercadoria', 'Mercadoria'       , , 'Get', '@E 999,999,999.99',   ,    , .F. )
              oStruct:AddField( 'VALIPI' , '02', 'IPI'       , 'IPI'              , , 'Get', '@E 999,999.99'    ,   ,    , .F. )
              oStruct:AddField( 'VALSUB' , '03', 'Sub.ST.'   , 'Subst. Tributaria', , 'Get', '@E 999,999.99'    ,   ,    , .F. )
              oStruct:AddField( 'VALTOT' , '04', 'Total'     , 'Valor Total'      , , 'Get', '@E 999,999,999.99',   ,    , .F. )
              oStruct:AddField( 'VALLUC' , '05', 'Lucro'     , 'Valor Lucro'      , , 'Get', '@E 999,999.99'    ,   ,    , .F. )
              oStruct:AddField( 'PERLUC' , '06', '% Lucro'   , '% Lucro'          , , 'Get', '@E 9,999.99'      ,   ,    , .F. )
              oStruct:AddField( 'VALCOM' , '07', 'Comissão'  , 'Valor Comissão'   , , 'Get', '@E 999,999.99'    ,   ,    , .F. )
              oStruct:AddField( 'PERCOM' , '08', '% Comissão', '% Comissão'       , , 'Get', '@E 9,999.99'      ,   ,    , .F. )
              oStruct:AddField( 'VALMAR' , '09', 'Margem R$' , 'Margem Bruta'     , , 'Get', '@E 999,999.99'    ,   ,    , .F. )
              oStruct:AddField( 'PERMAR' , '10', 'Margem %'  , 'Margem %'         , , 'Get', '@E 9,999.99'      ,   ,    , .F. )
       Endif
Return oStruct

/*/{Protheus.doc} fMontaTMP
Cria arquivo temporario através de uma estrutura
@type function
@version  v2021.01
@author Luís Gustavo Souza
@since 12/11/2021
@param _aCampos, Array, Matriz contendo campos da estrutura
@param _cAlias, Character, Nome do alias da estrutura
@param _objTbl, Object, Objeto da tabela criada
/*/
Static Function fMontaTMP( _aCampos, _cAlias, _objTbl )
       If Select( _cAlias ) > 0
          DbSelectArea( _cAlias )
          DbCloseArea()
       Endif
       _oObjTbl := FWTemporaryTable():New( _cAlias )
       _oObjTbl:SetFields( _aCampos )
       _oObjTbl:Create()
Return

/*/{Protheus.doc} FLCab
Função para carga do cabeçalho
@type function
@version  v2021.01
@author Luís Gustavo de Souza
@since 12/11/2021
@param oModel, object, Modelo retornado do objeto para carga do cabeçalho
@return Array, Conteudo do(s) campo(s) do cabeçalho
/*/
Static Function FLCab( oModel )
       Local aRet		:= {}
       Local aAux		:= {}

       aAdd( aAux, '999999' )

       aRet := { aAux, 0 }
Return aRet

Static Function fPosValid( oModel )
       Local _lRet := .t.
Return _lRet

Static Function FGrava( oModel )
       Local _aArea     := GetArea()
       Local _lRet      := .t.

       RestArea( _aArea )
Return _lRet

/*/{Protheus.doc} fLItem
Função para carga do browse com dados dos pedidos
@type function
@version  v2021.01
@author Luís Gustavo de Souza
@since 12/11/2021
@param oModelItem, object, Objeto com dados dos itens
@param _lCopy, Logical, variável que indica se pode copiar
@return Array, Conteudo do(s) campo(s) da grid de pedidos
/*/
Static Function fLItem( oModelItem, _lCopy )
       Local _aItPed  := {}
       Local _aArea   := GetArea()
       Local _aAux    := {}
       Local _cQry    := ""
       Local _cTabSC5 := "TMPPED"
       Local _cWhere  := ""
       Local _cOrdem  := "%SC5.C5_NUM%"
       Local _cLibRep := GETMV("MV_LIBSINT" ) //Usuario que libera sintegra de pedidos de representantes na analise de pedidos.

       _cWhere += "%"
       _cWhere += "    SC5.D_E_L_E_T_ = '' " + CHR(13) + CHR(10)
       _cWhere += "AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' " + CHR(13) + CHR(10)
       _cWhere += "AND SC5.C5_EMISSAO >= '20040906' " + CHR(13) + CHR(10)
       _cWhere += "AND SC5.C5_TIPO     = 'N' " + CHR(13) + CHR(10)
       _cWhere += "AND SC5.C5_NOTA     = ''  " + CHR(13) + CHR(10)
       _cWhere += "AND SC5.C5_APROVA   = '0' " + CHR(13) + CHR(10)
       If lAcsCad .or. lAcsCre
       _cWhere += "AND ( " + CHR(13) + CHR(10)
       Endif
       If lAcsCad
          _cWhere += "      ( ( ( UPPER( SC5.C5_CAD ) = '" + UPPER( cUsername ) + "' ) " + CHR(13) + CHR(10)
          If Alltrim( UPPER( cUsername ) ) $ Alltrim( UPPER( _cLibRep ) )
             _cWhere += " OR ( SUBSTRING( SC5.C5_CAD, 1, 1 ) IN('0','1','2','3','4','5','6','7','8','9') ) " + CHR(13) + CHR(10)
          Endif 
          _cWhere += " ) "
          _cWhere += "  AND (SC5.C5_LIBCAD = 'F') ) " + CHR(13) + CHR(10)
       Endif
       _cWhere += " ) "
       _cWhere += "%"

       BEGINSQL Alias _cTabSC5
                COLUMN C5_EMISSAO AS DATE
                COLUMN C5_DTALT   AS DATE
                COLUMN A1_ULTCOM  AS DATE
                COLUMN A1_PRICOM  AS DATE
                SELECT SC5.C5_NUM    , SC5.C5_EMISSAO, SC5.C5_DTALT , SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_CONDPAG, SC5.C5_BOLETO, SC5.C5_VEND1 , SC5.C5_TRANSP, SC5.C5_ALT   ,
                       SC5.C5_TIPOVEN, SC5.C5_OBSPED , SC5.C5_OBSSC5, SC5.C5_LIBCAD , SC5.C5_USRCAD , SC5.C5_LIBPED , SC5.C5_USRPED, SC5.C5_LIBCRE, SC5.C5_USRCRE, SC5.C5_LIBDIR, 
                       SC5.C5_USRDIR , SC5.C5_APROVA , SC5.C5_USRAPR, 
                       SA1.A1_NOME, SA1.A1_EST, SA1.A1_ULTCOM, SA1.A1_PRICOM, SA1.A1_RISCO,
                       SE4.E4_DESCRI, 
                       SA3.A3_NOME, 
                       SA4.A4_NOME 
                FROM %table:SC5% SC5
                LEFT OUTER JOIN %table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = SC5.C5_CLIENTE    AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.%notdel%
                LEFT OUTER JOIN %table:SE4% SE4 ON SE4.E4_FILIAL = %xFilial:SE4% AND SE4.E4_CODIGO = SC5.C5_CONDPAG AND SE4.%notdel%
                LEFT OUTER JOIN %table:SA3% SA3 ON SA3.A3_FILIAL = %xFilial:SA3% AND SA3.A3_COD = SC5.C5_VEND1      AND SA3.%notdel%
                LEFT OUTER JOIN %table:SA4% SA4 ON SA4.A4_FILIAL = %xFilial:SA4% AND SA4.A4_COD = SC5.C5_TRANSP     AND SA4.%notdel%
                WHERE %Exp:_cWhere%
                ORDER BY %Exp:_cOrdem%
       ENDSQL
       DbSelectArea( _cTabSC5 )
       While ( _cTabSC5 )->( !Eof() )
             _aAux := {}

             aAdd( _aAux  , ( _cTabSC5 )->C5_NUM )
             aAdd( _aAux  , ( _cTabSC5 )->C5_EMISSAO )
             aAdd( _aAux  , ( _cTabSC5 )->C5_DTALT   )
             aAdd( _aAux  , ( _cTabSC5 )->C5_CLIENTE + '/' + ( _cTabSC5 )->C5_LOJACLI + ' - ' + ( _cTabSC5 )->A1_NOME )
             aAdd( _aAux  , ( _cTabSC5 )->C5_CONDPAG + ' - ' + ( _cTabSC5 )->E4_DESCRI )
             aAdd( _aAux  , Iif( ( _cTabSC5 )->C5_BOLETO == 'S', 'Sim', 'Não' ) )
             aAdd( _aAux  , ( _cTabSC5 )->C5_VEND1  + ' - ' + ( _cTabSC5 )->A3_NOME )
             aAdd( _aAux  , ( _cTabSC5 )->C5_TRANSP + ' - ' + ( _cTabSC5 )->A4_NOME )
             aAdd( _aAux  , ( _cTabSC5 )->A1_ULTCOM )
             aAdd( _aAux  , ( _cTabSC5 )->A1_PRICOM )
             aAdd( _aAux  , ( _cTabSC5 )->A1_RISCO          )
             aAdd( _aAux  , ( _cTabSC5 )->C5_ALT            )
             aAdd( _aAux  , ( _cTabSC5 )->C5_TIPOVEN        )
             aAdd( _aAux  , ( _cTabSC5 )->C5_OBSPED         )
             aAdd( _aAux  , ( _cTabSC5 )->C5_OBSSC5         )
             aAdd( _aAux  , Iif( ( _cTabSC5 )->C5_LIBCAD == 'T', .T., .F. ) )
             aAdd( _aAux  , ( _cTabSC5 )->C5_USRCAD         )
             aAdd( _aAux  , Iif( ( _cTabSC5 )->C5_LIBPED == 'T', .T., .F. ) )
             aAdd( _aAux  , ( _cTabSC5 )->C5_USRPED         )
             aAdd( _aAux  , Iif( ( _cTabSC5 )->C5_LIBCRE == 'T', .T., .F. ) )
             aAdd( _aAux  , ( _cTabSC5 )->C5_USRCRE         )
             aAdd( _aAux  , Iif( ( _cTabSC5 )->C5_LIBDIR == 'T', .T., .F. ) )
             aAdd( _aAux  , ( _cTabSC5 )->C5_USRDIR         )
             aAdd( _aAux  , Iif( ( _cTabSC5 )->C5_APROVA <> '2', .F., .T. ) )
             aAdd( _aAux  , ( _cTabSC5 )->C5_USRAPR         )
             aAdd( _aAux  , ''                              )
             aAdd( _aItPed, { 0 , _aAux } )
             aAdd( _aPedidos, { ( _cTabSC5 )->C5_NUM, _aAux, } )
             If Len( _aItPed ) == 1
                //fCalImp( ( _cTabSC5 )->C5_NUM )
                _cPedido := ( _cTabSC5 )->C5_NUM
             Endif
             
             DbSelectArea( _cTabSC5 )
             ( _cTabSC5 )->( DbSkip( ) )
       EndDo
       DbSelectArea( _cTabSC5 )
       ( _cTabSC5 )->( DbCloseArea( ) )
       
       FWMsgRun( , { || fCalImp( _cPedido ) }, "Aguarde...", "Carregando informações..." )
       
       RestArea( _aArea )
Return _aItPed

Static Function fLValor( _oModel, _lCopy )
       Local aItPed    := {}
       Local aArea     := GetArea()
       Local aAux      := {}
       Local _nY
       Local _nValMerc := 0
       Local _nValIpi  := 0
       Local _nValSub  := 0

       Local _cPedido  := Iif( Len( _aItens ) > 0, _aItens[1][1], "" )
       
       If ! Empty( _cPedido )
          For _nY := 1 To Len( _aItens )
              If _aItens[_nY][1] == _cPedido
                 _nValMerc += _aItens[_nY][15]
                 _nValIpi  += _aItens[_nY][27]
                 _nValSub  += _aItens[_nY][32]
              Endif
          Next
          DbSelectArea('SC5')
          SC5->( DbSetOrder( 1 ) )
          SC5->( DbSeek( xFilial("SC5") + _cPedido ) )

          aAdd( aAux  , _nValMerc )      //Valor Mercadoria
          aAdd( aAux  , _nValIpi  )      //Valor IPI
          aAdd( aAux  , _nValSub  )      //Valor Subst. Tributária
          aAdd( aAux  , _nValMerc + _nValIpi + _nValSub ) //Valor Total
          aAdd( aAux  , 0              ) //Perc. Lucro
          aAdd( aAux  , SC5->C5_LUCRO  ) //Valor Lucro
          aAdd( aAux  , SC5->C5_PORCOM ) //Perc. Comissão
          aAdd( aAux  , SC5->C5_VLRCOM ) //Valor Comissão
          aAdd( aAux  , 0 )
          aAdd( aAux  , 0 )
          aAdd( aAux  , 0 )
          aAdd( aItPed, { 0 , aAux } )
       Endif

       RestArea( aArea )
Return aItPed

Static Function fChangePED( _oViewPED, _cAction, _aParam )
       Local _lRet      := .t.
       Local _nY
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oView     := FwViewActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _oModelVal := _oModel:GetModel( 'GRIDVALOR' )

       Local _nPosPri   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'DTPRICOM' } )
       Local _nPosUlt   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'DTULTCOM' } )
       Local _nPosRis   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'RISCO'    } )
       Local _nPosAlt   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRALT'   } )
       Local _nPosTip   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'TPVENDA'  } )
       Local _nPosOPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'OBSPED'   } )
       Local _nPosOC5   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'OBSSC5'   } )
       Local _nPosLCa   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBCAD'   } )
       Local _nPosUCa   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRCAD'   } )
       Local _nPosLPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBPED'   } )
       Local _nPosUPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRPED'   } )
       Local _nPosLCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBCRE'   } )
       Local _nPosUCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRCRE'   } )
       Local _nPosLDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBDIR'   } )
       Local _nPosUDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRDIR'   } )
       Local _nPosLAp   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'APROVA'   } )
       Local _nPosUAp   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRAPR'   } )
       Local _nPosRes   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'RESTRICAO' } )

       _cAltera := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosAlt ]
       _cVenda  := Iif( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosTip ] == 'I', 'Interna', 'Externa' )
       _cPriCom := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosPri ]
       _cUltCom := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosUlt ]
       _cRisco  := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosRis ]
       _cObsMsg := MSMM( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosOPe ], , , , 3 )
       _cObserv := Alltrim( U_TiraAcento( MSMM( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosOC5 ] ) ) )
       _lLibCad := _oModelPed:aCols[_oModelPed:nLine][_nPosLCa]
       _cUsrCad := _oModelPed:aCols[_oModelPed:nLine][_nPosUCa]
       _lLibPed := _oModelPed:aCols[_oModelPed:nLine][_nPosLPe]
       _cUsrPed := _oModelPed:aCols[_oModelPed:nLine][_nPosUPe]
       _lLibCre := _oModelPed:aCols[_oModelPed:nLine][_nPosLCr]
       _cUsrCre := _oModelPed:aCols[_oModelPed:nLine][_nPosUCr]
       _lLibDir := _oModelPed:aCols[_oModelPed:nLine][_nPosLDi]
       _cUsrDir := _oModelPed:aCols[_oModelPed:nLine][_nPosUDi]
       _lLibRec := _oModelPed:aCols[_oModelPed:nLine][_nPosLAp]
       _cUsrRec := _oModelPed:aCols[_oModelPed:nLine][_nPosUAp]
       If Empty( _oModelPed:aCols[_oModelPed:nLine][_nPosRes] )
          fDadRes( )
       Endif
       _cRestri := _oModelPed:aCols[_oModelPed:nLine][_nPosRes]
       _cPedido := _oModelPed:aCols[_oModelPed:nLine][1]
       If _aPedidos[aScan( _aPedidos, { |x| x[1] == _cPedido } )][3] == Nil
          FWMsgRun( , { || fCalImp( _cPedido ) }, "Aguarde...", "Carregando informações..." )
       Endif
       _oAltera:Refresh()
       _oVenda:Refresh()
       _oPriCom:Refresh()
       _oUltCom:Refresh()
       _oRisco:Refresh()
       _oObsMsg:Refresh()
       _oObserv:Refresh()
       _oLibCad:Refresh()
       _oUsrCad:Refresh()
       _oLibPed:Refresh()
       _oUsrPed:Refresh()
       _oLibCre:Refresh()
       _oUsrCre:Refresh()
       _oLibDir:Refresh()
       _oUsrDir:Refresh()
       _oLibRec:Refresh()
       _oUsrRec:Refresh()
       _oRestri:Refresh()

       DbSelectArea( "SB1" )
       DbSetOrder( 1 )

       DbSelectArea('SC5')
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial('SC5') + _oModelPed:aCols[_oModelPed:nLine][1] ) )
 
       _nValMerc := 0
       _nValIpi  := 0
       _nValSub  := 0
       For _nY := 1 To Len( _aItens )
           If _aItens[_nY][1] == _oModelPed:aCols[_oModelPed:nLine][1]
              _nValMerc += _aItens[_nY][15]
              _nValIpi  += _aItens[_nY][27]
              //_nValSub  += _aItens[_nY][15]
           Endif
       Next
       _oModelVal:aCols[1][1] := _nValMerc
       _oModelVal:aCols[1][2] := _nValIpi
       _oModelVal:aCols[1][4] := _nValMerc + _nValIpi + _nValSub
       _oModelVal:aCols[1][6] := SC5->C5_LUCRO
       _oModelVal:aCols[1][8] := SC5->C5_VLRCOM
       _oModelVal:aCols[1][7] := SC5->C5_PORCOM

       RestArea( aArea )
       _oView:Refresh( 'GRIDVALOR' )
Return _lRet

/*/{Protheus.doc} fHisPed
Consulta histórico de movimentação do pedido de vendas
@type function
@version v2021.01
@author Luís Gustavo de Souza
@since 13/10/2021
@param oView, object, View principal da tela.
/*/
Static Function fHisPed(oView)
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )

       SetKey( VK_F2, {||} )
       SetKey( VK_F4, {||} )
       SetKey( VK_F5, {||} )
       SetKey( VK_F6, {||} )
       SetKey( VK_F7, {||} )
       SetKey( VK_F8, {||} )
       SetKey( VK_F9, {||} )

       U_fHisPed( 3, _oModelPed:aCols[_oModelPed:nLine][1] )

       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F9, bDadosClie )

       RestArea( aArea )
Return

/*/{Protheus.doc} fItePed
Consulta itens do pedido de vendas
@type function
@version v2021.01
@author Luís Gustavo de Souza
@since 13/10/2021
@param oView, object, View principal da tela.
/*/
Static Function fItePed(oView)
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _aButtons  := {}
       Local _cPedido   := _oModelPed:aCols[_oModelPed:nLine][1]
       Local _cPerg     := 'MTA410'
       Local _nY, _nX
       Local _nPosHead
       /***********************************************************************/
       /** Bloco de variáveis para montagem das variáveis para o FillGetDados */
       Local _cArqQry   := "SC6"
       Local _nTotPed   := 0
       Local _nTotDes   := 0
       Local _lGrade    := MaGrade()
       Local _cSeek     := ""
       Local _bWhile
       Local _bCond     := { || .T. }
       Local _bAction1  := { || Mta410Vis( _cArqQry, @_nTotPed, @_nTotDes, _lGrade ) }
       Local _bAction2  := { || .T. } 
       Local _cQuery    := ""
       Local _aHeaderAux:= {}
       Local _aColsAux  := {}
       Local _nQtdAnt   := 0 
       //Local aFisGet
       //Local aFisGetSC5
       //Local _aRelImp   := MaFisRelImp( "MT100", { "SF2", "SD2" } )
       Local _aNoFields := { "C6_UM"     , "C6_SEGUM"  , "C6_OPER"   , "C6_CATALIS", "C6_ENTRIME", "C6_QTDENT2",;
                             "C6_QTDENT" , "C6_CLASFIS", "C6_QTDLIB" , "C6_QTDLIB2", "C6_LA"     , "C6_SLDALIB",;
                             "C6_UNSVEN ", "C6_DATFAT" , "C6_CLI"    , "C6_LOJA"   , "C6_NOTA"   , "C6_SERIE"  ,;
                             "C6_NUM"    , "C6_COMIS2" , "C6_COMIS3" , "C6_COMIS4" , "C6_COMIS5" , "C6_PEDCLI" ,;
                             "C6_PRUNIT" , "C6_NFORI"  , "C6_BLOQUEI", "C6_RESERVA", "C6_IPIDEV" , "C6_IDENTB6",;
                             "C6_BLQ"    , "C6_OP"     , "C6_OK"     , "C6_GRADE"  , "C6_ITEMGRD", "C6_LOTECTL",;
                             "C6_NUMLOTE", "C6_SERIORI", "C6_NUMORC" , "C6_ITEMORI", "C6_OPC"    , "C6_LOCALIZ",;
                             "C6_CODISS" , "C6_DTVALID", "C6_NUMSERI", "C6_NUMOP  ", "C6_ITEMOP ", "C6_CLASFIS",;
                             "C6_CONTRAT", "C6_NUMOS"  , "C6_NUMOSFA", "C6_CODFAB" , "C6_LOJAFA" , "C6_ITEMCON",;
                             "C6_TPOP"   , "C6_REVISAO", "C6_SERVIC" , "C6_ENDPAD" , "C6_TPESTR" , "C6_CONTRT" ,;
                             "C6_TPCONTR", "C6_ITCONTR", "C6_GEROUPV", "C6_QTDEMP" , "C6_QTDEMP2", "C6_PROJPMS",;
                             "C6_EDTPMS" , "C6_TASKPMS", "C6_TRT"    , "C6_PROJET" , "C6_MOPC"   , "C6_ITPROJ" ,;
                             "C6_NUMSC"  , "C6_ITEMSC" , "C6_POTENCI", "C6_LICITA" , "C6_REGWMS" , "C6_NUMCP"  ,;
                             "C6_SUGENTR", "C6_FUNRURA", "C6_FETAB"  , "C6_CODROM" , "C6_ITEMED" , "C6_TURNO"  ,;
                             "C6_LOJDED" , "C6_ABSCINS", "C6_FORDED" , "C6_ITPC"   , "C6_PVCOMOP", "C6_ABATISS",;
                             "C6_FILPED" , "C6_PEDCOM" , "C6_ABATMAT", "C6_TPDEDUZ", "C6_MOTDED" , "C6_VLDED"  ,;
                             "C6_VLNFD"  , "C6_RATEIO" , "C6_SERDED" , "C6_PCDED"  , "C6_NFDED"  , "C6_ITLPRE" ,;
                             "C6_D1SERIE", "C6_D1DOC"  , "C6_CODLPRE", "C6_D1ITEM" , "C6_PROGRAM", "C6_CODLAN ",;
                             "C6_VDMOST ", "C6_VDOBS  ", "C6_ABATINS", "C6_IEST   ", "C6_USERLGI", "C6_USERLGA",;
                             "C6_PALLET ", "C6_BASVEIC", "C6_TNATREC", "C6_CNATREC", "C6_GRPNATR", "C6_DTFIMNT",;
                             "C6_VLIMPOR", "C6_FCICOD ", "C6_INFAD  ", "C6_CODINF ", "C6_CC     ", "C6_CONTA  ",; 
                             "C6_ITEMCTA", "C6_CLVL   ", "C6_DATCPL ", "C6_HORCPL ", "C6_INTROT ", "C6_CATEG  ",; 
                             "C6_CTVAR  ", "C6_PENE   ", "C6_GCPLT  ", "C6_GCPIT  ", "C6_ALMTERC", "C6_ITEMGAR",;
                             "C6_ORCGAR ", "C6_HORENT ", "C6_CCUSTO ", "C6_SOLCOM ", "C6_PMSID  ", "C6_CULTRA ",;
                             "C6_REVPROD", "C6_PRODFIN", "C6_PEDVINC", "C6_TPPROD ", "C6_SDOCORI", "C6_SDOC   ",;
                             "C6_SDOCDED", "C6_SDOCSD1", "C6_CSTPIS ", "C6_NRSEQCQ", "C6_IPITRF ", "C6_TPREPAS",; 
                             "C6_X_EXPO ", "C6_X_SIM3G", "C6_DATAEMB", "C6_XREGD1D", "C6_XESPECI" }
       /***********************************************************************/
       //Private aTransp  := {"",""}

       //FisGetInit(@aFisGet,@aFisGetSC5)
       SetKey( VK_F2, {||} )
       SetKey( VK_F4, {||} )
       SetKey( VK_F5, {||} )
       SetKey( VK_F6, {||} )
       SetKey( VK_F7, {||} )
       SetKey( VK_F8, {||} )
       SetKey( VK_F9, {||} )

       DbSelectArea('SA4')
       SA4->( DbSetOrder( 1 ) )
       SA4->( DbSeek( xFilial('SA4') + SubStr( _oModelPed:aCols[_oModelPed:nLine][8], 1, 6 ) ) )

       DbSelectArea('SC5')
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial('SC5') + _oModelPed:aCols[_oModelPed:nLine][1] ) )

       DbSelectArea('SA1')
       SA1->( DbSetOrder( 1 ) )
       SA1->( DbSeek( xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )

       RegToMemory( 'SC5', .f. )
       Pergunte( _cPerg, .f. )

       aCols    := {}
       aHeader  := {}
       _cSeek   := FwxFilial( "SC6" ) + _oModelPed:aCols[_oModelPed:nLine][1]
       _bWhile  := { || C6_FILIAL + C6_NUM }
       _cQuery  := "SELECT * "
       _cQuery  += "FROM " + RetSQLName("SC6") + " SC6 "
       _cQuery  += "WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
       _cQuery  += "  AND SC6.D_E_L_E_T_ = '' "
       _cQuery  += "  AND SC6.C6_NUM = 'ZZZZZZ' "
       _cQuery  += "ORDER BY " + SQLOrder( SC6->( IndexKey() ) )
   
       FillGetDados( 2, 'SC6', 1, _cSeek, _bWhile, { { _bCond, _bAction1, _bAction2, } }, /*_aNoFields*/, /*_aYesFields*/, /*_lOnlyYes*/, _cQuery, /*_bMontCols*/, .F., /*_aHeaderAux*/, /*_aColsAux*/, , , , "SC6" )
       _nQtdAnt := Len( aHeader )
       aAdd( aHeader, { 'Margem(R$)', 'C6_X_VMAR', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Margem(%)' , 'C6_X_PMAR', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Bas.ICMS'  , 'C6_X_BICM', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Alq.ICMS'  , 'C6_X_AICM', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Val.ICMS'  , 'C6_X_VICM', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Bas.IPI'   , 'C6_X_BIPI', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Alq.IPI'   , 'C6_X_AIPI', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Val.IPI'   , 'C6_X_VIPI', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Bas.PIS'   , 'C6_X_BPIS', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Alq.PIS'   , 'C6_X_APIS', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Val.PIS'   , 'C6_X_VPIS', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Bas.COF.'  , 'C6_X_BCOF', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Alq.COF.'  , 'C6_X_ACOF', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Val.COF.'  , 'C6_X_VCOF', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( aHeader, { 'Val.SUB'   , 'C6_X_VIRE', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       //Ajuste para mostrar somente campos necessários e ordena-los
       _aAuxH := {}
       For _nY := 1 To Len( aHeader )
           If Alltrim( aHeader[_nY][2] ) $ 'C6_ITEM.C6_PRODUTO.C6_DESCRI.C6_QTDVEN.C6_PRCVEN.C6_XPRUNIT.C6_ULPRECO.C6_VALOR.C6_COMIS1.C6_ENTREGA.C6_LUCRESP.C6_VLRLUCR.C6_X_VICM.C6_X_VIPI.C6_X_VPIS.C6_X_VCOF.C6_X_VMAR.C6_X_PMAR.C6_VIRE'
              //C6_PICMRET.C6_ICMRET.C6_ICMSRET.C6_DESCONT.C6_VALDESC.C6_FCICOD
              If Alltrim( aHeader[_ny][2] ) $ 'C6_ITEM'
                 aAdd( _aAuxH, { '01', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_PRODUTO'
                     aAdd( _aAuxH, { '02', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_DESCRI'
                     aAdd( _aAuxH, { '03', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_QTDVEN'
                     aAdd( _aAuxH, { '04', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_PRCVEN'
                     aAdd( _aAuxH, { '05', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_VALOR'
                     aAdd( _aAuxH, { '06', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_XPRUNIT'
                     aAdd( _aAuxH, { '07', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_ULPRECO'
                     aAdd( _aAuxH, { '08', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_COMIS1'
                     aAdd( _aAuxH, { '11', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_X_VMAR'
                     aAdd( _aAuxH, { '12', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_X_PMAR'
                     aAdd( _aAuxH, { '13', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_X_VICM'
                     aAdd( _aAuxH, { '16', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_X_VIPI'
                     aAdd( _aAuxH, { '19', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_X_VPIS'
                     aAdd( _aAuxH, { '22', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_X_VCOF'
                     aAdd( _aAuxH, { '25', aHeader[_nY] } )
              ElseIf Alltrim( aHeader[_ny][2] ) $ 'C6_X_VIRE'
                     aAdd( _aAuxH, { '28', aHeader[_nY] } )
              Else
                 aAdd( _aAuxH, { '99', aHeader[_nY] } )
              Endif
           Endif
       Next
       aSort( _aAuxH, , , { |x,y| x[1] < y[1] } )
       For _nY := 1 To Len( _aAuxH )
           aAdd( _aHeaderAux, _aAuxH[_nY][2] )
       Next
 
       _nColImp  := aScan( _aPedidos, { |x| x[1] == _cPedido } )
       _aColImp  := _aPedidos[_nColImp][3]

       _nPosProd := aScan( _aHeaderAux, { |x| Alltrim( x[2] ) == "C6_PRODUTO" } )
       _nPosItem := aScan( _aHeaderAux, { |x| Alltrim( x[2] ) == "C6_ITEM"    } )
       _nPosUPrc := aScan( _aHeaderAux, { |x| Alltrim( x[2] ) == "C6_ULPRECO" } )
       _nPosTPrc := aScan( _aHeaderAux, { |x| Alltrim( x[2] ) == "C6_XPRUNIT" } )
       _nPosValo := aScan( _aHeaderAux, { |x| Alltrim( x[2] ) == "C6_VALOR"   } )

       DbSelectArea("SB1")
       SB1->( DbSetOrder( 1 ) )
       DbSelectArea("SB5")
       SB5->( DbSetOrder( 1 ) )

       For _nY := 1 To Len( aCols )
           aAdd( _aColsAux,  Array( Len( _aHeaderAux ) + 1 ) )
           For _nX := 1 To Len( _aHeaderAux )
               _nPosHead := aScan( aHeader, { |x| Alltrim( x[2] ) == Alltrim( _aHeaderAux[_nX][2] ) } )
               If _nPosHead < _nQtdAnt
                  _aColsAux[_nY][_nX] := aCols[_nY][_nPosHead]
               Else
                  _nPosIte := aScan( _aColImp, { |x| x[34] == _cPedido + _aColsAux[_nY][_nPosItem] } )
                  If Alltrim( aHeader[_nPosHead][2] ) == 'C6_X_VMAR'
                         _aColsAux[_nY][_nX] := _aColsAux[_nY][_nPosValo] -_aColImp[_nPosIte][22] - _aColImp[_nPosIte][28] - _aColImp[_nPosIte][31]
                  ElseIf Alltrim( aHeader[_nPosHead][2] ) == 'C6_X_PMAR'
                         _aColsAux[_nY][_nX] := 0
                  ElseIf Alltrim( aHeader[_nPosHead][2] ) == 'C6_X_VICM'
                         _aColsAux[_nY][_nX] := _aColImp[_nPosIte][22]
                  ElseIf Alltrim( aHeader[_nPosHead][2] ) == 'C6_X_VIPI'
                         _aColsAux[_nY][_nX] := _aColImp[_nPosIte][25]
                  ElseIf Alltrim( aHeader[_nPosHead][2] ) == 'C6_X_VPIS'
                         _aColsAux[_nY][_nX] := _aColImp[_nPosIte][28]
                  ElseIf Alltrim( aHeader[_nPosHead][2] ) == 'C6_X_VCOF'
                         _aColsAux[_nY][_nX] := _aColImp[_nPosIte][31]
                  ElseIf Alltrim( aHeader[_nPosHead][2] ) == 'C6_X_VIRE'
                         _aColsAux[_nY][_nX] := _aColImp[_nPosIte][31]
                  Endif
               Endif
           Next
           SB1->( DbSeek( xFilial( "SB1" ) + _aColsAux[_nY][ _nPosProd] ) )
           SB5->( DbSeek( xFilial( "SB5" ) + _aColsAux[_nY][ _nPosProd] ) )

           _aColsAux[_nY][_nPosUPrc]                := U_VERULPRECO( M->C5_CLIENTE, _aColsAux[_nY][ _nPosProd], M->C5_LOJACLI )
           _aColsAux[_nY][_nPosTPrc]                := IIF( SB1->B1_ESTOQUE <> "S", SB5->B5_PRV2, SB1->B1_PRV1 )
           _aColsAux[_nY][ Len( _aHeaderAux ) + 1 ] := .F.
       Next

       oModal := FWDialogModal():New()
       oModal:SetEscClose( .F. )
       oModal:setTitle( "Itens do pedido de Vendas" )
       oModal:setSize( 260, 600 )
       oModal:createDialog()

       aAdd( _aButtons, { "", 'Cancela' , {|| _nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )
       oModal:addButtons( _aButtons )

       oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
       oContainer:Align := CONTROL_ALIGN_ALLCLIENT

       _oGetD := MsNewGetDados():New( 004, 004, 214, 594, 0, /*_cLinhaOk*/, /*_cTudoOk*/, "", /*_aAlter*/, 1, 999, /*_cFieldOk*/, /*_cSuperDel*/, /*_cDelOK*/, oContainer, _aHeaderAux, _aColsAux)
       oModal:Activate()

       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F9, bDadosClie )

       RestArea( aArea )
Return

/*/{Protheus.doc} fDadPed
Consulta pedido de vendas
@type function
@version 2021.10
@author Luís Gustavo de Souza
@since 10/10/2021
@param oView, object, objeto da View
/*/
Static Function fDadPed(oView)
       Local aArea       := GetArea()                 //Irei gravar a area atual
       Local _oMdl     := FwModelActive()
       Local _oModelPed  := _oMdl:GetModel( 'GRIDPEDIDO' )
       Private Inclui    := .F.                       //defino que a inclusão é falsa
       Private Altera    := .T.                       //defino que a alteração é verdadeira
       Private nOpca     := 1                         //obrigatoriamente passo a variavel nOpca com o conteudo 1
       Private cCadastro := "Pedido de Vendas"        //obrigatoriamente preciso definir com private a variável cCadastro
       Private aRotina   := {}                        //obrigatoriamente preciso definir a variavel aRotina como private

       SetKey( VK_F2, {||} )
       SetKey( VK_F4, {||} )
       SetKey( VK_F5, {||} )
       SetKey( VK_F6, {||} )
       SetKey( VK_F7, {||} )
       SetKey( VK_F8, {||} )
       SetKey( VK_F9, {||} )

       DbSelectArea('SC5')
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial('SC5') + _oModelPed:aCols[_oModelPed:nLine][1] ) )
     
       If lAcsCad
          MATA410( Nil, Nil, Nil, Nil, "A410Altera" ) //executo a função padrão MatA410
          FWFormModel():DeActivate()
          FWFormModel():Destroy()
          FWModelActive( _oMdl )
       Else
          MATA410( Nil, Nil, Nil, Nil, "A410Visual" ) //executo a função padrão MatA410
       Endif
       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F9, bDadosClie )

       RestArea( aArea )   
Return

/*/{Protheus.doc} fPlaFin
Planilha Financeira com o calculo dos impostos
@type function
@version 2021.10
@author Luís Gustavo de Souza
@since 10/10/2021
@param oView, object, objeto da View
/*/
Static Function fPlaFin(oView)
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _aRentab   := {}
       Local _cPerg     := 'MTA410'
       /***********************************************************************/
       /** Bloco de variáveis para montagem das variáveis para o FillGetDados */
       Local _cArqQry := "SC6"
       Local _nTotPed := 0
       Local _nTotDes := 0
       Local _lGrade  := MaGrade()
       Local _cSeek   := ""
       Local _bWhile
       Local _bCond   := { || .T. }
       Local _bAction1:= { || Mta410Vis( _cArqQry, @_nTotPed, @_nTotDes, _lGrade ) }
       Local _bAction2:= { || .T. } 
       Local _cQuery  := "" 
       /***********************************************************************/
       Private aTransp  := {"",""}

       SetKey( VK_F2, {||} )
       SetKey( VK_F4, {||} )
       SetKey( VK_F5, {||} )
       SetKey( VK_F6, {||} )
       SetKey( VK_F7, {||} )
       SetKey( VK_F8, {||} )
       SetKey( VK_F9, {||} )

       RegToMemory( 'SC5', .f. )
       Pergunte( _cPerg, .f. )

       DbSelectArea('SA4')
       SA4->( DbSetOrder( 1 ) )
       SA4->( DbSeek( xFilial('SA4') + SubStr( _oModelPed:aCols[_oModelPed:nLine][8], 1, 6 ) ) )

       DbSelectArea('SC5')
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial('SC5') + _oModelPed:aCols[_oModelPed:nLine][1] ) )

       aCols    := {}
       aHeader  := {}
       _cSeek   := FwxFilial( "SC6" ) + _oModelPed:aCols[_oModelPed:nLine][1]
       _bWhile  := { || C6_FILIAL + C6_NUM }
       _cQuery  := "SELECT * "
       _cQuery  += "FROM " + RetSQLName("SC6") + " SC6 "
       _cQuery  += "WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
       _cQuery  += "  AND SC6.D_E_L_E_T_ = '' "
       _cQuery  += "  AND SC6.C6_NUM = '" + _oModelPed:aCols[_oModelPed:nLine][1] + "' "
       _cQuery  += "ORDER BY " + SQLOrder( SC6->( IndexKey() ) )
        
       FillGetDados( 2, 'SC6', 1, _cSeek, _bWhile, { { _bCond, _bAction1, _bAction2, } }, /*_aNoFields*/, /*_aYesFields*/, /*_lOnlyYes*/, _cQuery, /*_bMontCols*/, .F., /*_aHeaderAux*/, /*_aColsAux*/, , , , "SC6" )

       Ma410Impos( 2, .F., @_aRentab)

       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F5, bDadosClie )

       RestArea( aArea )   
Return

/*/{Protheus.doc} fTAbFin
Consulta todos os titulos em aberto de acordo com os parâmetros
@type function
@version 2021.10
@author Luís Gustavo de Souza
@since 10/10/2021
@param oView, object, objeto da View
/*/
Static Function fTAbFin(oView)
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local aParam     := {}
       Local aAlias     := {}
       Local cxArea     := "FC010QRY01"
       Local aGet       := { "", "", "", "" }
       Local _cCliente  := SubStr( _oModelPed:aCols[ _oModelPed:nLine][4], 1, 6 )
       Local _cLoja     := SubStr( _oModelPed:aCols[ _oModelPed:nLine][4], 8, 2 )
       Private nCasas   := GetMv("MV_CENT")
	Private aSelFil  := {}
	Private aTmpFil  := {}

       SetKey( VK_F2, {||} )
       SetKey( VK_F4, {||} )
       SetKey( VK_F5, {||} )
       SetKey( VK_F6, {||} )
       SetKey( VK_F7, {||} )
       SetKey( VK_F8, {||} )
       SetKey( VK_F9, {||} )

       If Pergunte("FIC010",.t.)
          aadd(aParam, MV_PAR01) ; aadd(aParam, MV_PAR02) ; aadd(aParam, MV_PAR03)
          aadd(aParam, MV_PAR04) ; aadd(aParam, MV_PAR05) ; aadd(aParam, MV_PAR06)
          aadd(aParam, MV_PAR07) ; aadd(aParam, MV_PAR08) ; aadd(aParam, MV_PAR09)
          aadd(aParam, MV_PAR10) ; aadd(aParam, MV_PAR11) ; aadd(aParam, MV_PAR12)
          aadd(aParam, MV_PAR13) ; aadd(aParam, MV_PAR14) ; aadd(aParam, MV_PAR15)
          aadd(aParam, MV_PAR16) ; aadd(aParam, MV_PAR17)
          DbSelectArea("SA1")
          DbSetOrder(1)
          DbSeek( xFilial( "SA1" ) + _cCliente + _cLoja, .t. )
          If Found()
             Fc010Brow( 1, @aAlias, aParam, .T., aGet )
             DbSelectArea(cxArea)
             DbCloseArea()
          Endif
       Endif

       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F5, bDadosClie )

       RestArea( aArea )
Return

/*/{Protheus.doc} fTReFin
Consulta todos os titulos recebidos de acordo com os parâmetros
@type function
@version 2021.10
@author Luís Gustavo de Souza
@since 10/10/2021
@param oView, object, objeto da View
/*/
Static Function fTReFin(oView)
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local aParam   := {}
       Local aAlias   := {}
       Local cxArea   := "FC010QRY02"
       Local aGet     := { "", "", "", ""}
       Local _cCliente  := SubStr( _oModelPed:aCols[ _oModelPed:nLine][4], 1, 6 )
       Local _cLoja     := SubStr( _oModelPed:aCols[ _oModelPed:nLine][4], 8, 2 )
       Private nCasas := GetMv("MV_CENT")
       Private aSelFil  := {}
       Private aTmpFil  := {}

       SetKey( VK_F2, {||} )
       SetKey( VK_F4, {||} )
       SetKey( VK_F5, {||} )
       SetKey( VK_F6, {||} )
       SetKey( VK_F7, {||} )
       SetKey( VK_F8, {||} )
       SetKey( VK_F9, {||} )

       If Pergunte("FIC010",.t.)
          aadd(aParam, MV_PAR01) ; aadd(aParam, MV_PAR02) ; aadd(aParam, MV_PAR03)
          aadd(aParam, MV_PAR04) ; aadd(aParam, MV_PAR05) ; aadd(aParam, MV_PAR06)
          aadd(aParam, MV_PAR07) ; aadd(aParam, MV_PAR08) ; aadd(aParam, MV_PAR09)
          aadd(aParam, MV_PAR10) ; aadd(aParam, MV_PAR11) ; aadd(aParam, MV_PAR12)
          aadd(aParam, MV_PAR13) ; aadd(aParam, MV_PAR14) ; aadd(aParam, MV_PAR15)
          aadd(aParam, MV_PAR16) ; aadd(aParam, MV_PAR17)
          DbSelectArea("SA1")
          DbSetOrder(1)
          DbSeek( xFilial( "SA1" ) + _cCliente + _cLoja, .t. )
          If Found()
             Fc010Brow( 2, @aAlias, aParam, .T., aGet )
             DbSelectArea( cxArea )
             DbCloseArea()
          Endif
       Endif

       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F9, bDadosClie )

       RestArea( aArea )
Return

/*/{Protheus.doc} fDadCli
Consulta dados do cliente - Para cadastro e crédito alteração para os demais visualização do cliente
@type function
@version 2021.12
@author Luís Gustavo de Souza
@since 21/12/2021
@param oView, object, objeto da View
/*/
Static Function fDadCli(oView)
       Local aArea        := GetArea()                 //Irei gravar a area atual
       Local _oMdl        := FwModelActive()
       Local _oModelPed   := _oMdl:GetModel( 'GRIDPEDIDO' )
       Local _cCliente    := SubStr( _oModelPed:aCols[ _oModelPed:nLine][4], 1, 6 )
       Local _cLoja       := SubStr( _oModelPed:aCols[ _oModelPed:nLine][4], 8, 2 )
       Private aRotAuto   := Nil
       Private aRotina
       Private cCadastro  := "Clientes" 
       Private aMemos     := { }
       Private bFiltraBrw := { || Nil }
       Private l030Auto   := .F. // Variavel usada para saber se é rotina automática
       Private aRAutoFOJ  := Nil
       Private aCpoAltSA1 := {} // Vetor usado na gravacao do historico de alteracoes
       Private aCpoSA1    := {} // Vetor usado na gravacao do historico de alteracoes
       Private aTELA[0][0],aGETS[0]

       aMemos  := { { "A1_CODMARC","A1_VM_MARC"},{"A1_OBS","A1_VM_OBS"}}
	aRotina := { { "Pesquisar" , "PesqBrw"    , 0 , 1,   0  , .F. },;
                    { "Visualisar", "A030Visual" , 0 , 2,   0  , NIL },;
                    { "Incluir"   , "A030Inclui" , 0 , 3,  81  , NIL },;
                    { "Alterar"   , "A030Altera" , 0 , 4, 143  , NIL },;
                    { "Excluir"   , "A030Deleta" , 0 , 5, 144  , NIL } }

       SetKey( VK_F2, {||} )
       SetKey( VK_F4, {||} )
       SetKey( VK_F5, {||} )
       SetKey( VK_F6, {||} )
       SetKey( VK_F7, {||} )
       SetKey( VK_F8, {||} )
       SetKey( VK_F9, {||} )

       DbSelectArea("SA1")
       SA1->( DbSetOrder( 1 ) )
       If SA1->( DbSeek( xFilial( "SA1" ) + _cCliente + _cLoja ) )
          If lAcsCad .or. lAcsCre
             A030Altera( "SA1", SA1->( RECNO() ), 4 )
             FWFormModel():DeActivate()
             FWFormModel():Destroy()
             FWModelActive( _oMdl )
          Else
             A030Altera( "SA1", SA1->( RECNO() ), 2 )
          Endif
       Endif

       SetKey( VK_F2, bHistorico )
       SetKey( VK_F4, bItensPedi )
       SetKey( VK_F5, bDadosPedi )
       SetKey( VK_F6, bPlanilhaF )
       SetKey( VK_F7, bTitAberto )
       SetKey( VK_F8, bTitRecebi )
       SetKey( VK_F9, bDadosClie )

       RestArea( aArea )
Return

/*/{Protheus.doc} fAprova
Painel das aprovações dos pedidos de vendas
@type function
@version  v.2021.01
@author Luís Gustavo de Souza
@since 23/10/2021
@param _oPanel, Object, Objeto do Painel das aprovações
/*/
Static Function fAprova( _oPanel )
       Local _oFont4  := Tfont():New( "Courier New", , -16, , .T., , , , , , )
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _nPosLCa   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBCAD'   } )
       Local _nPosUCa   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRCAD'   } )
       Local _nPosLPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBPED'   } )
       Local _nPosUPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRPED'   } )
       Local _nPosLCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBCRE'   } )
       Local _nPosUCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRCRE'   } )
       Local _nPosLDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBDIR'   } )
       Local _nPosUDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRDIR'   } )
       Local _nPosLAp   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'APROVA'   } )
       Local _nPosUAp   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRAPR'   } )

       _lLibCad := _oModelPed:aCols[_oModelPed:nLine][_nPosLCa]
       _cUsrCad := _oModelPed:aCols[_oModelPed:nLine][_nPosUCa]
       _lLibPed := _oModelPed:aCols[_oModelPed:nLine][_nPosLPe]
       _cUsrPed := _oModelPed:aCols[_oModelPed:nLine][_nPosUPe]
       _lLibCre := _oModelPed:aCols[_oModelPed:nLine][_nPosLCr]
       _cUsrCre := _oModelPed:aCols[_oModelPed:nLine][_nPosUCr]
       _lLibDir := _oModelPed:aCols[_oModelPed:nLine][_nPosLDi]
       _cUsrDIR := _oModelPed:aCols[_oModelPed:nLine][_nPosUDi]
       _lLibRec := _oModelPed:aCols[_oModelPed:nLine][_nPosLAp]
       _cUsrRec := _oModelPed:aCols[_oModelPed:nLine][_nPosUAp]

       @ 015,005 CHECKBOX _oLibCad VAR _lLibCad PROMPT OemToAnsi("Cadastro:")  SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 015,070 SAY      _oUsrCad VAR _cUsrCad PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       @ 035,005 CHECKBOX _oLibPed VAR _lLibPed PROMPT OemToAnsi("Vendas:")    SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 035,070 SAY      _oUsrPed VAR _cUsrPed PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       @ 055,005 CHECKBOX _oLibCre VAR _lLibCre PROMPT OemToAnsi("Crédito:")   SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 055,070 SAY      _oUsrCre VAR _cUsrCre PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       @ 075,005 CHECKBOX _oLibDir VAR _lLibDir PROMPT OemToAnsi("Diretoria:") SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 075,070 SAY      _oUsrDir VAR _cUsrDir PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       @ 095,005 CHECKBOX _oLibRec VAR _lLibRec PROMPT OemToAnsi("Recusar:")   SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 095,070 SAY      _oUsrRec VAR _cUsrRec PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       _oLibCad:bLClicked := { || fMRCCad() } ; _oLibPed:bLClicked := { || fMRCPed() }
       _oLibCre:bLClicked := { || fMRCCre() } ; _oLibDir:bLClicked := { || fMRCDir() }
       _oLibRec:bLClicked := { || fMRCRec() }
       If lAcsCad
          _oLibPed:bWhen := { || .F. }
          _oLibCre:bWhen := { || .F. }
          _oLibDir:bWhen := { || .F. }
          _oLibRec:bWhen := { || .F. }
       Endif
Return .T.

/*/{Protheus.doc} fRestri
Monta painel das restrições do cliente
@type function
@version  v2021.01
@author Luís Gustavo Souza
@since 23/10/2021
@param _oPanel, Object, Objeto do painel das restrições
/*/
Static Function fRestri( _oPanel )
       Local _oFont3    := Tfont():New( "Courier New", , -12, , .F., , , , , , )

       fDadRes( )
       @ 015,005 GET _oRestri VAR _cRestri MEMO READONLY SIZE 225,090 PIXEL OF _oPanel FONT _oFont3

Return .T.

/*/{Protheus.doc} fDadRes
Busca dados das restrições do cliente
@type function
@version  v2021.01
@author Luís Gustavo de Souza
@since 23/10/2021
/*/
Static Function fDadRes( )
       Local _cAuxRes   := ""
       Local _nTotTit   := 0
       Local _nTotAtr   := 0
       Local _nTotRes   := 0
       Local _nLinMen   := 0
       Local _nPasso    := 0
       Local _cTexto    := ""
       Local _cDescri   := ""
       Local _nAcumul   := 0
       Local _nSaldoMes := 0
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _nPosRes   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'RESTRICAO' } )

       DbSelectArea("SA1")
       SA1->( DbSetOrder( 1 ) )
       SA1->( DbSeek( xFilial( "SA1" ) + SubStr( _oModelPed:aCols[_oModelPed:nLine][4], 1, 6 ) + SubStr( _oModelPed:aCols[_oModelPed:nLine][4], 8, 2 ) ) )

       DbSelectArea("SC5")
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial( "SC5" ) + _oModelPed:aCols[_oModelPed:nLine][1] ) )

       /*** INFORMAÇÕES FINANCEIRAS ***/
       _cQry1 := "SELECT CASE WHEN ( SE1.E1_VENCREA < SE1.E1_BAIXA ) THEN '1-PAT' WHEN ( SE1.E1_SALDO > 0.0 ) AND ( SE1.E1_VENCREA < " + ;
                           "( SELECT CAST( DATEPART( Year, GETDATE() ) AS VARCHAR) + CASE WHEN LEN(DATEPART( Month, GETDATE())) = 1 THEN CAST('0' AS VARCHAR) " + ;
                                                   "+ CAST(DATEPART(Month, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Month, GETDATE()) AS VARCHAR) END + CASE WHEN LEN(DATEPART(Day, "+;
                                                   " GETDATE())) = 1 THEN CAST('0' AS VARCHAR) + CAST(DATEPART(Day, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Day, GETDATE()) AS VARCHAR) "+;
                                                   " END)) THEN '2-ATR' ELSE '3-NORMAL' END AS STATUS, E1_FILIAL, CASE WHEN (SE1.E1_VENCREA < SE1.E1_BAIXA) "+;
                      "THEN CAST(CAST(SE1.E1_BAIXA AS DATETIME) AS INT) - CAST(CAST(SE1.E1_VENCREA AS DATETIME) AS INT) WHEN (SE1.E1_SALDO > 0.0) AND "+;
                      "(SE1.E1_VENCREA < "+;
                          "(SELECT     CAST(DATEPART(Year, GETDATE()) AS VARCHAR) + CASE WHEN LEN(DATEPART(Month, GETDATE())) = 1 THEN CAST('0' AS VARCHAR) "+;
                                                   "+ CAST(DATEPART(Month, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Month, GETDATE()) AS VARCHAR) END + CASE WHEN LEN(DATEPART(Day, "+;
                                                   "GETDATE())) = 1 THEN CAST('0' AS VARCHAR) + CAST(DATEPART(Day, GETDATE()) AS VARCHAR) ELSE CAST(DATEPART(Day, GETDATE()) AS VARCHAR) "+;
                                                   "END)) THEN CAST(CAST "+;
                          "((SELECT     SUBSTRING(CONVERT(VARCHAR, GETDATE(), 105), 7, 4) + SUBSTRING(CONVERT(VARCHAR, GETDATE(), 105), 4, 2) + SUBSTRING(CONVERT(VARCHAR, "+;
                                                   " GETDATE(), 105), 1, 2)) AS DATETIME) AS INT) - CAST(CAST(SE1.E1_VENCREA AS DATETIME) AS INT) ELSE 0 END AS ATRASO, "+;
                      "E1_CLIENTE + '-' + E1_LOJA AS CLIENTE, E1_PREFIXO + '-' + E1_NUM + '-' + E1_PARCELA AS TITULO, SUBSTRING(E1_VENCREA, 7, 2) "+;
                      "+ '/' + SUBSTRING(E1_VENCREA, 5, 2) + '/' + SUBSTRING(E1_VENCREA, 1, 4) AS VENCIMENTO, E1_SALDO AS VALOR "
       _cQry1 += "FROM " + RetSqlName("SE1") + " AS SE1 WITH (NOLOCK) "
       _cQry1 += "WHERE ( SE1.D_E_L_E_T_ = '' ) "
       _cQry1 += "  AND ( SE1.E1_CLIENTE = '" + SA1->A1_COD + "') "
       _cQry1 += "  AND ( SE1.E1_LOJA = '" + SA1->A1_LOJA + "') "
       _cQry1 += "  AND ( SE1.E1_SALDO > 0 ) "
       DbUseArea( .T., "TOPCONN", TcGenQry( , , _cQry1 ), "TIT", .T., .T. )
       _cAuxRes := ""
       DbSelectArea("TIT")
       While !Eof()
             If SubStr( TIT->STATUS, 1, 1 ) == '2' //Titulos em atraso
                _cAuxRes += "    - TIT.: " + TIT->E1_FILIAL + '/' + TIT->TITULO + " VENCTO. EM " + TIT->VENCIMENTO + Chr(13) + chr(10)
                _cAuxRes += "      * " + StrZero( TIT->ATRASO, 3 ) + " dia(s) de atraso. - " + TransForm( TIT->VALOR, "@E 999,999,999.99") + Chr(13) + chr(10)
                _nTotTit += TIT->VALOR
                _nTotAtr += TIT->VALOR
             ElseIf SubStr(TIT->STATUS, 1, 1) == '1'
                    _cAuxRes += "    - TIT.: " + TIT->E1_FILIAL + '/' + TIT->TITULO + " VENCTO. EM " + TIT->VENCIMENTO + Chr(13) + chr(10)
                    _cAuxRes += "      * " + StrZero( TIT->ATRASO, 3 ) + " dia(s) de atraso. - " + TransForm( TIT->VALOR, "@E 999,999,999.99" ) + Chr(13) + chr(10)
                    _nTotTit += TIT->VALOR
                    _nTotAtr += TIT->VALOR
             ElseIf SubStr(TIT->STATUS, 1, 1) == '3'
                    _nTotTit += TIT->VALOR
             Endif
             DbSelectArea("TIT")
             TIT->( DbSkip() )
       Enddo
       DbSelectArea("TIT")
       TIT->( DbCloseArea() )

       /*Levantamento de Saldo de Pedidos Aprovados no Mês*/       
       _cQry1 := "SELECT SUM( SC6.C6_VALOR * ( CASE WHEN C5_ESPECI4 > '' THEN ( 1 / 0.7 ) ELSE 1 END ) ) AS VALOR "
       _cQry1 += "FROM " + RetSqlName( "SC6" ) + " SC6 WITH (NOLOCK) "
       _cQry1 += "LEFT OUTER JOIN " + RetSqlName("SC5") + " SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (SC6.C6_FILIAL = SC5.C5_FILIAL) AND (SC6.C6_NUM = SC5.C5_NUM) "
       _cQry1 += "LEFT OUTER JOIN " + RetSqlName("SF4") + " SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (SC6.C6_TES = SF4.F4_CODIGO) "
       _cQry1 += "WHERE (SC6.D_E_L_E_T_ <> '*') "
       _cQry1 += "  AND (SC6.C6_FILIAL = '" + xFilial("SC6") + "') "
       _cQry1 += "  AND (SC5.C5_CLIENTE = '" + SA1->A1_COD + "') "
       _cQry1 += "  AND (SC5.C5_LOJACLI = '" + SA1->A1_LOJA + "') "
       _cQry1 += "  AND (SUBSTRING( SC5.C5_EMISSAO, 1, 6 ) = '" + SubStr( DTOS( DATE() ), 1, 6 ) + "') "
       _cQry1 += "  AND (SC6.C6_NUM <> '" + _oModelPed:aCols[_oModelPed:nLine][1] + "') "
       _cQry1 += "  AND (SC5.C5_APROVA = '1') "
       _cQry1 += "  AND ( ( SF4.F4_DUPLIC <> 'N' ) OR ( SC6.C6_TES = '519' ) ) "
       DbUseArea( .T., "TOPCONN", TcGenQry( , , _cQry1 ), "TOTVENDIDO", .T., .T. )
       _nSaldoMes := TOTVENDIDO->VALOR
       dbselectarea("TOTVENDIDO")
       TOTVENDIDO->( DbCloseArea() )

       _cRestri := ""
       _cRestri += "1º) ÍNDICE DE LIQUIDEZ: " + Transform( SA1->A1_LIQUID , "@E 999.99%" ) + Chr(13) + chr(10)
       _cRestri += " " + Chr(13) + chr(10)
       _cRestri += "2º) TENDÊNCIA DE LIQUIDEZ ULT. VENCTOS.: " + Transform( SA1->A1_TENLIQ, "@E 999.99%" ) + Chr(13) + chr(10)
       _cRestri += " " + Chr(13) + chr(10)
       _cRestri += "3º) TITULOS EM ABERTO C/ ATRASO: " + Chr(13) + chr(10)
       _cRestri += _cAuxRes
       _cRestri += " " + Chr(13) + chr(10)
       _cRestri += "4º) VALOR TOTAL DE TITULOS EM ABERTO: R$ " + Alltrim( Transform( _nTotTit, "@E 999,999,999.99") ) + " (M)" + Chr(13) + chr(10)
       _cRestri += "                                      R$ " + Alltrim( Transform( _nTotRes, "@E 999,999,999.99") ) + " (R)" + Chr(13) + chr(10)
       _cRestri += " " + Chr(13) + chr(10)
       _cRestri += "5º) SCI " + Chr(13) + chr(10)
       _nLinMen := 0
       _nPasso  := 0
       _nLinMen := MlCount( SA1->A1_OB, 51 )
       _cTexto  := SA1->A1_OB
       While _nPasso <= _nLinMen
             _cDescri := MemoLine( _cTexto, 51, _nPasso )
             _nPasso++
             If Empty( _cDescri )
                Loop
             EndIf
             _cRestri += "    - " + Alltrim( _cDescri ) + Chr(13) + chr(10)
       Enddo
       _cRestri += " " + Chr(13) + chr(10)
       //_nAcumul := fAcuPed(aCliente, nPercSubst, nPerIcm, nAliqSol)
       _nAcumul := fAcuPed( Iif( SC5->C5_TIPO $ 'D.B', { 'SA2', SC5->C5_CLIENTE }, { 'SA1', SC5->C5_CLIENTE } ), 0, 0, 0 )
       _cRestri += "6º) PEDIDOS EM ABERTO: R$ " + Transform( _nAcumul, "@E 999,999,999.99" ) + Chr(13) + chr(10)
       If _nAcumul > SA1->A1_LC
          _cRestri += "    - Ultrapassa sugestão de crédito: " + Chr(13) + chr(10)
          _cRestri += "      R$ " + Transform( SA1->A1_LC, "@E 999,999,999.99" ) + Chr(13) + chr(10)
       Endif
       _cRestri += " " + Chr(13) + chr(10)
       _cRestri += "7º) SALDO DE PEDIDOS DO CLIENTE NO MÊS (EXCETO ESTE): R$ " + Alltrim( Transform( _nSaldoMes, "@E 999,999,999.99" ) ) + Chr(13) + chr(10)
       
       _nTotPAb := fAcuPed( Iif( SC5->C5_TIPO $ 'D.B', { 'SA2', SC5->C5_CLIENTE }, { 'SA1', SC5->C5_CLIENTE } ), 0/*nPercSubst*/, 0/*nPerIcm*/, 0/*nAliqSol*/, _oModelPed:aCols[_oModelPed:nLine][1] )

      _oModelPed:aCols[_oModelPed:nline][_nPosRes] := _cRestri
Return

/*/{Protheus.doc} fObserv
Montagem das Observações do pedido de vendas
@type function
@version  v2021.01
@author Luís Gustavo de Souza
@since 23/10/2021
@param _oPanel, Object, Objeto do painel das mensagens
/*/
Static Function fObserv( _oPanel )
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _nPosOPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'OBSPED'   } )
       Local _nPosOC5   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'OBSSC5'   } )

       _cObsMsg := MSMM( _oModelPed:aCols[_oModelPed:nLine][_nPosOPe], , , , 3 )
       _cObserv := Alltrim( U_TiraAcento( MSMM( _oModelPed:aCols[_oModelPed:nLine][_nPosOC5] ) ) )

       @ 015,005 GET _oObsMsg VAR _cObsMsg MEMO READONLY SIZE 225,045 PIXEL OF _oPanel
       @ 060,005 GET _oObserv VAR _cObserv MEMO READONLY SIZE 225,045 PIXEL OF _oPanel

Return .T.

Static Function fMRCCad()
       _cUsrCad := Iif(_lLibCad, cUsername, space(25) )
       _oUsrCad:SetText(_cUsrCad)
       _oUsrCad:Refresh()
Return

Static Function fMRCPed()
                _cUsrPed := Iif( _lLibPed, cUsername, space(25) )
                _oUsrPed:SetText(_cUsrPed)
                _oUsrPed:Refresh()
Return

Static Function fMRCCre()
       _cUsrCre := Iif( _lLibCre, cUsername, space(25) )
       _oUsrCre:SetText( _cUsrCre )
       _oUsrCre:Refresh()
Return

Static Function fMRCDir()
       _cUsrDir := Iif( _lLibDir, cUsername, space(25) )
       _oUsrDir:SetText(_cUsrDir)
       _oUsrDir:Refresh()
Return

Static Function fMRCRec()
          _cUsrRec := Iif( _lLIbRec, cUsername, space(25))
          cUsrPed := "" ; cUsrCre := "" ; cUsrDir := ""
          lLibPed := .f. ;  lLibCre := .f. ; lLibDir := .f.
          _oUsrRec:SetText(_cUsrRec)
          _oUsrPed:SetText(_cUsrPed)
          _oUsrDir:SetText(_cUsrDir)
          _oUsrCre:SetText(_cUsrCre)
          _oUsrPed:Refresh() ; _oUsrCre:Refresh() ; _oUsrDir:Refresh() ; _oUsrRec:Refresh()
Return

Static Function fAcuPed( aCliente, nPercSubst, nPerIcm, nAliqSol, _NumPedAtu )
       Local cQuery  := ""
       Local nAcumul := 0
       
       cQuery += "SELECT VALTOT = SUM(SC6.C6_VALOR), "
       cQuery += "       VALIPI = SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))), "
       cQuery += "       VALICM = (CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END), "
       cQuery += "       AUXICM = ((CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END) * "+Stuff( Transform(nPerIcm,"@E 999.99"), AT(",",Transform(nPerIcm,"@E 999.99")), 1, ".")+"), "
       cQuery += "       LUCROS = ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ), "
       cQuery += "       BASEST = CASE WHEN SF4.F4_INCSOL = 'S' THEN ( SUM(SC6.C6_VALOR) + SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))) ) * ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ) ELSE 0 END, "
       cQuery += "       VALSTB = ( (CASE WHEN SF4.F4_INCSOL = 'S' THEN ( SUM(SC6.C6_VALOR) + SUM((SC6.C6_VALOR * (SB1.B1_IPI / 100))) ) * ( 1 + ( "+Stuff( Transform(nPercSubst,"@E 999.99"), AT(",",Transform(nPercSubst,"@E 999.99")), 1, ".")+" / 100) ) ELSE 0 END) * "+Stuff( Transform(nAliqSol,"@E 999.99"), AT(",",Transform(nAliqSol,"@E 999.99")), 1, ".")+" ) - (CASE WHEN SF4.F4_INCSOL = 'S' THEN (CASE WHEN SF4.F4_INCIDE = 'S' THEN SUM(SC6.C6_VALOR + (SC6.C6_VALOR * (SB1.B1_IPI / 100))) ELSE 0 END ) ELSE 0 END) * "+Stuff( Transform(nPerIcm,"@E 999.99"), AT(",",Transform(nPerIcm,"@E 999.99")), 1, ".")+" "
       cQuery += "FROM " + RetSQLName("SC5") + " SC5 WITH (NOLOCK) "
       cQuery += "LEFT OUTER JOIN " + RetSqlName("SC6") + " SC6 WITH (NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ = '' "
       cQuery += "LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SC6.C6_FILIAL AND SB1.B1_COD = SC6.C6_PRODUTO "
       cQuery += "LEFT OUTER JOIN " + RetSqlName("SF4") + " SF4 WITH (NOLOCK) ON '  '          = SF4.F4_FILIAL AND SF4.F4_CODIGO = SC6.C6_TES "
       IF GETMV("MV_JUNFIL")
          cQuery += "WHERE "
       Else
          cQuery += "WHERE SC5.C5_FILIAL   = '" + xFilial("SC5") + "' AND "
       Endif
       cQuery += "         SC5.D_E_L_E_T_  = '' "
       cQuery += "  AND SC5.C5_NOTA     = '' "
       cQuery += "  AND SC5.C5_CLIENTE  = '" + aCliente[2] + "' "
       If _NumPedAtu <> NIL
          cQuery += "  AND SC5.C5_NUM <> '" + _NumPedAtu + "' "
       Endif
       cQuery += "GROUP BY SF4.F4_INCSOL, SF4.F4_INCIDE "
       dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), "LIQ", .T., .T. )

       DbSelectArea("LIQ")
       DbGoTop()
       While !Eof()
             nAcumul += ( LIQ->VALTOT + LIQ->VALIPI + LIQ->VALSTB)
             DbSelectArea("LIQ")
             DbSkip()
       Enddo
       DbSelectArea("LIQ")
       DbCloseArea()
Return( nAcumul )

Static Function fComple( _oPanel )
       Local _oFont4    := Tfont():New( "Courier New", , -16, , .T., , , , , , )
       Local _oFont3    := Tfont():New( "Courier New", , -10, , .T., , , , , , )
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _nPosPri   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'DTPRICOM' } )
       Local _nPosUlt   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'DTULTCOM' } )
       Local _nPosRis   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'RISCO'    } )
       Local _nPosAlt   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRALT'   } )
       Local _nPosTip   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'TPVENDA'} )

       _cAltera := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosAlt ]
       _cVenda  := Iif( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosTip ] == 'I', 'Interna', 'Externa' )
       _cPriCom := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosPri ]
       _cUltCom := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosUlt ]
       _cRisco  := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosRis ]

       @ 005,000 SAY OemToAnsi('1º Compra:')                                  SIZE 030,09 PIXEL OF _oPanel
       @ 004,030 SAY _oPriCom VAR _cPriCom        PICTURE '@!' COLOR CLR_BLUE SIZE 050,09 PIXEL OF _oPanel FONT _oFont4
       @ 005,090 SAY OemToAnsi('Ult. Compra:')                                SIZE 030,09 PIXEL OF _oPanel
       @ 004,123 SAY _oUltCom VAR _cUltCom        PICTURE '@!' COLOR CLR_BLUE SIZE 050,09 PIXEL OF _oPanel FONT _oFont4
       @ 005,183 SAY OemToAnsi('Risco:')                                      SIZE 020,09 PIXEL OF _oPanel
       @ 004,201 SAY _oRisco  VAR _cRisco         PICTURE '@!' COLOR CLR_BLUE SIZE 010,09 PIXEL OF _oPanel FONT _oFont4
       @ 005,215 SAY OemToAnsi('Tp. Venda:')                                  SIZE 030,09 PIXEL OF _oPanel
       @ 004,247 SAY _oVenda  VAR _cVenda         PICTURE '@!' COLOR CLR_BLUE SIZE 035,09 PIXEL OF _oPanel FONT _oFont4
       @ 005,292 SAY OemToAnsi('Ult. Alteração:')                             SIZE 040,09 PIXEL OF _oPanel
       @ 004,332 SAY _oAltera VAR _cAltera        PICTURE '@!' COLOR CLR_BLUE SIZE 125,09 PIXEL OF _oPanel FONT _oFont4

       //Teclas de atalho das funcionalidades
       @ 001,440 SAY OemToAnsi('F2-Hist. pedido | F5-Dados pedido | F7-Tit. em aberto | F9-Dados Cliente')    COLOR CLR_RED  SIZE 300,06 PIXEL OF _oPanel FONT _oFont3
       @ 008,440 SAY OemToAnsi('F4-Itens pedido | F6-Plan. Finan. | F8-Tit. recebidos | F10-Ped.Cliente' )    COLOR CLR_RED  SIZE 300,06 PIXEL OF _oPanel FONT _oFont3
Return .T.

/*/{Protheus.doc} fCalImp
Função para calculo e consolidação dos impostos
@type function
@version  v2021.01
@author Luis Gustavo de Souza
@since 13/11/2021
@param _cPedido, Character, Numero do pedido para calculo dos impostos
/*/
Static Function fCalImp( _cPedido )
       Local _aFisGet
       Local _aFisGetSC5
       Local _aRelImp    := MaFisRelImp( "MT100", { "SF2", "SD2" } )
       Local _nY
       Local _cQryAd
       Local _cAliasSC5
       Local _cAliasSC6
       Local _cCliEnt
       Local _aItemPed   := {}
       Local _aValMerc   := {}
       Local _cNfOri     := Nil
       Local _cSeriOri   := Nil
       Local _nRecnoSD1  := Nil
       Local _nDesconto  := 0
       Local _nValMerc   := 0
       Local _nPrcLista  := 0
       Local _nTamPrcVen := TamSX3("C6_PRCVEN")[2]
       Local _nAcresFin  := 0
       Local _nVlrPesoUnit := 0
       Local _nPesoTot   := 0    

       DbselectArea('SC5')
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial('SC5') + _cPedido ) )
       RegToMemory( 'SC5', .f. )
       
       DbSelectArea("SA1")
       SA1->( DbSetOrder( 1 ) )
       SA1->( DbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )
       
       FisGetInit( @_aFisGet, @_aFisGetSC5 )

       _cQryAd := "%"
       For _nY := 1 To Len( _aFisGet )
           _cQryAd += "," + _aFisGet[ _nY][ 2 ]
       Next _nY
       For _nY := 1 To Len( _aFisGetSC5 )
           _cQryAd += "," + _aFisGetSC5[ _nY ][ 2 ]
       Next _nY		
       _cQryAd += "%"

       _cAliasSC5 := _cAliasSC6 := GetNextAlias()

       BeginSql Alias _cAliasSC5
                SELECT SC5.R_E_C_N_O_ SC5REC,SC6.R_E_C_N_O_ SC6REC,
                       SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SC5.C5_TIPO,
                       SC5.C5_TIPOCLI,SC5.C5_TRANSP,SC5.C5_PBRUTO,SC5.C5_PESOL,SC5.C5_DESC1,
                       SC5.C5_DESC2,SC5.C5_DESC3,SC5.C5_DESC4,SC5.C5_MENNOTA,SC5.C5_EMISSAO,
                       SC5.C5_CONDPAG,SC5.C5_FRETE,SC5.C5_DESPESA,SC5.C5_FRETAUT,SC5.C5_TPFRETE,SC5.C5_SEGURO,SC5.C5_TABELA,
                       SC5.C5_VOLUME1,SC5.C5_ESPECI1,SC5.C5_MOEDA,SC5.C5_REAJUST,SC5.C5_BANCO,
                       SC5.C5_ACRSFIN,SC5.C5_VEND1,SC5.C5_VEND2,SC5.C5_VEND3,SC5.C5_VEND4,SC5.C5_VEND5,
                       SC5.C5_COMIS1,SC5.C5_COMIS2,SC5.C5_COMIS3,SC5.C5_COMIS4,SC5.C5_COMIS5,SC5.C5_PDESCAB,SC5.C5_DESCONT,C5_INCISS,
                       SC5.C5_CLIENT,
                       SC6.C6_FILIAL,SC6.C6_NUM,SC6.C6_PEDCLI,SC6.C6_PRODUTO,
                       SC6.C6_TES,SC6.C6_CF,SC6.C6_QTDVEN,SC6.C6_PRUNIT,SC6.C6_VALDESC,
                       SC6.C6_VALOR,SC6.C6_ITEM,SC6.C6_DESCRI,SC6.C6_UM,
                       SC6.C6_PRCVEN,SC6.C6_NOTA,SC6.C6_SERIE,SC6.C6_CLI,
                       SC6.C6_LOJA,SC6.C6_ENTREG,SC6.C6_DESCONT,SC6.C6_LOCAL, SC6.C6_COMIS1, 
                       SC6.C6_QTDEMP,SC6.C6_QTDLIB,SC6.C6_QTDENT,SC6.C6_NFORI,SC6.C6_SERIORI,SC6.C6_ITEMORI
                %Exp:_cQryAd%
                FROM %Table:SC5% SC5, %Table:SC6% SC6
                WHERE
                SC5.C5_FILIAL = %xFilial:SC5% AND
                SC5.C5_NUM >= %Exp:_cPedido% AND
                SC5.C5_NUM <= %Exp:_cPedido% AND
                SC5.%notdel% AND
                SC6.C6_FILIAL = %xFilial:SC6% AND
                SC6.C6_NUM   = SC5.C5_NUM AND
                SC6.%notdel%
                ORDER BY SC5.C5_NUM    
       EndSql

	dbSelectArea( _cAliasSC5 )

	_cCliEnt := IIf( !Empty( ( _cAliasSC5 )->( FieldGet( FieldPos("C5_CLIENT") ) ) ), ( _cAliasSC5 )->C5_CLIENT, ( _cAliasSC5 )->C5_CLIENTE )
	//_aCabPed := {}

       MaFisIni( _cCliEnt                                     ,; // 1-Codigo Cliente/Fornecedor
                 ( _cAliasSC5 )->C5_LOJACLI                   ,; // 2-Loja do Cliente/Fornecedor
                 If( ( _cAliasSC5)->C5_TIPO $ 'DB', "F", "C" ),; // 3-C:Cliente , F:Fornecedor
                 ( _cAliasSC5 )->C5_TIPO                      ,; // 4-Tipo da NF
                 ( _cAliasSC5 )->C5_TIPOCLI                   ,; // 5-Tipo do Cliente/Fornecedor
                 _aRelImp                                     ,; // 6-Relacao de Impostos que suportados no arquivo
                                                              ,; // 7-Tipo de complemento
                                                              ,; // 8-Permite Incluir Impostos no Rodape .T./.F.
                 "SB1"                                        ,; // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
                 "MATA461"                                     ) // 10-Nome da rotina que esta utilizando a funcao

       aCols      := {}

       dbSelectArea( _cAliasSC5 )
       For _nY := 1 to Len( _aFisGetSC5 )
           If !Empty( &( _aFisGetSC5[_nY][2] ) )
              If _aFisGetSC5[_ny][1] == "NF_SUFRAMA"
                 MaFisAlt( _aFisGetSC5[_nY][1], Iif( &( _aFisGetSC5[_nY][2] ) == "1", .T., .F. ), Len( aCols ), .T. )
              Else
                 MaFisAlt( _aFisGetSC5[_nY][1], &( _aFisGetSC5[_nY][2] ), Len( aCols ), .T. )
              Endif	
           EndIf
       Next _nY
       fMonHead()
       _nItem := 0
       While !( ( _cAliasSC6 )->( Eof() ) ) .And. xFilial("SC6") == ( _cAliasSC6 )->C6_FILIAL .And. ( _cAliasSC6 )->C6_NUM == _cPedido
             _cNfOri     := Nil
             _cSeriOri   := Nil
             _nRecnoSD1  := Nil
             _nDesconto  := 0
             _nItem++

             If !Empty( ( _cAliasSC6 )->C6_NFORI )
                dbSelectArea("SD1")
                dbSetOrder(1)
                dbSeek( xFilial("SC6") + ( _cAliasSC6 )->C6_NFORI + ( _cAliasSC6 )->C6_SERIORI + ( _cAliasSC6 )->C6_CLI + ( _cAliasSC6 )->C6_LOJA + ( _cAliasSC6 )->C6_PRODUTO + ( _cAliasSC6 )->C6_ITEMORI )
                _cNfOri     := ( _cAliasSC6 )->C6_NFORI
                _cSeriOri   := ( _cAliasSC6 )->C6_SERIORI
                _nRecnoSD1  := SD1->( RECNO() )
             EndIf

             dbSelectArea( _cAliasSC6 )
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Calcula o preco de lista                     ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             _nValMerc  := ( _cAliasSC6 )->C6_VALOR
             _nPrcLista := ( _cAliasSC6 )->C6_PRUNIT
             If ( _nPrcLista == 0 )
                _nPrcLista := NoRound( _nValMerc / ( _cAliasSC6 )->C6_QTDVEN, _nTamPrcVen )
             EndIf
             _nAcresFin := A410Arred( ( _cAliasSC6 )->C6_PRCVEN * ( _cAliasSC5 )->C5_ACRSFIN / 100, "D2_PRCVEN" )
             _nValMerc  += A410Arred( ( _cAliasSC6 )->C6_QTDVEN * _nAcresFin, "D2_TOTAL" )
             _nDesconto := a410Arred( _nPrcLista * ( _cAliasSC6 )->C6_QTDVEN, "D2_DESCON") - _nValMerc
             _nDesconto := IIf( _nDesconto == 0, ( _cAliasSC6 )->C6_VALDESC, _nDesconto )
             _nDesconto := Max( 0, _nDesconto )
             _nPrcLista += _nAcresFin
             If cPaisLoc == "BRA"
                _nValMerc  += _nDesconto
             EndIf			
             MaFisAdd( ( _cAliasSC6 )->C6_PRODUTO,; // 1-Codigo do Produto ( Obrigatorio )
                       ( _cAliasSC6 )->C6_TES    ,; // 2-Codigo do TES ( Opcional )
                       ( _cAliasSC6 )->C6_QTDVEN ,; // 3-Quantidade ( Obrigatorio )
                       _nPrcLista                ,; // 4-Preco Unitario ( Obrigatorio )
                       _nDesconto                ,; // 5-Valor do Desconto ( Opcional )
                       _cNfOri                   ,; // 6-Numero da NF Original ( Devolucao/Benef )
                       _cSeriOri                 ,; // 7-Serie da NF Original ( Devolucao/Benef )
                       _nRecnoSD1                ,; // 8-RecNo da NF Original no arq SD1/SD2
                       0                         ,; // 9-Valor do Frete do Item ( Opcional )
                       0                         ,; // 10-Valor da Despesa do item ( Opcional )
                       0                         ,; // 11-Valor do Seguro do item ( Opcional )
                       0                         ,; // 12-Valor do Frete Autonomo ( Opcional )
                       _nValMerc                 ,; // 13-Valor da Mercadoria ( Obrigatorio )
                       0                         ,; // 14-Valor da Embalagem ( Opiconal )
                       0                         ,; // 15-RecNo do SB1
                       0                          ) // 16-RecNo do SF4

             aadd( aCols, { ( _cAliasSC6)->C6_ITEM   ,;
                            ( _cAliasSC6)->C6_PRODUTO,;
                            ( _cAliasSC6)->C6_DESCRI ,;
                            ( _cAliasSC6)->C6_TES    ,;
                            ( _cAliasSC6)->C6_CF     ,;
                            ( _cAliasSC6)->C6_UM     ,;
                            ( _cAliasSC6)->C6_QTDVEN ,;
                            ( _cAliasSC6)->C6_PRCVEN ,;
                            ( _cAliasSC6)->C6_NOTA   ,;
                            ( _cAliasSC6)->C6_SERIE  ,;
                            ( _cAliasSC6)->C6_CLI    ,;
                            ( _cAliasSC6)->C6_LOJA   ,;
                            ( _cAliasSC6)->C6_VALOR  ,;
                            ( _cAliasSC6)->C6_ENTREG ,;
                            ( _cAliasSC6)->C6_DESCONT,;
                            ( _cAliasSC6)->C6_LOCAL  ,;
                            ( _cAliasSC6)->C6_QTDEMP ,;
                            ( _cAliasSC6)->C6_QTDLIB ,;
                            ( _cAliasSC6)->C6_QTDENT ,;
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ( _cAliasSC6)->C6_NUM+( _cAliasSC6)->C6_ITEM;
                          } ;
                 )
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Forca os valores de impostos que foram informados no SC6.              ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             dbSelectArea( _cAliasSC6 )
             For _nY := 1 to Len( _aFisGet )
                 If !Empty( &( _aFisGet[_nY][2] ) )
                    MaFisAlt( _aFisGet[_nY][1], &( _aFisGet[_nY][2]), Len( aCols ) )
                 EndIf
             Next _nY

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Calculo do ISS                               ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             SF4->( dbSetOrder(1) )
             SF4->( MsSeek( xFilial("SF4") + ( _cAliasSC6 )->C6_TES ) )
             If ( ( _cAliasSC5 )->C5_INCISS == "N" .And. ( _cAliasSC5)->C5_TIPO == "N" )
                If ( SF4->F4_ISS == "S" )
                   _nPrcLista := a410Arred( _nPrcLista / ( 1 - ( MaAliqISS( Len( aCols ) ) / 100 ) ), "D2_PRCVEN" )
                   _nValMerc  := a410Arred( _nValMerc  / ( 1 - ( MaAliqISS( Len( aCols ) ) / 100 ) ), "D2_PRCVEN" )
                   MaFisAlt( "IT_PRCUNI" , _nPrcLista, Len( aCols ) )
                   MaFisAlt( "IT_VALMERC", _nValMerc , Len( aCols ) )
                EndIf
             EndIf	
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Altera peso para calcular frete              ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             SB1->( dbSetOrder(1) )
             SB1->( MsSeek( xFilial("SB1") + ( _cAliasSC6 )->C6_PRODUTO ) )
             IF SB1->B1_PESO > 0			
                MaFisAlt( "IT_PESO"  , ( _cAliasSC6 )->C6_QTDVEN * SB1->B1_PESO, Len( aCols ) )
                MaFisAlt( "IT_PRCUNI", _nPrcLista, Len( aCols ) )
             EndIf
             aAdd( _aValMerc, { _nValMerc, Len( aCols ) } )

             // Somatória do Peso do Produto
             _nVlrPesoUnit := ( (_cAliasSC6)->C6_QTDVEN * SB1->B1_PESO )
             _nPesoTot     += _nVlrPesoUnit
             
             aCols[Len(aCols)][20] := MaFisRet( _nItem, 'IT_BASEICM' )
             aCols[Len(aCols)][21] := MaFisRet( _nItem, 'IT_ALIQICM' )
             aCols[Len(aCols)][22] := MaFisRet( _nItem, 'IT_VALICM'  )
             aCols[Len(aCols)][23] := MaFisRet( _nItem, 'IT_BASEIPI' )
             aCols[Len(aCols)][24] := MaFisRet( _nItem, 'IT_ALIQIPI' )
             aCols[Len(aCols)][25] := MaFisRet( _nItem, 'IT_VALIPI'  )
             aCols[Len(aCols)][26] := MaFisRet( _nItem, 'IT_BASECOF' )
             aCols[Len(aCols)][27] := MaFisRet( _nItem, 'IT_ALIQCOF' )
             aCols[Len(aCols)][28] := MaFisRet( _nItem, 'IT_VALCOF'  )
             aCols[Len(aCols)][29] := MaFisRet( _nItem, 'IT_BASEPIS' )
             aCols[Len(aCols)][30] := MaFisRet( _nItem, 'IT_ALIQPIS' )
             aCols[Len(aCols)][31] := MaFisRet( _nItem, 'IT_VALPIS'  )
             
             _aSolid      := ExecBlock( "M410SOLI", .f., .f., { _nItem } )
             aCols[Len(aCols)][32] := Iif( Len(_aSolid) > 0, _aSolid[3] + _aSolid[7], 0 ) //Valor do ICMS Solidario + Valor do FECP-ST

             ( _cAliasSC6 )->( dbSkip() )
	EndDo
       _aPedidos[aScan( _aPedidos, { |x| x[1] == _cPedido } )][3] := aCols
       For _nY := 1 To Len( aCols )
           //                            1,              2,              3,              4,              5,              6,              7,              8,              9,      
           aAdd( _aItens, { _cPedido      , aCols[_nY][01], aCols[_nY][34], aCols[_nY][02], aCols[_nY][03], aCols[_nY][04], aCols[_nY][05], aCols[_nY][06], aCols[_nY][07],;
                            aCols[_nY][08], aCols[_nY][09], aCols[_nY][10], aCols[_nY][11], aCols[_nY][12], aCols[_nY][13], aCols[_nY][14], aCols[_nY][15], aCols[_nY][16],;
                            aCols[_nY][17], aCols[_nY][18], aCols[_nY][19], aCols[_nY][20], aCols[_nY][21], aCols[_nY][22], aCols[_nY][23], aCols[_nY][24], aCols[_nY][25],;
                            aCols[_nY][26], aCols[_nY][27], aCols[_nY][28], aCols[_nY][29], aCols[_nY][30], aCols[_nY][31], aCols[_nY][32], aCols[_nY][33] } )
       Next
Return

Static Function FisGetInit( aFisGet, aFisGetSC5 )
       Local cValid      := ""
       Local cReferencia := ""
       Local nPosIni     := 0
       Local nLen        := 0

       If aFisGet == Nil
          aFisGet := {}
          dbSelectArea("SX3")
          dbSetOrder(1)
          MsSeek("SC6")
          While !Eof().And.X3_ARQUIVO=="SC6"
                cValid := UPPER( X3_VALID + X3_VLDUSER )
                If 'MAFISGET("' $ cValid
                    nPosIni     := AT( 'MAFISGET("', cValid ) + 10
                    nLen        := AT( '")', Substr( cValid, nPosIni, Len( cValid ) - nPosIni ) ) - 1
                    cReferencia := Substr(cValid,nPosIni,nLen)
                    aAdd( aFisGet, { cReferencia, X3_CAMPO, MaFisOrdem( cReferencia ) } )
                EndIf
                If 'MAFISREF("' $ cValid
                   nPosIni     := AT( 'MAFISREF("', cValid ) + 10
                   cReferencia := Substr( cValid, nPosIni, AT( '","MT410",', cValid ) - nPosIni )
                   aAdd( aFisGet, { cReferencia, X3_CAMPO, MaFisOrdem( cReferencia ) } )
                EndIf
                dbSkip()
          EndDo
          aSort( aFisGet, , , { |x,y| x[3] < y[3] } )
       EndIf

       If aFisGetSC5 == Nil
          aFisGetSC5	:= {}
          dbSelectArea("SX3")
          dbSetOrder(1)
          MsSeek("SC5")
          While !Eof().And.X3_ARQUIVO == "SC5"
                cValid := UPPER( X3_VALID + X3_VLDUSER )
                If 'MAFISGET("' $ cValid
                   nPosIni := AT( 'MAFISGET("', cValid ) + 10
                   nLen    := AT( '")', Substr( cValid, nPosIni, Len( cValid ) - nPosIni ) ) - 1
                   cReferencia := Substr( cValid, nPosIni, nLen )
                   aAdd( aFisGetSC5, { cReferencia, X3_CAMPO, MaFisOrdem( cReferencia ) } )
                EndIf
                If 'MAFISREF("' $ cValid
                   nPosIni     := AT( 'MAFISREF("', cValid ) + 10
                   cReferencia := Substr( cValid, nPosIni, AT( '","MT410",', cValid ) - nPosIni )
                   aAdd( aFisGetSC5, { cReferencia, X3_CAMPO, MaFisOrdem( cReferencia ) } )
                EndIf
                dbSkip()
          EndDo
          aSort( aFisGetSC5, , , { |x,y| x[3] < y[3] } )
       EndIf
       MaFisEnd()
Return( .T. )

Static Function fMonHead()
       DbSelectArea("SX3")
       SX3->( DbSetOrder(2) )
       SX3->( DbSeek("C6_ITEM") )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_PRODUTO") )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_DESCRI") )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_TES") )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_CF" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_UM" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_QTDVEN" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_PRCVEN" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_NOTA" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_SERIE" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_CLI" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_LOJA" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_VALOR" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_ENTREG" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_DESCONT" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_LOCAL" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_QTDEMP" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_QTDLIB" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
       SX3->( DbSeek("C6_QTDENT" ) )
       aAdd( aHeader , { SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3 } )
Return
