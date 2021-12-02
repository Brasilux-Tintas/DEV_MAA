#INCLUDE 'totvs.ch'
#INCLUDE 'fwmvcdef.ch'

Static _cProcPrinc := "ZFINF01"
Static _lFWCodFil  := .T.

/*/{Protheus.doc} ZFINF01
Chamada principal da Conciliação Bancaria desenvolvida para Brasilux, conforme solicitação do 
Diretor Sergio Duó, chamado 018457.
@type function
@version 
@author Luís Gustavo
@since 24/09/2020
@return return_type, return_description
/*/
User Function ZFINF01()
     Local oBrowse as Object
     Public lF100Auto := .T.
     Public cRecPag   := " "
     u_zcfga01( 'ZFINF01' ) //LGS#2021201 - Gravação de log de utilização da rotina
     fSIFStatus()

     oBrowse := FWMBrowse():New()
     oBrowse:SetAlias('SIF')
     oBrowse:SetDescription( 'Conciliação Bancária' )
     oBrowse:AddLegend( "IF_STATUS=='1'", "RED"   , "Não conciliado" )
     oBrowse:AddLegend( "IF_STATUS=='2'", "YELLOW", "Em Andamento"   )
     oBrowse:AddLegend( "IF_STATUS=='3'", "GREEN" , "Conciliado"     )
     oBrowse:Activate()

Return

Static Function MenuDef()     
       Local aRotina as Array

       aRotina	:= {}
       ADD OPTION aRotina TITLE 'Pesquisar'         ACTION 'PesqBrw'               OPERATION 1 ACCESS 0
       ADD OPTION aRotina TITLE "Importar"          ACTION 'F473Import( , , 3 )'   OPERATION 3 ACCESS 0
       ADD OPTION aRotina TITLE "Conciliar"         ACTION 'u_ZFINF01CON( , , 4 )' OPERATION 4 ACCESS 0
       ADD OPTION aRotina TITLE 'Visualizar'        ACTION 'VIEWDEF.FINA473'       OPERATION 2 ACCESS 0
       ADD OPTION aRotina TITLE 'Excluir'           ACTION 'VIEWDEF.FINA473'       OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
       Local oModel
       Local oStr1:= FWFormStruct( 1, 'SIF' )
       Local oStr2:= FWFormStruct( 1, 'SIG' )
 
       oModel := MPFormModel():New( 'ZFINF01' )
       oModel:SetDescription( 'Extrato Bancario' )
       oModel:addFields( 'MASTERSIF', , oStr1 )
       oStr2:AddField( 'Status', 'Status', 'IG_COR', 'BT', 15, , , , , , { || FSTATSIG() }, , .F., .T. )
       oModel:addGrid( 'DETAILSIG', 'MASTERSIF', oStr2 )
       oModel:SetRelation( 'DETAILSIG', { { 'IG_FILIAL', 'xFilial("SIG")' }, { 'IG_IDPROC', 'IF_IDPROC' } }, SIG->( IndexKey(1) ) )
       oModel:getModel('MASTERSIF'):SetDescription( 'Extrato Bancario' )
       oModel:getModel('DETAILSIG'):SetDescription( 'Movimento Extrato' )
       oModel:getModel('DETAILSIG'):SetOptional( .T. )
       oModel:SetVldActivate( { |oModel| FVldModel(oModel) } )
       If oModel:GetOperation() <> 1
          oModel:GetModel( 'SIGDETAIL' ):SetNoInsertLine( .T. )
          oModel:GetModel( 'SIGDETAIL' ):SetNoDeleteLine( .T. )
          oModel:GetModel( 'SIGDETAIL' ):SetNoUpdateLine( .T. )
       Endif
Return oModel

Static Function ViewDef()
       Local oView
       Local oModel := ModelDef()
       Local oStr1  := FWFormStruct( 2, 'SIF' )
       Local oStr2  := FWFormStruct( 2, 'SIG' )

       oView := FWFormView():New()
       oView:SetModel( oModel )
       oView:AddField( 'VIEWSIF' , oStr1, 'MASTERSIF' )
       oView:AddGrid( 'VIEWSIG' , oStr2, 'DETAILSIF' )

       oStr1:RemoveField( 'IF_STATUS' )
       oView:CreateHorizontalBox( 'BOXFORM1', 30 )

       oStr2:RemoveField( 'IG_SEQMOV' )
       oStr2:RemoveField( 'IG_IDPROC' )
       oStr2:AddField( 'IG_COR', '01', 'Status', 'Status', , 'BC', '@BMP', , , .T. )
       oStr2:RemoveField( 'IG_STATUS' )
       oView:CreateHorizontalBox( 'BOXFORM3', 70 )
       oView:SetOwnerView( 'VIEWSIF','BOXFORM1' )
       oView:SetOwnerView( 'VIEWSIG','BOXFORM3' )

       oView:EnableTitleView('VIEWSIG' , 'Movimento Extrato' )
       oView:EnableTitleView('VIEWSIF' , 'Extrato Bancario' )
       If oModel:GetOperation() <> 1
          oView:AddIncrementField('VIEWSIG' , 'IG_ITEM' ) 
       Endif
Return oView

Static Function FSTATSIG()
       Local cCor := "BR_VERMELHO"

       cCor := u_FRETCOR( SIG->IG_STATUS )
Return cCor

User Function FRETCOR( cStatus )
     Local cCor := ""

     If cStatus == '2'
        cCor:= "BR_AMARELO"
     ElseIf cStatus == '3'
            cCor := "BR_VERDE"
     ElseIf cStatus == '4'
            cCor := "BR_AZUL"
     ElseIf cStatus == '5'
            cCor := "BR_CANCEL
     ElseIf cStatus == '6'
            cCor := "BR_PINK"
     Else
        cCor := "BR_VERMELHO"
     EndIf
Return cCor

Static Function FVldModel( oModel )
       Local nOperation := oModel:GetOperation()
       Local lRet := .T.

       If lRet .And. ( nOperation == MODEL_OPERATION_DELETE )
          If SIF->IF_STATUS == '2' .Or. SIF->IF_STATUS == '3'
             Help( " ", 1, "FI473EXC01", , "Somente extratos não conciliados podem ser excluídos.", 1, 0 )
             lRet:=.F.
          EndIf
       EndIf
Return lRet

User Function ZFINF01CON( _cAlias, _nReg, _nOpc )
     Local _cTitulo    := "Conciliar"
     Local _cPrograma  := 'ZFINF02'
     //Local _cPerg      := "FINA473"
     Local _cPerg      := "ZFINF01"
     Local _nOperation := MODEL_OPERATION_UPDATE
     //Local _bBlock     := Nil
     Local _aSelFil    := {}
     Local _cSA6Emp    := FWModeAccess( "SA6", 1 )
     Local _cSA6UNe    := FWModeAccess( "SA6", 2 )
     Local _cSA6Fil    := FWModeAccess( "SA6", 3 )
     Local _lGestao    := Iif( _lFWCodFil, FWSizeFilial() > 2, .F. ) // Indica se usa Gestao Corporativa
     Local _lSE5Access := Iif( _lGestao  , FWModeAccess( "SE5", 1 ) == "C", FWModeAccess( "SE5", 3 ) == "C" )

     If Pergunte( _cPerg, .T. )
        //If mv_par09 == 1
        If mv_par06 == 1
           //SA6 exclusivo nao permite a selecao de filiais
           If _cSA6Fil == "E"
              Help( , , 'SA6_COMPART', , ;
                   "O compartilhamento do cadastro de Bancos (tabela SA6) não permite a seleção de filiais." + CRLF + ;
                   "O processo será feito considerando apenas titulos da filial corrente." + CRLF + ;
                   " " + CRLF + ;
                   "Compartilhamento da tabela SA6:" + CRLF + ;
                   "Empresa    : " + If( _cSA6Emp == "C", "Compartilhado", "Exclusivo" ) + CRLF + ;
                   "Un. Negócio: " + If( _cSA6UNe == "C", "Compartilhado", "Exclusivo" ) + CRLF + ;
                   "Filial     : " + If( _cSA6Fil == "C", "Compartilhado", "Exclusivo" ) + CRLF + ;
                   " " + CRLF + ;
                   "(Para que esta mensagem deixe de ser apresentada, altere a pergunta " + CRLF + ;
                   "<Seleciona Filiais?> para Não.)", 1, 0 )
              _aSelFil := { cFilAnt }
           ElseIf _lSE5Access
                  Help( , , 'SE5_COMPART', , "A tabela de Movimentação Bancária está compartilhada.O processo será feito considerando apenas movimentos da filial corrente", 1, 0 )
                  _aSelFil := { cFilAnt }
           ElseIf Len( _aSelFil ) <= 0
                  If _cSA6Emp <>  "C" .Or. _cSA6UNe <> "C" .Or. _cSA6Fil <> "C"
                     _aSelFil := AdmGetFil( .F., .T., "SE5" )
                  Else
                     _aSelFil := AdmGetFil(.T.,.F.,"SE5")
                  EndIf
           Endif
        Else
           _aSelFil := { cFilAnt }
        EndIf
        If Len( _aSelFil ) > 0
           u_fZeraStat( _aSelFil )
           BEGIN TRANSACTION
                 nOpc := FWExecView( _cTitulo , _cPrograma, _nOperation, /*oDlg*/, {|| .T. }, /*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
                 If nOpc == 1 // Cancelou a operação faz rollback
                    DisarmTransaction()
                 EndIf
                 //Zera as variáveis estáticas
                 u_fZeraStat()
           END TRANSACTION
        EndIf
     Endif
Return

Static Function fSIFStatus()
       Local cStatus  := "1"
       Local cQuery   := ""
       Local cTabSIF  := "SIFCONTA"
       Local cTabSIG  := "SIGCONTA"
       Local nTotal   := 0
       Local nNaoConc := 0

       Default cFilSIF   := FWxFilial("SIF")
       Default cFilSIG   := FWxFilial("SIG")

       cQuery := " "
       cQuery += " SELECT * "
       cQuery += " FROM "+RetSQLName("SIF")+" SIF "
       cQuery += " WHERE "
       cQuery += "     IF_FILIAL = '" + cFilSIF   + "'  AND "
       cQuery += "     IF_STATUS <> '3' AND "
       cQuery += "     SIF.D_E_L_E_T_ = ' ' "
       cQuery := ChangeQuery(cQuery)

       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSIF,.T.,.T.)
       While (cTabSIF)->(!EOF())
             cStatus   := "1"
             dDataExtr := DTOS( STOD( (cTabSIF)->IF_DTPROC ) + 1 )
             cQuery := " "
             cQuery += " SELECT "
             cQuery += "     COUNT(*) SIGCONT "
             cQuery += " FROM "+RetSQLName("SIG")+" SIG "
             cQuery += " WHERE "
             cQuery += "     IG_FILIAL = '" + cFilSIG   + "'  AND "
             cQuery += "     IG_IDPROC = '" + (cTabSIF)->IF_IDPROC + "'        AND "
             //cQuery += "     IG_DTEXTR = '" + dDataExtr + "' AND "
             cQuery += "     SIG.D_E_L_E_T_ = ' ' "
             cQuery := ChangeQuery(cQuery)

             dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSIG,.T.,.T.)
             If (cTabSIG)->(!EOF())
                nTotal := (cTabSIG)->SIGCONT
             EndIf
             (cTabSIG)->(dbCloseArea())

             cQuery := " "
             cQuery += " SELECT "
             cQuery += "     COUNT(*) SIGCONT "
             cQuery += " FROM "+RetSQLName("SIG")+" SIG "
             cQuery += " WHERE "
             cQuery += "     IG_FILIAL = '" + cFilSIG + "'  AND "
             cQuery += "     IG_IDPROC = '" + (cTabSIF)->IF_IDPROC + "'        AND "
             cQuery += "     IG_STATUS = '1'        		AND "
             cQuery += "     SIG.D_E_L_E_T_ = ' ' "
             cQuery := ChangeQuery(cQuery)

             dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSIG,.T.,.T.)

             If (cTabSIG)->(!EOF())
                nNaoConc := (cTabSIG)->SIGCONT
             EndIf
             (cTabSIG)->(dbCloseArea())

             If nNaoConc == 0 // Totalmente conciliado
                cStatus := '3'
             ElseIf nNaoConc < nTotal // Conciliado Parcialmente
                    cStatus := '2'
             EndIf
             //Atualiza os Status da tabela SIF
             DbSelectArea("SIF")
             SIF->( DbSetOrder( 1 ) )
             If SIF->( DbSeek( xFilial('SIF') + (cTabSIF)->IF_IDPROC ) )
                RecLock("SIF",.F.)
                   SIF->IF_STATUS := cStatus
                SIF->( MsUnLock() )
             Endif
             DbSelectArea( cTabSIF )
             (cTabSIF)->( DbSkip() )
       EndDo
       DbSelectArea( cTabSIF )
       (cTabSIF)->( DbCloseArea() )

Return
