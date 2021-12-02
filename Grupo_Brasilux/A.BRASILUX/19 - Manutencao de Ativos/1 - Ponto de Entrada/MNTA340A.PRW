#Include 'Protheus.ch'

/*/{Protheus.doc} MNTA340A
//TODO Retorna o código do produto que deverá ser gerada a solicitação de compra e armazém.
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
@author 
@since   /  /    
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MNTA340A()
     Local cTerceiro := ""
     Local oDlg, oList
     Local aProdutos := {}
     Local nList     := 1
     u_zcfga01( 'MNTA340A' ) //LGS#2021201 - Gravação de log de utilização da rotina
     If alltrim(FWGrpCompany()) <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        cTerceiro := GetMv("MV_PRODTER") //Para incluir mais de um Terceiro no parâmetro, dividir ambos com barra ( / ).
        DEFINE MSDIALOG oDlg TITLE "Selecione o Insumo" From 3,0 TO 150,320 COLOR CLR_BLACK,CLR_WHITE PIXEL
               aProdutos := NGProdMNT(cTerceiro)

               oList:= tListBox():New(10,10,{|u|if(Pcount()>0,nList:=u,nList)} ,aProdutos,100,100,,oDlg,,,,.T.)
               oList:Align := CONTROL_ALIGN_ALLCLIENT
        Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()}) Centered
     Endif
Return aProdutos[nList]
