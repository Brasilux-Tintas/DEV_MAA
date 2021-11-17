#include "totvs.ch"

/*/{Protheus.doc} M410LIOK
//TODO Descrição auto-gerada.
@author gustavosouza
@since 23/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function M410LIOK()
     Local _x      := 0
     Local cCodPro := ""
     Local nPosPro,lCanc 
     Local _lRet   := .T.
     Local _cMsg
   Local _cGrpEmp := alltrim(FWGrpCompany())
   If !(_cGrpEmp == '11')
        /*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
        ±±ºPrograma  ³ M410LIOK ºAutor  ³ Cleber O. Dominguesº Data ³  08/08/02   º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºDesc.     ³ Verifica se o item já está digitado.                       º±±
        ±±º 18/08/05 ³ Verifica se o item está deletado se é normal e se possui - º±±
        ±±º          ³ lote de produção cadastrado. Caso seja verdade não deixa - º±±
        ±±º          ³ deletar o item.                                            º±±
        ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
        ±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
        ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
      lCanc := .f. //Cancelar verificação
      //Cleber(01/04/21) -> Exceção para clientes exportação
      IF (M->C5_TIPO == 'N') .AND. (POSICIONE("SA1",1,xFilial("SA1")+M->C5_CLIENTE,"A1_EST") = "EX")
         lCanc := .t.
      ENDIF 
      IF !lCanc
         nPosPro := aScan(aHeader, {|x| Trim(x[2]) == "C6_PRODUTO"})
         If nPosPro > 0
            If !aCols[n][Len(aHeader)+1] .and. (M->C5_TIPO == 'N') .and. (M->C5_CLIENTE <> "023818") // Se não for Item deletado e pedido Normal e não for pedido para Dep. Fechado
               cCodPro := aCols[n][nPosPro]
               For _x := 1 To Len(aCols)
                  If (_x <> n) .and. (aCols[_x][nPosPro] == cCodPro) .and. !aCols[_x][Len(aHeader)+1]
                     _lRet = .f.
                     Exit
                  Endif
               Next
               If !_lRet
                  //LGS#20200114 - Ajuste na função de mensagem
				      //MsgBox("Existe item em DUPLICIDADE!", "Atenção...", "ALERT")
                  _cMsg := "Item "+cCodPro+" em DUPLICIDADE!"
   				   MessageBox( _cMsg, "Atenção!", 48 )

               Endif
            Endif
         Endif
      ENDIF
   Else
        // Chama rotina da Chaus que valida se o produto/cliente/fornecedor teve o cadastro finalizado
        _lRet := u_CHROTG13()
        // se a tes controla terceiros exige o preenchimento do campo NUM OP TA
        If _lRet
           _lRet := valNumOP()
        Endif
   Endif
Return( _lRet )

Static Function valNumOP()
       //Local aArea      := GetArea()
       Local cAliaAnte  := Alias()
       Local nAreaAnte  := IndexOrd()
       Local nRegiAnte  := RecNo()
       //Local _nItem     := 0
       Local _lRet      := .T.
       Local _cProduto  := ACols[n,Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
       Local _cNumOP    := ACols[n,Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_XNUMOP"})]
       Local _tpMercado := Posicione( "SA1", 1, xFILIAL("SA1")+M->C5_CLIENTE +  M->C5_LOJACLI,"A1_XMERCAD" )
       Local _tpProduto := Posicione( "SB1", 1, xFILIAL("SB1")+_cProduto ,"B1_TIPO" )

       If _tpMercado == 'B' .AND. !ACOLS[N,LEN(ACOLS[N])] .AND. Empty(_cNumOP) .AND. !(_tpProduto $ "TA/PA") .AND. _cProduto != "1AAACFPPFE13"
          _lRet := .F.
          //LGS#20200114 - Ajuste na função de mensagem
          //MsgBox("Dever ser preenchido o campo 'Num da Op TA' do item "+AllTrim(str(N)), "Atenção - MA410LIOK.prw", "ALERT")
          MessageBox( "Dever ser preenchido o campo 'Num da Op TA' do item " + AllTrim(str(N)), "Atenção - MA410LIOK.prw", 48 )
       Endif
       dbSelectArea(cAliaAnte)
       dbSetOrder(nAreaAnte)
       dbGoTo(nRegiAnte)
Return _lRet
