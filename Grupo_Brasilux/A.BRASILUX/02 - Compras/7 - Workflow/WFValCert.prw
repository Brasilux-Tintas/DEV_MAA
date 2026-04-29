#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*/{Protheus.doc} WFValCert
Envio de e-mail referente a validade de certificado de fornecedores de compras Certificado ISO a Vencer ou vencidos
@type function
@version  v2022.001
@author Luís Gustavo Souza
@since 08/02/2023
/*/
User Function WFValCert()
     Local cPara    := "" //"compras@brasilux.com.br;thiago@brasilux.com.br"  //lista de rementes 
     Local cAssunto := "CERTIFICADOS ISO DE FORNECEDORES ( VENCIDOS OU A VENCER )"
     Local cMsg     := ""

     PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" //TABLES "SB2"   
             u_zcfga01( 'WFVALCERT' ) //LGS#2021118 - Gravação de log de utilização da rotina
             cPara := GetMV('ZP_PAR0083')
             /** Monta a query para buscar os dados **/   
             cTmp := U_NovoCursor()
             cQuery := ""
             cQuery += " SELECT A2_COD, A2_NOME, A2_EMAIL, SUBSTRING(A2_VALCERT,7,2)+'/'+SUBSTRING(A2_VALCERT,5,2)+'/'+SUBSTRING(A2_VALCERT,1,4) AS 'A2_VALCERT', SUBSTRING(A2_ULTCOM,7,2)+'/'+SUBSTRING(A2_ULTCOM,5,2)+'/'+SUBSTRING(A2_ULTCOM,1,4) AS 'A2_ULTCOM' "
             cQuery += " FROM "+RetSqlName("SA2")+" WITH (NOLOCK) "
             cQuery += " WHERE D_E_L_E_T_ ='' AND A2_VALCERT <>'' AND DATEDIFF(DAY ,GETDATE(),A2_VALCERT) <=30 AND A2_MSBLQL <>'1' "
             cQuery += " ORDER BY DATEDIFF(DAY ,GETDATE(),A2_VALCERT) "

             TcQuery cQuery ALIAS (cTmp) NEW   
             DbSelectArea(cTmp)        

             /** Monta o script HTML para ser enviado por email **/        
             cMsg:="<html>"
             cMsg+="<body>"
             cMsg+="<table width='1400' height='92' border='0'>"
             cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CODIGO</th>"
             cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>FORNECEDOR</th>"
             cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>VALIDADE</th>" 
             cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>ÚLT. COMPRA</th>" 
             cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>E-MAIL FORNECEDOR</th>"
             cMsg+="</tr>"    
	         //#FFD7D7   #ECFFEC
             If !(cTmp)->(eof()) //se o arquivo estiver vazio, sai da rotina
                dbselectarea(cTmp)
                While !eof() 
                      cMsg+="<tr>"
                      cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->A2_COD)+"</td>"    
                      cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Substr(Alltrim((cTmp)->A2_NOME),1,40)+"</td>"
                      cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->A2_VALCERT)+"</td>"
                      cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->A2_ULTCOM)+"</td>"
                      cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+Alltrim((cTmp)->A2_EMAIL)+"</td>"
                      cMsg+="</tr>"
                      (cTmp)->(dbSkip())
                End
                cMsg+="</table>"
                cMsg+="</body>"
                cMsg+="</html>" 
                (cTmp)->(DbCloseArea()) 
  	         
                U_EnvMail(cAssunto, cMsg, cPara)
			 Endif
     RESET ENVIRONMENT

Return
