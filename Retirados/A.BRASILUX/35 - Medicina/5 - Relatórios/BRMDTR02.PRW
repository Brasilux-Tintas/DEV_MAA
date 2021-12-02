#INCLUDE "BRMDTR02.ch"
#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MDTR410  ³ Autor ³ Marcio Costa          ³ Data ³ 12.01.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³         Respostas ao Questionario Medico.                  ³±±
±±³          ³  Permite tabular as respostas dos questionamentos medicos. ³±±
±±³          ³Inicialmente o usuario seleciona o questionario desejado.   ³±±
±±³          ³Em seguida pode selecionar os funcionarios ou candidatos,   ³±±
±±³          ³por intermedio das fichas medicas.                          ³±±
±±³          ³  Finalmente seleciona do questionario escolhido, qual a    ³±±
±±³          ³pergunta  desejada, ou pode listar todas as perguntas.      ³±±
±±³          ³  O questionario medico e uma ferramenta que ajuda a tracar ³±±
±±³          ³o perfil dos funcionarios quanto aos assuntos relacionados a³±±
±±³          ³saude.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MDTR410(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRMDTR02( aDados )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL wnrel   := "MDTR410"
//LOCAL limite  := 132
//LOCAL cDesc1  := STR1001 //"Relatorio de apresentacao do questionario e suas respostas e resumo "
//LOCAL cDesc2  := STR1002 //"contento estatistica das respostas do universo selecionado          "
//LOCAL cDesc3  := STR1003 //"Opcao disponivel atraves do botao de  parametros.   "
//LOCAL cString := "TMI"
LOCAL nFor

PRIVATE aDad145     
Private oTempTbl01
Private oTempTbl02
  //BRMDTR02

If Valtype(aDados) == "A"
	aDad145 := aClone(aDados)
Endif

Private nSizeTMH := (TAMSX3("TMH_PERGUN")[1])
nSizeTMH := If( nSizeTMH > 0 , nSizeTMH , 60 )

SETKEY(VK_F9, {|| NGVersao("MDTR410", 6 )})
lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

PRIVATE nomeprog := "MDTR410"
PRIVATE tamanho  := "M"
PRIVATE aReturn  := { STR1004, 1,STR1005, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE titulo   := STR1006   // + ( NOME DO QUESTIONARIO ) //"Questionario Medico"
PRIVATE ntipo    := 0
PRIVATE nLastKey := 0
PRIVATE cPerg    :="MDT410    "
PRIVATE cabec1, cabec2
Private lPrinGraf := .t.
Private lPrintTel := .t.

If nSizeTMH > 60
	tamanho := "G"
Endif

/* Perguntas
+---------------------------+
| 01  Questionario ?        |
| 02  De Ficha MÚdica ?     |
| 03  Até Ficha MÚdica ?    |
| 04  De  Pergunta ?        |
| 05  Ate Pergunta ?        |
| 06  De  Data Realizacao ? |
| 07  Ate Data Realizacao ? |
| 08  Modelo Relatorio    ? |
+---------------------------+
*/

If lSigaMdtps

	/*  Perguntas
	+---------------------------+
	| 01  Cliente ?             | 
	| 02  Loja                  | 
	| 03  Questionario ?        |
	| 04  De Ficha Médica ?     |
	| 05  Até Ficha Médica ?    |
	| 06  De  Pergunta ?        |
	| 07  Ate Pergunta ?        |
	| 08  De  Data Realizacao ? |
	| 09  Ate Data Realizacao ? |
	| 10  Modelo Relatorio    ? |
	+---------------------------+	
	*/
//LGS#20200131 - Adequação de release 12.1.25 e posteriores
/*
	dbSelectArea("SX1")
	dbSetOrder(01)

	If Dbseek(cPerg+"07") .AND. AllTrim(SX1->X1_PERGUNT) == "Ate Data Realizacao ?"
		RecLock("SX1",.F.)
		SX1->X1_ORDEM   := "09"
		SX1->X1_VARIAVL := "mv_ch9"
		SX1->X1_VAR01   := "mv_par09"
		SX1->X1_VALID   := "(mv_par09 >= mv_par08)"
		MsUnLock("SX1")
	Endif

	If Dbseek(cPerg+"06") .AND. AllTrim(SX1->X1_PERGUNT) == "De  Data Realizacao ?"
		RecLock("SX1",.F.)
		SX1->X1_ORDEM   := "08"
		SX1->X1_VARIAVL := "mv_ch8"
		SX1->X1_VAR01   := "mv_par08"
		MsUnLock("SX1")
	Endif

	If Dbseek(cPerg+"05") .AND. AllTrim(SX1->X1_PERGUNT) == "Ate Pergunta ?"
		RecLock("SX1",.F.)
		SX1->X1_ORDEM   := "07"
		SX1->X1_VARIAVL := "mv_ch7"
		SX1->X1_VAR01   := "mv_par07" 
		SX1->X1_VALID   := "MDTTMH410()"
		SX1->X1_F3      := "TMH001"
		MsUnLock("SX1")
	Endif

	If Dbseek(cPerg+"04") .AND. AllTrim(SX1->X1_PERGUNT) == "De  Pergunta ?"
		RecLock("SX1",.F.)
		SX1->X1_ORDEM   := "06"
		SX1->X1_VARIAVL := "mv_ch6"
		SX1->X1_VAR01   := "mv_par06"
		SX1->X1_VALID   := "MDT410TMH()" 
		SX1->X1_F3      := "TMH001"
		MsUnLock("SX1")
	Endif

	If Dbseek(cPerg+"03") .AND. AllTrim(SX1->X1_PERGUNT) == "Até Ficha Médica ?"
		RecLock("SX1",.F.)
		SX1->X1_ORDEM   := "05"
		SX1->X1_VARIAVL := "mv_ch5"
		SX1->X1_VAR01   := "mv_par05"
		SX1->X1_VALID   := "MDTFIC410()"   
		SX1->X1_F3      := "TM0002"
		SX1->X1_CNT01   := Replicate("Z",9)
		MsUnLock("SX1")
	Endif   
	
	If Dbseek(cPerg+"02") .AND. AllTrim(SX1->X1_PERGUNT) == "De Ficha Médica ?"
		RecLock("SX1",.F.)
		SX1->X1_ORDEM   := "04"
		SX1->X1_VARIAVL := "mv_ch4"
		SX1->X1_VAR01   := "mv_par04"		
		SX1->X1_VALID   := "MDT410FIC()"   
		SX1->X1_F3	    := "TM0002"
		MsUnLock("SX1")
	Endif	
	
	If Dbseek(cPerg+"01") .AND. AllTrim(SX1->X1_PERGUNT) == "Questionario ?"
		RecLock("SX1",.F.)		
		SX1->X1_ORDEM   := "03"
		SX1->X1_VARIAVL := "mv_ch3"
		SX1->X1_VAR01   := "mv_par03"		
		SX1->X1_VALID   := 'ExistCpo("TMG",mv_par01+mv_par02+mv_par03,2)'
		SX1->X1_F3	    := "TMG002"
		MsUnLock("SX1")
	Endif
	
	nTa1 := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
	nTa1L := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
	nSizeTD := nTa1+nTa1L
			
	If !Dbseek(cPerg+"01")
	   RecLock("SX1",.T.)
	   SX1->X1_GRUPO   := cPerg
	   SX1->X1_ORDEM   := "01"
	   SX1->X1_PERGUNT := STR1019  //"Cliente ?"
	   SX1->X1_PERSPA  := STR1019
	   SX1->X1_PERENG  := STR1019
	   SX1->X1_VARIAVL := "mv_ch1"
	   SX1->X1_TIPO    := "C"
	   SX1->X1_TAMANHO := nTa1
	   SX1->X1_GSC     := "G"
	   SX1->X1_VALID   := "MDT005VL01(1)  .AND. MDT930CLI()"
	   SX1->X1_VAR01   := "mv_par01"
	   SX1->X1_F3      := "SA1"
	   SX1->X1_HELP    := "MDTR410PS_01"	   
	   MsUnLock("SX1")
	   NgHelp("MDTR410PS_01",STR1021)  //"Código do cliente."
	Endif     	
	If !Dbseek(cPerg+"02")
	   RecLock("SX1",.T.)
	   SX1->X1_GRUPO   := cPerg
	   SX1->X1_ORDEM   := "02"
	   SX1->X1_PERGUNT := STR1020  //"Loja"
	   SX1->X1_PERSPA  := STR1020
	   SX1->X1_PERENG  := STR1020
	   SX1->X1_VARIAVL := "mv_ch2"
	   SX1->X1_TIPO    := "C"
	   SX1->X1_TAMANHO := nTa1L
	   SX1->X1_GSC     := "G"
	   SX1->X1_VALID   := "MDT005VL01(2) .AND. MDT930CLI()"
	   SX1->X1_VAR01   := "mv_par02"
	   SX1->X1_HELP    := "MDTR410PS_02"
	   MsUnLock("SX1")
	   NgHelp("MDTR410PS_02",STR1022)  //"Loja do cliente."
	Endif
	If !Dbseek(cPerg+"10")
	   RecLock("SX1",.T.)
	   SX1->X1_GRUPO   := cPerg
	   SX1->X1_ORDEM   := "10"
	   SX1->X1_PERGUNT := "Tipo Impressão?"
	   SX1->X1_PERSPA  := "Tipo Impressão?"
	   SX1->X1_PERENG  := "Tipo Impressão?"
	   SX1->X1_VARIAVL := "mv_cha"
	   SX1->X1_TIPO    := "N"
	   SX1->X1_TAMANHO := 1
	   SX1->X1_GSC     := "C"
	   SX1->X1_VAR01   := "mv_par10"
	   SX1->X1_HELP    := "MDTR410_08"
	   SX1->X1_DEF01   := "Tela"
	   SX1->X1_DEF02   := "Impressora"
	   MsUnLock("SX1")
	   NgHelp("MDTR410_08","Informe o tipo de impressão. 1=Tela ou 2=Impressora.")
	Endif

Else
	dbSelectArea("SX1")
	dbSetOrder(01)
	If !Dbseek(cPerg+"08")
	   RecLock("SX1",.T.)
	   SX1->X1_GRUPO   := cPerg
	   SX1->X1_ORDEM   := "08"
	   SX1->X1_PERGUNT := "Tipo Impressão?"
	   SX1->X1_PERSPA  := "Tipo Impressão?"
	   SX1->X1_PERENG  := "Tipo Impressão?"
	   SX1->X1_VARIAVL := "mv_ch8"
	   SX1->X1_TIPO    := "N"
	   SX1->X1_TAMANHO := 1
	   SX1->X1_PRESEL  := 2
	   SX1->X1_GSC     := "C"
	   SX1->X1_VAR01   := "mv_par08"
	   SX1->X1_HELP    := "MDTR410_08"
	   SX1->X1_DEF01   := "Tela"
	   SX1->X1_DEF02   := "Impressora"
	   MsUnLock("SX1")
	   NgHelp("MDTR410_08","Informe o tipo de impressão. 1=Tela ou 2=Impressora.")
	Endif*/
Endif

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="MDTR410"

If Valtype(aDad145) == "A"
	For nFor := 1 To Len(aDad145)
		&(aDad145[nFor,1]) := aDad145[nFor,2]
	Next nFor
Else
	If !pergunte(cPerg,.T.)
		Return
	Endif
	If lSigaMdtps
		If mv_par10 == 2
			lPrintTel := .f.
		Endif
	Else
		If mv_par08 == 2
			lPrintTel := .f.
		Endif
	Endif
Endif

If lSigaMdtps

	dbSelectArea("TMG")
	dbSetOrder(02)  //TMG_FILIAL+TMG_CLIENT+TMG_LOJA+TMG_QUESTI
	dbSeek(xFilial("TMG")+MV_PAR01+MV_PAR02+MV_PAR03)

Else

	dbSelectArea("TMG")
	dbSetOrder(01)
	dbSeek(xFilial("TMG")+MV_PAR01)

Endif

cDESQUEST := ALLTRIM(TMG->TMG_NOMQUE)

If lSigaMdtps
	titulo := titulo + "  " + cDESQUEST + " ("+DTOC(MV_PAR08)+" a "+DTOC(MV_PAR09)+")"
	If !lPrinGraf
		RptStatus({|lEnd| R410Imp(@lEnd,wnRel,titulo,tamanho)},titulo)
	Else
		Processa({|lEnd| fImpMod2()})
	Endif
Else
	titulo := titulo + "  " + cDESQUEST + " ("+DTOC(MV_PAR06)+" a "+DTOC(MV_PAR07)+")"
	If !lPrinGraf
		RptStatus({|lEnd| R410Imp(@lEnd,wnRel,titulo,tamanho)},titulo)
	Else
		Processa({|lEnd| fImpMod2()})
	Endif
Endif

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R410Imp  ³ Autor ³ Inacio Luiz Kolling   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR410                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R410Imp(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRodaTxt := ""
LOCAL nCntImpr := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cFICHA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// PRIVATE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*
************************************************************************************************************************************
*<empresa>                                                                                                        Folha..: xxxxx   *
*SIGA /<nome .04                                 <Relatorio de Questionario Medico>                               DT.Ref.: dd/mm/aa*
*Hora...: xx:xx:xx                                                                                                Emissao: dd/mm/aa*
************************************************************************************************************************************

             1         2         3         4         5         6         7         8         9         0         1         2         3
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Matricula  Nome Funcionario                           Sexo       Admissao   Idade
Perg. Descricao Pergunta                                         Resp. Dt.Resp.  Quantidade Complemento
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxx     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxx  99/99/99      99

xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxx   99/99/99 999.999.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxx   99/99/99 999.999.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Resumo do Questionario  ( NOME DO QUESTIONARO )
Total de Funcionarios pesquisado.: 999.999
Per.  Descricao Pergunta                                                  Sim        Nao  Sem Respos.
xxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    999.999    999.999     999.999
xxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    999.999    999.999     999.999


TAMANHO G
_____________________________________________________________________________________________________________________________________________________________________________________________________________________________
          1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200       210       220
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
_____________________________________________________________________________________________________________________________________________________________________________________________________________________________
Matricula  Nome Funcionario                           Sexo       Admissao   Idade
Perg. Descricao Pergunta                                                                                                                                      Resp. Dt.Resp.  Quantidade Complemento
_____________________________________________________________________________________________________________________________________________________________________________________________________________________________
xxx   123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890  Sim   99/99/99 999.999.999 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


Per.  Descricao Pergunta                                                                                                                                                                Sim        Nao  Sem Respos.
xxx   12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890    999.999    999.999     999.999
*/

LoadArTmp(.F.,.F.)

cabec1 := STR1007 //"Matricula  Nome Funcionario                           Sexo       Admissao   Idade"
cabec2 := STR1008 //"Perg. Descricao Pergunta                                         Resp. Dt.Resp.  Quantidade Complemento"
If nSizeTMH > 60
	cabec2 := STR1025 //"Perg. Descricao Pergunta                                                                                                                                      Resp. Dt.Resp.  Quantidade Complemento"
Endif

dbSelectArea("TRB")
dbGOTOP()

If Eof()
	MsgInfo(STR1023)  //"Não há nada para imprimir no relatório."
	Use        
	dbSelectArea("TRB2")
	use	
	Return .F.
Else
	If lSigaMdtps
		Somalinha()
		@Li,000 PSAY "Cliente/Loja: " + MV_PAR01 +"-"+ MV_PAR02 +" - "+ NGSEEK("SA1",mv_par01+mv_par02,1,"SA1->A1_NOME")  //"Cliente/Loja: "
		Somalinha()
	Endif
Endif

nTOTFUNC := 0
While ! eof()

	cFICHA := TRB->NUMFICHA

	nTOTFUNC := nTOTFUNC + 1

	Somalinha()
	@Li,000 PSAY TRB->MATRICULA PICTURE "@!"

	dbSelectArea("SRA")
	dbSetOrder(01)
	dbSeek(xFilial("SRA")+TRB->MATRICULA)

	dbSelectArea("TM0")
	dbSetOrder(01)
	dbSeek(xFilial("TM0")+cFICHA)

	@Li,011 PSAY substr(TM0->TM0_NOMFIC,1,40)

	If TM0->TM0_SEXO = '1'
		@Li,054 PSAY STR1010 //'Masculino'
	Else
		@Li,054 PSAY STR1011 //'Feminino'
	Endif

	@Li,065 PSAY SRA->RA_ADMISSA      PICTURE '99/99/99'
	@Li,079 PSAY YEAR(DATE()) - YEAR(TM0->TM0_DTNASC)  PICTURE '99'
	Somalinha()

	dbSelectArea("TRB")

	While ! eof() .and. TRB->NUMFICHA == cFICHA

		SomaLinha()
		@ Li,000 PSAY TRB->PERGUNTA  PICTURE "@!"
		If nSizeTMH <= 60
			@ Li,004 PSAY Substr(TRB->NOMPERGU,1,60)
			If TRB->RESPOS = '1'
				@ Li,065 PSAY STR1012 //'Sim'
			Else
				@ Li,065 PSAY STR1013 //'Nao'
			Endif
			@ Li,071 PSAY TRB->DTREAL    PICTURE '99/99/99'
			@ Li,082 PSAY TRB->QUANTID   PICTURE '@E 999,999.99'
			@ LI,094 PSAY Substr(TRB->COMPLEM,1,30)
		Else
			@ Li,006 PSAY Substr(TRB->NOMPERGU,1,150)
			If TRB->RESPOS = '1'
				@ Li,158 PSAY STR1012 //'Sim'
			Else
				@ Li,158 PSAY STR1013 //'Nao'
			Endif
			@ Li,164 PSAY TRB->DTREAL    PICTURE '99/99/99'
			@ Li,173 PSAY TRB->QUANTID   PICTURE '@E 999,999.99'
			@ LI,185 PSAY Substr(TRB->COMPLEM,1,30)
		Endif

		dbSelectArea("TRB")
		dbskip()
	Enddo

	SomaLinha()

Enddo
 
If nTOTFUNC > 0
	SomaLinha()
	@ LI,000 PSAY Replicate("-",132)
	SomaLinha()
	If lSigaMdtps
		@ LI,000 PSAY "Resumo do Questionario - " + cDESQUEST + " ("+DTOC(MV_PAR08)+" a "+DTOC(MV_PAR09)+")" //"Resumo do Questionario - "	
	Else
		@ LI,000 PSAY "Resumo do Questionario - " + cDESQUEST + " ("+DTOC(MV_PAR06)+" a "+DTOC(MV_PAR07)+")" //"Resumo do Questionario - "
	Endif
	SomaLinha()              
	@ LI,000 PSAY STR1015 //"Total de Funcionarios ou Candidatos Pesquisados.:"
	@ LI,050 PSAY nTOTFUNC PICTURE '@E 999,999'
	SomaLinha()
	If nSizeTMH <= 60
		@ LI,000 PSAY STR1016 //"Per.  Descricao Pergunta                                                  Sim        Nao  Sem Respos."
	Else
		@ LI,000 PSAY STR1026 //"Per.  Descricao Pergunta                                                                                                                                                                Sim        Nao  Sem Respos."
	Endif

	SomaLinha()
	dbSelectArea("TRB2")
	dbGOTOP()

	While ! eof()
		SomaLinha()
		@ Li,000 PSAY TRB2->PERGUNTA                           PICTURE "@!"
		If nSizeTMH <= 60
			@ Li,006 PSAY Substr(TRB2->NOMPERGU,1,57)
			@ Li,070 PSAY TRB2->RESPSIM                            PICTURE '@E 999,999'
			@ Li,081 PSAY TRB2->RESPNAO                            PICTURE '@E 999,999'
			nTot := nTOTFUNC-(TRB2->RESPSIM + TRB2->RESPNAO) 
			If nTot < 0 
				nTot := 0
			EndIf   
			@ Li,093 PSAY nTOT PICTURE '@E 999,999'
		Else
			@ Li,006 PSAY Substr(TRB2->NOMPERGU,1,170)
			@ Li,180 PSAY TRB2->RESPSIM                            PICTURE '@E 999,999'
			@ Li,191 PSAY TRB2->RESPNAO                            PICTURE '@E 999,999'
			nTot := nTOTFUNC-(TRB2->RESPSIM + TRB2->RESPNAO) 
			If nTot < 0 
				nTot := 0
			EndIf   
			@ Li,203 PSAY nTOT PICTURE '@E 999,999'
		Endif

		dbSelectArea("TRB2")
		dbskip()
	Enddo

Endif

// EJECT

Roda(nCntImpr,cRodaTxt,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("TM1")
Set Filter To

Set device to Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
//SET CENTURY ON
MS_FLUSH()

dbSelectArea("TRB")
dbclosearea()
oTempTbl01:Delete()
//use
dbSelectArea("TRB2")
dbclosearea()
oTempTbl02:Delete()
//use
dbSelectArea("TMI")
dbSetOrder(01)

Return NIL
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ SomaLinha³ Autor ³ Inacio Luiz Kolling   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Incrementa Linha e Controla Salto de Pagina                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ SomaLinha()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MDTR405                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function Somalinha(lImpGrf,nSaltoGrf)

If Valtype(lImpGrf) == "L"
	If lImpGrf
		If Valtype(nSaltoGrf) == "N"
			lin += nSaltoGrf
		Else
			lin += 60
		Endif
		If lin > 3000
			oPrint:Line(lin,200,lin,2300)
			lin := 150
			oPrint:EndPage() //Fechar Pagina
			fInicPagina() //Iniciar Pagina
			//oPrint:Line(lin,200,lin,2300)
		Endif
		Return
	Endif
Endif

Li++
If Li > 58
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MDT410TMH³ Autor ³ André E. Perez Álvarez³ Data ³ 07/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a pergunta De Pergunta (prestador)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function MDT410TMH()

Return If(empty(mv_par06),.t.,ExistCpo("TMH",mv_par01+mv_par02+mv_par03+mv_par06,2))
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MDT410TMH³ Autor ³ André E. Perez Álvarez³ Data ³ 07/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a pergunta Ate Pergunta (prestador)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function MDTTMH410()

Return ValAte3(mv_par06,mv_par07,'TMH','TMH_QUESTA',mv_par01+mv_par02+mv_par03,2)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MDT410FIC³ Autor ³ André E. Perez Álvarez³ Data ³ 08/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a pergunta De Ficha Medica (prestador)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function MDT410FIC()   

Return IF(empty(mv_par04),.t.,existcpo('TM0',mv_par01+mv_par02+mv_par04,8))
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MDTFIC410³ Autor ³ André E. Perez Álvarez³ Data ³ 08/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a pergunta Ate Ficha Medica (prestador)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function MDTFIC410()   

Return ValAte3(mv_par04,mv_par05,'TM0','TM0_NUMFIC',mv_par01+mv_par02,8)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ fImpMod2 ³ Autor ³ André E. Perez Álvarez³ Data ³ 08/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a pergunta Ate Ficha Medica (prestador)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function fImpMod2()
Local nXYZ
Local cAliasCC := "SI3"
Local cCodCC2  := "I3_CUSTO"
Local cDescCC2 := "SI3->I3_DESC"
Local lCombTK0 := If( 	NGCADICBASE("TK0_FILIAL","D","TK0",.F.) .and. ;
						NGCADICBASE("TMH_COMBO","D","TMH",.F.)  .and. ;
						NGCADICBASE("TMH_CODGRU","D","TMH",.F.) , .t. ,.f. )
Local lTpDfTM0 := NGCADICBASE("TM0_TIPDEF","A","TM0",.F.)

Private cStartPath := AllTrim(GetSrvProfString("Startpath",""))
Private cBarraSrv := "\"
Private cBarSrv2 := "\\"
Private cLogo

If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cAliasCC := "CTT"
	cCodCC2  := "CTT_CUSTO"
	cDescCC2 := "CTT->CTT_DESC01"
Endif

If isSRVunix()  //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	cBarraSrv := "/"
	cBarSrv2 := "//"
Endif

If Substr(cStartPath,Len(cStartPath),1) <> cBarraSrv
	cStartPath := cStartPath+cBarraSrv
Endif

Private lin := 9999
Private nPag410 := 0
Private oPrint
Private oFont07  := TFont():New("Verdana",07,07,,.F.,,,,.F.,.F.)
Private oFont08  := TFont():New("Verdana",08,08,,.F.,,,,.F.,.F.)
Private oFont10b := TFont():New("Verdana",09,09,,.T.,,,,.F.,.F.)
Private oFont10	 := TFont():New("Verdana",09,09,,.F.,,,,.F.,.F.)
Private oFont15b := TFont():New("Verdana",15,15,,.T.,,,,.F.,.F.)
Private oFont16b := TFont():New("Verdana",16,16,,.T.,,,,.F.,.F.)
Private aCboxSV  := {}

oPrint := TMSPrinter():New(OemToAnsi(STR1006)) //"Questionario Medico"
oPrint:SetPortRait()
oPrint:Setup()

LoadArTmp(lCombTK0,.T.)

dbSelectArea("TRB")
dbGoTop()
lTemDados := .t.
If Eof()
	lTemDados := .f.
Endif
While !Eof()

	cFICHA := TRB->NUMFICHA
	dDTSAV := TRB->DTREAL

	fInicPagina()

	dbSelectArea("TM0")
	dbSetOrder(01)
	dbSeek(xFilial("TM0")+cFICHA)
	cCodFuncao := TM0->TM0_CODFUN
	cCodCcusto := TM0->TM0_CC
	dbSelectArea("SRA")
	dbSetOrder(01)
	If dbSeek( xFilial("SRA",TM0->TM0_FILFUN) + TM0->TM0_MAT )
		cCodFuncao := SRA->RA_CODFUNC
		cCodCcusto := SRA->RA_CC
	Endif
	dbSelectArea("SRJ")
	dbSetOrder(01)
	dbSeek( xFilial("SRJ") + cCodFuncao )
	dbSelectArea(cAliasCC)
	dbSetOrder(01)
	dbSeek( xFilial(cAliasCC) + cCodCcusto )

	oPrint:Line(330,200,550,200)
	oPrint:Line(330,2300,550,2300)
	oPrint:Line(550,200,550,2300)
	oPrint:Line(390,200,390,2300)

	oPrint:Say(340,210,"1. "+STR1027,oFont10b) //"IDENTIFICAÇÃO"
	oPrint:Say(400,210,STR1028+":",oFont10b) //"Nome"
	oPrint:Say(400,610,TM0->TM0_NOMFIC,oFont10)
	oPrint:Say(450,210,STR1029+":",oFont10b) //"Função"
	oPrint:Say(450,610,SRJ->RJ_DESC,oFont10)
	oPrint:Say(500,210,STR1030+":",oFont10b) //"Centro de Custo"
	oPrint:Say(500,610,&(cDescCC2),oFont10)

	cIdade := Alltrim( Str( Int((dDataBase - TM0->TM0_DTNASC) / 365) , 10 ) )
	oPrint:Say(400,1600,STR1031+":",oFont10b) //"Idade"
	oPrint:Say(400,1740,cIdade,oFont10)
	oPrint:Say(400,1910,STR1032+":",oFont10b) //"Sexo"
	oPrint:Say(400,2050,If(TM0->TM0_SEXO=="1",STR1010,STR1011),oFont10) //Masculino Feminino
	oPrint:Say(450,1600,STR1033+":",oFont10b) //"Data do Questionário"
	oPrint:Say(450,2050,DtoC(TRB->DTREAL),oFont10)
	oPrint:Say(500,1600,STR1034+":",oFont10b) //"Data Admissão"
	oPrint:Say(500,2050,DtoC(SRA->RA_ADMISSA),oFont10)

	oPrint:Line(550,200,870,200)
	oPrint:Line(550,2300,870,2300)
	oPrint:Line(870,200,870,2300)
	oPrint:Line(610,200,610,2300)

	aVetDiag := fRetPres( TM0->TM0_NUMFIC , TRB->DTREAL , TM0->TM0_PESO , TM0->TM0_ALTURA )
	oPrint:Say(560,210,"2. "+STR1035,oFont10b) //"EXAME FÍSICO"
	oPrint:Say(610,210,STR1036+":",oFont10b) //"Sinais Vitais"
	oPrint:Say(670,250,STR1037+":",oFont10b) //"PA"
	oPrint:Say(670,410, aVetDiag[1] ,oFont10)
	oPrint:Say(720,210,STR1038+":",oFont10b) //"Medidas Antopométricas"
	oPrint:Say(770,250,STR1039+":",oFont10b) //"Peso"
	If aVetDiag[2] <> 0
		oPrint:Say(770,410,Alltrim(Transform(aVetDiag[2],"@E 999.9")) + " " + STR1040,oFont10) //"KG"
	Endif
	oPrint:Say(820,250,STR1041+":",oFont10b) //"Altura"
	If aVetDiag[3] <> 0
		oPrint:Say(820,410,Transform(aVetDiag[3],"@E 9.99") + " "+"M",oFont10)
	Endif
	oPrint:Say(620,900,STR1042+":",oFont10b) //"Possui alguma deficiência"
	oPrint:Say(670,940,STR1043,oFont10) //"Física"
	oPrint:Say(720,940,STR1044,oFont10) //"Visual"
	oPrint:Say(770,940,STR1045,oFont10) //"Auditiva"
	oPrint:Say(820,940,STR1046,oFont10) //"Nenhuma"
	oPrint:Box(675,900,705,930)
	oPrint:Box(725,900,755,930)
	oPrint:Box(775,900,805,930)
	oPrint:Box(825,900,855,930)
	If lTpDfTM0
		If TM0->TM0_TIPDEF == "1"
			oPrint:line(675,900,705,930)
			oPrint:line(675,901,704,930)
			oPrint:line(676,900,705,929)
			oPrint:line(675,930,705,900)
			oPrint:line(675,929,704,900)
			oPrint:line(676,930,705,901)
		ElseIf TM0->TM0_TIPDEF == "2"
			oPrint:line(775,900,805,930)
			oPrint:line(775,901,804,930)
			oPrint:line(776,900,805,929)
			oPrint:line(775,930,805,900)
			oPrint:line(775,929,804,900)
			oPrint:line(776,930,805,901)
		ElseIf TM0->TM0_TIPDEF == "3"
			oPrint:line(725,900,755,930)
			oPrint:line(725,901,754,930)
			oPrint:line(726,900,755,929)
			oPrint:line(725,930,755,900)
			oPrint:line(725,929,754,900)
			oPrint:line(726,930,755,901)
		ElseIf TM0->TM0_TIPDEF $ "0/6" .or. Empty(TM0->TM0_TIPDEF)
			oPrint:line(825,900,855,930)
			oPrint:line(825,901,854,930)
			oPrint:line(826,900,855,929)
			oPrint:line(825,930,855,900)
			oPrint:line(825,929,854,900)
			oPrint:line(826,930,855,901)
		Endif
	Endif

	nContGrp := 2
	lin := 870
	lPrimQuest := .t.

	dbSelectArea("TRB")
	While !Eof() .and. TRB->NUMFICHA == cFICHA .and. dDTSAV == TRB->DTREAL

		cCodGrupo := TRB->CODGRUPO
		cDesGrupo := STR1047 //"QUESTIONÁRIO"
		nContGrp++
		If lCombTK0
			dbSelectArea("TK0")
			dbSetOrder(01)
			If dbSeek( xFilial("TK0") + cCodGrupo )
				If !Empty(TK0->TK0_DESCRI)
					cDesGrupo := Alltrim(TK0->TK0_DESCRI)
				Endif
			Endif
		Endif
		If !lPrimQuest
			SomaLinha(.t.)
		Endif
		lPrimQuest := .f.
		oPrint:Line(lin,200,lin+60,200)
		oPrint:Line(lin,2300,lin+60,2300)
		oPrint:Line(lin+60,200,lin+60,2300)
		oPrint:Say(lin+10,210,Alltrim(Str(nContGrp,10))+". "+cDesGrupo,oFont10b)
		
		dbSelectArea("TRB")
		While !Eof() .and. TRB->NUMFICHA == cFICHA .and. dDTSAV == TRB->DTREAL .and. cCodGrupo == TRB->CODGRUPO

			lParte2 := .f.
			aDados2 := { {} , " " , " " , " " }
			dbSkip()
			//Carrega dados para a segunda coluna
			If !Eof() .and. TRB->NUMFICHA == cFICHA .and. dDTSAV == TRB->DTREAL .and. cCodGrupo == TRB->CODGRUPO
				lParte2 := .t.
				aDados2[1] := fRetCbox( TRB->XCOMBO )
				aDados2[2] := TRB->NOMPERGU
				aDados2[3] := aScan(aDados2[1],{|x| x[2] == Substr(TRB->RESPOS,1,1) })
				If TRB->QUANTID > 0
					If ( TRB->QUANTID - Int(TRB->QUANTID) ) <> 0
						aDados2[4] := Alltrim(Transform(TRB->QUANTID,"@E 999999.99")) + " " + Capital(TRB->COMPLEM)
					Else
						aDados2[4] := Alltrim(Transform(TRB->QUANTID,"@E 999999")) + " " + Capital(TRB->COMPLEM)
					Endif
				Else
					aDados2[4] := Capital(TRB->COMPLEM)
				Endif
			Endif
			dbSkip(-1)

			//Carrega lista de respostas da primeira coluna
			aRetBox  := fRetCbox( TRB->XCOMBO )
			nPosMark := aScan(aRetBox,{|x| x[2] == Substr(TRB->RESPOS,1,1) })

			//Verifica qual coluna tem mais opções
			nTamBox := Max( Len(aRetBox) , Len(aDados2[1]) )
			
			//Verifica se necessita de uma segunda linha para o titulo da pergunta
			nTamAdd := 0
			If ( Len(Alltrim(TRB->NOMPERGU)) > 50 .and. lParte2) .or. Len(Alltrim(aDados2[2])) > 50 .or. Len(Alltrim(TRB->NOMPERGU)) > 100
				nTamAdd := 50
			Endif
			If nTamAdd + lin + (nTamBox * 50) + 60 > 3000
				lin := 9999
			Endif
			SomaLinha(.t.)

			//Imprime a pergunta
			cTxt001 := Capital(Alltrim(TRB->NOMPERGU))
			cTxt002 := Capital(Alltrim(aDados2[2]))

			oPrint:Line(lin,200,lin+60,200)
			oPrint:Line(lin,2300,lin+60,2300)
			If nTamAdd == 0
				oPrint:Say(lin+10,210,cTxt001,oFont10b)
				If lParte2
					oPrint:Line(lin,1250,lin+60,1250)
					oPrint:Say(lin+10,1260,cTxt002,oFont10b)
				Endif
			Else
				If lParte2
					oPrint:Say(lin+10,210,Memoline(cTxt001,50,1),oFont10b)
					oPrint:Line(lin,1250,lin+60,1250)
					oPrint:Say(lin+10,1260,Memoline(cTxt002,50,1),oFont10b)
				Else
					oPrint:Say(lin+10,210,Memoline(cTxt001,100,1),oFont10b)
				Endif
				nTamBox++ //Incrementa mais um loop
			Endif
			lin += 10

			nCont1 := 0
			nCont2 := 0
			For nXYZ := 1 To nTamBox
				SomaLinha(.t.,50)
				oPrint:Line(lin,200,lin+50,200)
				oPrint:Line(lin,2300,lin+50,2300)
				If lParte2
					oPrint:Line(lin,1250,lin+50,1250)
				Endif

				If nXYZ == 1 .and. nTamAdd > 0
					If lParte2
						If !Empty(Memoline(cTxt001,50,2))
							oPrint:Say(lin,210,Memoline(cTxt001,50,2),oFont10b)
						Else
							nCont1++
						Endif
						If !Empty(Memoline(cTxt002,50,2))
							oPrint:Say(lin,1260,Memoline(cTxt002,50,2),oFont10b)
						Else
							nCont2++
						Endif
					Else
						oPrint:Say(lin,210,Memoline(cTxt001,100,2),oFont10b)
					Endif
				Else
					nCont1++
					nCont2++
				Endif

				If Len(aRetBox) >= nCont1 .and. nCont1 > 0
					oPrint:Box(lin+10,210,lin+40,240)
					oPrint:Say(lin+5,260,aRetBox[nCont1,1],oFont10)
					If nCont1 == nPosMark
						oPrint:line(lin+10,210,lin+40,240)
						oPrint:line(lin+10,211,lin+39,240)
						oPrint:line(lin+11,210,lin+40,239)
						oPrint:line(lin+10,240,lin+40,210)
						oPrint:line(lin+10,239,lin+39,210)
						oPrint:line(lin+11,240,lin+40,211)
						
						cTxtCom := Capital(TRB->COMPLEM)
						If TRB->QUANTID > 0
							If ( TRB->QUANTID - Int(TRB->QUANTID) ) <> 0
								cTxtCom := Alltrim(Transform(TRB->QUANTID,"@E 999999.99")) + " " + cTxtCom
							Else
								cTxtCom := Alltrim(Transform(TRB->QUANTID,"@E 999999")) + " " + cTxtCom
							Endif
						Endif
						If !Empty(cTxtCom)
							nTamTit := 290 + ( Len(aRetBox[nCont1,1]) * 19 )
							nSubCom := 30 - Len(aRetBox[nCont1,1])
							If lParte2
								oPrint:line(lin+45,nTamTit,lin+45,1245)
								oPrint:Say(lin+5,nTamTit,Substr(cTxtCom,1,15+nSubCom),oFont08)
							Else
								oPrint:line(lin+45,nTamTit,lin+45,2290)
								oPrint:Say(lin+5,nTamTit,Substr(cTxtCom,1,15+nSubCom+50),oFont08)
							Endif
						Endif
					Endif
				Endif
				If Len(aDados2[1]) >= nCont2 .and. nCont2 > 0
					oPrint:Box(lin+10,1260,lin+40,1290)
					oPrint:Say(lin+5,1310,aDados2[1,nCont2,1],oFont10)
					If nCont2 == aDados2[3]
						oPrint:line(lin+10,1260,lin+40,1290)
						oPrint:line(lin+10,1261,lin+39,1290)
						oPrint:line(lin+11,1260,lin+40,1289)
						oPrint:line(lin+10,1290,lin+40,1260)
						oPrint:line(lin+10,1289,lin+39,1260)
						oPrint:line(lin+11,1290,lin+40,1261)
						If !Empty(aDados2[4])
							nTamTit := 1340 + ( Len(aRetBox[nCont1,1]) * 19 )
							nSubCom := 30 - Len(aRetBox[nCont1,1])
							oPrint:line(lin+45,nTamTit,lin+45,2290)
							oPrint:Say(lin+5,nTamTit,Substr(aDados2[4],1,15+nSubCom),oFont08)
						Endif
					Endif
				Endif
				If nXYZ == nTamBox
					oPrint:Line(lin+50,200,lin+50,2300)
				Endif
			Next nXYZ
			lin -= 10
	
			dbSelectArea("TRB")
			If lParte2 // Salta 2 registros
				dbSkip()
				dbSkip()
			Else
				dbSkip()
			Endif
		End
	End

	If lin+540 > 3000
		lin := 9999
	Endif
	Somalinha(.t.)
	oPrint:Line(lin,200,lin+540,200)
	oPrint:Line(lin+60,1250,lin+540,1250)
	oPrint:Line(lin,2300,lin+540,2300)

	oPrint:Line(lin+60,200,lin+60,2300)
	oPrint:Line(lin+120,200,lin+120,2300)
	oPrint:Line(lin+220,200,lin+220,2300)
	oPrint:Line(lin+280,200,lin+280,2300)
	oPrint:Line(lin+380,200,lin+380,2300)
	oPrint:Line(lin+440,200,lin+440,2300)
	oPrint:Line(lin+540,200,lin+540,2300)

	nContGrp++
	oPrint:Say(lin+10,210,Alltrim(Str(nContGrp,10))+". "+ STR1048,oFont10b) //"REGISTRO DE LEGITIMIDADE E VERACIDADE DAS INFORMAÇÕES"

	oPrint:Say(lin+70,500,STR1049,oFont10) //"DATA DO PREENCHIMENTO"
	oPrint:Line(lin+215,510,lin+215,950)
	oPrint:Line(lin+215,657,lin+155,667)
	oPrint:Line(lin+215,802,lin+155,812)
	oPrint:Say(lin+70,1480,STR1050,oFont10) //"ASSINATURA DO COLABORADOR"
	oPrint:Line(lin+215,1300,lin+215,2250)

	oPrint:Say(lin+230,500,STR1049,oFont10) //"DATA DO PREENCHIMENTO"
	oPrint:Line(lin+375,510,lin+375,950)
	oPrint:Line(lin+375,657,lin+315,667)
	oPrint:Line(lin+375,802,lin+315,812)
	oPrint:Say(lin+230,1255,STR1057,oFont10) //"ASSINATURA DO AUXILIAR NO REENCHIMENTO/TESTEMUNHA"
	oPrint:Line(lin+375,1300,lin+375,2250)

	oPrint:Say(lin+390,500,STR1051,oFont10) //"DATA DA ANÁLISE E EXAME"
	oPrint:Line(lin+535,510,lin+535,950)
	oPrint:Line(lin+535,657,lin+475,667)
	oPrint:Line(lin+535,802,lin+475,812)
	oPrint:Say(lin+390,1440,STR1052,oFont10) //"ASSINATURA DO MÉDICO EXAMINADOR"
	oPrint:Line(lin+535,1300,lin+535,2250)

	oPrint:EndPage() //Fechar Pagina
End

If !lTemDados
	MsgInfo(STR1023)  //"Não há nada para imprimir no relatório."
Else
	If lPrintTel
		oPrint:Preview()
	Else
		oPrint:Print()
	EndIf
Endif

dbSelectArea("TRB")
Use
dbSelectArea("TRB2")
Use

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³LoadArTmp ³ Autor ³ Denis                 ³ Data ³ 20/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Carrega arquivo temporario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function LoadArTmp(lCombTK0,lRelGraf)

Local nLenCompl := (TAMSX3("TMI_COMRES")[1])
If nLenCompl < 30
	nLenCompl := 30
Endif

aDBF := {}
AADD(aDBF,{ "MATRICULA" , "C" ,06, 0 })
AADD(aDBF,{ "NUMFICHA"  , "C" ,09, 0 })
AADD(aDBF,{ "PERGUNTA"  , "C" ,03, 0 })
AADD(aDBF,{ "NOMPERGU"  , "C" ,nSizeTMH, 0 })
AADD(aDBF,{ "RESPOS"    , "C" ,01, 0 })
AADD(aDBF,{ "DTREAL"    , "D" ,08, 0 })
AADD(aDBF,{ "QUANTID"   , "N" ,09, 2 })
AADD(aDBF,{ "COMPLEM"   , "C" ,nLenCompl, 0 })
AADD(aDBF,{ "CODGRUPO"  , "C" ,03, 0 })
AADD(aDBF,{ "XCOMBO"   , "C" ,250, 0 })

/********************************************************************************************************************************/
/*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
//cArqTrab := CriaTrab(aDBF)
//Use (cArqTrab) NEW Exclusive Alias TRB
//INDEX ON NUMFICHA+DTOS(DTREAL)+CODGRUPO+PERGUNTA TO (cArqTrab)
oTempTbl01 := FWTemporaryTable():New( "TRB" )
oTempTbl01:SetFields( aDBF )
oTempTbl01:AddIndex( "cInd01", { "NUMFICHA", "DTREAL", "CODGRUPO", "PERGUNTA" } )
oTempTbl01:Create()
/********************************************************************************************************************************/

aDBF2 := {}
AADD(aDBF2,{ "PERGUNTA" , "C" ,03, 0 })
AADD(aDBF2,{ "NOMPERGU" , "C" ,nSizeTMH, 0 })
AADD(aDBF2,{ "RESPSIM"  , "N" ,06, 0 })                                  
AADD(aDBF2,{ "RESPNAO"  , "N" ,06, 0 })

/********************************************************************************************************************************/
/*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
//cArqTrab2 := CriaTrab(aDBF2)
//Use (cArqTrab2) NEW Exclusive Alias TRB2
//INDEX ON PERGUNTA TO (cArqTrab2)
oTempTbl02 := FWTemporaryTable():New( "TRB2" )
oTempTbl02:SetFields( aDBF2 )
oTempTbl02:AddIndex( "cInd01", { "PERGUNTA" } )
oTempTbl02:Create()
/********************************************************************************************************************************/
If lSigaMdtps

	dbSelectArea("TMI")
	dbSetOrder(04)  //TMI_FILIAL+TMI_CLIENT+TMI_LOJA+TMI_QUESTI
	dbSeek(xFilial("TMI")+MV_PAR01+MV_PAR02+MV_PAR03)

	If lRelGraf
		ProcRegua(LastRec())
	Else
		SetRegua(LastRec())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Correr TMI para ler as  Questoes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !Eof()                                   .AND.;
	      TMI->TMI_FILIAL == xFilial('TMI')        .AND.;
	      TMI->(TMI_CLIENT+TMI_LOJA) == MV_PAR01+MV_PAR02 .AND.;
	      TMI->TMI_QUESTI == MV_PAR03
	      	      
		If lRelGraf
			IncProc()
		Else
			IncRegua()
		Endif

		If TMI->TMI_NUMFIC < mv_par04 .or. TMI->TMI_NUMFIC > mv_par05
			dbSelectArea("TMI")
			dbSkip()
			Loop		
		Endif
		
		dbSelectArea("TM0")
		dbSetOrder(1)
		If !dbSeek(xFilial("TM0")+TMI->TMI_NUMFIC)
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
			
		If TMI->TMI_QUESTA < MV_PAR06 .OR. TMI->TMI_QUESTA > MV_PAR07
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
	
		If TMI->TMI_DTREAL < MV_PAR08 .OR. TMI->TMI_DTREAL > MV_PAR09
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TMH")
		dbSetOrder(02)  //TMH_FILIAL+TMH_CLIENT+TMH_LOJA+TMH_QUESTI+TMH_QUESTA
		If !dbSeek(xFilial("TMH")+mv_par01+mv_par02+TMI->TMI_QUESTI+TMI->TMI_QUESTA)
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
	
		TRB->(DbAppend())
	
		TRB->MATRICULA  := TM0->TM0_MAT
		TRB->NUMFICHA   := TMI->TMI_NUMFIC
		TRB->PERGUNTA   := TMI->TMI_QUESTA
		TRB->NOMPERGU   := TMH->TMH_PERGUN
		TRB->RESPOS     := TMI->TMI_RESPOS
		TRB->DTREAL     := TMI->TMI_DTREAL
		TRB->QUANTID    := TMI->TMI_QTRESP
		TRB->COMPLEM    := TMI->TMI_COMRES
		If lCombTK0
			TRB->XCOMBO   := TMH->TMH_COMBO
			TRB->CODGRUPO := TMH->TMH_CODGRU
		Endif

		dbSelectArea("TRB2")
		If !dbSeek(TMI->TMI_QUESTA)
			TRB2->(DbAppend())
			TRB2->PERGUNTA := TMI->TMI_QUESTA
			TRB2->NOMPERGU := TMH->TMH_PERGUN
		Endif
	
		If TMI->TMI_RESPOS = '1'
			TRB2->RESPSIM := TRB2->RESPSIM + 1
		Else
			TRB2->RESPNAO := TRB2->RESPNAO + 1
		Endif
	
		dbSelectArea("TMI")
		dbSKIP()
	
	End

Else

	dbSelectArea("TMI")
	dbSetOrder(02)
	dbSeek(xFilial("TMI")+MV_PAR01,.T.)

	If lRelGraf
		ProcRegua(LastRec())
	Else
		SetRegua(LastRec())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Correr TMI para ler as  Questoes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	While !Eof()                                   .AND.;
	      TMI->TMI_FILIAL == xFIlial('TMI')        .AND.;
	      TMI->TMI_QUESTI == MV_PAR01

		If lRelGraf
			IncProc()
		Else
			IncRegua()
		Endif

		If TMI->TMI_QUESTA < MV_PAR04 .OR. TMI->TMI_QUESTA > MV_PAR05
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
	
		If TMI->TMI_DTREAL < MV_PAR06 .OR. TMI->TMI_DTREAL > MV_PAR07
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TM0")
		dbSetOrder(01)
		If dbSeek(xFilial("TM0")+TMI->TMI_NUMFIC)
			If TM0->TM0_NUMFIC < MV_PAR02 .OR. TM0->TM0_NUMFIC > MV_PAR03
				dbSelectArea("TMI")
				dbSkip()
				loop
			Endif
		Else
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
	
		dbSelectArea("TMH")
		dbSetOrder(01)
		If !dbSeek(xFilial("TMH")+TMI->TMI_QUESTI+TMI->TMI_QUESTA)
			dbSelectArea("TMI")
			dbSkip()
			loop
		Endif
	
		TRB->(DbAppend())
	
		TRB->MATRICULA  := TM0->TM0_MAT
		TRB->NUMFICHA   := TMI->TMI_NUMFIC
		TRB->PERGUNTA   := TMI->TMI_QUESTA
		TRB->NOMPERGU   := TMH->TMH_PERGUN
		TRB->RESPOS     := TMI->TMI_RESPOS
		TRB->DTREAL     := TMI->TMI_DTREAL
		TRB->QUANTID    := TMI->TMI_QTRESP
		TRB->COMPLEM    := TMI->TMI_COMRES
		If lCombTK0
			TRB->XCOMBO   := TMH->TMH_COMBO
			TRB->CODGRUPO := TMH->TMH_CODGRU
		Endif
	
		dbSelectArea("TRB2")
		If !dbSeek(TMI->TMI_QUESTA)
			TRB2->(DbAppend())
			TRB2->PERGUNTA := TMI->TMI_QUESTA
			TRB2->NOMPERGU := TMH->TMH_PERGUN
		Endif
	
		If TMI->TMI_RESPOS = '1'
			TRB2->RESPSIM := TRB2->RESPSIM + 1
		Else
			TRB2->RESPNAO := TRB2->RESPNAO + 1
		Endif
	
		dbSelectArea("TMI")
		dbSKIP()
	
	End

Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fRetCbox ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 01/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para mostar lista de opções ao entrar no campo      ³±±
±±³          ³ TMH_COMBO                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRetCbox( cCboxTMH )
Local nPos,nPos1,cDesc,nXX,aCodBox
Local aBoxPerg := {}
Local cSemRes := "1="+STR1012+";"+"2="+STR1013+";"+"3="+STR1056 //"Sim"###"Nao"###"Sem Resposta"

nPos1 := aScan(aCboxSV,{|x| x[1] == Alltrim(cCboxTMH) })
If nPos1 > 0
	aBoxPerg := aClone( aCboxSV[nPos1,2] )
Else
	aCodBox := {"1","2","3","4","5","6","7","8","9",;
				"A","B","C","D","E","F","G","H","I",;
				"J","K","L","M","N","O","P","Q","R",;
				"S","T","U","V","W","X","Y","Z" }
	If Alltrim(cCboxTMH) <> cSemRes
		For nXX := 1 To Len(aCodBox)
			nPos := At( aCodBox[nXX]+"=" , cCboxTMH )
			If nPos > 0
				nPos1 := At( ";" , Substr( cCboxTMH , nPos+2 ) )
				cDesc := Alltrim(Substr( cCboxTMH , nPos+2 ))
				If nPos1 > 0
					cDesc := Alltrim(Substr( cCboxTMH , nPos+2 , nPos1-1 ))
				Endif
				aAdd( aBoxPerg , { Alltrim(Substr(cDesc,1,30)) , aCodBox[nXX] } )
			Endif
		Next nXX
	Endif
	If Len(aBoxPerg) == 0
		aAdd( aBoxPerg , { STR1012 , "1" } ) //"Sim"
		aAdd( aBoxPerg , { STR1013 , "2" } ) //"Nao"
	Endif
	aAdd(aCboxSV , { Alltrim(cCboxTMH) , aBoxPerg } )
Endif

Return aBoxPerg

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fInicPagina³Autor ³Denis Hyroshi de Souza ³ Data ³ 01/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para imprimir cabeçalho do relatorio                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fInicPagina()

oPrint:StartPage() //Iniciar Pagina
oPrint:Box(150,200,330,2300)
cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" //Empresa+Filial
If File(cLogo)
	oPrint:SayBitMap(160,210,cLogo,310,170)
Else
	cLogo := cStartPath+"LGRL"+SM0->M0_CODIGO+".BMP" //Empresa
	If File(cLogo)
		oPrint:SayBitMap(160,210,cLogo,310,170)
	Endif
Endif

nColInic := 530
nTamTit  := Int(Len(cDESQUEST)/2)
nTamTit  := If(nTamTit>20,20,nTamTit)
nTamTit  := If(nTamTit==0,1,nTamTit)
nColInic := 530 + ( ( 20 - nTamTit ) * 38 )
If Len(cDESQUEST) > 36
	oPrint:Say(210,540,Substr(cDESQUEST,1,40),oFont15b) //Nome Questionario
Else
	oPrint:Say(210,nColInic,Substr(cDESQUEST,1,40),oFont16b) //Nome Questionario
Endif

nPag410++
oPrint:Say(170,2070,STR1053 + cValToChar(nPag410),oFont07) //"Pág.: "
oPrint:Say(210,2070,STR1054 + cValToChar(dDataBase),oFont07) //"Data: "
oPrint:Say(250,2070,STR1055 + Time(),oFont07) //"Hora: "
lin := 330

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fRetPres ³ Autor ³Denis Hyroshi de Souza ³ Data ³ 01/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Localiza ultimo diagnostico                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRetPres( nFichaMed , dRealData , nPesoTM0 , nAltTM0 )
Local aRet := { " " , 0 , 0 }

dbSelectArea("TMT")
dbSetOrder(3)
dbSeek(xFilial("TMT")+nFichaMed+DTOS(dRealData),.t.)
If Eof() .Or. Bof() .Or. TMT->TMT_FILIAL != xFilial("TMT") .Or. TMT->TMT_NUMFIC != nFichaMed .Or. TMT_DTCONS != dRealData
	dbSkip(-1)
Endif
While !Eof() .and. !Bof() .and. TMT->TMT_FILIAL == xFilial("TMT") .and. TMT->TMT_NUMFIC == nFichaMed
	If !Empty(TMT->TMT_PREART) .and. Empty(aRet[1])
		aRet[1] := TMT->TMT_PREART
	Endif
	If !Empty(TMT->TMT_PESO) .and. Empty(aRet[2])
		aRet[2] := TMT->TMT_PESO
	Endif
	If !Empty(TMT->TMT_ALTURA) .and. Empty(aRet[3])
		aRet[3] := TMT->TMT_ALTURA
	Endif
	dbSkip(-1)
	If !Empty(aRet[1]) .and. !Empty(aRet[2]) .and. !Empty(aRet[3])
		Exit
	Endif
End

If Empty(aRet[2])
	aRet[2] := nPesoTM0
Endif
If Empty(aRet[3])
	aRet[3] := nAltTM0
Endif

Return aRet