#include "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA60FIL  ºAutor  ³ Rogério Monteiro   º Data ³  07/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adidiona filtro de Banco na Tecla F12                      º±±
±±º 28/08/02 ³ Filtrar títulos que não possuem banco cadastrado           º±±
±±º 23/06/03 ³ Cleber                                                     º±±
±±º 23/08/18 ³ Cleber -> Alterado filtro p/ apenas 6 dias ao inves de 10  º±±
±±º          ³ Filtrar títulos com vencto. menor ou igual a (x10x)5 dias  º±±
±±º 22/09/20 ³ Cleber -> Troca de mv_par14 para mv_par15                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function FA60FIL()
     Local cString := ".T." //(Cleber 21/01/20, coloquei o ".T.")
     
     If alltrim(FWGrpCompany()) = '01' //Empresas do grupo BRASILUX
        cString := " Iif(Empty(Alltrim(mv_par15)), !Empty(Alltrim(E1_BCO)) .and. ((E1_VENCTO - E1_EMISSAO) > 5) .and. Empty(Alltrim(E1_NUMBCO)), (Alltrim(E1_BCO) == mv_par15) .and. ((E1_VENCTO - E1_EMISSAO) > 5) .AND. Empty(Alltrim(E1_NUMBCO))) "
     Endif
Return (cString)
