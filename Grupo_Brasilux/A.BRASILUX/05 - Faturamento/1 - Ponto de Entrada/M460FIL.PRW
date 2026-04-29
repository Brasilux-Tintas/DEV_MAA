#include "protheus.ch"
#include 'tbiconn.ch'
#include "rwmake.ch"
#include "topconn.ch"
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
     //u_zcfga01( 'M460FIL' ) //LGS#2021201 - Gravação de log de utilização da rotina
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

     /* Parametro que habilita o bloqueio por saldo negativo */
     // incluido por Nelieder em 12/12/2022
     if GETMV("ZP_PAR0334") .AND. FWCodEmp() <> '11'
          MsAguarde({|| FiltSel()}, "Aguarde...", "Processando Registros...")
     EndIf

Return(_cRet)       

// incluido por Nelieder em 12/12/2022
Static Function FiltSel()
Local _cret

   cQuery := ""
   cQuery += " UPDATE "+RetSqlName("SC9")+" SET C9_X_FLAG = '' "
   cQuery += " WHERE C9_X_FLAG = '"+RetCodUsr()+"' AND  D_E_L_E_T_ <> '*' "
   
   _cret :=  TcSQLExec(cQuery)

   If !(_CRet==0)
			_cRet = TCSQLERROR()   
			MsgAlert(AllTrim(_cRet),"M460FIL.PRW ERROR 01 - Erro na atualização do FLAG SC9, informar essa tela ao T.I ! ")
   EndIf  

   /* Ajusta Flag */
   cQuery := ""
   cQuery += " UPDATE "+RetSqlName("SC9")+"  SET C9_X_FLAG = '"+RetCodUsr()+"' "
   
   If !Empty(mv_par19)
         cQuery += " FROM SC9010  "
         cQuery += " INNER JOIN SZB010 SZB ON SUBSTRING(ZB_PEDIDO, 3, 6) = C9_PEDIDO AND SZB.D_E_L_E_T_ = '' "
   Endif
   
   cQuery += " WHERE  SC9010.D_E_L_E_T_ <> '*' "

   If !Empty(mv_par19)
      cQuery += " AND ZB_CODIGO BETWEEN '"+mv_par19+"' AND '"+mv_par19+"' "
   Endif
   
   If !Empty(mv_par06)
      cQuery += " AND C9_PEDIDO BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
   Endif

   cQuery += " AND C9_BLEST = '' AND C9_BLCRED = '' "

   If !Empty(mv_par10)
      cQuery += " AND C9_LOJA    BETWEEN '"+mv_par09+"' AND '"+mv_par10+"' "
   Endif   

   If !Empty(mv_par08)
      cQuery += " AND C9_CLIENTE BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
   Endif

   If !Empty(mv_par12   )
      cQuery += " AND C9_DATALIB BETWEEN '"+dToS(mv_par11)+"' AND '"+dToS(mv_par12)+"' "
   Endif

   _cret :=  TcSQLExec(cQuery)

   If !(_CRet==0)
			_cRet = TCSQLERROR()   
			MsgAlert(AllTrim(_cRet),"M460FIL.PRW ERROR 02 - Erro na atualização do FLAG SC9, informar essa tela ao T.I ! ")
   EndIf  
   

Return
