/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MT110GRV ³ Autor ³ Luís Gustavo de Souza ³ Data ³ 10.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de Entrada Usado na Gravação da Solicitação.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
/*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT110GRV()   
     Local _cAlias  := Alias()
     Local aAreaAnt := u_PegaArea({"SZU"})
     u_zcfga01( 'MT110GRV' ) //LGS#2021118 - Gravação de log de utilização da rotina
     If alltrim(FWGrpCompany()) <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        If !Empty(SC1->C1_IDREQUI)
           DbSelectArea("SZU")
           DbSetOrder(1)
           DbSeek(xFilial("SZU")+SC1->C1_IDREQUI, .t.)
           If Found()
              RecLock("SC1", .f.)
                 SC1->C1_SOLICIT := SZU->ZU_SOLICIT
              MsUnLock()
           Endif
        Endif
        U_VoltaArea(aAreaAnt)
        If !EMPTY( _cAlias )
	       DbSelectArea( _cAlias )
        Endif
     Endif 
Return
