#include "protheus.ch"
#include 'topconn.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M200FIL  บAutor  ณ Cleber Orati		 บ Data ณ  27/09/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra formulas que o usuแrio possui liberadas            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasilux Tintas T้cnicas Ltda.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function M200FIL()
Local _aAlias    := GetArea()
Local _cRet := ""
Local cAuxUser := Alltrim(Upper(cUsername))
Local _cCodUsr,cAuxFilt,cQuery

     u_zcfga01( 'M200FIL' ) //LGS#2021201 - Grava็ใo de log de utiliza็ใo da rotina
If (ALLTRIM(cNumEmp) == "01010101") .OR. (ALLTRIM(cNumEmp) == "01060101")   //Empresas que nใo sใo do grupo 11(Tecpolpa).
   If !(cAuxUser $ "CAIO_KELLY_RUI_ADMINISTRADOR")
      _cRet := "(Len(Alltrim(G1_COD)) # 12)"
      
      //_cRet +=  " .OR. ((Len(Alltrim(G1_COD)) = 12) .and. ((SubStr(G1_COD, 1, 3) # 'BM ') "

      _cCodUsr := RetCodUsr()
      cQuery := "SELECT SUBSTRING(X5_DESCRI,7,2) AS LINHA FROM SX5010 SX5 WHERE (D_E_L_E_T_ <> '*') AND (X5_TABELA = 'W0') AND (X5_CHAVE = '"+_cCodUsr+"') AND (SUBSTRING(X5_DESCRI,1,6) = '"+ alltrim(xFilial("SG1"))+"') ORDER BY LINHA"
		TCQuery cQuery ALIAS "TCQLIN" NEW
		DbSelectArea( "TCQLIN")
		dbgotop()
      cAuxFilt := ""
      do while !eof()
            if !empty(cAuxFilt)
               cAuxFilt += "-"
            endif
            cAuxFilt += TCQLIN->LINHA
            dbskip()
      enddo
		DbSelectArea("TCQLIN")
		dbclosearea()


      IF !EMPTY(cAuxFilt)
         _cRet += " .OR. ((Len(Alltrim(G1_COD)) = 12) .and. (SubStr(G1_COD, 4, 2) $ '"+cAuxFilt+"'))"
      ENDIF 

   Endif

Endif
If !empty( _aAlias )
   RestArea( _aAlias )
Endif 
Return(_cRet)
