#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±÷ííííííííííÛííííííííííøíííííííÛííííííííííííííííííííøííííííÛíííííííííííííô±±
±±?Programa =CHWF0003 - www.chaus.com.br       ? Data =  14/01/16	  	  ?±±
±±?Autor	=Dyego Figueiredo  								   	          ?±±
±±víííííííííí?ííííííííííÜííííííí?ííííííííííííííííííííÜíííííí?íííííííííííííp±±
±±?Desc     =Esta rotina monta um html com os pedidos de compra de terc.   ±±
±±?         =que chegarao no dia  					 								  ?±±
±±víííííííííí?ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííp±±
±±?Uso      = AP                                                          ?±±
±±™íííííííííí?íííííííííííííííííííííííííííííííííííííííííííííííííííííííííííí?±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/
  
         
User Function CHWF0013( )
 
//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 //:= {}
Private cQLinha   := Chr(13) + Chr(10)
Private nomeFonte := "CHWF0013"

PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

Workflow( cEmpAnt,cFilAnt )   
Return			
	

 	 
	 
   
Static Function Workflow( _codEmp,_codFil)
Local dData   	:=DATE()                    
Local cAssunto	:= "WorkFlow dos pedidos de recebimento de terceiros que chegarao hoje. Empresa "+_codEmp+ " Filial "+AllTrim(_codFil)+". Data: "+DTOC(dData)
   
Local cTitulo 	:= "Pedidos de recebimento de terceiros que chegarao hoje"

//Local cMsgCorpo	:= " " //ExplicaÁ„o WF

Local cMsg		:= ""
Local cAnexo	:= ""  
//Local nCont     := 0        
//Local cQuery    := ""  
Local i, x
     
Local _aItens,_aTitulos, _aTamCol, _aMascara      
     
cQLinha :=  Chr(13) + Chr(10) 
	
//LGS#20200214 - Adequação de release 12.1.25 e posteriores
//ConOut("Inicio do fonte "+nomeFonte+".prw")
FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "Inicio do fonte "+nomeFonte+".prw", 0 )
         
cPara := GETMV("MV_XWF0013")

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
	 

	 
//	filial, numpedido, Item , dataentrega, dataemissao, codpro,desc pro, qtd entregue, codfor, lojafor, forn, obs      


cQuery := "	 SELECT SZ1.Z1_NUM AS NUMPEDIDO, Z1_ITEM ITEM,																			"+cQLinha
cQuery += " 			SZ1.Z1_FILIAL AS FILIAL, 																					"+cQLinha
cQuery += " 			SUBSTRING(SZ1.Z1_DATPRF,7,2)+'/'+SUBSTRING(SZ1.Z1_DATPRF,5,2)+'/'+SUBSTRING(SZ1.Z1_DATPRF,1,4) AS DATAENTREGA, "+cQLinha
cQuery += " 			SUBSTRING(SZ1.Z1_EMISSAO,7,2)+'/'+SUBSTRING(SZ1.Z1_EMISSAO,5,2)+'/'+SUBSTRING(SZ1.Z1_EMISSAO,1,4) AS DATAEMISSAO, "+cQLinha
cQuery += " 			SZ1.Z1_PRODUTO AS CODPRO,                                                                                   "+cQLinha
cQuery += " 			SB1.B1_DESC	AS DESCPRO,                                                                                     "+cQLinha
cQuery += " 			SZ1.Z1_QUANT - SZ1.Z1_QUJE AS QTDENTREGUE,                                                                  "+cQLinha
cQuery += " 			SZ1.Z1_FORNECE AS CODFOR,                                                                                   "+cQLinha
cQuery += " 			SZ1.Z1_LOJA	AS LOJAFOR,                                                                                     "+cQLinha
cQuery += " 			SA2.A2_NOME	AS RZSOCIAL,                                                                                    "+cQLinha
cQuery += "             SZ1.Z1_OBS	AS OBS                                                                                    	 	"+cQLinha
cQuery += " FROM  "+RetSqlName("SZ1")+" SZ1   INNER JOIN "+RetSqlName("SA2")+" SA2 	ON  SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND SZ1.Z1_FORNECE = SA2.A2_COD AND SZ1.Z1_LOJA = SA2.A2_LOJA	AND SA2.D_E_L_E_T_ <> '*'	"+cQLinha
cQuery += "                 				  INNER JOIN  "+RetSqlName("SB1")+" SB1	ON  SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SZ1.Z1_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*'        "+cQLinha
cQuery += " WHERE SZ1.D_E_L_E_T_ <> '*'                                                                                             "+cQLinha
cQuery += "    AND SZ1.Z1_ENCER <> 'E'   	                                                                                        "+cQLinha
cQuery += "	   AND SZ1.Z1_RESIDUO <> 'S' 	                                                                                        "+cQLinha
cQuery += "	   AND SZ1.Z1_CONAPRO != 'B' 	                                                                                        "+cQLinha
cQuery += "	   AND SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"'                                                                             "+cQLinha
cQuery += "	   AND (SZ1.Z1_QUANT - SZ1.Z1_QUJE) > 0 																				"+cQLinha
cQuery += "    AND SZ1.Z1_DATPRF   =  CONVERT(VARCHAR,GetDate(),112)			  							                        "+cQLinha
cQuery += " ORDER BY Z1_FILIAL, SZ1.Z1_DATPRF,SZ1.Z1_NUM,SZ1.Z1_PRODUTO 	 DESC 													"+cQLinha


//cQuery +="		   AND SC1.C1_DATPRF  < CONVERT(VARCHAR,GetDate(),112)  "+cQLinha



TCQUERY cQuery ALIAS TMPWF NEW
dbSelectArea("TMPWF")
dbGoTop()

If TMPWF->(EOF())
   //ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
Endif
   
While !EOF()

	aadd(_aItens,{TMPWF->FILIAL ,  TMPWF->NUMPEDIDO, TMPWF->ITEM, TMPWF->DATAENTREGA, TMPWF->DATAEMISSAO, TMPWF->CODPRO, TMPWF->DESCPRO, TMPWF->QTDENTREGUE,  TMPWF->CODFOR, TMPWF->LOJAFOR,  TMPWF->RZSOCIAL,  TMPWF->OBS})
	//					 1			     2			 3				    4		  		   5		      6				  7				       8		      9               	10 				11           12 
	dbSkip() 
EndDo

//	filial, numpedido,filial , dataentrega, dataemissao, codpro,desc pro, qtd entregue, codfor, lojafor, forn, obs
   
_aTitulos := 	{"Filial", 	"Número do Pedido", "Item Pedido", 	"Dt. Entrega", 	"Dt Emissão", 	"Cod. Produto", 	"Des. Produto", 	"Quantidade", 		 "Cod. Forn.", 	"Loja Forn." , "Nome Forn." , "Obs."}
_aTamCol  :=  	{100,		100,				100,			100,			100,	   		100,				100,				100,	   			 100,	   		100, 			100, 		   100}
_aMascara := 	{"@!", 		"@!",				"@!",			"@!",	   		"@!",	   		"@!",				"@!",				"@E 999,999,999.99", "@!",	   		"@!",	   		"@!",	   	   "@!"}

        
//Transform(_aSC1[i][8], "@E 999,999,999.99")

Return {_aItens,_aTitulos, _aTamCol, _aMascara }
              
              
