#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"                                                            
#INCLUDE "TBICONN.CH"
// INCLUIR ROTINAS NO MENU PRINCIPAL DA ORDEM DE PRODUÇÃO
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MA650BUT()
     //Não declarar o array aRotina
     //Adiciona um novo item no menu principal do MATA650
     If ALLTRIM(FWGrpCompany()) == '11' //Empresas que são do grupo 11(Tecpolpa).
        If GetMv("MV_XBIPOP")
           aAdd(aRotina,{ 'Gera Ordem de Separação'   , 'u_TCGORDEM(1)', 0 , 6 } )
           aAdd(aRotina,{ 'Estorna Ordem de Separação', 'u_TCGORDEM(2)', 0 , 6 } )
        Endif
     Endif
Return (aRotina)
