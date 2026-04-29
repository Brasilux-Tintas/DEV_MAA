#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFDespa       | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Marcelo Paiva						                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 23/06/16   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               dos pedidos que estão endereçados e deletados ou ainda dos  |
    |               pedidos que foram faturados e ainda não despachados a 4 dias| 
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  

*/         
User Function PEPARADO()
   
    Local cPara    	:= ""
    Local cMsg		:= ""
    Local cQuery    := ""
    Local cQuery1   := ""
    Local _cFilial	:= ("010101","060101")
    
//    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101"
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL _cFilial

//Manutenção Sergio Magri 26/11/2024
	cPara := GETMV("ZP_PAR0102")
	cDias := Alltrim(GetMv("ZP_PAR0128"))

    cQuery := ""
    cQuery += " SELECT DISTINCT(C5_NUM), SUBSTRING(C5_FILIAL,1,2) as C5_FILIAL, C5_CLIENT, A1_NOME, SUBSTRING(C5_DTAPR,7,2)+'/'+SUBSTRING(C5_DTAPR,5,2)+'/'+SUBSTRING(C5_DTAPR,1,4) AS EMISSAO, DATEDIFF(D,C5_DTAPR,GETDATE()) AS 'DIAS', "
    cQuery += " ZA_CODIGO, SUBSTRING(ZA_PREVDSP,7,2)+'/'+SUBSTRING(ZA_PREVDSP,5,2)+'/'+SUBSTRING(ZA_PREVDSP,1,4) AS 'PREVISAO', ZA_DESCR  "  
    cQuery += " FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON C6_FILIAL = C5_FILIAL AND C5_NUM = C6_NUM AND C6_NOTA = C5_NOTA AND C6_SERIE = C5_SERIE AND SC6.D_E_L_E_T_ <> '*' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH(NOLOCK) ON A1_FILIAL = A1_FILIAL AND C5_CLIENT = A1_COD "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH(NOLOCK) ON ZB_FILIAL = C5_FILIAL AND SUBSTRING(ZB_PEDIDO,3,6) = C5_NUM AND SZB.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH(NOLOCK) ON ZA_FILIAL = ZB_FILIAL AND ZA_CODIGO = ZB_CODIGO AND SZA.D_E_L_E_T_ ='' "
	cQuery += " WHERE C5_FILIAL IN ('010101','060101') "
    //cQuery += " WHERE C5_FILIAL IN ('"+xFilial("SC5")+"') "
    cQuery += " AND SC5.D_E_L_E_T_ <> '*' AND C5_TIPO = 'N' "
    //cQuery += " AND C5_PEDPROG = '' "
    cQuery += " AND C5_NOTA = '' AND C5_APROVA = '1' AND C5_DTAPR > '' "
	cQuery += " AND DATEDIFF(D,CASE WHEN C5_PEDPROG = '' THEN C5_DTAPR ELSE C5_PEDPROG END,GETDATE()) >= ('"+cDias+"')"
    //cQuery += " AND DATEDIFF(D,CASE WHEN C5_PEDPROG = '' THEN C5_DTAPR ELSE C5_PEDPROG END,GETDATE()) > 4 "
	cQuery += " ORDER BY C5_FILIAL, DATEDIFF(D,C5_DTAPR,GETDATE()) DESC "

	TcQuery cQuery ALIAS "TM1" NEW
	DbSelectArea("TM1")
   
	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font-size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PEDIDO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FILIAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>RAZAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DT. APR.</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DIAS</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>BORDERO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PREVISAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FALTA</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QTD</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If TM1->(eof()) //se o arquivo estiver vazio, sai da rotina
   		 TM1->(DbCloseArea())
   		 Return()
   	EndIf		
   	DbSelectArea("TM1")
   	While TM1->(!eof())
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->C5_NUM)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->C5_FILIAL)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Substr(Alltrim(TM1->A1_NOME),1,30)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->EMISSAO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM1->DIAS,'@E 999')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Substr(Alltrim(TM1->ZA_DESCR),1,20)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->PREVISAO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
		cMsg+="</tr>"

	    cQuery1 := ""
        cQuery1 += " SELECT ZZC_PRODUT, (ZZC_QUANTI - ZZC_RETIRA) AS 'FALTA'" //, ZA_CODIGO, SUBSTRING(ZA_PREVDSP,7,2)+'/'+SUBSTRING(ZA_PREVDSP,5,2)+'/'+SUBSTRING(ZA_PREVDSP,1,4) AS 'PREVISAO', ZA_DESCR  "
        cQuery1 += " FROM "+RetSqlName("ZZC")+" ZZC WITH(NOLOCK) "
    	//cQuery1 += " LEFT OUTER JOIN "+RetSqlName("SZB")+" SZB WITH(NOLOCK) ON ZB_FILIAL = ZZC_FILIAL AND SUBSTRING(ZB_PEDIDO,3,6) = ZZC_PEDIDO AND SZB.D_E_L_E_T_ ='' "
    	//cQuery1 += " LEFT OUTER JOIN "+RetSqlName("SZA")+" SZA WITH(NOLOCK) ON ZA_FILIAL = ZB_FILIAL AND ZA_CODIGO = ZB_CODIGO AND SZA.D_E_L_E_T_ ='' "
        //cQuery1 += " WHERE ZZC_FILIAL ='"+xFilial("ZZC")+"' "
        cQuery1 += " WHERE ZZC_FILIAL IN ('010101','060101') "
		cQuery1 += " AND ZZC_PEDIDO ='"+TM1->C5_NUM+"'"
        cQuery1 += " AND ZZC.D_E_L_E_T_ ='' "
        cQuery1 += " AND (ZZC_QUANTI - ZZC_RETIRA) <> 0 "
        cQuery1 += " ORDER BY ZZC_PRODUT "

		TcQuery cQuery1 ALIAS "TM2" NEW
		DbSelectArea("TM2")
	   	While TM2->(!eof())
		
			cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+''+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM2->ZZC_PRODUT)+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM(TM2->FALTA,'@E 9999')+"</td>"
			cMsg+="</tr>"

		    TM2->(dbSkip())
	  	EndDo
	  	DbSelectArea("TM2")
	  	DbCloseArea()

	  
	    TM1->(dbSkip())
  	EndDo
  	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>PEPARADO</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
  
	cMsg+="</table>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail("Pedidos aprovados e não faturados há mais de "+cDias+" dias", cMsg, cPara)
  	
  	RESET ENVIRONMENT
 
Return
 