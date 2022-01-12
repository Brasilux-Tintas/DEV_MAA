#include "rwmake.ch"
#INCLUDE "TOTVS.CH"

User Function MT010INC()
     Local _cAlias     := Alias()
     Local aAreaAnt    := u_PegaArea({"SX5","SB5","SYD","SZ1","SB1"})
     Local lMandarBrasRepres, nPicmret, nAux, cTs, _cItem, nVlrTab,_cGrpEmp,cAuxMens
     Local _lRet       := .t.
     Local lBloqueouB1 := .F.
     Local nRecnoSB1   := SB1->( RECNO() )
     
_cGrpEmp := ALLTRIM(FWGrpCompany())

do case 
case _cGrpEmp == '01'
        /*Autor: Cleber Orati Domingues
          Data: 17/05/02
          Ponto de Entrada para atualizar pesos específicos de PI's baseado 
          no peso específico da mat. prima. Executado no após a Inclusão 
          da mat. prima.
          Data: 04/08/04
          Alterado para aceitar outros locais para materias primas.
          Utilizacao da fabrica.

          Uso: Brasilux/Matriz e Brasitec.
          Alerta! => Não pode ser usado na Resina!
        */
        //IF (SB1->B1_TIPO == "MP") .AND. (ALLTRIM(SB1->B1_UM) != "K") .AND. (ALLTRIM(SB1->B1_UM) != "KG") .AND. (SB1->B1_PESBRU <= 0)
        IF (ALLTRIM(SB1->B1_UM) != "K") .AND. (ALLTRIM(SB1->B1_UM) != "KG") .AND. (ALLTRIM(SB1->B1_UM) != "L") .AND. (SB1->B1_TIPO != "PA") .AND. (SB1->B1_PESBRU <= 0)
           IF !(cNumEmp = "01100101") //Não apresentar mensagem no Leiria!!!
               // produto de custeio
               If U_IsProdCusto(SB1->B1_COD,.T.)
               Else
                  cAuxMens := "Preencha o Peso Bruto!"
                  If (ValAtrib("l010Auto") <> "U") .and. l010Auto //release 12.1.25
                     FwLogMSG( "INFO", , 'SIGAPCP', FunName(), '', '01', cAuxMens, 0 )
                  else
                     MsgBox(cAuxMens, "Atenção", "STOP")
                  endif
               Endif  
           ENDIF
           //return(.f.)
        Endif
        If !(cNumEmp == "01010104") .and. !(cNumEmp == "01010106")
           IF (SB1->B1_TIPO == "MP")
              cAuxMens := "Atencao! O Programa ira' recalcular os Pesos Especificos"+chr(13)+;
              "e podera' demorar! Nao tente interromper o processamento"+chr(13)+;
              "pois podera' comprometer as estruturas de Produtos!" 
               If (ValAtrib("l010Auto") <> "U") .and. l010Auto //release 12.1.25
                  FwLogMSG( "INFO", , 'SIGAPCP', FunName(), '', '01', cAuxMens, 0 )
               else
                  MsgBox(cAuxMens, "Atenção", "STOP")
               endif

              U_CalcPesoEsp(SB1->B1_COD)     
           Endif
           If (len(alltrim(SB1->B1_COD)) == 12) .AND. ((SB1->B1_LUCRO <= 0) .or. (SB1->B1_LCRMIN <= 0) .or. ;
              (SB1->B1_LUCRO2 <= 0) .or. (SB1->B1_LUCROM2 <= 0) .or. (SB1->B1_COMIS <= 0))
              dbselectarea("SZ1")   
              dbsetorder(1)
              dbseek(xFilial("SZ1")+substr(SB1->B1_COD,4,2))
              If found()
                 dbselectarea("SB1") 
                 If !lBloqueouB1 
                    reclock("SB1",.F.)
                    lBloqueouB1 := .t.
                 Endif 
                 SB1->B1_LUCRO := SZ1->Z1_LUCRO
                 SB1->B1_LCRMIN := SZ1->Z1_LUCRMIN
                 SB1->B1_LUCRO2 := SZ1->Z1_LUCRO2
                 SB1->B1_LUCROM2 := SZ1->Z1_LUCROM2
                 If sb1->b1_comis <= 0
                    sb1->b1_comis := SZ1->Z1_COMISSA
                 endif
              endif
           endif
        endif 
        // Incluir Compl. de Produto p/ uso na Tab. 2
        If sb1->b1_tipo == "PA"
           dbselectarea("SB5")
           dbsetorder(1)
           dbseek(xFilial("SB5")+SB1->B1_COD)
           If !found()
              reclock("SB5",.T.)
                 SB5->B5_FILIAL := xFilial("SB5")
                 SB5->B5_COD := SB1->B1_COD
                 SB5->B5_CEME := SB1->B1_DESC
                 SB5->B5_CODATIV := SB1->B1_POSIPI
              msunlock()
           Endif
        Endif

        // Enviar alteracoes p/ representante
        lMandarBrasRepres = .F.
        If (cNumEmp == "01010101") .OR. (cNumEmp == "01060101") // .AND. (SB1->B1_VEND != 'N')
           If SB1->B1_TIPO = 'PA'
              lMandarBrasRepres = .t.
           Else   
              dbselectarea("SX5")
              If DBSEEK(xFilial("SX5")+"Z3"+ALLTRIM(SB1->B1_COD))
                 lMandarBrasRepres = .t.
              ENDIF 
           Endif
        endif
        If lMandarBrasRepres
           U_EnviaRec("SB1",SB1->B1_COD,(SB1->B1_VEND = 'N') .OR. (SB1->B1_MSBLQL = '1'))
           DO CASE
              CASE (SB1->B1_X_SIM3G = "S") .AND. ((SB1->B1_VEND = 'N') .OR. (SB1->B1_MSBLQL = '1'))
                   If !lBloqueouB1
                      reclock("SB1",.F.)
                      lBloqueouB1 := .t.
                   Endif 
                   SB1->B1_X_SIM3G := "N"
                   SB1->B1_X_DTATU := DATE()
                   SB1->B1_X_EXPO  := "N"
              CASE (SB1->B1_X_SIM3G <> "S") .AND. (SB1->B1_VEND <> 'N') .AND. (SB1->B1_MSBLQL <> '1')
                   If !lBloqueouB1
                      reclock("SB1",.F.)
                      lBloqueouB1 := .t.
                   Endif
                   SB1->B1_X_SIM3G := "S"
                   SB1->B1_X_DTATU := DATE()
                   SB1->B1_X_EXPO  := " "
              CASE (SB1->B1_X_SIM3G = "S")
                   If !lBloqueouB1
                      reclock("SB1",.F.)
                      lBloqueouB1 := .t.
                   Endif 
                   SB1->B1_X_DTATU := DATE()
                   SB1->B1_X_EXPO  := " "
           ENDCASE
           dbselectarea("DA1")
           dbsetorder(2) //Cod.Produto + Cod. Tabela + Item                                      
           dbseek(xFilial("DA1")+SB1->B1_COD+"2  ")
           If !eof() .AND. !BOF() .and. (DA1->DA1_FILIAL == xFilial("DA1")) .AND. (DA1->DA1_CODPRO == SB1->B1_COD) .AND. (DA1->DA1_CODTAB = "2  ")
              If !(DA1->DA1_X_SIM3 == SB1->B1_X_SIM3G)
                 reclock("DA1",.F.)
                    DA1->DA1_X_SIM3 := SB1->B1_X_SIM3G
                    DA1->DA1_X_EXPO := " "
                 Msunlock()
              Endif
           Else
              IF SB1->B1_X_SIM3G = "S"
                 nVlrTab := SB1->B1_PRV1
                 If !(SB1->B1_ESTOQUE = "S")
                    dbselectarea("SB5")
                    dbsetorder(1)
                    dbseek(xFilial("SB5")+SB1->B1_COD)
                    If found()
                       nVlrTab := SB5->B5_PRV2
                    Endif
	             Endif
                 dbselectarea("DA1")
                 dbsetorder(3) //Cod. Tabela + Item 
                 dbseek(xFilial("DA1")+"2  9999",.t.)
                 dbskip(-1)
                 if bof() .or. eof()
                    _nItem := 1
                 else
                    _nItem := val(DA1->DA1_ITEM)+1
                 endif
                 _cItem := padl(alltrim(str(_nItem)),4,"0")

                 reclock("DA1",.T.)
                    DA1->DA1_FILIAL := xFilial("DA1")
                    DA1->DA1_ITEM := _cItem
                    DA1->DA1_CODTAB := '2  '
                    DA1->DA1_CODPRO := SB1->B1_COD
                    DA1->DA1_PRCVEN := nVlrTab
                    DA1->DA1_ATIVO := "1"
                    DA1->DA1_TPOPER := "4"
                    DA1->DA1_QTDLOT := 999999.99
                    DA1->DA1_INDLOT := "000000000999999.99  "
                    DA1->DA1_MOEDA := 1
                    DA1->DA1_X_SIM3 := "S"
                 Msunlock()
              ENDIF
           endif	
           IF lBloqueouB1 .AND. (SB1->B1_X_SIM3G = "S")
              cObs := U_ObsProd()
              MSMM(SB1->B1_CODOBS, , , cObs, 1, , , "SB1", "B1_CODOBS")
           ENDIF
        endif 

        // Alteração para verificação dos locais padrão considerando na Matriz Fab1 e Fab2 André 15/05/14
        If (SB1->B1_TIPO == 'MP') .AND. IIF(!(cNumEmp == "01010101"), (!SB1->B1_LOCPAD $ '01.R1'), (!SB1->B1_LOCPAD $ '01.10.R1.R2') )  
           Dbselectarea("SB1")  
           If !lBloqueouB1
              Reclock("SB1",.F.)
                 lBloqueouB1 := .t.
           Endif 
           SB1->B1_LOCPAD = '01'
        Endif

        If (SB1->B1_TIPO == 'PI') .AND. IIF(!(cNumEmp == "01010101"), (!SB1->B1_LOCPAD $ '02.R1'), (!SB1->B1_LOCPAD $ '02.20.R1.R1') )  
           Dbselectarea("SB1")  
           If !lBloqueouB1
              Reclock("SB1",.F.)
                 lBloqueouB1 := .t.
           Endif 
           If Len(Alltrim(SB1->B1_COD)) ==12 .AND. (cNumEmp == "01010101") 
              SB1->B1_LOCPAD = Iif(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(SB1->B1_COD, 04, 02), "Z1_LOCPAD")='20','20','02')
           Else
              SB1->B1_LOCPAD = '02'
           Endif
        Endif
        If (SB1->B1_TIPO == 'PA') .AND. IIF(!(cNumEmp == "01010101"), (!SB1->B1_LOCPAD $ '03.P1'), (!SB1->B1_LOCPAD $ '03.30.P1.P2') )  
           Dbselectarea("SB1")  
           If !lBloqueouB1
              Reclock("SB1",.F.)
                 lBloqueouB1 := .t.
           Endif
           If Len(Alltrim(SB1->B1_COD)) ==12 .AND. (cNumEmp == "01010101") 
              SB1->B1_LOCPAD := Iif(Posicione("SZ1", 1, xFilial("SZ1")+SubStr(SB1->B1_COD, 04, 02), "Z1_LOCPAD")='02','P1','P2')
           Else 
              SB1->B1_LOCPAD := iif(cNumEmp == "01060101","P1","03") //'03' //Cleber(17/10/14) -> Criação do almox. de produtos recem produzidos
           Endif
        Endif

        // Checar almoxarifado
        //IF (SB1->B1_TIPO == 'MP') .AND. (SB1->B1_LOCPAD # '01')    
        //        dbselectarea("SB1")  
        //        reclock("SB1",.F.)
        //        SB1->B1_LOCPAD = '01' 
        //        msunlock()
        //endif
        //IF (SB1->B1_TIPO == 'PI') .AND. (SB1->B1_LOCPAD # '02')   	
        //	dbselectarea("SB1")  
        //	if !lBloqueouB1 
        //		reclock("SB1",.F.)
        //		lBloqueouB1 := .t.
        //	endif 
        //
        //	SB1->B1_LOCPAD = '02'
        //endif
        //IF (SB1->B1_TIPO == 'PA') .AND. (SB1->B1_LOCPAD # '03')   	
        //	dbselectarea("SB1")  
        //	if !lBloqueouB1 
        //		reclock("SB1",.F.)
        //		lBloqueouB1 := .t.
        //	endif 
        //	SB1->B1_LOCPAD = '03'
        //endif

        nPicmret := 35     
        cTs := "   "

        //Índice IBPT (18/06/14) e Verif. se tem ST
        if !EMPTY(SB1->B1_POSIPI)
           dbselectarea("SYD")
           dbsetorder(1)
           dbseek(xFilial("SYD")+SB1->B1_POSIPI+SB1->B1_EX_NCM)
           IF found()     
              if (SB1->B1_IMPNCM <= 0) 
                 nAux := iif(SB1->B1_ORIGEM > "0",SYD->YD_ALIQIM2,SYD->YD_ALIQIMP)
                 IF SB1->B1_IMPNCM != nAux
                    if !lBloqueouB1
                       reclock("SB1",.F.)    
                          lBloqueouB1 := .t.
                    ENDIF 
                    SB1->B1_IMPNCM := nAux
                 ENDIF
              endif
              if SYD->YD_TEM_ST = "2"
                 nPicmret := 0
                 cTs := "502"
              endif 
		
              //Cleber (21/06/17)->Chamado 007485, Preencher campos CEST para tintas, CONVÊNIO ICMS 52, DE 7 DE ABRIL DE 2017
              IF (SUBSTR(cNumEmp,1,4) == "0106") .OR. (substr(cNumEmp,1,4) == "0101")
                 DO CASE
                    CASE SB1->B1_POSIPI = "32061119"
                         SB1->B1_CEST := "2400300"
                    CASE SB1->B1_POSIPI = "32050000"
                         SB1->B1_CEST := "2400300"
                         /* Solicitação Priscila em 05/01/2021, excluir o CEST 2400200 para o NCM 32041700
                    CASE SB1->B1_POSIPI = "32041700"
                         SB1->B1_CEST := "2400200"
                        */
                    CASE SB1->B1_POSIPI = "321000"
                         SB1->B1_CEST := "2400100"
                    CASE SB1->B1_POSIPI = "3212"
                         SB1->B1_CEST := "2400300"
                    CASE SB1->B1_POSIPI = "3206"
                         SB1->B1_CEST := "2400300"
                    CASE SB1->B1_POSIPI = "3204"
                         SB1->B1_CEST := "2400300"
                    CASE SB1->B1_POSIPI = "2821"
                         SB1->B1_CEST := "2400200"
                    CASE SB1->B1_POSIPI = "3209"
                         SB1->B1_CEST := "2400100"
                    CASE SB1->B1_POSIPI = "3208"
                         SB1->B1_CEST := "2400100"
                 ENDCASE
              ENDIF
           ENDIF
        ENDIF
        if (SB1->B1_PICMRET <> nPicmret) .OR. (SB1->B1_TS <> cTs)
           if !lBloqueouB1
              reclock("SB1",.F.)    
                 lBloqueouB1 := .t.
           ENDIF 
           SB1->B1_PICMRET := nPicmret    
           SB1->B1_TS := cTs
        endif 

        //Chamado 008142 (Fernando Mauri), preencher contas contábeis automaticamente
        cConta := ""
        do case
		   /* ALTERAÇÃO DAS CONTAS CONTÁBEIS DE ACORDO COM O PROJETO DE CUSTOS - 25/01/2021#LGS
           case SB1->B1_TIPO = "MP"
                cConta := "101030101001"
           case SB1->B1_TIPO = "PI"
                cConta := "101030102001"
           case SB1->B1_TIPO = "PA"
                cConta := "101030103003"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Z100")
                cConta := "101030105001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "J000")
                cConta := "101030107001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F001")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F006")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F002")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F007")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F008")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F003")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F004")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "F005")
                cConta := "101030108001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "G000")
                cConta := "101030109001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "D100")
                cConta := "101030109002"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "E400")
                cConta := "101030109002"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "L100")
                cConta := "101030112001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "L200")
                cConta := "101030112001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "L300")
                cConta := "101030112001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "L400")
                cConta := "101030112001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "U000")
                cConta := "101030111001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Y100")
                cConta := "101030106001"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Z600")
                cConta := "101030110001" */
           //case SB1->B1_TIPO $ "MP"
           //     cConta := "101010801001"
           case SB1->B1_TIPO $ "MP" .AND. (ALLTRIM(SB1->B1_GRUPO) == "E001")
                cConta := "501010105003"
		   case SB1->B1_TIPO $ "MP" .AND. (ALLTRIM(SB1->B1_GRUPO) <> "E001")
		        cConta := "101010801001"
           case SB1->B1_TIPO $ "PI"
                cConta := "101010801003"
           case SB1->B1_TIPO $ "PA"
                cConta := "101010801004"
           case SB1->B1_TIPO $ "AI.IM"
                cConta := "107040101999"
		   case SB1->B1_TIPO $ "EM"
                cConta := "101010801002"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) $ "D000.D100.J000.L000.L100.L200.L300.L400.Y000")
                cConta := "501010105011"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) $ "F000.F001.F002.F003.F004.F005.F006.F007.E001")
                cConta := "501010105003"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "G000")
                cConta := "501010105010"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "U000")
                cConta := "501010105021"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Y100")
                cConta := "501010107008"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Z100")
                cConta := "501010105022"
           case (SB1->B1_TIPO $ "MC-GG") .AND. (ALLTRIM(SB1->B1_GRUPO) == "Z600")
                cConta := "501010105009"
        endcase                    
        if !empty(cConta)
           if !lBloqueouB1
              reclock("SB1",.F.)    
                 lBloqueouB1 := .t.
           ENDIF 
           SB1->B1_CONTA := cConta
        endif 
      //Chamado 017035, colocar grupo de tributação 003 para qualquer produto com palavras DILUENTE ou SOLVENTE
      if (("DILUENTE" $ SB1->B1_DESC) .OR. ("SOLVENTE" $ SB1->B1_DESC)) .and. !(SB1->B1_GRTRIB = "003")
         if !lBloqueouB1
            reclock("SB1",.F.)
            lBloqueouB1 := .t.
         endif
         SB1->B1_GRTRIB := "003"
      endif 

        if lBloqueouB1
           dbselectarea("SB1")
           msunlock()
        endif 
        U_VoltaArea( aAreaAnt )
        IF !EMPTY( _cAlias )
           DbSelectArea( _cAlias )
        endif 
case _cGrpEmp == '11'
        //Dyego Figueiredo
        //Ponto de entrada apos confirmacao do cadastro do produto
        //valida sequencial B1_XCOD
        seqB1XCOD(nRecnoSB1)

        SB1->(DbGoto(nRecnoSB1))
 
endcase 
U_VoltaArea( aAreaAnt )
IF !EMPTY( _cAlias )
	DbSelectArea( _cAlias )
ENDIF
Return( _lRet )  


//inclui sequencial SB1
Static Function seqB1XCOD(nRecnoSB1)
       Local _proxNum := " "

       DbSelectArea("SB1")

       If INCLUI.AND. Empty(SB1->B1_XCOD) 
          _proxNum := GetSx8Num("SB1","B1_XCOD") 
          //para corrigir erro do proximo numero

          SB1->( dbSetOrder(12) )      
          While SB1->( dbSeek(xFilial("SB1")+  _proxNum))    // AIC_FILIAL, AIC_CODIGO
                _proxNum := GetSx8Num("SB1","B1_XCOD")
                ConfirmSX8()
          EndDo
          SB1->(DbGoto(nRecnoSB1))
          Reclock("SB1",.F.) 
             SB1->B1_XCOD := _proxNum
          SB1->( MsUnlock() )
          dbCloseArea()
       Endif
Return Nil

static Function ValAtrib(atributo)
Return (type(atributo) )
