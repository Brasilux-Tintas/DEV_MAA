#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRCFGR01 ºAutor ³                     º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIOS DE CHAMADOS.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º 31/07/07 ³ GUSTAVO  ³ Adequação BRASILUX                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BRCFGR01()
//Local	lEnd		:= .f.
Local	_cPerg 		:= "CFGR01",;
		_cQuery		:= " ",;
		_lImpresso  := .f.

		//AjustaSX1(_cPerg) // Atualiza o dicionario de perguntas.  //LGS#20200211 - Adequação de release 12.1.25 e posteriores
		
		If	( Pergunte(_cPerg) ) // Faz as perguntas ao usuario.
			
			_cQuery := " SELECT *, CONVERT(VARCHAR(2046), CONVERT(VARBINARY(2046), ZZM.ZZM_OCORRE)) AS ZZM_OCORRE, CONVERT(VARCHAR(2046), CONVERT(VARBINARY(2046), ZZM.ZZM_COMENT)) AS ZZM_COMENTA, CONVERT(VARCHAR(2046), CONVERT(VARBINARY(2046), ZZM.ZZM_SOLUCA)) AS ZZM_SOLUCA  "
			_cQuery += " FROM " + RetSqlName("ZZM")+ " AS ZZM "
			_cQuery += " WHERE ZZM.ZZM_FILIAL = '" + xFilial("ZZM") + "' "
			_cQuery += "   AND ZZM.ZZM_DTABER >= '" + Dtos(mv_par01) + "' "
			_cQuery += "   AND ZZM.ZZM_DTABER <= '" + Dtos(mv_par02) + "' "
			_cQuery += "   AND ZZM.ZZM_SOLCHA >= '" + mv_par03 + "' "
			_cQuery += "   AND ZZM.ZZM_SOLCHA <= '" + mv_par04 + "' "
			_cQuery += "   AND ZZM.ZZM_NUMCHA >= '" + mv_par05 + "' "
			_cQuery += "   AND ZZM.ZZM_NUMCHA <= '" + mv_par06 + "' "
			_cQuery += "   AND ZZM.ZZM_STATUS IN ('" + Iif(mv_par07==1,"0",IIF(mv_par07==2,"8",IIF(mv_par07==3,"9",IIF(mv_par07==4,"1","0','8','9','1")))) + "') "
			_cQuery += "   AND SUBSTRING(ZZM.ZZM_EMPCHA,1,2) >= '" + mv_par08 + "' "
			_cQuery += "   AND SUBSTRING(ZZM.ZZM_EMPCHA,1,2) <= '" + mv_par09 + "' "
			_cQuery += "   AND ZZM.D_E_L_E_T_ = ' ' "
			_cQuery := ChangeQuery(_cQuery)
			DbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),'TRA',.F.,.T.)

			TcSetField('TRA', 'ZZM_DTABER','D')
			TcSetField('TRA', 'ZZM_DTFECH','D')

			TRA->(DbGoTop())

			If	TRA->( ! Eof() )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa a impressao dos dados.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Processa({ |lEnd| xPrintRel(),OemToAnsi('Imprimindo os Chamados...')}, OemToAnsi('Aguarde...'))
				_lImpresso := .t.
			EndIf

			TRA->(DbCloseArea())

		EndIf

		If	( ! _lImpresso )
			Help("",1,"CHA001R",,OemToAnsi("Nenhum registro localizado."+Chr(13)+Chr(10)+"Altere os parametros."),1)
		EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xPrintRel ºAutor ³                     º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o relatorio dos dados.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xPrintRel()
Local	_nQtdReg	:= 0
Local i
Local _cNameCom
Private	cStartPath	:= GetSrvProfString('Startpath',''),;
		cFileLogo	:= cStartPath + 'logo01.bmp'

Private	oPrint		:= TMSPrinter():New(OemToAnsi('Controle de Chamado')),;
		oBrush		:= TBrush():New(,4),;
		oFont07		:= TFont():New('Courier New', 07, 07, , .F., , , , .T., .F.),;
		oFont08		:= TFont():New('Courier New', 08, 08, , .F., , , , .T., .F.),;
		oFont08n	:= TFont():New('Courier New', 08, 08, , .T., , , , .T., .F.),;
		oFont10Co   := TFont():New('Courier New', 10, 10, , .F., , , , .T., .F.),;
		oFont09		:= TFont():New('Tahoma'     , 09, 09, , .F., , , , .T., .F.),;
		oFont10		:= TFont():New('Tahoma'     , 10, 10, , .F., , , , .T., .F.),;
		oFont10n	:= TFont():New('Courier New', 10, 10, , .T., , , , .T., .F.),;
		oFont11		:= TFont():New('Tahoma'     , 11, 11, , .F., , , , .T., .F.),;
		oFont12		:= TFont():New('Tahoma'     , 12, 12, , .T., , , , .T., .F.),;
		oFont14		:= TFont():New('Tahoma'     , 14, 14, , .T., , , , .T., .F.),;
		oFont14s	:= TFont():New('Arial'      , 14, 14, , .T., , , , .T., .T.),;
		oFont15		:= TFont():New('Courier New', 15, 15, , .T., , , , .T., .F.),;
		oFont18		:= TFont():New('Arial'      , 18, 18, , .T., , , , .T., .T.),;
		oFont18n	:= TFont():New('Arial'      , 18, 18, , .T., , , , .T., .F.),;
		oFont16		:= TFont():New('Arial'      , 16, 16, , .T., , , , .T., .F.),;
		oFont22		:= TFont():New('Arial'      , 22, 22, , .T., , , , .T., .F.)

Private	aAberOcor	:= {},;
		aComentar	:= {},;
		aSolucao	:= {},;
		cStatus		:= Space(10)

Private	nLin		:= 3000		// Linha que o sistema esta imprimindo.
		nPage		:= 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conta os registros e indica a regua.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Count to _nQtdReg
		TRA->(DbGoTop())
		ProcRegua(_nQtdReg)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime todos os registros da query.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While	TRA->( ! Eof() )

				aAberOcor	:= {}
				aComentar	:= {}
				aSolucao	:= {}

		  		If	( TRA->ZZM_STATUS == '0' )
					cStatus	:= 'Aberto'
				ElseIf	( TRA->ZZM_STATUS == '1' )
					cStatus	:= 'Em Análise'
				ElseIf	( TRA->ZZM_STATUS == '8' )
					cStatus	:= 'Cancelado'
				ElseIf	( TRA->ZZM_STATUS == '9' )
					cStatus	:= 'Encerrado'
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monta os dados em array.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For i:=1 To MlCount(TRA->ZZM_OCORRE,100)
					If	! Empty(AllTrim(MemoLine(TRA->ZZM_OCORRE,100,i)))
						aAdd(aAberOcor,AllTrim(MemoLine(TRA->ZZM_OCORRE,100,i)))
					EndIf
				Next
				For i:=1 To MlCount(TRA->ZZM_COMENT,100)
					If	! Empty(AllTrim(MemoLine(TRA->ZZM_COMENT,100,i)))
						aAdd(aComentar,AllTrim(MemoLine(TRA->ZZM_COMENT,100,i)))
					EndIf
				Next
				For i:=1 To MlCount(TRA->ZZM_SOLUCA,100)
					If	! Empty(AllTrim(MemoLine(TRA->ZZM_SOLUCA,100,i)))
						aAdd(aSolucao,AllTrim(MemoLine(TRA->ZZM_SOLUCA,100,i)))
					EndIf
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Seta a pagina para impressao em Retrato.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:SetPortrait()

				If	( nLin >= 3000 )
					xCabecPrin()
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³IMPRIME A PARTE DE INFORMACOES DO CHAMADO.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(nLin,0050,OemToAnsi('Número Chamado: '),oFont08n)
				oPrint:Say(nLin,0350,OemToAnsi('Descrição: '),oFont08n)
				oPrint:Say(nLin,1600,OemToAnsi('Dt. Abertura: '),oFont08n)
				oPrint:Say(nLin,2000,OemToAnsi('Empresa/Filial: '),oFont08n)
				nLin += 40
				oPrint:Say(nLin,0050,TRA->ZZM_NUMCHA,oFont10Co)
				oPrint:Say(nLin,0350,SubStr(TRA->ZZM_DESC,1,50),oFont10Co)
				oPrint:Say(nLin,1600,Dtoc(TRA->ZZM_DTABER)+'-'+TRA->ZZM_HRABER,oFont10Co)
				oPrint:Say(nLin,2000,TRA->ZZM_EMPCHA,oFont10Co)
		
				nLin += 60 // Espaco entre os campos
		
				oPrint:Say(nLin,0050,OemToAnsi('Tipo: '),oFont08n)
				oPrint:Say(nLin,0550,OemToAnsi('Status: '),oFont08n)
				oPrint:Say(nLin,1000,OemToAnsi('Prioridade: '),oFont08n)
				oPrint:Say(nLin,1600,OemToAnsi('Solicitante: '),oFont08n)
				nLin += 40
				oPrint:Say(nLin,0050,Tabela('Z4',TRA->ZZM_TIPO) + ' ' + TRA->ZZM_MODULO + ' ' + TRA->ZZM_PROGRA,oFont10Co)
				oPrint:Say(nLin,0550,cStatus,oFont10Co)
				oPrint:Say(nLin,1000,Tabela('Z5',TRA->ZZM_PRICHA),oFont10Co)
				//LGS#20200211 - Adequação de release 12.1.25 e posteriores
				//oPrint:Say(nLin,1600,Upper(UsrFullName(TRA->ZZM_SOLCHA)),oFont10Co)
				_cNameCom := fBusName( TRA->ZZM_SOLCHA )
                oPrint:Say(nLin,1600,Upper( _cNameCom ),oFont10Co)
				nLin += 60 // Espaco entre os campos
		
				oPrint:Say(nLin,0050,OemToAnsi('Ocorrência:'),oFont08n)
		
				For i:=1 To Len(aAberOcor)
					nLin += 40
					If	( nLin >= 3000 )
						xCabecPrin()
					EndIf
					oPrint:Say(nLin,0050,aAberOcor[i],oFont10Co)
				Next i
		
				nLin += 60 // Espaco entre os campos
		
				If	( nLin >= 3000 )
					xCabecPrin()
				EndIf
		
				nLin += 30
		
				If	( nLin >= 3000 )
					xCabecPrin()
				EndIf
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³IMPRIME OS DADOS DOS COMENTARIOS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If	( TRA->ZZM_STATUS == '1' ) .or. ( TRA->ZZM_STATUS == '8' ) .or. ( TRA->ZZM_STATUS == '9' )
		
					oPrint:Say(nLin,0050,OemToAnsi('Técnico Alocado:'),oFont08n)
					nLin += 40
					If	( nLin >= 3000 )
						xCabecPrin()
					EndIf
                    //LGS#20200211 - Adequação de release 12.1.25 e posteriores
					//oPrint:Say(nLin,0050,Upper(UsrFullName(TRA->ZZM_TECALO)),oFont10Co)
                    _cNameCom := fBusName( TRA->ZZM_TECALO )
                    oPrint:Say(nLin,0050,Upper( _cNameCom ),oFont10Co)
					nLin += 60 // Espaco entre os campos
		
					If	( nLin >= 3000 )
						xCabecPrin()
					EndIf
		
					oPrint:Say(nLin,0050,OemToAnsi('Comentários:'),oFont08n)
		
					For i:=1 To Len(aComentar)
						nLin += 40
						If	( nLin >= 3000 )
							xCabecPrin()
						EndIf
						oPrint:Say(nLin,0050,aComentar[i],oFont10Co)
					Next i
		
					nLin += 60 // Espaco entre os campos
		
					If	( nLin >= 3000 )
						xCabecPrin()
					EndIf
		
					nLin += 30
		
					If	( nLin >= 3000 )
						xCabecPrin()
					EndIf
		
				EndIf	
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³IMPRIME OS DADOS DOS COMENTARIOS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If	( TRA->ZZM_STATUS == '9' ) .or. ( TRA->ZZM_STATUS == '8' )
		
					oPrint:Say(nLin,0050,OemToAnsi('Técnico:'),oFont08n)
					oPrint:Say(nLin,1600,OemToAnsi('Dt. Encerramento: '),oFont08n)
					oPrint:Say(nLin,2000,OemToAnsi('Classificação: '),oFont08n)
					nLin += 40
					//LGS#20200211 - Adequação de release 12.1.25 e posteriores
					//oPrint:Say(nLin,0050,Upper(UsrFullName(TRA->ZZM_TECNIC)),oFont10Co)
					_cNameCom := fBusName( TRA->ZZM_TECNIC )
					oPrint:Say(nLin,0050,Upper( _cNameCom ),oFont10Co)
					oPrint:Say(nLin,1600,Dtoc(TRA->ZZM_DTFECH)+'-'+TRA->ZZM_HRFECH,oFont10Co)
					If	! Empty(TRA->ZZM_CLASSI)
						oPrint:Say(nLin,2000,Tabela('Z6',TRA->ZZM_CLASSI),oFont10Co)
					EndIf
		
					nLin += 60 // Espaco entre os campos
		
					If	( nLin >= 3000 )
						xCabecPrin()
					EndIf
		
					oPrint:Say(nLin,0050,OemToAnsi('Solução:'),oFont08n)
		
					For i:=1 To Len(aSolucao)
						nLin += 40
						If	( nLin >= 3000 )
							xCabecPrin()
						EndIf
						oPrint:Say(nLin,0050,aSolucao[i],oFont10Co)
					Next i
		
					nLin += 60 // Espaco entre os campos
		
					If	( nLin >= 3000 )
						xCabecPrin()
					EndIf
		
				EndIf

				// Linha Separacao
				oPrint:Line(nLin,0050,nLin,2300)

				IncProc("Imprimindo chamado: " + TRA->ZZM_NUMCHA)

			TRA->(DbSkip())

		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fina a impressao do relatorio.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:EndPage()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mostra em video a impressao do relatorio. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:Preview()

Return

Static Function fBusName( _nCodigo )
Return UsrFullName( _nCodigo )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xCabecPrin ºAutor ³                     º Data ³    /  /    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para imprimir o cabecalho do relatorio.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³  MOTIVO                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function xCabecPrin()

		nLin := 30

		If	( nPage > 0 )
			oPrint:EndPage()
		EndIf
		
		nPage++

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicia a impressao da pagina.!³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:StartPage()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o cabecalho da empresa. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:SayBitmap(nLin+20,040,cFileLogo,560,200) // ,560,350)
		oPrint:Say(nLin+20,700,'BRASILUX TINTAS TÉCNICAS LTDA.',oFont16)
		oPrint:Say(nLin+150,700,'Técnologia da Informação',oFont11)
		oPrint:Say(nLin+195,700,'Suporte on-line',oFont11)
		//oPrint:Say(nLin+285,700,AllTrim('Manuais: intranet.rechtratores.com.br'),oFont11)

		nLin += 450

		oPrint:Line(nLin,0050,nLin,2300) // Linha Separacao

		nLin += 30

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaSX1ºAutor ³                     º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajusta o SX1 - Arquivo de Perguntas..                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funcao Principal                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDATA      ³ ANALISTA ³ MOTIVO                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³          ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//LGS#20200211 - Adequação de release 12.1.25 e posteriores
/*
Static Function AjustaSX1(cPerg)
Local	aRegs   := {},;
		_sAlias := Alias(),;
		nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos a serem grav. no SX1³
		//³aRegs[nx][01] - X1_GRUPO   ³
		//³aRegs[nx][02] - X1_ORDEM   ³
		//³aRegs[nx][03] - X1_PERGUNTE³
		//³aRegs[nx][04] - X1_PERSPA  ³
		//³aRegs[nx][05] - X1_PERENG  ³
		//³aRegs[nx][06] - X1_VARIAVL ³
		//³aRegs[nx][07] - X1_TIPO    ³
		//³aRegs[nx][08] - X1_TAMANHO ³
		//³aRegs[nx][09] - X1_DECIMAL ³
		//³aRegs[nx][10] - X1_PRESEL  ³
		//³aRegs[nx][11] - X1_GSC     ³
		//³aRegs[nx][12] - X1_VALID   ³
		//³aRegs[nx][13] - X1_VAR01   ³
		//³aRegs[nx][14] - X1_DEF01   ³
		//³aRegs[nx][15] - X1_DEF02   ³
		//³aRegs[nx][16] - X1_DEF03   ³
		//³aRegs[nx][17] - X1_DEF04   ³
		//³aRegs[nx][18] - X1_DEF05   ³
		//³aRegs[nx][19] - X1_F3      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        cPerg := PADR(cPerg,10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria uma array, contendo todos os valores...³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(aRegs,{cPerg,'01','Dt. Abert. Inicial ?','Dt. Abert. Inicial ?','Dt. Abert. Inicial ?','mv_ch1','D', 8,0,0,'G','','mv_par01','','','','','',''})
		aAdd(aRegs,{cPerg,'02','Dt. Abert. Final   ?','Dt. Abert. Final   ?','Dt. Abert. Final   ?','mv_ch2','D', 8,0,0,'G','','mv_par02','','','','','',''})
		aAdd(aRegs,{cPerg,'03','Solic. Inicial     ?','Solic. Inicial     ?','Solic. Inicial     ?','mv_ch3','C', 6,0,0,'G','','mv_par03','','','','','',''})
		aAdd(aRegs,{cPerg,'04','Solic. Final       ?','Solic. Final       ?','Solic. Final       ?','mv_ch4','C', 6,0,0,'G','','mv_par04','','','','','',''})
		aAdd(aRegs,{cPerg,'05','Chamado Inicial    ?','Chamado Inicial    ?','Chamado Inicial    ?','mv_ch5','C', 6,0,0,'G','','mv_par05','','','','','',''})
		aAdd(aRegs,{cPerg,'06','Chamado Final      ?','Chamado Final      ?','Chamado Final      ?','mv_ch6','C', 6,0,0,'G','','mv_par06','','','','','',''})
		aAdd(aRegs,{cPerg,'07','Status             ?','Status             ?','Status             ?','mv_ch7','N', 1,0,1,'C','','mv_par07','Aberto','Cancelado','Encerrado','Em Analise','Todos',''})
		aAdd(aRegs,{cPerg,'08','Empresa Inicial    ?','Empresa Inicial    ?','Empresa Inicial    ?','mv_ch8','C', 2,0,0,'G','','mv_par08','','','','','',''})
		aAdd(aRegs,{cPerg,'09','Empresa Final      ?','Empresa Final      ?','Empresa Final      ?','mv_ch9','C', 2,0,0,'G','','mv_par09','','','','','',''})

		DbSelectArea('SX1')
		SX1->(DbSetOrder(1))

		For nX:=1 to Len(aRegs)
			If	( ! SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02])) )
				If	RecLock('SX1',.T.)
					Replace SX1->X1_GRUPO  		With aRegs[nx][01]
					Replace SX1->X1_ORDEM   	With aRegs[nx][02]
					Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
					Replace SX1->X1_PERSPA		With aRegs[nx][04]
					Replace SX1->X1_PERENG		With aRegs[nx][05]
					Replace SX1->X1_VARIAVL		With aRegs[nx][06]
					Replace SX1->X1_TIPO		With aRegs[nx][07]
					Replace SX1->X1_TAMANHO		With aRegs[nx][08]
					Replace SX1->X1_DECIMAL		With aRegs[nx][09]
					Replace SX1->X1_PRESEL		With aRegs[nx][10]
					Replace SX1->X1_GSC			With aRegs[nx][11]
					Replace SX1->X1_VALID		With aRegs[nx][12]
					Replace SX1->X1_VAR01		With aRegs[nx][13]
					Replace SX1->X1_DEF01		With aRegs[nx][14]
					Replace SX1->X1_DEF02		With aRegs[nx][15]
					Replace SX1->X1_DEF03		With aRegs[nx][16]
					Replace SX1->X1_DEF04		With aRegs[nx][17]
					Replace SX1->X1_DEF05		With aRegs[nx][18]
					Replace SX1->X1_F3   		With aRegs[nx][19]
					SX1->(MsUnlock())
				Else
					Help('',1,'REGNOIS')
				EndIf	
			Endif
		Next nX

Return*/