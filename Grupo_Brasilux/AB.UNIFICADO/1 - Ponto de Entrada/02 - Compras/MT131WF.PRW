#include 'TOTVS.CH'
#include "TbiConn.ch"
User Function MT131WF()
     Local cAlias     := Alias()
     Local aArea      := U_PegaArea({"SC8","SY1","SA2","SB1"})
     Local aUsers     := {} 
     Local _nItem,nX,cNumCot,cRemete,nPos,cComprador,cNomeProd
     Local lParamIXB  := Type("ParamIXB") != "U"
	 Local cParamIXB  := Nil
     Private cCodUser := ""
     Private nNumero  := ""
     Private cCodFor  := ""
     Private cForEMail:= ""

     If FWCodEmp() <> '11'
        /*-----------------------------------------------------------------------------------*
        | Projeto ..: Siga Workflow - Versão AP7                                             |
        | Módulo ...: Processo de Cotação de Preços de Produtos com os fornecedores.         |
        | Programa .: MATA130                                                                |
        *------------------------------------------------------------------------------------*
        | Observações/Comentários                                                            |
        *--------*----------------------*----------------------------------------------------*
        | Versao | Autor                | Descrição                                          |
        *--------+----------------------+----------------------------------------------------*
        |   01   | Luís Gustavo         | Desenvolvimento                                    |
        |   02   | Luís Gustavo         | Mudança de workflow para envio de e-mail.          |
        *--------*----------------------*----------------------------------------------------*
        Chamada do Ponto de Entrada mt130wf, após gravação da cotação na tabela SC8         */
        aUsers   := AllUsers()
        nPos     := aScan(aUsers,{ |x| UPPER(Alltrim(x[1][2]))  = UPPER(Alltrim(cUsername))})
        cCodUser := aUsers[nPos][1][1]

        For nX := 1 to Len(PARAMIXB)
            If Valtype(ParamIxb[nX]) $ 'C'
               DbSelectArea("SC8")
               DbSetOrder(1)
               DbSeek(xFilial("SC8")+PARAMIXB[nX],.t.)
               If Found()
                  cNumCot := PARAMIXB[nX]
                  While !Eof() .and. SC8->C8_NUM == cNumCot
                        DbSelectArea("SY1")
                        DbSetOrder(3)
                        DbSeek(xFilial("SY1")+cCodUser,.t.)
                        If Found()
                           cRemete    := SY1->Y1_EMAIL
                           cComprador := SY1->Y1_NOME
                        Else
                           cRemete    := ""
                           cComprador := ""
                        Endif
                        DbSelectArea("SA2")
                        DbSetOrder(1)
                        DbSeek(xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA,.t.)
                        If Found()
                           cFornece := Alltrim(SA2->A2_NOME)+" ("+SA2->A2_COD+"/"+SA2->A2_LOJA+")"
                           cCodFor  := SA2->A2_COD
                           cForEMail:= SA2->A2_EMAIL
                        Else
                           cFornece := ""
                           cCodFor  := ""
                           cForEMail:= ""
                        Endif
                        _nItem    := 0
                        aCotacao := {}
                        While !Eof() .and. SC8->C8_NUM == cNumCot .and. SC8->C8_FORNECE == SA2->A2_COD .and. SC8->C8_LOJA == SA2->A2_LOJA
                              _nItem := _nItem + 1
                              DbSelectArea("SB1")
                              DbSetOrder(1)
                              DbSeek(xFilial("SB1")+SC8->C8_PRODUTO,.t.)   
                              cNomeProd := SubStr(Posicione("SA5", 2, xFilial("SA5")+SC8->C8_PRODUTO+SC8->C8_FORNECE+SC8->C8_LOJA, "A5_NOMPROD"), 1, 30)
                              if empty(alltrim(cNomeProd))
                                 cNomeProd := SubStr(Posicione("SB1", 1, xFilial("SB1")+SC8->C8_PRODUTO, "B1_DESC"), 1, 30)
                              endif 
                              aadd(aCotacao,{ STRZERO(_nItem,3), SC8->C8_PRODUTO, cNomeProd, Transform(SC8->C8_QUANT,"@E 99,999.9999"), SB1->B1_UM } )
                              DbSelectArea("SC8")
                              DbSkip()
                        Enddo
                        fMonHtml(cFornece, aCotacao, cNumCot, cComprador, cRemete, cForEMail)
                        DbSelectArea("SC8")
                  Enddo
               Endif
            Endif
        Next     
        U_VoltaArea(aArea)
        If !empty(cAlias)
           dbselectarea(cAlias)
        endif
     Else
        // Para o protheus 11 use o ponto de entrada MT130WF
        // Ponto de entrada chamado apos a geracao do cotacao para
        // enviar um wf aos fornecedores
        If SUPERGETMV("CT_ATIVACT", .F. , .F.)
           If lParamIXB
			cParamIXB := ParamIXB[1]
           Else
			cParamIXB := c150WFNum
           Endif
           u_CHRTCT02( lParamIXB, cParamIXB )
        Endif
        U_VoltaArea(aArea)
     Endif
     
Return

/*-----------------------------------------------------------------------------------*
| Projeto ..: Siga Workflow - Versão AP7                                             |
| Módulo ...: Processo de Cotação de Preços de Produtos com os fornecedores.         |
| Programa .: Inicio do processo de envio de e-mails.                                |
*-----------------------------------------------------------------------------------*/
Static Function fMonHtml(cFornece, aCotacao, cNumCot, cComprador, cRemete, cForEMail)
       Local cSerNew := GETMV("MV_RELSERV")            //SERVIDOR SMTP
       Local cAccNew := GETMV("MV_XRELACN")            //GETMV("MV_RELACNT")            //CONTA DE EMAIL
       Local cEnvNew := GETMV("MV_XRELACN")            //GETMV("MV_RELACNT")            //EMAIL
       //Local cPasNew := GETMV("MV_RELPSW")            //SENHA DA CONTA
       Local cPasNew := GETMV("MV_XRELPSW")             //SENHA DA CONTA luis@brasilux.com.br
       Local cSubNew := Iif(Empty(cForEMail),"Solicitação de Cotação - Fornecedor sem e-mail","Solicitação de Cotação") 
       Local cTo     := Iif(GetMv("MV_COTMAIL")=="S",cRemete,Iif(Empty(cForEMail),cRemete,cForEMail))
       Local cHtml   := ""
       Local lEnviado:= .f.
       Local nI
       
       cHtml += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">'
       cHtml += '<HTML>'
       cHtml += '    <HEAD>'
       cHtml += '        <META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=windows-1252">'
       cHtml += '        <TITLE>'
       cHtml += '        </TITLE>'
       cHtml += '        <META NAME="GENERATOR" CONTENT="OpenOffice.org 1.0.1  (Win32)">'
       cHtml += '        <META NAME="CREATED" CONTENT="20030320;14010383">'
       cHtml += '        <META NAME="CHANGED" CONTENT="20030321;9500805">'
       cHtml += '    </HEAD>'
       cHtml += '    <BODY LANG="pt-BR" BGCOLOR="#FFFFDE">'
       cHtml += '        <P ALIGN=CENTER>'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=5>'
       cHtml += '                        <B>Solicita&ccedil;&atilde;o de Cota&ccedil;&atilde;o - '+cNumCot+'</B>'
       cHtml += '                    </FONT>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P>'
       cHtml += '            <BR><BR>'
       cHtml += '        </P>'
       cHtml += '        <P>'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <B>Prezados Srs.</B>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P>'
       cHtml += '            <FONT COLOR="#ff0000">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <I><B>'+cFornece+'</B></I>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-bottom: 0cm">'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=2>'
       cHtml += '                        <B>Solicitamos de V Sas. cota&ccedil;&atilde;o de pre&ccedil;os, prazo de entrega e condi&ccedil;&atilde;o de pagamento para os produtos discriminados abaixo.</B>'
       cHtml += '                    </FONT>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-top: 0cm">'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=2>'
       cHtml += '                        <B>Por favor queira referenciar o numero desta cota&ccedil;&atilde;o para quaisquer troca de informa&ccedil;&otilde;es.</B>'
       cHtml += '                    </FONT>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <TABLE WIDTH=658 BORDER=1 CELLPADDING=2 CELLSPACING=3>'
       cHtml += '            <COL WIDTH=39>'
       cHtml += '            <COL WIDTH=417>'
       cHtml += '            <COL WIDTH=119>'
       cHtml += '            <COL WIDTH=50>'
       cHtml += '            <TR>'
       cHtml += '                <TD WIDTH=39 BGCOLOR="#99ccff">'
       cHtml += '                    <P ALIGN=CENTER><FONT FACE="Verdana"><FONT SIZE=2><B>Item</B></FONT></FONT></P>'
       cHtml += '                </TD>'
       cHtml += '                <TD WIDTH=417 BGCOLOR="#99ccff">'
       cHtml += '                    <P ALIGN=CENTER><FONT FACE="Verdana"><FONT SIZE=2><B>Descri&ccedil;&atilde;o</B></FONT></FONT></P>'
       cHtml += '                </TD>'
       cHtml += '                <TD WIDTH=119 BGCOLOR="#99ccff">'
       cHtml += '                    <P ALIGN=CENTER><FONT FACE="Verdana"><FONT SIZE=2><B>Quantidade</B></FONT></FONT></P>'
       cHtml += '                </TD>'
       cHtml += '                <TD WIDTH=50 BGCOLOR="#99ccff">'
       cHtml += '                    <P ALIGN=CENTER><FONT FACE="Verdana"><FONT SIZE=2><B>Unid.</B></FONT></FONT></P>'
       cHtml += '                </TD>'
       cHtml += '            </TR>'
       cHtml += '        </TABLE>'
       cHtml += '        <TABLE WIDTH=658 BORDER=1 CELLPADDING=2 CELLSPACING=3>'
       cHtml += '            <COL WIDTH=38>'
       cHtml += '            <COL WIDTH=418>'
       cHtml += '            <COL WIDTH=118>'
       cHtml += '            <COL WIDTH=51>'
       For nI := 1 to Len(aCotacao)
           cHtml += '            <TR>'
           cHtml += '                <TD WIDTH=38>'
           cHtml += '                    <P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>'+aCotacao[nI][1]+'</FONT></FONT></P>'
           cHtml += '                </TD>'
           cHtml += '                <TD WIDTH=418>'
           cHtml += '                    <P><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>'+aCotacao[nI][2]+' - '+aCotacao[nI][3]+'</FONT></FONT></P>'
           cHtml += '                </TD>'
           cHtml += '                <TD WIDTH=118>'
           cHtml += '                    <P ALIGN=RIGHT><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>'+aCotacao[nI][4]+'</FONT></FONT></P>'
           cHtml += '                </TD>'
           cHtml += '                <TD WIDTH=51>'
           cHtml += '                    <P ALIGN=CENTER><FONT FACE="Verdana, sans-serif"><FONT SIZE=2>'+aCotacao[nI][5]+'</FONT></FONT></P>'
           cHtml += '                </TD>'
           cHtml += '            </TR>'
       Next
       cHtml += '        </TABLE>'
       cHtml += '        <P STYLE="margin-bottom: 0cm"><BR>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-bottom: 0cm"><BR>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-bottom: 0cm">'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=2>'
       cHtml += '                        <B>Atenciosamente,</B>'
       cHtml += '                    </FONT>'
       cHtml += '                 </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-bottom: 0cm">'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=2>'
       cHtml += '                        <B>'+cComprador+'</B>'
       cHtml += '                    </FONT>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-top: 0cm">'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=2>'
       cHtml += '                        <B>'+cRemete+'</B>'
       cHtml += '                    </FONT>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-bottom: 0cm">'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=2>'
       cHtml += '                        <B>'+SM0->M0_NOMECOM 
       cHtml += '                            <BR>'+SM0->M0_ENDENT+'. '
       cHtml += '                            <BR>MATAO SP'
       cHtml += '                            <BR>Fone: (16) 3383 &ndash; 7000'
       cHtml += '                        </B>'
       cHtml += '                    </FONT>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '        <P STYLE="margin-top: 0cm">'
       cHtml += '            <FONT COLOR="#008080">'
       cHtml += '                <FONT FACE="Verdana, sans-serif">'
       cHtml += '                    <FONT SIZE=2>'
       cHtml += '                        <B>Fax: 0800-556002'
       cHtml += '                            <BR>'+iif(cNumemp = "01100101",'www.leiriahotel.com.br','www.brasilux.com.br')
       cHtml += '                        </B>'
       cHtml += '                    </FONT>'
       cHtml += '                </FONT>'
       cHtml += '            </FONT>'
       cHtml += '        </P>'
       cHtml += '    </BODY>'
       cHtml += '</HTML>'

       CONNECT SMTP SERVER cSerNew ACCOUNT cAccNew PASSWORD cPasNew Result lConectou
               lResult := MailAuth(cAccNew, cPasNew) //Autenticação do servidor de envio
               If lResult
                  SEND MAIL FROM cEnvNew;
                         TO cTo;
                         BCC cRemete;
                         SUBJECT cSubNew;
                         BODY cHtml;
                         RESULT lEnviado
               Else
                  cMsg := ""
                  GET MAIL ERROR cMsg                  
                  MsgBox(cMsg)
               Endif
               If !lEnviado
                  cMensag := "E-mail não foi enviado..."
                  GET MAIL ERROR cMenNew
                      MsgBox(cMensag+' - '+cMenNew, "Erro...", "STOP")
               Endif
       DISCONNECT SMTP SERVER Result lDisConectou
Return