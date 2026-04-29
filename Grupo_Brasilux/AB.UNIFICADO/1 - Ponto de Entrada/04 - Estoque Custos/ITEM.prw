#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#include 'parmtype.ch'  
#include "topconn.ch"
/*/{Protheus.doc} ITEM
Pontos de entrada MVC da rotina MATA010.
17/05/2002 - Ponto de Entrada para atualizar pesos específicos de PI's baseado 
             no peso específico da mat. prima. Executado após a alteração 
             da mat. prima.                                              
04/08/2004 - Alterado para aceitar outros locais para materias primas.
	          Utilizacao da fabrica.
29/10/2004 - Atualização do campo B1_UPRCCMP com valor de B1_UPRC, para que o valor de últ. compra seja atualizado
             corretamente, pois B1_UPRC é ajustado antes de passar pelo ponto de entrada SD1100I
30/09/2019 - Luís Gustavo - Adequação para release 12.1.25

Uso: Brasilux/Matriz e Dissoltex.
Alerta! => Não pode ser usado na Resina!
@type function
@version 1.0
@author Cleber Orati Domingues
@since 17/05/2002
@return Logical, Retorna verdadeiro ou falso de acordo com as condições
/*/
User Function ITEM()//Nome o ID do Modelo de Dados (Model) ou Nome da rotina
     Local aParam     := PARAMIXB
     Local xRet       := .T.
     Local oObj       := ''
     Local cIdPonto   := ''
     Local cIdModel   := ''
     Local lIsGrid    := .F.
     Local _XSIM3G
     Local _XDTATU
     Local _XEXPO
     Local _nAtual    := 0
     Local _aEstru    := {}
     Local _aAjust    := {}
     Local _aArea     := GetArea()
     Local _cGrpEmp   := Alltrim( FWGrpCompany() )
     Local _cFilial   := Alltrim( FWCodFil() )
     Local _cNumEmp   := _cGrpEmp + _cFilial
     Local nPrcTab    := 0
     Local _ZPPAR0042 := GetMV( "ZP_PAR0042" ) //Empresas para desconsidera na validação 
     Local _ZPPAR0043 := GetMV( "ZP_PAR0043" ) //Empresas para envio ao TOTVS SFA
     
     Local _ZPPAR0092 := GetMV( "ZP_PAR0092" ) // Desabilita Trigger SB1
     Local _ZPPAR0104 := GetMV( "ZP_PAR0104" ) // Habilita alteração B1_GRUPO2 Trigger SB1
     Local _ZPPAR0103 := GetMV( "ZP_PAR0103" ) // Atualizar Pesos Específicos Trigger SB1

     
     

     

     If aParam <> NIL
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid  := ( Len( aParam ) > 3 )

        DO CASE 
           CASE _cGrpEmp == '01' //Empresas do grupo BRASILUX
                If cIdPonto == 'MODELVLDACTIVE'   //Valida abertura da Tela
                ElseIf cIdPonto == 'MODELPRE'     //Pré configurações do Modelo de Dados
                ElseIf cIdPonto == 'FORMPRE'      //Pré configurações do Formulário de Dados
                ElseIf cIdPonto == 'BUTTONBAR'    //Adição de opções no Ações Relacionadas dentro da tela
                ElseIf cIdPonto == 'FORMPOS'      //Chamada na validação total do formulário.
                ElseIf cIdPonto == 'FORMLINEPRE'  //Chamada na pré validação da linha do formulário.
                ElseIF cIdPonto == 'FORMLINEPOS'  //Chamada na validação da linha do formulário.
                ElseIf cIdPonto == 'MODELPOS'     //Chamada na validação total do modelo.
                       If oObj:nOperation == 3    //Inclusão ( Em substituição ao fonte antigo MT010INC )
                          //Validação da Unidade de Medida x Peso Bruto
                          If Alltrim( M->B1_UM ) != "K" .AND. Alltrim( M->B1_UM ) != "KG" .AND. Alltrim( M->B1_UM ) != "L" .AND. M->B1_TIPO != "PA" .AND. M->B1_PESBRU <= 0
                             If _cNumEmp != _ZPPAR0042 //Não apresentar mensagem para empresas cadastradas no parâmetro
                                If !U_IsProdCusto( M->B1_COD, .T. ) //Verifica se produto de custeio
                                   cAuxMens := "Produto: " + Alltrim( M->B1_COD ) + " - Preencha o Peso Bruto!"
                                   xRet := .F.
                                   If Type( "l010Auto" ) <> "U" .and. l010Auto //release 12.1.25
                                      FwLogMSG( "INFO", , 'SIGAPCP', FunName(), '', '01', cAuxMens, 0 )
                                   Else
                                      MessageBox( cAuxMens, "Atenção", 48 )
                                   Endif
                                Endif  
                             Endif
                          Endif 
                       ElseIf oObj:nOperation == 4    //Alteração ( Em substituição ao fonte antigo MT010ALT )
                              //Validação da Unidade de Medida x Peso Bruto
                              If Alltrim( M->B1_UM ) != "K" .AND. Alltrim( M->B1_UM ) != "KG" .AND. Alltrim( M->B1_UM ) != "L" .AND. M->B1_TIPO != "PA" .AND. M->B1_PESBRU <= 0
                                 If _cNumEmp != _ZPPAR0042 //Não apresentar mensagem para empresas cadastradas no parâmetro
                                    If !U_IsProdCusto( M->B1_COD, .T. ) //Verifica se produto de custeio
                                       cAuxMens := "Produto: " + Alltrim( M->B1_COD ) + " - Preencha o Peso Bruto!"
                                       xRet := .F.
                                       If Type( "l010Auto" ) <> "U" .and. l010Auto //release 12.1.25
                                          FwLogMSG( "INFO", , 'SIGAPCP', FunName(), '', '01', cAuxMens, 0 )
                                       Else
                                          MessageBox( cAuxMens, "Atenção", 48 )
                                       Endif
                                    Endif  
                                 Endif
                              Endif 
                              //Validação do preenchimento do NCM
                              If Empty( Alltrim( M->B1_POSIPI ) )
                                 cAuxMens := "Produto: " + Alltrim( M->B1_COD ) + " - Preencha o NCM!"
                                 xRet := .F.
                                 If Type( "l010Auto" ) <> "U" .and. l010Auto //release 12.1.25
                                    FwLogMSG( "INFO", , 'SIGAPCP', FunName(), '', '01', cAuxMens, 0 )
                                 Else
                                    MessageBox( cAuxMens, "Atenção", 48 )
                                 Endif
                              Endif
                              If ( Len( Alltrim( SB1->B1_COD ) ) == 12 ) .and. Empty( SB1->B1_GRUPO2 )
                                 MessageBox( "Preencha o campo GRUPO 2!", "Atenção", 48 )
                                 xRet := .F.
                              Endif
                       Endif
                ElseIf cIdPonto == 'MODELCOMMITTTS'   //Chamada após a gravação total do modelo e dentro da transação.
                       If oObj:nOperation == 5 //Exclusão
                          If SB1->B1_X_SIM3G == "S"
                             RecLock( "SB1", .F. )
                                SB1->B1_X_SIM3G := "N"
                                SB1->B1_X_DTATU := DATE()
                                SB1->B1_X_EXPO  := "N"
                             SB1->( MsUnLock() )
                          Endif
                       Endif
                ElseIf cIdPonto == 'MODELCOMMITNTTS'  //Chamada após a gravação total do modelo e fora da transação

                       // Subtitiu trigger trig_inclui_SB1010  Nelieder 19/05/2023
                       If (oObj:nOperation == 3) .AND. _ZPPAR0092//Desabilita Trigger SB1                            
                          U_ZPCPP01()  
                       EndIf 

                       // Subtitiu trigger trig_atualiza_SB1010 Nelieder 19/05/2023
                       If (oObj:nOperation == 4) .AND. _ZPPAR0092//Desabilita Trigger SB1                            
                          U_ZPCPP02()  
                       EndIf 
 
                       If oObj:nOperation == 3 .or.  oObj:nOperation == 4     //Inclusão ou Alteração ( Em substituição ao fonte antigo MT010INC / MT010ALT )
                          /*****************************************************************************************************************************/
                          /***                                      I N I C I O    D A S    A L T E R A Ç Õ E S                                      ***/
                          //*** Enviar alteracoes para TOTVS SFA
                          _lMandarMS = .F.
                          If _cNumEmp $ _ZPPAR0043 
                             If SB1->B1_TIPO == 'PA'
                                _lMandarMS := .t.
                             Else
                                DbSelectArea("SX5")
                                SX5->( DbSetOrder( 1 ) )
                                If SX5->( DbSeek( xFilial("SX5") + "Z3" + Alltrim( SB1->B1_COD ) ) ) //Identifico se o produto não for PA e for produto de venda na tabela Z3 da SX5
                                   _lMandarMS = .t.
                                Endif
                             Endif
                          Endif
                              If _lMandarMS
                                 Do Case
                                    Case SB1->B1_X_SIM3G <> "N" .AND. ( SB1->B1_VEND == 'N' .OR. SB1->B1_MSBLQL == '1' )
                                         _XSIM3G := "N"
                                         _XDTATU := DATE()
                                         _XEXPO  := "N"
                                    Case SB1->B1_X_SIM3G <> "S" .AND. SB1->B1_VEND <> 'N' .AND. SB1->B1_MSBLQL <> '1'
                                         _XSIM3G := "S"
                                         _XDTATU := DATE()
                                         _XEXPO  := " "
                                    Case SB1->B1_X_SIM3G == "S"
                                         _XSIM3G := "S"
                                         _XDTATU := DATE()
                                         _XEXPO  := " "
                                 EndCase
                                 If _XSIM3G == "S"
                                    cObs := U_ObsProd()
                                    MSMM(SB1->B1_CODOBS, , , cObs, 1, , , "SB1", "B1_CODOBS")
                                 Endif
                                 nPrcTab := SB1->B1_PRV1
                                 If SB1->B1_ESTOQUE <> "S"
                                    DbSelectArea("SB5")
                                    SB5->( DbSetorder( 1 ) )
                                    If SB5->( DbSeeK( xFilial("SB5") + SB1->B1_COD ) )
                                       nPrcTab := SB5->B5_PRV2
                                    Endif 
                                 Endif
                                 //Ajuste de tabela enviada ao Mastersales (Brasilux e Dissoltex) tem código 2
                                 DbSelectarea("DA1")
                                 DA1->( Dbsetorder(2) ) //Cod.Produto + Cod. Tabela + Item
                                 DA1->( DbSeek( xFilial("DA1") + SB1->B1_COD +"2  " ) ) 
                                 If !Eof() .AND. !Bof() .and. DA1->DA1_FILIAL == xFilial("DA1") .AND. DA1->DA1_CODPRO == SB1->B1_COD .AND. DA1->DA1_CODTAB = "2  "
                                    If !( DA1->DA1_X_SIM3 == _XSIM3G ) .OR. ( DA1->DA1_PRCVEN != nPrcTab )
                                       RecLock( "DA1", .F. )
                                          DA1->DA1_X_SIM3 := _XSIM3G
                                          DA1->DA1_X_EXPO := " "
                                          DA1->DA1_PRCVEN := nPrcTab
                                       DA1->( MsUnLock() )
                                    Endif
                                 Else
                                    If _XSIM3G == "S"
                                       Dbselectarea("DA1")
                                       DA1->( DbSetOrder(3) ) //Cod. Tabela + Item 
                                       DA1->( DbSeek( xFilial("DA1") + "2  9999", .t. ) )
                                       DA1->( DbSkip(-1) )
                                       If Bof() .or. Eof()
                                          _nItem := 1
                                       Else
                                          _nItem := Val( DA1->DA1_ITEM ) + 1
                                       Endif
                                       _cItem := PadL( Alltrim( Str( _nItem ) ), 4, "0" )
                                       Reclock( "DA1", .T. )
                                          DA1->DA1_FILIAL := xFilial("DA1")
                                          DA1->DA1_ITEM   := _cItem
                                          DA1->DA1_CODTAB := '2  '
                                          DA1->DA1_CODPRO := SB1->B1_COD
                                          DA1->DA1_PRCVEN := nPrcTab
                                          DA1->DA1_ATIVO  := "1"
                                          DA1->DA1_TPOPER := "4"
                                          DA1->DA1_QTDLOT := 999999.99
                                          DA1->DA1_INDLOT := "000000000999999.99  "
                                          DA1->DA1_MOEDA  := 1
                                          DA1->DA1_X_SIM3 := "S"
                                       DA1->( Msunlock() )
                                    Endif
                                 Endif
                              Endif
                              /*** AJUSTES NA TABELA SB1 ***/
                              DbSelectArea( "SB1" )
                              RecLock( "SB1", .F. )
                                 If _lMandarMS
                                    SB1->B1_X_SIM3G := _XSIM3G
                                    SB1->B1_X_DTATU := _XDTATU
                                    SB1->B1_X_EXPO  := _XEXPO
                                 Endif
                                 //Informações de Lucro e Comissão
                                 If (_cGrpEmp == '01') .and. (substr(_cFilial,1,2) $ "01-06") //Empresas de Tintas
                                    If Len( Alltrim( SB1->B1_COD ) ) == 12 .and. ( ( SB1->B1_LUCRO <= 0 .or. SB1->B1_LCRMIN <= 0 ) .or. ( SB1->B1_LUCRO2 <= 0 ) .or. ( SB1->B1_LUCROM2 <= 0 ) .or. ( SB1->B1_COMIS <= 0 ) )
                                       DbSelectArea("SZ1")
                                       SZ1->( DbSetOrder(1) )
                                       If SZ1->( DbSeek( xFilial("SZ1") + SubStr( SB1->B1_COD, 4, 2 ) ) )
                                          SB1->B1_LUCRO := SZ1->Z1_LUCRO
                                          SB1->B1_LCRMIN := SZ1->Z1_LUCRMIN
                                          SB1->B1_LUCRO2 := SZ1->Z1_LUCRO2
                                          SB1->B1_LUCROM2 := SZ1->Z1_LUCROM2
                                          If SB1->B1_COMIS <= 0
                                             SB1->B1_COMIS := SZ1->Z1_COMISSA
                                          Endif
                                       Endif
                                    Endif
                                 Endif
                                 // Alteração para verificação dos locais padrão considerando na Matriz Fab1 e Fab2
                                 If SB1->B1_TIPO == 'MP'
                                    If Iif( !( _cNumEmp $ "01010101.01010104" ), !SB1->B1_LOCPAD $ '01', !SB1->B1_LOCPAD $ '01.10.R1.R2' )
                                       SB1->B1_LOCPAD := '01'
                                    Endif
                                 ElseIf SB1->B1_TIPO == 'PI'
                                        If Iif( !( _cNumEmp $ "01010101.01010104" ), !SB1->B1_LOCPAD $ '02', !SB1->B1_LOCPAD $ '02.20.R1.R2' )
                                           If Len( Alltrim( SB1->B1_COD ) ) == 12 .AND. _cNumEmp == "01010101"
                                              SB1->B1_LOCPAD = Iif( Posicione( "SZ1", 1, xFilial("SZ1") + SubStr( SB1->B1_COD, 04, 02 ), "Z1_LOCPAD" ) == '20', '20', '02' )
                                           Else
                                              SB1->B1_LOCPAD := '02'
                                           Endif
                                        Endif
                                 ElseIf SB1->B1_TIPO == 'PA'
                                        If Iif( !( _cNumEmp == "01010101" ), !SB1->B1_LOCPAD $ '03.P1', !SB1->B1_LOCPAD $ '03.30.P1.P2' )
                                           If Len( Alltrim( SB1->B1_COD ) ) == 12 .AND. _cNumEmp == "01010101"
                                              SB1->B1_LOCPAD = Iif( Posicione( "SZ1", 1, xFilial("SZ1") + SubStr( SB1->B1_COD, 04, 02 ), "Z1_LOCPAD" ) == '02', 'P1', 'P2' )
                                           Else
                                              SB1->B1_LOCPAD := Iif( _cNumEmp == "01060101", "P1", "03" ) //Cleber(17/10/14) -> Criação do almox. de produtos recem produzidos
                                           Endif
                                        Endif
                                 Endif
                                 If SB1->B1_UPRCCMP != SB1->B1_UPRC // 29/10/04(Cleber) :
                                    SB1->B1_UPRCCMP := SB1->B1_UPRC
                                 Endif

                                 nPicmret := 35
                                 cTs      := "   "
                                 //Índice IBPT (18/06/14) e Verif. se tem ST
                                 If !Empty( SB1->B1_POSIPI )
                                    DbSelectArea("SYD")
                                    SYD->( DbSetOrder(1) )
                                    If SYD->( DbSeek( xFilial("SYD") + SB1->B1_POSIPI + SB1->B1_EX_NCM ) )
                                       If SB1->B1_IMPNCM <= 0
                                          nAux := Iif( SB1->B1_ORIGEM > "0", SYD->YD_ALIQIM2, SYD->YD_ALIQIMP )
                                          If SB1->B1_IMPNCM != nAux
                                             SB1->B1_IMPNCM := nAux
                                          Endif
                                       Endif
                                       If SYD->YD_TEM_ST = "2"
                                          nPicmret := 0
                                          cTs      := "502"
                                       Endif
                                       //Cleber (21/06/17)->Chamado 007485, Preencher campos CEST para tintas, CONVÊNIO ICMS 52, DE 7 DE ABRIL DE 2017
                                       If SubStr( _cNumEmp, 1, 4 ) == "0106" .or. SubStr( _cNumEmp, 1, 4 ) == "0101"
                                          cCest := ""
                                          DO CASE
                                             CASE Alltrim( SB1->B1_POSIPI ) $ "32050000.32061119"
                                                  cCest := "2400300"
                                             /*Solicitação Priscila em 05/01/2021, excluir o CEST 2400200 para o NCM 32041700
                                             CASE SB1->B1_POSIPI = "32041700"
                                                  cCest := "2400200"*/
                                             CASE SubStr( Alltrim( SB1->B1_POSIPI ), 1, 6 ) $ "321000"
                                                  cCest := "2400100"
                                             CASE SubStr( Alltrim( SB1->B1_POSIPI ), 1, 4 ) $ "3212.3206.3204"
                                                  cCest := "2400300"
                                             CASE SubStr( Alltrim( SB1->B1_POSIPI ), 1, 4 ) $ "2821"
                                                  cCest := "2400200"
                                             CASE Alltrim( SubStr( SB1->B1_POSIPI, 1, 4 ) ) $ "3209.3208"
                                                  cCest := "2400100"
                                          ENDCASE
                                          If !Empty( cCest )
                                             SB1->B1_CEST := cCest
                                          Endif
                                       Endif
                                    Endif
                                    //Cleber(23/11/17) => chamado 008813 
                                    If SB1->B1_POSIPI = "27101230"
                                       SB1->B1_GRTRIB := "003"
                                    Endif
                                 Endif
                                 If SB1->B1_PICMRET <> nPicmret .OR. SB1->B1_TS <> cTs
                                    SB1->B1_PICMRET := nPicmret 
                                    SB1->B1_TS := cTs
                                 Endif
                                 //Chamado 008142 (Fernando Mauri), preencher contas contábeis automaticamente
                                 cConta := ""
                                 DO CASE
                                    CASE SB1->B1_TIPO $ "MP" .AND. Alltrim( SB1->B1_GRUPO ) == "E001"
                                         cConta := "501010105003"
                                    CASE SB1->B1_TIPO $ "MP" .AND. Alltrim( SB1->B1_GRUPO ) <> "E001"
                                         cConta := "101010801001"
                                    CASE SB1->B1_TIPO $ "PI"
                                         cConta := "101010801003"
                                    CASE SB1->B1_TIPO $ "PA"
                                         cConta := "101010801004"
                                    CASE SB1->B1_TIPO $ "AI.IM"
                                         cConta := "107040101999"
                                    CASE SB1->B1_TIPO $ "EM"
                                         cConta := "101010801002"
                                    CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) $ "D000.D100.J000.L000.L100.L200.L300.L400.Y000")
                                         cConta := "501010105011"
                                    CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) $ "F000.F001.F002.F003.F004.F005.F006.F007.E001")
                                         cConta := "501010105003"
                                    CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "G000")
                                         cConta := "501010105010"
                                    //Ajustes solicitação Cezar - Chamado R773
                                    CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "U000")
                                         cConta := "501010105021"
                                    CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Y100")
                                         cConta := "501010107008"
                                    //Ajustes solicitação Cezar - Chamado R773
                                    CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Z100")
                                         cConta := "501010105022"
                                    CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Z600")
                                         cConta := "501010105009"
                                 ENDCASE
                                 If !Empty( cConta )
                                    SB1->B1_CONTA := cConta
                                 Endif
                                 //Chamado 017035, colocar grupo de tributação 003 para qualquer produto com palavras DILUENTE ou SOLVENTE
                                 If ( ( "DILUENTE" $ SB1->B1_DESC ) .or. ( "SOLVENTE" $ SB1->B1_DESC ) ) .and. !( SB1->B1_GRTRIB = "003" )
                                    SB1->B1_GRTRIB := "003"
                                 Endif
                              DbSelectArea( "SB1" )
                              SB1->( MsUnLock( ) )
                              /*** FIM DOS AJUSTES NA TABELA SB1 ***/
                              _aEstru := SB1->( DBStruct() )
                              For _nAtual := 1 To Len( _aEstru )
                                  aAdd( _aAjust, { _aEstru[_nAtual][1], &( "SB1->" + _aEstru[_nAtual][1] ) } )
                              Next

                              //Incluir Complemento de Produto p/ uso na Tab. 2
                              If ( _cGrpEmp == '01') .and. ( SubStr( _cFilial, 1, 2 ) $ "01-06" ) //Empresas de Tintas
                                 If Alltrim(SB1->B1_TIPO) == "PA" .or. nPrcTab > 0.0
                                    DbSelectArea("SB5")
                                    SB5->( DbSetOrder(1) )
                                    If !SB5->( DbSeek( xFilial("SB5") + SB1->B1_COD ) )
                                       Reclock( "SB5", .T. )
                                          SB5->B5_FILIAL  := xFilial("SB5")
                                          SB5->B5_COD     := SB1->B1_COD
                                          SB5->B5_CEME    := SB1->B1_DESC
                                          SB5->B5_CODATIV := SB1->B1_POSIPI
                                    Else
                                       Reclock("SB5",.F.)      
                                    Endif
                                    //Gravar B5_FCIPRV para ter referência em produtos novos ao calcular FCI
                                    If nPrcTab > 0.0 .and. nPrcTab != SB5->B5_FCIPRV
                                       SB5->B5_FCIPRV := nPrcTab
                                    Endif
                                    SB5->( MsUnLock() )
                                Endif
                              Endif
                              If ( _cGrpEmp == '01') .and. ( SubStr( _cFilial, 1, 2 ) $ "01" ) //Empresas de Tintas
                                 //CHAMADA PARA VERIFICAÇÃO E INCLUSÃO DO REGISTRO EM OUTRAS FILIAIS
                                 fAjustaCad( _aAjust )
                              Endif
                              /***                                            F I M    D O S    A J U S T E S                                            ***/
                              /*****************************************************************************************************************************/
                       Endif
                ElseIf cIdPonto == 'FORMCOMMITTTSPRE' //Chamada após a gravação da tabela do formulário.
                  
                  // incluido por Nelieder em 17/05/2023 retirada trigger SB1
                  //@cGrupodepois
                  //@cGrupoantes = SB1->B1_COD
                  cRecno := SB1->(RecNo())
                  If _ZPPAR0104
                     if (!Empty(M->B1_GRUPO2) .AND. LEN(AllTrim(SB1->B1_COD)) ==  12 ) .AND. (M->B1_GRUPO2 <> SB1->B1_GRUPO2) .AND. ( (SUBSTR(SB1->B1_COD,11,2) == '00') .OR. (SUBSTR(SB1->B1_COD,11,2) == '99'))
                        cQuery := "UPDATE "+RetSqlName("SB1")+" SET B1_GRUPO2 = '"+AllTrim(M->B1_GRUPO2)+"' WHERE (R_E_C_N_O_ <> "+AllTrim(Str(cRecno))+") AND  "
                        cQuery += "(D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND  "
                        cQuery += "(SUBSTRING(B1_COD,1,10) = SUBSTRING('"+SB1->B1_COD+"',1,10)) AND (B1_GRUPO2 <> '"+AllTrim(M->B1_GRUPO2)+"')"
                        TCSqlExec(cQuery)
                     EndIf
                  Endif   

                  // incluido por Nelieder em 17/05/2023 retirada trigger SB1
                  If _ZPPAR0103
                     If ( (_cFilial <> '010106') .AND. (_cFilial <> '010107') .AND. (M->B1_PESOESP <> SB1->B1_PESOESP) )  //Atualizar Pesos Específicos, excluindo depósitos e excluit também linha 75 que é de resinas
                        If (SB1->B1_TIPO == "MP") .OR. (SB1->B1_TIPO == "PI")
                           cQuery := " SELECT DISTINCT G1_COD AS CODIGO from "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
                           cQuery += " WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COMP = '"+AllTrim(SB1->B1_COD)+"') AND ((SUBSTRING(G1_COD,4,2) <> '75') OR (LEN(G1_COD) <> 12)) "
                           cQuery += " ORDER BY CODIGO "
                           
                           IF SELECT("TMP") > 0
                              TMP->(dbCloseArea())
                           EndIf
                           TCQUERY cQuery ALIAS "TMP" NEW
                           DbSelectArea("TMP")

                           While TMP->(!EOF())
                              
                              //SET @nRegB1 = ISNULL((SELECT R_E_C_N_O_ FROM SB1010 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (B1_FILIAL = @cFilial) AND (B1_COD = @cProdAlt) AND (B1_UM IN ('K','KG','L'))),0)
                              If (AllTrim(SB1->B1_UM) == "K") .OR. (AllTrim(SB1->B1_UM) == "KG") .OR. (AllTrim(SB1->B1_UM) == "L")
                                 cQuery := " SELECT ROUND(SUM(G1_PERC)/SUM(G1_PERC/B1_PESOESP),5) AS PESOESP FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
                                 cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') "
                                 cQuery += " AND (G1_FILIAL = B1_FILIAL) AND (G1_COMP = B1_COD) AND (B1_TIPO IN('PI','MP')) AND (B1_UM IN ('K','KG')) "
                                 cQuery += " WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL ='"+xFilial("SB1")+"')  "
                                 cQuery += " AND (G1_COD = '"+SB1->B1_COD+"') AND (B1_TIPO IN('PI','MP')) AND (B1_UM IN('K','KG'))"
                                 
                                 IF SELECT("PES") > 0
                                    PES->(dbCloseArea())
                                 EndIf

                                 TCQUERY cQuery ALIAS "PES" NEW
                                 DbSelectArea("PES")
                                 PES->(dbGoTop())

                                 //Verifica se tem estrutura
                                 cQuery := " SELECT DISTINCT G1_COD AS CODIGO from "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
                                 cQuery += " WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = '"+AllTrim(SB1->B1_COD)+"') AND ((SUBSTRING(G1_COD,4,2) <> '75') OR (LEN(G1_COD) <> 12)) "
                                 cQuery += " ORDER BY CODIGO "
                                 
                                 IF SELECT("PET") > 0
                                    PET->(dbCloseArea())
                                 EndIf

                                 TCQUERY cQuery ALIAS "PET" NEW
                                 Count To nTotal 
                                 DbSelectArea("PET")
                                 PET->(dbGoTop())
                                 
                          
                                 If nTotal > 0   
                                    cQuery := "UPDATE SB1010 SET B1_PESOESP = "+AllTrim(Str(PES->PESOESP))+" WHERE (R_E_C_N_O_ = "+AllTrim(Str(cRecno))+")"
                                    TCSqlExec(cQuery)

                                    cQuery := " UPDATE "+RetSqlName("SG1")+" SET G1_QUANT = CASE WHEN SB1.B1_UM = 'L' THEN ((G1_PERC*SB1.B1_PESOESP)/100) ELSE G1_PERC/100 END FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
                                    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = SB1.B1_FILIAL) AND (G1_COD = SB1.B1_COD) "
                                    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" B1COMP WITH (NOLOCK) ON (B1COMP.D_E_L_E_T_ <> '*') AND (G1_FILIAL = B1COMP.B1_FILIAL) AND (G1_COMP = B1COMP.B1_COD) "
                                    cQuery += " WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = '"+SB1->B1_COD+"') AND (SB1.B1_UM IN ('K','KG','L')) AND (B1COMP.B1_UM IN ('K','KG','L')) "
                                    TCSqlExec(cQuery)

                                    //Atualizar Peso Específico da ficha de inspeção.
                                    //SET @nRegAux = ISNULL((SELECT TOP 1 R_E_C_N_O_ FROM QP7010 WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (QP7_FILIAL = @cFilial) AND (QP7_PRODUT = @cProdAlt) AND (QP7_ENSAIO = 'EN04MA22') ORDER BY R_E_C_N_O_ DESC),0)
                                    cQuery := "SELECT TOP 1 R_E_C_N_O_ RECNO FROM "+RetSqlName("QP7")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (QP7_FILIAL = '"+xFilial("QP7")+"') AND (QP7_PRODUT = '"+SB1->B1_COD+"') AND (QP7_ENSAIO = 'EN04MA22') ORDER BY R_E_C_N_O_ DESC"
                                    
                                    IF SELECT("PEX") > 0
                                       PEX->(dbCloseArea())
                                    EndIf

                                    TCQUERY cQuery ALIAS "PEX" NEW
                                    Count To nTotal 
                                    DbSelectArea("PEX")  
                                    PEX->(dbGoTop())
                                    If nTotal > 0   
                                       
                                       //SET @nMin = ISNULL((SELECT CONVERT(float,REPLACE(QP7_NOMINA,',','.')) - CONVERT(float,REPLACE(QP7_LIE,',','.')) FROM QP7010 WITH (NOLOCK) WHERE R_E_C_N_O_ = @nRegAux),0)
                                       cQuery := "SELECT CONVERT(float,REPLACE(QP7_NOMINA,',','.')) - CONVERT(float,REPLACE(QP7_LIE,',','.')) VMIN FROM "+RetSqlName("QP7")+" WITH (NOLOCK) WHERE R_E_C_N_O_ = "+AllTrim(Str(PEX->RECNO))+" "
                                       IF SELECT("MIN") > 0
                                          MIN->(dbCloseArea())
                                       EndIf
                                       TCQUERY cQuery ALIAS "MIN" NEW
                                       
                                       
                                       //SET @nMax = ISNULL((SELECT CONVERT(float,REPLACE(QP7_LSE,',','.')) - CONVERT(float,REPLACE(QP7_NOMINA,',','.')) FROM QP7010 WITH (NOLOCK) WHERE R_E_C_N_O_ = @nRegAux),0)
                                       cQuery := "SELECT CONVERT(float,REPLACE(QP7_LSE,',','.')) - CONVERT(float,REPLACE(QP7_NOMINA,',','.')) VMAX FROM "+RetSqlName("QP7")+" WITH (NOLOCK) WHERE R_E_C_N_O_ = "+AllTrim(Str(PEX->RECNO))+" "

                                       IF SELECT("MAX") > 0
                                          MAX->(dbCloseArea())
                                       EndIf

                                       TCQUERY cQuery ALIAS "MAX" NEW                                    
                                       
                                       
                                       cQuery := " UPDATE "+RetSqlName("QP7")+" SET QP7_NOMINA = REPLACE(CONVERT(VARCHAR,"+AllTrim(Str(PES->PESOESP))+"),'.',','), "
                                       cQuery += " QP7_LIE = REPLACE(CONVERT(VARCHAR,"+AllTrim(Str(PES->PESOESP))+" - "+AllTrim(Str(MIN->VMIN))+"),'.',','), "
                                       cQuery += " QP7_LSE = REPLACE(CONVERT(VARCHAR,"+AllTrim(Str(PES->PESOESP))+" + "+AllTrim(Str(MAX->VMAX))+"),'.',',') WHERE R_E_C_N_O_ = "+AllTrim(Str(PEX->RECNO))+" "
                                       TCSqlExec(cQuery)                                 
                                    EndIf   

                                 EndIf 

                              Endif
                              TMP->(dbSKip())
                           Enddo
                           
                           cQuery := " UPDATE SB1010 SET B1_CONV = "+AllTrim(Str(M->B1_PESOESP))+" ,B1_TIPCONV = 'M' WHERE (R_E_C_N_O_ = "+AllTrim(Str(cRecno))+") AND (B1_UM = 'L')  "
                           TCSqlExec(cQuery)                                 
                        Endif

                        If (SB1->B1_PESBRU <> M->B1_PESBRU)
                           cQuery := " SELECT DISTINCT G1_COD FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
				               cQuery += " WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COMP = '"+SB1->B1_COD+"') "
                           
                           IF SELECT("TPB") > 0
                              TPB->(dbCloseArea())
                           EndIf

                           TCQUERY cQuery ALIAS "TPB" NEW                                    
                           While TPB->(!EOF())

                              cQuery := " UPDATE "+RetSqlName("SB1")+" SET "
				                  cQuery += " B1_PESBRU = (SELECT ROUND(SUM(G1_QUANT*(CASE WHEN B1_UM = 'L' THEN B1_PESOESP WHEN B1_UM IN ('K','KG') THEN 1 ELSE B1_PESBRU END)),4) AS PESOBRUTO FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
				                  cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = B1_FILIAL) AND (G1_COMP = B1_COD) AND (B1_TIPO IN('PA','MP','PI')) "
				                  cQuery += " WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = '"+SB1->B1_COD+"') AND (B1_TIPO IN('PA','MP','PI'))), "
				                  cQuery += " B1_PESO = (CASE WHEN B1_UM = 'L' THEN B1_PESOESP WHEN B1_UM IN ('K','KG') THEN 1 ELSE "
				                  cQuery += " (SELECT ROUND(SUM(G1_QUANT*(CASE WHEN B1_TIPO IN ('PA','PI') THEN B1_PESO ELSE 0 END)),4)  "
				                  cQuery += " FROM "+RetSqlName("SG1")+" SG1 WITH (NOLOCK) "
				                  cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = B1_FILIAL) AND (G1_COMP = B1_COD) AND (B1_TIPO IN('PA','MP','PI')) "
				                  cQuery += " WHERE (SG1.D_E_L_E_T_ <> '*') AND (G1_FILIAL = '"+xFilial("SG1")+"') AND (G1_COD = '"+SB1->B1_COD+"') AND (B1_TIPO IN('PA','MP','PI'))) END) "
				                  cQuery += " WHERE (D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (B1_COD = '"+SB1->B1_COD+"')"
                              TCSqlExec(cQuery)

                              TPB->(dbSKip())
                           Enddo
                           
                        Endif


                     Endif
                  Endif

                  If (oObj:GetOperation() == 4) .AND. (M->B1_UPRC <> SB1->B1_UPRC) .AND. ( (M->B1_TIPO == 'MP') .OR. (M->B1_TIPO == 'MC')  ) 
                     Reclock("Z05",.T.) 
                     Z05->Z05_FILIAL := xFilial("Z05")
                     Z05->Z05_COD    := SB1->B1_COD
                     Z05->Z05_DIA    := dDataBase
                     Z05->Z05_PRECO  := M->B1_UPRC
                     Z05->( MsUnlock() )
                  EndIf
                  
                  If (oObj:GetOperation() == 4) .AND. (_cFilial <> '010106') .AND. (_cFilial <> '010107')
                    If ( ( "DILUENTE" $ SB1->B1_DESC ) .or. ( "SOLVENTE" $ SB1->B1_DESC ) ) .and. !( M->B1_GRTRIB = "003" )
                        // não altera não enviando e-mail
                    Else   
                        if Alltrim(M->B1_GRTRIB) <> Alltrim(SB1->B1_GRTRIB)
                           cAssunto := 'Produto '+AllTrim(SB1->B1_COD)+' Grupo de Tributação Alterado!' 
                           Body     := 'O produto da filial '+AllTrim(SB1->B1_FILIAL)+', código: '+AllTrim(SB1->B1_COD)+' teve seu grupo de tributação alterado de '+AllTrim(SB1->B1_GRTRIB)+' para '+AllTrim(M->B1_GRTRIB)+'.
                           cDest    := 'fiscal@brasilux.com.br' 
                           //_cSubject, _cBody, _cMailTo, _cCC, _cAnexo, _cAccount, _cPass
                           U_EnvMail(cAssunto,Body,cDest,"","")
                        EndIf
                     EndIf
                  EndIf  

                ElseIf cIdPonto == 'FORMCOMMITTTSPOS' //Chamada após a gravação da tabela do formulário.
                ElseIf cIdPonto == 'MODELCANCEL'      //Tratamento na saida do formulário
                EndIf
           CASE _cGrpEmp == "11"             //TECPOLPA
                If cIdPonto == 'MODELCOMMITNTTS'  //Chamada após a gravação total do modelo e fora da transação
                   If oObj:nOperation == 3 .or.  oObj:nOperation == 4     //Inclusão ou Alteração ( Em substituição ao fonte antigo MT010INC / MT010ALT )
                      //RecLock( "SB1", .F. )
                      SB1 -> (SimpleLock())
                           DO CASE
                              CASE SB1->B1_X_SIM3G <> "N" .AND. SB1->B1_MSBLQL == '1'
                                 SB1->B1_X_SIM3G := "N"
                                 SB1->B1_X_DTATU := DATE()
                                 SB1->B1_X_EXPO  := "N"
                              CASE SB1->B1_X_SIM3G <> "S" .AND. SB1->B1_TIPO == "PA" .AND. SubStr( SB1->B1_COD, 1, 1 ) == "1" .AND. SB1->B1_MSBLQL <> '1'
                                 SB1->B1_X_SIM3G := "S"
                                 SB1->B1_X_DTATU := DATE()
                                 SB1->B1_X_EXPO  := " "
                              CASE SB1->B1_X_SIM3G == "S"
                                 SB1->B1_X_DTATU := DATE()
                                 SB1->B1_X_EXPO  := " "
                           ENDCASE

                         //Chamado 027359 (Fernando Mauri e Cezar), preenchimento de Contas Contábeis TecPolpa

                           cConta := ""
                           DO CASE
                              CASE SB1->B1_TIPO $ "MP.EM" .AND. Alltrim( SB1->B1_GRTRIB ) == "E001"
                              cConta := "501010105003"
                              CASE SB1->B1_TIPO $ "MP.EM" .AND. Alltrim( SB1->B1_GRTRIB ) <> "E001"
                              cConta := "101010801001"
                              CASE SB1->B1_TIPO $ "PI"
                              cConta := "101010801003"
                              CASE SB1->B1_TIPO $ "PA"
                              cConta := "101010801004"
                              CASE SB1->B1_TIPO $ "AI.IM" 
                              cConta := "107040101999"
                              CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRTRIB) $ "D000.D100.J000.L000.L100.L200.L300.L400.Y000")
                              cConta := "501010105011"
                              CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRTRIB) $ "F000.F001.F002.F003.F004.F005.F006.F007.E001")
                              cConta := "501010105003"
                              CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRTRIB) == "G000")
                              cConta := "501010105010"
                              CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRTRIB) == "U000")
                              cConta := "501010105021"
                              CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRTRIB) == "Y100")
                              cConta := "501010107008"
                              CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRTRIB) == "Z100")
                              cConta := "501010105022"
                              CASE (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRTRIB) == "Z600")
                              cConta := "501010105009"
                           ENDCASE
                              If !Empty( cConta )
                                 SB1->B1_CONTA := cConta
                              Endif
                     
                        DbSelectArea( "SB1" )
                        SB1->( MSUnLock() )
                   Endif
                Endif
        ENDCASE
     Endif
     RestArea( _aArea )
Return xRet

/*/{Protheus.doc} fAjustaCad
Ajusta cadastro de produto nas filiais de acordo com parâmetro ZP_PAR0044
@type function
@version v.2022.0315
@author Luis Gustavo Souza
@since 15/03/2022
@param _aAjust, Array, Recebe array com nome do campo e dados para gravação
/*/
Static Function fAjustaCad( _aAjust )
       Local _aZPAR0044 := StrTokArr( GetMV( "ZP_PAR0044" ), ';' ) 
       Local _nY, _nX
       Local _nRegSB1 := SB1->( RecNo( ) )
       Local _cCodPro := SB1->B1_COD

       If Len( _aZPAR0044 ) > 0
          For _nY := 1 To Len( _aZPAR0044 )
              _cCodFil := _aZPAR0044[_nY]
              DbSelectArea("SB1")
              SB1->( DbSetOrder( 1 ) )
              If SB1->( DbSeek( _cCodFil + _cCodPro ) )
                 //Altera produto para a filial
                 RecLock( "SB1", .F. )
                    For _nX := 1 To Len( _aAjust )
                        _nPosCpo := FieldPos( _aAjust[ _nX][1] )
                        If !Alltrim( _aAjust[ _nX][1] ) $ 'B1_FILIAL'
                           If Alltrim( _aAjust[ _nX][1] ) $ 'B1_X_SIM3G'
                              SB1->( FieldPut( _nPosCpo, 'N' ) )
                           Else
                              SB1->( FieldPut( _nPosCpo, _aAjust[ _nX][2] ) )
                           Endif
                        Endif
                    Next
              Else
                 //Inclui produto para a filial
                 RecLock( "SB1", .t. )
                    For _nX := 1 To Len( _aAjust )
                        _nPosCpo := FieldPos( _aAjust[ _nX][1] )
                        If Alltrim( _aAjust[ _nX][1] ) $ 'B1_FILIAL'
                           SB1->( FieldPut( _nPosCpo, _cCodFil ) )
                        ElseIf Alltrim( _aAjust[ _nX][1] ) $ 'B1_X_SIM3G'
                               SB1->( FieldPut( _nPosCpo, 'N' ) )
                        Else
                           SB1->( FieldPut( _nPosCpo, _aAjust[ _nX][2] ) )
                        Endif
                    Next
              Endif
              SB1->( MsUnLock( ) )
          Next
       Endif
       DbSelectArea( "SB1" )
       SB1->( DbGoTo( _nRegSB1 ) )
Return
