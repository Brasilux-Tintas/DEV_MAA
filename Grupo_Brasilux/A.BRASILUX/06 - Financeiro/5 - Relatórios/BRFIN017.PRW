#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "avprint.ch"
#xtranslate TRACO_BOLD1 => oPrn:Line( Linha - 1 , 10 , Linha - 1 , 2340 ) ;
                         ; oPrn:Line( Linha     , 10 , Linha     , 2340 ) ;
                         ; oPrn:Line( Linha + 1 , 10 , Linha + 1 , 2340 )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRFIN017 ºAutor  ³ Marcos C.D. Vieira º Data ³  29/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatório de participação sobre faturamento por represen-  º±±
±±º          ³ tante.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BRASILUX TINTAS TÉCNICAS LTDA.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BRFIN017()
     Private oTempTbl01
     SetPrvt("cPerg,cQuery,nPag,cNomeArq,aCampos,cIndex,aInd")


     //=//=//=//=//=//=//=//=//=//=//=//=//   
     //           PARAMETROS             //
     //=//=//=//=//=//=//=//=//=//=//=//=//
     //=//=//=//=//=//=//=//=//=//=//=//=//
     // MV_PAR01   Data de Referencia    // 
     //=//=//=//=//=//=//=//=//=//=//=//=//

     if !u_VldAcesso(funname())
        MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
        return 
     endif 
     u_zcfga01( 'BRFIN017' ) //LGS#2021202 - Gravação de log de utilização da rotina
     cPerg      := "FIN017"
     VldPerg()       
     cIndex     := ""
     aInd       := {}                        
     cNomeArq   := ""
     aCampos    := {}
     Linha      := 0                
     nOpcA      := 0                
     nPag       := 0 
     nFatBrt    := 0
     nFatLiq    := 0      
     cPRWRotina := funname()
     DbSelectArea("SZW")
     DbSetOrder(6)
     DbSeek(__CUSERID + cPRWRotina)
	 if PSWADMIN( cUsername, SubStr(cUsuario, 1, 6),RetCodUsr()) <> 0 .OR.  substr(ZW_ACESSOS,1,1) == "*"
        MsgBox("Acesso não autorizado!","Atenção","Alert")
        return
     endif 

     oDlg       := oSend( MSDialog(), "New", 8, 10, 18, 63,"Relatório de Rentabilidade por Representante.",,,.F.,,,,,GetWndDefault(),.F.,,,.F.)
     @ 20,18  SAY "Este relatório tem como função, Imprimir uma Relação "
     @ 30,18  SAY "de Paticipação sobre o Faturamento por Representante."
     @ 57,170 BMPBUTTON TYPE 05 ACTION (Pergunte("FIN017"))

     bOk     := {||nOpcA := 1, oSend(oDlg, "End")}
     bCancel := {||nOpcA := 0, oSend(oDlg, "End")}
     bInit   := {|| EnchoiceBar(oDlg, bOk, bCancel) }

     oSend( oDlg, "Activate",,,,.T.,,, bInit )

     If nOpca == 0
        Return
     EndIf

     MsAguarde( { || FilSE1FIN017() }, "Aguarde", "Este processamento poderá levar alguns minutos..." )

     DBSelectArea("TCQ")            
     DBGotop()
     If EOF()
        MSGSTOP("Nao ha dados a serem gerados com estes parametros.")
        DBSelectArea("TCQ") 
        Dbcloseare()
        Return
     Endif  
     Processa({|lEnd|RelFin017()})

     DBSelectArea("TCQ") 
     DbCloseArea()
     DBSelectArea("REP")
     DbcloseArea()
     oTempTbl01:Delete()
Return Nil

                         
*----------------------------*                         
Static Function FilSE1FIN017()  
*----------------------------*                                          
       dDtInic  := CTOD("01/"+SUBSTR(DTOC(MV_PAR01),4,5))
       IF SUBSTR(DTOC(MV_PAR01),4,2)$"01*03*05*07*08*10*12"
          dDtFin := CTOD("31/"+SUBSTR(DTOC(MV_PAR01),4,5))
       ELSEIF SUBSTR(DTOC(MV_PAR01),4,2)$"04*06*09*11"
              dDtFin := CTOD("30/"+SUBSTR(DTOC(MV_PAR01),4,5))
       ELSEIF SUBSTR(DTOC(MV_PAR01),4,2) == "02"          
              dDtFin := CTOD("28/"+SUBSTR(DTOC(MV_PAR01),4,5))
       ENDIF  

       cQuery  := "SELECT F2_VALBRUT,F2_VALMERC,F2_VEND1 "
       cQuery  += "FROM "+RetSqlName("SF2")+" "
       cQuery  += "WHERE F2_FILIAL = '"+xFilial("SF2")+ "' AND "
       cQuery  += "F2_EMISSAO BETWEEN '"+DTOS(ddtinic)+"' AND '"+DTOS(ddtfin)+"' AND "
       cQuery  += "F2_TIPO = 'N' AND D_E_L_E_T_ <> '*' "
       cQuery  += "ORDER BY F2_VEND1 "
       cQuery  := ChangeQuery(cQuery)
       DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TCQ", .F.)

       DBSelectArea("TCQ")            
       DBGotop()
       If EOF()
          Return 
       Endif

       cNomeArq := ""
       aCampos  := {}
                                    
       AADD(aCampos, { "CODREP" ,"C",06,0})
       AADD(aCampos, { "VALBRT" ,"N",15,2})
       AADD(aCampos, { "VALLIQ" ,"N",15,2})

       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25                  ***/
       //cNomeArq := CriaTrab(aCampos)
       //cIndex   := CriaTrab(nil,.f.)
       //AADD(aInd,cIndex)

       //dbUseArea( .T.,, cNomeArq, "REP", .F. , .F. )
       //IndRegua("REP",cNomeArq,"CODREP",,,"Selecionando Registros...") 

       oTempTbl01 := FWTemporaryTable():New( "REP" )
       oTempTbl01:SetFields( aCampos )
       oTempTbl01:AddIndex( "cInd01", { "CODREP" } )
       oTempTbl01:Create()
       /********************************************************************************************************************************/

       nFatBrt    := 0
       nFatLiq    := 0
         
       DBSelectArea("TCQ")            
       DBGotop()
       DO WHILE !EOF()
          DBSelectArea("REP")
          DBSetOrder(1)
          DBSeek(TCQ->F2_VEND1,.F.)
          If FOUND()
             Reclock("REP",.F.)
          Else
             Reclock("REP",.T.)
                CODREP := TCQ->F2_VEND1
          Endif
          VALBRT += TCQ->F2_VALBRUT
          VALLIQ += TCQ->F2_VALMERC
          MsUnlock()

          nFatBrt += TCQ->F2_VALBRUT
          nFatLiq += TCQ->F2_VALMERC                   
                          
          DBSelectArea("TCQ")
          DBSkip()
       ENDDO        
        
       DBSelectArea("REP")
       IndRegua("REP",cIndex,"VALBRT",,,"Selecionando Registros...") 
Return 
            

*-------------------------*
Static Function RelFIN017() 
*-------------------------*                     
oPrn:= TMSPrinter():New( "Relatório de Participação sobre Faturamento por Representante.")
oPrn:SetPortrait()     //SetLandscape()   

AVPRINT oPrn NAME "Relatório de Participação sobre Faturamento por Representante."
ProcRegua(150)

oFont1    := TFont():New("Arial"      ,9,07,.F.,.T.,5,.T.,5,.T.,.F.)
oFont2    := TFont():New("Courier New",9,14,.F.,.T.,5,.F.,5,.T.,.F.)
oFont3    := TFont():New("Courier New",9,10,.F.,.T.,5,.F.,5,.T.,.F.)
oFont4    := TFont():New("Courier New",9,10,.F.,.F.,5,.T.,5,.T.,.F.) 

AVPAGE

DBSelectArea("REP")
DBSetOrder(1)
DBGotop()
DO WHILE !EOF()  
 
  IF nPag == 0 .OR. Linha > 3200
    FIN017Cab()
  ENDIF                               
  
  DBSelectArea("SA3")
  DBSetOrder(1)
  DBSeek(xFilial("SA3")+REP->CODREP)
 
  nPerBrt := (REP->VALBRT/nFatBrt)*100 
  nPerLiq := (REP->VALLIQ/nFatLiq)*100
           
  oPrn:Say( Linha , 0010 , REP->CODREP+"-"+SA3->A3_NREDUZ              , oFont4 )
  oPrn:Say( Linha , 0800 , Transform(REP->VALBRT ,"@E 999,999,999.99") , oFont4 )   
  oPrn:Say( Linha , 1380 , Transform(nPerBrt     ,"@E 999.99")+"%"     , oFont4 ) 
  oPrn:Say( Linha , 1720 , Transform(REP->VALLIQ ,"@E 999,999,999.99") , oFont4 )
  oPrn:Say( Linha , 2150 , Transform(nPerLiq     ,"@E 999.99")+"%"     , oFont4 ) 
  Linha += 60   

  DBSelectArea("REP")
  DBSkip()
ENDDO  
  
Linha += 120   
oPrn:Say( Linha , 0010 , "FAT.TOTAL DO MÊS C/IMPOSTOS"          , oFont3 )
oPrn:Say( Linha , 0700 , Transform(nFatBrt,"@E 999,999,999.99") , oFont4 ) 
oPrn:Say( Linha , 1300 , "FAT.TOTAL DO MÊS S/IMPOSTOS"          , oFont3 )
oPrn:Say( Linha , 2000 , Transform(nFatLiq,"@E 999,999,999.99") , oFont4 )

AVENDPAGE
AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()

MS_FLUSH()

dbSelectArea("REP")
Use
Ferase(cNomeArq+".DBF")         // Elimina arquivos de Trabalho
Ferase(cNomeArq+OrdBagExt())   
Ferase(cIndex+OrdBagExt())     

Return nil 



*-------------------------*
Static FUNCTION FIN017Cab()
*-------------------------*      

If Linha <> 0
  AVNEWPAGE
Endif
      
nPag  += 1
Linha := 10                           
cMes  := MesExtenso(Month(MV_PAR01))

oPrn:Say( Linha , 010  , "BRASILUX"                        , oFont1 )
oPrn:Say( Linha , 650  , "PARTICIPAÇÃO POR REPRESENTANTE" , oFont2 )
oPrn:Say( Linha , 2100 , "PAG........:"                    , oFont1 )
oPrn:Say( Linha , 2260 , STRZERO(nPag,3)                   , oFont1 ) 
Linha += 70
oPrn:Say( Linha , 10   , "Referente ao Mês: "+cMes         , oFont1 )        
oPrn:Say( Linha , 2100 , "Emissao.:"                       , oFont1 )
oPrn:Say( Linha , 2240 , DTOC(dDataBase)                   , oFont1 ) 
Linha += 40
TRACO_BOLD1 
Linha += 20   
oPrn:Say( Linha , 0010 , "REPRESENTANTE"                   , oFont3 ) 
oPrn:Say( Linha , 0800 , "FAT. C/IMPOSTOS"                 , oFont3 )
oPrn:Say( Linha , 1380 , "% PART."                         , oFont3 )
oPrn:Say( Linha , 1720 , "FAT. S/IMPOSTOS"                 , oFont3 )
oPrn:Say( Linha , 2180 , "% PART."                         , oFont3 )
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
//=//=//=//=//=//=//=//=//=//=//=//=//
// MV_PAR01   Data de Ref.   ?      // 
//=//=//=//=//=//=//=//=//=//=//=//=//
cPerg := PADR(cPerg,10)
//          Grupo/Ordem/Pergunta/PersPa/Pereng/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Data de Ref. ? ","","","mv_ch1" ,"D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,""})

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
dbSelectArea(_sAlias)

Return
