#include 'totvs.ch'

/*/{Protheus.doc} ZESTF02
Data de Fechamento e bloqueio de estoque.
@type function
@version  v2021.01
@author Luís Gustavo de Souza
@since 21/10/2021
/*/
User Function ZESTF02()
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de cVariable dos componentes                                 ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     Private cSay1Fec   := Space(1)
     Private cSay2Fec   := Space(1)
     Private dGet1Fec   := GETMV( "MV_ULMES"   )
     Private dGet2Fec   := GETMV( "MV_DBLQMOV" )
     u_zcfga01( 'ZESTF02' )
     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Declaração de Variaveis Private dos Objetos                             ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     SetPrvt( "oFont1", "oDlg1Fec", "oSay2Fec", "oSay1Fec", "oGet1Fec", "oGet2Fec", "oSBtn1Fe", "oSBtn2Fe" )

     /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
     ±± Definicao do Dialog e todos os seus componentes.                        ±±
     Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
     oFont1     := TFont():New( "Arial", 0, -21, , .F., 0, , 400, .F., .F., , , , , , )
     oDlg1Fec   := MSDialog():New( 000, 000, 125, 350, "Datas do fechamento", , , .F., , , , , , .T., , , .T. )
     oSay2Fec   := TSay():New( 025, 004, { || "Blq. Movimentação:" }, oDlg1Fec, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 096, 012 )
     oSay1Fec   := TSay():New( 004, 004, { || "Ult. Fechamento:"   }, oDlg1Fec, , oFont1, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 096, 012 )
     oGet1Fec   := TGet():New( 004, 104, { |u| If( PCount() > 0, dGet1Fec := u, dGet1Fec ) }, oDlg1Fec, 064, 014, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .T., .F., "", "dGet1Fec", , )
     oGet2Fec   := TGet():New( 024, 104, { |u| If( PCount() > 0, dGet2Fec := u, dGet2Fec ) }, oDlg1Fec, 064, 014, '', , CLR_BLACK, CLR_WHITE, oFont1, , , .T., "", , , .F., .F., , .F., .F., "", "dGet2Fec", , )
     oSBtn1Fe   := SButton():New( 046, 104, 1, { || PUTMV( "MV_DBLQMOV", dGet2Fec ), oDlg1Fec:End() }, oDlg1Fec, , "", )
     oSBtn2Fe   := SButton():New( 046, 141, 2, { || oDlg1Fec:End()                                  }, oDlg1Fec, , "", )

     oDlg1Fec:Activate(,,,.T.)
Return
