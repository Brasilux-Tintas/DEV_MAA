#include "totvs.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT100CLA  ºAutor  ³ Cleber O. Dominguesº Data ³  12/09/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicio da classificação da nota. Gravar TES de acordo com  º±±
±±º          ³ tes do Prod x Fornecedor.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//25/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function MT100CLA()   
Local cAlias := Alias()  
Local aArea  := U_PegaArea({"SD1","SA5"})  
     u_zcfga01( 'MT100CLA' ) //LGS#2021118 - Gravação de log de utilização da rotina
dbselectarea("SA5")
IF (SA5->(FieldPos("A5_TES")) > 0) // Campo customizado que grava o TES na amarração Produto x Fornecedor
        dbselectarea("SA5")
        dbsetorder(2) //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA 

        dbselectarea("SD1")
        dbsetorder(1)         
        //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
        dbseek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
        While !eof() .and. (trim(xFilial("SD1")) == trim(SD1->D1_FILIAL)) .AND. (SF1->F1_DOC == SD1->D1_DOC) .AND. (SD1->D1_SERIE == SF1->F1_SERIE) .AND. (SF1->F1_FORNECE == SD1->D1_FORNECE) .AND. (SF1->F1_LOJA == SD1->D1_LOJA)
               If empty(trim(SD1->D1_TES)) .AND. !(SD1->D1_TIPO_NF == "6") //Cleber(03/12/2020), chamado 020089, exclusão para notas filhas no EIC
                 dbselectarea("SA5")
                 dbseek(xFilial("SA5")+SD1->D1_COD+SD1->D1_FORNECE+SD1->D1_LOJA)
                 If found()
                    If !EMPTY(SA5->A5_TES)
                       dbselectarea("SD1")
                       reclock("SD1",.F.)
                          SD1->D1_TES := SA5->A5_TES
                       msunlock()
                    Endif
                 Endif
               Endif
               dbselectarea("SD1")
               dbskip()
        Enddo 			 
ENDIF 
U_VoltaArea(aArea) 
If !empty(cAlias) 
   dbselectarea(cAlias)
Endif
Return(.t.)
