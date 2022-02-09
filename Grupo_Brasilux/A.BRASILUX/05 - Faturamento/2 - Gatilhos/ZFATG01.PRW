#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} ZFATG01
    Retorna o preço de vendas do produto de acordo com o campo B1_ESTOQUE, Sim ou Não
    @type  Function
    @author Luís Gustavo de Souza
    @since date 03/02/2022
    @version v.2022/.01
    @return numeric, Retorna o preço de vendas da tabela 1 (Estoque) ou 2 (Não estoque)
    /*/
User Function ZFATG01()
     Local _nPosPro := aScan( aHeader, { |x| Alltrim( x[2] ) == 'C6_PRODUTO' } )
     Local _nPrcVen := 0
     DbSelectArea( "SB1" )
     SB1->( DbSetOrder( 1 ) )
     If SB1->( DbSeek( xFilial( "SB1" ) + aCols[n][ _nPosPro] ) )
        If SB1->B1_ESTOQUE == 'S'
           _nPrcVen := SB1->B1_PRV1
        Else
           DbSelectArea( "SB5" )
           SB5->( DbSetOrder( 1 ) )
           If SB5->( DbSeek( xFilial("SB5") + aCols[n][ _nPosPro] ) )
              _nPrcVen := SB5->B5_PRV2
           Endif
        Endif
     Endif
Return _nPrcVen
