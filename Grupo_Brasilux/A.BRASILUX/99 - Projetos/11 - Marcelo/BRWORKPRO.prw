#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | BRWORKPRO        | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Jose Uliana	 					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 30/09/2019   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função destinada ao envio de e-mails de aviso para o PCP de	|
    |               Produtos que tem saldo e não foram vendidos a mais de seis  |
    |               Meses														|
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/         
User Function BRWORKPRO()
   
//    Local cPara    	:= "joseuliana@brasilux.com.br"
    Local cPara     := "grpestoque@brasilux.com.br" //"michelly@brasilux.com.br,tiagobianchi@brasilux.com.br,gustavo@brasilux.com.br,mirinho@brasilux.com.br,ramon@brasilux.com.br,edevilson@brasilux.com.br"
    Local cAssunto  := "PRODUTOS QUE TÊM SALDO, MAS NÃO FORAM VENDIDOS HÁ MAIS DE 6 MESES"
    Local cMsg		:= ""
    Local cQuery    := ""
    //Local TM1
    
    PREPARE ENVIRONMENT  EMPRESA "01" FILIAL "010101" 

    cQuery := ""
    cQuery += " SELECT SD2.D2_COD AS 'VPRODUTO', SB1.B1_DESC AS 'VDESCRICAO', SB2.B2_LOCAL AS 'VLOCALIZ', "
    cQuery += " SB2.B2_QATU AS 'VSALDO', "
    cQuery += " DATEDIFF(MONTH,MAX(SD2.D2_EMISSAO),GETDATE()) AS 'VMESES', MAX(SD2.D2_EMISSAO) AS 'VULTSAIDA' " 
    cQuery += " FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK) "
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = SD2.D2_FILIAL AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_ ='' " 
    cQuery += " LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH(NOLOCK) ON SD2.D2_FILIAL = SB2.B2_FILIAL AND SD2.D2_COD = SB2.B2_COD AND SB2.D_E_L_E_T_ ='' "
    cQuery += " WHERE SD2.D_E_L_E_T_ ='' AND SD2.D2_FILIAL ='010101' AND (SD2.D2_ESTOQUE ='S' OR SD2.D2_XESTOQU ='S') "
    cQuery += " AND SB2.B2_QATU > 0 AND SB1.B1_TIPO IN('PA') AND SB1.B1_GRUPO BETWEEN('PA01') AND ('PI99') "
    cQuery += " GROUP BY SD2.D2_COD, SB1.B1_DESC, SB2.B2_LOCAL, SB2.B2_QATU "
    cQuery += " HAVING DATEDIFF(MONTH,MAX(SD2.D2_EMISSAO),GETDATE())> 6 "
    cQuery += " ORDER BY SB2.B2_LOCAL, DATEDIFF(MONTH,MAX(SD2.D2_EMISSAO),GETDATE()) DESC, SD2.D2_COD
 

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
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>PRODUTO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRIÇÃO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>LOCAL</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>ULT. SAÍDA</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>MESES</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SALDO</th>"

	cMsg+="</tr>"    
	      
   	DbSelectArea("TM1")
           	 //#FFD7D7   #ECFFEC
   	While TM1->(!eof())
		
		cMsg+="<tr>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->VPRODUTO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->VDESCRICAO+"</td>"
		cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+TM1->VLOCALIZ+"</td>"
     	cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim(TM1->VULTSAIDA)+"</td>" 
    	cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(TM1->VMESES,"@E 99999")+"</td>"		
    	cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(TM1->VSALDO,"@E 99999")+"</td>"	

		cMsg+="</tr>"
	    
	    TM1->(dbSkip())
  	EndDo
   
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>BRWORKPRO</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 

    DbSelectArea("TM1")
    DbCloseArea() 
    
    U_EnvMail(cAssunto, cMsg, cPara)
  	
  	RESET ENVIRONMENT 

Return
