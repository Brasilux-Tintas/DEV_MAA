#include "TOTVS.CH"

User Function BRSACR07()
     Local cStartPath := GetSrvProfString("Startpath","")
	 Local lAchouCli := .f.
     Private cAcesso  := Repl(" ",10)
     Private nMaxCol  := 2330

	 dbselectarea("SA1")
	 dbsetorder(1)
	 dbseek(xFilial("SA1")+SZQ->ZQ_CLIENTE)
	 lAchouCli := found()
     //Monta objeto para impressão
     oPrint := TMSPrinter():New("Ficha de Atendimento")
     oPrint:SetPortrait()
     oPrint:Setup()
  
     oPrint:StartPage()

     oFont1 := TFont():New('Courier New', , -10, .T.)
     oFont2 := TFont():New('Courier New', , -14, .T., .T.)
     oFont3 := TFont():New('Courier New', , -10, .T., .T.)
     oPrint:SayBitmap( 0020, 0020, cStartPath+"logo-bras.jpg", 474, 112 )
     oPrint:Line(00140, 0010, 0140, nMaxCol )
     
     oPrint:Say(0100, 0500, Alltrim( SM0->M0_FILIAL ), oFont1, 100, CLR_BLACK )
     oPrint:Say(0050, 1000, "FICHA DE ATENDIMENTO"   , oFont2, 100, CLR_BLACK )
     oPrint:Say(0100, 2000, "Data: "+DTOC( MsDate() ), oFont1, 100, CLR_BLACK )
     
     //1º Box
     oPrint:Box(0150, 0010, 600, nMaxCol )
            //1º Linha
            oPrint:Say(0170, 0030, "Atendimento..:", oFont1, 100, CLR_BLACK )
            oBrush1 := TBrush():New( , CLR_YELLOW )
            oPrint:FillRect( {170, 345, 210, 470}, oBrush1 )
            oBrush1:End()
            oPrint:Say(0170, 0350, SZQ->ZQ_NUM   , oFont3, 100, CLR_BLACK )
            oPrint:Say(0170, 0620, "Abertura:", oFont1, 100, CLR_BLACK )
            oPrint:Say(0170, 0820, DTOC(SZQ->ZQ_DATA)+'  -  '+SZQ->ZQ_HINI, oFont1, 100, CLR_BLACK )
            oPrint:Say(0170, 1170, "Atendente:", oFont1, 100, CLR_BLACK )
            oPrint:Say(0170, 1390, Upper(SZQ->ZQ_ATENDEN), oFont1, 100, CLR_BLACK )
            //2º Linha
            oPrint:Say(0220, 0030, "Cliente......:", oFont1, 100, CLR_BLACK )
            oPrint:Say(0220, 0350, SZQ->ZQ_CLIENTE+' - '+iif(lAchouCli,SA1->A1_NOME,""), oFont3, 100, CLR_BLACK )
            oPrint:Say(0220, 1170, "Contato:"  , oFont1, 100, CLR_BLACK )
            oPrint:Say(0220, 1390, Upper(SZQ->ZQ_CONTATO), oFont1, 100, CLR_BLACK )
            //3º Linha
            oPrint:Say(0270, 0030, "Telefone.....:", oFont1, 100, CLR_BLACK )
            oPrint:Say(0270, 0350, iif(lAchouCli,TRIM(SA1->A1_DDD)+'-'+TRIM(SA1->A1_TEL),""), oFont3, 100, CLR_BLACK )
            oPrint:Say(0270, 0620, "Tipo SAC:", oFont1, 100, CLR_BLACK )
            oPrint:Say(0270, 0820, Iif(SZQ->ZQ_TIPOSAC $ '1', 'Reclamação', 'Sugestão'), oFont3, 100, CLR_BLACK )

            //4º Linha
            oPrint:Say(0320, 0030, "Represent....:", oFont1, 100, CLR_BLACK )
            oPrint:Say(0320, 0250, iif(lAchouCli,SA1->A1_VEND,"")+' - '+Posicione("SA3", 1, xFilial("SA3")+iif(lAchouCli,SA1->A1_VEND,""), "A3_NOME"), oFont3, 100, CLR_BLACK )
     
     // Visualiza a impressão
     oPrint:EndPage()     
     oPrint:Preview() 

     DbSelectArea("SZQ")
Return