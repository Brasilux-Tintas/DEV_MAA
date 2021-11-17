#INCLUDE "rwmake.ch"       
#INCLUDE "TOPCONN.CH"
#include "Font.ch"   
#INCLUDE "avprint.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT085 º Autor ³ Luís Gustavo de Souza º Data ³ 02/09/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatórios de Faturamento.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas.                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³   Data   ³  BOPS  ³ Programador ³Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 02/09/03 ³ XXXXXX ³ GUSTAVO     ³ Inicio do desenvolvimento.          ³±±
±±³          ³        ³             ³                                     ³±±
±±³          ³        ³             ³                                     ³±±
±±³          ³        ³             ³                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
User Function BRFAT085()
     Private cPerg := "FAT085"
     
     if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


     //VldPerg()
     If !Pergunte(cPerg,.t.)
        Return
     Else
        mvp01 := mv_par01
     Endif
     
     oFont1 := TFont():New("Courier New Negrito"        ,9,16,.F.,.T.,5,.T.,5,.F.,.F.)
     oFont2 := TFont():New("Courier New Negrito Italico",9,10,.F.,.F.,5,.T.,5,.F.,.F.)
     oFont3 := TFont():New("Courier New"                ,9,08,.F.,.F.,5,.T.,5,.F.,.F.)

     If mvp01 == 1
        cPerg := 'FA0851'
        //VldPerg1()
        If !Pergunte(cPerg,.t.)
           Return
        Else
           MsAguarde({|| FAT0851() },"Aguarde","Buscando informações conforme parâmetros...")     
           DbSelectArea("TCQ")            
           DbGotop()
           If EOF()
              MsgBox("Não há dados a serem processados com estes parâmetros!!!","Atenção","STOP")
              DbSelectArea("TCQ") 
              DbCloseArea()
              Return
           Endif  
        Endif
        Processa({|lEnd| FAT0852()})
     Endif
     DbSelectArea("TCQ")
     DbCloseArea()
Return

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FAT0852  º Autor ³ Luís Gustavo de Souza º Data ³ 02/09/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de Representantes x Linhas de Produtos.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function FAT0852()
       Local _ni
       Private nlinMax  := 2325
       Private nColMax  := 3385
 
       nMes :=  0 
       nLin :=  0
       nLRe :=  0
       nCol := 30

       nMes := Month(dDatabase)

       AVPRINT oPrn NAME "Relatório de Evolução de Faturamento."
               oPrn:SetPage(9)
               oPrn:SetLandscape()
               AVPAGE
                 fCab0851()
                 DbSelectArea("TCQ")
                 If mv_par03 == 3
                    While !Eof()
                          DbSelectArea("SA3")
                          DbSetOrder(1)
                          DbSeek(xFilial("SA3")+TCQ->VENDEDOR,.t.)
                          If Found()
                             If SA3->A3_ATIVO $ "N"
                                DbSelectArea("TCQ")
                                DbSkip()
                                Loop
                             Endif
                          Endif
                          DbSelectArea("TCQ")
                          aQLin := {} ; aVLin := {} ; aTQMes := {0,0,0,0,0,0,0,0,0,0,0,0}
                          aPage := {} ;               aTVMes := {0,0,0,0,0,0,0,0,0,0,0,0}
                          cRepre := TCQ->VENDEDOR
                          oPrn:Say( nLRe, nCol+450 , cRepre+" - "+Posicione("SA3",1,xFilial("SA3")+cRepre,"A3_NOME") , oFont2)
                          oPrn:Say( 0265   , nCol+0270, "Janeiro"          , oFont2)
                          oPrn:Say( 0315   , nCol+0150, " Qtde.     Valor ", oFont2)
                          oPrn:Say( 0265   , nCol+0690, "Fevereiro"        , oFont2)
                          oPrn:Say( 0315   , nCol+0600, " Qtde.     Valor ", oFont2)
                          oPrn:Say( 0265   , nCol+1210, "Março"            , oFont2)
                          oPrn:Say( 0315   , nCol+1060, " Qtde.     Valor ", oFont2)
                          oPrn:Say( 0265   , nCol+1670, "Abril"            , oFont2)
                          oPrn:Say( 0315   , nCol+1520, " Qtde.     Valor ", oFont2)
                          oPrn:Say( 0265   , nCol+2130, "Maio"             , oFont2)
                          oPrn:Say( 0315   , nCol+1980, " Qtde.     Valor ", oFont2)
                          oPrn:Say( 0265   , nCol+2590, "Junho"            , oFont2)
                          oPrn:Say( 0315   , nCol+2440, " Qtde.     Valor ", oFont2)
                          If nMes > 6
                             oPrn:Say( 0265   , nCol+3050, "Julho"    , oFont2)
                             oPrn:Say( 0315   , nCol+2900, " Qtde.     Valor ", oFont2)
                          Else
                             oPrn:Say( 0265   , nCol+3050, "TOTAL"    , oFont2)
                             oPrn:Say( 0315   , nCol+2900, " Qtde.     Valor ", oFont2)
                          Endif
                          While !Eof() .and. TCQ->VENDEDOR == cRepre
                                oPrn:Say( nLin   , nCol+0050, TCQ->LINHA , oFont3)
                                oPrn:Say( nLin   , nCol+0150, Transform(TCQ->Q01,"@E 999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0350, Transform(TCQ->V01,"@E 9,999,999.99"), oFont3)
                                oPrn:Say( nLin   , nCol+0600, Transform(TCQ->Q02,"@E 999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0800, Transform(TCQ->V02,"@E 9,999,999.99"), oFont3)
                                oPrn:Say( nLin   , nCol+1060, Transform(TCQ->Q03,"@E 999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1260, Transform(TCQ->V03,"@E 9,999,999.99"), oFont3)
                                oPrn:Say( nLin   , nCol+1520, Transform(TCQ->Q04,"@E 999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1720, Transform(TCQ->V04,"@E 9,999,999.99"), oFont3)
                                oPrn:Say( nLin   , nCol+1980, Transform(TCQ->Q05,"@E 999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2180, Transform(TCQ->V05,"@E 9,999,999.99"), oFont3)
                                oPrn:Say( nLin   , nCol+2440, Transform(TCQ->Q06,"@E 999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2640, Transform(TCQ->V06,"@E 9,999,999.99"), oFont3)
                                If nMes > 6
                                   oPrn:Say( nLin   , nCol+2900, Transform(TCQ->Q07,"@E 999,999.99") , oFont3)
                                   oPrn:Say( nLin   , nCol+3100, Transform(TCQ->V07,"@E 9,999,999.99"), oFont3)
                                   aadd(aQLin,{TCQ->LINHA,TCQ->Q01,TCQ->Q02,TCQ->Q03,TCQ->Q04,TCQ->Q05,TCQ->Q06,TCQ->Q07,TCQ->Q08,TCQ->Q09,TCQ->Q10,TCQ->Q11,TCQ->Q12})
                                   aTQMes[01] += TCQ->Q01 ; aTQMes[02] += TCQ->Q02
                                   aTQMes[03] += TCQ->Q03 ; aTQMes[04] += TCQ->Q04
                                   aTQMes[05] += TCQ->Q05 ; aTQMes[06] += TCQ->Q06
                                   aTQMes[07] += TCQ->Q07 ; aTQMes[08] += TCQ->Q08
                                   aTQMes[09] += TCQ->Q09 ; aTQMes[10] += TCQ->Q10
                                   aTQMes[11] += TCQ->Q11 ; aTQMes[12] += TCQ->Q12
                                   aadd(aVLin,{TCQ->LINHA,TCQ->Q01,TCQ->Q02,TCQ->Q03,TCQ->Q04,TCQ->Q05,TCQ->Q06,TCQ->Q07,TCQ->Q08,TCQ->Q09,TCQ->Q10,TCQ->Q11,TCQ->Q12})
                                   aTVMes[01] += TCQ->V01 ; aTVMes[02] += TCQ->V02
                                   aTVMes[03] += TCQ->V03 ; aTVMes[04] += TCQ->V04
                                   aTVMes[05] += TCQ->V05 ; aTVMes[06] += TCQ->V06
                                   aTVMes[07] += TCQ->V07 ; aTVMes[08] += TCQ->V08
                                   aTVMes[09] += TCQ->V09 ; aTVMes[10] += TCQ->V10
                                   aTVMes[11] += TCQ->V11 ; aTVMes[12] += TCQ->V12
                                   aadd(aPage,{TCQ->LINHA, TCQ->Q08, TCQ->V08, TCQ->Q09, TCQ->V09, TCQ->Q10, TCQ->V10, TCQ->Q11, TCQ->V11, TCQ->Q12, TCQ->V12,;
                                              (TCQ->Q01+TCQ->Q02+TCQ->Q03+TCQ->Q04+TCQ->Q05+TCQ->Q06+TCQ->Q07+TCQ->Q08+TCQ->Q09+TCQ->Q10+TCQ->Q11+TCQ->Q12),;
                                              (TCQ->V01+TCQ->V02+TCQ->V03+TCQ->V04+TCQ->V05+TCQ->V06+TCQ->V07+TCQ->V08+TCQ->V09+TCQ->V10+TCQ->V11+TCQ->V12)  })
                                Else
                                   oPrn:Say( nLin   , nCol+2900, Transform((TCQ->Q01+TCQ->Q02+TCQ->Q03+TCQ->Q04+TCQ->Q05+TCQ->Q06+TCQ->Q07+TCQ->Q08+TCQ->Q09+TCQ->Q10+TCQ->Q11+TCQ->Q12),"@E 9,999,999.99"), oFont3)
                                   oPrn:Say( nLin   , nCol+3140, Transform((TCQ->V01+TCQ->V02+TCQ->V03+TCQ->V04+TCQ->V05+TCQ->V06+TCQ->V07+TCQ->V08+TCQ->V09+TCQ->V10+TCQ->V11+TCQ->V12),"@E 9,999,999.99"), oFont3)
                                   aTQMes[01] += TCQ->Q01 ; aTQMes[02] += TCQ->Q02
                                   aTQMes[03] += TCQ->Q03 ; aTQMes[04] += TCQ->Q04
                                   aTQMes[05] += TCQ->Q05 ; aTQMes[06] += TCQ->Q06
                                   aTVMes[01] += TCQ->V01 ; aTVMes[02] += TCQ->V02
                                   aTVMes[03] += TCQ->V03 ; aTVMes[04] += TCQ->V04
                                   aTVMes[05] += TCQ->V05 ; aTVMes[06] += TCQ->V06
                                Endif
                                oPrn:Line(nlin+32, nCol    , nlin+32, nColMax)
                                nLin += 40
                                DbSelectArea("TCQ")
                                DbSkip()
                          Enddo
                          /* T O T A I S */
                          If nMes > 6 // Se o mes da data base for maior que o mes 6 totaliza e imprime os outros meses restantes
                             oPrn:Say( nLin   , nCol+0010, "TOTAL",oFont2)
                             oPrn:Say( nLin+05, nCol+0150, Transform(aTQMes[01],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+0350, Transform(aTVMes[01],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+0600, Transform(aTQMes[02],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+0800, Transform(aTVMes[02],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+1060, Transform(aTQMes[03],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+1260, Transform(aTVMes[03],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+1520, Transform(aTQMes[04],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+1720, Transform(aTVMes[04],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+1980, Transform(aTQMes[05],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+2180, Transform(aTVMes[05],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+2440, Transform(aTQMes[06],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+2640, Transform(aTVMes[06],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+2900, Transform(aTQMes[07],"@E 999,999.99") , oFont3)
                             oPrn:Say( nLin+05, nCol+3100, Transform(aTVMes[07],"@E 9,999,999.99"), oFont3)
                             oPrn:Line(nlin+40, nCol, nlin+40, nColMax)
                             oPrn:Line(nlinMax, nCol, nlinMax, nColMax)
                             /* I M P R E S S Ã O   D O S   M E S E S   R E S T A N T E S */
                             AVNEWPAGE
                             nLin := 0
                             fCab0851()
                             oPrn:Say( nLRe, nCol+450 , cRepre+" - "+Posicione("SA3",1,xFilial("SA3")+cRepre,"A3_NOME") , oFont2)
                             oPrn:Say( 0265   , nCol+0280, "Agosto"  , oFont2)
                             oPrn:Say( 0315   , nCol+0150, " Qtde.     Valor ", oFont2)
                             oPrn:Say( 0265   , nCol+0700, "Setembro", oFont2)
                             oPrn:Say( 0315   , nCol+0600, " Qtde.     Valor ", oFont2)
                             oPrn:Say( 0265   , nCol+1210, "Outubro" , oFont2)
                             oPrn:Say( 0315   , nCol+1060, " Qtde.     Valor ", oFont2)
                             oPrn:Say( 0265   , nCol+1670, "Novembro", oFont2)
                             oPrn:Say( 0315   , nCol+1520, " Qtde.     Valor ", oFont2)
                             oPrn:Say( 0265   , nCol+2130, "Dezembro", oFont2)
                             oPrn:Say( 0315   , nCol+1980, " Qtde.     Valor ", oFont2)
                             oPrn:Say( 0265   , nCol+2590, "TOTAL"            , oFont2)
                             oPrn:Say( 0315   , nCol+2440, " Qtde.     Valor ", oFont2)
                             For _ni := 1 to Len(aPage)
                                 oPrn:Say( nLin   , nCol+0050, aPage[_ni][01] , oFont3)
                                 oPrn:Say( nLin   , nCol+0150, Transform(aPage[_ni][02],"@E 999,999.99")  , oFont3)
                                 oPrn:Say( nLin   , nCol+0350, Transform(aPage[_ni][03],"@E 9,999,999.99"), oFont3)
                                 oPrn:Say( nLin   , nCol+0600, Transform(aPage[_ni][04],"@E 999,999.99")  , oFont3)
                                 oPrn:Say( nLin   , nCol+0800, Transform(aPage[_ni][05],"@E 9,999,999.99"), oFont3)
                                 oPrn:Say( nLin   , nCol+1060, Transform(aPage[_ni][06],"@E 999,999.99")  , oFont3)
                                 oPrn:Say( nLin   , nCol+1260, Transform(aPage[_ni][07],"@E 9,999,999.99"), oFont3)
                                 oPrn:Say( nLin   , nCol+1520, Transform(aPage[_ni][08],"@E 999,999.99")  , oFont3)
                                 oPrn:Say( nLin   , nCol+1720, Transform(aPage[_ni][09],"@E 9,999,999.99"), oFont3)
                                 oPrn:Say( nLin   , nCol+1980, Transform(aPage[_ni][10],"@E 999,999.99")  , oFont3)
                                 oPrn:Say( nLin   , nCol+2180, Transform(aPage[_ni][11],"@E 9,999,999.99"), oFont3)
                                 oPrn:Say( nLin   , nCol+2440, Transform(aPage[_ni][12],"@E 9,999,999.99"), oFont3)
                                 oPrn:Say( nLin   , nCol+2680, Transform(aPage[_ni][13],"@E 9,999,999.99"), oFont3)
                                 oPrn:Line(nlin+32, nCol    , nlin+32, nColMax)
                                 nLin += 40
                             Next
                             /*T O T A I S   D O S   M E S E S   R E S T A N T E S */
                             oPrn:Say( nLin   , nCol+0010, "TOTAL",oFont2)
                             oPrn:Say( nLin+05, nCol+0150, Transform(aTQMes[08],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+0350, Transform(aTVMes[08],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+0600, Transform(aTQMes[09],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+0800, Transform(aTVMes[09],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+1060, Transform(aTQMes[10],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+1260, Transform(aTVMes[10],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+1520, Transform(aTQMes[11],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+1720, Transform(aTVMes[11],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin+05, nCol+1980, Transform(aTQMes[12],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin+05, nCol+2180, Transform(aTVMes[12],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+2440, Transform((aTQMes[01]+aTQMes[02]+aTQMes[03]+aTQMes[04]+aTQMes[05]+aTQMes[06]+aTQMes[07]+aTQMes[08]+aTQMes[09]+aTQMes[10]+aTQMes[11]+aTQMes[12]),"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+2680, Transform((aTVMes[01]+aTVMes[02]+aTVMes[03]+aTVMes[04]+aTVMes[05]+aTVMes[06]+aTVMes[07]+aTVMes[08]+aTVMes[09]+aTVMes[10]+aTVMes[11]+aTVMes[12]),"@E 99,999,999.99"), oFont3)
                             oPrn:Line(nlin+40, nCol, nlin+40, nColMax)
                          Else /* T O T A I S   A T E   J U N H O */
                             oPrn:Say( nLin   , nCol+0010, "TOTAL",oFont2)
                             oPrn:Say( nLin   , nCol+0150, Transform(aTQMes[01],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin   , nCol+0350, Transform(aTVMes[01],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+0600, Transform(aTQMes[02],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin   , nCol+0800, Transform(aTVMes[02],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+1060, Transform(aTQMes[03],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin   , nCol+1260, Transform(aTVMes[03],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+1520, Transform(aTQMes[04],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin   , nCol+1720, Transform(aTVMes[04],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+1980, Transform(aTQMes[05],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin   , nCol+2180, Transform(aTVMes[05],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+2440, Transform(aTQMes[06],"@E 999,999.99")  , oFont3)
                             oPrn:Say( nLin   , nCol+2640, Transform(aTVMes[06],"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+2900, Transform((aTQMes[01]+aTQMes[02]+aTQMes[03]+aTQMes[04]+aTQMes[05]+aTQMes[06]+aTQMes[07]+aTQMes[08]+aTQMes[09]+aTQMes[10]+aTQMes[11]+aTQMes[12]),"@E 9,999,999.99"), oFont3)
                             oPrn:Say( nLin   , nCol+3140, Transform((aTVMes[01]+aTVMes[02]+aTVMes[03]+aTVMes[04]+aTVMes[05]+aTVMes[06]+aTVMes[07]+aTVMes[08]+aTVMes[09]+aTVMes[10]+aTVMes[11]+aTVMes[12]),"@E 99,999,999.99"), oFont3)
                             oPrn:Line(nlin+40, nCol, nlin+40, nColMax)
                          Endif
                          oPrn:Line(nlinMax, nCol, nlinMax, nColMax)
                          If !Eof()
                             AVNEWPAGE
                             nLin := 0
                             fCab0851()
                          EndIf
                    Enddo
                 ElseIf mv_par03 == 2
                    While !Eof()
                          DbSelectArea("SA3")
                          DbSetOrder(1)
                          DbSeek(xFilial("SA3")+TCQ->VENDEDOR,.t.)
                          If Found()
                             If SA3->A3_ATIVO $ "N"
                                DbSelectArea("TCQ")
                                DbSkip()
                                Loop
                             Endif
                          Endif
                          DbSelectArea("TCQ")
                          aTVMes := {0,0,0,0,0,0,0,0,0,0,0,0}
                          cRepre := TCQ->VENDEDOR
                          oPrn:Say( nLRe, nCol+450 , cRepre+" - "+Posicione("SA3",1,xFilial("SA3")+cRepre,"A3_NOME") , oFont2)
                          oPrn:Say( 0265   , nCol+0160, "Janeiro"          , oFont2)
                          oPrn:Say( 0265   , nCol+0400, "Fevereiro"        , oFont2)
                          oPrn:Say( 0265   , nCol+0690, "Março"            , oFont2)
                          oPrn:Say( 0265   , nCol+0940, "Abril"            , oFont2)
                          oPrn:Say( 0265   , nCol+1210, "Maio"             , oFont2)
                          oPrn:Say( 0265   , nCol+1440, "Junho"            , oFont2)
                          oPrn:Say( 0265   , nCol+1700, "Julho"            , oFont2)
                          oPrn:Say( 0265   , nCol+1935, "Agosto"           , oFont2)
                          oPrn:Say( 0265   , nCol+2160, "Setembro"         , oFont2)
                          oPrn:Say( 0265   , nCol+2410, "Outubro"          , oFont2)
                          oPrn:Say( 0265   , nCol+2660, "Novembro"         , oFont2)
                          oPrn:Say( 0265   , nCol+2910, "Dezembro"         , oFont2)
                          oPrn:Say( 0265   , nCol+3180, "TOTAL"            , oFont2)
                          While !Eof() .and. TCQ->VENDEDOR == cRepre
                                oPrn:Say( nLin   , nCol+0050, TCQ->LINHA , oFont3)
                                oPrn:Say( nLin   , nCol+0150, Transform(TCQ->V01,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0400, Transform(TCQ->V02,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0650, Transform(TCQ->V03,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0900, Transform(TCQ->V04,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1150, Transform(TCQ->V05,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1400, Transform(TCQ->V06,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1650, Transform(TCQ->V07,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1900, Transform(TCQ->V08,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2150, Transform(TCQ->V09,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2400, Transform(TCQ->V10,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2650, Transform(TCQ->V11,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2900, Transform(TCQ->V12,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+3150, Transform((+TCQ->V01+TCQ->V02+TCQ->V03+TCQ->V04+TCQ->V05+TCQ->V06+TCQ->V07+TCQ->V08+TCQ->V09+TCQ->V10+TCQ->V11+TCQ->V12),"@E 9,999,999.99")  , oFont3)
                                oPrn:Line(nlin+32, nCol    , nlin+32, nColMax)
                                nLin += 40
                                aTVMes[01] += TCQ->V01 ; aTVMes[02] += TCQ->V02
                                aTVMes[03] += TCQ->V03 ; aTVMes[04] += TCQ->V04
                                aTVMes[05] += TCQ->V05 ; aTVMes[06] += TCQ->V06
                                aTVMes[07] += TCQ->V07 ; aTVMes[08] += TCQ->V08
                                aTVMes[09] += TCQ->V09 ; aTVMes[10] += TCQ->V10
                                aTVMes[11] += TCQ->V11 ; aTVMes[12] += TCQ->V12

                                DbSelectArea("TCQ")
                                DbSkip()
                          Enddo
                          oPrn:Say( nLin   , nCol+0010, "TOTAL",oFont2)
                          oPrn:Say( nLin+05, nCol+0150, Transform(aTVMes[01],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+0400, Transform(aTVMes[02],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+0650, Transform(aTVMes[03],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+0900, Transform(aTVMes[04],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1150, Transform(aTVMes[05],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1400, Transform(aTVMes[06],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1650, Transform(aTVMes[07],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1900, Transform(aTVMes[08],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2150, Transform(aTVMes[09],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2400, Transform(aTVMes[10],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2650, Transform(aTVMes[11],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2900, Transform(aTVMes[12],"@E 99,999,999.99"), oFont3)
                          oPrn:Say( nLin   , nCol+3150, Transform((aTVMes[01]+aTVMes[02]+aTVMes[03]+aTVMes[04]+aTVMes[05]+aTVMes[06]+aTVMes[07]+aTVMes[08]+aTVMes[09]+aTVMes[10]+aTVMes[11]+aTVMes[12]),"@E 99,999,999.99"), oFont3)
                          oPrn:Line(nlin+40, nCol, nlin+40, nColMax)
                          oPrn:Line(nlinMax, nCol, nlinMax, nColMax)
                          If !Eof()
                             AVNEWPAGE
                             nLin := 0
                             fCab0851()
                          EndIf
                    Enddo
                 Else
                    While !Eof()
                          DbSelectArea("SA3")
                          DbSetOrder(1)
                          DbSeek(xFilial("SA3")+TCQ->VENDEDOR,.t.)
                          If Found()
                             If SA3->A3_ATIVO $ "N"
                                DbSelectArea("TCQ")
                                DbSkip()
                                Loop
                             Endif
                          Endif
                          DbSelectArea("TCQ")
                          aTQMes := {0,0,0,0,0,0,0,0,0,0,0,0}
                          cRepre := TCQ->VENDEDOR
                          oPrn:Say( nLRe, nCol+450 , cRepre+" - "+Posicione("SA3",1,xFilial("SA3")+cRepre,"A3_NOME") , oFont2)
                          oPrn:Say( 0265   , nCol+0160, "Janeiro"          , oFont2)
                          oPrn:Say( 0265   , nCol+0400, "Fevereiro"        , oFont2)
                          oPrn:Say( 0265   , nCol+0690, "Março"            , oFont2)
                          oPrn:Say( 0265   , nCol+0940, "Abril"            , oFont2)
                          oPrn:Say( 0265   , nCol+1210, "Maio"             , oFont2)
                          oPrn:Say( 0265   , nCol+1440, "Junho"            , oFont2)
                          oPrn:Say( 0265   , nCol+1700, "Julho"            , oFont2)
                          oPrn:Say( 0265   , nCol+1935, "Agosto"           , oFont2)
                          oPrn:Say( 0265   , nCol+2160, "Setembro"         , oFont2)
                          oPrn:Say( 0265   , nCol+2410, "Outubro"          , oFont2)
                          oPrn:Say( 0265   , nCol+2660, "Novembro"         , oFont2)
                          oPrn:Say( 0265   , nCol+2910, "Dezembro"         , oFont2)
                          oPrn:Say( 0265   , nCol+3180, "TOTAL"            , oFont2)
                          While !Eof() .and. TCQ->VENDEDOR == cRepre
                                oPrn:Say( nLin   , nCol+0050, TCQ->LINHA , oFont3)
                                oPrn:Say( nLin   , nCol+0150, Transform(TCQ->Q01,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0400, Transform(TCQ->Q02,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0650, Transform(TCQ->Q03,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+0900, Transform(TCQ->Q04,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1150, Transform(TCQ->Q05,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1400, Transform(TCQ->Q06,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1650, Transform(TCQ->Q07,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+1900, Transform(TCQ->Q08,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2150, Transform(TCQ->Q09,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2400, Transform(TCQ->Q10,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2650, Transform(TCQ->Q11,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+2900, Transform(TCQ->Q12,"@E 9,999,999.99")  , oFont3)
                                oPrn:Say( nLin   , nCol+3150, Transform((+TCQ->Q01+TCQ->Q02+TCQ->Q03+TCQ->Q04+TCQ->Q05+TCQ->Q06+TCQ->Q07+TCQ->Q08+TCQ->Q09+TCQ->Q10+TCQ->Q11+TCQ->Q12),"@E 9,999,999.99")  , oFont3)
                                oPrn:Line(nlin+32, nCol    , nlin+32, nColMax)
                                nLin += 40
                                aTQMes[01] += TCQ->Q01 ; aTQMes[02] += TCQ->Q02
                                aTQMes[03] += TCQ->Q03 ; aTQMes[04] += TCQ->Q04
                                aTQMes[05] += TCQ->Q05 ; aTQMes[06] += TCQ->Q06
                                aTQMes[07] += TCQ->Q07 ; aTQMes[08] += TCQ->Q08
                                aTQMes[09] += TCQ->Q09 ; aTQMes[10] += TCQ->Q10
                                aTQMes[11] += TCQ->Q11 ; aTQMes[12] += TCQ->Q12
                                DbSelectArea("TCQ")
                                DbSkip()
                          Enddo
                          oPrn:Say( nLin   , nCol+0010, "TOTAL",oFont2)
                          oPrn:Say( nLin+05, nCol+0150, Transform(aTQMes[01],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+0400, Transform(aTQMes[02],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+0650, Transform(aTQMes[03],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+0900, Transform(aTQMes[04],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1150, Transform(aTQMes[05],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1400, Transform(aTQMes[06],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1650, Transform(aTQMes[07],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+1900, Transform(aTQMes[08],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2150, Transform(aTQMes[09],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2400, Transform(aTQMes[10],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2650, Transform(aTQMes[11],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin+05, nCol+2900, Transform(aTQMes[12],"@E 9,999,999.99"), oFont3)
                          oPrn:Say( nLin   , nCol+3150, Transform((aTQMes[01]+aTQMes[02]+aTQMes[03]+aTQMes[04]+aTQMes[05]+aTQMes[06]+aTQMes[07]+aTQMes[08]+aTQMes[09]+aTQMes[10]+aTQMes[11]+aTQMes[12]),"@E 9,999,999.99"), oFont3)
                          oPrn:Line(nlin+40, nCol, nlin+40, nColMax)
                          oPrn:Line(nlinMax, nCol, nlinMax, nColMax)
                          If !Eof()
                             AVNEWPAGE
                             nLin := 0
                             fCab0851()
                          EndIf
                    Enddo
                 Endif
               AVENDPAGE
       AVENDPRINT
       MS_FLUSH()
Return

Static Function fCab0851()
       nLin += 30
       oPrn:Box( nLin, nCol, nLin+120, nColMax )
       nLin += 30
       If mvp01 == 1
          If mv_par03 == 3
             oPrn:Say( nLin, nCol+900, "REPRESENTANTES X LINHAS DE PRODUTOS (Qtde.+Valor) - Em "+iif(mv_par07 == 1,"Litros","Kilogramas")  , oFont1)
          ElseIf mv_par03 == 2
                 oPrn:Say( nLin, nCol+900, "REPRESENTANTES X LINHAS DE PRODUTOS (Valor) - Em "+iif(mv_par07 == 1,"Litros","Kilogramas"), oFont1)
          Else
             oPrn:Say( nLin, nCol+900, "REPRESENTANTES X LINHAS DE PRODUTOS (Qtde.) - Em "+iif(mv_par07 == 1,"Litros","Kilogramas"), oFont1)
          Endif
       Endif
       nLin += 100
       oPrn:Box( nLin, nCol    , nLin+50, nColMax )
       //oPrn:Say( nLin, nCol+20 , "Empresa : "+Iif(mv_par04 == 1,"Brasilux",Iif(mv_par04==2,"Teste","Ambas")), oFont2)
       oPrn:Say( nLin, nCol+600, "Ano     : "+mv_par05, oFont2)
       nLin += 50
       If mvp01 == 1
          nLRe := nLin
          oPrn:Say( nLin, nCol, "Representante: ", oFont2)
          nLin += 55
       Endif
       If mv_par03 == 3
          oPrn:Box( nLin   , nCol+140, nLin+0050, nColMax )
          nLin += 50
          oPrn:Box( nLin   , nCol    , nLin+045, nColMax)
          oPrn:Say( nLin   , nCol+010, "Linha", oFont2)
          nLin += 50
          oPrn:Line(nlin-005, nCol     , nlinMax, nCol   )
          oPrn:Line(nlin-055, nCol+0140, nlinMax, nCol+0140)
          oPrn:Line(nlin-100, nCol+0590, nlinMax, nCol+0590)
          oPrn:Line(nlin-100, nCol+1050, nlinMax, nCol+1050)
          oPrn:Line(nlin-100, nCol+1510, nlinMax, nCol+1510)
          oPrn:Line(nlin-100, nCol+1970, nlinMax, nCol+1970)
          oPrn:Line(nlin-100, nCol+2430, nlinMax, nCol+2430)
          oPrn:Line(nlin-100, nCol+2890, nlinMax, nCol+2890)
          oPrn:Line(nlin-005, nCol+3350, nlinMax, nCol+3350)
       Else
              oPrn:Box( nLin   , nCol    , nLin+045, nColMax)
              oPrn:Say( nLin   , nCol+010, "Linha", oFont2)
              nLin += 50
              oPrn:Line(nlin-005, nCol     , nlinMax, nCol   )
              oPrn:Line(nlin-050, nCol+0140, nlinMax, nCol+0140)
              oPrn:Line(nlin-050, nCol+0390, nlinMax, nCol+0390)
              oPrn:Line(nlin-050, nCol+0640, nlinMax, nCol+0640)
              oPrn:Line(nlin-050, nCol+0890, nlinMax, nCol+0890)
              oPrn:Line(nlin-050, nCol+1140, nlinMax, nCol+1140)
              oPrn:Line(nlin-050, nCol+1390, nlinMax, nCol+1390)
              oPrn:Line(nlin-050, nCol+1640, nlinMax, nCol+1640)
              oPrn:Line(nlin-050, nCol+1890, nlinMax, nCol+1890)
              oPrn:Line(nlin-050, nCol+2140, nlinMax, nCol+2140)
              oPrn:Line(nlin-050, nCol+2390, nlinMax, nCol+2390)
              oPrn:Line(nlin-050, nCol+2640, nlinMax, nCol+2640)
              oPrn:Line(nlin-050, nCol+2890, nlinMax, nCol+2890)
              oPrn:Line(nlin-050, nCol+3140, nlinMax, nCol+3140)
              oPrn:Line(nlin-005, nColMax, nlinMax, nColMax)
       Endif
Return

/*
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FAT0851  º Autor ³ Luís Gustavo de Souza º Data ³ 02/09/03 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Busca de informações.                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
Static Function FAT0851()
	Local cQry1 := ""
    Private cUnid	:= iif(mv_par07 == 1,"'L'","'K','KG'") 

    //Local cEmp := Iif(mv_par04 == 1,"'01'",Iif(mv_par04==2,"'02'","'01','02'"))
       
    If mvp01 == 1
    	cQry1 := " SELECT SUBSTRING(D2_COD,4,2) AS LINHA, C5_VEND1 AS 'VENDEDOR', "
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"01%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q01,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"02%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q02,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"03%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q03,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"04%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q04,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"05%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q05,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"06%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q06,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"07%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q07,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"08%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q08,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"09%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q09,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"10%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q10,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"11%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q11,"
		cQry1 += " SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"12%' THEN CASE WHEN D2_UM IN ("+cUnid+") THEN D2_QUANT WHEN D2_SEGUM IN ("+cUnid+") THEN D2_QTSEGUM ELSE 0 END ELSE 0 END) AS Q12,"
		cQry1 += " V01 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"01%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V02 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"02%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V03 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"03%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V04 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"04%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V05 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"05%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V06 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"06%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V07 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"07%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V08 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"08%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V09 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"09%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V10 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"10%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V11 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"11%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END),"
		cQry1 += " V12 = SUM(CASE WHEN D2_EMISSAO LIKE '"+mv_par05+"12%' THEN D2_TOTAL/(CASE WHEN C5_ESPECI4 > '' THEN 0.7 ELSE 1 END) ELSE 0 END) "
		cQry1 += " FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON (SC5.D_E_L_E_T_ <> '*') AND (C5_FILIAL = '"+xFilial("SC5")+"') AND (C5_NUM = D2_PEDIDO) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (D2_COD = B1_COD) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON (SF4.D_E_L_E_T_ <> '*') AND (F4_FILIAL = '"+xFilial("SF4")+"') AND (D2_TES = F4_CODIGO) "
		cQry1 += " LEFT OUTER JOIN "+RetSqlName("SF2")+" SF2 WITH (NOLOCK) ON (SF2.D_E_L_E_T_ <> '*') AND (F2_FILIAL = '"+xFilial("SF2")+"') AND (D2_SERIE = F2_SERIE) AND (D2_DOC = F2_DOC) AND (D2_CLIENTE = F2_CLIENTE) "
		cQry1 += " WHERE (SD2.D_E_L_E_T_ <> '*') AND (SD2.D2_FILIAL = '"+xFilial("SD2")+"') AND (D2_TIPO = 'N') AND (LEN(D2_COD) = 12) "
		cQry1 += " AND ((F4_DUPLIC <> 'N') OR (D2_TES = '519')) "
		If Mv_Par03 == 3
			cQry1 += " AND ((D2_UM IN ("+cUnid+")) OR (D2_SEGUM IN ("+cUnid+"))) "
		Endif
		If !Empty(mv_par01)
			cQry1 += " AND (F2_VEND1 BETWEEN '"+(ALLTRIM(MV_PAR01))+"' AND '"+(ALLTRIM(MV_PAR02))+"') "		
		Endif
		cQry1 += " AND (SD2.D2_EMISSAO LIKE '"+mv_par05+"%') "+;
				 " GROUP BY C5_VEND1, SUBSTRING(D2_COD,4,2) ORDER BY C5_VEND1,LINHA "
	       
       /*
          cQry += "SELECT ZE.ZE_LINHA AS 'LINHA', ZE.ZE_VEND1 AS 'VENDEDOR', "
          cQry += "       Sum(ZE.ZE_Q01) AS 'Q01', Sum(ZE.ZE_V01) AS 'V01', "
          cQry += "       Sum(ZE.ZE_Q02) AS 'Q02', Sum(ZE.ZE_V02) AS 'V02', "
          cQry += "       Sum(ZE.ZE_Q03) AS 'Q03', Sum(ZE.ZE_V03) AS 'V03', "
          cQry += "       Sum(ZE.ZE_Q04) AS 'Q04', Sum(ZE.ZE_V04) AS 'V04', "
          cQry += "       Sum(ZE.ZE_Q05) AS 'Q05', Sum(ZE.ZE_V05) AS 'V05', "
          cQry += "       Sum(ZE.ZE_Q06) AS 'Q06', Sum(ZE.ZE_V06) AS 'V06', "
          cQry += "       Sum(ZE.ZE_Q07) AS 'Q07', Sum(ZE.ZE_V07) AS 'V07', "
          cQry += "       Sum(ZE.ZE_Q08) AS 'Q08', Sum(ZE.ZE_V08) AS 'V08', "
          cQry += "       Sum(ZE.ZE_Q09) AS 'Q09', Sum(ZE.ZE_V09) AS 'V09', "
          cQry += "       Sum(ZE.ZE_Q10) AS 'Q10', Sum(ZE.ZE_V10) AS 'V10', "
          cQry += "       Sum(ZE.ZE_Q11) AS 'Q11', Sum(ZE.ZE_V11) AS 'V11', "
          cQry += "       Sum(ZE.ZE_Q12) AS 'Q12', Sum(ZE.ZE_V12) AS 'V12' "
          cQry += "FROM DADOSADV.dbo."+RetSqlName("SZE")+" ZE "
          cQry += "WHERE ZE.D_E_L_E_T_ IN('')  "
          cQry += "  AND ZE.ZE_FILIAL  IN('"+xFilial("SZE")+"') "
          cQry += "  AND ZE.ZE_EMPRESA IN("+cEmp+") "
          cQry += "  AND ZE.ZE_ANO='"+mv_par05+"' "
          cQry += "  AND ZE.ZE_VEND1 BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
          cQry += "GROUP BY ZE.ZE_LINHA, ZE.ZE_VEND1 "
          cQry += "ORDER BY ZE.ZE_VEND1, ZE.ZE_LINHA " */
          
       Endif
       TCQuery cQry1 ALIAS "TCQ" NEW
       //DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQry1), "TCQ", .F.)
Return
/*
Static Function VldPerg() 
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       aRegs:={}
       cPerg := PADR(cPerg,10)
       //          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Relatório         ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Repres.X Linha","","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","",""})
       For i:=1 to Len(aRegs)
           If ! dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next
       dbSelectArea(_sAlias)
Return

Static Function VldPerg1() 
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       aRegs:={}
       cPerg := PADR(cPerg,10)
       //          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Do representante  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01"," ","","","",""," ","","","",""," ","","","",""," ","","","",""," ","","","","","","SA3"})       
       AADD(aRegs,{cPerg,"02","Ate representante ?","","","mv_ch2","C",06,0,0,"G","","mv_par02"," ","","","",""," ","","","",""," ","","","",""," ","","","",""," ","","","","","","SA3"})       
       AADD(aRegs,{cPerg,"03","Qtde./Valor/Ambas ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Quantidade"    ,"","","","","Valor","","","","","Ambas","","","","","","","","","","","","","","",""})
     //AADD(aRegs,{cPerg,"04","Empresa           ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Brasilux"      ,"","","","","Teste","","","","","Ambas","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"05","Ano               ?","","","mv_ch5","C",04,0,0,"G","","mv_par05",""              ,"","","","",""     ,"","","","",""     ,"","","","","","","","","","","","","","",""})       
       AADD(aRegs,{cPerg,"06","Somente Ativos    ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim"           ,"","","","","Não"  ,"","","","",""     ,"","","","","","","","","","","","","","",""})

       For i:=1 to Len(aRegs)
           If ! dbSeek(cPerg+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                  Endif
              Next
              MsUnlock()
           Endif
       Next
       dbSelectArea(_sAlias)
   	   
   	   PutSX1(cPerg, "07",  "Litro ou Kg", "Litro ou Kg", "Litro ou Kg", "mv_ch7", "N",  1, 0, 1, "C", " ",   " ", " ", " ", "mv_par07", "Litros"       , "Litros", "Litros", "","Kilogramas", "Kilogramas","Kilogramas", "","","", "", "", ""     , "" ,  "",  ""  , {},{},{}     ,cPerg)       
Return
*/