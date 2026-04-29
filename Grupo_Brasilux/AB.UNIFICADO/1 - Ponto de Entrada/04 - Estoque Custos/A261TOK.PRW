#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} A261TOK
Ponto de entrada para validação de itens diferentes na transferencia de produtos.
O parâmetro ZP_PAR0048 ativa a funcionalidade e o ZP_PAR0049 valida usuários autorizados
a transterir para produtos diferentes.
@type function
@version  v2022.05.29
@author Luis Gustavo de Souza
@since 29/05/2022
@return Logical, Retorna verdadeiro se os produtos são iguais ou se o usuário esta autorizado a transferiri produtos diferentes.
/*/
User Function A261TOK()
     Local _lRet     := .T.
     Local _nPosOri  := aScan( aHeader, {|x| UPPER( Alltrim( x[1] ) ) $ "PROD.ORIG."   } )
     Local _nPosDes  := aScan( aHeader, {|x| UPPER( Alltrim( x[1] ) ) $ "PROD.DESTINO" } )
     Local _cCodUsr  := RetCodUsr()
     Local _lPAR0048 := GETMV("ZP_PAR0048")
     Local _cPAR0049 := GETMV("ZP_PAR0049")

     //Validar transferências para um único produto
     If _lPAR0048 //Ativa ou  não a validação
        For _nY := 1 To Len( aCols ) 
            If aCols[ _nY ][ _nPosOri ] <> aCols[ _nY ][ _nPosDes ] .OR. Empty( aCols[ _nY ][ _nPosDes ] ) .OR. Empty( aCols[ _nY ][ _nPosOri ] )
               If !_cCodUsr $ _cPAR0049
                  _lRet := .F.
                  If Type("MsgRetWMS") == "C" //Variável que controla o erro via coletor está declarada
                     MsgRetWMS   := "Movimentação com produtos origem/destino diferentes não pode ser realizada."
                     lMSErroAuto := .T.
                  Else
                     MessageBox( "Movimentação com produtos origem/destino diferentes não pode ser realizada.", "Verifique", 16 )
                  Endif
               Else
                  _lRet := .T.
               Endif
            Endif
        Next
     Endif
Return _lRet
