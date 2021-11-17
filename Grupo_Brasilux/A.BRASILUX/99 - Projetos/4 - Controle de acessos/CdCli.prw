#Include 'Protheus.CH'

User Function CdCli()

Local cVAlt := .T. //Valida Inclusão/Alteração
Local cVExc := 'u_VlExec()' //Valida Exclusão

AxCadastro ('SA1', 'CADASTRO NOME', cVAlt, cVExc)

Return Nil

User Function VlExc()

dbSelectArea('SA1')
dbOrderNickName('Nome do Cliente')
If dbSeek(xFilial('SA1') + SA1->A1_NOME)
MsgAlert('Atenção!!! Este cliente não pode ser excluído!')
Return .F.
EndIf

Return .F.


