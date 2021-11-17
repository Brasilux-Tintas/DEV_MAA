#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#Translate MSGBOX( => IW_MsgBox(

User Function BRCHAM02()
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define Variaveis                                             ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Relatorio Chamados"
PRIVATE cDesc1 := "Este relatorio ira Dialogos do Chamado "
PRIVATE cDesc2 := ""
PRIVATE cDesc3 := ""                                                                                 
                   //   0          1           2         3         4         5         6       7
                   //01234567890123456789012345678901234567890123456789012345678901234567890123456789
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:="BRCHAM02"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   :="BRCHAM02"
PRIVATE flag := 0
PRIVATE nTotalMin,dAux,Dia,Dias,Hra,Hora,Min,Minuto,numCham,nTotalMedia
PRIVATE cCountEnc:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) != 0
        MsgBox("Acesso não autorizado!", "Atenção...", "STOP")
        Return
    Endif 
  
//CriaSX1(cPerg) //LGS#20200211 - Adequação de release 12.1.25 e posteriores
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="BRCHAM02"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)
      
If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RptDetail()})

return
/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 22/08/14         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////
Static Function RptDetail()
//Local nTotal := 0
//Local _nCont := 0
//Local lNormal
Private _nLin := 7
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery :="SELECT Z06_TECALO AS TECNICO,Z06_SOLCHA AS SOLICITANTE, Z06_NUMCHA AS NUMCHAMADA,Z06_STATUS "
cQuery += "FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) " 
cQuery += "WHERE (D_E_L_E_T_ <> '*') AND (Z06_FILIAL = '"+XFILIAL("Z06")+"') AND (Z06_SOLCHA BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') AND (Z06_TECALO BETWEEN '"+mv_par04+"' AND '"+mv_par05+"') "
cQuery += "ORDER BY TECNICO, Z06_NUMCHA "

TCQuery cQuery NEW ALIAS "TEC"

SetRegua(RECCOUNT()) 

dbSelectArea("TEC")
dbgotop()
                                                  
cQuery :="SELECT Z06_SOLCHA ,Z06_TECALO, Z06_STATUS, Z06_NUMCHA "
cQuery += "FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) " 
cQuery += "WHERE (D_E_L_E_T_ <> '*') AND (Z06_FILIAL = '"+XFILIAL("Z06")+"') AND (Z06_SOLCHA BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') AND (Z06_TECALO BETWEEN '"+mv_par04+"' AND '"+mv_par05+"') "
cQuery += "ORDER BY Z06_TECALO, Z06_NUMCHA"

TCQuery cQuery NEW ALIAS "CON"

SetRegua(RECCOUNT()) 

dbSelectArea("CON")
dbgotop()

cQuery := "WITH TMP AS (SELECT Z06_NUMCHA AS CODIGO,Z06_TECALO AS TECNICO ,CONVERT(DATETIME,Z06_DTABER+' '+Z06_HRABER,102) AS DTHR "
cQuery += "FROM "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) "
cQuery += "WHERE (D_E_L_E_T_ <> '*') AND (Z06_FILIAL = '"+XFILIAL("Z06")+"') AND (Z06_SOLCHA BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') AND (Z06_TECALO BETWEEN '"+mv_par04+"' AND '"+mv_par05+"') "
cQuery += "UNION ALL SELECT Z07_CODIGO AS CODIGO,Z06_TECALO AS TECNICO,"
cQuery += "CASE WHEN Z06_STATUS = '2' THEN CONVERT(DATETIME,Z07_DATA+' '+Z07_HRA,102) ELSE GETDATE() END AS DTHR "
cQuery += "FROM "+RetSqlName("Z07")+" Z07 WITH (NOLOCK) LEFT OUTER JOIN "+RetSqlName("Z06")+" Z06 WITH (NOLOCK) ON (Z06.D_E_L_E_T_ <> '*') AND (Z06_FILIAL = '"+XFILIAL("Z06")+"') AND (Z07_CODIGO = Z06_NUMCHA)"
cQuery += "WHERE (Z07.D_E_L_E_T_ <> '*') AND (Z07_FILIAL = '"+XFILIAL("Z07")+"')  AND (Z06_SOLCHA BETWEEN '"+mv_par02+"' AND '"+mv_par03+"') AND (Z06_TECALO BETWEEN '"+mv_par04+"' AND '"+mv_par05+"')),"
cQuery += "TMP1 AS (SELECT CODIGO,MAX(TECNICO) AS TECNICO, DATEDIFF(minute,MIN(DTHR),MAX(DTHR)) AS DURACAO FROM TMP GROUP BY CODIGO) "
cQuery += "SELECT CODIGO,TECNICO,ZH_NOME,DURACAO/1440 AS DIAS,((DURACAO % 1440)/ 60) AS HRS,DURACAO % 60 AS MINUTOS, DURACAO "
cQuery += "FROM TMP1 "
cQuery += "LEFT OUTER JOIN SZH010 SZH WITH (NOLOCK) ON (SZH.D_E_L_E_T_ <> '*') AND (ZH_CODIGO = TMP1.TECNICO) "
cQuery += "ORDER BY TECNICO, CODIGO "

TCQuery cQuery NEW ALIAS "TCQ"

SetRegua(RECCOUNT()) 

dbSelectArea("TCQ")
dbgotop()

dbSelectArea("Z06")
dbgotop()

cParam := mv_par01
_nLin:= 4
if(cParam == 1)
	nTotalMin:=dAux:=Dia:=Dias:=Hra:=Hora:=Min:= Minuto:= numCham := 0
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	while !EOF()
	            
     	if _nLin > 55.AND. !EOF()
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 07
		endif   
		
	
		WHILE !EOF() .AND. (TCQ->TECNICO == TEC->TECNICO)
		
		if (CON->Z06_STATUS == "4" .OR. CON->Z06_STATUS == "3") 
		   		if flag == 0
			   		_nLin++   
			   		_nLin++ 
					@ _nLin,000 psay "Tecnico:"
			    	//LGS#20200211 - Adequação de release 12.1.25 e posteriores
			    	//@ _nLin,015 psay UsrFullName(TCQ->TECNICO)
			    	@ _nLin,015 psay fBusName( TCQ->TECNICO )
		    	   	_nLin++ 
		    	   	@ _nLin,000 psay replicate("-",80)
		    		_nLin++ 
		  		  	@ _nLin,005 psay "Num.Cham."
		  		  	@ _nLin,015 psay "Solicitante"
		  		   	@ _nLin,057 psay "Dias"
		  		  	@ _nLin,064 psay "Horas"
	 	  		  	@ _nLin,071 psay "Minutos"
		  		   	@ _nLin,000 psay replicate("_",80)
		    	   	
			    	flag := 1
			endif
				_nLin++ 
		  		
				@ _nLin,005 psay TCQ->CODIGO
				//LGS#20200211 - Adequação de release 12.1.25 e posteriores
			    //@ _nLin,015 psay UsrFullName(CON->Z06_SOLCHA)
			    @ _nLin,015 psay fBusName( CON->Z06_SOLCHA )
			    //@ _nLin,047 psay TCQ->Z06_STATUS
			    @ _nLin,057 psay TCQ->DIAS
			    @ _nLin,064 psay TCQ->HRS
			    @ _nLin,071 psay TCQ->MINUTOS
			   	
			   	Dias   += TCQ->DIAS
			   	Hora   += TCQ->HRS
			   	Minuto += TCQ->MINUTOS
			   	numCham ++
			   				   		                           
			if _nLin > 55  .AND. !EOF()
  				@ _nLin,000 psay replicate("_",80)
 				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
 				_nLin := 04
	  		endif
		   endIf
			dbSelectArea("TCQ")
			dbSkip()        
			dbSelectArea("CON")  
			dbSkip()
		   	   
		  EndDo 
		  
		  if flag == 1
		  	  	nTotalMin := (Dias*1440)+(Hora*60)+Minuto  //Total minutos
		  		nTotalMedia := int(nTotalMin /numCham) //Media minutos
		  		dAux := nTotalMin % 1440     // Pegando resto da divisao de dias
		   		dia  :=int(nTotalMin/1440)   // Transformando Min em Dias
		   		hra  := int(dAux/60)         // Transformando min em Horas
		   		min  := dAux%60 			  // Pegando o resto da Hora e gerando min final	
		   		_nLin++  
   		 		@ _nLin,000 psay replicate("_",80)
		   		_nLin++  
				@ _nLin,000 psay "Dias: "+transform(dia,"E@ 999")+" Horas: "+transform(hra,"E@ 999")+" Min: "+transform(min,"E@ 99")
 				dAux := nTotalMedia % 1440
		   		dia  := int(nTotalMedia/1440)
		   		hra  := int(dAux/60)
		   		min  := int(dAux%60)
		   		 
				@ _nLin,030 psay "Total Chamados: "+transform(numCham,"E@ 999")+" Dias: "+transform(dia,"E@ 999")+" Horas: "+transform(hra,"E@ 999")+" Min: "+transform(min,"E@ 999")
 				@ _nLin,000 psay replicate("_",80)
 				_nLin++
 				nTotalMin:=dAux:=Dia:=Dias:=Hra:=Hora:=Min:= Minuto:= numCham:= nTotalMedia := 0
		  	endif
		  	
			dbSelectArea("TEC")  
			dbSkip()
			
			flag := 0
	EndDo
	dbselectarea("TEC")
	dbclosearea()
	              
	dbselectarea("TCQ")
	dbclosearea() 
	
	dbselectarea("CON")
	dbclosearea() 		
	
elseif(cParam == 2)   
		
	nTotalMin:=dAux:=Dia:=Dias:=Hra:=Hora:=Min:= Minuto:= numCham:=nTotalMin	 := 0
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	while !EOF()
	            
     	if _nLin > 55.AND. !EOF()
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 07
		endif   
		
	
		WHILE !EOF() .AND. (TCQ->TECNICO == TEC->TECNICO)
		
		if (CON->Z06_STATUS == "2")
		   		if flag == 0
			   		_nLin++   
			   		_nLin++ 
					@ _nLin,000 psay "Tecnico:"
					//LGS#20200211 - Adequação de release 12.1.25 e posteriores
			    	//@ _nLin,015 psay UsrFullName(TCQ->TECNICO)
			    	@ _nLin,015 psay fBusName( TCQ->TECNICO )
		    	   	_nLin++ 
		    	   	@ _nLin,000 psay replicate("-",80)
		    		_nLin++ 
		  		  	@ _nLin,005 psay "Num.Cham."
		  		  	@ _nLin,015 psay "Solicitante"
		  		   	@ _nLin,057 psay "Dias"
		  		  	@ _nLin,064 psay "Horas"
	 	  		  	@ _nLin,071 psay "Minutos"
		  		   	@ _nLin,000 psay replicate("_",80)
		    	   	
			    	flag := 1
			endif
				_nLin++ 
		  		
				@ _nLin,005 psay TCQ->CODIGO
			    //LGS#20200211 - Adequação de release 12.1.25 e posteriores
			    //@ _nLin,015 psay UsrFullName(CON->Z06_SOLCHA)
			    @ _nLin,015 psay fBusName( CON->Z06_SOLCHA )
			    //@ _nLin,047 psay TCQ->Z06_STATUS
			    @ _nLin,057 psay TCQ->DIAS
			    @ _nLin,064 psay TCQ->HRS
			    @ _nLin,071 psay TCQ->MINUTOS
			   	
			   	Dias   += TCQ->DIAS
			   	Hora   += TCQ->HRS
			   	Minuto += TCQ->MINUTOS
			   	numCham++			   		                           
			if _nLin > 55  .AND. !EOF()
  				@ _nLin,000 psay replicate("_",80)
 				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
 				_nLin := 04
	  		endif
		   endIf
			dbSelectArea("TCQ")
			dbSkip()        
			dbSelectArea("CON")  
			dbSkip()
		   	   
		  EndDo 
		  
		  	  if flag == 1
		  	  	nTotalMin := (Dias*1440)+(Hora*60)+Minuto  //Total minutos
		  		nTotalMedia := int(nTotalMin /numCham) //Media minutos
		  		dAux := nTotalMin % 1440     // Pegando resto da divisao de dias
		   		dia  :=int(nTotalMin/1440)   // Transformando Min em Dias
		   		hra  := int(dAux/60)         // Transformando min em Horas
		   		min  := dAux%60 			  // Pegando o resto da Hora e gerando min final	
		   		_nLin++  
   		 		@ _nLin,000 psay replicate("_",80)
		   		_nLin++  
				@ _nLin,000 psay "Dias: "+transform(dia,"E@ 999")+" Horas: "+transform(hra,"E@ 999")+" Min: "+transform(min,"E@ 99")
 				dAux := nTotalMedia % 1440
		   		dia  := int(nTotalMedia/1440)
		   		hra  := int(dAux/60)
		   		min  := int(dAux%60)
		   		 
				@ _nLin,030 psay "Total Chamados: "+transform(numCham,"E@ 999")+" Dias: "+transform(dia,"E@ 999")+" Horas: "+transform(hra,"E@ 999")+" Min: "+transform(min,"E@ 999")
 				@ _nLin,000 psay replicate("_",80)
 				_nLin++
 				nTotalMin:=dAux:=Dia:=Dias:=Hra:=Hora:=Min:= Minuto:= numCham:= nTotalMedia := 0
		  	endif
		  	
		  	
			dbSelectArea("TEC")  
			dbSkip()
			
			flag := 0
	EndDo
	dbselectarea("TEC")
	dbclosearea()
	              
	dbselectarea("TCQ")
	dbclosearea() 
	
	dbselectarea("CON")
	dbclosearea() 	
 
elseif(cParam == 3)
	nTotalMin:=dAux:=Dia:=Dias:=Hra:=Hora:=Min:= Minuto:=numCham:=nTotalMin	 := 0
	Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
	while !EOF()
	            
     	if _nLin > 55.AND. !EOF()
			@ _nLin,000 psay replicate("_",80)
			Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
			_nLin := 07
		endif   
		
	
		WHILE !EOF() .AND. (TCQ->TECNICO == TEC->TECNICO)
				
		   		if flag == 0
			   		_nLin++   
			   		_nLin++ 
					@ _nLin,000 psay "Tecnico:"
			    	//LGS#20200211 - Adequação de release 12.1.25 e posteriores
			    	//@ _nLin,015 psay UsrFullName(TCQ->TECNICO)
			    	@ _nLin,015 psay fBusName( TCQ->TECNICO )
		    	   	_nLin++ 
		    	   	@ _nLin,000 psay replicate("-",80)
		    		_nLin++ 
		  		  	@ _nLin,005 psay "Num.Cham."
		  		  	@ _nLin,015 psay "Solicitante"
		  		   	@ _nLin,057 psay "Dias"
		  		  	@ _nLin,064 psay "Horas"
	 	  		  	@ _nLin,071 psay "Minutos"
		  		   	@ _nLin,000 psay replicate("_",80)
		    	   	
			    	flag := 1
			endif
				_nLin++ 
		  		
				@ _nLin,005 psay TCQ->CODIGO
				//LGS#20200211 - Adequação de release 12.1.25 e posteriores
			    //@ _nLin,015 psay UsrFullName(CON->Z06_SOLCHA)
			    @ _nLin,015 psay fBusName( CON->Z06_SOLCHA )
			    //@ _nLin,047 psay TCQ->Z06_STATUS
			    @ _nLin,057 psay TCQ->DIAS
			    @ _nLin,064 psay TCQ->HRS
			    @ _nLin,071 psay TCQ->MINUTOS
			   	
			   	Dias   += TCQ->DIAS
			   	Hora   += TCQ->HRS
			   	Minuto += TCQ->MINUTOS
			   	numCham ++			   		   			   				   		                           
			if _nLin > 55  .AND. !EOF()
  				@ _nLin,000 psay replicate("_",80)
 				Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
 				_nLin := 04
	  		endif
		  
			dbSelectArea("TCQ")
			dbSkip()        
			dbSelectArea("CON")  
			dbSkip()
		   	   
		  EndDo 
		  
		 	  if flag == 1
		  	  	nTotalMin := (Dias*1440)+(Hora*60)+Minuto  //Total minutos
		  		nTotalMedia := int(nTotalMin /numCham) //Media minutos
		  		dAux := nTotalMin % 1440     // Pegando resto da divisao de dias
		   		dia  :=int(nTotalMin/1440)   // Transformando Min em Dias
		   		hra  := int(dAux/60)         // Transformando min em Horas
		   		min  := dAux%60 			  // Pegando o resto da Hora e gerando min final	
		   		_nLin++  
   		 		@ _nLin,000 psay replicate("_",80)
		   		_nLin++  
				@ _nLin,000 psay "Dias: "+transform(dia,"E@ 999")+" Horas: "+transform(hra,"E@ 999")+" Min: "+transform(min,"E@ 99")
 				dAux := nTotalMedia % 1440
		   		dia  := int(nTotalMedia/1440)
		   		hra  := int(dAux/60)
		   		min  := int(dAux%60)
		   		 
				@ _nLin,030 psay "Total Chamados: "+transform(numCham,"E@ 999")+" Dias: "+transform(dia,"E@ 999")+" Horas: "+transform(hra,"E@ 999")+" Min: "+transform(min,"E@ 999")
 				@ _nLin,000 psay replicate("_",80)
 				_nLin++
 				nTotalMin:=dAux:=Dia:=Dias:=Hra:=Hora:=Min:= Minuto:= numCham:= nTotalMedia := 0
		  	endif
		  	
		  	
			dbSelectArea("TEC")  
			dbSkip()
			
			flag := 0
	EndDo
	dbselectarea("TEC")
	dbclosearea()
	              
	dbselectarea("TCQ")
	dbclosearea() 
	
	dbselectarea("CON")
	dbclosearea() 	
endif

Set Device To Screen
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

Return

Static Function fBusName( _nCodigo )
Return UsrFullName( _nCodigo )

//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*Static Function CriaSX1(cPerg)
       Local j, i
       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}

      	PutSX1(cPerg, "01","Status         " ,"","","mv_ch1","N",1,00,00,"C","","   ","","","MV_PAR01","Aberto","","","","Encerrado","","","Todos Chamados","","","","","","","","",NIL,NIL,NIL,"")
		PutSX1(cPerg, "02","de Solicitante " ,"","","mv_ch2","C",6,00,00,"G","","SZH","","","MV_PAR02","      ","","","","         ","","","         ","","","              ","","","","","",NIL,NIL,NIL,"")
	    PutSX1(cPerg, "03","ate Solicitante" ,"","","mv_ch3","C",6,00,00,"G","","SZH","","","MV_PAR03","      ","","","","         ","","","         ","","","              ","","","","","",NIL,NIL,NIL,"")
		PutSX1(cPerg, "04","de Tecnico     " ,"","","mv_ch4","C",6,00,00,"G","","SZH","","","MV_PAR04","      ","","","","         ","","","          ","","","              ","","","","","",NIL,NIL,NIL,"")
	    PutSX1(cPerg, "05","ate Tecnico    " ,"","","mv_ch5","C",6,00,00,"G","","SZH","","","MV_PAR05","      ","","","","         ","","","          ","","","              ","","","","","",NIL,NIL,NIL,"")
      	
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return*/