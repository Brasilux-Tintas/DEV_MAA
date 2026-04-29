#INCLUDE "RWMAKE.CH"

User Function M185BAIX()

    Local aArea    := FWGetArea() as Array
    Local cMessage := ""          as Character
    Local lOk      := .F.         as Logical

    Public cUserID := ""          as Character

    //Exibe a tela para que o usuário informe o login e senha
    lOk := FWAuthUser(@cUserID)

    //Incrementa a mensagem
    If lOk
        cMessage := "Deu tudo certo, o código do usuário é " + cUserID + " ( " + UsrRetName(cUserID) + " )"
    Else
        cMessage := "Não deu certo, usuário clicou no cancelar ou fechar!"
    EndIf

    //Exibe a mensagem
    FWAlertInfo(cMessage, "Atenção")

    FWRestArea(aArea)
Return (lOk)
