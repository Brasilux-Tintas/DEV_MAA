#include "protheus.ch"
#include "topconn.ch"
#Translate MSGBOX( => IW_MsgBox(
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCP021 ºAutor  ³ Cleber O. Dominguesº Data ³  17/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para atualizar todos os Pesos Específicos e quanti- º±±
±±º          ³ dades de produtos à partir dos pesos específicos de matéri-º±±
±±º          ³ as primas.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRPCP021()
     //Local oDlg
     Local nOpca
     Local cCadastro
     Local aSays    := {}
     Local aButtons := {}
     //Local cMens1, cMens2

     If (cNumEmp == "01010104")
        MsgBox("Nada a executar!", "Atenção", "INFO")
        Return
     Endif

     aAdd(aSays, "Este programa irá atualizar o Peso Especifico e  ")
     aAdd(aSays, "as quantidades de todo o cadastro de produtos    ")
     aAdd(aSays, "baseado nos pesos específicos das Materias Primas")
     nOpca := 0
     cCadastro := OemToAnsi("Recalculo de Peso Específico")

     aAdd(aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
     aAdd(aButtons, { 2, .T., {|o| o:oWnd:End() }} )

     FormBatch( cCadastro, aSays, aButtons )

     If nOpcA == 1
        Processa({|lEnd| BRPC21()})
     Endif
Return  

Static Function BRPC21()      
       Local cQuery := ""
       cQuery += "SELECT SB1.B1_COD "
       cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
       cQuery += "WHERE SB1.B1_FILIAL  = '"+xFilial("SB1")+"' "
       cQuery += "  AND SB1.B1_TIPO    = 'MP' "
       cQuery += "  AND SB1.D_E_L_E_T_ = '' "
       cQuery += "ORDER BY SB1.B1_COD"
       TCQuery cQuery ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       ProcRegua(600, 21, 6)
       While !Eof()
             U_CalcPesoEsp(TCQ->B1_COD)
             DbSelectArea("TCQ")
             DbSkip()
             IncProc(TCQ->B1_COD)
       Enddo
       If Used()
          DbSelectArea("TCQ")
          DbCloseArea()
       Endif
Return
