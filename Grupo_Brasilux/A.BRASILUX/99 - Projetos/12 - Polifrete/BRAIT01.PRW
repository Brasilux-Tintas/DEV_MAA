#include 'parmtype.ch'
#include "fileio.ch"
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "RESTFUL.ch"
#Include "FWMVCDef.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

User Function BRAIT01()
	Local aRetToken := ApiLog()
	//Local nToken    := NewToken()
	Local cAlias    := GetNextAlias()
	lOCAL cJson     := ''
	Local cJson     := ''

	if Empty(aRetToken[1])
		return()
	EndIf
    
    /* valida se destino foi informado */
	if Empty(SZA->ZA_COD_MUN)
		MsgAlert('Obrigatório informar o Destino')
		return()
	EndIf

	cQry:="    SELECT"
	cQry+="        ZA_CODIGO,"
	cQry+="        ZA_VOLUME,"
	cQry+="        ZA_COD_MUN, "
	cQry+="        SUM(C5_VLRDUP) as C5_VLRDUP "
	cQry+="    FROM  "
	cQry+="        "+RetSqlName("SZB")+" SZB WITH (NOLOCK)"
	cQry+="        LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH (NOLOCK) ON (SZA.D_E_L_E_T_ = '')"
	cQry+="        AND (ZA_FILIAL = ZB_FILIAL)"
	cQry+="        AND (ZA_CODIGO = ZB_CODIGO)"
	cQry+="        LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ = '')"
	cQry+="        AND (C5_FILIAL = '"+XFILIAL('SC5')+"')"
	cQry+="        AND (C5_NUM = SUBSTRING(ZB_PEDIDO, 3, 6))"
	cQry+="        LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ = '')"
	cQry+="        AND (F2_FILIAL = '"+XFILIAL('SF2')+"')"
	cQry+="        AND F2_DOC = C5_NOTA AND F2_SERIE=C5_SERIE"
	cQry+="    WHERE"
	cQry+="        (SZB.ZB_FILIAL = '"+XFILIAL('SZB')+"')"
	cQry+="        AND (SZB.D_E_L_E_T_ = ' ')"
	cQry+="        AND ZB_CODIGO = '"+SZA->ZA_CODIGO+"'"
	cQry+="    group  BY"
	cQry+="        ZA_CODIGO,"
	cQry+="        ZA_VOLUME,ZA_COD_MUN"

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAlias, .F., .T. )
	bWhile := { || !( cAlias )->( Eof() ) }
	(cAlias)->(dbgotop())
	While Eval( bWhile )
    /*
		IF (cAlias)->C5_TIPO$('D/B')
			cCGC:=Posicione("SA2",1,xFilial("SA2")+(cAlias)->(C5_CLIENTE+C5_LOJACLI),"A2_CGC")
			cNome:=(cAlias)->(C5_CLIENTE+C5_LOJACLI)+' '+alltrim(SA2->A2_NOME)
			cEnd:=alltrim(SA2->A2_END)+' '+alltrim(SA2->A2_EST)+' '+alltrim(SA2->A2_MUN)
			cIbgemun:=SA2->A2_COD_MUN
		ELSE

			cCGC:=Posicione("SA1",1,xFilial("SA1")+(cAlias)->(C5_CLIENTE+C5_LOJACLI),"A1_CGC")
			cNome:=(cAlias)->(C5_CLIENTE+C5_LOJACLI)+' '+alltrim(SA1->A1_NOME)
			cEnd:=alltrim(SA1->A1_END)+' '+alltrim(SA1->A1_EST)+' '+alltrim(SA1->A1_MUN)
			cIbgemun:=SA1->A1_COD_MUN

		EndIf
*/
		cJson+='{'+ CRLF
		cJson+='"offerer": '+aRetToken[2]+','+ CRLF
		cJson+='"formId": 903,'+ CRLF
		cJson+='"offerType": 1,'+ CRLF
		cJson+='"product": 1240,'+ CRLF
		cJson+='"productAlias": null,'+ CRLF
		cJson+='"volume": '+alltrim(str(( cAlias )->ZA_VOLUME))+','+ CRLF
		cJson+='"unity": 4,'+ CRLF
		cJson+='"vehicleType": 9,'+ CRLF
		cJson+='"budgeted": 0,'+ CRLF
		cJson+='"price": 0,'+ CRLF
		cJson+='"pricePerUnity": true,'+ CRLF
		cJson+='"intervalOfferPrice": "",'+ CRLF
		cJson+='"originibge": 3529302,'+ CRLF
		cJson+='"destinyibge": '+(cAlias)->ZA_COD_MUN+','+ CRLF
		cJson+='"stringOfferDate": "" ,'+ CRLF //+DToStamp(date())+','+ CRLF
		cJson+='"offerDateShowTo": "2",'
		cJson+='"stringInitDate": "",'+ CRLF
		cJson+='"stringEndDate": "",'+ CRLF
		cJson+='"nroCargoOrder": "pedido",'+ CRLF
		cJson+='"controls":' + CRLF
		cJson+='['+ CRLF
		cJson+='   {'+ CRLF
		cJson+='       "control": 6781,'+ CRLF
		cJson+='      "value": " " '+ CRLF
		cJson+='  },'+ CRLF
		cJson+='  {'+ CRLF
		cJson+='     "control": 6783,'+ CRLF
		cJson+='     "value": "'+(cAlias)->ZA_CODIGO+'"'+ CRLF
		cJson+=' },'+ CRLF
		cJson+=' {'+ CRLF
		cJson+='     "control": 6784,'+ CRLF
		cJson+='     "value": " "'+ CRLF
		cJson+=' },'+ CRLF
		cJson+=' {'+ CRLF
		cJson+='     "control": 6785,'+ CRLF
		cJson+='     "value": "'+file2bAS64()+'"'+ CRLF
		cJson+=' },'+ CRLF
		cJson+='   {'+ CRLF
		cJson+='      "control": 6786,'+ CRLF
		cJson+='      "value": "'+alltrim(str(( cAlias )->ZA_VOLUME))+'"'+ CRLF
		cJson+=' },'+ CRLF
		cJson+=' {'+ CRLF
		cJson+='     "control": 6789,'+ CRLF
		cJson+='     "value": '+GetCub((cAlias)->ZA_CODIGO)+ CRLF
		cJson+='  },'+ CRLF
		cJson+='  {'+ CRLF
		cJson+='     "control": 6790,'+ CRLF
		cJson+='     "value":'+alltrim(str(( cAlias )->C5_VLRDUP))+ CRLF
		cJson+=' },'+ CRLF
		cJson+=' {'+ CRLF
		cJson+='    "control": 6791,'+ CRLF
		cJson+='    "value": " "'+ CRLF
		cJson+='},'+ CRLF
		cJson+=' {'+ CRLF
		cJson+='    "control": 6792,'+ CRLF
		cJson+='     "value": '+getEntreg((cAlias)->ZA_CODIGO)+ CRLF 
		cJson+=' }'+ CRLF
		cJson+=' ],'+ CRLF
		cJson+='"invitedCompanies": ['+ CRLF
		cJson+=' ]'+ CRLF
		cJson+='}'

		DbSelectArea(cAlias)
		( cAlias )->( dbSkip() )
	EndDo
	( cAlias )->(DbCloseArea())
	
	
	// Incluido por Nelieder
	
	ApiPut(cJson+cJson,aRetToken[1])
return()
/*/{Protheus.doc} ApiLog
description
@type function
@version  
@author rubens
@since 20/05/2022
@param cPath, character, param_description
@param cJson, character, param_description
@param cToken, character, param_description
@return variant, return_description
/*/
Static Function ApiLog(cJson)

	Local aHeader := {}
	Local cId     := ''
	Local cJsonLog   := ''
	local cPath   := AllTrim( SuperGetMV("MV_LGPLFRETE", .F., "/User/login") )
	Local cSenha_ := AllTrim( SuperGetMV("MV_SNPLFRETE", .F., "123456") )
	Local cToken  := ''
	Local cUrl    := AllTrim( SuperGetMV("MV_URPLFRETE", .F., 'https://ws.polifrete.com' ) )
	Local cUser   := AllTrim( SuperGetMV("MV_USPLFRETE", .F., "log@brasilux.com.br",) )
	Local oObjRet := JSonObject():New()
	Local oRest   := FWRest()    :New(cUrl)
	Local NewToken

	cJsonLog+='{'+ CRLF
	cJsonLog+='"email": "'+alltrim(cUser)+'",'+ CRLF
	cJsonLog+='"password": "'+cSenha_+'"'+ CRLF
	cJsonLog+='}'

	NewToken := NewToken()
	Aadd( aHeader, "BasicAuthorization: Basic "+NewToken ) 
	Aadd( aHeader, "Content-Type: application/json" )
	oRest:setPath('/api'+cPath)

	oRest:SetPostParams(EncodeUtf8(cJsonLog))

	oRest:Post(aHeader)
	cResult:=oRest:getResult()
	cResult:=oObjRet:fromJson(cResult)
	If ValType(cResult) == "U"
		cToken :=alltrim( oObjRet["accessToken"])
		cId:=alltrim(str(oObjRet["user"]["id"]))
	Else
		cMsg := "Erro ao obter o Token: Nao foi possivel desserializar o objeto recebido." + CRLF
		cMsg += " Por favor, caso o erro persista, informe o administrador do sistema. "+ CRLF
		If Valtype(cResult ) == "C"
			cMsg += cResult
		EndIf
		Alert(cMsg)
	EndIf

Return({cToken,cId})

/*/{Protheus.doc} ApiPut
description
@type function
@version  
@author rubens
@since 24/05/2022
@param cPath, character, param_description
@param cJson, character, param_description
@param cToken, character, param_description
@return variant, return_description
/*/
Static Function ApiPut(cJson,cToken)

	Local aHeader := {}
	local cPath   := AllTrim( SuperGetMV("MV_FTPLFRETE", .F., "/offer") )
	Local cUrl    := AllTrim( SuperGetMV("MV_URPLFRETE", .F., 'https://ws.polifrete.com' ) )
	Local oObjput := JSonObject():New()
	Local oPut    := FWRest()    :New(cUrl)

	
	aadd(aHeader, "Authorization: Bearer " + alltrim(cToken))
	
	Aadd(aHeader , "Content-Type: application/json; charset=utf-8" )


	oPut:setPath('/api'+cPath)
	oPut:SetPostParams( EncodeUtf8(cJson))

	oPut:Post(aHeader)
	cResult:=oPut:getResult()
        RecLock("SZA", .F.)
        ZA_RETAPI:=cResult
        MsUnLock() 
	cResult:=oObjput:fromJson(DecodeUtf8(cResult))
	If ValType(cResult) <> "U"

		cMsg := "Erro ao fazer Put: Nao foi possivel desserializar o objeto recebido." + CRLF
		cMsg += " Por favor, caso o erro persista, informe o administrador do sistema. "+ CRLF
		If Valtype(cResult ) == "C"
			cMsg += cResult
		EndIf
		Alert(cMsg)
	else
		Alert("Registro incluido com sucesso !")
	EndIf
Return()

/*/{Protheus.doc} file2bAS64
description
@type function
@version  
@author rubens
@since 25/05/2022
@return variant, return_description
/*/
Static function file2bAS64()
	Local cType:="Arquivos PDF|*.PDF|Todos os Arquivos|*.*"
	Local cCaminho:=cGetFile(cType, OemToAnsi("Selecione a arquivo a ser enviado."),0,"",.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	IF Empty(cCaminho)
		return (" ")
	Endif

	nHandle := fopen(cCaminho , FO_READ + FO_SHARED )
	If nHandle == -1
		MSgStop("FOpen() Failed - FError("+cValToChar(ferror())+")",'FileSend() - Falha na abertura do arquivo')
		return (" ")
	Endif

// Pega o tamanho do arquivo
	nFSize := FSeek(nHandle,0,FS_END)
	FSeek(nHandle,0)

	If nFSize < 1
		MSgStop("Invalid File Size",'FileSend() - ARquivo vazio')
		return ""
	Endif

// Le o arquivo
	cString := space(nFSize)
	FRead( nHandle, @cString, nFSize ) //Carrega na variável cString, a string ASCII do arquivo.

	FClose(nHandle)

	cTexto := Encode64(cString) // Converte o arquivo para BASE64
    cTexto := 'data:application/pdf;base64,'+cTexto
return(cTexto)

/*/{Protheus.doc} GetCub
description
@type function
@version  
@author rubens
@since 25/05/2022
@param cPedido, character, param_description
@return variant, return_description
/*/
Static Function GetCub(cPedido)

	Local nCub      := 0
	Local aArea     := GetArea()
	Local caliasCub := GetNextAlias()


cQry:=" SELECT SUM(ZZO_CUBAGE) as ZZO_CUBAGE FROM  "+RetSqlName("SZB")+"  SZB 
cQry+=" INNER JOIN "+RetSqlName("ZZO")+" ZZO ON  ZZO_FILIAL = ZB_FILIAL AND ZZO_PEDIDO = SUBSTRING(ZB_PEDIDO,3,6)
cQry+=" WHERE ZB_CODIGO = '"+cPedido+"' AND (SZB.D_E_L_E_T_ <> '*')
 

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), caliasCub, .F., .T. )
	bWhile_ := { || !( caliasCub )->( Eof() ) }
	(caliasCub)->(dbgotop())
	While Eval( bWhile_ )

		nCub:= ( caliasCub )->ZZO_CUBAGE


		( caliasCub )->( dbSkip() )
	EndDo
	( caliasCub )->(DbCloseArea())

	RestArea(aArea)

Return(alltrim(str(nCub)))


static function getEntreg(cPedido)

	Local nEnt      := 0
	Local aArea     := GetArea()
	Local calias := GetNextAlias()


cQry:=" SELECT COUNT(DISTINCT(A1_CGC)) NENTREGAS FROM "+RetSqlName("SZB")+" SZB "
cQry+=" INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_NUM = SUBSTRING(ZB_PEDIDO,3,6) AND SC5.D_E_L_E_T_ = '' AND SC5.C5_FILIAL = SZB.ZB_FILIAL "
cQry+=" INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_COD = C5_CLIENT AND SA1.D_E_L_E_T_ = '' AND A1_FILIAL = '"+XFILIAL('SA1')+"' "
cQry+=" WHERE ZB_CODIGO = '"+cPedido+"' AND (SZB.D_E_L_E_T_ <> '*') AND ZB_FILIAL = '"+XFILIAL('SZB')+"' "



	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), calias, .F., .T. )
	bWhile_ := { || !( calias )->( Eof() ) }
	(calias)->(dbgotop())
	While Eval( bWhile_ )

		nEnt:= ( calias )->NENTREGAS


		( calias )->( dbSkip() )
	EndDo
	( calias )->(DbCloseArea())

	RestArea(aArea)

Return(alltrim(str(nEnt)))

Static Function NewToken()
Local cRetorno
Local oJson := JSonObject():New()

Local nCipherID   := 0 // AES-128 CBC
Local Token       := ""//"xqj60rRbMyPVRGmBsTH9UuJjIWt1ZUUrPdsLdEDDk6QPyTR75UMEkdbh65CoGGbUbLk5yNPowjA9+YqGJemHYWY0T6Yc9lZyUq6y5iUylz3QBS3Kswb8qvX+2P5GJWErqVhQtynQIxW2+iCuhpC+1fTWz22XpvgGcKBQq0abOf7EV9riS8w3bq5Y5LMsVowm"
Local Key         := "1203199320052021"
Local iv          := "1203199320052021"
Local Token2,newToken,aDescrip,aDescrip2


cRetorno := Httpget('https://ws.polifrete.com/api/system/secret', , , ,)
conout("WebPage", cRetorno)
oJson:FromJson(cRetorno)
Token := alltrim( oJson["secret"])

aDescrip := AESDecrypt(nCipherID, Decode64(Token) , Key, iv) //Descriptografando

Token2 := ";&T{(]@x{>l9@wT}qq07.`NJDAqw5wUxVs.C*}11:"+aDescrip[2]

aDescrip2 := AESEncrypt(nCipherID, Token2 , , Key, iv) //Criptografando

newToken := Encode64(aDescrip2[2])

newToken := Encode64(newToken)


Return(newToken)


