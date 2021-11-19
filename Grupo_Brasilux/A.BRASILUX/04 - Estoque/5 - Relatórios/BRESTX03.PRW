//#INCLUDE "BRASILUX.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "MSOLE.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRESTX03 º Autor ³ Luís G. de Souza   º Data ³  21/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geração de Mapas de produtos químicos controlados pela Po- º±±
±±º          ³ lícia Federal.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasilux Tintas Técnicas Ltda.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRESTX03()
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Declaracao de Variaveis                                             ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

     Private cPerg       := "ESTX03"
     Private oGeraTxt

     Private cString := "SB1"
     u_zcfga01( 'BRESTX03' ) //LGS#2021118 - Gravação de log de utilização da rotina
     ValPerg1()
     Pergunte(cPerg, .f.)
     DbSelectArea("SB1")
     DbSetOrder(1)

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Montagem da tela de processamento.                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Gera‡„o do Arquivo de Mapas de Controles Químicos.")                     PIXEL
            @ 18,006 TO 076,287 LABEL ""                                                                                          OF oDlg PIXEL
            @ 29, 15 SAY OemToAnsi(" Este programa ira gerar um arquivo texto, conforme os parame- ")                        SIZE 268, 8 OF oDlg PIXEL
            @ 38, 15 SAY OemToAnsi(" tros definidos  pelo usuario,  com os registros mensais para  ")                        SIZE 268, 8 OF oDlg PIXEL
            @ 47, 15 SAY OemToAnsi(" produtos de controles químicos.                               ")                        SIZE 268, 8 OF oDlg PIXEL

            DEFINE SBUTTON FROM 90, 193 TYPE 01 ACTION ESTX03_1()                                                     ENABLE             OF oDlg
            DEFINE SBUTTON FROM 90, 223 TYPE 02 ACTION oDlg:End()                                                     ENABLE             OF oDlg
            DEFINE SBUTTON FROM 90, 253 TYPE 05 ACTION Pergunte(cPerg,.T.)                                            ENABLE             OF oDlg

     ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ ESTX03_1 º Autor ³ Luís G. de Souza   º Data ³  21/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao chamada pelo botao OK na tela inicial de processamenº±±
±±º          ³ to. Executa a geracao do arquivo texto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ESTX03_1()
       Private cCNPJ   := Iif(mv_par11 == 1, SM0->M0_CGC, TransForm(SM0->M0_CGC, "@R 99.999.999/9999-99"))
       Private cAnoF   := SubStr(mv_par01, 3, 4)
       Private cMesF   := Upper(SubStr(MesExtenso(Val(SubStr(mv_par01, 1, 2))), 1, 3))
       Private cPathTrm := Alltrim( GetMV( "MV_QPATHWT" ) ) //Diretório dos temporários       
       Private cTextoDA := Alltrim( "ANEXOXIA.DOT" )        //Nome dos arquivos modelo do Anexo XI A
       Private cTextoDB1:= Alltrim( "ANEXXIB1.DOT" )        //Nome dos arquivos modelo do Anexo XI B
       Private cTextoDB2:= Alltrim( "ANEXXIB2.DOT" )        //Nome dos arquivos modelo do Anexo XI B
       Private cTextoDB3:= Alltrim( "ANEXXIB3.DOT" )        //Nome dos arquivos modelo do Anexo XI B

       If mv_par11 == 1
          Private cArqTxt := "C:\MAPAS\M"+cAnoF+cMesF+cCNPJ+".TXT"
          Private nHdl    := fCreate(cArqTxt)
          Private cEOL    := "CHR(13)+CHR(10)"

          If Empty(cEOL)
             cEOL := CHR(13)+CHR(10)
          Else
             cEOL := Trim(cEOL)
             cEOL := &cEOL
          Endif

          If nHdl == -1
             MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
             Return
          Endif
       Else
          Private cPath    := Alltrim( "C:\MAPAS\" )           //Diretório dos DOCS
          Private cPathD   := Alltrim( GetMV( "MV_QPATHWD" ) )+'\' //Diretório dos modelos
          Private cTextoA  := " "
          Private cTextoB  := " "
          Private cEditor  := "TMsOleWord97"
          CpyS2T(cPathD+cTextoDA ,cPathTrm,.T.)
          CpyS2T(cPathD+cTextoDB1,cPathTrm,.T.)
          CpyS2T(cPathD+cTextoDB2,cPathTrm,.T.)
          CpyS2T(cPathD+cTextoDB3,cPathTrm,.T.)
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Inicializa a regua de processamento                                 ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Processa({|| ESTX03_2() },"Processando...")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ ESTX03_2 º Autor ³ Luís G. de Souza   º Data ³  21/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ESTX03_2
       Local nTamLin, cLin, cCpo
       Local nY, nX
       dbSelectArea(cString)
       dbGoTop()
       cRazao := SM0->M0_NOMECOM
       cCLF   := TransForm(GETMV("MV_MAPACLF"), "@R 99999999-9")
       cCNAE  := TransForm(SM0->M0_CNAE, "@R 9999-9/99")
       cGrp1  := "0"   ; cGrp2 := "0" ; cGrp3  := "1"
       cGrp4  := "0"   ; cGrp5 := "0" ; cGrp6  := "0"
       cGrp7  := "0"   ; cGrp8 := "0" ; cGrp9  := "0"
       cGrup  := "III" ; cDGrp := "Fabricação de Tintas, vernizes, esmaltes e lacas"
       cDes9  := space(50) ; cInfo  := space(200) ; cGrpP  := "GRUPO III"
       cResp  := mv_par02  ; cCPFR  := Iif(mv_par11 == 1, mv_par03, TransForm(mv_par03, "@R 999.999.999-99")) ; cIden  := mv_par04
       cOrgI  := Alltrim(mv_par05)  ; cUFId  := Alltrim(mv_par06)   ; cDDDE  := mv_par07
       cFone  := mv_par08  ; cFaxE  := mv_par09   ; cEMai  := mv_par10
       If mv_par11 == 1
          //1º Linha - Empresa (Obrigatório)
          //ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
          //ºCampo           ³ Inicio ³ Tamanho ³                             º
          //ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
          //º cTipo          ³     01 ³     002 ³ EM                          º
          //º cCNPJ          ³     03 ³     014 ³ Numero do CNPJ              º
          //º cRazao         ³     17 ³     070 ³ Razao Social da Empresa     º
          //º cCLF           ³     87 ³     010 ³ Certif. de Licen. de Func.  º
          //º cCNAE          ³     97 ³     010 ³ Código CNAE                 º
          //º cGrp1          ³    107 ³     001 ³ Grupo I                     º
          //º cGrp2          ³    108 ³     001 ³ Grupo II                    º
          //º cGrp3          ³    109 ³     001 ³ Grupo III                   º
          //º cGrp4          ³    110 ³     001 ³ Grupo IV                    º
          //º cGrp5          ³    111 ³     001 ³ Grupo V                     º
          //º cGrp6          ³    112 ³     001 ³ Grupo VI                    º
          //º cGrp7          ³    113 ³     001 ³ Grupo VII                   º
          //º cGrp8          ³    114 ³     001 ³ Grupo VIII                  º
          //º cGrp9          ³    115 ³     001 ³ Grupo IX                    º
          //º cDes9          ³    116 ³     050 ³ Desc. Grupo IX              º
          //º cInfo          ³    166 ³     200 ³ Informações                 º
          //º cGrpP          ³    366 ³     010 ³ Grupo Principal             º
          //º cResp          ³    376 ³     040 ³ Responsável                 º
          //º cCPFR          ³    416 ³     011 ³ CPF do Responsável          º
          //º cIden          ³    427 ³     011 ³ Ident. do Responsável       º
          //º cOrgI          ³    438 ³     035 ³ Orgão Exped. da Ident.      º
          //º cUFId          ³    473 ³     002 ³ Estado da Ident.            º
          //º cDDDE          ³    475 ³     003 ³ DDD da Empresa              º
          //º cFone          ³    478 ³     008 ³ Fone da empresa             º
          //º cFaxE          ³    486 ³     008 ³ Fax da empresa              º
          //º cEMai          ³    494 ³     050 ³ E-mail da empresa           º
          //ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
          //1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          //         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21        22        23        24        25        26        27        28        29        30        31        32        33        34        35        36        37        38        39        40
          //EM72770878000117BRASILUX TINTAS TECNICAS LTDA                                         00001030-82481-3/00 001000000                                                                                                                                                                                                                                                          GRUPO III Rui Camilo Pontes                       974743558589759585    SSP                                SP0163383700033837000brasilux@brasilux.com.br                          
          nTamLin := 544
          cLin    := Space(nTamLin)+cEOL         //Variavel para criacao da linha do registros para gravacao
          cCpo := PADR('EM'           , 002) ; cLin := Stuff(cLin, 001, 002, cCpo)      //Tipo da Linha
          cCpo := PADR(Alltrim(cCNPJ) , 014) ; cLin := Stuff(cLin, 003, 014, cCpo)      //CNPJ da Empresa
          cCpo := PADR(Alltrim(cRazao), 053) ; cLin := Stuff(cLin, 017, 070, cCpo)      //Razão Social
          cCpo := PADR(Alltrim(cCLF)  , 010) ; cLin := Stuff(cLin, 087, 010, cCpo)      //Certificado de Licensa
          cCpo := PADR(Alltrim(cCNAE) , 010) ; cLin := Stuff(cLin, 097, 010, cCpo)      //Código CNAE
          cCpo := PADR(cGrp1          , 001) ; cLin := Stuff(cLin, 107, 001, cCpo)      //Grupo I
          cCpo := PADR(cGrp2          , 001) ; cLin := Stuff(cLin, 108, 001, cCpo)      //Grupo II
          cCpo := PADR(cGrp3          , 001) ; cLin := Stuff(cLin, 109, 001, cCpo)      //Grupo III
          cCpo := PADR(cGrp4          , 001) ; cLin := Stuff(cLin, 110, 001, cCpo)      //Grupo IV
          cCpo := PADR(cGrp5          , 001) ; cLin := Stuff(cLin, 111, 001, cCpo)      //Grupo V
          cCpo := PADR(cGrp6          , 001) ; cLin := Stuff(cLin, 112, 001, cCpo)      //Grupo VI
          cCpo := PADR(cGrp7          , 001) ; cLin := Stuff(cLin, 113, 001, cCpo)      //Grupo VII
          cCpo := PADR(cGrp8          , 001) ; cLin := Stuff(cLin, 114, 001, cCpo)      //Grupo VIII
          cCpo := PADR(cGrp9          , 001) ; cLin := Stuff(cLin, 115, 001, cCpo)      //Grupo IX
          cCpo := PADR(Alltrim(cDes9) , 050) ; cLin := Stuff(cLin, 116, 050, cCpo)      //Descrição do Grupo IX
          cCpo := PADR(Alltrim(cInfo) , 200) ; cLin := Stuff(cLin, 166, 200, cCpo)      //Informações
          cCpo := PADR(Alltrim(cGrpP) , 010) ; cLin := Stuff(cLin, 366, 010, cCpo)      //Grupo Principal
          cCpo := PADR(Alltrim(cResp) , 040) ; cLin := Stuff(cLin, 376, 040, cCpo)      //Responsável
          cCpo := PADR(Alltrim(cCPFR) , 011) ; cLin := Stuff(cLin, 416, 011, cCpo)      //CPF Responsável
          cCpo := PADR(Alltrim(cIden) , 011) ; cLin := Stuff(cLin, 427, 011, cCpo)      //Ident. Responsável
          cCpo := PADR(Alltrim(cOrgI) , 035) ; cLin := Stuff(cLin, 438, 035, cCpo)      //Orgão Exped. da Ident.
          cCpo := PADR(Alltrim(cUFId) , 002) ; cLin := Stuff(cLin, 473, 002, cCpo)      //Estado da Ident.
          cCpo := PADR(Alltrim(cDDDE) , 003) ; cLin := Stuff(cLin, 475, 003, cCpo)      //DDD da Empresa
          cCpo := PADR(Alltrim(cFone) , 008) ; cLin := Stuff(cLin, 478, 008, cCpo)      //Fone da Empresa
          cCpo := PADR(Alltrim(cFaxE) , 008) ; cLin := Stuff(cLin, 486, 008, cCpo)      //Fax da Empresa
          cCpo := PADR(Alltrim(cEMai) , 050) ; cLin := Stuff(cLin, 494, 050, cCpo)+cEOL //E-mail da Empresa
          fWrite(nHdl,cLin,Len(cLin))
       
          //2º Linha - Mês (Obrigatório)
          //ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
          //ºCampo           ³ Inicio ³ Tamanho ³                             º
          //ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
          //º cTipo          ³     01 ³     002 ³ ME                          º
          //º cCNPJ          ³     03 ³     014 ³ Numero do CNPJ              º
          //º cAnoF          ³     17 ³     004 ³ Ano a partir de 2003        º
          //º cMesF          ³     21 ³     003 ³ Mes JAN, FEV, MAR...DEZ     º
          //ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
          nTamLin := 24
          cLin    := Space(nTamLin)+cEOL         //Variavel para criacao da linha do registros para gravacao
          cCpo := PADR('ME'           , 002) ; cLin := Stuff(cLin, 001, 002, cCpo)      //Tipo da Linha
          cCpo := PADR(Alltrim(cCNPJ) , 014) ; cLin := Stuff(cLin, 003, 014, cCpo)      //CNPJ da Empresa
          cCpo := PADR(cAnoF          , 004) ; cLin := Stuff(cLin, 017, 004, cCpo)      //Ano
          cCpo := PADR(cMesF          , 003) ; cLin := Stuff(cLin, 021, 003, cCpo)+cEOL //Mes
          fWrite(nHdl,cLin,Len(cLin))

          //3º Linha - Produtos (Obrigatório)
          //ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
          //ºCampo           ³ Inicio ³ Tamanho ³                             º
          //ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
          //º cTipo          ³     01 ³     002 ³ PR                          º
          //º cCNPJ          ³     03 ³     014 ³ Numero do CNPJ              º
          //º cAnoF          ³     17 ³     004 ³ Ano a partir de 2003        º
          //º cMesF          ³     21 ³     003 ³ Mes JAN, FEV, MAR...DEZ     º
          //º nConcent       ³     24 ³     006 ³ % de Concentração do Produtoº
          //º nDensida       ³     30 ³     006 ³ Densidade do Produto        º
          //º nQtdAnte       ³     36 ³     020 ³ Estoque Anterior            º
          //º nQtdProd       ³     56 ³     020 ³ Quantidade Produzida        º
          //º nQtdTran       ³     76 ³     020 ³ Quantidade Transferida      º
          //º nQtdUtil       ³     96 ³     020 ³ Quantidade Utilizada        º
          //º nQtdComp       ³    116 ³     020 ³ Quantidade Compras          º
          //º nQtdVend       ³    136 ³     020 ³ Quantidade de Vendas        º
          //º nQtdReci       ³    156 ³     020 ³ Quantidade de Reciclagem    º
          //º nQtdReap       ³    176 ³     020 ³ Quantidade de Reaprov.      º
          //º nQtdImpo       ³    196 ³     020 ³ Quantidade de Importação    º
          //º nQtdExpo       ³    216 ³     020 ³ Quantidade de Exportação    º
          //º nQtdPerd       ³    236 ³     020 ³ Quantidade de perda         º
          //º nQtdEvap       ³    256 ³     020 ³ Quantidade de Evaporação    º
          //º nQtdEntD       ³    276 ³     020 ³ Quantidade de Entrada Diver.º
          //º nQtdSaiD       ³    296 ³     020 ³ Quantidade de Saidas Diver. º
          //º nQtdAtua       ³    316 ³     020 ³ Estoque Atual               º
          //º cUnidMed       ³    336 ³     006 ³ Unidade de Medida           º
          //º cCodiNCM       ³    342 ³     010 ³ Codigo NCM                  º
          //º cNomePro       ³    352 ³     070 ³ Nome do Produto             º
          //ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
       Endif
       cCodPro   := GETMV("MV_MAPAPRO")
       aProdutos := {}
       While Len(cCodPro) > 0
             cProduto := SubStr(cCodPro, 1, 4)
             nConcent := StrZero(Val(SubStr(Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99"), 1, At(',', Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99")) - 1)), 3)+SubStr(Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99"), At(',', Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99")), 3)
             nDensida := StrZero(Val(SubStr(Transform(Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_PESOESP"), "@E 999.99"), 1, At(',', Transform(Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_PESOESP"), "@E 999.99")) - 1)), 3)+SubStr(Transform(Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_PESOESP"), "@E 999.99"), At(',', Transform(Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_PESOESP"), "@E 999.99")), 3)
             /*** SALDO DO PRODUTO NO MES ANTERIOR ***/
             cQry1    := ""
             cQry1    += "SELECT ZZ9.ZZ9_QINI "
             cQry1    += "FROM "+RetSqlName("ZZ9")+" ZZ9 "
             cQry1    += "WHERE ZZ9.ZZ9_FILIAL = '"+xFilial("ZZ9")+"' "
             cQry1    += "  AND ZZ9.D_E_L_E_T_ = '' "
             cQry1    += "  AND ZZ9.ZZ9_MES    = '"+Strzero(Val(SubStr(mv_par01, 1, 2))-1, 2)+cAnoF+"' "
             cQry1    += "  AND ZZ9.ZZ9_PRODUT = '"+cProduto+"' "
             cQry1    += "  AND ZZ9.ZZ9_LOCAL  = '01' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdAnte := StrZero(TCQ->ZZ9_QINI, 20)
             DbSelectArea("TCQ")
             DbCloseArea()
             /*** QUANTIDADE PRODUZIDA ***/
             nQtdProd := StrZero(0, 20) //Sempre quantidade igual a zero
             /*** QUANTIDADE TRANSFORMADA ***/
             nQtdTran := StrZero(0, 20) //Sempre quantidade igual a zero
             /*** QUANTIDADE UTILIZADA PELA PRODUÇÃO ***/
             cQry1    := ""
             cQry1    += "SELECT ISNULL(SUM(SD3.D3_QUANT), 0) AS D3_QUANT "
             cQry1    += "FROM "+RetSqlName("SD3")+" SD3 "
             cQry1    += "WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"' "
             cQry1    += "  AND SD3.D_E_L_E_T_ = '' "
             cQry1    += "  AND SD3.D3_COD = '"+cProduto+"' "
             cQry1    += "  AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD3.D3_TM  = '999' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdUtil := StrZero(TCQ->D3_QUANT, 20)
             DbSelectArea("TCQ")
             DbCloseArea()
             /*** QUANTIDADE COMPRADA ***/
             cQry1    := ""
             cQry1    += "SELECT SUM(SD1.D1_QUANT) AS D1_QUANT "
             cQry1    += "FROM "+RetSqlName("SD1")+" SD1 "
             cQry1    += "WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"' "
             cQry1    += "  AND SD1.D_E_L_E_T_ = '' "
             cQry1    += "  AND SUBSTRING(SD1.D1_DTDIGIT, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD1.D1_COD      = '"+cProduto+"' "
             cQry1    += "  AND SD1.D1_FORNECE <> '00401' " //Transferencias da Resina entram como entradas diversas.
             cQry1    += "  AND SD1.D1_TIPO    = 'N' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdComp := StrZero(TCQ->D1_QUANT, 20)
             DbSelectArea("TCQ")
             DbCloseArea()
             /*** QUANTIDADE VENDIDA ***/
             cQry1    := ""
             cQry1    += "SELECT SUM(SD2.D2_QUANT) AS D2_QUANT "
             cQry1    += "FROM "+RetSqlName("SD2")+" SD2 "
             cQry1    += "WHERE SD2.D2_FILIAL  = '"+xFilial("SD2")+"' "
             cQry1    += "  AND SD2.D_E_L_E_T_ = '' "
             cQry1    += "  AND SUBSTRING(SD2.D2_EMISSAO, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD2.D2_COD     = '"+cProduto+"' "
             cQry1    += "  AND SD2.D2_TIPO    = 'N' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdVend := StrZero(TCQ->D2_QUANT, 20)
             DbSelectArea("TCQ")
             DbCloseArea()
             /*** RECICLAGEM ***/
             nQtdReci := StrZero(0, 20) //Sempre quantidade igual a zero
             /*** REAPROVEITAMENTO ***/
             nQtdReap := StrZero(0, 20) //Sempre quantidade igual a zero
             /*** IMPORTAÇÃO ***/
             nQtdImpo := StrZero(0, 20) //Sempre quantidade igual a zero
             /*** EXPORTAÇÃO ***/
             nQtdExpo := StrZero(0, 20) //Sempre quantidade igual a zero
             /*** PERDA ***/
             nQtdPerd := StrZero(0, 20)
             /*** EVAPORAÇÃO ***/
             nQtdEvap := StrZero(0, 20) //Sempre quantidade igual a zero
             /*** ENTRADAS DIVERSAS ***/
             cQry1    := ""
             cQry1    += "SELECT ISNULL(SUM(SD3.D3_QUANT), 0) AS D3_QUANT "
             cQry1    += "FROM "+RetSqlName("SD3")+" SD3 "
             cQry1    += "WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"' "
             cQry1    += "  AND SD3.D_E_L_E_T_ = '' "
             cQry1    += "  AND SD3.D3_COD = '"+cProduto+"' "
             cQry1    += "  AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD3.D3_TM  = '499' "
             cQry1    += "  AND SD3.D3_TM <> '999' "
             cQry1    += "  AND SUBSTRING(SD3.D3_CF, 3, 1) <> '6' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdEntD := TCQ->D3_QUANT
             DbSelectArea("TCQ")
             DbCloseArea()
             cQry1    := ""
             cQry1    += "SELECT ISNULL(SUM(SD3.D3_QUANT), 0) AS D3_QUANT "
             cQry1    += "FROM "+RetSqlName("SD3")+" SD3 "
             cQry1    += "WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"' "
             cQry1    += "  AND SD3.D_E_L_E_T_ = '' "
             cQry1    += "  AND SD3.D3_COD = '"+cProduto+"' "
             cQry1    += "  AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD3.D3_TM  = '499' "
             cQry1    += "  AND SUBSTRING(SD3.D3_CF, 3, 1) <> '6' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdEntD += TCQ->D3_QUANT
             DbSelectArea("TCQ")
             DbCloseArea()
             cQry1    := ""
             cQry1    += "SELECT SUM(SD1.D1_QUANT) AS D1_QUANT "
             cQry1    += "FROM "+RetSqlName("SD1")+" SD1 "
             cQry1    += "WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"' "
             cQry1    += "  AND SD1.D_E_L_E_T_ = '' "
             cQry1    += "  AND SUBSTRING(SD1.D1_DTDIGIT, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD1.D1_COD      = '"+cProduto+"' "
             cQry1    += "  AND SD1.D1_FORNECE  = '00401' " //Transferencias da Resina entram como entradas diversas.
             cQry1    += "  AND SD1.D1_TIPO     = 'N' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdEntD += TCQ->D1_QUANT
             DbSelectArea("TCQ")
             DbCloseArea()
             cQtdEntD := StrZero(nQtdEntD, 20)
             /*** SAIDAS DIVERSAS ***/
             cQry1    := ""
             cQry1    += "SELECT ISNULL(SUM(SD3.D3_QUANT), 0) AS D3_QUANT "
             cQry1    += "FROM "+RetSqlName("SD3")+" SD3 "
             cQry1    += "WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"' "
             cQry1    += "  AND SD3.D_E_L_E_T_ = '' "
             cQry1    += "  AND SD3.D3_COD     = '"+cProduto+"' "
             cQry1    += "  AND SUBSTRING(SD3.D3_EMISSAO, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD3.D3_TM     >= '501' "
             cQry1    += "  AND SD3.D3_TM     <> '999' "
             cQry1    += "  AND SUBSTRING(SD3.D3_CF, 3, 1)  = '0' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdSaiD := StrZero(TCQ->D3_QUANT, 20)
             DbSelectArea("TCQ")
             DbCloseArea()
             /*** SALDO ATUAL ***/
             cQry1    := ""
             cQry1    += "SELECT ZZ9.ZZ9_QINI "
             cQry1    += "FROM "+RetSqlName("ZZ9")+" ZZ9 "
             cQry1    += "WHERE ZZ9.ZZ9_FILIAL = '"+xFilial("ZZ9")+"' "
             cQry1    += "  AND ZZ9.D_E_L_E_T_ = '' "
             cQry1    += "  AND ZZ9.ZZ9_MES    = '"+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+cAnoF+"' "
             cQry1    += "  AND ZZ9.ZZ9_PRODUT = '"+cProduto+"' "
             cQry1    += "  AND ZZ9.ZZ9_LOCAL  = '01' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             nQtdAtua := StrZero(TCQ->ZZ9_QINI, 20)
             DbSelectArea("TCQ")
             DbCloseArea()
             nSoma := (Val(nQtdAnte)+Val(nQtdComp)+Val(cQtdEntD)) - (Val(nQtdUtil)+Val(nQtdVend)+Val(nQtdSaiD))
             nDife := nSoma - Val(nQtdAtua)
             If nDife < 0
                cQtdEntD := StrZero((Val(cQtdEntD) + Abs(nDife)), 20)
             ElseIf nDife > 0
                    nQtdPerd := StrZero(nDife, 20)
             Endif
             cUnidMed := Iif(Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_UM") == 'K ', 'Kilos', 'Litros')
             cCodiNCM := TransForm(Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_POSIPI"), "@R 9999.99.99")
             cNomePro := Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CEME")
             aadd(aProdutos, {cProduto, nConcent, nDensida, nQtdAnte, nQtdProd, nQtdTran, nQtdUtil, nQtdComp, nQtdVend, nQtdReci, nQtdReap, nQtdImpo, nQtdExpo, nQtdPerd, nQtdEvap, cQtdEntD, nQtdSaiD, nQtdAtua, cUnidMed, cCodiNCM, cNomePro })
             cCodPro   := SubStr(cCodPro, 6, Len(cCodPro)-5)
       Enddo
       ProcRegua( Len(aProdutos) )
       For nY := 1 To Len(aProdutos) //Geracao do ANEXO XI-A
           IncProc("Gerando ANEXO XI-A para o produto: "+aProdutos[nY][01])
           If mv_par11 == 1
              nTamLin := 422
              cLin    := Space(nTamLin)+cEOL         //Variavel para criacao da linha do registros para gravacao
              cCpo := PADR('PR'             , 002) ; cLin := Stuff(cLin, 001, 002, cCpo)      //Tipo da Linha
              cCpo := PADR(Alltrim(cCNPJ)   , 014) ; cLin := Stuff(cLin, 003, 014, cCpo)      //CNPJ da Empresa
              cCpo := PADR(cAnoF            , 004) ; cLin := Stuff(cLin, 017, 004, cCpo)      //Ano
              cCpo := PADR(cMesF            , 003) ; cLin := Stuff(cLin, 021, 003, cCpo)      //Mes
              cCpo := PADR(aProdutos[nY][02], 006) ; cLin := Stuff(cLin, 024, 006, cCpo)      //Concentracao
              cCpo := PADR(aProdutos[nY][03], 006) ; cLin := Stuff(cLin, 030, 006, cCpo)      //Densidade
              cCpo := PADR(aProdutos[nY][04], 020) ; cLin := Stuff(cLin, 036, 020, cCpo)      //Estoque Anterior
              cCpo := PADR(aProdutos[nY][05], 020) ; cLin := Stuff(cLin, 056, 020, cCpo)      //Qtde. Produzida
              cCpo := PADR(aProdutos[nY][06], 020) ; cLin := Stuff(cLin, 076, 020, cCpo)      //Qtde. Transformada
              cCpo := PADR(aProdutos[nY][07], 020) ; cLin := Stuff(cLin, 096, 020, cCpo)      //Qtde. Utilizada
              cCpo := PADR(aProdutos[nY][08], 020) ; cLin := Stuff(cLin, 116, 020, cCpo)      //Qtde. Compras
              cCpo := PADR(aProdutos[nY][09], 020) ; cLin := Stuff(cLin, 136, 020, cCpo)      //Qtde. Vendas
              cCpo := PADR(aProdutos[nY][10], 020) ; cLin := Stuff(cLin, 156, 020, cCpo)      //Qtde. Reciclagem
              cCpo := PADR(aProdutos[nY][11], 020) ; cLin := Stuff(cLin, 176, 020, cCpo)      //Qtde. Reaproveitamento
              cCpo := PADR(aProdutos[nY][12], 020) ; cLin := Stuff(cLin, 196, 020, cCpo)      //Qtde. Importação
              cCpo := PADR(aProdutos[nY][13], 020) ; cLin := Stuff(cLin, 216, 020, cCpo)      //Qtde. Exportação
              cCpo := PADR(aProdutos[nY][14], 020) ; cLin := Stuff(cLin, 236, 020, cCpo)      //Qtde. Perdas
              cCpo := PADR(aProdutos[nY][15], 020) ; cLin := Stuff(cLin, 256, 020, cCpo)      //Qtde. Evaporação
              cCpo := PADR(aProdutos[nY][16], 020) ; cLin := Stuff(cLin, 276, 020, cCpo)      //Qtde. Entradas Diversas
              cCpo := PADR(aProdutos[nY][17], 020) ; cLin := Stuff(cLin, 296, 020, cCpo)      //Qtde. Saídas Diversas
              cCpo := PADR(aProdutos[nY][18], 020) ; cLin := Stuff(cLin, 316, 020, cCpo)      //Estoque Atual
              cCpo := PADR(aProdutos[nY][19], 006) ; cLin := Stuff(cLin, 336, 006, cCpo)      //Unidade de Medida
              cCpo := PADR(aProdutos[nY][20], 010) ; cLin := Stuff(cLin, 342, 010, cCpo)      //NCM
              cCpo := PADR(aProdutos[nY][21], 070) ; cLin := Stuff(cLin, 352, 070, cCpo)      //Descrição do Produto
              fWrite(nHdl,cLin,Len(cLin))
           Else
              cTextoA := 'XIA'+aProdutos[nY][1]+cMesF+cAnoF+'.DOC'
              oWord := OLE_CreateLink( cEditor )
              OLE_SetProperty( oWord, oleWdVisible,   .f. )
              OLE_SetProperty( oWord, oleWdPrintBack, .t. )
              OLE_SetProperty( oWord, oleWdLeft,   000 )
              OLE_SetProperty( oWord, oleWdTop,    090 )
              OLE_SetProperty( oWord, oleWdWidth,  480 )
              OLE_SetProperty( oWord, oleWdHeight, 250 )
              OLE_NewFile( oWord, ( cPathTrm + cTextoDA ) )
              
              /*** CABEÇALHO DO DOCUMENTO ***/
              OLE_SetDocumentVar( oWord, "MAPA_EMPRESA", cRazao                 ) //01 - Nome da Empresa
              OLE_SetDocumentVar( oWord, "MAPA_MES"    , cMesF                  ) //02 - Mes do Mapa
              OLE_SetDocumentVar( oWord, "MAPA_ANO"    , cANOF                  ) //03 - Anos do Mapa
              OLE_SetDocumentVar( oWord, "MAPA_CNPJ"   , cCNPJ                  ) //04 - CNPJ da Empresa
              OLE_SetDocumentVar( oWord, "MAPA_CLF"    , cCLF                   ) //05 - CLF da Empresa
              OLE_SetDocumentVar( oWord, "MAPA_GRUPO"  , cGrup                  ) //06 - Grupo da Empresa
              OLE_SetDocumentVar( oWord, "MAPA_ATIVID" , cDGrp                  ) //07 - Atividade da Empresa
              OLE_SetDocumentVar( oWord, "MAPA_CNAE"   , cCNAE                  ) //08 - CNAE da Empresa
              
              /*** ITEMS DO PRODUTO ***/
              OLE_SetDocumentVar( oWord, "MAPA_NCM"    , aProdutos[nY][20]      ) //09 - Código NCM do Produto
              OLE_SetDocumentVar( oWord, "MAPA_DESC"   , aProdutos[nY][21]      ) //10 - Descrição do Produto
              OLE_SetDocumentVar( oWord, "MAPA_CONC"   , Val(StrTran(aProdutos[nY][02], ",", ".")) ) //11 - Concentração %
              OLE_SetDocumentVar( oWord, "MAPA_DENS"   , Val(StrTran(aProdutos[nY][03], ",", ".")) ) //12 - Densidade
              OLE_SetDocumentVar( oWord, "MAPA_QANT"   , Val(aProdutos[nY][04]) ) //13 - Quantidade Anterior
              OLE_SetDocumentVar( oWord, "MAPA_QPRO"   , Val(aProdutos[nY][05]) ) //14 - Quantidade Producao
              OLE_SetDocumentVar( oWord, "MAPA_QTRA"   , Val(aProdutos[nY][06]) ) //15 - Quantidade Transformada
              OLE_SetDocumentVar( oWord, "MAPA_QUTI"   , Val(aProdutos[nY][07]) ) //16 - Quantidade Utilizada
              OLE_SetDocumentVar( oWord, "MAPA_QCOM"   , Val(aProdutos[nY][08]) ) //17 - Quantidade Compras
              OLE_SetDocumentVar( oWord, "MAPA_QVEN"   , Val(aProdutos[nY][09]) ) //18 - Quantidade Vendas
              OLE_SetDocumentVar( oWord, "MAPA_QREC"   , Val(aProdutos[nY][10]) ) //19 - Quantidade Reciclagem
              OLE_SetDocumentVar( oWord, "MAPA_QREA"   , Val(aProdutos[nY][11]) ) //20 - Quantidade Reaproveitamento
              OLE_SetDocumentVar( oWord, "MAPA_QIMP"   , Val(aProdutos[nY][12]) ) //21 - Quantidade Importação
              OLE_SetDocumentVar( oWord, "MAPA_QEXP"   , Val(aProdutos[nY][13]) ) //22 - Quantidade Exportação
              OLE_SetDocumentVar( oWord, "MAPA_QPER"   , Val(aProdutos[nY][14]) ) //23 - Quantidade Perda
              OLE_SetDocumentVar( oWord, "MAPA_QEVA"   , Val(aProdutos[nY][15]) ) //24 - Quantidade Evaporação
              OLE_SetDocumentVar( oWord, "MAPA_QENT"   , Val(aProdutos[nY][16]) ) //25 - Quantidade Entradas Diversas
              OLE_SetDocumentVar( oWord, "MAPA_QSAI"   , Val(aProdutos[nY][17]) ) //26 - Quantidade Saídas Diversas
              OLE_SetDocumentVar( oWord, "MAPA_QATU"   , Val(aProdutos[nY][18]) ) //27 - Quantidade Atual
              OLE_SetDocumentVar( oWord, "MAPA_UNID"   , aProdutos[nY][19]      ) //28 - Unidade de Medida

              /*** RESPONSÁVEL PELO MAPA ***/
              OLE_SetDocumentVar( oWord, "MAPA_RESP"   , cResp                  ) //29 - Responsável
              OLE_SetDocumentVar( oWord, "MAPA_CPFR"   , cCPFR                  ) //30 - CPF do Responsável
              OLE_SetDocumentVar( oWord, "MAPA_IDEN"   , cIden                  ) //31 - Identidade do Responsável
              OLE_SetDocumentVar( oWord, "MAPA_ORGI"   , cOrgI                  ) //32 - Orgão da Identidade
              OLE_SetDocumentVar( oWord, "MAPA_UFID"   , cUFId                  ) //33 - Estado da Identidade

              OLE_UpdateFields( oWord )
              OLE_SaveAsFile( oWord, ( cPath + cTextoA ), , , .f., oleWdFormatDocument )
              OLE_SaveFile( oWord )
              OLE_SetProperty( oWord, oleWdVisible, .t. )
              OLE_SetProperty( oWord, oleWdPrintBack, .f. )
              OLE_CloseFile( oWord )
              OLE_CloseLink( oWord ) 
           Endif
       Next
       If File(cPathTrm+cTextoDA)
          FErase(cPathTrm+cTextoDA)
       Endif

       //4º Linha - Produtos Finais (Não Obrigatório)
       
       //5º Linha - Movimentos (Obrigatório)
       //ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
       //ºCampo           ³ Inicio ³ Tamanho ³                             º
       //ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
       //º cTipo          ³     01 ³     002 ³ MV                          º
       //º cCNPJ          ³     03 ³     014 ³ Numero do CNPJ              º
       //º cAnoF          ³     17 ³     004 ³ Ano a partir de 2003        º
       //º cMesF          ³     21 ³     003 ³ Mes JAN, FEV, MAR...DEZ     º
       //ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
       cCodPro   := GETMV("MV_MAPAPRO")
       aMoviment := {}
       While Len(cCodPro) > 0
             cProduto := SubStr(cCodPro, 1, 4)
             cQry1    := ""
             cQry1    += "SELECT SUBSTRING(SD1.D1_EMISSAO, 7, 2) AS DIA, SD1.D1_CF AS CFOP, SD1.D1_QUANT AS QUANT, SD1.D1_UM AS UM, SD1.D1_DOC AS NFISCAL, SD1.D1_FORNECE+SD1.D1_LOJA AS FORNECE "
             cQry1    += "FROM "+RetSqlName("SD1")+" SD1 "
             cQry1    += "WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"' "
             cQry1    += "  AND SD1.D_E_L_E_T_ = '' "
             cQry1    += "  AND SUBSTRING(SD1.D1_DTDIGIT, 1, 6) = '"+cAnoF+Strzero(Val(SubStr(mv_par01, 1, 2)), 2)+"' "
             cQry1    += "  AND SD1.D1_COD     = '"+cProduto+"' "
             cQry1    += "  AND SD1.D1_TIPO    = 'N' "
             TCQuery cQry1 ALIAS "TCQ" NEW
             DbSelectArea("TCQ")
             While !Eof()
                   cDiaN := TCQ->DIA
                   cCFOP := SubStr(TCQ->CFOP, 1, 1)+'.'+SubStr(TCQ->CFOP, 2, 3)
                   cConc := StrZero(Val(SubStr(Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99"), 1, At(',', Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99")) - 1)), 3)+SubStr(Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99"), At(',', Transform(Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CONCENT"), "@E 999.99")), 3)
                   cQtde := StrZero(TCQ->QUANT, 20)
                   cUniM := Iif(TCQ->UM == 'K ', 'Kilos', 'Litros')
                   cNota := TCQ->NFISCAL
                   cForn := Iif(mv_par11 == 1, Posicione("SA2", 1, xFilial("SA2")+TCQ->FORNECE, "A2_CGC"), Transform(Posicione("SA2", 1, xFilial("SA2")+TCQ->FORNECE, "A2_CGC"), "@R 99.999.999/9999-99"))
                   cTran := StrZero(0, 14)
                   cCNCM := TransForm(Posicione("SB1", 1, xFilial("SB1")+cProduto, "B1_POSIPI"), "@R 9999.99.99")
                   cNPro := Posicione("SB5", 1, xFilial("SB5")+cProduto, "B5_CEME")
                   aadd(aMoviment, {cProduto, cDiaN, cCFOP, cConc, cQtde, cUniM, cNota, cForn, cTran, cCNCM, cNPRO, " "})
                   DbSelectArea("TCQ")
                   DbSkip()
             Enddo
             DbSelectArea("TCQ")
             DbCloseArea()
             cCodPro   := SubStr(cCodPro, 6, Len(cCodPro)-5)
       Enddo
       ProcRegua( Len(aMoviment) )
       aSort(aMoviment,,, {|x,y| x[1]+x[2] < y[1]+y[2]})
       For nY := 1 To Len(aMoviment) //Gerando ANEXO XI-B
           IncProc("Gerando ANEXO XI-B para o produto: "+aMoviment[nY][01])
           If mv_par11 == 1
              nTamLin := 422
              cLin    := Space(nTamLin)+cEOL         //Variavel para criacao da linha do registros para gravacao
              cCpo := PADR('MV'             , 002) ; cLin := Stuff(cLin, 001, 002, cCpo)      //Tipo da Linha
              cCpo := PADR(Alltrim(cCNPJ)   , 014) ; cLin := Stuff(cLin, 003, 014, cCpo)      //CNPJ da Empresa
              cCpo := PADR(cAnoF            , 004) ; cLin := Stuff(cLin, 017, 004, cCpo)      //Ano
              cCpo := PADR(cMesF            , 003) ; cLin := Stuff(cLin, 021, 003, cCpo)      //Mes
              cCpo := PADR(aMoviment[nY][02], 002) ; cLin := Stuff(cLin, 024, 002, cCpo)      //Dia
              cCpo := PADR(aMoviment[nY][03], 005) ; cLin := Stuff(cLin, 026, 005, cCpo)      //CFOP
              cCpo := PADR(aMoviment[nY][04], 006) ; cLin := Stuff(cLin, 031, 006, cCpo)      //% Concentração
              cCpo := PADR(aMoviment[nY][05], 020) ; cLin := Stuff(cLin, 037, 020, cCpo)      //Qtde. Produto
              cCpo := PADR(aMoviment[nY][06], 006) ; cLin := Stuff(cLin, 057, 006, cCpo)      //Unid. de Medida
              cCpo := PADR(aMoviment[nY][07], 010) ; cLin := Stuff(cLin, 063, 010, cCpo)      //Nota Fiscal
              cCpo := PADR(aMoviment[nY][08], 014) ; cLin := Stuff(cLin, 073, 014, cCpo)      //Cód. Fornecedor
              cCpo := PADR(aMoviment[nY][09], 014) ; cLin := Stuff(cLin, 087, 014, cCpo)      //Cód. Transportadora
              cCpo := PADR(aMoviment[nY][10], 010) ; cLin := Stuff(cLin, 101, 010, cCpo)      //Código NCM do Produto
              cCpo := PADR(aMoviment[nY][11], 070) ; cLin := Stuff(cLin, 111, 070, cCpo)      //Nome do Produto
              fWrite(nHdl,cLin,Len(cLin))
           Else
              If Empty(aMoviment[nY][12])
                 cProAtu := aMoviment[nY][01]
                 aProAtu := {}
                 For nX := 1 To Len(aMoviment)
                     If aMoviment[nX][01] == cProAtu .and. Empty(aMoviment[nX][12])
                        aadd(aProAtu, {aMoviment[nX][01], aMoviment[nX][02], aMoviment[nX][03], aMoviment[nX][04], aMoviment[nX][05], aMoviment[nX][06], aMoviment[nX][07], aMoviment[nX][08], aMoviment[nX][09], aMoviment[nX][10], aMoviment[nX][11] })
                        aMoviment[nX][12] := "S"
                     Endif
                 Next
                 If Len(aProAtu) > 0
                    oWord := OLE_CreateLink( cEditor )
                    OLE_SetProperty( oWord, oleWdVisible,   .f. )
                    OLE_SetProperty( oWord, oleWdPrintBack, .t. )
                    OLE_SetProperty( oWord, oleWdLeft,   000 )
                    OLE_SetProperty( oWord, oleWdTop,    090 )
                    OLE_SetProperty( oWord, oleWdWidth,  480 )
                    OLE_SetProperty( oWord, oleWdHeight, 250 )
                    cTextoB := 'XIB'+aMoviment[nY][1]+cMesF+cAnoF+'.DOC'
                    If Len(aProAtu) <= 12
                       OLE_NewFile( oWord, ( cPathTrm + cTextoDB1 ) )
                       nItens  := 12
                    ElseIf Len(aProAtu) > 12 .and. Len(aProAtu) <= 24
                           OLE_NewFile( oWord, ( cPathTrm + cTextoDB2 ) )
                           nItens  := 24
                    ElseIf Len(aProAtu) > 24
                           OLE_NewFile( oWord, ( cPathTrm + cTextoDB3 ) )
                           nItens  := 36
                    Endif
                    /*** CABEÇALHO DO DOCUMENTO ***/
                    OLE_SetDocumentVar( oWord, "MAPA_EMPRESA", cRazao                 ) //01 - Nome da Empresa
                    OLE_SetDocumentVar( oWord, "MAPA_MES"    , cMesF                  ) //02 - Mes do Mapa
                    OLE_SetDocumentVar( oWord, "MAPA_ANO"    , cANOF                  ) //03 - Anos do Mapa
                    OLE_SetDocumentVar( oWord, "MAPA_CNPJ"   , cCNPJ                  ) //04 - CNPJ da Empresa
                    For nX := 1 To Len(aProAtu)
                        OLE_SetDocumentVar( oWord, "MAPA_DIA"+StrZero(nX, 2), aProAtu[nX][02]                         ) //05 - Dia da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_CFO"+StrZero(nX, 2), aProAtu[nX][03]                         ) //06 - CFOP do item da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_COD"+StrZero(nX, 2), aProAtu[nX][10]                         ) //07 - Cód. NCM do item da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_CON"+StrZero(nX, 2), Val(StrTran(aProAtu[nX][04], ",", ".")) ) //08 - % Concentração do Produto
                        OLE_SetDocumentVar( oWord, "MAPA_QTD"+StrZero(nX, 2), Val(aProAtu[nX][05])                    ) //09 - Quantidade da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_UND"+StrZero(nX, 2), aProAtu[nX][06]                         ) //10 - Unidade de Medida
                        OLE_SetDocumentVar( oWord, "MAPA_NFI"+StrZero(nX, 2), aProAtu[nX][07]                         ) //11 - Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_FOR"+StrZero(nX, 2), aProAtu[nX][08]                         ) //12 - CNPJ Fornecedor
                        OLE_SetDocumentVar( oWord, "MAPA_TRA"+StrZero(nX, 2), space(14)                               ) //13 - CNPJ Transportadora
                    Next
                    For nX := (Len(aProAtu) + 1) To nItens
                        OLE_SetDocumentVar( oWord, "MAPA_DIA"+StrZero(nX, 2), space(02)                               ) //05 - Dia da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_CFO"+StrZero(nX, 2), space(05)                               ) //06 - CFOP do item da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_COD"+StrZero(nX, 2), space(10)                               ) //07 - Cód. NCM do item da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_CON"+StrZero(nX, 2), space(06)                               ) //08 - % Concentração do Produto
                        OLE_SetDocumentVar( oWord, "MAPA_QTD"+StrZero(nX, 2), space(14)                               ) //09 - Quantidade da Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_UND"+StrZero(nX, 2), space(10)                               ) //10 - Unidade de Medida
                        OLE_SetDocumentVar( oWord, "MAPA_NFI"+StrZero(nX, 2), space(06)                               ) //11 - Nota Fiscal
                        OLE_SetDocumentVar( oWord, "MAPA_FOR"+StrZero(nX, 2), space(14)                               ) //12 - CNPJ Fornecedor
                        OLE_SetDocumentVar( oWord, "MAPA_TRA"+StrZero(nX, 2), space(14)                               ) //13 - CNPJ Transportadora
                    Next

                    /*** RESPONSÁVEL PELO MAPA ***/
                    OLE_SetDocumentVar( oWord, "MAPA_RESP"   , cResp                  ) //29 - Responsável
                    OLE_SetDocumentVar( oWord, "MAPA_CPFR"   , cCPFR                  ) //30 - CPF do Responsável
                    OLE_SetDocumentVar( oWord, "MAPA_IDEN"   , cIden                  ) //31 - Identidade do Responsável
                    OLE_SetDocumentVar( oWord, "MAPA_ORGI"   , cOrgI                  ) //32 - Orgão da Identidade
                    OLE_SetDocumentVar( oWord, "MAPA_UFID"   , cUFId                  ) //33 - Estado da Identidade

                    OLE_UpdateFields( oWord )
                    OLE_SaveAsFile( oWord, ( cPath + cTextoB ), , , .f., oleWdFormatDocument )
                    OLE_SaveFile( oWord )
                    OLE_SetProperty( oWord, oleWdVisible, .t. )
                    OLE_SetProperty( oWord, oleWdPrintBack, .f. )
                    OLE_CloseFile( oWord )
                    OLE_CloseLink( oWord )
                 Endif
              Endif
           Endif
       Next
       If File(cPathTrm+cTextoDB1)
          FErase(cPathTrm+cTextoDB1)
       Endif
       If File(cPathTrm+cTextoDB2)
          FErase(cPathTrm+cTextoDB2)
       Endif
       If File(cPathTrm+cTextoDB3)
          FErase(cPathTrm+cTextoDB3)
       Endif
       If mv_par11 == 1
          fClose(nHdl)
       Endif
       oDlg:End()
Return

/************************************************************************************************/
/*** VALPERG1 - Validação das perguntas para o relatório                                      ***/
/************************************************************************************************/
Static Function ValPerg1()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg, "01", "Mes+Ano mapa             ", "", "", "mv_ch1", "C", 06, 0, 0, "G", "NaoVazio()", "mv_par01", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "02", "Responsável              ", "", "", "mv_ch2", "C", 40, 0, 0, "G", "NaoVazio()", "mv_par02", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "03", "CPF do Responsável       ", "", "", "mv_ch3", "C", 11, 0, 0, "G", "NaoVazio()", "mv_par03", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "04", "Identidade do Responsável", "", "", "mv_ch4", "C", 11, 0, 0, "G", "NaoVazio()", "mv_par04", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "05", "Orgão da Identidade      ", "", "", "mv_ch5", "C", 35, 0, 0, "G", "NaoVazio()", "mv_par05", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "06", "UF da Identidade         ", "", "", "mv_ch6", "C", 02, 0, 0, "G", "NaoVazio()", "mv_par06", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "07", "DDD                      ", "", "", "mv_ch7", "C", 03, 0, 0, "G", "NaoVazio()", "mv_par07", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "08", "Telefone                 ", "", "", "mv_ch8", "C", 08, 0, 0, "G", "NaoVazio()", "mv_par08", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "09", "Fax                      ", "", "", "mv_ch9", "C", 08, 0, 0, "G", "NaoVazio()", "mv_par09", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "10", "E-mail                   ", "", "", "mv_cha", "C", 50, 0, 0, "G", "NaoVazio()", "mv_par10", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
       aAdd(aRegs,{cPerg, "11", "Gerar                    ", "", "", "mv_chb", "N", 01, 0, 0, "C", ""          , "mv_par11", "Arquivo", "", "", "", "", "MS-Word", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
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
