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
±±?Desc     =Esta rotina monta um html com as notas fiscais sem cobertura  ±±
±±?         =          											          ?±±
±±?         =   						 								  ?±±
±±víííííííííí?ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííp±±
±±?Uso      = AP                                                          ?±±
±±™íííííííííí?íííííííííííííííííííííííííííííííííííííííííííííííííííííííííííí?±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
?????????????????????????????????????????????????????????????????????????????
*/
  
         
User Function CHWF0018()
 
//Local 	nRecno    := 0
//Local 	nI        := 0
//Local 	nX        := 0
//Local 	aRecnoSM0 //:= {}
Private cQLinha   := Chr(13) + Chr(10)
Private nomeFonte := "CHWF0018"


PREPARE ENVIRONMENT EMPRESA '11' FILIAL '11'

Workflow( cEmpAnt,cFilAnt )   

Return			
	

 
   
Static Function Workflow( _codEmp,_codFil)
Local dData   	:=DATE()                    
Local cAssunto	:= "WorkFlow notas fiscais sem cobertura. Empresa "+_codEmp+ " Filial "+AllTrim(_codFil)+". Data: "+DTOC(dData)
Local cLogoEmp		:= RetLogoEmp()
Local cAltLogo		:= SUPERGETMV("MV_GPALTLOGO",,"30")
Local cLarLogo		:= SUPERGETMV("MV_GPLARLOGO",,"206")
Local cTitulo 	:= "Notas fiscais de fornecedores aguardando a nota do cliente"

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
         
cPara 	:=   GETMV("MV_XWF0018")  // pcp@tecpolpa.com.br


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
	//cMsg+="		src='http://eletromarques.com.br/uploads/5/4/9/2/54925075/6909339_orig.png'  alt='http://www.tecpolpa.com.br/'></td>"+cQLinha

	If !Empty(cLarLogo) .And. !Empty(cAltLogo)
		cMsg +=			"<img src='" + cLogoEmp +"' width='"+cLarLogo+"' height='"+cAltLogo+"'align=left hspace=30>" //+ CRLF
	Else
		cMsg +=		"<img src='" + cLogoEmp +"' width='206' height='030' align=left hspace=30>" //+ CRLF
	EndIf
	cMsg += "</td>"
	//cMsg +=					"<b>" + CRLF
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
    cMsg+="<p><font align = 'right' color='Black' size='1' face='Verdana'>Desenvolvido por: <a href='http://www.brasilux.com.br'>Brasilux<img   width='20px' height='20px'  id='_x0000_i1034'		src='http://chaus.com.br/images/logos/50x50.png'  alt='http://www.brasilux.com.br'></a> </font><br>"  
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
Local cLinha := Chr(13) + Chr(10)  
//Local cData:= dtos(date())

If Select("TMPWF")<>0
	dbselectarea("TMPWF")
	dbclosearea()
Endif
	 
 



cQuery :="	SELECT	D1_DOC, D1_SERIE, D1_TIPO, D1_ITEM, D1_FORNECE, D1_LOJA, A2_NOME, D1_QUANT, D1_CF,  D1_EMISSAO 	"+cLinha   
cQuery +="																														"+cLinha   
cQuery +="FROM	"+RetSqlName("SD1")+" SD1																																"+cLinha   
cQuery +="			LEFT JOIN "+RetSqlName("SDH")+" SDH ON DH_FILIAL = '"+xFilial("SDH")+"' AND D1_NUMSEQ = DH_IDENTNF AND D1_ITEM = DH_ITEM AND SDH.D_E_L_E_T_ = ''	"+cLinha   
cQuery +="			LEFT JOIN "+RetSqlName("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''		"+cLinha   
cQuery +="WHERE	SD1.D_E_L_E_T_ = ''				"+cLinha   
cQuery +="	AND D1_FILIAL = '"+xFilial("SD1")+"'"+cLinha   
cQuery +="	AND D1_TIPO = 'N'					"+cLinha   
cQuery +="	AND D1_CF IN (						"+cLinha   
cQuery +="			'1924','2924' -- FORNECEDOR	"+cLinha   			
//cQuery +="			--'1949','2949' --CLIENTE	"+cLinha   
cQuery +="			) 							"+cLinha   
cQuery +="	AND DH_FILIAL IS NULL				"+cLinha
cQuery +="	AND D1_DTDIGIT > '20171001'			"+cLinha
   
cQuery +="ORDER BY D1_DOC, D1_ITEM				"+cLinha   


TCQUERY cQuery ALIAS TMPWF NEW
dbSelectArea("TMPWF")
dbGoTop()

If TMPWF->(EOF())
   //ConOut("A Query nao retornou dados - fonte "+nomeFonte+".prw")
Endif

While TMPWF->(!EOF())
	
	
	aAdd(_aItens,{ ;	
			AllTrim(TMPWF->D1_DOC),	;
			AllTrim(TMPWF->D1_SERIE),	;	
			AllTrim(TMPWF->D1_TIPO),	;
			AllTrim(TMPWF->D1_ITEM),	;
			AllTrim(TMPWF->D1_FORNECE),	;
			AllTrim(TMPWF->D1_LOJA),	;
			AllTrim(TMPWF->A2_NOME),	;
			(TMPWF->D1_QUANT),		;
			AllTrim(TMPWF->D1_CF),	;
			dtoc(stod(TMPWF->D1_EMISSAO)) })
			
	
			
			
			                           
	TMPWF->(dbSkip()) 
EndDo

   
_aTitulos := 	{"Documento", 	"Série", 	"Tipo", "Item", 	"Fornecedor",  	"Loja", 	"Nome", 	"Quantidade", 			"Cfop",	"Dt. Emissão"}
_aTamCol  :=  	{100,			100,		100,	100,		100,		100, 		100,		100,					100,			100	}
_aMascara := 	{"@!", 			"@!",		"@!",	"@!",		"@!",   	 "@!", 		"@!",		"@E 999,999,999.99", 	"@!", 			"@!"}


	
	

//aviso("Teste-final")
        
//Transform(_aSC1[i][8], "@E 999,999,999.99")

Return {_aItens,_aTitulos, _aTamCol, _aMascara }