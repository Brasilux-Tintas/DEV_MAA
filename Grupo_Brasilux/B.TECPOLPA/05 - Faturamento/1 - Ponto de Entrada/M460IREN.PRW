#Include 'Protheus.ch'

/*--------+----------+-------+----------------------------------+------+--------+
| Função  | M460IREN | Autor |IGOR C. MANRQIUE/WWW.CHAUS.COM.BR | Data |09/08/16|
+---------+----------+-------+----------------------------------+------+--------+
|Descrição| Ponto de Entrada para alterar o valor do campo E1_XBOLETO de        |
|         | acordo com o pedido.												|	
+---------+---------------------------------------------------------------------+
| Uso     | Projeto - Geração Boletos Bancários									|	
|+--------+--------------------------------------------------------------------*/
//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function M460IREN()
     Local lBoleto
     Local aArea   := GetArea()

     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        lBoleto := GETMV("MV_XIMPBOL")
        If lBoleto = .T.
           Reclock("SE1",.F.)
              SE1->E1_XBOLETO := SC5->C5_XBOLETO
           MSUNLOCK()
        Endif
        RestArea(aArea)
     Endif
Return