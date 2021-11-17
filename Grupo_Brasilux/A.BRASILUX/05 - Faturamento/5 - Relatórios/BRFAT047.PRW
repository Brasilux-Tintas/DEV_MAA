#include "rwmake.ch"        
#INCLUDE "TOPCONN.CH"

User Function BRFAT047()     


/*/
Programa: BRFAT047  Autor:  Cleber Orati Domingues     
Data:     25/01/2002
Descricao:Rel Tabela de Descontos
/*/

	Private tamanho,limite,titulo,cbcont,nOrdem,Z,M,cDesc1,cDesc2,cDesc3
	Private cCabec,cCabPro,cNatureza,aReturn,nomeprog,cPerg,lContinua,nLin,nCol,wnrel,nTipo
	Private cCabec1,cCabec2,cCabec3,nTamnf,cString,mv_par01,mv_par02,_nLin,CbTxt,Alfa,nLastKey,m_pag




	CbTxt    :=""
	CbCont   :=0
	nOrdem   :=0
	Alfa     :=0
	Z 	     :=0
	M        :=0
	tamanho  :="P"
	limite   :=80
	titulo   :="TABELA DE DESCONTOS(P/ TABELA 60 DIAS) "
	cDesc1   :=PADC("Este programa ira emitir a Tabela de Descontos",74)
	cDesc2   :=""
	cDesc3   :=PADC(" ",74)
	cCabec   :=PADC("Tabela de Descontos",27)
	cCabPro  :=""
	cNatureza:=""
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog :="BRFAT047"
	cPerg    :="BRFT47"
	nLastKey := 0
	lContinua:=.T.
	_nLin    := 90
	nCol     := 60
	wnrel    := "BRFAT047"
	nTipo    := 18
	m_pag    := 01  
	
	if !u_VldAcesso(funname())
		MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
        return 
    endif 
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Tamanho do Formulario  (em Linhas)                        ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    nTamNf   :=83     // Apenas Informativo

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica as perguntas selecionadas, busca o padrao                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    cString  :="SB1"

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Envia controle para a funcao SETPRINT                        ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    //ValidPerg()
    Pergunte(cPerg,.F.)   

    wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,,Tamanho)

    SetDefault(aReturn,cString)

    If nLastKey == 27
    	Return
    Endif


    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Inicio do Processamento do Relatorio                         ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    RptStatus({|| RptDetail()})

Static Function RptDetail()

	Private cLucro,nAuxPerc,nPerint,nAux,nLC1,nLC2,cIcms
	Private nJuros,cLinhas,cQuery,nIcms
	do case
		case mv_par02 == 1
			cIcms := "18 %"
			nIcms = 18
		case mv_par02 == 2
			cIcms := "12 %"
			nIcms = 12
		case mv_par02 == 3
			cIcms := "7 %"
			nIcms = 7
		case mv_par02 == 4
			cIcms := "19 %"
			nIcms = 19
		endcase
		
		if cNumEmp == "01010104"
			cQuery := "SELECT MAX(B1_PERINT+B1_COMIS+B1_LUCRO) AS PERINT FROM "+RetSqlName("SB1")+" A" 
			cQuery := cQuery + " WHERE (A.B1_FILIAL = '"+xFilial("SB1")+"')"
			cQuery := cQuery + " AND (A.B1_TIPO = 'PA') AND A.D_E_L_E_T_ <> '*'"
			//				0       1           2          3        4          5      6         7
			//          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
			cCabec1  := " COND. PAGAMENTO                           ICMS 18%  ICMS 12%    ICMS 7%    "
			cCabec2  :=""
			cCabec3  :=""
		else 
		//				0       1           2          3        4          5      6         7
		//          1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
		cCabec2  :=" COND. PAGAMENTO                        PROD ESTOQ  PROD N EST     "
		cCabec3  :=""
		cCabec1  :="LINHAS "


		// Det. de qual lucro utilizar, dependendo da tab. de preços utilizada

		cQuery = "SELECT DISTINCT SUBSTRING(B1_COD,4,2) AS LINHA,B1_COMIS+B1_LUCRO"+;
		" AS PERINT,B1_COMIS+B1_LUCRO2 AS PERINT2,B1_COMIS+B1_LUCRO+B1_LUCRO2 AS SOMA"+;
		" FROM "+RetSqlName("SB1")+" " +;
		" WHERE (B1_FILIAL = '"+xFilial("SB1")+"')" +;
		" AND (B1_TIPO = 'PA')"+;
		" AND (LEN(B1_COD) = 12)"+;
		" AND (D_E_L_E_T_ <> '*') ORDER BY SOMA,LINHA"	
	endif
	/*
	cQuery := "SELECT MAX(B1_PERINT+B1_COMIS+"+cLucro+") AS PERINT FROM "+RetSqlName("SB1")+" A" 
	cQuery := cQuery + " WHERE A.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery := cQuery + " AND A.D_E_L_E_T_ <> '*'"
	*/

	TCQuery cQuery NEW ALIAS "PERC" 

	cQuery := "SELECT * FROM "+RetSqlName("SE4")+" A" 
	cQuery := cQuery + " WHERE A.E4_TABELA = 'S'"
	cQuery := cQuery + " AND A.D_E_L_E_T_ <> '*'"
	cQuery := cQuery + " ORDER BY A.E4_CODIGO "

	TCQuery cQuery NEW ALIAS "TCQ" 

	DO CASE
		CASE cnumemp == "01010104"
			DescResina()
		otherwise
			DescTintas()
	endcase
return

Static Function DescTintas
	Local i
	Local nPercIcm := (GETMV("MV_ICMPAD")/100)
	Local nJuros := getmv("MV_JUROS")  
	dbselectarea("PERC")
	dbgotop()
	while !eof()
		if perc->linha == "01"
			_nLinh := 90
		endif
		_nLin := 90
		nAux = PercInt()
		nPerint := nAux/100 //(PERC->PERINT + nAux)/100
		nLC1 := PERC->PERINT
		nLC2 := PERC->PERINT2
		nAuxPerc := PERC->SOMA
		cLinhas := ""
		
		dbselectarea("PERC")
		while !eof() .and. (PERC->SOMA == nAuxPerc)
			cLinhas += ","+PERC->LINHA
			dbselectarea("PERC")
			dbskip()
		enddo
		if len(cLinhas) > 0
			cLinhas := substr(cLinhas,2,len(cLinhas))
		endif
  	
		dbSelectArea("TCQ")
		dbgotop()
  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa  regua de impressao                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		SetRegua(Reccount())
		
		
		While ! EoF()      
   
			if len(cLinhas) > 72
				cCabec3 := substr(cLinhas,73,80)
			else
				cCabec3 := ""
			endif                        
			If _nlin >= 60
				if len(cCabec3) > 0
					Cabec(titulo,cCabec2,"",nomeprog,tamanho,nTipo)
					_nLin := 8
					@ _nLin,00 psay cCabec1+substr(cLinhas,1,72)
					_nLin++
					@ _nLin,00 psay cCabec3
					_nLin++
					@_nLin,00 psay replicate("_",80)
					_nLin++
				else
					Cabec(titulo,cCabec1+cLinhas,cCabec2,nomeprog,tamanho,nTipo)
					_nLin:= 08 
				endif
			Endif
      
			// Criando vetor c/ prazos de pagamento
		
			aPrazos:={}

			cAux := RTRIM(TCQ->E4_COND)   
			if len(cAux) == 0
				AADD(aPrazos,0)
			else
				nPos1 = 1
				for i := 1 to len(cAux)
					if substr(cAux,i,1) == ","
						AADD(aPrazos,val(substr(cAux,nPos1,nPos2-nPos1+1)))   
						nPos1 = i+1
					else             
						nPos2 = i
						if i == len(cAux)
							nPos2 = i
							AADD(aPrazos,val(substr(cAux,nPos1,nPos2-nPos1+1)))  
						endif
					endif
				next
			endif

			nQtdeParc = len(aPrazos)
			nInd = 0
			for i = 1 to nQtdeParc
				nAux = (1/nQtdeParc)/((1+(nJuros/100))^((12*aPrazos[i])/365))
				nInd = nInd+nAux
			next                             
			nIndAnt = (1+(nJuros/100))^((12*60)/365) && 60 dias

			//nDesc1 = (nInd - (1/nIndAnt) + (GETMV("MV_ICMPAD")/100) - (nIcms/100))/(nInd - nPerint - (nLC1/100) - (nIcms/100))
			//nDesc2 = (nInd - (1/nIndAnt) + (GETMV("MV_ICMPAD")/100) - (nIcms/100))/(nInd - nPerint - (nLC2/100) - (nIcms/100))
			// ADEQUAÇÃO RELEASE 12.1.25	
			
			nDesc1 = (nInd - (1/nIndAnt) + (nPercIcm) - (nIcms/100))/(nInd - nPerint - (nLC1/100) - (nIcms/100))
			nDesc2 = (nInd - (1/nIndAnt) + (nPercIcm) - (nIcms/100))/(nInd - nPerint - (nLC2/100) - (nIcms/100))
			

/*
			nDesc1 = (nInd - (1/nIndAnt))/(nInd - nPerint - 0.18)
			nDesc2 = (nInd - (1/nIndAnt) + 0.18 - 0.12 )/(nInd - nPerint - 0.12)
			nDesc3 = (nInd - (1/nIndAnt) + 0.18 - 0.07 )/(nInd - nPerint - 0.07)
			nDesc4 = (nInd - (1/nIndAnt) + 0.18 - 0.00 )/(nInd - nPerint - 0.00)
*/

      		@ _nlin,001 PSAY TCQ->E4_CODIGO +"-"+ TCQ->E4_DESCRI
      		@ _nlin,041 PSAY nDesc1*100 picture "@E 999.999999"
      		@ _nlin,051 PSAY "%"
      		@ _nlin,052 PSAY nDesc2*100 picture "@E 999.999999"
      		@ _nlin,062 PSAY "%"
      		/*@ _nlin,069 PSAY nDesc3*100 picture "@E 999.999999"
      		@ _nlin,079 PSAY "%"
      		@ _nlin,054 PSAY nDesc4*100 picture "@E 999.999999"
      		@ _nlin,064 PSAY "%" */
      		_nlin++  
     
      		dbSelectArea("TCQ")              
      		dbskip()
      	End
      	_nLin ++
      	@_nLin,00 psay replicate("*",80)
      	
      	If (_nlin+6) >= 60
      		Roda(cbcont,cbtxt,tamanho)
      		if len(cCabec3) > 0
      			Cabec(titulo,cCabec2,"",nomeprog,tamanho,nTipo)
      			_nLin := 8
      			@ _nLin,00 psay cCabec1+substr(cLinhas,1,66)
      			_nLin++
      			@ _nLin,00 psay cCabec3
      			_nLin++
      			@_nLin,00 psay replicate("_",80)
      			_nLin++
      		else
      			Cabec(titulo,cCabec1+cLinhas,cCabec2,nomeprog,tamanho,nTipo)
      			_nLin:= 08 
      		endif
      	Endif
  	
      	_nLin++
      	@_nLin,00 psay "Obs.: ICMS "+cIcms+". Os percentuais ref. a COLUNA 1 sao aplicaveis aos produ-"
      	_nLin++
      	@_nLin,00 psay "tos que aparecem com asterisco(*) na tabela. Os percentuais referentes aos pro"
      	_nLin++
      	@_nLin,00 psay "dutos que aparecem na COLUNA 2 sao aplicaveis aos demais produtos da tabela.  "
      	/*
      	_nLin++
      	@_nLin,00 psay "Caso a qtdade vendida dos produtos sem asterico atinjam a cota minima exigida "
      	_nLin++
      	@_nLin,00 psay "pela fabrica, aplicam-se os percentuais da COLUNA 3."
      	*/

      	_nLin ++
      	@_nLin,00 psay replicate("*",80)
      	Roda(cbcont,cbtxt,tamanho)
      	
        dbselectarea("PERC")
    enddo	

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³                      FIM DA IMPRESSAO                        ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


    dbSelectArea("TCQ")
    dbCloseArea()
    dbSelectArea("PERC")
    dbCloseArea()

    dbSelectArea("SB1")
    
    Set Device To Screen
    If aReturn[5] == 1
    	Set Printer TO
    	dbcommitAll()
    	ourspool(wnrel)
    Endif

Return


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                   FUNCOES ESPECIFICAS                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	/*/
	Programa: VALIDPERG   Autor:  Fernando Roquete     
	Data:     05/06/01
	Descricao:Grava Perguntas
	/*/
/* DESABILITADA FUNÇÃO PARA ADEQUAÇÃO DA RELEASE 12.1.25
Static Function ValidPerg()
	
	Local _sAlias := Alias()
	Local i, j
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	AADD(aRegs,{cPerg,"01","Planilha  ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Qual ICMS ?","","","mv_ch2" ,"C",03,0,0,"C","","mv_par02","18%","","","","","12%","","","","","7%","","","","","19%","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		if !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.F.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()     
		endif
    
	Next

	dbSelectArea(_sAlias)
Return

*/
//Função p/ calcular perc. interno
Static Function PercInt()

	Local cPlanilha,nArq,nPerc,nTamArq,lOk,aAux,nLidos,cLinha
	nPerc := 0
	cPlanilha = alltrim(mv_par01)+".pdv"
	nArq = fopen(cPlanilha)
	nLidos = 0
	if nArq > 0 
		FSEEK(nArq,0,0)
		nTamArq:=FSEEK(nArq,0,2)
		FSEEK(nArq,0,0)
		lOk = .f.
		aAux := {}
		while nLidos < nTamArq
			cLinha = U_fgets(nArq,nTamArq)
			if substr(cLinha,6,3) $ "PIS_IVA"
				lOk = .t.
			endif
			if lOk
				nPerc += U_cton(alltrim(substr(cLinha,36,10)))
			endif	
	
			if substr(cLinha,6,16) == "DESP. COMERCIAIS"
				lOk = .f.
			endif
			
			nLidos += len(cLinha)+2
		end
		fclose(nArq)
	else
		Alert("Impossível abrir planilha "+cPlanilha)
		return(0)
	endif
	
return(nPerc)    


Static Function DescResina
Local nJuros := getmv("MV_JUROS")
Local i
dbselectarea("PERC")
dbgotop()
_nLin := 90
nAux = PercInt()
nPerint := (PERC->PERINT + nAux)/100
cLinhas := ""
	dbSelectArea("TCQ")
	dbgotop()
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa  regua de impressao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(Reccount())
  	While ! EoF()      
   
		if len(cLinhas) > 66
			cCabec3 := substr(cLinhas,67,80)
		else
			cCabec3 := ""
		endif                        
   		If _nlin >= 60
			if len(cCabec3) > 0
	        	Cabec(titulo,cCabec2,"",nomeprog,tamanho,nTipo)
	        	_nLin := 8
	        	@ _nLin,00 psay cCabec1+substr(cLinhas,1,66)
	        	_nLin++
	        	@ _nLin,00 psay cCabec3
	        	_nLin++
	        	@_nLin,00 psay replicate("_",80)
	        	_nLin++
			else
	        	Cabec(titulo,cCabec1+cLinhas,cCabec2,nomeprog,tamanho,nTipo)
	        	_nLin:= 08 
			endif
      	Endif
      
		// Criando vetor c/ prazos de pagamento
		aPrazos:={}

		cAux := RTRIM(TCQ->E4_COND)   
		if len(cAux) == 0
			AADD(aPrazos,0)
		else
			nPos1 = 1
			for i := 1 to len(cAux)
				if substr(cAux,i,1) == ","
					AADD(aPrazos,val(substr(cAux,nPos1,nPos2-nPos1+1)))   
					nPos1 = i+1
				else             
					nPos2 = i
					if i == len(cAux)
						nPos2 = i
						AADD(aPrazos,val(substr(cAux,nPos1,nPos2-nPos1+1)))  
					endif
				endif
			next
		endif

		nQtdeParc = len(aPrazos)
		nInd = 0
		for i = 1 to nQtdeParc
			nAux = (1/nQtdeParc)/((1+(nJuros/100))^((12*aPrazos[i])/365))
			nInd = nInd+nAux
		next                             
		nIndAnt = (1+(nJuros/100))^((12*60)/365) && 60 dias

		nDesc1 = (nInd - (1/nIndAnt))/(nInd - nPerint - 0.18)
		nDesc2 = (nInd - (1/nIndAnt) + 0.18 - 0.12 )/(nInd - nPerint - 0.12)
		nDesc3 = (nInd - (1/nIndAnt) + 0.18 - 0.07 )/(nInd - nPerint - 0.07)
		nDesc4 = (nInd - (1/nIndAnt) + 0.18 - 0.00 )/(nInd - nPerint - 0.00)

      	@ _nlin,001 PSAY TCQ->E4_CODIGO +"-"+ TCQ->E4_DESCRI
	      
      	@ _nlin,041 PSAY nDesc1*100 picture "@E 999.999999"
      	@ _nlin,051 PSAY "%"
      	@ _nlin,052 PSAY nDesc2*100 picture "@E 999.999999"
      	@ _nlin,062 PSAY "%"
      	@ _nlin,063 PSAY nDesc3*100 picture "@E 999.999999"
      	@ _nlin,073 PSAY "%"
     	/* @ _nlin,054 PSAY nDesc4*100 picture "@E 999.999999"
      	@ _nlin,064 PSAY "%" */
      	_nlin++  
     
    	dbSelectArea("TCQ")              
    	dbskip()
  	End
  
	Roda(cbcont,cbtxt,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                      FIM DA IMPRESSAO                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


dbSelectArea("TCQ")
dbCloseArea()

dbSelectArea("PERC")
dbCloseArea()

dbSelectArea("SB1")
Set Device To Screen
If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

Return

