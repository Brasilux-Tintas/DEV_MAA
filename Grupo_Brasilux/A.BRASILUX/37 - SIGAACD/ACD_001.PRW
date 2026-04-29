#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "APVT100.CH"
#Include "TopConn.ch"

User Function ACD_001()

Private aTela                
Private aCab        := { "Produto  ", "Total", "Lidos", "NF","Chave", "Pallet" } //, "Recno"
Private aRet        := {}
Private aSize       := { 10, 5, 5 , 6 , 15 , 15 , 15 , 15}
Private _cNota      := SPACE( 44 )
Private _lHabilita  := .T.
Private nQtdNf      := 0
Private nSaldo      := 0
Private nQtdPallet  := 0
Private nItemPallet := 0
Private nNFitens    := 0 


If IsTelnet()
 
   aTela :=VtSave() 
   VTClear()
   While .t. 

        @ 0,0 VTSay "Cod.Bar:"  VTGet _cNota  When _lHabilita Valid ACD_COD( _cNota )
        @ 1,0 VTSay "NF     :"+ Alltrim(Str(nQtdNf))     + "("+ Alltrim(Str(nNFitens))+ ")"     
        @ 2,0 VTSay "Pallet :"+ Alltrim(Str(nQtdPallet)) + "("+ Alltrim(Str(nItemPallet))+ ")"     
        VtRead()

        If VTLastKey() == 27
          Exit
        EndIf
   End             
   VtRestore(,,,,aTela)

       
Else
        Alert("Esta rotina pode ser executada somente através do telnet (coletor de dados).")
Endif    

Return( Nil )

/* Identifica tipo de Codigo */
STATIC Function ACD_COD(_cCodNF)

        

        if VTLastKey() == 24
            VtABrowse( 3,0,10,20, aCab, aRet, aSize)
        EndIf


        if (Alltrim(_cCodNF) == "x") .OR. (Alltrim(_cCodNF) == "X")
            ACD_SAVE()
        EndIf

        if len(AllTrim(_cCodNF)) <= 9 .OR. len(AllTrim(_cCodNF)) == 44
                
                /* Nota Fiscal */        
                ACD_NF( _cCodNF )        

        else
                /* Etiqueta Pallet */        
                ACD_PLT( _cCodNF )        
        EndIf        


Return()

/*/{Protheus.doc} ACD_PLT
Localiza Produtos no Array e alimenta o campo lidos
com a qtd no pallet
@type function
@author neliedercorneta
@since 08/12/2022
/*/
STATIC Function ACD_PLT( _cCodNF )
Local nPos 
Local nLidos
Local nSoma
Local Produt
Local Doc
Local CodPLT
Local cChave
Local cPallet
Local cRecno


    nPos := aScan(aRet, {|x| AllTrim(x[6]) == Alltrim(_cCodNF)})
     
    If nPos > 0
       VTBeep( 3 )
       VTAlert( "VC_1. Pallet "+AllTrim(aRet[nPos][6])+" já informado já informada ! .", "Aviso", .T., 2500)
       _cNota := SPACE( 44 )
       Return .F. 
    else
    
        If !ACD_VLD(_cCodNF)
            Return .F.
        EndIf
        
        CodPLT := AllTrim(SUBSTR(_cCodNF,1,6)+"/"+SUBSTR(_cCodNF,7,4))    
        DbSelectArea("ZZK") //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
        ZZK->( DbSetOrder( 1 ) )
        If ZZK->( DbSeek( xFilial("ZZK") + PadR(CodPLT, tamsx3('ZZK_CODIGO') [1])  ))    
        
            nQtdPallet := nQtdPallet + 1
            While AllTrim(ZZK->ZZK_CODIGO) == AllTrim(CodPLT)
                
                nPos := aScan(aRet, {|x| AllTrim(x[1]) == Alltrim(ZZK->ZZK_PRODUT)})
                
                If nPos > 0

                        Produt     := aRet[nPos][1] 
                        nSoma      := aRet[nPos][2]
                        nLidos     := aRet[nPos][3] + ZZK->ZZK_QUANT
                        Doc        := aRet[nPos][4] 
                        cChave     := aRet[nPos][5] 
                        cRecno     := aRet[nPos][8] 
                        cPallet    := Alltrim(_cCodNF)

                        //nQtdPallet := nQtdPallet + ZZK->ZZK_QUANT
                        nItemPallet  := nItemPallet + ZZK->ZZK_QUANT

                        nSaldo     := nNFitens   - nItemPallet

                        ADel( aRet, nPos )   
                        ASize( aRet, len(aRet)-1 )    
                        aAdd( aRet, { Produt, nSoma, nLidos , Doc , cChave , cPallet , ZZK->ZZK_CODBAR ,cRecno  } ) //, cRecno

                Else

                    VTBeep( 3 )
                    VTAlert( "VC_33. Produto "+Alltrim(ZZK->ZZK_PRODUT)+" não localizado ! .", "Aviso", .T., 2500)
                    _cNota := SPACE( 44 )
                    Return .F.

                EndIf

                ZZK->(dbSkip()) 
            EndDo
        Else

        VTBeep( 3 )
        VTAlert( "VC_33. Pallet não Localizado ! .", "Aviso", .T., 2500)
        _cNota := SPACE( 44 )
        Return .F.

        EndIf

    EndIf


    If (nNFitens == nItemPallet) .AND. (nNFitens <> 0)
         
        If  VTYesNo('Salvar ?','Deposito',.T.)
            ACD_SAVE()
            VTBeep( 3 )
            VTAlert( "VC_33. Comfirmado com Sucesso ! .", "Aviso", .T., 2500)
        Else
            VTBeep( 3 )
            VTAlert( "VC_34. Processo Cancelado ! .", "Aviso", .T., 2500)    
        EndIf

    EndIf

Return()


Static Function ACD_VLD(_cCodNF)
Local cRet := .F.

CodPLT := AllTrim(SUBSTR(_cCodNF,1,6)+"/"+SUBSTR(_cCodNF,7,4))    
DbSelectArea("ZZK") //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
ZZK->( DbSetOrder( 1 ) )
If ZZK->( DbSeek( xFilial("ZZK") + PadR(CodPLT, tamsx3('ZZK_CODIGO') [1])  ))    

    While AllTrim(ZZK->ZZK_CODIGO) == AllTrim(CodPLT)
        
        nPos := aScan(aRet, {|x| AllTrim(x[1]) == Alltrim(ZZK->ZZK_PRODUT)})
        
        If nPos > 0

            cRet := .T.

        Else

            VTBeep( 4 )
                VTAlert( "VC_33. Produto "+Alltrim(ZZK->ZZK_PRODUT)+" não localizado no Pallet "+AllTrim(ZZK->ZZK_CODIGO)+" ! .", "Aviso", .T., 2500)
            _cNota := SPACE( 44 )
            Return(.F.)

        EndIf

        ZZK->(dbSkip()) 
    EndDo
Else


EndIf



Return(cRet)


Static Function ACD_SAVE()
Local i



// Parametro que habilita a inserção dos dados
if !GETMV("ZP_PAR0081") 
    Return .T.
EndIf

For i := 1 To len(aRet)

    if !Empty(aRet[i][7]) 
        RecLock("Z14",.T.)

            Z14->Z14_FILIAL  := xFilial("Z14")
            Z14->Z14_TABELA  := "SF2"
            Z14->Z14_RECNO   := val(aRet[i][8])
            Z14->Z14_OPERAC  := "CONFDEP"
            Z14->Z14_USER    := RetCodUsr()
            Z14->Z14_DIA     := dDataBase
            Z14->Z14_HORA    := StrTran( SUBSTR(Time(),1,5), ':', '' )
            Z14->Z14_CODBAR  := AllTrim(aRet[i][7])
            Z14->Z14_PROCES  := .F.

        MsUnLock() 

    EndIf    
Next

_cNota      := SPACE( 44 )
aRet        := {}
_lHabilita  := .T.
nQtdNf      := 0
nSaldo      := 0
nQtdPallet  := 0
nItemPallet := 0
nNFitens    := 0 

VTClear()
VtRestore(,,,,aTela)



Return()





STATIC Function ACD_NF( _cCodNF )
Local _lRet := .T.
Local nPos 
Local nSoma
Local nTotal

    If len(_cCodNF) == 44
        nPos := aScan(aRet, {|x| AllTrim(x[5]) == Alltrim(_cCodNF)})
    else
        nPos := aScan(aRet, {|x| AllTrim(x[4]) == Alltrim(_cCodNF)})
    End    
    
    If nPos > 0
       VTBeep( 3 )
       VTAlert( "VC_1. Nota Fiscal "+AllTrim(aRet[nPos][4])+" já informada ! .", "Aviso", .T., 2500)
       _cNota := SPACE( 44 )
       Return .F.         
    EndIf
    
    If Empty( _cCodNF )
       // VTBeep( 3 )
       // VTAlert( "VC_2. Codigo da Nota Fiscal não pode estar vazio.", "Aviso", .T., 2500)
        _cNota := SPACE( 44 )
        _lRet := .F.
    Else
        
        
            
            cQuery := " SELECT F2_DOC,F2_SERIE,F2_CHVNFE "
            cQuery += " FROM "+RetSqlName("SF2")+" SC2 WITH (NOLOCK) WHERE  "

            /* consulta nota via chave coletor */
            If Len(AllTrim(_cNota)) == 44    
                cQuery += " F2_CHVNFE = '"+Alltrim(_cNota)+"' "
            Else 
                cQuery += " F2_DOC    = '"+Alltrim(_cNota)+"' "    
            EndIf

            cQuery += " AND F2_FILIAL = '"+xFilial("SC2")+"' AND F2_SERIE = '1' AND D_E_L_E_T_ = '' "

            IF Select("TEMP") <> 0
	            DbSelectArea("TEMP")
                DbCloseArea()
            ENDIF

            TCQuery cQuery New Alias "TEMP"

            Count To nTotal 

            TEMP->(dbGoTop())
            
            If nTotal == 0

                VTBeep( 3 )
                VTAlert( "VC_3. Nota Fiscal "+_cCodNF+" não localizada !", "Aviso", .T., 2500)    
                _cNota := SPACE( 44 )
                Return(.F.)

            Else

                _cCodNF := AllTrim(TEMP->F2_DOC)      
            
            EndIf

        
        
        DbSelectArea("SD2") //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_CF+D2_COD+D2_ITEM                                                                                               
        SD2->( DbSetOrder( 3 ) )
        If SD2->( DbSeek( xFilial("SD2") + PadR(_cCodNF, tamsx3('D2_DOC') [1]) + '1  ' ))

            DbSelectArea("SF2") //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
            SF2->( DbSetOrder( 1 ) )
            SF2->( DbSeek( xFilial("SF2") + SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE  ))

            IF (SF2->F2_CGC == "72770878000540") 
                
                /* pesquisa notas cadastradas */
                cQuery := " SELECT TOP 1 R_E_C_N_O_ AS REG FROM Z14010 Z14 WHERE (D_E_L_E_T_ <> '*') AND "
                cQuery += " (Z14_OPERAC = 'CONFDEP') AND (Z14_TABELA = 'SF2') AND (Z14_RECNO = "+AllTrim(Str(SF2->(RecNo())))+") "
                
                IF Select("TMP") <> 0
	                DbSelectArea("TMP")
	            DbCloseArea()
                ENDIF

                TCQuery cQuery New Alias "TMP"
                Count To nTotal 
                TEMP->(dbGoTop())

                If nTotal >= 1

                    VTBeep( 3 )
                    VTAlert( "VC_4. Nota Fiscal "+_cCodNF+" já conferida !", "Aviso", .T., 2500)    
                    _cNota := SPACE( 44 )
                    _lRet := .F.

                
                Else
                    nQtdNf++
                    While AllTrim(SD2->D2_DOC) == AllTrim(_cCodNF)

                        nNFitens := nNFitens + SD2->D2_QUANT
                        nPos := aScan(aRet, {|x| AllTrim(x[1]) == Alltrim(SD2->D2_COD)})

                                If nPos > 0

                                  /* soma qtd do array + qtd da nf */
                                  nSoma := aRet[nPos][2] + SD2->D2_QUANT 
                                  ADel( aRet, nPos )   
                                  ASize( aRet, len(aRet)-1 )    
                                  aAdd( aRet, { Alltrim(SD2->D2_COD), nSoma, 0 , Alltrim(SD2->D2_DOC) , AllTrim(TEMP->F2_CHVNFE) , 0 , "" , AllTrim(Str(SF2->(RecNo()))) } ) //, SF2->(Recno())
                                  
                                Else
                                  aAdd( aRet, { Alltrim(SD2->D2_COD), SD2->D2_QUANT, 0 , Alltrim(SD2->D2_DOC), AllTrim(TEMP->F2_CHVNFE) , 0 , "" ,AllTrim(Str(SF2->(RecNo())))  } ) //, SF2->(Recno())     
                                EndIf        
                    
                        SD2->( dbSkip() )
                    EndDo
                    aSort(aRet, , , {|x, y| x[1] < y[1]})
                    VtABrowse( 3,0,10,20, aCab, aRet, aSize)

                EndIf    

            Else

                VTBeep( 3 )
                VTAlert( "VC_5. Nota Fiscal "+_cCodNF+" Inválida !", "Aviso", .T., 2500)    
                _lRet := .F.

            EndIf        

        Else

            VTBeep( 3 )
            VTAlert( "VC_6. Nota Fiscal "+_cCodNF+" não foi Localizada, verifique CNPJ !", "Aviso", .T., 2500)   
            VtRestore(,,,,aTela)
            _lRet := .F.

        Endif

    EndIf


_cNota := SPACE( 44 )

Return .F. 
