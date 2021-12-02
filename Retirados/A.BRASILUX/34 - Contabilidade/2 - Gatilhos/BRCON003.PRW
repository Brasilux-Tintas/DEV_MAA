#INCLUDE "rwmake.ch"

///////////////////////////////////////////////////////////
//                                                       //
// Função....: BRCON003     Data....: 19.02.03           //
// Autor.....: Marcos Cesar D.Vieira                     //
// Descrição.: Lancamento Padrao(Folha de Pgto/Provisão) //
// Uso.......: EXECBLOCK no Lancamento Padrao.           //
//                                                       //
///////////////////////////////////////////////////////////              
User Function BRCON003

//===========================//
// Declaracao de Variaveis   //
//===========================//
        
Local nArea,nRecno,nIndex,cContaDeb
                                        
nArea     := Alias()
nRecno    := Recno()
nIndex    := IndexOrd()
cContaDeb := Space(9)

If Substr(SRZ->RZ_CC,1,2)=="02" .OR. Substr(SRZ->RZ_CC,1,2)=="03" 
  If Substr(SRZ->RZ_CC,1,2)=="0304"
    cContaDeb := "51105005"        
  ElseIf Substr(SRZ->RZ_CC,1,2)=="0306"  
    cContaDeb := "51103005"        
  Else
    cContaDeb := "41101005"
  Endif  
ElseIf Substr(SRZ->RZ_CC,1,4)=="0102"
  cContaDeb := "51101005"
ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
  cContaDeb := "51102005" 
ElseIf Substr(SRZ->RZ_CC,1,2)=="05"
  cContaDeb := "51104005"  
EndIf
                                                           
dbSelectArea(nArea)
dbSetorder(nIndex)
dbGoto(nRecno)

Return(cContaDeb)