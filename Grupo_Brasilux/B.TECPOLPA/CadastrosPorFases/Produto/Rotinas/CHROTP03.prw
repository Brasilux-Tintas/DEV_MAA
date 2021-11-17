#include "rwmake.ch"
#Include "SigaWin.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

/**
Chamado no ponto de entrada MT010CAN para realizar as tarefas apos o
fim da inclusao / alteracao do produto
**/


User Function CHROTP03()

Local _aArea := GetArea()

Local etapa := 0

Local nOpc 		:= 1 // ParamIxb[1]//  TRATAMENTOS DO USUÁRIO.

//Armazena a etapa atual antes de verificar se houve uma mudanca de etapa
Local _nEtapaAnt:= SB1->B1_XCETAPA

//Parametro para armazenar o numero maximo de etapas da setorizacao do cadastro de produtos
Local _nMaxEtapa:= 0 //  GetMv("MV_XMAXETP")

// Armazena em qual etapa atingida será liberado automaticamente o cadastro de produto.
Local _nEtapaLib:= 0 // + 1 //GetMv("CH_ETAPLIB")

If (Altera .OR. Inclui ) .And. nOpc == 1
	 _nMaxEtapa:=  U_CHROTG11("P")
	 _nEtapaLib:= _nMaxEtapa + 0
Endif

//se incluiu e a etapa era branco, passa para etapa 1
If Inclui .And. nOpc == 1 .OR. (Altera .and.  Empty(SB1->B1_XCETAPA))

	//If Empty(SB1->B1_XCETAPA)
		Reclock("SB1",.F.)
		SB1->B1_XCETAPA := '1'
		MSUnlock()
	//Endif

Endif

//se incluiu e a etapa era branco, passa para etapa 1
If (Altera .OR. Inclui ) .And. nOpc == 1 .And. Val(SB1->B1_XCETAPA) <=  _nMaxEtapa

     etapaAtu := 1
     If  !Empty(SB1->B1_XCETAPA)
     	etapaAtu := Val(SB1->B1_XCETAPA)
     Endif

     //retorna a menor etapa nao finalizada
    etapa := u_CHROTG12 ("P", etapaAtu,_nMaxEtapa)

    //Funcao criada por Fabiano Dias no dia 22/09/16 para que seja checada se a(s) proxima(s) etapa(s) deve(m) ser inseridas geradas
    //o preenchimento dos campos determinados no cadastro de setor x campos, pois pode existir uma condicao no cadastro de etapa x setor que
    //indique que uma ou mais etapas nao sejam checadas de acordo com determinado criterio estabelecido
    etapa:= U_CHROTG10("P", etapa,_nMaxEtapa)

	If !Empty(SB1->B1_XCETAPA)

		Reclock("SB1",.F.)

		SB1->B1_XCETAPA := AllTrim(Str(etapa))

		//Caso a proxima etapa a ser executada seja Logistica, isto indica que as etapas de compras, fiscal e contabilidade já foram cumpridas
		//desta forma o uso do produto sera liberado
		If etapa >= _nEtapaLib

			SB1->B1_MSBLQL:= '2'

		EndIf

		MSUnlock()

		//Adicionado por Fabiano Dias no dia 22/09/16 para que somente no caso de uma nova etapa eh que seja disparado o e-mail para a proxima
		//etapa a ser concluida no cadastro de produto
		If _nEtapaAnt != SB1->B1_XCETAPA
			_ret := .F.
			MsgRun("Enviando e-mail para a próxima etapa...","Processando",{|| _ret := u_CHWFG001(  SB1->B1_COD, "P",  SB1->B1_XCETAPA, SB1->B1_DESC )})

			/*If ! _ret
		   		MsgInfo("Email enviado com sucesso "," MsgInfo ")
		    Else
		    	MsgAlert("Erro ao enviar email  " ," MsgAlert ")
		    End*/

		Else
			// alterado por sugestao do Cleiton na reuniao do dia 28.04.17
			// enviara sempre email para a proxima etapa se a etapa anterior fez alguma alteracao

			// etapa do usuario
			_nEtaUsu  := U_ChRotG14("P")

			If _nEtaUsu < _nMaxEtapa
			// Retirado ate que seja feita a reuniao sobre o assunto Dyego 29/11/17
				//MsgRun("Enviando e-mail para a próxima etapa...","Processando",{|| _ret := u_CHWFG001(  SB1->B1_COD, "P",  AllTrim(Str(_nEtaUsu + 1)) , SB1->B1_DESC, .t.)})
			Endif

		EndIf

	Endif

ElseIF (Altera .OR. Inclui ) .And. nOpc == 1
		// alterado por sugestao do Cleiton na reuniao do dia 28.04.17
		// enviara sempre email para a proxima etapa se a etapa anterior fez alguma alteracao

		// etapa do usuario
		_nEtaUsu  :=  U_ChRotG14("P")

		_nProx :=  ProxEtaCond('P', _nEtaUsu, _nMaxEtapa, altera)

		If _nEtaUsu < _nMaxEtapa .and. _nProx > 0
			// Retirado ate que seja feita a reuniao sobre o assunto Dyego 29/11/17
			//MsgRun("Enviando e-mail para a próxima etapa...","Processando",{|| _ret := u_CHWFG001(  SB1->B1_COD, "P",  AllTrim(Str(_nProx)) , SB1->B1_DESC, .t. )})
		Endif

Endif

RestArea(_aArea)

Return Nil


// proxima etapa que entra na condicao
Static Function ProxEtaCond(_cTipo, nEtapaAnt, nMaxEtapa, altera)

local nEtapa 	:= 0
local i 		:= 0
local lAtende	:= .F.

For i := (nEtapaAnt + 1) to nMaxEtapa

	lAtende := checkCond(_cTipo, str(i), altera)
	if lAtende
		nEtapa := i
		exit
	Endif

next i

Return nEtapa


//checa condicao
Static Function checkCond(_cTipo, _cEtapa, altera)

local lRet := .T.

	dbSelectArea("SZQ")
		//ZQ_FILIAL+ZQ_TIPO+ZQ_CODET+ZQ_SETOR
		SZQ->(dbSetOrder(1))
		If SZQ->(dbSeek(xFilial("SZQ") + _cTipo + AllTrim(_cEtapa)))

			cCondicao := SZQ->ZQ_COND001

			if !altera
				cCondicao := StrTran( cCondicao, "SB1", "M" )
				cCondicao := StrTran( cCondicao, "SA1", "M" )
				cCondicao := StrTran( cCondicao, "SA2", "M" )
			endif

			//Verifica se existe uma condicao para executar a etapa
			If !Empty(cCondicao)

				//Se a condicao for atendida, levando em consideracao os campos da SB1 a etapa sera checada, caso contrario nao
				If &(AllTrim(cCondicao))

					lRet := .T.

				Else
					//MsgBox("É obrigatório: " + AllTrim(SZQ->ZQ_COND001) , "Atenção ChRoG04.prw ", "ALERT")
					lRet := .F.
				EndIf

				//Caso nao tenha uma condicao para executar a etapa a mesma eh dada como obrigatoria a passagem pelo cadastro de produto
			Else

				lRet := .T.

			EndIf

		EndIf

Return	lRet









