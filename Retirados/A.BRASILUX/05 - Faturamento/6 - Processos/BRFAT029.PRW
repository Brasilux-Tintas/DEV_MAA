#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFAT029 ºAutor  ³ Cleber O. Dominguesº Data ³  12/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de compensacao de comissao. Executar antes de Atua-º±±
±±º          ³ lizar pagto de comissao.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFAT029            
     @ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Compensacao de Comissao"
     @ 91,139 BMPBUTTON TYPE 5 ACTION Pergunte("BRFT29")
     @ 91,168 BMPBUTTON TYPE 1 ACTION ExecBlock("FAT029_1", .f., .f.)
     @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
     @ 23,16 SAY "Este programa faz o processamento de todas as comissoes  ref.  a"
     @ 33,16 SAY "duplicatas pagas no mes informado, gravando as compensacoes com"
     @ 43,16 SAY "base no Lucro da Empresa. Deve ser executada antes de imprimir o"
     @ 53,16 SAY "relatorio de Comissoes e antes de Atualizar Pagto de comissoes."
     @ 8,10 TO 84,222
     ACTIVATE DIALOG oDlg1
Return Nil

/*******************************************************************************/
/*** FAT029_1 - Chamada da rotina pela função PROCESSA                       ***/
/*** Autor: Cleber O. Domingues                                              ***/
/*** Data : 12/09/01                                                         ***/
/*** Alterações: 11/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT030 para FAT029_1 dentro  ***/
/***                        do programa BRFAT029                             ***/
/*******************************************************************************/
User Function FAT029_1()
     Close(oDlg1)
     Processa( {|| ExecBlock("FAT029_2", .f., .f.) } )
Return

/*******************************************************************************/
/*** FAT029_2 - Calculo de compensacao de comissao                           ***/
/*** Autor: Cleber O. Domingues                                              ***/
/*** Data : 12/09/01                                                         ***/
/*** Alterações: 19/08/02 - Cleber O. Domingues                              ***/
/***                        Estava gravando comissão não processadas na com- ***/
/***                        pensação                                         ***/
/***             11/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT031 para FAT029_2 dentro  ***/
/***                        do programa BRFAT029                             ***/
/*******************************************************************************/
User Function FAT029_2()
     Local _cVend, _nPorc, _nComis, nVlrComis, cQuery,aArea
     Local _nLucro, _nPadComis, _nPadLucro, _nTotVenda, _nTotCif, _nDif, _nCont, _nPos

	aArea := U_PegaArea({"SE3"})

     Pergunte("BRFT29", .F.)

     DbSelectArea('SE3')

     If ValType(mv_par03) == 'C'
        mv_par03 := ctod(mv_par03)
     Endif

     If ValType(mv_par04) == 'C'
        mv_par04 := ctod(mv_par04)
     Endif
	
	//Cleber (17/08/2010) => Considerar todos os pedidos na compensação, independente de estarem ou não na pol. vendas. Solicitação de Rui e Caio.


/*     cQuery := "SELECT SE3.R_E_C_N_O_ AS ID,E3_VEND,C5_LUCRO,C5_MEDCOM,C5_MEDLUCR "+;
               "FROM "+RetSqlName("SE3")+" SE3 "+;
               "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON "+;
               "(E3_FILIAL = C5_FILIAL) AND (E3_PEDIDO = C5_NUM) AND (SC5.D_E_L_E_T_ <> '*') "+;
               "WHERE (E3_FILIAL = '"+xFilial("SE3")+"') AND (LEN(E3_DATA) = 0) AND "+;
               "(E3_VEND >= '"+mv_par01+"') AND (E3_VEND <= '"+mv_par02+"') AND "+;
               "(E3_EMISSAO >= '"+DTOS(mv_par03)+"') AND (E3_EMISSAO <= '"+DTOS(mv_par04)+"') AND "+;
               "(LEN(E3_PEDIDO) > 0) AND (C5_NUM IS NOT NULL) AND (SC5.C5_TPFRETE <> 'C') AND "+;
               "(SC5.C5_COMPENS <> 'N') AND (SE3.D_E_L_E_T_ <> '*') ORDER BY E3_VEND"

*/
   //Cleber(28/02/2021) ->Excluir pedidos de campanhas de vendas (C5_XCONF <> 'T')
     cQuery := "SELECT SE3.R_E_C_N_O_ AS ID,E3_VEND,C5_LUCRO,C5_MEDCOM,C5_MEDLUCR "+;
               "FROM "+RetSqlName("SE3")+" SE3 "+;
               "LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON "+;
               "(E3_FILIAL = C5_FILIAL) AND (E3_PEDIDO = C5_NUM) AND (SC5.D_E_L_E_T_ <> '*') "+;
               "WHERE (E3_FILIAL = '"+xFilial("SE3")+"') AND (LEN(E3_DATA) = 0) AND "+;
               "(E3_VEND >= '"+mv_par01+"') AND (E3_VEND <= '"+mv_par02+"') AND "+;
               "(E3_EMISSAO >= '"+DTOS(mv_par03)+"') AND (E3_EMISSAO <= '"+DTOS(mv_par04)+"') AND "+;
               "(LEN(E3_PEDIDO) > 0) AND (C5_NUM IS NOT NULL) AND "+;
               "(SC5.C5_XCONF <> 'T') AND (SE3.D_E_L_E_T_ <> '*') ORDER BY E3_VEND"

     TCQuery cQuery NEW ALIAS "TCQ" 

     DbSelectArea("TCQ")
     DbGoTop()

     ProcRegua(LastRec()) 
     _nCont := 1
     While !eof()
           _cVend     := TCQ->E3_VEND
           _nComis    := 0
           _nLucro    := 0
           _nComisCif := 0
           _nMedComis := 0
           _nMedLucro := 0
           _nTotVenda := 0
           _nTotCif   := 0
           _nPadComis := 0
           _nPadLucro := 0
           _nPorc     := 0
           _nPos      := _nCont
           While !Eof() .and. (TCQ->E3_VEND == _cVend)
                 DbSelectArea("SE3")
                 DbGoto(tcq->id)
                 If Recno() == tcq->id	  	                      
                    // Totaliza Comissoes prevendo possível reprocessamento por engano  
                    nVlrComis := SE3->E3_BASE*IIF(SE3->E3_PORCANT # 0,(SE3->E3_PORCANT/100),(SE3->E3_PORC/100))
                    _nComis := _nComis + nVlrComis

                    // Totaliza Lucro da empresa                               
                    _nLucro :=_nLucro + (SE3->E3_BASE * TCQ->C5_LUCRO / 100)            

                    // Totaliza duplicatas
                    _nTotVenda:=_nTotVenda + SE3->E3_BASE

                    // Comissao e Lucro padroes
                    _nPadComis := _nPadComis + ((TCQ->C5_MEDCOM/100)*SE3->E3_BASE)
                    _nPadLucro := _nPadLucro + ((TCQ->C5_MEDLUCR/100)*SE3->E3_BASE)

                    DbSelectArea('SE3')
                    If SE3->E3_COMP # "S"
                       RecLock("SE3", .F.)
                          SE3->E3_COMP := "S" // Gravar como título que participa da compensação
                          SE3->E3_PORCANT := SE3->E3_PORC
                       MsUnLock()
                    Endif
                 Endif
                 DbSelectArea('TCQ')
                 _nCont++
                 DbSkip()
           EndDo
           // Medias das Porcentagens de Comissao e Lucro
           _nMedComis := Round(_nComis / _nTotVenda, 4)
           _nMedLucro := Round(_nLucro / _nTotVenda, 4)
           _nPadComis := Round((_nPadComis / _nTotVenda), 4)
           _nPadLucro := Round((_nPadLucro / _nTotVenda), 4)
           _nPorc     := _nMedComis * 100
           _nDif      := 0

           // Lucro da empresa é maior que lucro minimo e comissao menor que comissao padrao
           If _nMedLucro > _nPadLucro
              _nDif := _nMedLucro - _nPadLucro
              If ((_nPadComis - _nMedComis) < _nDif)
                 _nDif:= _nPadComis - _nMedComis
              Endif
              _nDif :=_nDif * _nTotVenda
              _nPorc:=((_nComis + _nDif) / _nTotVenda) * 100
           Endif
           DbSelectArea('TCQ')
           Dbgotop()
           DbSkip(_nPos-1)
           While !Eof() .and. (TCQ->E3_VEND == _cVend)
                 Dbselectarea("SE3")
                 Dbgoto(tcq->id)
                 If Recno() == tcq->id
                    RecLock('SE3', .F.)
                       SE3->E3_VENCTO  := mv_par05
                       SE3->E3_PORC    := _nPorc
                       SE3->E3_COMIS   := SE3->E3_BASE * _nPorc / 100
                    MsUnlock()
                 Endif	
                 Dbselectarea("TCQ")
                 Dbskip()
                 IncProc()
           EndDo
     EndDo

	U_VoltaArea(aArea)

   DbSelectArea("TCQ")
   DbCloseArea()
Return(.t.)
