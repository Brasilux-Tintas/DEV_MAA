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
	+ Data 		| 15/12/17   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               dos pedidos que estão endereçados e deletados ou ainda dos  |
    |               pedidos que foram faturados e ainda não despachados a 4 dias| 
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  

*/
User Function WFCOMCLI()

    Local cPara    	:= "vendas@brasilux.com.br;andre@brasilux.com.br"
    Local cAssunto  := "Maquinas comodato com vendas negativas ( Mês referência "+SUBSTR(DTOS(date()),5,2)+'/'+SUBSTR(DTOS(date()),1,4)+" )" 
    Local cMsg		:= ""
	Local cAuxCli	:= ""
	Local cAuxPro 	:= ""
	Local fCalcM	:= 0
	Local cCliente	:= ""
	Local cCodProd 	:= ""
	Local cRazao	:= ""
	Local cDescri 	:= ""
	Local cEstado   := ""
    Local cQuery    := ""
    
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" 
     

     /**	Monta a query para buscar os dados	**/   
	
    cQuery := "EXEC BRCOMODATODETVEND '','','' "                                                                             	
    
	TcQuery cQuery ALIAS "TCQ" NEW   
	DbSelectArea("TCQ")        
   
	/**		Monta o script HTML para ser enviado por email 	**/        
	
    
    cMsg:="<html>"
	cMsg+="<body>"
	cMsg+="<table width='1400' height='92' border='0' font size='1'>"
	cMsg+="<tr><th height='30'  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>CODIGO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>RAZAO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>ESTADO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>COD. PRODUTO</th>" 
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>DESCRICAO</th>"
	cMsg+="<th  style='color: rgb(255, 255, 255); background-color: rgb(0, 0, 0);'  scope='col'>SALDO</th>"
	cMsg+="</tr>"    
	        //#FFD7D7   #ECFFEC
   	If eof() //se o arquivo estiver vazio, sai da rotina
   		 dbCloseArea()
   		 Return()
   	EndIf
    
    
    if (u_UltDiaMes(VAL(SUBSTR(DTOS(date()),5,2)),VAL(SUBSTR(DTOS(date()),1,4))) != date())
    	dbCloseArea()
        Return()
    EndIf
    
   	dbselectarea("TCQ")
   	While !eof()
	    fCalcM := TCQ->VLRMES - TCQ->COTAMES
	    if(alltrim(TCQ->CODCLI) != "" )
	    	cCliente	:= Alltrim(TCQ->CODCLI)
	    	cRazao		:= Alltrim(TCQ->RAZAO)
	    	cCodProd 	:= Alltrim(TCQ->CODPROD)
			cDescri 	:= Alltrim(TCQ->NOMEMAQ)
			cEstado     := POSICIONE( "SA1",1,xFilial("SA1")+cCliente, "A1_EST" )
	    endif
	    if((cAuxCli != cAuxCli .OR. cCodProd != cAuxPro)  .AND. TCQ->MES ==  (SUBSTRING(DTOS(date()),0,6)) .AND. fCalcM < 0) 
	    	cMsg+="<tr>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+cCliente+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+cRazao+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+cEstado+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+cCodProd+"</td>"
			cMsg+="<td  style='color: rgb(0, 0, 0); background-color: rgb(198, 226, 255);' >"+cDescri+"</td>"
			cMsg+="<td  style='color: rgb(255, 0, 0); background-color: rgb(198, 226, 255);' >"+transform(fCalcM,"@E 99,999.99")+"</td>"
			cMsg+="</tr>"
			cAuxCli := cCliente
			cAuxPro := cCodProd
		EndIf
	    dbselectarea("TCQ")	 
	    dbskip() 
	End
	cMsg+="</table>"
	cMsg+="<footer>"
	cMsg+="<p height='50' width='1400' style='text-align:center; color: rgb(255, 255, 255); background-color:rgb(0, 0, 0);'  scope='col'>WFCOMCLI</p>"
	cMsg+="</footer>"
  	cMsg+="</body>"
  	cMsg+="</html>" 
  dbselectarea("TCQ")
  dbCloseArea()

 U_EnvMail(cAssunto, cMsg, cPara)

RESET ENVIRONMENT