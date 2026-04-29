//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} CFG_EXEC
PERMITIR EXECUTAR RDMAKES SEM COLOCAR NO MENU UMA VEZ QUE NAO EXECUTA MAIS VIA FORMULA
@type function Processamento
@version  1.0
@author FURLAN-FABIO FURLAN
@since 03/12/2019
@return character, sem retorno
/*/ 
User Function CFG_EXEC()
    Local aArea      := FWGetArea()
    //Variáveis da tela
    Private oDlgForm
    Private oGrpForm
    Private oGetForm
    Private cGetForm := Space(250)
    Private oGrpAco
    Private oBtnExec
    //Tamanho da Janela
    Private nJanLarg := 500
    Private nJanAltu := 120
    Private nJanMeio := ((nJanLarg)/2)/2
    Private nTamBtn  := 048
     
    //Criando a janela
    DEFINE MSDIALOG oDlgForm TITLE "Execução rdmakes" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo Fórmula com o Get
        @ 003, 003  GROUP oGrpForm TO 30, (nJanLarg/2)-1        PROMPT "Fórmula: " OF oDlgForm COLOR 0, 16777215 PIXEL
        @ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 OF oDlgForm COLORS 0, 16777215 PIXEL
         
        //Grupo Ações com o Botão
        @ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "Ações: " OF oDlgForm COLOR 0, 16777215 PIXEL
        @ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExecuta()) PIXEL
         
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgForm CENTERED
     
    FWRestArea(aArea)
Return NIL

/*/{Protheus.doc} fExecuta
 Executa a fórmula digitada  
@type function Processamento
@version  1.00
@author FURLAN-FABIO FURLAN
@since 03/12/2019
@return character, sem retorno
/*/
Static Function fExecuta()
    Local aArea    := FWGetArea()
    Local cFormula := Alltrim(cGetForm)
    Local cError   := ""
    Local bError   := ErrorBlock({ |oError| cError := oError:Description})
     
    //Se tiver conteúdo digitado
    If .NOT. Empty(cFormula)
        //Inicio a utilização da tentativa
        Begin Sequence
            &("U_"+cFormula+"()")
        End Sequence
         
        //Restaurando bloco de erro do sistema
        ErrorBlock(bError)
         
        //Se houve erro, será mostrado ao usuário
        If .NOT. Empty(cError)
            MsgStop("Houve um erro na fórmula digitada: "+CRLF+CRLF+cError, "Atenção")
        EndIf
    EndIf
     
    FWRestArea(aArea)
Return Nil
