#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "AP5MAIL.CH"


/*
*********************************************************************************************************
** Fun¡Ño * WFCUSTDV.PRW *  Autor * Tiago Lucio - Chaus      *  Data :  * 19/12/2016                   **
*********************************************************************************************************
** Descri¡Ño      * Workflow para conferÕncia dos Custos Divergentes SD1 x SB2                         **
*********************************************************************************************************
** Uso            * Rotina: WFCUSTDV - Modulo: Faturamento                                             **
*********************************************************************************************************
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL, RELACIONAR ABAIXO CONFORME A PROXIMA LINHA.       **
*********************************************************************************************************
** ANALISTA                           * DATA                *  MOTIVO DA ALTERACAO                     **
*********************************************************************************************************
**  																								   **
**                                                                                                     **
** 																									   **
**                                                                                                     **
*********************************************************************************************************
*********************************************************************************************************
*/


User Function WFCUSTDV( )

//Local _cEmp:="11"
//Local _cFil:="11"
//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 := {}
Local   _aArea     := getArea()
Private cQLinha   := Chr(13) + Chr(10)

PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'
//RpcSetType(3)
//RpcSetEnv(_cEmp,_cFil)
//RpcSetEnv(_cEmp,_cFil)

Workflow(cEmpAnt,cFilAnt )


restArea(_aArea)
Return





Static Function Workflow( _codEmp,_codFil)
//Local dData   	:=DATE()
Local cAssunto	:= "WorkFlow das Divergencias do Custo no Estoque "/*+_codEmp*/+ ". Filial "+_codFil+". Data: "+DTOC(DDataBase)
Local cMsg		:= ""
Local cAnexo	:= ""
//Local nCont     := 0
//Local cQuery    := ""
Local _aCusto := {}
Local i := 0



//prepare environment empresa _emp filial _fil

//LGS#20200214 - AdequaÁ„o de release 12.1.25 e posteriores
//ConOut("Inicio do fonte WFCUSTDV.prw")
FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "Inicio do fonte WFCUSTDV.prw", 0 )

cPara := ""
nPercent:=0
cDtFecha:=""

DbGotop()
//LGS#20200214 - AdequaÁ„o de release 12.1.25 e posteriores
//Pega o(s) remente(s) para o envio do workflow
/*If SX6->(dbSeek(cFilAnt+"MV_XEMCUST" ))
    cPara := SX6->X6_CONTEUD
ElseIf SX6->(dbSeek(xFilial("SX6")+"MV_XEMCUST" ))
    cPara := Alltrim(SX6->X6_CONTEUD)
Endif*/
cPara := Alltrim( GetMV( "MV_XEMCUST" ) )
//cPara:="tiago.lucio@chaus.com.br"

//LGS#20200214 - AdequaÁ„o de release 12.1.25 e posteriores
//Pega o percentual de varia¡Ño de erro
/*If SX6->(dbSeek(cFilAnt+"MV_XPECUST" ))
    nPercent := SX6->X6_CONTEUD
ElseIf SX6->(dbSeek(xFilial("SX6")+"MV_XPECUST" ))
    nPercent := Val(SX6->X6_CONTEUD)
Endif*/
nPercent := Val( GetMV("MV_XPECUST") )
//nPercent:="80"

//LGS#20200214 - AdequaÁ„o de release 12.1.25 e posteriores
//Data do ultimo fechamento
/*If SX6->(dbSeek(cFilAnt+"MV_ULMES" ))
    cDtFecha := AllTrim(SX6->X6_CONTEUD)
ElseIf SX6->(dbSeek(xFilial("SX6")+"MV_ULMES" ))
    cDtFecha := AllTrim(SX6->X6_CONTEUD)
Endif*/
cDtFecha := AllTrim( GetMV( "MV_ULMES" ) )

IF Empty(cDtFecha)
   //LGS#20200214 - AdequaÁ„o de release 12.1.25 e posteriores
   //ConOut("MV_ULMES em branco para a filial "+Trim(_codFil)+" - WFCUSTDV.PRW")
   FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "MV_ULMES em branco para a filial "+Trim(_codFil)+" - WFCUSTDV.PRW", 0 )
     Return
EndIf

cAssunto+=" .  Ultimo Fechamento: "+dtoc(stoD(cDtFecha	))  +cQLinha
cAssunto+=" .  Tolerancia: "+Transform(nPercent, "@E 999,999,999.99 %") + cQLinha

//nPercent:=Val(nPercent)/100

_aCusto := queryMain()


If Len(_aCusto) > 0

	/**		Monta o script HTML para ser enviado por email 	**/
	cMsg:="<html>"
	cMsg+="<head> 					"
	cMsg+="<STYLE TYPE='text/css'> 	"
	cMsg+="<!--     				"
	cMsg+="TD{font-family: Calibri; font-size: 7pt;} "
	cMsg+="--->     				"
	cMsg+="</STYLE> 				"
	cMsg+="</head>  				"
	cMsg+="<body>					"
	cMsg+="<table  border=1 cellpadding=0 width='100%' style='border:none'>"
  	cMsg+="<tr>"
   // cMsg+="<td width='12%' style='border:none'><img   width='120px' height='50px' id='_x0000_i1033'"
  	//cMsg+="		src='http://www.ilista.com.br/sgm/arquivos/156899/image/comando-baterias-logo.jpg'  alt=' '></td>"
    cMsg+="<td width='100%'><p align=center><b><span style=' text-align:center;font-size:16.0px;font-weight:bold;font-family:Calibri;color:#1b772e'>CUSTOS EM ESTOQUE COM DIVERGENCIA</span></b></p></td>"
	cMsg+="</td></table>"
	//D:\TOTVS11\Protheus_Data\workflow\imagens  title='Bio Extratus'

	//	Filial, numero sc, item sc, dt necessidade, emissao, codigo produto, produto, qtd, solicitante
	cMsg+="<table  BORDER=1 width='100%' height='92'  style='border-collapse:collapse;border:none;mso-border-alt:solid black .5pt;'>"
	cMsg+="<tr  BGCOLOR='#D2DDD4'>"
	//cMsg+="<th  height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'><b>Filial</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Produto</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Modelo</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Descri¡Ño</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Documento</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>S»rie</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Dt. Digita¡Ño</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Custo Ultima Nota</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Custo Ultimo Fechamento</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Varia¡Ño (%)</th>"
   /*	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>C€digo do Produto</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Descri¡Ño do Produto</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Quantidade</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Requisitante</th>"
	cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#0D4820'  scope='col'><b>Solicitante</th>"  */
	cMsg+="</tr>"

	_dados := .F.

	For  i:=1 to Len(_aCusto)

	     _dados := .T.



  		IF i % 2 == 1

			cMsg+="<tr  BGCOLOR='#F0F5ED'>"
			//cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][1])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][2])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][3])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][4])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][5])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][6])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+dtoc(Stod(_aCusto[i][7]))+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][8], "@E 999,999,999.99")+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][9], "@E 999,999,999.99")+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][12], "@E 999,999,999.99")+"</td>"
		  /*	cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][5])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][6])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][7])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][8], "@E 999,999,999.99")+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][10])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][9])+"</td>"      */
			cMsg+="</tr>"
  		ELSE

  			cMsg+="<tr> "
			//cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][1])+"</td>"


			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][2])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][3])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][4])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][5])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][6])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+dtoc(Stod(_aCusto[i][7]))+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][8], "@E 999,999,999.99")+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][9], "@E 999,999,999.99")+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][12], "@E 999,999,999.99")+"</td>"
		  /*	cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][5])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][6])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][7])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Transform(_aCusto[i][8], "@E 999,999,999.99")+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][10])+"</td>"
			cMsg+="<td  style='font-size:13.0px;font-family:Calibri' >"+Alltrim(_aCusto[i][9])+"</td>"         */
		    cMsg+="</tr>"
  		ENDIF
		//Flega o item da nota como j∑ enviado pelo workflow
  	/*	dbSelectArea("SD1")
  		SD1->(dbSetOrder(1))  //	D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
  		SD1->(dbSeek(Trim(_codFil)+_aCusto[i][5]+_aCusto[i][6]+_aCusto[i][10]+_aCusto[i][11]+_aCusto[i][2]))
  		IF FOUND()    // Avalia o retorno da pesquisa realizada
           RECLOCK("SD1", .F.)
           SD1->D1_XWFCUT :='S'
           MSUNLOCK()     // Destrava o registro
        ENDIF   */

  Next i

  If !_dados
       //ConOut("Nao ha dados! - WFEEST001.PRW")
       Return
  Endif

  cMsg+="<p><b></font><font color='Black' size='2' face='Verdana'>Att. a Dire¡Ño</font></b><br>"

  cMsg+="</table>"
  cMsg+="</body>"
  cMsg+="</html>"


  _ret := EnvMail(cAssunto, cMsg, cPara, "", cAnexo)


Endif

  //RESET ENVIRONMENT

Return



Static Function queryMain()

 Local _aCusto := {}
 Local cCH := Chr(13) + Chr(10)

if Select("TMPWFCUS")<>0
	dbselectarea("TMPWFCUS")
	dbclosearea()
Endif

//	Filial, numero sc, item sc, dt necessidade, emissao, codigo produto, produto, qtd, solicitante

_cQuery:= "	SELECT D1_FILIAL,	"+cCH
_cQuery+= "			 D1_DOC,       	"+cCH
_cQuery+= "			 D1_SERIE, 	"+cCH
_cQuery+= "			 D1_COD,       	"+cCH
_cQuery+= "			 D1_LOCAL,       	"+cCH
_cQuery+= "			 B1_MODELO,     	"+cCH
_cQuery+= "			 B1_DESC,       	"+cCH
//_cQuery+= "			 GRUPO_TRIB, 	"+cCH
_cQuery+= "			 D1_DTDIGIT, 	"+cCH
_cQuery+= "			 TES,  	"+cCH
_cQuery+= "			 D1_QUANT,       	"+cCH
_cQuery+= "			 D1_VUNIT,      	"+cCH
_cQuery+= "			 D1_TOTAL,       	"+cCH
_cQuery+= "			 D1_VALIMP5,     	"+cCH
_cQuery+= "			 D1_VALIMP6,        	"+cCH
_cQuery+= "			 D1_VALIPI,         	"+cCH
_cQuery+= "			 D1_ICMSRET,     	"+cCH
_cQuery+= "			 D1_VALICM,    	"+cCH
_cQuery+= "			 ROYOUT,      	"+cCH
_cQuery+= "			 FRETE,   	"+cCH
_cQuery+= "			 CUSTO_TOTAL,    	"+cCH
_cQuery+= "			 CUSTO_UNITARIO,        	"+cCH
_cQuery+= "			 B9_CM1 AS B2_CM1	,	"+cCH //Custo do ulitmo fechamento
_cQuery+= "			 D1_FORNECE,	"+cCH
_cQuery+= "			 D1_LOJA,	"+cCH
_cQuery+= "			(CASE WHEN (B9_CM1) > CUSTO_UNITARIO THEN ((B9_CM1)-CUSTO_UNITARIO)/(B9_CM1) * 100  "+cCH
_cQuery+= "				  WHEN CUSTO_UNITARIO > (B9_CM1) THEN  (CUSTO_UNITARIO-(B9_CM1))/CUSTO_UNITARIO * 100 ELSE 100 END) VARIACAO	"+cCH

_cQuery+= "			 FROM (	"+cCH

_cQuery+= "		SELECT D1_FILIAL, 	"+cCH
_cQuery+= "				   D1_DOC, 	"+cCH
_cQuery+= "				   D1_SERIE,	"+cCH
_cQuery+= "				   D1_COD, 	"+cCH
_cQuery+= "			  	   D1_LOCAL, "+cCH
_cQuery+= "				   MAX(B1_MODELO) AS B1_MODELO,"+cCH
_cQuery+= "				   MAX(B1_DESC) AS B1_DESC,"+cCH
//_cQuery+= "				   MAX(B1_DESC) AS GRUPO_TRIB,"+cCH
_cQuery+= "				   D1_DTDIGIT,"+cCH
_cQuery+= "				   MAX(D1_TES) AS TES,"+cCH
_cQuery+= "				   SUM(D1_QUANT) AS D1_QUANT, "+cCH
_cQuery+= "				   SUM(D1_VUNIT) D1_VUNIT, "+cCH
_cQuery+= "				   SUM(D1_TOTAL) D1_TOTAL,"+cCH
_cQuery+= "				   SUM(D1_VALIMP5) AS D1_VALIMP5,"+cCH
_cQuery+= "				   SUM(D1_VALIMP6) AS D1_VALIMP6,"+cCH
_cQuery+= "				   SUM(D1_VALIPI) AS D1_VALIPI,"+cCH
_cQuery+= "				   SUM(D1_ICMSRET) AS D1_ICMSRET,"+cCH
_cQuery+= "				   SUM(D1_VALICM) AS D1_VALICM,"+cCH
_cQuery+= "				   SUM(ROYOUT) AS ROYOUT,"+cCH
_cQuery+= "				   SUM(FRETE) AS FRETE,"+cCH
_cQuery+= "				   ( SUM(D1_VALIPI) + SUM(D1_ICMSRET) + SUM(D1_VALIMP5) + SUM(D1_VALIMP6) + SUM(D1_TOTAL)+ SUM(ROYOUT)+SUM(FRETE)) AS CUSTO_TOTAL,"+cCH
_cQuery+= "				   ROUND(CASE WHEN SUM(D1_QUANT)>0 THEN ( SUM(D1_VALIPI)+ SUM(D1_ICMSRET) + SUM(D1_VALIMP5) + SUM(D1_VALIMP6) + SUM(D1_TOTAL)+ SUM(ROYOUT)+SUM(FRETE))/ SUM(D1_QUANT)ELSE 0 END,2) CUSTO_UNITARIO,"+cCH
_cQuery+= "				   MAX(SB9.B9_CM1) AS B9_CM1, "+cCH
_cQuery+= "				   MAX(D1_FORNECE) AS D1_FORNECE,"+cCH
_cQuery+= "				   MAX(D1_LOJA) AS D1_LOJA"+cCH

_cQuery+= "			FROM ("+cCH

_cQuery+= "			SELECT SD1.D1_FILIAL, "+cCH
_cQuery+= "				F8_NFORIG D1_DOC,"+cCH
_cQuery+= "				F8_SERORIG D1_SERIE, "+cCH
_cQuery+= "				SD1.D1_COD,"+cCH
_cQuery+= "				SD1.D1_LOCAL, "+cCH
_cQuery+= "				SD1.D1_DTDIGIT, "+cCH
_cQuery+= "				' ' AS D1_TES,"+cCH
_cQuery+= "				0 AS D1_QUANT, "+cCH
_cQuery+= "				0 D1_VUNIT, "+cCH
_cQuery+= "				0 D1_TOTAL, "+cCH
_cQuery+= "				SUM(SD1.D1_VALIMP5) AS D1_VALIMP5,"+cCH
_cQuery+= "				SUM(SD1.D1_VALIMP6) AS D1_VALIMP6,"+cCH
_cQuery+= "				0 AS D1_VALIPI,"+cCH
_cQuery+= "				0  AS D1_ICMSRET,"+cCH
_cQuery+= "				0  AS D1_VALICM,"+cCH
_cQuery+= "				CASE WHEN F8_TIPO='F' THEN 0  ELSE SUM(D1_TOTAL) END AS ROYOUT,		"+cCH
_cQuery+= "				CASE WHEN F8_TIPO='D' THEN 0  ELSE SUM(D1_TOTAL)+SUM(D1_ICMSRET) END AS FRETE,	"+cCH
_cQuery+= "				MAX(D1_FORNECE) AS D1_FORNECE,"+cCH
_cQuery+= "				MAX(D1_LOJA) AS D1_LOJA"+cCH

_cQuery+= "			FROM (	"+cCH

_cQuery+= "			SELECT DISTINCT F8_FILIAL, F8_NFDIFRE, F8_SEDIFRE, F8_FORNECE, F8_LOJA, F8_TIPO, F8_NFORIG, F8_SERORIG "+cCH
_cQuery+= "			FROM "+RetSqlName("SF1")+" SF1  (NOLOCK)	 LEFT JOIN "+RetSqlName("SF8")+"  SF8 (NOLOCK)	  ON SF1.F1_FILIAL = SF8.F8_FILIAL AND "+cCH
_cQuery+= "				SF1.F1_DOC = SF8.F8_NFORIG AND "+cCH
_cQuery+= "				SF1.F1_SERIE = SF8.F8_SERORIG AND "+cCH
_cQuery+= "				SF1.F1_FORNECE = SF8.F8_FORNECE AND "+cCH
_cQuery+= "				SF1.F1_LOJA = SF8.F8_LOJA AND"+cCH
_cQuery+= "				SF1.D_E_L_E_T_ = SF8.D_E_L_E_T_"+cCH
_cQuery+= "			WHERE SF1.D_E_L_E_T_=' '"+cCH
_cQuery+= "			 	AND SF1.F1_TIPO='N'"+cCH
_cQuery+= "				AND SF1.D_E_L_E_T_=' '"+cCH
_cQuery+= "			) A  "+cCH
_cQuery+= "			 LEFT JOIN "+RetSqlName("SD1")+" SD1 (NOLOCK)  ON A.F8_FILIAL = SD1.D1_FILIAL AND "+cCH
_cQuery+= "				A.F8_NFDIFRE = SD1.D1_DOC AND "+cCH
_cQuery+= "				A.F8_SEDIFRE = SD1.D1_SERIE  "+cCH
_cQuery+= "			 LEFT JOIN "+RetSqlName("SF4")+"  SF4 (NOLOCK) ON SD1.D1_FILIAL = SF4.F4_FILIAL AND SD1.D1_TES = SF4.F4_CODIGO AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_"+cCH

_cQuery+= "				WHERE SD1.D_E_L_E_T_=' '  AND  SD1.D1_DTDIGIT =  (SELECT MAX(D1_DTDIGIT) FROM  "+RetSqlName("SD1")+"  AUX (NOLOCK) "+cCH

_cQuery+= "									WHERE AUX.D1_FILIAL=SD1.D1_FILIAL AND AUX.D1_COD= SD1.D1_COD AND AUX.D1_DTDIGIT<='"+cDtFecha+"' AND AUX.D1_TIPO='N' "+cCH

_cQuery+= "									AND D_E_L_E_T_=' ' )  "+cCH

_cQuery+= "			GROUP BY  SD1.D1_FILIAL, SD1.D1_COD, SD1.D1_LOCAL, A.F8_NFORIG, A.F8_SERORIG,F8_TIPO,SD1.D1_DTDIGIT, D1_COD"+cCH

_cQuery+= "			UNION ALL"+cCH

_cQuery+= "			SELECT  SD1.D1_FILIAL, "+cCH
_cQuery+= "				SD1.D1_DOC DOC, "+cCH
_cQuery+= "				SD1.D1_SERIE SERIE,"+cCH
_cQuery+= "				SD1.D1_COD, "+cCH
_cQuery+= "				SD1.D1_LOCAL, "+cCH
_cQuery+= "				SD1.D1_DTDIGIT, "+cCH
_cQuery+= "				MAX(D1_TES) AS D1_TES,"+cCH
_cQuery+= "				SUM(SD1.D1_QUANT) D1_QUANT, "+cCH
_cQuery+= "				SUM(D1_VUNIT) D1_VUNIT, "+cCH
_cQuery+= "				SUM(D1_TOTAL) D1_TOTAL,"+cCH
_cQuery+= "				SUM(SD1.D1_VALIMP5) AS D1_VALIMP5,"+cCH
_cQuery+= "				SUM(SD1.D1_VALIMP6) AS D1_VALIMP6,"+cCH
_cQuery+= "				SUM(SD1.D1_VALIPI) D1_VALIPI, "+cCH
_cQuery+= "				SUM(SD1.D1_ICMSRET) D1_ICMSRET,"+cCH
_cQuery+= "				SUM(SD1.D1_VALICM) D1_VALICM,"+cCH
_cQuery+= "				0 AS ROYOUT,"+cCH
_cQuery+= "				0 FRETE, "+cCH
_cQuery+= "				MAX(D1_FORNECE) AS D1_FORNECE,"+cCH
_cQuery+= "				MAX(D1_LOJA) AS D1_LOJA"+cCH
_cQuery+= "			FROM  "+RetSqlName("SD1")+"  (NOLOCK) SD1 "+cCH
_cQuery+= "			WHERE SD1.D_E_L_E_T_=' '"+cCH

_cQuery+= "			AND  SD1.D1_DTDIGIT = (SELECT MAX(D1_DTDIGIT) FROM  "+RetSqlName("SD1")+"  (NOLOCK) AUX"+cCH

_cQuery+= "									WHERE AUX.D1_FILIAL=SD1.D1_FILIAL AND D1_COD= SD1.D1_COD AND AUX.D1_DTDIGIT<='"+cDtFecha+"' AND AUX.D1_TIPO='N' "+cCH
_cQuery+= "									AND AUX.D_E_L_E_T_=' ') "+cCH

_cQuery+= "			AND D1_TIPO='N' "+cCH

_cQuery+= "			GROUP BY SD1.D1_FILIAL, SD1.D1_DOC,SD1.D1_SERIE, SD1.D1_COD,SD1.D1_LOCAL, SD1.D1_DTDIGIT"+cCH
_cQuery+= "			)B  LEFT JOIN  "+RetSqlName("SB9")+" SB9  (NOLOCK)  ON D1_FILIAL= SB9.B9_FILIAL AND D1_COD = SB9.B9_COD AND SB9.D_E_L_E_T_=' '  AND B9_LOCAL=D1_LOCAL AND SB9.B9_DATA='"+cDtFecha+"' "+cCH

_cQuery+= "			LEFT JOIN  "+RetSqlName("SB1")+" SB1  (NOLOCK)   ON SUBSTRING(D1_FILIAL,1,2) = B1_FILIAL AND D1_COD = B1_COD AND SB1.D_E_L_E_T_=' '"+cCH
_cQuery+= "			LEFT JOIN  "+RetSqlName("SF4")+" SF4 (NOLOCK)   ON D1_FILIAL= SF4.F4_FILIAL AND D1_TES= SF4.F4_CODIGO AND SF4.D_E_L_E_T_=' '"+cCH

_cQuery+= "			WHERE  B1_MSBLQL='2'  AND  B9_CM1 != 0 	"+cCH

_cQuery+= "			GROUP BY D1_FILIAL, D1_DOC, D1_SERIE, D1_COD,D1_LOCAL, D1_DTDIGIT"+cCH
_cQuery+= "		 ) C	"+cCH
_cQuery+= "         WHERE (CASE WHEN B9_CM1 > 0 THEN (B9_CM1-CUSTO_UNITARIO)/B9_CM1 * 100 ELSE "+Str(nPercent)+" END >="+Str(nPercent)+" OR	"+cCH
_cQuery+= " (CASE WHEN CUSTO_UNITARIO > 0 THEN (CUSTO_UNITARIO-B9_CM1)/CUSTO_UNITARIO * 100 ELSE "+Str(nPercent)+" END >="+Str(nPercent)+") )    	"+cCH
_cQuery+= "   AND D1_FILIAL='"+xFilial("SD1")+"'     AND   CUSTO_UNITARIO !=0	"+cCH


TCQUERY _cQuery ALIAS TMPWFCUS NEW
dbSelectArea("TMPWFCUS")
dbGoTop()



If TMPWFCUS->(EOF())
   //ConOut("A Query nao retornou dados - fonte WFCUSTDV.prw")
Endif

While !(TMPWFCUS->(EOF()))
	aadd(_aCusto,{TMPWFCUS->D1_FILIAL ,  TMPWFCUS->D1_COD, TMPWFCUS->B1_MODELO, AllTrim(TMPWFCUS->B1_DESC), TMPWFCUS->D1_DOC, TMPWFCUS->D1_SERIE,TMPWFCUS->D1_DTDIGIT, ;
	TMPWFCUS->CUSTO_UNITARIO, TMPWFCUS->B2_CM1,TMPWFCUS->D1_FORNECE,TMPWFCUS->D1_LOJA,TMPWFCUS->VARIACAO })
	//				 								 1					  						 2				 						  3				    							 4				    					  5				          6				      7				          8		             9
	TMPWFCUS->(dbSkip() )
EndDo

Return _aCusto

Static Function EnvMail(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo)
Local _cMailS		:= GetMv("MV_RELSERV")
Local _cAccount		:= GetMV("MV_RELACNT")
Local _cPass		:= GetMV("MV_RELFROM")
Local _cSenha2		:= GetMV("MV_RELPSW")
Local _cUsuario2	:= GetMV("MV_RELACNT")
Local lAuth			:= GetMv("MV_RELAUTH",,.F.)
Local _xx
Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult

If lAuth		// Autenticacao da conta de e-mail
	lResult := MailAuth(_cUsuario2, _cSenha2)
	If !lResult
	   //	Alert("NÑo foi possivel autenticar a conta - " + _cUsuario2)	//Ö melhor a mensagem aparecer para o usu∑rio do que no console ou no log.txt - Poliester
       //LGS#20200214 - AdequaÁ„o de release 12.1.25 e posteriores
       //ConOut("Nao foi possivel autenticar a conta - " + _cUsuario2)
       FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "Nao foi possivel autenticar a conta - " + _cUsuario2, 0 )
		Return()
	EndIf
EndIf

_xx := 0

lResult := .F.

do while !lResult

	If !Empty(_cAnexo)
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody ATTACHMENT _cAnexo RESULT lResult
	Else
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody RESULT lResult
	Endif

	_xx++
	if _xx > 2
		Exit
	Else
		Get Mail Error cErrorMsg
       //LGS#20200214 - AdequaÁ„o de release 12.1.25 e posteriores
       //ConOut(cErrorMsg)
       FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', cErrorMsg, 0 )
	EndIf
EndDo

Return lResult