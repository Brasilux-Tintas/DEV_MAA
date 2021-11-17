#include "protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F040CPO  บAutor  ณMicrosiga           บ Data ณ  18/10/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera campos para altera็ใo no contas a receber           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX TINTAS TษCNICAS LTDA.                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//30/09/2019 - Luํs Gustavo - Adequa็ใo para release 12.1.25 - 
//             Usado para TecPolpa e Brasilux
//29/11/2019 - Cleber       - Incluido campos aos existentes
User Function F040CPO()      
     //Estrutura do aCpos original da rotina,
     //contendo os campos que foram definidos
     //para serem editแveis na altera็ใo do tํtulo
     Local aAux := aClone( ParamIxb )

     //Array para retorno dos campos que poderใo ser editados
     //na altera็ใo de um tํtulo a receber
     Local aRet := {}

     aAdd( aAux, 'E1_NATUREZ' )
     aAdd( aAux, 'E1_VENCTO' )
     aAdd( aAux, 'E1_VENCREA' )
     aAdd( aAux, 'E1_HIST' )
     aAdd( aAux, 'E1_NUMBCO' )
     aAdd( aAux, 'E1_VEND1' )
     aAdd( aAux, 'E1_COMIS1' )
     aAdd( aAux, 'E1_BASCOM1' )

     aRet := aClone( aAux )

Return aRet
