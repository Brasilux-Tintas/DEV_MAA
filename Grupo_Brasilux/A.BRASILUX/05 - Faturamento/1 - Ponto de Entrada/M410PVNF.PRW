#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M410PVNF   ºAutor  ³ Cleber Orati      º Data ³  23/06/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Executado na tela de cad. de pedidos para gerar NF direta- º±±
±±º          ³ mente do cadastro, verificar se o pedido está liberado     º±±
±±º          ³ não deixar passar caso não esteja                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function M410PVNF()   
Local lRet := .T.

/*nelieder*/
Local cQry    := ""
Local aBrowse := {}
//Local cRet    := .T.

//Fontes
Local cFontUti  := "Tahoma"
Local oFontBtn  := TFont():New(cFontUti, , -14)

//Tamanho da Janela
Local nJanLarg  := 400
Local nJanAltu  := 250

u_zcfga01( 'M410PVNF' ) //LGS#2021201 - Gravação de log de utilização da rotina
IF (SC5->(FieldPos("C5_APROVA")) > 0)
   IF !(SC5->C5_APROVA = '1')
      lRet := .f.
      If GetEnvServer() == "C6ZBKW_002"
         lRet:=.T.
      End   
      MsgAlert("Pedido NÃO ESTÁ LIBERADO!","Aviso")
   ENDIF
  
   /* Incluido por Nelieder em 14/12/2022 */
   


   /* Parametro que habilita o bloqueio por saldo negativo */
   // incluido por nelieder em 03/02/2023
   if !GETMV("ZP_PAR0080") .OR. FWCodEmp() == '11'
      RETURN(lRet)
   EndIf


   // incluido por nelieder em 03/02/2023
   cQry := " SELECT C6_PRODUTO C9_PRODUTO,C6_LOCAL C9_LOCAL,SUM(C6_QTDVEN)C9_QTDLIB FROM SC5010 SC5 "
   cQry += " INNER JOIN SC6010 SC6 ON SC6.D_E_L_E_T_  <> '*' AND C6_NUM = C5_NUM AND C6_FILIAL = C5_FILIAL  "
   cQry += " INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_  <> '*' AND B1_COD = C6_PRODUTO AND B1_FILIAL = C6_FILIAL  "
   cQry += " INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_  <> '*' AND F4_CODIGO = C6_TES AND F4_ESTOQUE = 'S'  "
   cQry += " WHERE  SC5.D_E_L_E_T_ = '' AND C5_NUM = '"+SC5->C5_NUM+"' AND C5_TIPO = 'N' AND C5_FILIAL = '"+xFilial("SC5")+"' "
   cQry += " GROUP BY C5_NUM,C6_ITEM,C6_PRODUTO,C6_LOCAL,C6_QTDLIB "
     

   IF Select("TCQ") <> 0
      DbSelectArea("TCQ")
      DbCloseArea()
   ENDIF

   TCQuery cQry ALIAS "TCQ" NEW

   dbSelectArea("TCQ")
   TCQ->(dbGoTop())

   While !TCQ->(EoF())

      DbSelectArea("SB2")
      DbSetorder(1)
      DbSeek(xFilial("SB2")+(TCQ->C9_PRODUTO)+(TCQ->C9_LOCAL))
      nSaldo := SB2->B2_QATU//SaldoSb2()
      
      iF (nSaldo-TCQ->C9_QTDLIB) < 0
         
         aAdd(aBrowse, { ;
               TCQ->C9_PRODUTO,;
               TCQ->C9_QTDLIB,;
               TCQ->C9_LOCAL,;
               SB2->B2_QATU;
         })
         
      EndIf

      TCQ->(DbSkip())

   EndDo

   If len(aBrowse) > 0 

      lRet := .F.
      
      DEFINE MSDIALOG oDlg TITLE "Produto com saldo Negativo, não será possivel prosseguir !" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

      @ 105,005 BUTTON oBtnFech PROMPT "Sair" SIZE 050, 015 OF oDlg ACTION oDlg:End() FONT oFontBtn PIXEL

      oBrowse  := TCBrowse():New(005, 004, 200, 080, , {'Produto','Qtd Liberar','Local','Saldo Atual'}, {20,20,20,20}, oDlg, , , , , , , oFontBtn, , , , , .F., , .T., , .F., , ,)

      // Seta vetor para a browse
      oBrowse:SetArray(aBrowse)

      // Monta a linha a ser exibina no Browse
      oBrowse:bLine  := {||{    aBrowse[oBrowse:nAt,01],;
                                 aBrowse[oBrowse:nAt,02],;
                                 aBrowse[oBrowse:nAt,03],;
                                 aBrowse[oBrowse:nAt,04];
                              }}

      /* habilita fechar tela no botão esc */
      oDlg:lEscClose := .T.

      ACTIVATE MSDIALOG oDlg CENTERED

   EndIf    

   /* fim Nelieder*/

ENDIF 

RETURN(lRet)


