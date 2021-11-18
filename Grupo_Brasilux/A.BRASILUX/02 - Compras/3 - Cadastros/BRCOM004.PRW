#INCLUDE "rwmake.CH"
//#INCLUDE "FIVEWIN.CH"
#INCLUDE "VKEY.CH"
//#INCLUDE "BRCOM004.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }
/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?BRCOM004 ?Lu? Gustavo de Souza         ?Data ?5.08.2003 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?         ?otina de atualizacao manual das requisi寤es de compras.     낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina permite as operacoes de pesquisa, visualizacao,  낢?
굇?         ?nclusao, alteracao e exclusao das requisi寤es de compras.   낢?
굇?         ?inda permite a impress? das requisi寤es e a libera豫o para 낢?
굇?         ?olicita豫o de compra.                                       낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function BRCOM004()

     //Local bBlock
     //Local nPos      := 0
     //Local nX        := 0
     //Local nRegSZU   := 0
     //Local lContinua := .T.
     Local aCores    := { { 'ZU_OK=="LB"', 'ENABLE'    },; //Liberada para Compras
                          { 'ZU_OK=="RC"', 'DISABLE'   },; //Cancelada
                          { 'ZU_OK=="AP"', 'BR_AZUL'   },; //Aguardando Aprova豫o
                          { 'ZU_OK=="EC"', 'BR_PRETO'  } } //Cancelado por compras

     PRIVATE aRotina := { {"Pesquisar" ,'axPesqui'                   , 0 , 1   },;
                          {"Visualizar",'U_fCOM0041("SZU",Recno(),2)', 0 , 2   },;
                          {"Incluir"   ,'U_fCOM0042("SZU",Recno(),3)', 0 , 3   },;
                          {"Alterar"   ,'U_fCOM0043("SZU",Recno(),4)', 0 , 4, 4},;
                          {"Libera豫o" ,'U_fCOM0047("SZU",Recno(),4)', 0 , 4, 4},;
                          {"Imprimir"  ,'U_fCOM0044()', 0 , 4, 4},;
                          {"Excluir"   ,'U_fCOM0045("SZU",Recno(),2)', 0 , 5, 5},;
                          {"Legenda"   ,'U_fCOM0046()', 0 , 5, 0} }

     PRIVATE cCadastro  := OemtoAnsi("Requisi豫o de Compras")
     PRIVATE lSelecao
     u_zcfga01( 'BRCOM004' ) //LGS#2021118 - Grava豫o de log de utiliza豫o da rotina
     pergunte("COM004",.f.)
     lSelecao := IIF(mv_par01==1,.T.,.F.)

     bFuncao := {|| fCOM0044() }
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     
     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?Verifica a permissao do programa em relacao aos modulos      ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     If ( AMIIn(02,12,19,97,98) )
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?Endereca a funcao de BROWSE                                  ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        dbSelectArea("SZU")
        dbSetOrder(1)
        MsSeek(xFilial("SZU"))	
        mBrowse( 6, 1,22,75,"SZU",,,,,,aCores)
     EndIf
     //Set Key VK_F12 To
     SetKey( VK_F12, { || } )
Return

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fCOM0041 ?ev. 01?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo visualizar as requisi寤es  de  낢?
굇?         ?ompra utilizando-se uma modelo 2                            낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?ExpZU = Alias do arquivo                                    낢?
굇?         ?ExpN2 = Numero do registro                                  낢?
굇?         ?ExpN3 = Numero da opcao selecionada                         낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fCOM0041(cAlias,nReg,nOpcx)
     Local aArea        := GetArea()
     Local aSizeAut     := MsAdvSize(,.F.)
     Local oDlg
     Local oGet
     Local dA110Data    := SZU->ZU_EMISSAO
     Local cSolic       := SZU->ZU_SOLICIT
     Local cDigit       := SZU->ZU_DIGITAD
     //Local cNomCompr    := ""
     Local aObjects     := {}
     Local aInfo        := {}
     Local aPosGet      := {}
     Local aPosObj      := {}
     Local aBut110      := {}
     Local lNaturez     := SZU->(FieldPos("ZU_NATUREZ")) > 0
     Local nBack        := NIL   

     PRIVATE cCodNatu	:= iiF(lNaturez,SZU->ZU_NATUREZ,"")
     PRIVATE cCCusto 	:= SZU->ZU_CC
     PRIVATE cA110Num	:= SZU->ZU_NUM
     PRIVATE aHeader	:= {}
     PRIVATE aCols 		:= {}
     PRIVATE aRatAFG	:= {}
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?Caso exista, guarda o valor de N                             ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     If TYPE( "N" ) == "N" 
        nBack := N
     EndIf 	
     
     fger0049( nOpcx )
     
     N := 1 

     AAdd( aObjects, { 0,    20, .T., .F. } )
     AAdd( aObjects, { 100, 100, .T., .T. } )
     AAdd( aObjects, { 0,    3, .T., .F. } )	
     aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
     aPosObj := MsObjSize( aInfo, aObjects ) 
     aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,35,100,135,205,255}})
     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Requisi豫o de Compras") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

            @ 40,aPosGet[1,1]-10 SAY OemToAnsi("Numero") PIXEL SIZE 020,009
            @ 39,aPosGet[1,2]-20 MSGET cA110Num 	Picture PesqPict("SZU","ZU_NUM") When .F. PIXEL SIZE 020,10
            
            @ 40,aPosGet[1,3]-50 SAY OemToAnsi("Digitador")  Of oDlg PIXEL
            @ 39,aPosGet[1,4]-90 MSGET cDigit       Picture PesqPict("SZU","ZU_DIGITAD") When .F. PIXEL SIZE 55,10

            @ 40,aPosGet[1,3]+50 SAY OemToAnsi("Requisitante") PIXEL SIZE 31,9 COLOR CLR_HBLUE
            @ 39,aPosGet[1,4]+20 MSGET cSolic 	Picture PesqPict("SZU","ZU_SOLICIT")	When .F.  PIXEL SIZE 55,10

            @ 40,aPosGet[1,5]+20 SAY OemToAnsi("Data de Emiss?")	PIXEL SIZE 41,9
            @ 39,aPosGet[1,6]    MSGET dA110Data Picture PesqPict("SZU","ZU_EMISSAO")	When .F. PIXEL SIZE 45,10 

            oGet := MSGetDados():New( aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "U_fger0045()", "U_fger0046()", "+ZU_ITEM", .F.,,,,300)
     
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},, aBut110)
     If ValType( nBack ) == "N" 
        N := nBack 
     EndIf 	
     RestArea(aArea)
Return

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fCOM0042 ?ev. 01?Lu? Gustavo de souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo possibilitar a inclusao manual 낢?
굇?         ?as requisi寤es de compras utilizando-se de uma modelo 2     낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?ExpZU = Alias do arquivo                                    낢?
굇?         ?ExpN2 = Numero do registro                                  낢?
굇?         ?ExpN3 = Numero da opcao selecionada                         낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fCOM0042(cAlias,nReg,nOpcx)
     Local nSavOrd      := IndexOrd()
     Local nOpcA        := 0
     Local oDlg
     Local oGet
     //Local oReq
     //Local oComp
     Local aSizeAut     := {}
     Local lRet         := .t.
     Local dA110Data    := dDataBase
     Local cSolic       := CriaVar("ZU_SOLICIT")
     Local cDigit       := CriaVar("ZU_DIGITAD")
     //Local cNomCompr    := ""
     Local aObjects     := {}
     Local aInfo        := {}
     Local aPosGet      := {}
     Local aPosObj      := {}
     Local aBut110      := {}
     Local cId          := ""
     Local _cContador   := ""

     cAlias := Alias()
     lRet := fGerSo( cUsername, @cId, 1 )
     If !lRet
        Return
     Endif
     DbSelectArea(cAlias)
     
     PRIVATE lNaturez   := SZU->(FieldPos("ZU_NATUREZ")) > 0
     PRIVATE cCodNatu   := IIf(lNaturez, CriaVar("ZU_NATUREZ") , "")
     PRIVATE cCCusto    := CriaVar("ZU_CC")
     PRIVATE cA110Num   := CriaVar("ZU_NUM")
     PRIVATE aHeader    := {}
     PRIVATE aCols      := {}
     PRIVATE aRatAFG    := {}
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?fetua a montagem do aHeader e do aCols                       ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     fger0049( nOpcx )

     If SZU->(FieldPos( "ZU_ITEM" )) > 0
        _cContador := "+" + "ZU_ITEM"
     Endif

     aSizeAut := MsAdvSize(,.F.)
     AAdd( aObjects, { 0  ,  20, .T., .F. } )		
     AAdd( aObjects, { 100, 100, .T., .T. } )
     AAdd( aObjects, { 0  ,   3, .T., .F. } )
     aInfo    := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
     aPosObj  := MsObjSize( aInfo, aObjects ) 
     aPosGet  := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,35,100,135,205,255},{10,45,105,145,215,265}})

     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Requisi豫o de Compras") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
            @ 40,aPosGet[1,1]-10 SAY OemToAnsi("Numero") Of oDlg PIXEL
            @ 39,aPosGet[1,2]-20 MSGET cA110Num F3 CpoRetF3("ZU_NUM")    Picture PesqPict("SZU","ZU_NUM");
            When VisualSX3("ZU_NUM",.F.) Valid CheckSX3("ZU_NUM",cA110Num) Of oDlg PIXEL
            
            @ 40,aPosGet[1,3]-50 SAY OemToAnsi("Digitador")  Of oDlg PIXEL
            @ 39,aPosGet[1,4]-90 MSGET cDigit   F3 CpoRetF3("ZU_DIGITAD") Picture PesqPict("SZU","ZU_DIGITAD");
            When VisualSX3("ZU_DIGITAD",.F.) Valid CheckSX3("ZU_DIGITAD",cDigit) SIZE 55,10 Of oDlg PIXEL
            
            @ 40,aPosGet[1,3]+50 SAY OemToAnsi("Requisitante") Of oDlg PIXEL COLOR CLR_HBLUE
            @ 39,aPosGet[1,4]+20 MSGET cSolic   F3 CpoRetF3("ZU_SOLICIT") Picture PesqPict("SZU","ZU_SOLICIT");
            When VisualSX3("ZU_SOLICIT",.T.) Valid CheckSX3("ZU_SOLICIT",cSolic).AND.NaoVazio(cSolic) SIZE 55,10 Of oDlg PIXEL
            
            @ 40,aPosGet[1,5]+20 SAY OemToAnsi("Data de Emissao") Of oDlg PIXEL
            @ 39,aPosGet[1,6]    MSGET dA110Data F3 CpoRetF3("ZU_EMISSAO") Picture PesqPict("SZU","ZU_EMISSAO");
            When VisualSX3("ZU_EMISSAO",.T.) Valid CheckSX3("ZU_EMISSAO",dA110Data) SIZE 40,10 Of oDlg PIXEL

            oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "U_fger0045()", "U_fger0046()", _cContador, .T.,,3,,300)

     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,IIf(oGet:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()},, aBut110)
     If ( nOpcA == 1 )
        If ( nOpcA == 1 )
           Begin Transaction
                 If ( !U_fger0047(1,cA110Num,cSolic,dA110Data,cCCusto,"","",cDigit,cId) )
                    nOpcA := 0
                    Help(" ",1,"A110NAOREG")
                 Else
                    EvalTrigger()
                    If ( __lSX8 )
                       ConfirmSX8()
                    Endif
                 EndIf
           End Transaction
        EndIf
     EndIf
     If ( nOpcA == 0 )
        If ( __lSX8 )
           RollBackSX8()
        EndIf
     EndIf
     MsUnLockAll()
     dbSelectArea(cAlias)
     dbSetOrder(nSavOrd)
Return ( nOpcA )

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fCOM0043 ?ev. 01?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo possibilitar a alteracao manual낢?
굇?         ?as requisi寤es de compras utilizando-se de uma modelo 2     낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?ExpZU = Alias do arquivo                                    낢?
굇?         ?ExpN2 = Numero do registro                                  낢?
굇?         ?ExpN3 = Numero da opcao selecionada                         낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fCOM0043(cAlias,nReg,nOpcx)
     Local aArea       := GetArea()
     //Local lPedido     := .T.
     //Local lCotacao    := .T.
     //Local lGravaOk    := .T.
     //Local lTransmissao:= .F.
     //Local cHelp       := ""
     Local aSizeAut    := {}
     Local nOpcA       := 0
     Local aObjects    := {}
     Local aInfo       := {}
     Local aPosGet     := {}
     Local aPosObj     := {}
     Local oDlg
     Local oGet
     //Local oReq
     //Local oComp
     Local cSolic      := SZU->ZU_SOLICIT
     Local cDigit      := SZU->ZU_DIGITAD
     Local dA110Data   := SZU->ZU_EMISSAO
     //Local cNomCompr   := ""
     Local aBut110     := {}
     Private lNaturez  := SZU->(FieldPos("ZU_NATUREZ")) > 0
     PRIVATE cCodNatu  := iiF(lNaturez,SZU->ZU_NATUREZ,"")
     PRIVATE cCCusto   := SZU->ZU_CC
     PRIVATE cA110Num  := SZU->ZU_NUM
     PRIVATE aHeader   := {}
     PRIVATE aCols     := {}
     PRIVATE aRatAFG   := {}
     
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     If !Upper(Alltrim(cUsername)) == Upper(Alltrim(SZU->ZU_DIGITAD))
        MsgBox("Usu?io n? autorizado !!!","Aten豫o","STOP")
        Return
     Else
        If !SZU->ZU_OK $ "AP"
           MsgBox("Essa requisi豫o j?foi liberada/rejeitada !!!","Aten豫o","INFO")
           Return
        Endif
     Endif
     
     cAlias := Alias()
     lRet := fGerSo( SZU->ZU_DIGITAD, , 1 )
     If !lRet
        Return
     Endif
     DbSelectArea(cAlias)

     aSizeAut          := MsAdvSize(,.F.)

     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?fetua a montagem do aHeader e do aCols                       ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     fger0049( nOpcx )

     AAdd( aObjects, { 0  ,  20, .T., .F. } )		
     AAdd( aObjects, { 100, 100, .T., .T. } )
     AAdd( aObjects, { 0  ,   3, .T., .F. } )	
     aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
     aPosObj := MsObjSize( aInfo, aObjects ) 
     aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,35,100,135,205,255},{10,45,105,145,215,265}})

     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Requisi豫o de Compras") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
            @ 40,aPosGet[1,1]-10	SAY OemToAnsi("Numero") 	of oDlg PIXEL
            @ 39,aPosGet[1,2]-20	MSGET cA110Num  Picture PesqPict("SZU","ZU_NUM")  When .F. 	of oDlg PIXEL

            @ 40,aPosGet[1,3]-50 SAY OemToAnsi("Digitador")  Of oDlg PIXEL
            @ 39,aPosGet[1,4]-90 MSGET cDigit   F3 CpoRetF3("ZU_DIGITAD") Picture PesqPict("SZU","ZU_DIGITAD");
            When VisualSX3("ZU_DIGITAD",.F.) Valid CheckSX3("ZU_DIGITAD",cDigit) SIZE 55,10 Of oDlg PIXEL

            @ 40,aPosGet[1,3]+50	SAY OemToAnsi("Requisitante")  of oDlg PIXEL COLOR CLR_HBLUE
            @ 39,aPosGet[1,4]+20	MSGET cSolic     F3 CpoRetF3("ZU_SOLICIT") Picture PesqPict("SZU","ZU_SOLICIT");
            When VisualSX3("ZU_SOLICIT") Valid CheckSX3("ZU_SOLICIT",cSolic) SIZE 55,10 	of oDlg PIXEL

            @ 40,aPosGet[1,5]+20 SAY OemToAnsi("Data de Emissao") 	of oDlg PIXEL
            @ 39,aPosGet[1,6]    MSGET dA110Data 	F3 CpoRetF3("ZU_EMISSAO") Picture PesqPict("SZU","ZU_EMISSAO");
            When VisualSX3("ZU_EMISSAO") Valid CheckSX3("ZU_EMISSAO",dA110Data) SIZE 40,10 	of oDlg PIXEL

            oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_fger0045()","U_fger0046()","+ZU_ITEM",.T.,,,,300,"U_fger004C()",,,"U_fger004D()",oDlg)
 
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGet:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()},, aBut110)
     If nOpcA == 1
        Begin Transaction
              If !U_fger0047(2,cA110Num,cSolic,dA110Data,cCCusto,"","",cDigit)
                 Help(" ",1,"A110NAOREG")
              Else
                 EvalTrigger()
              EndIf
        End Transaction
     Endif
  
     MsUnLockAll()
     RestArea(aArea)
Return(nOpcA)

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fCOM0045 ?ev. 01?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo possibilitar a exclusao manual 낢?
굇?         ?as requisi寤es de compras utilizando-se de uma modelo 2     낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?ExpZU = Alias do arquivo                                    낢?
굇?         ?ExpN2 = Numero do registro                                  낢?
굇?         ?ExpN3 = Numero da opcao selecionada                         낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fCOM0045(cAlias,nReg,nOpcx)
     Local aArea       := GetArea()
     Local aBut110     := {}
     Local aSizeAut    := {}
     Local aObjects    := {}
     Local aInfo       := {}
     Local aPosGet     := {}
     Local aPosObj     := {}
     //Local cHelp       := ""
     Local nOpcA       := 0
     Local oDlg
     Local oGet
     //Local oReq
     //Local oComp
     Local cSolic      := SZU->ZU_SOLICIT
     Local cDigit      := SZU->ZU_DIGITAD
     Local dA110Data   := SZU->ZU_EMISSAO
     //Local cNomCompr   := ""
     Local lNaturez    := SZU->(FieldPos("ZU_NATUREZ")) > 0
     PRIVATE cCodNatu  := iiF(lNaturez,SZU->ZU_NATUREZ,"")
     PRIVATE cCCusto   := SZU->ZU_CC
     PRIVATE cA110Num  := SZU->ZU_NUM
     PRIVATE aHeader   := {}
     PRIVATE aCols     := {}
     PRIVATE aRatAFG   := {}
     
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     If !Upper(Alltrim(cUsername)) == Upper(Alltrim(SZU->ZU_DIGITAD))
        MsgBox("Usu?io n? autorizado !!!","Aten豫o","STOP")
        Return
     Else
        If !SZU->ZU_OK $ "AP"
           MsgBox("Essa requisi豫o j?foi liberada/rejeitada !!!","Aten豫o","INFO")
           Return
        Endif
     Endif
     
     cAlias := Alias()
     lRet := fGerSo( SZU->ZU_DIGITAD, , 1 )
     If !lRet
        Return
     Endif
     DbSelectArea(cAlias)

     aSizeAut          := MsAdvSize(,.F.)

     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?fetua a montagem do aHeader e do aCols                       ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     fger0049(4)
     AAdd( aObjects, { 0  ,  20, .T., .F. } )		
     AAdd( aObjects, { 100, 100, .T., .T. } )
     AAdd( aObjects, { 0  ,   3, .T., .F. } )	
     aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
     aPosObj := MsObjSize( aInfo, aObjects ) 
     aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,35,100,135,205,255},{10,45,105,145,215,265}})
     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Requisi豫o de Compras") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
            @ 40,aPosGet[1,1]-10 SAY OemToAnsi("N?ero") of oDlg PIXEL
            @ 39,aPosGet[1,2]-20 MSGET cA110Num 	Picture PesqPict("SZU","ZU_NUM")			When .F. of oDlg PIXEL

            @ 40,aPosGet[1,3]-50 SAY OemToAnsi("Digitador")  Of oDlg PIXEL
            @ 39,aPosGet[1,4]-90 MSGET cDigit       Picture PesqPict("SZU","ZU_DIGITAD") When .F. PIXEL SIZE 55,10

            @ 40,aPosGet[1,3]+50 SAY OemToAnsi("Requisitante") of oDlg PIXEL
            @ 39,aPosGet[1,4]+20 MSGET cSolic 		Picture PesqPict("SZU","ZU_SOLICIT")	When .F. SIZE 55,10 of oDlg PIXEL

            @ 40,aPosGet[1,5]+20 SAY OemToAnsi("Data de Emiss꼘") of oDlg PIXEL
            @ 39,aPosGet[1,6]    MSGET dA110Data  	Picture PesqPict("SZU","ZU_EMISSAO")	When .F. SIZE 40,10 of oDlg PIXEL

            oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_fger0045()","U_fger0046()","ZU_ITEM",.F.,,,,300)

     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopcA:=1,oDlg:End()},{||oDlg:End()},, aBut110)
     If ( nOpcA == 1 )
        Begin Transaction
              U_fger0047(3,ca110Num,cSolic,dA110Data,cCCusto,"","",cDigit)
              EvalTrigger()
        End Transaction
     EndIf
     RestArea(aArea)
Return(.T.)

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fGER0041 ?Autor ?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo nao permitir a duplicacao do   낢?
굇?         ?umero da requisi豫o de compras.                             낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpZU: Numero da requisi豫o de compras.                      낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fGER0041(cNumSC)
     Local aArea := GetArea()
     Local lRet  := .T.
     
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     cNumSC      := Iif(Valtype(cNumSC)== "N",Strzero(cNumSC,6),cNumSC)
     If Empty(cNumSC)
        Help(" ",1,"VAZIO")
        lRet := .F.
     Else
        dbSelectArea("SZU")
        dbSetOrder(1)
        If MsSeek( xFilial("SZU")+cNumSC)
           Help(" ",1,"A11001")
           lRet := .F.
        EndIf
     EndIf
     RestArea(aArea)
Return lRet

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fGER0042 ?Autor ?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo nao permitir a duplicacao do   낢?
굇?         ?umero da requisi豫o de compras.                             낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpZU: Codigo do produto                                     낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fGER0042(cProduto)
     Local aArea		:= GetArea()
     Local nX        := 0
     Local nPLoja	:= 0
     Local cDescri	:= ""
     Local lRetorno  := .T.
     
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     cProduto := &(ReadVar())

     dbSelectArea("SB1")
     dbSetOrder(1)
     MsSeek(xFilial("SB1")+cProduto)
     cDescri := SB1->B1_DESC
     Do Case
        Case !SB1->(Found())
             lRetorno := .F.
             Help(" ",1,"ZU_PRODUTO")
        Case SB1->B1_CONTRAT == "S"
             lRetorno := .F.
             Help(" ",1,"A110CONTR")
        Case !U_fger0048("P")
             lRetorno := .F.
        Case SB1->B1_SOLICIT =="S" .And. GetMv("MV_RESTSOL")=="S" .And. !A110Restr(cProduto,UsrRetGrp(),RetCodUsr())
             lRetorno := .F.
     EndCase
     If ( lRetorno )
        If ( Alltrim(mv_par01) == "B5_CEME" )
           dbSelectArea("SB5")
           dbSetOrder(1)
           If MsSeek(xFilial("SB1") + cProduto )
              cDescri := SB5->B5_CEME
           EndIf
        EndIf
        cDescri := PadR(cDescri,Len(SZU->ZU_DESCRI))
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?tualiza os campos vinculados ao produto                      ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        For nX := 1 To Len(aHeader)
            Do Case
               Case Trim(aHeader[nX][2]) == "ZU_FORNECE"
                    If ( SB1->B1_MONO=="S" )
                       nPLoja := aScan(aHeader,{|x| Trim(x[2])=="ZU_LOJA"})
                       If ( nPLoja > 0 )
                          dbSelectArea("SA2")
                          dbSetOrder(1)								
                          If ( MsSeek(xFilial("SA2")+SB1->B1_PROC) )
                             aCols[n][nX] 		:= SB1->B1_PROC
                             aCols[n][nPLoja]	:=SA2->A2_LOJA					
                          EndIf
                       EndIf
                    EndIf
               Case Trim(aHeader[nX][2]) == "ZU_UM"			// Unidade Medida
                    aCols[n][nX] := SB1->B1_UM
               Case Trim(aHeader[nX][2]) == "ZU_SEGUM"		// Segunda Unidade Medida
                    aCols[n][nX] := SB1->B1_SEGUM
                    a100SegUm()			
               Case Trim(aHeader[nX][2]) == "ZU_LOCAL"		// Almoxarifado
                    aCols[n][nX] := SB1->B1_LOCPAD
               Case Trim(aHeader[nX][2]) == "ZU_CC"			// Centro Custo
                    aCols[n][nX] := SB1->B1_CC
               Case Trim(aHeader[nX][2]) == "ZU_CONTA"		// Conta Contabil
                    aCols[n][nX] := SB1->B1_CONTA
               Case Trim(aHeader[nX][2]) == "ZU_DESCRI"		// Descricao
                    aCols[n][nX] := cDescri
               Case Trim(aHeader[nX][2]) == "ZU_IMPORT"		// Produto Importado
                    aCols[n][nX] := SB1->B1_IMPORT
            EndCase
        Next nX
     EndIf
     RestArea(aArea)
Return (lRetorno)
/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fGER0043 ?Autor ?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo efetuar a validacao do codigo  낢?
굇?         ? loja do fornecedor canal                                   낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?enhum                                                       낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
/*/
User Function fGER0043()
     Local aArea    := GetArea()
     Local nPLoja   := aScan(aHeader,{|x| Trim(x[2])=="ZU_LOJA"})
     Local nPProd   := aScan(aHeader,{|x| Trim(x[2])=="ZU_PRODUTO"})
     Local lRetorno := .T.
     
     //Set Key VK_F12 To fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     If ( !Empty(M->ZU_FORNECE) )
        If ( xFilial("SA2")==SA2->A2_FILIAL .And. SA2->A2_COD==M->ZU_FORNECE )
           aCols[n][nPLoja] := SA2->A2_LOJA
        Else
           dbSelectArea("SA2")
           dbSetOrder(1)
           MsSeek(xFilial("SA2")+M->ZU_FORNECE)
           aCols[n][nPLoja] := SA2->A2_LOJA
        EndIf
     EndIf
     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?az a Consistencia entre do Fornecedor Canal do Produto               ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     dbSelectArea("SB1")
     dbSetOrder(1)
     If ( MsSeek(xFilial("SB1")+aCols[n][nPProd]) )
        If ( SB1->B1_MONO=="S" .And. SB1->B1_PROC != M->ZU_FORNECE)
           Help(" ",1,"A110CANAL")
           lRetorno := .F.
        Endif
     EndIf
     RestArea(aArea)
Return(lRetorno)

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fGER0044 ?Autor ?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo efetuar a validacao do codigo  낢?
굇?         ? loja do fornecedor canal                                   낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?enhum                                                       낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
/*/
User Function fGER0044()
     Local nPFornece := aScan(aHeader,{|x| Trim(x[2])=="ZU_FORNECE"})
     Local nPLoja    := aScan(aHeader,{|x| Trim(x[2])=="ZU_LOJA"})
Return(ExistCpo("SA2",aCols[n][nPFornece]+aCols[n][nPLoja]))

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?110LinOk ?Autor ?Eduardo Riera         ?Data ?8.07.2000 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo efetuar a validacao de uma     낢?
굇?         ?inha da getdados para a rotina de atualizacao da requisi豫o 낢?
굇?         ?e compra                                                    낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpO1: Objeto da GetDados                                    낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?etorno   ?xpL1: .T. -> Linha valida                                   낢?
굇?         ?      .F. -> Linha invalida                                 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
/*/
User Function fger0045(o)
     Local aArea    := GetArea()
     //Local cItem    := ""
     Local lRet     := .T.
     Local lDeleted := .F.
     Local nPProd   := aScan(aHeader,{|x| Trim(x[2])=="ZU_PRODUTO"})
     Local nPQuant  := aScan(aHeader,{|x| Trim(x[2])=="ZU_QUANT"})
     Local nPItem   := aScan(aHeader,{|x| Trim(x[2])=="ZU_ITEM"})

     If ValType(aCols[n,Len(aCols[n])]) == "L"
        lDeleted := aCols[n,Len(aCols[n])]      // Verifica se esta Deletado
     EndIf
     If ( !lDeleted )
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?erifica se a Linha esta preenchida                                   ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        If ( Empty(aCols[n][nPProd]) .Or. Empty(aCols[n][nPQuant]) )
           Help(" ",1,"A11002")
           lRet := .F.
        EndIf
     Else
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?erifica se a linha pode ser deletada                                 ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        If ( !INCLUI )
           dbSelectArea("SZU")
           dbSetOrder(1)
           If ( MsSeek(xFilial("SZU")+cA110Num+aCols[n][nPItem]) )
              lRet := MaCanDelSC("SZU")
           EndIf
        EndIf
     EndIf
     RestArea(aArea)
Return(lRet)
/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?110TudOk ?Autor ?Eduardo Riera         ?Data ?8.07.2000 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo efetuar a validacao da solici- 낢?
굇?         ?acao de compras para a rotina de atualizacao da solicitacao 낢?
굇?         ?e compra.                                                   낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpO1: Objeto da GetDados                                    낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?etorno   ?xpL1: .T. -> GetDados valida                                낢?
굇?         ?      .F. -> Getdados invalida                              낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fger0046(o)
     Local aArea    := GetArea()
     Local nPItem   := aScan(aHeader,{|x| Trim(x[2])=="ZU_ITEM"})
     Local nX       := 0
     Local lDeleted := .F.
     Local lRetorno := .T.

     If ( !INCLUI )
        For nX := 1 To Len(aCols)
            If ValType(aCols[nX,Len(aCols[nX])]) == "L"
               lDeleted := aCols[nX,Len(aCols[nX])]
            EndIf
            If ( lDeleted )
               dbSelectArea("SZU")
               dbSetOrder(1)
               If ( MsSeek(xFilial("SZU")+cA110Num+aCols[n][nPItem]) )
                  lRetorno := MaCanDelSC("SZU")
               EndIf
               If ( !lRetorno )
                  Exit
               EndIf
            EndIf
        Next nX
     EndIf
     RestArea(aArea)
Return(lRetorno)

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fGER0047 ?ev. 01?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo efetuar a validacao da solici- 낢?
굇?         ?acao de compras para a rotina de atualizacao da solicitacao 낢?
굇?         ?e compra.                                                   낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?etorno   ?xpO1: Objeto da GetDados                                    낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpN1: nOpcao sendo:                                         낢?
굇?         ?      [1] Inclusao                                          낢?
굇?         ?      [2] Alteracao                                         낢?
굇?         ?      [3] Exclusao                                          낢?
굇?         ?xpC2: Numero da Solicitacao                                 낢?
굇?         ?xpC3: Codigo do Solicitante                                 낢?
굇?         ?xpD4: Data de Emissao                                       낢?
굇?         ?xpC5: Centro de Custo                                       낢?
굇?         ?xpC6: Unidade Requisitante                                  낢?
굇?         ?xpC7: Codigo do Comprador                                   낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fger0047(nOpcao,ca110Num,cSolic,dA110Data,cCCusto,cUnidreq,cCodCompr,cDigit,cId, aGrava)
     Local aArea     := GetArea()
     Local aStru     := SZU->(dbStruct())
     Local aRegistro := {}
     Local lQuery    := .F.
     Local lDeleted  := .F.
     Local cQuery    := ""
     Local cMayCode  := ""
     Local cOldNum   := cA110Num
     Local cAliasSZU := "SZU"
     Local nX        := 0
     Local nY        := 0
     Local _ni       := 0
     Local lGrvDad   := .t.
     If ( nOpcao == 1 )
        lGrvDad   := .t.
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?onsistir o numero da requisi豫o de compra                            ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        If ( Empty(cA110Num) )
           cA110Num := NextNumero(cAlias,1,"ZU_NUM",.F.,cA110Num)	
        EndIf
        If ( INCLUI )
           cMayCode := "SZU"+xFilial("SZU")+cA110Num
           dbSelectArea("SZU")
           dbSetOrder(1)
           While ( MsSeek(xFilial("SZU")+cA110Num) .Or. !MayIUseCode(cMayCode) )
                 cA110Num := Soma1(cA110Num,Len(cA110Num))
                 cMayCode := "SZU"+xFilial("SZU")+cA110Num
           EndDo
        EndIf
        If ( cA110Num != cOldNum )
           HELP(" ",1,"NUMSEQ",,cOldNum,4,15)
        EndIf
     ElseIf ( nOpcao == 4 )
            lGrvDad   := .f.
            For _ni := 1 TO Len(aGrava)
                aSol      := {}
                aItensSol := {}
            
                cNumero   := aGrava[_ni]
            
                //aAdd(aSol,{"C1_NUM"    ,cNumero ,Nil})
                DbSelectArea("SZU")
                DbSetOrder(1)
                DbSeek(xFilial("SZU")+cNumero,.t.)
                If Found()
                   cSolicit  := SZU->ZU_SOLICIT
                   dEmissao  := Dtos(SZU->ZU_EMISSAO)
                Else
                   cSolicit  := cUsername
                   dEmissao  := Dtos(dDataBase)
                Endif
                aAdd(aSol,{"C1_SOLICIT",cSolicit,Nil})
                aAdd(aSol,{"C1_EMISSAO",dEmissao,Nil})
            
                DbSelectArea("SZU")
                DbSetOrder(1)
                DbSeek(xFilial("SZU")+cNumero,.t.)
                If Found()
                   While !Eof() .and. SZU->ZU_NUM == cNumero
                         aSolIt := {}
                         aadd(aSolIt,{"C1_ITEM"   , SZU->ZU_ITEM             , Nil })
                         aadd(aSolIt,{"C1_PRODUTO", SZU->ZU_PRODUTO          , Nil })
                         aadd(aSolIt,{"C1_UM"     , SZU->ZU_UM               , Nil })
                         aadd(aSolIt,{"C1_QUANT"  , SZU->ZU_QUANT            , Nil })
                         aadd(aSolIt,{"C1_DATPRF" , SZU->ZU_DATPRF           , Nil })
                         aadd(aSolIt,{"C1_LOCAL"  , SZU->ZU_LOCAL            , Nil })
                         aadd(aSolIt,{"C1_CC"     , SZU->ZU_CC               , Nil })
                         aadd(aSolIt,{"C1_CONTA"  , SZU->ZU_CONTA            , Nil })
                         aadd(aSolIt,{"C1_ITEMCTA", SZU->ZU_ITEMCTA          , Nil })
                         aadd(aSolIt,{"C1_FORNECE", SZU->ZU_FORNECE          , Nil })
                         aadd(aSolIt,{"C1_LOJA"   , SZU->ZU_LOJA             , Nil })
                         aadd(aSolIt,{"C1_IDREQUI", SZU->ZU_NUM+SZU->ZU_ITEM , Nil })
                         
                         aadd(aItensSol,aSolIt)
                         
                         RecLock("SZU",.f.)
                            SZU->ZU_OK := "LB"
                         MsUnLock()
                         DbSelectArea("SZU")
                         DbSkip()
                   Enddo
                   lMsErroAuto := .F. 
                   MATA110(aSol,aItensSol)
                   If lMsErroAuto
                      MsgBox("Ocorreu um erro na grava豫o, processo ser?revertido!","Aten豫o","STOP")
                      DbSelectArea("SZU")
                      DbSetOrder(1)
                      DbSeek(xFilial("SZU")+cNumero,.t.)
                      If Found()
                         While !Eof() .and. SZU->ZU_NUM == cNumero
                               RecLock("SZU",.f.)
                                  SZU->ZU_OK := "AP"
                               MsUnLock()
                               DbSelectArea("SZU")
                               DbSkip()
                         Enddo                  
                      Endif 
                   Endif
                Endif
            Next
     Else
        lGrvDad   := .t.
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?stornar os valores acumulados da requisi豫o de compra.               ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        dbSelectArea("SZU")
        dbSetOrder(1)
        #IFDEF TOP
               If ( TcSrvType()<>"AS/400" )
                  lQuery 		:= .T.
                  cAliasSZU	:= "A110GRAVA"
                  cQuery := "SELECT SZU.*,R_E_C_N_O_ SZURECNO "
                  cQuery += "FROM "+RetSqlName("SZU")+" SZU "
                  cQuery += "WHERE SZU.ZU_FILIAL='"+xFilial("SZU")+"' AND "
                  cQuery += "SZU.ZU_NUM='"+cA110Num+"' AND "
                  cQuery += "SZU.D_E_L_E_T_<>'*' "
                  cQuery += "ORDER BY "+SqlOrder(SZU->(IndexKey()))
                  //cQuery := ChangeQuery(cQuery)
                  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSZU,.T.,.T.)
                  For nX := 1 To Len(aStru)
                      If ( aStru[nX][2] <> "C" )
                         TcSetField(cAliasSZU,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
                      EndIf
                  Next nX
               Else
        #ENDIF
        MsSeek(xFilial("SZU")+cA110Num)
        #IFDEF TOP
               EndIf
        #ENDIF	
        While ( !Eof() .And. (cAliasSZU)->ZU_FILIAL == xFilial("SZU") .And.;
              (cAliasSZU)->ZU_NUM == cA110Num )
              AADD(aRegistro,If(lQuery,(cAliasSZU)->SZURECNO,SZU->(RecNo())))
              dbSelectArea(cAliasSZU)
              dbSkip()
        EndDo
        If ( lQuery )
           dbSelectArea(cAliasSZU)
           dbCloseArea()
           dbSelectArea("SZU")
        EndIf
     EndIf
     If lGrvDad
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?fetua a atualizacao da tabela de requisi豫o de compra.               ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        dbSelectArea("SZU")
        dbSetOrder(1)
        For nX := 1 To Len(aCols)
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
            //?erifico se a linha foi deletada.                                     ?
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
            If ValType(aCols[nX,Len(aCols[nX])]) == "L"
            lDeleted := aCols[nX,Len(aCols[nX])]
            EndIf
            If ( nOpcao == 3 )
               lDeleted := .T.
            EndIf
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
            //?osiciono no registro para alteracao/exclusao                         ?
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸	
            If ( Len(aRegistro) >= nx )
               dbSelectArea("SZU")
               dbGoto( aRegistro[nx] )
               RecLock("SZU",.F.)
            Else
               If ( !lDeleted )
                  RecLock("SZU",.T.)
               EndIf
            EndIf
            If ( !lDeleted )
               //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
               //?Atualiza dados padroes da solicitacao de compras         ?
               //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
               SZU->ZU_FILIAL  := xFilial("SZU")
               SZU->ZU_NUM     := cA110Num
               SZU->ZU_EMISSAO := dA110Data
               SZU->ZU_SOLICIT := cSolic
               SZU->ZU_DIGITAD := cDigit
               SZU->ZU_IDREQUI := cId
               SZU->ZU_OK      := "AP"
               //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
               //?Atualiza dados do corpo da SC selecionados pelo cliente  ?
               //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
               For nY := 1 to Len(aHeader)
                   If ( aHeader[nY][10] <> "V" )
                      SZU->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
                   EndIf
               Next nY
            Else
               If ( Len(aRegistro) >= nx )
                  SZU->(dbDelete())
               EndIf
            EndIf
            SZU->(MsUnLock())
        Next nX
     Endif
     RestArea(aArea)
Return .T.

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?110Valid ?ev.   ?Eduardo Riera         ?Data ?8.07.2000 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo efetuar a validacao da quantida낢?
굇?         ?e informada na requisi豫o  de compras para nao permitir     낢?
굇?         ?ue a quantidade da solicitacao de compra seja menor que a   낢?
굇?         ?uantidade em pedido.                                        낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpZU: [P] para Produto                                      낢?
굇?         ?      [Q] Para quantidade                                   낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?etorno   ?xpL1: Indica se a quantidade eh valida                      낢?
굇?         ?                                                            낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function fger0048(cTipo)
     Local aArea     := GetArea()
     Local cProduto	 := ""
     Local nQuant    := 0
     Local nPProduto := aScan(aHeader,{|x| Trim(x[2])=="ZU_PRODUTO"})
     Local nPQuant   := aScan(aHeader,{|x| Trim(x[2])=="ZU_QUANT"})
     Local nPItem    := aScan(aHeader,{|x| Trim(x[2])=="ZU_ITEM"})
     Local lRetorno  := .T.

     If ( cTipo == "P" )
        cProduto := &(ReadVar())
        nQuant   := aCols[n][nPQuant]
     Else
        cProduto := aCols[n][nPProduto]
        nQuant   := &(ReadVar())
     EndIf
     If ( Altera )
        dbSelectArea("SZU")
        dbSetOrder(2)
        If ( MsSeek(xFilial("SZU")+aCols[n][nPProduto]+cA110Num+aCols[n][nPItem]) )
           //If ( SZU->ZU_QUJE > nQuant )
           //   Help(" ",1,"A110MAIO")
           //   lRetorno := .F.
           //Else 
              lRetorno := .t.
           //EndIf

        EndIf
     EndIf
     RestArea(aArea)
Return(lRetorno)

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?110Monta ?Autor ?Eduardo Riera         ?Data ?7.07.2000 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo atualizar as variaveis de uti- 낢?
굇?         ?izada na modelo 2.                                          낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpN1: [1] Inclusao                                          낢?
굇?         ?      [2] Visualizacao                                      낢?
굇?         ?      [3] Alteracao                                         낢?
굇?         ?      [4] Exclusao                                          낢?
굇?         ?xpB2: CodeBlock a ser avaliado para o retorno da funcao     낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?etorno   ?ExpL1: Conforme indicado pelo CodeBlock em ExpB2, quando o  낢?
굇?         ?este indicar .F., a execucao da funcao sera interrompida.   낢?
굇?         ?Para o codeblock sera informado o alias do SZU.             낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
Static Function fger0049( nOpc )
       Local aArea     := GetArea()
       Local lRetorno  := .T.
       //Local nUsado    := 0
       //Local nX        := 0
       
       //V?iaveis usadas na montagem da fun豫o FillGetDados()
       Local _nIndice   := 1
       Local _cSeek     := xFilial("SZU") + cA110Num
       Local _bWhile    := { || ZU_FILIAL + ZU_NUM }
       Local _bCond     := { || .T. }
       Local _bAction1  := { || .T. }
       Local _bAction2  := { || .T. }
       Local _aNoFields := { "ZU_NUM" }
       
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 09/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZA플O DE RELEASE PROTHEUS 12.1.25                  ***/
       //FillGetDados( _nOPc, _alias, _nIndice, _cSeek, _bWhile, { { _bCond, _bAction1, _bAction2 } }, _aNoFields, /*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,"SC6")
       //                |       |        |        |       |                       |                        +- Array com nome dos campos que ser? exclu?os na montagem do aHeader
       //                |       |        |        |       |                       +-------------------------- Condi豫o para execu豫o do while.
       //                |       |        |        |       +-------------------------------------------------- Bloco contendo a express? a ser comparada com cSeekKey na condi豫o do While.
       //                |       |        |        +---------------------------------------------------------- Chave de pesquisa
       //                |       |        +------------------------------------------------------------------- Indice de pesquida da tabela
       //                |       +---------------------------------------------------------------------------- Alias da tabela que ser?montado os arrays aHeader / aCols
       //                +------------------------------------------------------------------------------------ 2=Visualiza, 3=Inclui, 4=Altera, 5=Exclui
       
       FillGetDados( nOPc, "SZU", _nIndice, _cSeek, _bWhile, { { _bCond, _bAction1, _bAction2 } }, _aNoFields )
       If nOpc == 3 //Inclus?
          aCols[1][ aScan( aHeader, { |x| Trim( x[2] ) == 'ZU_ITEM' } ) ] := StrZero( 1, Len( SZU->ZU_ITEM) )
       Endif
       //bBlock   := {|| .T.}
       //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
       //?Faz a montagem do aHeader a partir dos campos SX3.           ?
       //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
       //aHeader := {}
       //dbSelectArea("SX3")
       //dbSetOrder(1)
       //MsSeek("SZU")
       //While ( !EOF() .And. (SX3->X3_ARQUIVO == "SZU") )
       //      If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. Trim(SX3->X3_CAMPO) <> "ZU_NUM")
       //         nUsado++
       //         AADD(aHeader,{ TRIM(( _cAliasSX3 )->( X3_TITULO )),;
       //                        SX3->X3_CAMPO,;
       //                        SX3->X3_PICTURE,;
       //                        SX3->X3_TAMANHO,;
       //                        SX3->X3_DECIMAL,;
       //                        SX3->X3_VALID,;
       //                        SX3->X3_USADO,;
       //                        SX3->X3_TIPO,;
       //                        SX3->X3_ARQUIVO,;
       //                        SX3->X3_CONTEXT } )
       //      EndIf
       //      dbSelectArea("SX3")
       //      dbSkip()
       //EndDo
       //If ( nOpc <> 1 )
       //   //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
       //   //?Faz a montagem do aCols baseado no aHeader.                  ?
       //   //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
       //   dbSelectArea("SZU")
       //   dbSetOrder(1)
       //   MsSeek(xFilial("SZU")+cA110Num)
       //   While ( !Eof() .And. SZU->ZU_FILIAL == xFilial("SZU") .And.;
       //         SZU->ZU_NUM == cA110Num )
       //         If ( Eval(bBlock,"SZU") .And. If(nOpc<>2,SoftLock("SZU"),.T.) )
       //            If ( nOpc <> 2 )
       //               aadd(aCols,Array(nUsado+1))
       //            Else
       //               aadd(aCols,Array(nUsado))
       //            EndIf
       //            For nX := 1 to Len(aHeader)
       //                If ( aHeader[nX][10] <> "V" .And. aHeader[nX][08] <> "M")
       //                   aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
       //                Else
       //                   If ( aHeader[nX][08] <> "M" )
       //                      aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2],.T.)
       //                   Else
       //                      aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHeader[nX][2]))
       //                   EndIf
       //                EndIf
       //                If ( nOpc <> 2 )
       //                   aCols[Len(aCols)][nUsado+1] := .F.
       //                EndIf
       //            Next nX
       //         Else
       //            lRetorno := .F.
       //            Exit
       //         EndIf
       //         dbSelectArea("SZU")
       //         dbSkip()
       //   EndDo
       //Else
       //   aCols := {}
       //   aadd(aCols,Array(nUsado+1))
       //   aCols[1][nUsado+1] := .F.
       //   For nX := 1 To nUsado
       //       aCols[1][nX] := CriaVar(aHeader[nX][2],.T.)
       //       If ( Trim(aHeader[nX][2]) == "ZU_ITEM" )
       //          aCols[1][nX] := "01"
       //       EndIf
       //   Next nX
       //EndIf
       /********************************************************************************************************************************/
       RestArea(aArea)
Return(lRetorno)

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?110UnidRe?Autor ?Eduardo Riera         ?Data ?8.07.2000 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?         ?otina de validacao da unidade requisitante                  낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?xpZU: Codigo da Unidade Requisitante                        낢?
굇?         ?xpC2: Descricao da Unidade Requisitante                     낢?
굇?         ?xpO3: Objeto da unidade requisitante                        낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?etorno   ?ExpL1: Indica se a unidade requisitante eh valida.          낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo validar a unidade requisitante 낢?
굇?         ?uanto a integridade referencial                             낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?so       ?Materiais                                                   낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
User Function fger004A(cUnidReq,cDescUnidReq,oReq)

     Local aArea 	:= GetArea()
     Local lRetorno  := .T.

     If ( !Empty(cUnidReq) )
        dbSelectArea("SY3")
        dbSetOrder(1)
        If ( !(MsSeek(xFilial("SY3")+cUnidReq)) )
           Help( " ",1,"A110UNID")
           lRetorno := .F.
        EndIf
     EndIf
     RestArea(aArea)
Return(lRetorno)

/*/
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fCOM0046  ?Autor ?Lu? Gustavo de Souza?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?         ?xibe uma janela contendo a legenda da mBrowse.              낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?enhum Codigo do comprador                                   낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*/
User Function FCOM0046()
     BrwLegenda(cCadastro,"Legenda",{ {"ENABLE"  ,"Liberada para Compras"},;
                                      {"DISABLE" ,"Cancelada"            },;
                                      {"BR_PRETO","Cancelada por compras"},;
                                      {"BR_AZUL" ,"Aguardando Aprova豫o" }})
Return

/*/
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fCOM0047 ?ev. 01?Lu? Gustavo de Souza ?Data ?29/08/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?sta rotina tem como objetivo a libera豫o ou rejei豫o das re-낢?
굇?         ?uisi寤es de compras.                                        낢?
굇?         ?                                                            낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇?arametros?ExpZU = Alias do arquivo                                    낢?
굇?         ?ExpN2 = Numero do registro                                  낢?
굇?         ?ExpN3 = Numero da opcao selecionada                         낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
/*//*                         
User Function fCOM0047(cAlias,nReg,nOpcx)
     Local aArea        := GetArea()
     Local aSizeAut     := MsAdvSize(,.F.)
     Local oDlg
     Local oGet
     Local dA110Data    := SZU->ZU_EMISSAO
     Local cSolic       := SZU->ZU_SOLICIT
     Local cDigit       := SZU->ZU_DIGITAD
     Local cNomCompr    := ""
     Local aObjects     := {}
     Local aInfo        := {}
     Local aPosGet      := {}
     Local aPosObj      := {}
     Local aBut110      := { {"CADEADO" ,{||Close(oDlg),fGerRej(SZU->ZU_NUM) },"Rejeita"  } }
     Local lNaturez     := SZU->(FieldPos("ZU_NATUREZ")) > 0
     Local nBack        := NIL   
     Local nOpcA        := 0
     PRIVATE cCodNatu	:= iiF(lNaturez,SZU->ZU_NATUREZ,"")
     PRIVATE cCCusto 	:= SZU->ZU_CC
     PRIVATE cA110Num	:= SZU->ZU_NUM
     PRIVATE aHeader	:= {}
     PRIVATE aCols 		:= {}
     PRIVATE aRatAFG	:= {}
     
     If !SZU->ZU_OK $ "AP"
        MsgBox("Essa requisi豫o j?foi liberada/rejeitada !!!","Aten豫o","INFO")
        Return
     Endif
     cAlias := Alias()
     lRet := fGerSo(SZU->ZU_DIGITAD,"AP"+SubStr(SZU->ZU_IDREQUI,3,1),2)
     If !lRet
        Return
     Endif
     DbSelectArea(cAlias)

     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?Caso exista, guarda o valor de N                             ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     If TYPE( "N" ) == "N" 
        nBack := N
     EndIf 	
     
     fger0049(2,,cA110Num)
     
     N := 1 

     AAdd( aObjects, { 0,    20, .T., .F. } )
     AAdd( aObjects, { 100, 100, .T., .T. } )
     AAdd( aObjects, { 0,    3, .T., .F. } )	
     aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
     aPosObj := MsObjSize( aInfo, aObjects ) 
     aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,35,100,135,205,255}})
     DEFINE MSDIALOG oDlg TITLE OemToAnsi("Requisi豫o de Compras") From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

            @ 20,aPosGet[1,1]-10 SAY OemToAnsi("&N?ero") PIXEL SIZE 020,009
            @ 19,aPosGet[1,2]-20 MSGET cA110Num 	Picture PesqPict("SZU","ZU_NUM") When .F. PIXEL SIZE 020,10
            
            @ 20,aPosGet[1,3]-50 SAY OemToAnsi("&Digitador")  Of oDlg PIXEL
            @ 19,aPosGet[1,4]-70 MSGET cDigit       Picture PesqPict("SZU","ZU_DIGITAD") When .F. PIXEL SIZE 55,10

            @ 20,aPosGet[1,3]+50 SAY OemToAnsi("&Requisitante") PIXEL SIZE 31,9 COLOR CLR_HBLUE
            @ 19,aPosGet[1,4]+40 MSGET cSolic 	Picture PesqPict("SZU","ZU_SOLICIT")	When .F.  PIXEL SIZE 55,10

            @ 20,aPosGet[1,5]+20 SAY OemToAnsi("&Data de Emiss꼘")	PIXEL SIZE 41,9
            @ 19,aPosGet[1,6]    MSGET dA110Data Picture PesqPict("SZU","ZU_EMISSAO")	When .F. PIXEL SIZE 45,10 

            oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_fger0045()","U_fger0046()","",.F.,,,,300)
     
     ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||oDlg:End()},, aBut110)
     If ValType( nBack ) == "N" 
        N := nBack 
     EndIf 	
     If ( nOpcA == 1 )
        Begin Transaction
              U_fger0047(4,ca110Num,cSolic,dA110Data,cCCusto,"","",cDigit)
              EvalTrigger()
        End Transaction
     EndIf
     RestArea(aArea)
Return
*/
/*
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇?un뇚o    ?110Impri ?Autor ?Sergio Silveira       ?Data ?1/09/2001낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇?escri뇚o ?Efetua a chamada do relatorio padrao ou do usuario         낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙?
굇?intaxe   ?ExpX1 := A110Impri( ExpZU, ExpN1, ExpN2 )                  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙?
굇?arametros?ExpZU -> Alias do arquivo                                  낢?
굇?         ?ExpN1 -> Recno do registro                                 낢?
굇?         ?ExpN2 -> Opcao do Menu                                     낢?
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙?
굇?etorno   ?ExpX1 -> Retorno do relatorio                              낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
/*/
User Function fCOM0044(cAlias, nRecno, nOpc )
     Processa({|lEnd| fCAB0044(cAlias, nRecno, nOpc )},"Impress?")
Return

Static Function fCAB0044( cAlias, nRecno, nOpc )
       Loca _ni := 0
       //----------------------------------------------------------------------------//
       // Printer
       #xcommand AVPRINT [ <oPrint> ] ;
                         [ <name:TITLE,NAME,DOC> <cDocument> ] ;
                         [ <user: FROM USER> ] ;
                         [ <prvw: PREVIEW> ] ;
                         [ TO  <xModel> ] ;
                         => ;
                         [ <oPrint> := ] AvPrintBegin( [<cDocument>], <.user.>, <.prvw.>, <xModel> )

       #xcommand AVPRINTER [ <oPrint> ] ;
                           [ <name:NAME,DOC> <cDocument> ] ;
                           [ <user: FROM USER> ] ;
                           [ <prvw: PREVIEW> ] ;
                           [ TO  <xModel> ] ;
                           => ;
                           [ <oPrint> := ] AvPrintBegin( [<cDocument>], <.user.>, <.prvw.>, <xModel> )

       #xcommand AVPAGE => AvPageBegin()
       #xcommand AVENDPAGE => AvPageEnd()
       #xcommand AVNEWPAGE => AvPageEnd() ; AvPageBegin()
       #xcommand AVENDPRINT   => AvPrintEnd() ; AvSetPortrait()
       #xcommand AVENDPRINTER => AvPrintEnd() ; AvSetPortrait()

       Local   nQReq    := 0
       Private nTamanho :="P"
       Private nlinMax  := 2800
       Private nColMax  := 2350

       oFont1 := TFont():New("Courier New Negrito" ,9,19,.F.,.T.,5,.T.,5,.F.,.F.)
       oFont2 := TFont():New("Courier New"         ,9,12,.F.,.F.,5,.T.,5,.F.,.F.)
     
       AVPRINT oPrn NAME "Relatorio de Requisi豫o."
               oPrn:SetPage(9) //Seta Papel como A4
               oPrn:SetLoMetricMode()
               nLin :=  0
               nPri :=  0
               nCol := 30
               AVPAGE
                 cNum := SZU->ZU_NUM
                 DbSelectArea("SZU")
                 DbGoTop()
                 DbSetOrder(1)
                 DbSeek(xFilial("SZU")+cNum,.t.)
                 While !Eof() .and. SZU->ZU_NUM == cNum
                       nQReq := nQReq + 1
                       If nQReq > 3
                          nQreq := 1
                          nLin  := 0
                          AVNEWPAGE
                       Endif
                       fCabImp()
                       oPrn:Say( nPri, nCol+350 , SZU->ZU_PRODUTO+" - "+SZU->ZU_DESCRI , oFont2)
                       nPri += 50
                       cAux := MSMM(U_TiraAcento(SZU->ZU_DESITEM),,,,4)
                       For _ni := 1 to 4
                           If _ni == 1
                              oPrn:Say(nPri, nCol+350 , Substring(cAux,1,74), oFont2)
                              cAux := stuff(caux,1,74,"")
                           Else
                              oPrn:Say(nPri, nCol+20  , Substr(cAux,1,80), oFont2)
                              cAux := stuff(caux,1,80,"")
                           Endif
                           nPri += 50
                       next
                       oPrn:Say( nPri, nCol+380  ,SZU->ZU_UM     , oFont2)
                       oPrn:Say( nPri, nCol+980  ,Transform(SZU->ZU_QUANT,"@E 999,999,999.99") , oFont2)
                       oPrn:Say( nPri, nCol+1880 ,SubStr(Dtos(SZU->ZU_DATPRF),7,2), oFont2)
                       oPrn:Say( nPri, nCol+2030 ,SubStr(Dtos(SZU->ZU_DATPRF),5,2), oFont2)
                       oPrn:Say( nPri, nCol+2180 ,SubStr(Dtos(SZU->ZU_DATPRF),1,4), oFont2)
                       nPri += 50
                       cAux := MSMM(U_TiraAcento(SZU->ZU_APLICAC),,,,4)
                       For _ni := 1 to 3
                           If _ni == 1
                              oPrn:Say(nPri, nCol+350 , Substring(cAux,1,74), oFont2)
                              cAux := stuff(caux,1,74,"")
                           Else
                              oPrn:Say(nPri, nCol+20  , Substr(cAux,1,80), oFont2)
                              cAux := stuff(caux,1,80,"")
                           Endif
                           nPri += 50
                       next
                       oPrn:Say( nPri, nCol+350  , SZU->ZU_CC+" - "+Posicione("SI3",1,xFilial("SI3")+SZU->ZU_CC,"I3_DESC"), oFont2)
                       oPrn:Say( nPri, nCol+1850 , SZU->ZU_CONTA , oFont2)
                       nPri += 50
                       oPrn:Say( nPri, nCol+350 , SZU->ZU_FORNECE+"/"+SZU->ZU_LOJA+" - "+Posicione("SA2",1,xFilial("SA2")+SZU->ZU_FORNECE+SZU->ZU_LOJA,"A2_NREDUZ") , oFont2)
                       oPrn:Say( nPri, nCol+1850, Transform(SZU->ZU_TOTAL,"@E 999,999,999.99") , oFont2)
                       nPri += 50
                       oPrn:Say( nPri, nCol+350 , SZU->ZU_SOLICIT , oFont2)
                       oPrn:Say( nPri, nCol+1880 ,SubStr(Dtos(SZU->ZU_EMISSAO),7,2), oFont2)
                       oPrn:Say( nPri, nCol+2030 ,SubStr(Dtos(SZU->ZU_EMISSAO),5,2), oFont2)
                       oPrn:Say( nPri, nCol+2180 ,SubStr(Dtos(SZU->ZU_EMISSAO),1,4), oFont2)
                       DbSelectArea("SZU")
                       DbSkip()
                 Enddo
               AVENDPAGE
       AVENDPRINT
       MS_FLUSH()
Return()

Static Function fCabImp()
       nLin += 30
       //oSend(oPrn, "SayBitmap", nLin, nCol, "BRASILUX.BMP" , 300, 300 )
       //oPrn:Box( nLin, nCol+310, nLin+300, nColMax )
       oPrn:Box( nLin, nCol, nLin+300, nColMax )
       nLin += 100
       oPrn:Say( nLin, nCol+800, "REQUISI플O DE COMPRAS - "+SZU->ZU_NUM, oFont1)
       nLin += 150
       oPrn:Say( nLin, nCol+20, Alltrim(SM0->M0_NOME)+" / "+Alltrim(SM0->M0_FILIAL), oFont2)
       nLin +=  70
       oPrn:Box( nLin, nCol    , nLin+650, nColMax )
       /*-----------------------------------------------------------------------------*/
       nLin += 30
       nCol += 20
       nPri := nLin
       oPrn:Say( nLin, nCol    , "C?igo     : ", oFont2)
       nLin += 50
       oPrn:Line(nlin-10, nCol+330, nlin-10, nCol+1600)
       /*-----------------------------------------------------------------------------*/
       oPrn:Say( nLin, nCol    , "Descri豫o  : ", oFont2)
       nLin += 50
       oPrn:Line(nlin-10, nCol+330, nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       nLin += 50
       oPrn:Line(nlin-10, nCol   , nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       nLin += 50
       oPrn:Line(nlin-10, nCol   , nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       nLin += 50
       oPrn:Line(nlin-10, nCol   , nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       oPrn:Say( nLin, nCol      , "Unidade    : ", oFont2)
       oPrn:Say( nLin, nCol+600  , "Quantidade : ", oFont2)
       oPrn:Say( nLin, nCol+1400 , "Prazo Entrega : ", oFont2)
       oPrn:Say( nLin, nCol+1965 , "/", oFont2)
       oPrn:Say( nLin, nCol+2115 , "/", oFont2)
       nLin += 50
       oPrn:Line(nlin-10, nCol+330 , nlin-10, nCol+450)
       oPrn:Line(nlin-10, nCol+930 , nlin-10, nCol+1330)
       oPrn:Line(nlin-10, nCol+1830, nlin-10, nCol+1950)
       oPrn:Line(nlin-10, nCol+1980, nlin-10, nCol+2100)
       oPrn:Line(nlin-10, nCol+2130, nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       oPrn:Say( nLin, nCol    , "Aplica豫o  : ", oFont2)
       nLin += 50
       oPrn:Line(nlin-10, nCol+330, nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       nLin += 50
       oPrn:Line(nlin-10, nCol   , nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       nLin += 50
       oPrn:Line(nlin-10, nCol   , nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       oPrn:Say( nLin, nCol     , "C. Custo   : ", oFont2)
       oPrn:Say( nLin, nCol+1400, "Cta. Cont?il : ", oFont2)
       nLin += 50
       oPrn:Line(nlin-10, nCol+330 , nlin-10, nCol+1330)
       oPrn:Line(nlin-10, nCol+1830, nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       oPrn:Say( nLin, nCol     , "Fornecedor : ", oFont2)
       oPrn:Say( nLin, nCol+1400, "Vlr. Estimado : ", oFont2)
       nLin += 50
       oPrn:Line(nlin-10, nCol+330 , nlin-10, nCol+1330)
       oPrn:Line(nlin-10, nCol+1830, nlin-10, nColMax-20)
       /*-----------------------------------------------------------------------------*/
       oPrn:Say( nLin, nCol    , "Solicitante: ", oFont2)
       oPrn:Say( nLin, nCol+1400 , "Data Emiss?  : ", oFont2)
       oPrn:Say( nLin, nCol+1965 , "/", oFont2)
       oPrn:Say( nLin, nCol+2115 , "/", oFont2)
       nLin += 50
       oPrn:Line(nlin-10, nCol+330 , nlin-10, nCol+0830)
       oPrn:Line(nlin-10, nCol+1830, nlin-10, nCol+1950)
       oPrn:Line(nlin-10, nCol+1980, nlin-10, nCol+2100)
       oPrn:Line(nlin-10, nCol+2130, nlin-10, nColMax-20)
       nLin += 50
       nCol -=  20
Return Nil

/*
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇?un뇙o    ?fGER004C ? Autor?Lu? Gustavo de Souza ?Data ?29/08/03 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇?escri뇙o ?mpede Alteracoes dos Campos conforme as restricoes alcadas 낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
/*/
User Function fGER004C()
     Local lRet      := .T.
     Local cMenVar   := &(ReadVar())
     Local nPProduto := aScan(aHeader,{|x| Trim(x[2])=="ZU_PRODUTO"})
     Local nPItem    := aScan(aHeader,{|x| Trim(x[2])=="ZU_ITEM"})

     If !(cMenVar == cCampo)
        //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
        //?erifica se a Linha pode ser alterada                                 ?
        //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
        If ( Altera )
           dbSelectArea("SZU")
           dbSetOrder(2)
           If ( MsSeek(xFilial("SZU")+aCols[n][nPProduto]+cA110Num+aCols[n][nPItem]) )
              lRet := .t.
           EndIf
        EndIf
     EndIf
Return( lRet )

/*
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽?
굇?un뇙o    ?fGER004D ? Autor?Lu? Gustavo de Souza ?Data ?29/08/03 낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙?
굇?escri뇙o ?alida delecao da linha conforme as restricoes de alcadas   낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂?
/*/
User Function fGER004D()
     Local lRet      := .T.
     Local nPProduto := aScan(aHeader,{|x| Trim(x[2])=="ZU_PRODUTO"})
     Local nPItem    := aScan(aHeader,{|x| Trim(x[2])=="ZU_ITEM"})

     //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
     //?erifica se a Linha pode ser deletada                                 ?
     //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
     If ( Altera ) .And. !aCols[n,Len(aCols[n])]
        dbSelectArea("SZU")
        dbSetOrder(2)
        If ( MsSeek(xFilial("SZU")+aCols[n][nPProduto]+cA110Num+aCols[n][nPItem]) )
           lRet := .t.
        EndIf
     EndIf

Return( lRet )

Static Function fGerSo(cDigit,cId,nNum)
       Local lRet     := .f.
       //Local cQry     := ""
       Local _aRetInf := FWGetSX5 ( "Z2" )
       Local _nX      := 0
       /********************************************************************************************************************************/
       /*** BLOCO ALTERADO EM 17/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZA플O DE RELEASE PROTHEUS 12.1.25                  ***/
       //If nNum == 1
          //cQry += "SELECT * "
          //cQry += "FROM SX5"+cEmpAnt+"0 X5 "
          //cQry += "WHERE X5.X5_TABELA = 'Z2' "
          //cQry += "  AND X5.D_E_L_E_T_ = '' "
          //cQry += "  AND X5.X5_DESCRI =  '"+Upper(cDigit)+"' "
          //cQry += "  AND SUBSTRING(X5.X5_CHAVE,1,2) = 'EM' "
          //cQry += ChangeQuery(cQry)
          //DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "TCQ", .F.)
          //DbSelectArea("TCQ")
          //DbGoTop()
          //If !Eof()
          //   lRet := .t.
          //   cId  := TCQ->X5_CHAVE
          //Else
          //   MsgBox("Usu?io n? autorizado !!!","Aten豫o","STOP")
          //   lRet := .f.
          //   cId  := ""
          //Endif
       //Else
          //cQry += "SELECT * "
          //cQry += "FROM SX5"+cEmpAnt+"0 X5 "
          //cQry += "WHERE X5.X5_TABELA = 'Z2' "
          //cQry += "  AND X5.D_E_L_E_T_ = '' "
          //cQry += "  AND X5.X5_CHAVE LIKE ('"+cId+"%') "
          ////cQry += ChangeQuery(cQry)
          //DBUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "TCQ", .F.)
          //DbSelectArea("TCQ")
          //DbGoTop()
          //If !Eof()
          //   If Upper(Alltrim(cUsername)) == Alltrim(Upper(TCQ->X5_DESCRI))
          //      lRet := .t.
          //   Else
          //      lRet := .f.
          //      MsgBox("Usu?io n? autorizado !!!","Aten豫o","STOP")
          //   Endif
          //Else
          //   lRet := .f.
          //   MsgBox("Usu?io n? autorizado !!!","Aten豫o","STOP")
          //Endif
       //Endif
       //DbSelectArea("TCQ")
       //DbCloseArea()
       For _nX := 1 To Len( _aRetInf )
           If nNum == 1
              If _aRetInf[_nX][3] == 'EM' .and. Upper( Alltrim( _aRetInf[_nX][4] ) ) == Upper( Alltrim( cDigit ) )
                 lRet := .T.
                 cId  := _aRetInf[_nX][3]
              Endif
           Else
              If _aRetInf[_nX][3] == 'AP' .and. Upper( Alltrim( _aRetInf[_nX][4] ) ) == Upper( Alltrim( cDigit ) )
                 lRet := .T.
              Endif
           Endif
       Next
       If !lRet
          MessageBox( "Usu?io n? autorizado !!!", "Aten豫o...", 16 )
       Endif
       /********************************************************************************************************************************/
Return( lRet )

//Static Function fGerRej(cNUM)
//       DbSelectArea("SZU")
//       DbSetOrder(1)
//       DbSeek(xFilial("SZU")+cNum,.t.)
//       If Found()
//          While !Eof() .and. SZU->ZU_NUM == cNum
//                RecLock("SZU",.f.)
//                   SZU->ZU_OK := "RC"
//                MsUnLock()
//                DbSelectArea("SZU")
//                DbSkip()
//          Enddo
//       Endif
//Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇?un뇙o    ?fCOM0047 ?utor  ?Luis Gustavo de Souza ?Data ?10/10/03  낢?
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇?escri뇙o ?Libera豫o de itens para compras.                            낢?
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
/*/
User Function fCOM0047()
     Local oDlg
     Local cDigitador   := ""
     Local oDigitador
     Local cRequisit    := ""
     Local oRequisit
     Local dEmissao     := cTod("  /  /  ")
     Local oEmissao  
     Local dNecessid    := cTod("  /  /  ")
     Local oNecessid 
     Local cTextMemo1   := ""
     Local oTextMemo1
     Local cTextMemo2   := ""
     Local oTextMemo2
     //Local cSZU
     Local oSZU
     Local cQuery       := ""
     Local aLog         := {}
     Local aHeader1     := {}
     Local aHeader2     := {}
     Local aStrut       := {}
     //Local cQry         := ""
     Local _nx          := 0
     Private cArqTemp   := GetNextAlias()
     Private oTempTbl01
     
     //SET KEY VK_F12 TO fSelecao()
     SetKey( VK_F12, { || fSelecao() } )
     
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 17/01/2020 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZA플O DE RELEASE PROTHEUS 12.1.25                  ***/
     //cQry := ""
     //cQry += "SELECT X5.X5_CHAVE "
     //cQry += "FROM SX5"+cEmpAnt+"0 X5 WITH (NOLOCK) "
     //cQry += "WHERE X5.X5_TABELA = 'Z2' "
     //cQry += "  AND SUBSTRING(X5.X5_CHAVE,1,2) IN('AP') "
     //cQry += "  AND X5.X5_DESCRI = '"+UPPER(ALLTRIM(cUsername))+"' "
     //cQry += "  AND X5.D_E_L_E_T_ = '' "
     //cQry := ChangeQuery(cQry)
     //dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "QUSR",.T.,.T.)
     
     //cAprov := "'"
     //DbSelectArea("QUSR")
     //While !Eof()
     //      cAprov += SubStr(Alltrim(QUSR->X5_CHAVE),3,1)+"','"
     //      DbSkip()
     //Enddo
     //cAprov := stuff(cAprov,Len(cAprov)-1,2,"")
     //DbSelectArea("QUSR")
     //DbCloseArea()
     //If Empty(cAprov)
     //   MsgBox("Usu?io n? est?cadastrado como aprovador.","Aten豫o","STOP")
     //   Return
     //Endif
     
     lRet := fGerSo( cUsername, @cId, 2 )
     If !lRet
        Return
     Else
        cAprov := Alltrim( cUsername )
     Endif
     /********************************************************************************************************************************/
     aadd(aHeader2,{"TMP_FLAG"   ,"","",""})
     aadd(aHeader2,{"TMP_NUM"    ,"",RetTitle("ZU_NUM")     ,PesqPict("SZU","ZU_NUM"     )})
     aadd(aHeader2,{"TMP_ITEM"   ,"",RetTitle("ZU_ITEM")    ,PesqPict("SZU","ZU_ITEM"    )})
     aadd(aHeader2,{"TMP_PRODUT" ,"",RetTitle("ZU_PRODUTO") ,PesqPict("SZU","ZU_PRODUTO" )})
     aadd(aHeader2,{"TMP_UM"     ,"",RetTitle("ZU_UM")      ,PesqPict("SZU","ZU_UM"      )})
     aadd(aHeader2,{"TMP_QUANT"  ,"",RetTitle("ZU_QUANT")   ,PesqPict("SZU","ZU_QUANT"   )})
     aadd(aHeader2,{"TMP_VLRUNT" ,"",RetTitle("ZU_VLRUNIT") ,PesqPict("SZU","ZU_VLRUNIT" )})
     aadd(aHeader2,{"TMP_TOTAL"  ,"",RetTitle("ZU_TOTAL")   ,PesqPict("SZU","ZU_TOTAL"   )})
     
     aadd(aStrut,{"TMP_FLAG"   , "C", 02, 0})     
     aadd(aStrut,{"TMP_NUM"    , "C", 06, 0})
     aadd(aStrut,{"TMP_ITEM"   , "C", 02, 0})
     aadd(aStrut,{"TMP_PRODUT" , "C", 15, 0})
     aadd(aStrut,{"TMP_UM"     , "C", 02, 0})
     aadd(aStrut,{"TMP_QUANT"  , "N", 12, 2})
     aadd(aStrut,{"TMP_VLRUNT" , "N", 11, 4})
     aadd(aStrut,{"TMP_TOTAL"  , "N", 14, 4})
     
     cQuery := ""
     cQuery += "SELECT * "
     cQuery += "FROM SZU"+cEmpAnt+"0 ZU "
     If lSelecao
        cQuery += "WHERE ZU.ZU_OK IN('AP') "
     Else
        cQuery += "WHERE ZU.ZU_NUM = '"+SZU->ZU_NUM+"' "
        cQuery += "  AND ZU.ZU_OK IN('AP') "
     Endif
     cQuery += "  AND SUBSTRING(ZU.ZU_IDREQUI,3,1) IN("+cAprov+") "
     cQuery += "  AND ZU.D_E_L_E_T_ = '' "
     cQuery += "  AND ZU.ZU_FILIAL = '"+xFilial("SZU")+"' "
     //cQuery := ChangeQuery(cQuery)
     dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "QSZU",.T.,.T.)
     
     DbSelectArea("QSZU")
     DbGoTop()
     While !Eof()
           aadd(aLog, { QSZU->ZU_NUM, QSZU->ZU_ITEM, QSZU->ZU_PRODUTO, QSZU->ZU_UM, QSZU->ZU_QUANT, QSZU->ZU_VLRUNIT, QSZU->ZU_TOTAL  } )
           DbSelectArea("QSZU")
           DbSkip()
     Enddo
     DbSelectArea("QSZU")
     DbCloseArea()
     /********************************************************************************************************************************/
     /*** BLOCO ALTERADO EM 23/12/2019 POR LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZA플O DE RELEASE PROTHEUS 12.1.25                  ***/
     //cArqTemp := CriaTrab(aStrut,.T.)
     //dbUseArea(.T., __LocalDrive, cArqTemp, cArqTemp, .F., .F.)
     //index on TMP_NUM+TMP_ITEM TAG cInd01
     //DBClearInd()
     //DbSetIndex(cArqTemp)
     
     oTempTbl01 := FWTemporaryTable():New( cArqTemp )
     oTempTbl01:SetFields( aStrut )
     oTempTbl01:AddIndex( "cInd01", { "TMP_NUM", "TMP_ITEM" } )
     oTempTbl01:Create()

     /********************************************************************************************************************************/
     DbSetOrder(1)
     
     For _nx := 1 to Len(aLog)
         DbSelectArea(cArqTemp)
         RecLock(cArqTemp, .T.)
            (cArqTemp)->TMP_FLAG   := "XX"
            (cArqTemp)->TMP_NUM    := aLog[_nx][1]
            (cArqTemp)->TMP_ITEM   := aLog[_nx][2]
            (cArqTemp)->TMP_PRODUT := aLog[_nx][3]
            (cArqTemp)->TMP_UM     := aLog[_nx][4]
            (cArqTemp)->TMP_QUANT  := aLog[_nx][5]
            (cArqTemp)->TMP_VLRUNT := aLog[_nx][6]
            (cArqTemp)->TMP_TOTAL  := aLog[_nx][7]
         MsUnLock()
         aLog[_nx][5] := Transform(aLog[_nx][5],PesqPict("SZU","ZU_QUANT")  )
         aLog[_nx][6] := Transform(aLog[_nx][6],PesqPict("SZU","ZU_VLRUNIT"))
         aLog[_nx][7] := Transform(aLog[_nx][7],PesqPict("SZU","ZU_TOTAL")  )
     Next
     aSort( aLog,,,{ |x, y| x[1]+x[2] < y[1]+y[2] } )
     aHeader1 := {"Numero", "Item", "Produto", "UM", "Quantidade", "V. Unit. Estimado", "V. Total Estimado"}

     DbSelectArea(cArqTemp)
     DbGoTop()
     If Len(aLog) <= 0
        MsgBox("N? foram encontradas requisi寤es a serem aprovadas!!!","Informa豫o","INFO")
        Return
     Endif
     DEFINE MSDIALOG oDlg FROM 000,000 TO 24,100 TITLE OemToAnsi( "Libera豫o para Compras" )
            @ 005,003 TO 078,392  TITLE OemToAnsi(" Movimentos " )
            @ 085,003 SAY  OemToAnsi("Digitador")                       SIZE 030,10 PIXEL OF oDlg
            @ 084,033 MSGET oDigitador VAR cDigitador     WHEN  .f.     SIZE 060,10 PIXEL OF oDlg
            @ 085,103 SAY  OemToAnsi("Requisitante")                    SIZE 030,10 PIXEL OF oDlg
            @ 084,143 MSGET oRequisit  VAR cRequisit      WHEN  .f.     SIZE 060,10 PIXEL OF oDlg
            @ 085,213 SAY  OemToAnsi("Emiss?")                         SIZE 030,10 PIXEL OF oDlg
            @ 084,243 MSGET oEmissao   VAR dEmissao       WHEN  .f.     SIZE 040,10 PIXEL OF oDlg
            @ 085,293 SAY  OemToAnsi("Necessidade")                     SIZE 032,10 PIXEL OF oDlg
            @ 084,335 MSGET oNecessid  VAR dNecessid      WHEN  .f.     SIZE 040,10 PIXEL OF oDlg
            
            @ 105,003 TO 172, 180 TITLE OemToAnsi( " D E S C R I ??O   T E C N I C A " ) 
            @ 112,006 GET cTextMemo1 MEMO WHEN  .f.     SIZE 170,057 Object oTextMemo1
            
            @ 105,183 TO 172, 360 TITLE OemToAnsi( " A P L I C A ??O " ) 
            @ 112,186 GET cTextMemo2 MEMO WHEN  .f.     SIZE 170,057 Object oTextMemo2

            oSZU := MsSelect():New(cArqTemp, "TMP_FLAG",, aHeader2, .F., "XX", {015,006,070,382},,, oDlg)
            oSZU:oBrowse:lCanAllMark := .F.
            oSZU:bMark := {|| .T. }
            oSZU:oBrowse:bchange := { || COM00471(oSZU:oBrowse:nAt, aLog, @oTextMemo1, @cTextMemo1, @oDigitador, @cDigitador, @oRequisit, @cRequisit, @oEmissao, @dEmissao, @oNecessid, @dNecessid, @oTextMemo2, @cTextMemo2, oSZU:OBROWSE:NROWPOS) }
            nOpcGetd := 2

            @ 105,365 BMPBUTTON TYPE 13 ACTION fLibera(oDlg) OBJECT oBMP1
            oBMP1:cToolTip := "Libera"
            @ 127,365 BMPBUTTON TYPE 03 ACTION fRejeita(oDlg) OBJECT oBMP2
            oBMP2:cToolTip := "Rejeita"
            @ 160,365 BMPBUTTON TYPE 02 ACTION oDlg:End() OBJECT oBMP3
     ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( oSZU:oBrowse:Refresh(), oSZU:oBrowse:SetFocus(.T.), COM00471( oSZU:oBrowse:nAt, aLog, @oTextMemo1, @cTextMemo1, @oDigitador, @cDigitador, @oRequisit, @cRequisit, @oEmissao, @dEmissao, @oNecessid, @dNecessid, @oTextMemo2, @cTextMemo2, oSZU:OBROWSE:NROWPOS ) )
     oTempTbl01:Delete()
Return

Static Function COM00471( nPos, aLog, oTextMemo1, cTextMemo1, oDigitador, cDigitador, oRequisit, cRequisit, oEmissao, dEmissao, oNecessid, dNecessid, oTextMemo2, cTextMemo2, nPos2  )
       DbSelectArea("SZU")
       DbSetOrder(1)
       DbSeek(xFilial("SZU")+aLog[nPos2][1]+aLog[nPos2][2],.t.)
       If Found()
          cDigitador := SZU->ZU_DIGITAD
          cRequisit  := SZU->ZU_SOLICIT
          dEmissao   := SZU->ZU_EMISSAO
          dNecessid  := SZU->ZU_DATPRF
          cTextMemo1 := SZU->ZU_DESITEM
          cTextMemo2 := SZU->ZU_APLICAC
       Else
          cDigitador := space(15)
          cRequisit  := space(15)
          dEmissao   := cTod("  /  /  ")
          dNecessid  := cTod("  /  /  ")
          cTextMemo1 := ""
          cTextMemo2 := ""
       Endif
       If oDigitador <> Nil
          oDigitador:Refresh()
       Endif
       If oRequisit <> Nil
          oRequisit:Refresh()
       Endif
       If oEmissao <> Nil
          oEmissao:Refresh()
       Endif
       If oNecessid <> Nil
          oNecessid:Refresh()
       Endif
       If oTextMemo1 <> Nil
          oTextMemo1:Refresh()
       Endif
       If oTextMemo2 <> Nil
          oTextMemo2:Refresh()
       Endif
Return

Static Function fSelecao()
       pergunte("COM004",.T.)
       lSelecao := IIF(mv_par01==1,.T.,.F.)
Return

Static Function fLibera(oDlg)
       Local aGrava     := {}
       oDlg:End()
       DbSelectArea(cArqTemp)
       DbGoTop()
       While !Eof()
             If Marked("TMP_FLAG")
                nPos := aScan(aGrava, (cArqTemp)->TMP_NUM )
                If nPos == 0
                   aadd(aGrava, (cArqTemp)->TMP_NUM )
                Endif
             Endif
             DbSelectArea(cArqTemp)
             DbSkip()
       Enddo
       If Len(aGrava) > 0
          Begin Transaction
                U_fger0047(4, "", "", "", "", "", "", "", "", aGrava)
                EvalTrigger()       
          End Transaction
       Else
          MsgBox("Nenhum item foi marcado.","Aten豫o...","INFO")
       Endif
Return

Static Function fRejeita(oDlg)
       oDlg:End()
       DbSelectArea(cArqTemp)
       DbGoTop()
       While !Eof()
             If Marked("TMP_FLAG")
                DbSelectArea("SZU")
                DbSetOrder(1)
                DbSeek(xFilial("SZU")+(cArqTemp)->TMP_NUM+(cArqTemp)->TMP_ITEM,.t.)
                If Found()
                   RecLock("SZU",.f.)
                      SZU->ZU_OK := "RC"
                   MsUnLock()
                Endif
             Endif
             DbSelectArea(cArqTemp)
             DbSkip()
       Enddo
Return
