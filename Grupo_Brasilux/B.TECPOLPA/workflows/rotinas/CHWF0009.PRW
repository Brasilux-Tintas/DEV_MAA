#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±÷ííííííííííÛííííííííííøíííííííÛííííííííííííííííííííøííííííÛíííííííííííííô±±
±±?Programa =CHWF0009 - www.chaus.com.br       ? Data =  14/01/16	  	  ?±±
±±?Autor	=Dyego Figueiredo  								   	          ?±±
±±víííííííííí?ííííííííííÜííííííí?ííííííííííííííííííííÜíííííí?íííííííííííííp±±
±±?Desc     =Esta rotina monta um html com os pedidos de venda atrasados   ±±
±±?         = em carteira				 								  ?±±
±±víííííííííí?ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííp±±
±±?Uso      = AP                                                          ?±±
±±™íííííííííí?íííííííííííííííííííííííííííííííííííííííííííííííííííííííííííí?±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/
  
         
User Function CHWF0009( )
 
//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 //:= {}
Private cQLinha   := Chr(13) + Chr(10)
Private nomeFonte := "CHAUS009"

PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

Workflow( cEmpAnt,cFilAnt )   

Return			
	

 	 
	 
   
Static Function Workflow( _codEmp,_codFil)
Local dData   	:=DATE()                    
Local cAssunto	:= "WorkFlow dos pedidos de venda atrasados em carteira. Empresa "+_codEmp+ " Filial "+AllTrim(_codFil)+". Data: "+DTOC(dData)
   
Local cTitulo 	:= "Pedidos de venda atrasados em carteira"

//Local cMsgCorpo	:= " " //ExplicaÁ„o WF

Local cMsg		:= ""
Local cAnexo	:= ""  
//Local nCont     := 0                      '
//Local cQuery    := ""  
Local i, x
     
Local _aItens,_aTitulos, _aTamCol, _aMascara      
     
cQLinha :=  Chr(13) + Chr(10) 
	
//LGS#20200214 - Adequação de release 12.1.25 e posteriores
//ConOut("Inicio do fonte "+nomeFonte+".prw")
FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "Inicio do fonte "+nomeFonte+".prw", 0 )
      
cPara := GETMV("MV_XWF0009")


_aArrays := queryMain() 
   
_aItens 	:= _aArrays[1]
_aTitulos  	:= _aArrays[2]
_aTamCol 	:= _aArrays[3]
_aMascara 	:= _aArrays[4]
             
cQLinha := ""
           
If Len(_aItens) > 0                  

	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>" +cQLinha
	cMsg+="<head> 					"+cQLinha
	cMsg+="<STYLE TYPE='text/css'> 	"+cQLinha
	cMsg+="<!--     				"+cQLinha
	cMsg+="TD{font-family: Calibri; font-size: 7pt;} "+cQLinha
	cMsg+="--->     				"+cQLinha
	cMsg+="</STYLE> 				"+cQLinha
	cMsg+="</head>  				"+cQLinha
	cMsg+="<body>					"+cQLinha
	
	cMsg+="<table  border=1 cellpadding=0 width='100%' style='border:none'>"+cQLinha
  	cMsg+="<tr>"+cQLinha
    cMsg+="<td width='20%' style='border:none'><img   width='250px' height='100px' id='_x0000_i1033'"+cQLinha
	cMsg+="		src='http://eletromarques.com.br/uploads/5/4/9/2/54925075/6909339_orig.png'  alt='http://www.tecpolpa.com.br/'></td>"+cQLinha
    cMsg+="<td width='80%'><p align=center><b><span style=' text-align:center;font-size:16.0px;font-weight:bold;font-family:Calibri;color:#000000'>"+cTitulo+"</span></b></p></td>"+cQLinha
	cMsg+="</tr></table>"+cQLinha       
	
	
		
	//	Filial, numero sc, item sc, dt necessidade, emissao, codigo produto, produto, qtd, solicitante
	cMsg+="<table  BORDER=1 width='100%' height='92'  style='border-collapse:collapse;border:none;mso-border-alt:solid black .5pt;'>" +cQLinha      
	cMsg+="<tr  BGCOLOR='#000000'>"+cQLinha //D2DDD4' 8B8682

	//Alimenta os titulos
	For x := 1 to Len(_aTitulos)
		cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>"+_aTitulos[x]+"</th>" +cQLinha //FFFAFA 8B8682	 
	Next x       
	
	cMsg+="</tr>"	 +cQLinha  
	
			
	_dados := .F.
  
	
	For  i:=1 to Len(_aItens) 
	
	     _dados := .T.
           
  		If i % 2 == 1
  			cMsg+="<tr  BGCOLOR='#F4A460'>" +cQLinha // ;  FFA500
		Else              
  		    cMsg+="<tr>"
		Endif                                                                                                                                                                                                                                                        
  		    
		For x := 1 to Len(_aTitulos)
  			cMsg+="<td   style='font-size:13.0px;font-family:Calibri' >"+Transform(_aItens[i][x], _aMascara[x])+"</td>" +cQLinha
		Next x       
			
		cMsg+="</tr>"+cQLinha
  			    
  	Next i
    
  	If !_dados 
       	//ConOut("Nao ha dados! - "+nomeFonte+".PRW")  
		Return
  	Endif

  	//cMsg+="<p><b></font><font color='Black' size='2' face='Verdana'> "+cMsgCorpo+" </font></b><br>" 	   
         
  	 
  		
  	cMsg+="</table>"  +cQLinha
  	
    	cMsg+="<table>" +cQLinha
    cMsg+="<p><font align = 'right' color='Black' size='1' face='Verdana'>Desenvolvido por: <a href='http://www.chaus.com.br'>Chaus <img   width='20px' height='20px'  id='_x0000_i1034'		src='http://chaus.com.br/images/logos/50x50.png'  alt='http://www.chaus.com.br'></a> </font><br>"  
    //cMsg+="<p><font align = 'right' color='Black' size='1' face='Verdana'>Desenvolvido por: <a href='http://www.chaus.com.br'>Chaus</font><br>" +cQLinha
  	cMsg+="</table>"  +cQLinha
  	

  	cMsg+="</body>"+cQLinha
  	cMsg+="</html>"     
  	                  
  
  	
 // 	MsgInfo(cMsg)      
  	//ConOut(cMsg)
   
  	_ret := u_EnvMail(cAssunto, cMsg, cPara, "", cAnexo)	                                                          
   
Endif

  
Return


  
// monta a query do workflow
Static Function queryMain() 
  
Local _aItens 	:= {} 
Local _aTitulos := {} 
Local _aTamCol 	:= {} 
Local _aMascara := {}
Local cQuery 

If Select("TMPWF")<>0
	dbselectarea("TMPWF")
	dbclosearea()
Endif
	 

	 
//	filial, numpedido, Item , dataentrega, dataemissao, codpro,desc pro, codcli, loja, cli, situacao pedido, qtd venda, qtd emp, qtd a liberar, qtd lib, seq      


cQuery	:="SELECT 			    																"+cQLinha
cQuery	+="			SC6.C6_FILIAL,  															"+cQLinha 
cQuery	+="			SC6.C6_NUM,  			        											"+cQLinha      				
cQuery	+="			SC6.C6_ITEM,																"+cQLinha 			  					   
cQuery	+="			SUBSTRING(SC6.C6_ENTREG,7,2)+'/'+SUBSTRING(SC6.C6_ENTREG,5,2)+'/'+SUBSTRING(SC6.C6_ENTREG,1,4) C6_ENTREG,	   	"+cQLinha   				
cQuery	+="			SUBSTRING(SC5.C5_EMISSAO,7,2)+'/'+SUBSTRING(SC5.C5_EMISSAO,5,2)+'/'+SUBSTRING(SC5.C5_EMISSAO,1,4) C5_EMISSAO,	"+cQLinha   				
cQuery	+="			SC6.C6_PRODUTO,  			    											"+cQLinha 					
cQuery	+="			SB1.B1_DESC,	  			    											"+cQLinha 					
cQuery	+="			SC5.C5_CLIENTE,                 											"+cQLinha
cQuery	+="			SC5.C5_LOJACLI,																"+cQLinha   
cQuery	+="			SA1.A1_NOME,																"+cQLinha   
//cQuery	+="			CASE WHEN SC9.C9_FILIAL IS NOT NULL THEN 'PVE' ELSE 'PVC' END AS SIT_PV,  	"+cQLinha 
cQuery	+="			SC6.C6_QTDVEN,  															"+cQLinha 		 			
cQuery	+="			SC6.C6_QTDEMP,  															"+cQLinha			   					
cQuery	+="			SC6.C6_QTDVEN-(SC6.C6_QTDEMP+SC6.C6_QTDENT)  AS LIBERAR,  					"+cQLinha   
cQuery	+="			SC9.C9_QTDLIB,				  												"+cQLinha     
cQuery	+="			SC9.C9_SEQUEN				  												"+cQLinha		
cQuery	+="FROM  " + RetSqlName("SC5") + "  SC5  INNER JOIN  " + RetSqlName("SC6") + "  SC6 ON SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND SC5.C5_NUM = SC6.C6_NUM 	AND SC6.D_E_L_E_T_ = ' ' "+cQLinha
cQuery	+="		   								 INNER JOIN  " + RetSqlName("SB1") + "  SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SC6.C6_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' "+cQLinha
cQuery	+="		   								 INNER JOIN  " + RetSqlName("SF4") + "  SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SC6.C6_TES = SF4.F4_CODIGO  AND SF4.D_E_L_E_T_ = ' ' "+cQLinha
cQuery	+="										 INNER JOIN  " + RetSqlName("SA1") + "  SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SC6.C6_CLI = SA1.A1_COD 	AND SC6.C6_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ =' ' "+cQLinha  
cQuery	+="										 INNER JOIN   " + RetSqlName("SC9") + "  SC9 ON SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND SC6.C6_NUM = SC9.C9_PEDIDO 	AND SC6.C6_ITEM = SC9.C9_ITEM AND SC9.D_E_L_E_T_ =' ' AND (SC9.C9_BLEST = ' ' AND SC9.C9_BLCRED = ' ') "+cQLinha  
cQuery	+="WHERE  SC5.D_E_L_E_T_ <> '*'    														"+cQLinha
cQuery	+="			AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' 									"+cQLinha 
cQuery	+="			AND SC6.C6_BLQ <> 'R'    													"+cQLinha
cQuery	+="			AND SC5.C5_TIPO = 'N'    													"+cQLinha           
cQuery	+="			AND C6_ENTREG < CONVERT(VARCHAR,GetDate(),112)  							"+cQLinha           
cQuery	+="ORDER BY C5_EMISSAO, C6_NUM, C6_ITEM													"+cQLinha

//cQuery +="		   AND SC1.C1_DATPRF  < CONVERT(VARCHAR,GetDate(),112)  "+cQLinha



TCQUERY cQuery ALIAS TMPWF NEW
dbSelectArea("TMPWF")
dbGoTop()

If TMPWF->(EOF())
   //ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
Endif
   
While !EOF()

	aadd(_aItens,{TMPWF->C6_FILIAL ,  TMPWF->C6_NUM, TMPWF->C6_ITEM, TMPWF->C6_ENTREG, TMPWF->C5_EMISSAO, TMPWF->C6_PRODUTO, TMPWF->B1_DESC, TMPWF->C5_CLIENTE,  TMPWF->C5_LOJACLI, TMPWF->A1_NOME,    TMPWF->C6_QTDVEN,  TMPWF->C6_QTDEMP,  TMPWF->LIBERAR,  TMPWF->C9_QTDLIB,  TMPWF->C9_SEQUEN})
	//					 1			     2			 3				      4		  		     5		      			6				  7				       8		      9               	10 				11           12        			    13            14         		   15             
	dbSkip() 
EndDo


//	filial, numpedido, Item , dataentrega, dataemissao, codpro,desc pro, codcli, loja, cli, situacao pedido, qtd venda, qtd emp, qtd a liberar, qtd lib, seq   // "@E 999,999,999.99"   

   
_aTitulos := 	{"Filial", 	"Número do Pedido", "Item Pedido", 	"Dt. Entrega", 	"Dt Emissão", 	"Cod. Produto", 	"Des. Produto",  	"Cod. Cli.", 	"Loja Cli." , 	"Nome Cli" , 	 	"Qtd Venda", 			"Qtd Emp", 	 			"Qtd a Liberar", 		"Qtd Liberada", 	"Seq"}
_aTamCol  :=  	{100,		100,				100,			100,			100,	   		100,				100,				100,	   		100,	   		100, 			   	100,						100,					100,					100,				100}
_aMascara := 	{"@!", 		"@!",				"@!",			"@!",	   		"@!",	   		"@!",				"@!",				"@!",			"@!", 			"@!",	   		 	"@E 999,999,999.99",	"@E 999,999,999.99", 	"@E 999,999,999.99",	"@E 999,999,999.99","@!"}

        
//Transform(_aSC1[i][8], "@E 999,999,999.99")

Return {_aItens,_aTitulos, _aTamCol, _aMascara }
              
              
