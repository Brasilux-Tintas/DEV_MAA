#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

///////////////////////////////////////////////////////////
//                                                       //
// Função....: BRCON002     Data....: 13.08.02           //
// Autor.....: Marcos Cesar D.Vieira                     //
// Descrição.: Lancamento Padrao(Financeiro)             //
// Uso.......: EXECBLOCK no Lancamento Padrao.           //
//                                                       //
///////////////////////////////////////////////////////////              
User Function BRCON002

//===========================//
// Declaracao de Variaveis   //
//===========================//
        
Local nArea,nRecno,nIndex,cConta
                                        
nArea  := Alias()
nRecno := Recno()
nIndex := IndexOrd()
cConta := Space(9)

cQuery := "SELECT E5_NATUREZ "
cQuery := cQuery + " FROM "+RetSqlName("SE5")+" "
cQuery := cQuery + " WHERE E5_FILIAL = '"+xFilial("SE5")+"'"
cQuery := cQuery + " AND E5_DATA = '"+DTOS(SEF->EF_DATA)+"'"
cQuery := cQuery + " AND E5_BANCO = '"+SEF->EF_BANCO+"'"
cQuery := cQuery + " AND E5_AGENCIA = '"+SEF->EF_AGENCIA+"'"
cQuery := cQuery + " AND E5_CONTA   = '"+SEF->EF_CONTA+"'"
cQuery := cQuery + " AND E5_NUMCHEQ = '"+SEF->EF_NUM+"'"
cQuery := cQuery + " AND D_E_L_E_T_ <> '*'"
TCQuery cQuery NEW ALIAS "TCQ"

DbSelectArea("TCQ")
dbgotop()                         

dbSelectArea("SED")
dbSetorder(1)
dbSeek(xFilial("SED")+TCQ->E5_NATUREZ)

cConta := SED->ED_CONTA
                         
dbSelectArea("TCQ")
dbCloseArea()

dbSelectArea(nArea)
dbSetorder(nIndex)
dbGoto(nRecno)

Return(cConta)