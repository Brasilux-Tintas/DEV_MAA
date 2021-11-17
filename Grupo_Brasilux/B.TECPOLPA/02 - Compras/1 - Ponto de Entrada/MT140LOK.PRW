#Include 'Protheus.ch'
#include "TOPCONN.CH"
#include "rwmake.ch" 
/*„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„„
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±÷ííííííííííÛííííííííííøíííííííÛííííííííííííííííííííøííííííÛíííííííííííííô±±        				
±±?Programa  =MT140LOK  ?Autor= Tiago-www.chaus.com.br ?Data=  28/04/16   ?±±
±±víííííííííí?ííííííííííÜíííííííííííííííííííííííííííÜíííííííííííííííííííííp±±
±±?Desc.     =Este ponto de entrada e executado na rotina MATA140 e tem   ?±±
±±?          =como objetivo fazer a validacao das linhas lancadas na pre- ?±±
±±?          =nota. A rotina faz a seguinte validacao:  				  ?±±
±±?          ===>A rotina valida se o campo lote foi preenchido para      ?±±
±±?          =   produtos que controlam lote se o campo de quantidade de  ?±±
±±?          2) Validar a obrigatoriedade do lancamento do pedido de      ?±±
±±?          =  compra ou associado a pre-nota                            ?±±
±±?          =                                                            ?±±
±±?          =                                                            ?±±
±±?          =                                                            ?±±
±±víííííííííí?ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííp±±
±±?Uso       = AP                                                         ?±±
±±™ííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííííí?±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
???????????????????????????????????????????????????????????????????????????*/


User Function MT140LOK()
     Local _aArea      := getArea() 
     Local _nPosFornec := 0
     Local _nPosLoja   := 0
     Local _nPosProdut := 0
     Local _nPosGrupo  := 0
     Local _nPosPrcUnt := 0
     Local _nQtdLanc   := 0
     Local _nPosItemPc := 0
     Local _nPosPc     := 0
     Local _nPosLote   := 0
     Local _nPosVolu   := 0
     Local _cFornec    := ""
     Local _cLoja      := ""
     Local _cProduto   := ""
     //Local _cGrupo     := ""  
     Local _cPC    	   := ""
     Local _cLote      := ""
     Local _nPrecoUnt  := 0
     Local _nQtde      := 0
     Local _nItemPC    := 0
     Local _nVolume    := 0
     //Local _percDif    := 0
     //Local _percDifQ   := 0   
     //Local _qtdUnitPC  := 0    
     Local cAliaAnte := Alias()
     Local nAreaAnte := IndexOrd()
     Local nRegiAnte := RecNo()
     Local bRetorno := .T.

     If FWCodEmp() = '11' //Empresas que são do grupo 11(Tecpolpa).
        //msgBox(Paramixb[1])                   
        If !(Paramixb[1])
           Return .F.
        EndIf

        If !paramixb[1] 	 //Verifica se ja foi feita uma validacao anterior
           bRetorno := .f.
           dbSelectArea(cAliaAnte)
           dbSetOrder(nAreaAnte)
           dbGoTo(nRegiAnte)
           Return(bRetorno)
        EndIf

        If AllTrim(cTipo) == "N"  .and. bRetorno // Notas Normais
           If GetMV("MV_XPEDCOBR") .and. bRetorno
              bRetorno := ValPedComp()
           EndIf
           If !ACOLS[N,LEN(ACOLS[N])]   
              _nPosFornec := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_FORNECE"})    
              _nPosLoja   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_LOJA"})
              _nPosProdut := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_COD"})          
              _nPosGrupo  := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_GRUPO"})  
              _nPosPrcUnt := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_VUNIT"})
              _nQtdLanc   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_QUANT"})  
              _nPosItemPc := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_ITEMPC"}) 
              _nPosPc     := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_PEDIDO"})
              _nPosLote   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_LOTECTL"})  
              _nPosVolu   := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_XQTVL"})

              _cFornec    := CA100FOR //aCols[n,_nPosFornec] 
              _cLoja      := CLOJA //aCols[n,_nPosLoja] 
              _cProduto  	:= aCols[n,_nPosProduto] 
              //_cGrupo  	:= aCols[n,_nPosGrupo] 		
              _nPrecoUnt 	:=  aCols[n,_nPosPrcUnt]   
              _nQtde      := aCols[n,_nQtdLanc]   
              _nItemPC    := aCols[n,_nPosItemPc]  
              _cPC        := aCols[n,_nPosPc]
              _cLote      := aCols[n,_nPosLote]
              _nVolume    := aCols[n,_nPosVolu] 

              _cRastro:= Alltrim(POSICIONE( "SB1", 1, xFilial("SB1")+_cProduto,"B1_RASTRO" ))
              IF FunName()=="MATA140"
                 if _cRastro=="L"  //Controla lote
                    if AllTrim(_cLote)==""
                       Aviso("MT140LOK.PRW","O Produto "+ Alltrim(_cProduto) +" controla lote. O campo "+;
                             "'Lote' n„o pode ser vazio!",{"OK"})
                       Return .F.
                    EndIf
                 EndIf
                 _cEtiqueta:=Alltrim(POSICIONE( "SB1", 1, xFilial("SB1")+_cProduto,"B1_XETIQUE" )) 
                 if _cEtiqueta=='S'	
                    if _nVolume > _nQtde
                       Aviso("MT140LOK.PRW","A quantidade de itens por volume (D1_XQTDVOL) precisa ser menor ou igual "+;
                             " ‡ quantidade de itens (D1_QUANT)",{"OK"})
                       Return .F.
                    EndIf
                    if (_nVolume)==0
                       Aviso("MT140LOK.PRW","O Produto "+ Alltrim(_cProduto) +" imprime Etiqueta. Campo "+;
                             "'Qtd.Prod.Vol' n„o pode ser vazio!",{"OK"})
                       Return .F.
                    EndIf
                 EndIf
              EndIF
           EndIf
        EndIf
        RestArea(_aArea)
     Endif
Return (bRetorno)
                                                                     

Static Function ValPedComp()
Local _Ret:= .T.
Local  _nPedido, _nItemPC, _nCodPro
Local _nPos1,_nPos2, _nPos3
Local cPro := GETMV("MV_XPROSPE")

_nPos3 := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_COD"})
_nCodPro  := aCols[n,_nPos3]

If Substr(_nCodPro,1,4) <> "1AAA" .OR. (_nCodPro $ cPro)  //Produto da TecPolpa 
	_Ret:= .T.
	Return(_Ret)
EndIF

If !ACOLS[N,LEN(ACOLS[N])]  // Entra se a linha n„o estiver deletada
	_nPos1     := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_PEDIDO"})
	_nPos2     := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_ITEMPC"})
	_nPedido   := aCols[n,_nPos1]
	_nItemPC   := aCols[n,_nPos2]                                   

	If  (Empty(_nPedido) .or. empty(_nItemPC))
		_Ret :=  .F.
		MSGBOX("Obrigtorio o preenchimento do Pedido de Compras para qualquer nota fiscal de compra de acordo com parametro MV_XPEDCOBR.","CAMPO OBRIGATORIO-TECPOLPA:MT140LOK","AVISO")
	EndIf
EndIf

Return(_Ret)


/*  
*  Valida se o valor da Nota Fiscal de Entrada esta de acordo com as regras de negocia°—o da compra de cobre
*/
/*
Static Function ValidaValo(_percDif, _nPrecoUnt, VlPrcPC, _cPC, _nItemPC, _cProduto)
	
	teste=0

	If  _nPrecoUnt> (VlPrcPC * (1+(_percDif/100.0)))  
	
		MSGBOX("O preÁo da Nota Fiscal de Entrada n„o pode ser diferente do preÁo negociado no pedido acrescido do percentual de toler‚ncia do produto." + chr(13) + ;
		"Pedido: " +Alltrim(_cPC) + " Item: " + Alltrim(_nItemPC) + chr(13) + "Produto: " + Alltrim(_cProduto) +  chr(13)+;
		"PreÁo negociado: R$ " +	AllTrim(Transform( VlPrcPC, "@E 999,999,999.9999")) + chr(13) +;
		"Percentual de toler‚ncia aplicado ao preco negociado: R$ " + AllTrim(Transform(  VlPrcPC * (1+_percDif/100.0) , "@E 999,999,999.9999"))+ chr(13)+""+;
		"Valor unit·rio informado: R$ " + AllTrim(Transform( _nPrecoUnt, "@E 999,999,999.9999") ) )
		
		Return .F.
	EndIf

Return .T. */


/*  
*  Valida se a quantidade da Nota Fiscal de Entrada esta de acordo com as regras de negocia°—o da compra de cobre
*/
/*       
Static Function ValidaQtd(_percDifQ, _nQtde, _qtdUnitPC , _cPC, _nItemPC, _cProduto)
	
	teste=0

	If  _nQtde> (_qtdUnitPC * (1+(_percDifQ/100.0)))  
	
		MSGBOX("A quantidade da Nota Fiscal de Entrada n„o pode ser diferente da quantidade negociada no pedido acrescido do percentual de toler‚ncia do produto." + chr(13) + ;
		"Pedido: " +Alltrim(_cPC) + " Item: " + Alltrim(_nItemPC) + chr(13) + "Produto: " + Alltrim(_cProduto) +  chr(13)+;
		"Quantidade negociada pedido de compra:  " +AllTrim(Transform( _qtdUnitPC, "@E 999,999,999.9999") ) + chr(13) +;
		"Percentual de toler‚ncia aplicado ‡ quantidade negociada:  " +	AllTrim(Transform(  _qtdUnitPC * (1+_percDifQ/100.0) , "@E 999,999,999.9999") ) + chr(13)+""+;
		"Quantidade informada: " + 	AllTrim(Transform( _nQtde, "@E 999,999,999.9999") )  )
		
		Return .F.
	EndIf

Return .T.*/