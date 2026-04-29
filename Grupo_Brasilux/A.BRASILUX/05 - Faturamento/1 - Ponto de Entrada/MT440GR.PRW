#include "TOTVS.CH"

/*/{Protheus.doc} MT440GR
10/02/2004 - Permitir liberação apenas para usuários autorizados para o caso de pedidos que não respeitam a política de vendas.
25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@type function
@version v.2022.04.13
@author Cleber Orati Domingues
@since 13/04/2022
@return Logical, Retorna verdadeiro se o pedido respeita a politica comercial.
/*/
User Function MT440GR()
     Local lRet := .t.
     u_zcfga01( 'MT440GR' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        If SC5->C5_NAOCONF == "S"
           MessageBox( "Atencao! Pedido NAO RESPEITA as Politicas Comerciais Para Revenda! Liberacao Nao Permitida!", "ATENÇÃO", 16 )
           lRet := .f.
        Endif
     Endif 
Return lRet
