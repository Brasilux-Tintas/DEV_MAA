#include 'protheus.ch'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
  ฑฑบPrograma  ณ MTA650AC บAutor  ณ Luํs Gustavo       บ Data ณ  15/09/04   บฑฑ
  ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
  ฑฑบDesc.     ณ Ponto de entrada para ajustes na quantidade empenhada, de- บฑฑ
  ฑฑบ          ณ vido ao ajuste de cor das f๓rmulas.                        บฑฑ
  ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
  ฑฑบUso       ณ BRASILUX                                                   บฑฑ
  ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
  ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
  /* - aHeader modificado para inclusใo do campo D4_ACECOR, quantidade de MP,
       para ajuste de cor.
     - o retorno desse P.E. sใo dois arrays, o primeiro contedo o aHeader do 
       novo campo, o segundo ้ o conte๚do do aCols, por้m testei e nใo conse-
       gui fazer com que funcionasse; Da maneira que estแ (com Nil) estแ fun-
       cionando perfeitamente.
     - OBS: esse P.E. ้ utilizado juntamente com os P.E.s EMP650 (para gerar-
            o valor no aCols, da nova posi็ใo) e MA650EMP (้ utilizado para -
            gravar o valor do novo aCols para o campo D4_ACECOR);
  */
User Function MTA650AC()
     Local aArray := {}
     //Local aHeader := {}
     //If GETMV("MV_AJUSCOR")
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_TITULO" ) )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_CAMPO"  ) )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_PICTURE") )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_TAMANHO") )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_DECIMAL") )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_VALID"  ) )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_USADO"  ) )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_TIPO"   ) )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_ARQUIVO") )
        //aAdd(aHeader, Posicione("SX3", 2, "D4_ACECOR", "X3_CONTEXT") )
     //Else
        //aHeader := Nil
     //Endif
     If FWCodEmp() <> '11' //Empresas que nใo sใo do grupo 11(Tecpolpa).
      	aArray := {}
        aAdd( aArray, { "Acerto Cor", "D4_ACECOR", "@E 99,999,999.9999", TamSX3("D4_ACECOR")[1], TamSX3("D4_ACECOR")[2], "", .T., "N", "", " " } )
        aAdd( aArray, "SD4->D4_ACECOR")
     Else
     	//aArray := {{},} //Cleber (28/02/20) ->Extraํdo do fonte original
     	
     	//Luํs Gustavo -> Nใo aceita que se devolva o array em branco
        aadd( aArray, { "TRT"       , "D4_TRT"   , "@E 99"             , TamSX3("D4_TRT")[1]   , TamSX3("D4_TRT")[2]   , "", .T., "N", "", " " } )
        aadd( aArray, "SD4->D4_TRT")

     Endif
Return(aArray)