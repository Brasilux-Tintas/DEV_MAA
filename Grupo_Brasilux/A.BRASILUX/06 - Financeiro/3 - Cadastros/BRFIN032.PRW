#include "protheus.ch"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFIN032  º Autor ³ Jeane Q. Oliveira  º Data ³  24/11/00   º±±
±±ºPrograma  ³BRFIN032  º Alteração  ³ José Uliana   º Data ³  16/03/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Conciliação BX Fornecedor                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TECNICAS LTDA                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BRFIN032()
//     Local cVldAlt   	:= ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
//     Local cVldExc   	:= ".F." // Validacao para permitir a exclusao.  Pode-se utilizar ExecBlock. 
     Private cString 	:= "FIG"
     Private nomeprog   := "BRFIN032"
     
//     cVldAlt := 'ExecBlock("FIN032_1", .F., .F.)'
//     cVldExc := 'ExecBlock("FIN032_2", .F., .F.)'


     If !u_VldAcesso(funname())
        MsgStop("Acesso não autorizado!---->"+funname())
     	Return 
	 Endif           
     u_zcfga01( 'BRFIN032' ) //LGS#2021202 - Gravação de log de utilização da rotina
     DbSelectArea("FIG")
     DbSetOrder(1)
     Set Filter to FIG->FIG_CONCIL = '2'
     AxCadastro(cString, "Cadastro de Conciliação BX Fornecedor", ".T.", ".T.")

Return

/*******************************************************************************/
/*** FIN032_1 - Valida alteração do fornecedor e do CNPJ                     ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 16/03/2021 - Jose Uliana   do programa BRFIN030             ***/
/*******************************************************************************/
/*------------------------------------------  JOSE
User Function FIN030_1()
     Local lGerSim := .f.
     Local nY
     Local cIdentLib
     Local cQry1   := ""
     Local cCodOri := ""
     Local aRepSZP := {}
     Local aRepSZM := {}
     Local aRepSZN := {}
     Local cMenssag:=""
     
     If !Empty(M->Z3_PADCOR)
        DbSelectArea("ZZE")
        DbSetOrder(1)
        DbSeek(xFilial("ZZE")+M->Z3_PADCOR, .t.)
        If Found()
           If ZZE->ZZE_LIBERA $ 'S'
              cIdentLib := Int2Hex( WFGetNum( "MV_WF6IDEN" ),10 )
              cMenssag  := "Foi gerada simulação para o(s) produto(s) abaixo:"+Chr(13)+Chr(10)
              cQry1 := ""
              cQry1 += "SELECT SZM.ZM_CODIGO, MAX(SZM.ZM_REVISAO) AS ZM_REVISAO "
              cQry1 += "FROM "+RetSqlName("SZM")+" SZM WITH (NOLOCK) "
              cQry1 += "WHERE SZM.ZM_FILIAL  = '"+xFilial("SZM")+"' "
              cQry1 += "  AND SZM.D_E_L_E_T_ = '' "
              cQry1 += "  AND SUBSTRING(SZM.ZM_CODIGO, 6, 5) = '"+M->Z3_COR+M->Z3_VARIAC+"' "
              cQry1 += "GROUP BY SZM.ZM_CODIGO "
              TCQUERY cQry1 NEW ALIAS "TMP"
              DbSelectArea("TMP")
              DbGoTop()
              While !Eof()
                    cCodOri := TMP->ZM_CODIGO
                    //Monta Vetor com dados da tabela SZM - Cabeçalho da Simulação
                    aRepSZM := {}
                    DbSelectArea("SZM")
                    DbSetOrder(1)
                    DbSeek(xFilial("SZM")+cCodOri+TMP->ZM_REVISAO, .t.)
                    If Found()
                       cMenssag  += Alltrim(SZM->ZM_CODIGO)+" / "+Alltrim(SZM->ZM_REVISAO)+"  -  "+Alltrim(SZM->ZM_DESCRIC)+Chr(13)+Chr(10)
                       For nY := 1 To FCount()
                           aAdd( aRepSZM, FieldGet(nY) )
                       Next
                       //Monta Array com dados da tabela SZN - Itens da Simulação
                       aRepSZN := {}
                       DbSelectArea("SZN")
                       DbSetOrder(2)
                       DbSeek(xFilial("SZN")+cCodOri+TMP->ZM_REVISAO, .t.)
                       If Found()
                          While !Eof() .and. SZN->ZN_CODIGO == cCodOri .and. SZN->ZN_REVISAO == TMP->ZM_REVISAO
                                aAdd( aRepSZN, Array( FCount() ) )
                                For nY := 1 To FCount()
                                    aRepSZN[Len(aRepSZN)][nY] := FieldGet(nY)
                                Next
                            DbSelectArea("SZN")
                            DbSkip()
                          Enddo
                       Endif
                       //Monta Array com dados das Embalagens
                       aRepSZP := {}
                       DbSelectArea("TMP")
                       While SubStr(TMP->ZM_CODIGO, 1, 10) == SubStr(cCodOri, 1, 10)
                           aAdd(aRepSZP, SubStr(TMP->ZM_CODIGO, 11, 2) )
                           DbSelectArea("TMP")
                           DbSkip()
                       EndDo
                    Endif
                    //Grava SZM
                    lGerSim := .t.
                    //Grava SZN
                    //Grava SZP
                    //Grava SZT
                    DbSelectArea("TMP")
                    DbSkip()
                    //Loop
              EndDo
              DbSelectArea("TMP")
              DbCloseArea()
              If lGerSim
                 DbSelectArea("ZZE")
                 DbSetOrder(1)
                 DbSeek(xFilial("ZZE")+M->Z3_PADCOR, .t.)   
                 //Cleber(19/10/16) -> Jonatas informou que o Status R não existe mais
/*                 If Found()
                    RecLock("ZZE", .f.)
                       ZZE->ZZE_LIBERA := "R"
                    MsUnLock()
                 Endif
*/                 
/*  -----------------------    JOSE                 
                 //WFMessenger(cUserName, "RicardoAraujo", "Geração de Simulação Automática - por padrão de cor.", cMenssag, "0", cIdentLib)
                 WFMessenger(UsrRetName(RetCodUsr()), "RicardoAraujo", "Geração de Simulação Automática - por padrão de cor.", cMenssag, "0", cIdentLib)
              Endif
           Endif
        Endif
        DbSelectArea("SZ3")
     Endif
Return(.t.)
                
/*******************************************************************************/
/*** FAT011_2 - Valida exclusão das Variações de cores                       ***/
/*** Autor: Jeane Q. Oliveira                                                ***/
/*** Data : 30/11/00                                                         ***/
/*** Alterações: 10/05/07 - Luís Gustavo de Souza                            ***/
/***                        Troca do programa BRFAT019 para FAT011_2 dentro  ***/
/***                        do programa BRFAT011                             ***/
/*******************************************************************************/
/*----------------------------   JOSE
User Function FAT011_2()
     Local cQuery :=""
     Private _existe
     cQuery := ""
     cQuery += "SELECT SB1.B1_COD "
     cQuery += " FROM "+RetSqlName("SB1")+" SB1 "
     cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND"
     cQuery += " SUBSTRING(SB1.B1_COD, 6, 2) = '"+SZ3->Z3_COR+"' AND" 
     cQuery += " SUBSTRING(SB1.B1_COD, 8, 3) = '"+SZ3->Z3_VARIAC+"' AND"
     cQuery += " SB1.D_E_L_E_T_ <> '*' "
     TCQUERY cQuery NEW ALIAS "TMP"

     DbSelectArea("TMP")
     DbGoTop()
     
     _existe := .f.
     If !Eof()
        _existe := .t.
     Endif

     DbCloseArea("TMP")
     DbSelectArea("SZ3")
     If _existe
        MsgStop("Variacao de Cor nao pode ser excluida, pois existem produtos utilizando-a.")
        Return(.f.)
     Else
        Return(.t.)
     Endif
Return(.t.)
-----------------------    JOSE  -------                */
