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
     Local _aArea   := GetArea()

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

       oModel:= MPFormModel():New( "LIBERA", , , { |oModel| FGrava(oModel) },  )
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

       oModel:getModel( 'GRIDPEDIDO' ):SetUseOldGrid( .T. )
       oModel:getModel( 'GRIDVALOR'  ):SetUseOldGrid( .T. )

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

       bHistorico := { |oView| FWMsgRun( , { || fHisPed(oView) }, "Aguarde...", "Processando Histórico" ) }
       bItensPedi := { |oView| FWMsgRun( , { || fItePed(oView) }, "Aguarde...", "Processando Itens"     ) }
       bDadosPedi := { |oView| FWMsgRun( , { || fDadPed(oView) }, "Aguarde...", "Dados do Pedido"       ) }
       bPlanilhaF := { |oView| FWMsgRun( , { || fPlaFin(oView) }, "Aguarde...", "Montando Planilha"     ) }
       bTitAberto := { |oView| FWMsgRun( , { || fTAbFin(oView) }, "Aguarde...", "Consutando Titulos"    ) }
       bTitRecebi := { |oView| FWMsgRun( , { || fTReFin(oView) }, "Aguarde...", "Consutando Titulos"    ) }
       bDadosClie := { |oView| FWMsgRun( , { || fDadCli(oView) }, "Aguarde...", "Dados do Cliente"      ) }
       bObservPed := { |oView| FWMsgRun( , { || fObsPed(oView) }, "Aguarde...", "Observação Pedido"     ) }
       bPesquisaP := { |oView| FWMsgRun( , { || fPesPed(oView) }, "Aguarde...", "Pesquisar"             ) }

       oModel := ModelDef()
       
       oStr1  := MontaCab( 2 )
       oStr2  := MontaCab( 4 )
       oStr3  := MontaCab( 6 )
       
       oStr2:SetProperty( 'CLIENTE' , MVC_VIEW_WIDTH, 350 )
       oStr2:SetProperty( 'CONDICAO', MVC_VIEW_WIDTH, 200 )
       oStr2:SetProperty( 'VENDEDOR', MVC_VIEW_WIDTH, 350 )
       oStr2:SetProperty( 'TRANSPOR', MVC_VIEW_WIDTH, 350 )
       oStr3:SetProperty( 'VALIPI'  , MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'VALSUB'  , MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'VALMAR'  , MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'PERMAR'  , MVC_VIEW_WIDTH, 090 )
       oStr3:SetProperty( 'VALLUC'  , MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'PERLUC'  , MVC_VIEW_WIDTH, 090 )
       oStr3:SetProperty( 'VALCOM'  , MVC_VIEW_WIDTH, 130 )
       oStr3:SetProperty( 'PERCOM'  , MVC_VIEW_WIDTH, 090 )
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
       oView:AddOtherObject( 'RESTRICOES', { | oPanel | fRestri( oPanel ) }, { || } )
       oView:SetOwnerView( 'RESTRICOES', 'BOX_CEN' )
       oView:EnableTitleView( 'RESTRICOES', 'Restrições')
       oView:AddOtherObject( 'OBSERVACOES', { | oPanel | fObserv( oPanel ) }, { || } )
       oView:SetOwnerView( 'OBSERVACOES', 'BOX_DIR' )
       oView:EnableTitleView( 'OBSERVACOES', 'Observações')

       oView:SetViewProperty( 'VIEW_PED', "CHANGELINE", { { | _oView, _cAction, _aParam | fChangePED( _oView, _cAction, _aParam ) } } )

       oView:AddUserButton( "(F2) - Histórico do Pedido"  , 'PEDIDO', { |oView| FWMsgRun( , { || fHisPed(oView) }, "Aguarde...", "Processando histórico" ) } )
       oView:AddUserButton( "(F4) - Itens do Pedido"      , 'PEDIDO', { |oView| FWMsgRun( , { || fItePed(oView) }, "Aguarde...", "Processando itens"     ) } )
       oView:AddUserButton( "(F5) - Dados do Pedido"      , 'PEDIDO', { |oView| FWMsgRun( , { || fDadPed(oView) }, "Aguarde...", "Gerando consulta"      ) } )
       oView:AddUserButton( "(F6) - Planilha Financeira"  , 'PEDIDO', { |oView| FWMsgRun( , { || fPlaFin(oView) }, "Aguarde...", "Montando planilha"     ) } )
       oView:AddUserButton( "(F7) - Titulos em aberto"    , 'PEDIDO', { |oView| FWMsgRun( , { || fTAbFin(oView) }, "Aguarde...", "Consutando titulos"    ) } )
       oView:AddUserButton( "(F8) - Titulos recebidos"    , 'PEDIDO', { |oView| FWMsgRun( , { || fTReFin(oView) }, "Aguarde...", "Consutando titulos"    ) } )
       oView:AddUserButton( "(F9) - Dados do Cliente"     , 'PEDIDO', { |oView| FWMsgRun( , { || fDadCli(oView) }, "Aguarde...", "Consutando cliente"    ) } )
       oView:AddUserButton( "(F10)- Obs. Liberaç. Pedido" , 'PEDIDO', { |oView| FWMsgRun( , { || fObsPed(oView) }, "Aguarde...", "Observação"            ) } )
       oView:AddUserButton( "(F11)- Pesquisar"            , 'PEDIDO', { |oView| FWMsgRun( , { || fPesPed(oView) }, "Aguarde...", "Pesquisar"             ) } )

       //oView:SetCloseOnOk( { || .F. } ) 
       oView:SetCloseOnOk( { || .T. } )
       //VIEW_PED():SetCloseOnOk()-> Nil

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

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
              aAdd( _aCampos, { 'OBSSC5'   , 'M',                      10 ,                       0 } )
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
              aAdd( _aCampos, { 'VALATR'   , 'N',                      20 ,                       2 } )
              aAdd( _aCampos, { 'TOTTIT'   , 'N',                      20 ,                       2 } )
              aAdd( _aCampos, { 'TOTPAB'   , 'N',                      20 ,                       2 } )
              fMontaTMP( _aCampos, 'ITEPED', _oTable2 )
              oStruct:AddTable( 'CABPED', { 'PEDIDO'  }, 'Pedido de Vendas' )
              oStruct:AddField( 'Pedido'       , 'Pedido de Vendas'   , 'PEDIDO'   , 'C', TamSx3("C5_NUM")[1]    ,  , , , ,    , , .T. )
              oStruct:AddField( 'Emissão'      , 'Dt.Emissão'         , 'EMISSAO'  , 'D', TamSx3("C5_EMISSAO")[1],  , , , ,    , , .T. )
              oStruct:AddField( 'Alteração'    , 'Dt.Alteração'       , 'DTALTER'  , 'D', TamSx3("C5_EMISSAO")[1],  , , , ,    , , .T. )
              oStruct:AddField( 'Cliente'      , 'Cliente'            , 'CLIENTE'  , 'C',                      52,  , , , ,    , , .T. )
              oStruct:AddField( 'Cond.Pgto.'   , 'Condição Pgto.'     , 'CONDICAO' , 'C',                      40,  , , , ,    , , .T. )
              oStruct:AddField( 'Boleto?'      , 'Boleto?'            , 'BOLETO'   , 'C',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Vendedor'     , 'Vendedor'           , 'VENDEDOR' , 'C',                      50,  , , , ,    , , .T. )
              oStruct:AddField( 'Transp.'      , 'Transportadora'     , 'TRANSPOR' , 'C',                      50,  , , , ,    , , .T. )
              oStruct:AddField( 'Dt.Ult.Com.'  , 'Dt. Ultima Comp.'   , 'DTULTCOM' , 'D', TamSx3("C5_EMISSAO")[1],  , , , ,    , , .T. )
              oStruct:AddField( 'Dt.Pri.Com.'  , 'Dt.Primeira Com.'   , 'DTPRICOM' , 'D', TamSx3("C5_EMISSAO")[1],  , , , ,    , , .T. )
              oStruct:AddField( 'Risco'        , 'Risco do Cliente'   , 'RISCO'    , 'C',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Ultima Alt.'  , 'Usuário Alteração'  , 'USRALT'   , 'C',                      25,  , , , ,    , , .T. )
              oStruct:AddField( 'Tipo Venda'   , 'Tipo de Venda'      , 'TPVENDA'  , 'C',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Observação'   , 'Observação'         , 'OBSPED'   , 'C',                       6,  , , , ,    , , .T. )
              oStruct:AddField( 'Obs'          , 'Obs.'               , 'OBSSC5'   , 'M',                       6,  , , , ,    , , .T. )
              oStruct:AddField( 'Libera Cad.'  , 'Liberação Cadastro' , 'LIBCAD'   , 'L',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Cad.' , 'Usuário Cadastro'   , 'USRCAD'   , 'C',                      25,  , , , ,    , , .T. )
              oStruct:AddField( 'Libera Ped.'  , 'Liberação Pedido'   , 'LIBPED'   , 'L',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Ped.' , 'Usuário Pedido'     , 'USRPED'   , 'C',                      25,  , , , ,    , , .T. )
              oStruct:AddField( 'Libera Cre.'  , 'Liberação Credito'  , 'LIBCRE'   , 'L',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Cre.' , 'Usuário Credito'    , 'USRCRE'   , 'C',                      25,  , , , ,    , , .T. )
              oStruct:AddField( 'Aprov. Final' , 'Aprovação Final'    , 'LIBDIR'   , 'L',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Final', 'Usuário Apr. Final' , 'USRDIR'   , 'C',                      25,  , , , ,    , , .T. )
              oStruct:AddField( 'Aprovado'     , 'Aprovado'           , 'APROVA'   , 'C',                       1,  , , , ,    , , .T. )
              oStruct:AddField( 'Usuário Apr.' , 'Usuário Aprovador'  , 'USRAPR'   , 'C',                      25,  , , , ,    , , .T. )
              oStruct:AddField( 'Restricao'    , 'Restricao'          , 'RESTRICAO', 'M',                      10,  , , , ,    , , .T. )
              oStruct:AddField( 'Valor Atraso' , 'Valor Atraso'       , 'VALATR'   , 'N',                      15, 2, , , ,    , , .T. )
              oStruct:AddField( 'Valor Titulo' , 'Total Titulo'       , 'TOTTIT'   , 'N',                      15, 2, , , ,    , , .T. )
              oStruct:AddField( 'Total Pedido' , 'Total Pedido Aberto', 'TOTPAB'   , 'N',                      15, 2, , , ,    , , .T. )
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
              oStruct:AddField( 'Margem Bruta R$' , 'Margem Bruta (R$)', 'VALMAR' , 'N' , 18, 2 )
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
              oStruct:AddField( 'VALMAR' , '09', 'Margem Bruta R$' , 'Margem Bruta'     , , 'Get', '@E 999,999.99'    ,   ,    , .F. )
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
       Local _cPedido := ""
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
       If lAcsVis .or. lAcsCad .or. lAcsPed .or. lAcsCre .or. lAcsDir
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
       If lAcsPed
          _cWhere += " OR "
          _cWhere += "( ( SC5.C5_LIBCAD = 'T' ) AND ( SC5.C5_LIBPED = 'F' ) )"
       Endif
       If lAcsCre
          _cWhere += " OR "
          _cWhere += "( ( SC5.C5_LIBCAD = 'T' ) AND ( SC5.C5_LIBCRE = 'F' ) )"
       Endif
       If lAcsDir
          _cWhere += " OR "
          _cWhere += "( ( SC5.C5_LIBCAD = 'T' ) AND ( SC5.C5_LIBDIR = 'F' ) )"
       Endif
       If lAcsVis .and. !lAcsCad .and. !lAcsPed .and. !lAcsCre .and. !lAcsDir //Acesso somente para visualização
          //Cadastro
          _cWhere += "      ( ( ( UPPER( SC5.C5_CAD ) = '" + UPPER( cUsername ) + "' ) " + CHR(13) + CHR(10)
          If Alltrim( UPPER( cUsername ) ) $ Alltrim( UPPER( _cLibRep ) )
             _cWhere += " OR ( SUBSTRING( SC5.C5_CAD, 1, 1 ) IN('0','1','2','3','4','5','6','7','8','9') ) " + CHR(13) + CHR(10)
          Endif 
          _cWhere += " ) "
          _cWhere += "  AND (SC5.C5_LIBCAD = 'F') ) " + CHR(13) + CHR(10)
          //Pedido
          _cWhere += " OR "
          _cWhere += "( ( SC5.C5_LIBCAD = 'T' ) AND ( SC5.C5_LIBPED = 'F' ) )"
          //Crédito
          _cWhere += " OR "
          _cWhere += "( ( SC5.C5_LIBCAD = 'T' ) AND ( SC5.C5_LIBCRE = 'F' ) )"
          //Diretoria
          _cWhere += " OR "
          _cWhere += "( ( SC5.C5_LIBCAD = 'T' ) AND ( SC5.C5_LIBDIR = 'F' ) )"
       Endif
       _cWhere += " ) "
       _cWhere += "%"

       BEGINSQL Alias _cTabSC5
                COLUMN C5_EMISSAO AS DATE
                COLUMN C5_DTALT   AS DATE
                COLUMN A1_ULTCOM  AS DATE
                COLUMN A1_PRICOM  AS DATE
                SELECT SC5.C5_NUM    , SC5.C5_EMISSAO, SC5.C5_DTALT , SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_CONDPAG, SC5.C5_BOLETO, SC5.C5_VEND1 , SC5.C5_TRANSP, SC5.C5_ALT   ,
                       SC5.C5_TIPOVEN, SC5.C5_OBSPED , ISNULL(CAST(CAST(SC5.C5_X_OBSFA AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C5_X_OBSFA,
                       SC5.C5_LIBCAD , SC5.C5_USRCAD , SC5.C5_LIBPED , SC5.C5_USRPED, SC5.C5_LIBCRE, SC5.C5_USRCRE, SC5.C5_LIBDIR, 
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
             aAdd( _aAux  , ( _cTabSC5 )->A1_ULTCOM         )
             aAdd( _aAux  , ( _cTabSC5 )->A1_PRICOM         )
             aAdd( _aAux  , ( _cTabSC5 )->A1_RISCO          )
             aAdd( _aAux  , ( _cTabSC5 )->C5_ALT            )
             aAdd( _aAux  , ( _cTabSC5 )->C5_TIPOVEN        )
             aAdd( _aAux  , ( _cTabSC5 )->C5_OBSPED         )
             aAdd( _aAux  , ( _cTabSC5 )->C5_X_OBSFA        )
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
             aAdd( _aAux  , 0                               )
             aAdd( _aAux  , 0                               )
             aAdd( _aAux  , 0                               )
             aAdd( _aItPed, { 0 , _aAux } )
             aAdd( _aPedidos, { ( _cTabSC5 )->C5_NUM, _aAux, } )
             If Len( _aItPed ) == 1
                _cPedido := ( _cTabSC5 )->C5_NUM
             Endif
             
             DbSelectArea( _cTabSC5 )
             ( _cTabSC5 )->( DbSkip( ) )
       EndDo
       DbSelectArea( _cTabSC5 )
       ( _cTabSC5 )->( DbCloseArea( ) )
       If !Empty( _cPedido )
          FWMsgRun( , { || fCalImp( _cPedido ) }, "Aguarde...", "Carregando informações..." )
       Endif
       
       RestArea( _aArea )
Return _aItPed

Static Function fLValor( _oModel, _lCopy )
       Local aItPed    := {}
       Local aArea     := GetArea()
       Local aAux      := {}
       Local _nY
       Local _nValIpi  := 0
       Local _nValSub  := 0
       Local _cPedido  := Iif( Len( _aPedidos ) > 0, _aPedidos[1][1], "" ) //Somente para carga dos valores do primeiro pedido
       Local _aItePed  := _aPedidos[1][3] //Itens dos pedidos
       
       If ! Empty( _cPedido )
          _nValMer := 0
          _nValICM := 0
          _nValIPI := 0
          _nValCOF := 0
          _nValPIS := 0
          _nValSub := 0
          _nValMar := 0
          _nTotCus := 0
          For _nY := 1 To Len( _aItePed )
              _nValMer += _aItePed[_nY][13]
              _nValICM += _aItePed[_nY][22]
              _nValIpi += _aItePed[_nY][25]
              _nValCOF += _aItePed[_nY][28]
              _nValPIS += _aItePed[_nY][31]
              _nValSub += _aItePed[_nY][32]
              _nValMar += _aItePed[_nY][33]
              _nTotCus += Round( _aItePed[_nY][36], 2 )
          Next
          _nReqLiq := Round( _nValMer - _nValICM - _nValCOF - _nValPIS, 2 )
          DbSelectArea('SC5')
          SC5->( DbSetOrder( 1 ) )
          SC5->( DbSeek( xFilial("SC5") + _cPedido ) )

          aAdd( aAux  , _nValMer )                           //Valor Mercadoria
          aAdd( aAux  , _nValIpi )                           //Valor IPI
          aAdd( aAux  , _nValSub )                           //Valor Subst. Tributária
          aAdd( aAux  , _nValMer + _nValIpi + _nValSub )     //Valor Total
          aAdd( aAux  , _nValMer * ( SC5->C5_LUCRO / 100 ) ) //Valor Lucro
          aAdd( aAux  , SC5->C5_LUCRO  )                     //Perc. Lucro
          aAdd( aAux  , SC5->C5_VLRCOM )                     //Valor Comissão
          aAdd( aAux  , SC5->C5_COMIS1 )                     //Perc. Comissão
          aAdd( aAux  , _nValMar       )                     //Valor Margem
          aAdd( aAux  , Round( ( 1 - ( _nTotCus / _nReqLiq ) ) * 100, 2 ) )  //Percentual Margem
          aAdd( aItPed, { 0 , aAux } )
       Endif

       RestArea( aArea )
Return aItPed

Static Function fChangePED( _oViewPED, _cAction, _aParam )
       Local _lRet      := .t.
       Local _nY
       Local aArea      := GetArea()                 //Será gravado a area atual
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
       Local _nPosRes   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'RESTRICAO'} )

       _cAltera := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosAlt ]
       _cVenda  := Iif( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosTip ] == 'I', 'Interna', 'Externa' )
       _cPriCom := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosPri ]
       _cUltCom := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosUlt ]
       _cRisco  := _oModelPed:aCols[ _oModelPed:nLine ][ _nPosRis ]
       _cObsMsg := MSMM( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosOPe ], , , , 3 )
       _cObserv := AllTrim( U_TiraAcento( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosOC5 ] ) )
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
       _cObserv := AllTrim( U_TiraAcento( _oModelPed:aCols[ _oModelPed:nLine ][ _nPosOC5 ] ) )
       _cRestri := _oModelPed:aCols[_oModelPed:nLine][_nPosRes]
       _cPedido := _oModelPed:aCols[_oModelPed:nLine][1]
       If _aPedidos[aScan( _aPedidos, { |x| x[1] == _cPedido } )][3] == Nil
          FWMsgRun( , { || fCalImp( _cPedido ) }, "Aguarde...", "Carregando informações..." )
       Endif
       _aItePed := _aPedidos[aScan( _aPedidos, { |x| x[1] == _cPedido } )][3]       
       _oAltera:Refresh()
       _oVenda:Refresh()
       _oPriCom:Refresh()
       _oUltCom:Refresh()
       _oRisco:Refresh()
       _oObsMsg:Refresh()
       _oObserv:Refresh()
       //atualizar dados
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
 
       _nValMer := 0
       _nValICM := 0
       _nValIPI := 0
       _nValCOF := 0
       _nValPIS := 0
       _nValSub := 0
       _nValMar := 0
       _nTotCus := 0
       For _nY := 1 To Len( _aItePed )
           _nValMer += _aItePed[_nY][13]
           _nValICM += _aItePed[_nY][22]
           _nValIpi += _aItePed[_nY][25]
           _nValCOF += _aItePed[_nY][28]
           _nValPIS += _aItePed[_nY][31]
           _nValSub += _aItePed[_nY][32]
           _nValMar += _aItePed[_nY][33]
           _nTotCus += Round( _aItePed[_nY][36], 2)
       Next
       _nReqLiq := Round( _nValMer - _nValICM - _nValCOF - _nValPIS, 2 )
       _oModelVal:aCols[1][ 1] := _nValMer
       _oModelVal:aCols[1][ 2] := _nValIPI
       _oModelVal:aCols[1][ 3] := _nValSub
       _oModelVal:aCols[1][ 4] := _nValMer + _nValIPI + _nValSub
       _oModelVal:aCols[1][ 5] := _nValMer * ( SC5->C5_LUCRO / 100 )
       _oModelVal:aCols[1][ 6] := SC5->C5_LUCRO
       _oModelVal:aCols[1][ 7] := SC5->C5_VLRCOM
       _oModelVal:aCols[1][ 8] := SC5->C5_COMIS1
       _oModelVal:aCols[1][ 9] := _nValMar
       _oModelVal:aCols[1][10] := Round( ( 1 - ( _nTotCus / _nReqLiq ) ) * 100, 2 )
       //RestArea( aArea )
       
       //Atualiza informação nos Campos
       _oView:Refresh( 'GRIDPEDIDO' )
       _oView:Refresh( 'GRIDVALOR' )
       _oObsMsg:Refresh()
       _oObserv:Refresh()
       RestArea( aArea )


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

       SetKey( VK_F2 , {||} ) 
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

       U_fHisPed( 3, _oModelPed:aCols[_oModelPed:nLine][1] )

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

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
       Local aArea      := GetArea()                 //Será gravado a area atual
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
       Local _aHeaderNew:= {}
       Local _aColsAux  := {}
       Local _aColsNew  := {}
       Local _nQtdAnt   := 0
       Local _cCondPag  := SubStr( _oModelPed:aCols[_oModelPed:nLine][5], 1, 3 )
       Local _dDiaFat   := dDataBase
       Local _aPrazos   := {}
       Local _aRetPrazo := {}
       Local _nQtdePar  := 0
       Local _nAuxCal   := 0
       Local _nJuros    := GetMV( "MV_JUROS" )
       Local _lProdEst

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

       DbSelectArea('SA4')
       SA4->( DbSetOrder( 1 ) )
       SA4->( DbSeek( xFilial('SA4') + SubStr( _oModelPed:aCols[_oModelPed:nLine][8], 1, 6 ) ) )

       DbSelectArea('SC5')
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial('SC5') + _oModelPed:aCols[_oModelPed:nLine][1] ) )

       DbSelectArea('SA1')
       SA1->( DbSetOrder( 1 ) )
       SA1->( DbSeek( xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI ) )

       _aRetPrazo := fCalcPrazo( _dDiaFat, _cCondPag )
       _aPrazos   := _aRetPrazo[1]
       _nQtdePar  := Len( _aPrazos )

       RegToMemory( 'SC5', .f. )
       Pergunte( _cPerg, .f. )

       //aCols    := {}
       //aHeader  := {}
       _cSeek   := FwxFilial( "SC6" ) + _oModelPed:aCols[_oModelPed:nLine][1]
       _bWhile  := { || C6_FILIAL + C6_NUM }
       _cQuery  := "SELECT * "
       _cQuery  += "FROM " + RetSQLName("SC6") + " SC6 "
       _cQuery  += "WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
       _cQuery  += "  AND SC6.D_E_L_E_T_ = '' "
       _cQuery  += "  AND SC6.C6_NUM = 'ZZZZZZ' "
       _cQuery  += "ORDER BY " + SQLOrder( SC6->( IndexKey() ) )
   
       FillGetDados( 2, 'SC6', 1, _cSeek, _bWhile, { { _bCond, _bAction1, _bAction2, } }, /*_aNoFields*/, /*_aYesFields*/, /*_lOnlyYes*/, _cQuery, /*_bMontCols*/, .F., _aHeaderAux, _aColsAux, , , , "SC6" )
       _nQtdAnt := Len( _aHeaderAux )
       aAdd( _aHeaderAux, { 'Margem Bruta(R$)', 'C6_X_VMAR', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Margem(%)' , 'C6_X_PMAR', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Bas.ICMS'  , 'C6_X_BICM', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Alq.ICMS'  , 'C6_X_AICM', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Val.ICMS'  , 'C6_X_VICM', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Bas.IPI'   , 'C6_X_BIPI', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Alq.IPI'   , 'C6_X_AIPI', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Val.IPI'   , 'C6_X_VIPI', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Bas.PIS'   , 'C6_X_BPIS', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Alq.PIS'   , 'C6_X_APIS', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Val.PIS'   , 'C6_X_VPIS', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Bas.COF.'  , 'C6_X_BCOF', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Alq.COF.'  , 'C6_X_ACOF', '@E 999.99'        ,  6, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Val.COF.'  , 'C6_X_VCOF', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Val.SUB'   , 'C6_X_VIRE', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Val.SUB'   , 'C6_X_VIRE', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'A-Val.Hoje', 'C6_X_VHOJ', '@E 99,999.99'     ,  9, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'B-Par.Sim.', 'C6_X_PARS', '@E 99.99'         ,  5, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'C-Cus.Rep.', 'C6_X_CUSR', '@E 99,999.99'     ,  5, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'D-Luc.Item', 'C6_X_VLIT', '@E 99,999.9999'   , 11, 4, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Prod. Est.', 'C6_X_PRES', '@!'               ,  3, 0, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'C', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'E-Luc.Min.', 'C6_X_LMIN', '@E 99,999.9999'   , 11, 4, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )
       aAdd( _aHeaderAux, { 'Val.Prod.' , 'C6_X_VLPR', '@E 999,999,999.99', 14, 2, '', 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ', 'N', '      ', ' ' } )

       //Ajuste para mostrar somente campos necessários e ordena-los
       _aAuxH := {}
       For _nY := 1 To Len( _aHeaderAux )
           If Alltrim( _aHeaderAux[_nY][2] ) $ 'C6_ITEM.C6_PRODUTO.C6_DESCRI.C6_QTDVEN.C6_PRCVEN.C6_XPRUNIT.C6_ULPRECO.C6_VALOR.C6_COMIS1.C6_ENTREGA.C6_LUCRESP.'+;
                                            'C6_VLRLUCR.C6_X_VICM.C6_X_VIPI.C6_X_VPIS.C6_X_VCOF.C6_X_VMAR.C6_X_PMAR.C6_X_VIRE.C6_X_VHOJ.C6_X_PARS.C6_X_VLIT'+;
                                            'C6_X_CUSR.C6_X_PRES.C6_X_LMIN.C6_X_VLPR'
              If Alltrim( _aHeaderAux[_ny][2] ) $ 'C6_ITEM'
                 aAdd( _aAuxH, { '01', _aHeaderAux[_nY] } )
              ElseIf Alltrim( _aHeaderAux[_ny][2] ) $ 'C6_PRODUTO'
                     aAdd( _aAuxH, { '02', _aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_DESCRI'
                     aAdd( _aAuxH, { '03',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_QTDVEN'
                     aAdd( _aAuxH, { '04',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_PRCVEN'
                     aAdd( _aAuxH, { '05',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_VALOR'
                     aAdd( _aAuxH, { '06',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_XPRUNIT'
                     aAdd( _aAuxH, { '07',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_ULPRECO'
                     aAdd( _aAuxH, { '08',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_COMIS1'
                     aAdd( _aAuxH, { '11',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VMAR'
                     aAdd( _aAuxH, { '12',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_PMAR'
                     aAdd( _aAuxH, { '13',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VICM'
                     aAdd( _aAuxH, { '16',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VIPI'
                     aAdd( _aAuxH, { '19',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VPIS'
                     aAdd( _aAuxH, { '22',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VCOF'
                     aAdd( _aAuxH, { '25',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VIRE'
                     aAdd( _aAuxH, { '28',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VHOJ'
                     aAdd( _aAuxH, { '29',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_PARS'
                     aAdd( _aAuxH, { '30',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_CUSR'
                     aAdd( _aAuxH, { '31',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VLIT'
                     aAdd( _aAuxH, { '32',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_PRES'
                     aAdd( _aAuxH, { '33',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_LMIN'
                     aAdd( _aAuxH, { '34',_aHeaderAux[_nY] } )
              ElseIf Alltrim(_aHeaderAux[_ny][2] ) $ 'C6_X_VLPR'
                     aAdd( _aAuxH, { '35',_aHeaderAux[_nY] } )
              Else
                 aAdd( _aAuxH, { '99',_aHeaderAux[_nY] } )
              Endif
           Endif
       Next
       aSort( _aAuxH, , , { |x,y| x[1] < y[1] } )
       For _nY := 1 To Len( _aAuxH )
           aAdd( _aHeaderNew, _aAuxH[_nY][2] )
       Next
 
       _nColImp  := aScan( _aPedidos, { |x| x[1] == _cPedido } )
       _aColImp  := _aPedidos[_nColImp][3]

       _nPosProd := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_PRODUTO" } )
       _nPosQuan := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_QTDVEN"  } )
       _nPosItem := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_ITEM"    } )
       _nPosUPrc := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_ULPRECO" } )
       _nPosTPrc := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_XPRUNIT" } )
       _nPosValo := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_VALOR"   } )
       _nPosVHoj := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_VHOJ"  } )
       _nPosVIcm := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_VICM"  } )
       _nPosVPis := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_VPIS"  } )
       _nPosVCof := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_VCOF"  } )
       _nPosParS := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_PARS"  } )
       _nPosCusR := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_CUSR"  } )
       _nPosVLIT := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_VLIT"  } )
       _nPosPRES := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_PRES"  } )
       _nPosLMin := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_LMIN"  } )
       _nPosVLPr := aScan( _aHeaderNew, { |x| Alltrim( x[2] ) == "C6_X_VLPR"  } )

       DbSelectArea("SB1")
       SB1->( DbSetOrder( 1 ) )
       DbSelectArea("SB5")
       SB5->( DbSetOrder( 1 ) )

       For _nY := 1 To Len( _aColsAux )
           aAdd( _aColsNew,  Array( Len( _aHeaderNew ) + 1 ) )
           For _nX := 1 To Len( _aHeaderNew )
               _nPosHead := aScan( _aHeaderAux, { |x| Alltrim( x[2] ) == Alltrim( _aHeaderNew[_nX][2] ) } )
               If _nPosHead < _nQtdAnt
                  _aColsNew[_nY][_nX] := _aColsAux[_nY][_nPosHead]
               Else
                  _nPosIte := aScan( _aColImp, { |x| x[35] == _cPedido + _aColsNew[_nY][_nPosItem] } )
                  If Alltrim(_aHeaderAux[_nPosHead][2] ) == 'C6_X_VMAR'
                         _aColsNew[_nY][_nX] := _aColImp[_nPosIte][33]
                  ElseIf Alltrim(_aHeaderAux[_nPosHead][2] ) == 'C6_X_PMAR'
                         _aColsNew[_nY][_nX] := _aColImp[_nPosIte][34] 
                  ElseIf Alltrim(_aHeaderAux[_nPosHead][2] ) == 'C6_X_VICM'
                         _aColsNew[_nY][_nX] := _aColImp[_nPosIte][22]
                  ElseIf Alltrim(_aHeaderAux[_nPosHead][2] ) == 'C6_X_VIPI'
                         _aColsNew[_nY][_nX] := _aColImp[_nPosIte][25]
                  ElseIf Alltrim(_aHeaderAux[_nPosHead][2] ) == 'C6_X_VPIS'
                         _aColsNew[_nY][_nX] := _aColImp[_nPosIte][28]
                  ElseIf Alltrim(_aHeaderAux[_nPosHead][2] ) == 'C6_X_VCOF'
                         _aColsNew[_nY][_nX] := _aColImp[_nPosIte][31]
                  ElseIf Alltrim(_aHeaderAux[_nPosHead][2] ) == 'C6_X_VIRE'
                         _aColsNew[_nY][_nX] := _aColImp[_nPosIte][31]
                  Endif
               Endif
           Next
           SB1->( DbSeek( xFilial( "SB1" ) + _aColsNew[_nY][ _nPosProd] ) )
           SB5->( DbSeek( xFilial( "SB5" ) + _aColsNew[_nY][ _nPosProd] ) )

           _aColsNew[_nY][_nPosUPrc]                := U_VERULPRECO( M->C5_CLIENTE, _aColsNew[_nY][ _nPosProd], M->C5_LOJACLI )
           _aColsNew[_nY][_nPosTPrc]                := IIF( SB1->B1_ESTOQUE <> "S", SB5->B5_PRV2, SB1->B1_PRV1 )
           _aColsNew[_nY][ Len( _aHeaderNew ) + 1 ] := .F.
           //Calculo da retirada dos juros (adicionado no simulado do preço) para trazer o valor presente
           _nAuxCal := 0
           For _nX := 1 To Len( _aPrazos )
               _nAuxCal += ( _aColsNew[_nY][_nPosValo] * _aPrazos[_nX][ 2 ] ) / ( ( 1 + ( _nJuros / 100 ) ) ^ ( ( 12 * _aPrazos[_nX][1] ) / 365 ) )
           Next
           _aColsNew[_nY][_nPosVHoj] := Round( _nAuxCal, 2 ) //Calculo do Valor de vendas hoje
           _aColsNew[_nY][_nPosParS] := SB1->B1_PERINT       //Parametros do ultimo simulado que atualizou a Tabela de Preços
           _aColsNew[_nY][_nPosCusR] := SB1->B1_CUSTOR       //Custo de Reposição da ultima atualização da Tabela de preço
           _aColsNew[_nY][_nPosVLIT] := _aColsNew[_nY][_nPosVHoj] - ( _aColsNew[_nY][_nPosVALO] * ( _aColsNew[_nY][_nPosParS] / 100 ) ) - ( _aColsNew[_nY][_nPosCusR] * _aColsNew[_nY][_nPosQuan] ) - _aColsNew[_nY][_nPosVIcm] - _aColsNew[_nY][_nPosVPis] - _aColsNew[_nY][_nPosVCof]
           _lProdEst := Iif( SB1->B1_ESTOQUE == 'S', .t., .f. )
           _aColsNew[_nY][_nPosPRES] := Iif( _lProdEst, 'Sim', 'Não' )
           _nAuxLucr := Iif( _lProdEst, SB1->B1_LCRMIN, SB1->B1_LUCROM2 )
           
           _nVlrItem := _aColsNew[_nY][_nPosVALO]
       Next

       oModal := FWDialogModal():New()
       oModal :SetEscClose( .F. )
       oModal :setTitle( "Itens do pedido de Vendas" )
       oModal :setSize( 260, 600 )
       oModal :createDialog()

       aAdd( _aButtons, { "", 'Cancela' , {|| _nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )
       oModal :addButtons( _aButtons )

       oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
       oContainer :Align := CONTROL_ALIGN_ALLCLIENT

       _oGetD := MsNewGetDados():New( 004, 004, 214, 594, 0, /*_cLinhaOk*/, /*_cTudoOk*/, "", /*_aAlter*/, 1, 999, /*_cFieldOk*/, /*_cSuperDel*/, /*_cDelOK*/, oContainer, _aHeaderNew, _aColsNew )
       oModal:Activate()

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

       RestArea( aArea )
Return

Static Function fBusCus( _cProduto )
       Local _dDatFec := GETMV( "MV_ULMES" )
       Local _nCusPro := 0

       DbSelectArea("Z99")
       DbSetOrder(1)
       If DbSeek( xFilial('Z99') + _cProduto + dToS( _dDatFec ) )
          _nCusPro := ( Z99->Z99_GGFCON + Z99->Z99_MOCONS + Z99->Z99_REQCON )
       Endif
Return _nCusPro

/*/{Protheus.doc} fDadPed
Consulta pedido de vendas
@type function
@version 2021.10
@author Luís Gustavo de Souza
@since 10/10/2021
@param oView, object, objeto da View
/*/
Static Function fDadPed(oView)
       Local aArea       := GetArea()                 //Será gravado a area atual
       Local _oMdl       := FwModelActive()
       Local _oModelPed  := _oMdl:GetModel( 'GRIDPEDIDO' )
       Private Inclui    := .F.                       //defino que a inclusão é falsa
       Private Altera    := .T.                       //defino que a alteração é verdadeira
       Private nOpca     := 1                         //obrigatoriamente passo a variavel nOpca com o conteudo 1
       Private cCadastro := "Pedido de Vendas"        //obrigatoriamente preciso definir com private a variável cCadastro
       Private aRotina   := {}                        //obrigatoriamente preciso definir a variavel aRotina como private

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

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
       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )
       _oView:Refresh( 'GRIDPEDIDO' )
       _oView:Refresh( 'GRIDVALOR' )

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
       Local aArea      := GetArea()                 //Será gravado a area atual
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

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

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

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

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

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

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

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

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
       Local aArea      := GetArea()                 //Sera gravado a area atual
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

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

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

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

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

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

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

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

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
       _cUsrDir := _oModelPed:aCols[_oModelPed:nLine][_nPosUDi]
       _lLibRec := _oModelPed:aCols[_oModelPed:nLine][_nPosLAp]
       _cUsrRec := _oModelPed:aCols[_oModelPed:nLine][_nPosUAp]

      // Alterado função " Checkbox por Say " para inibir ações de Aprovação Comercial
       //@ 015,005 CHECKBOX _oLibCad VAR _lLibCad PROMPT OemToAnsi("Cadastro:")  SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 015,005 SAY _oLibCad VAR _lLibCad PROMPT OemToAnsi("*Cadastro:")  SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 015,070 SAY      _oUsrCad VAR _cUsrCad PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       //@ 035,005 CHECKBOX _oLibPed VAR _lLibPed PROMPT OemToAnsi("*Vendas:")    SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 035,005 SAY _oLibPed VAR _lLibPed PROMPT OemToAnsi("*Vendas:")    SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 035,070 SAY      _oUsrPed VAR _cUsrPed PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       //@ 055,005 CHECKBOX _oLibCre VAR _lLibCre PROMPT OemToAnsi("*Crédito:")   SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 055,005 SAY _oLibCre VAR _lLibCre PROMPT OemToAnsi("*Crédito:")   SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 055,070 SAY      _oUsrCre VAR _cUsrCre PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       //@ 075,005 CHECKBOX _oLibDir VAR _lLibDir PROMPT OemToAnsi("*Apr Final:") SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 075,005 SAY _oLibDir VAR _lLibDir PROMPT OemToAnsi("*Apr Final:") SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 075,070 SAY      _oUsrDir VAR _cUsrDir PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       //@ 095,005 CHECKBOX _oLibRec VAR _lLibRec PROMPT OemToAnsi("*Recusar:")   SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 095,005 SAY _oLibRec VAR _lLibRec PROMPT OemToAnsi("*Recusar:")   SIZE 060,10 FONT _oFont4 PIXEL OF _oPanel
       @ 095,070 SAY      _oUsrRec VAR _cUsrRec PICTURE '@!' COLOR CLR_BLUE    SIZE 130,09  PIXEL OF _oPanel FONT _oFont4
       
       //Comentado para inibir ações de Aprovação 
       //_oLibCad:bLClicked := { || fLibCad() } ; _oLibPed:bLClicked := { || fLibPed() }
       //_oLibCre:bLClicked := { || fLibCre() } ; _oLibDir:bLClicked := { || fLibDir() }
       //_oLibRec:bLClicked := { || fMRCRec() }
       
       _oLibCad:bWhen := { || .F. }
       _oLibPed:bWhen := { || .F. }
       _oLibCre:bWhen := { || .F. }
       _oLibDir:bWhen := { || .F. }
       _oLibRec:bWhen := { || .F. }

       If lAcsCad
          _oLibCad:bWhen := { || .T. }
       Endif
       If lAcsPed
          _oLibPed:bWhen := { || .T. }
       Endif
       If lAcsCre
          _oLibCre:bWhen := { || .T. }
       Endif
       If lAcsDir
          _oLibDir:bWhen := { || .T. }
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
       Local _nPosVat   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'VALATR' } )
       Local _nPosTTI   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'TOTTIT' } )
       Local _nPosTAB   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'TOTPAB' } )

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
      _oModelPed:aCols[_oModelPed:nline][_nPosVat] := _nTotAtr
      _oModelPed:aCols[_oModelPed:nline][_nPosTTI] := _nTotTit
      _oModelPed:aCols[_oModelPed:nline][_nPosTAB] := _nTotPAb
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
       _cObserv := Trim( U_TiraAcento( _oModelPed:aCols[_oModelPed:nLine][_nPosOC5] ) )

       @ 015,005 GET _oObsMsg VAR _cObsMsg MEMO READONLY SIZE 225,045 PIXEL OF _oPanel
       @ 060,005 GET _oObserv VAR _cObserv MEMO READONLY SIZE 225,045 PIXEL OF _oPanel
      
      _oObsMsg:Refresh()
      _oObserv:Refresh()
Return .T.

/*/{Protheus.doc} fLibCad
Função que marca e desmarca liberação do cadastro do pedido de vendas
@type function
@version  v2022.01
@author Luis Gustavo de Souza
@since 25/01/2022
/*/
Static Function fLibCad()
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _oModelVal := _oModel:GetModel( 'GRIDVALOR' )
       Local _nPosPed   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'PEDIDO'   } )
       Local _nPosLCa   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBCAD'   } )
       Local _nPosUCa   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRCAD'   } )
       Local _nPosVat   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'VALATR'   } )
       Local _nPosTTI   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'TOTTIT'   } )
       Local _nPosTAB   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'TOTPAB'   } )
       Local _nPosCon   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'CONDICAO' } )
       Local _nPosCli   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'CLIENTE'  } )
       Local _nValTOT   := aScan( _oModelVal:aHeader, { |x| Alltrim( x[2] ) == 'VALTOT'   } )
       Local _nPosLCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBCRE'   } )
       Local _nPosUCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRCRE'   } )
       Local _nPosLDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBDIR'   } )
       Local _nPosUDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRDIR'   } )
       Local _nPosOPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'OBSPED'   } )
       //Local _nPosOC5   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'OBSSC5'   } )
       Local _ZPPAR0018 := GetMV( "ZP_PAR0018" ) //Habilita/desabilita regra para aprovacao automatica de credito e diretoria/Apr.Final na analise de pedidos.
       Local _ZPPAR0019 := GetMV( "ZP_PAR0019" ) //Valor limite para liberacao automatica de credito e diretoria/Apr.Final.
       Local _lAutCre   := .f.
       Local _lAutDir   := .f.

       _lLibCad := Iif( ValType( _lLibCad ) == 'L', _lLibCad, Iif( _lLibCad $ 'F', .F., .T. ) )

       If _lLibCad
          _cUsrCad := cUsername
          _oModelPed:aCols[_oModelPed:nLine][_nPosLCa] := .T.
          _oModelPed:aCols[_oModelPed:nLine][_nPosUCa] := cUsername
          //Grava no pedido de Vendas
          DbSelectArea( 'SC5' )
          SC5->( DbSetOrder( 1 ) )
          If SC5->( DbSeek( xFilial( 'SC5' ) + _oModelPed:aCols[_oModelPed:nLine][_nPosPed] ) )
             RecLock( 'SC5', .F. )
                SC5->C5_USRCAD := cUsername
                SC5->C5_LIBCAD := 'T'
             SC5->( MsUnLock() )
             //Grava o Log de Liberação
             RecLock("ZZB", .t.)
                ZZB->ZZB_FILIAL := xFilial("ZZB")
                ZZB->ZZB_PEDIDO := SC5->C5_NUM
                ZZB->ZZB_IDLOG  := 'LCA'
                ZZB->ZZB_USRLOG := cUsername
                ZZB->ZZB_DATLOG := dDataBase
                ZZB->ZZB_HORLOG := Time()
             ZZB->( MsUnLock() )

             //Regra para liberação automática de Crédito
             /********************************************************************************************************************/
             //** ANALISE DE CREDITO PARA LIBERAÇÃO AUTOMÁTICA - Criada e solicitada por Sérgio Duó em 08/2020.
             //** 1º) SEM TITULOS EM ATRASO
             //** 2º) CONDIÇÃO DE PAGAMENTO DIFERENTE DE 001 (A VISTA)
             //** 3º) SALDO DE TITULOS EM ABERTO (SE1) + SALDO ATUAL + PEDIDO ATUAL (VALORES COM IMPOSTOS) < = A1_LC  DO CLIENTE
             //** 4º) PEDIDOS ATÉ R$ 100.000,00 (LIBERA CRÉDITO + LIBERA DIRETORIA/APR.FINAL) >= R$ 100.000,00 (LIBERA CRÉDITO)
             /********************************************************************************************************************/
             DbSelectArea('SA1')
             SA1->( DbSetOrder(1) )
             SA1->( DbSeek( xFilial('SA1') + SubString( _oModelPed:aCols[_oModelPed:nLine][_nPosCli], 1, 6 ) + SubString( _oModelPed:aCols[_oModelPed:nLine][_nPosCli], 8, 2 ) ) )
             If _ZPPAR0018 //Habilita utilização da regra
                _cRegra := ""
                _cRegra += "Pedido: " + _oModelPed:aCols[_oModelPed:nLine][_nPosPed] + CHR(13) + CHR(10)
                _cIncon := ""
                If _oModelPed:aCols[_oModelPed:nLine][_nPosVat] <= 0 //Regra 1 - Titulos em atraso
                   _cRegra += "Valor atraso em R$ " + DTOC( dDataBase ) + ": " + Transform( _oModelPed:aCols[_oModelPed:nLine][_nPosVat], "@E 999,999,999.99" ) + " OK" + CHR(13) + CHR(10)
                   If SubStr( _oModelPed:aCols[_oModelPed:nLine][_nPosCon], 1, 3 ) <> '001' //Regra 2 - Condição de pagamento a vista
                      _cRegra += "Condição: " + Alltrim( _oModelPed:aCols[_oModelPed:nLine][_nPosCon] ) + " OK" + CHR(13) + CHR(10)
                      If ( _oModelPed:aCols[_oModelPed:nLine][_nPosTTI] + _oModelPed:aCols[_oModelPed:nLine][_nPosTAB] + _oModelVal:aCols[_oModelVal:nLine][_nValTOT] ) < SA1->A1_LC //Regra 3 - ( TITULOS EM ABERTO + SALDO ATUAL + PEDIDO ATUAL ) < LIMITE CREDITO
                         _cRegra += "Titulos: R$ " + Alltrim( Transform( _oModelPed:aCols[_oModelPed:nLine][_nPosTTI], "@E 999,999,999.99" ) ) + " + Ped. em Aberto: R$ " + Alltrim( Transform( _oModelPed:aCols[_oModelPed:nLine][_nPosTAB], "@E 999,999,999.99" ) ) + " + Ped. Atual: R$ " + Alltrim( Transform( _oModelVal:aCols[_oModelVal:nLine][_nValTOT], "@E 999,999,999.99" ) ) +;
                                    " = " + Alltrim( Transform( ( _oModelPed:aCols[_oModelPed:nLine][_nPosTTI] + _oModelPed:aCols[_oModelPed:nLine][_nPosTAB] + _oModelVal:aCols[_oModelVal:nLine][_nValTOT] ), "@E 999,999,999.99" ) ) + " OK" + CHR(13) + CHR(10)
                         _cRegra += "Limite de Crédito: R$ " + Alltrim( Transform( ( SA1->A1_LC ), "@E 999,999,999.99" ) ) + CHR(13) + CHR(10)
                         If _oModelVal:aCols[_oModelVal:nLine][_nValTOT] <= _ZPPAR0019
                            _cRegra += "Valor do Pedido: R$ " + Alltrim( Transform( ( _oModelVal:aCols[_oModelVal:nLine][_nValTOT] ), "@E 999,999,999.99" ) ) + " OK" + CHR(13) + CHR(10)
                            _cRegra += "LIBERADO AUTOMATICO CREDITO E APROV. FINAL"
                            _lAutCre := .t. //Liberação do crédito
                            _lAutDir := .t. //Liberação da diretoria/Apr.Final
                         else
                            _cRegra += "Valor do Pedido: R$ " + Alltrim( Transform( ( _oModelVal:aCols[_oModelVal:nLine][_nValTOT] ), "@E 999,999,999.99" ) ) + " OK" + CHR(13) + CHR(10)
                            _cRegra += "LIBERADO AUTOMATICO CREDITO"
                            _lAutCre := .t. //Liberação do crédito
                         Endif
                      Else
                         _cRegra += "Titulos: R$ " + Alltrim( Transform( _oModelPed:aCols[_oModelPed:nLine][_nPosTTI], "@E 999,999,999.99" ) ) + " + Ped. em Aberto: R$ " + Alltrim( Transform( _oModelPed:aCols[_oModelPed:nLine][_nPosTAB], "@E 999,999,999.99" ) ) + " + Ped. Atual: R$ " + Alltrim( Transform( _oModelVal:aCols[_oModelVal:nLine][_nValTOT], "@E 999,999,999.99" ) ) +;
                                    " = R$ " + Alltrim( Transform( ( _oModelPed:aCols[_oModelPed:nLine][_nPosTTI] + _oModelPed:aCols[_oModelPed:nLine][_nPosTAB] + _oModelVal:aCols[_oModelVal:nLine][_nValTOT] ), "@E 999,999,999.99" ) ) + " NÃO LIBERADO" + CHR(13) + CHR(10)
                         _cRegra += "Limite de Crédito: R$ " + Alltrim( Transform( ( SA1->A1_LC ), "@E 999,999,999.99" ) ) + CHR(13) + CHR(10)
                         _cIncon := "INCONSISTÊNCIA: LIMITE DE CRÉDITO"
                      Endif
                   else
                      _cRegra += "Condição: " + Alltrim( _oModelPed:aCols[_oModelPed:nLine][_nPosCon] ) + " NÃO LIBERADO"
                      _cIncon := "INCONSISTÊNCIA: CONDIÇÃO DE PAGAMENTO A VISTA"
                   Endif
                else
                   _cRegra += "Valor atraso em R$ " + DTOC( dDataBase ) + ": " + Transform( _oModelPed:aCols[_oModelPed:nLine][_nPosVat], "@E 999,999,999.99" ) + " NÃO LIBERADO" + CHR(13) + CHR(10)
                   _cIncon := "INCONSISTÊNCIA: TITULOS EM ATRASO"
                Endif
                _cNomArq := xFilial("SC5") + '_' + _oModelPed:aCols[_oModelPed:nLine][_nPosPed] + "_" + Iif( _lAutCre .and. _lAutDir, 'LI', Iif( _lAutCre .and. !_lAutDir, 'CR', 'BL' ) ) + '_' + StrTran( Time(), ":", "" )
                MEMOWRITE( "\dirdoc\comercial\libped\" + _cNomArq + '.log', _cRegra )

                /**** LIBERAÇÃO DE CRÉDITO / DIRETORIA-Apr.Final AUTOMÁTICOS ****/
                If !_lAutCre .or. !_lAutDir
                  _cObsAtu := (AllTrim(SC5->C5_X_OBSFA))
                   If !( 'AGUARDANDO LIBERAÇÃO' $ _cObsAtu )
                      _cObsAtu += Iif( Empty(_cObsAtu), '', CHR(13) + CHR(10) )
                      _cObsAtu += Iif( Empty(_cObsAtu), '', CHR(13) + CHR(10) )
                      _cObsAtu += 'AGUARDANDO LIBERAÇÃO DE VENDA'
                      RecLock( 'SC5', .F. )
                      (SC5->C5_X_OBSFA) := AllTrim(_cObsAtu)
                      SC5->( MsUnLock() )                      
                      //_oModelPed:aCols[_oModelPed:nLine][_nPosOC5] := _nCodMsg
                      //_nCodMsg:= Trim( U_TiraAcento( _oModelPed:aCols[_oModelPed:nLine][_nPosOC5] ) )
                      //_oModelPed:aCols[_oModelPed:nLine][_nPosOC5] := _nCodMsg                      
                   Endif
                   If !Empty( Alltrim( _cIncon ) )
                      _cObsLib := DTOC(dDataBase) + '-' + Time() + ': ' + _cIncon
                      _cObsLib += Iif( Empty( Alltrim( MSMM( SC5->C5_OBSPED ) ) ), '', CHR(13) + CHR(10) + Alltrim( MSMM( SC5->C5_OBSPED ) ) )
                      _nCodMsg := MSMM( SC5->C5_OBSPED,      , , _cObsLib   , 1, , , "SC5", 'C5_OBSPED' )
                      _oModelPed:aCols[_oModelPed:nLine][_nPosOPe] := _nCodMsg
                      _cObsMsg := _cObsLib
                   Endif
                   //_cObsAtu:Refresh()
                   //_cObserv:Refresh()
                Endif
                //Liberação Automatica de Crédito pela regra.
                If _lAutCre
                   _lLibCre := .T.
                   _cUsrCre := 'BR_Automatico'                   
                   _oModelPed:aCols[_oModelPed:nLine][_nPosLCr] := .T.
                   _oModelPed:aCols[_oModelPed:nLine][_nPosUCr] := 'BR_Automatico'
                   RecLock( 'SC5', .F. )
                      SC5->C5_LIBCRE := 'T'
                      SC5->C5_USRCRE := 'BR_Automatico'                      
                   SC5->( MsUnLock() )
                   //Grava o Log de Liberação de Crédito
                   RecLock("ZZB", .t.)
                      ZZB->ZZB_FILIAL := xFilial("ZZB")
                      ZZB->ZZB_PEDIDO := SC5->C5_NUM
                      ZZB->ZZB_IDLOG  := 'LCR'
                      ZZB->ZZB_USRLOG := 'BR_Automatico'
                      ZZB->ZZB_DATLOG := dDataBase
                      ZZB->ZZB_HORLOG := Time()
                   ZZB->( MsUnLock() )
                Endif
                //Liberação Automatica de Diretoria/Apr.Final pela regra.
                //CONFORME ANOTAÇÃO DO PROGRAMA ANTIGO BRFATX01.PRW
                //(04/08/2017)Chamado 007850 => Kelly pediu para liberar automaticamente pedidos abaixo de R$ 50 mil com lucratividade maior ou igual a 6%
                If _lAutCre .AND. !( SC5->C5_LIBDIR == "T" ) .AND. SC5->C5_VLRDUP < 50000 .AND. SC5->C5_LUCRO >= 6.0
                   _cUsrDir := 'BR_Automatico'
                   _lLibDir := .T.
                   _oModelPed:aCols[_oModelPed:nLine][_nPosLDi] := .T.
                   _oModelPed:aCols[_oModelPed:nLine][_nPosUDi] := 'BR_Automatico'
                   RecLock( 'SC5', .F. )
                      SC5->C5_USRDIR := 'BR_Automatico'
                      SC5->C5_LIBDIR := 'T'
                   SC5->( MsUnLock() )
                   //Grava o Log de Liberação de Diretoria/Apr.Final
                   RecLock("ZZB", .t.)
                      ZZB->ZZB_FILIAL := xFilial("ZZB")
                      ZZB->ZZB_PEDIDO := SC5->C5_NUM
                      ZZB->ZZB_IDLOG  := 'LDI'
                      ZZB->ZZB_USRLOG := 'BR_Automatico'
                      ZZB->ZZB_DATLOG := dDataBase
                      ZZB->ZZB_HORLOG := Time()
                   MsUnLock()
                Endif
             Endif
             //Verificação final se todos as etapas estão aprovadas
             fLibera()
          Endif
       Else //Desmarca em tempo de execução
          _cUsrCad := space(25)
          _oModelPed:aCols[_oModelPed:nLine][_nPosLCa] := .F.
          _oModelPed:aCols[_oModelPed:nLine][_nPosUCa] := space(25)
          If Alltrim( _oModelPed:aCols[_oModelPed:nLine][_nPosUCr] ) == 'BR_Automatico' .and. _oModelPed:aCols[_oModelPed:nLine][_nPosLCr] == .T.
             _oModelPed:aCols[_oModelPed:nLine][_nPosLCr] := .F.
             _oModelPed:aCols[_oModelPed:nLine][_nPosUCr] := space(25)
          Endif
          If Alltrim( _oModelPed:aCols[_oModelPed:nLine][_nPosUDi] ) == 'BR_Automatico' .and. _oModelPed:aCols[_oModelPed:nLine][_nPosLDi] == .T.
             _oModelPed:aCols[_oModelPed:nLine][_nPosLDi] := .F.
             _oModelPed:aCols[_oModelPed:nLine][_nPosUDi] := space(25)
          Endif
          _lEstCre := .F.
          _lEstDir := .F.
          DbSelectArea( 'SC5' )
          SC5->( DbSetOrder( 1 ) )
          If SC5->( DbSeek( xFilial( 'SC5' ) +  _oModelPed:aCols[_oModelPed:nLine][_nPosPed] ) )
             fCancela() //Antes de retornar o status verifica se o pedido foi aprovado
             RecLock( 'SC5', .F. )
                SC5->C5_USRCAD := space(25)
                SC5->C5_LIBCAD := 'F'
                If Alltrim( SC5->C5_USRCRE ) == 'BR_Automatico' .and. SC5->C5_LIBCRE == 'T'
                   SC5->C5_USRCRE := space(25)
                   SC5->C5_LIBCRE := 'F'
                   _lEstCre := .T.
                Endif
                If Alltrim( SC5->C5_USRDIR ) == 'BR_Automatico' .and. SC5->C5_LIBDIR == 'T'
                   SC5->C5_USRDIR := space(25)
                   SC5->C5_LIBDIR := 'F'
                   _lEstDir := .T.
                Endif
             SC5->( MsUnLock() )
             DbSelectArea( 'ZZB' )
             ZZB->( DbSetOrder( 1 ) )
             If ZZB->( DbSeek( xFilial( 'ZZB' ) + SC5->C5_NUM ) )
                While !Eof() .and. ZZB->ZZB_PEDIDO == SC5->C5_NUM
                      If ZZB->ZZB_IDLOG == 'LCA' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == Alltrim( cUsername )
                         RecLock( 'ZZB', .F. )
                            DBDelete()
                         ZZB->( MsUnLock( ) )
                      Endif
                      If _lEstCre
                         If ZZB->ZZB_IDLOG == 'LCR' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == 'BR_Automatico' 
                            RecLock( 'ZZB', .F. )
                               DBDelete()
                            ZZB->( MsUnLock( ) )
                         Endif
                      EndIf
                      If _lEstDir
                         If ZZB->ZZB_IDLOG == 'LDI' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == 'BR_Automatico'
                            RecLock( 'ZZB', .F. )
                               DBDelete()
                            ZZB->( MsUnLock( ) )
                         Endif 
                      Endif
                      ZZB->( DbSkip( ) )
                EndDo
             Endif
          Endif
          If _lEstCre
             _cUsrCre := space(25)
             _lLibCre := .f.
          Endif
          If _lEstDir
             _cUsrDir := space(25)
             _lLibDir := .f.
          Endif
       Endif
       _oUsrCad:SetText(_cUsrCad)
       _oUsrCad:Refresh()
       _oLibCad:Refresh()
       _oUsrCre:SetText(_cUsrCre)
       _oUsrCre:Refresh()
       _oLibCre:Refresh()
       _oUsrDir:SetText(_cUsrDir)
       _oUsrDir:Refresh()
       _oLibDir:Refresh()
       _oObsMsg:SetText(_cObsMsg)
       _oObsMsg:Refresh()
       _oObserv:SetText(_cObserv)
       _oObserv:Refresh()

Return

/*/{Protheus.doc} fCancela
Função para verificar se o pedido foi aprovando em tela e alguma etapa está sendo desmarcada.
@type function
@version  v.2022.01
@author Luís Gustavo Souza
@since 31/01/2022
/*/
Static Function fCancela()
       If SC5->C5_LIBCAD == 'T' .AND. SC5->C5_LIBPED == 'T' .AND. SC5->C5_LIBCRE == 'T' .AND. SC5->C5_LIBDIR == 'T' .AND. SC5->C5_APROVA <> '2'
          DbSelectArea("SC9")
          SC9->( DbSetOrder(1) )
          If SC9->( DbSeek(xFilial("SC9") + SC5->C5_NUM, .t. ) )
             While !Eof() .and. SC9->C9_FILIAL = xFilial("SC9") .and. SC9->C9_PEDIDO = SC5->C5_NUM
                   RecLock("SC9", .f.)
                      SC9->C9_LIBPOR  := space(25)
                      SC9->C9_DTLCRED := ctod('  /  /    ')
                   SC9->( MsUnLock() )
                   SC9->( DbSkip() )
             Enddo
          Endif
          RecLock( 'SC5', .F. )
             SC5->C5_APROVA := '0'
             SC5->C5_USRAPR := space(25) //(Cleber, 16/01/14) LPD->USRAPR
             SC5->C5_DTAPR  := ctod('  /  /    ') //(Cleber, 27/04/16) -> Data de Aprovação do Pedido
             SC5->C5_SUGENT := ctod('  /  /    ')
             SC5->C5_X_EXPO := " "
          SC5->( MsUnLock() )
          DbSelectArea( 'ZZB' )
          ZZB->( DbSetOrder( 1 ) )
          If ZZB->( DbSeek( xFilial( 'ZZB' ) + SC5->C5_NUM ) )
             While !Eof() .and. ZZB->ZZB_PEDIDO == SC5->C5_NUM
                   If ZZB->ZZB_IDLOG == 'APR' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == Alltrim( cUsername )
                      RecLock( 'ZZB', .F. )
                         DBDelete()
                      ZZB->( MsUnLock( ) )
                   Endif
                   ZZB->( DbSkip( ) )
             EndDo
          Endif
       Endif
Return

/*/{Protheus.doc} fLibera
Função final da liberação que verifica se todos as etapas foram liberadas
@type function
@version  v.2022.01
@author Luís Gustavo de Souza
@since 31/01/2022
/*/
Static Function fLibera()
       Local _lCif := .f.

       If SC5->C5_LIBCAD == 'T' .AND. SC5->C5_LIBPED == 'T' .AND. SC5->C5_LIBCRE == 'T' .AND. SC5->C5_LIBDIR == 'T' .AND. SC5->C5_APROVA <> '2'
          //Antiga chamada de função fCreLib() - 31/01/2022
          DbSelectArea("SC9")
          SC9->( DbSetOrder(1) )
          If SC9->( DbSeek(xFilial("SC9") + SC5->C5_NUM, .t. ) )
             While !Eof() .and. SC9->C9_FILIAL = xFilial("SC9") .and. SC9->C9_PEDIDO = SC5->C5_NUM
                   RecLock("SC9", .f.)
                      SC9->C9_LIBPOR  := cUsername
                      SC9->C9_DTLCRED := dDataBase
                   SC9->( MsUnLock() )
                   SC9->( DbSkip() )
             Enddo
          Endif
          If SC5->C5_TPFRETE = "C" .AND. SC5->C5_XVLRFRE > 0.0 .AND. SC5->C5_TIPO = "N"
             _lCif := .t.
          Endif
          //Determinar data de entrega
          dAux := Iif( !Empty( SC5->C5_PEDPROG ), SC5->C5_PEDPROG, U_ProxDiaUtil( dDataBase, SC5->C5_ENTREGA ) )

          nDesc1 := SC5->C5_DESCON1
          nDesc2 := SC5->C5_DESCON2
          nDesc3 := SC5->C5_DESCON3
          nDesc4 := SC5->C5_DESCON4

          RecLock( 'SC5', .F. )
             SC5->C5_APROVA := '1'
             SC5->C5_USRAPR := Iif( _lCif, "#*#CIF#*#", cUserName ) //(Cleber, 16/01/14) LPD->USRAPR
             SC5->C5_DTAPR  := dDataBase //(Cleber, 27/04/16) -> Data de Aprovação do Pedido
             SC5->C5_SUGENT := dAux
             SC5->C5_X_EXPO := " "
             If _lCif // Se for CIF, zerar descontos antes de alterar valores dos itens para evitar problemas de se colocar valor de tabela descontado
                SC5->C5_DESCON1 := 0
                SC5->C5_DESCON2 := 0
                SC5->C5_DESCON3 := 0
                SC5->C5_DESCON4 := 0
             Endif
          SC5->( MsUnLock() )
          lSucesso := .t.
          DbSelectArea("ZZB")
          RecLock("ZZB", .t.)
             ZZB->ZZB_FILIAL := xFilial("ZZB")
             ZZB->ZZB_PEDIDO := SC5->C5_NUM
             ZZB->ZZB_IDLOG  := 'APR'
             ZZB->ZZB_USRLOG := cUsername
             ZZB->ZZB_DATLOG := dDataBase
             ZZB->ZZB_HORLOG := Time()
          ZZB->( MsUnLock() )
          If _lCif
             lSucesso := XSomaCIF(SC5->C5_NUM)
             If lSucesso
                lSucesso := U_LiberaPed(SC5->C5_NUM)
             Endif
             DbSelectArea("SC5")
             RecLock("SC5",.f.)
                SC5->C5_USRAPR  := cUserName
                SC5->C5_DESCON1 := nDesc1
                SC5->C5_DESCON2 := nDesc2
                SC5->C5_DESCON3 := nDesc3
                SC5->C5_DESCON4 := nDesc4
             MsUnLock()
          Endif
          If !lSucesso
             U_fMosAvs( "Atenção", "O pedido: "+LPD->PEDIDO+" teve problemas ao tentar AGREGAR O FRETE CIF!!!."+chr(10)+char(13)+;
                                   "Contate o Administrador do SISTEMA!", {"Continua"}, 2)
          Endif 
       EndIf
Return

/*/{Protheus.doc} fLibPed
Marca/Desmarca liberação de pedidos de vendas 
@type function
@version  v2022.01
@author Luís Gustavo de Souza
@since 31/01/2022
/*/
Static Function fLibPed()
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _nPosPed   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'PEDIDO'   } )
       Local _nPosLPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBPED'   } )
       Local _nPosUPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRPED'   } )

       _lLibPed := Iif( ValType( _lLibPed ) == 'L', _lLibPed, Iif( _lLibPed $ 'F', .F., .T. ) )

       DbSelectArea("SC5")
       SC5->( DbSetOrder( 1 ) )
       If _lLibPed
          If SC5->( DbSeek( xFilial("SC5") + _oModelPed:aCols[_oModelPed:nLine][_nPosPed], .t. ) )
             If SC5->C5_NAOCONF $ 'S'
                MessageBox( "Atenção, pedido desconforme com a Politica de Vendas.", "Atenção...", 48 )
                _lLibPed := .F.
                _cUsrPed := space(25)
             Else
                _cUsrPed := cUsername
                FwMsgRun( NIL, { |oSay| U_fPedLib(oSay) }, "Processando", "Liberando pedido " + SC5->C5_NUM )
                RecLock( 'SC5', .f. )
                   SC5->C5_LIBPED := 'T'
                   SC5->C5_USRPED := cUsername
                SC5->( MsUnLock() )
                RecLock("ZZB", .t.)
                   ZZB->ZZB_FILIAL := xFilial("ZZB")
                   ZZB->ZZB_PEDIDO := SC5->C5_NUM
                   ZZB->ZZB_IDLOG  := 'LVE'
                   ZZB->ZZB_USRLOG := cUsername
                   ZZB->ZZB_DATLOG := dDataBase
                   ZZB->ZZB_HORLOG := Time()
                MsUnLock()
                _oModelPed:aCols[_oModelPed:nLine][_nPosLPe] := .T.
                _oModelPed:aCols[_oModelPed:nLine][_nPosUPe] := cUsername
             Endif
             //Verificação final se todos as etapas estão aprovadas
             fLibera()
          Endif
       Else
          _lLibPed := .F.
          _cUsrPed := space(25)
          If SC5->( DbSeek( xFilial("SC5") + _oModelPed:aCols[_oModelPed:nLine][_nPosPed], .t. ) )
             fCancela() //Antes de retornar o status verifica se o pedido foi aprovado
             RecLock( 'SC5', .f. )
                SC5->C5_LIBPED := 'F'
                SC5->C5_USRPED := cUsername
             SC5->( MsUnLock() )
             _oModelPed:aCols[_oModelPed:nLine][_nPosLPe] := .F.
             _oModelPed:aCols[_oModelPed:nLine][_nPosUPe] := ''
             _aCabec := {}
             _aItens := {}
             _aLinha := {}
             aAdd( _aCabec, { "C5_NUM", SC5->C5_NUM, Nil } )
             DbSelectArea("SC6")
             SC6->( DbSetOrder(1) )
             If SC6->( DbSeek( xFilial("SC6") + SC5->C5_NUM ) )
                While !Eof() .and. SC6->C6_NUM == SC5->C5_NUM
                      _aLinha := {}
                      aAdd( _aLinha, { "C6_NUM"    , SC6->C6_NUM    , Nil } )
                      aAdd( _aLinha, { "C6_ITEM"   , SC6->C6_ITEM   , Nil } )
                      aAdd( _aLinha, { "C6_PRODUTO", SC6->C6_PRODUTO, Nil } )
                      aadd( _aItens, _aLinha )
                      SC6->( DbSkip() )
                EndDo
             Endif
             _lRet := MSExecAuto( { |x,y,z| Mata410( x, y, z ) }, _aCabec, _aItens, 4 )
           Endif
           DbSelectArea( 'ZZB' )
           ZZB->( DbSetOrder( 1 ) )
           If ZZB->( DbSeek( xFilial( 'ZZB' ) + SC5->C5_NUM ) )
              While !Eof() .and. ZZB->ZZB_PEDIDO == SC5->C5_NUM
                    If ZZB->ZZB_IDLOG == 'LVE' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == Alltrim( cUsuario )
                       RecLock( 'ZZB', .F. )
                          DBDelete()
                       ZZB->( MsUnLock( ) )
                    Endif
                    ZZB->( DbSkip( ) )
              EndDo
           Endif
       Endif
       _oUsrPed:SetText(_cUsrPed)
       _oUsrPed:Refresh()
       _oLibPed:Refresh()
Return

/*/{Protheus.doc} fLibCre
Marca/Desmarca liberação de pedidos de vendas área de crédito e automático diretoria dentro das regras
Liberado Crédito e Não Liberado Diretoria e Valor Financeiro menor que R$ 50.000,00 e Lucro maior ou igual a 6.0
@type function
@version  v.2022.01
@author Luís Gustavo de Souza
@since 31/01/2022
/*/
Static Function fLibCre()
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _nPosPed   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'PEDIDO'   } )
       Local _nPosLCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBCRE'   } )
       Local _nPosUCr   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRCRE'   } )
       Local _nPosLDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBDIR'   } )
       Local _nPosUDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRDIR'   } )

       _lLibCre := Iif( ValType( _lLibCre ) == 'L', _lLibCre, Iif( _lLibCre $ 'F', .F., .T. ) )

       DbSelectArea("SC5")
       SC5->( DbSetOrder( 1 ) )
       If _lLibCre
          If SC5->( DbSeek( xFilial("SC5") + _oModelPed:aCols[_oModelPed:nLine][_nPosPed], .t. ) )
             _cUsrCre := cUsername
             RecLock( 'SC5', .f. )
                SC5->C5_LIBPED := 'T'
                SC5->C5_USRPED := cUsername
             SC5->( MsUnLock() )
             RecLock("ZZB", .t.)
                ZZB->ZZB_FILIAL := xFilial("ZZB")
                ZZB->ZZB_PEDIDO := SC5->C5_NUM
                ZZB->ZZB_IDLOG  := 'LCR'
                ZZB->ZZB_USRLOG := cUsername
                ZZB->ZZB_DATLOG := dDataBase
                ZZB->ZZB_HORLOG := Time()
             ZZB->( MsUnLock() )
             _oModelPed:aCols[_oModelPed:nLine][_nPosLCr] := .T.
             _oModelPed:aCols[_oModelPed:nLine][_nPosUCr] := cUsername
             //(04/08/2017)Chamado 007850 => Kelly pediu para liberar automaticamente pedidos abaixo de R$ 50 mil com lucratividade maior ou igual a 6%
             If SC5->C5_LIBCRE == 'T'.AND. SC5->C5_LIBDIR == "F" .AND. SC5->C5_VLRDUP < 50000  .AND. SC5->C5_LUCRO >= 6.0
                _lLibDir := .T.
                _cUsrCre := "BR_Automatico"
                RecLock( "SC5", .F. )
                   SC5->C5_LIBDIR := "T"
                   SC5->C5_USRDIR := "BR_Automatico"
                SC5->( MsUnLock( ) )
                RecLock("ZZB", .t.)
                   ZZB->ZZB_FILIAL := xFilial("ZZB")
                   ZZB->ZZB_PEDIDO := SC5->C5_NUM
                   ZZB->ZZB_IDLOG  := 'LDI'
                   ZZB->ZZB_USRLOG := 'BR_Automatico'
                   ZZB->ZZB_DATLOG := dDataBase
                   ZZB->ZZB_HORLOG := Time()
                ZZB->( MsUnLock() )
                _oModelPed:aCols[_oModelPed:nLine][_nPosLDi] := .T.
                _oModelPed:aCols[_oModelPed:nLine][_nPosUDi] := "BR_Automatico"
             Endif
             //Verificação final se todos as etapas estão aprovadas
             fLibera()
          Endif
       Else
          _lLibCre := .F.
          _cUsrCre := space(25)
          If SC5->( DbSeek( xFilial("SC5") + _oModelPed:aCols[_oModelPed:nLine][_nPosPed], .t. ) )
             fCancela() //Antes de retornar o status verifica se o pedido foi aprovado
             RecLock( 'SC5', .f. )
                SC5->C5_LIBCRE := 'F'
                SC5->C5_USRCRE := space(25)
             SC5->( MsUnLock() )
             DbSelectArea( 'ZZB' )
             ZZB->( DbSetOrder( 1 ) )
             If ZZB->( DbSeek( xFilial( 'ZZB' ) + SC5->C5_NUM ) )
                While !Eof() .and. ZZB->ZZB_PEDIDO == SC5->C5_NUM
                      If ZZB->ZZB_IDLOG == 'LCR' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == Alltrim( cUsuario )
                         RecLock( 'ZZB', .F. )
                            DBDelete()
                         ZZB->( MsUnLock( ) )
                      Endif
                      ZZB->( DbSkip( ) )
                EndDo
             Endif
             _oModelPed:aCols[_oModelPed:nLine][_nPosLCr] := .F.
             _oModelPed:aCols[_oModelPed:nLine][_nPosUCr] := space(25)
             If SC5->C5_LIBCRE == 'F' .AND. Alltrim( SC5->C5_USRDIR ) == 'BR_Automatico' .AND. SC5->C5_LIBDIR == "T" .AND. SC5->C5_VLRDUP < 50000  .AND. SC5->C5_LUCRO >= 6.0
                _lLibDir := .F.
                _cUsrCre := Space(25)
                RecLock( "SC5", .F. )
                   SC5->C5_LIBDIR := 'F'
                   SC5->C5_USRDIR := Space(25)
                SC5->( MsUnLock( ) )
                DbSelectArea( 'ZZB' )
                ZZB->( DbSetOrder( 1 ) )
                If ZZB->( DbSeek( xFilial( 'ZZB' ) + SC5->C5_NUM ) )
                   While !Eof() .and. ZZB->ZZB_PEDIDO == SC5->C5_NUM
                         If ZZB->ZZB_IDLOG == 'LDI' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == 'BR_Automatico'
                            RecLock( 'ZZB', .F. )
                               DBDelete()
                            ZZB->( MsUnLock( ) )
                         Endif
                         ZZB->( DbSkip( ) )
                   EndDo
                Endif
                _oModelPed:aCols[_oModelPed:nLine][_nPosLDi] := .F.
                _oModelPed:aCols[_oModelPed:nLine][_nPosUDi] := space(25)
             Endif
          Endif
       Endif
       _oUsrCre:SetText( _cUsrCre )
       _oUsrCre:Refresh()
       _oLibCre:Refresh()
       _oUsrDir:SetText( _cUsrDir )
       _oUsrDir:Refresh()
       _oLibDir:Refresh()
Return

/*/{Protheus.doc} fLibDir
Marca/Desmarca para liberação da etapa diretoria.
@type function
@version  v.2022.021
@author Luís Gustavo de Souza
@since 31/01/2022
/*/
Static Function fLibDir()
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _nPosLDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'LIBDIR'   } )
       Local _nPosUDi   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'USRDIR'   } )
       Local _nPosPed   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'PEDIDO'   } )

       _lLibDir := Iif( ValType( _lLibDir ) == 'L', _lLibDir, Iif( _lLibDir $ 'F', .F., .T. ) )

       DbSelectArea("SC5")
       SC5->( DbSetOrder( 1 ) )
       If _lLibDir
          If SC5->( DbSeek( xFilial("SC5") + _oModelPed:aCols[_oModelPed:nLine][_nPosPed], .t. ) )
             _cUsrDir := cUsername
             RecLock( 'SC5', .f. )
                SC5->C5_LIBDIR := 'T'
                SC5->C5_USRDIR := cUsername
             SC5->( MsUnLock() )
             RecLock("ZZB", .t.)
                ZZB->ZZB_FILIAL := xFilial("ZZB")
                ZZB->ZZB_PEDIDO := SC5->C5_NUM
                ZZB->ZZB_IDLOG  := 'LDI'
                ZZB->ZZB_USRLOG := cUsername
                ZZB->ZZB_DATLOG := dDataBase
                ZZB->ZZB_HORLOG := Time()
             ZZB->( MsUnLock() )
             _oModelPed:aCols[_oModelPed:nLine][_nPosLDi] := .T.
             _oModelPed:aCols[_oModelPed:nLine][_nPosUDi] := cUsername
             //Verificação final se todos as etapas estão aprovadas
             fLibera()
          Endif
       Else
          If SC5->( DbSeek( xFilial("SC5") + _oModelPed:aCols[_oModelPed:nLine][_nPosPed], .t. ) )
             fCancela() //Antes de retornar o status verifica se o pedido foi aprovado
             _lLibDir := .f.
             _cUsrDir := space( 25 )
             RecLock( 'SC5', .f. )
                SC5->C5_LIBDIR := 'F'
                SC5->C5_USRDIR := space(25)
             SC5->( MsUnLock() )
             DbSelectArea( 'ZZB' )
             ZZB->( DbSetOrder( 1 ) )
             If ZZB->( DbSeek( xFilial( 'ZZB' ) + SC5->C5_NUM ) )
                While !Eof() .and. ZZB->ZZB_PEDIDO == SC5->C5_NUM
                      If ZZB->ZZB_IDLOG == 'LDI' .and. ZZB->ZZB_DATLOG == dDataBase .and. Alltrim( ZZB->ZZB_USRLOG ) == 'BR_Automatico'
                         RecLock( 'ZZB', .F. )
                            DBDelete()
                         ZZB->( MsUnLock( ) )
                      Endif
                      ZZB->( DbSkip( ) )
                EndDo
             Endif
             _oModelPed:aCols[_oModelPed:nLine][_nPosLDi] := .F.
             _oModelPed:aCols[_oModelPed:nLine][_nPosUDi] := space(25)
          Endif
       Endif
       _oUsrDir:SetText(_cUsrDir)
       _oUsrDir:Refresh()
       _oLibDir:Refresh()
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

/*/{Protheus.doc} fAcuPed description
@type function
@version  01.01
@author gustavosouza
@since 25/01/2022
@param aCliente, array, Array com dados do cliente
@param nPercSubst, numeric, param_description
@param nPerIcm, numeric, param_description
@param nAliqSol, numeric, param_description
@param _NumPedAtu, variant, param_description
@return variant, return_description 
/*/
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
       @ 001,440 SAY OemToAnsi('F2-Hist. Ped. | F5-Dados Ped. | F7-Tit. Aberto | F9-Dados Cli. | F11-Pesquisa' ) COLOR CLR_RED  SIZE 300,06 PIXEL OF _oPanel FONT _oFont3
       @ 008,440 SAY OemToAnsi('F4-Itens Ped. | F6-Plan. Fin. | F8-Tit. Receb. | F10-Obs. Lib. | '             ) COLOR CLR_RED  SIZE 300,06 PIXEL OF _oPanel FONT _oFont3
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
       Local _nTXPIS     := GETMV( "MV_TXPIS"   )
       Local _nTXCOFINS  := GETMV( "MV_TXCOFIN" )

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
       aHeader := {}
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
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ( _cAliasSC6)->C6_NUM+( _cAliasSC6)->C6_ITEM, 0;
                          } ;
                 ) 
                 //Posições da Matriz
                 //     20       21       22      23      24      25      26      27      28      29      30      31       32         33       34
                 //BS.ICMS  AL.ICMS  VL.ICMS  BS.IPI  AL.IPI  VL.IPI  BS.COF  AL.COF  VL.COF  BS.PIS  AL.PIS  VL.PIS  VL.IRET  VL.MARGEM  VL.PMAR
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
             aCols[Len(aCols)][26] := ( _cAliasSC6)->C6_VALOR - aCols[Len(aCols)][22]         //MaFisRet( _nItem, 'IT_BASECOF' )
             aCols[Len(aCols)][27] := _nTXCOFINS                                              //MaFisRet( _nItem, 'IT_ALIQCOF' )
             aCols[Len(aCols)][28] := aCols[Len(aCols)][26] * ( aCols[Len(aCols)][27] / 100 ) //MaFisRet( _nItem, 'IT_VALCOF'  )
             aCols[Len(aCols)][29] := ( _cAliasSC6)->C6_VALOR - aCols[Len(aCols)][22]         //MaFisRet( _nItem, 'IT_BASEPIS' )
             aCols[Len(aCols)][30] := _nTXPIS                                                 //MaFisRet( _nItem, 'IT_ALIQPIS' )
             aCols[Len(aCols)][31] := aCols[Len(aCols)][29] * ( aCols[Len(aCols)][30] / 100 ) //MaFisRet( _nItem, 'IT_VALPIS'  )
             
             _aSolid      := ExecBlock( "M410SOLI", .f., .f., { _nItem } )
             aCols[Len(aCols)][32] := Iif( Len(_aSolid) > 0, _aSolid[2] + _aSolid[7], 0 ) //Valor do ICMS Solidario + Valor do FECP-ST

             _nCusPro := fBusCus( ( _cAliasSC6 )->C6_PRODUTO )
             _nRecLiq := ( ( _cAliasSC6)->C6_VALOR - aCols[Len(aCols)][22] - aCols[Len(aCols)][28] - aCols[Len(aCols)][31] )
             //          ( Valor Mercadoria        - Valor ICMS            - Valor COFINS          - Valor PIS             )

             aCols[Len(aCols)][33] := ( _nRecLiq - ( ( _cAliasSC6 )->C6_QTDVEN * _nCusPro ) )
             aCols[Len(aCols)][34] := ( 1 - ( ( _cAliasSC6 )->C6_QTDVEN * _nCusPro   ) / _nRecLiq ) * 100 //Percentual Margem
             aCols[Len(aCols)][36] := ( _cAliasSC6 )->C6_QTDVEN * _nCusPro
             ( _cAliasSC6 )->( dbSkip() )
	EndDo
       _aPedidos[aScan( _aPedidos, { |x| x[1] == _cPedido } )][3] := aCols
       /*For _nY := 1 To Len( aCols )
           //                            1,              2,              3,              4,              5,              6,              7,              8,              9,             10
           aAdd( _aItens, { _cPedido      , aCols[_nY][01], aCols[_nY][35], aCols[_nY][02], aCols[_nY][03], aCols[_nY][04], aCols[_nY][05], aCols[_nY][06], aCols[_nY][07], aCols[_nY][08],; 
                            aCols[_nY][09], aCols[_nY][10], aCols[_nY][11], aCols[_nY][12], aCols[_nY][13], aCols[_nY][14], aCols[_nY][15], aCols[_nY][16], aCols[_nY][17], aCols[_nY][18],;
                            aCols[_nY][19], aCols[_nY][20], aCols[_nY][21], aCols[_nY][22], aCols[_nY][23], aCols[_nY][24], aCols[_nY][25], aCols[_nY][26], aCols[_nY][27], aCols[_nY][28],; 
                            aCols[_nY][29], aCols[_nY][30], aCols[_nY][31], aCols[_nY][32], aCols[_nY][33] } )
       Next */
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

/*/{Protheus.doc} fCalcPrazo
Calcula prazos de pagamentos - Desenvolvida a partir do MTA410, regras de negócios comerciais (Politica de Vendas Brasilux/Dissoltex)
@type function
@version  v.2022,01
@author Luis Gustavo de Souza
@since 19/01/2022
@param _dDiaFat, variant, Data que o pedido será faturado
@param _cCondPag, variant, Condição de pagamento do pedido
@return array, Array contendo três parâmetros array com os prazos, prazo médio, array contendo vencimentos
/*/
Static Function fCalcPrazo( _dDiaFat, _cCondPag )
       Local _aVenctos := {}
       Local _nQtdePar := 0
       Local _nPrazoMd := 0
       Local _nTotTp9  := 0
       Local _nY
       Local _cCampo   := ""
       Local _aPrazos  := {}
       
       DbSelectArea('SE4')
       SE4->( DbSetOrder( 1 ) )
       If SE4->( DbSeek( xFilial('SE4') + _cCondPag ) )
          If SE4->E4_TIPO == "9"
             For _nY := 1 to 4
                 _cCampo := "M->C5_DATA" + Alltrim( Str( _nY ) )
                 If !Empty( &_cCampo )
                    aAdd( _aVenctos, { &_cCampo, 0 } )
                    _cCampo  := "M->C5_PARC" + Alltrim (Str( _nY ) )
                    _nTotTp9 += &_cCampo
                    _aVenctos[_nY][2] := &_cCampo
                    _nQtdePar++
                 Endif
             Next
             If _nQtdePar == 0
                _nQtdePar := 1
                _nTotTp9  := 1
                aAdd( _aVenctos, { dDataBase, 1 } )
             Endif
          Else
             //Verifica se a condição é a vista ( menor igual a 7 dias ) e considera a condição 001
             If ( SE4->E4_TIPO == "1" ) .AND. LEN( ( ALLTRIM( SE4->E4_COND ) ) ) == 1
                If Val( Alltrim( SE4->E4_COND ) ) <= 7
                   _cCondPag := "001"
                Endif
             Endif
             _aVenctos := Condicao( 100, _cCondPag, 0.00, _dDiaFat, 0.00 )
          Endif
       Else
          _nTotTp9  := 1
          _aVenctos := {}
          aAdd( aVenctos, { dDataBase, 1 } )
       Endif
       If ( _nTotTp9 > 0 )
          If !Empty( M->C5_PEDPROG )
             _dDiaFat := M->C5_PEDPROG //Considerar dia do Faturamento data do pedido programado para o caso de datas fixas de vencimento (Chamado 014805)
          Endif
       Endif
       //Monta vetor com prazos em dias + % de cada parcela sobre total e cálculo do prazo médio
       _nPrazoMd := 0
       For _nY := 1 To Len( _aVenctos )
           aAdd( _aPrazos, { _aVenctos[_nY][1] - _dDiaFat + 1, Iif( _nTotTp9 > 0, _aVenctos[_nY][2] / _nTotTp9, 1 / Len( _aVenctos ) ) } )
           _nPrazoMd += _aPrazos[_nY][1]
       Next
       If Len( _aVenctos ) > 0
          _nPrazoMd := _nPrazoMd / Len( _aVenctos )
       Endif
Return { _aPrazos, _nPrazoMd, _aVenctos }


Static Function fObsPed(oView)
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _aButtons  := {}
       Local _cPedido   := _oModelPed:aCols[_oModelPed:nLine][1]
       Local _cObsPed   := ''
       Local _nOpcAju   := 0
       Local _nPosOPe   := aScan( _oModelPed:aHeader, { |x| Alltrim( x[2] ) == 'OBSPED'   } )

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

       DbSelectArea('SC5')
       SC5->( DbSetOrder( 1 ) )
       SC5->( DbSeek( xFilial('SC5') + _cPedido ) )

       oModal := FWDialogModal():New()
       oModal:SetEscClose( .F. )
       oModal:setTitle( "Obs. de Liberação do Pedido de Vendas" )
       oModal:setSize( 141, 268 )
       oModal:createDialog()

       aAdd( _aButtons, { "", 'Confirma', {|| _nOpcAju := 1, oModal:DeActivate() }, , , .T., .F. } )
       aAdd( _aButtons, { "", 'Cancela' , {|| _nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )
       oModal:addButtons( _aButtons )

       oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
       oContainer:Align := CONTROL_ALIGN_ALLCLIENT

       _oGetDObs    := tMultiGet():new( 002, 002, {| u | If( pCount() > 0, _cObsPed := u, _cObsPed ) }, oContainer, 260,  92, , , , , , .T. )
       oModal:Activate()

         If _nOpcAju == 1
            _cAuxObs := MSMM( _oModelPed:aCols[_oModelPed:nLine][_nPosOPe], , , , 3 )
            _cObsMsg := Alltrim( cUsername ) + " (" + dToc( dDataBase ) + " " + Time() + "):" + Chr(13) + chr(10)
            _cObsMsg += Upper( _cObsPed) + Chr(13) + chr(10) + Chr(13) + chr(10)
            _cObsMsg += _cAuxObs

            _nCodMsg := MSMM(SC5->C5_OBSPED, , , _cObsMsg, 1, , , "SC5", "C5_OBSPED")
               If Empty( _cAuxObs )
               _oModelPed:aCols[_oModelPed:nLine][_nPosOPe] := _nCodMsg
               //_cAuxObs := _oModelPed:aCols[_oModelPed:nLine][_nPosOPe] := _nCodMsg
               Endif
            _oObsMsg:Refresh()
            _oObserv:Refresh()
         Endif

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

       RestArea( aArea )
Return

Static Function fPesPed( oView )
       Local aArea      := GetArea()                 //Irei gravar a area atual
       Local _oModel    := FwModelActive()
       Local _oModelPed := _oModel:GetModel( 'GRIDPEDIDO' )
       Local _aButtons  := {}
       Local _aOrdPes   := {}
       Local _cOrdPes
       Local _oCbxPes
       Local _oBigGet
       Local _cCampo    := Space( 6 )
       Local _oScroll
       Local _nOrdPes   := 1

       SetKey( VK_F2 , {||} )
       SetKey( VK_F4 , {||} )
       SetKey( VK_F5 , {||} )
       SetKey( VK_F6 , {||} )
       SetKey( VK_F7 , {||} )
       SetKey( VK_F8 , {||} )
       SetKey( VK_F9 , {||} )
       SetKey( VK_F10, {||} )
       SetKey( VK_F11, {||} )

       aadd( _aOrdPes, OemToAnsi( "Pedido"            ) )
       aadd( _aOrdPes, OemToAnsi( "Código do Cliente" ) )
       aadd( _aOrdPes, OemToAnsi( "Nome do Cliente"   ) )

       oModal := FWDialogModal():New()
       oModal:SetEscClose( .F. )
       oModal:setTitle( "Obs. de Liberação do Pedido de Vendas" )
       oModal:setSize( 85, 220 )
       oModal:createDialog()

       oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
       oContainer:Align := CONTROL_ALIGN_ALLCLIENT

       @ 005, 005 COMBOBOX  _oCbxPes VAR _cOrdPes ITEMS _aOrdPes SIZE 206,36 PIXEL OF oContainer
       @ 022, 005 MSGET     _oBigGet VAR _cCampo                 SIZE 206,10 PIXEL OF oContainer
       @ 022, 005 SCROLLBOX _oScroll VERTICAL                    SIZE 84,205       OF oContainer BORDER
       _oScroll:Hide()
       _oCbxPes:bChange := { || _nOrdPes := _oCbxPes:nAt, _cCampo := Iif( _oCbxPes:nAt == 1, Space(6), Iif( _oCbxPes:nAt == 2, Space(6), Space(40) ) ) }

       aAdd( _aButtons, { "", 'Pesquisa' , {|| oModal:DeActivate() }, , , .T., .F. } )
       oModal:addButtons( _aButtons )

       oModal:Activate()

       _nOldOrd := _oModelPed:nLine
       If _nOrdPes == 1
          _oModelPed:nLine := aScan( _oModelPed:aCols, {|x| x[1] == _cCampo } )
       ElseIf _nOrdPes == 2
              _oModelPed:nLine := aScan( _oModelPed:aCols, {|x| SubString( x[4], 1, 6 ) == _cCampo } )
       ElseIf _nOrdPes == 3
              If !Empty( _cCampo )
                 _oModelPed:nLine := aScan( _oModelPed:aCols, {|x| Substring( x[4], 13, Len( Alltrim( _cCampo ) ) ) == SubStr( _cCampo, 1, Len( Alltrim( _cCampo ) ) ) } ) 
              Endif
       Endif
       If _oModelPed:nLine == 0
          MessageBox( 'Informação não encontrada, verifique chave de pesquisa.', 'Pesquisa...', 48 )
          _oModelPed:nLine := _nOldOrd
       Else
          fChangePED( oView, 'GRIDPEDIDO',  )
          oView:Refresh( 'GRIDPEDIDO' )
          oView:Refresh( 'GRIDVALOR' )
       Endif

       SetKey( VK_F2 , bHistorico )
       SetKey( VK_F4 , bItensPedi )
       SetKey( VK_F5 , bDadosPedi )
       SetKey( VK_F6 , bPlanilhaF )
       SetKey( VK_F7 , bTitAberto )
       SetKey( VK_F8 , bTitRecebi )
       SetKey( VK_F9 , bDadosClie )
       SetKey( VK_F10, bObservPed )
       SetKey( VK_F11, bPesquisaP )

       RestArea( aArea )
Return



Static Function XSomaCIF(_cPed)
       Local lRet := .t.
       Local aCabec := {}
       Local aItens := {}
       Local aLinha := {}
       Local nTam1,nTam2,nVlrFrete,nVlrProd,nSaldo,nFreteItem,nVlrUnit,nQtde,nPos,nVlrUnAnt,_nVlrTotDup,nComis,cAux,_cAlias
       //Local nTam3,nValor
       Local _lOpen        := .F. //LGS#20200210 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200210 - Adequação para release 12.1.25
       Private lMsErroAuto := .f.
       Private lMsHelpAuto := .f.

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200210 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200210 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif

       nVlrFrete := SC5->C5_XVLRFRE
       nSaldo := nVlrFrete

       dbselectarea("SF4")
	   dbsetorder(1)

       aItens := {}
       dbselectarea("SC6")
       dbsetorder(1)
       nVlrProd := 0.0
       nQtde = 0
       dbseek(xFilial("SC6")+SC5->C5_NUM)
       DO WHILE !eof() .and. (SC6->C6_FILIAL == xFilial("SC6")) .and. (SC6->C6_NUM == SC5->C5_NUM)
          nVlrProd += (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
          nQtde++
          dbskip()
       ENDDO
       nTam1 := TamSX3("C6_PRCVEN")[2]
       nTam2 := TamSX3("C6_XVLRFRE")[2]
       nPos := 0
       _nVlrTotDup := 0.0 // Valor total financeiro novo sem ipi+st
       dbseek(xFilial("SC6")+SC5->C5_NUM)
       DO WHILE !eof() .and. (SC6->C6_FILIAL == xFilial("SC6")) .and. (SC6->C6_NUM == SC5->C5_NUM)
		nPos++
		if nPos == nQtde
			nFreteItem := nSaldo
		else 
			nFreteItem := round(nVlrFrete*(SC6->C6_QTDVEN*SC6->C6_PRCVEN)/nVlrProd,nTam2)
		endif 
		nVlrUnAnt := SC6->C6_PRCVEN
		nVlrUnit := round(((SC6->C6_QTDVEN*SC6->C6_PRCVEN)+nFreteItem)/SC6->C6_QTDVEN,nTam1)
		nSaldo := nSaldo - nFreteItem
		dbselectarea("SF4")
		dbseek(xFilial("SF4")+SC6->C6_TES)
		if found()
            If (SF4->F4_DUPLIC = "S") .OR. (SF4->F4_CODIGO = "519")
				_nVlrTotDup := _nVlrTotDup + (nVlrUnit*SC6->C6_QTDVEN)
			Endif
		endif
		aLinha := U_DetCposTab("SC6","C6_XVLRFRE-C6_PRCVEN-C6_PRUNIT-C6_FILIAL-C6_ITEM-C6_NUM-C6_BLOQUEI-C6_BLQ-C6_GEROUPV-C6_QTDEMP-C6_QTDEMP2-C6_QTDENT-C6_QTDENT2-C6_QTDLIB-C6_QTDLIB2-C6_QTDRESE-C6_SLDALIB-C6_SUGENTR-C6_TRT")
		aadd(aLinha,{"LINPOS","C6_ITEM",SC6->C6_ITEM})		
		aadd(aLinha,{"AUTDELETA","N",Nil})
		aadd(aLinha,{"C6_PRCVEN",nVlrUnit,Nil})		
		aadd(aLinha,{"C6_PRUNIT",nVlrUnit,Nil})		
		aadd(aLinha,{"C6_XVLRFRE",nVlrUnAnt,Nil})		
		aadd(aItens,aLinha)
		      
		dbselectarea("SC6")
		dbskip()
	enddo 
	if _nVlrTotDup > 0.0
		nComis := round(SC5->C5_VLRCOM*100/_nVlrTotDup,TamSX3("C5_COMIS1")[2])
	else
		nComis := SC5->C5_COMIS1
	endif
	_nVlrTotDup := ROUND(_nVlrTotDup,TamSX3("C5_VLRDUP")[2])
       _cAlias := "SC5"	
       aCabec := {} 	

       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek("SC5") )
       While !EOF() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) = _cAlias
             If ( X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .AND. !( ( _cAliasSX3 )->( X3_CONTEXT ) = "V") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_FILIAL")) .OR. ( ( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_COMIS1") .OR. ( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_VLRDUP" ) )
                cAux := alltrim(_cAlias)+"->"+( _cAliasSX3 )->( X3_CAMPO )
                do case
                   case ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_COMIS1"
                        xValor := nComis
                   case ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_VLRDUP"
                        xValor := _nVlrTotDup
                   otherwise
                        xValor := &cAux
                endcase
                if !empty(xValor)
                   aadd( aCabec, { ( _cAliasSX3 )->( X3_CAMPO ), xValor, .F. } )
                endif
             Endif
             dbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( dbSkip() )
       End
       DbSelectArea("SC5")
       MsgRun("Frete CIF...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCabec, aItens, 4 ) } )
       If lMsErroAuto
          lRet := !lMsErroAuto
          MostraErro()
       ENDIF

       DbSelectArea( _cAliasSX3 )
       DbCloseArea()

       DbSelectArea("SC5")
       dbsetorder(1)
       dbseek(xFilial("SC5")+_cPed)
Return(lRet)
