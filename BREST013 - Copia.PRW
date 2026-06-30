#include "rwmake.ch"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }                          
#include "sigawin.ch"
#include "font.ch"
#INCLUDE "TOPCONN.CH"
#include 'DIRECTRY.CH'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BREST013 บ Autor ณ Luํs Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta de Consumo Mensal.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BREST013()
     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     //ณ Declaracao de Variaveis                                             ณ
     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Private cPerg1   := "EST131"
     Private cPerg2   := "EST132"
     Private cPerg5   := "EST135"
     Private lPerg
     Private Titulo  := OemToAnsi("Consulta Consumo Medio")
     Private oDlg1
     Private oDlg2
     Private lLocal := .t.
     Private lJaFech  := .f.
     Private lJaFech2 := .f.     
     Private lTelaJaFechada := .f.
     Private lTelaJaFechada2 := .f.
     Private Acentos := '€๚๚๚'+chr(65533)+'๚…๚๚๚ ๚'+chr(65533)+'๚๚๚ก๚“๚”๚ข๚๚ฃ๚'
     Private cAcSubst := "C,c,A~A'a`a~a^a'E'e^e'i'o^o~o'O~U'"
     Private lCriaArq := .t.
     Private Cabec1      := "    CODIGO                     DESCRICAO                 TP LC UM  "     
     Private oTempTable := ""
     
     dbSelectArea("SB1")
     dbSetOrder(1)
     
     ValPerg5()
     lPerg := pergunte(cPerg5,.T.)   // Escolher 1 - Consumo ou 2 - Classifica็ใo
     If lPerg
        If mv_par01 == 1 // Consumo
           ValPerg2()
           lPerg := pergunte(cPerg2,.T.) // Escolher 1 - Atualiza็ao (Mensal) ou 2 - Consulta
           If !lPerg
              Return
           Else
              If mv_par01 == 1           // Atualiza็ใo do Consumo
                 Processa({|| EST0138(mv_par01) },Titulo)
              ElseIf mv_par01 == 2       // Consulta Consumo
                     ValPerg1()
                     lPerg := pergunte(cPerg1,.T.) // Parametros para consulta
                     If !lPerg
                        Return
                     Else
                        Processa({|| EST0131() },Titulo) 
                     Endif
              Else
                 Processa({|| EST0138(mv_par01) },Titulo)
              Endif
           Endif
        Else
           lLocal := .t.
           Processa({|| EST013A() },"Classifica็ใo do Produto")
        Endif
     Endif

	if Select("CCONS")<>0
		dbselectarea("CCONS")
		dbclosearea()
		oTempTable:Delete()
	endif 
	if Select("CCONS2")<>0
		dbselectarea("CCONS2")
		dbclosearea()
		ocCons2:Delete()
	endif 

/*
	aEval(Directory("tmp*.dtc"), { |aFile| FERASE(aFile[F_NAME]) })     
	aEval(Directory("tmp*.cdx"), { |aFile| FERASE(aFile[F_NAME]) })     
*/
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG5 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg5()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg5 := PADR(cPerg5,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg5,"01","Consulta           ","","","mv_ch1","N",01,0,0,"C","","mv_par01","Consumo Medio","","","","","Classifica็ใo","","","","","","","","","","","","","","","","","","","",""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg5+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG2 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg2()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg2 := PADR(cPerg2,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg2,"01","Atualiza / Consulta","","","mv_ch1","N",01,0,0,"C","","mv_par01","Atualiza Consumo","","","","","Consulta Consumo","","","","","Atualiza Medias","","","","","","","","","","","","","","",""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg2+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0138  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para atualizacao do consumo mensal.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0138(nPar)
       Local cQry1   := ""  // Variavel para guardar a query da tabela SB1
       Local cQry2   := ""  // Variavel para guardar a query da tabela SD3
       Local cQry3   := ""  // Variavel para guardar a query da tabela SD2 
       Local cQry4   := ""  // Variavel para guardar a query da tabela SD1
       Local aProd   := {}
       Local cPriDia := ""  // Primeiro dia do mes
       Local cUltDia := ""  // Ultimo dia do mes
       Local i, x
       Private cPerg3 := "EST133"
       #IFDEF TOP
              If nPar == 1       
                 ValPerg3()
                 lPerg := Pergunte(cPerg3,.t.) // Escolher parametros da Atualiza็ใo
                 If !lPerg 
                    Return
                 Endif
 
                 dbSelectArea("SB1")
                 dbSetOrder(1)

                 cQry1 := cQry1 + "SELECT SB1.B1_COD AS CODIGO, SB1.B1_LOCPAD AS LOCAL, SB1.B1_TIPO AS TIPO, "
                 cQry1 := cQry1 + "SB1.B1_DESC AS DESCRICAO, SB1.B1_UM AS UNIDADE, "
                 cQry1 := cQry1 + "0 AS MES01, 0 AS MES02, 0 AS MES03, 0 AS MES04, 0 AS MES05, 0 AS MES06, "
                 cQry1 := cQry1 + "0 AS MES07, 0 AS MES08, 0 AS MES09, 0 AS MES10, 0 AS MES11, 0 AS MES12, "
                 cQry1 := cQry1 + "0 AS MEDIA "
                 cQry1 := cQry1 + "FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "
                 cQry1 := cQry1 + "WHERE SB1.D_E_L_E_T_ = '' "
                 cQry1 := cQry1 + "AND SB1.B1_FILIAL    = '"+xFilial("SB1")+"' "
                 cQry1 := cQry1 + "AND SB1.B1_COD      >= '"+mv_par01+"' "
                 cQry1 := cQry1 + "AND SB1.B1_COD      <= '"+mv_par02+"' "
                 cQry1 := cQry1 + "AND SB1.B1_LOCPAD   >= '"+mv_par03+"' "
                 cQry1 := cQry1 + "AND SB1.B1_LOCPAD   <= '"+mv_par04+"' "
                 cQry1 := cQry1 + "AND SB1.B1_TIPO     >= '"+mv_par05+"' "
                 cQry1 := cQry1 + "AND SB1.B1_TIPO     <= '"+mv_par06+"' "
                 cQry1 := cQry1 + "AND SB1.B1_GRUPO    >= '"+mv_par07+"' "
                 cQry1 := cQry1 + "AND SB1.B1_GRUPO    <= '"+mv_par08+"' "
                 cQry1 := cQry1 + "ORDER BY SB1.B1_COD,SB1.B1_LOCPAD "

                 TCQUERY cQry1 NEW ALIAS "TMPSB1"

                 DbSelectArea("TMPSB1")
                 DbGoTop()
                 If mv_par05 $ 'MP' .or. mv_par06 $ 'MP'
                    ProcRegua(900)
                 ElseIf mv_par05 $ 'PI' .or. mv_par06 $ 'PI'
                        ProcRegua(6600)
                 ElseIf mv_par05 $ 'PA' .or. mv_par06 $ 'PA'
                        ProcRegua(14400)
                 Else
                     ProcRegua(22100)
                 Endif
                 While !eof()
                       IncProc("Zerando consumo atual: "+Alltrim(ZZ3->ZZ3_COD))
                       DbSelectArea("ZZ3")
                       DbSetOrder(1)
                       DbSeek(xFilial("ZZ3")+mv_par10+TMPSB1->CODIGO,.t.)
                       If !Found()
                          RecLock("ZZ3",.t.)
                             ZZ3->ZZ3_FILIAL                     := xFilial("ZZ3")
                             ZZ3->ZZ3_ANO                        := mv_par10
                             ZZ3->ZZ3_COD                        := TMPSB1->CODIGO
                             ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) := 0
                       Else
                          RecLock("ZZ3",.f.)
                             ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) := 0
                       Endif
                       MsUnLock()
                       aadd(aProd, TMPSB1->CODIGO)
                       DbSelectArea("TMPSB1")
                       dbSkip()
                 Enddo
              Else 
                 cQry1 := ""
                 cQry1 := cQry1 + "SELECT ZZ3.ZZ3_COD AS CODIGO, B1_TIPO AS 'TIPO', B1_ESTOQUE "
                 cQry1 := cQry1 + "FROM "+RetSqlName("ZZ3")+" ZZ3 WITH (NOLOCK) "
                 cQry1 := cQry1 + "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = ZZ3_FILIAL AND B1_COD = ZZ3_COD AND SB1.D_E_L_E_T_ ='' "
                 cQry1 := cQry1 + "WHERE ZZ3.D_E_L_E_T_ = '' AND B1_TIPO IS NOT NULL "
                 cQry1 := cQry1 + "AND ZZ3.ZZ3_FILIAL = '"+xFilial("ZZ3")+"' "
                 //cQry1 := cQry1 + "AND SB1.B1_COD ='BT 010500702' "
                 cQry1 := cQry1 + "GROUP BY ZZ3.ZZ3_COD, SB1.B1_TIPO, B1_ESTOQUE  "
                 cQry1 := cQry1 + "ORDER BY ZZ3.ZZ3_COD "
                 TCQUERY cQry1 NEW ALIAS "TMPSB1"

                 DbSelectArea("TMPSB1")
                 DbGoTop()
                 While !Eof()
                       IncProc("Aguarde a montagem do arquivo de trabalho...")
                       //aadd(aProd, TMPSB1->CODIGO, TMPSB1->TIPO, TMPSB1->B1_ESTOQUE )
                       aAdd(aProd,{TMPSB1->CODIGO, TMPSB1->TIPO, TMPSB1->B1_ESTOQUE})
                       DbSelectArea("TMPSB1")
                       dbSkip()
                 Enddo
              Endif
              ProcRegua(Len(aProd))
              lRet := ChkFile("TMPSB1")
              If lRet
                 DbSelectArea("TMPSB1")
                 DbCloseArea()
              Endif

              If nPar == 1
                 cPriDia := ctod('01/'+StrZero(mv_par09,2)+'/'+mv_par10)
                 cUltDia := ctod(strzero(f_ultdia(cPridia),2)+'/'+StrZero(mv_par09,2)+'/'+mv_par10)
                 ProcRegua(Len(aProd))
                 For i := 1 to Len(aProd)
                     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                     //ณ Busca informacoes do arquivo de movimentacoes - SD3                 ณ
                     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                     IncProc("Recalculando consumo: "+aProd[i])
                     cQry2  := ""
                     cQry2  := cQry2 + "SELECT SUM(SD3.D3_QUANT) AS MES "
                     cQry2  := cQry2 + "FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK) "
                     cQry2  := cQry2 + "WHERE SD3.D_E_L_E_T_         = '' "
                     cQry2  := cQry2 + "AND SD3.D3_FILIAL            = '"+xFilial("SD3")+"' "
                     cQry2  := cQry2 + "AND SD3.D3_COD               = '"+aProd[i]+"' "
                     cQry2  := cQry2 + "AND SD3.D3_EMISSAO          >= '"+dtos(cPridia)+"' "
                     cQry2  := cQry2 + "AND SD3.D3_EMISSAO          <= '"+dtos(cUltdia)+"' "
                     cQry2  := cQry2 + "AND SD3.D3_DOC              <> 'INVENT' "
                     cQry2  := cQry2 + "AND SD3.D3_ESTORNO          <> 'S' "
                     cQry2  := cQry2 + "AND SUBSTRING(SD3.D3_CF,1,2) = 'RE' "
                     cQry2  := cQry2 + "AND SUBSTRING(SD3.D3_CF,3,1) IN('0', '1', '2', '3') "
                     cQry2  := cQry2 + "AND SD3.D3_TM NOT IN('120','520') "
                     //If !Posicione("SB1",1,xFilial("SB1")+aProd[i],"B1_TIPO") $ 'PA.MC'
                     //   cQry2  := cQry2 + "AND SD3.D3_OP               <> '' "
                     //Endif
                     TCQUERY cQry2 NEW ALIAS "TMPSD3"
                  
                     DbSelectArea("ZZ3")
                     DbSeek(xFilial("ZZ3")+mv_par10+aProd[i],.t.)
                     RecLock("ZZ3",.f.)
                        ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) := TMPSD3->MES
                     MsUnLock()             
                     DbSelectArea("TMPSD3")
                     DbCloseArea()
               
                     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                     //ณ Busca informacoes do arquivo de NFs. de Saida - SD2                 ณ
                     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

                     cQry3 := ""
                     cQry3 := cQry3 + "SELECT SD2.D2_TES AS CODIGO, SUM(SD2.D2_QUANT) AS MES "
                     cQry3 := cQry3 + "FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) "
                     cQry3 := cQry3 + "WHERE SD2.D_E_L_E_T_  = '' "
                     cQry3 := cQry3 + "AND SD2.D2_FILIAL   = '"+xFilial("SD2")+"' "
                     cQry3 := cQry3 + "AND SD2.D2_COD      = '"+aProd[i]+"' "
                     cQry3 := cQry3 + "AND SD2.D2_EMISSAO >= '"+dtos(cPridia)+"' "
                     cQry3 := cQry3 + "AND SD2.D2_EMISSAO <= '"+dtos(cUltdia)+"' "
                     cQry3 := cQry3 + "AND SD2.D2_TIPO    NOT IN('D') "
                     cQry3 := cQry3 + "AND SD2.D2_ORIGLAN NOT IN('LF','DB') "
                     cQry3 := cQry3 + "AND SD2.D2_TES NOT IN('822', '826','823') "
                     cQry3 := cQry3 + "GROUP BY SD2.D2_TES "
                     TCQUERY cQry3 NEW ALIAS "TMPSD2"
               
                     DbSelectArea("TMPSD2")
                     DbGoTop()
                     While !Eof()
                           DbSelectArea("SF4")
                           DbSetOrder(1)
                           DbSeek(xFilial("SF4")+TMPSD2->CODIGO,.T.)
                           If Found()
                              If SF4->F4_ESTOQUE = 'S'
                                 If SF4->F4_CODIGO <= '500'
                                    DbSelectArea("ZZ3")
                                    DbSeek(xFilial("ZZ3")+mv_par10+aProd[i],.t.)
                                    RecLock("ZZ3",.f.)
                                       ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) := (ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) - TMPSD2->MES)
                                    MsUnLock()
                                 Else
                                    DbSelectArea("ZZ3")
                                    DbSeek(xFilial("ZZ3")+mv_par10+aProd[i],.t.)
                                    RecLock("ZZ3",.f.)
                                       ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) := (ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) + TMPSD2->MES)
                                    MsUnLock()
                                 Endif
                              Endif
                           Endif
                           DbSelectArea("TMPSD2")
                           DbSkip()
                     Enddo      
                     DbSelectArea("TMPSD2")
                     DbCloseArea()
                
                     //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                     //ณ Busca informacoes do arquivo de NFs. de Entrada - SD1               ณ
                     //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        
                     cQry4 := ""
                     cQry4 := cQry4 + "SELECT SD1.D1_TES AS CODIGO, SUM(SD1.D1_QUANT) AS MES "
                     cQry4 := cQry4 + "FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) "
                     cQry4 := cQry4 + "WHERE SD1.D_E_L_E_T_  = '' "
                     cQry4 := cQry4 + "AND SD1.D1_FILIAL   = '"+xFilial("SD1")+"' "
                     cQry4 := cQry4 + "AND SD1.D1_COD      = '"+aProd[i]+"' "
                     cQry4 := cQry4 + "AND SD1.D1_DTDIGIT >= '"+dtos(cPridia)+"' "
                     cQry4 := cQry4 + "AND SD1.D1_DTDIGIT <= '"+dtos(cUltdia)+"' "
                     cQry4 := cQry4 + "AND SD1.D1_TIPO     = 'D' "
                     cQry4 := cQry4 + "AND SD1.D1_ORIGLAN NOT IN('LF') "
                     cQry4 := cQry4 + "AND SD1.D1_TES NOT IN('215', '216', '227') "
                     cQry4 := cQry4 + "GROUP BY SD1.D1_TES "
                     TCQUERY cQry4 NEW ALIAS "TMPSD1"

                     DbSelectArea("TMPSD1")
                     DbGoTop()
                     While !Eof()
                           DbSelectArea("SF4")
                           DbSetOrder(1)
                           DbSeek(xFilial("SF4")+TMPSD1->CODIGO,.T.)
                           If Found()
                              If SF4->F4_ESTOQUE == 'S'
                                 If SF4->F4_CODIGO <= '500'
                                    DbSelectArea("ZZ3")
                                    DbSeek(xFilial("ZZ3")+mv_par10+aProd[i],.t.)
                                    RecLock("ZZ3",.f.)
                                       ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) := (ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) - TMPSD1->MES)
                                    MsUnLock()
                                 Else
                                    DbSelectArea("ZZ3")
                                    DbSeek(xFilial("ZZ3")+mv_par10+aProd[i],.t.)
                                    RecLock("ZZ3",.f.)
                                       ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) := (ZZ3->&("ZZ3_Q"+StrZero(mv_par09,2)) + TMPSD1->MES)
                                    MsUnLock()
                                 Endif
                              Endif
                           Endif
                           DbSelectArea("TMPSD1")
                           DbSkip()
                     Enddo
                     DbSelectArea("TMPSD1")
                     DbCloseArea()
                 Next
              Endif
              //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
              //ณ Monta a M้dia Mensal dos Produtos                                   ณ
              //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
              If nPar == 3
                 lCont := .t.
                 
                 //LGS#20200128 - Adequa็ใo para release 12.1.25
                 cPerg6 := "EST136"
                 ValPerg6()
                 lPerg := pergunte(cPerg6,.T.) // Escolher 1 - Atualiza็ao (Mensal) ou 2 - Consulta
                 If !lPerg
                    Return
                 Endif
                 While lCont
                       //LGS#20200128 - Adequa็ใo para release 12.1.25
                       //cPerg6 := "EST136"
                       //ValPerg6()
                       //lPerg := pergunte(cPerg6,.T.) // Escolher 1 - Atualiza็ao (Mensal) ou 2 - Consulta
                       If !lPerg
                          Return
                       Else
                          mvpar09 := mv_par05 // Mes
                          mvpar10 := mv_par06 // Ano
                          cPriDia := ctod('01/'+StrZero(mvpar09,2)+'/'+mvpar10)
                          cUltDia := ctod(strzero(f_ultdia(cPridia),2)+'/'+StrZero(mvpar09,2)+'/'+mvpar10)

                          aMesM := {}
                          aPesos:= {}
                          If Empty(mv_par02)
                             For i := 1 to 12
                                 aadd(aPesos,1)
                             Next
                          Else
                             For i := 1 to 12
                                 aadd(aPesos,Iif(Val(Substr(mv_par02,i,1)) <> 0,Val(Substr(mv_par02,i,1)),1) )
                             Next
                          Endif
                          If mv_par01 == mvpar09                          // 12 == 12
                             nMesIniM := 1
                             nMesFimM := mvpar09
                             nAnoIniM := mvpar10
                             nAnoIniM := mvpar10
                             For i := nMesIniM to nMesFimM
                                 aadd(aMesM,StrZero(i,2)+nAnoIniM)
                             Next 
                          ElseIf mv_par01 < mvpar09                       // 1 < 2
                                 nMesIniM := (mvpar09 - mv_par01) + 1     // 2 - 1 + 1 == 10
                                 nMesFimM := mvpar09                      // 12
                                 nAnoIniM := mvpar10
                                 nAnoFimM := mvpar10
                                 For i := nMesIniM to nMesFimM
                                     aadd(aMesM,StrZero(i,2)+nAnoIniM)
                                 Next 
                          ElseIf mv_par01 > mvpar09                          // 3 > 1
                                 nMesIniM := (12 - (mv_par01 - mvpar09)) + 1 // (12 - (3 - 1)) + 1 == 13
                                 nMesFimM := mvpar09
                                 nAnoIniM := Strzero(Val(mvpar10) - 1, 4)
                                 nAnoFimM := mvpar10
                                 For i := nMesIniM to 12
                                     aadd(aMesM,StrZero(i,2)+nAnoIniM)
                                 Next 
                                 For i := 1 to nMesFimM
                                     aadd(aMesM,StrZero(i,2)+nAnoFimM)
                                 Next 
                          Endif

                          ProcRegua(Len(aProd))
       
                          For i := 1 to Len(aProd)
                              nValor := 0
                              If mv_par04 == 1
                                 DbSelectArea("SB1")
                                 DbSetOrder(1)
                                 DbSeek(xFilial("SB1")+aProd[i,1],.t.)
                                 If Found()
                                    nValor := SB1->B1_UPRC
                                 Else
                                    nValor := 0
                                 Endif
                             ElseIf mv_par04 == 2
                                    DbSelectArea("SB2")
                                    DbSetOrder(1)
                                    DbSeek(xFilial("SB2")+aProd[i,1],.t.)
                                    If Found()
                                       nValor := SB2->B2_CM1
                                    Else
                                       nValor := 0
                                    Endif
                             ElseIf mv_par04 == 3 .and. aProd[i,2] =="PA" //.and. aProd[i,3] =="S"
                                    DbSelectarea("DA1")
                                    DA1->( Dbsetorder(2) ) //Cod.Produto + Cod. Tabela + Item
                                    DA1->( DbSeek( xFilial("DA1") + aProd[i,1] +"2  " ) )                                     
                                    If Found()
                                       nValor := ROUND(DA1->DA1_PRCVEN,2)
                                    Else
                                       nValor := 0
                                    Endif
                             Endif
                             nSoma := 0
                             For x := 1 to Len(aMesM)
                                 DbSelectArea("ZZ3")
                                 DbSetOrder(1)
                                 DbSeek(xFilial("ZZ3")+SubStr(aMesM[x],3,4)+aProd[i,1],.t.)
                                 If Found()
                                    nSoma := nSoma + ( ZZ3->&('ZZ3_Q'+SubStr(aMesM[x],1,2))  * aPesos[Val(SubStr(aMesM[x],1,2))] )
                                 Endif
                             Next
                          
                             DbSelectArea("ZZ2")
                             DbSetOrder(1)
                             DbSeek(xFilial("ZZ2")+aProd[i,1],.t.)
                             If Found()
                                RecLock("ZZ2",.f.)
                                   ZZ2->ZZ2_MEDIA  := (nSoma / Len(aMesM)) * (1 + (mv_par03/100))
                                   ZZ2->ZZ2_TOTAL  := ROUND((ZZ2->ZZ2_MEDIA * nValor),2)
                                   ZZ2->ZZ2_MES    := cUltDia
                                MsUnLock()
                             Else
                                RecLock("ZZ2",.T.)
                                   ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
                                   ZZ2->ZZ2_COD    := aProd[i,1]
                                   ZZ2->ZZ2_MEDIA  := (nSoma / Len(aMesM)) * (1 + (mv_par03/100))
                                   ZZ2->ZZ2_CLASSE := ""
                                   ZZ2->ZZ2_TOTAL  := ROUND((ZZ2->ZZ2_MEDIA * nValor),2)
                                   ZZ2->ZZ2_MES    := cUltDia
                                MsUnLock()
                             Endif
                             IncProc("Calculando as M้dias. Produto: "+aProd[i,1])
                          Next
                       Endif
                       lCont := .f.
                 Enddo
              Endif
       #ENDIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG3 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg3()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg3 := PADR(cPerg3,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg3,"01","Do produto          ","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg3,"02","Ate o produto       ","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg3,"03","Do local            ","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg3,"04","Ate o local         ","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg3,"05","Do tipo             ","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg3,"06","Ate o tipo          ","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg3,"07","Do grupo            ","","","mv_ch7","C",04,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg3,"08","Ate o grupo         ","","","mv_ch8","C",04,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg3,"09","Mes                 ","","Entre(1,12,mv_par09)","mv_ch9","N",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg3,"10","Ano                 ","","","mv_cha","C",04,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""})

       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg3+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG1 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg1()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg1 := PADR(cPerg1,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg1,"01","Do produto        ","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg1,"02","Ate o produto     ","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg1,"03","Do local          ","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg1,"04","Ate o local       ","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg1,"05","Do tipo           ","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg1,"06","Ate o tipo        ","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg1,"07","Do grupo          ","","","mv_ch7","C",04,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg1,"08","Ate o grupo       ","","","mv_ch8","C",04,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg1,"09","Meses Anteriores  ","Entre(1,12,mv_par10)","","mv_ch9","N",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg1,"10","Consid. Mes Atual ","","","mv_cha","N",01,0,0,"C","","mv_par10","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg1,"11","Ordem             ","","","mv_chb","N",01,0,0,"C","","mv_par11","Produto","","","","","Media","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg1,"12","Listar            ","","","mv_chc","N",01,0,0,"C","","mv_par12","Todos","","","","","Media > 0","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg1,"13","Filtra Ativos    ?","","","mv_chd","N",01,0,0,"C","","mv_par13","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg1+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0131  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA. A funcao PROCESSA   บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0131()
       Local nMesAtu := 0   // Variavel para guardar mes atual
       Local nAnoAtu := 0   // Variavel para guardar mes atual
       Local nMesIni := 0   // Variavel para guardar mes inicial
       Local nMesFim := 0   // Variavel para guardar mes inicial
       Local nAnoIni := 0   // Variavel para guardar mes inicial
       Local nAnoFim := 0   // Variavel para guardar mes inicial
       //Local nQuantR := 0   // Quantidade reservada em estoque
       //Local nQuant  := 0   // Quantidade atual no estoque
       Local cQry5   := ""
       Local cCon    := ""
       Local i
       Private aMesesE := {"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
       Private aMeses  := {}  // Array com os meses a serem impressos
       Private aAno    := {}  // Array com os meses a serem impressos
       Private aCampos := {}
       Private aCpoBro := {}
       cabec1          := ""
       cabec1          := "    CODIGO                     DESCRICAO                 TP LC UM  "     

       If mv_par10 == 1
             nMesAtu := Month(dDataBase)
             nAnoAtu := Year(dDataBase)
       Else
          nMesAtu := Iif((Month(dDataBase) - 1) == 0, 12, (Month(dDataBase) - 1) )
          nAnoAtu := Iif((Month(dDataBase) - 1) == 0, (Year(dDataBase) - 1), Year(dDataBase))
       Endif
       If nMesAtu == mv_par09
          nMesIni := (nMesAtu - mv_par09) + 1
          nMesFim := nMesAtu
          nAnoIni := StrZero(nAnoAtu,4)
          nAnoFim := StrZero(nAnoAtu,4)
          For i := nMesIni To nMesFim
              aadd(aMeses,StrZero(i,2)+nAnoIni)
          Next
       ElseIf nMesAtu > mv_par09
              nMesIni := (nMesAtu - mv_par09) + 1
              nMesFim := nMesAtu
              nAnoIni := StrZero(nAnoAtu,4)
              nAnoFim := StrZero(nAnoAtu,4)
              For i := nMesIni To nMesFim
                  aadd(aMeses,StrZero(i,2)+nAnoIni)
              Next
       ElseIf nMesAtu < mv_par09
              nMesIni := (12 - (mv_par09 - nMesAtu)) + 1
              nMesFim := If(nMesAtu == 0,1,nMesAtu)
              nAnoIni := StrZero(nAnoAtu - 1,4)
              nAnoFim := StrZero(nAnoAtu,4)
              For i := nMesIni to 12
                  aadd(aMeses,StrZero(i,2)+nAnoIni)
              Next 
              For i := 1 to nMesFim
                  aadd(aMeses,StrZero(i,2)+nAnoFim)
              Next 
       Endif

       For i := 1 to Len(aMeses)
           Cabec1 := Cabec1 + SubStr(UPPER(MesExtenso(Val(SubStr(aMeses[i],1,2)))),1,3)+'/'+SubStr(Alltrim(SubStr(aMeses[i],3,4)),3,2)+'     '
       Next
       
       Cabec1 := Cabec1 + 'MEDIAS    '
       Cabec1 := Cabec1 + 'SAL. ATUAL   '
       Cabec1 := Cabec1 + 'DISPONIVEL   '
       Cabec1 := Cabec1 + 'PTO. PEDIDO     '
       Cabec1 := Cabec1 + 'C '
       Cabec1 := Cabec1 + '> PRODUCAO '
       
       aadd(aCampos,{"CODIGO"   ,"C",15,0} )
       aadd(aCampos,{"DESCRICAO","C",40,0} )
       aadd(aCampos,{"TIPO"     ,"C",02,0} )
       //aadd(aCampos,{"LOCAL"    ,"C",02,0} )
       aadd(aCampos,{"ARMAZ"    ,"C",02,0} )
       aadd(aCampos,{"UNIDADE"  ,"C",02,0} )
       aadd(aCpoBro,{"CODIGO"   ,OemToAnsi("Codigo")    ,"@R XXX99.99.999-99"} )
       aadd(aCpoBro,{"DESCRICAO",OemToAnsi("Descricao") ,"@!"             } )
       aadd(aCpoBro,{"TIPO"     ,OemToAnsi("Tipo")      ,"@!"             } )
       //aadd(aCpoBro,{"LOCAL"    ,OemToAnsi("Local")     ,"99"             } )
        aadd(aCpoBro,{"ARMAZ"    ,OemToAnsi("Local")     ,"99"             } )
       aadd(aCpoBro,{"UNIDADE"  ,OemToAnsi("Unidade")   ,"@!"             } )
       For i := 1 to Len(aMeses)
           aadd(aCampos,{"MES"+SubStr(aMeses[i],1,2),"N",11,0} )
           aadd(aCpoBro,{"MES"+SubStr(aMeses[i],1,2),OemToAnsi(aMesesE[Val(SubStr(aMeses[i],1,2))])   ,"@E 999,999,999"} )
           cCon := cCon + "0 AS MES"+SubStr(aMeses[i],1,2)+", "
       Next
       cPriPar := SubStr(aMeses[1],3,4)+SubStr(aMeses[1],1,2)+"01"
       cUltPar := SubStr(aMeses[Len(aMeses)],3,4)+SubStr(aMeses[Len(aMeses)],1,2)+StrZero(f_ultdia(cTod('01'+'/'+SubStr(aMeses[Len(aMeses)],1,2)+'/'+SubStr(aMeses[Len(aMeses)],3,4))),2)

       aadd(aCampos,{"MEDIA"    ,"N",11,0} )
       aadd(aCampos,{"UNITARIO" ,"N",12,2} )
       aadd(aCampos,{"TOTAL"    ,"N",14,2} )
       aadd(aCampos,{"ATUAL"    ,"N",12,2} )
       aadd(aCampos,{"DISPON"   ,"N",12,2} )
       aadd(aCampos,{"PEDIDO"   ,"N",12,2} )
       aadd(aCampos,{"CLASSE"   ,"C",01,0} )
       aadd(aCampos,{"CLAINV"   ,"C",01,0} )
       aadd(aCampos,{"TOTINV"   ,"C",16,0} )
       aadd(aCampos,{"MEDINV"   ,"C",16,0} )
       aadd(aCampos,{"MAXOP"    ,"N",12,2} )
       aadd(aCpoBro,{"MEDIA"    ,OemToAnsi("Media")         ,"@E 999,999,999"    } )
       aadd(aCpoBro,{"UNITARIO" ,OemToAnsi("Custo Unitario"),"@E 9,999,999.99"   } )
       aadd(aCpoBro,{"TOTAL"    ,OemToAnsi("Custo Total")   ,"@E 999,999,999.99" } )
       aadd(aCpoBro,{"ATUAL"    ,OemToAnsi("Sld. Atual")    ,"@E 9,999,999.99"   } )
       aadd(aCpoBro,{"DISPON"   ,OemToAnsi("Disponivel")    ,"@E 9,999,999.99"   } )
       aadd(aCpoBro,{"PEDIDO"   ,OemToAnsi("Pto. Pedido")   ,"@E 9,999,999.99"   } )
       aadd(aCpoBro,{"CLASSE"   ,OemToAnsi("Classe ABC")    ,"@!"                } )

       If lCriaArq
          //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
          //ณ Cria indice condicional									  ณ
          //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
          //lRet := ChkFile("CCONS")
          If Select("CCONS")<>0
             DbSelectArea("CCONS")
             DbCloseArea()
             oTempTable:Delete()
          Endif
          /*
          _cNomArq1 := U_NovoArqTrab("dtc")
          dbcreate(_cNomArq1+".dtc",aCampos,"CTREECDX")
          USE (_cNomArq1+".dtc") ALIAS CCONS VIA "CTREECDX" NEW
          */
           oTempTable := FWTemporaryTable():New( "CCONS" )
	       oTemptable:SetFields( aCampos )
	       oTempTable:AddIndex( "cInd01", { "CODIGO" } )
	       oTempTable:AddIndex( "cInd02", { "MEDINV" } )
	       oTempTable:Create()
	       DbSelectArea( "CCONS" )
	       DbSetOrder(1)
          
          
          lCriaArq := .T.
          /*
 		  DbCreateIndex(_cNomArq1+"_1.cdx", "CODIGO", {||"CODIGO"} )
     	  DbCreateIndex(_cNomArq1+"_2.cdx", "MEDINV", {||"MEDINV"} )
          DbClearInd()
          DbSetIndex(_cNomArq1+"_1")
          DbSetIndex(_cNomArq1+"_2")
          DbSetOrder(1)
          */
       Endif
       DbSelectArea("ZZ3")
       ProcRegua(RecCount())
       
       cQry5 := ""
       cQry5 := cQry5 + "SELECT ZZ2.ZZ2_COD AS CODIGO, B1.B1_DESC AS DESCRICAO, B1.B1_TIPO AS TIPO, B1.B1_LOCPAD AS ARMAZ, B1.B1_UM AS UNIDADE, "
       cQry5 := cQry5 + cCon
       cQry5 := cQry5 + "       ZZ2.ZZ2_MEDIA AS MEDIA, ZZ2.ZZ2_TOTAL AS 'CTOTAL', B1.B1_EMIN AS PEDIDO, ZZ2.ZZ2_CLASSE AS CLASSE "
       cQry5 := cQry5 + "FROM "+RetSqlName("SB1")+" B1 WITH (NOLOCK) "
       cQry5 := cQry5 + "INNER JOIN "+RetSqlName("ZZ2")+" ZZ2 WITH (NOLOCK) ON ZZ2.ZZ2_FILIAL = B1.B1_FILIAL AND ZZ2.ZZ2_COD = B1.B1_COD "
       cQry5 := cQry5 + "WHERE B1.D_E_L_E_T_ = '' "
       cQry5 := cQry5 + "  AND ZZ2.D_E_L_E_T_ = '' "
       cQry5 := cQry5 + "  AND B1.B1_FILIAL = '"+xFilial("SB1")+"' "
       cQry5 := cQry5 + "  AND B1.B1_COD    BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry5 := cQry5 + "  AND B1.B1_LOCPAD BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQry5 := cQry5 + "  AND B1.B1_TIPO   BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
       cQry5 := cQry5 + "  AND B1.B1_GRUPO  BETWEEN '"+mv_par07+"' AND '"+mv_par08+"' "
       If mv_par13 == 1
          cQry5 := cQry5 + "  AND B1.B1_ATIVO NOT IN('N') "
       Endif
       cQry5 := cQry5 + "ORDER BY B1.B1_COD "

       TCQUERY cQry5 NEW ALIAS "TMPSB1"
       
       DbSelectArea("TMPSB1")
       DbGoTop()
       ProcRegua(500)
       While !EOF()
             nQAtu := 0
             nQEmp := 0
             If mv_par12 == 2
                If TMPSB1->MEDIA <= 0
                   DbSelectArea("TMPSB1")
                   DbSkip()
                   Loop
                Endif
             Endif
             If TMPSB1->TIPO $ "PI"
                nMaxOP := 0
                cQryOP := ""
                cQryOP += "SELECT MAX(C2.C2_QUANT) AS MAXOP "
                cQryOP += "FROM "+RetSqlName("SC2")+" C2 WITH (NOLOCK) "
                cQryOP += "WHERE C2.C2_FILIAL  = '"+xFilial("SC2")+"' "
                cQryOP += "  AND C2.D_E_L_E_T_ = '' "
                cQryOP += "  AND C2.C2_PRODUTO = '"+TMPSB1->CODIGO+"' "
                cQryOP += "  AND C2.C2_DATRF BETWEEN '"+cPriPar+"' AND '"+cUltPar+"' "
                
                TCQUERY cQryOP NEW ALIAS "TMPXXX"
                
                DbSelectArea("TMPXXX")
                nMaxOP := TMPXXX->MAXOP
                
                DbCloseArea()
                
                DbSelectArea("TMPSB1")
             Else
                nMaxOP := 0
             Endif
             DbSelectArea("SB2")
             DbSetOrder(1)
             DbSeek(xFilial("SB2")+TMPSB1->CODIGO,.t.)
             While !Eof() .and. SB2->B2_COD == TMPSB1->CODIGO
                   If SB2->B2_LOCAL >= mv_par03 .and. SB2->B2_LOCAL <= mv_par04
                      nQAtu := nQAtu + SB2->B2_QATU
                      nQEmp := nQEmp + SB2->B2_QEMP
                   Endif
                   DbSkip()
             Enddo
             RecLock("CCONS",.t.)
                CCONS->CODIGO    := TMPSB1->CODIGO
                CCONS->DESCRICAO := TMPSB1->DESCRICAO
                CCONS->TIPO      := TMPSB1->TIPO
                //CCONS->LOCAL     := TMPSB1->LOCAL
                CCONS->ARMAZ     := TMPSB1->ARMAZ
                CCONS->UNIDADE   := TMPSB1->UNIDADE
                For i := 1 to Len(aMeses)
                    DbSelectArea("ZZ3")
                    DbSetOrder(1)
                    DbSeek(xFilial("ZZ3")+SubStr(aMeses[i],3,4)+TMPSB1->CODIGO,.t.)
                    If Found()
                       CCONS->&("MES"+SubStr(aMeses[i],1,2))     := ZZ3->&("ZZ3_Q"+SubStr(aMeses[i],1,2))
                    Endif
                Next
                CCONS->MEDIA     := TMPSB1->MEDIA
                CCONS->UNITARIO  := IIF(TMPSB1->CTOTAL > 0, (TMPSB1->CTOTAL / TMPSB1->MEDIA),0)
                CCONS->TOTAL     := ROUND(TMPSB1->CTOTAL,2)
                CCONS->ATUAL     := nQAtu
                CCONS->DISPON    := (nQAtu - nQEmp)
                CCONS->PEDIDO    := TMPSB1->PEDIDO
                CCONS->CLASSE    := TMPSB1->CLASSE
                CCONS->CLAINV    := INVERTE(TMPSB1->CLASSE)
                CCONS->TOTINV    := INVERTE(TRANSFORM(TMPSB1->CTOTAL,"@E 999,999,999.9999"))
                CCONS->MEDINV    := INVERTE(TRANSFORM(TMPSB1->MEDIA,"@E 999,999,999.9999"))
                CCONS->MAXOP     := nMaxOP
             MsUnLock()
             IncProc("Montando consulta.")
             DbSelectArea("TMPSB1")
             DbSkip()
       EndDo
       //lRet := ChkFile("TMPSB1")
       If Select("TMPSB1")<>0
          DbSelectArea("TMPSB1")
          DbCloseArea()
       Endif

       EST0132()
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0132  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para mostrar consulta na tela.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0132()       
       DbSelectArea("CCONS")
       If mv_par11 == 1
          DbSetOrder(1)
       Else
          DbSetOrder(2)
       Endif
       DbGoTop()
      
       @ 012,010 To 400,800 Dialog oDlg1 Title OemToAnsi("Consulta consumo m้dio")
       @ 005,005 To 190,360 Browse "CCONS" Fields aCpoBro
       
       @ 005,365 BMPBUTTON Type  1 Action EST0133()
       @ 025,365 BMPBUTTON Type  5 Action EST0134()
       @ 045,365 BMPBUTTON Type  6 Action EST0135()
       Activate Dialog oDlg1 Centered
       If !lJaFech
          lTelaJaFechada := .t.
          EST0133()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0133  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para finalizacao da consulta.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0133()
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao da consulta...                                  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If !lTelaJaFechada
          Close(oDlg1)
       Endif
       lJaFech := .t.
       //lRet := ChkFile("CCONS")
       If Select("CCONS")<>0
          DbSelectArea("CCONS")
          DbCloseArea()
          oTempTable:Delete()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0134  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para alteracao dos paramentros da consulta.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0134()
       lPerg := Pergunte(cPerg1,.T.)
       If lPerg
          DbSelectArea("CCONS")
          DbSetOrder(1)
          DbCloseArea()
          oTempTable:Delete()
          Close(oDlg1)
          EST0131()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0135  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para impressao da consulta.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0135()
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Declaracao de Variaveis                                             ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       //Private cString
       Private aOrd        := {}
       //Private CbTxt       := ""
       Private cDesc1      := "Este programa tem como objetivo imprimir relatorio "
       Private cDesc2      := "de acordo com os parametros informados pelo usuario."
       Private cDesc3      := "Relatorio de Consumo Mensal"
       Private cPict       := ""
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       Private limite      := 220
       Private tamanho     := "G"
       Private nomeprog    := "BREST013" 
       Private nTipo       := 15
       Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cPerg1      := "EST131"
       Private titulo      := "Relatorio de Consumo Mensal"
       Private nLin        := 80

       Private Cabec2      := ""
       Private cbtxt       := Space(10)
       Private cbcont      := 00
       Private CONTFL      := 01
       Private m_pag       := 01
       Private imprime     := .T.
       Private wnrel       := "BREST013"
       Private cString     := "CCONS"

       dbSelectArea("CCONS")

       pergunte(cPerg1,.F.)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Monta a interface padrao com o usuario...                           ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       wnrel := SetPrint(cString,NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

       If nLastKey == 27
          Return
       Endif

       SetDefault(aReturn,cString)
     
       If nLastKey == 27
          Return
       Endif

       nTipo := If(aReturn[4]==1,15,18)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Processamento. PROCESSA monta janela com a regua de processamento.  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       Processa({|| EST01351(Cabec1,Cabec2,Titulo,nLin) },Titulo)
       
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST01351 บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA. A funcao PROCESSA   บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST01351(Cabec1,Cabec2,Titulo,nLin)
       Local x
       DbSelectArea("CCONS")
       DbGoTop()
       ProcRegua(RecCount())
       While !Eof()
             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Verifica o cancelamento pelo usuario...                             ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Impressao do cabecalho do relatorio. . .                            ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

             If nLin > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                nLin := nLin + 1
             Endif
             @ nLin,000 PSAY CCONS->CODIGO    Picture "@R XXX99.99.999-99"
             @ nLin,016 PSAY CCONS->DESCRICAO Picture "@!"
             @ nLin,057 PSAY CCONS->TIPO      Picture "@!"
             @ nLin,060 PSAY CCONS->ARMAZ     Picture "99"
             @ nLin,063 PSAY CCONS->UNIDADE   Picture "@!"
             nCol := 066
             For x := 1 to Len(aMeses)
                 @ nLin,nCol PSAY CCONS->&("MES"+Substr(aMeses[x],1,2)) Picture "@E 999,999.99"
                 nCol := nCol + 11
             Next
             @ nLin,nCol PSAY CCONS->MEDIA  Picture "@E 999,999.99"
             nCol := nCol + 11
             @ nLin,nCol PSAY CCONS->ATUAL  Picture "@E 9,999,999.99"
             nCol := nCol + 14
             @ nLin,nCol PSAY CCONS->DISPON Picture "@E 9,999,999.99"
             nCol := nCol + 14
             @ nLin,nCol PSAY CCONS->PEDIDO Picture "@E 9,999,999.99"
             nCol := nCol + 14
             @ nLin,nCol PSAY CCONS->CLASSE Picture "@!"
             nCol := nCol + 2
             @ nLin,nCol PSAY CCONS->MAXOP  Picture "@E 9,999,999.99"
             nLin := nLin + 1    // Avanca a linha de impressao
             
             IncProc("Imprimindo relatorio !!!")

             DbSelectArea("CCONS")
             DbSkip()
       Enddo
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao do relatorio...                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SET DEVICE TO SCREEN

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

       DbSelectArea("CCONS")
       DbGoTop()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG6 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg6()
       Local aRegs := {}
       Local i, j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg6 := PADR(cPerg6,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg6,"01","Meses p/ Media      ","","Entre(1,12,mv_par11)","mv_ch1","N",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg6,"02","Peso Mensal p/ Media","","","mv_ch2","C",12,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg6,"03","% Incr. sobre Media ","","","mv_ch3","N",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg6,"04","Calculo de Custo    ","","","mv_ch4","N",01,0,0,"C","","mv_par04","Ultimo Pre็o","","","","","Custo M้dio","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg6,"05","Mes Ultimo Consumo  ","","Entre(1,12,mv_par09)","mv_ch5","N",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg6,"06","Ano Ultimo Consumo  ","","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg6+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next
Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ EST013A     ณ Autor ณ                     ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณFuncao que valida os percentuais do Calculo ABC              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EST013A()
       //Local cQry6     := ""
       //Local cQry7     := ""
       Private cPerg4  := "EST134"
       Private cPerg7  := "EST137"
       Private aCpoCon := {}       
       Private aCamCla := {}
       Private ocCons2 := ""
       
       Processa( {|| EST013AA()},"Classifica็ใo")
Return
       
Static Function EST013AA()
       Local cQry6     := ""
       Local cQry7     := ""
       If lLocal
          ValPerg7()
          lPerg := Pergunte(cPerg7,.t.)
          If !lPerg
             Return
          Else
             If mv_par01 == 1
                EST0139()
                Return
             Endif
          Endif
                 
          ValPerg4()
          lPerg := Pergunte(cPerg4,.t.)
          If !lPerg 
             Return
          Endif
       Endif
       aadd(aCamCla,{"CODIGO"     ,"C",15,0 } )
       aadd(aCamCla,{"DESCRICAO"  ,"C",40,0 } )
       aadd(aCamCla,{"TIPO"       ,"C",02,0 } )
       //aadd(aCamCla,{"LOCAL"      ,"C",02,0 } )
       aadd(aCamCla,{"ARMAZ"      ,"C",02,0 } )
       aadd(aCamCla,{"UNIDADE"    ,"C",02,0 } )
       aadd(aCamCla,{"ATUAL"      ,"N",14,2 } )
       aadd(aCamCla,{"EMPENHO"    ,"N",14,2 } )
       aadd(aCamCla,{"DISPONIVEL" ,"N",14,2 } )
       aadd(aCamCla,{"PREVISTO"   ,"N",14,2 } )
       aadd(aCamCla,{"PROJECAO"   ,"N",14,2 } )
       aadd(aCamCla,{"LOTE"       ,"N",14,2 } )
       aadd(aCamCla,{"PEDIDO"     ,"N",14,2 } )
       aadd(aCamCla,{"MEDIA"      ,"N",14,2 } )
       aadd(aCamCla,{"CLASSE"     ,"C",01,0 } )
       aadd(aCamCla,{"PRECO"      ,"N",14,2 } )
       aadd(aCamCla,{"ENTREGA"    ,"C",17,0 } )      //'99 + 99 = 99 DIAS'
       aadd(aCamCla,{"NUMPED"     ,"C",27,0 } )
       aadd(aCamCla,{"VALTOT"     ,"N",14,4 } )
       aadd(aCamCla,{"CLAINV"     ,"C",01,0 } )
       aadd(aCamCla,{"TOTINV"     ,"C",16,0 } )
       
       aadd(aCpoCon,{"CODIGO"     ,OemToAnsi("Codigo")       ,"@R XXX99.99.999-99"} )
       aadd(aCpoCon,{"DESCRICAO"  ,OemToAnsi("Descricao")    ,"@!"                } )
       aadd(aCpoCon,{"TIPO"       ,OemToAnsi("Tipo")         ,"@!"                } )
       //aadd(aCpoCon,{"LOCAL"      ,OemToAnsi("Local")        ,"99"                } ) 
       aadd(aCpoCon,{"ARMAZ"      ,OemToAnsi("Local")        ,"99"                } )
       aadd(aCpoCon,{"UNIDADE"    ,OemToAnsi("Unidade")      ,"@!"                } )
       aadd(aCpoCon,{"ATUAL"      ,OemToAnsi("Saldo Atual")  ,"@E 999,999,999.99" } ) 
       aadd(aCpoCon,{"EMPENHO"    ,OemToAnsi("Empenhado")    ,"@E 999,999,999.99" } ) 
       aadd(aCpoCon,{"DISPONIVEL" ,OemToAnsi("Disponivel")   ,"@E 999,999,999.99" } ) 
       aadd(aCpoCon,{"PREVISTO"   ,OemToAnsi("Prev. Entrada"),"@E 999,999,999.99" } )        
       aadd(aCpoCon,{"PROJECAO"   ,OemToAnsi("Projecao")     ,"@E 999,999,999.99" } ) 
       aadd(aCpoCon,{"LOTE"       ,OemToAnsi("Lote Econ๔m.") ,"@E 999,999,999.99" } ) 
       aadd(aCpoCon,{"PEDIDO"     ,OemToAnsi("Ponto Pedido") ,"@E 999,999,999.99" } ) 
       aadd(aCpoCon,{"MEDIA"      ,OemToAnsi("Media Consumo"),"@E 999,999,999.99" } ) 
       aadd(aCpoCon,{"CLASSE"     ,OemToAnsi("Classe ABC")   ,"@!"                } )        
       aadd(aCpoCon,{"PRECO"      ,OemToAnsi("Ult. Preco")   ,"@E 999,999,999.99" } )        

       //lRet := ChkFile("CCONS2")
       If SELECT("CCONS2") > 0
          DbSelectArea("CCONS2")
          DbCloseArea()
          ocCons2:Delete()
       Endif
       /*
		_cNomArq2 := U_NovoArqTrab("dtc")
		dbcreate(_cNomArq2+".dtc",aCamCla,"CTREECDX")     
       USE (_cNomArq2+".dtc") ALIAS CCONS2 VIA "CTREECDX" NEW

       DbCreateIndex(_cNomArq2+"_1.cdx", "CODIGO", {||"CODIGO"} )
       DbCreateIndex(_cNomArq2+"_2.cdx", "CLAINV+TOTINV", {||"CLAINV+TOTINV"} )
       DbCreateIndex(_cNomArq2+"_3.cdx", "TOTINV", {||"TOTINV"} )
       DbClearInd()
       DbSetIndex(_cNomArq2+"_1")
       DbSetIndex(_cNomArq2+"_2")
       DbSetIndex(_cNomArq2+"_3")
       DbSetOrder(1)
       */
       ocCons2 := FWTemporaryTable():New( "CCONS2" )
       ocCons2:SetFields( aCamCla )
       ocCons2:AddIndex( "cInd01", { "CODIGO" } )
       ocCons2:AddIndex( "cInd02", { "CLAINV","TOTINV" } )
       ocCons2:AddIndex( "cInd03", { "TOTINV" } )
       ocCons2:Create()
       DbSelectArea( "CCONS2" )
       DbSetOrder(1)
       

       cQry6 := ""
       cQry6 := cQry6 + "SELECT B2.B2_COD AS CODIGO, SUM(B2.B2_QATU) AS ATUAL, SUM(B2.B2_QEMP) AS EMPENHO, "
       cQry6 := cQry6 + "SUM((B2.B2_QATU - B2.B2_QEMP)) AS DISPONIVEL, SUM(B2.B2_SALPEDI) AS PREVISTO, SUM(((B2.B2_QATU - B2.B2_QEMP) + B2.B2_SALPEDI)) AS PROJECAO "
       cQry6 := cQry6 + "FROM "+RetSqlName("SB2")+" B2 WITH (NOLOCK) "
       cQry6 := cQry6 + "WHERE B2.B2_FILIAL = '"+xFilial("SB2")+"' "
       cQry6 := cQry6 + "AND B2.D_E_L_E_T_ = '' "
       cQry6 := cQry6 + "AND B2.B2_COD BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
       cQry6 := cQry6 + "AND B2.B2_LOCAL BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "
       cQry6 := cQry6 + "GROUP BY B2.B2_COD "
       If mv_par11 == 1
          cQry6 := cQry6 + "ORDER BY B2.B2_COD "
       Endif

       TCQUERY cQry6 NEW ALIAS "TMPCON"
       
       DbSelectArea("TMPCON")
       DbGoTop()
       nTotReg := fCount()
       ProcRegua(500)
       While !Eof()
             IncProc('Processando a consulta. Aguarde...')
             cClasse := ""
             nMedia  := 0
             DbSelectArea("ZZ2")
             DbSetOrder(1)
             DbSeek(xFilial("ZZ2")+TMPCON->CODIGO,.t.)
             If Found()
                cClasse := ZZ2->ZZ2_CLASSE
                nMedia  := ZZ2->ZZ2_MEDIA
             Endif
             DbSelectArea("SB1")
             DbSetOrder(1)
             DbSeek(xFilial("SB1")+TMPCON->CODIGO,.t.)
             If Found()
                If mv_par13 == 1
                   If SB1->B1_ATIVO $ 'N'
                      DbSelectArea("TMPCON")
                      DbSkip()
                      Loop
                   Endif
                Endif
                If mv_par09 == 2
                   If !(TMPCON->ATUAL <= SB1->B1_EMIN) 
                      If !((TMPCON->ATUAL - TMPCON->EMPENHO) <= SB1->B1_EMIN) 
                         DbSelectArea("TMPCON")
                         DbSkip()
                         Loop
                      Endif
                   Endif
                Endif  
                If mv_par10 == 2
                   If SB1->B1_EMIN <= 0
                       DbSelectArea("TMPCON")
                       DbSkip()
                       Loop
                   Endif
                Endif
                cQry7 := ""
                cQry7 := cQry7 + "SELECT C7.C7_NUM AS NUMERO, C7.C7_EMISSAO AS EMISSAO "
                cQry7 := cQry7 + "FROM "+RetSqlName("SC7")+" C7 WITH (NOLOCK) "
                cQry7 := cQry7 + "WHERE C7.C7_FILIAL = '"+xFilial("SC7")+"' "
                cQry7 := cQry7 + "  AND C7.D_E_L_E_T_ = '' "
                cQry7 := cQry7 + "  AND C7.C7_RESIDUO <> 'S' "
                cQry7 := cQry7 + "  AND C7.C7_PRODUTO = '"+TMPCON->CODIGO+"' "
                cQry7 := cQry7 + "  AND C7.C7_QUANT > C7.C7_QUJE "
                cQry7 := cQry7 + "  AND C7.C7_ENCER = '' "
                cQry7 := cQry7 + "ORDER BY C7.C7_EMISSAO "
             
                TCQUERY cQry7 NEW ALIAS "TMPNUM"
                DbSelectArea("TMPNUM")
                DbGoTop()
                cNumPed := ""
                _Vez    := 1
                While !Eof()
                      If _Vez == 1
                         cNumPed := cNumPed + TMPNUM->NUMERO+" - "+SubStr(TMPNUM->EMISSAO,7,2)+"/"+SubStr(TMPNUM->EMISSAO,5,2)
                         _Vez    := _Vez + 1
                      Endif
                      DbSelectArea("TMPNUM")
                      DbSkip()
                Enddo
                
                DbSelectArea("TMPNUM")
                DbCloseArea()
                
                If SB1->B1_TIPO >= mv_par05 .AND. SB1->B1_TIPO <= mv_par06
                   If SB1->B1_GRUPO >= mv_par07 .AND. SB1->B1_GRUPO <= mv_par08 
                      RecLock("CCONS2",.t.)
                         CCONS2->CODIGO     := SB1->B1_COD
                         CCONS2->TIPO       := SB1->B1_TIPO
                         //CCONS2->LOCAL      := SB1->B1_LOCPAD
                         CCONS2->ARMAZ      := SB1->B1_LOCPAD
                         CCONS2->UNIDADE    := SB1->B1_UM
                         CCONS2->DESCRICAO  := SB1->B1_DESC
                         CCONS2->LOTE       := SB1->B1_LE
                         CCONS2->PEDIDO     := SB1->B1_EMIN
                         CCONS2->PRECO      := ROUND(SB1->B1_UPRC,2)
                         CCONS2->ATUAL      := TMPCON->ATUAL
                         CCONS2->EMPENHO    := TMPCON->EMPENHO
                         CCONS2->DISPONIVEL := TMPCON->DISPONIVEL
                         CCONS2->PREVISTO   := TMPCON->PREVISTO
                         CCONS2->PROJECAO   := TMPCON->PROJECAO
                         CCONS2->MEDIA      := nMedia
                         CCONS2->CLASSE     := cClasse
                         CCONS2->ENTREGA    := STRZERO(SB1->B1_PE,2)+" + "+IIF(SB1->B1_LOCENT == '1',"02","00")+" = "+StrZero(SB1->B1_PE+IIF(SB1->B1_LOCENT == '1',2,0),2)+" DIAS"
                         CCONS2->NUMPED     := cNumPed
                         CCONS2->VALTOT     := (SB1->B1_UPRC * (nMedia - TMPCON->DISPONIVEL) )
                         CCONS2->CLAINV     := INVERTE(cClasse)
                         CCONS2->TOTINV     := INVERTE(Transform(CCONS2->VALTOT,"@E 999,999,999.9999"))
                      MsUnLock()
                   Endif
                Endif
             Endif
             DbSelectArea("TMPCON")
             DbSkip()
       Enddo

       DbSelectArea("TMPCON")
       DbCloseArea()
       
       DbSelectArea("CCONS2")
       If mv_par11 == 1
          DbSetOrder(1)
       ElseIf mv_par11 == 2
              DbSetOrder(2)
       Else
          DbSetOrder(3)
       Endif
       DbGoTop()
       
       @ 012,010 To 400,800 Dialog oDlg2 Title OemToAnsi("Consulta classifica็ใo")
       @ 005,005 To 190,360 Browse "CCONS2" Fields aCpoCon
       
       @ 005,365 BMPBUTTON Type  1 Action EST013A1()
       @ 025,365 BMPBUTTON Type  5 Action EST013B()
       @ 045,365 BMPBUTTON Type  6 Action EST013C()
       @ 065,365 BUTTON OemToAnsi("Classif.") SIZE 28,14 ACTION EST0139()

       Activate Dialog oDlg2 Centered
       If !lJaFech2
          lTelaJaFechada2 := .t.
          EST013A1()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG7 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg7()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg7 := PADR(cPerg7,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg7,"01","Atualiza / Consulta","","","mv_ch1","N",01,0,0,"C","","mv_par01","Atualiza Classif.","","","","","Consulta Classif.","","","","","","","","","","","","","","","","","","","",""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg7+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0139  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Classifica็ใo ABC e Ponto de Pedido                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST0139()
       LOCAL oDlg, i
       LOCAL oQual
       LOCAL oChk2,oChk3
       LOCAL aTipo:={}
       LOCAL nA1:=nB1:=nC1:=1
       LOCAL nA2:=20
       LOCAL nB2:=30
       LOCAL nC2:=50
       LOCAL nMes:=22
       LOCAL nEnt:=0
       LOCAL nOpca:=2
       LOCAL qtdmarca := 0
       LOCAL j:= 0
       LOCAL oChkQual,oChk5
       LOCAL oOk := LoadBitmap( GetResources(), "LBOK")
       LOCAL oNo := LoadBitmap( GetResources(), "LBNO")
       LOCAL cVarQ := "  "
       //LOCAL cCapital
       Local _aRetInf := FWGetSX5 ( "02" )
       Local _nX
       Private lLote
       Private lPedido
       Private lGrvABC
       Private lQual3

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณMonta a Tabela de Tipos                                      ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 17/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAวรO DE RELEASE PROTHEUS 12.1.25                  ***/
       /*
       dbSelectArea("SX5")
       dbSeek(cFilial+"02")
       While (SX5->X5_FILIAL == xFilial("SX5")) .AND. (SX5->X5_TABELA == "02")
             cCapital := OemToAnsi(Capital(X5Descri()))
             If Alltrim(SX5->X5_CHAVE) $ "MP"
                AADD(aTipo,{.T.,SubStr(SX5->X5_CHAVE,1,3)+cCapital})
             Endif
             dbSkip()
       EndDo
       */
       For _nX := 1 To Len( _aRetInf )
           If Alltrim( _aRetInf[ _nX][ 3] ) $ "MP.PA.MC.EP"
              AADD(aTipo, { .T., SubStr( _aRetInf[ _nX][ 3], 1, 3) + _aRetInf[ _nX][ 4] } )
           Endif
       Next
       DEFINE MSDIALOG oDlg TITLE "Classifica็ใo ABC" From 145,0 To 455,628 OF oMainWnd PIXEL

       @ 002,015 TO 073,125 TITLE "Calculo"
       @ 012,020 CHECKBOX OemToAnsi("Lote Econ๔mico") VAR lLote Object oChk2 
       oChk2:oFont := oDlg:oFont
       @ 022,020 CHECKBOX OemToAnsi("Ponto de Pedido") VAR lPedido Object oChk3
       oChk3:oFont := oDlg:oFont
       @ 34,020 Say OemToAnsi("Dias do M๊s") SIZE 45,10
       @ 32,100 GET nMes Picture "99.9" VALID Entre(1,30,nMes) SIZE 17,10 
       @ 44,020 Say OemToAnsi("Dias Sใo Paulo x Matใo") SIZE 65,10
       @ 42,100 GET nEnt Picture "99.9" VALID Entre(1,30,nMes) SIZE 17,10 

       @ 02,130 TO 073,300 TITLE OemToAnsi("Classifica็ใo ABC")
       @ 12,182 TO 58,219 TITLE "A"
       @ 12,220 TO 58,257 TITLE "B"
       @ 12,258 TO 58,295 TITLE "C"
       @ 18,135 Say OemToAnsi("Perกodo de") SIZE 45,10
       @ 25,135 Say OemToAnsi("Aquisio(meses)") SIZE 45,10
       @ 38,135 Say OemToAnsi("Distribuio") SIZE 45,10
       @ 45,135 Say OemToAnsi("Percentual (%)") SIZE 45,10
       @ 20,185 GET nA1 Picture "99.9" VALID nA1 >0 SIZE 17,10 
       @ 20,223 GET nB1 Picture "99.9" VALID nB1 >0 SIZE 17,10 
       @ 20,261 GET nC1 Picture "99.9" VALID nC1 >0 SIZE 17,10 
       @ 40,185 GET nA2 Picture "99.9" VALID nA2 >0 SIZE 17,10 
       @ 40,223 GET nB2 Picture "99.9" VALID nB2 >0 SIZE 17,10 
       @ 40,261 GET nC2 Picture "99.9" VALID nC2 >0 SIZE 17,10 
       @ 60,135 CHECKBOX OemToAnsi("Grava Classificacao ABC") VAR lGrvABC Object oChk5
       oChk5:oFont := oDlg:oFont

       @ 076,015 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi("Tipos de Material") SIZE 75,50 ON DBLCLICK (aTipo:=EST01392(oQual:nAt,aTipo),oQual:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual,oOk,oNo,@aTipo) NOSCROLL OF oDlg PIXEL
       oQual:SetArray(aTipo)
       oQual:bLine := { || {if(aTipo[oQual:nAt,1],oOk,oNo),aTipo[oQual:nAt,2]}}
       @ 127,015 CHECKBOX OemToAnsi("Inverter Selecao") VAR lQual3  Object oChkQual 
       oChkQual:BlClicked := { || AEval(aTipo , {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.) }
       DEFINE SBUTTON FROM 140,240 TYPE 1 ACTION IIF(EST01391(nA2,nB2,nC2),(nOpca:=1,oDlg:End()),Help(" ",1,"A290PERC")) ENABLE OF oDlg
       DEFINE SBUTTON FROM 140,270 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
       oChk2:BlClicked :=	{|| oChk2:Refresh()}
       ACTIVATE MSDIALOG oDlg CENTERED
       For i := 1 to Len(aTipo)
         If aTipo[i,1] 
            qtdmarca := (qtdmarca +1)
         Endif
       Next
       If nOpca == 1
          If (qtdmarca) > 0
             cConTP := ""
             For i := 1 to Len(aTipo)
                 //If aTipo[i,1]
                    If (qtdmarca) == 1
                       If aTipo[i,1]
                           cConTP := cConTP + "'"+SubStr(aTipo[i,2],1,2)+"'"
                       Endif 
                    Else
                        If aTipo[i,1]   
                           j:= (j+1)
                           If j == qtdmarca
                              cConTP := cConTP + "'"+SubStr(aTipo[i,2],1,2)+"'"
                           Else
                              cConTP := cConTP + "'"+SubStr(aTipo[i,2],1,2)+"',"
                           Endif
                        Endif
                    Endif
                 //Endif
             Next
             Processa({|| EST0137(nA1,nB1,nC1,nA2,nB2,nC2,lGrvABC,cConTP,nMes,nEnt,lLote,lPedido) },"Classifica็ใo")
          Else
             MSGBOX("Deve ser selecionado algum Tipo de Material","Aten็ใo","STOP")
             Return()
          Endif
          MSGBOX("Final do Processamento !!!","Informa็ใo","INFO")
       Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funo    ณ EST01392                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Autor     ณ                                          ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descrio ณ Troca marcador entre x e branco                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ  Uso      ณ SigaEST - Advanced                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EST01392(nIt,aArray)
       aArray[nIt,1] := !aArray[nIt,1]
       //aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ EST01391    ณ Autor ณ                     ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณFuncao que valida os percentuais do Calculo ABC              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EST01391(nA2,nB2,nC2)
       lRet:=.T.
       If nA2+nB2+nC2 != 100
          lRet:=.F.
       EndIf
Return lRet

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ EST0137     ณ Autor ณ Luis Gustavo        ณ Data ณ 26/11/02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณFuncao que calcula e grava Lote Economico e Classe ABC       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EST0137(nMesA,nMesB,nMesC,nPerA,nPerB,nPerC,lGrvABC,cTipo,nMes,nEnt,lLote,lPedido)
       Local cQry6  := ""
       Local aTotTp := {}
       Local nTotA  := 0
       Local nTotB  := 0
       Local nTotC  := 0
       Local i
       
       cQry6  := ""
       cQry6 := cQry6 + "SELECT B1.B1_TIPO AS TIPO, SUM(ZZ2.ZZ2_TOTAL) AS TOTAL "
       cQry6 := cQry6 + "FROM "+RetSqlName("ZZ2")+" ZZ2 WITH (NOLOCK) "
       cQry6 := cQry6 + "INNER JOIN "+RetSqlName("SB1")+" B1 WITH (NOLOCK) ON B1.B1_FILIAL = ZZ2.ZZ2_FILIAL AND B1.B1_COD = ZZ2.ZZ2_COD "
       cQry6 := cQry6 + "WHERE ZZ2.ZZ2_FILIAL = '"+xFilial("ZZ2")+"' "
       cQry6 := cQry6 + "  AND ZZ2.D_E_L_E_T_ = '' "
       cQry6 := cQry6 + "  AND  B1.D_E_L_E_T_ = '' "
       cQry6 := cQry6 + "  AND B1.B1_TIPO IN("+cTipo+") "
       cQry6 := cQry6 + "  AND ((B1.B1_TIPO ='PA' AND B1_ESTOQUE ='S') OR (B1.B1_TIPO <>'PA' AND B1_ESTOQUE IN('','S','N'))) "
       cQry6 := cQry6 + "GROUP BY B1.B1_TIPO "
       
       TCQUERY cQry6 NEW ALIAS "TMPSB3"
       
       DbSelectArea("TMPSB3")
       DbGoTop()
       While !Eof()
             aadd(aTotTp,{TMPSB3->TIPO,TMPSB3->TOTAL} )
             DbSkip()
       Enddo
       //DbCloseArea("TMPSB3")
       DbSelectArea("TMPSB3")
       DbCloseArea()
       For i := 1 to Len(aTotTp)
           nTotA := nPerA * aTotTp[i,2] / 100
           nTotB := nPerB * aTotTp[i,2] / 100 + nTotA
           nTotC := nPerC * aTotTp[i,2] / 100 + nTotB
           cQry6  := ""
           cQry6 := cQry6 + "SELECT ZZ2.ZZ2_COD AS CODIGO, B1.B1_TIPO AS TIPO, ZZ2.ZZ2_MEDIA AS MEDIA, B1.B1_QE AS EMBALAGEM, "
           cQry6 := cQry6 + "ZZ2.ZZ2_TOTAL AS TOTAL, 0 AS LOTE, '' AS CLASSE "
           cQry6 := cQry6 + "FROM "+RetSqlName("ZZ2")+" ZZ2 WITH (NOLOCK) "
           cQry6 := cQry6 + "INNER JOIN "+RetSqlName("SB1")+" B1 WITH (NOLOCK) ON B1.B1_FILIAL = ZZ2.ZZ2_FILIAL AND B1.B1_COD = ZZ2.ZZ2_COD "
           cQry6 := cQry6 + "WHERE ZZ2.ZZ2_FILIAL = '"+xFilial("ZZ2")+"' "
           cQry6 := cQry6 + "  AND ZZ2.D_E_L_E_T_ = '' "
           cQry6 := cQry6 + "  AND B1.B1_TIPO IN('"+aTotTp[i,1]+"') "
           cQry6 := cQry6 + "  AND ((B1.B1_TIPO ='PA' AND B1_ESTOQUE ='S') OR (B1.B1_TIPO <>'PA' AND B1_ESTOQUE IN('','S','N'))) "
           cQry6 := cQry6 + "ORDER BY ZZ2.ZZ2_TOTAL DESC"
           
           TCQUERY cQry6 NEW ALIAS "TMPSB3"

           DbSelectArea("TMPSB3")
           DbGoTop()
           nTotCon := 0
           nLote   := 0
           cClasse := ""
           ProcRegua(500 * Len(aTotTp))
           While !Eof()
                 IncProc("Processando...")
                 Do Case
                    Case nTotCon < nTotA
                         nLote   := TMPSB3->MEDIA * nMesA
                         cClasse := "A"
                    Case nTotCon < nTotB
                         nLote   := TMPSB3->MEDIA * nMesB
                         cClasse := "B"
                    OtherWise
                         nLote   := TMPSB3->MEDIA * nMesC
                         cClasse := "C"
                 EndCase
                 DbSelectArea("SB1")
                 DbSetOrder(1)
                 DbSeek(xFilial("SB1")+TMPSB3->CODIGO,.T.)
                 If Found() .and. SB1->B1_MRP == 'S'
                    RecLock("SB1",.f.)
                       IF lLote
                          SB1->B1_LE   := Iif(nLote < SB1->B1_QE, SB1->B1_QE, Round(nLote / Iif(SB1->B1_QE == 0,1,SB1->B1_QE),0) * Iif(SB1->B1_QE == 0,1,SB1->B1_QE) )
                       Endif
                       IF lPedido
                          SB1->B1_EMIN := (TMPSB3->MEDIA * (Iif(SB1->B1_LOCENT $ '1',(SB1->B1_PE + nEnt), SB1->B1_PE) / nMes))
                       Endif
                    MsUnLock()
                 Endif
                 DbSelectArea("ZZ2")
                 DbSetOrder(1)
                 DbSeek(xFilial("ZZ2")+TMPSB3->CODIGO,.T.)
                 If Found()
                    RecLock("ZZ2",.f.)
                       IF lGrvABC
                          ZZ2->ZZ2_CLASSE := cClasse
                          ZZ2->ZZ2_DT_ABC := DATE()
                       Endif
                    MsUnLock()
                 Endif
                 nTotCon := nTotCon + TMPSB3->TOTAL
                 DbSelectArea("TMPSB3")
                 DbSkip()
           Enddo
           //DbCloseArea("TMPSB3")
           DbSelectArea("TMPSB3")
           DbCloseArea()
       Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG4 บ Autor ณ AP5 IDE            บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg4()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg4 := PADR(cPerg4,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg4,"01","Do produto          ","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg4,"02","Ate o produto       ","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1",""})
       aAdd(aRegs,{cPerg4,"03","Do local            ","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg4,"04","Ate o local         ","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","99",""})
       aAdd(aRegs,{cPerg4,"05","Do tipo             ","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg4,"06","Ate o tipo          ","","","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","02",""})
       aAdd(aRegs,{cPerg4,"07","Do grupo            ","","","mv_ch7","C",04,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg4,"08","Ate o grupo         ","","","mv_ch8","C",04,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SBM",""})
       aAdd(aRegs,{cPerg4,"09","Tipo da Consulta    ","","","mv_ch9","N",01,0,0,"C","","mv_par09","Todos os Itens","","","","","Pto. Pedido","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg4,"10","Prod. s/ Pto. Pedido","","","mv_cha","N",01,0,0,"C","","mv_par10","Lista","","","","","Nใo Lista","","","","","","","","","","","","","","","","","","","",""})
       aAdd(aRegs,{cPerg4,"11","Ordem               ","","","mv_chb","N",01,0,0,"C","","mv_par11","Produto","","","","","Classe","","","","","Valor Compra","","","","","","","","","","","","","","",""})       
       aAdd(aRegs,{cPerg4,"12","Impressao           ","","","mv_chc","N",01,0,0,"C","","mv_par12","Somente Pto.Ped.","","","","","Tudo","","","","","Cadastro","","","","","","","","","","","","","","",""})       
       aAdd(aRegs,{cPerg4,"13","Filtra Ativos      ?","","","mv_chd","N",01,0,0,"C","","mv_par13","Sim"             ,"","","","","Nao"    ,"","","","","","","","","","","","","","","","","","","",""})
       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg4+aRegs[i,2])
              RecLock("SX1",.T.)
              For j:=1 to FCount()
                  If j <= Len(aRegs[i])
                     FieldPut(j,aRegs[i,j])
                 Endif
              Next
              MsUnlock()
           Endif
       Next
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST013A1  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para finalizacao da consulta.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST013A1()
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao da consulta...                                  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       If !lTelaJaFechada2
          Close(oDlg2)
       Endif
       lJaFech2 := .t.
       //lRet := ChkFile("CCONS2")
       If Select("CCONS2")<>0
          DbSelectArea("CCONS2")
          DbCloseArea()
          ocCons2:Delete()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST013B  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para alteracao dos paramentros da consulta.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST013B()
       lPerg := Pergunte(cPerg4,.T.)
       If lPerg
          DbSelectArea("CCONS2")
          DbSetOrder(1)
          DbCloseArea()
          ocCons2:Delete()
          Close(oDlg2)
          lLocal := .f.
          EST013A()
       Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST013C  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para impressao da consulta.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST013C()
       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
       //? Define Variaveis                                             ?
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       LOCAL CbCont, cabec12, cabec22, wnrel
       LOCAL tamanho    := "G"
       //LOCAL limite     := 220
       LOCAL titulo2    := OemtoAnsi( "Relatorio de Itens em Ponto de Pedido" )
       LOCAL cDesc1     := OemtoAnsi( "Este programa tem como objetivo imprimir relatorio " )
       LOCAL cDesc2     := OemtoAnsi( "de acordo com os parametros informados pelo usuario.")
       LOCAL cDesc3     := OemtoAnsi( "Relatorio de Classifica็ใo de Produtos" )
       LOCAL aOrd       := {}
       PRIVATE aReturn  := { OemtoAnsi("Zebrado"), 1, OemtoAnsi("Administracao"), 1, 2,  , , 1 }  //"Zebrado"###"Administracao"
       PRIVATE nomeprog := "EST013C"
       PRIVATE nLastKey := 0


       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Declaracao de Variaveis                                             ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       //Private cString
       //Private CbTxt       := ""
       //Private cPict       := ""
       //Private lEnd        := .F.
       Private lAbortPrint := .F.
       //Private nomeprog    :=  
       Private nTipo       := 15
       
       Private cPerg4      := "EST134"
       Private nLin        := 80
       If mv_par12 == 1
          //Private Cabec12     := "                                                                                                                                                                 CUSTO        |"
          //Private Cabec22     := "    CODIGO      DESCRICAO                      TP UM      ATUAL         EMPENHADO      DISPONIVEL     MEDIA CONSUMO  P. PEDIDO       S. COMPRA       U. PRECO  REPOSIวรO    C | PEDIDO  DATA "
                                //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
                                //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                                //                                                                                                                                                                                     CUSTO                               
                                //    CODIGO      DESCRICAO                      TP UM      ATUAL         EMPENHADO      DISPONIVEL     MEDIA CONSUMO  PONTO DE PEDIDO LOTE ECONOMICO  U. PRECO  REPOSIวรO    | PREV. ENTRADA
                                //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX XX 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 9,999.99 9,999,999.99  | 99,999,999.99
                                //    CODIGO      DESCRICAO                      TP UM PONTO DE PEDIDO 
                                //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX XX 99,999,999.9999
          Cabec12     := "                                                                                                                                                                 CUSTO        |"
          Cabec22     := "    CODIGO      DESCRICAO                      TP UM      ATUAL         EMPENHADO      DISPONIVEL     MEDIA CONSUMO  P. PEDIDO       S. COMPRA       U. PRECO  REPOSIวรO    C | PEDIDO  DATA " 
       ElseIf mv_par12 == 2
          //Private Cabec12     := "                                                                                                                                                                                     CUSTO                     "
          //Private Cabec22     := "    CODIGO      DESCRICAO                      TP UM      ATUAL         EMPENHADO      DISPONIVEL     MEDIA CONSUMO  PONTO DE PEDIDO LOTE ECONOMICO  C   ENTREGA         U. PRECO  REPOSIวรO    | PREV. ENTRADA"
          Cabec12     := "                                                                                                                                                                                     CUSTO                     "
          Cabec22     := "    CODIGO      DESCRICAO                      TP UM      ATUAL         EMPENHADO      DISPONIVEL     MEDIA CONSUMO  PONTO DE PEDIDO LOTE ECONOMICO  C   ENTREGA         U. PRECO  REPOSIวรO    | PREV. ENTRADA"
       Else
          //Private Cabec22     := ""
          //Private Cabec12     := "    CODIGO      DESCRICAO                      TP UM      PONTO DE PEDIDO "
          Cabec22     := ""
          Cabec12     := "    CODIGO      DESCRICAO                      TP UM      PONTO DE PEDIDO "
       Endif
       Private cbtxt       := Space(10)
       Private CONTFL      := 01
       Private m_pag       := 01
       Private imprime     := .T.
       wnrel       := "EST013C"
       Private cString     := "CCONS2"
       Private nLin2       := 80

       cbcont := 0
       //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15
       //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
       //    CODIGO      DESCRICAO                      TP UM      ATUAL         EMPENHADO      DISPONIVEL    PONTO DE PEDIDO LOTE ECONOMICO  C ENTREGA
       //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX XX 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 X      99
       //123456789012345 123456789012345678901234567890 12

       dbSelectArea("CCONS2")

       pergunte(cPerg4,.F.)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Monta a interface padrao com o usuario...                           ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       wnrel    := "EST013C"
       wnrel := SetPrint(cString,wnrel,cPerg4, @titulo2, cDesc1, cDesc2, cDesc3, .F.,aOrd,.T.,Tamanho,,.T.)

       If nLastKey == 27
          Return
       Endif

       SetDefault(aReturn,cString)
     
       If nLastKey == 27
          Return
       Endif

       //nTipo := If(aReturn[4]==1,15,18)

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Processamento. PROCESSA monta janela com a regua de processamento.  ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
       //msgbox('Op็ใo em Desenvolvimento','Atencao','STOP')
       Processa( { || EST013C1( Cabec12, Cabec22, Titulo2, nLin2, tamanho, nTipo, wnrel ) }, Titulo2 )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST013C1 บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para impressao da consulta.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EST013C1( Cabec12, Cabec22, Titulo2, nLin2, tamanho, nTipo, wnrel )
       DbSelectArea("CCONS2")
       DbGoTop()
       ProcRegua(RecCount())
       While !Eof()
             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Verifica o cancelamento pelo usuario...                             ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

             If lAbortPrint
                @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif
             //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
             //ณ Impressao do cabecalho do relatorio. . .                            ณ
             //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

             If nLin2 > 55 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
                Cabec( Titulo2, Cabec12, Cabec22, NomeProg, Tamanho, nTipo )
                nLin2 := 9
             Endif
             
             //0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22
             //01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
             //                                                                                                                                                                                     CUSTO                               
             //    CODIGO      DESCRICAO                      TP UM      ATUAL         EMPENHADO      DISPONIVEL     MEDIA CONSUMO  PONTO DE PEDIDO LOTE ECONOMICO  C   ENTREGA         U. PRECO  REPOSIวรO    | PREV. ENTRADA
             //999999999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX XX 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 99,999,999.9999 X XX + XX = XX DIAS 9,999.99 9,999,999.99  | 99,999,999.99
             If mv_par12 == 1
                @ nLin2, 000 PSAY CCONS2->CODIGO                 Picture "@R XXX99.99.999-99"
                @ nLin2, 016 PSAY Substr(CCONS2->DESCRICAO,1,30) Picture "@!"
                @ nLin2, 047 PSAY CCONS2->TIPO                   Picture "@!"
                @ nLin2, 050 PSAY CCONS2->UNIDADE                Picture "@!"
                @ nLin2, 054 PSAY CCONS2->ATUAL                  Picture "@E 99,999,999.9999"
                @ nLin2, 069 PSAY CCONS2->EMPENHO                Picture "@E 99,999,999.9999"
                @ nLin2, 085 PSAY CCONS2->DISPONIVEL             Picture "@E 99,999,999.9999"
                @ nLin2, 101 PSAY CCONS2->MEDIA                  Picture "@E 99,999,999.9999"
                @ nLin2, 117 PSAY CCONS2->PEDIDO                 Picture "@E 99,999,999.9999"
                @ nLin2, 133 PSAY (CCONS2->MEDIA - CCONS2->DISPONIVEL)              Picture "@E 99,999,999.9999"
                @ nLin2, 149 PSAY CCONS2->PRECO                  Picture "@E 999,999,999.99"
                @ nLin2, 159 PSAY CCONS2->VALTOT   Picture "@E 9,999,999.99"
                @ nLin2, 172 PSAY CCONS2->CLASSE   Picture "@!"
                @ nLin2, 174 PSAY "|"
                @ nLin2, 176 PSAY CCONS2->NUMPED
             ElseIf mv_par12 == 2
                @ nLin2, 000 PSAY CCONS2->CODIGO                 Picture "@R XXX99.99.999-99"
                @ nLin2, 016 PSAY Substr(CCONS2->DESCRICAO,1,30) Picture "@!"
                @ nLin2, 047 PSAY CCONS2->TIPO                   Picture "@!"
                @ nLin2, 050 PSAY CCONS2->UNIDADE                Picture "@!"
                @ nLin2, 054 PSAY CCONS2->ATUAL                  Picture "@E 99,999,999.9999"
                @ nLin2, 069 PSAY CCONS2->EMPENHO                Picture "@E 99,999,999.9999"
                @ nLin2, 085 PSAY CCONS2->DISPONIVEL             Picture "@E 99,999,999.9999"
                @ nLin2, 101 PSAY CCONS2->MEDIA                  Picture "@E 99,999,999.9999"
                @ nLin2, 117 PSAY CCONS2->PEDIDO                 Picture "@E 99,999,999.9999"
                @ nLin2, 133 PSAY CCONS2->LOTE                   Picture "@E 99,999,999.9999"
                @ nLin2, 149 PSAY CCONS2->CLASSE                 Picture "@!"
                @ nLin2, 151 PSAY CCONS2->ENTREGA                Picture "@!"
                @ nLin2, 169 PSAY CCONS2->PRECO                  Picture "@E 999,999,999.99"
                @ nLin2, 178 PSAY CCONS2->LOTE * CCONS2->PRECO   Picture "@E 999,999,999.99"
                @ nLin2, 192 PSAY "|"
                @ nLin2, 195 PSAY CCONS2->PREVISTO               Picture "@E 99,999,999.99"
             Else
                @ nLin2, 000 PSAY CCONS2->CODIGO                 Picture "@R XXX99.99.999-99"
                @ nLin2, 016 PSAY Substr(CCONS2->DESCRICAO,1,30) Picture "@!"
                @ nLin2, 047 PSAY CCONS2->TIPO                   Picture "@!"
                @ nLin2, 050 PSAY CCONS2->UNIDADE                Picture "@!"
                @ nLin2, 053 PSAY CCONS2->PEDIDO                 Picture "@E 99,999,999.9999"                
             Endif
             //@ nLin2, 195 PSAY CCONS2->PROJECAO               Picture "@E 99,999,999.99"
             //@ nLin2, 209 PSAY IIF(CCONS2->ATUAL      <= CCONS2->PEDIDO,"SIM","NAO")
             //@ nLin2, 214 PSAY IIF(CCONS2->DISPONIVEL <= CCONS2->PEDIDO,"SIM","NAO")
             
             nLin2 := nLin2 + 1
             DbSelectArea("CCONS2")
             DbSkip()
       Enddo

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Finaliza a execucao do relatorio...                                 ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       SET DEVICE TO SCREEN

       //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
       //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
       //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()

       DbSelectArea("CCONS2")
       DbGoTop()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ EST0136  บ Autor ณ Luis Gustavo       บ Data ณ  17/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao para grafico da consulta.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/*
Static Function EST0136()
       Local aDados := {}
       Local i
       For i := 1 To Len(aMeses)
           AADD(aDados, { aMesesE[Val(SubStr(aMeses[i],1,2))]  ,CCONS->&("MES"+SubStr(aMeses[i],1,2)) } )
       Next
       //Chama funcao generica para montagem de grafico
       MatGraph("Consumo Mensal",.F.,.T.,.T.,1,6,aDados)
Return
*/
