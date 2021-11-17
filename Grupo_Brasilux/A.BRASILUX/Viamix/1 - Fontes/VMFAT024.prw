#include 'rwmake.ch'
#include 'topconn.ch'
#include 'ap5mail.ch'  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VMFAT024 ºAutor  ³ Luis Gustavo       º Data ³  10/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importacao / Exportacao de dados.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VIAMIX / BRASILUX                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VMFAT024()
     //Local   cAlias  := Alias()
     //Local   nOrder  := IndexOrd()
     //Local   cAux
     Local   lRet    := .t.
     //Private cPerg1  := padr('VMFT24',Len(SX1->X1_GRUPO)," ") //LGS#20200213 - Adequação de release 12.1.25 e posteriores
     Private cPerg1  := 'VMFT24'
     //Private cPerg2  := padr('VM24FT',Len(SX1->X1_GRUPO)," ") //LGS#20200213 - Adequação de release 12.1.25 e posteriores
     Private cPerg2  := 'VM24FT'
     Private cFileVM := ""
     Private oTempTbl01
     /*If cNumEmp $ '01010101'
        Private cPathVM := '\REMOTE\VIAMIX\'
     Else
        Private cPathVM := '\BIN\REMOTE\VIAMIX\'
     Endif*/
     Private cPathVM := Iif( cNumEmp $ '01010101', '\REMOTE\VIAMIX\', '\BIN\REMOTE\VIAMIX\' )
     Private bCampo  := {|nCpo| Field(nCpo)}

     //VldPerg1() //LGS#20200213 - Adequação de release 12.1.25 e posteriores
     Pergunte(cPerg1,.F.)
     nAux       := SPACE(40)
     Linha      := 0                
     nOpcA      := 0                
     nPag       := 0
     nValTotGer := 0 
    
     oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Exportação / Importação de dados BRASILUX / VIAMIX.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

     @ 020,018 SAY OemToAnsi("Este processo  tem como  função, importar / exportar ")
     @ 030,018 SAY OemToAnsi("os dados, para integração entre Brasilux / Viamix.   ")
     @ 040,018 SAY OemToAnsi("                                                     ")
     @ 057,170 BMPBUTTON TYPE 05 ACTION (Pergunte(cPerg1))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
     If nOpca == 0 
        //Exit
        Return
     EndIf
     nExpImp := mv_par01 //1 - Exporta Brasilux para Viamix, 2 - Exporta Viamix para Brasilux, 3 - Importa Brasilux para Viamix, 4 - Importa Viamix para Brasilux
     nOpc    := mv_par02 //1 - Cadastro de Produtos, 2 - Cadastro de Transportadoras, 3 - Borderos
     If nExpImp == 1 // Exportação Brasilux para Viamix
        If !cNumEmp $ '01010101'
           MsgBox("Empresa/Filial inválida !!!", "Atenção", "STOP")
           Return
        Else
           If nOpc == 1 // Exporta Cadastro de produtos
              MsAguarde({|| lRet := FAT024_1(nExpImp, 1) }, "Aguarde...", "Montando arquivo de dados...")
              If lRet
                 MsAguarde({|| lRet := EXP024_1(nExpImp, 1) }, "Aguarde...", "Incluido informações no arquivo...")
              Endif
              If lRet
                 fEnvArq(nExpImp, nOpc, cPathVM+cFileVM+".DBF")
              Endif
           ElseIf nOpc == 2 // Exporta Cadastro de Transportadora 
                  MsAguarde({|| lRet := FAT024_1(nExpImp, 2) }, "Aguarde...", "Montando arquivo de dados...")
                  If lRet
                     MsAguarde({|| lRet := EXP024_1(nExpImp, 2) }, "Aguarde...", "Incluido informações no arquivo...")
                  Endif
                  If lRet
                     fEnvArq(nExpImp, nOpc, cPathVM+cFileVM+".DBF")
                  Endif
           ElseIf nOpc == 3 // Borderos
                  MsAguarde({|| lRet := FAT024_1(nExpImp, 3) }, "Aguarde...", "Montando arquivo de dados...")
                  If lRet
                     MsAguarde({|| lRet := EXP024_1(nExpImp, 3) }, "Aguarde...", "Incluido informações no arquivo...")
                  Endif
                  If lRet
                     fEnvArq(nExpImp, nOpc, cPathVM+cFileVM+".DBF")
                  Endif
           Endif
        Endif
     ElseIf nExpImp == 2 // Exportação Viamix para Brasilux
            If !cNumEmp $ '01010106'
               MsgBox("Empresa/Filial inválida !!!", "Atenção", "STOP")
               Return
            Else
               If nOpc == 1 // Cadastro de Produtos
                  MsgBox("Opção não utilizada para essa empresa/filial !!!", "Atenção", "STOP")
                  Return
               ElseIf nOpc == 2 // Cadastro de Transportadoras
                      MsAguarde({|| lRet := FAT024_1(nExpImp, 2) }, "Aguarde...", "Montando arquivo de dados...")
                      If lRet
                         MsAguarde({|| lRet := EXP024_1(nExpImp, 2) }, "Aguarde...", "Incluido informações no arquivo...")
                      Endif
                      If lRet
                         fEnvArq(nExpImp, nOpc, cFileVM+".DBF", cPathVM)
                      Endif
               ElseIf nOpc == 3 // Borderos
                      MsAguarde({|| lRet := FAT024_1(nExpImp, 3) }, "Aguarde...", "Montando arquivo de dados...")
                      If lRet
                         MsAguarde({|| lRet := EXP024_1(nExpImp, 3) }, "Aguarde...", "Incluido informações no arquivo...")
                      Endif
                      If lRet
                         fEnvArq(nExpImp, nOpc, cFileVM+".DBF", cPathVM)
                      Endif
               Endif
            Endif
     //ElseIf nExpImp == 3 // Importação para Brasilux
            //If !cNumEmp $ '0101'
            //   MsgBox("Empresa/Filial inválida !!!", "Atenção", "STOP")
            //   Return
            //Else
            //   If nOpc == 1
            //      MsgBox("Opção não utilizada para essa empresa/filial !!!", "Atenção", "STOP")
            //      Return
            //   ElseIf nOpc == 2
            //          MsAguarde({|| lRet := FAT024_1(nExpImp, 2) }, "Aguarde...", "Lendo arquivo de dados...")
            //          If lRet
            //             MsAguarde({|| lRet := IMP024_1(nExpImp, 2) }, "Aguarde...", "Importando informações do arquivo...")
            //          Endif
            //   ElseIf nOpc == 3
            //          MsAguarde({|| lRet := FAT024_1(nExpImp, 3) }, "Aguarde...", "Lendo arquivo de dados...")
            //          If lRet
            //             MsAguarde({|| lRet := IMP024_1(nExpImp, 3) }, "Aguarde...", "Importanto informações do arquivo...")
            //          Endif
            //   Endif
            //Endif
     ElseIf nExpImp == 4 // Importação para Viamix
            If !cNumEmp $ '01010106'
               MsgBox("Empresa/Filial inválida !!!", "Atenção", "STOP")
               Return
            Else
               If nOpc == 1
                  MsAguarde({|| lRet := FAT024_1(nExpImp, 1) }, "Aguarde...", "Lendo arquivo de dados...")
                  If lRet
                     MsAguarde({|| lRet := IMP024_1(nExpImp, 1) }, "Aguarde...", "Importando informações do arquivo...")
                  Endif
               ElseIf nOpc == 2
                      MsAguarde({|| lRet := FAT024_1(nExpImp, 2) }, "Aguarde...", "Lendo arquivo de dados...")
                      If lRet
                         MsAguarde({|| lRet := IMP024_1(nExpImp, 2) }, "Aguarde...", "Importando informações do arquivo...")
                      Endif
               ElseIf nOpc == 3
                      MsAguarde({|| lRet := FAT024_1(nExpImp, 3) }, "Aguarde...", "Lendo arquivo de dados...")
                      If lRet
                         MsAguarde({|| lRet := IMP024_1(nExpImp, 3) }, "Aguarde...", "Importando informações do arquivo...")
                      Endif
               Endif
            Endif
     Endif


Return

/**************************************************************************************/
/*** FAT024_1 - Montagem / Leitura dos arquivos temporários.                        ***/
/**************************************************************************************/
Static Function FAT024_1(nExpImp, nOpc)
       Local   aCampos:= {}
       If nExpImp == 1 // Exportação de dados da Brasilux para Viamix
          If nOpc == 1 // Cadastro de Produtos
             aadd(aCampos, {"B1_FILIAL" , "C", 06, 00} ) ; aadd(aCampos, {"B1_COD"    , "C", 15, 00} )
             aadd(aCampos, {"B1_DESC"   , "C", 30, 00} ) ; aadd(aCampos, {"B1_TIPO"   , "C", 02, 00} )
             aadd(aCampos, {"B1_LOCPAD" , "C", 02, 00} ) ; aadd(aCampos, {"B1_UM"     , "C", 02, 00} )
             aadd(aCampos, {"B1_PRV1"   , "N", 14, 04} ) ; aadd(aCampos, {"B1_PERINT" , "N", 10, 02} )
             aadd(aCampos, {"B1_LCRMIN" , "N", 10, 04} ) ; aadd(aCampos, {"B1_LUCROM2", "N", 10, 04} )
             aadd(aCampos, {"B1_LUCRO"  , "N", 10, 04} ) ; aadd(aCampos, {"B1_LUCRO2" , "N", 10, 04} )
             aadd(aCampos, {"B1_CONINI" , "D", 08, 00} ) ; aadd(aCampos, {"B1_POSIPI" , "C", 10, 00} )
             aadd(aCampos, {"B1_PICM"   , "N", 05, 02} ) ; aadd(aCampos, {"B1_IPI"    , "N", 05, 02} )
             aadd(aCampos, {"B1_DTREFP1", "D", 08, 00} ) ; aadd(aCampos, {"B1_PESO"   , "N", 11, 04} )
             aadd(aCampos, {"B1_PESBRU" , "N", 11, 04} ) ; aadd(aCampos, {"B1_CUSTOR" , "N", 14, 02} )
             cFileVM := "BESB1"+SubStr(cNumEmp, 1, 2)+DtoS(dDataBase)+StrTran(Time(), ':', '')
           
             /********************************************************************************************************************************/
             /*** BLOCO ALTERADO EM 13/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
             //DbCreate(cPathVM+cFileVm, aCampos, "DBFCDXADS")  
             //USE (cPathVM+cFileVM) ALIAS (cFileVM) VIA "DBFCDXADS" NEW
             oTempTbl01 := FWTemporaryTable():New( cFileVM )
             oTempTbl01:SetFields( aCampos )
             oTempTbl01:Create()
             /********************************************************************************************************************************/
//             DbUseArea(.T., "DBFCDX", cPathVM+cFileVM, cFileVM, .F.)
             DbselectArea(cFileVM)
          ElseIf nOpc == 2 // Cadastro de Transportadoras
                 aadd(aCampos, {"A4_FILIAL" , "C", 06, 00} ) ; aadd(aCampos, {"A4_COD"    , "C", 06, 00} )
                 aadd(aCampos, {"A4_NOME"   , "C", 40, 00} ) ; aadd(aCampos, {"A4_NREDUZ" , "C", 15, 00} )
                 aadd(aCampos, {"A4_VIA"    , "C", 15, 00} ) ; aadd(aCampos, {"A4_END"    , "C", 40, 00} )
                 aadd(aCampos, {"A4_MUN"    , "C", 30, 00} ) ; aadd(aCampos, {"A4_CEP"    , "C", 09, 00} )
                 aadd(aCampos, {"A4_EST"    , "C", 02, 00} ) ; aadd(aCampos, {"A4_TEL"    , "C", 15, 00} )
                 aadd(aCampos, {"A4_CGC"    , "C", 14, 00} ) ; aadd(aCampos, {"A4_TELEX"  , "C", 15, 00} )
                 aadd(aCampos, {"A4_CONTATO", "C", 15, 00} ) ; aadd(aCampos, {"A4_INSEST" , "C", 15, 00} )
                 aadd(aCampos, {"A4_EMAIL"  , "C", 30, 00} ) ; aadd(aCampos, {"A4_HPAGE"  , "C", 30, 00} )
                 aadd(aCampos, {"A4_BAIRRO" , "C", 30, 00} ) ; aadd(aCampos, {"A4_DDI"    , "C", 06, 00} )
                 aadd(aCampos, {"A4_DDD"    , "C", 03, 00} ) ; aadd(aCampos, {"A4_ENDPAD" , "C", 15, 00} )
                 aadd(aCampos, {"A4_CODBRA" , "C", 06, 00} ) ; aadd(aCampos, {"A4_CODCID" , "C", 06, 00} )
                 cFileVM := "BESA4"+SubStr(cNumEmp, 1, 2)+DtoS(dDataBase)+StrTran(Time(), ':', '')
                 /********************************************************************************************************************************/
                 /*** BLOCO ALTERADO EM 13/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                 //DbCreate(cPathVM+cFileVm, aCampos, "DBFCDXADS")  
                 //USE (cPathVM+cFileVM) ALIAS (cFileVM) VIA "DBFCDXADS" NEW
                 oTempTbl01 := FWTemporaryTable():New( cFileVM )
                 oTempTbl01:SetFields( aCampos )
                 oTempTbl01:Create()
                 /********************************************************************************************************************************/
                 //DbUseArea(.T., "DBFCDX", cPathVM+cFileVM, cFileVM, .F.)
                 DbselectArea(cFileVM)
          ElseIf nOpc == 3 // Cadastro de Borderos
                 //VldPerg2()  //LGS#20200213 - Adequação de release 12.1.25 e posteriores
                 If !Pergunte(cPerg2, .T.)
                    Return(.f.)
                 Endif
                 aadd(aCampos, {"FILIAL" , "C", 06, 00}) ; aadd(aCampos, {"BORDERO", "C", 06, 00})
                 aadd(aCampos, {"DTBORDE", "D", 08, 00}) ; aadd(aCampos, {"DTDESPA", "D", 08, 00})
                 aadd(aCampos, {"EMPRESA", "C", 02, 00}) ; aadd(aCampos, {"PEDIDO" , "C", 06, 00})
                 aadd(aCampos, {"NFISCAL", "C", 06, 00}) ; aadd(aCampos, {"CLIENTE", "C", 06, 00})
                 aadd(aCampos, {"LOJACLI", "C", 02, 00}) ; aadd(aCampos, {"RAZAO"  , "C", 40, 00})
                 aadd(aCampos, {"ENDENT" , "C", 40, 00}) ; aadd(aCampos, {"MUNENT" , "C", 25, 00})
                 aadd(aCampos, {"ESTENT" , "C", 02, 00}) ; aadd(aCampos, {"CNPJ"   , "C", 14, 00})
                 aadd(aCampos, {"INSCR"  , "C", 18, 00}) ; aadd(aCampos, {"VALMERC", "N", 14, 02})
                 aadd(aCampos, {"VALFAT" , "N", 14, 02}) ; aadd(aCampos, {"VOLUME" , "N", 06, 00})
                 aadd(aCampos, {"PLIQUI" , "N", 14, 02}) ; aadd(aCampos, {"PBRUTO" , "N", 14, 02})
                 aadd(aCampos, {"REDESP" , "C", 06, 00}) ; aadd(aCampos, {"REGIAO" , "C", 03, 00})
                 aadd(aCampos, {"CGCRED" , "C", 14, 00}) ; aadd(aCampos, {"VOLDES" , "M", 10, 00})
                 cFileVM := "B"+mv_par01
                 /********************************************************************************************************************************/
                 /*** BLOCO ALTERADO EM 13/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                 //DbCreate(cPathVM+cFileVm, aCampos, "DBFCDXADS")   
                 //USE (cPathVM+cFileVM) ALIAS (cFileVM) VIA "DBFCDXADS" NEW
                 oTempTbl01 := FWTemporaryTable():New( cFileVM )
                 oTempTbl01:SetFields( aCampos )
                 oTempTbl01:Create()
                 /********************************************************************************************************************************/
                 //DbUseArea(.T., "DBFCDX", cPathVM+cFileVM, cFileVM, .F.)
                 DbSelectArea(cFileVM)
          Endif
       ElseIf nExpImp == 2 // Exportação de dados da Viamix para Brasilux
              If nOpc == 1 // Cadastro de Produtos - Não aplicável
              ElseIf nOpc == 2 // Cadastro de Transportadoras
                     aadd(aCampos, {"A4_FILIAL" , "C", 06, 00} ) ; aadd(aCampos, {"A4_COD"    , "C", 06, 00} )
                     aadd(aCampos, {"A4_OCORREN", "C", 01, 00} ) ; aadd(aCampos, {"A4_QUALIDA", "C", 01, 00} )
                     aadd(aCampos, {"A4_CODBRA" , "C", 06, 00} ) ; aadd(aCampos, {"A4_REGIAO" , "C", 06, 00} )
                     cFileVM := "VESA4"+SubStr(cNumEmp, 1, 2)+DtoS(dDataBase)+StrTran(Time(), ':', '')
                     /********************************************************************************************************************************/
                     /*** BLOCO ALTERADO EM 13/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                     //DbCreate(cPathVM+cFileVm, aCampos, "DBFCDXADS")  
                     //USE (cPathVM+cFileVM) ALIAS (cFileVM) VIA "DBFCDXADS" NEW
                     oTempTbl01 := FWTemporaryTable():New( cFileVM )
                     oTempTbl01:SetFields( aCampos )
                     oTempTbl01:Create()
                     /********************************************************************************************************************************/
                     //DbUseArea(.T., "DBFCDX", cPathVM+cFileVM, cFileVM, .F.)
                     DbselectArea(cFileVM)
              ElseIf nOpc ==3 // Cadastro de Borderos
                     aadd(aCampos, {"ZZ0_FILIAL", "C", 06, 00} ) ; aadd(aCampos, {"ZZ0_BORDER", "C", 06, 00} )
                     aadd(aCampos, {"ZZ0_DTBORD", "D", 08, 00} ) ; aadd(aCampos, {"ZZ0_DTDESP", "D", 08, 00} )
                     aadd(aCampos, {"ZZ0_EMPRES", "C", 02, 00} ) ; aadd(aCampos, {"ZZ0_PEDIDO", "C", 06, 00} )
                     aadd(aCampos, {"ZZ0_NFISCA", "C", 06, 00} ) ; aadd(aCampos, {"ZZ0_REDESP", "C", 06, 00} )
                     aadd(aCampos, {"ZZ0_CGCRED", "C", 14, 00} ) ; aadd(aCampos, {"ZZ0_NOMRED", "C", 30, 00} )
                     aadd(aCampos, {"ZZ0_CLIENT", "C", 06, 00} ) ; aadd(aCampos, {"ZZ0_LOJACL", "C", 02, 00} )
                     aadd(aCampos, {"ZZ0_RAZAO" , "C", 40, 00} ) ; aadd(aCampos, {"ZZ0_ENDENT", "C", 40, 00} )
                     aadd(aCampos, {"ZZ0_MUNENT", "C", 30, 00} ) ; aadd(aCampos, {"ZZ0_ESTENT", "C", 02, 00} )
                     aadd(aCampos, {"ZZ0_CNPJ"  , "C", 14, 00} ) ; aadd(aCampos, {"ZZ0_INSCR" , "C", 18, 00} )
                     aadd(aCampos, {"ZZ0_VALMER", "N", 14, 02} ) ; aadd(aCampos, {"ZZ0_VOLUME", "N", 06, 00} )
                     aadd(aCampos, {"ZZ0_PLIQUI", "N", 14, 02} ) ; aadd(aCampos, {"ZZ0_PBRUTO", "N", 14, 02} )
                     aadd(aCampos, {"ZZ0_REGIAO", "C", 03, 00} ) ; aadd(aCampos, {"ZZ0_FLAG"  , "C", 01, 00} )
                     aadd(aCampos, {"ZZ0_CTRC"  , "C", 06, 00} ) ; aadd(aCampos, {"ZZ0_ENTREG", "D", 08, 02} )
                     aadd(aCampos, {"ZZ0_MOTIVO", "C", 01, 00} ) ; aadd(aCampos, {"ZZ0_VEICUL", "C", 08, 00} )
                     aadd(aCampos, {"ZZ0_COLETA", "C", 01, 00} ) ; aadd(aCampos, {"ZZ0_MOTORI", "C", 06, 00} )
                     aadd(aCampos, {"ZZ0_VALFAT", "N", 14, 02} )
                     cFileVM := "VEZZ0"+SubStr(cNumEmp, 1, 2)+DtoS(dDataBase)+StrTran(Time(), ':', '')
                     /********************************************************************************************************************************/
                     /*** BLOCO ALTERADO EM 13/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
                     //DbCreate(cPathVM+cFileVm, aCampos, "DBFCDXADS")   
                     //USE (cPathVM+cFileVM) ALIAS (cFileVM) VIA "DBFCDXADS" NEW
                     oTempTbl01 := FWTemporaryTable():New( cFileVM )
                     oTempTbl01:SetFields( aCampos )
                     oTempTbl01:Create()
                     /********************************************************************************************************************************/
                     //DbUseArea(.T., "DBFCDX", cPathVM+cFileVM, cFileVM, .F.)
                     DbselectArea(cFileVM)
              Endif
       //ElseIf nExpImp == 3 // Importação de dados para Brasilux.
              //If nOpc == 1 // Cadastro de Produtos - Não se aplica
              //ElseIf nOpc == 2 // Cadastro de Transportadoras
                     //cFileVM := "VESA4"
                     //If File(cPathVM+cFileVM+".DBF")
                     //   DbUseArea(.T.,, cPathVM+cFileVM, cFileVM, .F.)
                     //   If !Used()
                     //      MsgBox('Houve problemas na abertura do arquivo !!!','Atenção','ALERT')
                     //      Return
                     //   Endif
                     //Else
                     //   MsgBox("Atenção o arquivo não foi encontrado !!!", "Atenção", "STOP")                     
                     //Endif
              //ElseIf nOpc == 3 // Cadastro de Borderos
                     //cFileVM := "VEZZ0"
                     //If File(cPathVM+cFileVM+".DBF")
                     //   DbUseArea(.T., , cPathVM+cFileVM, cFileVM, .F.)
                     //   If !Used()
                     //      MsgBox('Houve problemas na abertura do arquivo !!!','Atenção','ALERT')
                     //      Return
                     //   Endif
                     //Else
                     //   MsgBox("Atenção o arquivo não foi encontrado !!!", "Atenção", "STOP")
                     //Endif
              //Endif
       ElseIf nExpImp == 4 // Importação de dados para Viamix.
              If nOpc == 1 // Cadastro de Produtos
                 cFileVM := "BESB1"
                 //LGS#20200213 - Adequação de release 12.1.25 e posteriores
                 //If File(cPathVM+cFileVM+".DBF")
                 If Select( cFileVM ) < 0
                    //DbUseArea(.T.,"DBFCDXADS", cPathVM+cFileVM, cFileVM, .F.)
                    If !Used()
                       MsgBox('Houve problemas na abertura do arquivo !!!','Atenção','ALERT')
                       Return
                    Endif
                 Else
                    MsgBox("Atenção o arquivo não foi encontrado !!!", "Atenção", "STOP")
                    Return
                 Endif
              ElseIf nOpc == 2 // Cadastro de Transportadora
                     cFileVM := "BESA4"
                     //LGS#20200213 - Adequação de release 12.1.25 e posteriores
                     //If File(cPathVM+cFileVM+".DBF")
                     If Select( cFileVM ) < 0
                        //DbUseArea(.T.,"DBFCDXADS", cPathVM+cFileVM, cFileVM, .F.)
                        If !Used()
                           MsgBox('Houve problemas na abertura do arquivo !!!','Atenção','ALERT')
                           Return
                        Endif
                     Else
                        MsgBox("Atenção o arquivo não foi encontrado !!!", "Atenção", "STOP")
                        Return
                     Endif
              ElseIf nOpc == 3 // Cadastro de Borderos
                     //VldPerg2() //LGS#20200213 - Adequação de release 12.1.25 e posteriores
                     If !Pergunte(cPerg2, .T.)
                        Return(.f.)
                     Endif
                     cFileVM := "B"+mv_par01
                     //LGS#20200213 - Adequação de release 12.1.25 e posteriores
                     //If File(cPathVM+cFileVM+".DBF")
                     If Select( cFileVM ) < 0
                        //DbUseArea(.T.,"DBFCDXADS", cPathVM+cFileVM, cFileVM, .F.)
                        If !Used()
                           MsgBox('Houve problemas na abertura do arquivo !!!','Atenção','ALERT')
                           Return
                        Endif
                     Else
                        MsgBox("Atenção o arquivo não foi encontrado !!!", "Atenção", "STOP")
                        Return
                     Endif
              Endif
       Endif
Return(.t.)

/**************************************************************************************/
/*** EXP024_1 - Exportação de dados da empresa BRASILUX para VIAMIX e vice-versa.   ***/
/**************************************************************************************/
Static Function EXP024_1(nExpImp, nOpc)
       Local cQry := ""
       Local nX
       If nExpImp == 1 //Exportação de dados da Brasilux para Viamix
          If nOpc == 1 //Cadastro de Produtos
             cQry := ""
             cQry += "SELECT SB1.B1_FILIAL, SB1.B1_COD    , SB1.B1_DESC  , SB1.B1_TIPO   , SB1.B1_LOCPAD , SB1.B1_UM    , "
             cQry += "       SB1.B1_PRV1  , SB1.B1_PERINT , SB1.B1_LCRMIN, SB1.B1_LUCROM2, SB1.B1_LUCRO  , SB1.B1_LUCRO2, "
             cQry += "       SB1.B1_CONINI, SB1.B1_POSIPI , SB1.B1_PICM  , SB1.B1_IPI    , SB1.B1_DTREFP1, SB1.B1_PESO  , "
             cQry += "       SB1.B1_PESBRU, SB1.B1_CUSTOR "
             cQry += "FROM SB1010 SB1 WITH (NOLOCK) "
             cQry += "WHERE SB1.B1_FILIAL   = '"+xFilial("SB1")+"' "
             cQry += "  AND SB1.D_E_L_E_T_  = '' "
             cQry += "  AND SB1.B1_TIPO     = 'PA' "
             cQry += "  AND LEN(SB1.B1_COD) = 12 "
             cQry += "ORDER BY SB1.B1_FILIAL, SB1.B1_COD "
             TCQUERY cQry ALIAS "TCQ" NEW
             DbselectArea("TCQ")
             While !Eof()
                   RecLock(cFileVm, .T.)
                      For nX := 1 To FCount()
                          nCpo := Alltrim(FieldName(nX))
                          If nCpo $ "B1_CONINI"
                             FieldPut(nX, cTod(SubStr(TCQ->B1_CONINI, 7, 2)+'/'+SubStr(TCQ->B1_CONINI, 5, 2)+'/'+SubStr(TCQ->B1_CONINI, 1, 4)))
                          ElseIf nCpo $ "B1_DTREFP1"
                                 FieldPut(nX, cTod(SubStr(TCQ->B1_DTREFP1, 7, 2)+'/'+SubStr(TCQ->B1_DTREFP1, 5, 2)+'/'+SubStr(TCQ->B1_DTREFP1, 1, 4)) )
                          ElseIf nCpo $ "B1_LOCPAD"
                                 FieldPut(nX, "01")
                          Else
                             FieldPut(nX, &("TCQ->"+(Eval(bCampo, nX))))
                          Endif
                      Next
                   MsUnLock()
                   DbSelectArea("TCQ")
                   DbSkip()
             Enddo
          ElseIf nOpc == 2 //Cadastro de Transportadoras
                 cQry := ""
                 cQry += "SELECT SA4.A4_FILIAL , SA4.A4_COD    , SA4.A4_NOME  , SA4.A4_NREDUZ, SA4.A4_VIA   , SA4.A4_END    , "
                 cQry += "       SA4.A4_MUN    , SA4.A4_CEP    , SA4.A4_EST   , SA4.A4_TEL   , SA4.A4_CGC   , SA4.A4_TELEX  , "
                 cQry += "       SA4.A4_CONTATO, SA4.A4_INSEST , SA4.A4_EMAIL , SA4.A4_HPAGE , SA4.A4_BAIRRO, SA4.A4_DDI    , "
                 cQry += "       SA4.A4_DDD    , SA4.A4_ENDPAD , SA4.A4_COD AS A4_CODBRA     , SA4.A4_CODCID "
                 cQry += "FROM SA4010 SA4 WITH (NOLOCK) "
                 cQry += "WHERE SA4.A4_FILIAL  = '"+xFilial("SA4")+"' "
                 cQry += "  AND SA4.D_E_L_E_T_ = '' "
                 cQry += "ORDER BY SA4.A4_FILIAL, SA4.A4_COD "
                 TCQUERY cQry ALIAS "TCQ" NEW
                 DbselectArea("TCQ")
                 While !Eof()
                       RecLock(cFileVm, .T.)
                          For nX := 1 To FCount()
                              nCpo := Alltrim(FieldName(nX))
                              FieldPut(nX, &("TCQ->"+(Eval(bCampo, nX))))
                          Next
                       MsUnLock()
                       DbSelectArea("TCQ")
                       DbSkip()
                 Enddo
          Elseif nOpc == 3 //Cadastro de Borderos
                 cQry := ""
                 cQry += "SELECT SZA.ZA_FILIAL                AS FILIAL, "
                 cQry += "       SZA.ZA_CODIGO                AS BORDERO, "
                 cQry += "       SZA.ZA_EMISSAO               AS DTBORDE, "
                 cQry += "       SZA.ZA_DTDESPA               AS DTDESPA, "
                 cQry += "       SUBSTRING(SZB.ZB_PEDIDO,1,2) AS EMPRESA, "
                 cQry += "       SUBSTRING(SZB.ZB_PEDIDO,3,6) AS PEDIDO, "
                 cQry += "       SF2.F2_DOC                   AS NFISCAL, "
                 cQry += "       SF2.F2_CLIENTE               AS CLIENTE, "
                 cQry += "       SF2.F2_LOJA                  AS LOJACLI, "
                 cQry += "       SA1.A1_NOME                  AS RAZAO, "
                 cQry += "       CASE WHEN SA1.A1_ENDENT = '' THEN SA1.A1_END ELSE SA1.A1_ENDENT END AS ENDENT, "
                 cQry += "       CASE WHEN SA1.A1_MUNE   = '' THEN SA1.A1_MUN ELSE SA1.A1_MUNE   END AS MUNENT, "
                 cQry += "       CASE WHEN SA1.A1_ESTE   = '' THEN SA1.A1_EST ELSE SA1.A1_ESTE   END AS ESTENT, "
                 cQry += "       SA1.A1_CGC                   AS CNPJ, "
                 cQry += "       SA1.A1_INSCR                 AS INSCR, "
                 cQry += "       SF2.F2_EMISSAO               AS DTNOTAF, "
                 cQry += "       SF2.F2_VALMERC               AS VALMERC, "
                 cQry += "       SF2.F2_VALFAT                AS VALFAT , "
                 cQry += "       SF2.F2_VOLUME1               AS VOLUME, "
                 cQry += "       SF2.F2_PLIQUI                AS PLIQUI, "
                 cQry += "       SF2.F2_PBRUTO                AS PBRUTO, "
                 cQry += "       SF2.F2_REDESP                AS REDESP, "
                 cQry += "       SZ7.Z7_REGIAO                AS REGIAO, "
                 cQry += "       SA4.A4_CGC                   AS CGCRED "  
                 cQry += "FROM SZA010 SZA WITH (NOLOCK) "
                 cQry += "LEFT OUTER JOIN SZB010 SZB WITH (NOLOCK) ON SZB.ZB_FILIAL = SZA.ZA_FILIAL  AND SZB.ZB_CODIGO  = SZA.ZA_CODIGO AND SZB.D_E_L_E_T_ = '' "
                 cQry += "LEFT OUTER JOIN SF2010 SF2 WITH (NOLOCK) ON SF2.F2_FILIAL = SZA.ZA_FILIAL  AND SF2.F2_PEDIDO  = SUBSTRING(SZB.ZB_PEDIDO,3,6) AND SF2.D_E_L_E_T_ = '' "
                 cQry += "LEFT OUTER JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_COD    = SF2.F2_CLIENTE AND SA1.D_E_L_E_T_ = '' "
                 cQry += "LEFT OUTER JOIN SZ7010 SZ7 WITH (NOLOCK) ON '"+xFilial("SZ7")+"' = SZ7.Z7_FILIAL  AND SA1.A1_CODCID  = SZ7.Z7_COD AND SZ7.D_E_L_E_T_ = '' "
                 cQry += "LEFT OUTER JOIN SA4010 SA4 WITH (NOLOCK) ON '"+xFilial("SA4")+"' = SA4.A4_FILIAL  AND SA4.A4_COD     = SF2.F2_REDESP AND SA4.D_E_L_E_T_ = '' "
                 cQry += "WHERE SZA.D_E_L_E_T_ = '' "
                 cQry += "  AND SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
                 cQry += "  AND SZA.ZA_CODIGO  = '"+mv_par01+"' "
                 cQry += "  AND SUBSTRING(SZB.ZB_PEDIDO,1,2) = '01' "
                 //cQry += "  AND SZ7.Z7_REGIAO  = '999' "
                 cQry += "  ORDER BY SF2.F2_REDESP "
                 TCQUERY cQry NEW ALIAS "TCQ" 
                 DbselectArea("TCQ")
                 While !Eof()
                       aEmba   := {}
                       cRetVol := ""
                       cRetVol := fDetVol(aEmba)
                       RecLock(cFileVm, .T.)
                          For nX := 1 To FCount()
                              nCpo := Alltrim(FieldName(nX))
                              If nCpo $ "DTBORDE"
                                 FieldPut(nX, cTod(SubStr(TCQ->DTBORDE,7,2)+'/'+SubStr(TCQ->DTBORDE,5,2)+'/'+SubStr(TCQ->DTBORDE,1,4)))
                              ElseIf nCpo $ "DTDESPA" 
                                     FieldPut(nX, mv_par02)
                              ElseIf nCpo $ "VOLDES"
                                     FieldPut(nX, cRetVol)
                              Else
                                 FieldPut(nX, &("TCQ->"+(Eval(bCampo, nX))))
                              Endif
                          Next
                       MsUnLock()
                       DbSelectArea("TCQ")
                       DbSkip()
                 Enddo
          Endif
       ElseIf nExpImp == 2 //Exportação de dados da Viamix para Brasilux
              If nOpc == 1 //Cadastro de Produtos - Não aplicável
              ElseIf nOpc == 2 //Cadastro de Transportadoras
                     cQry := ""
                     cQry += "SELECT SA4.A4_FILIAL , SA4.A4_COD    , SA4.A4_OCORREN, SA4.A4_QUALIDA, SA4.A4_CODBRA, SA4.A4_REGIAO "
                     cQry += "FROM SA4040 SA4 WITH (NOLOCK) "
                     cQry += "WHERE SA4.A4_FILIAL  = '"+xFilial("SA4")+"'"
                     cQry += "  AND SA4.D_E_L_E_T_ = '' "
                     cQry += "ORDER BY SA4.A4_FILIAL, SA4.A4_COD "
                     TCQUERY cQry ALIAS "TCQ" NEW
                     DbselectArea("TCQ")
                     While !Eof()
                           RecLock(cFileVm, .T.)
                              For nX := 1 To FCount()
                                  nCpo := Alltrim(FieldName(nX))
                                  FieldPut(nX, &("TCQ->"+(Eval(bCampo, nX))))
                              Next
                           MsUnLock()
                           DbSelectArea("TCQ")
                           DbSkip()
                     Enddo
              ElseIf nOpc == 3 //Cadastro de Borderos
                     cQry += "SELECT * "
                     cQry += "FROM ZZ0040 ZZ0 WITH (NOLOCK) "
                     cQry += "WHERE ZZ0.ZZ0_FILIAL = '"+xFilial("ZZ0")+"' "
                     cQry += "  AND ZZ0.D_E_L_E_T_ = '' "
                     cQry += "  AND ZZ0.ZZ0_ENVIA <> 'S' "
                     TCQUERY cQry NEW ALIAS "TCQ" 
                     DbselectArea("TCQ")
                     While !Eof()
                           RecLock(cFileVm, .T.)
                              For nX := 1 To FCount()
                                  nCpo := Alltrim(FieldName(nX))
                                  If nCpo $ "ZZ0_ENTREG"
                                     FieldPut(nX, cTod(SubStr(TCQ->ZZ0_ENTREG,7,2)+'/'+SubStr(TCQ->ZZ0_ENTREG,5,2)+'/'+SubStr(TCQ->ZZ0_ENTREG,1,4)))
                                  ElseIf nCpo $ "ZZ0_DTBORD"
                                         FieldPut(nX, cTod(SubStr(TCQ->ZZ0_DTBORD,7,2)+'/'+SubStr(TCQ->ZZ0_DTBORD,5,2)+'/'+SubStr(TCQ->ZZ0_DTBORD,1,4)))
                                  ElseIf nCpo $ "ZZ0_DTDESP"
                                         FieldPut(nX, cTod(SubStr(TCQ->ZZ0_DTDESP,7,2)+'/'+SubStr(TCQ->ZZ0_DTDESP,5,2)+'/'+SubStr(TCQ->ZZ0_DTDESP,1,4)))
                                  ElseIf nCpo $ "ZZ0_NOMRED"
                                  Else
                                     FieldPut(nX, &("TCQ->"+(Eval(bCampo, nX))))
                                  Endif
                              Next
                           MsUnLock()
                           If (Empty(TCQ->ZZ0_MOTIVO) .and. !Empty(TCQ->ZZ0_ENTREG))
                              DbSelectArea("ZZ0")
                              DbSetOrder(2)
                              DbSeek(xFilial("ZZ0")+TCQ->ZZ0_BORDER+TCQ->ZZ0_NFISCA,.t.)
                              If Found()
                                 RecLock("ZZ0",.f.)
                                    ZZ0->ZZ0_ENVIA = 'S'
                                 MsUnLock()
                              Endif
                           Endif
                           DbSelectArea("TCQ")
                           DbSkip()
                     Enddo
              Endif
       Endif
       DbselectArea("TCQ")
       DbCloseArea()
       DbSelectArea(cFileVM)
       DbCloseArea()
       oTempTbl01:Delete()
Return(.t.)

/**************************************************************************************/
/*** IMP024_1 - Exportação de dados da empresa BRASILUX para VIAMIX e vice-versa.   ***/
/**************************************************************************************/
Static Function IMP024_1(nExpImp, nOpc)
       //Local cQry := ""
       If nExpImp == 3 //Importação de dados para Brasilux
          //If nOpc == 1 //Cadastro de Produtos - Não se aplica.
          //ElseIf nOpc == 2 //Cadastro de Transportadoras
                 //DbSelectArea(cFileVM)
                 //DbGotop()
                 //While !Eof()
                       //DbSelectArea("SA4")
                       //DbSetOrder(1)
                       //DbSeek(xFilial("SA4")+&(cFileVM+"->A4_CODBRA"),.t.)
                       //If Found()
                          //RecLock("SA4",.f.)
                             //SA4->A4_OCORREN := &(cFileVM+"->A4_OCORREN")
                             //SA4->A4_QUALIDA := &(cFileVM+"->A4_QUALIDA")
                             //SA4->A4_REGIAO  := &(cFileVM+"->A4_REGIAO")
                          //MsUnLock()
                       //Endif
                       //DbSelectArea(cFileVM)
                       //DbSkip()
                 //Enddo
          //ElseIf nOpc == 3 //Cadastro de Borderos
                 //nCont := 0
                 //DbSelectArea(cFileVM)
                 //DbGotop()
                 //While !Eof()
                       //DbSelectArea("ZZ0")
                       //DbSetOrder(2)
                       //DbSeek(xFilial("ZZ0")+&(cFileVM+"->ZZ0_BORDER")+&(cFileVM+"->ZZ0_NFISCA"),.t.)
                       //If Found()
                          //nCont += 1
                          //RecLock("ZZ0",.f.)
                             //ZZ0->ZZ0_REDESP := &(cFileVM+"->ZZ0_REDESP")
                             //ZZ0->ZZ0_CGCRED := &(cFileVM+"->ZZ0_CGCRED")
                             //ZZ0->ZZ0_ENTREG := &(cFileVM+"->ZZ0_ENTREG")
                             //ZZ0->ZZ0_MOTIVO := &(cFileVM+"->ZZ0_MOTIVO")
                             //ZZ0->ZZ0_VEICUL := &(cFileVM+"->ZZ0_VEICUL")
                             //ZZ0->ZZ0_MOTORI := &(cFileVM+"->ZZ0_MOTORI")
                             //ZZ0->ZZ0_COLETA := &(cFileVM+"->ZZ0_COLETA")
                             //ZZ0->ZZ0_FLAG   := &(cFileVM+"->ZZ0_FLAG")
                             //ZZ0->ZZ0_CTRC   := &(cFileVM+"->ZZ0_CTRC")
                       //Else
                          //RecLock("ZZ0",.t.)
                             //ZZ0->ZZ0_FILIAL := &(cFileVM+"->ZZ0_FILIAL")
                             //ZZ0->ZZ0_BORDER := &(cFileVM+"->ZZ0_BORDER")
                             //ZZ0->ZZ0_DTBORD := &(cFileVM+"->ZZ0_DTBORD")
                             //ZZ0->ZZ0_DTDESP := &(cFileVM+"->ZZ0_DTDESP")
                             //ZZ0->ZZ0_EMPRES := &(cFileVM+"->ZZ0_EMPRES")
                             //ZZ0->ZZ0_PEDIDO := &(cFileVM+"->ZZ0_PEDIDO")
                             //ZZ0->ZZ0_NFISCA := &(cFileVM+"->ZZ0_NFISCA")
                             //ZZ0->ZZ0_REDESP := &(cFileVM+"->ZZ0_REDESP")
                             //ZZ0->ZZ0_CGCRED := &(cFileVM+"->ZZ0_CGCRED")
                             //ZZ0->ZZ0_CLIENT := &(cFileVM+"->ZZ0_CLIENT")
                             //ZZ0->ZZ0_LOJACL := &(cFileVM+"->ZZ0_LOJACL")
                             //ZZ0->ZZ0_RAZAO  := &(cFileVM+"->ZZ0_RAZAO")
                             //ZZ0->ZZ0_ENDENT := &(cFileVM+"->ZZ0_ENDENT")
                             //ZZ0->ZZ0_MUNENT := &(cFileVM+"->ZZ0_MUNENT")
                             //ZZ0->ZZ0_ESTENT := &(cFileVM+"->ZZ0_ESTENT")
                             //ZZ0->ZZ0_CNPJ   := &(cFileVM+"->ZZ0_CNPJ")
                             //ZZ0->ZZ0_INSCR  := &(cFileVM+"->ZZ0_INSCR")
                             //ZZ0->ZZ0_VALMER := &(cFileVM+"->ZZ0_VALMERC")
                             //ZZ0->ZZ0_VOLUME := &(cFileVM+"->ZZ0_VOLUME")
                             //ZZ0->ZZ0_PLIQUI := &(cFileVM+"->ZZ0_PLIQUI")
                             //ZZ0->ZZ0_PBRUTO := &(cFileVM+"->ZZ0_PBRUTO")
                             //ZZ0->ZZ0_REGIAO := &(cFileVM+"->ZZ0_REGIAO")
                             //ZZ0->ZZ0_FLAG   := &(cFileVM+"->ZZ0_FLAG")
                             //ZZ0->ZZ0_CTRC   := &(cFileVM+"->ZZ0_CTRC")
                             //ZZ0->ZZ0_ENTREG := &(cFileVM+"->ZZ0_ENTREG")
                             //ZZ0->ZZ0_MOTIVO := &(cFileVM+"->ZZ0_MOTIVO")
                             //ZZ0->ZZ0_VEICUL := &(cFileVM+"->ZZ0_VEICUL")
                             //ZZ0->ZZ0_COLETA := &(cFileVM+"->ZZ0_COLETA")
                             //ZZ0->ZZ0_MOTORI := &(cFileVM+"->ZZ0_MOTORI")
                             //ZZ0->ZZ0_VALFAT := &(cFileVM+"->ZZ0_VALFAT")
                       //Endif
                          //MsUnLock()
                       //DbSelectArea(cFileVM)
                       //DbSkip()
                 //Enddo
          //Endif
       ElseIf nExpImp == 4 //Importação de dados para Viamix
              If nOpc == 1 //Cadastro de Produtos
                 DbSelectArea(cFileVM)
                 DbGotop()
                 While !Eof()
                       DbSelectArea("SB1")
                       DbSetOrder(1)
                       DbSeek(xFilial("SB1")+BESB1->B1_COD, .t.)
                       If Found()
                          RecLock("SB1", .f.)
                       Else
                          RecLock("SB1", .t.)
                             SB1->B1_FILIAL  := BESB1->B1_FILIAL
                             SB1->B1_COD     := BESB1->B1_COD
                       Endif
                          SB1->B1_DESC    := BESB1->B1_DESC
                          SB1->B1_TIPO    := BESB1->B1_TIPO
                          SB1->B1_LOCPAD  := '01'
                          SB1->B1_UM      := BESB1->B1_UM
                          SB1->B1_PRV1    := BESB1->B1_PRV1
                          SB1->B1_PERINT  := BESB1->B1_PERINT
                          SB1->B1_LCRMIN  := BESB1->B1_LCRMIN
                          SB1->B1_LUCRO   := BESB1->B1_LUCRO
                          SB1->B1_CONINI  := BESB1->B1_CONINI
                          SB1->B1_POSIPI  := BESB1->B1_POSIPI
                          SB1->B1_PICM    := BESB1->B1_PICM
                          SB1->B1_IPI     := BESB1->B1_IPI
                          SB1->B1_DTREFP1 := BESB1->B1_DTREFP1
                          SB1->B1_PESO    := BESB1->B1_PESO
                          SB1->B1_PESBRU  := BESB1->B1_PESBRU
                          SB1->B1_CUSTOR  := BESB1->B1_CUSTOR
                       MsUnLock()
                       DbSelectArea(cFileVM)
                       DbSkip()
                 Enddo
              ElseIf nOpc == 2 //Cadastro de Transportadoras
                     DbSelectArea(cFileVM)
                     DbGotop()
                     While !Eof()
                           DbSelectArea("SA4")
                           DbSetOrder(4)
                           DbSeek(xFilial("SA4")+BESA4->A4_COD, .t.)
                           If Found()
                              RecLock("SA4", .f.)
                           Else
                              RecLock("SA4", .t.)
                              SA4->A4_FILIAL  := BESA4->A4_FILIAL
                              SA4->A4_COD     := GETSXENUM("SA4","A4_COD")
                           Endif
                              SA4->A4_NOME    := BESA4->A4_NOME
                              SA4->A4_NREDUZ  := BESA4->A4_NREDUZ
                              SA4->A4_VIA     := BESA4->A4_VIA
                              SA4->A4_END     := BESA4->A4_END
                              SA4->A4_MUN     := BESA4->A4_MUN
                              SA4->A4_CEP     := BESA4->A4_CEP
                              SA4->A4_EST     := BESA4->A4_EST
                              SA4->A4_TEL     := BESA4->A4_TEL
                              SA4->A4_CGC     := BESA4->A4_CGC
                              SA4->A4_TELEX   := BESA4->A4_TELEX
                              SA4->A4_CONTATO := BESA4->A4_CONTATO
                              SA4->A4_INSEST  := BESA4->A4_INSEST
                              SA4->A4_EMAIL   := BESA4->A4_EMAIL
                              SA4->A4_HPAGE   := BESA4->A4_HPAGE
                              SA4->A4_BAIRRO  := BESA4->A4_BAIRRO
                              SA4->A4_CODBRA  := BESA4->A4_COD
                              SA4->A4_CODCID  := BESA4->A4_CODCID
                           MsUnLock()
                           DbSelectArea(cFileVM)
                           DbSkip()
                     Enddo
              ElseIf nOpc == 3 //Cadastro de Borderos
                     nCont := 0
                     DbSelectArea(cFileVM)
                     DbGotop()
                     While !Eof()
                           If &(cFileVM+"->BORDERO") == mv_par01
                              DbSelectArea("ZZ0")
                              DbSetOrder(3)
                              DbSeek(xFilial("ZZ0")+&(cFileVM+"->NFISCAL"),.t.)
                              If Found()
                                 nCont += 1
                                 RecLock("ZZ0",.f.)
                                    If MsgYesNo("O bordero: "+&(cFileVM+"->BORDERO")+", nota: "+&(cFileVM+"->NFISCAL")+" já existe. Continua ?","Pergunta")
                                       ZZ0->ZZ0_BORDER := &(cFileVM+"->BORDERO")
                                       ZZ0->ZZ0_DTBORD := &(cFileVM+"->DTBORDE")
                                       ZZ0->ZZ0_DTDESP := &(cFileVM+"->DTDESPA")
                                       ZZ0->ZZ0_EMPRES := &(cFileVM+"->EMPRESA")
                                       ZZ0->ZZ0_PEDIDO := &(cFileVM+"->PEDIDO")
                                       ZZ0->ZZ0_NFISCA := &(cFileVM+"->NFISCAL")
                                       ZZ0->ZZ0_CLIENT := &(cFileVM+"->CLIENTE")
                                       ZZ0->ZZ0_LOJACL := &(cFileVM+"->LOJACLI")
                                       ZZ0->ZZ0_RAZAO  := &(cFileVM+"->RAZAO")
                                       ZZ0->ZZ0_ENDENT := &(cFileVM+"->ENDENT")
                                       ZZ0->ZZ0_MUNENT := &(cFileVM+"->MUNENT")
                                       ZZ0->ZZ0_ESTENT := &(cFileVM+"->ESTENT")
                                       ZZ0->ZZ0_CNPJ   := &(cFileVM+"->CNPJ")
                                       ZZ0->ZZ0_INSCR  := &(cFileVM+"->INSCR")
                                       ZZ0->ZZ0_VALMER := &(cFileVM+"->VALMERC")
                                       ZZ0->ZZ0_VOLUME := &(cFileVM+"->VOLUME")
                                       ZZ0->ZZ0_PLIQUI := &(cFileVM+"->PLIQUI")
                                       ZZ0->ZZ0_PBRUTO := &(cFileVM+"->PBRUTO")
                                       ZZ0->ZZ0_REDESP := &(cFileVM+"->REDESP")
                                       ZZ0->ZZ0_REGIAO := &(cFileVM+"->REGIAO")
                                       ZZ0->ZZ0_CGCRED := &(cFileVM+"->CGCRED")
                                       ZZ0->ZZ0_VALFAT := &(cFileVM+"->VALFAT")
                                       ZZ0->ZZ0_VOLDES := &(cFileVM+"->VOLDES")
                                    Endif
                              Else
                                 RecLock("ZZ0",.t.)
                                    ZZ0->ZZ0_FILIAL := &(cFileVM+"->FILIAL")
                                    ZZ0->ZZ0_BORDER := &(cFileVM+"->BORDERO")
                                    ZZ0->ZZ0_DTBORD := &(cFileVM+"->DTBORDE")
                                    ZZ0->ZZ0_DTDESP := &(cFileVM+"->DTDESPA")
                                    ZZ0->ZZ0_EMPRES := &(cFileVM+"->EMPRESA")
                                    ZZ0->ZZ0_PEDIDO := &(cFileVM+"->PEDIDO")
                                    ZZ0->ZZ0_NFISCA := &(cFileVM+"->NFISCAL")
                                    ZZ0->ZZ0_CLIENT := &(cFileVM+"->CLIENTE")
                                    ZZ0->ZZ0_LOJACL := &(cFileVM+"->LOJACLI")
                                    ZZ0->ZZ0_RAZAO  := &(cFileVM+"->RAZAO")
                                    ZZ0->ZZ0_ENDENT := &(cFileVM+"->ENDENT")
                                    ZZ0->ZZ0_MUNENT := &(cFileVM+"->MUNENT")
                                    ZZ0->ZZ0_ESTENT := &(cFileVM+"->ESTENT")
                                    ZZ0->ZZ0_CNPJ   := &(cFileVM+"->CNPJ")
                                    ZZ0->ZZ0_INSCR  := &(cFileVM+"->INSCR")
                                    ZZ0->ZZ0_VALMER := &(cFileVM+"->VALMERC")
                                    ZZ0->ZZ0_VOLUME := &(cFileVM+"->VOLUME")
                                    ZZ0->ZZ0_PLIQUI := &(cFileVM+"->PLIQUI")
                                    ZZ0->ZZ0_PBRUTO := &(cFileVM+"->PBRUTO")
                                    ZZ0->ZZ0_REDESP := &(cFileVM+"->REDESP")
                                    ZZ0->ZZ0_REGIAO := &(cFileVM+"->REGIAO")
                                    ZZ0->ZZ0_CGCRED := &(cFileVM+"->CGCRED")
                                    ZZ0->ZZ0_VALFAT := &(cFileVM+"->VALFAT")
                                    ZZ0->ZZ0_VOLDES := &(cFileVM+"->VOLDES")
                              Endif
                              MsUnLock()
                           Endif
                           DbSelectArea(cFileVM)
                           DbSkip()
                     Enddo
              Endif
       Endif
       DbSelectArea(cFileVM)
       DbCloseArea()
       oTempTbl01:Delete()
Return

/**************************************************************************************/
/*** FENVARQ - Envio de e-mails com arquivos anexos.                                ***/
/**************************************************************************************/
Static Function fEnvArq(nExpImp, nOpc, cFileVM, cPathVM)   
Local cMensagem
       If nExpImp == 2
          cSerFTP   := 'ftp.brasilux.com.br'
          nPorFTP   := 21
          cUseFTP   := 'viamix'
          cPatFTP   := '\VIAMIX\
          cPasFTP   := '6d8de338sf'
          lConnect  := .f.
          lUpLoad   := .f.
          lFireWall := .F.
          lConnect := FTPConnect( cSerFTP, nPorFTP, cUseFTP, cPasFTP)
          If !lConnect
             MsgBox("Falha de conexão ao servidor FTP...", "OK", "STOP" )
             Return
          Else
             lUpLoad  := FTPUpLoad( cPathVM+cFileVM, cFileVM )
             If !lUpLoad
                MsgBox("Falha de envio de arquivo para o servidor FTP...", "OK", "STOP" )
             Else
                MsgBox("Arquivo enviado com sucesso!", "Informação", "INFO")
             Endif
             lConnect := !FTPDisconnect()
             If lConnect
                MsgBox("Falha ao tentar desconectar", "OK", "STOP" )
             Endif
          Endif
          /***********************************************************/
       Else
          cServer   := GETMV("MV_RELSERV")            //SERVIDOR SMTP
          cAccount  := GETMV("MV_RELACNT")            //CONTA DE EMAIL
          cEnvia    := GETMV("MV_RELACNT")            //EMAIL
          cPassword := GETMV("MV_RELPSW")             //SENHA DA CONTA
          aFiles    := {cFileVM}                      //VETOR PARA ARQUIVOS ATACHADOS
          cMensagem := ""                             //MENSAGEM DO CORPO DO EMAIL
          cSubject  := "INTEGRAÇÃO BRASILUX / VIAMIX" //ASSUNTO DA MENSAGEM
          CRLF      := Chr(13) + Chr(10)
          cDe       := ""
          cPara     := ""
          cTipArq   := ""
          If nExpImp == 1 //De BRASILUX para VIAMIX
             cRecebe := GETMV("MV_INTBRVM")      //DESTINATARIO
             cDe     += "Brasilux"
             cPara   += "Viamix"
             If nOpc == 1
                cTipArq += "a exportação do cadastro de produtos"
             ElseIf nOpc == 2
                    cTipArq += "a exportação do cadastro de transportadoras"
             ElseIf nOpc == 3
                    cTipArq += "a exportação do bordero"
                    aadd(aFiles, SubStr(cFileVM, 1, Len(cFileVM)-3)+"FPT")
             Endif
          ElseIf nExpImp == 2 //De VIAMIX para BRASILUX
                 cRecebe := GETMV("MV_INTBRVM")      //DESTINATARIO
                 cDe     += "Viamix"
                 cPara   += "Brasilux"
             If nOpc == 1
             ElseIf nOpc == 2
                    cTipArq += "a exportação do cadastro de transportadoras"
             ElseIf nOpc == 3
                    cTipArq += "a exportação do bordero"
             Endif
          Endif
          cMensagem += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
          cMensagem += '<HTML>'
          cMensagem += '      <HEAD>'
          cMensagem += '            <META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">'
          cMensagem += '            <TITLE></TITLE>'
          cMensagem += '            <META NAME="GENERATOR" CONTENT="OpenOffice.org 1.1.0  (Win32)">'
          cMensagem += '            <META NAME="CREATED" CONTENT="20040625;9294208">'
          cMensagem += '            <META NAME="CHANGED" CONTENT="20040625;9352133">'
          cMensagem += '      </HEAD>'
          cMensagem += '      <BODY LANG="pt-BR" DIR="LTR">'
          cMensagem += '            <P ALIGN=CENTER STYLE="margin-bottom: 0cm">'
          cMensagem += '               <FONT COLOR="#ff0000">'
          cMensagem += '                     <FONT FACE="Verdana, sans-serif">'
          cMensagem += '                           <FONT SIZE=4>'
          cMensagem += '                                 <I>'
          cMensagem += '                                    <U>'
          cMensagem += '                                       <B>INTEGRA&Ccedil;&Atilde;O BRASILUX / VIAMIX</B>'+CRLF
          cMensagem += '                                    </U>'
          cMensagem += '                                 </I>'
          cMensagem += '                           </FONT>'
          cMensagem += '                     </FONT>'
          cMensagem += '               </FONT>'
          cMensagem += '            </P>'
          //cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR><BR>'
          //cMensagem += '            </P>'
          cMensagem += '            <P STYLE="margin-bottom: 0cm"><FONT FACE="Verdana, sans-serif">Aten&ccedil;&atilde;o o arquivo anexo corresponde '+cTipArq+'.</FONT>'
          cMensagem += '            </P>'
          cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR><FONT FACE="Verdana, sans-serif">Favor salva-lo no servidor no seguinte caminho: \REMOTE\VIAMIX\.</FONT>'
          cMensagem += '            </P>'
          //cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR>'
          //cMensagem += '            </P>'
          cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR><FONT FACE="Verdana, sans-serif">De: '+cDe+'</FONT>'
          cMensagem += '            </P>'
          cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR><FONT FACE="Verdana, sans-serif">Para: '+cPara+'</FONT>'
          cMensagem += '            </P>'
          //cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR>'
          //cMensagem += '            </P>'
          //cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR>'
          //cMensagem += '            </P>'
          //cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR>'
          //cMensagem += '            </P>'
          cMensagem += '            <P STYLE="margin-bottom: 0cm"><BR>'
          cMensagem += '            </P>'
          cMensagem += '            <P STYLE="margin-bottom: 0cm">'
          cMensagem += '               <FONT FACE="Verdana, sans-serif">'
          cMensagem += '                     <FONT SIZE=1 STYLE="font-size: 8pt">Importante:N&atilde;o responder essa mensagem, pois a mesma &eacute; autom&aacute;tica do servidor.</FONT>'
          cMensagem += '               </FONT>'
          cMensagem += '            </P>'
          cMensagem += '      </BODY>'
          cMensagem += '</HTML>'

			lResult := .t.
  	   		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou
			if lConectou   
  				if SuperGetMv("MV_RELAUTH")
					lResult := MailAuth(cAccount, cPassword) //Autenticação do servidor de envio
				endif 
				If lResult    

   					SEND MAIL FROM cAccount;
                               TO cRecebe;
                               SUBJECT cSubject;
                               BODY cMensagem;
                               ATTACHMENT aFiles[1], aFiles[2];
                               RESULT lResult
	   				If lResult
    	  				MsgBox("E-Mail enviado com sucesso!", "Informação", "INFO")
					Else
   						cMensagem := ""
       					GET MAIL ERROR cMensagem
						MsgBox(cMensagem, "Erro...", "STOP")
					Endif
	   			Else
    	  			cMsg := ""
        			GET MAIL ERROR cMsg                  
	       			MsgBox(cMsg)
				Endif
    	      DISCONNECT SMTP SERVER Result lResult
			Else
				//Erro na conexao com o SMTP Server
				cMensagem := ""
				GET MAIL ERROR cMensagem
				MsgBox(cMensagem, "Erro ao conectar ao servidor de e-mail!", "STOP")
	       	Endif
	   endif 
Return

/**************************************************************************************/
/*** VLDPERG1 - Validação de perguntas para a rotina de exportação/importação.      ***/
/**************************************************************************************/
//LGS#20200213 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg1() 
       Local _sAlias   := getarea()
       Local aRegs     := {}      
       Local i,j
       
       DbSelectArea("SX1")
       DbSetOrder(1)


       aAdd(aRegs,{cPerg1, "01", "Exporta / Importa   ?", "", "", "mv_ch1", "N", 1, 0, 0, "C", ""        , "mv_par01", "Exp. BR. -> VM.", "", "", "", "", "Exp. VM. -> VM.", "", "", "", "", "Imp. BRASILUX", "", "", "", "", "Imp. VIAMIX", "", "", "", "", "", "", "", "", "", "", "", "" })
       aAdd(aRegs,{cPerg1, "02", "Dados a Imp. / Exp. ?", "", "", "mv_ch2", "N", 1, 0, 0, "C", ""        , "mv_par02", "Cad. Produtos"  , "", "", "", "", "Cad. Transport.", "", "", "", "", "Borderos"     , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
       
       For i:=1 to Len(aRegs)
           If ! dbSeek(cPerg1+aRegs[i,2])
              RecLock("SX1",.T.)
                 For j:=1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j,aRegs[i,j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       restarea(_sAlias)
Return */

/**************************************************************************************/
/*** VLDPERG2 - Validação de perguntas para a exportação do bordero de despacho     ***/
/**************************************************************************************/
//LGS#20200213 - Adequação de release 12.1.25 e posteriores
/*Static Function VldPerg2() 
       Local _sAlias   := Alias()
       Local aRegs     := {}
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       aAdd(aRegs,{cPerg2, "01", "Numero Bordero      ?", "", "", "mv_ch1", "C", 6, 0, 0, "G", "NaoVazio", "mv_par01", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
       aAdd(aRegs,{cPerg2, "02", "Data de Despacho    ?", "", "", "mv_ch2", "D", 8, 0, 0, "G", ""        , "mv_par02", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
       
       For i:=1 to Len(aRegs)
           If ! dbSeek(cPerg2+aRegs[i,2])
              RecLock("SX1",.T.)
                 For j:=1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j,aRegs[i,j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return*/

Static Function fDetVol(aEmba)
       Local cUniMed := ""
       Local lTemEmb := .f.
       Local cCodCom := ""
       Local nQtdCom := 0.0
       Local lAchouE := .f.
       Local cDesEmb := ""
       Local nVarEmb := 0.0
       Local nRelVol := 0
       Local nQtdVol := 0
       Local nAuxEmb := 0
       Local nAuxTam := 0
       Local cAuxMen := ""
       //Local cRetVol := ""
       Local nColuna := 45
       Local i, nY
       DbSelectArea("SB1")
       DbSetOrder(1)

       DbSelectArea("SD2")
       DbSetOrder(3)
       DbSeek(xFilial("SD2")+TCQ->NFISCAL, .T.)
       If Found()
          While !Eof() .and. SD2->D2_DOC == TCQ->NFISCAL
                If Len(Alltrim(SD2->D2_COD)) == 12
                   DbSelectArea("SZ5")
                   DbSeek(xFilial("SZ5")+SubStr(SD2->D2_COD, 11, 2), .t.)
                   If Found()
                      cUniMed := "("+Alltrim(SZ5->Z5_DESCR)+")"
                   Endif
                   lTemEmb := .f.
                   DbSelectArea("SG1")
                   DbSetOrder(1)
                   DbSeek(xFilial("SG1")+SD2->D2_COD, .f.)
                   If Found()
                      While !Eof() .and. (SG1->G1_FILIAL == xFilial("SG1")) .and. (SG1->G1_COD = SD2->D2_COD) .and. (Len(RTrim(SG1->G1_COMP)) == 4)
                            cCodCom := RTrim(SG1->G1_COMP)
                            nQtdCom := 0
                            While !Eof() .and. (SG1->G1_FILIAL == xFilial("SG1")) .and. (SG1->G1_COD = SD2->D2_COD) .and. (Len(RTrim(SG1->G1_COMP)) == 4) .and. (RTrim(SG1->G1_Comp) == cCodCom)
                                  nQtdCom += SG1->G1_QUANT
                                  DbSkip()
                            Enddo
                            DbSelectArea("SB1")
                            DbSeek(xFilial("SB1")+cCodCom, .f.)
                            If Found() .and. !Empty(SB1->B1_RELCAT1)
                               lTemEmb := .t.
                               lAchouE := .f.
                               For i := 1 to Len(aEmba)
                                   If (aEmba[i][1] == Alltrim(SB1->B1_RELCAT1))
                                      lAchouE = .t.
                                      nVarEmb := i
                                   Endif
                               Next
                               If !lAchouE
                                  cDesEmb := ""
                                  DbSelectArea("SZ5")
                                  DbSeek(xFilial("SZ5")+Alltrim(SB1->B1_RELCAT1), .f.)
                                  If Found()
                                     cDesEmb := SZ5->Z5_DESCR
                                  Endif
                                  //Tipo de embalagem correspondente armazenado em B1_RELCAT1
                                  aAdd(aEmba, {Alltrim(SB1->B1_RELCAT1), SD2->D2_QUANT * nQtdCom * Iif(!Empty(Alltrim(SC5->C5_ESPECI4)), 2, 1), cDesEmb})
                               Else
                                  aEmba[nVarEmb][2] := aEmba[nVarEmb][2]+SD2->D2_QUANT * nQtdCom * Iif(!Empty(Alltrim(SC5->C5_ESPECI4)), 2, 1)
                               Endif
                            Endif
                            DbSelectArea("SG1")
                      EndDo
                      If !lTemEmb .and. (SubStr(SD2->D2_COD, 11, 2) # "00")
                         lAchouE = .f.
                         For i := 1 to Len(aEmba)
                             If (aEmba[i][1] == SubStr(SD2->D2_COD, 11, 2))
                                lAchouE = .t.
                                nVarEmb := i
                             Endif
                         Next
                         If !lAchouE
                            cDesEmb := ""
                            DbSelectArea("SZ5")
                            DbSeek(xFilial("SZ5")+SubStr(SD2->D2_COD, 11, 2), .f.)
                            If Found()
                               cDesEmb := SZ5->Z5_DESCR
                            Endif
                            aAdd(aEmba, {SubStr(SD2->D2_COD, 11, 2), SD2->D2_QUANT * Iif(!Empty(Alltrim(SC5->C5_ESPECI4)), 2, 1), cDesEmb})
                         Else
                            aEmba[nVarEmb][2] := aEmba[nVarEmb][2]+SD2->D2_QUANT * Iif(!Empty(Alltrim(SC5->C5_ESPECI4)), 2, 1)
                         Endif
                      Endif
                   Endif
                Else
                   nQtdVol := 0
                   nRelVol := 1
                   DbSelectArea("SB1")
                   DbSeek(xFilial("SB1")+SD2->D2_COD, .t.)
                   If Found() .and. (SB1->B1_RELVOL > 0)
                      nAuxEmb := SD2->D2_QUANT * Iif(!Empty(Alltrim(SC5->C5_ESPECI4)), 2, 1) / SB1->B1_RELVOL
                      If Int(nAuxEmb) < nAuxEmb
                         nAuxEmb := Int(nAuxEmb) + 1
                      Endif
                      nQtdVol := nAuxEmb
                      nRelVol := 1
                   Endif
                   lAchouE := .f.
                   For i := 1 to Len(aEmba)
                       If aEmba[i][1] == "  "
                          lAchouE = .t.
                          nVarEmb := i
                       Endif
                   Next
                   If !lAchouE
                      aadd(aEmba, {"  ", nQtdVol, "Diversos"})
                   Else
                      aEmba[nVarEmb][2] := aEmba[nVarEmb][2] + nQtdVol
                   Endif
                Endif
                DbSelectArea("SD2")
                DbSkip()
          Enddo
       Endif
       aEmba  := aSort(aEmba,,, { |x, y| x[1] < y[1] })
       cMenEmb := ""
       If Len(aEmba) > 0
          nAuxTam := Len(cMenEmb) % nColuna //Resto
          If nAuxTam > 0
             cMenEmb := Space(nColuna - nAuxTam) + cMenEmb
          Endif
          //                      999,999	        999,999
          //         0         1         2         3         4         5
          //          12345678901234567890123456789012345678901234567890123456789
          cMenEmb := "EMBALAGEM          QTDE           VOLUMES"
          cMenEmb := cMenEmb + Space(nColuna - Len(cMenEmb))+chr(13)+chr(10)
       Endif
       For nY := 1 To Len(aEmba)
           cAuxMen := SubStr(Alltrim(SubStr(aEmba[nY][3], 1, 18)), 1, 16)
           cAuxMen := cAuxMen + Space(16 - Len(cAuxMen))
           cAuxMen += Iif(aEmba[nY][1] != "  ", Transform(aEmba[nY][2], "999,999"), "--")
           cAuxMen := cAuxMen+Space(34 - Len(cAuxMen))
           If (aEmba[nY][2] > 0) .and. (aEmba[nY][1] != "  ")
              nAux := U_DetVolEmba(aEmba[nY][1], aEmba[nY][2])
           Else
              nAux := aEmba[nY][2]
           Endif
           cAuxMen += Transform(nAux, "999,999")
           cAuxMen += Space(nColuna - Len(cAuxMen))
           cMenEmb += cAuxMen+chr(13)+chr(10)
       Next
Return(cMenEmb)
