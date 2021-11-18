#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPConn.ch'
#INCLUDE 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"
#DEFINE ENTER Chr(13)+Chr(10)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |COMMI010    ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Esse arquivo contém funçoes responsáveis pelo funcionamento da   ³±±
±±³          | opção de importação de XML de Nota Fiscal Eletronica             ³±±
±±³			 |                                                  				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Nil                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

User Function COMMI010()
     Local clPar         := "MTA140I"
     Local _lOpen        := .F. //LGS#20200128 - Adequação para release 12.1.25
     Private cIniFile    := GetADV97()
     Private cStartPath  := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\ENTRADA\'
     Private cStartLido  := Trim(cStartPath)+"OLD\"
     Private c2StartPath := Trim(cStartLido)+AllTrim(Str(Year(Date())))+"\"
     Private c3StartPath := Trim(c2StartPath)+AllTrim(Str(Month(Date())))+"\"	//MES
     Private cStartError := Trim(cStartPath)+"ERRO\"
     Private _cAliasSX3  := GetNextAlias() //LGS#20200128 - Adequação para release 12.1.25
     u_zcfga01( 'COMMI010' ) //LGS#2021118 - Gravação de log de utilização da rotina
     // ABERTURA DO DICIONÁRIO SX3 - LGS#20200128 - Adequação para release 12.1.25
     OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
     _lOpen := Select( _cAliasSX3 ) > 0

     If _lOpen //LGS#20200128 - Adequação para release 12.1.25
        //CRIA DIRETORIOS
        MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFE\')
        MakeDir(Trim(cStartPath)) //CRIA DIRETOTIO ENTRADA
        MakeDir(cStartLido) //CRIA DIRETORIO ARQUIVOS IMPORTADOS
        MakeDir(c2StartPath) //CRIA DIRETOTIO ANO
        MakeDir(c3StartPath) //CRIA DIRETOTIO MES
        MakeDir(cStartError) //CRIA DIRETORIO ERRO

        If Pergunte(clPar,.T.,"")
           MsgRun(("Aguarde..."+Space(1)+"Criando Interface"),"Aguarde...",{|| MontaBrw() } )
        EndIf
        //Restaura grupo de perguntas da rotina MATA140.
        Pergunte("MTA140",.F.)
        dbSelectArea( _cAliasSX3 )
        dbCloseArea()
     Else //LGS#20200128 - Adequação para release 12.1.25
        MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
     Endif
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | SelCor     ³Autor  ³Paulo Bindo            ³Data  ³30/01/12      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o |Funcao retorna objeto com cor do farol                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³clStatus = Status do registro (SDT->DT_STATUS)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³olCor = LoadBitmap(GetResources(),'COR')                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³	MontaBrw                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function SelCor(clStatus)

Local olCor := NIL

Do Case
	// STATUS = PROCESSADA PELO PROTHEUS
	Case clStatus == 'P'
		olCor:=LoadBitmap(GetResources(),'BR_VERMELHO')
	Case clStatus == 'R' //REJEITADO NA RECEITA
		olCor:=LoadBitmap(GetResources(),'BR_PRETO')
		// STATUS = LIBERADO PARA PRE-NOTA
	OtherWise
		olCor:=LoadBitmap(GetResources(),'BR_VERDE')
EndCase
Return olCor

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MontHdr    ³Autor  ³Paulo Bindo            |Data  ³30/01/12      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o |Funcao monta o aHeader do browse principal com os itens da SDS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alHdRet = Array com o nome dos campos selecionados no dicionario ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MontaBrw	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function MontHdr()
       Local alHdRet := {}

       aAdd(alHdRet,"DS_STATUS")
       //LGS#20200128 - Adequação para release 12.1.25
       /*dbSelectArea("SX3")
       DbSetOrder(1)
       dbGoTop()
       SX3->(DbSeek("SDS"))

       While !EOF() .AND. SX3->X3_ARQUIVO == "SDS"
             If (SX3->X3_BROWSE=="S") .AND. (cNivel>=SX3->X3_NIVEL) .AND. (!(ALLTRIM(SX3->X3_CAMPO) $ "DS_FILIAL/DS_STATUS"))
                Aadd(alHdRet,SX3->X3_CAMPO)
             EndIf
             DbSkip()
       EndDo*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder( 1 ) )
       ( _cAliasSX3 )->( DbGoTop() )
       ( _cAliasSX3 )->( DbSeek("SDS") )
       While !EOF() .AND. ( _cAliasSX3 )->( X3_ARQUIVO ) == "SDS"
             If ( ( _cAliasSX3 )->( X3_BROWSE ) == "S" ) .AND. ( cNivel >= ( _cAliasSX3 )->( X3_NIVEL ) ) .AND. ( !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) $ "DS_FILIAL/DS_STATUS" ) )
                Aadd( alHdRet, ( _cAliasSX3 )->( X3_CAMPO ) )
             EndIf
             ( _cAliasSX3 )->( DbSkip() )
       EndDo
       aAdd( alHdRet, "DS_CHAVENF" )
Return alHdRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | CarItens(alHdr,alParam)³Autor|Paulo Bindo         |Data³ 30/01/12³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o | Funcao verifica os itens a carregar no browse perante os campos  ³±±
±±³          | e parametro.							                            ³±±
±±³          | Adciona os registro em um array (alRet) que e usado como retorno ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³alHdr   := Array com os campos do browse                          ³±±
±±³          |alParam := Array com os possiveis parametros, sendo as posicoes   ³±±
±±³          | [1]-{1 , " " } // 1 - Liberado para pre-nota      			    ³±±
±±³          | [2]-{2 , "P" } // 2 - Processada pelo Protheus				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet = Array contendo os registros                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AtuBrw	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

Static Function CarItens(alHdr,alParam)

Local alRet     := {}
Local cArqInd   := ""
Local cChaveInd := ""
Local cQuery	:= ""
Local nlK       := 0
Local nIndice	:= 0

Pergunte("MTA140I",.f.)
dbSelectArea("SDS")
dbSetOrder(1)

cArqInd   := CriaTrab(, .F.)
cChaveInd := IndexKey()
cQuery := 'DS_FILIAL >="'+xFilial("SDS")+'" .And.'
cQuery += 'DS_DOC    >="'+mv_par01+'".And.DS_DOC   <="'+mv_par02+'".And.'
cQuery += 'DS_SERIE  >="'+mv_par03+'".And.DS_SERIE <="'+mv_par04+'"'

IndRegua("SDS", cArqInd, cChaveInd, , cQuery,"Criando indice de trabalho" ) //"Criando indice de trabalho"

nIndice := RetIndex("SDS") + 1
#IFNDEF TOP
	dbSetIndex(cArqInd + OrdBagExt())
#ENDIF
dbSetOrder(nIndice)
SDS->(MsSeek(xFilial("SDS")))

While SDS->(!EOF())
	AADD(alRet,Array(Len(alHdr)))
	For nlk:=1 to Len(alHdr)
		If alHdr[nlk,4]=="V"
			alRet[Len(alRet),nlk]:=CriaVar(alHdr[nlk,2])
		Else
			alRet[Len(alRet),nlk]:=FieldGet(FieldPos(alHdr[nlk,2]))
		EndIf
	Next nlk
	SDS->(dbSKip())
End

SDS->(DbClearFil())
RetIndex("SDS")
Return alRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MontaBrw   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Monta o Browse principal que exibi os schemas importados         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clRaiz = Diretorio/Local arquivos raiz                           ³±±
±±³          | clDest = Diretorio/Local arquivos lidos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ A140XMLNFe	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function MontaBrw()
       Local alSize      := MsAdvSize()
       Local alHdCps     := {}
       Local alHdSize    := {}
       Local alCpos      := {}
       Local alItBx      := {}
       Local alParam     := {}
       Local alCpHd      := MontHdr()
       Local clLine      := ""
       Local clLegenda   := ""
       Local clFilBrw    := ""
       Local cTCFilterEX := "TCFilterEX"
       Local nlTl1       := alSize[1]
       Local nlTl2       := alSize[2]
       Local nlTl3       := alSize[1]+450
       Local nlTl4       := alSize[2]+790
       Local nlCont      := 0
       Local nlPosCFor   := 0
       Local nlPosLoja   := 0
       Local nlPosNum    := 0
       Local nlPosSer    := 0
       Local nlPosCHNF   := 0
       Local olLBox      := NIL
       Local olBtLeg     := NIL
       Local olBtFiltro  := NIL
       Local olBtImpM    := NIL

       Private _opDlgPcp := NIL
       Private opBtVis   := NIL
       Private opBtImp   := NIL
       Private opBtPed   := NIL
       Private cIdEnt
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Array alParam recebe parametros para filtro           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       aAdd(alParam,{1 , " " }) // 1 - Liberado para pre-nota
       aAdd(alParam,{2 , "P" }) // 2 - Processada pelo Protheus

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta o Header com os titulos do TWBrowse             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       //LGS#20200128 - Adequação para release 12.1.25
       /*dbSelectArea("SX3")
       dbSetOrder(2)
       For nlCont	:= 1 to Len(alCpHd)
           If MsSeek(alCpHd[nlCont])
              If alCpHd[nlCont] == "DS_STATUS"
                 AADD(alHdCps," ")
                 AADD(alHdSize,1)
              Else
                 AADD(alHdCps,AllTrim(( _cAliasSX3 )->( X3_TITULO )))
                 AADD(alHdSize,Iif(nlCont==1,200,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,( _cAliasSX3 )->( X3_TITULO ))))
              EndIf
              AADD(alCpos,{AllTrim(( _cAliasSX3 )->( X3_TITULO )),SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
           EndIf
       Next*/       

       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( DbSetOrder(2) )
       For nlCont	:= 1 to Len(alCpHd)
           If MsSeek( alCpHd[ nlCont ] )
              If alCpHd[ nlCont ] == "DS_STATUS"
                 AADD( alHdCps , " ")
                 AADD( alHdSize, 1 )
              Else
                 AADD( alHdCps , AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ) )
                 AADD( alHdSize, Iif( nlCont == 1, 200, CalcFieldSize( ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_TAMANHO ), ( _cAliasSX3 )->( X3_DECIMAL ), ( _cAliasSX3 )->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TITULO ) ) ) )
              EndIf
              AADD( alCpos, { AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ), ( _cAliasSX3 )->( X3_CAMPO ), ( _cAliasSX3 )->( X3_TIPO ), ( _cAliasSX3 )->( X3_CONTEXT ), ( _cAliasSX3 )->( X3_PICTURE ) } )
           EndIf
       Next
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Verifica as posicoes/ordens dos campos no array       ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       nlPosCFor := Ascan( alCpos, { |x| Alltrim( X[2] ) == "DS_FORNEC"  } )
       nlPosLoja := Ascan( alCpos, { |x| Alltrim( X[2] ) == "DS_LOJA"    } )
       nlPosNum  := Ascan( alCpos, { |x| Alltrim( X[2] ) == "DS_DOC"     } )
       nlPosSer  := Ascan( alCpos, { |x| Alltrim( X[2] ) == "DS_SERIE"   } )
       nlPosCHNF := Ascan( alCpos, { |x| Alltrim( X[2] ) == "DS_CHAVENF" } )

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Colunas da ListBox/TWBrowse                                				³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       clLine := "{|| {SelCor(alItBx[olLBox:nAt,1]) ,"
       For nlCont:=2 To Len(alCpos)
           clLine += "alItBx[olLBox:nAt,"+AllTrim(Str(nlCont))+"]"+IIf(nlCont<Len(alCpos),",","")
       Next nX
       clLine += "}}"

       // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       // | Monta Legenda  |
       // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       clLegenda := "BrwLegenda('Nf-e Disponíveis','Legenda' ,{{'BR_VERDE'    ,'Apto a gerar Pré nota'}";
                   +" ,{'BR_VERMELHO' ,'Documento Gerado'}";
                   +" ,{'BR_PRETO' ,'Cancelado Receita'}";
                   +" })"

       cIdEnt := U_WSAT01GetIdEnt()

       DEFINE MSDIALOG _opDlgPcp TITLE "Nf-e Disponíveis" From nlTl1,nlTl2 to nlTl3,nlTl4 PIXEL
              // ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
              // |  BOTOES    |
              // ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ

              // Selec. Pedido
              opBtPed := TButton():New(nlTl1+203,alSize[2]+000,"Selec. Pedido",_opDlgPcp,{|| SelePed(	alItBx[olLBox:nAt,nlPosCFor] ,;		// | Cod. Fornecedor
              alItBx[olLBox:nAt,nlPosLoja] ,;			// | Loja
              alItBx[olLBox:nAt,nlPosNum ] ,;			// | Numero Doc.
              alItBx[olLBox:nAt,nlPosSer])} ;			// | Serie
              ,041,014,,,,.T.  )
              // Visualizar
              opBtVis := TButton():New(nlTl1+203,alSize[2]+045,"Visualizar",_opDlgPcp,{|| (ExecTela(	2,; 								// | Opcao
              alItBx[olLBox:nAt,nlPosCFor],;			// | Cod. Fornec./Cli.
              alItBx[olLBox:nAt,nlPosLoja],;	  		// | Loja
              alItBx[olLBox:nAt,nlPosNum],;	   		// | Num. Nota Fiscal
              alItBx[olLBox:nAt,nlPosSer])   ) };		// | Serie
              ,035,014,,,,.T.  )

              // Gerar Pre Nota
              opBtImp := TButton():New(nlTl1+203,alSize[2]+085,"Gerar Pre Nota",_opDlgPcp,{|| (ExecTela(	3, ;								// | Opcao
              alItBx[olLBox:nAt,nlPosCFor],;     		// | Cod. Fornec./Cli.
              alItBx[olLBox:nAt,nlPosLoja],;   		// | Loja
              alItBx[olLBox:nAt,nlPosNum],;    	   	// | Num. Nota Fiscal
              alItBx[olLBox:nAt,nlPosSer]) ,; 		// | Serie
              (olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)),;
              (olLBox:Refresh()),(olLBox:bGoTop),;
              (Iif(!Empty(olLBox:aArray),AtuBtn(olLBox:aArray[olLBox:nAt,1]),)))};
              ,040,014,,,,.T.  )

              // Legenda
              olBtLeg := TButton():New(nlTl1+203,alSize[2]+130,"Legenda",_opDlgPcp, {|| &clLegenda } ,035,014,,,,.T.  )

              // Filtro
              olBtFiltro := TButton():New(nlTl1+203,alSize[2]+170,"Filtro",_opDlgPcp, {|| FiltraBrw(olLBox,alItBx,clLine,alCpos,alParam, @clFilBrw) } ,035,014,,,,.T.  )

              // Importação manual
              olBtImpM := TButton():New(nlTl1+203,alSize[2]+210,"Imp. Manual",_opDlgPcp, {|| ImpManual(),(olLBox:=AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)) } ,035,014,,,,.T.  )

              @ (nlTl1+203),(alSize[2]+250) 	BUTTON "Cons.NFE" SIZE 41,14 OF _opDlgPcp PIXEL ACTION (ConsNFeChave(alItBx[olLBox:nAt,nlPosCHNF],cIdEnt))

              // Sair / Fechar
              @ (nlTl1+203),(alSize[2]+300) 	BUTTON "Sair" SIZE 41,14 OF _opDlgPcp PIXEL ACTION Eval({|| DbSelectArea("SDS"), &cTCFilterEX.("",1), _opDlgPcp:END()})

              // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              // | TW BROWSE - NOTAS  |
              // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              &cTCFilterEX.("",1)
              //olLBox := TwBrowse():New( nlTl1+10, nlTl2-2, nlTl3-75, nlTl4-620, , alHdCps, alHdSize, _opDlgPcp, , , , , { || Iif( !Empty( olLBox:aArray ), Eval( opBtVis:BACTION ),) }, , , , , , , .F., , .T., , .F., , , )
              olLBox := TwBrowse():New( nlTl1+10, nlTl2-20, nlTl3-70, nlTl4-630, , alHdCps, alHdSize, _opDlgPcp, , , , , { || Iif( !Empty( olLBox:aArray ), Eval( opBtVis:BACTION ),) }, , , , , , , .F., , .T., , .F., , , )
              olLBox := AtuBrw( olLBox, alItBx, clLine, alCpos, alParam )
              olLBox:BChange := Iif( !Empty( olLBox:aArray ), { || AtuBtn( olLBox:aArray[olLBox:nAt, 1 ] ) } , { || olLBox:Refresh() } )
       ACTIVATE DIALOG _opDlgPcp CENTERED
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | ImpManual  ³Autor ³ Paulo Bindo 				   |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Realiza a importacao manual do arquivo selecionado pelo usuario  ³±±
±±³          | utilizando a rotina automatica de importacao da NF-e		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MontaBrw		                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ImpManual()

Local cPathR := cGetFile("*.xml","XML File",1,"C:\",.T.,GETF_LOCALHARD,.T.,.T.)
Local cFile := cPathR

If !Empty(cPathR)
	While At("\",cFile) > 0
		cFile := Substr(cFile,At("\",cFile)+1)
	End
	
	If !":\" $ cPathR //-- Arquivo do servidor
		Copy File &(cPathR) TO &(cStartPath +cFile)
	Else //-- Arquivo do client
		CpyT2S(cPathR,cStartPath)
	EndIf
	
	//-- Chama funcao de import
	MsAguarde({|| U_ReadXML(cFile,.F.)},"Aguarde","Importando dados do arquivo XML...",.F.)
	
EndIf

Return( Nil )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | FiltraBrw  ³Autor ³Paulo Bindo                  |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Atualiza botoes na mudanca de registro. Se o status for          ³±±
±±³          | P = Processada Desabilita os botoes de Selecionar Pedido, 		³±±
±±³			 | Ver. Schema e Importar.											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clStatus = Status do registro selecioado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MontaBrw	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function FiltraBrw(olLBox,alItBx,clLine,alCpos,alParam,clFilBrw )
Local cTCFilterEX 	:= "TCFilterEX"
Local aArea			:= GetArea()
clFilBrw := BuildExpr("SDS",,clFilBrw)

DbSelectArea("SDS")
&cTCFilterEX.(clFilBrw,1)

AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)

RestArea(aArea)
Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | AtuBtn     ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Atualiza botoes na mudanca de registro. Se o status for          ³±±
±±³          | P = Processada Desabilita os botoes de Selecionar Pedido, 		³±±
±±³			 | Ver. Schema e Importar.											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clStatus = Status do registro selecioado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MontaBrw	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtuBtn(clStatus)
       If (clStatus$"P")
          opBtPed:Disable()
          opBtImp:Disable()
       Else
          opBtPed:Enable()
          opBtImp:Enable()
       EndIf
Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | AtuBrw     ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Atualiza a tela apos gerar pre nota                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ olLBox  = Objeto do TwBrowse (ListBOx)                           ³±±
±±³          | alItBx  = Array contendo os itens do ListBox                     ³±±
±±³          | clLine  = String do BLoco de Codigo bLine                        ³±±
±±³          | alCpos  = Campos exibidos no ListBox                             ³±±
±±³          | alParam = Array com informacoes do filtro                        ³±±
±±³          |           [ 1 ] - Parametro escolhido                            ³±±
±±³          |           [ 2 ] - String para sua representacao Exemplo: "T"     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ olLBox = ListBox atualizado                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FiltraBrw, MontaBrw                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtuBrw(olLBox,alItBx,clLine,alCpos,alParam)
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Carrega o array com as informacoes dos registros      ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       alItBx:=CarItens(alCpos, alParam)
       olLBox:SetArray(alItBx)
       olLBox:bLine := Iif(!Empty(alItBx),&clLine, {|| Array(Len(alCpos))} )
       If EmpTy(olLBox:aArray)
          opBtPed:Disable()
          opBtVis:Disable()
          opBtImp:Disable()
       EndIf
Return olLBox

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | SelePed    ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Monta tela para selecao do pedido de compra                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  = Cod. Fornec./Cli.                                    ³±±
±±³          | clLoja    = Loja                                                 ³±±
±±³          | clNota    = Num. Nota                                            ³±±
±±³          | clSerie   = Serie da Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MontaBrw	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function SelePed(clCodFor,clLoja,clNota,clSerie)
       Local nlCont      := 0
       Local clDescProd  := ""
       Local clTipo      := ""
       Local alNome      := {}
       Local alRetRef    := {}
       Local olBtSch     := NIL
       Local olBDsfz     := NIL
       Local olFont      := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
       Local alSize    	 := MsAdvSize()
       Local nlTl1     	 := alSize[1]
       Local nlTl2       := alSize[2]
       Local nlTl3       := alSize[1]+300
       Local nlTl4     	 := alSize[2]+520
       Local alItens     := {}
       Local alCabec     := {"DT_ITEM","DT_COD","DT_PRODFOR","B1_DESC"}
       Local alHdIt      := {}
       Local alTamHd     := {}
       Private _opBoxIt  := NIL
       Private _opSPeDlg := NIL

       //LGS#20200128 - Adequação para release 12.1.25
       /*dbSelectArea("SX3")
       SX3->(dbSetOrder(2))
       For nlCont	:= 1 to Len(alCabec)
           If MsSeek(alCabec[nlCont])
              AADD(alHdIt,AllTrim(( _cAliasSX3 )->( X3_TITULO )))
              AADD(alTamHd,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,( _cAliasSX3 )->( X3_TITULO )) )
           EndIf
       Next*/
       dbSelectArea( _cAliasSX3 )
       (_cAliasSX3)->( dbSetOrder( 2 ) )
       For nlCont	:= 1 to Len( alCabec )
           If MsSeek( alCabec[nlCont] )
              AADD( alHdIt, AllTrim( ( _cAliasSX3 )->( X3_TITULO ) ) )
              AADD( alTamHd, CalcFieldSize( (_cAliasSX3)->( X3_TIPO ), (_cAliasSX3)->( X3_TAMANHO ), (_cAliasSX3)->( X3_DECIMAL ), (_cAliasSX3)->( X3_PICTURE ), ( _cAliasSX3 )->( X3_TITULO ) ) )
           EndIf
       Next
       // ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       // | POSICIONA PARA BUSCAR NOME DO FORNECEDOR/CLIENTE |
       // ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea("SDS")
       SDS->(dbSetOrder(1))
       SDS->(dbSeek(xFilial("SDS")+clNota+clSerie+clCodFor+clLoja))
       If SDS->DS_TIPO == 'N'
          dbSelectArea("SA2")
          dbSetOrder(1)
          aAdd(alNome,{"SA2","A2_NOME","Fornecedor"})
          clTipo:="F"
       Else
          Aviso("Atenção","Tipo de Nota Fiscal não permitida",{"Ok"})
          Return
       EndIf
       &(alNome[1,1])->(dbGoTop())

DEFINE MSDIALOG _opSPeDlg TITLE "Selecionar Pedido" From nlTl1,nlTl2 to nlTl3,nlTl4 PIXEL

// Box
@(nlTl1+10),nlTl2 to (nlTl1+35),(nlTl2+237) PIXEL OF _opSPeDlg
@(nlTl1+14),(nlTl2+005) Say "Nota Fiscal:"+clNota Font olFont Pixel Of _opSPeDlg
@(nlTl1+14),(nlTl2+180) Say "Serie :"+clSerie Font olFont Pixel Of _opSPeDlg
@(nlTl1+23),(nlTl2+005) Say alNome[1,3]+clCodFor+" - "+ Posicione(alNome[1,1],1,(xFilial(alNome[1,1])+clCodFor+clLoja),alNome[1,2])      Font olFont Pixel Of _opSPeDlg

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | CARREGA OS ITENS |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SDT")
SDT->(dbSetOrder(2))
If SDT->(dbSeek(xFilial("SDT")+PadR(clCodFor,TamSx3("DT_FORNEC")[1])+PadR(clLoja,TamSx3("DT_LOJA")[1])+PadR(clNota,TamSx3("DT_DOC")[1])+PadR(clSerie,TamSx3("DT_SERIE")[1]) ))
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	While SDT->(!EOF()) .AND. (SDT->DT_FORNEC==clCodFor) .AND. (SDT->DT_LOJA==clLoja) .AND. (SDT->DT_DOC==clNota) .AND. (SDT->DT_SERIE==clSerie)
		clDescProd:= Iif(!Empty(SDT->DT_COD),Posicione("SB1",1,(xFilial("SB1")+PadR(SDT->DT_COD,TamSX3("B1_COD")[1])),"B1_DESC"),SDT->DT_DESCFOR)
		aAdd(alItens,{SDT->DT_ITEM , SDT->DT_COD, SDT->DT_PRODFOR ,clDescProd })
		clDescProd:=""
		SDT->(dbSkip())
	EndDo
EndIf

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | TW BROWSE - ITENS DA NOTA |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 //larg   //alt
_opBoxIt := TwBrowse():New(nlTl1+40,nlTl2,nlTl4-295,nlTl3-217,,alHdIt,alTamHd,_opSPeDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
_opBoxIt:SetArray(alItens)
_opBoxIt:bLine := {|| {alItens[_opBoxIt:nAt,1],alItens[_opBoxIt:nAt,2],alItens[_opBoxIt:nAt,3], alItens[_opBoxIt:nAt,4]} }

// ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  BOTOES    |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
olBtSch  := TButton():New(nlTl1+132,nlTl2,"Selecionar Pedidos",_opSPeDlg,{||  MsgRun("Aguarde","Selecionando Registros..." ,{|| ProcPCxNFe(clCodFor,clLoja,clNota,clSerie,alItens,alItens[_opBoxIt:nrowpos,1], SDS->DS_TIPO) })    } ,055,012,,,,.T.  )

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | Botao: "Desfazer amarracao do produto" ; Permite ao usuario refazer a amarracao Prod. X Prod. Fornec.    |
// | Caso usuario escolha "SIM" na pergunta de confirmacao, sao executados os 4 passoas descritos abaixo      |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
olBDsfz  := TButton():New(nlTl1+132,nlTl2+065,"Desfazer amarracao do produto",_opSPeDlg, {|| Iif(Aviso("Deseja desfazer a amarraÇâo Prod x Prod.Fornec.?",("Ao clicar em <SIM> "+CRLF+"a selecçãodo pedido será excluída"),{"Sim","Nâo"})==1   											,;  // Condicao
( ( DelSDV((clCodFor+clLoja+clNota+clSerie),alItens[_opBoxIt:nrowpos,2])  						) 	,;  // -----------| - Deleta registros tabela amarracao pedido de compra - SDV
( GPrdxPrdF(clCodFor,clLoja,clNota,clSerie,alItens[_opBoxIt:nrowpos,3],"",SDS->DS_TIPO) 		)	,;  //    Opcao   | - Altera / Limpa campo DT_COD
( alRetRef:=RPrdxPrdF(clCodFor,clLoja,clNota,clSerie,alItens[_opBoxIt:nrowpos,3],,SDS->DS_TIPO) ) 	,;  //     SIM    | - Atualiza SDT com nova amarracao do usuario
( (alItens[_opBoxIt:nrowpos,2]:=alRetRef[1]),(alItens[_opBoxIt:nrowpos,4]:=alRetRef[2]) 		)  ),;  // -----------| - Atualiza browse
(	/* Opcao caso usuario escolha NAO. Nada faz / Nao usado */  									)  )}; 	// Opcao NAO
,095,012,,,,.T.  )

DEFINE SBUTTON FROM nlTl1+134,nlTl2+212 TYPE 1 ACTION(_opSPeDlg:End()) ENABLE Of _opSPeDlg
_opSPeDlg:Activate(,,,.T.,,,)

SDT->(dbCloseArea())
SB1->(dbCloseArea())
&(alNome[1,1])->(dbCloseArea())
Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | DelSDV     ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Deleta os registros na tabela de relação de pedidos quando o     ³±±
±±³          | amarracao do produto e' desfeita                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clChave  = Forn.+Loja+Nota+Serie.                                ³±±
±±³          ³ clProd   = Codigo do produto                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SelePed                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function DelSDV(clChave,clProd)

Local alArea := GetArea()

dbSelectArea("SDV")
SDV->(dbSetOrder(1))
SDV->(dbGoTop())
If SDV->(dbSeek(xFilial("SDV")+clChave))
	While SDV->(!EOF()) .AND. (clChave==(SDV->DV_FORNEC+SDV->DV_LOJA+SDV->DV_DOC+SDV->DV_SERIE))
		If (clProd==SDV->DV_PROD)
			If  RecLock("SDV",.F.)
				SDV->(DbDelete())
				MsUnlock("SDV")
			EndIf
		EndIf
		SDV->(dbSkip())
	EndDo
EndIf
SDV->(dbCloseArea())

RestArea(alArea)

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | RPrdxPrdF  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Refaz a amarracao de produto X prod. fornecedor                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  = Cod. Fornec./Cli.                                    ³±±
±±³          | clLoja    = Loja                                                 ³±±
±±³          | clNota    = Num. Nota                                            ³±±
±±³          | clSerie   = Serie da Nota                                        ³±±
±±³          | clProdFor = cod. produto identificacao do fornecedor / cliente   ³±±
±±³          | clPar     = NIL                                                  ³±±
±±³          | cTipo     = Tipo da nota - Entrada ou devolucao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet  = [1] - Cod. produto  / [2] - Descricao do produto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SelePed                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function RPrdxPrdF(clCodFor,clLoja,clNota,clSerie,clProdFor,clPar,cTipo)

Local llRetCons := .F.
Local alRet     := {"",""}
Local alArea    := GetArea()

If (llRetCons:=ConPad1(,,,"SB1",,,.F.)) // Consulta Padrao
	alRet[1] := SB1->B1_COD
	alRet[2] := SB1->B1_DESC
	GPrdxPrdF(clCodFor,clLoja,clNota,clSerie,clProdFor,SB1->B1_COD,cTipo)
Else
	alRet[2] := Posicione("SDT",2,(xFilial("SDT")+clCodFor+clLoja+clNota+clSerie+clProdFor),"DT_DESCFOR")
EndIf

RestArea(alArea)

Return alRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | ProcPCxNFe ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao procura possiveis pedidos de compra relacionados a NF     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  = Cod. Fornec./Cli.                                    ³±±
±±³          | clLoja    = Loja                                                 ³±±
±±³          | clNota    = Num. Nota                                            ³±±
±±³          | clSerie   = Serie da Nota                                        ³±±
±±³          | alItens   = array contendo os itens da nota fiscal               ³±±
±±³          | clItem    = Item selecionado                                     ³±±
±±³          | cTipo     = Tipo da nota - Entrada ou devolucao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alItens  = array com os itens atualizados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SelePed	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ProcPCxNFe(clCodFor,clLoja,clNota,clSerie,alItens,clItem,cTipo)

Local nlPos   	:= Ascan(alItens,{|x|X[1]==clItem})
Local alItem1 	:= {}
Local llretCons := .F.
//Local nlVarVal  := 0.01 // Variacao de valores para busca do pedido
Local clArqSQL  := GetNextAlias()
Local clQuery 	:= ""
Local cCodProdEmp := ""
Local lEmpGrupo  := .F. // Empresa do Grupo .T. = Sim / .F. = Não

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | VERIFICA SE O FORNECEDOR FAZ PARTE DO CADASTRO DE EMPRESAS NO SIGAMAT    |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA2->(DbSetOrder(1))
If SA2->(DbSeek(xFilial("SA2")+clCodFor+clLoja))
	If Len(PesqCGC(SA2->A2_CGC))!=0
		lEmpGrupo := .T.
	EndIf
EndIf

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | CASO NAO TENHA O COD. DO PRODUTO PREENCHIDO, POSSIBILITA QUE O USUARIO   |
// | DEFINA QUAL O PRODUTO CORRESPONDENTE AO COD. PROD. DO FORNECEDOR         |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SDT")
If SDT->(dbSeek(xFilial("SDT")+clCodFor+clLoja+clNota+clSerie))
	While SDT->(!EOF()) .AND. (SDT->DT_FORNEC==clCodFor)
		If AllTrim(SDT->DT_PRODFOR) == AllTrim(alItens[nlPos,3])
			If lEmpGrupo // Se for Empresa do Grupo utiliza proprio codigo XML
				cCodProdEmp := SDT->DT_PRODFOR
			Else
				cCodProdEmp := SDT->DT_COD
			EndIf
			If Empty(cCodProdEmp)
				// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				// | PROCURA RELACIONAMENTO DO PRODUTO NA TABELA SA5/SA7|
				// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCodProdEmp := PrdxForCli(clCodFor, clLoja, SDT->DT_PRODFOR, cTipo)
				If Empty(cCodProdEmp)
					If MsgYesNo("O produto da Nota está sem amarração no sistema, código "+Space(1)+AllTrim(SDT->DT_PRODFOR)+"."+CRLF+"Deseja selecionar um produto?"  )
						If (llRetCons:=ConPad1(,,,"SB1",,,.F.))
							cCodProdEmp := SB1->B1_COD
							GPrdxPrdF(clCodFor, clLoja, clNota, clSerie, SDT->DT_PRODFOR, cCodProdEmp, cTipo)
							
							_opBoxIt:aArray[_opBoxIt:nrowpos,2] := cCodProdEmp
							_opBoxIt:aArray[_opBoxIt:nrowpos,4] := SB1->B1_DESC
						EndIf
					EndIf
				Else
					GPrdxPrdF(clCodFor, clLoja, clNota, clSerie, SDT->DT_PRODFOR, cCodProdEmp, cTipo)
					
					_opBoxIt:aArray[_opBoxIt:nrowpos,2] := cCodProdEmp
					_opBoxIt:aArray[_opBoxIt:nrowpos,4] := SB1->B1_DESC
				EndIf
			EndIf
			
			// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// | CARREGA ARRAY QUE CONTERA AS INFORMACOES PARA A QUERY |
			// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(alItem1,SDT->DT_COD)       // COD. PRODUTO
			aAdd(alItem1,SDT->DT_PRODFOR)   // COD. PROD. FORNECEDOR
			aAdd(alItem1,SDT->DT_QUANT)     // QUANT. ITEM NA NF
			aAdd(alItem1,SDT->DT_VUNIT)     // VALOR UNITARIO
			Exit
		EndIf
		SDT->(dbSkip())
	EndDo
EndIf

If !Empty(cCodProdEmp)
	#IFDEF TOP
		
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// |  MONTA QUERY   |
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Where / Condicao
		clWhere:=""
		clWhere+=" WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
		If ( TcSrvType()=="AS/400" )
			clWhere+=" AND SC7.@DELETED@  <> '*'
		Else
			clWhere+=" AND SC7.D_E_L_E_T_ <> '*'
		EndIf
		clWhere+=" AND C7_FORNECE = '" + clCodFor + "' "
		clWhere+=" AND C7_LOJA = '" + clLoja + "' "
		//		clWhere+=" AND C7_PRECO BETWEEN '" + AllTrim(Str(alItem1[4]-nlVarVal)) + "' AND '" + AllTrim(Str(alItem1[4]+nlVarVal)) + "' "
		clWhere+=" AND C7_PRODUTO = '" + alItem1[1] + "' "
		clWhere+=" AND C7_QTDACLA < C7_QUANT "
		clWhere+=" AND C7_ENCER = ' '  "
		clWhere+=" AND C7_QUJE < C7_QUANT "
		
		// Query
		clQuery:=""
		clQuery+=" SELECT "
		clQuery+=" ( "
		clQuery+="	 SELECT COUNT(*) "
		clQuery+="	 FROM " + RetSqlName("SC7") + " SC7 "
		clQuery+=clWhere
		clQuery+=" ) "
		clQuery+=" AS CONT "
		clQuery+="  , C7_NUM "
		clQuery+=" 	, C7_ITEM "
		clQuery+=" 	, C7_QUANT "
		clQuery+=" 	, C7_PRECO "
		clQuery+=" 	, C7_TOTAL "
		clQuery+=" 	, C7_QTDACLA "
		clQuery+=" 	, C7_EMISSAO "
		clQuery+=" FROM " + RetSqlName("SC7") + " SC7 "
		clQuery+=clWhere
		dbUseArea(.T., "TOPCONN", TCGenQry(,,clQuery),clArqSQL, .T., .T.)
		
		dbSelectArea(clArqSQL)
		&(clArqSQL)->(dbGoTop())
		
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// |  VERIFICA SE ECONTROU PEDIDOS    |
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If &(clArqSQL)->(!EOF()) // -> ENCONTROU PEDIDOS
			MarkBrwPC(clArqSQL,alItem1,clCodFor,clLoja,clNota,clSerie)
		Else
			Aviso("Atenção",("Item não encontrado "+STRZero(Val(clItem),TamSX3("DT_ITEM")[1])+" na Nota "+clNota),{"Ok"})
		EndIf
		&(clArqSQL)->(dbCloseArea())
	#ENDIF
EndIf
Return alItens

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MarkBrwPC  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao responsavel por criat MsSelect/MarkBrowse para que o      ³±±
±±³          | usuario escolha os pedidos de compra referentes aos itens na NF  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clArqSQL  = String com o nome da Tabela SQL                      ³±±
±±³          | alItem1   = Dados do item da nota fiscal                         ³±±
±±³          |          [1] - Cod. Produto                                      ³±±
±±³          |          [2] - Cod. Produto FOrnecedor                           ³±±
±±³          |          [3] - Quant. do item na Nf                              ³±±
±±³          |          [4] - Valor unitario                                    ³±±
±±³          | clCodFor  = Cod. Fornec./Cli.                                    ³±±
±±³          | clLoja    = Loja                                                 ³±±
±±³          | clNota    = Num. Nota                                            ³±±
±±³          | clSerie   = Serie da Nota                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ProcPCxNFe                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function MarkBrwPC(clArqSQL,alItem1,clCodFor,clLoja,clNota,clSerie)
Local clQZ4         := 0
Local olFont        := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
Local alSize    	:= MsAdvSize()
Local nlTl1     	:= alSize[1]
Local nlTl2    		:= alSize[2]
Local nlTl3    		:= alSize[1]+300
Local nlTl4     	:= alSize[2]+520
Local clPed         := ""
Local clItmPC       := ""
Local alEstru       := {}
Local llInvert      := .F.
Local alCampos      := {}
//Local clTabTmp      := ""
Local clTMPMark     := ""
Local clTMPQtd      := 0
Local alTamSDV      := {TAMSX3("DV_FORNEC")[1],TAMSX3("DV_LOJA")[1],TAMSX3("DV_DOC")[1],TAMSX3("DV_SERIE")[1],TAMSX3("DV_PROD")[1],TAMSX3("DV_NUMPED")[1],TAMSX3("DV_ITEMPC")[1]}
Local olSayQtd      := NIL
Local olMsSel01     := NIL
Local clMarca       := GetMark() // Essa variável não pode ter outro conteudo
Private opDlgMPed   := NIL

// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
Private INCLUI      := .F.
Private ALTERA      := .F.
Private nTipoPed    := 1
Private cCadastro   := "Seleção dos Pedidos de Compra"
Private l120Auto    := .F.
Private oTempTbl01

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  VERIFICA SE ALGUMA NOTA JA PREENCHE QUANTIDADE DESSE PRODUTO  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbselectArea("SDV")
SDV->(dbSetOrder(1))
SDV->(dbGoTop())

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  ESTRUTURA PARA TABELA TEMPORARIA  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
alEstru := {}
aadd(alEstru,{"MMARK",     "C",  LEn(clMarca),           0                     })
aadd(alEstru,{"PED ",      "C",  TamSx3("C7_NUM")[1],    0                     })
aadd(alEstru,{"ITEM",      "C",  TamSx3("C7_ITEM")[1],   0                     })
aadd(alEstru,{"DDATA",     "D",  8                   ,   0                     })
aadd(alEstru,{"QTDDISP" ,  "N",  TamSx3("C7_QUANT")[1],  TamSx3("C7_QUANT")[2] })
aadd(alEstru,{"QTDREF" ,   "N",  TamSx3("C7_QUANT")[1],  TamSx3("C7_QUANT")[2] })

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  CAMPOS PARA MSSELECT  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
alCampos := {}
aAdd(alCampos,{"MMARK"    , , ""   	       ,""                      	})
aAdd(alCampos,{"PED"      , , "Pedido"      ,PesqPict("SC7","C7_NUM")  	})
aAdd(alCampos,{"ITEM"     , , "Item"      ,PesqPict("SC7","C7_ITEM")   })
aAdd(alCampos,{"DDATA"    , , "Data"      ,                            })
aAdd(alCampos,{"QTDDISP"  , , "Qtd.Disp." ,PesqPict("SC7","C7_QUANT")  })
aAdd(alCampos,{"QTDREF"   , , "Qtd.Infor" ,PesqPict("SC7","C7_QUANT")  })

// Cria e seleciona a tabela temporária
/********************************************************************************************************************************/
/*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
//clTabTmp := CriaTrab(alEstru,.T.)
//dbUseArea(.T.,,clTabTmp,"TMP",.F.,.F.)
//dbSelectArea("TMP") 

oTempTbl01 := FWTemporaryTable():New( "TMP" )
oTempTbl01:SetFields( alEstru )
oTempTbl01:Create()
/********************************************************************************************************************************/

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  TRANSFERE OS DADOS PARA A TABELA TEMPORARIA  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(clArqSql)
&(clArqSql+"->(dbGoTop())")
While &(clArqSql+"->(!EOF())")
	clPed 			:= &(clArqSql+"->C7_NUM")
	clItmPc 		:= &(clArqSql+"->C7_ITEM")
	clTMPMark       := ""
	clTMPQtd        := 0
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// |  VERIFICA REGISTRO NA TABELA SDV E TRAZ PREENCHIDA CASO ENCONTRE  |
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbselectArea("SDV")
	SDV->(dbSetOrder(1))
	SDV->(dbGoTop())
	If SDV->(dbSeek(xFilial("SDV")+PadR(clCodFor,alTamSDV[1])+PadR(clLoja,alTamSDV[2])+PadR(clNota,alTamSDV[3])+PadR(clSerie,alTamSDV[4])+PadR(alItem1[1],alTamSDV[5])+PadR(clPed,alTamSDV[6])+PadR(clItmPc,alTamSDV[7])))
		clTMPMark     := clMarca
		clTMPQtd      := SDV->DV_QUANT
	EndIf
	
	dbselectArea("TMP")
	If RecLock("TMP",.T.)
		TMP->PED     	:= clPed
		TMP->ITEM    	:= clItmPc
		TMP->DDATA  	:= StoD(&(clArqSql+"->C7_EMISSAO"))
		TMP->QTDDISP 	:= (&(clArqSql+"->C7_QUANT") - (&(clArqSql+"->C7_QTDACLA")+ clQZ4))
		TMP->MMARK   	:= clTMPMark
		TMP->QTDREF    	:= clTMPQtd
		TMP->(MsUnLock())
	EndIf
	
	dbSelectArea(clArqSql)
	&(clArqSql)->(dbSkip())
EndDo

TMP->(dbGoTop())

DEFINE MSDIALOG opDlgMPed TITLE "Seleção dos Pedidos de Compra" From nlTl1,nlTl2 to nlTl3,nlTl4 PIXEL

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  CABECALHO DA TELA  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@(nlTl1+10),nlTl2 to (nlTl1+35),(nlTl2+237) PIXEL OF opDlgMPed
@(nlTl1+14),(nlTl2+005) Say AllTrim(alItem1[2]) + " / " + AllTrim(alItem1[1]) + " - " + Posicione("SB1",1,(xFilial("SB1")+PadR(alItem1[1],TamSX3("B1_COD")[1])),"B1_DESC")   Font olFont Pixel Of opDlgMPed
@(nlTl1+23),(nlTl2+005) Say "Item "   + AllTrim(STR(alItem1[3]))      Font olFont Pixel Of opDlgMPed

olSayQtd := tSay():New((nlTl1+23),(nlTl2+130),{|| "Qtd.Nota Fiscal " + AllTrim(STR(DigQtdeIt(0,alItem1[3],"C")[1])) },opDlgMPed,,olFont,,,,.T.,,,100,20)

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  MARKBROWSE / MSSELECT |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
olMsSel01 :=  MsSelect():New('TMP','MMARK',"",alCampos,@llInvert,@clMarca,{(nlTl1+40),(nlTl2),(nlTl3-175),(nlTl4-283)},,opDlgMPed)
olMsSel01:oBrowse:lColDrag    := .T.
olMsSel01:bMark := {|| (MarcaReg(clMarca,alItem1[3]), olMsSel01:oBrowse:Refresh(), opDlgMPed:Refresh(), olSayQtd:cCaption:= "Qtd. Sem Pedido de Compra" + AllTrim(STR(DigQtdeIt(0,alItem1[3],"C")[1])) )  }


// ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  BOTOES    |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
obTVisPe := TButton():New(nlTl1+132,nlTl2,"Visualizar Pedido",opDlgMPed,{|| MsgRun("Pedido "+Space(1)+TMP->PED+"Sendo Localizado","Aguarde...", {|| A120Pedido("SC7",PosSC7( TMP->PED ),2) })   } ,055,012,,,,.T.  )
DEFINE SBUTTON FROM nlTl1+134,nlTl2+178 TYPE 1 ACTION(eVal( {|| (MarkBrwOk(clCodFor,clLoja,clNota,clSerie,alItem1[1],alTamSDV) , opDlgMPed:End())  } )) ENABLE Of opDlgMPed
DEFINE SBUTTON FROM nlTl1+134,nlTl2+212 TYPE 2 ACTION(opDlgMPed:End()) ENABLE Of opDlgMPed

ACTIVATE DIALOG opDlgMPed CENTERED

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | FECHA E DELETA ARQ. TAB. TEMP.     |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMP->(dbCloseArea())
oTempTbl01:Delete()
//If File( AllTrim(clTabTmp)+GetDBExtension())
//	Ferase(AllTrim(clTabTmp)+GetDBExtension())
//EndIf
Return Nil


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MarkBrwOk  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Executada no botao "OK" do MarkBrowse de selecao de ped. Comp.   ³±±
±±³          | deleta e/ou grava os registros na tabelza PED. COMP. X NFE (SDV) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor   = Cod. Fornec./Cli.                                   ³±±
±±³          | clLoja     = Loja                                                ³±±
±±³          | clNota     = Num. Nota                                           ³±±
±±³          | clSerie    = Serie da Nota                                       ³±±
±±³          | clCodProd  = Codigo do produto                                   ³±±
±±³          | alTamSDV   = Array com os tamanhos dos campos usados no dbSeek   ³±±
±±³          |              [1] - Tam. Campo DV_FORNEC                          ³±±
±±³          |              [2] - Tam. Campo DV_LOJA                            ³±±
±±³          |              [3] - Tam. Campo DV_DOC                             ³±±
±±³          |              [4] - Tam. Campo DV_SERIE                           ³±±
±±³          |              [5] - Tam. Campo DV_PROD                            ³±±
±±³          |              [6] - Tam. Campo DV_NUMPED                          ³±±
±±³          |              [7] - Tam. Campo DV_ITEMPC                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MarkBrwPC	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function MarkBrwOk(clCodFor,clLoja,clNota,clSerie,clCodProd,alTamSDV)

Local clNumPed := ""
Local clItemPc := ""

dbSelectArea("SDV")
SDV->(dbSetOrder(1))

TMP->(dbGoTop())
While TMP->(!EOF())
	
	SDV->(dbGoTop())
	clNumPed  := PadR(TMP->PED,TamSX3("C7_NUM")[1])
	clItemPC  := PadR(TMP->ITEM,TamSX3("C7_ITEM")[1])
	dbSelectArea("SDV")
	SDV->(dbSetOrder(1))
	
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// | EXCLUI O REGISTRO DA TABELA   |
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dbSeek(xFilial("SDV")+PadR(clCodFor,alTamSDV[1])+PadR(clLoja,alTamSDV[2])+PadR(clNota,alTamSDV[3])+PadR(clSerie,alTamSDV[4])+PadR(clCodProd,alTamSDV[5])+PadR(clNumPed,alTamSDV[6])+PadR(clItemPC,alTamSDV[7]))
		If RecLock("SDV",.F.)
			SDV->(DbDelete())
			SDV->(MsUnlock())
		EndIf
	EndIf
	
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// | GRAVA NA SDV SE ESTIVER MARCADO  |
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(TMP->MMARK)
		Begin Transaction
		If RecLock("SDV",.T.)
			SDV->DV_FILIAL     	:= xFilial("SDV")
			SDV->DV_DOC        	:= clNota
			SDV->DV_SERIE      	:= clSerie
			SDV->DV_FORNEC      := clCodFor
			SDV->DV_LOJA   	    := clLoja
			SDV->DV_PROD  	    := clCodProd
			SDV->DV_NUMPED     	:= TMP->PED
			SDV->DV_ITEMPC		:= TMP->ITEM
			SDV->DV_QUANT		:= TMP->QTDREF
			dbCommit()
			SDV->(MsUnlock())
		EndIf
		End Transaction
	EndIf
	dbSelectArea("TMP")
	TMP->(dbSkip())
EndDo

SDV->(dbCloseArea())

Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MarcaReg	  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Executada quando o registro e marcado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clMarca   = String retornada do GETMark()                        ³±±
±±³          | nlQtdTot  = Qtd. total / maxima permitida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MarkBrwPC                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function MarcaReg(clMarca,nlQtdTot)

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | PREENCHE COM VALOR DIGITADO PELO USUARIO  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If RecLock("TMP",.F.)
	REPLACE TMP->QTDREF with DigValIt(TMP->QTDREF,TMP->QTDDISP,nlQtdTot)
	MsUnLock()
EndIf

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | VERIFICA SE O VALOR E ZERO. SE SIM DESMARCA REGISTRO  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(TMP->QTDREF)
	If RecLock("TMP",.F.)
		REPLACE TMP->MMARK with ""
		MsUnLock()
	EndIF
Else
	If RecLock("TMP",.F.)
		REPLACE TMP->MMARK with clMarca
		MsUnLock()
	EndIF
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |DigValIt	  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao cria telinha para que o usuario digite numa get o valor   ³±±
±±³          | (unidades) do item da nota fiscal correspondente ao pedido selec.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlValGet   = quantidade ja preenchido                            ³±±
±±³          | nlValDisp  = quantidade maxima disponivel                        ³±±
±±³          | nlQtdTot   = quantidade total                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Se variavel llOk == .T., retorna valor digitado 'nlValGet'       ³±±
±±³          | senao retorna  nlValAnt = valor anterior                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MarcaReg		                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function DigValIt(nlValGet,nlValDisp,nlQtdTot)

Local nlValAnt  	:= nlValGet
Local alSize   		:= MsAdvSize()
Local llOk     		:= .F.
Local olGetVal  	:= Nil
Private _opdlgGet 	:= Nil

DEFINE MSDIALOG _opdlgGet TITLE "Quantidade" From alSize[1],alSize[2] to (alSize[1]+080),(alSize[2]+195) PIXEL

olGetVal :=TGet():New((alSize[1]+10),(alSize[2]+15),{|u| if(PCount()>0,nlValGet:=u,nlValGet)}, _opdlgGet ,50,10,PesqPict("SC7","C7_QUANT") , {|| ValorNFxPC(nlValGet, nlValDisp, nlQtdTot ) },,,,,,.T.,,,,,,,.F.,,,"nlValGet")
DEFINE SBUTTON FROM (alSize[1]+28),(alSize[2]+57) TYPE 1 ACTION(eVal( {|| ( (llOk:=.T.),_opdlgGet:End())  } )) ENABLE Of _opdlgGet

ACTIVATE DIALOG _opdlgGet CENTERED

Return ( Iif(llOk,nlValGet,nlValAnt) )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |ValorNFxPC    ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Valida o valor informado do item da nota fiscal correspondente     ³±±
±±³          | ao pedido selecionado. 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlValGet   = quantidade ja preenchido                              ³±±
±±³          | nlValDisp  = quantidade maxima disponivel                          ³±±
±±³          | nlQtdTot   = quantidade total                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Lógico	 														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DigValIt		                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ValorNFxPC(nlValGet, nlValDisp, nlQtdTot )
Local lRet := .F.

If (nlValGet<=nlValDisp) .AND. (DigQtdeIt(nlValGet,nlQtdTot,"V")[2] ) .And. Positivo(nlValGet)
	lRet := .T.
Else
	Aviso("Atenção","O valor informado do Itema da nota" + CHR(13)+CHR(10) + "não corresponde ao pedido selecionado" ,{"Ok"})
	lRet := .F.
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | DigQtdeIt  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao cria telinha para que o usuario digite numa get o valor   ³±±
±±³          | (unidades) do item da nota fiscal correspondente ao pedido selec.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlValGet   = quantidade ja preenchido                            ³±±
±±³          | nlQtdTot   = quantidade total                                    ³±±
±±³          | clFin      = Finalidade da funcao. Podendo receber "C" ou "V"    ³±±
±±³          | Se recebe "V" (verificar), valida se ainda é possivel selecionar ³±±
±±³          | valores referente ao item da nota. Valida o maximo.              ³±±
±±³          | Se "C" apenas calcula a quant. ja informada ( alRet[1] )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet = array 2 posicoes                                         ³±±
±±³          |         [1] - soma dos valores jah preenchidos para o iten       ³±±
±±³          |         [2] - booleana - Se .F., nao possivel mais indicar valor ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MarkBrwPC, ValorNFxPC                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function DigQtdeIt(nlValGet,nlQtdTot,clFin)

Local alRet 	:= {0,.T.}
Local nlReg 	:= TMP->(Recno())

TMP->(dbGoTop())
While  TMP->(!EOF())
	If (clFin=="V")
		If (TMP->(Recno()) <> nlReg)
			alRet[1]+=TMP->QTDREF
		EndIf
	Else
		alRet[1]+=TMP->QTDREF
	EndIf
	TMP->(dbSkip())
EndDo
TMP->(dbGoTop())

TMP->(dbGoTo(nlReg))
If (clFin=="V")
	If ((alRet[1]+nlValGet) > nlQtdTot)
		alRet[2] := !alRet[2]
	EndIf
Else
	alRet[1] := (nlQtdTot-alRet[1])
EndIf
Return alRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |  PosSC7    ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao para posicionar a Tabela SC7 no pedido escolhido          ³±±
±±³          | retorna o recno que sera passado como parametro na funcao padrao ³±±
±±³          | do sistema A120Pedido()                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clPed = Numero do pedido de compra                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nlRet = SC7->(Recno())                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MarkBrwPC	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function PosSC7(clPed)

Local nlRet := 0

dbSelectArea("SC7")
dbSetOrder(1)
SC7->(dbGoTop())
If dbSeek(xFilial("SC7")+PadR(clPed,TamSx3("C7_NUM")[1]) )
	nlRet := SC7->(Recno())
EndIf
Return nlRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | ExecTela   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao que monta aCols, aHeader para tela e executa rotina aut.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlOpc     := Opcao escolhida (2-Visu / 3-Gerar)                  ³±±
±±³          | clCodFor  := Cod. Fornecedor/Cliente                             ³±±
±±³          | clLoja    := Loja                                                ³±±
±±³          | clNota    := Num. Nota                                           ³±±
±±³          | clSerie   := Serie                                               ³±±
±±³          | olLBox    := Objeto                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MontaBrw	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ExecTela(nlOpc,clCodFor,clLoja,clNota,clSerie,olLBox)
       Local nlUsado       := 0
       Local alDTVirt      := {}
       Local alDTVisu      := {}
       Local alRecDT       := {}
       Local alSF1         := {}
       Local alSD1         := {}
       //Local alSize        := MsAdvSize(.T.)
       Local clKey         := ""
       Local clTab1        := "SDS"
       Local clTab2        := "SDT"
       Local clAwysT       := "AllwaysTrue()"
       Local alCpoEnch     := {}
       Local alHeaderDT    := {}
       Local llPedCom      := .F.
       Local llD1Imp       := .F.
       Private lMsErroAuto := .F.
       Private aCols       := {}
       Private aHeader     := GdMontaHeader( @nlUsado     	 ,; //01 -> Por Referencia contera o numero de campos em Uso
                                             @alDTVirt       ,; //02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
                                             @alDTVisu       ,; //03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
                                             clTab2          ,; //04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
                                             {"DT_FILIAL"}   ,; //05 -> Opcional, Campos que nao Deverao constar no aHeader
                                             .F.             ,; //06 -> Opcional, Carregar Todos os Campos
                                             .F.             ,; //07 -> Nao Carrega os Campos Virtuais
                                             .F.             ,; //08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
                                             NIL             ,; //09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
                                             .T.             ,; //10 -> Verifica se Deve Checar se o campo eh usado
                                             .T.             ,;
                                             .F.             ,;
                                             .F.             ,; 
                                           )

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ POSICIONA A TABELA SDS / CARREGA VARIAVEIS DE MEMORIA   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       dbSelectArea(clTab1)
       dbSetOrder(1)
       &(clTab1+"->(dbGoTop())")
       dbSeek(xFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
       RegToMemory("SDS",.F.)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ CAMPOS USADOS PARA ENCHOICE   ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       //LGS#20200128 - Adequação para release 12.1.25
       /*dbSelectArea("SX3")
       SX3->(dbSetOrder(1))
       SX3->(dbGoTop())
       SX3->(dbSeek("SDS"))
       alCpoEnch := {}
       Do While !Eof().And.(SX3->X3_ARQUIVO=="SDS")
          V_CPO := ALLTRIM(X3_CAMPO)
          If X3USO(SX3->X3_USADO).And.cNivel>=SX3->X3_NIVEL
             Aadd(alCpoEnch,V_CPO)
          Endif
          DbSkip()
       End Do*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder( 1 ) )
       ( _cAliasSX3 )->( dbGoTop( ) )
       ( _cAliasSX3 )->( dbSeek( "SDS" ) )
       alCpoEnch := {}
       While !Eof( ).And.( ( _cAliasSX3 )->( X3_ARQUIVO ) == "SDS" )
             V_CPO := ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) )
             If X3USO( ( _cAliasSX3 )->( X3_USADO ) ) .And. cNivel >= ( _cAliasSX3 )->( X3_NIVEL )
                Aadd(alCpoEnch,V_CPO)
          Endif
          DbSkip()
       End Do
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTA ACOLS   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SDT")
SDT->(dbSetOrder(1))
SDT->(dbGoTop())
alRecDT := {}
alHeaderDT:=aClone(aHeader)
clKey := xFilial("SDS")+M->DS_CNPJ+clCodFor+clLoja+clNota+clSerie
aCols := GdMontaCols(	@alHeaderDT		,; 	//01 -> Array com os Campos do Cabecalho da GetDados
@nlUsado		,;	//02 -> Numero de Campos em Uso
@alDTVirt		,;	//03 -> [@]Array com os Campos Virtuais
@alDTVisu   	,;	//04 -> [@]Array com os Campos Visuais
clTab2			,;	//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
NIL				,;	//06 -> Opcional, Campos que nao Deverao constar no aHeader
@alRecDT		,;	//07 -> [@]Array unidimensional contendo os Recnos
clTab1			,;	//08 -> Alias do Arquivo Pai
clKey  			,;	//09 -> Chave para o Posicionamento no Alias Filho
NIL				,;	//10 -> Bloco para condicao de Loop While
NIL				,;	//11 -> Bloco para Skip no Loop While
.F.				,;	//12 -> Se Havera o Elemento de Delecao no aCols
.F.				,;	//13 -> Se cria variaveis Publicas
.T.				,;	//14 -> Se Sera considerado o Inicializador Padrao
NIL				,;	//15 -> Lado para o inicializador padrao
NIL				,;	//16 -> Opcional, Carregar Todos os Campos
.F.				,;	//17 -> Opcional, Nao Carregar os Campos Virtuais
NIL				,;	//18 -> Opcional, Utilizacao de Query para Selecao de Dados
NIL				,;	//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
NIL				,;	//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
.F.				,;	//21 -> Carregar Coluna Fantasma
NIL				,;	//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
.T.				,;	//23 -> Verifica se Deve Checar se o campo eh usado
.T.				,;	//24 -> Verifica se Deve Checar o nivel do usuario
NIL				,;	//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
NIL				,;	//26 -> [@]Array que contera as chaves conforme recnos
NIL				,;	//27 -> [@]Se devera efetuar o Lock dos Registros
NIL				,;	//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
NIL				,;	//29 -> Numero maximo de Locks a ser efetuado
.F.				,;	//30 -> Utiliza Numeracao na GhostCol
NIL				,;	//31
2		    	 ;	//32 -> nOpc
)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MONTA TELA MODELO 3   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Mod3XML(	nlOpc,;                  								  		// 01 -> Opcao
	"Nf-e Disponíveis",;                  								  		// 02 -> Titulo da Tela
	clTab1,;                  								  		// 03 -> Tabela para Enchoice
	clTab2,;               									 		// 04 -> Tabela para GetDados
	alCpoEnch,;                 							  		// 05 -> Campos Enchoice
	clAwysT,;                 								  		// 06 -> CampoOk
	clAwysT,;                  								 		// 07 -> LinhaOk
	nlOpc,;                 										// 08 -> Opcao Enchoice
	nlOpc,;                  										// 09 -> Opcao GetDados
	clAwysT,;                  										// 10 -> TdOk
	.T.,;                  											// 11 -> Se carrega Campos Virtuais
	alCpoEnch,;                  									// 12 -> Campos alterar
	GetRodape(clCodFor,clLoja,clNota,clSerie,clTab1) )  ;   		// 13 -> Array com as informacoes do Radape
	.AND. VldCpoProd(clCodFor,clLoja,clNota,clSerie,SDS->DS_TIPO)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ GERA A PRE-NOTA   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ALIMENTA VETORES PARA A ROTINA AUTOMATICA (MSExecAuto)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	alSF1:=F1Imp(clCodFor,clLoja,clNota,clSerie,clTab1)
	MsgRun("Aguarde...",,{|| iif(!Empty(alSD1:=D1Imp(clCodFor,clLoja,clNota,clSerie,clTab2)),llD1Imp:=.T.,llD1Imp:=.F.  ) } )
	MsgRun("Aguarde...",,{|| llPedCom := VldQtdPC(alSD1) } )
	If llD1Imp .AND. llPedCom
		lMsErroAuto := .F.
		MsgRun("Aguarde gerando Pré-Nota de Entrada...",,{|| MSExecAuto({|x,y,z| MATA140(x,y,z)},alSF1,alSD1,3 )})
		
		If !lMsErroAuto
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ APOS EXECUTADA A ROTINA AUTOMATICA                 ³
			//³ ATUALIZA REGISTRO ( STATUS, DATA IMPORTACAO ...)   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(clTab1)
			dbSetOrder(1)
			&(clTab1)->(dbGoTop())
			If dbSeek(xFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
				If RecLock(clTab1,.F.)
					Replace DS_USERPRE  With cUserName
					Replace DS_DATAPRE  With dDataBase
					Replace DS_HORAPRE  With Time()
					Replace DS_STATUS   With 'P' // P = PROCESSADA PELO PROTHEUS
					&(clTab1)->(MsUnLock())
					Aviso("Atenção", "Pré-Nota gerada com Sucesso!" ,{"Ok"})
				EndIf
			EndIf
		Else
			DisarmTransaction()
			lMsErroAuto := .F.
			MostraErro()
		EndIf
	EndIf
	End Transaction
EndIf
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | VldQtdPC   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Essa funcao executada quando gera pre nota. Se retornar True     ³±±
±±³          | gera a rotina automatica.                                        ³±±
±±³          | Funcao verifica se a quant. do pedido de compra escolhido condiz ³±±
±±³          | com a quant. disponivel do pedido de compra (SC7) atualizado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ alItns := Array com os itens (D1) para rotina automatica         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llRet = Se .T. = OK                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldQtdPC(alItns)

Local llRet     := .T.
Local nlK       := 0
Local llErro    := .F.
Local nlPedPos  := 0
Local nlItnPos  := 0
Local nlQtdPos  := 0
Local nlForPos  := 0
Local nlLojPos  := 0
Local nlNotPos  := 0
Local nlSerPos  := 0
Local nlCodPos  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LACO PERCORRE O ARRAY DOS ITENS E FAZ VERIFICACAO SE O ITEM TIVER PED. DE COMPRA PREENCHIDO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nlK:=1 to Len(alItns)
	If ((nlPedPos:=Ascan(alItns[nlK],{|x|X[1]=="D1_PEDIDO"}))>0) .AND. ((nlItnPos:=Ascan(alItns[nlK],{|x|X[1]=="D1_ITEMPC"}))>0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VERIFICA AS POSICOES DOS CAMPOS NO ARRAY  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nlQtdPos := Ascan(alItns[nlK],{|x|X[1]=="D1_QUANT"})
		nlForPos := Ascan(alItns[nlK],{|x|X[1]=="D1_FORNECE"})
		nlLojPos := Ascan(alItns[nlK],{|x|X[1]=="D1_LOJA"})
		nlNotPos := Ascan(alItns[nlK],{|x|X[1]=="D1_DOC"})
		nlSerPos := Ascan(alItns[nlK],{|x|X[1]=="D1_SERIE"})
		nlCodPos := Ascan(alItns[nlK],{|x|X[1]=="D1_COD"})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VERIFICA SE NA TABELA DE PED. DE COMPRAS EXISTE REALMENTE A QUANT. DISPONIVEL ³
		//³ SE FOR TIVER DIFERENCA PARA MAIS, EXCLUI DA SDV                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC7")
		dbSetOrder(1)
		SC7->(dbGoTop())
		If SC7->(dbSeek(xFilial("SC7")+PadR(alItns[nlK,nlPedPos,2],TamSx3("C7_NUM")[1])+ PadR(alItns[nlK,nlItnPos,2],TamSx3("C7_ITEM")[1])))
			If (alItns[nlK,nlQtdPos,2] > (SC7->C7_QUANT-SC7->C7_QTDACLA) )
				dbSelectArea("SDV")
				dbSetOrder(1)
				SDV->(dbGoTop()) // dbSeek - > Fornecedor+Loja+Nota Num.+Serie+Cod. Produto+Num. Pedido+Item PC
				If SDV->(dbSeek(xFilial("SDV")+alItns[nlK,nlForPos,2]+alItns[nlK,nlLojPos,2]+alItns[nlK,nlNotPos,2]+alItns[nlK,nlSerPos,2]+alItns[nlK,nlCodPos,2]+alItns[nlK,nlPedPos,2]+alItns[nlK,nlItnPos,2] ))
					If RecLock("SDV",.F.)
						SDV->(DbDelete())
						SDV->(MsUnlock())
					EndIf
					llErro:=.T.
				EndIf
			EndIf
		EndIf
	EndIf
Next nlK
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ EXIBE MENSAGEM DE ERRO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If llErro
	Aviso("Atenção","Erro ao importar a Pré-Nota",{"Ok"})
	llRet:=.F.
EndIf

Return llRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | VldCpoProd ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Verifica se o campo Produto esta preenchido. Caso nao esteja exec³±±
±±³          | funcao para que o usuario escolha qual produto se corresponde    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  := Cod. Fornecedor/Cliente                             ³±±
±±³          | clLoja    := Loja                                                ³±±
±±³          | clNota    := Num. Nota                                           ³±±
±±³          | clSerie   := Serie                                               ³±±
±±³          | clTipo    := N = Nota fiscal Normal / B ou D = Benef./Devolucao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llRet = Se .T. = OK                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldCpoProd(clCodFor,clLoja,clNota,clSerie, clTipo)

Local llRet     := .T.
Local nlK       := 0
Local nlPosCmp  := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_COD"})

For nlK:=1 to Len(aCols)
	If Empty(aCols[nlK,nlPosCmp])
		llRet:=EscolhaPrd(clCodFor,clLoja,clNota,clSerie,clTipo,nlK,nlPosCmp)
		Exit
	EndIf
Next nlK

Return llRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | EscolhaPrd ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Monta a tela com os produtos sem cod. para que usuario escolha   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  := Cod. Fornecedor/Cliente                             ³±±
±±³          | clLoja    := Loja                                                ³±±
±±³          | clNota    := Num. Nota                                           ³±±
±±³          | clSerie   := Serie                                               ³±±
±±³          | clTipo    := N = Nota fiscal Normal / B ou D = Benef./Devolucao  ³±±
±±³          | nlK       := Primeira posicao do acols encontrada sem Cod. Prod. ³±±
±±³          | nlPosCmp  := Posicao no aHeader do campo "DT_COD"                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llProcPrd = Se .T. = OK                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VldCpoProd                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function EscolhaPrd(clCodFor,clLoja,clNota,clSerie, clTipo, nlK, nlPosCmp)

Local llProcPrd     :=.F.
Local alSize    	:= MsAdvSize()
Local nlTl1     	:= alSize[1]
Local nlTl2    		:= alSize[2]
Local nlTl3    		:= alSize[1]+300
Local nlTl4     	:= alSize[2]+520
Local olFont        := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
Local llRetCons     := .F.
Local alHeaderTw    := {("Escolha produto"+Iif(AllTrim(clTipo)=="N","Fornecdor","Cliente" )),"Produto","Descrição"}
Local alTamHeader   := {60,60,100}
Local alRegs        := {}
Local olLisBox      := NIL
Local olBtInf       := NIL
Local alAlias       := Iif(AllTrim(clTipo)=="N",{"SA2","A2_NOME"},{"SA1","A1_NOME"})
Local nlCodPos      := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_PRODFOR"})
Local nlCont        := 0
Private _opPPrDlg  	:= NIL

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | SELECIONA REGISTROS  |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nlCont:=nlK to Len(aCols)
	If Empty(aCols[nlCont,nlPosCmp])
		aAdd(alRegs,{(aCols[nlCont,nlCodPos]),"","",nlCont})
	EndIf
Next nlCont

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | TELA - INTERFACE   |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG _opPPrDlg TITLE "Seleção Produtos" From nlTl1,nlTl2 to nlTl3,nlTl4 PIXEL

// Box
@(nlTl1+10),nlTl2 to (nlTl1+35),(nlTl2+237) PIXEL OF _opPPrDlg
@(nlTl1+14),(nlTl2+005) Say "Fornecedor: " + clCodFor + " - " + Posicione(alAlias[1],1,(xFilial(alAlias[1])+clCodFor+clLoja),alAlias[2])   Font olFont Pixel Of _opPPrDlg
@(nlTl1+23),(nlTl2+005) Say "Itens sem Còdigo Inforshop" Font olFont Pixel Of _opPPrDlg

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | TW BROWSE - ITENS DA NOTA |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	     //larg       //alt
olLisBox := TwBrowse():New(nlTl1+40,nlTl2,nlTl4-295,nlTl3-217,,alHeaderTw,alTamHeader,_opPPrDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
olLisBox:SetArray(alRegs)
olLisBox:bLine := {|| {alRegs[olLisBox:nAt,1],alRegs[olLisBox:nAt,2],alRegs[olLisBox:nAt,3]} }

// ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  BOTOES    |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
olBtInf  := TButton():New(nlTl1+132,nlTl2,"Produto" ,_opPPrDlg,{|| (llRetCons:=ConPad1(,,,"SB1",,,.F.)),(Iif(llRetCons, ((alRegs[olLisBox:nAt,2]:=SB1->B1_COD),(alRegs[olLisBox:nAt,3]:=SB1->B1_DESC)) ,  ) )    } ,065,012,,,,.T.  )
DEFINE SBUTTON FROM nlTl1+134,nlTl2+178 TYPE 1 ACTION (eVal( {|| llProcPrd:=PrcPrdOK(alRegs),  Iif((llProcPrd==.T.),(AtuSDT(alRegs,nlPosCmp,clCodFor,clLoja,clNota,clSerie, clTipo),_opPPrDlg:End()),Aviso("Atenção" ,"Produto não encontrado" ,{"Ok" }))   } )) ENABLE Of _opPPrDlg
DEFINE SBUTTON FROM nlTl1+134,nlTl2+212 TYPE 2 ACTION (eVal( {|| Iif(MsgyESnO("Deseja sair?"),_opPPrDlg:End(),) } )) ENABLE Of _opPPrDlg

ACTIVATE DIALOG _opPPrDlg CENTERED

Return llProcPrd


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |AtuSDT	  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao atualiza aCols e tabela SDT pela escolha do usuario       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ alRegs    := Array com os registros                              ³±±
±±³          | nlPosCmp  := Posicao no aHeader do Campo DT_COD                  ³±±
±±³          | clCodFor  := Cod. Fornecedor/Cliente                             ³±±
±±³          | clLoja    := Loja                                                ³±±
±±³          | clNota    := Num. Nota                                           ³±±
±±³          | clSerie   := Serie                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EscolhaPrd                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function AtuSDT(alRegs,nlPosCmp,clCodForCli,clLoja,clNota,clSerie, clTipo)

Local nlK         := 0
Local nlPosDes 	  := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_DESC"})
Local cProdForCli := ""
Local aArea		  := GetArea()

For nlK:=1 to Len(alRegs)
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// | ATUALIZA ACOLS     |
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[alRegs[nlK,Len(alRegs[nlK])],nlPosCmp] := alRegs[nlK,2]
	aCols[alRegs[nlK,Len(alRegs[nlK])],nlPosDes] := alRegs[nlK,3]
	
	cProdForCli := PadR(AllTrim(alRegs[nlK,1]),TamSx3("DT_PRODFOR")[1])
	cProdEmp	:= PadR(AllTrim(alRegs[nlK,2]),TamSX3("B1_COD")[1]		)
	
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// | ATUALIZA RELACIONAMENTO PRODUTO X FORNECEDOR E TABELA SDT|
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GPrdxPrdF(clCodForCli, clLoja, clNota, clSerie, cProdForCli, cProdEmp, clTipo)
	
Next nlK

RestArea(aArea)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | PrcPrdOK   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Validacao do botao OK na tela de selecao de prod. correspondente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ alRegs     := Array com os itens                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EscolhaPrd                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function PrcPrdOK(alRegs)

Local llPrcPrdOk := .T.
Local nlT        := 0

For nlT:=1 to Len(alRegs)
	If Empty(alRegs[nlT,2])
		llPrcPrdOk := !llPrcPrdOk
		Exit
	EndIf
Next nlT
Return llPrcPrdOk


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |  GetRodape ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao que busca as inforamcoes do rodape da tela mod. 3         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor  := Cod. Fornecedor/Cliente                             ³±±
±±³          | clLoja    := Loja                                                ³±±
±±³          | clNota    := Num. Nota                                           ³±±
±±³          | clSerie   := Serie                                               ³±±
±±³          | clTab1    := Tabela SDS                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array alNFe				                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function GetRodape(clCodFor,clLoja,clNota,clSerie,clTab1)

Local alNFe 	:= {}

dbSelectArea(clTab1)
dbSetOrder(1)
&(clTab1)->(dbGoTop())
If dbSeek(xFilial(clTab1)+clNota+clSerie+clCodFor+clLoja)
	aAdd(alNFe, &(clTab1+"->DS_STATUS"  ))
	aAdd(alNFe, &(clTab1+"->DS_ARQUIVO" ))
	aAdd(alNFe, &(clTab1+"->DS_USERIMP" ))
	aAdd(alNFe, &(clTab1+"->DS_DATAIMP" ))
	aAdd(alNFe, &(clTab1+"->DS_HORAIMP" ))
EndIf


Return alNFe



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |  Mod3XML   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Rotina principal para importar Schema XML                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nlOpc       := Opcao do Uusario (2-Visualizar/3-Gerar Pre Nota)  ³±±
±±³          | clTitle     := Titulo da Tela                                    ³±±
±±³          | clTab1      := Alias da Enchoice                                 ³±±
±±³          | clTab2      := Alias da GetDados                                 ³±±
±±³          | alCpoEnch   := Cmpos da Enchoice                                 ³±±
±±³          | clAwysT     := cLinhaOk                                          ³±±
±±³          | clAwysT     := cTudoOk                                           ³±±
±±³          | nlOpc1      := Opcao Enchoice                                    ³±±
±±³          | nlOpc2      := Opcao GetDados                                    ³±±
±±³          | clAwysT     := cFieldOk                                          ³±±
±±³          | llVirtual   := llVirtual (Campos Virtuais)                       ³±±
±±³          | alCpoEnch   := Campos Alteracao enchoice                         ³±±
±±³          | alInfRod    := Array com as informacoes do radpe 			    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ llRet                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function Mod3XML(nlOpc,clTitle,clTab1,clTab2,alCpoEnch,clAwysT,clAwysT,nlOpc1,nlOpc2,clAwysT,llVirtual,alAltEnch,alInfRod)

Local alAdvSz    := MsAdvSize()
Local alRNfe     := alInfRod
Local olFld      := NIL
Local llRet 	 := .F.
Local olFont     := TFont ():New(,,-11,.T.,.F.,5,.T.,5,.F.,.F.)
//Local olFont2    := TFont ():New(,,-11,.T.,.T.,5,.T.,5,.F.,.F.)
//Local clPicture  := "@E 999,999,999.99" 
Local olEnch     := NIL
Local olGetDd    := NIL
Local olGetStats := NIL
Local olGetArq   := NIL
Local olGetUser  := NIL
Local olGetData  := NIL
Local olGetHora  := NIL
Local clGStatus  := Iif( Empty(Upper(alRNfe[1])),"???","???")
Local clGNomArq  := Upper(alRNfe[2])
Local clGUser    := alRNfe[3]
Local dlGData    := alRNfe[4]
Local clGHora    := alRNfe[5]
Local nPosDesc	 := 0
Local nPosProd	 := 0
Local cDescProd	 := ""
Local nLoop
Local nLoops
Private aTrocaF3  := {}
Private _opMoD3lg := NIL

DEFINE MSDIALOG _opMoD3lg TITLE clTitle From alAdvSz[1],alAdvSz[2] to (alAdvSz[1]+450),(alAdvSz[2]+690) PIXEL

olFld      := TFolder():New((alAdvSz[1]+151),(alAdvSz[2]-6),{"Arquivos XML carregados"},{},_opMoD3lg,,,,.T.,.F., 334 , 068  )

// AJUSTA TELA PARA TEMA P10
If (Alltrim(GetTheme()) == "TEMAP10") .Or. SetMdiChild()
	_opMoD3lg:nHeight+=025
EndIf


// Muda Consulta padrao do cmapo DS_FORNEC para tabela de Clientes - SA1
IF AllTrim(SDS->DS_TIPO)<>"N"
	Aadd(aTrocaF3,{"DS_FORNEC", "SA1"} )
EndIf

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Monta enchoice e getDados 			  				  ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(clTab1,.F.)
olEnch := Msmget():New(clTab1,&(clTab1)->(Recno()),2,,,,alCpoEnch,{15,5,80,340},,3,,,,_opMoD3lg,,.T.,,,,,,,,.T.)

If !(Type("aHeader") == "U") .AND. !(Type("aCols") == "U") .AND. ((nPosDesc := GDFieldPos("DT_DESC", aHeader))>0) .AND. ((nPosProd := GDFieldPos("DT_COD", aHeader))>0)
	
	nLoops := Len( aCols  )
	For nLoop := 1 To nLoops
		cDescProd := Posicione("SB1",1,xFilial("SB1")+aCols[nLoop][nPosProd],"B1_DESC")
		GdFieldPut( "DT_DESC" , cDescProd , nLoop , aHeader , aCols )
	Next nLoop
	
EndIf

olGetDd := MsGetDados():New(84,5,150,340,2,clAwysT,clAwysT,"",.T.,,,,,clAwysT)

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Monta Rodape         ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// ---- NOTA FISCAL ELETRONICA
// Status
@(alAdvSz[1]+010),(alAdvSz[2]-2) Say "Status" Font olFont Pixel Of olFld:aDialogs[1]
olGetStats := TGet():New((alAdvSz[1]+08),(alAdvSz[2]+045),{|u| if(PCount()>0,clGStatus:=u,clGStatus)}, olFld:aDialogs[1] ,110,10,"@!",,,,,,,.T.,,,,,,,.T.,,,"clGStatus")
// Arquivo
@(alAdvSz[1]+025),(alAdvSz[2]-2) Say "Arquivo" Font olFont Pixel Of olFld:aDialogs[1]
olGetArq := TGet():New((alAdvSz[1]+23),(alAdvSz[2]+045),{|u| if(PCount()>0,clGNomArq:=u,clGNomArq)}, olFld:aDialogs[1] ,110,10,"@!",,,,,,,.T.,,,,,,,.T.,,,"clGNomArq")
// Usuario Import
@(alAdvSz[1]+010),(alAdvSz[2]+170) Say "Usuario Import" Font olFont Pixel Of olFld:aDialogs[1]
olGetUser := TGet():New((alAdvSz[1]+08),(alAdvSz[2]+240),{|u| if(PCount()>0,clGUser:=u,clGUser)}, olFld:aDialogs[1] ,70,10,,,,,,,,.T.,,,,,,,.T.,,,"clGUser")
// Data Import
@(alAdvSz[1]+025),(alAdvSz[2]+170) Say "Data Import" Font olFont Pixel Of olFld:aDialogs[1]
olGetData := TGet():New((alAdvSz[1]+23),(alAdvSz[2]+240),{|u| if(PCount()>0,dlGData:=u,dlGData)}, olFld:aDialogs[1] ,50,10,,,,,,,,.T.,,,,,,,.T.,,,"dlGData")
// Hora Import
@(alAdvSz[1]+040),(alAdvSz[2]+170) Say "Hora Import" Font olFont Pixel Of olFld:aDialogs[1]
olGetHora := TGet():New((alAdvSz[1]+38),(alAdvSz[2]+240),{|u| if(PCount()>0,clGHora:=u,clGHora)}, olFld:aDialogs[1] ,40,10,,,,,,,,.T.,,,,,,,.T.,,,"clGHora")

ACTIVATE DIALOG _opMoD3lg ON INIT(EnchoiceBar(_opMoD3lg,  {|| (Iif((nlOpc==3),llRet:=.T.,),_opMoD3lg:End()) } , {|| _opMoD3lg:End()},  ,  )) CENTERED

Return llRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |  D1Imp     ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Carrega Array com os itens da nota fiscal para rotina automatica ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor = Cod. Fornecedor                                       ³±±
±±³          | clLoja   = Loja                                                  ³±±
±±³          | clNota   = Num. NOta                                             ³±±
±±³          | clSerie  = Serie                                                 ³±±
±±³          | clTab    = Tabela de itens - SDT                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet = array com os dados para execucao da rotina automatica    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function D1Imp(clCodFor,clLoja,clNota,clSerie,clTab)

Local alItens	 := {}
Local alRet      := {}
Local nlQtd      := 0
Local nlCont	 := 0
Local alBaseImp  := {}
Local alAliqImp  := {}

Local alTamSDV   := {TAMSX3("DV_FORNEC")[1],TAMSX3("DV_LOJA")[1],TAMSX3("DV_DOC")[1],TAMSX3("DV_SERIE")[1],TAMSX3("DV_PROD")[1],TAMSX3("DV_NUMPED")[1],TAMSX3("DV_ITEMPC")[1]}
Local nlPosProd  := Ascan(aHeader,{|x|Alltrim(X[2])=="DT_PRODFOR"})

For nlCont:=1 to Len(aCols)
	dbSelectarea(clTab)
	dbSetOrder(2)
	&(clTab)->(dbGoTop())
	alBaseImp := {}
	alAliqImp := {}
	If dbSeek(xFilial(clTab)+clCodFor+clLoja+clNota+clSerie+aCols[nlCont,nlPosProd])
		nlQtd := SDT->DT_QUANT
		
		
		dbSelectArea("SDV")
		SDV->(dbSetOrder(1))
		SDV->(dbGoTop())
		If dbSeek(xFilial("SDV")+PadR(clCodFor,alTamSDV[1])+PadR(clLoja,alTamSDV[2])+PadR(clNota,alTamSDV[3])+PadR(clSerie,alTamSDV[4])+PadR(SDT->DT_COD,alTamSDV[5]))
			While SDV->(!EOF()) .AND. (SDV->DV_PROD==SDT->DT_COD) .AND. (SDV->DV_FORNEC==SDT->DT_FORNEC) .AND. (SDV->DV_LOJA==SDT->DT_LOJA) .AND. (SDV->DV_DOC==SDT->DT_DOC) .AND. (SDV->DV_SERIE==SDT->DT_SERIE)
				alItens:={}
				aAdd(alItens,{"D1_FILIAL"   , SDT->DT_FILIAL          ,NIL})  // INF. PED.
				aAdd(alItens,{"D1_DOC"      , SDT->DT_DOC             ,NIL})
				aAdd(alItens,{"D1_SERIE"    , SDT->DT_SERIE           ,NIL})
				aAdd(alItens,{"D1_FORNECE"  , SDT->DT_FORNEC          ,NIL})
				aAdd(alItens,{"D1_LOJA"     , SDT->DT_LOJA            ,NIL})
				aAdd(alItens,{"D1_ITEM"     , StrZero(Len(alRet)+1,4) ,NIL})
				aAdd(alItens,{"D1_COD"      , SDT->DT_COD             ,NIL})
				aAdd(alItens,{"D1_QUANT"    , SDV->DV_QUANT           ,NIL})
				aAdd(alItens,{"D1_VUNIT"    , SDT->DT_VUNIT           ,NIL})
				aAdd(alItens,{"D1_TOTAL"    , (SDT->DT_VUNIT*SDV->DV_QUANT )        ,NIL})
				aAdd(alItens,{"D1_PEDIDO"  	, SDV->DV_NUMPED       	  ,NIL})
				aAdd(alItens,{"D1_ITEMPC"  	, SDV->DV_ITEMPC      	  ,NIL})
				aAdd(alRet,alItens)
				nlQtd := (nlQtd - SDV->DV_QUANT)
				SDV->(dbSkip())
			EndDo
		EndIf
		
		If nlQtd > 0
			alItens:={}
			aAdd(alItens,{"D1_FILIAL"   , SDT->DT_FILIAL          ,NIL})  // INF. PED.
			aAdd(alItens,{"D1_DOC"      , SDT->DT_DOC             ,NIL})
			aAdd(alItens,{"D1_SERIE"    , SDT->DT_SERIE           ,NIL})
			aAdd(alItens,{"D1_FORNECE"  , SDT->DT_FORNEC          ,NIL})
			aAdd(alItens,{"D1_LOJA"     , SDT->DT_LOJA            ,NIL})
			aAdd(alItens,{"D1_ITEM"     , StrZero(Len(alRet)+1,4) ,NIL})
			aAdd(alItens,{"D1_COD"      , SDT->DT_COD             ,NIL})
			aAdd(alItens,{"D1_QUANT"    , nlQtd                   ,NIL})
			aAdd(alItens,{"D1_VUNIT"    , SDT->DT_VUNIT           ,NIL})
			aAdd(alItens,{"D1_TOTAL"    , (SDT->DT_VUNIT*nlQtd)   ,NIL})
			aAdd(alRet,alItens)
		EndIf
	EndIf
Next nlCont

Return alRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | F1Imp   	  ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Carrega Array com o cabecalho da nota fiscal para rotina automat.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor = Cod. Fornecedor                                       ³±±
±±³          | clLoja   = Loja                                                  ³±±
±±³          | clNota   = Num. NOta                                             ³±±
±±³          | clSerie  = Serie                                                 ³±±
±±³          | clTab    = Tabela de cabecalho - SDS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alCabec = array com os dados para execucao da rotina automatica  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ExecTela	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function F1Imp(clCodFor,clLoja,clNota,clSerie,clTab)

Local alCabec:={}

dbSelectArea(clTab)
dbSetOrder(1)
&(clTab)->(dbGoTop())
If dbSeek(xFilial(clTab)+clNota+clSerie+clCodFor+clLoja)
	aAdd(alCabec,{"F1_FILIAL"      ,SDS->DS_FILIAL         ,Nil})
	aAdd(alCabec,{"F1_TIPO"        ,SDS->DS_TIPO           ,Nil})
	aAdd(alCabec,{"F1_FORMUL"      ,SDS->DS_FORMUL         ,Nil})
	aAdd(alCabec,{"F1_DOC"         ,SDS->DS_DOC            ,Nil})
	aAdd(alCabec,{"F1_SERIE"       ,SDS->DS_SERIE          ,Nil})
	aAdd(alCabec,{"F1_EMISSAO"     ,SDS->DS_EMISSA		 	,Nil})
	aAdd(alCabec,{"F1_FORNECE"     ,SDS->DS_FORNEC         ,Nil})
	aAdd(alCabec,{"F1_LOJA"        ,SDS->DS_LOJA           ,Nil})
	aAdd(alCabec,{"F1_ESPECIE"     ,SDS->DS_ESPECI         ,Nil})
	aAdd(alCabec,{"F1_DTDIGIT"     ,SDS->DS_DATAIMP			,Nil})
	aAdd(alCabec,{"F1_EST"         ,SDS->DS_EST				,Nil})
	aAdd(alCabec,{"F1_HORA"        ,SubStr(Time(),1,5)		,Nil})
EndIf
&(clTab)->(dbCloseArea())

Return alCabec

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Rotina    | XmlRetNome ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Rotina chamada no inicializador padrão do campo DS_NOME (virtual)³±±
±±³          | posiciona na tabela correta (Fornecedor/Cliente) e retorna nome  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCodFor = Cod. Fornecedor                                       ³±±
±±³          | clLoja   = Loja                                                  ³±±
±±³          | clTipo   = Tipo da Nota (NORMAL/DEVOLUCAO/BENEFICIAMNETO)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ clNomeRet = Nome do fornecedor ou cliente                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO		                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function XmlRetNome(clForCli,clLoja,clTipo)
Local clNomeRet := ""
Local clAlias   := Iif((AllTrim(clTipo)<>"N"),"SA1","SA2")
clNomeRet := POSICIONE(clAlias,1,(XFILIAL(clAlias)+clForCli+clLoja),(Right(clAlias,2)+"_NOME") )
Return clNomeRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Rotina    |GPrdxPrdF   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Grava relacinamento Produto x Produto do Pornecedor				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cod. Fornecedor|Cliente                                  ³±±
±±³			 ³ ExpC2 = Loja Fornecedor|Cliente                                  ³±±
±±³			 ³ ExpC3 = Nota Fiscal		                                        ³±±
±±³			 ³ ExpC4 = Serie da Nota                                            ³±±
±±³			 ³ ExpC5 = Produto Clinte/Fornecedor                                ³±±
±±³			 ³ ExpC6 = Cod. Produto		                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil										                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SelePed, RPrdxPrdF, ProcPCxNFe, AtuSDT							³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function GPrdxPrdF(clCodForCli, clLoja, clNota, clSerie, cProdForCli, cProdEmp, cTipo)
Local aArea		:= GetArea()
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | GRAVA RELACIONAMENTO PARA PROXIMA IMPORTACAO |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SDT")
SDT->(dbSetOrder(2))
If SDT->(dbSeek(xFilial("SDT")+clCodForCli+clLoja+clNota+clSerie+cProdForCli ))
	If RecLock("SDT",.F.)
		Replace DT_COD With cProdEmp
		SDT->(MsUnLock())
	EndIf
EndIf

RestArea( aArea )
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Rotina    | PrdxForCli		   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Valida se existe amarração entre Produto x Fornecedor/Cliente	   	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Cod. Fornecedor|Cliente                                 			 ³±±
±±³			 ³ ExpC2 = Loja Fornecedor|Cliente                                    		 ³±±
±±³			 ³ ExpC3 = Cod. Produto		                                          		 ³±±
±±³			 ³ ExpC4 = Tipo da Nota		                                          		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cProdEmp = Produto relacionado ao Forncedor/Cliente                		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ProcPCxNFe                                                        	     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function PrdxForCli(clCodForCli, clLoja, clCodProd,clTipo)
Local cWAlias 	:= ""
Local cProdEmp	:= ""
Local nOrd		:= 1

If clTipo<>"N"
	cWAlias := "SA7"
	nOrd := RetOrder("SA7", "A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO")
Else
	cWAlias := "SA5"
	nOrd	:= RetOrder("SA5", "A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO")
EndIf

DbSelectArea(cWAlias)
(cWAlias)->(DbSetOrder( nOrd ))

If ( (cWAlias)->(dbSeek(xFilial(cWAlias)+clCodForCli+clLoja+clCodProd )) )
	If cWAlias == "SA5"
		cProdEmp := SA5->A5_PRODUTO
	Else
		cProdEmp := SA7->A7_PRODUTO
	EndIf
EndIf
Return cProdEmp



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    |  PesqCGC   ³Autor ³ Paulo Bindo                 |Data ³ 30/01/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao pesquisa no SM0 para qual empresa/filial é destinado a NFe³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ clCGC = CNPJ informado no arquivo XML                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ alRet = Array de 2 posicoes                                      ³±±
±±³          | 		[ 1 ] = COD. EMPRESA                                        ³±±
±±³          | 		[ 2 ] = COD. FILIAL                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function PesqCGC(clCGC)
       Local alAreaSM0
Local aCodEmpFil:= {}

dbSelectArea("SM0")
alAreaSM0 := SM0->(GetArea())
dbGoTop()
Do While !eof() .and. !Empty(clCGC)
	If SM0->M0_CGC = clCGC
		aAdd(aCodEmpFil, {SM0->M0_CODIGO, SM0->M0_CODFIL})
		exit
	Endif
	dbSkip()
Enddo
RestArea(alAreaSM0)
Return aCodEmpFil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  ReadXML ºAutor  ³Paulo Bindo		 º Data ³  30/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para leitura de XMLs de NFe no diretorio de downloadº±±
±±º			 ³ e geracao da pre-nota de entrada.						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ReadXML(cFile,lJob)
     Local cProduto      := CriaVar("B1_COD")
     Local cXML          := ""
     Local cError        := ""
     Local cWarning      := ""
     Local cCGC          := ""
     Local cTipoNF       := ""
     Local cTabEmit      := ""
     Local cDoc          := ""
     Local cSerie        := ""
     Local cCodigo       := ""
     Local cLoja         := ""
     Local cCampo1       := ""
     Local cCampo2       := ""
     Local cCampo3       := ""
     Local cCampo4       := ""
     Local cCampo5       := ""
     Local cQuery        := ""
     //Local cNFECFAP      := SuperGetMV("MV_NFECFAP",.F.,"")
     Local lFound        := .F.
     Local lProces       := .T.
     //Local lCFOPEsp      := .T.
     Local nX            := 0
     Local nY            := 0
     Local oFullXML      := NIL
     Local oAuxXML       := NIL
     Local oXML          := NIL
     Local aItens        := {}
     Local aHeadSDS      := {}
     Local aItemSDT      := {}
     Local oDlg     
     Local lStatus       := .F.
     Local cProduto2     := CriaVar("B1_COD")
     Local cAuxMens      := ""
     Local _oTafINFE
     Private cEmailAdm   := GETMV("MV_WFADMIN")
     Private cEmailErro  := "fiscal@inforshop.com.br"
     Private lMsErroAuto := .F.

     Default lJob        := .T.

     If !File(cStartPath +cFile)
        If lJob
           /*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
           //ConOut(Replicate("=",80))
           //ConOut("ReadXML Error:")
           //ConOut("Arquivo: " +cFile)
           //ConOut("Ocorrencia: Arquivo inexistente.")
           //ConOut(Replicate("=",80))
           cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
           cAuxMens += "ReadXML Error:"     + CHR( 13 ) + CHR( 10 )
           cAuxMens += "Arquivo: " + cFile  + CHR( 13 ) + CHR( 10 )
           cAuxMens += "Ocorrencia: Arquivo inexistente." + CHR( 13 ) + CHR( 10 )
           cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )

           FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
        Else
           Aviso("Error","Arquivo " +cFile +" inexistente.",{"OK"},2,"ReadXML")
        EndIf
        lProces := .F.
     Else
        cXML := MemoRead(cStartPath +cFile)
        //-- Nao processa conhecimentos de transporte
        If "</CTE>" $ Upper(cXML)
           FErase(cStartPath+cFile)
           lProces := .F.
        EndIf

        //-- Nao processa XML de outra empresa/filial
        If lProces .And. !(Substr(SM0->M0_CGC,0,8) $ cXML)
           lProces := .F.
        EndIf
     EndIf

     If lProces
        oFullXML := XmlParserFile(cStartPath + cFile,"_",@cError,@cWarning)
        //-- Erro na sintaxe do XML
        If Empty(oFullXML) .Or. !Empty(cError)
           If lJob
              /*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
              //ConOut(Replicate("=",80))
              //ConOut("ReadXML Error:")
              //ConOut("Arquivo: " +cFile)
              //ConOut("Ocorrencia: " +cError)
              //ConOut(Replicate("=",80))
              cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
              cAuxMens += "ReadXML Error:"     + CHR( 13 ) + CHR( 10 )
              cAuxMens += "Arquivo: " + cFile  + CHR( 13 ) + CHR( 10 )
              cAuxMens += "Ocorrencia: Arquivo inexistente." + CHR( 13 ) + CHR( 10 )
              cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )

              FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
           Else
              Aviso("Erro",cError,{"OK"},2,"ReadXML")
           EndIf

           //-- Move arquivo para pasta dos erros
           cArqTXT := cStartPath+cFile
           //copia o arquivo antes da transacao
           cNomNovArq  := cStartError+cFile
           If MsErase(cNomNovArq)
              __CopyFile(cArqTXT,cNomNovArq)
              FErase(cStartPath+cFile)
           EndIf
           lProces := .F.
        Else
           oXML    := oFullXML
           oAuxXML := oXML

           //-- Resgata o no inicial da NF-e
           While !lFound
                 oAuxXML := XmlChildEx(oAuxXML,"_NFE")
                 If !(lFound := oAuxXML # NIL)
                    For nX := 1 To XmlChildCount(oXML)
                        oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
                        lFound := oAuxXML:_InfNfe # Nil
                        If lFound
                           oXML := oAuxXML
                           Exit
                        EndIf
                    Next nX
                 EndIf
                 If lFound
                    oXML := oAuxXML
                    Exit
                 EndIf
           EndDo
           //VERIFICAR PARA QUAL FILIAL SERA IMPORTADO
           cCNPJInf := oXML:_INFNFE:_DEST:_CNPJ:TEXT
           If lJob
              dbSelectArea("SM0")
              dbSetOrder(1)
              dbGoTop()
              While !Eof()
                    If M0_CGC == cCNPJInf
                       cFilAnt := M0_CODFIL
                       cEmpAnt := M0_CODIGO
                       Exit
                    EndIf
                    dbSkip()
              End
           Else
              If SM0->M0_CGC # cCNPJInf
                 MsgStop("Este arquivo não pertence a esta Filial!","Atenção - COMMI010")
                 Return
              EndIf
           EndIf
           //-- Verifica se este ID ja foi processado
           DbSelectArea("SDS")
           SDS->(DbSetOrder(2))
           lFound := SDS->(DbSeek(xFilial("SDS")+Right(AllTrim(oXML:_InfNfe:_Id:Text),44)))//Filial + Chave de acesso
		
           //PEGA A IDENT
           If lJob
              cIdEnt := U_WSAT01GetIdEnt()
           EndIf
		
           //VERIFICA O STATUS NA RECEITA FEDERAL E EM CASO DE REJEICAO NAO IMPORTA
           lStatus := ConsNFeChave(Right(AllTrim(oXML:_InfNfe:_Id:Text),44),cIdEnt,lJob)

           If lStatus
              If !lJob
                 MsgStop("NFe com problemas, rotina Cancelada!","COMMI010")
                 Return
              Else
                 //ENVIA E-MAIL
                 U_EnvMail('Protheus@inforshop.net.br',cEmailAdm+";"+cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")
                 Return
              EndIf
           EndIf
           If lFound
              If lJob
                 cEmailErro :="ReadXML Error:"+ENTER
                 cEmailErro +="Arquivo: " +cFile+ENTER
                 cEmailErro +="Ocorrencia: ID de NFe ja registrado na NF " +SDS->(DS_DOC+"/"+DS_SERIE)+" do fornecedor " +SDS->(DS_FORNEC+"/"+DS_LOJA) +"."+ENTER
                 //ENVIA E-MAIL
                 U_EnvMail('Protheus@inforshop.net.br',cEmailAdm+";"+cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")

                 /*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                 //ConOut(Replicate("=",80))
                 //ConOut("ReadXML Error:")
                 //ConOut("Arquivo: " +cFile)
                 //ConOut("Ocorrencia: ID de NFe ja registrado na NF " +SDS->(DS_DOC+"/"+DS_SERIE);
                 //+" do fornecedor " +SDS->(DS_FORNEC+"/"+DS_LOJA) +".")
                 //ConOut(Replicate("=",80))
                 cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
                 cAuxMens += "ReadXML Error:"     + CHR( 13 ) + CHR( 10 )
                 cAuxMens += "Arquivo: " + cFile  + CHR( 13 ) + CHR( 10 )
                 cAuxMens += "Ocorrencia: ID de NFe ja registrado na NF " + SDS->( DS_DOC + "/" + DS_SERIE ) + " do fornecedor " + SDS->( DS_FORNEC + "/" + DS_LOJA ) + "." + CHR( 13 ) + CHR( 10 )
                 cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )

                 FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
              Else
                 Aviso("Erro","ID de NFe ja registrado na NF " +SDS->(DS_DOC+"/"+DS_SERIE);
                 +" do fornecedor " +SDS->(DS_FORNEC+"/"+DS_LOJA) +".",{"OK"},2,"ReadXML")
              EndIf
              //-- Move arquivo para pasta dos erros
              cArqTXT := cStartPath+cFile
              //copia o arquivo antes da transacao
              cNomNovArq  := cStartError+cFile
              If MsErase(cNomNovArq)
                 __CopyFile(cArqTXT,cNomNovArq)
                 FErase(cStartPath+cFile)
              EndIf
              lProces := .F.
           EndIf
           //-- Se ID valido
           //-- Extrai tag _InfNfe:_Det
           //***Luis Gustavo (29/01/2020) - Declaração das variáveis de verificação após criação do objeto oNfe
           _oTafINFE := ValType(oXML:_InfNfe:_Det)
           If lProces
              //If ValType(oXML:_InfNfe:_Det) == "O"
              If _oTafINFE == "O"
                 aItens := {oXML:_InfNfe:_Det}
              //ElseIf ValType(oXML:_InfNfe:_Det) == "U"
              ElseIf _oTafINFE == "U"
                     If lJob
                        cEmailErro :="ReadXML Error:"+ENTER
                        cEmailErro +="Arquivo: " +cFile+ENTER
                        cEmailErro +="Ocorrencia: tag _InfNfe:_Det nao localizada."+ENTER
                        //ENVIA E-MAIL
                        U_EnvMail('Protheus@inforshop.net.br',cEmailAdm+";"+cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")
					
                        /*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                        //ConOut(Replicate("=",80))
                        //ConOut("ReadXML Error:")
                        //ConOut("Arquivo: " +cFile)
                        //ConOut("Ocorrencia: tag _InfNfe:_Det nao localizada.")
                        //ConOut(Replicate("=",80))
                        cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
                        cAuxMens += "ReadXML Error:"     + CHR( 13 ) + CHR( 10 )
                        cAuxMens += "Arquivo: " + cFile  + CHR( 13 ) + CHR( 10 )
                        cAuxMens += "Ocorrencia: tag _InfNfe:_Det nao localizada." + CHR( 13 ) + CHR( 10 )
                        cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )

                        FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
                     Else
                        Aviso("Erro","Tag _InfNfe:_Det nao localizada.",{"OK"},2,"ReadXML")
                     EndIf
				
                     //-- Move arquivo para pasta dos erros
                     cArqTXT := cStartPath+cFile
                     //copia o arquivo antes da transacao
                     cNomNovArq  := cStartError+cFile
                     If MsErase(cNomNovArq)
                        __CopyFile(cArqTXT,cNomNovArq)
                        FErase(cStartPath+cFile)
                     EndIf
                     lProces := .F.
              Else
                 aItens := oXML:_InfNfe:_Det
              EndIf
           EndIf

           //-- Se tag _InfNfe:_Det valida
           //-- Extrai CGC do fornecedor/cliente
           If lProces
              If AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "1"
                 cTipoNF := "N"
              ElseIf AllTrim(oXML:_InfNfe:_Ide:_finNFe:Text) == "2"
                     cTipoNF := "D"
              Else
                 cTipoNF := "B"
              EndIf
              If ValType(oXML:_INFNFE:_EMIT:_CNPJ) <> "U"
                 cCGC := oXML:_INFNFE:_EMIT:_CNPJ:Text
              ElseIf ValType(oXML:_INFNFE:_EMIT:_CPF) <> "U"
                     cCGC := oXML:_INFNFE:_EMIT:_CPF:Text
              Else
                 If lJob
                    cEmailErro :="ReadXML Error:"+ENTER
                    cEmailErro +="Arquivo: " +cFile+ENTER
                    cEmailErro +="Ocorrencia: tag _CNPJ/_CPF ausente."+ENTER
                    //ENVIA E-MAIL
                    U_EnvMail('Protheus@inforshop.net.br',cEmailAdm+";"+cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")
					/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                    //ConOut(Replicate("=",80))
                    //ConOut("ReadXML Error:")
                    //ConOut("Arquivo: " +cFile)
                    //ConOut("Ocorrencia: tag _CNPJ/_CPF ausente.")
                    //ConOut(Replicate("=",80))
                    cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
                    cAuxMens += "ReadXML Error:"     + CHR( 13 ) + CHR( 10 )
                    cAuxMens += "Arquivo: " + cFile  + CHR( 13 ) + CHR( 10 )
                    cAuxMens += "Ocorrencia: tag _CNPJ/_CPF ausente." + CHR( 13 ) + CHR( 10 )
                    cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )

                    FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
                 Else
                    Aviso("Erro","Tag _CNPJ/_CPF ausente.",{"OK"},2,"ReadXML")
                 EndIf

                 //-- Move arquivo para pasta dos erros
                 cArqTXT := cStartPath+cFile
                 //copia o arquivo antes da transacao
                 cNomNovArq  := cStartError+cFile
                 If MsErase(cNomNovArq)
                    __CopyFile(cArqTXT,cNomNovArq)
                    FErase(cStartPath+cFile)
                 EndIf

                 lProces := .F.
              EndIf
           EndIf

           //-- Se tag CGC valida
           //-- Busca fornecedor/cliente na base
           If lProces
              cTabEmit := If(cTipoNF == "N","SA2","SA1")
              (cTabEmit)->(dbSetOrder(3))
              If (cTabEmit)->(dbSeek(xFilial(cTabEmit)+cCGC))
                 cCodigo := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_COD")
                 cLoja   := (cTabEmit)->&(Substr(cTabEmit,2,2)+"_LOJA")
              Else
                 If lJob
                    cEmailErro :="ReadXML Error:"+ENTER
                    cEmailErro +="Arquivo: " +cFile+ENTER
                    cEmailErro +="Ocorrencia: " +If(cTipoNF == "N","fornecedor","cliente") +" de CNJP/CPF numero " +cCGC +" inexistente na base."+ENTER
                    //ENVIA E-MAIL
                    U_EnvMail('Protheus@inforshop.net.br',cEmailAdm+";"+cEmailErro,'',aStatus[2],' Importacao XML NFe entrada com Erros' ,"")
					/*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                    //ConOut(Replicate("=",80))
                    //ConOut("ReadXML Error:")
                    //ConOut("Arquivo: " +cFile)
                    //ConOut("Ocorrencia: " +If(cTipoNF == "N","fornecedor","cliente") +" de CNJP/CPF numero " +cCGC +" inexistente na base.")
                    //ConOut(Replicate("=",80))
                    cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
                    cAuxMens += "ReadXML Error:"     + CHR( 13 ) + CHR( 10 )
                    cAuxMens += "Arquivo: " + cFile  + CHR( 13 ) + CHR( 10 )
                    cAuxMens += "Ocorrencia: " +If(cTipoNF == "N","fornecedor","cliente") +" de CNJP/CPF numero " +cCGC +" inexistente na base." + CHR( 13 ) + CHR( 10 )
                    cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )

                    FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
                 Else
                    Aviso("Erro",If(cTipoNF == "N","Fornecedor","Cliente") +" de CNJP/CPF numero " +cCGC +" inexistente na base.",{"OK"},2,"ReadXML")
                 EndIf

                 //-- Move arquivo para pasta dos erros
                 cArqTXT := cStartPath+cFile
                 //copia o arquivo antes da transacao
                 cNomNovArq  := cStartError+cFile
                 If MsErase(cNomNovArq)
                    __CopyFile(cArqTXT,cNomNovArq)
                    FErase(cStartPath+cFile)
                 EndIf

                 lProces := .F.
              EndIf
           EndIf
		
           //-- Se fornecedor/cliente validado
           //-- Processa cabeçalho e itens
           If lProces
              cCampo1 := If(cTipoNF # "N","A7_PRODUTO","A5_PRODUTO")
              cCampo2 := If(cTipoNF # "N","A7_FILIAL","A5_FILIAL")
              cCampo3 := If(cTipoNF # "N","A7_CLIENTE","A5_FORNECE")
              cCampo4 := If(cTipoNF # "N","A7_LOJA","A5_LOJA")
              cCampo5 := If(cTipoNF # "N","A7_CODCLI","A5_CODPRF")

              cDoc   := StrZero(Val(AllTrim(oXML:_InfNfe:_Ide:_nNF:Text)),TamSx3("F1_DOC")[1])
              cSerie := PadR(oXML:_InfNfe:_Ide:_Serie:Text,TamSX3("F1_SERIE")[1])
			
              //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
              //³ Grava os Dados do Cabecalho - SDS  ³
              //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
              DbSelectArea("SDS")
              AADD( aHeadSDS, { { "DS_FILIAL" , xFilial("SDS") 	                                                                  },; //Filial
                                { "DS_CNPJ"   , cCGC 	                                                                          },; //CGC
                                { "DS_DOC"    , cDoc 	                                                                          },; //Numero do Documento
                                { "DS_SERIE"  , cSerie 	                                                                          },; //Serie
                                { "DS_FORNEC" , cCodigo 	                                                                      },; //Fornecedor
                                { "DS_LOJA"   , cLoja 	                                                                          },; //Loja do Fornecedor
                                { "DS_EMISSA" , StoD(StrTran(AllTrim(oXML:_InfNfe:_Ide:_DEmi:Text),"-","")) 	                  },; //Data de Emissão
                                { "DS_EST"    , oXML:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT 	                                          },; //Estado de emissao da NF
                                { "DS_TIPO"   , cTipoNF 	                                                                      },; //Tipo da Nota
                                { "DS_FORMUL" , "N" 	                                                                          },; //Formulario proprio
                                { "DS_DTDIGI" , dDataBase 	                                                                      },; //Dtda de digitaçao
                                { "DS_ESPECI" , "SPED"                                                                            },; //Especie
                                { "DS_ARQUIVO", AllTrim(cFile)                                                                    },; //Arquivo importado
                                { "DS_STATUS" , " "                                                                               },; //Status
                                { "DS_CHAVENF", Iif(ValType("opNF:_InfNfe:_Id")<>"U",Right(AllTrim(oXML:_InfNfe:_Id:Text),44),"") },; //Chave de Acesso da NF
                                { "DS_VERSAO" , Iif(ValType("opNF:_InfNfe:_versao")<>"U",oXML:_InfNfe:_versao:text ,"")           },; //Versão
                                { "DS_USERIMP", Iif(!Empty(cUserName),cUserName,"JOB" )                                           },; //Usuario na importacao
                                { "DS_DATAIMP", dDataBase                                                                         },; //Data importacao do XML
                                { "DS_HORAIMP", SubStr(Time(),1,5)                                                                } } ) //Hora importacao XML
			
			
              For nX := 1 To Len(aItens)
                  cProduto := AllTrim(aItens[nX]:_Prod:_cProd:Text)

                  cQuery := "SELECT " +cCampo1 +" FROM " +RetSqlName(If(cTipoNF # "N","SA7","SA5"))
                  cQuery += " WHERE D_E_L_E_T_ <> '*' AND "
                  cQuery += cCampo2 +" = '" +xFilial(If(cTipoNF # "N","SA7","SA5")) +"' AND "
                  cQuery += cCampo3 +" = '" +cCodigo +"' AND "
                  cQuery += cCampo4 +" = '" +cLoja +"' AND "
                  cQuery += cCampo5 +" = '" +cProduto +"'"

                  If Select("TRB") > 0
                     TRB->(dbCloseArea())
                  EndIf
				
                  TcQuery cQuery new Alias "TRB"
				
                  If !TRB->(EOF())
					cProduto2 := TRB->(&cCampo1)
                  Else
                     If lJob
                        /*** Substituido em 29/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                        //ConOut(Replicate("=",80))
                        //ConOut("ReadXML Error:")
                        //ConOut("Arquivo: " +cFile)
                        //ConOut("Ocorrencia: " +If(cTipoNF == "N","fornecedor ","cliente ") +cCodigo +"/" +cLoja;
                        //+" sem cadastro de Produto X " +If(cTipoNF == "N","Fornecedor","Cliente");
                        //+" para o codigo " +cProduto +".")
                        //ConOut(Replicate("=",80))
                        cAuxMens := Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )
                        cAuxMens += "ReadXML Error:"     + CHR( 13 ) + CHR( 10 )
                        cAuxMens += "Arquivo: " + cFile  + CHR( 13 ) + CHR( 10 )
                        cAuxMens += "Ocorrencia: " + If( cTipoNF == "N", "fornecedor ", "cliente " ) + cCodigo + "/" + cLoja + " sem cadastro de Produto X " + If( cTipoNF == "N", "Fornecedor", "Cliente" ) +" para o codigo " + cProduto +"." + CHR( 13 ) + CHR( 10 )
                        cAuxMens += Replicate( "=", 80 ) + CHR( 13 ) + CHR( 10 )

                        FwLogMSG( "ERROR", , 'SIGACOM', funname(), '', '01', cAuxMens, 0 )
                     Else
                        Aviso("Erro",If(cTipoNF == "N","Fornecedor ","Cliente ") +cCodigo +"/" +cLoja;
                        +" sem cadastro de Produto X " +If(cTipoNF == "N","Fornecedor","Cliente");
                        +" para o código " +cProduto +".",{"OK"},2,"ReadXML")

                        If MsgYesNo('Atencao Produto '+cProduto+' Não Encontrado na Amarraçâo Prod. x Fornecedor, Deseja incluir?' )
                           cProduto2	:= cProduto+Space(15-Len(cProduto))
                           @ 65,153 To 229,435 Dialog oDlg Title OemToAnsi("Inclusão Ammarcao")
                           @ 9,9 Say OemToAnsi("Produto") Size 99,8
                           @ 28,9 Get cProduto2 Picture "@!" F3 "SB1" VALID Existcpo("SB1",cProduto2) Size 59,10
                           @ 62,39 BMPBUTTON TYPE 1 ACTION Close(oDlg)

                           Activate Dialog oDlg Centered

                           If !Empty(cProduto2)
                              If cTipoNF # "N"
                                 dbSelectArea("SA7")
                                 RecLock("SA7",.T.)
                                    A7_FILIAL 	:= xFilial("SA7")
                                    A7_CLIENTE 	:= cCodigo
                                    A7_LOJA 	:= cLoja
                                    A7_CODCLI   := cProduto
                                    A7_PRODUTO  := cProduto2
                                 MsUnlock()
                              Else
                                 dbSelectArea("SA5")
                                 RecLock("SA5",.T.)
                                    A5_FILIAL 	:= xFilial("SA5")
                                    A5_FORNECE 	:= cCodigo
                                    A5_LOJA 	:= cLoja
                                    A5_NOME		:= Posicione("SA2",1,xFilial("SA2")+cCodigo,"A2_NOME")
                                    A5_CODPRF	:= cProduto
                                    A5_PRODUTO  := cProduto2
                                    A5_NOMPROD  := Posicione("SB1",1,xFilial("SB1")+cProduto2,"B1_DESC")
                                 MsUnlock()
                              Endif
                           /*
                           Else
                              //-- Move arquivo para pasta dos erros
                              cArqTXT := c2StartPath+cFile
                              //copia o arquivo antes da transacao
                              cNomNovArq  := cStartError+cFile
                              If MsErase(cNomNovArq)
                                 __CopyFile(cArqTXT,cNomNovArq)
                                 FErase(c2StartPath+cFile)
                           EndIf

                           lProces := .F.
                           Exit
                           */
                           EndIf
                        Else
                           //-- Move arquivo para pasta dos erros
                           cArqTXT := cStartPath+cFile
                           //copia o arquivo antes da transacao
                           cNomNovArq  := cStartError+cFile
                           If MsErase(cNomNovArq)
                              __CopyFile(cArqTXT,cNomNovArq)
                              FErase(cStartPath+cFile)
                           EndIf

                           lProces := .F.
                           Exit
                        EndIf
                     EndIf
                  EndIf

                  TRB->(dbCloseArea())

                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³ Dados dos Itens - SDT	   ³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  DbSelectArea("SDT")
                  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                  //³  DADOS DO PRODUTO      ³
                  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  AADD( aItemSDT, { { "DT_FILIAL" , xFilial("SDT")                                                  },; //Filial
                                    { "DT_CNPJ"   , cCGC                                                            },; //CGC
                                    { "DT_COD"    , cProduto2                                                       },; //Codigo do produto
                                    { "DT_PRODFOR", aItens[nX]:_PROD:_CPROD:TEXT                                    },; //Cdgo do pduto do Fornecedor
                                    { "DT_DESCFOR", aItens[nX]:_PROD:_XPROD:TEXT                                    },; //Dcao do pduto do Fornecedor
                                    { "DT_ITEM"   , PadL(aItens[nX]:_nItem:Text,TamSX3("D1_ITEM")[1],"0")           },; //Item
                                    { "DT_QUANT"  , Val(aItens[nX]:_Prod:_qCom:Text)                                },; //Qtde
                                    { "DT_VUNIT"  , Round(Val(aItens[nX]:_Prod:_vUnCom:Text),TamSX3("C7_PRECO")[2]) },; //Vlor Unitário
                                    { "DT_FORNEC" , cCodigo                                                         },; //Forncedor
                                    { "DT_LOJA"   , cLoja                                                           },; //Lja
                                    { "DT_DOC"    , cDoc                                                            },; //DocmTo
                                    { "DT_SERIE"  , cSerie                                                          },; //Serie
                                    { "DT_TOTAL"  , Val(aItens[nX]:_Prod:_vProd:Text)                               } } ) //Vlor Total
              Next nX

              If !Empty(aItemSDT) .And. !Empty(aHeadSDS)
                 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                 //³Grava os dados do cabeçalho e itens da nota importada do XML³
                 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                 Begin Transaction
                       aHeadSDS:=aHeadSDS[1]
                       //--Grava cabeçalho
                       RecLock("SDS",.T.)
                          For nX:=1	To Len(aHeadSDS)
                              SDS->&(aHeadSDS[nX][1]):= aHeadSDS[nX][2]
                          Next
                          dbCommit()
                       MsUnlock()
                       //--Grava Itens
                       For nX:=1 To Len(aItemSDT)
                           RecLock("SDT",.T.)
                              For nY:=1 To Len(aItemSDT[nX])
                                  SDT->&(aItemSDT[nX][nY][1]):= aItemSDT[nX][nY][2]
                              Next
                              dbCommit()
                           MsUnlock()
                       Next
                       cArqTXT := cStartPath+cFile
                       //copia o arquivo antes da transacao
                       cNomNovArq  := c3StartPath+cFile
                       If MsErase(cNomNovArq)
                          __CopyFile(cArqTXT,cNomNovArq)
                          FErase(cStartPath+cFile)
                       EndIf
                 End Transaction
              Else
                 //-- Move arquivo para pasta dos erros
                 cArqTXT := cStartPath+cFile
                 //copia o arquivo antes da transacao
                 cNomNovArq  := cStartError+cFile
                 If MsErase(cNomNovArq)
                    __CopyFile(cArqTXT,cNomNovArq)
                    FErase(cStartPath+cFile)
                 EndIf
              EndIf
           EndIf
        EndIf
     EndIf
Return lProces

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMMI010  ºAutor  ³Microsiga           º Data ³  01/30/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConsNFeChave(cChaveNFe,cIdEnt,lWeb)

Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMensagem:= ""
Local oWS
Local lErro := .F.


If ValType(lWeb) == 'U'
	lWeb := .F.
EndIf

oWs:= WsNFeSBra():New()
oWs:cUserToken   := "TOTVS"
oWs:cID_ENT    := cIdEnt
ows:cCHVNFE		 := cChaveNFe
oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

If oWs:ConsultaChaveNFE()
	cMensagem := ""
	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
		cMensagem += "Versão da Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
	EndIf
	cMensagem += "Ambiente"+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF //"Produção"###"Homologação"
	cMensagem += "Cod.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
	cMensagem += "Msg.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
		cMensagem += "Protocolo"+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
	EndIf
	//QUANDO NAO ESTIVER OK NAO IMPORTA, CODIGO DIFERENTE DE 100
	If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE # "100"
		lErro := .T.
	EndIf
	
	If !lWeb
		Aviso("Consulta NF",cMensagem,{"Ok"},3)
	Else
		Return({lErro,cMensagem})
	EndIf
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
EndIf
Return(lErro)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GetIdEnt  ³ Autor ³Eduardo Riera          ³ Data ³18.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem o codigo da entidade apos enviar o post para o Totvs  ³±±
±±³          ³Service                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo da entidade no Totvs Services                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function WSAT01GetIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"

oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
If oWs:ADMEMPRESAS()
	cIdEnt  := oWs:cADMEMPRESASRESULT
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
EndIf

RestArea(aArea)
Return(cIdEnt)
