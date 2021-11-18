#include "rwmake.ch"
#include "avprint.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRCOM001  ºAutor  ³ Cleber O. Dominguesº Data ³  19/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Etiquetas de fornecedores.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRCOM001()
     //Local cQry    := ''
     //Local aEtqExp := {}
     //Local cEmpresa
     Local _cFilial

     Private cPerg

     if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 
     u_zcfga01( 'BRCOM001' ) //LGS#2021118 - Gravação de log de utilização da rotina
     cPerg := padr("BRCO01",10," ")
     ValidPerg()                     
     Pergunte(cPerg, .t.)

     oPrn:= TMSPrinter():New( "Etiquetas Fornecedores" )
     oPrn:SetPortrait()

     AVPRINT oPrn NAME "Etiquetas Fornecedores"
             oFont1 := TFont():New("Arial"      ,9,10,.F.,.F.,5,.T.,5,.T.,.F.)
             oFont4 := TFont():New("Arial"      ,9,12,.F.,.T.,5,.F.,5,.T.,.F.)
             oFont2 := TFont():New("Arial Black",9,12,.F.,.F.,5,.T.,5,.T.,.F.)
             oFont3 := TFont():New("Arial Black",9,14,.F.,.F.,5,.T.,5,.T.,.F.)
             AVPAGE
               nLin     := 050
               nCol     := 060
               nContEtq := 0
               DbSelectArea("SA2")
               DbSetOrder(1)
               _cFilial := xFilial("SA2")
               Dbseek(xFilial("SA2")+mv_par01)
               While !EOF() .and. (SA2->A2_FILIAL = _cFilial) .and. (SA2->A2_COD >= mv_par01) .and. (SA2->A2_COD <= mv_par02)
                     nLinIni = nLin
                     oPrn:Say (nLin,nCol,SUBSTR(SA2->A2_NOME,1,34),oFont1)
                     nLin += 30
                     oPrn:Say (nLin,nCol,SA2->A2_END,oFont1)
                     nLin += 30
                     oPrn:Say (nLin,nCol,SA2->A2_BAIRRO,oFont1)
                     nLin += 30
                     oPrn:Say (nLin,nCol,ALLTRIM(SA2->A2_MUN)+"-"+SA2->A2_EST,oFont1)
                     nLin+=30
                     oPrn:Say (nLin,nCol,SUBSTR(SA2->A2_CEP,1,5)+"-"+SUBSTR(SA2->A2_CEP,6,3),oFont1)
                     nContEtq++
                     Do Case
                        Case nCol == 60
                             nCol = 840
                             nLin = nLinIni
                        Case nCol == 840
                             nCol = 1680
                             nLin = nLinIni
                        Case nCol == 1680
                             nCol = 60
                             nLin += 155
                     EndCase
                     If ncontEtq == 36
                        AVNEWPAGE
                        nLin     := 050
                        nCol     := 060
                        nContEtq := 0
                     Endif
                     DbSelectArea("SA2")
                     DbSkip()
               Enddo
             AVENDPAGE
     AVENDPRINT
     oFont1:End()
     oFont2:End()
     oFont3:End()
     oFont4:End()
     MS_FLUSH() 
Return  

   

/********************************************************************************************/
/*** VALIDPERG - Grava Perguntas - 28/01/02                                               ***/
/********************************************************************************************/
Static Function ValidPerg()
       Local i, j
       _sAlias := Alias()
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Forn. De  ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
       AADD(aRegs,{cPerg,"02","Forn. Ate ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})

       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1", .T.)
                 For j:=1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j,aRegs[i,j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return
