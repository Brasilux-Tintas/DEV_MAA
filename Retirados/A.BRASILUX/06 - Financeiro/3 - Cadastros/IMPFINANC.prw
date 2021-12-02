#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

USER FUNCTION IMPFINANC()
LOCAL aArray := {}   
LOCAL cQuery,lSucesso,cNumero,cHist,dEmissao,dVencto,cAux,cCliFor
//Local cQBase,cCgc
lSucesso := .t.
 
PRIVATE lMsErroAuto := .F.
if !(trim(upper(cUsername)) == "CLEBER")
	return
endif 

if xFilial("SE1") != "060101"   
	RETURN
ENDIF 
/*
cQuery := "SELECT * FROM RCDIS"
   

TCQUERY cQuery ALIAS "TCQ" NEW    
   
dbselectarea("SA1")
dbsetorder(1)
dbselectarea("SA2")
DBSETORDER(1)
dbselectarea("SE1")
dbsetorder(1)
dbselectarea("SE2")
dbsetorder(1)
dbselectarea("TCQ")
dbgotop()
while lSucesso .and. !eof()  
	cNumero := PADL(alltrim(TCQ->NUMERO),9,"0")   
	cHist := "IMPORTADO WEBSAI "
	cCgc := ALLTRIM(TCQ->CNPJ)
	dbselectarea("SA1")
	dbsetorder(3)
	dbseek(xFilial("SA1")+cCgc)
	if found()
		cCliFor := SA1->A1_COD
	else
		dbselectarea("TCQ")
		dbskip()
		loop
	endif 
	dEmissao := ctod(substr(TCQ->EMISSAO,7,2)+'/'+substr(TCQ->EMISSAO,5,2)+'/'+substr(TCQ->EMISSAO,1,4))
	dVencto := ctod(substr(TCQ->VENCTO,7,2)+'/'+substr(TCQ->VENCTO,5,2)+'/'+substr(TCQ->VENCTO,1,4)) 
	IF dVencto < dEmissao
		dVencto := dEmissao
	endif  
	nComis := 0.0
	nBaseCom := 0
	cVend := ""
	IF TCQ->COMISSAO > 0 
		cVend := ALLTRIM(TCQ->VEND)
		if !empty(cVend) 
			nComis = round((TCQ->COMISSAO*100)/TCQ->VALOR,4)
			nBaseCom := TCQ->VALOR 
			if cVend == "002099"
				cVend := "000003"
			endif   
		endif
	endif    
	
	cNumBco := alltrim(TCQ->NUMBCO) 
	cSituaca := iif(!empty(cNumBco),"1","0") 
	cParcela := ALLTRIM(TCQ->PARCELA) 
	cParcela := PADR(cParcela,TamSX3("E1_PARCELA")[1]," ")  
	cTipo := "DP"  
	cTipo := PADR(cTipo,TamSX3("E1_TIPO")[1]," ")
	aArray := {} 
	aArray := { { "E1_PREFIXO"  , TCQ->PREFIXO             , NIL },;
    	        { "E1_NUM"      , cNumero            , NIL },;
    	        { "E1_PARCELA"  , cParcela            , NIL },;
        	    { "E1_TIPO"     , cTipo              , NIL },;
            	{ "E1_NATUREZ"  , "11111"       , NIL },;
	            { "E1_CLIENTE"  , cCliFor          , NIL },;
    	        { "E1_EMISSAO"  , dEmissao, NIL },;
        	    { "E1_VENCTO"   , dVencto, NIL },;
            	{ "E1_VENCREA"  , dVencto, NIL },;
            	{ "E1_VEND1"  , cVend, NIL },;
            	{ "E1_BASCOM1"  , nBaseCom, NIL },;
            	{ "E1_COMIS1"  , nComis, NIL },;
            	{ "E1_SITUACA"  , cSituaca, NIL },;
            	{ "E1_NUMBCO"  , cNumBco, NIL },;
            	{ "E1_HIST"  , cHist, NIL },;
	            { "E1_VALOR"    , TCQ->VALOR              , NIL } }

//            	{ "E1_BCO"  , TCQ->BANCO, NIL },;

	dbselectarea("SE1")
	dbsetorder(2)    
	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	cAux := xFilial("SE1")+PADR(cClifor,TamSX3("E1_CLIENTE")[1]," ")+PADR("01",TamSX3("E1_LOJA")[1]," ")+PADR(TCQ->PREFIXO,TamSX3("E1_PREFIXO")[1]," ")+PADR(cNumero,TamSX3("E1_NUM")[1]," ")+PADR(cParcela,TamSX3("E1_PARCELA")[1]," ")+PADR(cTipo,TamSX3("E1_TIPO")[1]," ")
	dbseek(cAux)
	if !found()
		nAcao := 3    
	else
		nAcao := 4 
	endif 
	dbselectarea("SE1")
	dbsetorder(1)    
	if nAcao == 3 //Somente incluir pra não mexer nos que estão baixados
		BEGIN TRANSACTION  
		MsExecAuto( { |x,y| FINA040(x,y)} , aArray, nAcao)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
 
		If lMsErroAuto
			lSucesso := .f.
    		MostraErro() 
    		RETURN
		Else  
    		Conout("Incluso titulo REC "+cNumero)
		Endif      
		END TRANSACTION
	endif 
	dbselectarea("TCQ")  
	dbskip()
enddo 
 
dbselectarea("TCQ")  
dbclosearea("TCQ")
if !lSucesso
	return
endif
*/ 

cQuery := "SELECT * FROM PGDIS"
TCQUERY cQuery ALIAS "TCQ" NEW    
dbselectarea("TCQ")
dbgotop()
while lSucesso .and. !eof()  
	cNumero := TCQ->NUMERO
	cHist := "IMPORTADO WEBSAI DISSOLTEX"
	dEmissao := ctod(substr(TCQ->EMISSAO,7,2)+'/'+substr(TCQ->EMISSAO,5,2)+'/'+substr(TCQ->EMISSAO,1,4))
	dVencto := ctod(substr(TCQ->VENCTO,7,2)+'/'+substr(TCQ->VENCTO,5,2)+'/'+substr(TCQ->VENCTO,1,4))  
	dbselectarea("SA2")
	dbsetorder(3)
	dbseek(xFilial("SA2")+ALLTRIM(TCQ->CNPJ))
	if !found()
		dbselectarea("TCQ")
		dbskip()
		loop
	endif 
	cCliFor := SA2->A2_COD
	dbselectarea("SA2")
	dbsetorder(1)
		
		
	aArray := {} 
	aArray := { { "E2_PREFIXO"  , TCQ->PREFIXO             , NIL },;
    	        { "E2_NUM"      , cNumero            , NIL },;
        	    { "E2_TIPO"     , "DP"              , NIL },;
            	{ "E2_NATUREZ"  , "901001"       , NIL },;
	            { "E2_FORNECE"  , cCliFor          , NIL },;
	            { "E2_LOJA"  , "01"          , NIL },;
    	        { "E2_EMISSAO"  , dEmissao, NIL },;
        	    { "E2_VENCTO"   , dVencto, NIL },;
            	{ "E2_VENCREA"  , dVencto, NIL },;
            	{ "E2_HIST"  , cHist, NIL },;
	            { "E2_VALOR"    , TCQ->VALOR              , NIL } }

	dbselectarea("SE2")
	dbsetorder(1)    
	//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA  
	cAux := xFilial("SE2")+PADR(TCQ->PREFIXO,TamSX3("E2_PREFIXO")[1]," ")+PADR(cNumero,TamSX3("E2_NUM")[1]," ")+SPACE(TamSX3("E2_PARCELA")[1])+PADR("DP",TamSX3("E2_TIPO")[1]," ")+PADR(cClifor,TamSX3("E2_FORNECE")[1]," ")+PADR("01",TamSX3("E2_LOJA")[1]," ")
	dbseek(cAux)
	if !found()  
		BEGIN TRANSACTION
		MsExecAuto( { |x,y| FINA050(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
        //MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)
		If lMsErroAuto
			lSucesso := .f.
    		MostraErro() 
    		//RETURN - //LGS#20200130 - Adequação para release 12.1.25 e posteriores - Lugar inadequado do return, dentro de um begin transaction
		Else
    		//LGS#20200130 - Adequação para release 12.1.25 e posteriores
    		//Conout("Incluso titulo PAG "+cNumero)
    		FwLogMSG( "INFO", , 'SIGAFIN', funname(), '', '01', "Titulo PAG " + cNumero, 0 )
		Endif  
		END TRANSACTION
	else
	   //LGS#20200130 - Adequação para release 12.1.25 e posteriores
	   //Conout("Titulo PAG "+cNumero+" ja existe")
	   FwLogMSG( "INFO", , 'SIGAFIN', funname(), '', '01', "Titulo PAG " + cNumero + " ja existe.", 0 )
	endif 
	dbselectarea("TCQ")  
	dbskip()
enddo 
 
dbselectarea("TCQ")  
dbclosearea()

/* 
            { "E2_FORNECE"  , "0001"            , NIL },;
            { "E2_EMISSAO"  , CtoD("17/02/2012"), NIL },;
            { "E2_VENCTO"   , CtoD("17/02/2012"), NIL },;
            { "E2_VENCREA"  , CtoD("17/02/2012"), NIL },;
            { "E2_VALOR"    , 5000              , NIL } }
 
MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão   
*/
Return  