//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function zVid0020
Tela com vАrios componentes grАficos, usando FWLayer
@type Function
@author Atilio
@since 09/03/2022
@version 1.0
/*/

User Function zVid0020()
    Local aArea := GetArea()

    fMontaTela()

    RestArea(aArea)
Return

Static Function fMontaTela()
   Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Private aCoBrwIte := {}
Private aHoBrwIte := {}
Private aFolder    := {"Itens","Custos","DiagnСstico / SoluГЦo","HistСrico","Resumo"}
Private cSACAnex   := Space(10)
Private cSACAssu   := Space(3)
Private cSAcAtend  := Space(15)
Private cSACClie   := Space(6)
Private cSACDASS   := Space(30)
Private cSACDEsc  
Private cSACDOCO   := Space(30)
Private cSACFone   := Space(20)
Private cSACFone2  := Space(15)
Private cSACHI     := Space(5)
Private cSACLj     := Space(2)
Private cSACNF     := Space(9)
Private cSACNome   := Space(30)
Private cSacNum    := Space(6)
Private cSACOcorr  := Space(6)
Private cSacSeri   := Space(1)
Private dSACData   := CtoD(" ")
Private noBrwIte  := 0
Private nTpDesc   
Private nTPSac    

/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠ DeclaraГЦo de Variaveis Private dos Objetos                             ╠╠
ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
SetPrvt("oDlgSAC","oSACGrp01","oSay1","oSay2","oSay3","oSay4","oSacNum","oSACData","oTpDesc","oTPSac")
SetPrvt("oSay5","oSay6","oSay7","oSay8","oSay9","oSay10","oSay16","oSACNF","oSacSeri","oSACClie","oSACLj")
SetPrvt("oSACFone","oSACContat","oSACGrp03","oSay11","oSay12","oSay13","oSay14","oSay15","oSAcAtend","oSACHI")
SetPrvt("oSACAssu","oSACDASS","oSACOcorr","oSACDOCO","oSACGrp04","oSACDEsc","oSACFld","oBrwIte","oBtnOk")
 

/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠ Definicao do Dialog e todos os seus componentes.                        ╠╠
ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
oDlgSAC    := MSDialog():New( 145,233,796,1325,"Atendimento ao Cliente",,,.F.,,,,,,.T.,,,.T. )

oSACGrp01  := TGroup():New( 004,008,044,528," Dados do SAC ",oDlgSAC,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 016,016,{||"Numero "},oSACGrp01,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2      := TSay():New( 016,084,{||"Data"},oSACGrp01,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 016,152,{||"Tipo Desconto"},oSACGrp01,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
oSay4      := TSay():New( 016,240,{||"Tipo SAC"},oSACGrp01,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSacNum    := TGet():New( 024,016,{|u| If(PCount()>0,cSacNum:=u,cSacNum)},oSACGrp01,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSacNum",,)
oSACData   := TGet():New( 024,084,{|u| If(PCount()>0,dSACData:=u,dSACData)},oSACGrp01,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dSACData",,)
oTpDesc    := TComboBox():New( 024,152,{|u| If(PCount()>0,nTpDesc:=u,nTpDesc)},,072,010,oSACGrp01,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,nTpDesc )
oTPSac     := TComboBox():New( 024,240,{|u| If(PCount()>0,nTPSac:=u,nTPSac)},{"a","b","c","d","e","g"},072,010,oSACGrp01,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,nTPSac )

oSACGrp02  := TGroup():New( 052,008,092,528," Nota Fiscal / Dados Cliente  ",oDlgSAC,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay5      := TSay():New( 064,016,{||"Nota Fiscal"},oSACGrp02,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay6      := TSay():New( 064,084,{||"Serie"},oSACGrp02,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay7      := TSay():New( 064,116,{||"CСdigo"},oSACGrp02,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay8      := TSay():New( 064,180,{||"Loja"},oSACGrp02,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay9      := TSay():New( 064,200,{||"Nome"},oSACGrp02,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay10     := TSay():New( 064,376,{||"Fone"},oSACGrp02,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay16     := TSay():New( 064,440,{||"Contato"},oSACGrp02,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSACNF     := TGet():New( 072,016,{|u| If(PCount()>0,cSACNF:=u,cSACNF)},oSACGrp02,060,008,'', { || fValNota() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACNF",,)
oSacSeri   := TGet():New( 072,084,{|u| If(PCount()>0,cSacSeri:=u,cSacSeri)},oSACGrp02,024,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSacSeri",,)
oSACClie   := TGet():New( 072,116,{|u| If(PCount()>0,cSACClie:=u,cSACClie)},oSACGrp02,060,008,'',{ || fValClient() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA1","cSACClie",,)
oSACLj     := TGet():New( 072,180,{|u| If(PCount()>0,cSACLj:=u,cSACLj)},oSACGrp02,016,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACLj",,)
oSACNome   := TGet():New( 072,200,{|u| If(PCount()>0,cSACNome:=u,cSACNome)},oSACGrp02,172,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F.},.F.,.F.,,.F.,.F.,"","cSACNome",,)
oSACFone   := TGet():New( 072,376,{|u| If(PCount()>0,cSACFone:=u,cSACFone)},oSACGrp02,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACFone",,)
oSACContat := TGet():New( 072,440,{|u| If(PCount()>0,cSACContat:=u,cSACContat)},oSACGrp02,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACContat",,)

oSACGrp03  := TGroup():New( 100,008,204,528," Dados Atendimento ",oDlgSAC,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay11     := TSay():New( 112,016,{||"Atendenete"},oSACGrp03,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay12     := TSay():New( 112,080,{||"Hora Inicio"},oSACGrp03,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay13     := TSay():New( 112,144,{||"Anexo"},oSACGrp03,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay14     := TSay():New( 112,212,{||"Assunto"},oSACGrp03,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay15     := TSay():New( 112,344,{||"Ocorrencia"},oSACGrp03,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSAcAtend  := TGet():New( 120,016,{|u| If(PCount()>0,cSAcAtend:=u,cSAcAtend)},oSACGrp03,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSAcAtend",,)
oSACHI     := TGet():New( 120,080,{|u| If(PCount()>0,cSACHI:=u,cSACHI)},oSACGrp03,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACHI",,)
oSACAnex   := TGet():New( 120,144,{|u| If(PCount()>0,cSACAnex:=u,cSACAnex)},oSACGrp03,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cSACAnex",,)
oSACAssu   := TGet():New( 120,212,{|u| If(PCount()>0,cSACAssu:=u,cSACAssu)},oSACGrp03,028,008,'',{ || fValAssunt() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"T1","cSACAssu",,)
oSACDASS   := TGet():New( 120,244,{|u| If(PCount()>0,cSACDASS:=u,cSACDASS)},oSACGrp03,096,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F.},.F.,.F.,,.F.,.F.,"","cSACDASS",,)
oSACOcorr  := TGet():New( 120,344,{|u| If(PCount()>0,cSACOcorr:=u,cSACOcorr)},oSACGrp03,028,008,'',{ || fValOcorre() },CLR_BLACK,CLR_WHITE,,,,.T.,"",,nOpc == 3,.F.,.F.,,.F.,.F.,"SU9","cSACOcorr",,)
oSACDOCO   := TGet():New( 120,376,{|u| If(PCount()>0,cSACDOCO:=u,cSACDOCO)},oSACGrp03,144,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F.},.F.,.F.,,.F.,.F.,"","cSACDOCO",,)
oSACGrp04  := TGroup():New( 136,016,200,520," Descritivo OcorrЙncia /  Problema ",oSACGrp03,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSACDEsc   := TMultiGet():New( 044,012,{|u| If(PCount()>0,cSACDEsc:=u,cSACDEsc)},oSACGrp04,496,052,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oBtnOk     := TButton():New( 296,492,"Confrma",oDlgSAC,{|| GRAVA},037,012,,,,.T.,,"",,,,.F. )
oBtnCanc   := TButton():New( 296,432,"Cancelar",oDlgSAC,{|| oDlgSAC:End()},037,012,,,,.T.,,"",,,,.F. )

oFld1      := TFolder():New( 212,008,{"oaDialogs1","oaDialogs2","oaDialogs3","oaDialogs4","oaDialogs5"},{},oDlgSAC,,,,.T.,.F.,520,072,) 
MHoBrw1()
MCoBrw1()
oBrw1      := MsNewGetDados():New(004,004,052,512,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oaDialogs1,aHoBrw1,aCoBrw1 )
oSay17     := TSay():New( 008,012,{||"oSay17"},oFld1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay18     := TSay():New( 008,080,{||"oSay18"},oFld1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay19     := TSay():New( 008,152,{||"oSay19"},oFld1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay20     := TSay():New( 008,220,{||"oSay20"},oFld1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet1      := TGet():New( 016,012,,oFld1:aDialogs[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet2      := TGet():New( 016,080,,oFld1:aDialogs[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet3      := TGet():New( 016,152,,oFld1:aDialogs[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet4      := TGet():New( 016,220,,oFld1:aDialogs[2],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oSay21     := TSay():New( 044,008,{||"oSay21"},oFld1:aDialogs[3],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay22     := TSay():New( 044,204,{||"oSay22"},oFld1:aDialogs[3],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oMGet1     := TMultiGet():New( 004,008,,oFld1:aDialogs[3],504,032,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oGet5      := TGet():New( 040,032,,oFld1:aDialogs[3],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oCBox1     := TComboBox():New( 040,232,,,072,010,oFld1:aDialogs[3],,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
oMGet2     := TMultiGet():New( 032,004,,oFld1:aDialogs[4],508,020,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oBrw2      := MsSelect():New( "","","",{{"","","Title",""}},.F.,,{000,004,028,512},,, oFld1:aDialogs[4] ) 
oSay23     := TSay():New( 008,012,{||"oSay23"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay24     := TSay():New( 036,012,{||"oSay24"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay25     := TSay():New( 008,084,{||"oSay25"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay26     := TSay():New( 036,084,{||"oSay26"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay27     := TSay():New( 004,152,{||"oSay27"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay28     := TSay():New( 008,220,{||"oSay28"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay29     := TSay():New( 036,152,{||"oSay29"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay30     := TSay():New( 004,296,{||"oSay30"},oFld1:aDialogs[5],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet6      := TGet():New( 016,012,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet7      := TGet():New( 044,012,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet8      := TGet():New( 016,084,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet9      := TGet():New( 044,084,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet10     := TGet():New( 016,152,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet11     := TGet():New( 016,220,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet12     := TGet():New( 044,152,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet13     := TGet():New( 016,296,,oFld1:aDialogs[5],060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oBtn1      := TButton():New( 044,416,"oBtn1",oFld1:aDialogs[5],,037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 044,464,"oBtn2",oFld1:aDialogs[5],,037,012,,,,.T.,,"",,,,.F. )

oDlgSAC:Activate(,,,.T.)

Return

/*ддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддддддддддддд
Function  Ё MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias: 
ддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддддддддд*/
Static Function MHoBrw1()

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("")
While !Eof() .and. SX3->X3_ARQUIVO == ""
   If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
      noBrw1++
      Aadd(aHoBrw1,{Trim(X3Titulo()),;
           SX3->X3_CAMPO,;
           SX3->X3_PICTURE,;
           SX3->X3_TAMANHO,;
           SX3->X3_DECIMAL,;
           "",;
           "",;
           SX3->X3_TIPO,;
           "",;
           "" } )
   EndIf
   DbSkip()
End

Return


/*ддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбддддддддддддддддддд
Function  Ё MCoBrw1() - Monta aCols da MsNewGetDados para o Alias: 
ддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддаддддддддддддддд*/
Static Function MCoBrw1()

Local aAux := {}
Local nI := 0

Aadd(aCoBrw1,Array(noBrw1+1))
For nI := 1 To noBrw1
   aCoBrw1[1][nI] := CriaVar(aHoBrw1[nI][2])
Next
aCoBrw1[1][noBrw1+1] := .F.

Return

