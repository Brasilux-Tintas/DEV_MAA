#Include "totvs.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ BRPCP065 º Autor ³ Nelieder Corneta   º Data ³  02/10/2023 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³ Relatório Codigo de Barras dos Pallets Por Pedido\NF       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function BRPCP065()
Local Letiq := 0
Local nLin
Local n,i
Local aPlt := {}
//Local PlArray := {}
Local aPallet  := {}
Local aNota   := {}
Local cNota   := ""
Local cPerg   := Padr("BRPCP065",10)
Local nPos


Private oPrint
Private oFont9     := TFont():New('Arial',,9,,.F.,,,,.F.,.F.)
Private oFont9n    := TFont():New('Arial',,9,,.T.,,,,.F.,.F.)

Private oFont10     := TFont():New('Arial',,10,,.F.,,,,.F.,.F.)
Private oFont10n    := TFont():New('Arial',,10,,.T.,,,,.F.,.F.)

Private oFont12     := TFont():New('Arial',,12,,.F.,,,,.F.,.F.)
Private oFont12n    := TFont():New('Arial',,12,,.T.,,,,.F.,.F.)

Private oFont15     := TFont():New('Arial',,15,,.F.,,,,.F.,.F.)
Private oFont15n    := TFont():New('Arial',,15,,.T.,,,,.F.,.F.)

Private oFont30     := TFont():New('Arial',,30,,.F.,,,,.F.,.F.)
Private oFont30n    := TFont():New('Arial',,30,,.T.,,,,.F.,.F.)

Pergunte(cPerg,.T.)

If !Empty(mv_par01)
     Aadd(aNota,mv_par01) 
EndIf

If !Empty(mv_par02)
     Aadd(aNota,mv_par02) 
EndIf

If !Empty(mv_par03)
     Aadd(aNota,mv_par03) 
EndIf

If !Empty(mv_par04)
     Aadd(aNota,mv_par04) 
EndIf

If !Empty(mv_par05)
     Aadd(aNota,mv_par05) 
EndIf


For i := 1 to len(aNota)

    DbSelectArea("SF2")

    iF len(aNota[i]) == 44
        DbSetorder(k) // pesquisa por numero da nota
    else
        DbSetorder(1) // pesquisa por chave
    EndIf    
    If DbSeek(xFilial("SF2")+Padr(aNota[i],TamSx3("F2_DOC")[1])+Padr('1',TamSx3("F2_SERIE")[1]), .f.)

        DbSelectArea("SC5")
        DbSetorder(1)
        If DbSeek(xFilial("SC5")+SF2->F2_PEDIDO, .f.)

            cMemo := MSMM(SC5->C5_OBSSC5)
            cMemo := StrTran( cMemo, CHR(13)+CHR(10), " " )
            aPallet := STRTOKARR(cMemo," ")

            for n := 1 To Len(aPallet)

                nPos := 0
                if (SUBSTR(aPallet[n],7,1) == "/") .And. Len(aPallet[n]) == 11
                    
                    if len(aPlt) > 0
                        nPos := aScan(aPlt, {|x| x == replace(aPallet[n],"/","")})
                    endif

                    If nPos == 0
                        Aadd(aPlt,replace(aPallet[n],"/","") ) 
                    EndIf    
                EndIf    

            Next

        endif    

    EndIf    

Next

oPrint := TMSPrinter():New(OemToAnsi('Codigo Barras Pallet'))
oPrint:SetPortrait()
nLin  := 0050


oPrint:StartPage()  

For i := 1 to len(aNota)
    cNota := cNota + aNota[i] + ' '
Next 

oPrint:Say(nLin,0800,OemToAnsi("Nota Fiscal : "+cNota),oFont15n,,,,0)

nLin += 050

nLin += 050


for n := 1 To Len(aPlt)

    MSBAR3( 'CODE128', 2+Letiq , 1, aPlt[n], oPrint, .T.,10, .T., 0.040,1.4, .T.,,, .F. )
    n++

    If n <= Len(aPlt)  
        MSBAR3( 'CODE128', 2+Letiq , 16, aPlt[n], oPrint, .T.,10, .T., 0.040,1.4, .T.,,, .F. )
    EndIf        
    
    Letiq += 3.5

    if Letiq >= 24
        oPrint:EndPage()
        nLin  := 0050
        Letiq := 0
    endif  

Next


oPrint:EndPage()
oPrint:Preview()
oPrint:end()


return
