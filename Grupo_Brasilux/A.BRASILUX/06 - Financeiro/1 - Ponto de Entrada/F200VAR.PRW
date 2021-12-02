#include "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F200VAR  บAutor  ณMicrosiga           บ Data ณ  02/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera valor titulo de desconto                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//30/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25
User Function F200VAR()
Local cArea := Alias()
Local aArea, lBaixa, lLiqui, lBloqueado, lAchou,_cTitulo
Local  _cGrpEmp := ALLTRIM(FWGrpCompany())
     u_zcfga01( 'F200VAR' ) //LGS#2021202 - Grava็ใo de log de utiliza็ใo da rotina
If _cGrpEmp <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
   aArea := U_PegaArea({"SE1","SEA"})
   DbSelectArea("SE1")
   DbSetOrder(1)
        /*_cAux := alltrim(substr(cNumTit,10,3))
        if empty(_cAux) .and. !empty(substr(cNumTit,1,10))
           _cTitulo = substr(paramixb[1][1],1,13)
           cNumTit := substr(cNumTit,1,9)+substr(cNumTit,13,3)
        else
           //_cTitulo := substr(paramixb[1][1],1,9)+space(3)+substr(paramixb[1][1],10,1)
           //cNumTit  := substr(paramixb[1][1],1,9)+space(3)+substr(paramixb[1][1],10,3)
           _cTitulo := substr(paramixb[1][1],1,9)+space(3)+substr(paramixb[1][1],10,1)+" "
           cNumTit  := _cTitulo
           if empty(alltrim(substr(paramixb[1][1],11,1)))
              cNumTit += substr(paramixb[1][1],12,2)
           else
              cNumTit += substr(paramixb[1][1],11,2)
           endif
        endif */

   _cTitulo := PADR(substr(paramixb[1][1],1,9),9)+space(3)+PADR(substr(paramixb[1][1],10,1),2)+"NF "

   DbSelectArea("SE1")
   DbSeek(xFilial("SE1")+_cTitulo) // paramixb[1][3])
   lAchou := found()

   cNumTit := IIF(lAchou .and. !empty(alltrim(SE1->E1_IDCNAB)),SE1->E1_IDCNAB,substr(_cTitulo,1,len(_cTitulo)-3))
   paramixb[1][1] := cNumTit

        //Cleber (15/01/09) => Mudou tam. campo num tํt. em SE1, de 6 p/ 9 dํg., acerto de probl. em retornos de tํt. remetidos anteriormente
        /*_cTitulo = rtrim(paramixb[1][1])
        if len(_cTitulo) == 12
           _cTitulo = substr(paramixb[1][1],1,9)+space(3)+substr(paramixb[1][1],10,1)
           cNumTit = substr(paramixb[1][1],1,9)+space(3)+substr(paramixb[1][1],10,3)
           paramixb[1][1] := cNumTit
        else
           _cTitulo = substr(paramixb[1][1],1,13)
        endif */

   if lAchou	
           //cLEBER (05/12/12) -> Excluido tratamento para E1_SITUACA = 2
           /*If (Alltrim(Paramixb[1][14]) $ "06*08*09*48") .AND. Alltrim(SE1->E1_SITUACA) == "2"
                nValrec   := SE1->E1_SALDO
                dDatacred := dbaixa
                nJuros    := 0
           Endif */
           //
           // Marcar como em cartorio e voltar p/carteira
           //
           lBaixa := .F.
           lLiqui := .F.
           If Alltrim(cBanco) == "237"
              If Alltrim(Paramixb[1][14]) == "10" .and. SubStr(Paramixb[1][15], 1, 2) == "14"        //Baixa por ter sido
                 lBaixa := .T.                                                                       //enviado ao Cart๓rio
              ElseIf Alltrim(Paramixb[1][14]) == "15" .and. SubStr(Paramixb[1][15], 1, 2) == "00"    //Liquida็ใo em Cart๓rio
                     lLiqui := .T.
              Endif
           ElseIf Alltrim(cBanco) == "341"                                                           //Baixa por ter sido
                  If Alltrim(Paramixb[1][14]) == "32"                                                //Enviado ao Cart๓rio
                     lBaixa := .T.                                                
                  ElseIf Alltrim(Paramixb[1][14]) == "08"                                            //Liquida็ใo em Cart๓rio
                         lLiqui := .T.
                  Endif
           ElseIf Alltrim(cBanco) == "001"
                  If Alltrim(Paramixb[1][14]) $ "10_09" .and. SubStr(Paramixb[1][15], 1, 2) == "15"  //Baixa por ter sido
                     lBaixa := .T.                                                                   //Enviado ao Cart๓rio
                  ElseIf Alltrim(Paramixb[1][14]) == "15"                                            //Liquida็ใo em Cart๓rio
                         lLiqui := .T.
                  Endif
           Endif
           If .f. //lBaixa
              DbSelectArea("SEA")
              DbSetOrder(1)
              If DbSeek(cFilial+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
                 lBloqueado := u_EstaBloqueado("SEA", Recno())
                 If !lBloqueado
                    Reclock( "SEA" , .F. , .T.)
                 Endif
                 SEA->(DbDelete())
                 If !lBloqueado
                    MsUnlock()
                 Endif
              EndIf
              DbSelectArea("SE1")
              lBloqueado := u_EstaBloqueado("SE1", Recno())
              If !lBloqueado
                 Reclock("SE1", .f.)
              Endif
              SE1->E1_SITUACA := "0"
              SE1->E1_PORTADO := Space(Len(SE1->E1_PORTADO) )
              SE1->E1_AGEDEP  := Space(Len(SE1->E1_AGEDEP ) )
              SE1->E1_CONTA   := Space(Len(SE1->E1_CONTA  ) )
              SE1->E1_DATABOR := CtoD("")
              SE1->E1_NUMBOR  := Space(Len(SE1->E1_NUMBOR ) )
              SE1->E1_BCO     := Space(03)
              SE1->E1_HIST    := "*BXP*"+ALLTRIM(SE1->E1_HIST)
              SE1->E1_OCORREN := cOcorr
              SE1->E1_NATUREZ := "802016"
              If !lBloqueado
                 MsUnLock()
              Endif
           ElseIf lLiqui
                  DbSelectArea("SE1")
                  lBloqueado := u_EstaBloqueado("SE1", Recno())
                  If !lBloqueado
                     Reclock("SE1", .f.)
                  Endif
                  Reclock("SE1")
                  SE1->E1_OCORREN := cOcorr
                  SE1->E1_NATUREZ := "802024"
                  If !lBloqueado
                     MsUnlock()
                  Endif
           Endif
   Endif 
   U_VoltaArea(aArea)
Endif // Fim If _cGrpEmp <> '11'
if !empty(cArea)
	dbselectarea(cArea)
endif 

Return(.t.)
