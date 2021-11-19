#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRAEST01 บ Autor ณ Luํs Gustavo       บ Data ณ  30/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera Inventแrio de Produtos por almoxarifado.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BREST004()
     Public cPerg := ""
     Public cQuer := ""

     cPerg := "GERSB7" 
     GeraSX1()
     
     lCont := Pergunte(cPerg,.t.)
     If !lCont
        Return
     Else
        Processa({|| ProcInvent()},"Gerando Inventario")
     Endif
Return     

Static Function ProcInvent()
       Local _Count     := 8000
       Local _nNaoGrava := 0
       Local _nGrava    := 0
       Local _Doc       := ""

       _Doc := MV_PAR04
       
       DbSelectArea("SB1")
       If mv_par01 $ '13'
          cQuer := cQuer + "SELECT SB1.B1_COD AS B1_COD, SB2.B2_LOCAL AS B1_LOCPAD, SB1.B1_TIPO AS B1_TIPO "
          cQuer := cQuer + "FROM "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) "
          cQuer := cQuer + "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = SB2.B2_FILIAL AND SB1.B1_COD = SB2.B2_COD AND SB1.D_E_L_E_T_ = '' "
          cQuer := cQuer + "WHERE SB2.B2_FILIAL  = '"+xFilial("SB2")+"' "
          cQuer := cQuer + "  AND SB2.D_E_L_E_T_ = '' "
          cQuer := cQuer + "  AND SB2.B2_LOCAL   = '"+mv_par01+"' "
          cQuer := cQuer + "  AND SB1.B1_TIPO    = '"+mv_par02+"' "
          cQuer := cQuer + "ORDER BY SB1.B1_COD, SB1.B1_LOCPAD "
       Else
          cQuer := cQuer + "SELECT B1.B1_COD, '30' AS B1_LOCPAD, B1.B1_TIPO "
          cQuer := cQuer + "FROM "+RetSqlName("SB1")+" B1 "
          //cQuer := cQuer + "WHERE B1.B1_FILIAL = '"+xFilial("SB1")+"' AND B1.B1_LOCPAD = '"+mv_par01+"' AND B1.B1_TIPO = '"+mv_par02+"' AND B1.D_E_L_E_T_ = ''"
          cQuer := cQuer + "WHERE B1.B1_FILIAL = '"+xFilial("SB1")+"' AND B1.B1_TIPO = '"+mv_par02+"' AND B1.D_E_L_E_T_ = '' AND LEN(B1.B1_COD) = 12 "
          cQuer := cQuer + "ORDER BY B1.B1_COD, B1.B1_LOCPAD "
       Endif
       TcQuery cQuer New Alias "SB1TMP"
     
       DbSelectArea("SB1TMP")
       DbGoTop()
       /*While !Eof()
             _Count := _Count + 1
             DbSkip()
       Enddo*/
       ProcRegua(_Count)
       DbGoTop()
      
       While !EOF()
             DbSelectArea("SB7")
             DbSetOrder(1)
             DbSeek(xFilial("SB7")+dTos(mv_par03)+SB1TMP->B1_COD+SB1TMP->B1_LOCPAD,.T.)
             If Found()
                If SB7->B7_DOC <> mv_par04
                   RecLock("SB7",.t.)
                      SB7->B7_FILIAL  := xFilial("SB7")
                      SB7->B7_COD     := SB1TMP->B1_COD
                      SB7->B7_LOCAL   := SB1TMP->B1_LOCPAD
                      SB7->B7_TIPO    := SB1TMP->B1_TIPO
                      SB7->B7_DOC     := _Doc
                      SB7->B7_QUANT   := 0.0
                      SB7->B7_DATA    := mv_par03
                      SB7->B7_LOTECTL := ''
                      SB7->B7_NUMLOTE := ''
                      SB7->B7_DTVALID := mv_par03
                      SB7->B7_LOCALIZ := ''
                      SB7->B7_NUMSERI := ''
                   MsUnLock()
                   _nGrava := _nGrava + 1
                Else
                   _nNaoGrava := _nNaoGrava + 1
                Endif
                DbSelectArea("SB1TMP")
                DbSkip()
                IncProc()
                Loop
             Else
                //If Len(Alltrim(SB1TMP->B1_COD)) == 12
                   RecLock("SB7",.t.)
                      SB7->B7_FILIAL  := xFilial("SB7")
                      SB7->B7_COD     := SB1TMP->B1_COD
                      SB7->B7_LOCAL   := SB1TMP->B1_LOCPAD
                      SB7->B7_TIPO    := SB1TMP->B1_TIPO
                      SB7->B7_DOC     := _Doc
                      SB7->B7_QUANT   := 0.0
                      SB7->B7_DATA    := mv_par03
                      SB7->B7_LOTECTL := ''
                      SB7->B7_NUMLOTE := ''
                      SB7->B7_DTVALID := mv_par03
                      SB7->B7_LOCALIZ := ''
                      SB7->B7_NUMSERI := ''
                   MsUnLock()
                   _nGrava := _nGrava + 1
                //Endif
             Endif
             DbSelectArea("SB1TMP")
             DbSkip()
             IncProc()
       Enddo
       MsgBox("Total de Registros processados: "+strzero(_nGrava+_nNaoGrava,6)+" Gravados: "+strzero(_nGrava,6)+" Nใo Gravados: "+strzero(_nNaoGrava,6),"Gera็ใo de Inventแrio...","INFO")
       DbSelectArea("SB1TMP")
       DbCloseArea()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ GeraSX1  บ Autor ณ Luํs Gustavo       บ Data ณ  30/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function GeraSX1()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg,10)

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Local de Armazenagem","","","mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"02","Tipo Produto        ","","","mv_ch2","C",2,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"03","Data para Gera็ใo   ","","","mv_ch3","D",8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg,"04","Documento           ","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i,2])
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
