#include 'rwmake.ch'
#include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VMFAT012 ºAutor  ³ Luis Gustavo       º Data ³  02/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importacao / Exportacao de dados de despacho de mercadoriasº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VIAMIX / BRASILUX                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VMFAT012()
     Local   cAlias := Alias()
     Local   nOrder := IndexOrd()
     //Local   cAux
     Local   aCampos:= {}
     //Private cPerg  := padr('VMFT12',Len(SX1->X1_GRUPO)," ") //LGS#20200213 - Adequação de release 12.1.25 e posteriores
     Private cPerg  := 'VMFT12' 
     Private oTempTbl01
     Private cQuery := ''

     //VldPerg()  //LGS#20200213 - Adequação de release 12.1.25 e posteriores    
     pergunte(cPerg,.F.)
     nAux       := SPACE(40)
     Linha      := 0                
     nOpcA      := 0                
     nPag       := 0
     nValTotGer := 0 
     cPathVM := "\REMOTE\VIAMIX\"
     cFileVM := "VIAMIX"
     
     oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Exportação / Importação de dados BRASILUX / VIAMIX.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

     @ 020,018 SAY OemToAnsi("Este processo  tem como  função, importar / exportar ")
     @ 030,018 SAY OemToAnsi("os dados do borderos para cargas com redespacho, para")
     @ 040,018 SAY OemToAnsi("integração entra Brasilux / Viamix.                  ")
     @ 057,170 BMPBUTTON TYPE 05 ACTION (Pergunte(cPerg))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
     If nOpca == 0 
        //Exit
        Return
     EndIf
     If mv_par02 == 1
        If SubStr(cNumEmp,1,2) $ '01'
           aadd(aCampos, {"FILIAL" , "C", 02, 00})
           aadd(aCampos, {"BORDERO", "C", 06, 00})
           aadd(aCampos, {"DTBORDE", "D", 08, 00})
           aadd(aCampos, {"DTDESPA", "D", 08, 00})
           aadd(aCampos, {"EMPRESA", "C", 02, 00})
           aadd(aCampos, {"PEDIDO" , "C", 06, 00})
           aadd(aCampos, {"NFISCAL", "C", 06, 00})
           aadd(aCampos, {"CLIENTE", "C", 06, 00})
           aadd(aCampos, {"LOJACLI", "C", 02, 00})
           aadd(aCampos, {"RAZAO"  , "C", 40, 00})
           aadd(aCampos, {"ENDENT" , "C", 40, 00})
           aadd(aCampos, {"MUNENT" , "C", 25, 00})
           aadd(aCampos, {"ESTENT" , "C", 02, 00})
           aadd(aCampos, {"CNPJ"   , "C", 14, 00})
           aadd(aCampos, {"INSCR"  , "C", 18, 00})
           aadd(aCampos, {"VALMERC", "N", 14, 02})
           aadd(aCampos, {"VALFAT" , "N", 14, 02})           
           aadd(aCampos, {"VOLUME" , "N", 06, 00})
           aadd(aCampos, {"PLIQUI" , "N", 14, 02})
           aadd(aCampos, {"PBRUTO" , "N", 14, 02})
           aadd(aCampos, {"REDESP" , "C", 06, 00})
           aadd(aCampos, {"REGIAO" , "C", 03, 00})
           aadd(aCampos, {"CGCRED" , "C", 14, 00})
           
           /********************************************************************************************************************************/
           /*** BLOCO ALTERADO EM 13/02/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
           cFileVM := "V"+mv_par01
           //DbCreate(cPathVM+cFileVm, aCampos, "DBFCDX")
           //DbUseArea(.T., "DBFCDX", cPathVM+cFileVM, "VMIX", .F.)
           oTempTbl01 := FWTemporaryTable():New( "VMIX" )
           oTempTbl01:SetFields( aCampos )
           oTempTbl01:Create()
           /********************************************************************************************************************************/
           MsAguarde({|| VMFAT012_1() },"Aguarde","Em processando conforme parâmetros...")
           DbSelectArea("TCQ")
           While !Eof()
                 RecLock("VMIX",.T.)
                    VMIX->FILIAL  := TCQ->FILIAL
                    VMIX->BORDERO := TCQ->BORDERO
                    VMIX->DTBORDE := cTod(SubStr(TCQ->DTBORDE,7,2)+'/'+SubStr(TCQ->DTBORDE,5,2)+'/'+SubStr(TCQ->DTBORDE,1,4))
                    VMIX->DTDESPA := mv_par03 //Iif(Empty(TCQ->DTDESPA), cTod(SubStr(TCQ->DTDESPA,7,2)+'/'+SubStr(TCQ->DTDESPA,5,2)+'/'+SubStr(TCQ->DTDESPA,1,4)), VMIX->DTBORDE + 1)
                    VMIX->EMPRESA := TCQ->EMPRESA
                    VMIX->PEDIDO  := TCQ->PEDIDO
                    VMIX->NFISCAL := TCQ->NFISCAL
                    VMIX->CLIENTE := TCQ->CLIENTE
                    VMIX->LOJACLI := TCQ->LOJACLI
                    VMIX->RAZAO   := TCQ->RAZAO
                    VMIX->ENDENT  := TCQ->ENDENT
                    VMIX->MUNENT  := TCQ->MUNENT
                    VMIX->ESTENT  := TCQ->ESTENT
                    VMIX->CNPJ    := TCQ->CNPJ
                    VMIX->INSCR   := TCQ->INSCR
                    VMIX->VALMERC := TCQ->VALMERC
                    VMIX->VALFAT  := TCQ->VALFAT
                    VMIX->VOLUME  := TCQ->VOLUME
                    VMIX->PLIQUI  := TCQ->PLIQUI
                    VMIX->PBRUTO  := TCQ->PBRUTO
                    VMIX->REDESP  := TCQ->REDESP
                    VMIX->REGIAO  := TCQ->REGIAO
                    VMIX->CGCRED  := TCQ->CGCRED
                 MsUnLock()
                 DbSelectArea("TCQ")
                 DbSkip()
           Enddo
           DbSelectArea("TCQ")
           DbCloseArea()
           DbSelectArea("VMIX")
           DbCloseArea()
           oTempTbl01:Delete()
           DbSelectArea(cAlias)
           DbSetOrder(nOrder)
           MsgBox('Arquivo gerado com sucesso !!!','Informação','INFO')
        Else
           MsgBox('Essa empresa não está autorizada a executar essa operação !!!','Atenção','ALERT')
        Endif
     Else
        If SubStr(cNumEmp,1,2) $ '04'
           MsAguarde({|| VMFAT012_2() },"Aguarde","Em processando conforme parâmetros...")
        Else
           MsgBox('Essa empresa não está autorizada a executar essa operação !!!','Atenção','ALERT')
        Endif
     Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VMFAT012_1ºAutor  ³ Luis Gustavo       º Data ³  02/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para buscar dados do borderor de descpacho da empre-º±±
±±º          ³ sa Brasilux e exportar para empresa VIAMIX.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VIAMIX / BRASILUX                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VMFAT012_1()
       cQuery := ""
       cQuery += "SELECT SZA.ZA_FILIAL                AS FILIAL, "
       cQuery += "       SZA.ZA_CODIGO                AS BORDERO, "
       cQuery += "       SZA.ZA_EMISSAO               AS DTBORDE, "
       cQuery += "       SZA.ZA_DTDESPA               AS DTDESPA, "
       cQuery += "       SUBSTRING(SZB.ZB_PEDIDO,1,2) AS EMPRESA, "
       cQuery += "       SUBSTRING(SZB.ZB_PEDIDO,3,6) AS PEDIDO, "
       cQuery += "       SF2.F2_DOC                   AS NFISCAL, "
       cQuery += "       SF2.F2_CLIENTE               AS CLIENTE, "
       cQuery += "       SF2.F2_LOJA                  AS LOJACLI, "
       cQuery += "       SA1.A1_NOME                  AS RAZAO, "
       cQuery += "       CASE WHEN SA1.A1_ENDENT = '' THEN SA1.A1_END ELSE SA1.A1_ENDENT END AS ENDENT, "
       cQuery += "       CASE WHEN SA1.A1_MUNE   = '' THEN SA1.A1_MUN ELSE SA1.A1_MUNE   END AS MUNENT, "
       cQuery += "       CASE WHEN SA1.A1_ESTE   = '' THEN SA1.A1_EST ELSE SA1.A1_ESTE   END AS ESTENT, "
       cQuery += "       SA1.A1_CGC                   AS CNPJ, "
       cQuery += "       SA1.A1_INSCR                 AS INSCR, "
       cQuery += "       SF2.F2_EMISSAO               AS DTNOTAF, "
       cQuery += "       SF2.F2_VALMERC               AS VALMERC, "
       cQuery += "       SF2.F2_VALFAT                AS VALFAT , "
       cQuery += "       SF2.F2_VOLUME1               AS VOLUME, "
       cQuery += "       SF2.F2_PLIQUI                AS PLIQUI, "
       cQuery += "       SF2.F2_PBRUTO                AS PBRUTO, "
       cQuery += "       SF2.F2_REDESP                AS REDESP, "
       cQuery += "       SZ7.Z7_REGIAO                AS REGIAO, "
       cQuery += "       SA4.A4_CGC                   AS CGCRED "  
       cQuery += "FROM SZA010 SZA "
       cQuery += "LEFT OUTER JOIN SZB010 SZB ON SZB.ZB_FILIAL = SZA.ZA_FILIAL  AND SZB.ZB_CODIGO  = SZA.ZA_CODIGO AND SZB.D_E_L_E_T_ = '' "
       cQuery += "LEFT OUTER JOIN SF2010 SF2 ON SF2.F2_FILIAL = SZA.ZA_FILIAL  AND SF2.F2_PEDIDO  = SUBSTRING(SZB.ZB_PEDIDO,3,6) AND SF2.D_E_L_E_T_ = '' "
       cQuery += "LEFT OUTER JOIN SA1010 SA1 ON SA1.A1_COD    = SF2.F2_CLIENTE AND SA1.D_E_L_E_T_ = '' "
       cQuery += "LEFT OUTER JOIN SZ7010 SZ7 ON ''            = SZ7.Z7_FILIAL  AND SA1.A1_CODCID  = SZ7.Z7_COD AND SZ7.D_E_L_E_T_ = '' "
       cQuery += "LEFT OUTER JOIN SA4010 SA4 ON ''            = SA4.A4_FILIAL  AND SA4.A4_COD     = SF2.F2_REDESP AND SA4.D_E_L_E_T_ = '' "
       cQuery += "WHERE SZA.D_E_L_E_T_ = '' "
       cQuery += "  AND SZA.ZA_FILIAL  = '"+xFilial("SZA")+"' "
       cQuery += "  AND SZA.ZA_CODIGO  = '"+mv_par01+"' "
       cQuery += "  AND SUBSTRING(SZB.ZB_PEDIDO,1,2) = '01' "
       cQuery += "  AND SZ7.Z7_REGIAO  = '999' "
       cQuery += "  ORDER BY SF2.F2_REDESP "
       TCQUERY cQuery NEW ALIAS "TCQ" 
       
       DbSelectArea("TCQ")
  
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VMFAT012_2ºAutor  ³ Luis Gustavo       º Data ³  02/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para importacao de dados da empresa BRASILUX para   º±±
±±º          ³ empresa VIAMIX.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VIAMIX                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VMFAT012_2()
       //LGS#20200213 - Adequação de release 12.1.25 e posteriores
       //Modificado abertura do programa
       //cFileVM := "V"+mv_par01
       //If File(cPathVM+cFileVM+".DBF")
       If Select( FWTemporaryTable():GetAlias( ) ) > 0
          //DbUseArea(.T.,,cPathVM+cFileVM,"VMIX",.F.)
          If !Used()
             MsgBox('Houve problemas na abertura do arquivo !!!','Atenção','ALERT')
             Return
          Else
             nCont := 0
             DbSelectArea("VMIX")
             DbGoTop()
             While !Eof()
                   If VMIX->BORDERO = mv_par01
                      DbSelectArea("ZZ0")
                      DbSetOrder(3)
                      DbSeek(xFilial("ZZ0")+VMIX->NFISCAL,.t.)
                      If Found()
                         nCont += 1
                         If MsgYesNo("O bordero: "+VMIX->BORDERO+", nota: "+VMIX->NFISCAL+" já existe. Continua ?","Pergunta")
                            RecLock("ZZ0",.f.)
                               ZZ0->ZZ0_BORDER := VMIX->BORDERO
                               ZZ0->ZZ0_DTBORD := VMIX->DTBORDE
                               ZZ0->ZZ0_DTDESP := VMIX->DTDESPA
                               ZZ0->ZZ0_EMPRES := VMIX->EMPRESA
                               ZZ0->ZZ0_PEDIDO := VMIX->PEDIDO
                               ZZ0->ZZ0_NFISCA := VMIX->NFISCAL
                               ZZ0->ZZ0_CLIENT := VMIX->CLIENTE
                               ZZ0->ZZ0_LOJACL := VMIX->LOJACLI
                               ZZ0->ZZ0_RAZAO  := VMIX->RAZAO
                               ZZ0->ZZ0_ENDENT := VMIX->ENDENT
                               ZZ0->ZZ0_MUNENT := VMIX->MUNENT
                               ZZ0->ZZ0_ESTENT := VMIX->ESTENT
                               ZZ0->ZZ0_CNPJ   := VMIX->CNPJ
                               ZZ0->ZZ0_INSCR  := VMIX->INSCR
                               ZZ0->ZZ0_VALMER := VMIX->VALMERC
                               ZZ0->ZZ0_VOLUME := VMIX->VOLUME
                               ZZ0->ZZ0_PLIQUI := VMIX->PLIQUI
                               ZZ0->ZZ0_PBRUTO := VMIX->PBRUTO
                               ZZ0->ZZ0_REDESP := VMIX->REDESP
                               ZZ0->ZZ0_REGIAO := VMIX->REGIAO
                               ZZ0->ZZ0_CGCRED := VMIX->CGCRED
                               ZZ0->ZZ0_VALFAT := VMIX->VALFAT
                            MsUnLock()
                         Endif
                      Else
                         nCont += 1
                         RecLock("ZZ0",.T.)
                            ZZ0->ZZ0_FILIAL := VMIX->FILIAL
                            ZZ0->ZZ0_BORDER := VMIX->BORDERO
                            ZZ0->ZZ0_DTBORD := VMIX->DTBORDE
                            ZZ0->ZZ0_DTDESP := VMIX->DTDESPA
                            ZZ0->ZZ0_EMPRES := VMIX->EMPRESA
                            ZZ0->ZZ0_PEDIDO := VMIX->PEDIDO
                            ZZ0->ZZ0_NFISCA := VMIX->NFISCAL
                            ZZ0->ZZ0_CLIENT := VMIX->CLIENTE
                            ZZ0->ZZ0_LOJACL := VMIX->LOJACLI
                            ZZ0->ZZ0_RAZAO  := VMIX->RAZAO
                            ZZ0->ZZ0_ENDENT := VMIX->ENDENT
                            ZZ0->ZZ0_MUNENT := VMIX->MUNENT
                            ZZ0->ZZ0_ESTENT := VMIX->ESTENT
                            ZZ0->ZZ0_CNPJ   := VMIX->CNPJ
                            ZZ0->ZZ0_INSCR  := VMIX->INSCR
                            ZZ0->ZZ0_VALMER := VMIX->VALMERC
                            ZZ0->ZZ0_VOLUME := VMIX->VOLUME
                            ZZ0->ZZ0_PLIQUI := VMIX->PLIQUI
                            ZZ0->ZZ0_PBRUTO := VMIX->PBRUTO
                            ZZ0->ZZ0_REDESP := VMIX->REDESP
                            ZZ0->ZZ0_REGIAO := VMIX->REGIAO
                            ZZ0->ZZ0_CGCRED := VMIX->CGCRED
                            ZZ0->ZZ0_VALFAT := VMIX->VALFAT
                         MsUnLock()
                      Endif
                   Endif
                   DbSelectArea("VMIX")
                   DbSkip()
             EndDo
             If nCont <= 0
                MsgBox("Nenhum registro foi gravado para esse Bordero","Atenção","ALERT")
             Endif
          Endif
          DbSelectArea("VMIX")
          DbCloseArea()
          oTempTbl01:Delete()
       Else
          MsgBox('Arquivo não encontrado para importação !!!','Atenção','ALERT')
          Return
       Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldPerg  ºAutor  ³ Luis Gustavo       º Data ³  02/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacão de perguntas para a rotina.                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VIAMIX                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//LGS#20200213 - Adequação de release 12.1.25 e posteriores
/*
Static Function VldPerg() 
       Local _sAlias   := Alias()
       Local aRegs     := {}
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)

       aAdd(aRegs,{cPerg, "01", "Numero Bordero      ?", "", "", "mv_ch1", "C", 6, 0, 0, "G", "NaoVazio", "mv_par01", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
       aAdd(aRegs,{cPerg, "02", "Exporta / Importa   ?", "", "", "mv_ch2", "N", 1, 0, 0, "C", ""        , "mv_par02", "Exporta", "", "", "", "", "Importa", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
       aAdd(aRegs,{cPerg, "03", "Data de Despacho    ?", "", "", "mv_ch3", "D", 8, 0, 0, "G", ""        , "mv_par03", ""       , "", "", "", "", ""       , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
       
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
       DbSelectArea(_sAlias)
Return*/