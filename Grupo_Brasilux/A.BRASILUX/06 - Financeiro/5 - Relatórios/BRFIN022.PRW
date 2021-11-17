#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "avprint.ch"
#xtranslate TRACO_BOLD1  => oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 ) ;
                          ; oPrn:Line( Linha     , 10 , Linha     , 2340 ) ;
                          ; oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
#xtranslate TRACO_NORMAL => oPrn:Line( Linha     , 10 , Linha     , 2340 )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRFIN022  ºAutor  ³ Marcos C.D. Vieira º Data ³  02/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de despesas de motoristas.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN022()

     SetPrvt("cPerg,cQuery,nPag,cNomeArq,aCampos,cIndex,aInd")


     //=//=//=//=//=//=//=//=//=//=//=//=//   
     //           PARAMETROS             //
     //=//=//=//=//=//=//=//=//=//=//=//=//
     // MV_PAR01   Motorista Inicial     // 
     // MV_PAR02   Motorista Final       // 
     // MV_PAR03   Mês de Referencia     // 
     //=//=//=//=//=//=//=//=//=//=//=//=//
     
   if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 


     cPerg      := "FIN022"
     VldPerg()       
     cIndex     := ""
     aInd       := {}                        
     cNomeArq   := ""
     aCampos    := {}
     Linha      := 0                
     nOpcA      := 0                
     nPag       := 0 
     nCredMot   := 0 
     nDebMot    := 0
     nSaldo     := 0
     cCodigo    := SPACE(06)
     dDtInic    := CTOD("")
     dDtFin     := CTOD("")
     cSld_A_T   := "A"
     Private aCodMot  := {}
     Pergunte("FIN022", .f.)

     oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Relatório de Despesas de Motorista.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)

     @ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação "
     @ 30,18  SAY "de despesas de viagens de motoristas."
     @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("FIN022"))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )
    
     If nOpca == 0
        Return
     EndIf

     MsAguarde({|| FilSE2FIN022() },"Aguarde","Este processamento poderá levar alguns minutos...")

     DBSelectArea("TCQ")            
     DBGotop()
     If EOF()
        MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
        DBSelectArea("TCQ") 
        Dbcloseare()
        Return
     Endif  

     Processa({|lEnd|RelFin022()})

     DBSelectArea("TCQ") 
     Dbcloseare()

Return Nil

                         
*----------------------------*
Static Function FilSE2FIN022()
*----------------------------*
       dDtInic  := CTOD("01/"+SUBSTR(DTOC(MV_PAR03),4,5))
       /*
       IF SUBSTR(DTOC(MV_PAR03),4,2)$"01*03*05*07*08*10*12"
          dDtFin := CTOD("31/"+SUBSTR(DTOC(MV_PAR03),4,5))
       ELSEIF SUBSTR(DTOC(MV_PAR03),4,2)$"04*06*09*11"
              dDtFin := CTOD("30/"+SUBSTR(DTOC(MV_PAR03),4,5))
       ELSEIF SUBSTR(DTOC(MV_PAR03),4,2) == "02"          
              dDtFin := CTOD("28/"+SUBSTR(DTOC(MV_PAR03),4,5))
       ENDIF  */
       dDtFin := CTOD(StrZero(F_ULTDIA(dDtInic), 2)+'/'+StrZero(Month(MV_PAR03), 2)+'/'+StrZero(Year(MV_PAR03), 4))
       
//       cQuery  := "SELECT * "
//       cQuery  += "FROM "+RetSqlName("SE2")+" "
//       cQuery  += "WHERE E2_FILIAL = '"+xFilial("SE2")+ "' AND "
//       cQuery  += "E2_EMISSAO BETWEEN '"+DTOS(ddtinic)+"' AND '"+DTOS(ddtfin)+"' AND "
//       cQuery  += "E2_FORNECE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
//       cQuery  += "D_E_L_E_T_ <> '*' "
//       cQuery  += "ORDER BY E2_FORNECE,E2_EMISSAO"

       cQry1 := ""
       cQry1 += "SELECT SA2.A2_COD "
       cQry1 += "FROM "+RetSqlName("SA2")+" SA2 "
       cQry1 += "WHERE SA2.A2_FILIAL  = '' "
       cQry1 += "  AND SA2.D_E_L_E_T_ = '' "
       cQry1 += "  AND SUBSTRING(SA2.A2_COD, 1, 3) = 'MOT' "
       cQry1 += "ORDER BY SA2.A2_COD "
       TCQuery cQry1 ALIAS "TCQ" NEW
       DbSelectArea("TCQ")
       While !Eof()
             aAdd(aCodMot, {TCQ->A2_COD, ""})
             DbSelectArea("TCQ")
             DbSkip()
       Enddo
       DbSelectArea("TCQ")
       DbCloseArea()
       
       cQuery  := ""
       cQuery  += "SELECT SE2.E2_NUM, SE2.E2_PREFIXO, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_EMISSAO, SE2.E2_VALOR "
       cQuery  += "FROM "+RetSqlName("SE2")+" SE2 WITH (NOLOCK) "
       cQuery  += "WHERE SE2.E2_FILIAL = '"+xFilial("SE2")+"' "
       cQuery  += "  AND SE2.E2_EMISSAO BETWEEN '"+DTOS(ddtinic)+"' AND '"+DTOS(ddtfin)+"' "
       cQuery  += "  AND SE2.E2_FORNECE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
       cQuery  += "  AND SE2.D_E_L_E_T_ <> '*' "
       cQuery  += "UNION ALL "
       cQuery  += "SELECT SE5.E5_NUMERO AS E2_NUM, SE5.E5_PREFIXO AS E2_PREFIXO, SE5.E5_TIPO AS E2_TIPO, SE5.E5_FORNADT AS E2_FORNECE, SE5.E5_DATA AS E2_EMISSAO, SE5.E5_VALOR AS E2_VALOR "
       cQuery  += "FROM "+RetSqlName("SE5")+" SE5 WITH (NOLOCK) "
       cQuery  += "WHERE SE5.E5_FILIAL = '"+xFilial("SE5")+"' "
       cQuery  += "  AND SE5.D_E_L_E_T_ = '' "
       cQuery  += "  AND SE5.E5_FORNADT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
       cQuery  += "  AND SE5.E5_DATA BETWEEN '"+DTOS(ddtinic)+"' AND '"+DTOS(ddtfin)+"' "
       cQuery  += "  AND SE5.E5_CLIFOR NOT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
       cQuery  += "ORDER BY 4, 5 "
       TCQuery cQuery ALIAS "TCQ" NEW
       //cQuery  := ChangeQuery(cQuery)
       //DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)
       DbSelectArea("TCQ")
Return 
            

*-------------------------*
Static Function RelFIN022()
*-------------------------*
       oPrn:= TMSPrinter():New( "Relatório de Despesas de Motorista.")
       oPrn:SetPortrait()     //SetLandscape()   

       AVPRINT oPrn NAME "Relatório de Despesas de Motorista."
               ProcRegua(150)

               oFont1    := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
               oFont2    := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
               oFont3    := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
               oFont4    := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.)
               oFont5    := TFont():New("Arial"      ,9,10,.F.,.T.,5,.T.,5,.T.,.F.) 

               AVPAGE
                 _nY := 0
                 DBSelectArea("TCQ")
                 DO WHILE !EOF()
                    _nY += 1
                    cCodigo := TCQ->E2_FORNECE
                    If Alltrim(aCodMot[_nY][1]) <> Alltrim(cCodigo)
                       DbSelectArea("SZV")
                       DBSetOrder(1)
                       DBSeek(xFilial("SZV")+aCodMot[_nY][1]+DTOS(dDtInic-1))
                       If Found()
                          nSaldo := ZV_SALDO
                       Else                
                          nSaldo := 0
                       Endif  
                       If nSaldo > 0
                          DbSelectArea("SA2")
                          DBSetOrder(1)
                          DBSeek(xFilial("SA2")+aCodMot[_nY][1])
                          Linha += 60   
                          oPrn:Say( Linha , 0010 , "MOTORISTA : "+aCodMot[_nY][1]+"  "+SA2->A2_NOME, oFont5 )
                          If cSld_A_T == "T"
                             oPrn:Say( Linha , 1670 , "Saldo a Transportar : "                      , oFont5 )
                          Else   
                             oPrn:Say( Linha , 1670 , "Saldo Anterior : "                           , oFont5 )
                          Endif  
                          oPrn:Say( Linha , 2000 , Transform(nSaldo,"@E 999,999,999.99")           , oFont5 ) 
                          Linha += 80
                          TRACO_NORMAL
                       Endif
                       DBSelectArea("TCQ")
                       Loop
                    Endif
                    DbSelectArea("SZV")
                    DBSetOrder(1)
                    DBSeek(xFilial("SZV")+cCodigo+DTOS(dDtInic-1))
                    If Found()
                       nSaldo := ZV_SALDO
                    Else                
                       nSaldo := 0
                    Endif  
  
                    If nPag <> 0                              
                       DbSelectArea("SA2")
                       DBSetOrder(1)
                       DBSeek(xFilial("SA2")+cCodigo)
                       Linha += 30   
                       oPrn:Say( Linha , 0010 , "MOTORISTA : "+cCodigo+"  "+SA2->A2_NOME , oFont5 )    
                       oPrn:Say( Linha , 1670 , "Saldo Anterior : "                      , oFont5 )
                       oPrn:Say( Linha , 2000 , Transform(nSaldo,"@E 999,999,999.99")    , oFont5 ) 
                       Linha += 80         
                       cSld_A_T := "T"
                       
                    Endif  
  
                    DBSelectArea("TCQ")
                    DO WHILE !EOF() .AND. cCodigo == TCQ->E2_FORNECE
                       IF nPag == 0 .OR. Linha > 3060
                          If nPag <> 0
                             Linha += 50
                             oPrn:Say( Linha , 0010 , "SUBTOTAL"                             , oFont5 )
                             oPrn:Say( Linha , 01220, Transform(nDebMot ,"@E 999,999,999.99"), oFont5 )    
                             oPrn:Say( Linha , 01590, Transform(nCredMot,"@E 999,999,999.99"), oFont5 )
                             oPrn:Say( Linha , 2000 , Transform(nSaldo  ,"@E 999,999,999.99"), oFont5 ) 
                             Linha += 60   
                             TRACO_NORMAL         
                          Endif
    
                          FIN022Cab()
   
                          DbSelectArea("SA2")
                          DBSetOrder(1)
                          DBSeek(xFilial("SA2")+TCQ->E2_FORNECE)
      
                          oPrn:Say( Linha , 0010 , "MOTORISTA : "+TCQ->E2_FORNECE+"  "+SA2->A2_NOME, oFont5 )
                          If cSld_A_T == "T"
                             oPrn:Say( Linha , 1670 , "Saldo a Transportar : "                      , oFont5 )
                          Else   
                             oPrn:Say( Linha , 1670 , "Saldo Anterior : "                           , oFont5 )
                          Endif  
                          oPrn:Say( Linha , 2000 , Transform(nSaldo,"@E 999,999,999.99")           , oFont5 ) 

                          Linha += 80   
                       ENDIF                                                                           
                       cData := SUBSTR(TCQ->E2_EMISSAO,7,2)+"/"+SUBSTR(TCQ->E2_EMISSAO,5,2)+"/"+SUBSTR(TCQ->E2_EMISSAO,3,2)
                       oPrn:Say( Linha , 0010 , cData                                          , oFont4 )
                       If ALLTRIM(TCQ->E2_TIPO) == "PA"
                          oPrn:Say( Linha , 0220 , "ADIANTAMENTO DE VIAGEM(PA)"                 , oFont4 ) 
                          oPrn:Say( Linha , 1220 , Transform(TCQ->E2_VALOR,"@E 999,999,999.99") , oFont4 ) 
                          nSaldo  := nSaldo  + TCQ->E2_VALOR
                          nDebMot := nDebMot + TCQ->E2_VALOR
                       ELSEIF ALLTRIM(TCQ->E2_TIPO) == "RDV"
                              oPrn:Say( Linha , 0220 , "DESPESA DE VIAGEM(RDV)    "                 , oFont4 )   
                              oPrn:Say( Linha , 1590 , Transform(TCQ->E2_VALOR,"@E 999,999,999.99") , oFont4 )   
                              nSaldo   := nSaldo   - TCQ->E2_VALOR 
                              nCredMot := nCredMot + TCQ->E2_VALOR
                       ELSEIF ALLTRIM(TCQ->E2_TIPO) == "ACE"
                              oPrn:Say( Linha , 0220 , "DEVOLUÇÃO P/ACERTO(ACE)   "                 , oFont4 )   
                              oPrn:Say( Linha , 1590 , Transform(TCQ->E2_VALOR,"@E 999,999,999.99") , oFont4 )   
                              nSaldo   := nSaldo   - TCQ->E2_VALOR 
                              nCredMot := nCredMot + TCQ->E2_VALOR
                       ELSEIF ALLTRIM(TCQ->E2_TIPO) $ "NF"
                              oPrn:Say( Linha , 0220 , "OUTRAS DESPESAS COM NF    "                 , oFont4 )   
                              oPrn:Say( Linha , 1590 , Transform(TCQ->E2_VALOR,"@E 999,999,999.99") , oFont4 )   
                              nSaldo   := nSaldo   - TCQ->E2_VALOR 
                              nCredMot := nCredMot + TCQ->E2_VALOR
                       ENDIF
                       oPrn:Say( Linha , 0850 , TCQ->E2_PREFIXO+" "+TCQ->E2_NUM                , oFont4 )   
                       oPrn:Say( Linha , 2000 , Transform(nSaldo,"@E 999,999,999.99")          , oFont4 ) 
                       Linha += 40   

                       DBSelectArea("TCQ")
                       DBSkip()
                    ENDDO  
                    Linha += 40
                    oPrn:Say( Linha , 0010 , "TOTAL"                                , oFont5 )
                    oPrn:Say( Linha , 1220 , Transform(nDebMot ,"@E 999,999,999.99"), oFont5 )
                    oPrn:Say( Linha , 1590 , Transform(nCredMot,"@E 999,999,999.99"), oFont5 )
                    oPrn:Say( Linha , 2000 , Transform(nSaldo  ,"@E 999,999,999.99"), oFont5 )
                    Linha += 60   
                    TRACO_NORMAL
                    nDebMot  := 0
                    nCredMot := 0
                    nSaldo   := 0

                 ENDDO  

               AVENDPAGE
       AVENDPRINT

       oFont1:End()
       oFont2:End()
       oFont3:End()
       oFont4:End()
       oFont5:End()

       MS_FLUSH()

Return nil 

*-------------------------*
Static FUNCTION FIN022Cab()
*-------------------------*      
       If Linha <> 0
          AVNEWPAGE
       Endif
      
       nPag  += 1
       Linha := 10                           
       cMes  := MesExtenso(Month(MV_PAR03))

       oPrn:Say( Linha , 010  , "BRASILUX"                            , oFont1 )
       oPrn:Say( Linha , 640  , "RELATÓRIO DE DESPESAS DE MOTORISTAS" , oFont2 )
       oPrn:Say( Linha , 2100 , "PAG........:"                        , oFont1 )
       oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                       , oFont1 ) 
       Linha += 70
       oPrn:Say( Linha , 10   , "Referente ao Mês: "+cMes             , oFont1 )        
       oPrn:Say( Linha , 2100 , "Emissao.:"                           , oFont1 )
       oPrn:Say( Linha , 2240 , DTOC(dDataBase)                       , oFont1 ) 
       Linha += 40
       TRACO_BOLD1 
       Linha += 20   
       oPrn:Say( Linha , 0010 , "DATA"                                , oFont3 ) 
       oPrn:Say( Linha , 0220 , "OPERAÇÃO"                            , oFont3 )
       oPrn:Say( Linha , 0900 , "DOCUMENTO"                           , oFont3 )
       oPrn:Say( Linha , 1350 , "DEBITO"                              , oFont3 )
       oPrn:Say( Linha , 1720 , "CREDITO"                             , oFont3 )
       oPrn:Say( Linha , 2180 , "SALDO"                               , oFont3 )
       Linha += 70
       TRACO_BOLD1
       Linha += 30 
 
Return NIL                              

//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
// Função....: VldPerg                             //
// Data......: 14/03/03                            //
// Descrição.: Verifica as perguntas incluindo-as  //
//             caso não existam                    //
// Uso.......: BRCON006                            //
//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//=//
*-----------------------*
Static Function VldPerg() 
*-----------------------*     
       Local _sAlias := Alias()
       Local i, j
       dbSelectArea("SX1")
       dbSetOrder(1)
       aRegs:={}

       //=//=//=//=//=//=//=//=//=//=//=//=//   
       //           PARAMETROS             //
       //=//=//=//=//=//=//=//=//=//=//=//=//
       // MV_PAR01   Motorista Inicial     // 
       // MV_PAR02   Motorista Final       // 
       // MV_PAR03   Mês de Referencia     // 
       //=//=//=//=//=//=//=//=//=//=//=//=//
       cPerg := PADR(cPerg,10)
       //          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Motorista Inicial? ","","","mv_ch1" ,"C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"02","Motorista Final?   ","","","mv_ch2" ,"C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"03","Data de Referência?","","","mv_ch3" ,"D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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