#include "rwmake.ch"        

/////////////////////////////////////////////////////////
//                                                     //
// FunГЮo....: BRPCP022     Data....: 28.01.02         //
// Autor.....: Marcos Cesar D.Vieira                   //
// DescriГao.: Relatorio de itens em ponto de pedido   //
// Uso.......: Brasilux/Resina                         //
//                                                     //
/////////////////////////////////////////////////////////  

User Function BRPCP022
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL wnrel
LOCAL Tamanho  := "G"
LOCAL cDesc1   := "Emite uma relacao com os itens em estoque que atingiram o Ponto de"
LOCAL cDesc2   := "Pedido ,sugerimdo a quantidade a comprar."
LOCAL cDesc3   := ""

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis tipo Private padrao de todos os relatorios         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nomeprog := "BRPCP022"
PRIVATE cString  := "SB1"
PRIVATE aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }		
PRIVATE nLastKey := 0 ,cPerg := "MTR440"
PRIVATE titulo   := "Itens em Ponto de Pedido"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Contadores de linha e pagina                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE li := 80 ,m_pag := 1

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas para parametros                         Ё
//Ё mv_par01             // Produto de                           Ё
//Ё mv_par02             // Produto ate                          Ё
//Ё mv_par03             // Grupo de                             Ё
//Ё mv_par04             // Grupo ate                            Ё
//Ё mv_par05             // Tipo de                              Ё
//Ё mv_par06             // Tipo ate                             Ё
//Ё mv_par07             // Local de                             Ё
//Ё mv_par08             // Local ate                            Ё
//Ё mv_par09             // Considera Necess Bruta   1 - Sim     Ё Pto Pedido
//Ё mv_par10             // Saldo Neg Considera      1 - Sim     Ё Lote Economico
//Ё mv_par11             // Considera C.Q.           1 - Sim     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
pergunte(cPerg,.F.)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)

If nLastKey = 27
	Set Filter To
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
   Set Filter To
   Return
Endif

#IFDEF WINDOWS
	RptStatus({|lEnd| R022Imp(@lEnd,tamanho,wnrel,cString)},Titulo)
#ELSE
	R440Imp(.F.,tamanho,wnrel,cString)
#ENDIF	

Return .T.

///////////////////////////////////////////////
//                                           //
// Funcao....: R022IMP                       //
// Autor.....: Marcos Cesar                  //
// Data......: 28.01.02                      //
// Descricao.: Chamada do Relatorio          //
// Uso.......: BRPCP022                      //
//                                           //
///////////////////////////////////////////////
Static Function R022Imp(lEnd,tamanho,wnrel,cString)

LOCAL nQuant := nSaldo := 0 ,nValUnit ,nValor ,nValTot ,cTipoVal ,nPrazo, nX
LOCAL nToler, nEstSeg, nNeces := 0
LOCAL nCntImpr := 0
LOCAL cRodaTxt := "PRODUTO(S)"
LOCAL nTipo    := 0
LOCAL cabec1,cabec2
//Local cabec3
//LOCAL limite 	:= 132
//LOCAL cbCont   := 0
LOCAL cLocCQ	:= GetMV("MV_CQ")
LOCAL _cFilial := xFilial("SB1")
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa os codigos de caracter Comprimido/Normal da impressora Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nTipo  := IIF(aReturn[4]==1,15,18)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta os Cabecalhos                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cabec1 := "CODIGO          DESCRICAO                      TP GRP  UM  SALDO ATUAL     PONTO DE   ESTOQUE DE         LOTE ___TOLERANCIA___   QUANTIDADE QUANTIDADE A   VALOR ESTIMADO BASE  DATA DE   VALOR UNITARIO     PRAZO DE"
cabec2 := "                                                                             PEDIDO    SEGURANCA    ECONOMICO   %   QUANTIDADE   POR EMBAL.      COMPRAR        DA COMPRA      REFERENCIA      DA COMPRA      ENTREGA"
*****     0123456789012345 123456789012345678901234567890 12 1234 12 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 999 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999.999,99 XXXX 99/99/9999 999.999.999,99 99999 Dia(s)
*****     0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
*****     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123

dbSelectArea("SB1")
SetRegua(RecCount())

Set SoftSeek On
dbSeek( _cFilial+mv_par01 )
Set SoftSeek Off
nValTot := 0

While !Eof() .And. B1_FILIAL+B1_COD <= _cFilial+mv_par02

	#IFNDEF WINDOWS
		If LastKey() = 286    //ALT_A
			lEnd := .t.
		EndIf
	#ENDIF	

	If lEnd
		@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"		
		Exit
	Endif

	IncRegua()
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Filtra grupos e tipos nao selecionados e tambem se for MODЁ
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If B1_GRUPO < mv_par03 .Or. B1_GRUPO > mv_par04 .Or.;
		B1_TIPO  < mv_par05 .Or. B1_TIPO  > mv_par06 .Or.;
		SubStr(B1_COD,1,3) == "MOD" .Or. B1_TIPO == "BN" .Or.;
		B1_CONTRAT == "S"
		dbSkip()
		Loop
	EndIf

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Direciona para funcao que calcula o necessidade de compra Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//зддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula o saldo atual de todos os almoxarifados Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea("SB2")
	dbSeek( _cFilial+SB1->B1_COD )
	While !Eof() .And. B2_FILIAL+B2_COD == _cFilial+SB1->B1_COD
		If B2_LOCAL < mv_par07 .Or. B2_LOCAL > mv_par08
			dbSkip()
			Loop
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддд©
		//Ё inclui os produtos que estao no C.Q.      Ё
		//юддддддддддддддддддддддддддддддддддддддддддды
		If B2_LOCAL == cLocCQ .And. mv_par11 == 2
			dbSkip()
			Loop
		Endif			
		nSaldo += (SaldoSB2()+B2_SALPEDI)       //- B2_QPEDVEN
		dbSkip()
	EndDo		
	nEstSeg := CalcEstSeg( SB1->B1_ESTFOR )
	nSaldo -= nEstSeg
   If (Round(nSaldo,4) # 0) .Or. (mv_par09 == 1)
		Do Case
			Case ( SB1->B1_EMIN != 0 .And. MV_PAR09 == 1 )
			   nNeces := If((nSaldo < 0),Abs(nSaldo)+SB1->B1_EMIN,(SB1->B1_EMIN-nSaldo))
			Case ( SB1->B1_EMIN != 0 .And. MV_PAR09 == 2 )
			   nNeces := If((nSaldo < 0),Abs(nSaldo),(SB1->B1_EMIN-nSaldo))			
			Case ( SB1->B1_LE != 0 .And. (nSaldo < 0  .or. mv_par09 == 2) )
				If ( MV_PAR10 == 2 .And. nSaldo < 0 )
				   nNeces := Abs(nSaldo)+SB1->B1_LE
				Else
					nNeces := If( Abs(nSaldo)<SB1->B1_LE,SB1->B1_LE,if(nSaldo<0,Abs(nSaldo),0))
				EndIf
   		OtherWise
	         nNeces := IF(MV_PAR09 == 1,IIf(nSaldo<0,Abs(nSaldo),0),0)
	   EndCase
   Else
		If SB1->B1_EMIN != 0 
			 nNeces := ( SB1->B1_EMIN )
		Else	 
	      nNeces := 0
		Endif	
   EndIf

	If nNeces > 0
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se o produto tem estrutura                       Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		dbSelectArea("SG1")
		If dbSeek( xFilial()+SB1->B1_COD )
			aQtdes := CalcLote(SB1->B1_COD,nNeces,"F")
		Else
			aQtdes := CalcLote(SB1->B1_COD,nNeces,"C")
		Endif	
		For nX := 1 to Len(aQtdes)
			nQuant += aQtdes[nX]
		Next
	EndIf

	dbSelectArea("SB1")

	If nQuant > 0

		//зддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pega o prazo de entrega do material         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддды
		nPrazo := CalcPrazo(SB1->B1_COD,nQuant)
		dbSelectArea("SB1")

		//зддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calcula a tolerancia do item                Ё
		//юддддддддддддддддддддддддддддддддддддддддддддды
		nToler   := (B1_LE * B1_TOLER)/100

		If li > 55
			Cabec(titulo,cabec1,cabec2,nomeprog,Tamanho,nTipo)
		EndIf

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Adiciona 1 ao contador de registros impressos         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nCntImpr++
  
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica qual dos precos e' mais recente servir de base Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If B1_UCOM < B1_DATREF
			cTipoVal := "STD"
			dData    := B1_DATREF
			nValUnit := B1_CUSTD
		Else
			cTipoVal := "U.CO"
			dData    := B1_UCOM
			nValUnit := B1_UPRC
		EndIf
		nValor := nQuant * nValUnit
		
		@ li,000 PSAY B1_COD
		@ li,016 PSAY SubStr(B1_DESC,1,30)
		@ li,047 PSAY B1_TIPO
		@ li,050 PSAY B1_GRUPO
		@ li,055 PSAY B1_UM
		@ li,058 PSAY nSaldo    Picture PesqPictQt("B2_QATU",12)
		@ li,071 PSAY B1_EMIN   Picture PesqPictQt("B1_EMIN",12)
		@ li,084 PSAY nESTSEG   Picture PesqPictQt("B1_ESTSEG",12)
		@ li,097 PSAY B1_LE     Picture PesqPictQt("B1_LE",12)
		@ li,110 PSAY B1_TOLER  Picture "999"
		@ li,114 PSAY nToler    Picture PesqPictQt("B1_LE",12)
		@ li,127 PSAY B1_QE     Picture PesqPictQt("B1_LE",12)
		@ li,140 PSAY nQuant    Picture PesqPictQt("B1_LE",12)
		@ li,153 PSAY nValor    Picture TM(nValor,16)
		@ li,170 PSAY cTipoVal
		@ li,175 PSAY dData
		@ li,186 PSAY nValUnit  Picture TM(nValUnit,14)
		@ li,201 PSAY nPrazo    Picture "99999"
		@ li,207 PSAY "Dia(s)"

		nValTot += nValor
		li++

	Endif

	nSaldo := 0
	nQuant := 0

	dbSelectArea("SB1")
	dbSkip()

EndDo

If li != 80
	Li++
	@ li,000 PSAY "TOTAL GERAL A COMPRAR"+Replicate(".",131)		//"TOTAL GERAL A COMPRAR"
	@ li,153 PSAY nValTot Picture TM(nValTot,16)
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Devolve a condicao original do arquivo principal             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea(cString)
Set Filter To
Set Order To 1

Set device to Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return .T.