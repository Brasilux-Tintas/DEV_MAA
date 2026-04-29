#INCLUDE "PROTHEUS.CH"

User Function S011TES()
     Local aArea := GetArea()
     Local cTES  := ParamIXB[1]
     Local cAux, cMens
     u_zcfga01( 'S011TES' ) //LGS#2021201 - Gravação de log de utilização da rotina
     //If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
     If cEmpAnt <> '11'
        //ConOut("PE S011TES") release 12.1.25
        cMens := "PE S011TES"
        FwLogMSG( "INFO", , 'SIGAFAT', funname(), '', '01', cMens, 0 )
        //Integração MASTERSALES
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Variáveis do GETIMPOSTO que podem ser utilizadas      ³
        //³ _cTipoPed: Tipo de pedido                             ³
        //³ _cCliente: Código do cliente                          ³
        //³ _cLoja   : Loja do cliente                            ³
        //³ _cTipoCli: Tipo de cliente                            ³
        //³ _cTpFrete: Tipo de frete                              ³
        //³ _aItem                                                ³
        //³ _aItem[1]: Código do produto                          ³
        //³ _aItem[2]: Código do TES                              ³
        //³ _aItem[3]: Quantidade                                 ³
        //³ _aItem[4]: Preço unitário                             ³
        //³ _aItem[5]: Valor total                                ³
        //³ _aItem[6]: Valor desconto                             ³
        //³ _aItem[7]: Valor frete                                ³
        //³ _aItem[8]: Valor despesa                              ³
        //³ _aItem[9]: Valor seguro                               ³
        //³ _aItem[10]: Valor frete autonomo                      ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        /*
        If _cTipoPed == "N"
           If _cTipoCli == 'X' .and. _aItem[1] == "000004"
              cTES := '502'
              //conout("cTES: "+ cTES)
           Endif
        Endif */
        cAux := U_BRFAT053(_cTipoPed,_cCliente,_aItem[1])
        if !empty(cAux)
           cTes := cAux
        endif
        RestArea(aArea)
     Endif
Return(cTES)
