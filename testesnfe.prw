#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BR_PesqChv
Verificação do status da NFe no Sefaz
@type function Processamento
@version  1.00
@author Eduardo Clemente
@since 15/07/14
@return character, sem retorno
/*/
User Function BR_PesqChv()

    Local oButton1
    Local oButton2
    Local oSay1
    Local nOpcChe := 0
    Private aCordW := MsAdvSize(.T.)
    Private oChave
    Private cChave := Space(44)
    Private oDlg
    Private cLineOk := "AllwaysTrue()"
    Private cAllOk := "AllwaysTrue()"
    Private nCOunt := 0
    Private cIdEnt := GetIdEnt()
    Private nOpcx := 3
    Private aCGD := {}
    Private lDelGetD := .T.
    Private aButtons := {}

    DEFINE MSDIALOG oDlg TITLE "Verificação do Status da NF-e no Sefaz" FROM 000, 000 TO 100, 640 COLORS 0, 16777215 PIXEL

    @ 010, 003 SAY oSay1 PROMPT "Chave de Acesso:" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 009, 059 MSGET oChave VAR cChave SIZE 256, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 275 BUTTON oButton1 PROMPT ">>> Avançar" SIZE 037, 012 OF oDlg PIXEL ACTION ( oDlg:End(), nOpcChe := 1 ) // SH143NXT(cChave)
    @ 028, 225 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    If nOpcChe == 1

        VldNfe(cChave,cIdEnt)

    EndIF

Return



/*/{Protheus.doc} VldNfe
Valida NFE
@type function Processamento
@version  1.0
@author marioantonaccio
@since 17/04/2026
@param cChaveNFe, character, chave NFE a ser validada
@param cIndChv, character, código da entidade
@return character, sem retorno
/*/
Static Function VldNfe(cChaveNFe,cIndChv)

    Local cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cMensagem := ""
    Local oWS
    Local cCodRet := ""
    Local cVersao := ""
    //Local cTpRet := ""
    //Local cDescRet := ""

    oWs:= WsNFeSBra():New()
    oWs:cUserToken := "TOTVS"
    oWs:cID_ENT := cIndChv
    ows:cCHVNFE := cChaveNFe
    oWs:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

    If oWs:ConsultaChaveNFE()

        cCodRet := oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE
        cVersao := oWs:oWSCONSULTACHAVENFERESULT:cVERSAO
        cMensagem := oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE
        cProtocolo := oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO

        Aviso("SPED", cMensagem,{"OK"},3)

    Else

        Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)

    EndIf

Return(NIL)


/*/{Protheus.doc} GetIdEnt
Obtem o codigo da entidade apos enviar o post para o Totvs Service
@type function Processamento
@version  1.00
@author Eduardo Riera
@since 17/04/2026
@return character, Codigo da entidade no Totvs Services
/*/
Static Function GetIdEnt()

    Local aArea := GetArea()
    Local cIdEnt := ""
    Local cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local lMethodOk := .F.
    Local oWsSPEDAdm

    BEGIN SEQUENCE

        IF .NOT. ( CTIsReady(cURL) )
            BREAK
        EndIF

        cURL := AllTrim(cURL)+"/SPEDADM.apw"

        IF .NOT. ( CTIsReady(cURL) )
            BREAK
        EndIF

        oWsSPEDAdm := WsSPEDAdm():New()

        oWsSPEDAdm:cUSERTOKEN := "TOTVS"
        oWsSPEDAdm:oWsEmpresa:cCNPJ := SM0->( IF(M0_TPINSC==2 .Or. Empty(M0_TPINSC),M0_CGC,"") )
        oWsSPEDAdm:oWsEmpresa:cCPF := SM0->( IF(M0_TPINSC==3,M0_CGC,"") )
        oWsSPEDAdm:oWsEmpresa:cIE := SM0->M0_INSC
        oWsSPEDAdm:oWsEmpresa:cIM := SM0->M0_INSCM
        oWsSPEDAdm:oWsEmpresa:cNOME := SM0->M0_NOMECOM
        oWsSPEDAdm:oWsEmpresa:cFANTASIA := SM0->M0_NOME
        oWsSPEDAdm:oWsEmpresa:cENDERECO := FisGetEnd(SM0->M0_ENDENT)[1]
        oWsSPEDAdm:oWsEmpresa:cNUM := FisGetEnd(SM0->M0_ENDENT)[3]
        oWsSPEDAdm:oWsEmpresa:cCOMPL := FisGetEnd(SM0->M0_ENDENT)[4]
        oWsSPEDAdm:oWsEmpresa:cUF := SM0->M0_ESTENT
        oWsSPEDAdm:oWsEmpresa:cCEP := SM0->M0_CEPENT
        oWsSPEDAdm:oWsEmpresa:cCOD_MUN := SM0->M0_CODMUN
        oWsSPEDAdm:oWsEmpresa:cCOD_PAIS := "1058"
        oWsSPEDAdm:oWsEmpresa:cBAIRRO := SM0->M0_BAIRENT
        oWsSPEDAdm:oWsEmpresa:cMUN := SM0->M0_CIDENT
        oWsSPEDAdm:oWsEmpresa:cCEP_CP := NIL
        oWsSPEDAdm:oWsEmpresa:cCP := NIL
        oWsSPEDAdm:oWsEmpresa:cDDD := Str(FisGetTel(SM0->M0_TEL)[2],3)
        oWsSPEDAdm:oWsEmpresa:cFONE := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
        oWsSPEDAdm:oWsEmpresa:cFAX := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
        oWsSPEDAdm:oWsEmpresa:cEMAIL := UsrRetMail(RetCodUsr())
        oWsSPEDAdm:oWsEmpresa:cNIRE := SM0->M0_NIRE
        oWsSPEDAdm:oWsEmpresa:dDTRE := SM0->M0_DTRE
        oWsSPEDAdm:oWsEmpresa:cNIT := SM0->( IF(M0_TPINSC==1,M0_CGC,"") )
        oWsSPEDAdm:oWsEmpresa:cINDSITESP := ""
        oWsSPEDAdm:oWsEmpresa:cID_MATRIZ := ""
        oWsSPEDAdm:oWsOutrasInscricoes:oWsInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
        oWsSPEDAdm:_URL := cURL

        lMethodOk := oWsSPEDAdm:AdmEmpresas()

        DEFAULT lMethodOk := .F.

        IF .NOT. ( lMethodOk )
            cError := IF( Empty( GetWscError(3) ) , GetWscError(1) , GetWscError(3) )
            BREAK
        EndIF

        cIdEnt := oWsSPEDAdm:cAdmEmpresasResult

    END SEQUENCE

    RestArea(aArea)

Return( cIdEnt )
