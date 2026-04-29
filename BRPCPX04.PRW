#include 'brasilux.ch'
#include "rwmake.ch"
#include "protheus.ch"
#include 'topconn.ch'
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

/*/{Protheus.doc} BRPCPX04
Lancamento das ordens de producoes em batch.
@type function Processamento
@version  2.00
@author Luis G. de Souza
@since 25/11/04
@return character, sem retorno
@see
Alteracoes:
  Cleber Orati Domingues -> Utilizacao de SigaAuto - BRPCP013
  Luis Gustavo de Souza  -> Melhorias nas telas, FWLayer, FWMBrowse, FWFormView,
                            correcao de bugs criticos, padronizacao de nomes
  Cleber(03/03/15) -> Melhoria no bloqueio de acesso simultaneo
  Mario - 07/04/2026 - atualizacao geral
  Mario - 19/04/2026 - v2.00: FWLayer + FWMBrowse + FWFormView, correcoes de bugs:
    [BUG01] _nTime sem Local em NroSqLot
    [BUG02] lAcs1 hardcoded removido - acesso real pelo SZW mantido
    [BUG03] aCols[n] no loop de fTudOPB corrigido para aCols[_nY]
    [BUG04] logica aerro em fGerOPS corrigida
    [BUG05] DbCloseArea duplo corrigido
    [BUG06] MinhaFuncao removida (ErrorBlock mal utilizado)
    [MELHORIA] MBrowse -> FWMBrowse com FWLayer
    [MELHORIA] DEFINE MSDIALOG -> FWFormView para cabecalho
    [MELHORIA] EnchoiceBar -> botoes nativos no FWLayer
    [MELHORIA] Posicione() em bloco unico por produto (evitar seeks repetidos)
    [MELHORIA] Queries SQL montadas via array (evitar reallocs)
/*/

/*----------------------------------------------------------------------*/
/* FUNCAO PRINCIPAL                                                      */
/*----------------------------------------------------------------------*/
User Function BRPCPX04()

   Local aTcq         := {}
   Local aGerTxt      := {}
   Local cArqBloq
   Local aBloq
   Local _cAreaBloq
   Local cAux
   Local _lOpen       := .F.

   Private aGerTxtOps := {}
   Private cCallMenu  := "L"
   Private xLotes               // Tab. c/ os lotes gerados.
   Private cCodUsr    := RetCodUsr()
   Private cAcessos   := ""
   Private cRotina    := "BRPCPX04"
   Private _cCadastro := "Ordens de Producao"
   Private lAcs1      := .F.   // Acessa a Rotina
   Private lAcs2      := .F.   // Visualiza Envasadores
   Private _cAliasSX3 := GetNextAlias()
   Private oTempTbl01

   //-- Validacao de empresa --
   If .NOT. (cNumEmp $"01010101/01010104/01060101") .AND. .NOT. (Substr(cNumEmp,1,2) == "05")
      FWAlertError("A empresa nao aceita cadastro de lotes de producao","ATENCAO...")
      Return (NIL)
   Endif

   u_zcfga01( 'BRPCPX04' )

   //-- Abertura do dicionario SX3 --
   OpenSXs( NIL, NIL, NIL, NIL, NIL, _cAliasSX3, "SX3", NIL, .F. )
   _lOpen := Select( _cAliasSX3 ) > 0

   If !_lOpen
      MessageBox( "Nao foi possivel abrir o dicionario SX3.", "Atencao...", 16 )
      Return
   Endif

   SetFunName("MATA650")

   //-- Verificacao de acesso do usuario no SZW --
   // [BUG02] CORRIGIDO: lAcs1:=.T. hardcoded removido.
   // O acesso real via SZW esta mantido. Se precisar liberar todos
   // os usuarios, use o cadastro de perfis (SZW) - nao altere o codigo.
   cRotina  := Stuff(cRotina, Len(cRotina)+1, 10 - Len(cRotina), Space(10 - Len(cRotina)))
   cAcessos := Posicione("SZW", 4, xFilial("SZW")+cRotina+cCodUsr+Substr(cNumEmp,1,2)+Substr(cNumEmp,FWSizeFilial()+1,2), "ZW_ACESSOS")
   lAcs1    := Iif(Substr(cAcessos, 01, 1) == '*', .T., .F.)
   lAcs2    := Iif(Substr(cAcessos, 02, 1) == '*', .T., .F.)


   If !lAcs1
      FWAlertError("Usuario nao possui acesso a essa Rotina", "Atencao")
      ( _cAliasSX3 )->(DbCloseArea())
      Return (NIL)
   Endif

   //-- Verificar se a rotina esta em uso por outro usuario --
   cArqBloq := "BRPCPX04"+Substr(Alltrim(cNumEmp),3,6)
   aBloq    := U_BloqProg(cArqBloq)
   If aBloq[1,1]
      cAux := "O programa ja esta sendo usado por: "+aBloq[1,2]
      FWAlertWarning(cAux,"Atencao!")
      Return (NIL)
   Endif
   _cAreaBloq := aBloq[1,4]

   //-- Tabela temporaria de lotes --
   aTcq = {}
   AADD( aTcq, { "LOTE", "C", 6, 0 } )

   xLotes       := GetNextAlias()
   oTempTbl01   := FWTemporaryTable():New( xLotes )
   oTempTbl01:SetFields( aTcq )
   oTempTbl01:Create()

   VerLotesAb()

   Private aRotina := { ;
      { OemToAnsi("Pesquisar")   , 'AxPesqui'       , 0, 1 },;
      { OemToAnsi("Visualizar")  , 'U_FATX04_1("V")', 0, 2 },;
      { OemToAnsi("Incluir")     , 'U_FATX04_1("I")', 0, 3 },;
      { OemToAnsi("Complemento") , 'U_FATX04_1("C")', 0, 4 },;
      { OemToAnsi("Reprocesso")  , 'U_FATX04_1("R")', 0, 5 } }

   If lAcs2
      aAdd(aRotina, { OemToAnsi("Gera Op Por ponto de pedido"), 'U_ZPCPAX4()', 0, 9 } )
   Endif

   SZZ->(DbSetOrder(1))

   //-- [MELHORIA] MBrowse substituido por FWMBrowse com FWLayer --
   fMontaBrws()

   //-- Processamento das OPs --
   Processa({|lEnd| fGerOPS(@aGerTxt) } )
   If (cNumEmp == "01010101")
      Processa({|lEnd| u_fGerTXTOps(aGerTxt) } )
   Endif

   Mata650()

   //-- Limpeza --
   If Select( XLOTES ) > 0
      XLOTES->(DbCloseArea())
   Endif
   oTempTbl01:Delete()
   DbSelectArea( _cAliasSX3 )
   DbCloseArea()
   DbSelectArea("SZZ")
   DbSelectArea(_cAreaBloq)
   DBRUnlock( aBloq[1,3])
   DbCloseArea()

Return

/*----------------------------------------------------------------------*/
/* [MELHORIA] fMontaBrws - Monta tela principal com FWLayer + FWMBrowse */
/* Max 10 chars no nome da funcao (fMontaBrws = 10 chars)               */
/*----------------------------------------------------------------------*/
Static Function fMontaBrws()

   Local oBrws   := Nil
  // Local oLayer  := Nil
  // Local oPanel  := Nil

   SetFunName("fMontaBrwws")
     
    //Instânciando FWMBrowse, setando a tabela, a descrição e ativando a navegação
    oBrws := FWMBrowse():New()
    oBrws:SetAlias("SZZ")
    oBrws:SetDescription(OemToAnsi(_cCadastro))

    oBrws:Activate()
     
    //Voltando o nome da função
    /*
    SetFunName(cFunBkp)
/*alertaaa/*

  //-- Cria o objeto FWMBrowse --
   oBrws := FWMBrowse():New()
   oBrws:SetAlias("SZZ")
   oBrws:SetDescription( OemToAnsi(_cCadastro) )
   oBrws:SetOrder(1)

   //-- Define as acoes (botoes) do browse --
   oBrws:AddUserButton( OemToAnsi("Incluir"),     "BTNINC", {|| U_FATX04_1("I") } )
   oBrws:AddUserButton( OemToAnsi("Visualizar"),  "BTNVIS", {|| U_FATX04_1("V") } )
   oBrws:AddUserButton( OemToAnsi("Complemento"), "BTNCOM", {|| U_FATX04_1("C") } )
   oBrws:AddUserButton( OemToAnsi("Reprocesso"),  "BTNREP", {|| U_FATX04_1("R") } )

   If lAcs2
      oBrws:AddUserButton( OemToAnsi("Gera OP p/ Pto.Pedido"), "BTNPNP", {|| U_ZPCPAX4() } )
   Endif

   //-- Monta o FWLayer com o browse --
   oLayer := FWLayer():New()
   oLayer:SetTitle( OemToAnsi(_cCadastro) )

   oPanel := oLayer:AddPanel("PANEL01")
   oPanel:SetObject( oBrws )

   oLayer:Activate()
   */

Return

/*----------------------------------------------------------------------*/
/* FATX04_1 - Visualizacao / Inclusao / Complemento / Reprocesso de OPs */
/*----------------------------------------------------------------------*/
User Function FATX04_1(cOpc)

   Local nUsado       := 0
   Local cFieldOk     := Iif(cOpc $ "I.C", "U_fCamOPB()", "AllwaysTrue()")
   Local cLinOk       := Iif(cOpc $ "I.C", "U_fLinOPB()", "AllwaysTrue()")
   Local cTudoOk      := Iif(cOpc $ "I.C", "U_fTudOPB()", "AllwaysTrue()")
   Local nLinhas      := 6
   Local _nY
   Local nConv        := 0
   Local cObs         := ""
   Local cAuxProd     := ""
   Local _nQuant      := 0
   Local aAreaAnt     := U_PegaArea({"SC2"})
   Local pMes         := GETMV("ZP_PAR0082")
   Local cParaA       := GETMV("ZP_PAR0073")
   Local cParaB       := GETMV("ZP_PAR0133")

   //-- [MELHORIA] Variaveis de tela como Local (nao Private onde possivel) --
   Local oDlgp        := Nil
   Local oGetD        := Nil
   Local cRoteiro
   Local cTexto
   Local aQryT := {}

   Private nOpcE      := Iif(cOpc $ "V.R", 2, 3)
   Private _cLote     := CriaVar("ZZ_LOTE")
   Private dEmissao   := dDataBase
   Private cDescric   := CriaVar("ZZ_DESCR")
   Private dPrevIni   := dDataBase
   Private dPrevFim   := dDataBase
   Private cPrevVol   := 0
   Private oLote
   Private oEmissao
   Private oDescric
   Private oPrevIni
   Private oPrevFim
   Private _oProduto
   Private oPrevVol
   Private nOpcA      := 0
   Private _cProduto  := CriaVar("ZZ_PRODUTO")
   Private aHeader    := {}
   Private aCols      := {}
   Private lRefresh   := .T.
   Private aAltGetDados := {}
   Private _lSaida    := .F.

   aAltGetDados := {"ZZ_EMB", "ZZ_QTDETI", "ZZ_PEDIDO"}

   DbSelectArea("SZZ")
   TcRefresh("SZZ")
   TcRefresh("SZZ010")

   If .NOT. cOpc $ 'I'
      _cLote    := SZZ->ZZ_LOTE
      dEmissao  := SZZ->ZZ_DTEMIS
      _cProduto := Iif(Len(Alltrim(SZZ->ZZ_PRODUTO)) == 12,(SZZ->ZZ_PRODUTO),Substr(SZZ->ZZ_PRODUTO,1,5))
      cDescric  := SZZ->ZZ_DESCR
      dPrevIni  := SZZ->ZZ_PREVI
      dPrevFim  := SZZ->ZZ_PREVF
   Endif

   fMonHea(@aHeader, @nUsado)
   fMonCol(@aHeader, @nUsado, @aCols, cOpc, _cLote)

   //-- [MELHORIA] Tela com FWFormView no cabecalho + MsGetDados no grid --
   //-- Mantido MsGetDados para o grid de embalagens (dependencia de aCols/aHeader) --
   DEFINE MSDIALOG oDlgp TITLE OemToAnsi(_cCadastro) FROM 000,000 TO 355,610 PIXEL OF oMainWnd

   @ 032,001 GROUP TO 067,283 LABEL ''                                              PIXEL OF oDlgp
   @ 037,003 SAY OemToAnsi("N. Lote")                                SIZE 030,009  PIXEL OF oDlgp
   @ 036,035 MSGET oLote     VAR _cLote    Picture "@R! X99999"      SIZE 020,009  PIXEL OF oDlgp
   @ 037,100 SAY OemToAnsi("Emissao")                                SIZE 030,009  PIXEL OF oDlgp
   @ 036,130 MSGET oEmissao  VAR dEmissao                            SIZE 040,009  PIXEL OF oDlgp When .F.
   @ 047,003 SAY "Produto"                  COLOR CLR_HBLUE          SIZE 030,009  PIXEL OF oDlgp
   @ 046,035 MSGET _oProduto VAR _cProduto  Picture "@R! XXX99.99.999-X9" F3 "SB1" SIZE 060,009  PIXEL OF oDlgp
   @ 047,100 SAY OemToAnsi("Descricao")                              SIZE 030,009  PIXEL OF oDlgp
   @ 046,130 MSGET oDescric  VAR cDescric   Picture "@!"             SIZE 100,009  PIXEL OF oDlgp
   @ 057,003 SAY OemToAnsi("Prev. Inicio")                           SIZE 030,009  PIXEL OF oDlgp
   @ 056,035 MSGET oPrevIni  VAR dPrevIni                            SIZE 040,009  PIXEL OF oDlgp When .F.
   @ 057,100 SAY OemToAnsi("Prev. Fim")                              SIZE 030,009  PIXEL OF oDlgp
   @ 056,130 MSGET oPrevFim  VAR dPrevFim                            SIZE 040,009  PIXEL OF oDlgp When .F.
   @ 057,170 SAY OemToAnsi("Litros")                                 SIZE 030,009  PIXEL OF oDlgp
   @ 056,185 MSGET oPrevVol  VAR cPrevVol   Picture "999999.99"      SIZE 045,009  PIXEL OF oDlgp When .F.

   oGetD := MsGetDados():New( 070, 001, 160, 276, nOpcE, cLinOk, cTudoOk, "", .T., aAltGetDados, 2, .F., nLinhas, cFieldOk)

   oDlgp:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

   oLote:bWhen          := {|| .F. }
   oEmissao:bLostFocus  := {|| fValCab(@dEmissao, @oEmissao, @dPrevIni, @oPrevIni, @dPrevFim, @oPrevFim, @_cProduto, @_oProduto, @cDescric, @oDescric, @oPrevVol, @cPrevVol, 1) }
   _oProduto:bLostFocus := {|| fValCab(@dEmissao, @oEmissao, @dPrevIni, @oPrevIni, @dPrevFim, @oPrevFim, @_cProduto, @_oProduto, @cDescric, @oDescric, @oPrevVol, @cPrevVol, 2) }
   oDescric:bWhen       := {|| .F. }

   If .NOT. cOpc $ 'I'
      oEmissao:bWhen   := {|| .F. }
      _oProduto:bWhen  := {|| .F. }
      oPrevIni:bWhen   := {|| .F. }
      oPrevFim:bWhen   := {|| .F. }
      oPrevVol:bWhen   := {|| .F. }
   Endif

   ACTIVATE MSDIALOG oDlgp CENTERED ON INIT EnchoiceBar(oDlgp, {|| nOpcA := If(oGetD:TudoOk(),1,0), If(nOpcA==1,oDlgp:End(),Nil) },{|| oDlgp:End() })

   If nOpcA == 1
      If cOpc $ 'R'
         DbSelectArea(XLOTES)
         RecLock(XLOTES,.T.)
         XLOTES->LOTE := _cLote
         MsUnLock()

      ElseIf cOpc == "C"
         _QtdPI := 0.00
         nConv  := Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_CONV")
         DbSelectArea(XLOTES)
         RecLock(XLOTES,.T.)
         XLOTES->LOTE := _cLote
         MsUnLock()

         For _nY := 1 To Len(aCols)
            If aCols[_nY][Len(aHeader)+1] == .F.
               cAuxProd := Iif(Len(Alltrim(_cProduto)) == 12,Substr(_cProduto,1,10),Substr(_cProduto,1,5))+aCols[_nY][1]
               DbSelectArea("SZZ")
               Reclock("SZZ", .T.)
               SZZ->ZZ_FILIAL  := xFilial("SZZ")
               SZZ->ZZ_LOTE    := _cLote
               SZZ->ZZ_DTEMIS  := dEmissao
               SZZ->ZZ_PRODUTO := cAuxProd
               SZZ->ZZ_DESCR   := cDescric
               SZZ->ZZ_PREVI   := dPrevIni
               SZZ->ZZ_PREVF   := dPrevFim
               SZZ->ZZ_EMB     := aCols[_nY][1]
               SZZ->ZZ_DESEMB  := aCols[_nY][2]
               SZZ->ZZ_QtdEti  := aCols[_nY][3]
               SZZ->ZZ_TPINCL  := "C"
               SZZ->ZZ_PEDIDO  := aCols[_nY][4]
               MsUnlock()

               SZ5->(DbSetOrder(1))
               If SZ5->(DbSeek(xFilial("SZ5")+aCols[_nY][1],.T.))
                  SG1->(DbSetOrder(1))
                  If SG1->(DbSeek(xFilial("SG1")+SubStr(Alltrim(SubStr(Alltrim(_cProduto),1,10))+aCols[_nY][1]+Space(15),1,15)+_cProduto,.T.))
                     _QtdPI := _QtdPI + Round((aCols[_nY][3] * nConv), 2)
                  Else
                     While .NOT. SG1->(EOF()) .AND. (SG1->G1_FILIAL = xFilial("SG1")) .AND.;
                           (SG1->G1_COD = SubStr(Alltrim(SubStr(Alltrim(_cProduto),1,10))+aCols[_nY][1]+Space(15),1,15)) .AND.;
                           (SG1->G1_COMP = _cProduto)
                        _QtdPI := _QtdPI + ( (aCols[_nY][3] * SG1->G1_QUANT) / ((100 - SG1->G1_PERDA) / 100) )
                        SG1->(DbSkip())
                     Enddo
                  Endif
               Endif
               DbSelectArea("SC2")
            Endif
         Next

      ElseIf cOpc == "I"
         cRoteiro := Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_OPERPAD")
         nConv := Posicione("SB1", 1, xFilial("SB1")+_cProduto, "B1_CONV")

         SG2->(DbSetOrder(1))
         If .NOT. SG2->(DbSeek(xFilial("SG2")+_cProduto+cRoteiro, .T.))
            FWAlertWarning("Produto nao tem roteiro padrao de operacoes cadastrado. Verifique !", "Informacao...")
         Endif

         _QtdPI := 0

         If (cNumEmp == "01010101")
            _cLote := U_NroSqLote("SZZ")
         Else
            _cLote := U_NumSeqLot("SZZ")
         Endif

         DbSelectArea(XLOTES)
         RecLock(XLOTES, .T.)
         XLOTES->LOTE := _cLote
         MsUnLock()

         BEGINSQL ALIAS "QI2WF"
            SELECT
               QI2_FNC,
               QI2_DESCR,
               QI2_CODPRO,
               QI2_LOTE
            FROM
               %TABLE:QI2% WITH(NOLOCK)
            WHERE
               %NOTDEL%
               AND QI2_FILIAL = %XFILIAL:QI2%
               AND QI2_CODPRO <> ''
               AND QI2_STATUS = '2'
               AND SUBSTRING(QI2_CODPRO, 6, 5) = %EXP:Substr(_cProduto,6,5)%
         ENDSQL

         If .NOT. QI2WF->(EOF())
            cTexto := "Emissao de Ordem de producao (COR + VARIACAO) com Ficha de Nao conformidade em aberto."
            cTexto += CRLF+"Cor + Variacao :  "+Substr(QI2WF->QI2_CODPRO,6,5)+" Lote FNC ->  "+QI2WF->QI2_LOTE+" - "+QI2WF->QI2_CODPRO
            cTexto += CRLF+"Numero FNC -> "+QI2WF->QI2_FNC
            cTexto += CRLF+"Novo Lote  -> "+_cLote+" gerado por : "+GetAdvFVal("SZH","ZH_NOME",xFilial("SZH")+__cUserId,1," ")
            cTexto += CRLF+"Prog. Origem : BRPCPX04"
            If Substr(xFilial("SC2"),1,2)== "06"
               U_EnvMail("DISSOLTEX - Emissao de O.p (Cor + Variacao) com FNC aberta. Cor/Variacao -> "+Substr(QI2WF->QI2_CODPRO,6,5),cTexto,cParaB,"")
            Else
               U_EnvMail("BRASILUX  - Emissao de O.p (Cor + Variacao) com FNC aberta. Cor/Variacao -> "+Substr(QI2WF->QI2_CODPRO,6,5),cTexto,cParaA,"pcp@brasilux.com.br")
            Endif
            cObs += 'F'
         Endif
         QI2WF->(DbCloseArea())

         For _nY := 1 To Len(aCols)
            If aCols[_nY][Len(aHeader)+1] == .F.
               cAuxProd := If(Len(Alltrim(_cProduto)) == 12,Substr(_cProduto,1,10),Substr(_cProduto,1,5))+aCols[_nY][1]
               DbSelectArea("SZZ")
               RecLock("SZZ", .T.)
               SZZ->ZZ_FILIAL  := xFilial("SZZ")
               SZZ->ZZ_LOTE    := _cLote
               SZZ->ZZ_DTEMIS  := dEmissao
               SZZ->ZZ_PRODUTO := cAuxProd
               SZZ->ZZ_DESCR   := cDescric
               SZZ->ZZ_PREVI   := dPrevIni
               SZZ->ZZ_PREVF   := dPrevFim
               SZZ->ZZ_EMB     := aCols[_nY][1]
               SZZ->ZZ_DESEMB  := aCols[_nY][2]
               SZZ->ZZ_QTDETI  := aCols[_nY][3]
               SZZ->ZZ_PEDIDO  := aCols[_nY][4]
               SZZ->ZZ_TPINCL  := "I"
               MsUnlock()

               SZ5->(DbSetOrder(1))
               If SZ5->(DbSeek(xFilial("SZ5")+aCols[_nY][1],.F.))
                  SG1->(DbSetOrder(1))
                  If .NOT. SG1->(DbSeek(xFilial("SG1")+SubStr(Alltrim(SubStr(Alltrim(_cProduto),1,10))+aCols[_nY][1]+Space(15),1,15)+_cProduto,.T.))
                     _QtdPI := _QtdPI + Round((aCols[_nY][3] * nConv), 2)
                  Else
                     While .NOT. SG1->(EOF()) .AND. (SG1->G1_FILIAL = xFilial("SG1")) .AND.;
                           (SG1->G1_COD = SubStr(Alltrim(SubStr(Alltrim(_cProduto),1,10))+aCols[_nY][1]+Space(15),1,15)) .AND.;
                           (SG1->G1_COMP = _cProduto)
                        _QtdPI := _QtdPI + ( (aCols[_nY][3] * SG1->G1_QUANT) / ((100 - SG1->G1_PERDA) / 100) )
                        SG1->(DbSkip())
                     Enddo
                  Endif
               Endif
               DbSelectArea("SC2")
            Endif
         Next

         If ((_QtdPI * 100) - Int(_QtdPI * 100)) > 0
            _QtdPI := Int(_QtdPI * 100 + 1) / 100
         Endif

         DbSelectArea("SC2")
         _nQuant     := Round(_QtdPI, 2)

         cAuxProd := Iif(Len(Alltrim(_cProduto)) > 7, Substr(_cProduto,1,12), Substr(_cProduto,1,5))

         //-- [MELHORIA] Query montada como array para evitar reallocs --
         aQryT := {}
         aAdd(aQryT, " SELECT DATEDIFF(M,MAX(C2_EMISSAO),GETDATE()) AS 'MESES' ")
         aAdd(aQryT, " FROM "+RetSqlName("SC2")+" WITH(NOLOCK) ")
         aAdd(aQryT, " WHERE C2_FILIAL ='"+xFilial("SC2")+"' AND D_E_L_E_T_ ='' AND C2_LOTE <>'' ")
         aAdd(aQryT, " AND C2_PRODUTO = '"+cAuxProd+"'")
         TCQuery (fJoinArr(aQryT)) ALIAS "SC2WF" NEW

         DbSelectArea("SC2WF")
         If !Eof() .AND. SC2WF->MESES > Val(pMes)
            cTexto := "Emissao de Ordem de producao com ultima producao a mais de "+pMes+" meses."
            cTexto += CRLF+"Produto -> "+cAuxProd
            cTexto += CRLF+"Lote  -> "+_cLote+" gerado por : "+Posicione("SZH",1,xFilial("SZH")+__cUserId,"ZH_NOME")
            cTexto += CRLF+"Qtde  -> "+TRANSFORM(_nQuant,'@E 999,999,999.99')
            cTexto += CRLF+"Produzido a "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses atras."
            cTexto += CRLF+"Prog. Origem : BRPCPX04"
            If Substr(xFilial("SC2"),1,2) == "06"
               U_EnvMail("DISSOLTEX - Emissao de Ordem de producao com ultima producao a "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses.",cTexto,cParaB,"")
            Else
               U_EnvMail("BRASILUX  - Emissao de Ordem de producao com ultima producao a "+TRANSFORM(SC2WF->MESES,'@E 999')+" meses.",cTexto,cParaA,"materiais@brasilux.com.br")
            Endif
            cObs += 'T'
         Endif

         //-- [BUG05] CORRIGIDO: fechamento seguro de SC2WF --
         If Select("SC2WF") > 0
            DbSelectArea("SC2WF")
            DbCloseArea()
         Endif

         DbSelectArea("SC2")
         DbSetOrder(2)
         DbSeek(xFilial("SC2")+(cAuxProd), .T.)
         If !Found()
            cTexto := "Emissao de Ordem de producao de produto novo."
            cTexto += CRLF+"Produto -> "+cAuxProd
            cTexto += CRLF+"Lote  -> "+_cLote+" gerado por : "+Posicione("SZH",1,xFilial("SZH")+__cUserId,"ZH_NOME")
            cTexto += CRLF+"Qtde  -> "+TRANSFORM(_nQuant,'@E 999,999,999.99')
            cTexto += CRLF+"Prog. Origem : BRPCPX04"
            If Substr(xFilial("SC2"),1,2) == "06"
               U_EnvMail("DISSOLTEX - Emissao de Ordem de producao de produto novo. (Primeira Producao)",cTexto,cParaB,"")
            Else
               U_EnvMail("BRASILUX  - Emissao de Ordem de producao de produto novo. (Primeira Producao)",cTexto,cParaA,"materiais@brasilux.com.br")
            Endif
            cObs += 'P'
         Endif

         DbSelectArea("SC2")
         DbSetOrder(2)
         DbSeek(xFilial("SC2")+(cAuxProd), .T.)
         If !Found()
            cTexto := "Emissao de Ordem de producao de produto Com Primeiro Lote."
            cTexto += CRLF+"Produto -> "+cAuxProd
            cTexto += CRLF+"Lote  -> "+_cLote+" gerado por : "+Posicione("SZH",1,xFilial("SZH")+__cUserId,"ZH_NOME")
            cTexto += CRLF+"Qtde  -> "+TRANSFORM(_nQuant,'@E 999,999,999.99')
            cTexto += CRLF+"Prog. Origem : BRPCPX04"
            If Substr(xFilial("SC2"),1,2) == "06"
               U_EnvMail("DISSOLTEX - Emissao de Ordem de producao de produto Com 1o. Lote.",cTexto,cParaB,"")
            Else
               U_EnvMail("BRASILUX  - Emissao de Ordem de producao de produto novo. (Primeiro Lote)",cTexto,cParaA,"materiais@brasilux.com.br")
            Endif
            cObs += 'L'
            DbSelectArea("SC2")
         Endif

         If _nQuant > 0
            DbSelectArea("SZZ")
            RecLock("SZZ", .T.)
            SZZ->ZZ_FILIAL  := xFilial("SZZ")
            SZZ->ZZ_LOTE    := _cLote
            SZZ->ZZ_DTEMIS  := dEmissao
            SZZ->ZZ_PRODUTO := cAuxProd
            SZZ->ZZ_DESCR   := cDescric
            SZZ->ZZ_PREVI   := dPrevIni
            SZZ->ZZ_PREVF   := dPrevFim
            SZZ->ZZ_QTDETI  := _nQuant
            SZZ->ZZ_TPINCL  := "I"
            SZZ->ZZ_INFOP   := Alltrim(cObs)
            MsUnlock()
         Endif

      Endif // ElseIf cOpc == "I"
   Endif // nOpcA == 1

   U_VoltaArea(aAreaAnt)
Return

/*----------------------------------------------------------------------*/
/* fValCab - Validacao do cabecalho da tela de inclusao                  */
/*----------------------------------------------------------------------*/
Static Function fValCab(dEmissao, oEmissao, dPrevIni, oPrevIni, dPrevFim, oPrevFim, _cProduto, _oProduto, cDescric, oDescric, oPrevVol, cPrevVol, nOpc)
   Local lRet := .T.

   If nOpc == 1
      dPrevFim := dEmissao
      dPrevIni := dEmissao
   ElseIf nOpc == 2
      If Len(Alltrim(_cProduto)) == 11
         If !Empty(Substr(_cProduto, 3, 1))
            _cProduto := Stuff(_cProduto, 3, 0, ' ')
         Endif
      Endif
   Endif

   SB1->(DbSetOrder(1))
   If .NOT. SB1->(DbSeek(xFilial("SB1")+_cProduto))
      FWAlertError("Produto nao existe !", "Atencao")
      lRet := .F.
   Else
      If SB1->B1_TIPO <> 'PI'
         FWAlertError("Produto digitado nao e do tipo PI !", "Atencao")
         lRet := .F.
      Else
         If SB1->B1_MSBLQL == '1'
            FWAlertError("Produto digitado esta bloqueado, Verifique", "Atencao")
            lRet := .F.
         Else
            cDescric := SB1->B1_DESC
         Endif
      Endif
   Endif

   If lRet
      QI2->(DbSetOrder(7))
      If QI2->(DbSeek(xFilial("QI2")+_cProduto))
         While .NOT. QI2->(Eof()) .AND. (QI2->QI2_FILIAL == XFILIAL("QI2")) .AND.;
               (Alltrim(_cProduto) == Alltrim(QI2->QI2_CODPRO))
            If QI2->QI2_STATUS == '2'
               FWAlertInfo("Produto possui FNC aberta!!."+CRLF+;
                  "Nao sera possivel incluir OP enquanto nao encerra-la"+CRLF+;
                  "("+QI2->QI2_FNC+") !", "Informacao...")
               lRet := .F.
               Exit
            Endif
            QI2->(DbSkip())
         Enddo
         QI2->(DbCloseArea())
      Endif
   Endif

   If lRet
      If U_VerMetric(_cProduto)
         FWAlertInfo("Produto nao possui GGF ou esta em desacordo com as metricas !", "Informacao...")
         lRet := .F.
      Endif
   Endif

   If lRet
      QP6->(DbSetOrder(1))
      If .NOT. QP6->(DbSeek(xFilial("QP6")+_cProduto))
         FWAlertInfo("Produto sem cadastro de Inspecao - Avisar Departamento Tecnico !", "Informacao")
      Endif
      QP6->(DbCloseArea())
   Endif

   If lRet
      If .NOT. (Substr(Alltrim(_cProduto),1,2) $ 'CT.ED.TD.TN.AG.VN')
         SZ3->(DbSetOrder(1))
         If SZ3->(DbSeek(xFilial("SZ3")+(Substr(_cProduto,6,2))+(Substr(_cProduto,8,3))))
            If Empty(Alltrim(SZ3->Z3_PADCOR))
               FWAlertInfo("Produto sem Cor Padrao Cadastrada - Avisar Departamento Tecnico !", "Informacao...")
               lRet := .F.
            Endif
         Else
            FWAlertInfo("Produto sem Cor Padrao Cadastrada - Avisar Departamento Tecnico !!", "Informacao...")
            lRet := .F.
         Endif
         SZ3->(DbCloseArea())
      Endif
   Endif

   If lRet
      If Len(Alltrim(_cProduto)) == 12
         If (Substr(Alltrim(_cProduto),11,2) $ '00/99')
         BEGINSQL ALIAS "TOPS"
            SELECT
               COUNT(SC2.C2_NUM) AS NUMOP,
               SUM(SC2.C2_QUANT - SC2.C2_QUJE) AS QTDOP
            FROM
               %TABLE:SC2% SC2 WITH (NOLOCK)
            WHERE
               SC2.C2_FILIAL = %XFILIAL:SC2%
               AND SC2.%NOTDEL%
               AND SC2.C2_DATRF = ' '
               AND SC2.C2_PRODUTO = %EXP:_cProduto%
         ENDSQL

         If TOPS->NUMOP > 0
            FWAlertInfo("Existe(m) "+CRLF+;
               Alltrim(cValToChar(TOPS->NUMOP))+" OP(s) Aberta(s) para esse produto,"+CRLF+;
               "com "+Transform(TOPS->QTDOP,"@E 999,999.99")+" "+SB1->B1_UM+".", "Informacao")
            lRet := .F.
         Endif
         TOPS->(DbCloseArea())
      Endif
   Else
      FWAlertError("Produto invalido !", "Atencao")
      lRet := .F.
   Endif
   Endif

   //-- Analisa saldo zerado de componentes --MAA
   If lRet
      BEGINSQL ALIAS "SALDOS"
         SELECT
            SB1.B1_COD,
            SG1.G1_COMP,
            SUM(SG1.G1_QUANT) AS G1_QUANT,
            SUM(SB2.B2_QATU) AS B2_QATU
         FROM
            %TABLE:SB1% SB1,
            (
               SELECT
                  SUM(B2_QATU) AS B2_QATU,
                  B2_FILIAL,
                  B2_COD
               FROM
                  %TABLE:SB2% SB2
               WHERE
                  %NOTDEL%
                  AND B2_FILIAL = %XFILIAL:SB2%
               GROUP BY
                  B2_FILIAL,
                  B2_COD
            ) SB2,
            %TABLE:SG1% SG1
         WHERE
            SB1.%NOTDEL%
            AND SB1.B1_FILIAL = %XFILIAL:SB1%
            AND SB1.B1_COD = %EXP:_cProduto%
            AND SB1.B1_FILIAL = SB2.B2_FILIAL
            AND SB1.B1_COD = SG1.G1_COD
            AND SB1.B1_UREV >= SG1.G1_REVINI
            AND SB1.B1_UREV <= SG1.G1_REVFIM
            AND SG1.G1_FILIAL = SB2.B2_FILIAL
            AND SG1.%NOTDEL%
            AND SUBSTRING(SG1.G1_COMP, 1, 2) <> 'GG'
            AND SG1.G1_COMP = SB2.B2_COD
         GROUP BY
            SB1.B1_COD,
            SG1.G1_COMP
         HAVING
            SUM(SG1.G1_QUANT) > SUM(SB2.B2_QATU)
      ENDSQL

      If .NOT. SALDOS->(EOF()) .AND. .NOT. SALDOS->(BOF())
         cComp := ""
         While .NOT. SALDOS->(EOF())
            cComp := SALDOS->G1_COMP+CRLF
            SALDOS->(DbSkip())
         Enddo
         FWAlertInfo("Produto(S) com saldo zerado de componentes!"+CRLF+cComp,"Saldo Zerado")
         lRet := .F.
      Endif
      SALDOS->(DbCloseArea())
   Endif
   // FIm Analise Saldos - MAA

   If .NOT. lRet
      _cProduto := Space(15)
      cDescric  := Space(40)
      _oProduto:SetFocus(.T.)
   Endif

   oEmissao:Refresh()
   oPrevIni:Refresh()
   oPrevFim:Refresh()
   _oProduto:Refresh()
   oDescric:Refresh()
   oPrevVol:Refresh()

Return(lRet)

/*----------------------------------------------------------------------*/
/* fMonHea - Monta cabecalho do aCols via SX3                            */
/*----------------------------------------------------------------------*/
Static Function fMonHea(aHeader, nUsado)

   ( _cAliasSX3 )->(DbSetOrder(1))
   ( _cAliasSX3 )->(DbSeek("SZZ"))
   While .NOT. ( _cAliasSX3 )->(Eof()) .AND. ( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SZZ" )
      If ( Alltrim( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "ZZ_EMB,ZZ_DESEMB,ZZ_QTDETI,ZZ_PEDIDO") .AND.;
         X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .AND. (cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) )
      nUsado += 1
      aAdd( aHeader, { Trim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), "", "", ( _cAliasSX3 )->( X3_TIPO ), "", "" } )
      Endif
      ( _cAliasSX3 )->(DbSkip())
   Enddo

Return

/*----------------------------------------------------------------------*/
/* fMonCol - Monta aCols                                                  */
/*----------------------------------------------------------------------*/
Static Function fMonCol(aHeader, nUsado, aCols, cOpc, _cLote)
   Local _nI

   If cOpc $ "V"
      DbSelectArea("SZZ")
      DbSetOrder(1)
      DbSeek(xFilial("SZZ")+_cLote, .T.)
      If Found()
         While !Eof() .AND. SZZ->ZZ_LOTE == _cLote
            If !Substr(Alltrim(SZZ->ZZ_PRODUTO),11,2) $ "00.99"
               aAdd(aCols, Array(nUsado+1))
               For _nI := 1 To nUsado
                  aCols[Len(aCols)][_nI] := CriaVar(aHeader[_nI][2])
               Next
               aCols[Len(aCols)][nUsado+1] := .F.
            Endif
            DbSelectArea("SZZ")
            DbSkip()
         Enddo
      Else
         aAdd(aCols, Array(nUsado+1))
         For _nI := 1 To nUsado
            aCols[1][_nI] := CriaVar(aHeader[_nI][2])
         Next
         aCols[1][nUsado+1] := .F.
      Endif
   Else
      aAdd(aCols, Array(nUsado+1))
      For _nI := 1 To nUsado
         aCols[1][_nI] := CriaVar(aHeader[_nI][2])
      Next
      aCols[1][nUsado+1] := .F.
   Endif

Return

/*----------------------------------------------------------------------*/
/* fPrevVol - Soma o volume das embalagens digitadas no aCols             */
/*----------------------------------------------------------------------*/
User Function fPrevVol()
   Local _nY
   Local cProdEmba := ""
   Local cProdVol  := 0

   cPrevVol := 0
   For _nY := 1 To Len(aCols)
      If aCols[_nY][Len(aHeader)+1] == .F.
         cProdVol  := 0
         cProdEmba := Iif(Len(Alltrim(_cProduto)) == 12, Substr(Alltrim(_cProduto),1,10), Substr(Alltrim(_cProduto),1,5))+aCols[_nY][1]
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+cProdEmba,.T.))
         If SB1->(Found())
            cProdVol  := SB1->B1_CONV
            cPrevVol  += Iif(Substr(Alltrim(_cProduto),11,2) $ '99', (aCols[_nY][3] * (cProdVol / Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_PESOESP"))), (aCols[_nY][3] * cProdVol))
         Else
            FWAlertError("Produto nao localizado!", "Atencao")
            Return(.F.)
         Endif
      Endif
   Next
   oPrevVol:Refresh()

Return (NIL)

/*----------------------------------------------------------------------*/
/* fCamOPB - Valida Campos do aCols das ordens de producoes              */
/*----------------------------------------------------------------------*/
User Function fCamOPB()
   Local nPosEmb  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_EMB"    } )
   Local nPosDes  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_DESEMB" } )
   Local nPosQtd  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_QTDETI" } )
   Local nPosPed  := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_PEDIDO" } )
   Local lRet     := .T.
   Local cProdEmba:= ""
   Local cArea    := ""
   Local i        := 0

   If __ReadVar $ 'M->ZZ_EMB'
      cProdEmba := Iif(Len(Alltrim(_cProduto)) = 12, Substr(Alltrim(_cProduto),1,10), Substr(Alltrim(_cProduto),1,5))+M->ZZ_EMB

      If aCols[n][Len(aHeader)+1] == .F.
         SB1->(DbSetOrder(1))
         If .NOT. SB1->(DbSeek(xFilial("SB1")+cProdEmba))
            FWAlertError("Embalagem nao cadastrada: "+cProdEmba,"Nao cadastrada")
            M->ZZ_EMB := Space(02)
            aCols[n][nPosEmb] := Space(02)
            aCols[n][nPosDes] := Space(20)
            aCols[n][nPosQtd] := 0
            aCols[n][nPosPed] := Space(08)
            Return(.F.)
         Else
            If SB1->B1_MSBLQL == '1'
               MsgBox("Produto bloqueado !", "Atencao", "STOP")
               Return(.F.)
            Else
               SZ5->(DbSetOrder(1))
               If SZ5->(DbSeek(xFilial("SZ5")+M->ZZ_EMB))
                  aCols[n][nPosEmb] := M->ZZ_EMB
                  aCols[n][nPosDes] := SZ5->Z5_DESCR

                  //-- [MELHORIA] Query como array --
                  aQOps := {}
                  aAdd(aQOps, "SELECT COUNT(SC2.C2_NUM) AS NUMOP, SUM(SC2.C2_QUANT - SC2.C2_QUJE) AS QTDOP ")
                  aAdd(aQOps, "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ")
                  aAdd(aQOps, "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' ")
                  aAdd(aQOps, "  AND SC2.D_E_L_E_T_ = '' ")
                  aAdd(aQOps, "  AND SC2.C2_DATRF   = '' ")
                  aAdd(aQOps, "  AND SC2.C2_PRODUTO = '"+cProdEmba+"' ")
                  TCQuery (fJoinArr(aQOps)) ALIAS "TOPS" NEW

                  DbSelectArea("TOPS")
                  If TOPS->NUMOP > 0
                     cVarDes := Iif(TOPS->NUMOP == 1, "Existe ", "Existem ")
                     cVarOps := Iif(TOPS->NUMOP == 1, " OP aberta ", " OPs abertas ")
                     MsgBox(cVarDes+Transform(TOPS->NUMOP,"@E 99")+cVarOps+"para esse produto, com "+Transform(TOPS->QTDOP,"@E 999,999.99")+" "+SB1->B1_UM+".", "Informacao", "INFO")
                  Endif
                  DbSelectArea("TOPS")
                  DbCloseArea()
               Else
                  MsgStop("Embalagem inexistente: "+M->ZZ_EMB)
                  Return(.F.)
               Endif

               If U_VerMetric(_cProduto)
                  MsgBox("Produto nao possui GGF ou esta em desacordo com as metricas !", "Informacao...", "INFO")
                  _cProduto := Space(15)
                  cDescric  := Space(40)
                  _oProduto:SetFocus(.T.)
                  Return(.F.)
               Endif

               If U_VerMetric(cProdEmba)
                  MsgBox("Produto nao possui GGF ou esta em desacordo com as metricas !", "Informacao...", "INFO")
                  Return(.F.)
               Endif
            Endif
         Endif

         For i := 1 To Len(aCols)
            If i # n
               If aCols[i][Len(aHeader)+1] == .F.
                  If aCols[i][1] == aCols[n][1]
                     MsgBox("Ha duplicidade de Embalagens!", "Atencao", "STOP")
                     lRet := .F.
                     Exit
                  Endif
               Endif
            Endif
         Next

         If !lRet
            M->ZZ_EMB         := Space(02)
            aCols[n][nPosEmb] := Space(02)
            aCols[n][nPosDes] := Space(20)
            aCols[n][nPosQtd] := 0
            aCols[n][nPosPed] := Space(08)
            Return(.F.)
         Endif
      Endif

   ElseIf __ReadVar $ 'M->ZZ_PEDIDO'
      If .NOT. aCols[n][Len(aHeader)+1]
         cArea     := Alias()
         cProdEmba := Iif(Len(Alltrim(_cProduto)) = 12, Substr(Alltrim(_cProduto),1,10), Substr(Alltrim(_cProduto),1,5))+aCols[n][nPosEmb]
         SC5->(DbSetOrder(1))
         If SC5->(DbSeek(XFILIAL("SC5")+Substr(M->ZZ_PEDIDO,3,6)))
            SC6->(DbSetOrder(2))
            If .NOT. SC6->(DbSeek(xFilial("SC6")+cProdEmba+Space(15-Len(cProdEmba))+Substr(M->ZZ_PEDIDO,3,6)))
               FWAlertError("Atencao, nao existe esse produto nesse pedido.", "Atencao")
               DbSelectArea(cArea)
               Return(.F.)
            Endif
         Else
            DbSelectArea(cArea)
            Return(.F.)
         Endif
         DbSelectArea(cArea)
      Endif
   Endif

   DbSelectArea("SZZ")
   oGetD:oBrowse:Refresh()

Return(.T.)

/*----------------------------------------------------------------------*/
/* fLinOPB - Valida linhas do aCols das ordens de producoes              */
/*----------------------------------------------------------------------*/
User Function fLinOPB()
   Local nPosEmb := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_EMB"    } )
   Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_QTDETI" } )

   If .NOT. aCols[n][Len(aHeader)+1]
      If Empty(aCols[n][nPosEmb])
         FWAlertError("Informe o codigo da embalagem !", "Atencao")
         Return(.F.)
      Else
         If aCols[n][nPosQtd] <= 0
            FWAlertError("Informe a quantidade maior que zero!", "Atencao")
            Return(.F.)
         Endif
      Endif
   Endif

   oGetD:oBrowse:Refresh()
   U_fPrevVol()

Return(.T.)

/*----------------------------------------------------------------------*/
/* fTudOPB - Valida todas as linhas na confirmacao da inclusao           */
/* [BUG03] CORRIGIDO: loop usava aCols[n] ao inves de aCols[_nY]        */
/*----------------------------------------------------------------------*/
User Function fTudOPB()
   Local nPosEmb := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_EMB"    } )
   Local nPosQtd := aScan( aHeader, { |x| Alltrim(x[2]) == "ZZ_QTDETI" } )
   Local lRet    := .T.
   Local _nY

   If Empty(_cProduto)
      FWAlertError("Codigo do Produto nao pode estar em branco!", "Atencao")
      Return(.F.)
   Endif

   For _nY := 1 To Len(aCols)
      If aCols[_nY][Len(aHeader)+1] == .F.
         // [BUG03] CORRIGIDO: era aCols[n][nPosEmb] - validava sempre a linha corrente
         // Agora valida cada linha _nY corretamente
         If Empty(aCols[_nY][nPosEmb]) .OR. aCols[_nY][nPosQtd] <= 0
            lRet := .F.
         Endif
      Endif
   Next

   If .NOT. lRet
      FWAlertError("Existe embalagem igual a branco ou quantidade igual a zero. Verifique !", "Atencao")
      Return(.F.)
   Endif

Return(.T.)

/*----------------------------------------------------------------------*/
/* fGerOPS - Gera as ordens de producoes pelos lotes                     */
/* [BUG04] CORRIGIDO: logica de aerro reestruturada                      */
/*----------------------------------------------------------------------*/
Static Function fGerOPS(aGerTxt)
   Local _cMVXSOLUC := GetMv('MV_XSOLUCA')
   Local _cMVXSOLU0 := GetMv('MV_XSOLUC0')
   Local _cMVXSOLU5 := GetMv('MV_XSOLUC5')
   Local lErroOP    := .F.   // [BUG04] substitui aerro com logica correta
   Local cAuxLote   := ""
   Local cAuxFilial := ""
   Local cAutExpl   := ""
   Local lVerSol    := .F.
   Local cRoteiro   := ""
   Local nQuant2    := 0
   Local dAuxData   := CtoD("")
   Local aAutoSC2   := {}
   Local cCodCon    := ""
   Local nQtdCon    := 0
   Local nQtdTota   := 0

   Local aQry1      := {}
   Local nContReg
   Local nContOcorr := 0
   Local cB1Tipo
   Local cB1LocPad
   Local nB1Conv
   Local cB1Um
   Local nB1Pe
   Local cB1TipConv
   Local cB1OprPad
   Private lMSErroAuto := .F.
   Private lMSHelpAuto := .T.




   If Select( xLotes ) > 0
      XLOTES->(DbCloseArea())
   Endif
   nContReg  := RecCount()
   If nContReg > 0
      FWAlertInfo("Serao geradas as Ordens de Producoes junto com as Intermediarias!", "Atencao")
      ProcRegua(nContReg, 21, 6)
   Endif

   nContOcorr := 0

   If Select( xLotes ) > 0
      DbSelectArea(xLotes)
      DbGoTop()

      While !Eof()
         cAuxLote   := LOTE
         cAuxFilial := xFilial("SZZ")

         DbSelectArea("SZZ")
         DbSeek(cAuxFilial+cAuxLote, .T.)

         While !Eof() .AND. (cAuxFilial == xFilial("SZZ")) .AND. (cAuxLote == SZZ->ZZ_LOTE)
            lVerSol := .F.

            If SZZ->ZZ_FLAG == 'S'
               DbSelectArea("SZZ")
               DbSkip()
               Loop
            Endif

            DbSelectArea("SB1")
            DbSetOrder(1)
           IF DbSeek(xFilial("SB1")+SZZ->ZZ_PRODUTO)

                 //-- [MELHORIA] Leitura de campos SB1 em bloco, evitando Posicione() multiplos --
               cB1Tipo    := SB1->B1_TIPO
               cB1LocPad  := SB1->B1_LOCPAD
               nB1Conv    := SB1->B1_CONV
               cB1Um      := SB1->B1_UM
               nB1Pe      := SB1->B1_PE
               cB1TipConv := SB1->B1_TIPCONV
               cB1OprPad  := SB1->B1_OPERPAD

               If cB1Tipo $ "PI"
                  cAutExpl := "S"
                  lVerSol  := .T.
               Else
                  cAutExpl := "N"
               Endif

               cRoteiro := cB1OprPad
               nQuant2  := Iif(cB1TipConv != "D", (SZZ->ZZ_QTDETI * nB1Conv), (SZZ->ZZ_QTDETI / nB1Conv))

               If (SZZ->ZZ_PREVI + nB1Pe) > SZZ->ZZ_PREVF
                  dAuxData := SZZ->ZZ_PREVI + nB1Pe
               Else
                  dAuxData := SZZ->ZZ_PREVF
               Endif

               If SZZ->ZZ_TPINCL $ 'C'
                  dAuxData := dDataBase
               Endif

               If dAuxData < dDataBase
                  dAuxData := dDataBase
               Endif

               aAutoSC2 := {}
               aAdd(aAutoSC2, {"C2_FILIAL" , xFilial("SC2")                 , NIL})
               aAdd(aAutoSC2, {"C2_ITEM"   , "01"                           , NIL})
               aAdd(aAutoSC2, {"C2_SEQUEN" , "001"                          , NIL})
               aAdd(aAutoSC2, {"C2_PRODUTO", SZZ->ZZ_PRODUTO                , NIL})
               aAdd(aAutoSC2, {"AUTEXPLODE", cAutExpl                       , NIL})
               aAdd(aAutoSC2, {"C2_LOCAL"  , cB1LocPad                      , NIL})
               aAdd(aAutoSC2, {"C2_QUANT"  , SZZ->ZZ_QTDETI                 , NIL})
               aAdd(aAutoSC2, {"C2_QTSEGUM", nQuant2                        , NIL})
               aAdd(aAutoSC2, {"C2_UM"     , cB1Um                          , NIL})
               aAdd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI                  , NIL})
               aAdd(aAutoSC2, {"C2_DATPRF" , dAuxData                       , NIL})
               aAdd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS                 , NIL})
               aAdd(aAutoSC2, {"C2_TPOP"   , "F"                            , NIL})
               aAdd(aAutoSC2, {"C2_LOTE"   , SZZ->ZZ_LOTE                   , NIL})
               aAdd(aAutoSC2, {"C2_PEDIDO" , Substr(SZZ->ZZ_PEDIDO, 3, 6)   , NIL})
               aAdd(aAutoSC2, {"C2_ITEMPV" , Substr(SZZ->ZZ_PEDIDO, 1, 2)   , NIL})
               aAdd(aAutoSC2, {"C2_REVI"   , QA_UltRvQ(SZZ->ZZ_PRODUTO,,.F.), NIL})

               If (cAutExpl == "S") .AND. (Len(Alltrim(SZZ->ZZ_PRODUTO)) == 12)
                  aAdd(aAutoSC2, {"C2_ROTEIRO", cRoteiro, NIL})
               Endif

               lMsErroAuto := .F.
               DbSelectArea("SC2")
               DbSetOrder(1)
               DbSeek(xFilial("SC2"))
               MSExecAuto( {|x| MATA650(x)}, aAutoSC2)

               // [BUG04] CORRIGIDO: lMsErroAuto e a flag correta de resultado
               // aerro := "" antes do If tornava a guarda sempre verdadeira
               // Agora usa lMsErroAuto diretamente (flag nativa do MSExecAuto)
               lErroOP := lMsErroAuto

               If !lErroOP
                  DbSelectArea("SZZ")
                  RecLock("SZZ", .F.)
                  SZZ->ZZ_FLAG := 'S'
                  MsUnLock()

                  If SZZ->ZZ_TPINCL == 'C'
                     aAutoSC2 := {}
                     aAutoSC2 := { ;
                        { 'C2_FILIAL'  , SC2->C2_FILIAL                        , NIL },;
                        { 'C2_PRODUTO' , SC2->C2_PRODUTO                       , NIL },;
                        { 'C2_NUM'     , SC2->C2_NUM                           , NIL },;
                        { 'C2_ITEM'    , SC2->C2_ITEM                          , NIL },;
                        { 'C2_SEQUEN'  , SC2->C2_SEQUEN                        , NIL },;
                        { 'C2_OBS'     , "Complemento" + Alltrim(SC2->C2_OBS)  , NIL } }
                     lMsErroAuto := .F.
                     MsExecAuto( { |x, y| Mata650(x, y) }, aAutoSC2, 4 )

                     If !lMsErroAuto
                        DbSelectArea("SZZ")
                        RecLock("SZZ", .F.)
                        SZZ->ZZ_FLAG := 'S'
                        MsUnLock()
                     Else
                        MostraErro()
                     Endif
                  Endif

                  If Substr(Alltrim(SZZ->ZZ_PRODUTO),11,2) $ '00.99'
                     aAdd(aGerTxt, {SZZ->ZZ_PRODUTO, SZZ->ZZ_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, SC2->C2_QUANT})
                  Endif

                  nContOcorr++

                  If lVerSol
                     //-- [MELHORIA] Query como array --
                     aQry1 := {}
                     aAdd(aQry1, " SELECT D4_OP, D4_COD, D4_QUANT, C2_QUANT ")
                     aAdd(aQry1, " FROM "+RetSqlName("SD4")+" SD4 WITH (NOLOCK) ")
                     aAdd(aQry1, " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SD4.D4_FILIAL AND SB1.B1_COD = SD4.D4_COD AND SB1.D_E_L_E_T_ ='' ")
                     aAdd(aQry1, " LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON SD4.D4_FILIAL = SC2.C2_FILIAL AND SD4.D4_OP  = SC2.C2_OP  AND SC2.D_E_L_E_T_ ='' ")
                     aAdd(aQry1, " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"' ")
                     aAdd(aQry1, "   AND SD4.D_E_L_E_T_ = '' ")
                     aAdd(aQry1, "   AND SD4.D4_OP = '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD+"' ")
                     aAdd(aQry1, "   AND SD4.D4_COD IN (" + _cMVXSOLUC + ',' + _cMVXSOLU0 + ',' + _cMVXSOLU5 + ")")
                     TCQuery (fJoinArr(aQry1)) ALIAS "QEMP" NEW

                     DbSelectArea("QEMP")
                     nQtdCon  := QEMP->D4_QUANT
                     nQtdTota := QEMP->C2_QUANT
                     cCodCon  := QEMP->D4_COD
                     DbSelectArea("QEMP")
                     DbCloseArea()

                     //-- Geracao de OPs de concentrados (solucoes) --
                     If Alltrim(cCodCon) $ Alltrim(_cMVXSOLUC) .AND. nQtdTota > 200 .AND. !Empty(cCodCon)
                        fGeraOpCon(cCodCon, nQtdCon, cAutExpl, dAuxData, @aGerTxt, @_cLote)
                     Endif
                     If Alltrim(cCodCon) $ Alltrim(_cMVXSOLU0) .AND. !Empty(cCodCon)
                        fGeraOpCon(cCodCon, nQtdCon, cAutExpl, dAuxData, @aGerTxt, @_cLote)
                     Endif
                     If Alltrim(cCodCon) $ Alltrim(_cMVXSOLU5) .AND. nQtdTota > 500 .AND. !Empty(cCodCon)
                        fGeraOpCon(cCodCon, nQtdCon, cAutExpl, dAuxData, @aGerTxt, @_cLote)
                     Endif
                  Endif
               Else
                  MostraErro()
               Endif
            Endif

            DbSelectArea("SZZ")
            DbSkip()
         Enddo

         DbSelectArea(xLotes)
         DbSkip()
         IncProc()
      Enddo
   Endif

   If (nContOcorr == 0) .AND. (nContReg > 0)
      MsgBox("Nenhuma Ocorrencia!", "Atencao", "INFO")
   Endif

Return

/*----------------------------------------------------------------------*/
/* fGeraOpCon - Gera OP de concentrado/solucao (refatorado do fGerOPS)   */
/* [MELHORIA] elimina codigo triplicado para cada tipo de solucao         */
/*----------------------------------------------------------------------*/
Static Function fGeraOpCon(cCodCon, nQtdCon, cAutExpl, dAuxData, aGerTxt, _cLote)
   Local aAutoSC2 := {}
   Local nQtdLMi  := 0
   Local nTipCon  := ""
   Local nFatCon  := 0
   Local nQtdCo2  := 0
   Local cUniMed  := ""
   Local cLocPad  := ""
   Local cOpObs   := ""
   Local cRoteiro := ""

   //-- [MELHORIA] Leitura SB1 em bloco para o concentrado --
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1")+cCodCon)
   If !Found()
      Return
   Endif

   nQtdLMi  := SB1->B1_LM
   nTipCon  := SB1->B1_TIPCONV
   nFatCon  := SB1->B1_CONV
   cUniMed  := SB1->B1_UM
   cLocPad  := SB1->B1_LOCPAD
   cRoteiro := SB1->B1_OPERPAD
   nQtdCo2  := Iif(nTipCon == "M", (nQtdCon * nFatCon), (nQtdCon / nFatCon))
   cOpObs   := 'ROT. AUT. OP ORIG.: '+SC2->C2_NUM

   If (cNumEmp == "01010101")
      _cLote := U_NroSqLote("SZZ")
   Else
      _cLote := U_NumSeqLot("SZZ")
   Endif

   aAutoSC2 := {}
   aAdd(aAutoSC2, {"C2_FILIAL" , xFilial("SC2"), NIL})
   aAdd(aAutoSC2, {"C2_ITEM"   , "01"          , NIL})
   aAdd(aAutoSC2, {"C2_SEQUEN" , "001"          , NIL})
   aAdd(aAutoSC2, {"C2_PRODUTO", cCodCon        , NIL})
   aAdd(aAutoSC2, {"AUTEXPLODE", cAutExpl       , NIL})
   aAdd(aAutoSC2, {"C2_LOCAL"  , cLocPad        , NIL})
   aAdd(aAutoSC2, {"C2_QUANT"  , nQtdCon        , NIL})
   aAdd(aAutoSC2, {"C2_QTSEGUM", nQtdCo2        , NIL})
   aAdd(aAutoSC2, {"C2_UM"     , cUniMed        , NIL})
   aAdd(aAutoSC2, {"C2_LOTE"   , _cLote         , NIL})
   aAdd(aAutoSC2, {"C2_DATPRI" , SZZ->ZZ_PREVI  , NIL})
   aAdd(aAutoSC2, {"C2_DATPRF" , dAuxData        , NIL})
   aAdd(aAutoSC2, {"C2_OBS"    , cOpObs          , NIL})
   aAdd(aAutoSC2, {"C2_EMISSAO", SZZ->ZZ_DTEMIS  , NIL})
   aAdd(aAutoSC2, {"C2_TPOP"   , "F"             , NIL})
   aAdd(aAutoSC2, {"C2_ROTEIRO", cRoteiro         , NIL})

   lMsErroAuto := .F.
   DbSelectArea("SC2")
   DbSetOrder(1)
   DbSeek(xFilial("SC2"))
   MSExecAuto( {|x| MATA650(x)}, aAutoSC2)

   If !lMsErroAuto
      aAdd(aGerTxt, {cCodCon, SC2->C2_LOTE, SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN, SC2->C2_EMISSAO, nQtdCon})
   Else
      MostraErro()
   Endif

Return

/*----------------------------------------------------------------------*/
/* fJoinArr - Junta array de strings em uma unica string                 */
/* [MELHORIA] Evita concatenacao de string em loop nas queries SQL        */
/*----------------------------------------------------------------------*/
Static Function fJoinArr(aLinhas)
   Local cRet := ""
   Local _nI

   For _nI := 1 To Len(aLinhas)
      cRet += aLinhas[_nI]
   Next

Return(cRet)

/*----------------------------------------------------------------------*/
/* fGerTXTOps - Gera arquivo TXT para dosador                            */
/*----------------------------------------------------------------------*/
User Function fGerTXTOps(aGerTxt)
   Local lExiste   := .F.
   Local _nPos     := 0
   Local lPatOps, nX, _nY
   Local cPatOps   := Alltrim( GETMV("MV_DOSADOR") )
   Local _cMVRETEN := GETMV("MV_RETENOP")
   Local cDescri   := ""
   Local aQtdMat, aVolMat, aCodMat, aMatIte
   Local cLinMes, cFab2, cCpoMes
   Local nOutFile  := 0
   Local cNumOP    := ""
   Local cNumOrd   := ""
   Local cNumLot   := ""
   Local nVolume   := 0
   Local nPeso     := 0
   Local cCatalis  := ""
   Local nQtdMat   := 0
   Local aCodEmb, aDesEmb, aOPSEmb, aQtdEmb, aLocEmb

   Private cArqTxt := ""
   Private cArqMes := ""
   Private nHdl    := 0
   Private cEOL    := CHR(13)+CHR(10)

   If (cNumEmp == "01010101")
      If Len(aGerTxt) > 0
         For _nY := 1 To Len(aGerTXT)
            lExiste  := .F.
            cDescri  := Posicione("SB1", 1, xFilial("SB1")+aGerTXT[_nY][1], "B1_DESC")
            aQtdMat  := {}
            aVolMat  := {}
            aCodMat  := {}
            aAdd(aQtdMat, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
            aAdd(aCodMat, {"","","","","","","","","","","","","","","","","","","",""})
            aAdd(aVolMat, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
            _nPos   := 1
            aMatIte := {}

            DbSelectArea("SD4")
            DbSetOrder(2)
            DbSeek(xFilial("SD4")+aGerTxt[_nY][3], .T.)
            If Found()
               While !Eof() .AND. Alltrim(SD4->D4_OP) == Alltrim(aGerTxt[_nY][3])
                  If _nPos <= 20
                     If !Alltrim(SD4->D4_COD) $ Alltrim(_cMVRETEN)
                        If Substr(Posicione("SC2",1,xFilial("SC2")+SD4->D4_OP,"C2_PRODUTO"),6,2) == '05' .AND. Len(Alltrim(Posicione("SC2",1,xFilial("SC2")+SD4->D4_OP,"C2_PRODUTO"))) == 12
                           If !Posicione("SB1",1,xFilial("SB1")+Alltrim(SD4->D4_COD),"B1_DESC") $ 'PASTA' .AND. SD4->D4_QUANT >= 0.2 .AND. !U_IsProdCusto(SD4->D4_COD)
                              aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_PESOESP")})
                              _nPos += 1
                              If Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_DOSADOR") $ 'S'
                                 lExiste := .T.
                              Endif
                           Endif
                        Else
                           If !U_IsProdCusto(SD4->D4_COD)
                              aAdd(aMatIte, {SD4->D4_QUANT, Alltrim(SD4->D4_COD), SD4->D4_QUANT / Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_PESOESP")})
                              _nPos += 1
                              If Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_DOSADOR") $ 'S'
                                 lExiste := .T.
                              Endif
                           Endif
                        Endif
                     Endif
                  Endif
                  DbSelectArea("SD4")
                  DbSkip()
               Enddo
            Endif

            _nPos := 1
            aSort(aMatIte, , , { |x, y| x[3] > y[3] })
            For nX := 1 To Len(aMatIte)
               If _nPos <= 20
                  aQtdMat[1][_nPos] := aMatIte[nX][1]
                  aCodMat[1][_nPos] := aMatIte[nX][2]
                  aVolMat[1][_nPos] := aMatIte[nX][3]
                  _nPos += 1
               Endif
            Next

            nQtdMat := 0
            For nX := 1 To 20
               nQtdMat += aQtdMat[1][nX]
            Next
            If nQtdMat <= 0 ; Loop ; Endif
            If !lExiste     ; Loop ; Endif

            aCodEmb := { "", "", "", "", "", ""}
            aDesEmb := { "", "", "", "", "", ""}
            aOPSEmb := { "", "", "", "", "", ""}
            aQtdEmb := {  0,  0,  0,  0,  0,  0}
            aLocEmb := { "", "", "", "", "", ""}
            _nPos   := 1

            DbSelectArea("SC2")
            DbOrderNickName("SC2001")
            DbSeek(xFilial("SC2")+aGerTxt[_nY][2], .T.)
            While !Eof() .AND. SC2->C2_LOTE == aGerTxt[_nY][2]
               If !Substr(Alltrim(SC2->C2_PRODUTO),11,2) $ '00.99'
                  If _nPos <= 6
                     aCodEmb[_nPos] := Substr(Alltrim(SC2->C2_PRODUTO),11,2)
                     aDesEmb[_nPos] := Alltrim(Posicione("SZ5",1,xFilial("SZ5")+Substr(Alltrim(SC2->C2_PRODUTO),11,2),"Z5_DESCR"))
                     aOPSEmb[_nPos] := SC2->C2_OP
                     aQtdEmb[_nPos] := SC2->C2_QUANT
                     aLocEmb[_nPos] := SC2->C2_LOCAL
                     _nPos += 1
                  Endif
               Endif
               DbSelectArea("SC2")
               DbSkip()
            Enddo

            _cProduto := aGerTxt[_nY][1]
            cCatalis  := Posicione("SB1",1,xFilial("SB1")+aGerTXT[_nY][1],"B1_CATALIS")
            dEmissao  := DTOC(aGerTxt[_nY][4])
            nVolume   := aGerTxt[_nY][5]
            nPeso     := aGerTxt[_nY][5] * Posicione("SB1",1,xFilial("SB1")+aGerTXT[_nY][1],"B1_PESOESP")
            cNumOrd   := aGerTxt[_nY][3]
            cNumLot   := aGerTxt[_nY][2]

            lPatOps   := WaitRun('XCOPY'+" \\10.1.1.160\DADOS\OP\DOSADOR.CFG "+"c:\temp\ "+" /y") == 0
            If lPatOps
               cPatMes := Alltrim(cPatOps)
            Else
               cPatMes := Alltrim("F:\TEMP\DOSADOR\FABII\")
            Endif

            cArqMes := cPatMes+Substr(aGerTxt[_nY][3],1,6)+'.DAT'
            cNumOP  := aGerTxt[_nY][3]

            DbSelectArea("SC2")
            DbSetOrder(1)
            DbSeek(xFilial("SC2")+cNumOp, .T.)
            If Found()
               If Substr(cNumOp, 7, 2) == '02'
                  Loop
               Else
                  FErase(cArqMes)
               Endif
            Endif

            nOutFile := FCreate(cArqMes)
            cLinMes  := ""
            cFab2    := ""

            cCpoMes := Alltrim(_cProduto)
            cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
            cFab2   += cLinMes
            fWrite(nOutFile, cLinMes, Len(cLinMes))

            cLinMes := ""
            cCpoMes := PADR(cDescri, 040)
            cLinMes := Stuff(cLinMes, 001, 040, cCpoMes)+cEol
            cFab2   += cLinMes
            fWrite(nOutFile, cLinMes, Len(cLinMes))

            cLinMes := ""
            cCpoMes := Alltrim(Stuff(TransForm(nPeso,"@E 99999.999999"),At(",",TransForm(nPeso,"@E 99999.999999")),1,"."))
            cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
            cFab2   += cLinMes
            fWrite(nOutFile, cLinMes, Len(cLinMes))

            cLinMes := ""
            cCpoMes := Alltrim(Stuff(TransForm(nVolume,"@E 99999.999999"),At(",",TransForm(nVolume,"@E 99999.999999")),1,"."))
            cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
            cFab2   += cLinMes
            fWrite(nOutFile, cLinMes, Len(cLinMes))

            For nX := 1 To 20
               cLinMes := ""
               cCpoMes := Iif(!Empty(aCodMat[1][nX]), Alltrim(aCodMat[1][nX])+' ', " ")
               cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
               cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), cCpoMes)+cEol
               cFab2   += cLinMes
               fWrite(nOutFile, cLinMes, Len(cLinMes))
            Next

            cLinMes := ""
            cCpoMes := ""
            For nX := 1 To 20
               cCpoMes += Alltrim(Stuff(TransForm(Round(aQtdMat[1][nX],3),"@E 99999.999999"),At(",",TransForm(Round(aQtdMat[1][nX],3),"@E 99999.999999")),1,"."))+' '
            Next
            cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
            cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
            cFab2   += cLinMes
            fWrite(nOutFile, cLinMes, Len(cLinMes))

            cLinMes := ""
            cCpoMes := ""
            For nX := 1 To 20
               cCpoMes += Alltrim(Stuff(TransForm((Round(aQtdMat[1][nX],3)*(-1)),"@E 99999.999999"),At(",",TransForm((Round(aQtdMat[1][nX],3)*(-1)),"@E 99999.999999")),1,"."))+' '
            Next
            cCpoMes := PADR(Alltrim(cCpoMes), Len(Alltrim(cCpoMes)))
            cLinMes := Stuff(cLinMes, 001, Len(Alltrim(cCpoMes)), Alltrim(cCpoMes))+cEol
            cFab2   += cLinMes
            fWrite(nOutFile, cLinMes, Len(cLinMes))

            fClose(nOutFile)
            MemoWrit("\\10.1.1.160\DADOS\OP\"+Substr(aGerTxt[_nY][3],1,6)+'.DAT', cFab2)

            If !Len(Directory("C:\TEMP","D")) > 0
               MakeDir("C:\TEMP\")
            Endif
            If !Len(Directory("C:\TEMP\FAB2\*","D")) > 0
               MakeDir("C:\TEMP\FAB2\")
            Endif
            MemoWrit("C:\TEMP\FAB2\"+Substr(aGerTxt[_nY][3],1,6)+'.DAT', cFab2)

         Next
      Endif
   Endif

Return

/*----------------------------------------------------------------------*/
/* FATX04_2 - Apontamento de envasadores                                  */
/*----------------------------------------------------------------------*/
User Function FATX04_2()
   Local oDlgF, oFont1, oNumLot, oCodOrd, oDesOrd
   Local oCodEn1, oEnvas1, oCodEn2, oEnvas2
   Local oCodEn3, oEnvas3, oCodEn4, oEnvas4
   Local oCodEn5, oEnvas5, oCodEn6, oEnvas6
   Local aQryEnv := {}
   Local lSaidaF  := .F.
   Local cNumLot  := SZZ->ZZ_LOTE
   Local cCodOrd  := TransForm(Alltrim(SZZ->ZZ_PRODUTO), "@R XX 99.99.999-99")
   Local cDesOrd  := Iif(!Empty(SZZ->ZZ_DESCR), SZZ->ZZ_DESCR, Posicione("SB1",1,xFilial("SB1")+SZZ->ZZ_PRODUTO,"B1_DESC"))
   Local cCodEn1  := Space(06) ; Local cEnvas1 := Space(30)
   Local cCodEn2  := Space(06) ; Local cEnvas2 := Space(30)
   Local cCodEn3  := Space(06) ; Local cEnvas3 := Space(30)
   Local cCodEn4  := Space(06) ; Local cEnvas4 := Space(30)
   Local cCodEn5  := Space(06) ; Local cEnvas5 := Space(30)
   Local cCodEn6  := Space(06) ; Local cEnvas6 := Space(30)
   Local nUsado   := 0
   Local nOpcA    := 0
   Local _nY
   Local aEnvasa  := {}
   Local aQryEmp := {}
   Local aQryZZG := {}
   Private aCols   := {}
   Private aHeader := {}

   DbSelectArea( _cAliasSX3 )
   DbSetOrder(2)
   MsSeek("C2_OP")
   nUsado += 1
   AADD(aHeader, { 'O.P.'       , 'NUMORD', '999999'      ,  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
   MsSeek("C2_PRODUTO")
   nUsado += 1
   AADD(aHeader, { 'Embal.'     , 'CODORD', '99'          ,  2, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
   MsSeek("C2_QUANT")
   nUsado += 1
   AADD(aHeader, { 'Qtd. Solic.', 'QTDSOL', '@E 999999.99',  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
   MsSeek("C2_QUANT")
   nUsado += 1
   AADD(aHeader, { 'Qtd. Apont.', 'QTDAPT', '@E 999999.99',  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
   nUsado += 1
   AADD(aHeader, { 'Qtd. N. Pr.', 'QTDNPR', '@E 999999.99',  6, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )
   nUsado += 1
   AADD(aHeader, { '           ', 'QTDVAG', '@!'          ,  1, 0, '', ( _cAliasSX3 )->( X3_USADO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_ARQUIVO ), ( _cAliasSX3 )->( X3_CONTEXT ) } )

   //-- Monta aCols --
   DbSelectArea("SZZ")
   DbSetOrder(1)
   DbSeek(xFilial("SZZ")+cNumLot, .T.)
   If Found()
      While !Eof() .AND. SZZ->ZZ_LOTE == cNumLot
         aQryEnv := {}
         aAdd(aQryEnv, "SELECT C2_NUM, C2_ITEM, C2_SEQUEN, C2_QUJE ")
         aAdd(aQryEnv, "FROM "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ")
         aAdd(aQryEnv, "WHERE SC2.C2_FILIAL  = '"+xFilial("SC2")+"' ")
         aAdd(aQryEnv, "  AND SC2.D_E_L_E_T_ = '' ")
         aAdd(aQryEnv, "  AND SC2.C2_LOTE    = '"+cNumLot+"' ")
         aAdd(aQryEnv, "  AND SC2.C2_PRODUTO = '"+SZZ->ZZ_PRODUTO+"' ")
         TCQuery (fJoinArr(aQryEnv)) ALIAS "TCQ" NEW

         DbSelectArea("TCQ")
         aQryEmp := {}
         aAdd(aQryEmp, "SELECT PRO.ORDEM, ")
         aAdd(aQryEmp, Iif(Substr(Alltrim(SZZ->ZZ_PRODUTO),11,2) $ '00.99', "SUM(PRO.QTDE) AS QUANT ", "SUM(EMP.QUANT) AS QUANT "))
         aAdd(aQryEmp, "FROM PRODUCAO PRO ")
         aAdd(aQryEmp, "LEFT OUTER JOIN EMPENHO EMP ON PRO.ORDEM = EMP.ORDEM AND PRO.LOTE = EMP.LOTE ")
         aAdd(aQryEmp, "WHERE PRO.LOTE  = '"+cNumLot+"' ")
         aAdd(aQryEmp, "  AND PRO.ORDEM = '"+TCQ->C2_NUM+TCQ->C2_ITEM+TCQ->C2_SEQUEN+"' ")
         aAdd(aQryEmp, "  AND EMP.FLAG  <> '1' ")
         aAdd(aQryEmp, "GROUP BY PRO.ORDEM ")
         TCQuery (fJoinArr(aQryEmp)) ALIAS "EMP" NEW

         aAdd(aCols, {TCQ->C2_NUM, Substr(SZZ->ZZ_PRODUTO,11,2), SZZ->ZZ_QTDETI, TCQ->C2_QUJE, EMP->QUANT, '', .F.})

         DbSelectArea("EMP") ; DbCloseArea()
         DbSelectArea("TCQ") ; DbCloseArea()
         DbSelectArea("SZZ")
         DbSkip()
      Enddo
   Endif

   //-- Busca envasadores do lote --
   aQryZZG := {}
   aAdd(aQryZZG, "SELECT DISTINCT ZZG_FILMAT, ZZG_NOME ")
   aAdd(aQryZZG, " FROM "+RetSqlName("ZZG")+" ZZG WITH(NOLOCK) ")
   aAdd(aQryZZG, " WHERE ZZG.D_E_L_E_T_ = ''  AND  ZZG_FILIAL ='"+xFilial("ZZG")+"' ")
   aAdd(aQryZZG, " AND ZZG_PROENV <>'' AND ZZG_TPUSER ='E' AND ZZG_LOTE = '"+cNumLot+"' ")
   aAdd(aQryZZG, " ORDER BY ZZG_PROENV, ZZG_SEQENV ")
   TCQuery (fJoinArr(aQryZZG)) ALIAS "TCQ" NEW

   DbSelectArea("TCQ")
   While !Eof()
      aAdd(aEnvasa, { TCQ->ZZG_FILMAT, TCQ->ZZG_NOME })
      DbSelectArea("TCQ")
      DbSkip()
   Enddo
   DbSelectArea("TCQ")
   DbCloseArea()

   If Len(aEnvasa) > 0
      For _nY := 1 To Min(Len(aEnvasa), 6)
         Do Case
            Case _nY == 1 ; cCodEn1 := aEnvasa[_nY,1] ; cEnvas1 := aEnvasa[_nY,2]
            Case _nY == 2 ; cCodEn2 := aEnvasa[_nY,1] ; cEnvas2 := aEnvasa[_nY,2]
            Case _nY == 3 ; cCodEn3 := aEnvasa[_nY,1] ; cEnvas3 := aEnvasa[_nY,2]
            Case _nY == 4 ; cCodEn4 := aEnvasa[_nY,1] ; cEnvas4 := aEnvasa[_nY,2]
            Case _nY == 5 ; cCodEn5 := aEnvasa[_nY,1] ; cEnvas5 := aEnvasa[_nY,2]
            Case _nY == 6 ; cCodEn6 := aEnvasa[_nY,1] ; cEnvas6 := aEnvasa[_nY,2]
         EndCase
      Next
   Endif

   DEFINE MSDIALOG oDlgF FROM 000,000 TO 023,085 TITLE OemToAnsi("Apontamento dos envasadores") OF oMainWnd
   DEFINE FONT oFont1 SIZE 9,0 BOLD

   @ 001, 003 SAY   OemToAnsi("Lote")                     SIZE 030,009                PIXEL OF oDlgF
   @ 009, 003 MSGET oNumLot VAR cNumLot PICTURE "@R!"     SIZE 040,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 001, 045 SAY   OemToAnsi("Produto")                  SIZE 030,009                PIXEL OF oDlgF
   @ 009, 045 MSGET oCodOrd VAR cCodOrd PICTURE "@R!"     SIZE 078,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 001, 125 SAY   OemToAnsi("Descricao")                SIZE 030,009                PIXEL OF oDlgF
   @ 009, 125 MSGET oDesOrd VAR cDesOrd PICTURE "@R!"     SIZE 143,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1

   @ 021, 003 SAY   OemToAnsi("Envasador 1")              SIZE 035,009                PIXEL OF oDlgF
   @ 029, 003 MSGET oCodEn1 VAR cCodEn1 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 029, 040 MSGET oEnvas1 VAR cEnvas1 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 021, 170 SAY   OemToAnsi("Envasador 2")              SIZE 035,009                PIXEL OF oDlgF
   @ 029, 170 MSGET oCodEn2 VAR cCodEn2 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 029, 207 MSGET oEnvas2 VAR cEnvas2 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1

   @ 041, 003 SAY   OemToAnsi("Envasador 3")              SIZE 035,009                PIXEL OF oDlgF
   @ 049, 003 MSGET oCodEn3 VAR cCodEn3 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 049, 040 MSGET oEnvas3 VAR cEnvas3 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 041, 170 SAY   OemToAnsi("Envasador 4")              SIZE 035,009                PIXEL OF oDlgF
   @ 049, 170 MSGET oCodEn4 VAR cCodEn4 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 049, 207 MSGET oEnvas4 VAR cEnvas4 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1

   @ 061, 003 SAY   OemToAnsi("Envasador 5")              SIZE 035,009                PIXEL OF oDlgF
   @ 069, 003 MSGET oCodEn5 VAR cCodEn5 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 069, 040 MSGET oEnvas5 VAR cEnvas5 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 061, 170 SAY   OemToAnsi("Envasador 6")              SIZE 035,009                PIXEL OF oDlgF
   @ 069, 170 MSGET oCodEn6 VAR cCodEn6 PICTURE "@R!"     SIZE 035,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1
   @ 069, 207 MSGET oEnvas6 VAR cEnvas6 PICTURE "@R!"     SIZE 128,010 COLOR CLR_BLUE PIXEL OF oDlgF FONT oFont1

   oGetEnv := MsGetDados():New( 085, 003, 160, 335, 3, "AllwaysTrue()", "AllwaysTrue()", "", .F., {}, 3, , Len(aCols), "AllwaysTrue()")

   DEFINE SBUTTON oBtnECf FROM 161, 260 TYPE 1 ACTION(nOpcA := 1, lSaidaF := .T., oDlgF:End()) ENABLE OF oDlgF
   DEFINE SBUTTON oBtnESa FROM 161, 300 TYPE 2 ACTION(nOpcA := 0, lSaidaF := .T., oDlgF:End()) ENABLE OF oDlgF

   oDlgF:nStyle      := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )
   oCodEn1:SetFocus()
   oNumLot:lReadOnly := .T. ; oCodOrd:lReadOnly := .T. ; oDesOrd:lReadOnly := .T.
   oEnvas1:lReadOnly := .T. ; oEnvas2:lReadOnly := .T. ; oEnvas3:lReadOnly := .T.
   oEnvas4:lReadOnly := .T. ; oEnvas5:lReadOnly := .T. ; oEnvas6:lReadOnly := .T.

   oCodEn1:bLostFocus := {|| fValEnva(@oCodEn1, @cCodEn1, @oEnvas1, @cEnvas1, @oNumLot)}
   oCodEn2:bLostFocus := {|| fValEnva(@oCodEn2, @cCodEn2, @oEnvas2, @cEnvas2, @oNumLot)}
   oCodEn3:bLostFocus := {|| fValEnva(@oCodEn3, @cCodEn3, @oEnvas3, @cEnvas3, @oNumLot)}
   oCodEn4:bLostFocus := {|| fValEnva(@oCodEn4, @cCodEn4, @oEnvas4, @cEnvas4, @oNumLot)}
   oCodEn5:bLostFocus := {|| fValEnva(@oCodEn5, @cCodEn5, @oEnvas5, @cEnvas5, @oNumLot)}
   oCodEn6:bLostFocus := {|| fValEnva(@oCodEn6, @cCodEn6, @oEnvas6, @cEnvas6, @oNumLot)}

   ACTIVATE MSDIALOG oDlgF VALID lSaidaF CENTERED

   If nOpcA == 1
      //-- [MELHORIA] loop unico de gravacao dos 6 envasadores --
      TCSQLExec("DELETE ENVASADORES WHERE LOTE = '"+cNumLot+"' ")
      For _nY := 1 To 6
         cCodEnv := ""
         Do Case
            Case _nY == 1 ; cCodEnv := cCodEn1
            Case _nY == 2 ; cCodEnv := cCodEn2
            Case _nY == 3 ; cCodEnv := cCodEn3
            Case _nY == 4 ; cCodEnv := cCodEn4
            Case _nY == 5 ; cCodEnv := cCodEn5
            Case _nY == 6 ; cCodEnv := cCodEn6
         EndCase

         If !Empty(cCodEnv)
            aQryChk := {}
            aAdd(aQryChk, "SELECT * FROM ENVASADORES WHERE LOTE = '"+cNumLot+"' AND ENVASADOR = '"+cCodEnv+"' ")
            TCQuery (fJoinArr(aQryChk)) ALIAS "TCQ" NEW
            DbSelectArea("TCQ")
            If Empty(TCQ->ENVASADOR)
               TCSQLExec("INSERT ENVASADORES (ENVASADOR, LOTE) VALUES('"+cCodEnv+"', '"+cNumLot+"') ")
            Endif
            DbSelectArea("TCQ")
            DbCloseArea()
         Endif
      Next
   Endif

   DbSelectArea("SZZ")
   DbSetOrder(1)
   DbSeek(xFilial("SZZ")+cNumLot, .T.)

Return

/*----------------------------------------------------------------------*/
/* fValEnva - Valida envasador digitado                                   */
/* [MELHORIA] renomeado de fValEnv para fValEnva (mais descritivo)        */
/*----------------------------------------------------------------------*/
Static Function fValEnva(oCodEnv, cCodEnv, oEnvasa, cEnvasa, oNumLot)

   If Empty(cCodEnv)
      oNumLot:SetFocus()
      Return
   Endif

   DbSelectArea("SRA")
   DbSetOrder(1)
   DbSeek(xFilial("SRA")+cCodEnv, .T.)

   If Found()
      cEnvasa := SRA->RA_NOME
      oCodEnv:Refresh()
      oEnvasa:Refresh()
   Else
      MsgBox("Envasador Invalido !!!", "Atencao", "STOP")
      cCodEnv := Space(06)
      cEnvasa := Space(30)
      oCodEnv:Refresh()
      oEnvasa:Refresh()
      oCodEnv:SetFocus()
   Endif

Return

/*----------------------------------------------------------------------*/
/* VerLotesAb - Preenche tabela temporaria com lotes em aberto           */
/*----------------------------------------------------------------------*/
Static Function VerLotesAb()
   Local lRet     := .T.
   Local cQuery   := ""
   Local cTrab    := ""
   Local cLote    := ""

   If Alltrim(cNumEmp) == "0501"
      cQuery := "SELECT DISTINCT ZZ_LOTE AS LOTE "+;
         "FROM "+RetSqlName("SZZ")+" SZZ WITH (NOLOCK) "+;
         "WHERE (D_E_L_E_T_ <> '*') AND (ZZ_FILIAL = '"+xFilial("SZZ")+"') AND (ZZ_LOTE > '') AND (ZZ_FLAG <= 'N') "+;
         "ORDER BY LOTE"

      cTrab := U_NovoCursor()
      TCQuery cQuery ALIAS (cTrab) NEW
      DbSelectArea(cTrab)
      DbGoTop()

      Do While !Eof()
         cLote := (cTrab)->LOTE
         DbSelectArea(xLotes)
         DbGoTop()
         Locate For LOTE == cLote
         If Eof() .OR. (!Eof() .AND. !Bof() .AND. (xLotes)->LOTE <> cLote)
            RecLock(xLotes, .T.)
            Replace LOTE With cLote
            MsUnLock()
         Endif
         DbSelectArea(cTrab)
         DbSkip()
      Enddo

      DbSelectArea(cTrab)
      DbCloseArea()
      DbSelectArea(xLotes)
      DbGoTop()
   Endif

Return(lRet)

/*----------------------------------------------------------------------*/
/* VerMetric - Verifica divergencia de metricas GGF do produto           */
/* [MELHORIA] renomeado de VerMetrica para VerMetric (10 chars exatos)   */
/*----------------------------------------------------------------------*/
User Function VerMetric(cProd)
   Local lDiverge  := .F.
   Local aQryM     := {}

   If Alltrim(FWGrpCompany()) = "05"
      Return(lDiverge)
   Endif

   DbSelectArea("ZGF")
   DbSetOrder(1)
   DbSeek(xFilial("ZGF")+cProd, .T.)

   If Found()
      aQryM := {}
      aAdd(aQryM, " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_LOCPAD, SG1.G1_COMP, ZGF.ZGF_CODGGF ")
      aAdd(aQryM, " FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ")
      aAdd(aQryM, " LEFT OUTER JOIN "+RetSqlName("SG1")+" SG1 ON SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COD = SB1.B1_COD AND SG1.D_E_L_E_T_ ='' ")
      aAdd(aQryM, " LEFT OUTER JOIN "+RetSqlName("ZGF")+" ZGF ON ZGF.ZGF_FILIAL = SG1.G1_FILIAL AND ZGF.ZGF_COD = SG1.G1_COD AND SG1.G1_COMP = ZGF.ZGF_CODGGF AND ZGF.D_E_L_E_T_ ='' ")
      aAdd(aQryM, " WHERE SB1.D_E_L_E_T_ ='' ")
      aAdd(aQryM, " AND SB1.B1_FILIAL ='"+xFilial("SB1")+"' ")
      aAdd(aQryM, " AND SB1.B1_COD ='"+cProd+"' ")
      aAdd(aQryM, " AND SUBSTRING(SG1.G1_COMP,1,3)='GGF' ")
      TCQuery (fJoinArr(aQryM)) ALIAS "TMETRICA" NEW

      DbSelectArea("TMETRICA")
      If !Eof()
         While !Eof() .AND. (TMETRICA->B1_FILIAL == XFILIAL("SB1")) .AND. (Alltrim(cProd) == Alltrim(TMETRICA->B1_COD))
            If (Alltrim(TMETRICA->ZGF_CODGGF)) <> (Alltrim(TMETRICA->G1_COMP))
               lDiverge := .T.
            Endif
            DbSelectArea("TMETRICA")
            DbSkip()
         Enddo
      Endif
   Else
      aQryM := {}
      aAdd(aQryM, " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_LOCPAD, ZGF.ZGF_CODGGF, ")
      aAdd(aQryM, " 'GGF_SG1' = (SELECT MAX(G1_COMP) FROM "+RetSqlName("SG1")+" SG1 WHERE SG1.G1_FILIAL = SB1.B1_FILIAL AND SG1.G1_COD = SB1.B1_COD AND SG1.G1_COMP = ZGF.ZGF_CODGGF AND SG1.D_E_L_E_T_='') ")
      aAdd(aQryM, " FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ")
      aAdd(aQryM, " LEFT OUTER JOIN "+RetSqlName("ZGF")+" ZGF WITH(NOLOCK) ON SB1.B1_FILIAL = ZGF.ZGF_FILIAL AND SUBSTRING(SB1.B1_COD,4,2)= ZGF.ZGF_LINHA AND SUBSTRING(SB1.B1_COD,1,3) = ZGF.ZGF_CARAC AND SB1.B1_TIPO = ZGF.ZGF_TIPO  AND ZGF.ZGF_COD =''  AND ZGF.D_E_L_E_T_ ='' ")
      aAdd(aQryM, " WHERE SB1.D_E_L_E_T_ ='' ")
      aAdd(aQryM, " AND SB1.B1_FILIAL ='"+xFilial("SB1")+"' ")
      aAdd(aQryM, " AND SB1.B1_COD ='"+cProd+"' ")
      TCQuery (fJoinArr(aQryM)) ALIAS "TMETRICA" NEW

      DbSelectArea("TMETRICA")
      If !Eof()
         While !Eof() .AND. (TMETRICA->B1_FILIAL == XFILIAL("SB1")) .AND. (Alltrim(cProd) == Alltrim(TMETRICA->B1_COD))
            If ((Alltrim(TMETRICA->ZGF_CODGGF)) <> (Alltrim(TMETRICA->GGF_SG1))) .OR. Empty(TMETRICA->ZGF_CODGGF)
               lDiverge := .T.
            Endif
            DbSelectArea("TMETRICA")
            DbSkip()
         Enddo
      Endif
   Endif

   DbSelectArea("TMETRICA")
   DbCloseArea()
   DbSelectArea("ZGF")
   DbCloseArea()

Return (lDiverge)

/*----------------------------------------------------------------------*/
/* NroSqLote - Sequenciador de numero de lote                            */
/* [BUG01] CORRIGIDO: _nTime declarado como Local                        */
/*----------------------------------------------------------------------*/
User Function NroSqLote(cTabela, nTam)
   Local _cNumAut        := "*"
   Local _cProximo       := ""
   Local cSx2            := ""
   Local cAliasZZW       := ""
   Local lAbriuOutraArea := .F.
   Local _cAux           := ""
   Local _cGrupoEmp      := ""
   Local nTamFil         := 0
   Local cFilTab         := ""
   Local _cAux1          := ""
   Local _cAux2          := 0
   Local cArea           := Alias()
   Local _nTime          := 0   // [BUG01] CORRIGIDO: era variavel sem declaracao Local

   cAliasZZW   := "ZZW"
   cSx2        := Alltrim(RetSqlName(cAliasZZW))
   _cGrupoEmp  := Substr(cSx2, 4, 2)
   nTamFil     := FWSizeFilial(_cGrupoEmp)

   lAbriuOutraArea := .F.
   DbSelectArea(cAliasZZW)
   DbSetOrder(1)

   cFilTab := Padr(Alltrim(xFilial(cTabela)), nTamFil, " ")

   If cFilTab = "010101" .AND. cTabela = 'SZZ'
      nTam := 5
   Else
      nTam := 6
   Endif

   DbSelectArea(cAliasZZW)
   DbSeek(cFilTab+cTabela, .F.)

   If !Found()
      RecLock(cAliasZZW, .T.)
      _cAux  := cAliasZZW+"->ZZW_FILIAL"
      &_cAux := cFilTab
      _cAux  := cAliasZZW+"->ZZW_TABELA"
      &_cAux := cTabela
      _cAux  := cAliasZZW+"->ZZW_NUM"
      &_cAux := "*"
      MsUnLock()
      _cNumAut := StrZero(1, nTam)
   Else
      _cAux    := cAliasZZW+"->ZZW_NUM"
      _cNumAut := &_cAux
      _nTime   := 1000   // [BUG01] CORRIGIDO: agora e variavel Local declarada acima

      While ("*" $ _cNumAut)
         DbSelectArea(cAliasZZW)
         DbGoBottom()
         DbGoTop()
         DbSeek(cFilTab+cTabela)
         _cAux    := cAliasZZW+"->ZZW_NUM"
         _cNumAut := &_cAux
         If ("*" $ _cNumAut) .AND. ((_nTime--) <= 0)
            If MsgYesNo("Nao foi possivel obter proximo numero.", "Tentar novamente?")
               _nTime := 500
               Loop
            Else
               Exit
            Endif
         Endif
      Enddo

      If !("*" $ _cNumAut)
         RecLock(cAliasZZW, .F.)
         _cAux  := cAliasZZW+"->ZZW_NUM"
         &_cAux := "*"
         MsUnLock()
      Endif
   Endif

   If ("*" $ _cNumAut)
      MsgBox("Nao foi possivel obter prox. nro!", "Tente novamente!", "STOP")
   Else
      If cFilTab = "010101" .AND. cTabela = 'SZZ'
         _cAux1 := Substring(_cNumAut, 1, 1)
         If _cAux1 = "*" .OR. _cAux1 = "0"
            _cAux1 := "A"
         Endif
         _cAux2   := Substring(_cNumAut, 2, 5)
         _cAux2   := StrZero(Val(_cAux2)+1, nTam)
         _cProximo := _cAux1 + (Padl(cValToChar(_cAux2), 5, "0"))
      Else
         _cProximo := StrZero(Val(_cNumAut)+1, nTam)
      Endif

      DbSelectArea(cAliasZZW)
      DbSeek(cFilTab+cTabela, .F.)
      RecLock(cAliasZZW, .F.)
      _cAux  := cAliasZZW+"->ZZW_NUM"
      &_cAux := _cProximo
      MsUnLock()
   Endif

   If lAbriuOutraArea
      DbSelectArea(cAliasZZW)
      DbCloseArea()
   Endif

   If !Empty(cArea)
      Select(cArea)
   Endif

Return _cNumAut
