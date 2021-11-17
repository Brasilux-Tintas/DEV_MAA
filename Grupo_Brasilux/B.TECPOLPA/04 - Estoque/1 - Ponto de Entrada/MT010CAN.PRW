#include "rwmake.ch"
#Include "SigaWin.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

/**  MT010CAN - Ponto de entrada  localizado nas funções  A010Inclui (Inclusão do Produto),
	A010Altera (Alteração do Produto) e A010Deleta (Deleção do Produto).
	Pode ser utilizado para executar customizações conforme o tipo de retorno: Execução OK
	ou Execução Cancelada.
**/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT010CAN()
     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        //Chama rotina Chaus  para executar as funcoes apos a inclusao ou alteracao do produto
        If SUPERGETMV("CF_ATIVARP", .F. , .F.)
           U_CHROTP03()
        Endif
     Endif
Return Nil
