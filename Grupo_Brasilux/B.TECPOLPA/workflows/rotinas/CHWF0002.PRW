#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±÷ííííííííííÛííííííííííøíííííííÛííííííííííííííííííííøííííííÛíííííííííííííô±±
±±?Programa =CHWF0002 - www.chaus.com.br       ? Data =  14/01/16	  	  ?±±
±±?Autor	=Dyego Figueiredo  								   	          ?±±
±±víííííííííí?ííííííííííÜííííííí?ííííííííííííííííííííÜíííííí?íííííííííííííp±±
±±?Desc     =Esta rotina monta um html com as e Solicitacoes de Compra em  ±±
±±?         =atraso   											          ?±±
±±?         =   						 								  ?±±
±±víííííííííí?ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííp±±
±±?Uso      = AP                                                          ?±±
±±™íííííííííí?íííííííííííííííííííííííííííííííííííííííííííííííííííííííííííí?±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/
  
         
User Function CHWF0002( )
 
//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 //:= {}
Private cQLinha   := Chr(13) + Chr(10)
Private nomeFonte := "CHAUS002"


PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

Workflow( cEmpAnt,cFilAnt )   


Return			
	
 
   
Static Function Workflow( _codEmp,_codFil)
Local dData   	:=DATE()                    
Local cAssunto	:= "WorkFlow das solicitacoes de compra em atraso. Empresa "+_codEmp+ " Filial "+AllTrim(_codFil)+". Data: "+DTOC(dData)
   
Local cTitulo 	:= "Solicitações de compra em atraso"

//Local cMsgCorpo	:= " " //ExplicaÁ„o WF

Local cMsg		:= ""
Local cAnexo	:= ""  
//Local nCont     := 0        
//Local cQuery    := ""  
Local i, x
     
Local _aItens,_aTitulos, _aTamCol, _aMascara      
     
cQLinha :=  Chr(13) + Chr(10) 
	

//prepare environment empresa _emp filial _fil   

//LGS#20200214 - Adequação de release 12.1.25 e posteriores
//ConOut("Inicio do fonte "+nomeFonte+".prw")
FwLogMSG( "INFO", , 'SIGACOM', funname(), '', '01', "Inicio do fonte "+nomeFonte+".prw", 0 )
	         
cPara := GETMV("MV_XWF0002")


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
  //	ConOut(cMsg)
   
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
	 
 
//	Filial, numero sc, item sc, dt necessidade, emissao, codigo produto, produto, qtd, solicitante
cQuery := "SELECT  	SC1.C1_FILIAL, 		"+cQLinha
cQuery += "			SC1.C1_NUM, 		"+cQLinha
cQuery += "			SC1.C1_ITEM, 		"+cQLinha
cQuery += "			SUBSTRING(SC1.C1_DATPRF,7,2)+'/'+SUBSTRING(SC1.C1_DATPRF,5,2)+'/'+SUBSTRING(SC1.C1_DATPRF,1,4)   AS DT_NECESSIDADE,  "+cQLinha
cQuery += "        	SUBSTRING(SC1.C1_EMISSAO,7,2)+'/'+SUBSTRING(SC1.C1_EMISSAO,5,2)+'/'+SUBSTRING(SC1.C1_EMISSAO,1,4) AS DT_EMISSAO ,    "+cQLinha
cQuery += "	       	SC1.C1_PRODUTO,		"+cQLinha
cQuery += "        	SC1.C1_DESCRI,		"+cQLinha
cQuery += "        	SC1.C1_QUANT,		"+cQLinha
cQuery += "			CASE 					"+cQLinha
cQuery += "				WHEN C1_ORIGEM != 'MATA106' THEN UPPER(SC1.C1_SOLICIT) 		"+cQLinha
cQuery += "				ELSE ''					"+cQLinha
cQuery += "			END SOLICITANTE,			"+cQLinha
cQuery += "			CASE 						"+cQLinha
cQuery += "				WHEN C1_ORIGEM = 'MATA106' THEN UPPER(SC1.C1_SOLICIT)		"+cQLinha
cQuery += "				ELSE ''					"+cQLinha
cQuery += "			END REQUISITANTE			"+cQLinha	
cQuery += "FROM "+RetSqlName("SC1")+"  SC1 (NOLOCK)			"+cQLinha
cQuery += "WHERE SC1.D_E_L_E_T_  <> '*'						"+cQLinha
cQuery += "        AND SC1.C1_FILIAL = '"+xFilial("SC1")+"'	"+cQLinha
cQuery += "        AND SC1.C1_QUANT > C1_QUJE				"+cQLinha
cQuery += "        AND SC1.C1_APROV NOT IN ( 'B', 'R') 		"+cQLinha
//cQuery += "        AND SC1.C1_COTACAO = ' '					"+cQLinha
//cQuery += "        AND SC1.C1_QUJE = 0						"+cQLinha
cQuery +="		   AND SC1.C1_DATPRF  < CONVERT(VARCHAR,GetDate(),112)  "+cQLinha

cQuery += "ORDER BY C1_DATPRF, C1_NUM , C1_ITEM			"+cQLinha

//cQuery +="		   AND SC1.C1_DATPRF  < CONVERT(VARCHAR,GetDate(),112)  "+cQLinha



TCQUERY cQuery ALIAS TMPWF NEW
dbSelectArea("TMPWF")
dbGoTop()

If TMPWF->(EOF())
   //ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
Endif
   
While !EOF()
	aadd(_aItens,{TMPWF->C1_FILIAL ,  TMPWF->C1_NUM, TMPWF->C1_ITEM, TMPWF->DT_NECESSIDADE, TMPWF->DT_EMISSAO, TMPWF->C1_PRODUTO, TMPWF->C1_DESCRI,  TMPWF->C1_QUANT, TMPWF->SOLICITANTE,  TMPWF->REQUISITANTE})
	//					 1						 2				   3				     4				      5				          6				      7				          8		             9                           
	dbSkip() 
EndDo

   
_aTitulos := 	{"Filial", 	"Número da SC", "Item SC", 	"Dt. Necessidade", 	"Dt Emissão", 	"Cod. Produto", 	"Des. Produto", 	"Quantidade", 		 "Requisitante", 	"Solicitante"}
_aTamCol  :=  	{100,		100,			100,		100,				100,	   		100,				100,				100,	   			 100,	   			100}
_aMascara := 	{"@!", 		"@!",			"@!",		"@!",	   			"@!",	   		"@!",				"@!",				"@E 999,999,999.99", "@!",	   			"@!"}

        
//Transform(_aSC1[i][8], "@E 999,999,999.99")

Return {_aItens,_aTitulos, _aTamCol, _aMascara }
              
              
