#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 
/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFPALLET         | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| André Maester 					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 23/10/19   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função destinada ao envio de e-mails de aviso para a expedi	|
    |               ção dos pallets que contem itens bipados com saída do depósi|
    |               to em SP e não foram transferidos via nota fiscal.			|
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/         
User Function WFPALLET()
   
    Local cPara    	:= "expedicao@brasilux.com.br"
    Local cAssunto  := "Pallets que contem pedido com saída pelo depósito sem transferência entre filiais."
    Local cMsg		:= ""
    Local cQuery    := ""
    //Local TM1

    
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 

    cQuery := ""
    cQuery += " SELECT DISTINCT ZZJ_CODIGO AS 'PALLET', ZG_CODIGO AS 'BORDERO', " 
    cQuery += " CASE WHEN ZF_TIPOBOR ='1' THEN '1 - ) AGLUTINADO'      ELSE " 
    cQuery += " CASE WHEN ZF_TIPOBOR ='2' THEN '2 - ) DEPOSITO'        ELSE "
    cQuery += " CASE WHEN ZF_TIPOBOR ='3' THEN '3 - ) REGIÃO-RETIRA'   ELSE "
    cQuery += " CASE WHEN ZF_TIPOBOR ='4' THEN '4 - ) EXPORTAÇÃO'      ELSE "
    cQuery += " CASE WHEN ZF_TIPOBOR ='5' THEN '5 - ) CARGA FECHADA'   ELSE "
    cQuery += " CASE WHEN ZF_TIPOBOR ='6' THEN '6 - ) AMOSTRA'         ELSE "
    cQuery += " CASE WHEN ZF_TIPOBOR ='7' THEN '7 - ) VOLUME QUEBRADO' ELSE "
    cQuery += " CASE WHEN ZF_TIPOBOR ='8' THEN '8 - ) CARGA MATRIZ'    END END END END END END END END AS 'TIPOBORD', "
    cQuery += " ZZK.ZZK_PEDIDO AS 'PEDIDO' " 
    cQuery += " FROM "+RetSqlName("ZZK")+" ZZK WITH(NOLOCK) " 
    cQuery += " LEFT OUTER JOIN "+RetSqlName("ZZJ")+" ZZJ WITH(NOLOCK) ON ZZJ_FILIAL = ZZK_FILIAL AND ZZJ_CODIGO = ZZK_CODIGO AND ZZJ.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) ON C5_FILIAL  = ZZK_FILIAL AND C5_NUM  = ZZK_PEDIDO AND SC5.D_E_L_E_T_ =''  "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SC6")+" SC6 WITH(NOLOCK) ON C6_FILIAL  = C5_FILIAL  AND C6_NUM  = C5_NUM AND SC6.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH(NOLOCK) ON ZG_FILIAL  = ZZK_FILIAL AND SUBSTRING(ZG_PEDIDO,3,6) = ZZK_PEDIDO AND SZG.D_E_L_E_T_ ='' "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SZF")+" SZF WITH(NOLOCK) ON ZF_FILIAL  = ZG_FILIAL  AND ZF_CODIGO = ZG_CODIGO AND SZF.D_E_L_E_T_ ='' "
    cQuery += " WHERE ZZK_PEDIDO <>'' AND ZZK.D_E_L_E_T_ ='' AND (C5_TRANSP IN('00700','00573'))  AND ZZJ_CARGA ='' "
    cQuery += " AND ZZK_FILIAL ='010101' AND DATEDIFF(MONTH,ZZJ_DTINI,GETDATE())<=1 AND SUBSTRING(C6_LOCAL,1,1) ='G' "
    cQuery += " ORDER BY ZZJ_CODIGO "  

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
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PALLET</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>BORDERO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO BORDERO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PEDIDO</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	DbSelectArea("TM1")
   	While TM1->(!eof())
		
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->PALLET+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->BORDERO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->TIPOBORD+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->PEDIDO+"</td>" 
		cMsg+="</tr>"
	    
	    TM1->(dbSkip())
  	EndDo
  
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFPALLET</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT 

Return
