#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±÷ííííííííííÛííííííííííøíííííííÛííííííííííííííííííííøííííííÛíííííííííííííô±±
±±?Programa =CHWF0001 - www.chaus.com.br       ? Data =  16/10/17	  	  ?±±
±±?Autor	=Dyego Figueiredo 								   	          ?±±
±±víííííííííí?ííííííííííÜííííííí?ííííííííííííííííííííÜíííííí?íííííííííííííp±±
±±?Desc     =Esta rotina monta um html com os saldos divergentes B2 X B8   ±±
±±?         =          											          ?±±
±±?         =   						 								  ?±±
±±víííííííííí?ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííp±±
±±?Uso      = AP                                                          ?±±
±±™íííííííííí?íííííííííííííííííííííííííííííííííííííííííííííííííííííííííííí?±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/
  
         
User Function CHWF0016()
 
//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 //:= {}
Private cQLinha   := Chr(13) + Chr(10)
Private nomeFonte := "CHAUS016"


PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

Workflow( cEmpAnt,cFilAnt )   

Return			
	

 
   
Static Function Workflow( _codEmp,_codFil)
Local dData   	:=DATE()                    
Local cAssunto	:= "WorkFlow dos produtos com saldo em estoque (SB2) divergente do saldo por lote (SB8). Empresa "+_codEmp+ " Filial "+AllTrim(_codFil)+". Data: "+DTOC(dData)
   
Local cTitulo 	:= "Saldos divergentes SB2 X SB8"

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
         
cPara 	:= GETMV("MV_XWF0016")




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
cQuery := "	SELECT  * FROM ( SELECT B1_COD, B1_DESC, B1_TIPO, B2_LOCAL, SUM(B2_QATU) B2_QATU, ISNULL( (SELECT SUM(B8_SALDO) FROM SB8110 SB8 WHERE B8_FILIAL  = '11' AND B1_COD = B8_PRODUTO AND B2_LOCAL = B8_LOCAL AND SB8.D_E_L_E_T_ = '' ) , 0 ) B8_SALDO " +cQLinha
cQuery += "	FROM "+RetSqlName("SB1")+" SB1 (NOLOCK) 			" +cQLinha
cQuery += "		INNER JOIN "+RetSqlName("SB2")+" SB2 (NOLOCK) ON B2_FILIAL  = '"+xFilial("SB2")+"' AND B1_COD = B2_COD AND SB2.D_E_L_E_T_ = ' ' " +cQLinha
cQuery += "	WHERE SB1.D_E_L_E_T_ = '' 							" +cQLinha
cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"'				" +cQLinha
cQuery += " AND B1_RASTRO = 'L'									" +cQLinha
cQuery += " GROUP BY B1_COD, B1_DESC, B1_TIPO, B2_LOCAL			" +cQLinha
cQuery += " )A													" +cQLinha
cQuery += " WHERE abs( B2_QATU - B8_SALDO ) >  0.001			" +cQLinha	
cQuery += " ORDER BY 1											" +cQLinha



TCQUERY cQuery ALIAS TMPWF NEW
dbSelectArea("TMPWF")
dbGoTop()

If TMPWF->(EOF())
   //ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
Endif

While !EOF()
	aadd(_aItens,{TMPWF->B1_COD,     TMPWF->B1_DESC, TMPWF->B1_TIPO,         TMPWF->B2_LOCAL,      TMPWF->B2_QATU, TMPWF->B8_SALDO})
	//					 1						 2				   3				     4				      5				          6				      7				          8		             9                           
	dbSkip() 
EndDo

   
_aTitulos := 	{"Código", 	"Descrição", "Tipo", 	"Armazém",  "Quantidade Atual (SB2)", "Quantidade Atual dos Lotes (SB8)"}
_aTamCol  :=  	{100,		100,		100,			100,			100, 					100}
_aMascara := 	{"@!", 		"@!",		"@!",			"@!",   	   "@E 999,999,999.99", "@E 999,999,999.99"}

//aviso("Teste-final")
        
//Transform(_aSC1[i][8], "@E 999,999,999.99")

Return {_aItens,_aTitulos, _aTamCol, _aMascara }