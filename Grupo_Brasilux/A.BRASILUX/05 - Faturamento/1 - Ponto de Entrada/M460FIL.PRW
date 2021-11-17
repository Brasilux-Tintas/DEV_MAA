#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M460FIL  ºAutor  ³ Cleber O. Dominguesº Data ³  01/10/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtrar somente pedidos que pertençam a um determinado bor-º±±
±±º          ³ dero na emissão de notas.                                  º±±
±±º          ³ Guardar a sequencia de numeração de NF. para evitar proble-º±±
±±º          ³ ma de faturamento paralelo entre filiais.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function M460FIL()  
     Local  _cRet := ""
     
     If alltrim(FWGrpCompany()) == '01' //Empresas DO GRUPO BRASILUX.
        Pergunte("MT461A",.F.)
        _cRet      := "(SC9->C9_APROVA = '"+iif(mv_par20 == 2,"9","1")+"')" 
        /* Cleber (26/11/2010) -> Passando a usar SD9, parâmetro MV_TPNRNFS igual a 3
        Public _cNumeroNF := "" // Variável p/ guardar a sequência de número de NF   
        */
        If !Empty(mv_par19)
           _cRet += " .AND. (SC9->C9_PEDIDO == RetField('SZB',1,'"+xFilial('SZB')+mv_par19+"01"+"'+SC9->C9_PEDIDO, 'Right(SZB->ZB_PEDIDO,6)'))" //"U_FILBORD(mv_par19,SC9->C9_PEDIDO)"
        Endif  
     Else
        _cRet := " SC9->C9_FILIAL == '" + xFilial('SC9')+ "' "
     Endif
Return(_cRet)              

