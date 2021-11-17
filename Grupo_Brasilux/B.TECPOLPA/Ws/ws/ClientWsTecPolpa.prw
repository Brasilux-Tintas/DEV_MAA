#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.1.1.230:85/wstecpolpa/WSTECPOLPA.apw?WSDL
Gerado em        10/22/16 01:12:16
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _CLUQOMA ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSTECPOLPA
------------------------------------------------------------------------------- */

WSCLIENT WSWSTECPOLPA

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GERATRANSF

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCDPROD                  AS string
	WSDATA   cCNRLOTE                  AS string
	WSDATA   cCQUANT                   AS string
	WSDATA   cCCODUSER                 AS string
	WSDATA   lLCHK                     AS boolean
	WSDATA   cGERATRANSFRESULT         AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSTECPOLPA
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160114 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSTECPOLPA
Return

WSMETHOD RESET WSCLIENT WSWSTECPOLPA
	::cCCDPROD           := NIL 
	::cCNRLOTE           := NIL 
	::cCQUANT            := NIL 
	::cCCODUSER          := NIL 
	::lLCHK              := NIL 
	::cGERATRANSFRESULT  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSTECPOLPA
Local oClone := WSWSTECPOLPA():New()
	oClone:_URL          := ::_URL 
	oClone:cCCDPROD      := ::cCCDPROD
	oClone:cCNRLOTE      := ::cCNRLOTE
	oClone:cCQUANT       := ::cCQUANT
	oClone:cCCODUSER     := ::cCCODUSER
	oClone:lLCHK         := ::lLCHK
	oClone:cGERATRANSFRESULT := ::cGERATRANSFRESULT
Return oClone

// WSDL Method GERATRANSF of Service WSWSTECPOLPA

WSMETHOD GERATRANSF WSSEND cCCDPROD,cCNRLOTE,cCQUANT,cCCODUSER,lLCHK WSRECEIVE cGERATRANSFRESULT WSCLIENT WSWSTECPOLPA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GERATRANSF xmlns="http://10.1.1.230:'+GETMV("MV_XPORTWS")+'/">'
cSoap += WSSoapValue("CCDPROD", ::cCCDPROD, cCCDPROD , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CNRLOTE", ::cCNRLOTE, cCNRLOTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CQUANT", ::cCQUANT, cCQUANT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODUSER", ::cCCODUSER, cCCODUSER , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LCHK", ::lLCHK, lLCHK , "boolean", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GERATRANSF>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://10.1.1.230:"+GETMV("MV_XPORTWS")+"/GERATRANSF",; 
	"DOCUMENT","http://10.1.1.230:"+GETMV("MV_XPORTWS")+"/",,"1.031217",; 
	"http://10.1.1.230:"+GETMV("MV_XPORTWS")+"/wstecpolpa/WSTECPOLPA.apw")

::Init()
::cGERATRANSFRESULT  :=  WSAdvValue( oXmlRet,"_GERATRANSFRESPONSE:_GERATRANSFRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



