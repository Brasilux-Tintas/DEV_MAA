#include 'TOTVS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DIRECTRY.CH"
#INCLUDE "RWMAKE.CH"

#include 'brasilux.ch'
#include "protheus.ch"
#INCLUDE "AP5MAIL.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#INCLUDE 'fwmvcdef.ch'
#INCLUDE "Avprint.ch"
#include 'font.ch'
#INCLUDE 'INKEY.CH'
#INCLUDE 'vkey.CH'


// Definição de constantes no início do código
#Define C6_ITEM_INDEX 1    // Supondo que o índice correto seja 1
#Define C6_NUM_INDEX 1     // Supondo que o índice correto seja 1
#Define C6_PRODUTO_INDEX 1 // Supondo que o índice correto seja 1

User Function MA410MNU()
	Local _aArea   := GetArea()
	Local _cGrpEmp := Alltrim( FWGrpCompany() )
	Local _ZPPAR0105 := GetMV( "ZP_PAR0105" ) // Habilita/Desabilita Divide Pedido Antigo

	If _cGrpEmp <> '11'
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³ MA410MNU ºAutor  ³ Cleber Orati       º Data ³  17/08/12   º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³ Ponto de Entrada para adicionar botão no pedido de vendas. º±±
        ±±º          ³ para se poder dividir pedido                               º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
        
        If _ZPPAR0105
           aAdd( aRotina, { 'Divide Ped'          , 'U_DividePed(SC5->C5_NUM)', 0, 3, 0, NIL } )
        Endif   
        
        aAdd( aRotina, { 'Divide Ped Novo'     , 'U_ZFATP01(SC5->C5_NUM)'  , 0, 3, 0, NIL } )
        aAdd( aRotina, { 'Estorna Div Ped'     , 'U_EstDivPed(SC5->C5_NUM)', 0, 3, 0, NIL } )
        aAdd( aRotina, { 'Posicao Estoque'     , 'U_BRFATC02(SC5->C5_NUM)' , 0, 3, 0, NIL } )
        aAdd( aRotina, { 'Imprimi Pallets'     , 'U_BRPCP065(SC5->C5_NUM)' , 0, 3, 0, NIL } )
        aAdd( aRotina, { 'Frete CIF'           , 'U_ZFATC01()'             , 0, 3, 0, NIL } )

        aAdd( aRotina, { 'Gera Pedidos P/Guarulhos' , 'U_DuplicaPedido()' , 0, 3, 0, NIL } )    // Jose 13/01/2025   'U_DuplicaPedido(SC5->C5_NUM)'

        aAdd( aRotina, { 'Politica x Frete CIF', 'U_ZFATC10(SC5->C5_NUM)'  , 0, 2, 0, NIL } )
                
        // Criado por Nelieder em 07/06/2023, aguardando aprovação de Gustavo para liberação
        //aAdd( aRotina, { 'Politica Comercial1'  , 'U_ZFATC01()'             , 0, 3, 0, NIL } )

        
        SetKey( VK_F10, { || U_ZFATC01() } )
        //SetKey( VK_F5,  { || U_ZFATC02() } )
     Else
        AADD( aRotina, { 'Mens. Padrão'   , 'U_MENU410'               , 0, 0, 0, .F. } )
     Endif
     RestArea( _aArea )
	/*ONDE:Parametros do array a Rotina:
	1. Nome a aparecer no cabecalho
	2. Nome da Rotina associada
	3. Reservado
	4. Tipo de Transação a ser efetuada:
	1 - Pesquisa e Posiciona em um Banco de Dados
	2 - Simplesmente Mostra os Campos
	3 - Inclui registros no Bancos de Dados
	4 - Altera o registro corrente
	5 - Remove o registro corrente do Banco de Dados
	5. Nivel de acesso
	6. Habilita Menu Funcional
	*/
		Return

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±À
Function    ³ DividePed
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
User Function DividePed(_cPed)
     Local aArea  := GetArea()
     Local aItens := {}

     // Incluido por Nelieder em 04/05/2023
     If GETMV("ZP_PAR0096")
         IF (SC5->C5_TPFRETE = "C") .AND. (SC5->C5_XVLRFRE > 0.0) .AND. (SC5->C5_TIPO = "N")
            Messagebox( "Atenção! Pedido com FRETE CIF! NÃO PODE SER DIVIDIDO! ", "Atenção!", 16 )
            return(.f.)
         Endif
     Endif 
    
     If !Empty( SC5->C5_TABELA ) //LGS#20220308 - Não de deixar pedidos de campanha serem divididos. Indicativo que é pedido de campanha é a tabela de preços.
        Messagebox( "Atenção! Pedido de Campanha! NÃO PODE SER DIVIDIDO! ", "Atenção!", 16 )
        Return(.f.)
     Endif
     aItens := SelecionaItens(_cPed)
     restarea(aArea)
return(.t.)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ EstDivPed()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function EstDivPed(_cPed)
     Local nArea := Alias()
     Local cPedAnt,aCab := {},aCab2 := {},aItens1 := {},aItens2 := {},aAux := {},aLiberacoes := {}
     Local nRegC6,nOrdC6,lRegC6,i,j,lContinua,lReg,nReg,nOrdem,nAuxReg
     //Local cAux,nCont,nQtdeItens
     Local nDesc1,nDesc2,nDesc3,nDesc4
     private lMsErroAuto,lMsHelpAuto
     lContinua := .t.
     dbselectarea("SC5")
     nOrdem := IndexOrd()
     if !eof() .and. !bof()
        lReg := .t.
        nReg := recno()
     else
        lReg := .f.
     endif
     dbselectarea("SC6")
     nOrdC6 := IndexOrd()
     if !eof() .and. !Bof()
        lRegC6 := .t.
        nRegC6 := recno()
     else
        lRegC6 := .f.
     endif

     if empty(SC5->C5_PEDDIV)
        lContinua := .f.
        Messagebox("Este pedido não é divisão de outro!","Atenção!",16)
     endif

     if lContinua
        if (Messagebox("Confirma o estorno da Divisão do Pedido?!","Confirme",4) != 6)
           lContinua := .f.
        endif
     endif
     if lContinua
        cPedAnt := SC5->C5_PEDDIV
        dbselectarea("SC6")
        dbsetorder(1)
        dbseek(xFilial("SC5")+cPedAnt)
        if !found()
           lContinua := .f.
           messagebox("Não encontrado o pedido origem nro: "+cPedAnt,"Atenção!",16)
        else
           aCab := DetCampos("SC5")
        endif
     endif

     if lContinua
        dbselectarea("SC5")
        dbsetorder(1)
        dbseek(xFilial("SC5")+_cPed)
        aCab2 := DetCampos("SC5")
        aItens1 := {}
        aItens2 := {}
        dbselectarea("SC6")
        dbsetorder(1)
        i := 0
        cItem := "01"
        dbseek(xFilial("SC6")+cPedAnt,.t.)
        while !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == ALLTRIM(xFilial("SC6"))) .AND. (alltrim(SC6->C6_NUM) == alltrim(cPedAnt))
              i++
              while cItem < SC6->C6_ITEM
                    i++
                    cItem := VerNumItem(i)
              enddo
              aLinha := {}
              aadd(aLinha,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
			aadd(aLinha,{"AUTDELETA","N",.F.})

              aAux := DetCampos("SC6")

              for j := 1 to len(aAux)
                  aadd(aLinha,{aAux[j,1],aAux[j,2],aAux[j,3]})
              next
              aadd(aItens1,aLinha)
              dbselectarea("SC6")
              dbskip()
        enddo

        aItens2 :={}
        dbseek(xFilial("SC6")+_cPed,.t.)
        while !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == ALLTRIM(xFilial("SC6"))) .AND. (alltrim(SC6->C6_NUM) == alltrim(_cPed))
              i++
              aAux := {}
              aadd(aAux,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
			aadd(aAux,{"AUTDELETA","S",.F.})
              aadd(aItens2,aAux)

              aLinha := {}
              aAux := {}
              aAux := DetCampos("SC6")
              for j := 1 to len(aAux)
                  aadd(aLinha,{aAux[j,1],aAux[j,2],aAux[j,3]})
              next
			aAdd(aLinha, {"C6_ITEM"   , VerNumItem(i)                       , .F.})
              aadd(aItens1,aLinha)

              nAuxReg := recno()
              dbselectarea("SC6")
              dbskip()
        enddo
        i++
        dbselectarea("SC6")
        dbgoto(nAuxReg)
        aLinha := {}
        aAux := {}
        aAux := DetCampos("SC6")
        for j := 1 to len(aAux)
            aadd(aLinha,{aAux[j,1],aAux[j,2],aAux[j,3]})
        next
		aAdd(aLinha, {"C6_ITEM"   , VerNumItem(i)                       , .F.})
        aadd(aItens2,aLinha)

        /*
        INCLUIR E EXLUIR ITENS DO PEDIDO GERADO PARA PODER TIRAR LIBERAÇÕES!!!
        */

        /*
        nQtdeItens := len(aItens2)
        aItens2 := {}
        i := 0
        cItem := "01"
        dbselectarea("SC6")
		dbseek(xFilial("SC6")+_cPed,.t.)
        while !eof() .and. (ALLTRIM(SC6->C6_FILIAL) == ALLTRIM(xFilial("SC6"))) .AND. (alltrim(SC6->C6_NUM) == alltrim(_cPed))
              i++
              if i < nQtdeItens
                 aLinha := {}
                 aadd(aLinha,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
                 aadd(aLinha,{"AUTDELETA","S",Nil})
                 aadd(aItens2,aLinha)
              else
                 aAux := {}
                 aadd(aAux,{"LINPOS","C6_ITEM",SC6->C6_ITEM})
                 aadd(aAux,{"AUTDELETA","N",Nil})

                 aLinha := {}
                 aLinha := DetCampos("SC6")
                 for j := 1 to len(aLinha)
                     aadd(aAux,{aLinha[j,1],aLinha[j,2],aLinha[j,3]})
                 next
                 aAdd(aLinha, {"C6_ITEM"   , VerNumItem(i)                       , Nil})
                 aadd(aItens2,aAux)
              endif
              dbselectarea("SC6")
              dbskip()
        enddo
        */
        /*
        FIM => INCLUIR E EXCLUIR ITENS
        */
		dbselectarea("SC6")
		dbsetorder(nOrdC6)
		if lRegC6
			dbgoto(nRegC6)
		endif

		aadd(aCab,{"C5_NUM"   ,cPedAnt,.F.})
		aadd(aCab2,{"C5_NUM"   ,_cPed,.F.})

		begin transaction
			lMsErroAuto := .f.
			lMsHelpAuto := .f.

			dbselectarea("SC5")
			dbsetorder(1)
			dbseek(xFilial("SC5")+cPedAnt)
			RecLock("SC5",.f.)
			nDesc1 := SC5->C5_DESCON1
			nDesc2 := SC5->C5_DESCON2
			nDesc3 := SC5->C5_DESCON3
			nDesc4 := SC5->C5_DESCON4
			SC5->C5_DESCON1 := 0
			SC5->C5_DESCON2 := 0
			SC5->C5_DESCON3 := 0
			SC5->C5_DESCON4 := 0
			MsUnLock()
			aLiberacoes := DetLibera()
			MsgRun("Incluindo dados no ped ant...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab, aItens1, 4 ) } )

			If lMsErroAuto
				MostraErro()
			endif
			dbselectarea("SC5")
			RecLock("SC5",.f.)
			SC5->C5_DESCON1 := nDesc1
			SC5->C5_DESCON2 := nDesc2
			SC5->C5_DESCON3 := nDesc3
			SC5->C5_DESCON4 := nDesc4
			MsUnLock()
			If !lMsErroAuto
				lMsErroAuto := .f.
				lMsHelpAuto := .f.

				dbselectarea("SC5")
				dbsetorder(1)
				dbseek(xFilial("SC5")+_cPed)
				//Alterar primeiro para tirar liberações
				MsgRun("Alterando ped atual...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab2, aItens2, 4 ) } )
				If lMsErroAuto
					MostraErro()
				Else
					lMsErroAuto := .f.
					lMsHelpAuto := .f.
					MsgRun("Excluindo ped atual...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab2, aItens2, 5 ) } )
					If lMsErroAuto
						MostraErro()
					endif
					dbselectarea("SC5")
					dbsetorder(1)
					dbseek(xFilial("SC5")+cPedAnt)
					dbsetorder(nOrdem)
				endif
			EndIf
			If !lMsErroAuto
				lMsErroAuto := !VoltaLiberacoes(aLiberacoes)
				If lMsErroAuto
					MostraErro()
				endif
			endif
			If lMsErroAuto
				dbselectarea("SC5")
				dbsetorder(nOrdem)
				if lReg
					dbgoto(nReg)
				endif
				dbselectarea("SC6")
				dbsetorder(nOrdC6)
				if lRegC6
					dbgoto(nRegC6)
				endif
				//return(.t.) //LGS#20200212 - Adequação de release 12.1.25 e posteriores - Não pode ser usado Return dentro de begin transaction.
			endif
		end transaction
		PreencheLiberacoes(aLiberacoes)
	endif

	dbselectarea("SC5")
	dbsetorder(nOrdem)
	if lReg
		dbgoto(nReg)
	endif

	dbselectarea("SC6")
	dbsetorder(nOrdC6)
	if lRegC6
		dbgoto(nRegC6)
	endif

	select(nArea)
return(.t.)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±À
Function    ³ SelecionaItens
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
Static Function SelecionaItens(_cPed)
       Local aArea      := GetArea()
       Local aRet       := {}
       Local lRet       := .t.
       Private aCores   := { { "DISPONIVEL > 0    ", "BR_VERDE"   },{ "DISPONIVEL <= 0", "BR_VERMELHO"} }
       Private cMarca   := GetMark()
       Private cGet1Sel := Space(1)
       Private cSay1Sel := Space(1)
       Private nCBox1Sl := ""
       Private lInverte := .f.
       Private oTempTable
       
       //     cVlrOpcB   := cOpcBPro

       If Select("TMPSEL")<>0
          Dbselectarea("TMPSEL")
          Dbclosearea()
          oTempTable:Delete()
       Endif

       SetPrvt("oDlg1Sel", "oBrw1Sel", "oBtn1Sel", "oBtn2Sel", "oBtn3Sel","oFont1Sl",  "oGet1Sel")

       /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±À
       ±± Definicao do Dialog e todos os seus componentes.                       ±±
       Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
       lRet := oTbl1Sel(_cPed)
       If lRet
          oFont1Sl   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
          oDlg1Sel   := MSDialog():New( 077, 223, 354, 985, "Itens pedido "+_cPed, , , .F., , , , , , .T., , , .T. )
          DbSelectArea("TMPSEL")
          oBrw1Sel   := MsSelect():New( "TMPSEL", "SELEC", "", ;
          { {"SELEC", , "Mark", "@!"}, {"CODPRO", "", "Produto", ""}, {"DESCRPRO", "", "Descrição", ""}, {"ITEM", "", "Item", ""}, {"DISPONIVEL", "", "Q. DISPONIVEL", PesqPict("SB2","B2_QATU")} }, ;
          @lInverte,@cMarca, {004, 004, 112, 372}, , , oDlg1Sel, , )

          oBrw1Sel:oBrowse:lHasMark    := .T.
          oBrw1Sel:oBrowse:lCanAllmark := .F.
          oBrw1Sel:bMark := {||TMPSELMark()}

          oBtn2Sel   := TButton():New( 116, 220, "Dividir em 2", oDlg1Sel, { || aRet := {.t., 'S'}, fConfirmaSel(2,_cPed) }, 037, 012, , , , .T., , "", , , , .F. )
          oBtn3Sel   := TButton():New( 116, 288, "Dividir", oDlg1Sel, { || aRet := {.t., 'S'}, fConfirmaSel(1,_cPed) }, 037, 012, , , , .T., , "", , , , .F. )
          oBtn1Sel   := TButton():New( 116, 336, "Sair"    , oDlg1Sel, { || aRet := {.f., 'S'}, oDlg1Sel:End()         }, 037, 012, , , , .T., , "", , , , .F. )
          oDlg1Sel:Activate(,,,.T.)
          If Len(aRet) == 0
             aRet := {.f., 'S'}
          Endif
       Endif
       DbSelectArea("TMPSEL")
       DbCloseArea()
       If ValType( oTempTable ) == 'O'
          oTempTable:Delete()
       Endif
	/*
	aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })
	aEval(Directory("tmp*.fpt"), { |aFile| FERASE(aFile[F_NAME]) })
	aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })
	*/
	restarea(aArea)
Return aRet

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±À
Function    ³ oTbl1Sel() - Cria temporario para o Alias: TMPSEL
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ */
Static Function oTbl1Sel(_cPed)
       Local aFds  := {}
       //Local cTmp
       Local cQuery, lRet
       Local aArea := GetArea()
       lRet        := .t.

       Aadd( aFds, {"SELEC" , "C", 002, 000} )
       Aadd( aFds, {"CODPRO" , "C", TamSX3("C6_PRODUTO")[1], 000} )
       Aadd( aFds, {"DESCRPRO" , "C", TamSX3("B1_DESC")[1], 000} )
       Aadd( aFds, {"ITEM" , "C", TamSX3("C6_ITEM")[1], 000} )
       Aadd( aFds, {"DISPONIVEL" , "N", TamSX3("B2_QATU")[1], TamSX3("B2_QATU")[2]} )
       Aadd( aFds, {"ORDEM" , "C", 7, 000} )

//       cTmp := U_NovoArqTrab("dbf")
//       dbcreate(cTmp+".dbf",aFds,"DBFCDXADS")
//       USE (cTmp+".dbf") ALIAS TMPSEL VIA "DBFCDXADS" NEW
//       DbCreateIndex(cTmp+".cdx", "ORDEM", {||"ORDEM"} )
//       DbClearInd()
//       DbSetIndex(cTmp)
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 24/09/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       oTempTable := FWTemporaryTable():New( "TMPSEL" )
       oTemptable:SetFields( aFds )
       oTempTable:AddIndex( "cInd01", { "ORDEM" } )
       oTempTable:Create()
       DbSelectArea( "TMPSEL" )
       DbSetOrder(1)
       /********************************************************************************************************************************/

       cQuery := "SELECT C6_PRODUTO AS CODPRO,B1_DESC AS DESCRPRO,C6_ITEM AS ITEM,"+;
       "QTDLIB = ISNULL((SELECT C9_QTDLIB FROM "+RetSqlName("SC9")+" WITH (NOLOCK) WHERE (D_E_L_E_T_ <> '*') AND (C9_FILIAL = SC6.C6_FILIAL) AND "+;
       "(C9_PEDIDO = SC6.C6_NUM) AND (C9_ITEM = SC6.C6_ITEM) AND (C9_PRODUTO = SC6.C6_PRODUTO) AND (C9_BLOQUEI = '') AND "+;
       "(C9_BLCRED = '') AND (C9_BLEST = '')),0) "+;
       "FROM "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) "+;
       "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ = '') AND (C6_FILIAL = B1_FILIAL) AND (C6_PRODUTO = B1_COD) "+;
       "WHERE (SC6.D_E_L_E_T_ = '') AND (C6_FILIAL = '"+xFilial("SC6")+"') AND (C6_NUM = '"+_cPed+"') AND (C6_NOTA = '') "+;
       "ORDER BY CODPRO,ITEM"
       TCQuery cQuery ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMPSEL", .t.)
                TMPSEL->CODPRO := TCQ->CODPRO
                TMPSEL->DESCRPRO := TCQ->DESCRPRO
                TMPSEL->ITEM := TCQ->ITEM
                TMPSEL->DISPONIVEL := U_DetSaldo(TCQ->CODPRO)+TCQ->QTDLIB
                TMPSEL->ORDEM := IIF(TMPSEL->DISPONIVEL <= 0,'0','1')+alltrim(TCQ->ITEM)
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       EndDo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMPSEL")
       DbGoTop()
       If TMPSEL->(RecCount()) <= 0
          lRet := .f.
       Endif
       restarea(aArea)
Return(lRet)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ TMPSELMark() - Funcao para marcar o MsSelect
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function TMPSELMark()
       RecLock("TMPSEL",.F.)
          If Marked("SELEC")
             TMPSEL->SELEC := cMarca
          Else
             TMPSEL->SELEC := ""
          Endif
       MSUNLOCK()

       oBrw1Sel:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fConfirmaSel() - Funcao para confirmar seleção de ITENS DO PEDIDO
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fConfirmaSel( _nOpc, _cPed )
       Local aAuxSel, nContItens, nContMark, lContinua, i, nPular, nTam
       //Local nPos
       Local aArea := GetArea()
       Local aCab, aCab2, aItens1, aItens2, aLinha, cDoc, cVend, nReg, cPedRepr, nOrdem
       Local nOrdC6, nRegC6, lRegC6, cObs := "", aLiberacoes := {}
       //Local _nPorcComiss, _nPorcLucro, _nMedComiss, _nMedLucro
       Local nDesc1, nDesc2, nDesc3, nDesc4,cAuxMail,cRazao
       Private lMsErroAuto, lMsHelpAuto := .t.

       lContinua := .t.
       aAuxSel := {}
       nContItens := 0
       nContMark := 0
       DbSelectArea("TMPSEL")
       DbGoTop()
       While !Eof()
             nContItens++
             If MarKed("SELEC")
                nContMark++
                aAdd(aAuxSel, { TMPSEL->CODPRO, TMPSEL->ITEM } )
             ENDIF
             DbSelectArea("TMPSEL")
             DbSkip()
       EndDo
       DbSelectArea("TMPSEL")
       DbGoTop()
       if nContItens > 0 .and. (nContItens == nContMark)
          lContinua := .f.
          Messagebox("Não é permitida a seleção de TODOS os itens!", "Atenção...", 16)
       endif
       if nContItens < 2
          lContinua := .f.
          Messagebox("Não há o que separar!", "Atenção...", 16)
       Endif

       if lContinua
          if _nOpc == 2
             nPular := round(nContItens/2,0)
             nContMark := 0
             aAuxSel := {}
             DbSelectArea("TMPSEL")
             DbGoTop()
             dbskip(nPular)
             while !eof()
                   nContMark++
                   aAdd(aAuxSel, { TMPSEL->CODPRO, TMPSEL->ITEM } )
                   dbskip()
             enddo
          endif
       endif
       if lContinua .and. (nContMark == 0)
          lContinua := .f.
          Messagebox("Não há o que separar!", "Atenção...", 16)
       endif
       if lContinua
          lContinua := iif(Messagebox("Confirma a divisão do pedido?","Confirme!",4) == 6,.t.,.f.)
       endif

       if lContinua
          aCab := DetCampos("SC5")
          aCab2 := DetCampos("SC5")
          aItens1 := {}
          aItens2 := {}
          dbselectarea("SC6")
          nOrdC6 := IndexOrd()
          if !eof() .and. !Bof()
             lRegC6 := .t.
             nRegC6 := recno()
          else
             lRegC6 := .f.
          endif
          dbsetorder(1)
          for i := 1 to nContMark
              aLinha := {}
              aadd(aLinha,{"LINPOS","C6_ITEM",aAuxSel[i,2]})
			      aadd(aLinha,{"AUTDELETA","S",.F.})
              aadd(aItens1,aLinha)

              aLinha := {}
              dbselectarea("SC6")
              dbseek(xFilial("SC6")+_cPed+aAuxSel[i,2])
              if found()
                 /*
                 aAdd(aLinha, {"C6_ITEM"   , VerNumItem(i)                       , Nil})
                 aadd(aLinha,{"AUTDELETA","N",Nil})
                 aadd(aLinha,{"C6_PRODUTO",SC6->C6_PRODUTO,Nil})
                 aadd(aLinha,{"C6_QTDVEN",SC6->C6_QTDVEN,Nil})
                 aadd(aLinha,{"C6_PRCVEN",SC6->C6_PRCVEN,Nil})
                 aadd(aLinha,{"C6_TES",SC6->C6_TES,Nil})
                 aadd(aLinha,{"C6_CF",SC6->C6_CF,Nil})
                 aadd(aLinha,{"C6_CLASFIS",SC6->C6_CLASFIS,Nil})
                 aadd(aLinha,{"C6_NUMORC",SC6->C6_NUMORC,Nil})
                 aadd(aLinha,{"C6_LOCALIZ",SC6->C6_LOCALIZ,Nil})
                 //aadd(aLinha,{"C6_COMIS1",SC6->C6_COMIS1,Nil})
                 aadd(aLinha,{"C6_ENTREG",SC6->C6_ENTREG,Nil})
                 aadd(aLinha,{"C6_PEDCLI",SC6->C6_PEDCLI,Nil})
                 aadd(aLinha,{"C6_OP",SC6->C6_OP,Nil})
                 aadd(aLinha,{"C6_VOLITEM",SC6->C6_VOLITEM,Nil})
                 aadd(aLinha,{"C6_PALLET",SC6->C6_PALLET,Nil})
                 aadd(aLinha,{"C6_VLRLUCR",SC6->C6_VLRLUCR,Nil})
                 aadd(aLinha,{"C6_LUCRESP",SC6->C6_LUCRESP,Nil})
                 aadd(aLinha,{"C6_XVLRFRE",SC6->C6_XVLRFRE,Nil})
                 //aAdd(aLinha, {"C6_ITEM"   , VerNumItem(i)                       , Nil})
                 aadd(aItens2,aLinha)
                 */
	aLinha := U_DetCposTab("SC6","C6_FILIAL-C6_ITEM-C6_NUM-C6_BLOQUEI-C6_BLQ-C6_GEROUPV-C6_QTDEMP-C6_QTDEMP2-C6_QTDENT-C6_QTDENT2-C6_QTDLIB-C6_QTDLIB2-C6_QTDRESE-C6_SLDALIB-C6_SUGENTR-C6_TRT")
	aAdd(aLinha, {"C6_ITEM"   , VerNumItem(i)                       , .F.})
	aadd(aLinha,{"AUTDELETA","N",.F.})
	aadd(aItens2,aLinha)
endif
next
dbselectarea("SC6")
dbsetorder(nOrdC6)
if lRegC6
	dbgoto(nRegC6)
endif
aadd(aCab2,{"C5_PEDDIV"   ,_cPed,.F.})
aadd(aCab,{"C5_NUM"   ,_cPed,.F.})
DbSelectArea("SC5")
nOrdem := IndexOrd()
nReg := recno()
dbsetorder(1)
dbseek(xFilial("SC5")+_cPed)
if found()
	cVend := SC5->C5_VEND1
	IF SC5->C5_TIPO = "N"
		cRazao := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,"A1_NOME")
	ELSE
		cRazao := Posicione("SA2",1,xFilial("SA2")+SC5->C5_CLIENTE,"A2_NOME")
	ENDIF
	cPedRepr := SC5->C5_PEDREPR
	M->C5_OBS := MSMM(SC5->C5_OBSSC5)
	cObs := M->C5_OBS
	aLiberacoes := DetLibera()
ELSE
	cRazao := ""
	cVend := ""
	cPedRepr := ""
ENDIF
if !empty(cVend) .and. !empty(cPedRepr)
	DbSelectArea("SC5")
	DbOrderNickName("SC5001")
	cAux := alltrim(str(9-val(substr(cPedRepr,1,1))))
	nTam := TamSX3("C5_PEDREPR")[1]
	cPedRepr := cAux+substr(cPedRepr,2,nTam-1)
	DbSeek(xFilial("SC5")+cVend+cPedRepr)
	while found()
		cAux := substr(cPedRepr,1,6)
		cAux := padl(alltrim(str(val(cAux)+1)),6,"0")
		cPedRepr := cAux+right(cPedRepr,nTam-6)
		DbSeek(xFilial("SC5")+cVend+cPedRepr)
	enddo
	aadd(aCab2,{"C5_PEDREPR"   ,cPedRepr,.F.})
endif
aadd(aCab2,{"C5_X_PVSIM"   ,"",.F.})
DbSelectArea("SC5")
DbSetOrder(nOrdem)
dbgoto(nReg)

cDoc := GetSxeNum("SC5","C5_NUM")
RollBAckSx8()

aadd(aCab2,{"C5_NUM"   ,cDoc,.F.})
DbSelectArea("SC5")
DbSetOrder(1)
dbseek(xFilial("SC5")+_cPed)
if found()
	RecLock("SC5",.f.)
	nDesc1 := SC5->C5_DESCON1
	nDesc2 := SC5->C5_DESCON2
	nDesc3 := SC5->C5_DESCON3
	nDesc4 := SC5->C5_DESCON4
	SC5->C5_DESCON1 := 0
	SC5->C5_DESCON2 := 0
	SC5->C5_DESCON3 := 0
	SC5->C5_DESCON4 := 0
	MsUnLock()
endif

BEGIN TRANSACTION
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
	aadd(aCab2,{"C5_OBS"   ,"PEDIDO DIVIDIDO."+CHR(13)+CHR(10)+cObs,.F.})
	MsgRun("Incluindo novo pedido...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab2, aItens2, 3 ) } )
	If lMsErroAuto
		MostraErro()
	else
		DbSelectArea("SC5")
		DbSetOrder(1)
		dbseek(xFilial("SC5")+_cPed)
                   /*
                   if found()
                      RecLock("SC5",.f.)
                         nDesc1 := SC5->C5_DESCON1
                         nDesc2 := SC5->C5_DESCON2
                         nDesc3 := SC5->C5_DESCON3
                         nDesc4 := SC5->C5_DESCON4
                         SC5->C5_DESCON1 := 0
                         SC5->C5_DESCON2 := 0
                         SC5->C5_DESCON3 := 0
                         SC5->C5_DESCON4 := 0
                      MsUnLock()
                   endif
*/
		lMsErroAuto := .f.
		lMsHelpAuto := .f.
		MsgRun("Excluindo itens do ped atual...", "Aguarde", {|| MsExecAuto( { |x, y, z| MATA410(x, y, z) }, aCab, aItens1, 4 ) } )
		If lMsErroAuto
			MostraErro()
		endif
		DbSelectArea("SC5")
		DbSetOrder(1)
		dbseek(xFilial("SC5")+_cPed)
		if found()
			RecLock("SC5",.f.)
			SC5->C5_DESCON1 := nDesc1
			SC5->C5_DESCON2 := nDesc2
			SC5->C5_DESCON3 := nDesc3
			SC5->C5_DESCON4 := nDesc4
			MsUnLock()
		endif
	EndIf

	If !lMsErroAuto
		lMsErroAuto := !VoltaLiberacoes(aLiberacoes)
		If lMsErroAuto
			MostraErro()
		endif
	endif
	if lMsErroAuto
		restarea(aArea)
		//return(.t.) //LGS#20200212 - Adequação de release 12.1.25 e posteriores - Não pode ser usado Return dentro de begin transaction.
	endif
END TRANSACTION

PreencheLiberacoes(aLiberacoes)
endif
//Enviar e-mail avisando que pedido foi dividido e deverá passar por nova liberação
if lContinua .and. !empty(cVend)
	cAuxMail := alltrim(UsrRetMail(__cUserId))
	dbselectarea("SA3")
	dbsetorder(1)
	dbseek(xFilial("SA3")+cVend)
	if found()
		if !empty(alltrim(SA3->A3_EMAIL))
			if !empty(cAuxMail)
				cAuxMail += ","
			endif
			cAuxMail += alltrim(SA3->A3_EMAIL)
		endif
	endif
	cTexto := "ATENÇÃO! O Pedido "+_cPed+"-"+ALLTRIM(cRazao)+", da filial "+xFilial("SC5")
	cTexto += ", foi dividido e o novo pedido gerado terá que passar por nova liberação! "+chr(13)+chr(10)
	cTexto += "Número do pedido novo gerado: "+cDoc
	//U_EnvMail("Pedido "+_cPed+" foi DIVIDIDO!!",cTexto,"vendas@brasilux.com.br",cAuxMail,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
	MsgAlert(cAuxMail)
	//U_EnvMail("Pedido "+_cPed+" foi DIVIDIDO!!",cTexto,"neliedercorneta@brasilux.com.br",cAuxMail,"") //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data


endif
restarea(aArea)
oDlg1Sel:End()
Return .t.

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ DetCampos()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function DetCampos( cAlias )
       Local aArea := GetArea()
       Local aCampos := {},cAux,xValor
       Local _lOpen        := .F. //LGS#20200212 - Adequação para release 12.1.25
       Local _cAliasSX3 := GetNextAlias() //LGS#20200212 - Adequação para release 12.1.25

       // ABERTURA DO DICIONÁRIO SX3 - LGS#20200212 - Adequação para release 12.1.25
       OpenSXs( NIL, NIL, NIL, NIL, Nil, _cAliasSX3, "SX3", NIL, .F. )
       _lOpen := Select( _cAliasSX3 ) > 0
       If !_lOpen //LGS#20200212 - Adequação para release 12.1.25
          MessageBox( "Não foi possível abrir dicionário de dados.", "Atenção", 16 )
          Return
       Endif
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 12/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*dbSelectArea("SX3")
       dbSetOrder(1)
       dbSeek( cAlias )
       While !EOF() .And. X3_ARQUIVO = cAlias
             If X3Uso(X3_USADO) .AND. !(X3_CONTEXT = "V") .and. !(ALLTRIM(X3_CAMPO) == "C5_PEDREPR") .and. !(ALLTRIM(X3_CAMPO) == "C5_X_PVSIM") .AND. !(ALLTRIM(X3_CAMPO) == "C6_FILIAL") .AND. !(ALLTRIM(X3_CAMPO) == "C6_ITEM") .AND. !(ALLTRIM(X3_CAMPO) == "C6_NUM") .AND. !(ALLTRIM(X3_CAMPO) == "C5_FILIAL") .AND. !(ALLTRIM(X3_CAMPO) == "C5_PEDDIV") .AND. !(ALLTRIM(X3_CAMPO) == "C5_NUM")
                cAux := alltrim(cAlias)+"->"+X3_CAMPO
                xValor := &cAux
                if !empty(xValor)
                   aadd(aCampos,{X3_CAMPO   ,xValor,.F.})
                endif
             Endif
             dbSelectArea("SX3")
             dbSkip()
       End*/
       dbSelectArea( _cAliasSX3 )
       ( _cAliasSX3 )->( dbSetOrder(1) )
       ( _cAliasSX3 )->( dbSeek( cAlias ) )
       While !EOF() .And. ( _cAliasSX3 )->( X3_ARQUIVO ) = cAlias
             If X3Uso( ( _cAliasSX3 )->( X3_USADO ) ) .AND. !( ( _cAliasSX3 )->( X3_CONTEXT ) = "V") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_DESCON1") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_DESCON2") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_DESCON3") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_DESCON4") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_PEDREPR") .and. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_X_PVSIM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_FILIAL") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_ITEM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C6_NUM") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_FILIAL") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_PEDDIV") .AND. !( ALLTRIM( ( _cAliasSX3 )->( X3_CAMPO ) ) == "C5_NUM")
                cAux   := Alltrim( cAlias ) + "->" + ( _cAliasSX3 )->( X3_CAMPO )
                xValor := &cAux
                if !empty(xValor)
                   aadd( aCampos, { ( _cAliasSX3 )->( X3_CAMPO ), xValor, .F. } )
                endif
             Endif
             dbSelectArea( _cAliasSX3 )
             ( _cAliasSX3 )->( dbSkip() )
       End
       DbSelectArea( _cAliasSX3 )
       DbCloseArea()
       /********************************************************************************************************************************/
       RestArea(aArea)
Return(aCampos)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ VerNumItem()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function VerNumItem(i)
       Local cRet
       If i < 100
          cRet = padl(Alltrim(Str(i)),2,"0")
       Else
          cRet = Alltrim(Str(i))
          cRet = SubStr(cRet, Len(cRet), 1)
          cRet = Chr(Int((i - 100)/10)+65) + cRet
       Endif
return(cRet)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ DetLibera()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function DetLibera()
       Local aLibs := {}
       aadd( aLibs, { "C5_NUM"    , SC5->C5_NUM    } )
       aadd( aLibs, { "C5_LIBCAD" , SC5->C5_LIBCAD } )
       aadd( aLibs, { "C5_USRCAD" , SC5->C5_USRCAD } )
       aadd( aLibs, { "C5_LIBPED" , SC5->C5_LIBPED } )
       aadd( aLibs, { "C5_USRPED" , SC5->C5_USRPED } )
       aadd( aLibs, { "C5_LIBCRE" , SC5->C5_LIBCRE } )
       aadd( aLibs, { "C5_USRCRE" , SC5->C5_USRCRE } )
       aadd( aLibs, { "C5_LIBDIR" , SC5->C5_LIBDIR } )
       aadd( aLibs, { "C5_USRDIR" , SC5->C5_USRDIR } )
       aadd( aLibs, { "C5_APROVA" , SC5->C5_APROVA } )
       aadd( aLibs, { "C5_USRAPR" , SC5->C5_USRAPR } )
       aadd( aLibs, { "C5_PORCOM" , SC5->C5_PORCOM } )
       aadd( aLibs, { "C5_LUCRO"  , SC5->C5_LUCRO  } )
       aadd( aLibs, { "C5_MEDCOM" , SC5->C5_MEDCOM } )
       aadd( aLibs, { "C5_MEDLUCR", SC5->C5_MEDLUCR} )
       aadd( aLibs, { "C5_COMIS1", SC5->C5_COMIS1} )
return(aLibs)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ VoltaLiberacoes()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function VoltaLiberacoes(aLiberacoes)
          Local aArea := getarea()
       Local cPedDiv := "",_cPed,cQuery,lRet := .t.

       _cPed := aLiberacoes[1,2]
       dbselectarea("SC5")
       dbsetorder(1)
       dbseek(xFilial("SC5")+_cPed)
       if found()
          cQuery := "SELECT C5_NUM AS PEDDIV FROM "+RetSqlName("SC5")+" SC5 WHERE (D_E_L_E_T_ <> '*') AND "+;
          "(C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_PEDDIV = '"+_cPed+"')"
          TCQuery cQuery ALIAS "TCQ" NEW

          DbSelectArea("TCQ")
          if !eof() .and. !bof()
             cPedDiv := ALLTRIM(TCQ->PEDDIV)
          endif
          dbclosearea()
          if aLiberacoes[4,2] = "T"
             lRet := U_LiberaPed(_cPed)
             //Chamado 020237-> Não liberar mais pedido dividido
             /*
             IF lRet .and. !empty(cPedDiv)
                lRet := U_LiberaPed(cPedDiv)
             Endif
             */
endif
endif
restarea(aArea)
return(lRet)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ VerNumItem()
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function PreencheLiberacoes(aLiberacoes)
       //Local aArea := getarea()
       Local cPedDiv := "",_cPed,cQuery,_cPorcComiss,_cPorcLucro,_cMedLucro,_cComis1
       //Local _nVlrComiss, _nMedComiss, lRet := .t.
       _cPed := aLiberacoes[1,2]
       cQuery := "SELECT C5_NUM AS PEDDIV FROM "+RetSqlName("SC5")+" SC5 WHERE (D_E_L_E_T_ <> '*') AND "+;
       "(C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_PEDDIV = '"+_cPed+"')"
       TCQuery cQuery ALIAS "TCQ" NEW

       DbSelectArea("TCQ")
       if !eof() .and. !bof()
          cPedDiv := ALLTRIM(TCQ->PEDDIV)
       endif
       dbclosearea()
       _cPorcComiss := alltrim(str(aLiberacoes[12,2],TamSx3("C5_PORCOM")[1],TamSx3("C5_PORCOM")[2]))
       _cComis1 := alltrim(str(aLiberacoes[16,2],TamSx3("C5_COMIS1")[1],TamSx3("C5_COMIS1")[2]))
       _cPorcLucro := alltrim(str(aLiberacoes[13,2],TamSx3("C5_LUCRO")[1],TamSx3("C5_LUCRO")[2]))
       _cMedComiss := alltrim(str(aLiberacoes[14,2],TamSx3("C5_MEDCOM")[1],TamSx3("C5_MEDCOM")[2]))
       _cMedLucro := alltrim(str(aLiberacoes[14,2],TamSx3("C5_MEDLUCR")[1],TamSx3("C5_MEDLUCR")[2]))

       cQuery := "UPDATE "+RetSqlName("SC5")+" SET C5_LIBCAD = '"+TRIM(aLiberacoes[2,2])+"',"+;
       "C5_USRCAD = '"+TRIM(aLiberacoes[3,2])+"',"+;
       "C5_LIBPED = '"+TRIM(aLiberacoes[4,2])+"',"+;
       "C5_USRPED = '"+TRIM(aLiberacoes[5,2])+"',"+;
       "C5_LIBCRE = '"+TRIM(aLiberacoes[6,2])+"',"+;
       "C5_USRCRE = '"+TRIM(aLiberacoes[7,2])+"',"+;
       "C5_LIBDIR = '"+TRIM(aLiberacoes[8,2])+"',"+;
       "C5_USRDIR = '"+TRIM(aLiberacoes[9,2])+"',"+;
       "C5_APROVA = '"+TRIM(aLiberacoes[10,2])+"',"+;
       "C5_USRAPR = '"+TRIM(aLiberacoes[11,2])+"',"+;
       "C5_PORCOM = "+_cPorcComiss+","+;
       "C5_COMIS1 = "+_cComis1+","+;
       "C5_LUCRO = "+_cPorcLucro+","+;
       "C5_MEDCOM = "+_cMedComiss+","+;
       "C5_MEDLUCR = "+_cMedLucro+","+;
       "C5_VLRCOM = ROUND("+_cComis1+"*C5_VLRDUP/100,"+ALLTRIM(STR(TamSx3("C5_VLRCOM")[2]))+") "+;
       "WHERE "+;
       "(D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = '"+_cPed+"')"
       TCSQLExec(cQuery)
       //Chamado 020237 -> Não voltar liberação de pedido dividido!
       /*
       if !empty(cPedDiv)
          cQuery := "UPDATE "+RetSqlName("SC5")+" SET C5_LIBCAD = '"+TRIM(aLiberacoes[2,2])+"',"+;
          "C5_USRCAD = '"+TRIM(aLiberacoes[3,2])+"',"+;
          "C5_LIBPED = '"+TRIM(aLiberacoes[4,2])+"',"+;
          "C5_USRPED = '"+TRIM(aLiberacoes[5,2])+"',"+;
          "C5_LIBCRE = '"+TRIM(aLiberacoes[6,2])+"',"+;
          "C5_USRCRE = '"+TRIM(aLiberacoes[7,2])+"',"+;
          "C5_LIBDIR = '"+TRIM(aLiberacoes[8,2])+"',"+;
          "C5_USRDIR = '"+TRIM(aLiberacoes[9,2])+"',"+;
          "C5_APROVA = '"+TRIM(aLiberacoes[10,2])+"',"+;
          "C5_USRAPR = '"+TRIM(aLiberacoes[11,2])+"',"+;
          "C5_PORCOM = "+_cPorcComiss+","+;
          "C5_COMIS1 = "+_cComis1+","+;
          "C5_LUCRO = "+_cPorcLucro+","+;
          "C5_MEDCOM = "+_cMedComiss+","+;
          "C5_MEDLUCR = "+_cMedLucro+","+;
          "C5_VLRCOM = ROUND("+_cComis1+"*C5_VLRDUP/100,"+ALLTRIM(STR(TamSx3("C5_VLRCOM")[2]))+") "+;
          "WHERE "+;
          "(D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = '"+cPedDiv+"')"
          TCSQLExec(cQuery)
       endif
       */
return(.t.)

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MENU410() - Utilizado na Tecpolpa
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
User Function MENU410()
     Local _cMensagem := Space(3)

     @ 0,0 TO 200,400 DIALOG oDlg TITLE "Mensagem"
     @ 10,10 SAY "Mensagem" 
     @ 10,40 Get _cMensagem Size 20,10 F3 "SM4"
     @ 65,150 BUTTON "Ok" SIZE 35,15 ACTION Grava(oDlg, _cMensagem)
     ACTIVATE DIALOG oDlg CENTER

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ Grava() - Utilizado na Tecpolpa
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function Grava (oDlg, _cMensagem)
       If MSGYESNO( "Deseja alterar a mensagem padrão da Danfe do pedido "+SC5->C5_NUM+"? ", "MA410MNU" ) // MSG
          RecLock("SC5",.F.)
             SC5->C5_MENPAD := _cMensagem
          MsUnlock()
       Endif
       Close(oDlg)
Return

// jose 13/01/2025
//Ultimas modificações realizadas por Lucas Bonfim. Adequação com release 25. 16-06-2026
User Function DuplicaPedido()

   Local aArea          := FWGetArea()
   Local nNovoPedido    := 0
   Local nPedidoOrig    := SC5->C5_NUM    // Número do pedido Original
   Local nFilialOrig    := SC5->C5_FILIAL // Número da filial Original
   Local cFilialDest    := "010101"       // Numero da filial Destino
   Local cObs           := "ENVIO DE MERCADORIA DE ARARAQUARA PARA GUARULHOS (TRIANGULA COM MATÃO) -> REPLICA DO PEDIDO  "+SC5->C5_NUM+" / NF / "+SC5->C5_NOTA
   Local cChvNfe        :=""
   Local aProdBloq      := {}
   Local aProdNVend     := {}
   
   Local _aCab 
   Local _aItens
   Local _aLinha

   // //1. Faz o backup das variáveis públicas //ANDRE
   // Private cEmpBkp      := cEmpAnt
   // Private cFilBkp      := cFilAnt
   // Private cNumEmpBkp   := cNumEmp
   // //Private nW :=0
   // //---------------------------------------------------------------------------------------//
   // // Muda para a filial desejada
   
   // //2. Altera as variáveis públicas ANDRE
   // cEmpAnt := "01"
   // cFilAnt := "010101"
   // cNumEmp := cEmpAnt + cFilAnt
   // OpenFile(cNumEmp)
   
   // nNovoPedido :=GetSXENum("SC5", "C5_NUM")
   
   // //5. Volta o backup das variáveis
   // cEmpAnt := cEmpBkp
   // cFilAnt := cFilBkp
   // cNumEmp := cEmpAnt + cFilAnt
   // OpenFile(cNumEmp)
   //---------------------------------------------------------------------------------------//
   
   Private cNovoCliente := "023818" // Código do novo CLIENTE
   Private cLoja        := "01"     // Código da nova LOJA
   Private cNovaTES     := "823"    // Código da nova TES
   Private cNovoTipo    := "N"      // Código do novo TIPO

   If SC5->C5_FILIAL <>"010108"
      MsgInfo("Rotina permitida apenas a filial Depósito Araraquara !!")
      Return
   Endif

   If LEN(TRIM(SC5->C5_PEDDEP)) >0
      MsgInfo("Atenção, não é possível gerar novamente o pedido de transferência na Matriz, pedido já gerado anteriormente ----> : "+cValToChar(SC5->C5_PEDDEP))
      Return
   Endif

   If LEN(TRIM(SC5->C5_NOTA)) == 0
      MsgInfo("Fature o pedido e dê entrada na nota fiscal antes de realizar esse procedimento !!")
      Return
   Else
      DbSelectarea("SF2")
      DbOrderNickName("SF2001") //F2_FILIAL+F2_PEDIDO  
      Dbseek(xFilial("SF2")+SC5->C5_NUM)  
      cChvNfe := SF2->F2_CHVNFE
   Endif

   DbSelectArea("SF1")
   DbSetOrder(8)
   DbSeek("010101"+cChvNfe)
   If !found() .OR. Len(TRIM(cChvNfe))=0
      MsgInfo("Falta entrada da nota fiscal na Matriz, realize a entrada da nota fiscal antes de tentar replicar o pedido !!")
      Return
   Endif

   nNovoPedido := GetSXENum("SC5", "C5_NUM", , 1, "01", "010101")

   DbSelectArea("SC5")
   DbSetOrder(1)
   DbSeek(xFilial("SC5")+nPedidoOrig)

   _aCab := {{"C5_FILIAL" ,cFilialDest                                                          ,NIL},;
            {"C5_NUM"    ,cValToChar(nNovoPedido)                                               ,NIL},;
            {"C5_TIPO"   ,cNovoTipo                                                             ,NIL},;
            {"C5_CLIENTE",cNovoCliente                                                          ,NIL},;
            {"C5_LOJACLI",cLoja                                                                 ,NIL},;
            {"C5_CONDPAG",SC5->C5_CONDPAG                                                       ,NIL},;
            {"C5_TABELA" ,SC5->C5_TABELA                                                        ,NIL},;
            {"C5_TRANSP" ,"00250"                                                            	,Nil},;
     	   	{"C5_OBS"    ,	cObs                                                                 ,Nil},;
            {"C5_X_OBSFA",	cObs                                                            	   ,Nil},;
            {"C5_DEPOSI",	"A"                                                            	   ,Nil},;
   			{"C5_OBSNF"  ,"Transferência de Mercadoria para depósito fechado Guarulhos !! "    	,NIL},;
            {"C5_EMISSAO",Date()                                                                ,NIL}}

   // Posiciona no Cadastro do Produto
   DbSelectArea("SC6")
   DbSetOrder(1)
   DbSeek(xFilial("SC6")+nPedidoOrig)

   //Cria Vetor dos Itens
   _aItens := {}


   Do While !Eof() .and. SC6->C6_FILIAL==nFilialOrig .and. SC6->C6_NUM==nPedidoOrig

      _aLinha := {}

      AADD(_aLinha,{"C6_FILIAL" ,cFilialDest    ,NIL})
      AADD(_aLinha,{"C6_NUM"    ,cValToChar(nNovoPedido),NIL})
      AADD(_aLinha,{"C6_ITEM"   ,SC6->C6_ITEM   ,NIL})
      AADD(_aLinha,{"C6_PRODUTO",SC6->C6_PRODUTO,NIL})
      AADD(_aLinha,{"C6_DESCRI" ,SC6->C6_DESCRI ,NIL})
      AADD(_aLinha,{"C6_QTDVEN" ,SC6->C6_QTDVEN ,NIL})
      AADD(_aLinha,{"C6_PRCVEN" ,SC6->C6_PRCVEN ,NIL})
      AADD(_aLinha,{"C6_PRUNIT" ,SC6->C6_PRUNIT ,NIL})
      //AADD(_aLinha,{"C6_VALOR"  ,SC6->C6_VALOR  ,NIL})
      AADD(_aLinha,{"C6_TES"    ,cNovaTES       ,NIL})
      AADD(_aLinha,{"C6_UM"     ,SC6->C6_UM     ,NIL})
      AADD(_aLinha,{"C6_CLI"    ,cNovoCliente   ,NIL})
      AADD(_aLinha,{"C6_LOJA"   ,cLoja          ,NIL})

      AADD(_aItens,_aLinha)

      If Posicione("SB1", 1, '010101'+SC6->C6_PRODUTO, "B1_MSBLQL") ='1'
         aAdd(aProdBloq, {Alltrim(SC6->C6_PRODUTO)} )	
      Endif
      If Posicione("SB1", 1, '010101'+SC6->C6_PRODUTO, "B1_VEND") ='N'
         aAdd(aProdNVend, {Alltrim(SC6->C6_PRODUTO)} )
      Endif

      DbSelectArea("SC6")
      DbSkip()

   EndDo

   StartJob( "u_zGerPedD", GetEnvServer(), .F., _aCab, _aItens, aProdBloq, aProdNVend, nPedidoOrig, cObs, nNovoPedido)

   Processa({|| fMsgWarn(nPedidoOrig)}, "Aguarde...", "Gerando pedido de transferência na matriz...")
   
   If !Empty(AllTrim(SC5->C5_PEDDEP))
      ConfirmSX8()
      MsgInfo("Atenção, novo pedido gerado na filial Matriz, aprove e fature o pedido de número: "+SC5->C5_PEDDEP)
   Else
      RollbackSx8()
   EndIf

   FWRestArea(aArea)

Return 

Static Function fMsgWarn(nPedidoOrig)

   Local nX := 0

   For nX := 1 To 20

      IncProc("Aguardando confirmação da geração do pedido...")

      DbSelectArea("SC5")
      DbSetOrder(1)

      If DbSeek(xFilial("SC5") + nPedidoOrig)

         DbSkip(0)

         If !Empty(AllTrim(SC5->C5_PEDDEP))
            Exit
         EndIf

      EndIf

      Sleep(500)

   Next

Return
