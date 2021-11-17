#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#include "RWMAKE.ch"
#include "Topconn.ch"
#INCLUDE "AP5MAIL.CH" 

/*
„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±÷ííííííííííÛííííííííííøíííííííÛííííííííííííííííííííøííííííÛíííííííííííííô±±
±±?Programa =CHWF0001 - www.chaus.com.br       ? Data =  08/05/17	  	  ?±±
±±?Autor	=Claudio Vilarinho 								   	          ?±±
±±víííííííííí?ííííííííííÜííííííí?ííííííííííííííííííííÜíííííí?íííííííííííííp±±
±±?Desc     =Esta rotina monta um html com os contratos a vencer           ±±
±±?         =          											          ?±±
±±?         =   						 								  ?±±
±±víííííííííí?ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííp±±
±±?Uso      = AP                                                          ?±±
±±™íííííííííí?íííííííííííííííííííííííííííííííííííííííííííííííííííííííííííí?±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/
  
         
User Function CHWF0014()
 
//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 //:= {}
Private cQLinha   := Chr(13) + Chr(10)
Private nomeFonte := "CHAUS014"


PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

Workflow( cEmpAnt,cFilAnt )   

Return			
	

 
   
Static Function Workflow( _codEmp,_codFil)
Local dData   	:=DATE()                    
Local cAssunto	:= "WorkFlow dos contratos a vencer. Empresa "+_codEmp+ " Filial "+AllTrim(_codFil)+". Data: "+DTOC(dData)
   
Local cTitulo 	:= "Contratos a vencer"

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
         
cPara 	:= GETMV("MV_XWF0014")
cPrazo 	:= AllTrim(Str(GETMV("MV_XPRZOCT")))



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
cQuery := "	SELECT " +cQLinha
cQuery += "		CN9_NUMERO, " +cQLinha
cQuery += "		CN1_DESCRI, " +cQLinha
cQuery += "		SUBSTRING(CN9_DTINIC,7,2) + '/' + SUBSTRING(CN9_DTINIC,5,2) + '/' + SUBSTRING(CN9_DTINIC,1,4) AS DATA_INICIAL,  " +cQLinha
cQuery += "		SUBSTRING(CN9_DTFIM,7,2) + '/' + SUBSTRING(CN9_DTFIM,5,2) + '/' + SUBSTRING(CN9_DTFIM,1,4) AS DATA_FINAL,  " +cQLinha
cQuery += "		CN9_VIGE " +cQLinha
cQuery += "	FROM "+RetSqlName("CN9")+" CN9 (NOLOCK) " +cQLinha
cQuery += "		INNER JOIN "+RetSqlName("CN1")+" CN1 (NOLOCK) ON CN9_TPCTO = CN1_CODIGO " +cQLinha
cQuery += "	WHERE CN9.D_E_L_E_T_ = '' " +cQLinha
cQuery += "	AND CN1.D_E_L_E_T_ = '' " +cQLinha
cQuery += " AND CN9_FILIAL = '"+xFilial("CN9")+"'	"+cQLinha
cQuery += "	AND CN9_SITUAC <> '01' " +cQLinha
cQuery += "	AND CN9_DTENCE = ' ' " +cQLinha
cQuery += "	AND CN9_DTFIM < GETDATE() + "+cPrazo+" " +cQLinha
cQuery += "ORDER BY CN9_DTFIM DESC " +cQLinha

TCQUERY cQuery ALIAS TMPWF NEW
dbSelectArea("TMPWF")
dbGoTop()

If TMPWF->(EOF())
   //ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
Endif

While !EOF()
	aadd(_aItens,{TMPWF->CN9_NUMERO, TMPWF->CN1_DESCRI, TMPWF->DATA_INICIAL, TMPWF->DATA_FINAL, TMPWF->CN9_VIGE})
	//					 1						 2				   3				     4				      5				          6				      7				          8		             9                           
	dbSkip() 
EndDo

   
_aTitulos := 	{"Numero", 	"Tipo", "Dt. Inicial", 	"Dt. Vigencia", 	"Vigencia"}
_aTamCol  :=  	{100,		100,	100,			100,				100}
_aMascara := 	{"@!", 		"@!",	"@!",			"@!",	   			"@!"}

//aviso("Teste-final")
        
//Transform(_aSC1[i][8], "@E 999,999,999.99")

Return {_aItens,_aTitulos, _aTamCol, _aMascara }