#include 'protheus.ch'
#include 'topconn.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M410STTS  ºAutor  ³ Cleber Orati      º Data ³  28/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Está em todas as rotinas de alteração, inclusão, exclusão eº±±
±±º          ³ devolução de compras. Executado após todas as alterações noº±±
±±º          ³  arquivo de pedidos terem sido feitas.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function M410STTS() 

//Tamanho da Janela
Local nJanLarg  := 700 //730
Local nJanAltu  := 190 //500

//Fontes
Local cFontUti  := "Tahoma"
//Local oFontAno  := TFont():New(cFontUti, , -38)
Local oFontBtn  := TFont():New(cFontUti, , -14)
//Local oFontSub  := TFont():New(cFontUti, , -16)
//Local oFontSubN := TFont():New(cFontUti, , -20, , .T.)

Local oBtnFech
Local _nOper := PARAMIXB[1]

Private aMotivos  :={""}
Private oMotivos
Private cMotivos
Private oDlg

     u_zcfga01( 'M410STTS' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).
        If (INCLUI .OR. ALTERA)
           IF !EMPTY(M->C5_OBS)
              MSMM(SC5->C5_OBSSC5,     ,     , M->C5_OBS  , 1   ,         ,      , "SC5" , "C5_OBSSC5"             )
           ENDIF
           IF !EMPTY(M->C5_OBSNF)
              MSMM(SC5->C5_OBSNFS,     ,     , M->C5_OBSNF, 1   ,         ,      , "SC5" , "C5_OBSNFS"             )
           ENDIF          
           IF (cNumEmp = "01010101") .or. (cNumEmp = "01060101")
              U_EnviaRec("SC5",SC5->C5_NUM,.f.,SC5->C5_VEND1)      
           ENDIF 
        Endif 
//-----  Jose  10/08/2023 -------------------------------------------- 
     ELSE
         If alltrim(FWGrpCompany()) == '11' //Empresa do grupo 11(Tecpolpa).
            If _nOper == 5 //Eclusão
               // carrega tela para exclusão
               DEFINE MSDIALOG oDlg TITLE "Motivo da Exclusão" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME

               @ 010, 010 SAY OemToAnsi("Selecione um Motivo") SIZE 100,020 PIXEL OF oDlg FONT oFontBtn
               @ 020, 010 MSCOMBOBOX oMotivos VAR cMotivos ITEMS aMotivos SIZE 250, 010 OF oDlg COLORS 0, 16777215 PIXEL FONT oFontBtn
               ListMot()
               // Cancela fechar tela com ESC
               oDlg:lEscClose := .F.
               //aMotivos array
               //cMotivos variavel vai conter as informaçoes
               //oMotivos Objeto
               @ 020,300 BUTTON oBtnFech PROMPT "Salvar" SIZE 050, 010 OF oDlg ACTION SlvMoti() FONT oFontBtn PIXEL
               ACTIVATE MSDIALOG oDlg CENTERED
            EndIf
         Endif
      EndIf   

Return Nil

// função que carrega os motivos da tabela SX5 Z1
Static function ListMot()
   
   DbSelectArea("SX5")
   DbSetOrder(1)
   DbSeek(xFilial("SX5")+"Z1",.t.)
   If Found()
      While !Eof() .and. SX5->X5_TABELA == "Z1"
         aAdd(aMotivos,Alltrim(SX5->X5_CHAVE+" - "+SX5->X5_DESCRI))
         oMotivos:SetItems(aMotivos)
         DbSkip()
      Enddo
   Endif

return

// função que salva o motivo selecionado
Static function SlvMoti()
/**/
     DbSelectArea("ZAB")
     RecLock("ZAB", .T.)
       ZAB_FILIAL := SC5->C5_FILIAL
       ZAB_PEDIDO := SC5->C5_NUM
       ZAB_CLIENT := SC5->C5_CLIENTE
       ZAB_LOJA   := SC5->C5_LOJACLI
       ZAB_NOME   := SA1->A1_NOME
       ZAB_MOTIVO := SUBSTRING(cMotivos,1,6)
       ZAB_DESCRI := SUBSTRING(cMotivos,10,55)
     ZAB->(MsUnlock())
     oDlg:End()
   /**/
return 

