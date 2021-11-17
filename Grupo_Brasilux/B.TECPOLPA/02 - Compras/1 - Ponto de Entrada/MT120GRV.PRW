#Include 'Protheus.ch'
/*================================================|
|Rotina: MT120GRV() 							  |
|Função: Calcular o custo do produto sem impostos |	
|Autor : Igor Manrique / Chaus					  |
|================================================*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT120GRV()
   Local _aArea 	 := GetArea()
   Local cNum  := PARAMIXB[1]
   Local lInclui  := PARAMIXB[2]
   Local lAltera := PARAMIXB[3]
   Local lExclui := PARAMIXB[4]
   Local _cFor,_cLoja
   Local _cAlmox 
     Local _lRet 	 := .T.
/*     Local _nItem	 := "" 
     Local _nValUnit := "" 
     Local _nQuant 	 := "" 
     Local cPro		 := "" 
     Local _nPrcTot	 := "" 
     Local cTes    	 := "" 
     Local _cOper	 := ""
*/     
     Local i 		 := 1
   Local _cGrpEmp := alltrim(FWGrpCompany())
   _cFor := M->C7_FORNECE
   _cLoja	 := M->C7_LOJA
   If _cGrpEmp = '11' //Empresas que são do grupo 11(Tecpolpa).
      /* //Cleber(21/01/21)->Comentei porque não estava fazendo nada, ponto de entrada pra TecPolpa sem sentido!!
        MaFisSave()
        //MaFisEnd()

        MaFisClear()
        MaFisIni(_cFor,_cLoja,"F","N","J",Nil,Nil,Nil,Nil,"MATA121") 

        For i := 1 to Len(aCols)
            If !(aCols[i,Len(aHeader)+1])	
               _nItem    :=  Val(aCols[i,GdFieldPos("C7_ITEM",aHeader)])
               _nValUnit :=  aCols[i,GdFieldPos("C7_PRECO",aHeader)]
               _nQuant   :=  aCols[i,GdFieldPos("C7_QUANT",aHeader)]
               cPro      :=  aCols[i,GdFieldPos("C7_PRODUTO",aHeader)]
               _nPrcTot  :=  aCols[i,GdFieldPos("C7_TOTAL",aHeader)]
               cTes      :=  aCols[i,GdFieldPos("C7_TES",aHeader)]
               _cOper    :=  aCols[i,GdFieldPos("C7_OPER",aHeader)]

               If Empty(_cOper)
                  _cOper := "EC"
               Endif
               //comentado por Dyego
               //aCols[i,GdFieldPos("C7_XCSTUNI",aHeader)]:= U_CUSTOUNIT(_cFor, _cLoja,_nItem,_nValUnit,_nQuant,cPro,_nPrcTot,cTes)
            Endif
        Next i
        //MaFisRestore()
      */        
   Else
      //lAltera
      //lInclui
      if lInclui .or. lAltera
         For i := 1 to Len(aCols)
            If !(aCols[i,Len(aHeader)+1])	//Não é deletado?
               /*
                  _nItem    :=  Val(aCols[i,GdFieldPos("C7_ITEM",aHeader)])
                  _nValUnit :=  aCols[i,GdFieldPos("C7_PRECO",aHeader)]
                  _nQuant   :=  aCols[i,GdFieldPos("C7_QUANT",aHeader)]
                  cPro      :=  aCols[i,GdFieldPos("C7_PRODUTO",aHeader)]
                  _nPrcTot  :=  aCols[i,GdFieldPos("C7_TOTAL",aHeader)]
                  _cOper    :=  aCols[i,GdFieldPos("C7_OPER",aHeader)]
               */
               cTes      :=  aCols[i,GdFieldPos("C7_TES",aHeader)]
               if cTes = '415' //TES de nota mãe/única do EIC, mercadoria irá diretamente para armazém em trânsito
                  _cAlmox := aCols[i,GdFieldPos("C7_LOCAL",aHeader)]
                  IF _cAlmox != "95"
                     aCols[i,GdFieldPos("C7_LOCAL",aHeader)] := "95"
                  ENDIF
               endif 
            Endif
         Next i
      endif    
   Endif

   RestArea(_aArea)
Return(_lRet)

