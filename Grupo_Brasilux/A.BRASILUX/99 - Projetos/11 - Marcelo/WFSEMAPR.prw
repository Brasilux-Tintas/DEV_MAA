#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

       
User Function WFSEMAPR()                                                        
   
    Local cPara    	:= "andre@brasilux.com.br;marcelopaiva@brasilux.com.br"
    Local cAssunto  := "Produtos transferidos sem aprovação"
    Local cMsg		:= ""

	 PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
     

     /**	Monta a query para buscar os dados	**/   
	cTmp := U_NovoCursor()    
    cQuery := ""
    
    cQuery += " SELECT D3_FILIAL, D3_COD, B1_DESC, D3_LOCAL, D3_TIPO, D3_QUANT, D3_USUARIO, SUBSTRING(D3_EMISSAO,7,2)+'/'+SUBSTRING(D3_EMISSAO,5,2)+'/'+SUBSTRING(D3_EMISSAO,1,4) AS D3_EMISSAO "
    cQuery += " FROM "+RetSqlName("SD3")+" SD3  WITH(NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON B1_FILIAL = D3_FILIAL AND B1_COD = D3_COD AND SB1.D_E_L_E_T_ ='' "
    cQuery += " WHERE D3_FILIAL ='010101'"
    cQuery += " AND D3_ESTORNO <>'S' AND D3_CF ='DE4' AND D3_TM ='499'  
	cQuery += " AND D3_LOCAL IN('R1','R2','01','10','70','02','20') AND D3_USUARIO <>'' "
	cQuery += " AND D3_XAPROVA = '' AND D3_NUMSERI = '' "
	cQuery += " AND D3_EMISSAO ='20160704' "
	cQuery += " ORDER BY D3_FILIAL,D3_LOCAL, D3_COD "

	TcQuery cQuery ALIAS (cTmp) NEW   
	DbSelectArea(cTmp)        
    /**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FILIAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CODIGO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRICAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOCAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>TIPO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>QUANTIDADE</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>USUARIO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>EMISSAO</th>"
	cMsg+="</tr>"    
    //#FFD7D7   #ECFFEC
   	If (cTmp)->(eof()) 
   	
   	//se o arquivo estiver vazio, sai da rotina
   		 (cTmp)->(DbCloseArea())                                                       	
   		 Return()
   	EndIf		
   	dbselectarea(cTmp)
   	While !eof()
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_FILIAL)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_COD)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->B1_DESC)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_LOCAL)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_TIPO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TRANSFORM((cTmp)->D3_QUANT,'@E 99999')+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_USUARIO)+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->D3_EMISSAO)+"</td>"
		cMsg+="</tr>"
  
	    (cTmp)->(dbSkip())
  	End
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFAPED</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
	cMsg+="</table>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
 	(cTmp)->(DbCloseArea()) 
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT