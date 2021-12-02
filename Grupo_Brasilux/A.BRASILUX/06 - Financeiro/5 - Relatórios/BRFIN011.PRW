#include "protheus.ch"
#include "avprint.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN011 º Autor ³ Marcos C.D. Vieira º Data ³  17/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão de etiquetas por cliente.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Alter.: 12/03/04 - Uso de query e inclusão do parâmetro MV_PAR03 - Dt. Nasc.
        07/10/05 - Inclusào do parâmetro MV_PAR04 - Representante e identação
                   do fonte.
*/
User Function BRFIN011()
     Local cQry     := ''
     Local aEtqExp  := {}
     Local cEmpresa := ""
     Local _cFilial := ""
     Private cPerg  := "FIN011"
     
     If !u_VldAcesso(funname())
     	MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
     	Return 
  	 Endif 
     u_zcfga01( 'BRFIN011' ) //LGS#2021202 - Gravação de log de utilização da rotina
     VldPerg()                     
     Pergunte(cPerg, .T.)
	 
     oPrn := TMSPrinter():New( "Etiquetas de Clientes" )
     oPrn:SetPortrait()      // ou SetLandscape()

     AVPRINT oPrn NAME "Etiquetas Clientes"

             oFont1  := TFont():New("Arial"      ,9,10,.F.,.F.,5,.T.,5,.T.,.F.)
             oFont4  := TFont():New("Arial"      ,9,12,.F.,.T.,5,.F.,5,.T.,.F.) 
             oFont2  := TFont():New("Arial Black",9,12,.F.,.F.,5,.T.,5,.T.,.F.)
             oFont3  := TFont():New("Arial Black",9,14,.F.,.F.,5,.T.,5,.T.,.F.)

             AVPAGE

               nLin     := 050
               nCol     := 060      
               nContEtq := 000

               cQry1 := ""
               cQry1 += " SELECT A1_NOME, A1_CONTATO, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP  "
               cQry1 += " FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "
               cQry1 += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
               cQry1 += "  AND SA1.D_E_L_E_T_ = '' "
               cQry1 += "  AND SA1.A1_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
               If !Empty(Alltrim(mv_par03))
                  cQry1 += "  AND SUBSTRING(SA1.A1_DTNASC, 5, 2) = '"+mv_par03+"' "
               Endif
               If !Empty(Alltrim(mv_par04))
                  cQry1 += "  AND SA1.A1_VEND = '"+mv_par04+"' "
               Endif
               If mv_par06 == 1
                  cQry1 += " ORDER BY SA1.A1_COD "
               Else
                  cQry1 += " ORDER BY SubString(SA1.A1_DTNASC, 7, 2) "
               Endif
               TCQuery cQry1 ALIAS "TMP" NEW

               DbSelectArea("TMP")
               While !EOF()
                     nLinIni = nLin
                     If mv_par05 == 1
                        oPrn:Say (nLin, nCol,'A/C '+SUBSTR(TMP->A1_CONTATO, 1, 34), oFont1)
                        nLin += 30
                     Endif
                     oPrn:Say (nLin, nCol,SUBSTR(TMP->A1_NOME, 1, 34), oFont1)
                     nLin += 30
                     oPrn:Say (nLin, nCol, TMP->A1_END, oFont1)
                     nLin += 30
                     oPrn:Say (nLin, nCol, TMP->A1_BAIRRO, oFont1)
                     nLin += 30
                     oPrn:Say (nLin, nCol, ALLTRIM(TMP->A1_MUN)+"-"+TMP->A1_EST, oFont1)
                     nLin += 30
                     oPrn:Say (nLin, nCol, SUBSTR(TMP->A1_CEP,1,5)+"-"+SUBSTR(TMP->A1_CEP,6,3), oFont1)
                     nContEtq++	
                     DO CASE
                        CASE nCol == 60
                             nCol = 840
                             nLin = nLinIni
                        CASE nCol == 840
                             nCol = 1680
                             nLin = nLinIni
                        CASE nCol == 1680
                             nCol = 60
                             If mv_par05 == 1
                                nLin += 125
                             Else
                                nLin += 155
                             Endif
                     ENDCASE
                     If ncontEtq == 36
                        AVNEWPAGE	       
                          nLin     := 050
                          nCol     := 060   
                          nContEtq := 000
                     Endif   
                     DbSelectArea("TMP")
                     DbSkip()
               Enddo
             AVENDPAGE
     AVENDPRINT

     oFont1:End()
     oFont2:End()
     oFont3:End()
     oFont4:End()

     MS_FLUSH() 
     DbSelectArea("TMP")
     DbCloseArea("TMP")
Return  
   
/*************************************************************************************/
/*** VLDPERG - Validação e inclusão das perguntas SX1                              ***/
/*************************************************************************************/
Static Function VldPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg   := PADR(cPerg, 10)
       aRegs   := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs, {cPerg, "01", "Cliente de       ?", "", "", "mv_ch1", "C", 6, 0, 0, "G", "", "mv_par01", ""      , "", "", "", "", ""          , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1", ""})
       aAdd(aRegs, {cPerg, "02", "Cliente Ate      ?", "", "", "mv_ch2", "C", 6, 0, 0, "G", "", "mv_par02", ""      , "", "", "", "", ""          , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1", ""})
       aAdd(aRegs, {cPerg, "03", "Apenas o Mes     ?", "", "", "mv_ch3", "C", 2, 0, 0, "G", "", "mv_par03", ""      , "", "", "", "", ""          , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , ""})
       aAdd(aRegs, {cPerg, "04", "Representante    ?", "", "", "mv_ch4", "C", 6, 0, 0, "G", "", "mv_par04", ""      , "", "", "", "", ""          , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA3", ""})
       aAdd(aRegs, {cPerg, "05", "Inclui Contato   ?", "", "", "mv_ch5", "C", 6, 0, 0, "C", "", "mv_par05", "Sim"   , "", "", "", "", "Não"       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", ""})
       aAdd(aRegs, {cPerg, "06", "Ordem de Impressao", "", "", "mv_ch6", "N", 1, 0, 0, "C", "", "mv_par06", "Codigo", "", "", "", "", "Nascimento", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "   ", ""})
       For i := 1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j,aRegs[i,j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return
