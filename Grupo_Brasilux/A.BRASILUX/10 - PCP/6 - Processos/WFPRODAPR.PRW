#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
*/         
User Function WFPRODAPR()

    Local cPara    	:= ""
    Local cAssunto  := "Produtos aprovados na rotina de Simulação em "+Dtoc(Date())
    Local cMsg		:= ""
    Local cQuery    := ""

    
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
    cPara := GETMV("ZP_PAR0101")
    
    cQuery := ""
    cQuery += " WITH TMP AS( "
    cQuery += " SELECT DISTINCT SZT.ZT_FILIAL AS 'FILIAL', SZT.ZT_USUARIO AS 'APROVADOR', SZT.ZT_DATAGER AS DATAGER, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), SZT1.ZT_LOG)),'') AS LOG, "
    cQuery += " SUBSTRING(SZT.ZT_DATAGER,7,2)+'/'+SUBSTRING(SZT.ZT_DATAGER,5,2)+'/'+SUBSTRING(SZT.ZT_DATAGER,1,4) AS 'DATAAPR',  "
    cQuery += " ZM_RESPONS AS 'CADASTRADO', TRIM(ZM_CODIGO) AS 'CODIGO',TRIM(ZM_CODIGO)+' - '+(ZM_DESCRIC) AS 'PRODUTO', ZM_TIPO AS 'TIPO', ZM_TIPOPRO AS 'TIPOPRO', ZM_REVISAO AS 'REVATUAL', "
    cQuery += " CASE WHEN ZM_TIPOPRO = 'PE' THEN REPLICATE('0', (3-LEN(TRIM(ZM_REVISAO)-1))) + RTrim(ZM_REVISAO-1) ELSE '000' END AS 'REVANT' "
    cQuery += " FROM "+RetSqlName("SZT")+" SZT WITH (NOLOCK)  "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SZM")+" SZM  WITH(NOLOCK) ON ZM_FILIAL = SZT.ZT_FILIAL AND SZT.ZT_ID = ZM_ID AND SZM.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SZT")+" SZT1 WITH(NOLOCK) ON ZM_FILIAL = SZT1.ZT_FILIAL AND SZT1.ZT_ID = ZM_ID AND SZT1.ZT_STATUS ='EE' AND SZT1.ZT_PROCESS ='SI' AND SZT1.D_E_L_E_T_ ='' "
	cQuery += " WHERE SZT.D_E_L_E_T_ =''  "
    cQuery += " AND SZT.ZT_STATUS ='AC'  "
    cQuery += " AND ZM_TIPOPRO ='PE' "
	cQuery += " AND SZT.ZT_DATAGER > '20230501') "
    cQuery += " SELECT DATAGER, FILIAL, APROVADOR, DATAAPR, CADASTRADO, PRODUTO, TIPO, TIPOPRO, REVATUAL, REVANT,SUBSTRING(LOG,26,50) AS JUST, "//CASE WHEN REVANT <> '000' THEN 1 ELSE 1 END AS 'CUSTOANT',  1 AS 'CUSTOATUAL', 1 / (CASE WHEN REVANT <> '000' THEN 0.9 ELSE 1.1 END)-1 *100 AS 'VARIAC' FROM TMP  WHERE DATAAPR =FORMAT(CONVERT(DATETIME,(GETDATE()-88)), 'dd/MM/yyyy')  ORDER BY FILIAL, TIPOPRO DESC, PRODUTO "
    cQuery += " CASE WHEN REVANT <> '000' THEN ROUND(dbo.CustoMpSZN(FILIAL,CODIGO,1,REVANT),2) ELSE ROUND(dbo.CustoMp(FILIAL,CODIGO,1),2) END AS 'CUSTOANT', "
    cQuery += " ROUND(dbo.CustoMp(FILIAL,CODIGO,1),2) AS 'CUSTOATUAL', "
    cQuery += " ROUND(((dbo.CustoMp(FILIAL,CODIGO,1) / (CASE WHEN REVANT <> '000' THEN dbo.CustoMpSZN(FILIAL,CODIGO,1,REVANT) ELSE  dbo.CustoMp(FILIAL,CODIGO,1) END)-1) *100),2) AS 'VARIAC'FROM TMP "
    cQuery += " WHERE CONVERT(DATE, DATAGER ,103) = CONVERT(DATE, (GETDATE()-1), 103)  "
    cQuery += " ORDER BY FILIAL, TIPOPRO DESC, PRODUTO "

	TcQuery cQuery ALIAS "TM1" NEW   
	DbSelectArea("TM1")        

	If TM1->(eof()) //se o arquivo estiver vazio, sai da rotina
		TM1->(DbCloseArea()) 
		Return()
	EndIf		
    
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font-size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FILIAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CADASTRADO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>APROVADOR</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>REVISÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CUSTO ANT.</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CUSTO ATUAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VARIAÇÃO %</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>JUSTIFICATIVA</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
	DbSelectArea("TM1")
	While TM1->(!eof())
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->FILIAL+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->CADASTRADO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->APROVADOR+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->PRODUTO+"</td>" 
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->REVATUAL+"</td>"		
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM1->CUSTOANT,'@E 99999.99')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM1->CUSTOATUAL,'@E 99999.99')+"</td>"
        If TM1->CUSTOATUAL > TM1->CUSTOANT
            cMsg+="<td  style='color: rgb(0, 0, 0); background-color: red;' >"+TRANSFORM(TM1->VARIAC,'@E 99999.99')+"</td>"
		Elseif TM1->CUSTOATUAL < TM1->CUSTOANT
            cMsg+="<td  style='color: rgb(0, 0, 0); background-color: green;' >"+TRANSFORM(TM1->VARIAC,'@E 99999.99')+"</td>"
        Else
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM1->VARIAC,'@E 99999.99')+"</td>"
		Endif
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->JUST+"</td>"
        cMsg+="</tr>"
		TM1->(dbSkip())
	EndDo

	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFPRODAPR</p>"
	cMsg+="</footer>"
	cMsg+="</body>"
	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)

	RESET ENVIRONMENT 

Return
