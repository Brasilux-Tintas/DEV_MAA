#include "TOTVS.CH"

/*/{Protheus.doc} A010TOK
//Função de Validação para inclusão ou alteração do Produto.
//Unificação do fonte Brasilux x Tecpolpa - tratamento pela variável da empresa
@author gustavosouza
@since 19/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function A010TOK()
     Local _lRet  := .T.
     Local _aArea := GetArea()
     
     //LOCALIZAÇÃO : Function A010TudoOK - Função de Validação para inclusão ou alteração do Produto.
     //EM QUE PONTO: No início das validações após a confirmação da inclusão ou alteração, antes da gravação do Produto;
     //              deve ser utilizado para validações adicionais para a INCLUSÃO ou ALTERAÇÃO do Produto.
     // CHAMADO 001901 - PROIBIR A INCLUSÃO DE PRODUTOS DO TIPO MP SEM O PREENCHIMENTO DO CAMPO B1_UPRC
     
     If FWCodEmp() <> '11'
        //If (M->B1_TIPO == "MP") .and. (M->B1_UPRC <= 0)	
        //   MsgBox("Preencha o campo Preço para Tabela.", "Atenção", "STOP")
        //   _LRET :=.F.
        //Endif
        If _lRet
            _lRet := VldProdCust()
        Endif    
     Else
        /*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
        ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
        ±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
        ±±?Programa  =A010TOK  ?Autor  =Dyego  - Chaus      ? Data =  30/03/2016  ?±±
        ±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕp±±
        ±±?Desc.     =Ponto de entrada localizado na confirmacao do cadastro de   ?±±
        ±±?          =produto. ROtina MATA010 - Cadastro de produto               ?±±
        ±±?          =Objetivos:` 												  ?±±
        ±±?          =        1) Gravar a tolerancia de entrada de mercadoria.    ?±±
        ±±?          = 		  2) Validar se o produto e obrigatorio Item Contabil ?±±
        ±±?          = 		  3) Valida o segmento Cliente nos produtos PA/TA  	  ?±±
        ±±?          = 		  4) Valida existencia do item contabil e se o mesmo   ±±
        ±±?          = 			  e sintetico    		 					      ?±±
        ±±?          = 		  5) Valida se o peso bruto e liquido foi preenchdo   ?±±
        ±±?          = 			  quando prodito é PA ou TA				  	      ?±±
        ±±?          = 															  ?±±
        ±±?          = 							                                  ?±±
        ±±?          = 															  ?±±
        ±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕp±±*/
        GrvTolera()  //Grava a tolerancia

         //Cleber(09/09/2020) ->Constantemente usuários acionam o TI porque pede item contábil e não sabem a razão, consultado o Fernando (Contador) e ele 
         //disse que não utiliza item contábil. Como não está sendo usado e desconhecem a utilização estou desabilitando a obrigatoriedade do item contábil
        _lRet := .t. // ValItemCtba()   //Valida se foi preenchido Item  Contábil quando prouto doi PA ou TA  

        If _lRet
           _lRet := ValEGrp()
        EndIf
        If _lRet .and. ( M->B1_TIPO = 'TA' .or. M->B1_TIPO = 'TM' .or. M->B1_TIPO = 'ET' .or. M->B1_TIPO = 'TM' )
           _lRet := ValExCli()   //Valida se existe cliente 		 
        EndIf
         //Cleber(09/09/2020) ->Constantemente usuários acionam o TI porque pede item contábil e não sabem a razão, consultado o Fernando (Contador) e ele 
         //disse que não utiliza item contábil. Como não está sendo usado e desconhecem a utilização estou desabilitando a obrigatoriedade do item contábil
        /*
        If _lRet  .and. ( M->B1_TIPO = "PA" .OR. M->B1_TIPO = 'TA' )  // Valida se o Item contábil

           _lRet :=  ValCadItem()
        EndIf
        */
        If _lRet .and. ( M->B1_TIPO = "PA" .OR. M->B1_TIPO = 'TA' )  // Valida preenchimento peso liquido e Bruto
           _lRet := ValdPeso()
        EndIf

        //Chama rotina Chaus  para validar se o usuario preencheu os campos obrigatorios
        If _lRet .and. SUPERGETMV( "CF_ATIVARP", .F. , .F. )
           // alert('A010TOK')
           _lRet := u_CHROTP01()
        Endif
        RestArea( _aArea )
     Endif 

Return( _lRet ) 

Static Function GrvTolera()
       Local _proxNum := " "
       DbSelectArea("AIC")
       AIC->( dbSetOrder(2))
       If !AIC->( dbSeek( xFilial("AIC")+ SPACE( LEN( AIC->AIC_FORNEC ) ) +	SPACE( LEN( AIC->AIC_LOJA ) ) + M->B1_COD +  M->B1_GRUPO ) )    // AIC_FILIAL, AIC_FORNEC, AIC_LOJA, AIC_PRODUT, AIC_GRUPO, R_E_C_N_O_, D_E_L_E_T_
          _proxNum := GetSx8Num( "AIC", "AIC_CODIGO" ) 
          //para corrigir erro do proximo numero
          AIC->( dbSetOrder(1) )      
          Dbgotop()
          While AIC->( dbSeek(xFilial("AIC")+  _proxNum ) )    // AIC_FILIAL, AIC_CODIGO
                _proxNum := GetSx8Num("AIC","AIC_CODIGO") 
          EndDo
          Reclock( "AIC", .T. ) 
             AIC->AIC_FILIAL := xFilial("AIC")
             AIC->AIC_CODIGO := _proxNum
             AIC->AIC_PRODUT := M->B1_COD			//Pedido Liberado por outro usuario 
             AIC->AIC_GRUPO  := M->B1_GRUPO	  
             AIC->AIC_PPRECO := 0
          AIC->( MsUnlock() )
          DbCloseArea()   
       Endif
Return Nil

Static Function ValItemCtba()
       Local _Ret := .T.
       If ( M->B1_TIPO = "PA" .or. M->B1_TIPO = "TA" ) .and. ;  //Produto PA
          EMPTY( M->B1_ITEMCC )                                 //Nao foi preenchdio item contábil
          _Ret := .f.
          Aviso( "A010TOK-TecPolpa","Item contábil é obrigatório", { "OK" } )	
       EndIf

//*Cleber(09/09/2020) ->Constantemente usuários acionam o TI porque pede item contábil e não sabem a razão, consultado o Fernando (Contador) e ele 
//disse que não utiliza item contábil. Como não está sendo usado e desconhecem a utilização estou desabilitando a obrigatoriedade do item contábil
_Ret := .t. //*Cleber(09/09/20) -> vide obs acima
Return( _Ret )

Static function ValEGrp()
       Local _lRet := .T.

       SBM->(DBSelectArea("SBM"))
       SBM->(DBSetOrder(1))
       SBM->(DBSeek(xFilial("SBM")+M->B1_GRUPO),.t.)
       If !(SBM->(Found()))
          _lRet := .F.
          Aviso( "A010TOK-TecPolpa", "Grupo de Produto Inexistente", { "OK" } )
       EndIf
Return( _lRet )

Static Function ValExCli() 
       Local _Ret        := .T.
       Local _CCliRed    := SubSTR( M->B1_COD, 2, 3 ) 
       Local _NReg       := 0
       Local _aLastQuery := {}
       Local _cLastQuery := ""

       BeginSql alias 'SA1TMP'
                COLUMN nNumReg AS Numeric(5,2)	
                SELECT COUNT(*)  AS nNumReg
                FROM %table:SA1% SA1
                WHERE SA1.%notDel%  
                  AND SA1.A1_FILIAL = %xfilial:SA1%
                  AND SA1.A1_XCODENG =  %exp:_CCliRed%
       EndSQL
       _aLastQuery := GetLastQuery()	
       _cLastQuery := _aLastQuery[ 2 ]
       If !( SA1TMP->( EOF() ) )
          _NReg := SA1TMP->nNumReg
       EndIf
       SA1TMP->( DbCloseArea() )
       If _NReg = 0  //Não tem cliente cadastrado no codigo de engenharia
          _Ret := .F.
          Aviso( "A010TOK-TecPolpa", "Não existe o código " + _CCliRed + "  associado a um cliente da TecPolpa !. Não é possível confirmar o cadastro "+CHR(10)+". Cadastro do produto não realizado !!" + CHR( 10 ), { "OK" } )
       EndIf
Return( _Ret )

Static Function ValCadItem()
       Local _Ret := .T.
       CTD->(DBSelectArea("CTD"))
       CTD->(DBSetOrder(1))
       CTD->(DBSeek( xFilial("CTD") + M->B1_ITEMCC ), .T. )

       If CTD->(found()) .and. CTD->CTD_CLASSE = "1"   //Sintetica
          _Ret := .F.
          Aviso( "A010TOK-TECPOLPA", " O Item contábil do produto e um item contábil sintético. Favor informar um item contabil analítico " + CHR( 10 ) + ;
                                     " em caso de dúvida favor entrar em contato com setor contábil para fazer o cadastro o Item Contábil", { "OK" } )
       EndIf

       If _Ret .and. !( CTD->( Found() ) ) .and. M->B1_XCETAPA >= '4'  //.and. CTD->CTD_CLASE = "1"   //Sintetica
          _Ret := .F.
          Aviso( "A010TOK-TECPOLPA", "O Item contábil do produto não esta cadastrado " + CHR(10) + ;
                                     " Não e possível confirmar o cadastro do produto" + ;
                                     "Procure setor contábil para fazer o cadastro o Item Contábil", { "OK" } )
       EndIf
Return( _Ret )

Static Function ValdPeso()
       Local _Ret :=.T.

       If M->B1_PESBRU = 0 .or. M->B1_PESO = 0
          _Ret := .F.
          Aviso( "A010TOK-TECPOLPA", " No produto " + AllTrim(M->B1_COD) + "-" + Alltrim(M->B1_DESC) + " e do tipo " + Alltrim(M->B1_TIPO) + ;
                                     " necessario informar o peso Bruto e peso liquido na aba MRP/Suprimentos." + CHR(10) + ;
                                     " Favor preencher os campos ", { "OK" } )
       EndIf
Return(_Ret)


Static Function VldProdCust()

Local aCmpCusto := {}
Local aDCmpCusto := {}
Local cMens := ""
Local nCnt := 0
Local lRet := .T.

// produto de custeio     
If U_IsProdCusto(M->B1_COD,.T.)
   aCmpCusto := {"B1_UPRCCMP","B1_UPRC","B1_PESBRU","B1_PESO","B1_ESP05","B1_RELCAT1"}
   For nCnt:=1 To Len(aCmpCusto)
      aAdd(aDCmpCusto,RetTitle(aCmpCusto[nCnt]))
   Next   
   For nCnt:=1 To Len(aCmpCusto)
      If !Empty(&("M->"+(aCmpCusto[nCnt])))
         cMens := aCmpCusto[nCnt]+" - "+aDCmpCusto[nCnt]+CRLF
         lRet := .F.
      Endif   
   Next   
   If !lRet
      //For nCnt:=1 To Len(aCmpCusto)
      //   cMens := cMens+aCmpCusto[nCnt]+" - "+aDCmpCusto[nCnt]+CRLF
      //Next   
      cMens := "Campos não devem ser preenchidos para Produtos de Custeio. Verificar o campo a seguir: "+CRLF+cMens
      Help("",1,"Campos preenchidos",,cMens,1,0)
   Endif
   If lRet   
      If !(M->B1_PESOESP == 1)
         lRet := .F.
         Help("",1,"Peso Específico",,"Peso Específico deve ser igual a 1",1,0)
      Endif
   Endif      
Endif

Return(lRet)
