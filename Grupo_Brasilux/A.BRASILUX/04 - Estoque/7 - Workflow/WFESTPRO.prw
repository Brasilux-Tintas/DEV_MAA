#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
	+---------------------------------------------------------------------------+
	+ Funcao    | WFESTPRO         | Função de Workflow					   	    |
	+-----------+----------+-------+-----------------------+------+-------------+ 
	+ Autor 	| Cleiton Fernandes					                            | 
	+-----------+----------+-------+-----------------------+------+-------------+
	+ Data 		| 02/02/16   													|
	+-----------+----------+-------+-----------------------+------+-------------+
	|                                                                           |
    | Descricao:	Função de WorkFlow para envio de mensagem por email	 	  	|
    |               saldo os almoxarifados Provisorios (P1,P2,P3,R0,D1)         |
	+-----------+------------------------------------------+------+-------------+ 
	| USO  AP        				    									   	|                                      						    
	+---------------------------------------------------------------------------+  
*/    
         
User Function WFESTPRO()
   
	 Local cPara    			 	:= "materiais@brasilux.com.br;expedicao@brasilux.com.br"
	 Local cAssunto				    := "Verificar as divergências abaixo"
     Local cMsg						:= ""
   
     PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010101" //TABLES "SB2"   	
     
                
    /**	Monta a query para buscar os dados	**/   
     cQuery:=" 	SELECT B2_FILIAL AS FILIAL,B2_COD AS PRODUTO,B2_LOCAL AS ALMOXARIFADO,B2_QATU AS QUANTIDADE"
     cQuery+=" 	FROM "+ RetSqlName("SB2")+" SB2  WITH (NOLOCK)"
	 cQuery+=" 	WHERE SB2.D_E_L_E_T_='' AND B2_QATU > '0' AND B2_LOCAL IN ('P1','P2','P3','R0','D1','98') AND B2_FILIAL IN('010101')" 	
	 cQuery+="	ORDER BY B2_FILIAL,B2_LOCAL,B2_COD"  
       
     TcQuery cQuery ALIAS "TMP" NEW   
      
	 DbSelectArea("TMP")        

   	If eof() //se o arquivo estiver vazio, sai da rotina
   		 Return()
   	Endif
	  	cMsg+="."
	  	cMsg+="<html>"       
		cMsg+="<body>"
		cMsg+="<table width='1000' height='92' border='#99CCFF'>"
		cMsg+="<th bgcolor='#99CCFF' scope='col'>FILIAL</th>"
		cMsg+="<th bgcolor='#99CCFF' scope='col'>PRODUTO</th>"
		cMsg+="<th bgcolor='#99CCFF' scope='col'>ALMOXARIFADO</th>"
		cMsg+="<th bgcolor='#99CCFF' scope='col'>QUANTIDADE</th>"
		cMsg+="</tr>" 
	
	While !eof()                                               
	   
		cMsg+="<tr>"
		cMsg+="<td bgcolor='#CCFFFF'align=center>"+TMP->FILIAL+"</td>"
		cMsg+="<td bgcolor='#CCFFFF'align=center>"+TMP->PRODUTO+"</td>"   
		cMsg+="<td bgcolor='#CCFFFF'align=center>"+Alltrim(TMP->ALMOXARIFADO)+"</td>"
		cMsg+="<td bgcolor='#CCFFFF'align=center>"+str(TMP->QUANTIDADE)+"</td>" 
		cMsg+="</tr>"
	   
   DbSelectArea("TMP")
   dbSkip()
  End
  
  DbCloseArea("TMP")
  
  U_EnvMail(cAssunto, cMsg, cPara)	                                                          

  RESET ENVIRONMENT 

Return