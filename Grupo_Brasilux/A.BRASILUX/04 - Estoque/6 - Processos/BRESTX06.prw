#include 'tbiconn.ch'
#include 'error.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include "rwmake.ch"                                         
#include "topconn.ch"

/*
Movim. Estoque Guarulhos
*/
User Function BRESTX06()
     Local aSays:={}, aButtons := {}
     Local cMens1, nOpca
     //If (!u_VldAcesso(funname()) .and. !FWIsAdmin() )
     If !u_VldAcesso(funname())
        /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        //MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert") 
        MessageBox( "Acesso não autorizado!---->" + FunName(), "Atenção", 48 )
        Return 
     Endif 
  
     If !(alltrim(cNumEmp) == "01010101") .and. !(alltrim(cNumEmp) == "01010104")
        /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        cMens1 := "Acesso deverá ser feito na empresa Brasilux/Matriz ou Resina!"
        //Conout(cMens1)
        //FwLogMSG( "INFO", , 'SIGAEST', FunName(), '', '01', cMens1, 0 )
        MessageBox( cMens1, "Atenção!", 48 )
        return
     Endif
     //------------ LGS#20231023 ----- RETIRADA DA GRAVAÇÃO DO LOG DE ROTINA PARA MELHORA DE PERFORMANCE.
     //u_zcfga01( 'BRESTX06' ) //LGS#2021118 - Gravação de log de utilização da rotina
     nOpca	  := 0
     AADD(aSays,"Este programa ira atualizar o estoque do Deposito Fechado")
     AADD(aSays,"com as movimentacoes de entrada e saida do periodo.")
     cCadastro:=OemToAnsi("Estoq Dep. Fechado")

     AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()}})
     AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

     FormBatch( cCadastro, aSays, aButtons )
     if nOpca = 1
        Processa({|| U_ESTX06(1)})
     endif 
Return 

// ESTX06 = 1 - (Etapa de selecão de Filial )
// ESTX06 = 2 - (Etapa de processamento e execução / usado para agendamento de schedule )
User Function ESTX06(_xOpcao )
     Local _cFilial, i, nOpcao
     DEFAULT _xOpcao := 2         

     If ValType( _xOpcao ) <> "N"
        _xOpcao := 2
     Endif
     nOpcao := _xOpcao
     If nOpcao == 1
        _cFilial := Alltrim( FWCodFil() )
        PESTX06(nOpcao,_cFilial)
     Else 
        For i := 1 to Iif( nOpcao == 1, 1, 2 )
            If i == 1
               _cFilial := "010101"
            Else
               _cFilial := "010104"
            Endif
            PESTX06( nOpcao, _cFilial )
        Next 
     Endif 
Return(.t.)

Static Function PESTX06(_xOpcao,_cFilial)
       Local ExpA1    := {}
       Local ExpN2    := 3
       Local cProd    := ""
       Local cUnidade := ""
       Local cArmazem := ""
       Local cQuery, cTPMovimento, nCont, lSucesso, cAux /* cAuxMail*/
       Local cArqBloq, aBloq
       Local cEstNeg, cLocMatriz, _cDoc, cNumSeri, _cLocOri, _cLocDest, cCmpCgc, lTransf, cMens, _cDescri
       //Local aCampos  := {}
       Local cPara    := ( Alltrim( GetMV('ZP_PAR0130') ) )
       Local _aAuto   := {}
       Local _aItem   := {}
       Local _cAuxMens
       PRIVATE lMsErroAuto := .F.          
       If _xOpcao == 2
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //| Abertura do ambiente                                         |
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           If _cFilial == Nil
              _cFilial := ""
           Endif 
           If Empty( _cFilial )
              _cFilial := "010101"
           Endif 

           RESET ENVIRONMENT
           RpcSetType(3) //seta tipo de consumo de licença
           PREPARE ENVIRONMENT EMPRESA "01" FILIAL _cFilial MODULO "EST" TABLES "SD3","SB1","SB2"

           /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
           //ConOut(Repl("-",80))
           //ConOut(PadC("****************************",80))
           //ConOut(PadC("Movimentação Prods Depositos",80))
           //ConOut(PadC("****************************",80))
           //ConOut("Inicio: "+Time())
           _cAuxMens := Repl( "-", 80 )                + CHR( 13 ) + CHR( 10 )
           _cAuxMens += "****************************" + CHR( 13 ) + CHR( 10 )
           _cAuxMens += "Movimentação Prods Depositos" + CHR( 13 ) + CHR( 10 )
           _cAuxMens += "****************************" + CHR( 13 ) + CHR( 10 )
           _cAuxMens += "Inicio: " + Time() + CHR( 13 ) + CHR( 10 )
           FwLogMSG( "INFO", , 'SIGAEST', FunName(), '', '01', _cAuxMens, 0 )

           If ( _xOpcao == 2 ) .and. ( Alltrim( FWCodFil() ) == "010104" )
              U_EnvMail("Funcionando TRF dep Resina!","Processamento ZZY para a Resina via Schedule esta funcionando!",cPara,'','') //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
           Endif 
        Endif

        cArqBloq := "BRESTX06" + Substr( Alltrim( cNumEmp ), 3, 6 ) //Cleber (13/02/20)  -> Reajuste da função  BloqProg 
        aBloq    := U_BloqProg( cArqBloq ) //Retorna matriz com primeira coluna verdadeiro ou falso se tá bloqueado e segunda coluna com nome de quem está bloqueando ou nome da área de trabalho gerada

        If aBloq[1,1] //Já estava bloqueado?
           cAux := "O programa já está sendo usado por: " + aBloq[1,2]
           If _xOpcao == 1
              Messagebox(cAux,"Atenção!",48) 		
           Else
              FwLogMSG( "WARN", , 'SIGAEST', funname(), '', '01', cAux, 0 )
           Endif 
           Return
        Endif
       
     /********************************************************************************************************************************/
     cQuery := "SELECT FILIAL = ZZY_FILIAL +'  p/  '+ (CASE WHEN ZZY_TAB = 'SD1' THEN D1_FILIAL ELSE D2_FILIAL END ), "+;
               "DIA = CASE WHEN ZZY_TAB = 'SD1' THEN convert(varchar, cast(D1_DTDIGIT as smalldatetime),103) ELSE convert(varchar, cast(D2_EMISSAO as smalldatetime),103) END, "+;
               "LOC = CASE WHEN ZZY_TAB = 'SD1' THEN D1_LOCAL+' '+(CASE WHEN D1_LOCAL LIKE 'A%' OR D1_LOCAL LIKE 'G%' THEN '' ELSE '**' END) 		ELSE D2_LOCAL+' '+(CASE WHEN D2_LOCAL LIKE 'A%' OR D2_LOCAL LIKE 'G%' THEN '' ELSE '**' END) END,  "+;
               "ZZY_TIPO AS TIPO, ZZY.R_E_C_N_O_ AS REG, "+;
               "DOC = CASE WHEN ZZY_TAB = 'SD1' THEN D1_DOC ELSE D2_DOC END, "+;
               "SERIE = CASE WHEN ZZY_TAB = 'SD1' THEN D1_SERIE ELSE D2_SERIE END, "+;
               "CUSTO = CASE WHEN ZZY_TAB = 'SD1' THEN D1_CUSTO ELSE CASE WHEN D2_CUSTO1 > 0 THEN D2_CUSTO1 ELSE D2_TOTAL END END, "+;
               "NUMSEQ = CASE WHEN ZZY_TAB = 'SD1' THEN D1_NUMSEQ ELSE D2_NUMSEQ END, "+;
               "CODPRO = CASE WHEN ZZY_TAB = 'SD1' THEN D1_COD ELSE D2_COD END, "+;
               "QTDE = CASE WHEN ZZY_TAB = 'SD1' THEN D1_QUANT ELSE D2_QUANT END,"+;
               "CLIFOR = CASE WHEN ZZY_TAB = 'SD1' THEN D1_FORNECE ELSE D2_CLIENTE END,"+;
               "TABCLIFOR = CASE WHEN ZZY_TAB = 'SD1' THEN CASE WHEN D1_TIPO IN ('D','B') THEN 'SA1' ELSE 'SA2' END ELSE CASE WHEN D2_TIPO IN ('D','B') THEN 'SA2' ELSE 'SA1' END END, "+;
               "ZZY_TAB AS TABELA "+;
               "FROM "+RetSqlName("ZZY")+" ZZY WITH (NOLOCK) "+;
               "LEFT OUTER JOIN "+RetSqlName("SD1")+" SD1 WITH (NOLOCK) ON (ZZY_TAB = 'SD1') AND (SD1.R_E_C_N_O_ = ZZY_DOC) "+;
               "LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 WITH (NOLOCK) ON (ZZY_TAB = 'SD2') AND (SD2.R_E_C_N_O_ = ZZY_DOC) "+;
               "WHERE (ZZY.D_E_L_E_T_ <> '*') "+;
               "ORDER BY LOC, FILIAL, DIA, CODPRO"
               TCQuery cQuery NEW ALIAS "TCQ"

     nCont    := 0
     lSucesso := .t.

     _cDoc	:=  nextnumero("SD3",2,"D3_DOC",.t.) //GetSxENum("SD3","D3_DOC",1) //

     cEstNeg := GETMV("MV_ESTNEG")
     DbSelectArea("TCQ")
     DbGoTop()
     DO WHILE lSucesso .and. !eof()
        /*
        IF (TCQ->DIA <> DTOS(dDataBase))
           dbselectarea("TCQ")
           dbskip()
           loop
        ENDIF
        */

        lMSErroAuto := .F.
        lTransf     := .t. //Define se efetiva a transferência, caso falso apenas exclui o lcto de ZZY
        cCmpCgc     := TCQ->TABCLIFOR+"->A"+substr(TCQ->TABCLIFOR,3,1)+"_CGC"

        dbselectarea(TCQ->TABCLIFOR)
        dbsetorder(1)
        dbseek(xFilial(TCQ->TABCLIFOR)+TCQ->CLIFOR)
        If !found()     
           cMens := iif(TCQ->TABCLIFOR = "SA1","Cliente ","Fornecedor ")+TCQ->CLIFOR+" NÃO ENCONTRADO!"
           IF _xOpcao == 2
              /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
              //Conout(cMens)
              FwLogMSG( "ERROR", , 'SIGAEST', funname(), '', '01', cMens, 0 )
           Else
              /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
              //MsgBox(cMens, "Atenção!", "STOP")
              MessageBox( cMens, "Atenção!", 16 )
           Endif 
           dbselectarea("TCQ")
           dbskip()
           loop
        Endif

        If !( &(cCmpCgc) = "72770878") .OR. (( &(cCmpCgc) = "72770878") .AND. (ALLTRIM(TCQ->SERIE) == "4")) //.OR. (TCQ->TABELA = "SD2") //Movimentar somente lançamentos BRASILUX
           lTransf := .f.
        Endif
	
        IF lTransf .and. ( &(cCmpCgc) <> alltrim(SM0->M0_CGC))
           cMens := "FILIAL ERRADA!!"
           /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
           //Conout(cMens)
           FwLogMSG( "ERROR", , 'SIGAEST', funname(), '', '01', cMens, 0 )
           dbselectarea("TCQ")
           dbskip()
           loop
        Endif

        If lTransf
           dbSelectArea("SB1")
           dbSetOrder(1)
           dbSeek(xFilial("SB1")+TCQ->CODPRO)
           If !found()     
              cMens := "Produto "+TCQ->CODPRO+" NÃO ENCONTRADO!"
              If _xOpcao == 2
                 /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                 //Conout(cMens)
                 FwLogMSG( "ERROR", , 'SIGAEST', funname(), '', '01', cMens, 0 )
              Else
                 /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                 //MsgBox(cMens, "Atenção!", "STOP")
                 MessageBox( cMens, "Atenção!", 16 )
              Endif 
              dbselectarea("TCQ")
              dbskip()
              loop
           Endif
        Endif 
	
        If lTransf
           cProd    := SB1->B1_COD
           cUnidade := SB1->B1_UM
           _cDescri := SB1->B1_DESC
           cArmazem := TCQ->LOC
           cLocMatriz := iif(substr(cArmazem,1,1) $ "G_M_A","0"+SUBSTR(cArmazem,2,1),cArmazem)
           _cLocOri := IIF(TCQ->TIPO = "S",cArmazem,cLocMatriz)
           _cLocDest := IIF(TCQ->TIPO = "S",cLocMatriz,cArmazem)

           dbselectarea("SB2")
           dbsetorder(1)
           dbseek(xFilial("SB2")+TCQ->CODPRO+_cLocDest)
           If !found()
              CriaSb2(TCQ->CODPRO,_cLocDest)
           Endif  

           dbselectarea("SB2")
           dbsetorder(1)
           dbseek(xFilial("SB2")+TCQ->CODPRO+_cLocOri)
           If !found()
              CriaSb2(TCQ->CODPRO,_cLocOri)
              dbselectarea("SB2")
              dbseek(xFilial("SB2")+TCQ->CODPRO+_cLocOri)
           Endif  
        Endif

        If lTransf .AND. ((TCQ->TABELA = "SD1") .OR. ((TCQ->TABELA <> "SD1") .AND. (TCQ->TIPO = "S"))) .AND. (SB2->B2_QATU < TCQ->QTDE)
           dbselectarea("TCQ")
           dbskip()
           loop
        Endif

        begin transaction 
              If lTransf
                 If TCQ->TABELA = "SD1"  
                    //Cabecalho a Incluir	
                    _aAuto := {}  
                    _aItem := {}
                    aadd(_aAuto,{_cDoc,dDataBase})  	//Cabecalho
                    //Begin Transaction   	
                    cNumSeri := TCQ->TABELA+"->"+TCQ->DOC
                    //Itens a Incluir		
                    aadd(_aItem,cProd)  		//D3_COD
                    aadd(_aItem,_cDescri)     	//D3_DESCRI		
                    aadd(_aItem,cUnidade)  			//D3_UM
                    aadd(_aItem,_cLocOri)      	//D3_LOCAL
                    aadd(_aItem,"")				//D3_LOCALIZ
                    aadd(_aItem,cProd)  		//D3_COD
                    aadd(_aItem,_cDescri)     	//D3_DESCRI		
                    aadd(_aItem,cUnidade)  			//D3_UM
                    aadd(_aItem,_cLocDest)     	//D3_LOCAL
                    aadd(_aItem,"")				//D3_LOCALIZ
                    aadd(_aItem,cNumSeri)         //D3_NUMSERI
                    aadd(_aItem,"")				//D3_LOTECTL  
                    aadd(_aItem,"")         	//D3_NUMLOTE
                    aadd(_aItem,criavar('D3_DTVALID'))	//D3_DTVALID
                    aadd(_aItem,0)						//D3_POTENCI
                    aadd(_aItem,TCQ->QTDE) 				//D3_QUANT
                    aadd(_aItem,criavar("D3_QTSEGUM"))	//D3_QTSEGUM
                    aadd(_aItem,criavar("D3_ESTORNO"))  //D3_ESTORNO
                    aadd(_aItem,criavar("D3_NUMSEQ"))   //D3_NUMSEQ 
                    aadd(_aItem,"")						//D3_LOTECTL
                    aadd(_aItem,criavar("D3_DTVALID"))	//D3_DTVALID
                    aadd(_aItem,"")						//D3_ITEMGRD   	
                    //aadd(_aItem,criavar("D3_IDDCF"))	//D3_IDDCF
                    aadd(_aItem,criavar("D3_OBSERVA"))  //D3_OBSERVA  
                    aadd(_aAuto,_aItem)
                    PutMv( "MV_ESTNEG", "S" )
                    lMsErroAuto := .f.
                    dbselectarea("SD3")
                    MSExecAuto( { |x,y| mata261(x,y) }, _aAuto, 3 )
                    lSucesso := !lMsErroAuto
                    PutMv( "MV_ESTNEG", cEstNeg )
                    //End Transaction
                 Else
                    //Begin Transaction   	
                    cTPMovimento := iif(TCQ->TIPO = "S","520","120")
                    ExpA1 := {} 		
                    aadd(ExpA1,{"D3_FILIAL",xFilial("SD3"),})	
                    aadd(ExpA1,{"D3_DOC",TCQ->TIPO+"-"+TCQ->NUMSEQ,})	
                    aadd(ExpA1,{"D3_TM",cTPMovimento,})	
                    aadd(ExpA1,{"D3_COD",cProd,})	
                    aadd(ExpA1,{"D3_UM",cUnidade,})			
                    aadd(ExpA1,{"D3_LOCAL",cArmazem,})	
                    aadd(ExpA1,{"D3_QUANT",TCQ->QTDE,})	
                    aadd(ExpA1,{"D3_EMISSAO",dDataBase,})		        
                    aadd(ExpA1,{"D3_TIPO",SB1->B1_TIPO,})		        
                    //aadd(ExpA1,{"D3_CUSTO1",TCQ->CUSTO,})		      RETIRADO EM 14/01/21 - CONFORME REUNIÃO (TI BRASILUX - TOTVS - CONTABILIDADE) MOVIMENTAÇÕES NÃO SERÃO VALORIZADAS (120 / 520)
                    PutMv( "MV_ESTNEG", "S" )
                    lMsErroAuto := .f.
                    dbselectarea("SD3")
                    MSExecAuto({|x,y| mata240(x,y)},ExpA1,ExpN2)		
                    PutMv( "MV_ESTNEG", cEstNeg )
                    //End Transaction
                 Endif 
              Endif 
              If !lMsErroAuto
                 nCont++ //Contar quantos lctos foram feitos com sucesso
                 dbselectarea("ZZY")
                 dbgoto(TCQ->REG)
                 If !eof() .and. !bof()
                    RecLock("ZZY", .F.)
                       ZZY->( DbDelete() )
                    MsUnLock()
                 Endif
                 /*
                 cQuery := "UPDATE "+RetSqlName("ZZY")+" SET D_E_L_E_T_ = '*' WHERE R_E_C_N_O_ = "+ALLTRIM(STR(TCQ->REG))
                 TCSQLEXEC(cQuery)
                 */
              Else
                 //lSucesso := .f.
                 /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
                 //ConOut("Erro na inclusao!")
                 FwLogMSG( "ERROR", , 'SIGAEST', funname(), '', '01', "Erro na inclusao!", 0 )
                 cAux := ""
                 If _xOpcao == 1
                    cAux     := MostraErro()    
                 Endif
                 //cAuxMail := Alltrim( UsrRetMail("000000") )                 
                 //U_EnvMail( "Erro BRESTX06", "Erro ao tentar lançar no estoque registro " + Alltrim( Str( TCQ->REG ) ) + " da tabela ZZY" + chr(13) + chr(10) + cAux, cAuxMail, '', '' ) //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
                 U_EnvMail( "Erro BRESTX06", "Erro ao tentar lançar no estoque registro " + Alltrim( Str( TCQ->REG ) ) + " da tabela ZZY" + chr(13) + chr(10) + cAux, cPara, '', '' ) //para que seja enviado um arquivo em anexo o arquivo deve estar dentro da pasta protheus_data
              EndIf	
        End transaction 

        dbselectarea("TCQ")
        dbskip()
     Enddo
     dbSelectArea("TCQ")
     dbclosearea()

     PutMv( "MV_ESTNEG", cEstNeg )
     /*
     if nCont > 0 
        cQuery := "DELETE FROM "+RetSqlName("ZZY")+" WHERE D_E_L_E_T_ = '*'"
        TCSQLEXEC(cQuery)
        TcRefresh( RetSqlName("ZZY") ) 
     endif 
     */

     //dbselectarea(_cAreaBloq)
     //dbclosearea()
     //ferase(cArqBloq)
     //PutMV( "ZP_PAR0010", '' ) 
     DbSelectArea(aBloq[1,4]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DBRUnlock( aBloq[1,3]) //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     DbCloseArea() //Cleber (13/02/20)  -> Reajuste da função  BloqProg
     

     IF _xOpcao == 2
        /*** Substituido em 30/01/2020 por LUIS GUSTAVO, EM ATENDIMENTO A ATUALIZAÇÃO DE RELEASE PROTHEUS 12.1.25 ***/
        //ConOut("FIM Movimentação Prods Depositos"+Time())
        FwLogMSG( "INFO", , 'SIGAEST', funname(), '', '01', "FIM Movimentação Prods Depositos" + Time(), 0 )
        RESET ENVIRONMENT
     ENDIF 
Return Nil
//Para realizar o Estorno, poderá ser utilizado o mesmo ponto de entrada, porém com as seguinte configuração:
//- Alterar a linha: Local ExpN2 := 3   para:  Local ExpN2 := 5- Incluir as linhas:   aadd(ExpA1,{"D3_NUMSEQ","000074",})	
// Aqui deverá ser colocado o D3_NUMSEQ do registro que foi incluido e agora esta sendo estornado.   aadd(ExpA1,{"INDEX",3,})	                     
// Aqui deverá ser indicado o número do indice da tabela SD3 que será utilizado.Desta forma, o movimento será estornado.
