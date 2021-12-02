#include "protheus.ch"
#include "topconn.ch"
#include 'DIRECTRY.CH' 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BRQIEC01³ Autor ³ Luís G. de Souza      ³ Data ³ 12/03/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ IQF-Fornecedores                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function BRQIEC01()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cSay1IQF   := Space(1)
     Private cSay2IQF   := Space(1)
     Private cSay3IQF   := Space(1)
     Private nGet1IQF   := 0
     Private nGet2IQF   := 0
     Private lValMesD   := .t.
     Private nLigaMes   := 1
     Private nLigaPer   := 1
     Private cSay4IQF   := ""
     Private oTempTbl01
     u_zcfga01( 'BRQIEC01' ) //LGS#2021201 - Gravação de log de utilização da rotina
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt("oFon1IQF", "oFon2IQF", "oDlg1IQF", "oGrp1IQF", "oSay1IQF", "oSay2IQF", "oSay3IQF", "oGet1IQF", "oGet2IQF")
     SetPrvt("oBtn1IQF", "oBtn2IQF", "oSay4IQF")

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFon1IQF   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oFon2IQF   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1IQF   := MSDialog():New( 095, 232, 545, 915, "IQF - Fornecedores x Período", , , .F., , , , , , .T., , , .T. )

     oGrp1IQF   := TGroup():New( 004, 004, 032, 340, "Filtro", oDlg1IQF, CLR_RED, CLR_WHITE, .T., .F. )
     oSay1IQF   := TSay():New( 015, 008, { || "Mês Inicio:"}                             , oGrp1IQF, , oFon1IQF, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
     oGet1IQF   := TGet():New( 013, 056, { |u| If(PCount() > 0, nGet1IQF := u, nGet1IQF)}, oGrp1IQF, 016, 012, '@E 99', , CLR_BLUE , CLR_WHITE, oFon2IQF, , , .T., "", , , .F., .F., , .F., .F., "", "nGet1IQF", , )

     oSay2IQF   := TSay():New( 015, 088, { || "Periodo:"   }                             , oGrp1IQF, , oFon1IQF, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 036, 008)
     oGet2IQF   := TGet():New( 013, 124, { |u| If(PCount() > 0, nGet2IQF := u, nGet2IQF)}, oGrp1IQF, 016, 012, '@E 99', , CLR_BLACK, CLR_WHITE, oFon1IQF, , , .T., "", , , .F., .F., , .F., .F., "", "nGet2IQF", , )
     oSay3IQF   := TSay():New( 015, 150, { || "(meses)"    }                             , oGrp1IQF, , oFon1IQF, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008)
     oBtn2IQF   := TButton():New( 015, 300, "Novo Filtro", oGrp1IQF, { || fNovoFiltr() }, 037, 012, , , , .T., , "", , , , .F. )
     
     oTbl1IQF()
     DbSelectArea("TMP")
     DbSetOrder(1)
     oBrw1IQF   := MsSelect():New( "TMP", "", "", { {"TMP_CODF", "", "Cod. Fornec.", ""}, {"TMP_NOMF", "", "Nome Fornec.", ""}, {"TMP_CODP", "", "Cod. Produto", ""}, {"TMP_NOMP", "", "Descricao", ""}, {"TMP_IIQF", "", "IQF", "999"}, {"TMP_CLAS", "", "Classificassao", "@!"} }, .F., , {036, 004, 204, 340}, , , oDlg1IQF )
     oBtn1IQF   := TButton():New( 208, 302, "Sair", oDlg1IQF, { || oDlg1IQF:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oSay4IQF   := TSay():New( 210, 004, { || cSay4IQF    }                             , oGrp1IQF, , oFon1IQF, .F., .F., .F., .T., CLR_RED, CLR_WHITE, 300, 008)
     oGet1IQF:bLostFocus := { || fValMesIQF(nLigaMes) }
     oGet2IQF:bLostFocus := { || fValPerIQF(nLigaPer) }
     oBtn2IQF:lVisible := .f.
     oGet1IQF:SetFocus()
     oDlg1IQF:Activate(, , , .T.)
     DbSelectArea("TMP")
     DbCloseArea()
     oTempTbl01:Delete()

     //aEval(Directory("tmp*.dbf"), { |aFile| FERASE(aFile[F_NAME]) })     
     //aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })     

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValMesIQF() - Valida Mes Inicio para IQF
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fValMesIQF(nLigaMes)
       If nLigaMes == 1
          lValMesD := .t.
          If nGet1IQF <= 0
             MsgSTOP("Valor não pode ser menor ou igual a zero.", "Atenção...")
             nGet1IQF := 0
             oGet1IQF:SetFocus()
             lValMesD := .f.
             Return .f.
          ElseIf nGet1IQF > 12
                 MsgStop("Não existe mês maior do que 12.", "Atenção...")
                 nGet1IQF := 0
                 oGet1IQF:SetFocus()
                 lValMesD := .f.
                 Return
          Else
             If nGet2IQF > 0
                //Faz a busca dos dados
                nLigaMes := 0
                nLigaPer := 0
                oBtn2IQF:lVisible := .t.
                MsgRun(OemToAnsi('Buscando informações para consulta...... Aguarde....'), '', {|| CursorWait(), fBuscaIQF(), CursorArrow() } )
             Endif
             oGet2IQF:SetFocus()
          Endif
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValPerIQF() - Valida Periodo para o IQF
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fValPerIQF(nLigaPer)
       If nLigaPer == 1
          If lValMesD
             If nGet2IQF <= 0
                MsgStop("Valor não pode ser menor ou igual a zero.", "Atenção...")
                nGet2IQF := 0
                oGet2IQF:SetFocus()
                Return
             Else
                If nGet1IQF > 0 .and. nGet1IQF <= 12
                   //Faz a busca dos dados
                   nLigaMes := 0
                   nLigaPer := 0
                   oBtn2IQF:lVisible := .t.
                   MsgRun(OemToAnsi('Buscando informações para consulta...... Aguarde....'), '', {|| CursorWait(), fBuscaIQF(), CursorArrow() } )
                Endif
             Endif
          Endif
       Endif
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1IQF() - Cria temporario para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1IQF()
       Local aFds := {}
       //Local cTmp,NomArq,cKey01,cInd01

       Aadd( aFds , {"TMP_CODF", "C", 006, 000} )
       Aadd( aFds , {"TMP_NOMF", "C", 030, 000} )
       Aadd( aFds , {"TMP_CODP", "C", 015, 000} )
       Aadd( aFds , {"TMP_NOMP", "C", 030, 000} )
       Aadd( aFds , {"TMP_IIQF", "N", 003, 000} )
       Aadd( aFds , {"TMP_CLAS", "C", 012, 000} )


       /*  cTmp := CriaTrab( aFds, .T. )
       Use (cTmp) Alias TMP New Exclusive
       Index On TMP_IIQF To (cTmp) DESCENDING */

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 04/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cNomArq := U_NovoArqTrab("dbf")
       //dbcreate(cNomArq+".dbf",aFds,"DBFCDXADS")     
       //USE (cNomArq+".dbf") ALIAS TMP VIA "DBFCDXADS" NEW Exclusive	
       //Index On TMP_IIQF To (cNomArq) DESCENDING
       oTempTbl01 := FWTemporaryTable():New( "TMP")
       oTempTbl01:SetFields( aFds )
       oTempTbl01:AddIndex( "cInd01", { "TMP_IIQF" } )
       oTempTbl01:Create()
       /********************************************************************************************************************************/
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fBuscaIQF() - Busca dados do IQF dos fornecedores
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fBuscaIQF()
       Local cQry1 := ""
       Local aVetM := {}
       Local nAuxM := nGet1IQF
       Local nAuxA := Year(dDataBase)
       Local nY
      
      if nAuxM > month(dDataBase)
         nAuxA--
      endif 
       //Monta Array com os períodos a serem buscados
       For nY := 1 To nGet2IQF
           If nY == 1
              aAdd(aVetM, {nAuxM, nAuxA} )
              ++nAuxM
           Else
              If nAuxM > 12
                 nAuxM := 1
                // nAuxA := Year(dDataBase) + 1
                 nAuxA++
                 aAdd(aVetM, {nAuxM, nAuxA} )
                 ++nAuxM
              Else
                 aAdd(aVetM, {nAuxM, nAuxA} )
                 ++nAuxM
              Endif
           Endif
       Next
       cTxtAux := "IN ('"
       For nY := 1 To Len(aVetM)
           cTxtAux += StrZero(aVetM[nY][1], 2)+StrZero(aVetM[nY][2], 4)+"', '"
       Next

       DbSelectArea("TMP")
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       //Zap
       TCSqlExec("DELETE FROM " + oTempTbl01:GetRealName() )
       nSomIQF := 0
       nQtdFor := 0
       cTxtAux := SubStr( cTxtAux, 1, Len(cTxtAux) - 3 ) + ")  "
       cQry1 += "SELECT QEV.QEV_FORNEC AS 'CODFOR', SA5.A5_NOMEFOR AS 'NOMFOR', QEV.QEV_PRODUT AS CODPRO, SA5.A5_NOMPROD AS NOMPRO, "+;
       "AVG(QEV.QEV_IQF) AS IQF, AVG(QEV.QEV_IQFA) AS IQFA, "+;
       "'CLASSI' = CASE WHEN AVG(QEV.QEV_IQF) BETWEEN 85.00 AND 100.00 THEN 'ASSEGURADO' ELSE CASE WHEN AVG(QEV.QEV_IQF) BETWEEN 70.00 AND 84.99 THEN 'QUALIFICADO' ELSE CASE WHEN AVG(QEV.QEV_IQF) BETWEEN 50.00 AND 69.99 THEN 'PRÉ-QUALIFICADO' ELSE 'NÃO HABILITADO' END END END "
       cQry1 += "FROM "+RetSqlName("QEV")+" QEV WITH (NOLOCK) "
       cQry1 += "LEFT OUTER JOIN "+RetSqlName("SA5")+" SA5 WITH (NOLOCK) ON SA5.A5_FILIAL = QEV.QEV_FILIAL AND SA5.A5_PRODUTO = QEV.QEV_PRODUT AND SA5.A5_FORNECE = QEV.QEV_FORNEC AND SA5.D_E_L_E_T_ = '' "
       cQry1 += "WHERE SUBSTRING(QEV.QEV_FILIAL,1,2) = '"+Substr(cNumEmp,3,2)+"'  "
       //cQry1 += "WHERE QEV.QEV_FILIAL = '"+xFilial("QEV")+"'  "  // alterado pela necessidade de ter apenas um resultado para por empresa - andré 10-07-14    
       cQry1 += "  AND QEV.D_E_L_E_T_ = '' "
       cQry1 += "  AND QEV.QEV_MES+QEV.QEV_ANO "+cTxtAux
       cQry1 += "GROUP BY QEV.QEV_FORNEC, SA5.A5_NOMEFOR, QEV.QEV_PRODUT, SA5.A5_NOMPROD "
       cQry1 += "ORDER BY 5 "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       DbGoTop()
       While !Eof()
             RecLock("TMP", .t.)
                TMP->TMP_CODF := TCQ->CODFOR
                TMP->TMP_NOMF := TCQ->NOMFOR
                TMP->TMP_CODP := TCQ->CODPRO
                TMP->TMP_NOMP := TCQ->NOMPRO
                TMP->TMP_IIQF := TCQ->IQF
                TMP->TMP_CLAS := TCQ->CLASSI
                nSomIQF += Iif(TCQ->IQF >= 90, 1, 0)
                nQtdFor += 1
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMP")
       DbGoTop()
       cSay4IQF := TransForm( ( ( nSomIQF / nQtdFor ) * 100 ), "@E 999.99")+"% DOS FORNECEDORES ESTÃO COM IQF ACIMA DE 90.00%."
       oSay4IQF:Refresh()
       oBrw1IQF:oBrowse:Refresh()
Return

Static Function fNovoFiltr()
       nGet1IQF := 0
       oGet1IQF:Refresh()
       nGet2IQF := 0
       oGet2IQF:Refresh()
       oGet1IQF:SetFocus()
       oBtn2IQF:lVisible := .f.
       DbSelectArea("TMP")
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       //Zap
       TCSqlExec("DELETE FROM " + oTempTbl01:GetRealName() )
       oBrw1IQF:oBrowse:Refresh()
       cSay4IQF := ""
       oSay4IQF:Refresh()
Return
