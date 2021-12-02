#include 'rwmake.ch'
#include 'topconn.ch' 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BRMDT001 บAutor  ณ Luํs Gustavo       บ Data ณ  15/03/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo de arquivo texto para exporta็ใo de dados e inte - บฑฑ
ฑฑบ          ณ gra็ใo do microsiga com o NEXUS utilizado pela Consult   - บฑฑ
ฑฑบ          ณ acessoria.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BRASILUX                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function BRMDT001(cOpc)
     Private cPerg := "BRMT01"
     ValPerg()
     If !Pergunte(cPerg, .t.)
        Return
     Endif
     cRotina   := Iif(mv_par01 == 1, 'U_MDT001_1()', '')
     cProcesso := "dos Funcionแrios"
     MsgRun("Exportando dados "+cProcesso, "Aguarde...", {|| &cRotina } )
Return

User Function MDT001_1()
     Local cQry1   := ""
     Local cRelato := "\SPOOL\MDT\"
     Local nHandle := 0
     Local cEOL := CHR(13)+CHR(10)

     nHandle := fCreate(cRelato+"TESTE.TXT")
     If nHandle <> -1 
        fClose(nHandle)
        fErase(cRelato+"TESTE.TXT")
     Else
        If MakeDir(cRelato) != 0
           If Right(cRelato,1) == "\"
              cRelt := SubStr(cRelato,1,Len(cRelato)-1)
           Else
              cRelt := cRelato
           Endif
           If !MontaDir(cRelt)
              Help(" ",1,"RELDIRERR")
           Endif
        Endif
     Endif
     cArqTxt1 := cRelato+"FUNCIONA.TXT"
     nHdl1    := fCreate(cArqTxt1)
     cQry1 := ""     
     cQry1 += "SELECT SRA.RA_MAT AS RA_MAT, SRA.RA_FILIAL AS RA_FILIAL, SRA.RA_CODFUNC AS RA_CODFUNC, SRA.RA_NOME AS RA_NOME, "
     cQry1 += "       SUBSTRING(SRA.RA_ADMISSA,7,2)+'/'+SUBSTRING(SRA.RA_ADMISSA,5,2)+'/'+SUBSTRING(SRA.RA_ADMISSA,1,4) AS RA_ADMISSA, "
     cQry1 += "       SUBSTRING(SRA.RA_DEMISSA,7,2)+'/'+SUBSTRING(SRA.RA_DEMISSA,5,2)+'/'+SUBSTRING(SRA.RA_DEMISSA,1,4) AS RA_DEMISSA, "
     cQry1 += "       SUBSTRING(SRA.RA_NASC,7,2)+'/'+SUBSTRING(SRA.RA_NASC,5,2)+'/'+SUBSTRING(SRA.RA_NASC,1,4) AS RA_NASC, "
     cQry1 += "       SRA.RA_NUMCP AS RA_NUMCP, SRA.RA_SERCP AS RA_SERCP, SRA.RA_SEXO AS RA_SEXO, SRA.RA_ESTCIVI AS RA_ESTCIVI, "
     cQry1 += "       SRA.RA_ENDEREC AS RA_ENDEREC, SRA.RA_COMPLEM AS RA_COMPLEM, SRA.RA_BAIRRO AS RA_BAIRRO, SRA.RA_MUNICIP AS RA_MUNICIP, "
     cQry1 += "       SRA.RA_CEP AS RA_CEP, SRA.RA_TELEFON AS RA_TELEFON, SRA.RA_EMAIL AS RA_EMAIL, SRA.RA_RG AS RA_RG, SRA.RA_ESTADO AS RA_ESTADO, "
     cQry1 += "       SRA.RA_MAE AS RA_MAE, SRA.RA_UFCP AS RA_UFCP, SRA.RA_RGORG AS RA_RGORG, SRA.RA_PIS AS RA_PIS "
     cQry1 += "FROM "+RetSqlName("SRA")+" SRA "
     cQry1 += "WHERE SRA.D_E_L_E_T_ = '' "
     cQry1 += "  AND SRA.RA_SITFOLH <> 'D' "
     cQry1 += "  AND (SUBSTRING(SRA.RA_MAT,1,1) <> '9' AND LEN(SRA.RA_MAT) <> 4) "
     cQry1 += "ORDER BY RA_FILIAL,RA_MAT "
     TCQUERY cQry1 ALIAS "TCQ" NEW
     DbSelectArea("TCQ")
     DbGoTop()
     While !Eof()
           cEstCivil := "" ; cEstCivil := Posicione("SX5", 1, xFilial("SX5")+'33'+TCQ->RA_ESTCIVI, "X5_DESCRI")
           cEndereco := "" ; cEndereco := Alltrim(SubStr( Alltrim(TCQ->RA_ENDEREC), 1, at(',', TCQ->RA_ENDEREC)-1 ) )
           cEnderec2 := "" ; cEnderec2 := Alltrim(SubStr( Alltrim(TCQ->RA_ENDEREC), at(',', TCQ->RA_ENDEREC) + 1 ) )
           cDataCTPS := "" ; cDataCTPS := space(02)+'/'+space(02)+'/'+space(04)
           cDataRegG := "" ; cDataRegG := space(02)+'/'+space(02)+'/'+space(04)
           cNumerCBO := "" ; cNumerCBO := Posicione("SRJ", 1, xFilial("SRJ")+TCQ->RA_CODFUNC, "RJ_CODCBO")
           cLin := space(1000)
           /*** MATRICULA ***/
           cCpo := PADR('#'+TCQ->RA_MAT    , 0022) ; cLin := Stuff( cLin, 0001, 0022, cCpo )
           /*** EMPRESA ***/
           cCpo := PADR('#'+TCQ->RA_FILIAL , 0061) ; cLin := Stuff( cLin, 0023, 0083, cCpo )
           /*** FUNวรO DO FUNCIONมRIO ***/
           cCpo := PADR('#'+TCQ->RA_CODFUNC, 0061) ; cLin := Stuff( cLin, 0084, 0144, cCpo )
           /*** NOME DO FUNCIONARIO ***/
           cCpo := PADR('#'+TCQ->RA_NOME   , 0061) ; cLin := Stuff( cLin, 0145, 0205, cCpo )
           /*** DATA DE ADMISSรO ***/
           cCpo := PADR('#'+TCQ->RA_ADMISSA, 0011) ; cLin := Stuff( cLin, 0206, 0216, cCpo )
           /*** DATA DE DEMISSรO ***/
           cCpo := PADR('#'+TCQ->RA_DEMISSA, 0011) ; cLin := Stuff( cLin, 0217, 0227, cCpo )
           /*** DATA DE NASCIMENTO ***/
           cCpo := PADR('#'+TCQ->RA_NASC   , 0011) ; cLin := Stuff( cLin, 0228, 0238, cCpo )
           /*** NUMERO DA CARTEIRA DE TRABALHO ***/
           cCpo := PADR('#'+TCQ->RA_NUMCP  , 0019) ; cLin := Stuff( cLin, 0239, 0257, cCpo )
           /*** SษRIE DA CARTEIRA DE TRABALHO ***/
           cCpo := PADR('#'+TCQ->RA_SERCP  , 0011) ; cLin := Stuff( cLin, 0258, 0268, cCpo )
           /*** SEXO DO FUNCIONARIO ***/
           cCpo := PADR('#'+TCQ->RA_SEXO   , 0002) ; cLin := Stuff( cLin, 0269, 0270, cCpo )
           /*** ESTADO CIVIL ***/
           cCpo := PADR('#'+cEstCivil      , 0061) ; cLin := Stuff( cLin, 0271, 0331, cCpo )
           /*** SETOR ***/
           cCpo := PADR('#'+space(60)      , 0061) ; cLin := Stuff( cLin, 0332, 0392, cCpo )
           /*** TURNO ***/
           cCpo := PADR('#'+space(60)      , 0061) ; cLin := Stuff( cLin, 0393, 0453, cCpo )
           /*** ENDEREวO ***/
           cCpo := PADR('#'+cEndereco      , 0061) ; cLin := Stuff( cLin, 0454, 0514, cCpo )
           /*** NUMERO DO ENDEREวO ***/
           cCpo := PADR('#'+cEnderec2      , 0039) ; cLin := Stuff( cLin, 0515, 0553, cCpo )
           /*** COMPLEMENTO DO ENDEREวO ***/
           cCpo := PADR('#'+RA_COMPLEM     , 0061) ; cLin := Stuff( cLin, 0554, 0614, cCpo )
           /*** BAIRRO ***/
           cCpo := PADR('#'+RA_BAIRRO      , 0021) ; cLin := Stuff( cLin, 0615, 0635, cCpo )
           /*** MUNICIPIO ***/
           cCpo := PADR('#'+RA_MUNICIP     , 0021) ; cLin := Stuff( cLin, 0636, 0656, cCpo )
           /*** CEP ***/
           cCpo := PADR('#'+RA_CEP         , 0009) ; cLin := Stuff( cLin, 0657, 0666, cCpo )
           /*** CONTATO ***/
           cCpo := PADR('#'+SPACE(250)     , 0251) ; cLin := Stuff( cLin, 0667, 0917, cCpo )
           /*** TELEFONE ***/
           cCpo := PADR('#'+RA_TELEFON     , 0021) ; cLin := Stuff( cLin, 0918, 0938, cCpo )
           /*** E-MAIL ***/
           cCpo := PADR('#'+RA_EMAIL       , 0061) ; cLin := Stuff( cLin, 0939, 0999, cCpo )
           /*** TIPO DO FUNCIONมRIO ***/
           cCpo := PADR('#'+SPACE(05)      , 0006) ; cLin := Stuff( cLin, 1000, 1005, cCpo )
           /*** TIPO SANGUอNEO ***/
           cCpo := PADR('#'+SPACE(05)      , 0006) ; cLin := Stuff( cLin, 1006, 1011, cCpo )
           /*** NUMERO DO PLANO DE SAฺDE ***/
           cCpo := PADR('#'+SPACE(20)      , 0021) ; cLin := Stuff( cLin, 1012, 1032, cCpo )
           /*** CODIGO DO PLANO DE SAฺDE ***/
           cCpo := PADR('#'+SPACE(05)      , 0006) ; cLin := Stuff( cLin, 1033, 1038, cCpo )
           /*** RG ***/
           cCpo := PADR('#'+RA_RG          , 0021) ; cLin := Stuff( cLin, 1039, 1059, cCpo )
           /*** ESTADO ***/
           cCpo := PADR('#'+RA_ESTADO      , 0003) ; cLin := Stuff( cLin, 1060, 1062, cCpo )
           /*** NOME DA MAE ***/
           cCpo := PADR('#'+RA_MAE         , 0061) ; cLin := Stuff( cLin, 1063, 1123, cCpo )
           /*** DATA CTPS ***/
           cCpo := PADR('#'+cDataCTPS      , 0011) ; cLin := Stuff( cLin, 1024, 1134, cCpo )
           /*** DATA CTPS ***/
           cCpo := PADR('#'+RA_UFCP        , 0003) ; cLin := Stuff( cLin, 1135, 1137, cCpo )
           /*** DATA RG   ***/
           cCpo := PADR('#'+cDataRegG      , 0011) ; cLin := Stuff( cLin, 1138, 1148, cCpo )
           /*** ORGรO EXPEDIDOR DO RG ***/
           cCpo := PADR('#'+RA_RGORG       , 0021) ; cLin := Stuff( cLin, 1149, 1169, cCpo )
           /*** UF RG  ***/
           cCpo := PADR('#'+SPACE(02)      , 0003) ; cLin := Stuff( cLin, 1171, 1172, cCpo )
           /*** PIS    ***/
           cCpo := PADR('#'+RA_PIS         , 0003) ; cLin := Stuff( cLin, 1173, 1188, cCpo )
           /*** PIS    ***/
           cCpo := PADR('#'+cNumerCBO      , 0006) ; cLin := Stuff( cLin, 1189, 1194, cCpo )+cEol
           
           fWrite(nHdl1,cLin,Len(cLin))
           DbSelectArea("TCQ")
           DbSkip()
     Enddo
     fClose(nHdl1)
     DbSelectArea("TCQ")
     DbCloseArea()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบFuno    ณ VALPERG  บ Autor ณ Luํs Gustavo de Souza บ Data ณ 10/07/03 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValPerg()
       Local _sAlias := Alias()
       Local aRegs := {}
       Local i,j

       dbSelectArea("SX1")
       dbSetOrder(1)
       cPerg := PADR(cPerg,10)
       
       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       aAdd(aRegs,{cPerg,"01","Cad. เ ser exportado","","","mv_ch1","N",01,0,0,"C","","mv_par01","Cadastro de Funcionแrios","","","","","","","","","","","","","","","","","","","","","","","","",""})
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