#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"   
#INCLUDE "TBICONN.CH"     
#INCLUDE "TBICODE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IBFWEXCEL    ºAutor  ³Rafael Motta     º Data ³  09/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que gera Excel de qualquer query 		   			  º±±
±±º          ³                    	 									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                               						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function IBFWEXCEL(cNomePlan1 ; // Nome Planilha // 1
,cQuery ; // Query // 2
,cTitulo1 ; // Titulo tabela // 3
,cLocName ; // Diretorio + Arquivo // 4
,lAbre ; // Abre Excel // 5
,lGeraObj ; // Gera objeto // 6
,lQuery ; // Usa query ou nao // 7
,cTabela1 ; // Nome da temporaria que sera usada // 8
,lTot ; // Totalizadores? // 9
,lEmail ; // Envia Email? // 10   
,cDest ; // Destinatarios // 11
,cEmail ; // Assunto email // 12
,cBody ; // Assunto email // 13
,nTema ; // Tema de Cores e Fontes // 14
,lSX3 ; // Utiliza SX3 para Formatar campos? // 15
,_lMultAba ; // Utiliza Multiplas Abas baseado na coluna 1 // 16
,_lZML;  // Utiliza Rotima ZML no email? // 17  
,_lXLSX; // Gera XLSX // 18
,lSemMasc; // Grava a máscara do campo // 19
,aTitHead; // Titulos das Colunas // 20
,lAviso; //21
,aStru_; //Array com pictures dos campos numericos com 2 posições, nome do campo e picture, o restante ira respeitar o padrao // 21
)  

Local r_ := 0
Local p_:= 0
//Private oExcel := FWMSEXCEL():New()
Private aStru := {} 
Private nPosi := 0
Private nPosi2 := 0
Private aDados := {}
Private oProcess := NIL 
Private lEnd := .f.                
Private cNomePlan := cNomePlan1
Private cTitulo := cTitulo1
Private cTabela := ""
Private aTotal	:= {}
Private nTotF := 0
Private lVerSX3 := .T.
Private lMultAba := .F.
Private oExcel 

Default lQuery   := .T.
Default lAbre 	 := .T.
Default lGeraObj := .T.
Default cTabela1  := "TRB_"
Default lTot := .F.
Default lEmail := .F.
Default cDest  := ""
Default cEmail := cNomePlan1
Default cBody := cEmail
Default nTema := 1
Default lSX3 := .T.
Default _lMultAba := .F.
Default lZML := .F.
Default _lXLSX := .F.
Default lSemMasc := .F.
Default aTitHead := {}
Default lAviso := .F.
Default aStru_ := {}

cTabela := cTabela1
lVerSX3 := lSX3
lMultAba := _lMultAba
lZML := _lZML

//If Right(Alltrim(cLocName),4) == ".xls"
	
//Endif

If _lXLSX
	oExcel :=FwMsExcelXlsx():New()	
	//cLocName := STRTRAN(cLocName,".xlsx",".xlsx")
Else
	oExcel := FWMsExcelEx():New()
	cLocName := STRTRAN(cLocName,".xlsx",".xls")
Endif
///////////////////////////////////////////////////////////////////////////////
// Parametros de Estilo da Planila / Cores / Fontes
If !_lXLSX
	If nTema == 1 // Tema Padrao
		 //Tema Monocromatico - Cinza / Branco
	oExcel:SetTitleBgColor("#fafafa") // Cor linha titulo
	oExcel:SetTitleFrColor("#000000") // Cor fonte titulo

	oExcel:SetBgColorHeader("#696969") // Cor linha cabecalho
	oExcel:SetFrColorHeader("#ffffff") // Cor fonte cabecalho

	oExcel:SetLineBgColor("#ffffff") // Cor linha 1
	oExcel:Set2LineBgColor("#ebebeb") // Cor linha 2
	EndIf
Endif
///////////////////////////////////////////////////////////////////////////////

If lQuery              
	IF SELECT(cTabela) <> 0
		(cTabela)->(DBCLOSEAREA())
	Endif	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQUERY),'TRB_',.F.,.T.)
	Memowrite("C:\TEMPOR\"+cNomePlan+".sql",cQUERY)
Endif
	
DBSELECTAREA(cTabela)	
COUNT TO nRec
	
If nRec == 0
	If !FunName() $ "CST05/U_CST05/CST08/U_CST08/EnDivCOM/U_EnDivCOM/"
		MsgAlert("Sem dados para consulta... ")
	ENDIF
	Return()
Endif	

aSort(aStru_,,,{|x,y| x[1] < y[1]})
aStru := (cTabela)->(DbStruct())
aStru2 := {}

 (cTabela)->(dbGoTop())

If _lMultAba

	//Remove primeira coluna utilizada como Aba apenas
	aDel(aStru,1)
	aSize(aStru,Len(aStru)-1)

	_AbaTmp := ""
	While (cTabela)->(!EOF())
		If _AbaTmp <> AllTrim((cTabela)->ABA)
			_AbaTmp := AllTrim((cTabela)->ABA)
			cNomePlan := _AbaTmp

			oExcel:AddworkSheet(cNomePlan)
			oExcel:AddTable (cNomePlan,cTitulo)

			//adiciona coluna                             
			dbSelectArea("SX3")
			dbSetOrder(2)

			For r_ := 1 to Len(aStru)     
				oExcel:AddColumn(cNomePlan,cTitulo,aStru[r_][1],1,iif(aStru[r_][2]=="C",1,IIF(aStru[r_][2]=="N",2,1)))
					If MsSeek(aStru[r_][1])
						If SX3->X3_TIPO == "D" .AND. ALLTRIM(SX3->X3_CAMPO) ==  Alltrim(aStru[r_][1])			
							aStru[r_][2] := "D"
						EndIf	
						aadd(aStru2,{SX3->X3_TITULO})
					ElseIf aStru[r_][1] == "R_E_C_N_O_"
						aadd(aStru2,{"RECNO"})		 
					EndIf
			Next r_	

			aDados := Array(nRec,Len(aStru))
			While (cTabela)->(!Eof()) 
				If AllTrim((cTabela)->ABA) <> cNomePlan
					Exit
				EndIf
				nPosi2 += 1
				For p_ := 1 to Len(aStru)
					cCamp := cTabela+"->"+alltrim(aStru[p_][1])
					_valor := &cCamp
					If ValType(_valor) == "D"
						If !DTOS(&cCamp) == "19000101"
							aDados[nPosi2][p_] := IIF(aStru[p_][2 ] == "D",DTOC(&cCamp),&cCamp)
						Else
							aDados[nPosi2][p_] := ""
						EndIf
					Else
						aDados[nPosi2][p_] := IIF(aStru[p_][2 ] == "D",Substr(&cCamp,7,2)+"/"+Substr(&cCamp,5,2)+"/"+Substr(&cCamp,1,4),&cCamp)
					EndIf
					If aStru[p_][2] == "C"
						aDados[nPosi2][p_] := StrTran( aDados[nPosi2][p_], "<", "" ) 
						aDados[nPosi2][p_] := StrTran( aDados[nPosi2][p_], ">", "" ) 
					Endif
				Next p_
				oExcel:AddRow(cNomePlan,cTitulo,aDados[nPosi2])
				(cTabela)->(dbskip())
			EndDo
		EndIf		
	EndDo


Else
	oExcel:AddworkSheet(cNomePlan)
	oExcel:AddTable (cNomePlan,cTitulo)
	//adiciona coluna                             
	dbSelectArea("SX3")
	dbSetOrder(2)

	For r_ := 1 to Len(aStru)     

		//Titulo Coluna
		nPosTit := 0
		cTit := aStru[r_][1]		
		nPosTit := aScan(aTitHead,{|x| Trim(x[1])==AllTrim(cTit)})	
		cTipoCampo := ""
		If nPosTit > 0
			cTit := aTitHead[nPosTit][2]
			If !Empty(aTitHead[nPosTit][3])
				cTipoCampo := aTitHead[nPosTit][3]
			EndIf
		EndIf

		If cTipoCampo == "D"
			oExcel:AddColumn(cNomePlan,cTitulo,cTit,1,4)
			aStru[r_][2] := "D"
		ElseIf lSemMasc
			oExcel:AddColumn(cNomePlan,cTitulo,cTit,1,iif(aStru[r_][2]=="C",1,IIF(aStru[r_][2]=="N",2,1)),,iif(aStru[r_][2]=="C","@!",IIF(aStru[r_][2]=="N","9999","@!")))
		Else
			//Adicionar casa decimal aqui . - Rafael Motta
			//oExcel:AddColumn(cNomePlan,cTitulo,cTit,1,iif(aStru[r_][2]=="C",1,IIF(aStru[r_][2]=="N",2,1)))
			If Len(aStru_) > 0
				If aScan(aStru_,{|x| x[1] == cTit }) > 0
					oExcel:AddColumn(cNomePlan,cTitulo,cTit,1,2,,,aStru_[aScan(aStru_,{|x| x[1] == cTit })][2])
				Else
					oExcel:AddColumn(cNomePlan,cTitulo,cTit,1,iif(aStru[r_][2]=="C",1,IIF(aStru[r_][2]=="N",2,1)))
				Endif	
			Else
				oExcel:AddColumn(cNomePlan,cTitulo,cTit,1,iif(aStru[r_][2]=="C",1,IIF(aStru[r_][2]=="N",2,1)))
			Endif

			//oExcel:AddColumn(cNomePlan,cTitulo,cTit,1,iif(aStru[r_][2]=="C",1,IIF(aStru[r_][2]=="N",2,1)),	,iif(aStru[r_][2]=="C","@!",IIF(aStru[r_][2]=="N","999,999,999.999","@!")))
		Endif
		If MsSeek(aStru[r_][1])
			If SX3->X3_TIPO == "D" .AND. ALLTRIM(SX3->X3_CAMPO) ==  Alltrim(aStru[r_][1])			
				aStru[r_][2] := "D"
			EndIf	
			aadd(aStru2,{SX3->X3_TITULO})
		ElseIf aStru[r_][1] == "R_E_C_N_O_"
			aadd(aStru2,{"RECNO"})		 
		EndIf
	Next r_	

	If (alltrim(Funname()) == "RPC" .or. alltrim(Funname()) == "APOJOB" .or. alltrim(Funname()) == "APOSCH")
		lGeraObj := .F.
	Endif

	If lGeraObj 
		INIPROC(.t.,lTot)
	Else
		If lAviso			
			Processa({|| Roda() },'Processando dados...')
		Else		
			Roda()	
		Endif
	Endif	
EndIf

oExcel:Activate()
oExcel:GetXMLFile(cLocName)
If lAbre
	If ALLTRIM(Funname()) <> "RPC"
		IncProc("Abrindo Microsoft Excel")
		WinExec( 'RunDLL32.EXE shell32.dll,ShellExec_RunDLL "' + cLocName+ '"' ,1) 
	Endif	
Endif	

If lEmail
	
	If  lZML
		cMsg := cBody
		_cPathAnex := cLocName
		U_ZMLGRAVA("ibar@ibar.com.br",cDest,cEmail,cMsg,_cPathAnex)	
	Else
		cMsg := cBody
		If _lXLSX
			_cPathAnex := "\IBANEXO\ibemail\"+cNomePlan1+".xlsx"
		else
			_cPathAnex := "\IBANEXO\ibemail\"+cNomePlan1+".xls"	
		Endif
		__CopyFile(cLocName,_cPathAnex)
		U_IBEMAIL("ibar@ibar.com.br",cDest,cEmail,cMsg,_cPathAnex)	
	EndIf

Endif

Return() 
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
Static Function INIPROC(lMarca,lTot)

oProcess := MsNewProcess():New( { | lEnd | lOk := marca( lEnd, lMarca,lTot ) }, 'Gerando Relatório', 'Aguarde, selecionando registros ...', .F. )
oProcess:Activate() 

Return
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
Static Function Marca(lEnd,lMarca,lTot)

Local p_ := 0
Local j := 0
DbSelectArea(cTabela) 
dbgotop()

If lTot
	aDados := Array(nRec+1,Len(aStru))  	
    aTotal := Array(1,Len(aStru))  	
Else
	aDados := Array(nRec,Len(aStru))  
Endif

oProcess:SetRegua1(Len(aDados))
While !Eof()
	nPosi2 += 1	
	oProcess:SetRegua2(Len(aStru)) 
	
		 For p_ := 1 to Len(aStru)
	     	oProcess:IncRegua2(aStru[p_][1])
			//ProcessMessages()
			//Sleep(1)
	     	 cCamp := cTabela+"->"+alltrim(aStru[p_][1])	
			If lVerSX3
				If Valtype(&cCamp) == "D"
					aDados[nPosi2][p_] := &cCamp
				Else
					aDados[nPosi2][p_] := IIF(aStru[p_][2 ] == "D",Substr(&cCamp,7,2)+"/"+Substr(&cCamp,5,2)+"/"+Substr(&cCamp,1,4),&cCamp)
				Endif
			Else
				aDados[nPosi2][p_] := IIF(aStru[p_][2 ] == "D",DTOC(&cCamp),&cCamp)
			EndIf		 
			If aStru[p_][2] == "C"
			 	aDados[nPosi2][p_] := StrTran( aDados[nPosi2][p_], "<", "" ) 
			 	aDados[nPosi2][p_] := StrTran( aDados[nPosi2][p_], ">", "" ) 
			Endif
			 If lTot			 	
			 	If aStru[p_][2] == "N"
			 		If ValType(aTotal[1][p_]) == "U"
			 			aTotal[1][p_] := 0
			 		Endif    
		 			aTotal[1][p_] += &cCamp
			 	Else
				 	aTotal[1][p_] := ""
			 	Endif
			 Endif
		 Next p_
	oExcel:AddRow(cNomePlan,cTitulo,aDados[nPosi2])
	oProcess:IncRegua1(aDados[nPosi2][1])
	//ProcessMessages()
	//Sleep(1)
	dbskip()
EndDo

If lTot	     
	aTotal[1][1] := "TOTAIS ---------->"
	at := {}	
	For j:=1 To Len(aDados[1])
		aadd(at,"")		
	Next j
	oExcel:AddRow(cNomePlan,cTitulo,at)
	oExcel:AddRow(cNomePlan,cTitulo,aTotal[1])
Endif

Return
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

User Function IBFWXLS (cNomePlan1,cQuery,cTitulo1,cLocName,lAbre,lGeraObj,lQuery/*Usa query ou nao*/,cTabela1/*Nome da temporaria que sera usada*/)  //MESMA ROTINA SEM CRIAÇÃO DE OBJETO NA CONSTRUÇÃO DA MESMA. 

Local r_ := 0
Local p_ := 0
Private oExcel := FwMsExcelXlsx():New() //FWMSEXCEL():New()      
Private aStru := {} 
Private nPosi := 0
Private nPosi2 := 0
Private aDados := {}
Private oProcess := NIL 
Private lEnd := .f.                
Private cNomePlan := cNomePlan1
Private cTitulo := cTitulo1

Default lAbre := .T.
Default lGeraObj := .T.

IF SELECT(cTabela) <> 0
	(cTabela)->(DBCLOSEAREA())
Endif

DbUseArea(.T.,"TOPCONN",TCGENQry(,,cQuery),'TRB_',.T.,.T.)	
COUNT TO nRec
aStru := DbStruct()

oExcel:AddworkSheet(cNomePlan)
oExcel:AddTable (cNomePlan,cTitulo)

dbSelectArea("SX3")
dbSetOrder(2)
For r_ := 1 to Len(aStru)
		oExcel:AddColumn(cNomePlan,cTitulo,aStru[r_][1],1,iif(aStru[r_][2]=="C",1,IIF(aStru[r_][2]=="N",2,1)))
		If MsSeek(aStru[r_][1])
			IF SX3->X3_TIPO == "D"
				aStru[r_][2] := "D"
			ENDIF	
		EndIf	
Next r_	

//adiciona registro
DbSelectArea(cTabela)
dbgotop()
aDados := Array(nRec,Len(aStru))
While !Eof()
	nPosi2 += 1
	For p_ := 1 to Len(aStru)
		cCamp := cTabela+"->"+alltrim(aStru[p_][1])
		aDados[nPosi2][p_] := IIF(aStru[p_][2 ] == "D",Substr(&cCamp,7,2)+"/"+Substr(&cCamp,5,2)+"/"+Substr(&cCamp,1,4),&cCamp)
	Next p_
			oExcel:AddRow(cNomePlan,cTitulo,aDados[nPosi2])
Enddo
	
oExcel:Activate()
oExcel:GetXMLFile(cLocName)
If lAbre
	If ALLTRIM(Funname()) <> "RPC"
		IncProc("Abrindo Microsoft Excel")
		WinExec( 'RunDLL32.EXE shell32.dll,ShellExec_RunDLL "' + cLocName+ '"' ,1) 
	Endif	
Endif	

Return() 
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

User Function IBTESTEF()  
Private cTil := "Planilha de Teste"
Private cQry := "SELECT TOP 100 * FROM SB1010 WHERE B1_TIPO = 'PP' "

u_IBFWEXCEL(cTil,cQry,cTil,"\ibanexo\TESTEXML1.xlsx",.F.,.F.,.T.,,.F.,.T.,"rafael@ibar.com.br;wcasuporte@ibar.com.br","Relacao de teste")   

Return()
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

Static Function Roda()
Local p_ := 0
	//Conout("cTabela ")
	//Conout(cTabela)
	DbSelectArea(cTabela)
	dbgotop()
	aDados := Array(nRec,Len(aStru))
	While !Eof()
		nPosi2 += 1
		For p_ := 1 to Len(aStru)
			cCamp := cTabela+"->"+alltrim(aStru[p_][1])
			_valor := &cCamp
			If ValType(_valor) == "D"
				aDados[nPosi2][p_] := IIF(aStru[p_][2 ] == "D",DTOC(&cCamp),&cCamp)
			Else
				aDados[nPosi2][p_] := IIF(aStru[p_][2 ] == "D",Substr(&cCamp,7,2)+"/"+Substr(&cCamp,5,2)+"/"+Substr(&cCamp,1,4),&cCamp)
			EndIf
			If aStru[p_][2] == "C"
			 	aDados[nPosi2][p_] := StrTran( aDados[nPosi2][p_], "<", "" ) 
			 	aDados[nPosi2][p_] := StrTran( aDados[nPosi2][p_], ">", "" ) 
			Endif
		Next p_
		oExcel:AddRow(cNomePlan,cTitulo,aDados[nPosi2])
		dbskip()
	EndDo
Return()
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
User function FA330BX()

If cEmpAnt == "36"
	
Endif

Return()
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
User Function TSTFWEXC()

Local oExcel := FWMsExcelEx():New()
Local cLocName := "c:\tempor\teste.xml"
Local h

oExcel:AddworkSheet("Teste - 1")
oExcel:AddTable ("Teste - 1","Titulo de teste 1")
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col1",1,1)
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col2",2,2)
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col3",3,3)
oExcel:AddColumn("Teste - 1","Titulo de teste 1","Col4",1,1)
oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Arial')
oExcel:SetCelItalic(.T.)
oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(10)

oExcel:AddRow("Teste - 1","Titulo de teste 1",{11,12,13,14},{1,3})

oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Arial')
oExcel:SetCelItalic(.T.)
oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(15)
oExcel:SetCelFrColor("#FFFFFF")
oExcel:SetCelBgColor("#000666")

oExcel:AddRow("Teste - 1","Titulo de teste 1",{21,22,23,24},{1})

oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Courier New')
oExcel:SetCelItalic(.F.)
oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(10)
oExcel:SetCelFrColor("#FFFFFF")
oExcel:SetCelBgColor("#000333")

oExcel:AddRow("Teste - 1","Titulo de teste 1",{31,32,33,34},{2,4})

oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Line Draw')
oExcel:SetCelItalic(.F.)
oExcel:SetCelUnderLine(.F.)
oExcel:SetCelSizeFont(12)
oExcel:SetCelFrColor("#FFFFFF")
oExcel:SetCelBgColor("#D7BCFB")

oExcel:AddRow("Teste - 1","Titulo de teste 1",{41,42,43,44},{3})

oExcel:AddworkSheet("Teste - 2")
oExcel:AddTable("Teste - 2","Titulo de teste 1")
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col1",1)
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col2",2)
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col3",3)
oExcel:AddColumn("Teste - 2","Titulo de teste 1","Col4",1)
For h := 1 to 2000
oExcel:AddRow("Teste - 2","Titulo de teste 1",{11,12,13,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{21,22,23,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{31,32,33,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{41,42,43,stod("20121212")})
oExcel:AddRow("Teste - 2","Titulo de teste 1",{51,52,53,stod("20121212")})
Next h
oExcel:Activate()
oExcel:GetXMLFile(cLocName)
WinExec( 'RunDLL32.EXE shell32.dll,ShellExec_RunDLL "' + cLocName+ '"' ,1) 
Return
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

User function cmexcel()

//LjMsgRun( "Aguarde...Preparando e Transferindo dados...","Processando...",{ || Processa({|| u_TSTFWEXC() },"Criando Relatorio...")}   )
cQry := "SELECT * FROM SB1010"
u_IBFWEXCEL("teste",cQry,"TESTE","C:\TEMPOR\TESTEXML1.xlsx")
Return()
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  
