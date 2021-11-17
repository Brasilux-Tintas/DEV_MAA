#INCLUDE 'totvs.ch'
#INCLUDE 'protheus.ch'
#INCLUDE 'TAFCSS.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'shell.ch'

#DEFINE MAX_BUFFER 21

/*/{Protheus.doc} ZPCPA01
   Chamada principal do apontamento de produção
    @type Function
    @author user
    @since 05/05/2020
    @version 2020.01
    @param _cParam, Character, Parametro do atalho para indicar grupo, empresa/filial
    @example
    Caminho do atalho: C:\Protheus_HOM\smartclient.exe -M -p=u_zpcpa01 -a="010101011" -c=GUSTAVO -e=GUSTAVO -q
    Onde: -M=Permite multiplas instancias
          -P=Programa inicial (Função)
          -A=Passagem de parâmetro para o programa
          -C=Concexão
          -E=Ambiente do servidor
          -Q=Não mostra a tela do splash
    /*/
User Function ZPCPA01( _cParam )
     Local _oDlgApt, _oSay1Loc, _oSay2Loc, _oLayer, _oApontamento
     Local _oSize        := FWDefSize():New(.F.)
     Private _oFontApt    := TFont():New( "MS Sans Serif", 0, -19, , .T., 0, , 700, .F., .F., , , , , , )
     Private _oFontLeg    := TFont():New( "MS Sans Serif", 0, -12, , .T.) 
     
     Private _cGet1Ord    := Space(11)
     Private _oGet1Ord
     Private _oGetGer01, _oGetGer02, _oGetGer03, _oGetGer04, _oGetGer05, _oGetGer06, _oGetGer07
     Private _oGetIte01, _oGetIte02, _oGetIte03, _oGetIte04
     Private _oBtnDApt, _oBtPeso
     Private _lSair       := .f.
     Private _aRotApt     := { }
     Private _aBrwIte     := { }
     Private _aBrwRes     := { }
     Private _oPreto      := LoadBitmap( GetResources(), 'BR_PRETO'   ) //Não iniciada
     Private _oVerde      := LoadBitmap( GetResources(), 'BR_VERDE'   ) //Iniciada
     Private _oAmarelo    := LoadBitmap( GetResources(), 'BR_AMARELO' ) //Pausada
     Private _oVermelho   := LoadBitmap( GetResources(), 'BR_VERMELHO') //Finalizada
     Private _oAzul       := LoadBitmap( GetResources(), 'BR_AZUL'    ) //Conferência
     Private _cMVBLQOPSA, _cMVXLIBOPE, _lZPPAR9999, _cMVXHABZZ
     /*+-----------------------------------------------------+
       | Abertura de Empresa                                 |
       +-----------------------------------------------------+*/

     If Empty( _cParam )
        _cParam := '010101011'
     Endif
     OpenSm0( SubStr( _cParam, 1, 2 ) )
     DbSelectArea('SM0')
     SM0->( DbSetOrder( 1 ) )
     SM0->( DbSeek( SubStr( _cParam, 1, 8 ) ) )
     
     PREPARE ENVIRONMENT EMPRESA SubStr( _cParam, 1, 2 ) FILIAL SubStr( _cParam, 3, 6 ) MODULO 'PCP'

     _cFabrica    := Iif( !Empty( SubStr( _cParam, 9 ) ), 'FABRICA - ' + SubStr( _cParam, 9 ), '' )
     _aFabrica    := GetStringPixSize( _cFabrica, "MS Sans Serif", -19, .T. )
     _cNFilial    := Alltrim( SM0->M0_FILIAL )
     _aNFilial    := GetStringPixSize( _cNFilial, "MS Sans Serif", -19, .T. )
     _cMVBLQOPSA  := Alltrim( GETMV( "MV_BLQOPSA" ) )
     _cMVXLIBOPE  := GetMv("MV_XLIBOPE")
     _lZPPAR9999  := GetMv( "ZP_PAR0024" , .F. , .F. ) //Parametro que indica se faz debug na pesagem da balança para correção de problemas
     _cMVXHABZZ   := getMV("MV_XHABZZF")
     _lMVVEREST   := Alltrim(GETMV("MV_VERESTI")) $ 'S'

     /*+-----------------------------------------------------+
       | Teste para montagem de conexão com o Banco de dados |
       +-----------------------------------------------------+*/
     _oSize:lLateral := .F.
     _oSize:AddObject( "LAYER", 100, 100, .T., .T. )
     DEFINE DIALOG _oDlgApt TITLE "Apontamento de produção v.01/2020" FROM 0, 0 TO 480, 300 STYLE nOr( WS_VISIBLE, WS_POPUP ) PIXEL
            _oLayer       := FWLayer():New()
            _oLayer:Init( _oDlgApt, .F. )
            _oLayer:AddLine( "LINE01", 100) 
            _oLayer:AddCollumn( "BOX_UNICO", 100, , "LINE01")           
            _oLayer:AddWindow( "BOX_UNICO", "PANEL01", "Apontamento de produção v.01/2020"     , 100, .F., , , "LINE01" )
            _oApontamento := _oLayer:GetWinPanel( "BOX_UNICO", "PANEL01", "LINE01" )

            _oGet1Ord   := TGet():New( 002, 002, {|u| If(PCount() > 0, _cGet1Ord := u, _cGet1Ord ) }, _oApontamento, 100, 013, '@!R XXXXXX-99-999', { || Iif( !Empty( _cGet1Ord ) .and. Len(Alltrim(_cGet1Ord)) <= 11, fVerOrdPro(), ) }, CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .F., .F.,   , _cGet1Ord, , , , , , , 'Informe o numero da OP', 1, _oFontApt, CLR_BLUE, '<Ordem de produção>', .T.)

            _oSay1Loc     := TSay():New( _oApontamento:nClientHeight * 0.20, ( _oApontamento:nWidth * 0.25 ) - ( _aFabrica[2] * 0.5 ), {|| _cFabrica }, _oApontamento, , _oFontApt, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, _aFabrica[2], 036, , , , , , , 2, 2 )
            _oSay2Loc     := TSay():New( _oApontamento:nClientHeight * 0.25, ( _oApontamento:nWidth * 0.25 ) - ( _aNFilial[2] * 0.5 ), {|| _cNFilial }, _oApontamento, , _oFontApt, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, _aNFilial[2], 036, , , , , , , 2, 2 )

            _oBtnDApt   := TButton():New( 234, 108, "Sair", _oDlgApt, { | | _oDlgApt:End() }, 037, 012, , , .F., .T., .F., "", .F., , , .F. )

            _oGet1Ord:SetFocus( )

     ACTIVATE DIALOG _oDlgApt CENTERED

Return

/*/{Protheus.doc} fVerOrdPro
Validação e montagem dos dados da ordem de produção a ser apontada.
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 23/05/2020
@return Logical, Retorna o conteudo das itens validados
/*/
Static Function fVerOrdPro()
       Local _lRet          := .t.
       Private _aAptAtu     := {}
       Private _cGet2Lot    := space(06)
       Private _nGet3Qtd    := 0
       Private _nGet1Ite    := 0
       Private _nGet2Ite    := 0
       Private _nGet3Ite    := 0
       Private _nGet4Ite    := 0
       Private _nGet4Pes    := 0
       Private _cGet5Cod    := space(15)
       Private _cGet6Des    := space(40)
       Private _cGet7Tip    := space(02)
       Private _cGet8Est    := space(01)
       Private _cGet9UnM    := space(02)
       Private _cGetALoc    := space(02)
       Private _nGet7Tar    := 0
       Private _cRetSup     := space(25)
       Private _cGet1Ope    := space(02)
       Private _cMaxTRT     := ""
       Private _lEstNegat   := .f.
       Private _aUsrAut     := {}
       Private _aUsrExc     := {}
       Private _lReserva    := GETMV( "ZP_PAR0028" )
       Public  _lSaldoIns   := .f. //Variável para tratar apontamento do empenho com o saldo insuficiente e não deixar gravar a baixa

       _oGet1Ord:lReadOnly := .t.
       If Empty( _cGet1Ord )
          //MESSAGEBOX( "Informe uma ordem de produção válida.", "Atenção", 48 )
          _lRet := .f.
       else
          If Len( Alltrim( _cGet1Ord ) ) == 6
             _cGet1Ord := _cGet1Ord + '01001'
             _oGet1Ord:Refresh()
          Endif
       Endif 
       /* +--------------------------------------+
          | Busca ordem de produção              |
          +--------------------------------------+*/
       If _lRet
          DbSelectArea("SC2")
          SC2->( DbSetOrder( 1 ) )
          If !SC2->( DbSeek( xFilial("SC2") + _cGet1Ord ) )
             MESSAGEBOX( "Ordem de produção não encontrada.", "Atenção", 16 )
             _lRet := .f.
          else
             If SC2->C2_QUJE <> 0 .and. !Empty( SC2->C2_DATRF )  //VERIFICAÇÃO DE ORDEM DE PRODUÇÃO JÁ FINALIZADA
                MessageBox( 'Ordem de produção já encerrada!', 'Atenção', 48 )
                _lRet := .f.
             Else
                _cGet2Lot := SC2->C2_LOTE
                _nGet3Qtd := SC2->C2_QUANT
                _cGet1Ope := SC2->C2_ROTEIRO
             Endif
          Endif
       Endif
       /* +--------------------------------------+
          | Posiciona no produto da Ordem        |
          +--------------------------------------+*/
       If _lRet
          DbSelectArea("SB1")
          SB1->( DbSetOrder( 1 ) )
          SB1->( DbSeek( xFilial( "SB1" ) + SC2->C2_PRODUTO ) )
          If SB1->B1_MSBLQL == '1'
             Messagebox( "Produto bloqueado não pode ser apontado.", "Atenção....", 48 )
             _lRet := .f.
          else
             If !SB1->B1_TIPO == 'PI'
                Messagebox( "Esse produto não é o produto principal da OP.", "Atenção....", 48 )
                _lRet := .f.
             Else
                _nGet4Pes := Round( SB1->B1_PESOESP, 3 )
                _cGet5Cod := SB1->B1_COD
                _cGet6Des := SB1->B1_DESC
                _cGet7Tip := SB1->B1_TIPO
                _cGet8Est := SB1->B1_ESTOQUE
                _cGet9UnM := SB1->B1_UM
                _cGetALoc := SB1->B1_LOCPAD
             Endif
          Endif
       Endif
       /* +------------------------------------------+
          | Posiciona no Apontamento e monta Roteiro |
          +------------------------------------------+
          Configuração do Array "_aRotApt" - Roteiro
         [ 1] - Tabela Origem
         [ 2] - Status Operação
         [ 3] - Operação
         [ 4] - Descrição
         [ 5] - Data e Hora inicio
         [ 6] - Data e Hora final
         [ 7] - Pesagem no final do Processo ?
         [ 8] - Processo já foi pesado ?
         [ 9] - Tira Tara do tacho
         [10] - Recurso
         [11] - Peso Conferido
         [12] - Pesquisa para Responsável
         [13] - Status
          */

       _aRotApt := {}
       If _lRet
          DbSelectArea("ZZA")
          ZZA->( DbSetOrder( 2 ) )
          If ZZA->( DbSeek( xFilial("ZZA" ) + SC2->C2_OP ) )
             _nGet7Tar := Round( ZZA->ZZA_TARA, 3 )
             While !Eof() .and. ZZA->ZZA_ORDEM == SC2->C2_OP
                   _cConfPeso := Iif( ZZA->ZZA_FLAG == '3', 'N', Posicione( "SG2", 1, xFilial("SG2") + SC2->C2_PRODUTO + SC2->C2_ROTEIRO + ZZA->ZZA_OPERAC, 'G2_X_CONFP') )
                   _cPesqFase := Posicione( "SG2", 1, xFilial("SG2") + SC2->C2_PRODUTO + SC2->C2_ROTEIRO + ZZA->ZZA_OPERAC, 'G2_X_PESQR')
                   _lConfPeso := Iif( Iif( _cPesqFase == 'XXB', ZZA->ZZA_PESAPB, ZZA->ZZA_PESAPU ) > 0, .t., .f. )
                   aAdd( _aRotApt, { 'ZZA'          ,; //01
                                     ZZA->ZZA_FLAG  ,; //02
                                     ZZA->ZZA_OPERAC,; //03
                                     Posicione( "SG2", 1, xFilial("SG2") + SC2->C2_PRODUTO + SC2->C2_ROTEIRO + ZZA->ZZA_OPERAC, 'G2_DESCRI' ),; //04
                                     Iif( Empty( ZZA->ZZA_DTINI ), '', DTOC( ZZA->ZZA_DTINI ) + ' - ' + Stuff( ZZA->ZZA_HINI, 3, 0, ':' ) )  ,; //05
                                     Iif( Empty( ZZA->ZZA_DTFIM ), '', DTOC( ZZA->ZZA_DTFIM ) + ' - ' + Stuff( ZZA->ZZA_HFIM, 3, 0, ':' ) )  ,; //06
                                     _cConfPeso     ,; //07
                                     ''             ,; //08
                                     'S'            ,; //09
                                     ZZA->ZZA_ID    ,; //10
                                     Iif( _cPesqFase == 'XXB', ZZA->ZZA_PESAPB, Iif( _cPesqFase == 'XXL', ZZA->ZZA_PESAPU, 0 ) ),; //11
                                     _cPesqFase     ,; //12
                                     Iif( ZZA->ZZA_FLAG == '0', _oPreto, Iif( ZZA->ZZA_FLAG == '1', _oVerde, Iif( ZZA->ZZA_FLAG == '2' .and. _cConfPeso == 'S' .and. _lConfPeso, _oVermelho, Iif( ZZA->ZZA_FLAG == '2' .and. _cConfPeso <> 'S', _oVermelho, Iif( ZZA->ZZA_FLAG == '3', _oAmarelo, _oAzul ) ) ) ) ),; //13
                                     ZZA->ZZA_SEQENV } ) //14-Sequencia de operações - Campo ZZA_SEQENV
                   ZZA->( DbSelectArea( "ZZA" ) )
                   ZZA->( DbSkip( ) )
             EndDo
             aSort( _aRotApt, , , { |x, y| x[3] + x[14] < y[3] + y[14] } )
          else //Ordem ainda não foi baixada.
             /* +--------------------------------------------------------------+
                | Se não encontrou roteiro no apontamento Busca roteiro padrão |
                +--------------------------------------------------------------+*/
             DbSelectArea( "SG2" )
             SG2->( DbSetOrder( 1 ) )
             If SG2->( DbSeek( xFilial("SG2") + SC2->C2_PRODUTO + SC2->C2_ROTEIRO ))
                While !Eof() .and. SG2->G2_PRODUTO == SC2->C2_PRODUTO .and. SG2->G2_CODIGO == SC2->C2_ROTEIRO
                      aAdd( _aRotApt, { 'SG2'          ,; //01
                                        '0'            ,; //02
                                        SG2->G2_OPERAC ,; //03
                                        SG2->G2_DESCRI ,; //04
                                        ''             ,; //05
                                        ''             ,; //06 
                                        SG2->G2_X_CONFP,; //07
                                        ''             ,; //08
                                        'S'            ,; //09
                                        SG2->G2_RECURSO,; //10
                                        0              ,; //11
                                        SG2->G2_X_PESQR,; //12
                                        _oPreto        ,; //13
                                        '01'           }) //14

                      SG2->( DbSelectArea( "SG2" ) )
                      SG2->( DbSkip( ) )
                EndDo
             Endif
          Endif
          /*+--------------------------------------------------+
            | Verificar operações baixadas                     |
            +--------------------------------------------------+*/
          If _lRet
             DbSelectArea("SH6")
             SH6->( DbSetOrder( 1 ) )
             If SH6->( DbSeek( xFilial( "SH6" ) + SC2->C2_OP ) )
                
             Endif
          Endif
          /*+--------------------------------------------------+
            | Verifico se o array das Operações foi preenchido |
            +--------------------------------------------------+*/
          If Len( _aRotApt ) <= 0
             MESSAGEBOX( "Atenção, não existem cadastros de roteiros.", "Atenção", 16 )
             _lRet := .f.
          Endif
       Endif
       If _lRet
          //Posiciona o apontamento atual
          _aAptAtu := fBusAptAtu( )
          _lRet := _aAptAtu[3]
          //Se for inicio de produção executar as validações abaixo
          If _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'I' 
             If _lRet
                //Validar se existem novos pedidos e ordem de produção do mesmo produto
                If _cGet7Tip == 'PI' .and. Len( Alltrim( SC2->C2_PRODUTO ) ) == 12
                   If _cMVXLIBOPE 
                      _lRet := fVerPedApr()
                   Endif
                   If _lRet
                      _lRet := fVerMaiOrd()
                   Endif
                Endif
             Endif
             If _cMVBLQOPSA $ 'S'  // verificar falta de saldo e se existe necessidade maior neste momento chamado 007858
                If fBloqOpSal()
                   Messagebox("Ordem de Produção não será iniciada por falta de saldo disponível!","Atenção...",48)
                   _lRet := .f.
                Endif
             Endif
          Endif
       Endif
       If _lRet
          _aBrwIte := {}
          _aBrwRes := {}
          /* LEGADO DO PROGRAMA ANTIGO - BRPCPA08
           aAdd( aFds , {"MARC", "C", 002, 000} )
           aAdd( aFds , {"ITEM", "C", 015, 000} ) 01 - CODIGO/ITEM             SD4->D4_COD     / ZZF_CODIGO 
           aAdd( aFds , {"SEQU", "C", 003, 000} ) 02 - SEQUENCIA               SD4->D4_TRT     / ZZF_TRT
           aAdd( aFds , {"QTSO", "N", 011, 004} ) 03 - QUANTIDADE SOLICITADA   SD4->D4_QTDEORI / ZZF_QTDORI
           aAdd( aFds , {"QTUS", "N", 011, 004} ) 04 - QUANTIDADE USADA        SD4->D4_QUANT   / ZZF_QTDUSA
           aAdd( aFds , {"TPEM", "C", 001, 000} ) 05 - TIPO EMPENHO            'P'             / ZZF_TIPEMP
           aAdd( aFds , {"ARMZ", "C", 002, 000} ) 06 - ARMAZEM                 SD4->D4_LOCAL   / ZZF_LOCAL
           aAdd( aFds , {"ACER", "N", 007, 003} ) 07 - ACERTO COR              SD4->D4_ACECOR  /
           aAdd( aFds , {"DSCR", "C", 020, 000} ) 08 - DESCRIÇÃO
           aAdd( aFds , {"VISI", "C", 001, 000} ) 09 - VISIVEL
           aAdd( aFds , {"ORIG", "C", 002, 000} ) 10 - ORIGINAL                                / ZZF_ORIGIN
           aAdd( aFds , {"FLAG", "C", 001, 000} ) 11 - FLAG                    1=Baixado
           aAdd( aFds , {"SLDE", "N", 014, 003} ) SALDO                   SB2->B2_QATU
           aAdd( aFds , {"SLDR", "N", 014, 003} ) RESERVA                 SB2->B2_RESERVA
           aAdd( aFds , {"DISP", "N", 014, 003} ) DISPONIVEL              SALDO - RESERVA
           aAdd( aFds , {"LCBX", "C", 002, 000} ) LOCAL DA BAIXA          SD4->D4_LOCAL
           aAdd( aFds , {"INCL", "C", 002, 000} )
           aAdd( aFds , {"TIPO", "C", 002, 000} )
                                                   / ZZF_OPERAC */
          
          //Posiciono no cadastro de linhas
          DbSelectArea("SZ1")
          SZ1->( DbSetOrder( 1 ) )
          SZ1->( DbSeek( xFilial("SZ1") + SubStr( SC2->C2_PRODUTO, 4, 2 ) ) )
          _cProdRet := SZ1->Z1_PRODRET
          _cProdFil := SZ1->Z1_CODFILT
          _nGet2Ite := _nGet7Tar
          DbSelectArea("ZZF")
          ZZF->( DbSetOrder( 1 ) )
          If ZZF->( DbSeek( xFilial("ZZF") + SC2->C2_OP ) )
             While !Eof() .and. ZZF->ZZF_ORDEM == SC2->C2_OP
                   _nQtdAtu := 0
                   _nQtdRes := 0

                   DBSelectArea("SB1")
                   SB1->( DbSetOrder( 1 ) )
                   SB1->( DbSeek( xFilial("SB1") + ZZF->ZZF_CODIGO ) )

                   DbSelectArea("SB2")
                   SB2->( DbSetOrder( 1 ) )
                   If SB2->( DbSeek( xFilial("SB2") + ZZF->ZZF_CODIGO + ZZF->ZZF_LOCAL ) )
                      _nQtdAtu := Round( SB2->B2_QATU, 3 )
                   Endif
                   If SB1->B1_TIPO == 'MP'
                      _cLocEmp := '01'
                   ElseIf SB1->B1_TIPO == 'PI'
                          _cLocEmp := '02'
                   Else
                      _cLocEmp := '03'
                   Endif
                   If SB2->( DbSeek( xFilial("SB2") + ZZF->ZZF_CODIGO + _cLocEmp ) )
                      _nQtdRes := Round( Iif( _lReserva, SB2->B2_RESERVA, 0 ), 3 )
                   Endif
                   If ZZF->ZZF_TIPEMP == 'O'
                      _cDescFase := StrTokArr( Posicione( "SG2", 1, xFilial("SG2") + SC2->C2_PRODUTO + SC2->C2_ROTEIRO + ZZF->ZZF_OPERAC, "G2_DESCRI" ), ' ' )[1]
                   Endif
                   If ZZF->ZZF_ORIGIN <> 'E'
                      aAdd( _aBrwIte, { ZZF->ZZF_CODIGO             ,; //01 - Codigo do Produto
                                        ZZF->ZZF_TRT                ,; //02 - Sequencia da Fórmula
                                        ZZF->ZZF_QTDORI             ,; //03 - Quantidade Original empenhada
                                        Iif( ZZF->ZZF_FLAG == '1', ZZF->ZZF_QTDUSA, 0 ) /*ZZF->ZZF_QTDUSA*/       ,; //04 - Quantidade Usada
                                        ZZF->ZZF_TIPEMP             ,; //05 - Tipo do empenho (P=PESAGEM / C=TINGIMENTO / L=LABORATORIO / O=OUTRAS OPERACOES (SEGUIR ZZF_OPERAC-ITEM 17 DESSE ARRAY))
                                        ZZF->ZZF_LOCAL              ,; //06 - Local para baixa (Armazem)
                                        0                           ,; //07 - Acerto de COR - Campo mantido por compatibilidade
                                        Iif( ZZF->ZZF_TIPEMP == 'P', 'PESAGEM', Iif( ZZF->ZZF_TIPEMP == 'C', 'TINGIMENTO', Iif( ZZF->ZZF_TIPEMP == 'L', 'LABORATORIO', _cDescFase ) ) ),; //08 - Descrição da Etapa
                                        'S'                         ,; //09 - S=Visivel / N=Nao Visivel - Campo mantido por compatibilidade
                                        SubStr( ZZF->ZZF_OBS, 1, 2 ),; //10 - Empenho Original S-Sim/SA=Acerto de Cor/SE=Empenho SD4/N=Incluido
                                        ZZF->ZZF_FLAG               ,; //11 - 1=Baixado / 2=Nao Baixado
                                        _nQtdAtu                    ,; //12 - Saldo Atual
                                        _nQtdRes                    ,; //13 - Reservado
                                        _nQtdAtu - _nQtdRes         ,; //14 - Disponivel
                                                                    ,; //15 - 
                                        SB1->B1_TIPO                ,; //16 - Tipo do Produto
                                        ZZF->ZZF_OPERAC             ,; //17 - Operação
                                        ZZF->ZZF_QTDUSA             }) //18 - Valor a pesar - Criado no caso de alteração pelo quimico
                      _nGet1Ite += Iif( ZZF->ZZF_FLAG == '1', ZZF->ZZF_QTDUSA, Iif( ( _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'F' ) .or. ( _aRotApt[ _aAptAtu[1] ][ 14 ] <> '01' ) , 0, Round( ZZF->ZZF_QTDUSA, 3 ) ) )
                      _nGet2Ite += Iif( ZZF->ZZF_FLAG == '1', ZZF->ZZF_QTDUSA, Iif( ( _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'F' ) .or. ( _aRotApt[ _aAptAtu[1] ][ 14 ] <> '01' ) , 0, Round( ZZF->ZZF_QTDUSA, 3 ) ) )
                      _lEstNegat := Iif( _lEstNegat, _lEstNegat, Iif( ( _nQtdAtu - _nQtdRes ) < 0, .t., .f. ) )
                      //Verifica ultima sequencia
                      _cMaxTRT := Iif( Val( ZZF->ZZF_TRT ) > Val( _cMaxTRT ), ZZF->ZZF_TRT, _cMaxTRT )
                   Endif
                   DbSelectArea("ZZF")
                   ZZF->(DbSkip( ) )
             EndDo
          else
             DbSelectArea("SD4")
             SD4->( DbSetOrder( 8 ) )
             If SD4->( DbSeek( xFilial("SD4") + SC2->C2_OP ) )
                While !Eof() .and. SD4->D4_FILIAL == xFilial("SD4") .and. Alltrim( SD4->D4_OP ) == Alltrim( SC2->C2_OP )
                      _nQtdAtu := 0
                      _nQtdRes := 0

                      DBSelectArea("SB1")
                      SB1->( DbSetOrder( 1 ) )
                      SB1->( DbSeek( xFilial("SB1") + SD4->D4_COD ) )

                      DbSelectArea("SB2")
                      SB2->( DbSetOrder( 1 ) )
                      If SB2->( DbSeek( xFilial("SB2") + SD4->D4_COD + SD4->D4_LOCAL ) )
                         _nQtdAtu := Round( SB2->B2_QATU, 3 )
                      Endif
                      If SB1->B1_TIPO == 'MP'
                         _cLocEmp := '01'
                      ElseIf SB1->B1_TIPO == 'PI'
                             _cLocEmp := '02'
                      Else
                         _cLocEmp := '03'
                      Endif
                      If SB2->( DbSeek( xFilial("SB2") + SD4->D4_COD + _cLocEmp ) )
                         _nQtdRes := Round( Iif( _lReserva, SB2->B2_RESERVA, 0 ), 3 )
                      Endif
                      If !SubStr( SD4->D4_COD, 1, 3 ) $ 'GGF.MOD'
                         If SD4->D4_ACECOR > 0 //MANTIDO POR COMPATIBILIDADE, POIS ACERTO DE COR NÃO É MAIS UTILIZADO
                            aAdd( _aBrwIte, { SD4->D4_COD               ,; //01 - Codigo do Produto
                                              SD4->D4_TRT               ,; //02 - Sequencia da Fórmula
                                              Round( SD4->D4_ACECOR, 3 ),; //03 - Quantidade Original empenhada
                                              Round( SD4->D4_ACECOR, 3 ),; //04 - Quantidade Usada
                                              'C'                       ,; //05 - Tipo do empenho (P=PESAGEM / C=TINGIMENTO / L=LABORATORIO / O=OUTRAS OPERACOES (SEGUIR ZZF_OPERAC-ITEM 17 DESSE ARRAY))
                                              SD4->D4_LOCAL             ,; //06 - Local para baixa (Armazem)
                                              Round( SD4->D4_ACECOR, 3 ),; //07 - Acerto de COR - Campo mantido por compatibilidade
                                              'TINGIMENTO'              ,; //08 - Descrição da Etapa
                                              'N'                       ,; //09 - S=Visivel / N=Nao Visivel - Campo mantido por compatibilidade
                                              'SA'                      ,; //10 - Empenho Original S-Sim/SA=Acerto de Cor/SE=Empenho SD4/N=Incluido
                                              '2'                       ,; //11 - 1=Baixado / 2=Nao Baixado
                                              _nQtdAtu                  ,; //12 - Saldo Atual
                                              _nQtdRes                  ,; //13 - Reservado
                                              _nQtdAtu - _nQtdRes       ,; //14 - Disponivel
                                                                        ,; //15 - 
                                              SB1->B1_TIPO              ,; //16 - Tipo do Produto
                                              _aRotApt[_aAptAtu[1]][3]  ,; //17 - Operação
                                              Round( SD4->D4_ACECOR, 3 )}) //18 - Quantidade Solicitada
   
                            _nGet1Ite += Round( SD4->D4_ACECOR, 3 )
                            _nGet2Ite += Round( SD4->D4_ACECOR, 3 )
                         Endif
                         If SD4->D4_QTDEORI > 0
                            aAdd( _aBrwIte, { SD4->D4_COD                ,; //01 - Codigo do Produto
                                              SD4->D4_TRT                ,; //02 - Sequencia da Fórmula
                                              Round( SD4->D4_QTDEORI, 3 ),; //03 - Quantidade Original empenhada
                                              Round( SD4->D4_QUANT, 3 )  ,; //04 - Quantidade Usada
                                              'P'                        ,; //05 - Tipo do empenho (P=PESAGEM / C=TINGIMENTO / L=LABORATORIO / O=OUTRAS OPERACOES (SEGUIR ZZF_OPERAC-ITEM 17 DESSE ARRAY))
                                              SD4->D4_LOCAL              ,; //06 - Local para baixa (Armazem)
                                              0                          ,; //07 - Acerto de COR - Campo mantido por compatibilidade
                                              'PESAGEM'                  ,; //08 - Descrição da Etapa
                                              'S'                        ,; //09 - S=Visivel / N=Nao Visivel - Campo mantido por compatibilidade
                                              'SE'                       ,; //10 - Empenho Original S-Sim/SA=Acerto de Cor/SE=Empenho SD4/N=Incluido
                                              '2'                        ,; //11 - 1=Baixado / 2=Nao Baixado
                                              _nQtdAtu                   ,; //12 - Saldo Atual
                                              _nQtdRes                   ,; //13 - Reservado
                                              _nQtdAtu - _nQtdRes        ,; //14 - Disponivel
                                                                         ,; //15 -
                                              SB1->B1_TIPO               ,; //16 - Tipo do Produto
                                              _aRotApt[_aAptAtu[1]][3]   ,; //17 - Operação
                                              Round( SD4->D4_QUANT, 3 )  }) //18 - Quantidade solicitada
                            _nGet1Ite += Round( SD4->D4_QTDEORI, 3 )
                            _nGet2Ite += Round( SD4->D4_QTDEORI, 3 )
                         Endif
                         If !_lEstNegat
                            _lEstNegat := Iif( _lEstNegat, _lEstNegat, Iif( ( _nQtdAtu - _nQtdRes ) < Round( SD4->D4_QUANT, 3 ), .t., .f. ) )
                         Endif
                         //Verifica ultima sequencia
                         _cMaxTRT := Iif( Val( SD4->D4_TRT ) > Val( _cMaxTRT ), SD4->D4_TRT, _cMaxTRT )
                      Endif
                      DbSelectArea("SD4")
                      SD4->( DbSkip( ) )
                EndDo 
             Endif
          Endif
          aSort( _aBrwIte, , , { |x, y| x[2] < y[2] } )
          
          /*
          _cTipUser: B=Balanceiro
                     P=Conferente Pesagem -
                     C=Colorista
                     L=Laboratorio
          */
          //Considerar o B=Balanceiro e P=Conferende da pesagem como o mesmo, conforme determinado pelo Gustavo Diniz em reunião de apresentação da tela
          //_cTipUser := Iif( _aRotApt[_aAptAtu[1]][12] == 'XXB', IIF( _aAptAtu[2] <> 'C', 'B' , 'P' ), Iif( _aRotApt[_aAptAtu[1]][12] == 'XXC', 'C', Iif( _aRotApt[_aAptAtu[1]][12] == 'XXL', IIF( _aAptAtu[2] <> 'C', 'L' , 'F' ), 'O' ) ) )
          _cTipUser := Iif( _aRotApt[_aAptAtu[1]][12] == 'XXB', IIF( _aAptAtu[2] <> 'C', 'B' , 'B' ), Iif( _aRotApt[_aAptAtu[1]][12] == 'XXC', 'C', Iif( _aRotApt[_aAptAtu[1]][12] == 'XXL', IIF( _aAptAtu[2] <> 'C', 'L' , 'F' ), 'O' ) ) )
          DbSelectArea("ZZG")
          ZZG->( DbSetOrder( 7 ) ) //FILIAL + ORDEM + OPERACAO + TPUSER + MATRICULA
          If ZZG->( DbSeek( xFilial("ZZG") + SC2->C2_OP + _aRotApt[_aAptAtu[1]][3] + _cTipUser ) )
             While !Eof() .and. ZZG->ZZG_ORDEM == SC2->C2_OP .AND. ZZG->ZZG_OPERAC == _aRotApt[_aAptAtu[1]][3] .AND. ZZG->ZZG_TPUSER == _cTipUser
                   aAdd( _aBrwRes, { ZZG->ZZG_FILMAT, ZZG->ZZG_NOME } )
                   DbSelectArea("ZZG")
                   ZZG->( DbSkip() )
             EndDo
          else
             aAdd( _aBrwRes, { space(6), space(40) } )
          Endif
       Endif
       If !_lRet
          _cGet1Ord := Space(11)
          _oGet1Ord:lReadOnly := .f.
          _oGet1Ord:Refresh()
          _oGet1Ord:Setfocus()
       Else
          PCPA01_1( ) //Chamada principal para apontamentos
          _cGet1Ord := Space(11)
          _oGet1Ord:lReadOnly := .f.
          _oGet1Ord:Refresh()
          _oGet1Ord:Setfocus()
       Endif
Return _lRet


Static Function PCPA01_1( )
       Local _oSize      := FWDefSize():New(.F.)
       Local _oLayer
       Local _nTop       := 0
       Local _nLeft      := 0
       Local _nBottom    := 0
       Local _nRight     := 0
       Local _aScreenRes := GetScreenRes()
       Private _oDlgOpe, _oTimeCro, _oSayGet02, _oMGetOp
       Private _cCrono   := "00:00"
       Private _cMGet1Op := ""

       _oSize:lLateral := .T.
       _oSize:AddObject( "LAYER", 100, 100, .T., .T. )
     
       _oSize:Process()
       If _oSize:aWindSize[1] == 0
          _oSize:aWindSize[1] := 8
       Endif
       If _oSize:aWindSize[2] == 0
          _oSize:aWindSize[2] := 8
       Endif
       If _oSize:aWindSize[3] == 0
          _oSize:aWindSize[3] := _aScreenRes[2]
       Endif
       If _oSize:aWindSize[4] == 0
          _oSize:aWindSize[4] := _aScreenRes[1]
       Endif
       _nTop    := _oSize:aWindSize[1] - ( _oSize:aWindSize[1] * 0.02 )
       _nLeft   := _oSize:aWindSize[2] - ( _oSize:aWindSize[2] * 0.08 )
       _nBottom := _oSize:aWindSize[3] - ( _oSize:aWindSize[3] * 0.20 )
       _nRight  := _oSize:aWindSize[4] - ( _oSize:aWindSize[4] * 0.08 )

       DEFINE DIALOG _oDlgOpe TITLE "Apontamento de produção v.01/2020" FROM _nTop, _nLeft TO _nBottom, _nRight STYLE nOr( WS_VISIBLE, WS_POPUP ) PIXEL
  
              /*+--------------------------------------------+
                | Montagem do Painel Principal               |
                +--------------------------------------------+*/
              _oLayer := FWLayer():New()
              _oLayer:Init( _oDlgOpe, .F. )
              _oLayer:AddLine( "LINE01", 95)
              _oLayer:AddLine( "LINE02",  5)

              _oLayer:AddCollumn( "BOX_ESQUERDO", 30, , "LINE01")
              _oLayer:AddCollumn( "BOX_DIREITO1", 70, , "LINE01")

              _oLayer:AddWindow( "BOX_ESQUERDO", "PANEL01", "Operações"     , 100, .F., , , "LINE01" )
              _oLayer:AddWindow( "BOX_DIREITO1", "PANEL02", "Dados gerais"  ,  33, .F., , , "LINE01" )
              _oLayer:AddWindow( "BOX_DIREITO1", "PANEL03", "Materiais"     ,  43, .F., , , "LINE01" )
              _oLayer:AddWindow( "BOX_DIREITO1", "PANEL04", "Responsáveis"  ,  24, .F., , , "LINE01" )

              _oOperacoes := _oLayer:GetWinPanel( "BOX_ESQUERDO", "PANEL01", "LINE01" )
              _oDados     := _oLayer:GetWinPanel( "BOX_DIREITO1", "PANEL02", "LINE01" )
              _oMateriais := _oLayer:GetWinPanel( "BOX_DIREITO1", "PANEL03", "LINE01" )
              _oResponsav := _oLayer:GetWinPanel( "BOX_DIREITO1", "PANEL04", "LINE01" )
              _oRodape    := _oLayer:GetLinePanel( "LINE02" )

              /*+--------------------------------------------+
                | Montagem do Grid de Operações              |
                +--------------------------------------------+*/
              _oGetOpe01 := TGet():New( 004, 002, {|u| If( PCount() > 0, _cGet1Ope := u, _cGet1Ope ) }, _oOperacoes, 020, 013, '99', , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_cGet1Ope", , , , , , , 'Roteiro'   , 1, _oFontApt, CLR_BLUE, '<Ordem de produção>'    , .T. )
              _oGroupLeg := TGroup():New( 000, 033, 032, 175, 'Legenda', _oOperacoes, , , .T. )
              _oTBitmap1 := TBitmap():New(007, 040, 020, 020, 'BR_PRETO'   ,             , .T.          , _oGroupLeg,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
              _oTBitmap2 := TBitmap():New(015, 040, 020, 020, 'BR_VERDE'   ,             , .T.          , _oGroupLeg,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
              _oTBitmap3 := TBitmap():New(023, 040, 020, 020, 'BR_VERMELHO',             , .T.          , _oGroupLeg,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
              _oTBitmap4 := TBitmap():New(007, 120, 020, 020, 'BR_AMARELO' ,             , .T.          , _oGroupLeg,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
              _oTBitmap5 := TBitmap():New(015, 120, 020, 020, 'BR_AZUL'    ,             , .T.          , _oGroupLeg,               ,              , .F.        , .F.         ,            ,             , .F.         ,          , .T.       ,           , .F.         ,             ,              )
              _oSayOpe01   := TSay():New( 006, 050, {|| "Não Iniciada" }, _oGroupLeg, , _oFontLeg, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)
              _oSayOpe02   := TSay():New( 014, 050, {|| "Iniciada"     }, _oGroupLeg, , _oFontLeg, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)
              _oSayOpe03   := TSay():New( 022, 050, {|| "Finalizada"   }, _oGroupLeg, , _oFontLeg, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)
              _oSayOpe04   := TSay():New( 006, 130, {|| "Pausada"      }, _oGroupLeg, , _oFontLeg, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)
              _oSayOpe05   := TSay():New( 014, 130, {|| "Conferência"  }, _oGroupLeg, , _oFontLeg, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 060, 012)

              _oBrwOpe := TWBrowse():New( 034 , 002, ( _oOperacoes:nWidth )* 0.49, ( _oOperacoes:nHeight ) * 0.22, , {'','Op.','Descrição', 'Inicio', 'Fim'}, { 10, 20, 70, 50, 50 }, _oOperacoes, ,  , ,  , {||},  ,  ,  ,  ,  ,  , .F.,  , .T.,  ,   ,  , .T., .T. )
              _oBrwOpe:SetArray( _aRotApt )
              _oBrwOpe:bLine     := { || { _aRotApt[_oBrwOpe:nAt,13], _aRotApt[_oBrwOpe:nAt,03], _aRotApt[_oBrwOpe:nAt,04], _aRotApt[_oBrwOpe:nAt,05], _aRotApt[_oBrwOpe:nAt,06] } }
              _oBrwOpe:bChange   := { || _cMGet1Op := Alltrim( Posicione( "SG2", 1, FWxFilial("SG2") + _cGet5Cod + _cGet1Ope + _oBrwOpe:aArray[_oBrwOpe:nAt][3], "G2_ESPOP" ) ), _oMGetOp:Refresh() }
              _oMGetOp           := TMultiGet():New( 160, 002, { |u| If(PCount() > 0, _cMGet1Op := u, _cMGet1Op ) }, _oOperacoes, 174, 110, , , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., , )
              _oMGetOp:lReadOnly := .t.

             /*+--------------------------------------------+
               | Montagem dos Botões                        |
               +--------------------------------------------+*/
             _oBtCanc := TButton():New( 000, _oRodape:nClientWidth * 0.002   , "Cancelar"     , _oRodape   , { | | _oDlgOpe:End() } , 55, 12, , , .F., .T., .F., , .F., , , .F. )
             _oBtPeso := TButton():New( 000, _oRodape:nClientWidth * 0.151   , "Força Pesagem", _oRodape   ,  , 55, 12, , , .F., .T., .F., , .F., , , .F. )
             _oBtPeso:bAction := { | | MsgRun ( 'Aguarde pesagem...', 'Pesagem', {|| fPesaTara( Iif( _aAptAtu[2] <> 'C', 1, 2 ) ) } ) }
             If !( _aAptAtu[2] $ 'C.I' ) //Diferente de Conferencia e Inicio
                _oBtPara := TButton():New( 000, _oRodape:nClientWidth * 0.251   , "Parar Operação", _oRodape   ,  , 55, 12, , , .F., .T., .F., , .F., , , .F. )
                _oBtPara:bAction := { || fGrvAponta( 'P' ) }
             Endif
             _oBtApon := TButton():New( 000, _oRodape:nClientWidth * 0.445   , "Apontar"      , _oRodape   , { | | fGrvAponta('A')    } , 55, 12, , , .F., .T., .F., , .F., , , .F. )
             _oBtPeso:lVisible := .f.
             _oBtIteI := TButton():New( 000, _oMateriais:nClientWidth * 0.345, "<<-- INCLUIR" , _oMateriais, { | | fMntEmpPro( 0 ) }, 55, 12, , , .F., .T., .F., , .F., , , .F. )
             _oBtIteA := TButton():New( 015, _oMateriais:nClientWidth * 0.345, "<<-- ALTERAR" , _oMateriais, { | | fMntEmpPro( 1 ) }, 55, 12, , , .F., .T., .F., , .F., , , .F. )
             _oBtIteE := TButton():New( 030, _oMateriais:nClientWidth * 0.345, "<<-- EXCLUIR" , _oMateriais, { | | fMntEmpPro( 2 ) }, 55, 12, , , .F., .T., .F., , .F., , , .F. )
             If ( _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'F' ) .or. ( _aRotApt[ _aAptAtu[1] ][ 3 ] == '01' .and. _aRotApt[ _aAptAtu[1] ][ 14 ] <> '01' )
                _oBtIteP := TButton():New( 090, _oMateriais:nClientWidth * 0.345, "PESAGEM"   , _oMateriais, { | | RptStatus( { |oSay| fLerPeso( oSay ) }, "Processando", "Processando a rotina...") }, 55, 12, , , .F., .T., .F., , .F., , , .F. )
             Endif
             _oBtResI := TButton():New( 000, _oResponsav:nClientWidth * 0.345, "<<-- INCLUIR" , _oResponsav, { | | fMntFunApt( 0 ) }, 55, 12, , , .F., .T., .F., , .F., , , .F. )
             _oBtResE := TButton():New( 015, _oResponsav:nClientWidth * 0.345, "<<-- EXCLUIR" , _oResponsav, { | | fMntFunApt( 1 ) }, 55, 12, , , .F., .T., .F., , .F., , , .F. )

             /*+----------------------------------------+
               | Dados para gerais da Ordem de Produção |
               +----------------------------------------+*/
             _oGetGer01   := TGet():New( 001, 002, {|u| If( PCount() > 0, _cGet1Ord := u, _cGet1Ord ) }, _oDados, 100, 013, '@!R XXXXXX-99-999', , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_cGet1Ord", , , , , , , 'Ordem de Produção'   , 1, _oFontApt, CLR_BLUE, '<Ordem de produção>'    , .T. )
             _oGetGer02   := TGet():New( 001, 112, {|u| If( PCount() > 0, _cGet2Lot := u, _cGet2Lot ) }, _oDados, 050, 013, '@!R 999999'       , , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_cGet2Lot", , , , , , , 'Lote'                , 1, _oFontApt, CLR_BLUE, '<Lote de produção>'     , .T. )
             _oGetGer03   := TGet():New( 001, 172, {|u| If( PCount() > 0, _nGet3Qtd := u, _nGet3Qtd ) }, _oDados, 100, 013, '@E 999,999.999'   , , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_nGet3Qtd", , , , , , , 'Quantidade'          , 1, _oFontApt, CLR_BLUE, '<Quantidade do Lote>'   , .T. )
             _oGetGer04   := TGet():New( 001, 282, {|u| If( PCount() > 0, _nGet4Pes := u, _nGet4Pes ) }, _oDados, 100, 013, '@E 9.999'         , , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_nGet4Qtd", , , , , , , 'P.Especifico'        , 1, _oFontApt, CLR_BLUE, '<Peso Especifico>'      , .T. )
             _oGetGer05   := TGet():New( 026, 002, {|u| If( PCount() > 0, _cGet5Cod := u, _cGet5Cod ) }, _oDados, 100, 013, '@!'               , , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_cGet5Cod", , , , , , , 'Codigo do Produto'   , 1, _oFontApt, CLR_BLUE, '<Codigo do Produto>'    , .T. )
             _oGetGer06   := TGet():New( 026, 112, {|u| If( PCount() > 0, _cGet6Des := u, _cGet6Des ) }, _oDados, 270, 013, '@!'               , , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_cGet6Des", , , , , , , 'Descrição do Produto', 1, _oFontApt, CLR_BLUE, '<Descrição do Produto>' , .T. )
             If _aAptAtu[2] <> 'C' //Diferente de Conferencia
                _oGetGer07   := TGet():New( 050, 282, {|u| If( PCount() > 0, _nGet7Tar := u, _nGet7Tar ) }, _oDados, 100, 013, '@E 9,999.999'     , , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_nGet7Tar", , , , , , , 'Tara'                , 1, _oFontApt, CLR_BLUE, '<Tara do tacho>'        , .T. )
                _oGetGer07:bValid := { || _nGet2Ite := _nGet1Ite + _nGet7Tar, _oGetIte02:Refresh() }
             Endif
             _oSayGer01   := TSay():New( 060, 002, {|| "Operação: " + _aRotApt[_aAptAtu[1]][3] + ' - ' + Alltrim( _aRotApt[_aAptAtu[1]][4] ) + ' / ' + Iif( _aAptAtu[2] == 'I', 'INICIO', Iif( _aAptAtu[2] == 'F', 'FIM', 'CONFERÊNCIA' ) ) }, _oDados, , _oFontApt, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 340, 012)
             If _aAptAtu[2] == 'F'
                fAtuTempo( @_cCrono )
                _oSayGet02   := TSay():New( 002, 0150, {|| _cCrono }, _oRodape, , _oFontApt, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 060, 012)
                _oTimeCro := TTimer():New( 2000, { || fAtuTempo( @_cCrono ), _oSayGet02:Refresh() }, _oDlgOpe )
                _oTimeCro:Activate()
             Endif
             /*+----------------------------------------+
               | Itens para Ordem de Produção           |
               +----------------------------------------+*/
             If _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'I'
                _oBrwIte := TWBrowse():New( 002 , 002, ( _oMateriais:nWidth )* 0.335, ( _oMateriais:nHeight ) * 0.48, , {'','Item','Local', 'Seq.','Quantidade', 'Estoque', 'Reserva', 'Disponivel', 'Operação'}, { 10, 60, 10, 10, 40, 40, 40, 40, 100 }, _oMateriais, ,  , ,  , {||},  ,  ,  ,  ,  ,  , .F.,     , .T.,  , .F.,  , .T., .T. )
                _oBrwIte:SetArray( _aBrwIte )
                _oBrwIte:bLine := { || { IIF( _aBrwIte[_oBrwIte:nAt][14] < _aBrwIte[_oBrwIte:nAt][04], _oVermelho, _oVerde ), _aBrwIte[_oBrwIte:nAt][01], _aBrwIte[_oBrwIte:nAt][06], _aBrwIte[_oBrwIte:nAt][02], Transform( _aBrwIte[_oBrwIte:nAt][04], '@E 99,999,999.999'), _aBrwIte[_oBrwIte:nAt][12], _aBrwIte[_oBrwIte:nAt][13], _aBrwIte[_oBrwIte:nAt][14], _aBrwIte[_oBrwIte:nAt][08] } }

                _oBrwIte:lUseDefaultColors := .F.
                _oBrwIte:SetBlkBackColor( { || IIf( _aBrwIte[_oBrwIte:nAt][14] > 0, CLR_HREG , Nil ) } )
             Else
                //_oBrwIte := TWBrowse():New( 002 , 002, ( _oMateriais:nWidth )* 0.335, ( _oMateriais:nHeight ) * 0.48, , { 'Item', 'Seq.', 'Solicitada', 'Usada', 'Operação'}, { 70, 10, 70, 70, 100 }, _oMateriais, ,  , ,  , {||},  ,  ,  ,  ,  ,  , .F.,  , .T.,  ,   ,  , .T., .T. )
                _oBrwIte := TWBrowse():New( 002 , 002, ( _oMateriais:nWidth )* 0.335, ( _oMateriais:nHeight ) * 0.48, , { 'Item', 'Seq.', 'Usada', 'Operação'}, { 70, 10, 70, 70, 100 }, _oMateriais, ,  , ,  , {||},  ,  ,  ,  ,  ,  , .F.,  , .T.,  ,   ,  , .T., .T. )
                _oBrwIte:SetArray( _aBrwIte )
                If _aAptAtu[2] $ 'C.F'
                   _oBrwIte:bLine := { || { _aBrwIte[_oBrwIte:nAt][01], _aBrwIte[_oBrwIte:nAt][02], Transform( _aBrwIte[_oBrwIte:nAt][04], '@E 99,999,999.999' ), _aBrwIte[_oBrwIte:nAt][08] } }
                Else
                   If _aRotApt[ _aAptAtu[1] ][ 12 ] == 'XXL'
                      _oBrwIte:bLine := { || { _aBrwIte[_oBrwIte:nAt][01], _aBrwIte[_oBrwIte:nAt][02], Transform( _aBrwIte[_oBrwIte:nAt][04], '@E 99,999,999.999' ), _aBrwIte[_oBrwIte:nAt][08] } }
                   Else
                      //_oBrwIte:bLine := { || { _aBrwIte[_oBrwIte:nAt][01], _aBrwIte[_oBrwIte:nAt][02], Transform( _aBrwIte[_oBrwIte:nAt][18], '@E 999,999.999' ), Transform( _aBrwIte[_oBrwIte:nAt][04], '@E 999,999.999' ), _aBrwIte[_oBrwIte:nAt][08] } }
                      _oBrwIte:bLine := { || { _aBrwIte[_oBrwIte:nAt][01], _aBrwIte[_oBrwIte:nAt][02], Transform( _aBrwIte[_oBrwIte:nAt][04], '@E 99,999,999.999' ), _aBrwIte[_oBrwIte:nAt][08] } }
                   Endif
                Endif
                If _aAptAtu[2] == 'C' .or. (_aAptAtu[1] <> 1 .and. _aAptAtu[2] == 'I') //Conferencia ou Inicio de outras operações não aciona botões
                   _oBtIteI:lreadonly := .t.
                   _oBtIteA:lreadonly := .t.
                   _oBtIteE:lreadonly := .t.
                Endif
             Endif
             If _aAptAtu[2] <> 'C' //Diferente de Conferencia
               _oGetIte01   := TGet():New( 000, _oMateriais:nClientWidth * 0.425, {|u| If( PCount() > 0, _nGet1Ite := u, _nGet1Ite ) }, _oMateriais, 060, 013, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_nGet1Ite", , , , , , , 'Peso Liquido'      , 1, _oFontApt, CLR_BLUE, '<Peso Liquido>'    , .T. )
               _oGetIte02   := TGet():New( 025, _oMateriais:nClientWidth * 0.425, {|u| If( PCount() > 0, _nGet2Ite := u, _nGet2Ite ) }, _oMateriais, 060, 013, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,   , "_nGet2Ite", , , , , , , 'Peso Bruto'        , 1, _oFontApt, CLR_BLUE, '<Peso Bruto>'      , .T. )
             else
                _oGetIte03   := TGet():New( 000, _oMateriais:nClientWidth * 0.425, {|u| If( PCount() > 0, _nGet3Ite := u, _nGet3Ite ) }, _oMateriais, 060, 013, '@E 999,999.999', , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , .T., .F.,  , "_nGet3Ite", , , , , , , 'Peso Balança'     , 1, _oFontApt, CLR_BLUE, '<Peso Balança>'    , .T. ) 
             Endif
             If _aRotApt[_aAptAtu[1]][12] == 'XXL'
                If _aAptAtu[2] <> 'C' //Diferente de Conferência
                   _oGetGer07:lVisible := .f.
                   _oGetIte01:lVisible := .f.
                   _oGetIte02:lVisible := .f.
                   _oGetIte04   := TGet():New( 000, _oMateriais:nClientWidth * 0.425, {|u| If( PCount() > 0, _nGet4Ite := u, _nGet4Ite ) }, _oMateriais, 060, 013, '@E 9.999', , CLR_BLACK, CLR_WHITE, _oFontApt, .F., , .T.,  ,    , ,    ,    , , Iif( _aAptAtu[2] $ 'I.C', .T., .F. ), .F.,  , "_nGet4Ite", , , , , , , 'P.E.(Laboratório)', 1, _oFontApt, CLR_BLUE, '<P.E. Laboratório>', .T. )
                   _oGetIte04:bLostFocus := { || fValidaPE() }
                Endif
             Endif
             /*+----------------------------------------+
               | Itens para Ordem de Produção           |
               +----------------------------------------+*/
             _oBrwRes := TWBrowse():New( 002 , 002, ( _oResponsav:nWidth )* 0.335, ( _oResponsav:nHeight ) * 0.42, , { 'Matricula','Nome' }, { 30, 200 }, _oResponsav, ,  , ,  , {||},  ,  ,  ,  ,  ,  , .F.,  , .T.,  ,   ,  , .F., .T. )
             _oBrwRes:SetArray( _aBrwRes )
             _oBrwRes:bLine := {||{ _aBrwRes[_oBrwRes:nAt,01], _aBrwRes[_oBrwRes:nAt,02] } }
             
             _oDlgOpe:bInit := Iif( _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'I', { || MsgRun ( 'Aguarde pesagem...', 'Pesagem', {|| fPesaTara(1) } ) },;
                               Iif(                        _aAptAtu[2] == 'C', { || MsgRun ( 'Aguarde pesagem...', 'Pesagem', {|| fPesaTara(2) } ) }, { || _nGet2Ite := _nGet1Ite + _nGet7Tar } ) )

       ACTIVATE DIALOG _oDlgOpe CENTERED

Return 

Static Function fAtuTempo( _cCrono )
       Local _cOperIni := SubStr( _aRotApt[ _aAptAtu[1]][5], 12, 5 ) + ':00'
       Local _cTempoAt := SubStr( Time(), 1, 5 ) + ':00'
       
       _cCrono := SubStr( Elaptime( _cOperIni, _cTempoAt ), 1, 5 )
Return

/*/{Protheus.doc} fBloqOpSal
Veririca saldo dos itens da op antes do inicio - Função compatibilizada do fonte ZPCPA08
@type function
@version 2020.01
@author Luís Gustavo
@since 11/05/2020
@return Logical, Verdadeiro ou falso
/*/
Static Function fBloqOpSal()
       Local cAliAtu := Alias()
       Local cQry1   := ""
       Local cTexto  := ""
       Local lReturn := .f. 
       Local nDif    := 0.0, _nDec, nQtd, nQtdSegum
       Local aVetor  := {}, aArea := {}
       Local nOpc    := 4 //Alterar
       Local cNumOrd := _cGet1Ord + Space(03) //Como cNumOrd é usado em uma busca na SD4 e nas customizações usa-se o tamanho de 11 digitos ajustei de acordo com o tamanho do campo C2_ITEMGRD que faz parte da chave primária dessa tabela.
       Private lMsErroAuto
	
       aArea := U_PegaArea({"SD4"})
    
       cQry1 := ""
       cQry1 += "SELECT D4_COD, MAX(B1_DESC) AS B1_DESC, D4_LOCAL, SUM(D4_QUANT) AS D4_QUANT, MAX(B2_QATU) AS B2_QATU, (MAX(B2_QATU) - SUM(D4_QUANT)) AS 'DISP', B1_GRUPO, " + Chr(13) + Chr(10)
       cQry1 += "'SALTOTAL' = (SELECT SUM(B2_QATU) FROM " + RetSqlName("SB2") + " WITH(NOLOCK) WHERE D4_FILIAL = B2_FILIAL AND D4_COD = B2_COD AND D_E_L_E_T_ ='' AND SUBSTRING(B2_LOCAL,1,1) NOT IN('G','M') ) " + Chr(13) + Chr(10)
       cQry1 += "FROM " + RetSqlName("SD4") + " SD4 WITH(NOLOCK) " + Chr(13) + Chr(10)
       cQry1 += "LEFT OUTER JOIN " + RetSqlName("SB2") + " SB2 WITH(NOLOCK) ON (B2_FILIAL = D4_FILIAL) AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND SB2.D_E_L_E_T_ ='' " + Chr(13) + Chr(10)
       cQry1 += "LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON (B1_FILIAL = D4_FILIAL) AND B1_COD = D4_COD AND SB1.D_E_L_E_T_ ='' " + Chr(13) + Chr(10)
       cQry1 += "LEFT OUTER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON (C2_FILIAL = D4_FILIAL) AND C2_OP = D4_OP AND SC2.D_E_L_E_T_ ='' " + Chr(13) + Chr(10)
       cQry1 += "WHERE ( SD4.D_E_L_E_T_ ='' ) " + Chr(13) + Chr(10)
       cQry1 += "  AND SB1.B1_GRUPO NOT BETWEEN('PI00') AND ('PI99') " + Chr(13) + Chr(10)
       cQry1 += "  AND SB1.B1_GRUPO BETWEEN('E000') AND ('E999') "  + Chr(13) + Chr(10) //Adicionado em 17/12/20 - Para tratar somente as embalagens
       cQry1 += "  AND ( SD4.D4_FILIAL  = '" + xFilial("SD4") + "' ) " + Chr(13) + Chr(10)
       cQry1 += "  AND SC2.C2_LOTE     = '" + _cGet2Lot + "' " + Chr(13) + Chr(10)
       cQry1 += "GROUP BY SD4.D4_FILIAL, SD4.D4_COD, SD4.D4_LOCAL, SB1.B1_GRUPO HAVING SUM( SD4.D4_QUANT ) > MAX( SB2.B2_QATU ) " + Chr(13) + Chr(10)
       cQry1 += "ORDER BY SD4.D4_COD, SD4.D4_LOCAL " + Chr(13) + Chr(10)
       TCQuery cQry1 ALIAS "TCS" NEW

       DbSelectArea("TCS")
       DbGoTop()
       While !Eof()  
             If SUBSTR( TCS->B1_GRUPO, 1, 1 ) <> 'E' // embalagens deve se considerar o saldo de todos os almoxarifados - chamado 007121 - Michelly
                If ABS( TCS->D4_QUANT - TCS->B2_QATU ) >= 0.001 //definir tolerância p/ qdo passar de 3 casas
                   cTexto += "Produto "+TCS->D4_COD+" - "+TCS->B1_DESC+" com saldo insuficiente "+Alltrim(TransForm(TCS->DISP, "@E 9999.9999"))+" Local -> "+TCS->D4_LOCAL+CHR(13)+CHR(10)
                   lReturn := .t.
                Else
                   //Cleber(22/11/16)->Ajustar empenho tirando a diferença em relação ao saldo.
                   nDif := TCS->D4_QUANT - TCS->B2_QATU    
                   dbselectarea( "SD4" )
                   dbsetorder( 2 )
                   dbseek( xFilial("SD4") + cNumOrd + TCS->D4_COD + TCS->D4_LOCAL )
                   While !Eof() .AND. ( SD4->D4_FILIAL == xFilial("SD4") ) .AND. ( SD4->D4_OP = cNumOrd ) .AND. ( SD4->D4_COD == TCS->D4_COD ) .AND. ( SD4->D4_LOCAL == TCS->D4_LOCAL )
                         If SD4->D4_QUANT >= nDif //Ajustar empenho tirando resíduo a mais para não dar diferença na baixa
                            nQtd        := SD4->D4_QUANT-nDif
                            _nDec       := TamSX3("D4_QTSEGUM")[2]
                            nQtdSegum   := round(SD4->D4_QTSEGUM - (SD4->D4_QTSEGUM*nQtd/SD4->D4_QUANT),_nDec)
                            lMsErroAuto := .F.
 
                            aVetor := { { "D4_COD"     , SD4->D4_COD    , Nil },; //COM O TAMANHO EXATO DO CAMPO
                                        { "D4_LOCAL"   , SD4->D4_LOCAL  , Nil },;
                                        { "D4_OP"      , SD4->D4_OP     , Nil },;
                                        { "D4_DATA"    , SD4->D4_DATA   , Nil },;
                                        { "D4_QTDEORI" , SD4->D4_QTDEORI, Nil },;
                                        { "D4_QUANT"   , nQtd           , Nil },;
                                        { "D4_TRT"     , SD4->D4_TRT    , Nil },;
                                        { "D4_QTSEGUM" , nQtdSegum      , Nil } }
                            MSExecAuto( { |x,y| mata380( x, y ) }, aVetor, nOpc )
                            If lMsErroAuto
	                            MostraErro()
                            EndIf
                            Exit
                         Endif
                         DbSelectArea("SD4")
                         SD4->( DbSkip( ) )
                   Enddo
                Endif
             Else
                If ( TCS->D4_QUANT ) > ( TCS->SALTOTAL )
                   cTexto += "Produto "+TCS->D4_COD+" - "+TCS->B1_DESC+" com saldo insuficiente em todos os almoxarifados somados "+Alltrim(TransForm(TCS->SALTOTAL, "@E 99999"))+" Local -> "+TCS->D4_LOCAL+CHR(13)+CHR(10)
                   lReturn:= .t.
                Endif
             Endif
             DbSelectArea("TCS")
             DbSkip()
       Enddo
       DbSelectArea("TCS")
       DbCloseArea()
       If Len( Alltrim( cTexto ) ) > 0
          Messagebox( cTexto, "Produto sem Saldo", 48 )
          If Substr( xFilial("ZZA"), 1, 2) == "06"
             U_EnvMail( "DISSOLTEX - O.P " + cNumOrd + " não iniciada por falta de Saldo !", cTexto, "silene@dissoltex.com.br, ricardo@dissoltex.com.br", "" )
          Else
             U_EnvMail( "BRASILUX - O.P "  + cNumOrd + " não iniciada por falta de Saldo !", cTexto, "materiais@brasilux.com.br, paulo@brasilux.com.br" , "" )
          Endif
       Endif
       U_VoltaArea( aArea )
       If !Empty( cAliAtu )
          DbSelectArea( cAliAtu )
       Endif
Return lReturn 

/*/{Protheus.doc} fBusAptAtu
Busca operação atual a ser apontada
@type function
@version 2020.01
@author Luís Gustavo
@since 12/05/2020
@return array, Retorna um vetor com a posição da operação a ser apontada e o status inicio ou final
/*/
Static Function fBusAptAtu( )
       Local _nAptAtu := 0
       Local _lAchou  := .f.
       Local _nY      := 0
       Local _cStaApt := ""

       For _nY := 1 To len( _aRotApt )
           If ! _lAchou
              If _aRotApt[ _nY ][ 5 ] == '' //Inicio
                 _lAchou  := .t.
                 _nAptAtu := _nY
                 _cStaApt := 'I'
              ElseIf _aRotApt[ _nY ][ 6 ] = ''
                     _lAchou  := .t.
                     _nAptAtu := _nY
                     _cStaApt := 'F'
              Endif
           Endif
       Next
       //Verifica se operação anterior necessita da conferência de peso e se o mesmo já foi apurado.
       _nOperAnt := Iif( _nAptAtu == 0, Len( _aRotApt ),  _nAptAtu - 1 )
       If _nOperAnt > 0 
          If _aRotApt[_nOperAnt][7] == 'S' .and. _aRotApt[_nOperAnt][11] <= 0
             _nAptAtu := _nOperAnt
             _cStaApt := 'C'
             _lAchou  := .T.
          ElseIf _aRotApt[_nOperAnt][7] == 'S' .and. _aRotApt[_nOperAnt][11] > 0
                 //Posiciono Apontamento na operação correta para verificação
                 DbSelectArea("ZZA")
                 ZZA->( DbSetOrder( 5 ) )
                 ZZA->( DbSeek( xFilial("ZZA" ) + SC2->C2_OP + _aRotApt[ _nOperAnt ][3] + _aRotApt[ _nOperAnt ][14] ) )
                 //Por enquanto amarrei a fase de pesagem com o da balança/laboratório - deve ser estudado se houverem outras no futuro
                 If !fVerPEnv( Iif( _aRotApt[ _nOperAnt ][ 12 ] == 'XXB', 1, 2) ) //Retornando falso
                    _lAchou  := .f.
                 Endif
          ElseIf _aRotApt[_nOperAnt][7] <> 'S'
                 //Posiciono Apontamento na operação correta para verificação
                 DbSelectArea("ZZA")
                 ZZA->( DbSetOrder( 5 ) )
                 If ZZA->( DbSeek( xFilial("ZZA" ) + SC2->C2_OP + _aRotApt[ _nOperAnt ][3] + _aRotApt[ _nOperAnt ][14] ) )
                    If ZZA->ZZA_FLAG == '1'
                       _nAptAtu := _nOperAnt
                       _cStaApt := 'F'
                       _lAchou  := .T.
                    Endif
                 Endif
          Endif
       Endif
       //Posiciono Apontamento na operação correta
       If _nAptAtu <> 0
          DbSelectArea("ZZA")
          ZZA->( DbSetOrder( 5 ) )
          ZZA->( DbSeek( xFilial("ZZA" ) + SC2->C2_OP + _aRotApt[ _nAptAtu ][3] + _aRotApt[ _nAptAtu ][14] ) )
       Else 
          MessageBox( 'Ordem de produção não possui operações a serem apontadas.', 'Ordem de produção encerrada', 48 )
       Endif
Return { _nAptAtu, _cStaApt, _lAchou }

/*/{Protheus.doc} fVerPedApr
Verifica se existem mais pedidos liberados após a criação da OP - Função compatibilizada do fonte ZPCPA08
@type function
@version 2020.01
@author Luís Gustavo
@since 12/05/2020
@return Logical, Retorna verdadeiro para continuar com apontamento e falso se encontrou pedidos liberados
/*/
Static Function fVerPedApr()
       Local cQry1    := ""
       Local _lRet    := .t.
       Local nY       := 0
       Local aCadPed1 := {}
       Local cAuxMens := ""
	 	  	    	        
       cQry1 += "SELECT C6_FILIAL, C6_PRODUTO, C6_DESCRI, SUM(C6_QTDVEN) AS C6_QTDVEN, " + Chr(13) + Chr(10)
       cQry1 += "(SELECT SUM(B2_QATU) FROM " +RetSqlName("SB2") + " WITH(NOLOCK) WHERE B2_FILIAL = C6_FILIAL AND B2_COD = C6_PRODUTO AND B2_LOCAL NOT IN('13','G1')) AS 'SALDOATUAL', " + Chr(13) + Chr(10)
       cQry1 += "(SELECT ISNULL(SUM(C2_QUANT),0) FROM " + RetSqlName("SC2") + " WITH(NOLOCK) WHERE C2_FILIAL = C6_FILIAL AND C2_PRODUTO = C6_PRODUTO AND D_E_L_E_T_ ='' AND C2_DATRF ='' AND C2_QUJE =0 ) AS 'SALDOOPS' ,B1_ESTOQUE " + Chr(13) + Chr(10)
       cQry1 += "FROM " + RetSqlName("SC6") + " SC6 WITH(NOLOCK) "
       cQry1 += "LEFT OUTER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC5.D_E_L_E_T_ ='' " + Chr(13) + Chr(10)
       cQry1 += "LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON B1_FILIAL = C6_FILIAL AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ ='' " + Chr(13) + Chr(10)
       cQry1 += "LEFT OUTER JOIN " + RetSqlName("SF4") + " SF4 WITH(NOLOCK) ON F4_FILIAL = '' AND C6_TES = F4_CODIGO AND SF4.D_E_L_E_T_ ='' " + Chr(13) + Chr(10)
       cQry1 += "WHERE SC6.D_E_L_E_T_ = '' " + Chr(13) + Chr(10)
       cQry1 += "  AND SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + Chr(13) + Chr(10)
       cQry1 += "  AND SC5.C5_APROVA  = '1' " + Chr(13) + Chr(10)
       cQry1 += "  AND SC6.C6_NOTA    = '' " + Chr(13) + Chr(10)
       cQry1 += "  AND SUBSTRING( SC6.C6_PRODUTO, 1, 10) = '" + SubStr( SC2->C2_PRODUTO, 1, 10 )+"' " + Chr(13) + Chr(10)
       cQry1 += "  AND SF4.F4_ESTOQUE <> 'N' " + Chr(13) + Chr(10)
       cQry1 += "GROUP BY SC6.C6_FILIAL, SC6.C6_PRODUTO, SC6.C6_DESCRI, SB1.B1_ESTOQUE " + Chr(13) + Chr(10)
       TCQuery cQry1 ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       DbGoTop()              
       While !Eof()
             If ( ( TCQ->SALDOATUAL + TCQ->SALDOOPS ) < TCQ->C6_QTDVEN ) .AND. TCQ->B1_ESTOQUE <> 'S'
                aAdd( aCadPed1, { TCQ->C6_PRODUTO, TCQ->C6_DESCRI, Iif( TCQ->B1_ESTOQUE == 'S', 'SIM', 'NÃO' ), TRANSFORM( TCQ->C6_QTDVEN, "@E 999999" ), TRANSFORM( TCQ->SALDOATUAL, "@E 999999" ), TRANSFORM( TCQ->SALDOOPS, "@E 999999" ), TRANSFORM( ( TCQ->SALDOATUAL + TCQ->SALDOOPS ), "@E 999999" ) } )
             Endif
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()              
       If Len( aCadPed1 ) > 0  .AND. Posicione( "SC2", 1, xFilial("SC2") + SC2->C2_OP, "C2_XLIBOPE" ) <> "S"
          Messagebox( "Existem pedidos que foram aprovados após a emissão desta ordem de produção e devem ser fabricados juntos, verifique com PCP !!", "Atenção...", 48 )
          cAuxMens := "Pedido com Produto específico aprovado após emissão deste lote "+chr(13)+chr(10)
          For nY := 1 To Len( aCadPed1 )
              cAuxMens += "Lote.........: " + SC2->C2_LOTE + "   O.P : " + SC2->C2_OP + chr(13) + chr(10)
              cAuxMens += "Produto......: " + aCadPed1[nY][1] +" - " + aCadPed1[nY][2] + chr(13) + chr(10)
              cAuxMens += "Qtd Pedidos..: " + aCadPed1[nY][4] +" (Saldo Atual + Ops em Aberto)..: " + aCadPed1[nY][7] + chr(13) + chr(10)
              cAuxMens += "Saldo Atual..: " + aCadPed1[nY][5] +" Ops em Aberto..: " + aCadPed1[nY][6] + chr(13) + chr(10)
              cAuxMens += " " + chr(13) + chr(10)
          Next
          cAuxMens += chr(13) + chr(10) + "Prog. Origem : ZPCPA01"
          If Substr( xFilial("ZZA"), 1, 2) == "06"
             //U_EnvMail("DISSOLTEX - Lote "+cNumLot+" deve ser analisado, pois existe necessidade de produção maior do que este lote. !",cAuxMens,silene@brasilux.com.br","")                       	  
          Else
             U_EnvMail( "BRASILUX - Lote " + SC2->C2_LOTE + " deve ser analisado, pois existe necessidade de produção maior do que este lote. !", cAuxMens, "pcp@brasilux.com.br", "")
          Endif
          _lRet := .f.
       Endif
Return _lRet

/*/{Protheus.doc} fVerMaiOrd
Verifica ordens de produção do mesmo produto e pedidos ainda em abertos.
@type function
@version 2020.01
@author Luís Gustavo
@since 12/05/2020
@return Logical, Retorna verdadeiro para continuar com apontamento ou falso para juntar ordens.
/*/
Static Function fVerMaiOrd()
       Local aCadOps := {}
       Local cMsgApt := ""
       Local aCadPed := {}
       Local lNaoApt := .f.
       Local nOpcA   := 0
       Local nY      := 0
       Local _lRet   := .T.

       cQry1 := ""
       cQry1 += "SELECT SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS OP, SC2.C2_EMISSAO AS EMISSAO, SC2.C2_QUANT AS QUANT, ISNULL(PRO.ZZA_FLAG, '') AS FLAG " + Chr(13) + Chr(10)
       cQry1 += "FROM "+ RetSqlName("SC2") + " SC2 WITH (NOLOCK) " + Chr(13) + Chr(10)
       cQry1 += "LEFT OUTER JOIN " + RetSqlName("ZZA") + " PRO WITH (NOLOCK) ON PRO.ZZA_FILIAL = SC2.C2_FILIAL AND PRO.ZZA_ORDEM = SC2.C2_OP AND PRO.D_E_L_E_T_ = '' " + Chr(13) + Chr(10)
       cQry1 += "WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' " + Chr(13) + Chr(10)
       cQry1 += "  AND SC2.D_E_L_E_T_ = '' " + Chr(13) + Chr(10)
       cQry1 += "  AND SC2.C2_OP     <> '" + SC2->C2_OP      + "' " + Chr(13) + Chr(10)
       cQry1 += "  AND SC2.C2_PRODUTO = '" + SC2->C2_PRODUTO + "' " + Chr(13) + Chr(10)
       cQry1 += "  AND SC2.C2_DATRF   = '' " + Chr(13) + Chr(10)
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             aAdd( aCadOps, { TCQ->OP, SubStr( TCQ->EMISSAO, 7, 2 ) + '/' + SubStr( TCQ->EMISSAO, 5, 2 ) + '/' + SubStr( TCQ->EMISSAO, 1, 4 ), TCQ->QUANT, Iif( Empty( TCQ->FLAG ), 'NÃO', 'SIM') } )
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()

       If Len( aCadOps ) > 0
          //d) Verifica se as Ordens de Produção encontradas já foram ou não iniciadas.
          cMsgApt += '          APONTAMENTO DE ORDENS DE PRODUÇÃO          '+Chr(13)+Chr(10)
          cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
          cMsgApt += '|  ORDEM PROD.  |   EMISSAO  | INICIADA |   QTDE.   |'+Chr(13)+Chr(10)
          cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
          For nY := 1 To Len( aCadOps )
              cMsgApt += '| ' + SubStr( aCadOps[nY][1], 1, 6)+'-'+SubStr(aCadOps[nY][1], 7, 2)+'-'+SubStr(aCadOps[nY][1], 9, 3)+' | '+aCadOps[nY][2]+' |    '+aCadOps[nY][4]+'   | '+Transform(aCadOps[nY][3], "@E 99,999.99")+' |'+Chr(13)+Chr(10)
              cMsgApt += '+---------------+------------+----------+-----------+'+Chr(13)+Chr(10)
          Next
       Endif
       If !_cGet8Est $ 'S' .and. Len( Alltrim( SC2->C2_PRODUTO ) ) >= 12
          //e) Se o produto não for de estoque verificar se exitem outros pedidos em aberto para o item
          cQry1 := ""
          cQry1 += "SELECT SC6.C6_NUM AS PEDIDO, SUBSTRING(SC6.C6_PRODUTO, 11, 2) AS EMBALAGEM, SC6.C6_QTDVEN AS QUANT, SC5.C5_APROVA AS APROVA " + Chr(13) + Chr(10)
          cQry1 += "FROM " + RetSQLName("SC6") +" SC6 WITH(NOLOCK) " + Chr(13) + Chr(10)
          cQry1 += "LEFT OUTER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) ON SC5.C5_FILIAL = '" + xFilial("SC5")+"' AND SC5.C5_NUM = SC6.C6_NUM AND SC5.D_E_L_E_T_ = '' " + Chr(13) + Chr(10)
          cQry1 += "WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "' " + Chr(13) + Chr(10)
          cQry1 += "  AND SC6.D_E_L_E_T_ = '' " + Chr(13) + Chr(10)
          cQry1 += "  AND SC6.C6_NOTA    = '' " + Chr(13) + Chr(10)
          cQry1 += "  AND SUBSTRING( SC6.C6_PRODUTO, 1, 10 ) = '" + SubStr( SC2->C2_PRODUTO, 1, 10 ) + "' " + Chr(13) + Chr(10)
          cQry1 += "  AND SC5.C5_APROVA = '1' " + Chr(13) + Chr(10)
          cQry1 += "ORDER BY 1, 2 " + Chr(13) + Chr(10)
          TCQuery cQry1 ALIAS "TCQ" NEW
          DbSelectArea("TCQ")
          DbGoTop()
          While !Eof()
                aAdd( aCadPed, { TCQ->PEDIDO, TCQ->EMBALAGEM, Iif( TCQ->APROVA == '1', 'SIM', 'NÃO' ), TRANSFORM( TCQ->QUANT, "@E 999999" ) } )
                DbSelectArea("TCQ")
                DbSkip()
          Enddo
          DbSelectArea("TCQ")
          DbCloseArea()
          If Len( aCadPed ) > 0
             cMsgApt += ''+Chr(13)+Chr(10)
             cMsgApt += ''+Chr(13)+Chr(10)
             cMsgApt += '   PEDIDOS EM ABERTO SEM ORDENS DE PRODUÇÃO    '+Chr(13)+Chr(10)
             cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
             cMsgApt += '| PEDIDO |  APROVADO  |  EMBALAGEM  |  QTDE.  |'+Chr(13)+Chr(10)
             cMsgApt += '+--------+------------+-------------+---------+'+Chr(13)+Chr(10)
             For nY := 1 To Len( aCadPed )
                 If aCadPed[nY][3] $ 'SIM'
                    lNaoApt := .t.
                 Endif
                 cMsgApt += '| ' + aCadPed[nY][1] + ' |    ' + aCadPed[nY][3] + '     |     ' + aCadPed[nY][2] + '      | ' + aCadPed[nY][4] + '  |' + Chr(13) + Chr(10)
                 cMsgApt += '+--------+------------+-------------+---------+' + Chr(13) + Chr(10)
             Next
          Endif
       Endif
       If !Empty( cMsgApt )
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Declaração de cVariable dos componentes                                 ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          Private cMGet1Ms
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Declaração de Variaveis Private dos Objetos                             ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          SetPrvt( "oFontMsg", "oDlg1Msg", "oMGet1Ms" )
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Definicao do Dialog e todos os seus componentes.                        ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          cMGet1Ms   := cMsgApt
          oFontMsg   := TFont():New( "Courier New", 0, -15, , .F., 0, , 400, .F., .F., , , , , , )
          oDlg1Msg   := MSDialog():New( 0, 0, 371, 520, "Aviso", , , .F., , , , , , .T., , , .T. )
          oMGet1Ms   := TMultiGet():New( 003, 003, {|u| If(PCount() > 0, cMGet1Ms := u, cMGet1Ms)}, oDlg1Msg, 255,180, oFontMsg, , CLR_BLACK, CLR_WHITE, , .T., "", , , .F., .F., .F., , , .F., , )
          oMGet1Ms:lReadOnly := .t.
          oDlg1Msg:Activate(, , , .T.)
       Endif
       If lNaoApt
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Declaração de cVariable dos componentes                                 ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          Private cSay1Avs   := Space(1)
          Private cSay2Avs   := Space(1)

          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Declaração de Variaveis Private dos Objetos                             ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          SetPrvt("oFontAvs", "oDlg1Avs", "oSay1Avs", "oSay2Avs", "oBtn1Avs", "oBtn2Avs")

          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Definicao do Dialog e todos os seus componentes.                        ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          lSai1Avs   := .f.
          oFontAvs   := TFont():New( "Courier New", 0, -20, , .T., 0, , 680, .F., .F., , , , , , )
          oDlg1Avs   := MSDialog():New( 282, 250, 405, 945, "Aviso", , , .F., , , , , , .T., , , .T. )
          oSay1Avs   := TSay():New( 008, 003, {|| "               ATENÇÃO, PRODUTO ESPECÍFICO             "}, oDlg1Avs, , oFontAvs, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 340, 012)
          oSay2Avs   := TSay():New( 024, 003, {|| "  *** EXISTEM PRODUTOS LIBERADOS SEM OP, CONTINUA ? ***"}, oDlg1Avs, , oFontAvs, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 340, 012)
          oBtn1Avs   := TButton():New( 040, 304, "ABANDONA", oDlg1Avs, { || nOpcA := 0, lSai1Avs := .t., oDlg1Avs:End()}, 037, 012, , , , .T., , "", , , , .F. )
          oBtn2Avs   := TButton():New( 040, 256, "CONTINUA", oDlg1Avs, { || nOpcA := 1, lSai1Avs := .t., oDlg1Avs:End()}, 037, 012, , , , .T., , "", , , , .F. )
          oDlg1Avs:bValid := {|| lSai1Avs }
          oDlg1Avs:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
          oDlg1Avs:Activate(, , , .t.)
       Else
          nOpcA := 1
       Endif
       If nOpcA == 0
          _lRet := .f.
       Endif
Return _lRet

/*/{Protheus.doc} fPesaTara
Pesagem da Tara do Tacho
@type function
@version 2020.01
@author gustavosouza
@since 13/05/2020
/*/
Static Function fPesaTara( _nOpcPes )
       Local _cConfig   := ''
       Local _cPorta    := 'COM3'
       Local _cVelocid  := '19200'
       Local _cParidade := 'n'
       Local _cBits     := '8'
       Local _cStopBits := '1'
       Local _nHandle   := 0 
       Local _nTempo    := 5
       Local _nX        := 0
       Local _lRet      := .t.
       Local _cBuffer   := ''
       Local _nPosFim   := 0
       Local _cPesoLido := ""
       Local _cNaoLer   := GETMV( "ZP_PAR0027" )

       If GetClientIP() $ _cNaoLer
          MessageBox( "Leitura automática da balança desabilitada pelo parâmetro ZP_PAR0027. Digite o peso manual.", "Pesagem", 48 )
          If _aAptAtu[2] <> 'C'
             _oGetGer07:lReadOnly := .f.
             _oGetGer07:SetFocus()
             _oGetGer07:Refresh()
          Else
             _oGetIte03:lReadOnly := .f.
             _oGetIte03:SetFocus()
             _oGetIte03:Refresh()
          Endif
          Return
       Endif
       _cConfig := _cPorta+":"+_cVelocid+","+_cParidade+","+_cBits+","+_cStopBits

       //Paro o serviço da PPI para pesagem de balança  -  DrvNetWS_PM026750
       cExec := "stop DrvNetWS_PM026750"
       ShellExecute( "Open", "C:\Windows\System32\net.exe", cExec, "C:\", 0 )
       Sleep( 4000 )

       _lRet := MSOpenPort( @_nHandle, _cConfig )
       If _lRet
          If _lZPPAR9999
             Messagebox( 'Conectado com a balança em: ' + _cConfig, 'Conexão', 64)
          Endif
          For _nX := 1 To 50
              //Obtendo o tempo de espera antes de iniciar a leitura da balança    
              Sleep( _nTempo )
              MSRead( _nHandle, @_cBuffer)
              If _lZPPAR9999
                 MemoWrite( 'C:\TEMP\BALANCA_' + DTOS(DATE()) + '_' + StrTran( Time(), ":", "" ) + 'A_' + strzero(_nX) + '.txt', _cBuffer)
              Endif
              //Se a linha retornada for igual ao tamanho limite, encerra o laço
              If Len(AllTrim( _cBuffer)) == MAX_BUFFER
                 Exit
              EndIf
          Next _nX    
          //Verifica onde começa o peso
          If _lZPPAR9999
             MemoWrite( 'C:\TEMP\BALANCA_' + DTOS(DATE()) + '_' + StrTran( Time(), ":", "" ) + 'D.txt', _cBuffer)
          Endif
          _nPosFim := At( ",", _cBuffer ) + 2 - 4
          //Obtendo apenas o peso da balança
          _cPesoLido := StrTran( Alltrim( SubStr( _cBuffer, 4, _nPosFim ) ), ",", "." )
          If _lZPPAR9999
             MessageBox( _cPesoLido, 'Conexão', 0 )
          Endif
       Else
          Messagebox('NÃO Conectado', 'Conexão', 16)
       EndIf
       //Encerra a conexão com a porta
       MSClosePort( _nHandle, _cConfig )
       //Inicio o serviço da PPI para pesagem de balança
       cExec := "Start DrvNetWS_PM026750"
       ShellExecute( "Open", "C:\Windows\System32\net.exe", cExec, "C:\", 0 )

       //Tratamento do peso para tara
       If Val( _cPesoLido ) <= 0
          MessageBox( "Não foi possível apurar o peso automático da balança. Utilize o botão 'Força Pesagem' ou digite o peso manual.", "Pesagem", 48 )
          _oBtPeso:lVisible    := .t.
          If _nOpcPes == 1 //Tara
             _oGetGer07:lReadOnly := .f.
             _oGetGer07:SetFocus()
             _oGetGer07:Refresh()
          else //Outras Pesagens
             _oGetIte03:lReadOnly := .f.
             _oGetIte03:SetFocus()
             _oGetIte03:Refresh()
          Endif
       else
          If _nOpcPes == 1 //Tara
             _nGet7Tar := Val( _cPesoLido )
             _nGet2Ite += Round( _nGet7Tar, 3 )
             _oBtPeso:lVisible    := .f.
             _oGetGer07:lReadOnly := .t.
             _oGetGer07:Refresh()
          else
             _cGet3Ite := Val( _cPesoLido )
             _oBtPeso:lVisible    := .f.
             _oGetIte03:lReadOnly := .t.
             _oGetIte03:Refresh()
          Endif
       Endif
Return

/*/{Protheus.doc} fMntEmpPro
Manutenção dos itens empenhados - inclusão/alteração/exclusão
@type function
@version 2020.01
@author Luís Gustavo
@since 14/05/2020
@param nOpcMnt, numeric, Opção do botão de manutenção - 0=Inclusão, 1=Alteração, 2=Exclusão
/*/
Static Function fMntEmpPro( nOpcMnt )
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local   lMntAltNao := Iif(nOpcMnt == 0, .f.      , .t.)
       Local   _lRet      := .T.
       Local   _cParamU   := GetMV('ZP_PAR0023') //Parâmetro que indica usuários que podem dar manutenção do empenhos na tela incial
       Local   _nPosIni   := 0
       Private cGet1Mnt   := Iif(nOpcMnt == 0, Space(15), _oBrwIte:AArray[_oBrwIte:nAt][1] ) //Item
       Private cGet6Mnt   := Iif(nOpcMnt == 0, Space(2) , _oBrwIte:AArray[_oBrwIte:nAt][6] ) //Item
       Private cGet2Mnt   := Iif(nOpcMnt == 0, Space(3) , _oBrwIte:AArray[_oBrwIte:nAt][2] ) //Sequencia
       Private nGet3Mnt   := Iif(nOpcMnt == 0, 0        , Iif( _oBrwIte:AArray[_oBrwIte:nAt][4] <> 0, _oBrwIte:AArray[_oBrwIte:nAt][4], _oBrwIte:AArray[_oBrwIte:nAt][18] ) ) //Quantidade Usada
       Private cGet4Mnt   := Iif(nOpcMnt == 0, Space(30), Posicione( "SB1", 1, xFilial("SB1") + _oBrwIte:AArray[_oBrwIte:nAt][1], "B1_DESC" ) )
       Private cGet5Mnt   := space(2)
       Private cSay1Mnt   := Space(1)
       Private cSay2Mnt   := Space(1)
       Private cSay3Mnt   := Space(1)
       Private cSay4Mnt   := Space(1)
       Private lOpcMnt    := .f.
       Private _cJustifi  := Space(40)

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de Variaveis Private dos Objetos                             ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay4Mnt", "oSay2Mnt", "oSay3Mnt", "oGet1Mnt", "oGet2Mnt")
       SetPrvt("oGet3Mnt", "oBtn2Mnt", "oBtn1Mnt")
       If _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'I'
          If !fTelaSenha( _cParamU )
             MessageBox( 'Usuário não autorizado a executar essa manutenção.', 'Autorização', 16 )
             _lRet := .f.
          else
             If nOpcMnt == 0
                _nPosIni := Len( _aUsrAut ) + 1
                aAdd( _aUsrAut, { _nPosIni, FWxFilial("ZZA"), _cGet1Ord, _cGet2Lot, 'S', PSWID(), UsrFullName( PSWID() ), , , , , , , _cJustifi, , } )
             Else
                _nPosIni := aScan( _aUsrAut, { |x| Alltrim( x[9] ) == Alltrim( _oBrwIte:aArray[_oBrwIte:nAt][1] ) } )
                If _nPosIni == 0
                   aAdd( _aUsrAut, { _oBrwIte:nAt, FWxFilial("ZZA"), _cGet1Ord, _cGet2Lot, 'S', PSWID(), UsrFullName( PSWID() ), , _oBrwIte:AArray[_oBrwIte:nAt][1], , _oBrwIte:AArray[_oBrwIte:nAt][2], _oBrwIte:AArray[_oBrwIte:nAt][3], , _cJustifi, _oBrwIte:AArray[_oBrwIte:nAt][4], _oBrwIte:AArray[_oBrwIte:nAt][6] } )
                   _nPosIni := Len( _aUsrAut )
                Endif
             Endif
             //         1         2         3         4         5         6         7
             //1234567890123456789012345678901234567890123456789012345678901234567890
             //99/99/99-99:99 INCLUSAO..: XXXXXXXXXXXXXXX - 99 / 999 / 999,999.999
             //99/99/99-99:99 EXCLUSAO..: XXXXXXXXXXXXXXX - 99 / 999 / 999,999.999
             //99/99/99-99:99 ALTERACAO.: XXXXXXXXXXXXXXX - 99 / 999 / 999,999.999
             //Mapeamento: _aUsrAut
             //1 - Posição                    |  8 - Descrição da Manutenção | 15 - Quantidade ajustada
             //2 - Filial                     |  9 - Produto                 | 16 - Armazem
             //3 - Ordem                      | 10 - Descrição               |
             //4 - Lote                       | 11 - Sequencia               |
             //5 -                            | 12 - Quantidade Original     |
             //6 - ID Usuário                 | 13 - (Não identificado uso)  |
             //7 - Nome do usuário            | 14 - Justificativa           |
          Endif
       Endif
       If _lRet
          If nOpcMnt <> 0
             If Len( _aUsrAut ) <= 0
                If SubStr( _oBrwIte:AArray[_oBrwIte:nAt][10], 1, 1 ) == "S" .and. !( _oBrwIte:AArray[_oBrwIte:nAt][17] == _aRotApt[_aAptAtu[1]][3] ) //Verifica se item é original da fórmula
                   MessageBox( "Item original da fómula não pode ser " + Iif( nOpcMnt == 1, 'alterado.', 'excluido.' ), 'Atenção', 48 )
                   _lRet := .f.
                Endif
                If _lRet
                   If _oBrwIte:AArray[_oBrwIte:nAt][11] == "1" //Flag de Baixa
                      Messagebox( "Item já baixado não pode ser " + Iif( nOpcMnt == 1, 'alterado', 'excluido' ) + ".", "Atenção...", 48 ) 
                      _lRet := .f.
                   Endif
                Endif
             Endif
          Endif
       
          If _lRet
             /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
             ±± Definicao do Dialog e todos os seus componentes.                        ±±
             Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
             oFontMn1   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
             oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
             oDlg1Mnt   := MSDialog():New( 000, 000, 095, 596, "Manutenção do Empenho", , , .F., , , , , , .T., , , .T. )
             oSay1Mnt   := TSay():New( 004, 004, {|| "Codigo:"   }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
             oGet1Mnt   := TGet():New( 002, 056, {|u| If(PCount() > 0, cGet1Mnt := u, cGet1Mnt)}, oDlg1Mnt, 068, 012, '@!R XX 99.99.999-99', , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , lMntAltNao, .F., "SB1", "cGet1Mnt", , )
             oSay4Mnt   := TSay():New( 021, 004, {|| "Descrição:"}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
             oGet4Mnt   := TGet():New( 020, 056, {|u| If(PCount() > 0, cGet4Mnt := u, cGet4Mnt)}, oDlg1Mnt, 236, 012, '@!'                 , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.       , .F., ""   , "cGet4Mnt", , )
             oSay2Mnt   := TSay():New( 004, 136, {|| "Seq:"      }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 024, 012)
             oGet2Mnt   := TGet():New( 002, 164, {|u| If(PCount() > 0, cGet2Mnt := u, cGet2Mnt)}, oDlg1Mnt, 024, 012, '@R 999'             , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.       , .F., ""   , "cGet2Mnt", , )
             oSay3Mnt   := TSay():New( 004, 200, {|| "Qtde:"     }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 028, 012)
             oGet3Mnt   := TGet():New( 002, 232, {|u| If(PCount() > 0, nGet3Mnt := u, nGet3Mnt)}, oDlg1Mnt, 060, 012, '@E 9,999.999'       , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.       , .F., ""   , "nGet3Mnt", , )
             oGet3Mnt:bGotFocus := {|| Iif( lOpcMnt, fAjuQtd( nGet3Mnt ), ) }
             oGet1Mnt:bLostFocus := {|| Iif( !Empty(cGet1Mnt) .and. nOpcMnt == 0, fValCodMnt( nOpcMnt ), ) }
             oBtn2Mnt   := TButton():New( 036, 251, "Abandona", oDlg1Mnt, {|| oDlg1Mnt:End()        }, 040, 012, , oFontMn2, , .T., , "", , , , .F. )
             oBtn1Mnt   := TButton():New( 036, 209, "Confirma", oDlg1Mnt, {|| fConEmpMnt( nOpcMnt, _aUsrAut, _nPosIni ) }, 040, 012, , oFontMn2, , .T., , "", , , , .F. )
             If nOpcMnt == 1
                oGet3Mnt:SetFocus()
                oDlg1Mnt:bInit:= { || fAjuQtd( nGet3Mnt ) }
             Endif
             If _nPosIni > 0
                _aUsrAut[ _nPosIni ][ 8] := DTOC( MSDate() ) + '-' + SubStr( Time(), 1, 5 ) + ' ' + Iif( nOpcMnt == 0, 'INCLUSAO..: ', Iif( nOpcMnt == 1, 'ALTERACAO.: ', 'EXCLUSAO..: ' ) ) + Alltrim( _oBrwIte:AArray[_oBrwIte:nAt][1] ) + ' - ' + _oBrwIte:AArray[_oBrwIte:nAt][6] + ' / ' + _oBrwIte:AArray[_oBrwIte:nAt][2] + ' / ' + TransForm( _oBrwIte:AArray[_oBrwIte:nAt][4], '999,999.999' ) + ' # ' + Alltrim( _aUsrAut[ _nPosIni ][14] )
                //_aUsrAut[ _nPosIni ][ 9] := cGet1Mnt
                //_aUsrAut[ _nPosIni ][10] := cGet4Mnt
                //_aUsrAut[ _nPosIni ][11] := cGet2Mnt
                //_aUsrAut[ _nPosIni ][12] := nGet3Mnt
             Endif
             oDlg1Mnt:Activate( , , , .T. )
             If _nPosIni > 0 .and. nOpcMnt == 1
                _nPos := aScan( _aBrwIte, { |x| Alltrim( x[ 1 ] ) == Alltrim(_aUsrAut[ _nPosIni ][ 9 ] ) })
                If _aBrwIte[_nPos][4] == _aUsrAut[ _nPosIni ][ 15 ] //Se não houve alteração, exclui o item
                   _nQtdUsr := Len( _aUsrAut )
                   aDel( _aUsrAut, _nPosIni )
                   aSize( _aUsrAut, _nQtdUsr - 1 )
                Endif
             Endif
          Endif
       Endif
Return

/*/{Protheus.doc} fValCodMnt
Validação na inclusão de um novo item de empenho
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 19/05/2020
@param nOpcMnt, Numeric, Opção da manutenção.
/*/
Static Function fValCodMnt( nOpcMnt )
       Local _lRet := .T.

       DbSelectArea("SB1")
       SB1->( DbSetOrder(1) ) 
       If SB1->( DbSeek( xFilial("SB1")+cGet1Mnt, .t. ) )
          If SB1->B1_MSBLQL <> '1' //Verifica se o item não está bloqueado
             If SB1->B1_TIPO $ 'MP.PI' //Verifica se o item é uma Materia Prima ou Produto Intermediário
                cGet4Mnt := SB1->B1_DESC
                cGet2Mnt := Strzero( Val( _cMaxTRT ) + 5, 3 )
                cGet5Mnt := iif(SB1->B1_APROPRI = "I","99",SB1->B1_LOCPAD)
                oGet4Mnt:Refresh()
                oGet2Mnt:Refresh()
                oGet3Mnt:SetFocus()
                lOpcMnt := .t.
             Else
                Messagebox( "Produto não é MP ou PI, verifique!!!", "Atenção...", 48 )
                _lRet := .F.
             Endif
          Else
             Messagebox( "Produto bloqueado, verifique!!!", "Atenção...", 48 )
             _lRet := .F.
          Endif
       Else
          Messagebox( "Produto inválido, verifique!!!", "Atenção...", 48 )
          _lRet := .F.
       Endif
       If !_lRet
          oGet1Mnt:SetFocus()
          cGet1Mnt := space(15)
          oGet1Mnt:Refresh()
          cGet4Mnt := space(30)
          oGet4Mnt:Refresh()
          cGet2Mnt := space(3)
          oGet2Mnt:Refresh()
          nGet3Mnt := 0
          oGet3Mnt:Refresh()
       Endif
Return

/*/{Protheus.doc} fAjuQtd
Ajusta quantidades utilizadas
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 19/05/2020
@param nQtdAju, numeric, Quantidade a ser ajustada
@return numeric, Retorna a quantidade ajustada
/*/
Static Function fAjuQtd( nQtdAju )
       Local aButtons     := {}
       Local oFont1Aj     := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local nOpcAju      := 1
       Private nGet1Aju   := nQtdAju
       Private nOld1Aju   := nQtdAju
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       oModal := FWDialogModal():New()
       oModal:SetEscClose(.F.)
       oModal:setTitle("Quantidade")
       oModal:setSize( 080, 135 )
       oModal:createDialog()
       Aadd( aButtons, { "", 'Confirma', {|| lOpcMnt := .f., nOpcAju := 1, oModal:DeActivate() }, , , .T., .F. } )
       Aadd( aButtons, { "", 'Cancela' , {|| lOpcMnt := .f., nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )

       oModal:addButtons(aButtons)

       oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
       oContainer:Align := CONTROL_ALIGN_ALLCLIENT

       oGet1Aju   := TGet():New( 004, 052,{|u| If(PCount() > 0, nGet1Aju := u, nGet1Aju) }, oContainer, 030, 012, '@E 9,999.999', { || fVldQtd( ) }, CLR_BLACK, CLR_WHITE, oFont1Aj, , , .T., "", , , .F., .F., , .F., .F., "", "nGet1Aju", ,)
       //oGet1Aju:SetFocus()
       oModal:Activate()
       If nOpcAju == 1
          nOpcAju := 0
          nGet3Mnt := nGet1Aju
          oGet3Mnt:Refresh()
       Endif
Return(nGet1Aju)

Static Function fVldQtd( )
       Local _lRet    := .t.
       Local _nTolera := GetMV( "ZP_PAR0025" ) //Parâmetro de tolerância para alteração de itens de estrutura 0.05
       Local _nTolIni := GetMV( "ZP_PAR0026" ) //Parâmetro de tolerância para inclusão de novos itens pelo peso total liquido no apontamento de produção. 0.15
       Local _nLimIni := 0
       Local _nValTol := Round( nOld1Aju * ( _nTolera ), 3 )
       Local _nTolMai := Round( nOld1Aju + _nValTol, 3 )
       Local _nTolMen := Round( nOld1Aju - _nValTol, 3 )
       Local _nX      := 0
       Local _nNewSom := 0

       If !( _aAptAtu[1] == 1 .and. _aAptAtu[2] == 'I' ) //Se for inicio da primeira operação ignora tolerâncias
          If nOld1Aju > 0 .and. nOld1Aju <> nGet1Aju
             If nGet1Aju > _nTolMai .or. nGet1Aju < _nTolMen
                MessageBox( 'Atenção, quantidade digitada é divergente devido a tolerância.', 'Atenção', 48 )
                nGet1Aju := nOld1Aju
                _lRet := .f. 
                oGet1Aju:Refresh()
             Endif
          Else
             For _nX := 1 To Len( _aBrwIte )
                 _nNewSom += _aBrwIte[_nX][18]
             Next
             _nLimIni := Round( _nNewSom * _nTolIni, 3 )
             If nGet1Aju > _nLimIni
                MessageBox( 'Atenção, quantidade digitada é divergente devido a tolerância.', 'Atenção', 48 )
                nGet1Aju := nOld1Aju
                _lRet := .f. 
                oGet1Aju:Refresh()
             Endif
          Endif
       Endif
Return _lRet

/*/{Protheus.doc} fConEmpMnt
Confirmação da manutenção dos itens empenhados
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 19/05/2020
@param nOpcMnt , Numeric, Opção da manutenção dos itens empenhados
       _aUsrAut, Array  , Array com os usuários
       _nPosIni, Numeric, Posição inicial
/*/
Static Function fConEmpMnt( nOpcMnt, _aUsrAut, _nPosIni )
       Local _aAuxIte := { }
       Local _nX
       Local _lRet    := .F.

       DbSelectArea("SB1")
       SB1->( DbSetOrder( 1 ) )
       SB1->( DbSeek( xFilial("SB1") + cGet1Mnt ) )
       If nOpcMnt == 0 //Inclusão
          If nGet3Mnt > 0
             DbSelectArea("SC2")
             SC2->( DbSetOrder( 1 ) )
             SC2->( DbSeek( xFilial("SC2") + _cGet1Ord ) )
             If SC2->C2_FILIAL == '010101' //Brasilux Matriz
                If SC2->C2_LOCAL == '02' //Fabrica '1
                   If SB1->B1_TIPO == 'MP'
                      If Substr( SB1->B1_LOCPAD, 1, 1 ) == 'R'
                         cGet6Mnt := 'R1'
                      Else
                         cGet6Mnt := '01'
                      Endif
                   ElseIf SB1->B1_TIPO == 'PI'
                          If Substr( SB1->B1_LOCPAD, 1, 1 ) == 'R'
                             cGet6Mnt := 'R2'
                          Else
                             cGet6Mnt := '02'
                          Endif
                   Endif
                ElseIf SC2->C2_LOCAL == '20' //Fabrica '1
                       If SB1->B1_TIPO == 'MP'
                          If Substr(SB1->B1_LOCPAD,1,1)=='R'
                             cGet6Mnt := 'R2'
                          Else
                             cGet6Mnt := '10'
                          Endif
                       ElseIf SB1->B1_TIPO == 'PI'
                              If Substr( SB1->B1_LOCPAD, 1, 1 ) == 'R'
                                 cGet6Mnt := 'R2'
                              Else
                                 cGet6Mnt := '20'
                              Endif
                       Endif
                Else
                   cGet6Mnt := SB1->B1_LOCPAD
                Endif
             Else
                cGet6Mnt := SB1->B1_LOCPAD
             Endif
             DbSelectArea("SB2")
             SB2->( DbSetOrder( 1 ) )
             //SB2->( DbSeek( xFilial("SB2") + cGet1Mnt + SB1->B1_LOCPAD ) )
             SB2->( DbSeek( xFilial("SB2") + cGet1Mnt + cGet6Mnt ) )
             If ( SB2->B2_QATU - SB2->B2_QACLASS - Iif( _lReserva, SB2->B2_RESERVA, 0 ) ) >= Round( nGet3Mnt, 3 )
                _lRet := .T.
             Else
                MessageBox( 'Produto não possuí saldo suficiente para atender essa requisição.', 'Verifique', 48 )
                 /*If MsgYesNo( 'Produto não possuí saldo suficiente para atender essa requisição. Continua? ')
                    _lRet      := .T.
                    _lSaldoIns := .T.
                 Endif*/
             Endif
             If _lRet   
                aAdd( _aBrwIte, { cGet1Mnt                           ,; //01 - Codigo do Produto
                                  cGet2Mnt                           ,; //02 - Sequencia da Fórmula
                                  Iif( Len( _aUsrAut ) <= 0, 0, Round( nGet3Mnt, 3 ) ),; //03 - Quantidade Original empenhada
                                  Round( nGet3Mnt, 3 )               ,; //04 - Quantidade Usada
                                  Iif( _aRotApt[ _aAptAtu[1] ][12] $ 'XXB', 'P', Iif( _aRotApt[ _aAptAtu[1] ][12] $ 'XXC', 'C', Iif( _aRotApt[ _aAptAtu[1] ][12] $ 'XXL', 'L', 'O' ) ) ),; //05 - Tipo do empenho (P=PESAGEM / C=TINGIMENTO / L=LABORATORIO / O=OUTRAS OPERACOES (SEGUIR ZZF_OPERAC-ITEM 17 DESSE ARRAY))
                                  cGet6Mnt /*SB1->B1_LOCPAD*/        ,; //06 - Local para baixa (Armazem)
                                  0                                  ,; //07 - Acerto de COR - Campo mantido por compatibilidade
                                  StrTokArr( _aRotApt[ _aAptAtu[1]][4], ' ' )[1],; //08
                                  'S'                                ,; //09 - S=Visivel / N=Nao Visivel - Campo mantido por compatibilidade
                                  'N'                                ,; //10 - Empenho Original S-Sim/SA=Acerto de Cor/SE=Empenho SD4/N=Incluido
                                  '2'                                ,; //11 - 1=Baixado / 2=Nao Baixado
                                  SB2->B2_QATU                       ,; //12 - Saldo Atual
                                  Iif( _lReserva, SB2->B2_RESERVA, 0),; //13 - Reservado
                                  SB2->B2_QATU - Iif( _lReserva, SB2->B2_RESERVA, 0 ),; //14 - Disponivel
                                                                     ,; //15 - 
                                  SB1->B1_TIPO                       ,; //16 - Tipo do Produto
                                  _aRotApt[_aAptAtu[1]][3]           ,; //17 - Operação
                                  nGet3Mnt                           }) //18
                _cMaxTRT := cGet2Mnt
                _nGet1Ite += Round( nGet3Mnt, 3 )
                _nGet2Ite += Round( nGet3Mnt, 3 )
                //Inclusão de item gravar também na tabela ZZF
                If Len( _aUsrAut ) <= 0 //Só grava senão for manutenção no inicio da primeira operação
                   RecLock( "ZZF", .T. )
                      ZZF->ZZF_FILIAL := xFilial("ZZF")
                      ZZF->ZZF_ORDEM  := _cGet1Ord
                      ZZF->ZZF_LOTE   := _cGet2Lot
                      ZZF->ZZF_CODIGO := cGet1Mnt
                      ZZF->ZZF_TRT    := cGet2Mnt
                      ZZF->ZZF_QTDORI := 0
                      ZZF->ZZF_QTDUSA := Round( nGet3Mnt, 3 )
                      ZZF->ZZF_FLAG   := '2'
                      ZZF->ZZF_TIPEMP := Iif( _aRotApt[ _aAptAtu[1] ][12] $ 'XXB', 'P', Iif( _aRotApt[ _aAptAtu[1] ][12] $ 'XXC', 'C', Iif( _aRotApt[ _aAptAtu[1] ][12] $ 'XXL', 'L', 'O' ) ) )
                      ZZF->ZZF_OBS    := 'N ' + " / Aguardando"
                      ZZF->ZZF_LOCAL  := cGet6Mnt /*SB1->B1_LOCPAD */
                      ZZF->ZZF_ORIGIN := 'I'
                      ZZF->ZZF_OPERAC := _aRotApt[ _aAptAtu[1] ][ 3 ]
                      ZZF->ZZF_XHABIL := _cMVXHABZZ
                   ZZF->( MsUnLock() )
                else
                   _aUsrAut[ _nPosIni ][ 8] := DTOC( MSDate() ) + '-' + SubStr( Time(), 1, 5 ) + ' ' + Iif( nOpcMnt == 0, 'INCLUSAO..: ', Iif( nOpcMnt == 1, 'ALTERACAO.: ', 'EXCLUSAO..: ' ) ) + Alltrim( cGet1Mnt ) + ' - ' + SB1->B1_LOCPAD + ' / ' + cGet2Mnt + ' / ' + TransForm( nGet3Mnt, '999,999.999' ) + ' # ' + Alltrim( _aUsrAut[ _nPosIni ][14] )
                   _aUsrAut[ _nPosIni ][13] := 'S'
                   _aUsrAut[ _nPosIni ][ 9] := cGet1Mnt
                   _aUsrAut[ _nPosIni ][10] := cGet4Mnt
                   _aUsrAut[ _nPosIni ][11] := cGet2Mnt
                   _aUsrAut[ _nPosIni ][12] := nGet3Mnt
                   _aUsrAut[ _nPosIni ][15] := nGet3Mnt
                   _aUsrAut[ _nPosIni ][16] := cGet6Mnt //SB1->B1_LOCPAD
                Endif
             Endif   
          else
             MessageBox( "Informe uma quantidade valida, ou clique em Abandona.", "Atenção", 16 )
          Endif
       ElseIf nOpcMnt == 1 //Alteração
              DbSelectArea("SB2")
              SB2->( DbSetOrder( 1 ) )
              //SB2->( DbSeek( xFilial("SB2") + cGet1Mnt + SB1->B1_LOCPAD ) )
              SB2->( DbSeek( xFilial("SB2") + cGet1Mnt + cGet6Mnt ) )
              If ( SB2->B2_QATU - SB2->B2_QACLASS - Iif( _lReserva, SB2->B2_RESERVA, 0 ) ) >= Round( nGet3Mnt, 3 )
                 _lRet := .T.
              else
                 MessageBox( 'Produto não possuí saldo suficiente para atender essa requisição.', 'Verifique', 48 )
                 /*If MsgYesNo( 'Produto não possuí saldo suficiente para atender essa requisição. Continua? ')
                    _lRet      := .T.
                    _lSaldoIns := .T.
                 Endif*/
              Endif
              If _lRet
                 _nGet1Ite -= Round( _oBrwIte:aArray[ _oBrwIte:nAt][ 4 ], 3 ) //Tiro a quantidade original
                 _nGet2Ite -= Round( _oBrwIte:aArray[ _oBrwIte:nAt][ 4 ], 3 ) //Tiro a quantidade original
                 _nGet1Ite += Round( nGet3Mnt, 3 )                            //Ajusto Peso Liquido
                 _nGet2Ite += Round( nGet3Mnt, 3 )                            //Ajusto Peso Bruto
                 _oBrwIte:aArray[ _oBrwIte:nAt][ 4 ] := nGet3Mnt              //Ajusto a quantidade original
                 If Len( _aUsrAut ) <= 0
                    DbSelectArea("ZZF")
                    ZZF->( DbSetOrder( 4 ) )
                    If ZZF->( DbSeek( xFilial("ZZF") + _cGet1Ord + _oBrwIte:aArray[ _oBrwIte:nAt][ 1 ] + _oBrwIte:aArray[ _oBrwIte:nAt][ 2 ] ) )
                       If !( _oBrwIte:aArray[ _oBrwIte:nAt][ 4 ] == ZZF->ZZF_QTDUSA )
                          RecLock( "ZZF", .F. )
                             ZZF->ZZF_QTDUSA := _oBrwIte:aArray[ _oBrwIte:nAt][ 4 ]
                          ZZF->( MsUnLock() )
                       Endif
                    Endif
                 Else
                    //_oBrwIte:aArray[ _oBrwIte:nAt][ 3 ] := nGet3Mnt              //Ajusto a quantidade usada somente na primeira operação
                    _aUsrAut[ _nPosIni ][13] := 'S'
                 Endif
              Endif
       Else //Exclusão
          _lRet := .T.
          //If SubStr( _oBrwIte:aArray[ _oBrwIte:nAt][ 10 ], 1, 1 ) == 'S' .and. Len( _aUsrAut ) <= 0 //.and. _aAptAtu[1] <> 1//Item original
          //   MessageBox( "Item original não pode ser excluido.", "Atenção", 16 )
          //else
             If _oBrwIte:aArray[_oBrwIte:nAt][11] == "1"
                Messagebox( "Item já baixado não pode ser " + Iif( nOpcMnt == 1, 'alterado', 'excluido' ) + ".", "Atenção...", 48 ) 
             Else
                _nGet1Ite := 0
                _nGet2Ite := Round( _nGet7Tar, 3 )
                For _nX := 1 To Len( _oBrwIte:aArray )
                    If !( _nX == _oBrwIte:nAt )
                       _nGet1Ite += Round( _oBrwIte:aArray[_nX][4], 3 )
                       _nGet2Ite += Round( _oBrwIte:aArray[_nX][4], 3 )
                       aAdd( _aAuxIte, _oBrwIte:aArray[_nX] )
                    Else
                       If  Len( _aUsrAut ) > 0
                          aAdd( _aUsrExc, _oBrwIte:aArray[_nX] )
                          _aUsrAut[ _nPosIni ][13] := 'S'
                       Endif
                    Endif
                Next
                If Len( _aAuxIte ) == 0
                   aAdd( _aAuxIte, { '', '', 0, 0, '', '', 0, '', '', '', '', 0, 0, 0, , '', '' } )
                Endif
                DbSelectArea("ZZF")
                ZZF->( DbSetOrder( 4 ) )
                If ZZF->( DbSeek( xFilial("ZZF") + _cGet1Ord + _oBrwIte:aArray[ _oBrwIte:nAt][ 1 ] + _oBrwIte:aArray[ _oBrwIte:nAt][ 2 ] ) )
                   RecLock( "ZZF", .F. )
                      ZZF->( DbDelete() )
                   ZZF->( MsUnLock() )
                Endif
                _aBrwIte        := _aAuxIte
                _oBrwIte:aArray := _aAuxIte
                _oBrwIte:nAt    := 1
                If _lEstNegat //Se a avaliação inicial encontrou que o produto estava com saldo menor do que o requisitado e houve uma exclusão, fazer a reavaliação
                   _lEstNegat := .f.
                   For _nX := 1 To Len( _aBrwIte )
                       DbSelectArea("SB2")
                       SB2->( DbSetOrder( 1 ) )
                       SB2->( DbSeek( xFilial("SB2") + _aBrwIte[_nX][1] + _aBrwIte[_nX][6] ) )
                       If ( SB2->B2_QATU - SB2->B2_QACLASS - Iif( _lReserva, SB2->B2_RESERVA, 0 ) ) < Round( _aBrwIte[_nX][4], 3 )
                          _lEstNegat := .t.
                       Endif
                   Next
                Endif
             Endif
          //Endif
       Endif
       If _lRet
          _oGetIte01:Refresh()
          _oGetIte02:Refresh()
          _oBrwIte:Refresh()
          oGet3Mnt:Refresh()
          oDlg1Mnt:End()
       Endif
Return

/*/{Protheus.doc} fMntFunApt
Manutenção de Responsáveis
@type function
@version 2020.01
@author Luís Gustavo
@since 28/05/2020
@param _nOpcFun, numeric, parametro que tras o tipo de manutenção 0=inclusão/1=exclusão
/*/
Static Function fMntFunApt( _nOpcFun )
       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Declaração de cVariable dos componentes                                 ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       Local _lRet        := .t.
       Private cPesqF3    := _aRotApt[ _aAptAtu[1] ][12]
       Private cGet1Mnt   := Iif( _nOpcFun == 0 , Space(08), _oBrwRes:aArray[_oBrwRes:nAt][1] )
       Private cGet2Mnt   := Iif( _nOpcFun == 0 , Space(30), _oBrwRes:aArray[_oBrwRes:nAt][2] )
       Private cSay1Mnt   := Space(1)
       Private cSay2Mnt   := Space(1)
       Private lCBox1En   := .T.
       
       If _nOpcFun == 1
          If Len( _oBrwRes:aArray ) == 1 .and. Empty( _oBrwRes:aArray[1][1] )
             _lRet := .f.
          Endif
       Endif
       If _lRet
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Declaração de Variaveis Private dos Objetos                             ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          SetPrvt("oFontMn1", "oFontMn2", "oDlg1Mnt", "oSay1Mnt", "oSay2Mnt", "oGet1Mnt", "oGet2Mnt", "oBtn2Mnt", "oBtn1Mnt")
          /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
          ±± Definicao do Dialog e todos os seus componentes.                        ±±
          Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
          oFontMn1   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
          oFontMn2   := TFont():New( "MS Sans Serif", 0, -16, , .F., 0, , 400, .F., .F., , , , , , )
          oDlg1Mnt   := MSDialog():New( 258, 232, 356, 828, "Manutenção de Funcionarios", , , .F., , , , , , .T., , , .T. )
          oSay1Mnt   := TSay():New( 004, 004, {|| "Matric..:"}, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
          oSay2Mnt   := TSay():New( 021, 004, {|| "Nome:"    }, oDlg1Mnt, , oFontMn1, .F., .F., .F., .T., CLR_BLUE, CLR_WHITE, 048, 012)
          oGet1Mnt   := TGet():New( 002, 056, {|u| If( PCount() > 0, cGet1Mnt := u, cGet1Mnt ) }, oDlg1Mnt, 054, 012, '@!R 999999', , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , Iif( _nOpcFun == 0, .F., .T.), .F., , "cGet1Mnt", , )
          oGet1Mnt:CF3 := cPesqF3
          oGet2Mnt   := TGet():New( 020, 056, {|u| If( PCount() > 0, cGet2Mnt := u, cGet2Mnt ) }, oDlg1Mnt, 236, 012, '@!'        , , CLR_BLACK, CLR_WHITE, oFontMn2, , , .T., "", , , .F., .F., , .T.                         , .F., ""     , "cGet2Mnt", , )
          oBtn2Mnt   := TButton():New( 036, 254, "Abandona", oDlg1Mnt, {|| oDlg1Mnt:End()         }, 037, 012, , , , .T., , "", , , , .F. )
          oBtn1Mnt   := TButton():New( 036, 212, "Confirma", oDlg1Mnt, {|| fGrvMntApt( _nOpcFun ) }, 037, 012, , , , .T., , "", , , , .F. )
          oGet1Mnt:bLostFocus := {|| Iif( !Empty(cGet1Mnt) .and. _nOpcFun == 0, fBusAptOrd(), ) }
          oDlg1Mnt:Activate(,,,.T.)
       Endif
Return

/*/{Protheus.doc} fGrvMntApt
Grava manutenção de inclusão/alteração/exclusão de materias primas
@type function
@version 2020.01
@author Luís Gustavo
@since 28/05/2020
@param _nOpcFun, numeric, Parametro que tras a opção de manutenção 0=inclusão/1=exclusão
/*/
Static Function fGrvMntApt( _nOpcFun )
       Local _nX
       Local _lAchou  := .f.
       Local _aAuxRes := {}
       If _nOpcFun == 0 //Inclusão
          If Empty( Alltrim( _oBrwRes:aArray[1][1] ) )
             _oBrwRes:aArray[1][1] := cGet1Mnt
             _oBrwRes:aArray[1][2] := cGet2Mnt
          Else
             For _nX := 1 To Len( _oBrwRes:aArray )
                 If Alltrim( _oBrwRes:aArray[_nX][1] ) == Alltrim( cGet1Mnt )
                    MessageBox( "Responsável já está cadastrado.", "Atenção", 16 )
                    _lAchou := .T.
                 Endif
             Next
             If !_lAchou
                aAdd( _aBrwRes, { cGet1Mnt, cGet2Mnt } )
             Endif
          Endif
       Else //Exclusão
          For _nX := 1 To Len( _oBrwRes:aArray )
              If !( _nX == _oBrwRes:nAt )
                 aAdd( _aAuxRes, { _oBrwRes:aArray[_nX][1], _oBrwRes:aArray[_nX][2] } ) 
              Endif
          Next
          If Len( _aAuxRes ) == 0
             aAdd( _aAuxRes, { space(06), space(40) } )
          Endif
          _aBrwRes        := _aAuxRes
          _oBrwRes:aArray := _aAuxRes
          _oBrwRes:nAt    := 1
       Endif
       _oBrwRes:Refresh()
       oDlg1Mnt:End()
Return

/*/{Protheus.doc} fBusAptOrd
Valida responsável digitado e carrega o nome
@type function
@version 2020.01
@author Luís Gustavo
@since 28/05/2020
@return logical, retorna verdadeiro ou falso para validação do responsável
/*/
Static Function fBusAptOrd()
       Local _lRet := .T.

       //Pesquiso codigo digito para verificar se existe na tabela
       DbSelectArea("SX5")
       SX5->( DbSetOrder( 1 ) )
       If !SX5->( DbSeek( xFilial("SRA") + SubStr( _aRotApt[ _aAptAtu[1]][12], 2, 2 ) + M->cGet1Mnt ) )
          _lRet := .f.
       Endif
       If _lRet
          cGet2Mnt := Alltrim( SX5->X5_DESCRI )
          oGet2Mnt:Refresh()
       Else
          cGet2Mnt := Space( 40 )
          oGet2Mnt:Refresh()
          cGet1Mnt := Space( 06 )
          oGet1Mnt:Refresh()
          oGet1Mnt:SetFocus()
       Endif
Return _lRet

User Function FiltroF3( cTitulo, cQuery, nTamCpo, cAlias, cCodigo, cCpoChave, cTitCampo, cMascara, cRetCpo, nColuna )
     Local nLista
     Local cCampos    := ""
     Local bCampo     := {}
     Local nCont      := 0
     Local aCampos    := {}
     Local cTabela
     Local nX
     Local cCSSGet    := "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
     Local cCSSButton := "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"

     Private _oLista  := nil
     Private _oDlg    := nil
     Private _oCodigo
     Private _cCodigo
     Private _aDados  := {}
     Private _nColuna := 0
	
     Default cTitulo  := ""
     Default cCodigo  := ""
     Default nTamCpo  := 30
     Default _nColuna := 1
     Default cTitCampo:= RetTitle(cCpoChave)
     Default cMascara := PesqPict('"'+cAlias+'"',cCpoChave)

     _nColuna := nColuna

     If Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
        MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias são obrigatórios!","Erro")
        Return
     Endif

     _cCodigo := Space(nTamCpo)
     _cCodigo := cCodigo

     cTabela:= GetNextAlias()
     DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)
     
     (cTabela)->(DbGoTop())
     If (cTabela)->(Eof())
        MsgStop("Não há registros para serem exibidos!","Atenção")
        Return
     Endif
   
     Do While (cTabela)->(!Eof())
        /*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
        cCampos	:= ""
        aCampos 	:= {}
        For nX := 1 TO FCount()
            bCampo := {|nX| Field(nX) }
            If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
               if ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
                  cCampos += "'" + (cTabela)->&(EVAL(bCampo,nX)) + "',"
               ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
                      cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
               Else
                  cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
               Endif
               aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",30})
            Endif
        Next
        If !Empty(cCampos) 
           cCampos := Substr(cCampos,1,len(cCampos)-1)
           aAdd( _aDados,&("{"+cCampos+"}"))
        Endif
     	
        (cTabela)->(DbSkip())     
     Enddo
     DbSelectArea(cTabela)
     (cTabela)->( DbCloseArea( ) )

     If Len(_aDados) == 0
        MsgInfo("Não há dados para exibir!","Aviso")
        Return
     Endif
   
     nLista := aScan(_aDados, {|x| alltrim(x[1]) == alltrim(_cCodigo)})
     
     iif(nLista = 0,nLista := 1,nLista)
     
     Define MsDialog _oDlg Title "Consulta Padrão" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel

            oCodigo:= TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| /*Processa({|| FiltroF3P(M->_cCodigo)},"Aguarde...")*/ },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
            oCodigo:SetCss(cCSSGet)	
            oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| FiltroF3P(M->_cCodigo) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
            oButton1:SetCss(cCSSButton)	
	    
            _oLista:= TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)
            nCont := 1
            //Para ficar dinâmico a criação das colunas, eu uso macro substituição "&"
            For nX := 1 to len(aCampos)
                cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
                nCont++
            Next
            _oLista:SetArray(_aDados)
            _oLista:bWhen 		 := { || Len(_aDados) > 0 }
            _oLista:bLDblClick  := { || FiltroF3R(_oLista:nAt, _aDados, cRetCpo)  }
            _oLista:Refresh()
 
            oButton2 := TButton():New(122, 005," OK "			,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDados, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
            oButton2:SetCss(cCSSButton)	
            oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	         oButton3:SetCss(cCSSButton)	

     Activate MSDialog _oDlg Centered
Return(bRet)

Static Function FiltroF3R( nLinha, aDados, cRetCpo )
       cCodigo := aDados[nLinha,_nColuna]
       &(cRetCpo) := cCodigo //Uso desta forma para campos como tGet por exemplo.
       bRet := .T.
       _oDlg:End()    
Return

Static Function FiltroF3P(cBusca)
       Local i := 0

       If !Empty(cBusca)
          For i := 1 to len(_aDados)
              //Aqui busco o texto exato, mas pode utilizar a função AT() para pegar parte do texto
              If UPPER(Alltrim(_aDados[i,_nColuna]))==UPPER(Alltrim(cBusca))
                 //Se encontrar me posiciono no grid e saio do "For"			
                 _oLista:GoPosition(i)
                 _oLista:Setfocus()
                 exit
              Endif
          Next
       Endif
Return

User Function FCONPADF3( _cOpc )
     Local cTitulo   := "Responsáveis"
     Local cQuery    := ""                         //obrigatorio
     Local cAlias    := _cOpc                      //obrigatorio
     Local cCpoChave := "X5_CHAVE"                 //obrigatorio
     Local cTitCampo := RetTitle(cCpoChave)        //obrigatorio
     Local cMascara	:= PesqPict(cAlias,cCpoChave) //obrigatorio
     Local nTamCpo   := TamSx3(cCpoChave)[1]
     Local cRetCpo   := "M->cGet1Mnt"              //obrigatorio
     Local nColuna   := 1	
     Local cCodigo   := M->cGet1Mnt                //pego o conteudo e levo para minha consulta padrão
     Private bRet    := .F.

     //Monto minha consulta, neste caso quero retornar apenas uma coluna, mas poderia inserir outros campos para compor outras colunas no grid, lembrando que não posso utilizar um alias para o nome do campo, deixar o nome real.
     //Posso fazer qualquer tipo de consulta, usando INNER, GROUPY BY, UNION's etc..., desde que mantenha o nome dos campos no SELECT.
     cQuery := "SELECT DISTINCT SX5.X5_CHAVE, SX5.X5_DESCRI "
     cQuery += "FROM "+RetSQLName("SX5") + " AS SX5 " //WITH (NOLOCK)
     cQuery += " WHERE SX5.X5_FILIAL  = '" + xFilial("SRA") + "' "
     cQuery += " AND SX5.D_E_L_E_T_ = ' ' "
     cQuery += " AND SX5.X5_TABELA = '" + SubStr( cAlias, 2, 2 ) + "' "
     cQuery += " ORDER BY SX5.X5_DESCRI "

     bRet := U_FiltroF3( cTitulo, cQuery, nTamCpo, cAlias, cCodigo, cCpoChave, cTitCampo, cMascara, cRetCpo, nColuna )

     //Devido a pesquisa ser na tabela SX5 - e o retorno ser X5_CHAVE - devo posicionar a mesma para correto retorno
     DbSelectArea("SX5")
     SX5->( DbSetOrder( 1 ) )
     SX5->( DbSeek( xFilial("SRA") + SubStr( cAlias, 2, 2 ) + M->cGet1Mnt ) )
Return( bRet )


Static Function fGrvAponta( _cOpcApt )
       Local _lRet      := .T.
       //Local _nPosAut   := 0
       Local _nOpcAju   := 0
       Local _aButtons  := {}
       Local _cGet1Mot  := space(10)
       Local _cGet2Mot  := space(40)
       Local _oFont1Mot := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
       Local _nX, _nY
       Local _aFinal    := {}

       If _nGet7Tar > 0 //Verificação se o peso da Tara do Tacho foi recuperada ou digitada
          If _aAptAtu[2] == 'F' //Indica inicio/fim da Ordem de produção - Para o final os responsáveis devem estar indicados no array
             If ( Len( _aBrwRes ) == 1 .and. Empty( _aBrwRes[1][1]) ) .and. !Empty( _aRotApt[ _aAptAtu[1] ][ 12 ] )
                MessageBox( "Pelo menos um responsável por fase deve ser indicado.", "Atenção", 16 )
                _lRet := .f.
             Endif
             If _lRet
                //Verifica o tempo entre inicio e fim que deve ser maior que 1 min.
                If ELAPTIME( Stuff( ZZA->ZZA_HINI, 3, 0, ':' ) + ':00', Time() ) <= '00:00:59'
                   MessageBox( 'Tempo de apontamento deve ser superior a 1 min no protheus.', 'Atenção', 48)
                   _lRet := .f.
                Endif
             Endif
             If _lRet
                If _aRotApt[ _aAptAtu[1]][12] == 'XXL' //Apontamento de Laboratório
                   If _nGet4Ite <= 0 .and. _cOpcApt <> 'P'
                      MessageBox( 'Peso especifico não informado, verifique', 'Atenção', 16 )
                      _lRet := .f.
                   Endif
                Endif
             Endif
             If _lRet
                If _cOpcApt == 'P' //Pausa
                   //Busca Motivo da Pausa
                   _lRetPar := .t.
                   oModal := FWDialogModal():New()
                   oModal:SetEscClose(.F.)
                   oModal:setTitle("Motivo de Parada")
                   oModal:setSize( 100, 155 )
                   oModal:createDialog()
                   aAdd( _aButtons, { "", 'Confirma', {|| _lRetPar := fVldPar( _cGet1Mot, @_oGet2DMot, @_cGet2Mot ), Iif( _lRetPar, _nOpcAju := 1, _nOpcAju := 0 ), Iif( _lRetPar, oModal:DeActivate(), ) }, , , .T., .F. } )
                   aAdd( _aButtons, { "", 'Cancela' , {|| _nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )
                   oModal:addButtons( _aButtons )

                   oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
                   oContainer:Align := CONTROL_ALIGN_ALLCLIENT

                   _oGet1Mot     := TGet():New( 004, 004, {|u| If (PCount() > 0, _cGet1Mot := u, _cGet1Mot ) }, oContainer, 070 , 012, '@!', { || fVldPar( _cGet1Mot, @_oGet2DMot, @_cGet2Mot ) }, CLR_BLACK, CLR_WHITE, _oFont1Mot,    , , .T., "", , , .F., .F., , .F., .F., "", "_cGet1Mot", , , , , , , 'Motivo de Parada'   , 1,          , CLR_BLUE, '<Motivo de Parada>'    , .T. )
                   _oGet2DMot    := TGet():New( 028, 004, {|u| If (PCount() > 0, _cGet2Mot := u, _cGet2Mot ) }, oContainer, 150 , 012, '@!',           , CLR_BLACK, CLR_WHITE, _oFont1Mot,    , , .T., "", , , .F., .F., , .T., .F., "", "_cGet2Mot", , , , , , , 'Descrição'          , 1,          , CLR_BLUE, ' '                     , .T. )

                   _oGet1Mot:cF3 := 'CYN004'
                   oModal:Activate()
                   If !_nOpcAju == 1
                      _lRet := .f.
                   Endif
                Else //Para apontamento confiro se o peso liquido final está apontado.
                   For _nY := 1 To Len( _aBrwIte )
                       If _aBrwIte[_nY][4] <=0
                          _lRet := .f.
                       Endif
                   Next
                   If !_lRet
                      MessageBox( 'Existem materiais sem peso informado (Altere com a quantidade correta ou exclua o mesmo.), verifique!', 'Atenção', 16 )
                   Endif
                Endif
             Endif
          ElseIf _aAptAtu[2] == 'C' //Conferência de peso
                 If _nGet3Ite > 0
                    If ( Len( _aBrwRes ) == 1 .and. Empty( _aBrwRes[1][1]) )
                       MessageBox( "Pelo menos um responsável por fase deve ser indicado.", "Atenção", 16 )
                       _lRet := .f.
                    Endif
                 Else
                    MessageBox( "Peso da balança deve ser informado.", "Atenção", 16 )
                    _lRet := .f.
                 Endif
          ElseIf _aAptAtu[2] == 'I' .and. _aAptAtu[1] == 1
                 If _lMVVEREST .and. _lEstNegat //Verifica apontamento inicial de pesagem
                    MessageBox( "Ordem de produção não pode ser iniciada pois existe(m) produto(s) indisponível(is).", "Atenção", 16 )
                    _lRet := .f.
                 Endif
          Endif
       Else
          MessageBox( "Peso da tara não foi informado.", "Verifique.", 16 )
          _lRet := .f.
       Endif

       If _lRet
          If _aAptAtu[2] $ 'I.F'
             //Gravo tabela ZZA - Apontamento / verificar se é inicio ou fim
             For _nX := 1 To Len( _aRotApt )
                 DbSelectArea("ZZA")
                 ZZA->( DbSetOrder( 5 ) )
                 If ZZA->( DbSeek( xFilial("ZZA") + _cGet1Ord + _aRotApt[ _nX ][ 3 ] + _aRotApt[ _nX ][ 14 ]  ) ) //Filial + Ordem + Operação + Sequencia
                    //Atualizar
                    If _aRotApt[ _nX ][ 3 ] == _aRotApt[ _aAptAtu[1]  ][ 3 ] .and. _aRotApt[ _nX ][ 14 ] == _aRotApt[ _aAptAtu[1]  ][ 14 ]
                       RecLock( "ZZA", .f. )
                          If _aAptAtu[2] == 'I' //Gravação de Inicio
                             ZZA->ZZA_HELP   := '1 - Inicio ' + _aRotApt[ _aAptAtu[1]  ][ 3 ] + '-' + Alltrim( _aRotApt[ _aAptAtu[1]  ][ 4 ] )
                             ZZA->ZZA_FLAG   := '1'
                             ZZA->ZZA_DTINI  := Date()
                             ZZA->ZZA_HINI   := SubStr( StrTran( Time(), ':', '' ), 1, 4 )
                          Else //Gravação de Fim
                             aAdd( _aFinal, { 'A', ZZA->ZZA_HELP, ZZA->ZZA_FLAG, ZZA->ZZA_DTFIM, ZZA->ZZA_HFIM, ZZA->ZZA_PESFIN, ZZA->ZZA_PESPES, ZZA->ZZA_DTPES, ZZA->ZZA_HPES, ZZA->ZZA_PESCOL, ZZA->ZZA_DTCOL, ZZA->ZZA_HCOL, ZZA->ZZA_PESLAB, ZZA->ZZA_PERDA, ZZA->ZZA_LIBLAB, ZZA->ZZA_QUANT, ZZA->ZZA_MOTIVO } )
                             ZZA->ZZA_HELP   := Iif( _cOpcApt == 'A', '2 - Fim ' + _aRotApt[ _aAptAtu[1]  ][ 3 ] + '-' + Alltrim( _aRotApt[ _aAptAtu[1]  ][ 4 ] ), '3 - Pausa ' + _aRotApt[ _aAptAtu[1]  ][ 3 ] + '-' + Alltrim( _aRotApt[ _aAptAtu[1]  ][ 4 ] ) )
                             ZZA->ZZA_FLAG   := Iif( _cOpcApt == 'A', '2', '3' )
                             ZZA->ZZA_DTFIM  := Date()
                             ZZA->ZZA_HFIM   := SubStr( StrTran( Time(), ':', '' ), 1, 4 )
                             ZZA->ZZA_PESFIN := _nGet1Ite
                             //Gravando campos abaixo para manter compatibilidade com apontamentos antigos
                             If  _aRotApt[ _aAptAtu[1]  ][ 12 ] == 'XXB' //Pesagem
                                 ZZA->ZZA_PESPES := _nGet1Ite
                                 ZZA->ZZA_DTPES  := Date()
                                 ZZA->ZZA_HPES   := SubStr( StrTran( Time(), ':', '' ), 1, 4 )
                             ElseIf _aRotApt[ _aAptAtu[1]  ][ 12 ] == 'XXC' //Colorista
                                    ZZA->ZZA_PESCOL := _nGet1Ite
                                    ZZA->ZZA_DTCOL  := Date()
                                    ZZA->ZZA_HCOL   := SubStr( StrTran( Time(), ':', '' ), 1, 4 )
                             ElseIf _aRotApt[ _aAptAtu[1]  ][ 12 ] == 'XXL' //Laboratorio
                                    ZZA->ZZA_PESLAB := _nGet4Ite
                                    ZZA->ZZA_PERDA  := Iif( _nGet3Qtd > Round( _nGet1Ite / _nGet4Ite, 3 ), _nGet3Qtd - Round( _nGet1Ite / _nGet4Ite, 3 ), 0 )
                                    ZZA->ZZA_LIBLAB := _cRetSup
                                    ZZA->ZZA_QUANT  := Round( Iif( Posicione( "SB1", 1, xFilial("SB1") + ZZA->ZZA_PRODUT, "B1_UM" ) $ 'UN.KG.K ', _nGet1Ite, ( _nGet1Ite / Iif( _nGet4Ite == 0, _nGet4Pes, _nGet4Ite ) ) ) , 3 )
                                    /*If _cOpcApt == 'A' .and. _aAptAtu[2] == 'F' //Envio para o PCF somente no final do processo.
                                       FINTEGPCF()
                                    Endif*/
                             Else //Outros apontamentos
                             
                             Endif
                          Endif
                          If _cOpcApt == 'P'
                             ZZA->ZZA_MOTIVO := _cGet1Mot
                          Endif
                          If Len( _aRotApt ) == _aAptAtu[1] .and. _cOpcApt == 'A'
                             ZZA->ZZA_QUANT  := Round( Iif( Posicione( "SB1", 1, xFilial("SB1") + ZZA->ZZA_PRODUT, "B1_UM" ) $ 'UN.KG.K ', _nGet1Ite, ( _nGet1Ite / Iif( _nGet4Ite == 0, _nGet4Pes, _nGet4Ite ) ) ) , 3 )
                          Endif
                       ZZA->( MsUnLock() )
                       If Len( _aRotApt ) == _aAptAtu[1] .and. _cOpcApt == 'A'
                          If _cOpcApt == 'A' .and. _aAptAtu[2] == 'F' //Envio para o PCF somente no final do processo.
                             //FINTEGPCF() //LGS#20210215 - Passado para após o apontamento final.
                          Endif
                       Endif
                       If _cOpcApt == 'P'
                          //Se for pausa crio um registro identico como não iniciado.
                          _aDadosZZA := {}
                          For _nY := 1 To ZZA->( FCount() )
                              aAdd( _aDadosZZA, FieldGet( _nY ) ) 
                          Next
                          //Grava o dados novamente na tabela
                          RecLock( "ZZA", .t. )
                             For _nY := 1 To Len( _aDadosZZA )
                                 If !FieldName( _nY ) $ 'ZZA_HELP.ZZA_FLAG.ZZA_QUANT.ZZA_DTINI.ZZA_HINI.ZZA.ZZA_DTPES.ZZA_HPES.ZZA_PESPES.ZZA_DTCOL.ZZA_HCOL.ZZA_DTFIM.ZZA_HFIM.ZZA_PESFIN.ZZA_PESLAB.ZZA_SEQENV'
                                    FieldPut( _nY, _aDadosZZA[_nY] )
                                 ElseIf FieldName( _nY ) $ 'ZZA_SEQENV'
                                        FieldPut( _nY, StrZero( Val( _aDadosZZA[_nY] ) + 1, 2 ) )
                                 ElseIf FieldName( _nY ) $ 'ZZA_FLAG'
                                        FieldPut( _nY, '0' )
                                 ElseIf FieldName( _nY ) $ 'ZZA_MOTIVO'
                                        FieldPut( _nY, Space(10) )
                                 Endif
                             Next
                          ZZA->( MsUnLock() )
                       Endif
                    Endif
                 else
                    //Incluir
                    RecLock( "ZZA", .T. )
                       ZZA->ZZA_FILIAL := xFilial("ZZA")
                       ZZA->ZZA_ORDEM  := _cGet1Ord
                       ZZA->ZZA_OPERAC := _aRotApt[ _nX ][ 3 ]
                       ZZA->ZZA_PRODUT := _cGet5Cod
                       ZZA->ZZA_LOTE   := _cGet2Lot
                       ZZA->ZZA_CAMPO  := _cFabrica
                       ZZA->ZZA_TARA   := _nGet7Tar
                       ZZA->ZZA_FLAG   := Iif( Empty( _aRotApt[_nX][5] ) .and. Empty( _aRotApt[_nX][6] ) , '0', '' )
                       ZZA->ZZA_ID     := _aRotApt[ _nX ][ 10 ] //Recurso
                       ZZA->ZZA_PESESP := _nGet4Pes
                       ZZA->ZZA_SEQENV := "01"
                       If _aAptAtu[2] == 'I' .and. _aRotApt[_nX][3] == _aRotApt[ _aAptAtu[1] ][ 3 ]
                          ZZA->ZZA_DTINI  := Date()
                          ZZA->ZZA_HINI   := SubStr( StrTran( Time(), ':', '' ), 1, 4 )
                          ZZA->ZZA_HELP   := '01 - Inicio de Pesagem' 
                          ZZA->ZZA_FLAG   := '1'
                          ZZA->ZZA_PESPES := _nGet1Ite
                       Endif
                    ZZA->( MsUnLock() )
                 Endif
             Next
             If _cOpcApt == 'A'
                //Gravo tabela ZZF - Empenhos - Somente no inicio do processo
                For _nX := 1 To Len( _aBrwIte )
                    /*If Len( _aUsrAut ) > 0
                       _nPosAut := aScan( _aUsrAut, { |x| x[9] == _aBrwIte[_nX][1] } )
                       If _nPosAut > 0
                          If _aUsrAut[ _nPosAut ][13] <> 'S'
                             _nPosAut := 0
                          Endif
                       Endif
                    Endif*/
                    DbSelectArea("ZZF")
                    ZZF->( DbSetOrder( 4 ) )
                    If ZZF->( DbSeek( xFilial("ZZF") + _cGet1Ord + _aBrwIte[_nX][1] + _aBrwIte[_nX][2] ) )
                       If ZZF->ZZF_FLAG <> '1'
                          If _aBrwIte[_nX][ 3] <> 0 .and. !( _aBrwIte[_nX][ 4] == ZZF->ZZF_QTDUSA )
                             RecLock( "ZZF", .F. )
                                //ZZF->ZZF_QTDUSA := _aBrwIte[_nX][ 4]
                                //ZZF->ZZF_OBSINI := Iif( Len( _aUsrAut ) > 0 .and. _nPosAut > 0, _aUsrAut[_nPosAut][8], ZZF->ZZF_OBS )
                             ZZF->( MsUnLock() )
                          Endif
                       Endif
                    Else
                       RecLock( "ZZF", .T. )
                          ZZF->ZZF_FILIAL := xFilial("ZZF")
                          ZZF->ZZF_ORDEM  := _cGet1Ord
                          ZZF->ZZF_LOTE   := _cGet2Lot
                          ZZF->ZZF_CODIGO := _aBrwIte[_nX][ 1]
                          ZZF->ZZF_TRT    := _aBrwIte[_nX][ 2]
                          ZZF->ZZF_QTDORI := _aBrwIte[_nX][ 3]
                          ZZF->ZZF_QTDUSA := _aBrwIte[_nX][ 4]
                          ZZF->ZZF_FLAG   := '2'                                  //Flag: 2 para ser baixado / 9 para aguardar processo.
                          ZZF->ZZF_TIPEMP := _aBrwIte[_nX][ 5]                    //P=Pesagem, C=Colorista, L=Laboratorio
                          ZZF->ZZF_OBS    := _aBrwIte[_nX][10] + " / Aguardando"  //Aguardando processar
                          ZZF->ZZF_LOCAL  := _aBrwIte[_nX][ 6]                    //Troca do local quanto apontamento for na fábrica 2 
                          ZZF->ZZF_ORIGIN := 'S'//Iif( _nPosAut == 0, 'I', 'S' )        //O=Original; I=Incluido; A=Alterado
                          ZZF->ZZF_OPERAC := _aRotApt[ _aAptAtu[1] ][ 3 ]
                          ZZF->ZZF_XHABIL := _cMVXHABZZ	                         //Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14
                          ZZF->ZZF_OBSINI := ''//Iif( Len( _aUsrAut ) > 0 .and. _nPosAut > 0, _aUsrAut[_nPosAut][8], ZZF->ZZF_OBSINI )
                       ZZF->( MsUnLock() )
                    Endif
                Next
                //Verificação da alteração inicial
                For _nX := 1 TO Len( _aUsrAut )
                    DbSelectArea("ZZF")
                    ZZF->( DbSetOrder( 4 ) )
                    If ZZF->( DbSeek( xFilial("ZZF") + _cGet1Ord + _aUsrAut[_nX][9] + _aUsrAut[_nX][11] ) )
                       If Empty( Alltrim( ZZF->ZZF_OBSINI ) )
                          RecLock( "ZZF", .F. )
                             ZZF->ZZF_OBSINI := _aUsrAut[_nX][8]
                          ZZF->( MsUnLock() )
                       Endif
                    Else
                       RecLock( "ZZF", .T. )
                          ZZF->ZZF_FILIAL := xFilial("ZZF")
                          ZZF->ZZF_ORDEM  := _cGet1Ord
                          ZZF->ZZF_LOTE   := _cGet2Lot
                          ZZF->ZZF_CODIGO := _aUsrAut[_nX][ 9]
                          ZZF->ZZF_TRT    := _aUsrAut[_nX][11]
                          ZZF->ZZF_QTDORI := _aUsrAut[_nX][12]
                          ZZF->ZZF_QTDUSA := _aUsrAut[_nX][15]
                          ZZF->ZZF_FLAG   := '2'                                  //Flag: 2 para ser baixado / 9 para aguardar processo.
                          ZZF->ZZF_TIPEMP := 'P'                    //P=Pesagem, C=Colorista, L=Laboratorio
                          ZZF->ZZF_OBS    := _aUsrAut[_nX][ 5] + " / Aguardando"  //Aguardando processar
                          ZZF->ZZF_LOCAL  := _aUsrAut[_nX][16]                    //Troca do local quanto apontamento for na fábrica 2 
                          ZZF->ZZF_ORIGIN := 'S'  //Iif( _nPosAut == 0, 'I', 'S' )        //O=Original; I=Incluido; A=Alterado
                          ZZF->ZZF_OPERAC := _aRotApt[ _aAptAtu[1] ][ 3 ]
                          ZZF->ZZF_XHABIL := _cMVXHABZZ	                         //Inclusão do campo para armazenar status do parametro Tiago Lucio Chaus/28/02/14
                          ZZF->ZZF_OBSINI := _aUsrAut[_nX][8]
                       ZZF->( MsUnLock() )
                    Endif
                Next
                For _nX := 1 TO Len( _aUsrExc )
                    DbSelectArea("ZZF")
                    ZZF->( DbSetOrder( 4 ) )
                    If ZZF->( DbSeek( xFilial("ZZF") + _cGet1Ord + _aUsrExc[_nX][1] + _aUsrExc[_nX][2] ) )
                       RecLock( "ZZF", .F. )
                          ZZF->( DbDelete() )
                       ZZF->( MsUnLock() )
                    Endif
                Next
             Endif
             //Gravo tabela ZZG - Responsáveis
             //Considerar o B=Balanceiro e P=Conferende da pesagem como o mesmo, conforme determinado pelo Gustavo Diniz em reunião de apresentação da tela
             //_cTipUser := _cTipUser := Iif( _aRotApt[_aAptAtu[1]][12] == 'XXB', IIF( _aAptAtu[2] <> 'C', 'B' , 'P' ), Iif( _aRotApt[_aAptAtu[1]][12] == 'XXC', 'C', Iif( _aRotApt[_aAptAtu[1]][12] == 'XXL', IIF( _aAptAtu[2] <> 'C', 'L' , 'F' ), 'O' ) ) )
             _cTipUser := _cTipUser := Iif( _aRotApt[_aAptAtu[1]][12] == 'XXB', IIF( _aAptAtu[2] <> 'C', 'B' , 'B' ), Iif( _aRotApt[_aAptAtu[1]][12] == 'XXC', 'C', Iif( _aRotApt[_aAptAtu[1]][12] == 'XXL', IIF( _aAptAtu[2] <> 'C', 'L' , 'F' ), 'O' ) ) )
             If !Empty( _aBrwRes[1][1] )
                For _nX := 1 To Len( _aBrwRes )
                    DbSelectArea("ZZG")
                    ZZG->( DbSetOrder( 7 ) )
                    If !( ZZG->( DbSeek( xFilial("ZZG") + _cGet1Ord + _aRotApt[ _aAptAtu[1] ][ 3 ] + _cTipUser + _aBrwRes[_nX][1] ) ) )
                       RecLock( "ZZG", .t. )
                          ZZG->ZZG_FILIAL := xFilial("ZZG")
                          ZZG->ZZG_ORDEM  := _cGet1Ord
                          ZZG->ZZG_LOTE   := _cGet2Lot
                          ZZG->ZZG_TPUSER := _cTipUser
                          ZZG->ZZG_FILMAT := _aBrwRes[_nX][1]
                          ZZG->ZZG_NOME   := _aBrwRes[_nX][2]
                          ZZG->ZZG_OPERAC := _aRotApt[ _aAptAtu[1] ][ 3 ]
                       ZZG->( MsUnLock() )
                    Endif
                Next
                For _nX := 1 To Len( _aUsrAut )
                    If _aUsrAut[ _nX ][13] == 'S'
                       RecLock( "ZZG", .t. )
                          ZZG->ZZG_FILIAL := _aUsrAut[_nX][2]
                          ZZG->ZZG_ORDEM  := _aUsrAut[_nX][3]
                          ZZG->ZZG_LOTE   := _aUsrAut[_nX][4]
                          ZZG->ZZG_TPUSER := _aUsrAut[_nX][5]
                          ZZG->ZZG_FILMAT := _aUsrAut[_nX][6]
                          ZZG->ZZG_NOME   := _aUsrAut[_nX][7]
                          ZZG->ZZG_OPERAC := _aRotApt[ _aAptAtu[1] ][ 3 ]
                          ZZG->ZZG_OBS    := _aUsrAut[_nX][8]
                       ZZG->( MsUnLock() )
                    Endif
                Next
             Endif
          else //Conferência
             //Por enquanto amarrei a fase de pesagem com o da balança/laboratório - deve ser estudado se houverem outras no futuro
             aAdd( _aFinal, { 'C', Iif( _aRotApt[ _aAptAtu[1] ][ 12 ] == 'XXB', 1, 2 ), ZZA->ZZA_PESAPB, ZZA->ZZA_PESAPU } )
             _lRet := fVerPEnv( Iif( _aRotApt[ _aAptAtu[1] ][ 12 ] == 'XXB', 1, 2) )
             _oDlgOpe:End()
          Endif
          //Se a operação atual for Inicio - atualizo a tela para apontamento do final
          If _lRet
             DbSelectArea("ZZA")
             ZZA->( DbSetOrder( 5 ) )
             ZZA->( DbSeek( xFilial("ZZA") + _cGet1Ord + _aRotApt[ _aAptAtu[1] ][ 3 ] + _aRotApt[ _aAptAtu[1] ][ 14 ] ))
             If _aAptAtu[2] == 'I'
                _oDlgOpe:End()
                fVerOrdPro()
             else
                //Verificação para baixa SH6/SD3
                If _aAptAtu[2] == 'F' .and. _aRotApt[ _aAptAtu[1]][7] <> 'S' //Apontamento Final sem pesagem de conferência
                   RptStatus( { || fBaixaRot( _cOpcApt, _aFinal ) }, "Baixa de Operação...", "Baixando operação " + _aRotApt[ _aAptAtu[1]][3] + ' / OP ' + _cGet1Ord )
                ElseIf _aAptAtu[2] $ 'F.C' .and. _aRotApt[ _aAptAtu[1]][7] == 'S' .and. _aRotApt[ _aAptAtu[1]][11] > 0 //Apontamento Final com pesagem de conferência
                       RptStatus( { || fBaixaRot( _cOpcApt, _aFinal ) }, "Baixa de Operação...", "Baixando operação " + _aRotApt[ _aAptAtu[1]][3] + ' / OP ' + _cGet1Ord )
                ElseIf _cOpcApt == 'P' //Operação Pausada
                       RptStatus( { || fBaixaRot( _cOpcApt, _aFinal ) }, "Baixa de Operação...", "Baixando operação " + _aRotApt[ _aAptAtu[1]][3] + ' / OP ' + _cGet1Ord )
                Endif
                _oDlgOpe:End()
             Endif
          Endif
          //Se for final da operação verificar se irá baixar.
       Endif
Return

/*/{Protheus.doc} fBaixaRot
Função que efetua a baixa dos itens em estoque e do apontamento de produção modelo 2
@type function
@version 2020.01
@author Luis Gustavo
@since 16/12/2020
@param _cOpcApt, Character, Variável que indica A=Apontamento ou P=Pausa da operação
/*/
Static Function fBaixaRot( _cOpcApt, _aFinal )
       Local _aOpeBai      := {}
       Local _aCabMov      := {}
       Local _aIteMov      := {}
       Local _aIteBai      := {}
       Local _nQtdMenor    := 0
       Local _nQtdMaior    := 0
       Local _lExcEmp      := .F.
       Local _lAltEmp      := .F.
       Local _nOpcAju      := 0
       Local _nX           := 0
       Local _aButtons     := {}
       Local _cGet1Rec     := space(10)
       Local _cGet2Rec     := space(40)
       Local _oFont1Rec    := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
       Local _aSegApt      := {}
	   Local _cFlagAn      := ''
       Private lMsErroAuto := .f.
       Private lMsHelpAuto := .T.
       Private l680        := .F.
       Private l681        := .F.
       Private lAtuEmpExe  := .F.
       Private lDelOpSc    := GetMV("MV_DELOPSC") == "S"
       Private lPerdInf    := SuperGetMV( "MV_PERDINF", .f., .f. )
       Private lProdAut    := GetMV( "MV_PRODAUT" )
       Private _lErro      := .F.
       Private _aErro      := {}
       Private _cErro      := "Entrar em contato com o PCP informando a mensagem abaixo: " + CHR(13) + CHR(10)
       Private _cLinTPO    := GetMV( "ZP_PAR0022" )

       SetRegua( 6 )

       If !( _cOpcApt $ 'P' )
          //Verifica se existem itens para efetuar baixa na operação
          DbSelectArea("ZZF")
          ZZF->( DbSetOrder( 5 ) )
          If ZZF->( DbSeek( xFilial("ZZF") + ZZA->ZZA_ORDEM + _aRotApt[ _aAptAtu[1]][03] + _aRotApt[ _aAptAtu[1]][14] ) )
             While !Eof() .and. ZZF->ZZF_ORDEM == ZZA->ZZA_ORDEM .and. ZZF->ZZF_OPERAC == _aRotApt[ _aAptAtu[1]][03]
			       If ZZF->ZZF_FLAG == '2'
                      DbSelectArea("SB1")
                      SB1->( DbSetOrder(1) )
                      SB1->( DbSeek( xFilial("SB1") + ZZF->ZZF_CODIGO ) )
                      _aIteMov := { { "D3_COD"  , ZZF->ZZF_CODIGO, NIL },;
                                    { "D3_QUANT", ZZF->ZZF_QTDUSA, NIL },;
                                    { "D3_UM"   , SB1->B1_UM     , NIL },;
                                    { "D3_LOCAL", ZZF->ZZF_LOCAL , NIL },;
                                    { "D3_TIPO" , SB1->B1_TIPO   , NIL },;
                                    { "D3_OP"   , ZZF->ZZF_ORDEM , NIL },;
                                    { "D3_TRT"  , ZZF->ZZF_TRT   , NIL },;
                                    { "D3_EMPOP", "S"            , NIL },; 
                                    { "D3_OBS"  , 'ZPCPA01'      , NIL } }
                      aAdd( _aIteBai, _aIteMov )
                      //Garante que existe o item no armazem na tabela SB2
                      DbSelectArea("SB2") 
                      SB2->( DbSetOrder( 1 ) )
                      If !SB2->( DbSeek( xFilial("SB2") + ZZF->ZZF_CODIGO + ZZF->ZZF_LOCAL ) )
                        CriaSB2( ZZF->ZZF_CODIGO, ZZF->ZZF_LOCAL )
                      Endif
                      //Pesquisa Item na SD4 para verificar se existe e necessita de alteração
                      _lExcEmp := .F.
                      _lAltEmp := .F.
                      DbSelectArea("SD4")
                      SD4->( DbSetOrder( 1 ) )
                      If SD4->( DbSeek( xFilial("SD4") + ZZF->ZZF_CODIGO + ( ZZF->ZZF_ORDEM + SPACE( ( LEN(SD4->D4_OP) - LEN(ZZF->ZZF_ORDEM) ) ) ) + ZZF->ZZF_TRT ) )
                         If SD4->D4_QTDEORI <> ZZF->ZZF_QTDUSA
                            If SD4->D4_QTDEORI < ZZF->ZZF_QTDUSA
                               _lExcEmp := .T.
                            Else
                               _lAltEmp := .T.
                            Endif
                            _aAltEmp := { { "D4_FILIAL" , xFilial("SD4") , Nil },;
                                          { "D4_COD"    , SD4->D4_COD    , Nil },;
                                          { "D4_LOCAL"  , ZZF->ZZF_LOCAL , Nil },;
                                          { "D4_OP"     , SD4->D4_OP     , Nil },;
                                          { "D4_TRT"    , SD4->D4_TRT    , Nil },;
                                          { "D4_QTSEGUM", 0              , Nil } }
                            lMsErroAuto := .f.
                            DbSelectArea("SD4")
                            If _lExcEmp
                               MSExecAuto( { |x, y| mata380( x, y ) }, _aAltEmp, 5 ) //Exclusão
                               IncRegua()
                               If lMsErroAuto
                                  Mostraerro()
                                  _lErro := .t.
                                  aAdd( _aErro, { "EXCSD4ERR - " + SD4->D4_COD + SD4->D4_TRT } )
                                  //**Verificar possibilidade de criar fila de não processado
                               Else
                                  lMsErroAuto := .f.
                                  DbSelectArea("SD4")
                                  aAdd( _aAltEmp, { "D4_QTDEORI", ZZF->ZZF_QTDUSA, Nil } )
                                  aAdd( _aAltEmp, { "D4_QUANT"  , ZZF->ZZF_QTDUSA, Nil } )
                                  MSExecAuto( { |x, y| mata380( x, y ) }, _aAltEmp, 3 ) //Inclusão
                                  IncRegua()
                                  If lMsErroAuto
                                     Mostraerro()
                                     _lErro := .t.
                                     aAdd( _aErro, { "INCSD4ERR - " + SD4->D4_COD + SD4->D4_TRT } )
                                     //**Verificar possibilidade de criar fila de não processado
                                  Endif
                               Endif
                            Endif
                            If _lAltEmp
                               aAdd( _aAltEmp, { "D4_QUANT"  , ZZF->ZZF_QTDUSA, Nil } )
                               aAdd( _aAltEmp, { "D4_QTDEORI", ZZF->ZZF_QTDUSA, Nil } )
                               MSExecAuto( { |x, y| mata380( x, y ) }, _aAltEmp, 4 ) //Alteração
                               IncRegua()
                               If lMsErroAuto
                                  Mostraerro()
                                  _lErro := .t.
                                  aAdd( _aErro, { "ALTSD4ERR - " + SD4->D4_COD + SD4->D4_TRT } )
                                  //**Verificar possibilidade de criar fila de não processado
                               Endif
                            Endif
                         Endif
                      Endif
                   Endif
				   DbSelectArea("ZZF")
                   ZZF->( DbSkip() )
             EndDo
             If Len( _aIteBai ) > 0
                //Baixa da Operação
                _aCabMov := { { "D3_TM"     , '997'    , NIL },;
                              { "D3_EMISSAO", dDatabase, NIL },;
                              { "D3_DOC"  , SubStr( ZZA->ZZA_ORDEM , 1, 6 ) + '-' + _aRotApt[ _aAptAtu[1]][03] , NIL } }

                MSExecAuto( { |x, y, z| MATA241( x, y, z ) }, _aCabMov, _aIteBai, 3 )
                IncRegua()
                If lMsErroAuto
                   MostraErro()
                   _lErro := .t.
                   aAdd( _aErro, { "REQSD3ERR - "  } )
                   //**Verificar possibilidade de criar fila de não processado
                else
                   DbSelectArea("ZZF")
                   ZZF->( DbSetOrder( 5 ) )
                   If ZZF->( DbSeek( xFilial("ZZF") + ZZA->ZZA_ORDEM + _aRotApt[ _aAptAtu[1]][03] + _aRotApt[ _aAptAtu[1]][14] ) )
                      While !Eof() .and. ZZF->ZZF_ORDEM == ZZA->ZZA_ORDEM .and. ZZF->ZZF_OPERAC == _aRotApt[ _aAptAtu[1]][03]
                            RecLock( "ZZF", .f. )
                               ZZF->ZZF_FLAG := '1'
                               ZZF->ZZF_OBS  := SubStr( ZZF->ZZF_OBS, 1, 5 ) + 'Baixado'
                            ZZF->( MsUnLock() )
                            DbSelectArea("ZZF")
                            ZZF->( DbSkip() )
                      EndDo
                   Endif
                Endif
             Endif
          Endif
       Endif

       //Tratamento do erro de baixa, retornando status.
       If _lErro
          For _nX := 1 To Len( _aErro )
              _cErro += _aErro[_nX][1] + CHR(13) + CHR(10)
          Next
          _cErro += "O apontamento não foi efetuado. Verifique."
          RecLock( "ZZA", .f. )
             If _aFinal[1][1] == 'C'
                If _aFinal[1][2] == 1
                   ZZA->ZZA_PESAPB := 0
                Else
                   ZZA->ZZA_PESAPU := 0
                Endif
             Else
                ZZA->ZZA_HELP   := _aFinal[1][ 2]
                ZZA->ZZA_FLAG   := _aFinal[1][ 3]
                ZZA->ZZA_DTFIM  := _aFinal[1][ 4]
                ZZA->ZZA_HFIM   := _aFinal[1][ 5]
                ZZA->ZZA_PESFIN := _aFinal[1][ 6]
                ZZA->ZZA_PESPES := _aFinal[1][ 7]
                ZZA->ZZA_DTPES  := _aFinal[1][ 8]
                ZZA->ZZA_HPES   := _aFinal[1][ 9]
                ZZA->ZZA_PESCOL := _aFinal[1][10]
                ZZA->ZZA_DTCOL  := _aFinal[1][11]
                ZZA->ZZA_HCOL   := _aFinal[1][12]
                ZZA->ZZA_PESLAB := _aFinal[1][13]
                ZZA->ZZA_PERDA  := _aFinal[1][14]
                ZZA->ZZA_LIBLAB := _aFinal[1][15]
                ZZA->ZZA_QUANT  := _aFinal[1][16]
                ZZA->ZZA_MOTIVO := _aFinal[1][17]
             Endif
          ZZA->( MsUnLock() )
          MessageBox( _cErro, "", 16 )
       Else
          //Busca Informações 
          _lRetMot := .t.
          oModal := FWDialogModal():New()
          oModal:SetEscClose( .F. )
          oModal:setTitle( "Recurso da Operação" )
          oModal:setSize( 100, 155 )
          oModal:createDialog()
          aAdd( _aButtons, { "", 'Confirma', {|| _lRetMot := fVldRec( _cGet1Rec, @_oGet2DRec, @_cGet2Rec ), Iif( _lRetMot, _nOpcAju := 1, _nOpcAju := 0 ), Iif( _lRetMot, oModal:DeActivate(), ) }, , , .T., .F. } )
          aAdd( _aButtons, { "", 'Cancela' , {|| _nOpcAju := 0, oModal:DeActivate() }, , , .T., .F. } )
          oModal:addButtons( _aButtons )

          oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
          oContainer:Align := CONTROL_ALIGN_ALLCLIENT

          _oGet1Rec     := TGet():New( 004, 004, {|u| If (PCount() > 0, _cGet1Rec := u, _cGet1Rec ) }, oContainer, 070 , 012, '@!', { || fVldRec( _cGet1Rec, @_oGet2DRec, @_cGet2Rec ) }, CLR_BLACK, CLR_WHITE, _oFont1Rec,    , , .T., "", , , .F., .F., , .F., .F., "", "_cGet1Rec", , , , , , , 'Recurso da Operação', 1,          , CLR_BLUE, '<Recurso>'    , .T. )
          _oGet2DRec    := TGet():New( 028, 004, {|u| If (PCount() > 0, _cGet2Rec := u, _cGet2Rec ) }, oContainer, 150 , 012, '@!',                                                     , CLR_BLACK, CLR_WHITE, _oFont1Rec,    , , .T., "", , , .F., .F., , .T., .F., "", "_cGet2Rec", , , , , , , 'Descrição'          , 1,          , CLR_BLUE, ' '            , .T. )
          _oGet1Rec:cF3 := 'SH1'
          oModal:Activate()
          If !_nOpcAju == 1
             _cGet1Rec := ZZA->ZZA_ID
          else
             RecLock( "ZZA", .f. )
                ZZA->ZZA_ID := _cGet1Rec
             ZZA->( MsUnLock() )
          Endif

          //Baixa da Ordem
          lMsErroAuto := .f.
          DbSelectArea("SF5")
          MSFILTER('')
          DbSelectArea("SF5")
          DbSetOrder(1)
          DbSelectArea("SC2")
          SC2->( DbSetOrder(1) )
          SC2->( DbSeek( xFilial("SC2") + ZZA->ZZA_ORDEM ) )
          DbSelectArea("SH6")
          SH6->( DbSetOrder(1) )
          SH6->( DbSeek( xFilial("SH6") + ZZA->ZZA_ORDEM ) )
          //Apontamento da Operação - referente as horas da operação
          _aOpeBai := {}
          aAdd( _aOpeBai, { "H6_OP"     , ZZA->ZZA_ORDEM                        , Nil } )
          aAdd( _aOpeBai, { "H6_PRODUTO", ZZA->ZZA_PRODUT                       , Nil } )
          aAdd( _aOpeBai, { "H6_QTDPROD", 0                                     , Nil } )
          aAdd( _aOpeBai, { "H6_OPERAC" , ZZA->ZZA_OPERAC                       , Nil } )
          aAdd( _aOpeBai, { "H6_RECURSO", _cGet1Rec                             , Nil } )
          aAdd( _aOpeBai, { "H6_PT"     , 'P'                                   , Nil } )
          aAdd( _aOpeBai, { "H6_OBSERVA", 'ZPCPA01-OP'                          , Nil } )
          aAdd( _aOpeBai, { "H6_DATAINI", ZZA->ZZA_DTINI                        , Nil } )
          aAdd( _aOpeBai, { "H6_HORAINI", TransForm( ZZA->ZZA_HINI, '@R 99:99' ), Nil } )
          aAdd( _aOpeBai, { "H6_DATAFIN", ZZA->ZZA_DTFIM                        , Nil } )
          aAdd( _aOpeBai, { "H6_HORAFIN", TransForm( ZZA->ZZA_HFIM, '@R 99:99' ), Nil } )
          aAdd( _aOpeBai, { "H6_DTAPONT", dDataBase                             , Nil } )
          aAdd( _aOpeBai, { "H6_LOCAL"  , _cGetALoc                             , Nil } )
          aAdd( _aOpeBai, { "H6_SEQ"    , ZZA->ZZA_SEQENV                       , Nil } )
          aAdd( _aOpeBai, { "H6_TIPO"   , Iif( _cOpcApt == 'P', 'I', 'P' )      , Nil } ) //Tipo de apontamento P=Produção / I=Parada
          If _cOpcApt == 'P'
             aAdd( _aOpeBai, { "H6_MOTIVO", ZZA->ZZA_MOTIVO                     , Nil } )
          Endif
          /******************************************************************************/
          /*** RESGUARDO A BAIXA DE PRODUÇÃO DEVIDO A ALGUNS TRAVAMENTOS QUE OCORRIAM ***/
          If ZZA->ZZA_FLAG == '2'
             _aSegApt := {}
             _cFlagAn := '2'
             aAdd( _aSegApt, ZZA->ZZA_FLAG  )
             aAdd( _aSegApt, ZZA->ZZA_DTFIM )
             aAdd( _aSegApt, ZZA->ZZA_HFIM  )
             RecLock( 'ZZA', .f. )
                ZZA->ZZA_FLAG  := '1'
                ZZA->ZZA_DTFIM := CTOD( '  /  /    ' )
                ZZA->ZZA_HFIM  := ''
             ZZA->( MsUnLock() )
          Endif
          /******************************************************************************/
          lMSErroAuto := .f.
          DbSelectArea("SF5")
          MSFILTER('')
          DbSelectArea("SF5")
          DbSetOrder(1)
          DbSelectArea("SC2")
          SC2->( DbSetOrder(1) )
          SC2->( DbSeek( xFilial("SC2") + ZZA->ZZA_ORDEM ) )
          DbSelectArea("SH6")
          SH6->( DbSetOrder(1) )
          SH6->( DbSeek( xFilial("SH6") + ZZA->ZZA_ORDEM ) )
          MsExecAuto( { |x, y| Mata681( x, y ) }, _aOpeBai, 3 )
          IncRegua()
          If lMSErroAuto
             Mostraerro()
          Else
             /******************************************************************************/
             /*** RETORNO OS VALORES DO APONTAMENTO                                      ***/
             If _cFlagAn == '2'
                RecLock( 'ZZA', .f. )
                   ZZA->ZZA_FLAG  := _aSegApt[1]
                   ZZA->ZZA_DTFIM := _aSegApt[2]
                   ZZA->ZZA_HFIM  := _aSegApt[3]
                ZZA->( MsUnLock() )
             Endif
             /******************************************************************************/
          Endif
          //Verifica se é ou não a ultima operação
          If Len( _aRotApt ) == _aAptAtu[1] .and. _cOpcApt == 'A'
             //Apontamento da Quantidade da Operação
             //If !SubStr( ZZA->ZZA_PRODUT, 4, 2 ) $ _cLinTPO //Para produtos que não são das linhas de Pó.
                _aOpeBai := {}
                aAdd( _aOpeBai, { "H6_OP"     , ZZA->ZZA_ORDEM                           , Nil } )
                aAdd( _aOpeBai, { "H6_PRODUTO", ZZA->ZZA_PRODUT                          , Nil } )
                aAdd( _aOpeBai, { "H6_QTDPROD", ZZA->ZZA_QUANT                           , Nil } )
                aAdd( _aOpeBai, { "H6_OPERAC" , ZZA->ZZA_OPERAC                          , Nil } )
                aAdd( _aOpeBai, { "H6_RECURSO", _cGet1Rec                                , Nil } )
                aAdd( _aOpeBai, { "H6_PT"     , 'P'                                      , Nil } )
                aAdd( _aOpeBai, { "H6_OBSERVA", 'ZPCPA01-QT'                             , Nil } )
                aAdd( _aOpeBai, { "H6_DATAINI", ZZA->ZZA_DTINI                           , Nil } )
                aAdd( _aOpeBai, { "H6_DATAFIN", ZZA->ZZA_DTFIM                           , Nil } )
                aAdd( _aOpeBai, { "H6_DTAPONT", dDataBase                                , Nil } )
                aAdd( _aOpeBai, { "H6_LOCAL"  , _cGetALoc                                , Nil } )
                aAdd( _aOpeBai, { "H6_SEQ"    , StrZero( Val( ZZA->ZZA_SEQENV ) + 1, 2 ) , Nil } )
                aAdd( _aOpeBai, { "H6_TIPO"   , 'P'                                      , Nil } ) //Tipo de apontamento P=Produção / I=Parada
                //Analisar ganho de produção
                _nQtdMaior := Iif( ZZA->ZZA_QUANT > _nGet3Qtd, ZZA->ZZA_QUANT - _nGet3Qtd, 0 )
                If _nQtdMaior > 0
                   aAdd( _aOpeBai, { "H6_QTGANHO", _nQtdMaior                            , Nil } )
                Endif
                //Analisar produção a menor
                _nQtdMenor := Iif( ZZA->ZZA_QUANT < _nGet3Qtd, _nGet3Qtd - ZZA->ZZA_QUANT, 0 )
                If _nQtdMenor > 0
                   aAdd( _aOpeBai, { "H6_QTDPERD", _nQtdMenor                            , Nil } )
                Endif
                aAdd( _aOpeBai, { "AUTCONSUMO"    , Nil , Nil } ) //Para consumo do GGF
                lMSErroAuto := .f.
                DbSelectArea("SF5")
                MSFILTER('')
                DbSelectArea("SF5")
                DbSetOrder(1)
                DbSelectArea("SC2")
                SC2->( DbSetOrder(1) )
                SC2->( DbSeek( xFilial("SC2") + ZZA->ZZA_ORDEM ) )
                DbSelectArea("SH6")
                SH6->( DbSetOrder(1) )
                SH6->( DbSeek( xFilial("SH6") + ZZA->ZZA_ORDEM ) )
                MsExecAuto( {|x, y| Mata681(x, y)}, _aOpeBai, 3 )
                IncRegua()
                If lMSErroAuto
                   Mostraerro()
                   //**Verificar possibilidade de criar fila de não processado
                Else
                   //Após baixar a quantidade final da Ordem de Produção fazer a requisição do GGF empenhado.
                   lMsErroAuto := .f.
                   _nQtdNew := 0
                   _aAux241 := {}
                   _aMat241 := {}
                   _aCab241 := {}
                   DbSelectArea("SD4")
                   SD4->( DbSetOrder(2) )
                   If SD4->( DbSeek( xFilial( "SD4" ) + ZZA->ZZA_ORDEM ) )
                      While !Eof() .and. Alltrim( SD4->D4_OP ) == Alltrim( ZZA->ZZA_ORDEM )
                            If SUBSTR( SD4->D4_COD, 1, 3 ) == 'GGF'
                               _nQtdNew := 0
                               _nQtdNew := ( SD4->D4_QTDEORI / SC2->C2_QUANT ) * ZZA->ZZA_QUANT
                               DbSelectArea("SB1")
                               SB1->( DbSetOrder( 1 ) )
                               SB1->( DbSeek( xFilial( "SB1" ) + SD4->D4_COD ) )
                               _aAux241 := { { "D3_COD"    , SD4->D4_COD         , NIL },;
                                             { "D3_QUANT"  , Round( _nQtdNew, 3 ), NIL },;
                                             { "D3_UM"     , SB1->B1_UM          , NIL },;
                                             { "D3_LOCAL"  , SD4->D4_LOCAL       , NIL },;
                                             { "D3_TIPO"   , SB1->B1_TIPO        , NIL },;
                                             { "D3_OP"     , SD4->D4_OP          , NIL },;
                                             { "D3_TRT"    , SD4->D4_TRT         , NIL },;
                                             { "D3_LOTECTL", ''                  , NIL },;
                                             { "D3_NUMLOTE", ''                  , NIL },;
                                             { "D3_DTVALID", CTOD('  /  /  ')    , NIL },;
                                             { "D3_EMPOP"  , 'S'                 , NIL },;
                                             { "D3_OBS"    , 'ZPCPA01'           , NIL } }
                               aAdd( _aMat241, _aAux241 )
                            Endif
                            DbSelectArea("SD4")
                            SD4->( DbSkip( ) )
                      EndDo
                      If Len( _aMat241 ) > 0
                         _aCab241 := { { "D3_TM"     , "997"                                     , NIL },;
                                       { "D3_EMISSAO", dDatabase                                 , NIL },;
                                       { "D3_DOC"    ,  SubStr( ZZA->ZZA_ORDEM , 1, 6 ) + '- GGF', NIL } }
                         MSExecAuto( { | x, y, z | MATA241( x, y, z ) }, _aCab241, _aMat241, 3 )
                         If lMsErroAuto
                            MostraErro()
                         Endif
                      Endif
                   Endif
                   FINTEGPCF()
                Endif
             //Endif
             //Encerrar ordem de produção.
             If ( !( SubStr( ZZA->ZZA_PRODUT, 4, 2 ) $ _cLinTPO ) .and. Len( Alltrim( ZZA->ZZA_PRODUT ) ) == 12 ) .or. Len( Alltrim( ZZA->ZZA_PRODUT ) ) < 12
                DbSelectArea("SC2")
                SC2->( DbSetOrder(1) )
                SC2->( DbSeek( xFilial("SC2") + ZZA->ZZA_ORDEM ) )
                IncRegua()
                DbSelectArea("SD3")
                SD3->( DbSetOrder(1) )
                If SD3->( DbSeek( xFilial("SD3") + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD + SC2->C2_PRODUTO ) )
                   a250End( .T., .T. )
                Else
                   MessageBox( 'Ordem de produção ' + ZZA->ZZA_ORDEM + ' não encerrada. Informar esse numero de ordem ao PCP.', 'Encerramento', 48 )
                Endif
             Endif
             IncRegua()
          Endif
       Endif
Return

Static Function fVldRec( _cGet1Rec, _oGet2DRec, _cGet2Rec )
       Local _lRet := .t.

       If !Empty( _cGet1Rec )
          DbSelectArea("SH1")
          SH1->( DbSetOrder( 1 ) )
          If SH1->( DbSeek( xFilial('SH1') + _cGet1Rec ) )
             _cGet2Rec := SH1->H1_DESCRI
          else
             MessageBox( 'Recurso inválido', 'Recurso da Operação', 16 )
             _cGet1Rec := Space(10)
             _cGet2Rec := Space(40)
             _lRet := .f.
          Endif
       Else
          MessageBox( 'Recurso não pode ser em branco.', 'Recurso da Operação', 16 )
          _lRet := .f.
       Endif
       _oGet2DRec:Refresh()
Return _lRet

Static Function fVldPar( _cGet1Mot, _oGet2DMot, _cGet2Mot )
       Local _lRet := .t.

       If !Empty( _cGet1Mot )
          DbSelectArea("CYN")
          CYN->( DbSetOrder( 1 ) )
          If CYN->( DbSeek( xFilial('CYN') + _cGet1Mot ) )
             _cGet2Mot := CYN->CYN_DSSP
          else
             MessageBox( 'Motivo inválido', 'Motivo de Parada', 16 )
             _cGet1Mot := Space(10)
             _cGet2Mot := Space(40)
             _lRet := .f.
          Endif
       Else
          MessageBox( 'Motivo não pode ser em branco', 'Motivo de Parada', 16 )
          _lRet := .f.
       Endif
       _oGet2DMot:Refresh()
Return _lRet

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fVerPEnv() Verifica se o Peso da Balança esta dentro do limite 
                     Fase 1 - Após Pesagem Balanceiro
                     Fase 2 - Após Laboratório, antes do Envase
LIMITE PERMITIDO PARA DIFERENÇA DE PESO ENTRE O TOTAL APONTADO E O TOTAL PESADO NA BALANÇA
		DE    0 A 150 KG/LITRO -> 600 GRAMAS/MLS
	    ACIMA DE 150  KG/LITRO -> 0,4 %
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÁÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fVerPEnv( _nFase )
       Local _nVolTotal := 0  
       Local _nPesTotal := 0
	    Local _nLimite   := 0 
       Local _nDif      := 0
       Local _nPesApto  := 0
       Local _lRet      := .t.
       Local _cAuxMens  := ""
       Local _nPorcent  := 0
       Local _lJaGravou := .T.
       Local _nX
	
       If _nFase ==1
          _nVolTotal := SC2->C2_QUANT
          _nPesTotal := ZZA->ZZA_PESPES // peso após final pesagem       
          _nPesApto  := Iif( ZZA->ZZA_PESAPB <= 0, _nGet3Ite, ZZA->ZZA_PESAPB )
          _lJaGravou := Iif( ZZA->ZZA_PESAPB <= 0, .F., .T. )
       Elseif _nFase == 2
              _nVolTotal := ZZA->ZZA_QUANT
              _nPesTotal := ZZA->ZZA_PESFIN // peso final, após laboratório
              _nPesApto  := Iif( ZZA->ZZA_PESAPU <= 0, _nGet3Ite, ZZA->ZZA_PESAPB )
              _lJaGravou := Iif( ZZA->ZZA_PESAPU <= 0, .F., .T. )
       Endif
       If _nVolTotal <= 150
          _nLimite   := 0.6
          _nPesTotal += _nGet7Tar
          _nDif      := Iif( _nPesApto > _nPesTotal, ( _nPesApto - _nPesTotal ), ( _nPesTotal - _nPesApto ) ) //Trata valor negativo
          If _nDif > _nLimite
             Messagebox( "Diferença entre peso apontado e peso apurado na balança é maior do que o limite estabelecido para este volume. Entre em contato com o PCP - O.P Bloqueada !!", "O.P BLOQUEADA", 48 )
             If _nPesApto == 0
                _cAuxMens := "Diferença entre peso apontado e peso apurado ! "+Iif( _nFase == 1," - Após Pesagem"," - Após Laboratório")+;
                             chr(13)+chr(10) + "Lote.........: " + ( _cGet2Lot )+"   O.P : " + ( _cGet1Ord ) +;
                             chr(13)+chr(10) + "Produto......: " + ( _cGet5Cod )+" - " + Alltrim( _cGet6Des )+;
                             chr(13)+chr(10) + "Peso Apontado: " + TRANSFORM( _nPesTotal, '@E 999,999.999' ) +;
                             chr(13)+chr(10) + "Peso Apurado.: " + TRANSFORM( _nGet3Ite , '@E 999,999.999' ) +;
                             chr(13)+chr(10) + "Diferença....: " + TRANSFORM( _nDif     , '@E 999,999.999' ) +;
                             chr(13)+chr(10) + "Limite Dif...: " + TRANSFORM( _nLimite  , '@E 999,999.999' ) +;
                             chr(13)+chr(10) + "Prog. Origem : ZPCPA01"
                If Alltrim( SM0->M0_CODFIL ) == '010101'
                   If Alltrim( Upper( GetEnvServer() ) )  == 'PRODUCAO' //Envio de e-mail somente para ambiente oficial
                      U_EnvMail( "BRASILUX - O.P " +_cGet1Ord + " com diferença entre peso apontado e peso apurado !" + Iif( _nFase == 1, " - Após Pesagem"," - Após Laboratório"), _cAuxMens, "pcp@brasilux.com.br, paulo@brasilux.com.br", "" )
                   else
                      MessageBox( _cAuxMens, "Atenção", 48 )
                   Endif
                Endif
             Endif
             _lRet := .f.
          Endif
       ElseIf _nVolTotal > 150
              _nLimite  := 0.4
              _nPesTotal:= ( _nPesTotal + _nGet7Tar )
              _nDif     := Iif( _nPesApto > _nPesTotal, ( _nPesApto - _nPesTotal ), ( _nPesTotal - _nPesApto ) ) //Trata valor negativo
              _nPorcent := Round( ( ( _nDif ) * ( 100 / _nPesApto ) ), 2 )
              If _nPorcent > _nLimite
                 Messagebox( "Diferença entre peso apontado e peso apurado na balança é maior do que o limite estabelecido para este volume. Entre em contato com o PCP - O.P Bloqueada !!", "O.P BLOQUEADA", 48 ) 
                 If _nPesApto == 0
                    _cAuxMens := "Diferença entre peso apontado e peso apurado ! "+Iif(Fase==1," - Após Pesagem"," - Após Laboratório")+;
                                 chr(13) + chr(10) + "Lote.........: " + ( _cGet2Lot ) + "   O.P : " + ( _cGet1Ord ) +;
                                 chr(13) + chr(10) + "Produto......: " + ( _cGet5Cod ) + " - " + Alltrim( _cGet6Des )+;
                                 chr(13) + chr(10) + "Peso Apontado: " + TRANSFORM( _nPesTotal, '@E 999,999.999' )   +;
                                 chr(13) + chr(10) + "Peso Apurado.: " + TRANSFORM( _nGet3Ite , '@E 999,999.999' )   +;
                                 chr(13) + chr(10) + "Diferença....% " + TRANSFORM( _nPorcent , '@E 999,999.999' )   +;
                                 chr(13) + chr(10) + "Limite Dif...% " + TRANSFORM( _nLimite  , '@E 999,999.999' )   +;
                                 chr(13) + chr(10) + "Prog. Origem : ZPCPA01"
                    If Alltrim( SM0->M0_CODFIL ) == '010101'
                       If Alltrim( Upper( GetEnvServer() ) )  == 'PRODUCAO' //Envio de e-mail somente para ambiente oficial
                          U_EnvMail("BRASILUX - O.P " + _cGet1Ord + " com diferença entre peso apontado e peso apurado !" + Iif( _nFase == 1, " - Após Pesagem", " - Após Laboratório"), _cAuxMens, "pcp@brasilux.com.br,paulo@brasilux.com.br", "" )
                       else
                          MessageBox( _cAuxMens, "Atenção", 48 )
                       Endif
                    Endif
                 Endif
                 _lRet :=.f.
              Endif
       Endif
       If !_lJaGravou
          //Gravação do peso na conferência
          RecLock( "ZZA", .f. )
             If _nFase == 1
                ZZA->ZZA_PESAPB := _nGet3Ite		// PESO APURADO APÓS BALANCEIRO
                _aRotApt[ _aAptAtu[1] ][11] := _nGet3Ite
             Else
                ZZA->ZZA_PESAPU := _nGet3Ite		// PESO APURADO APÓS LABORATÓRIO			
                _aRotApt[ _aAptAtu[1] ][11] := _nGet3Ite
             Endif
          ZZA->( MsUnLock() )
          //Gravação do Responsável pela pesagem
          _cTipUser := Iif( _aRotApt[_aAptAtu[1]][12] == 'XXB', IIF( _aAptAtu[2] <> 'C', 'B' , 'P' ), Iif( _aRotApt[_aAptAtu[1]][12] == 'XXC', 'C', Iif( _aRotApt[_aAptAtu[1]][12] == 'XXL', IIF( _aAptAtu[2] <> 'C', 'L' , 'F' ), 'O' ) ) )
          For _nX := 1 To Len( _aBrwRes )
              DbSelectArea("ZZG")
              ZZG->( DbSetOrder( 7 ) )
              If !( ZZG->( DbSeek( xFilial("ZZG") + _cGet1Ord + _aRotApt[ _aAptAtu[1] ][ 3 ] + _cTipUser + _aBrwRes[_nX][1] ) ) )
                 RecLock( "ZZG", .t. )
                    ZZG->ZZG_FILIAL := xFilial("ZZG")
                    ZZG->ZZG_ORDEM  := _cGet1Ord
                    ZZG->ZZG_LOTE   := _cGet2Lot
                    ZZG->ZZG_TPUSER := _cTipUser
                    ZZG->ZZG_FILMAT := _aBrwRes[_nX][1]
                    ZZG->ZZG_NOME   := _aBrwRes[_nX][2]
                    ZZG->ZZG_OPERAC := _aRotApt[ _aAptAtu[1] ][ 3 ]
                 ZZG->( MsUnLock() )
              Endif
          Next
       Endif
Return _lRet

/*/{Protheus.doc} fValidaPE
Validação do Peso Específico do Laboratório
@type function
@version 2020.01
@author Luís Gustavo
@since 17/06/2020
/*/
Static Function fValidaPE( )
       Local _nTolera    := 0
       Local _lTolera
       Local _cTxtMsg    := ""
       Local _cMVSUPLABO := Alltrim( GetMv( "MV_SUPLABO" ) ) //Usuários para validação/autorização
       Private _cJustifi   := space(40)

       _cRetSup := space(25) //Retorno do Superior que libera o processo
       If _nGet4Ite > 0
          If _cGet9UnM $ 'K .KG'
             _nTolera := 0.050 
          Else
             _nTolera := 0.020
          Endif
          _lTolera := Iif( Round( _nGet4Ite, 3 ) > Round( _nGet4Pes + _nTolera, 3 ), .t., Iif( Round( _nGet4Ite, 3 ) < Round( _nGet4Pes - _nTolera, 3 ), .f., Nil ) )
          If _lTolera <> Nil
             _cTxtMsg := "Peso Específico na O.P " + _cGet1Ord + " informado é " + Iif( _lTolera, 'MAIOR', 'MENOR' ) + " que o tolerável." + CHR(13) + CHR(10)
             _cTxtMsg += "Peso Esp. Informado: " + Alltrim( TransForm( _nGet4Ite, "@E 9.999" ) ) + "   -   Peso Esp. Teórico: " + Alltrim( TransForm( _nGet4Pes, "@E 9.999" ) ) + CHR(13) + CHR(10)
             _cTxtMsg += " " + CHR(13) + CHR(10)
             _cTxtMsg += "Tolerância Máxima - ± " + Alltrim( TransForm( _nTolera, "@E 9.999" ) ) + "."
             If GetMv("MV_OMITMSG") $ 'N'
                Messagebox( _cTxtMsg, "Atenção...", 48 )
             Endif
             If Alltrim( Upper( GetEnvServer() ) )  == 'PRODUCAO' //Enviar e-mail somente para o ambiente oficial
                If Alltrim( SM0->M0_CODFIL ) == '060101'
                   U_EnvMail( "DISSOLTEX - O.P " + _cGet1Ord + " Peso Específico na O.P informado é " + Iif( _lTolera, 'MAIOR', 'MENOR' ) + " que o tolerável. !" , _cTxtMsg, "silene@dissoltex.com.br, ricardo@dissoltex.com.br", "" )
                Else
                   U_EnvMail( "BRASILUX - O.P " + _cGet1Ord + " Peso Específico na O.P informado é " + Iif( _lTolera, 'MAIOR', 'MENOR' ) + " que o tolerável. !" , _cTxtMsg, "marciononis@brasilux.com.br, pcp@brasilux.com.br ", "" )
                Endif
             Endif
             If GetMv("MV_PASLABO") $ 'S'
                If _lTolera //Maior
                   _cRetSup := space(25)
                   If !fTelaSenha( _cMVSUPLABO )
                      _nGet4Ite := 0
                      _oGetIte04:SetFocus()
                   Endif
                Else //Menor
                   _cRetSup := space(25)
                   If !fTelaSenha( _cMVSUPLABO )
                      _nGet4Ite := 0
                      _oGetIte04:SetFocus()
                   Endif
                Endif
             Else
                _oGetIte04:SetFocus()
             Endif
          Endif
          _oGetIte04:Refresh()
       Endif
Return

/*/{Protheus.doc} fTelaSenha
Tela para validação/autorização por senha
@type function
@version 2020.01
@author Luís Gustavo
@since 17/06/2020
@param _cParamU, character, Variável que contém usuários que podem validar/autorizar rotina.
@return Logical, Retorna verdadeiro ou falso na validação da senha.
/*/
Static Function fTelaSenha( _cParamU )
       Local   _lRet       := .F.
       Local _cBitmap      := 'LOGIN'
       Local _cSenha       := space(25)
       Private _oDlgSenha
       Private _lQuit      := "N"
       Private _cUsuario   := space(20)
       Private _oGetSup
       Private _cIDUsuario := ""

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
       ±± Definicao do Dialog e todos os seus componentes.                        ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
       While _lQuit == "N"
             DEFINE DIALOG _oDlgSenha TITLE 'Validação por senha' FROM 0,0 TO 200,290 PIXEL
                    @ 0,0 BITMAP _oBMP01 RESNAME _cBitmap OF _oDlgSenha SIZE 50,140 NOBORDER WHEN .F. PIXEL

                    @ 05, 55 SAY 'Usuario' PIXEL
                    @ 15, 55 MSGET _oGetSup VAR _cUsuario WHEN .T. PIXEL SIZE 80,08 VALID fValidaUsu( _cParamU )
                    @ 30, 55 SAY 'Senha' PIXEL
                    @ 40, 55 MSGET _oGetSenha VAR _cSenha PASSWORD PIXEL SIZE 40,08 VALID fValidaPSW( _cSenha )
                    @ 55, 55 SAY 'Justificativa' PIXEL
                    @ 65, 55 MSGET _oGetJus VAR _cJustifi WHEN .T. PIXEL SIZE 80,08 VALID !Empty(_cJustifi)

                    DEFINE SBUTTON FROM 85,075 TYPE 1 ACTION ( Iif( !_lRet .or. Empty( _cSenha ) .or. Empty( _cJustifi ), _lRet := fAutoriza( _cParamU ), .T. ), _oDlgSenha:End() ) ENABLE OF _oDlgSenha
                    DEFINE SBUTTON FROM 85,105 TYPE 2 ACTION ( _lRet := .F., _lQuit := "S", _oDlgSenha:End() )                                              ENABLE OF _oDlgSenha
             ACTIVATE MSDIALOG _oDlgSenha CENTERED
       EndDo
       If _lRet
          _cRetSup := _cIDUsuario
       Endif
Return( _lRet )

/*/{Protheus.doc} fValidaUsu
Função para validar usuário digitado
@type function
@version 2020.01
@author Luís Gustavo
@since 17/06/2020
@param _cParamU, character, Variável com usuários a serem validados
@return Logical, Retorna verdadeiro ou falso para usuário digitado
/*/
Static Function fValidaUsu( _cParamU )
       Local _lRet := .F.

       If ( Alltrim( _cUsuario ) ) $ Alltrim( _cParamU )
          PswOrder(2)
          If PswSeek( _cUsuario )
             _lRet := .T.
          else
             MessageBox( 'Usuário não encontrado.', 'Atenção', 16 )
          Endif
       else
          MessageBox( 'Usuário não autorizado.', 'Atenção', 16 )
       Endif
       If !_lRet
          _cUsuario  := space(20)
          _oGetSup:Refresh()
          _oGetSup:SetFocus()
       Endif
Return _lRet

/*/{Protheus.doc} fValidaPSW
Valida senha digitada
@type function
@version 2020.01
@author Luís Gustavo
@since 17/06/2020
@param _cSenha, character, Senha a ser validada
@return Logical, Retorno de verdadeiro ou falso na validação da senha
/*/
Static Function fValidaPSW( _cSenha )
       Local _lRet       := .f.

       PSWOrder( 2 )
       PSWSeek( Alltrim( _cUsuario ) )
       If PSWName( _cSenha )
          _cIDUsuario := PSWRet()[1][2]
          _lRet := .T.
       else
          MessageBox( 'Senha inválida.', 'Atenção', 64 )
       Endif
Return _lRet

/*/{Protheus.doc} fAutoriza
Retorna autorização da rotina
@type function
@version 2020.01
@author Luís Gustavo
@since 17/06/2020
@param _cParamU, character, Variável com usuários a serem validados
@return Logical, Retorno de verdadeiro ou falso na validação da senha
/*/
Static Function fAutoriza( _cParamU )
       Local _lRet := .F.

       If ( Alltrim( _cUsuario ) ) $ Alltrim( _cParamU )
          PswOrder(2)
          If PswSeek( _cUsuario )
             _lRet := .T.
          else
             MessageBox( 'Usuário sem permissão', 'Atenção', 16 )
          Endif
       Else
          MessageBox( 'Usuário sem permissão', 'Atenção', 16 )
       Endif
       If _lRet
          _lQuit := 'S'
          _oDlgSenha:End()
       Endif
Return _lRet

//TOTVSMES - Integração com o PCFactory
//**********************************************************************************************************
//*** BRASILUX - APÓS GRAVAÇÃO DO APONTAMENTO DE LABORATÓRIO ALTERA A OP PARA ENVIO DO PESO FINAL PARA O PCF
Static Function FINTEGPCF()
       Local aMATA650    := {}       //-Array com os campos
       Local nOpc        := 4
       Local lMsErroAuto := .F.
       Local _cFunAtual  := FunName()

       SetFunName( "MATA650" ) //Para funcionar a integração com o PPI Multitask
       RpcSetType( )
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Se alteracao ou exclusao, deve-se posicionar no registro     ³
       //³ da SC2 antes de executar a rotina automatica                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
       SC2->(DbSeek(xFilial("SC2") + _cGet1Ord ) )
	
       aMata650 := { { 'C2_FILIAL' , SC2->C2_FILIAL           , NIL },;
                     { 'C2_PRODUTO', SC2->C2_PRODUTO          , NIL },;          
                     { 'C2_NUM'    , SC2->C2_NUM              , NIL },;          
                     { 'C2_ITEM'   , SC2->C2_ITEM             , NIL },;
                     { 'C2_SEQUEN' , SC2->C2_SEQUEN           , NIL },;
                     { 'C2_OBS'    , "4 - Fim  do Laboratório", NIL } }

       msExecAuto( { |x, Y| Mata650(x, Y) }, aMata650, nOpc )
       If lMsErroAuto
          MostraErro()
       Else
          //Função para buscar Ordens de PAs e integrar pesos
          fIntegPAs()
       EndIf
       SetFunName( _cFunAtual )
Return

//************************************************************
//*** TOTVSMES - Integração com o PCFactory - LGS#20191106 ***
//************************************************************
Static Function fIntegPAs()
       Local aMATA650    := {}  //-Array com os campos
       Local nOpc        := 4
       Local lMsErroAuto := .F.
       Private _aPesoProd:= {}

       SetFunName("MATA650") 
       RpcSetType( )

       DbSelectArea("SC2") //Busco Produtos do Lote
       SC2->( DbOrderNickName("SC2001") )
       If SC2->( DbSeek( xFilial("SC2") + _cGet2Lot ) )
          While !Eof() .and. SC2->C2_LOTE == _cGet2Lot
                _aPesoProd := {}
                DbSelectArea("SB1") //Verifico se produto é um PA
                SB1->( DbSetorder( 1 ) )
                If SB1->( DbSeek( xFilial ("SB1") + SC2->C2_PRODUTO ) )
                   If SB1->B1_TIPO == 'PA'
                      _aPesoProd := fPesoPA()
                      aMata650  := { {'C2_FILIAL'   ,SC2->C2_FILIAL                                    , NIL },;
                                     {'C2_PRODUTO'  ,SC2->C2_PRODUTO                                   , NIL },;          
                                     {'C2_NUM'      ,SC2->C2_NUM                                       , NIL },;          
                                     {'C2_ITEM'     ,SC2->C2_ITEM                                      , NIL },;
                                     {'C2_SEQUEN'   ,SC2->C2_SEQUEN                                    , NIL },;
                                     {'C2_OBS'      ,"4 - Fim  do Laboratório" + AllTrim( SC2->C2_OBS ), NIL } }             

                      msExecAuto( { | x, Y | Mata650( x, Y ) }, aMata650, nOpc )
                      If lMsErroAuto
                         MostraErro()
                      EndIf
                   Endif
                Endif
                DbSelectArea("SC2")
                SC2->( DbSkip() )
          EndDo
       Endif
Return

/*/{Protheus.doc} fPesoPA
Busca a estrutura do produto e retorna o peso liquido e bruto do produto
@type function
@version 2020.01
@author Luís Gustavo de Souza
@since 16/12/2020
@return Array, Retorna array com pesos liquido e bruto para envio ao PCF
/*/
Static Function fPesoPA()
       Local _nPesoLiqu := 0
       Local _nPesoBrut := 0
       Local _aCompProd := {}
       Local _nX        := 0

       DbSelectArea("SG1")
       SG1->( DbSetOrder( 1 ) )
       If SG1->( DbSeek( xFilial("SG1") + SB1->B1_COD) )
          While !Eof() .and. SG1->G1_COD == SB1->B1_COD
                //                  COMPONENTE    QUANTIDADE     UNIDADE  TIPO  PESO  TOTAL
                aAdd( _aCompProd, { SG1->G1_COMP, SG1->G1_QUANT, ''     , ''  , 0   , 0    } )
                DbSelectArea("SG1")
                SG1->( DbSkip( ) )
          EndDo
       Endif
       //Calcula Peso Por item da fórmula
       For _nX := 1 To Len( _aCompProd )
           DbSelectArea( "SB1" )
           SB1->( DbSetorder( 1 ) )
           If SB1->( DbSeek( xFilial( "SB1" ) + _aCompProd[_nX][1] ) )
              _aCompProd[ _nX ][3] := SB1->B1_UM
              _aCompProd[ _nX ][4] := SB1->B1_TIPO
              _aCompProd[ _nX ][5] := SB1->B1_PESO //Peso Liquido do Produto
              If SB1->B1_TIPO == 'PI'
                 _aCompProd[ _nX ][6] := Round( Iif( SB1->B1_UM $ 'UN.KG.K ', _aCompProd[ _nX ][2], _aCompProd[ _nX ][2] * ZZA->ZZA_PESLAB ), 3 )
                 _nPesoLiqu += Round( _aCompProd[ _nX ][6], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Else
                 _aCompProd[ _nX ][6] := Round( _aCompProd[ _nX ][2] * _aCompProd[ _nX ][5], 3 )
                 _nPesoBrut += Round( _aCompProd[ _nX ][6], 3 )
              Endif
           Endif
       Next
Return { _nPesoLiqu, _nPesoBrut }

/*/{Protheus.doc} fLerPeso
Função que efetua a leitura dos pesos capturados pelo sistema supervisório ( IP 10.1.1.160/161 )
@type function
@version 2020.01
@author gustavosouza
@since 16/12/2020
@param oSay, Object, Parametro da descrição da tela
/*/
Static Function fLerPeso( oSay )
       Local _cPathOP := 'C:\DADOS\OP\'
       Local _cArqOrd := SubStr( _cGet1Ord, 1, 6 ) + '.DAT'
       Local _cArqNew := SubStr( _cGet1Ord, 1, 6 ) + '.TXT'
       Local _cString , _nArq, _nX
       Local _nlinha as Numeric
       Local _aPesos as Array

       _aPesos  := {}
       _nlinha  := 1
       _cString := ""
       _nArq    := FOPEN( _cPathOP + _cArqOrd, 0 )
       If FERROR() == 0 .and. _nArq <> -1
          //Busco o tamanho do arquivo.
          _nLength := FSEEK( _nArq, 0, 2 )
          //Posiciono o arquivo no inicio.
          FSEEK( _nArq, 0 )
          //Leio o arquivo carregando a variável com os dados do arquivo.
          FRead( _nArq, @_cString, _nLength )
          //Ajusto a codificação do arquivo.
          _cString := EncodeUtf8( _cString, "ucs-2" )
          //Fecho o arquivo.
          FClose( _nArq )
          //Gravo um novo arquivo com o formato correto.
          MemoWrite( _cPathOP + _cArqNew, _cString )
          //Tratamentos para leitura do arquivo no novo formato
          _nArq    := FT_FUSE( _cPathOP + _cArqNew )
          _nLength := FT_FLASTREC()
          FT_FGOTOP()
          While !FT_FEOF()
                cLine  := FT_FReadLn()
                //Estrutura do arquivo 
                //Linha  1 - Produto
                //Linha  2 - Descrição
                //Linha  3 - Peso Bruto
                //Linha  4 - Peso Liquido
                //Linha  5 a Linha 24 - Produto
                //Linha 25 / 20 Colunas - A pesar
                //Linha 26 / 20 Colunas - Diferença de peso
                If _nlinha >= 1 .and. _nLinha <= 24
                   aAdd( _aPesos, { cLine } )
                Else
                   aAdd( _aPesos, { StrTokArr( cLine, " " ) } )
                Endif
                _nlinha++
                FT_FSKIP()
          EndDo
          FT_FUSE()
          FErase( _cPathOP + _cArqNew )
       else
          MessageBox( 'Não foi possivel ler o arquivo.', 'Atenção', 48 )
       Endif
       _nColPes := 4 //Variável para controle da coluna dos arrays da posição 25 e 26 (de 1 a 20 posições correspondente a partir da linha 5)
       For _nX := 1 To Len( _aPesos )
           If ( _nX >= 5 .and. _nX <= 24 ) .and. !Empty( _aPesos[_nX] )
              _nPos := aScan( _aBrwIte, { |x| Alltrim( x[1] ) == Alltrim( _aPesos[_nX][1] ) } )
              If _nPos > 0
                 _aBrwIte[ _nPos ][ 4 ] := ROUND( ( Val( _aPesos[25][1][_nX - _nColPes] ) + Val( _aPesos[26][1][_nX - _nColPes] ) ), 3 )
              Endif
           Endif
       Next
       _nGet1Ite := 0
       _nGet2Ite := _nGet7Tar
       For _nX := 1 To Len( _aBrwIte )
           _nGet1Ite += _aBrwIte[_nX][4]
           _nGet2Ite += _aBrwIte[_nX][4]
            DbSelectArea("ZZF")
            ZZF->( DbSetOrder( 4 ) )
            If ZZF->( DbSeek( xFilial("ZZF") + Substr( _cGet1Ord + space(TamSx3( 'ZZF_ORDEM' )[1]), 1, TamSx3( 'ZZF_ORDEM' )[1] ) + _aBrwIte[_nX][1] + _aBrwIte[_nX][2] ) )
               If ZZF->ZZF_FLAG <> '1'
                  If _aBrwIte[_nX][ 3] <> 0 .and. !( _aBrwIte[_nX][ 4] == ZZF->ZZF_QTDUSA )
                     RecLock( "ZZF", .F. )
                        ZZF->ZZF_QTDUSA := _aBrwIte[_nX][ 4]
                        ZZF->ZZF_OBSINI := Alltrim( ZZF->ZZF_OBS ) + ' / P.Mesanino'
                     ZZF->( MsUnLock() )
                  Endif
               Endif
            Endif
       Next
       _oGetIte01:Refresh()
       _oGetIte02:Refresh()
Return
