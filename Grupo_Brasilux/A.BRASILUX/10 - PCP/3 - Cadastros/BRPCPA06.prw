#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRPCPA06 º Autor ³ Luís G. de Souza   º Data ³  12/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Padrões de cores                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRPCPA06()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Private cVldAlt   := ".T."          // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
     Private cVldExc   := "u_PCPA06_D()" // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
     Private cDelFunc  := "u_PCPA06_D()" // Validacao para a exclusao. Pode-se utilizar ExecBlock
     Private cCadastro := "Cadastro de Padrão de Cores"
     Private cString := "ZZE"
     Private aRotina := { {"Pesquisar" 	   ,"AxPesqui"  , 0, 1},;
                          {"Visualizar"	   ,"AxVisual"  , 0, 2},;
                          {"Incluir"   	   ,"AxInclui"  , 0, 3},;
                          {"Alterar"   	   ,"AxAltera"  , 0, 4},;
                          {"Excluir"       ,"AxDeleta"  , 0, 5},;
                          {"Vencidos"      ,"u_PCPA06_2", 0, 6},;
                          {"Log Alteração" ,"u_PCPA06_3", 0, 7}  }

     Private oTempTable
     DbSelectArea("ZZE")
     DbSetOrder(1)

     DbSelectArea(cString)
     mBrowse( 6, 1, 22, 75, cString)

     //AxCadastro(cString, "Cadastro de Padrão de Cor", cVldExc, cVldAlt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA06_D ºAutor  ³ Luís G. de Souza   º Data ³  19/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação da deleção do padrão de cor.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ PCPA06_D()                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1 -> .T. -> Deleta / .F. -> Nao Deleta                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA06_D()
       Local lRet := .f.
       SZ3->(DbSetOrder(3))
       If SZ3->(MsSeek(xFilial('SZ3')+ZZE->ZZE_PADRAO, .F.))
          Help(' ', 1, 'PCPA06_D')
       Else
          lRet := .T.
       Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PCPA06_1 ºAutor  ³ Luís G. de Souza   º Data ³  12/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para validação do padrão de cor liberado, no cadas-º±±
±±º          ³ tro de variação de cor.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PCPA06_1()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Local cPadCor := Space(06)

     If ZZE->ZZE_LIBERA $ 'S'
        cPadCor := ZZE->ZZE_PADRAO
     Else
        MsgAlert('Atenção, padrão de cor não liberado!')
     Endif
Return(cPadCor)

User Function PCPA06_2()
     Private dGet1PAD   := Ctod("  /  /  ")
     Private lValMesD   := .t.
     Private nLigaMes   := 1
     Private cSay4PAD   := ""

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFon1PAD   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oFon2PAD   := TFont():New( "MS Sans Serif", 0, -16, , .T., 0, , 700, .F., .F., , , , , , )
     oDlg1PAD   := MSDialog():New( 095, 232, 545, 915, "Validade do Padrão de Cor", , , .F., , , , , , .T., , , .T. )

     oGrp1PAD   := TGroup():New( 004, 004, 032, 340, "Filtro", oDlg1PAD, CLR_RED, CLR_WHITE, .T., .F. )
     oSay1PAD   := TSay():New( 015, 008, { || "Vencimento:"}                             , oGrp1PAD, , oFon1PAD, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008)
     oGet1PAD   := TGet():New( 013, 070, { |u| If(PCount() > 0, dGet1PAD := u, dGet1PAD)}, oGrp1PAD, 060, 012, '', , CLR_BLUE , CLR_WHITE, oFon2PAD, , , .T., "", , , .F., .F., , .F., .F., "", "dGet1PAD", , )

     oBtn2PAD   := TButton():New( 015, 300, "Novo Filtro", oGrp1PAD, { || fNovoFiltro() }, 037, 012, , , , .T., , "", , , , .F. )

     oTbl1PAD()
     DbSelectArea("TMP")
     DbSetOrder(1)

     oBrw1PAD   := MsSelect():New( "TMP", "", "", { {"TMP_CPAD", "", "Cod. Padrão", ""}, {"TMP_DPAD", "", "Descrição", ""}, {"TMP_VPAD", "", "Validade", ""}, {"TMP_PCOR", "", "Cor", ""}, {"TMP_VARI", "", "Variação", ""}, {"TMP_DVAR", "", "Desc. Varic.", ""} }, .F., , {036, 004, 204, 340}, , , oDlg1PAD )
     oBtn1PAD   := TButton():New( 208, 302, "Sair", oDlg1PAD, { || oDlg1PAD:End() }, 037, 012, , , , .T., , "", , , , .F. )
     oBtn3PAD   := TButton():New( 208, 230, "Impressão", oDlg1PAD, { || fImpPADVen() }, 037, 012, , , , .T., , "", , , , .F. )
     oGet1PAD:bLostFocus := { || fValDatPAD(nLigaMes) }
     oBtn2PAD:lVisible := .f.
     oBtn3PAD:lVisible := .f.
     oGet1PAD:SetFocus()
     oDlg1PAD:Activate(, , , .T.)
     DbSelectArea("TMP")
     DbCloseArea()
     oTempTable:Delete()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ fValDatPAD() - Valida Mes Inicio para PADRÃO DE COR
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function fValDatPAD(nLigaMes)
       If nLigaMes == 1
          lValMesD := .t.
          If dGet1PAD < dDataBase
             MsgStop("Data informada não pode ser menor que a data base do sistema.", "Atenção...")
             dGet1PAD := CTOD('  /  /  ')
             oGet1PAD:SetFocus()
             lValMesD := .f.
             Return
          Else
             //Faz a busca dos dados
             nLigaMes := 0
             oBtn2PAD:lVisible := .t.
             oBtn3PAD:lVisible := .t.
             MsgRun(OemToAnsi('Buscando informações para consulta...... Aguarde....'), '', {|| CursorWait(), fBuscaVEN(), CursorArrow() } )
          Endif
       Endif
Return

Static Function fNovoFiltro()
       dGet1PAD := CTOD('  /  /  ')
       oGet1PAD:Refresh()
       oGet1PAD:SetFocus()
       oBtn2PAD:lVisible := .f.
       oBtn3PAD:lVisible := .f.
       DbSelectArea("TMP")
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       //Zap
       TCSqlExec("DELETE FROM " + oTempTable:GetRealName() )

       oBrw1PAD:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ oTbl1PAD() - Cria temporario para o Alias: TMP
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function oTbl1PAD()
       Local aFds := {}
       //Local cTmp

       Aadd( aFds , {"TMP_CPAD", "C", 006, 000} )
       Aadd( aFds , {"TMP_DPAD", "C", 025, 000} )
       Aadd( aFds , {"TMP_VPAD", "D", 008, 000} )
       Aadd( aFds , {"TMP_PCOR", "C", 005, 000} )
	   Aadd( aFds , {"TMP_VARI", "C", 006, 000} )
       Aadd( aFds , {"TMP_DVAR", "C", 030, 000} )

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 03/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cTmp := CriaTrab( aFds, .T. )
       //Use (cTmp) Alias TMP New Exclusive
       //Index On TMP_VPAD To (cTmp)
       oTempTable := FWTemporaryTable():New( "TMP" )
       oTempTable:SetFields( aFds )
       oTempTable:Create()
       /********************************************************************************************************************************/
Return

Static Function fBuscaVEN()
       Local cQry1 := ""

       DbSelectArea("TMP")
       //LGS#20200211 - Adequação de release 12.1.25 e posteriores
       //Zap
       TCSqlExec("DELETE FROM " + oTempTable:GetRealName() )
       cQry1 := "SELECT ZZE.* ,SZ3.Z3_COR, SZ3.Z3_PADCOR, SZ3.Z3_DESCR, SZ3.Z3_VARIAC  "
       cQry1 += "FROM "+RetSqlName("ZZE")+" ZZE WITH (NOLOCK) "
	   cQry1 += "LEFT OUTER JOIN "+RetSqlName("SZ3")+" SZ3 WITH (NOLOCK) ON (SZ3.D_E_L_E_T_ ='') AND (Z3_FILIAL = '"+xFilial("SZ3")+"') AND (ZZE.ZZE_PADRAO = SZ3.Z3_PADCOR)   "
       cQry1 += "WHERE (ZZE.D_E_L_E_T_ = '') AND (ZZE_FILIAL = '"+xFilial("ZZE")+"') "
       cQry1 += "AND (ZZE.ZZE_DTVALI <= '"+dTOS(dGet1PAD)+"') "
       cQry1 += "AND (ZZE.ZZE_DTVALI <> '') "
       cQry1 += "ORDER BY ZZE_DTVALI "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbGoTop()
       While !Eof()
             RecLock("TMP", .t.)
                TMP->TMP_CPAD := SUBSTR(TCQ->ZZE_PADRAO,1,9)
                TMP->TMP_DPAD := SUBSTR(TCQ->ZZE_DESCRI,1,25)
                TMP->TMP_VPAD := STOD(TCQ->ZZE_DTVALI)
                TMP->TMP_PCOR := TCQ->Z3_COR
                TMP->TMP_VARI := TCQ->Z3_VARIAC
                TMP->TMP_DVAR := SUBSTR(TCQ->Z3_DESCR,1,30)
             MsUnLock()
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       DbSelectArea("TMP")
       DbGoTop()
       oBrw1PAD:oBrowse:Refresh()
Return

Static Function fImpPADVen()
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Declaracao de Variaveis                                             ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
       Local cDesc2        := "de acordo com os parametros informados pelo usuario."
       Local cDesc3        := "Padrão de Cores x Vencimento"
       //Local cPict         := ""
       Local titulo        := "Padrão de Cores x Vencimento"
       Local nLin          := 80
       Local Cabec1        := "PADRÃO   DESCRIÇÃO                COR    VARIAÇÃO                     VALIDADE"
       Local Cabec2        := ""
       //Local imprime       := .T.
       Local aOrd          := {}
       Private lEnd        := .F.
       Private lAbortPrint := .F.
       //Private CbTxt       := ""
       Private limite      := 80
       Private tamanho     := "P"
       Private nomeprog    := "BRPCPA06" // Coloque aqui o nome do programa para impressao no cabecalho
       Private nTipo       := 18
       Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
       Private nLastKey    := 0
       Private cbtxt       := Space(10)
       Private cbcont      := 00
       Private CONTFL      := 01
       Private m_pag       := 01
       Private wnrel       := "PADCOR" // Coloque aqui o nome do arquivo usado para impressao em disco
       Private cString     := "TMP"

       DbSelectArea("TMP")
       DbSetOrder(1)
       DbGoTop()

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta a interface padrao com o usuario...                           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       wnrel := SetPrint(cString, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho, , .F.)

       If nLastKey == 27
          Return
       Endif

       SetDefault(aReturn, cString)

       If nLastKey == 27
          Return
       Endif

       nTipo := If(aReturn[4] == 1, 15, 18)

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Processa({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
       //Local nOrdem

       DbSelectArea(cString)
       dbSetOrder(1)
       DbGoTop()

       ProcRegua(RecCount())

       While !EOF()
             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Verifica o cancelamento pelo usuario...                             ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

             If lAbortPrint
                @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
                Exit
             Endif

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³ Impressao do cabecalho do relatorio. . .                            ³
             //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

             If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
                nLin := Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
                nLin += 1
             Endif
             //PADRÃO  DESCRIÇÃO                       VALIDADE
             //999999  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  99/99/9999
             //012345678901234567890123456789012345678901234567890
             //0         1         2         3         4         5
             @nLin,000 PSAY TMP->TMP_CPAD
             @nLin,008 PSAY SUBSTR(TMP->TMP_DPAD,1,25)
             @nLin,034 PSAY SUBSTR(TMP->TMP_PCOR,1,4)
             @nLin,040 PSAY SUBSTR(TMP->TMP_VARI,1,5) 
             @nLin,047 PSAY SUBSTR(TMP->TMP_DVAR,1,30) 
             @nLin,073 PSAY DTOC(TMP->TMP_VPAD)
             nLin := nLin + 1 // Avanca a linha de impressao
             DbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Finaliza a execucao do relatorio...                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       SET DEVICE TO SCREEN

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Se impressao em disco, chama o gerenciador de impressao...          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

       If aReturn[5]==1
          dbCommitAll()
          SET PRINTER TO
          OurSpool(wnrel)
       Endif

       MS_FLUSH()
       DbSelectArea("TMP")
       DbSetOrder(1)
       DbGoTop()
Return                                    

	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Relatorio de log                                                    ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
       
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function PCPA06_3()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE CbTxt
PRIVATE Titulo := "Log de alteração padrão de cor"
PRIVATE cDesc1:=""
PRIVATE cDesc2:=""
PRIVATE cDesc3 := "" 
                   //   0          1           2         3         4         5         6       7          8        9        10         11        12       13        14         15         16
                   //012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
PRIVATE cCabec1  := ""
PRIVATE cCabec2  := ""  
private nTipo := 18
PRIVATE Tamanho:= "P"
PRIVATE Limite := 80
PRIVATE cString:= "SA1"
private m_pag    := 01
PRIVATE CbCont,cabec1,cabec2,wnrel
PRIVATE aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
PRIVATE nomeprog:= "PCPA06_3"
PRIVATE aLinha  := { },nLastKey := 0
PRIVATE cPerg   := "PCPA06_3"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:= "PCPA06_3"            //Nome Default do relatorio em Disco

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
//wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho)

If nLastKey==27
	dbClearFilter()
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	dbClearFilter()
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento do Relatorio                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RptDetail()})

return

/////////////////////////////////////////////////////////
// Funçào....: RPTDETAIL    Data....: 08/06/15         //
// Autor.....: Marcelo J. A. de Paiva                  //
/////////////////////////////////////////////////////////

Static Function RptDetail()
//Local nTotal := 0
//Local 	_nCont := 0
//Local lNormal
Private _nLin := 7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA('ZZE')
cQuery :=""
cQuery +="SELECT ZZE_RESPON, ZZE_DESCRI, CASE WHEN ZZE_LIBERA = 'S' THEN 'SIM' ELSE 'NÃO' END AS 'LIBERADO', ZZE_DATALI, ZZE_DTVALI,ZZE_CLIENT, ZZE_JUSTIF, ZZE_DTALT "
cQuery +="FROM ZZE010LOG "
cQuery +="WHERE R_E_C_N_O_ = "+ALLTRIM(STR(RECNO()))+" "
cQuery +="ORDER BY ZZE_DTALT DESC"
                                                                            
TCQUERY cQuery ALIAS "TCQ" NEW
dbselectarea("TCQ")

SetRegua(RECCOUNT()) 
Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)
_nLin := 6
While !Eof()
	if _nLin > 55
		@ _nLin,000 psay replicate("_",80)
		Cabec(titulo,cCabec1,cCabec2,nomeprog,tamanho,nTipo)			
		_nLin := 6
	endif
	@ _nLin,000 psay "Responsavel: "+SUBSTR(TCQ->ZZE_RESPON,0,30)
  	@ _nLin,045 psay "Produto: "+SUBSTR(TCQ->ZZE_DESCRI,0,30)  
  	@ _nLin++
	@ _nLin,000 psay "Liberado? "+TCQ->LIBERADO
	@ _nLin,016 psay "Cliente: "+ Posicione("SA1", 1, xFilial("SA1")+TCQ->ZZE_CLIENT, "A1_NOME")    
	@ _nLin++
	@ _nLin,000 psay "Data: "+substr(TCQ->ZZE_DATALI,5,2)+"/"+substr(TCQ->ZZE_DATALI,3,2)+"/"+substr(TCQ->ZZE_DATALI,1,4)
	@ _nLin,020 psay "Dt Valid: "+substr(TCQ->ZZE_DTVALI,5,2)+"/"+substr(TCQ->ZZE_DTVALI,3,2)+"/"+substr(TCQ->ZZE_DTVALI,1,4)
	@ _nLin,045 psay "Dt Alt: "+substr(TCQ->ZZE_DTALT,9,2)+"/"+substr(TCQ->ZZE_DTALT,6,2)+"/"+substr(TCQ->ZZE_DTALT,1,4)+" - "+substr(TCQ->ZZE_DTALT,12,2)+":"+substr(TCQ->ZZE_DTALT,15,2)+":"+substr(TCQ->ZZE_DTALT,18,2)
	@ _nLin++
	@ _nLin,000 psay "Justif: "+substr(TCQ->ZZE_JUSTIF,0,60)	
	@ _nLin++
	@ _nLin,000 psay substr(TCQ->ZZE_JUSTIF,61,70)	
	@ _nLin++ 
	@ _nLin,000 psay replicate("_",80)
	@ _nLin++ 
	dbselectarea("TCQ")	 
	dbskip() 
EndDo
	dbSelectArea("TCQ")
    dbCloseArea()  
    
    DBSELECTAREA('ZZE')
Set Device To Screen
If aReturn[5] == 1             	
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif
Return