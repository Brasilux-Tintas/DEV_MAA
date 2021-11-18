#include "topconn.ch"

/*/{Protheus.doc} M310Filtro
description
@type function
@version  
@author gustavosouza
@since 22/09/2021
@return variant, return_description
Cleber(23/09/2021)->Adaptação para transf. entre Brasilux/Matriz e Resina
/*/

User Function M310Filtro()
Local _cRet,cQuery,_cFilOrig,cFornec,cLojafor,nCont,cCliente,cLojacli,cFildest,_cFilial

     u_zcfga01( 'M310FILTRO' ) //LGS#2021118 - Gravação de log de utilização da rotina
_cRet := "" 

     // Rotina criada pelo usuário: selecionará apenas os produtos PA001, PA007, PA009 e PA015
//     _cRet := " ( B1_COD IN ( '0102', 'RB 757110299' ) ) 

If alltrim(FWGrpCompany()) == '01' //Empresas que não são do grupo 11(Tecpolpa).

     IF SuperGetMV("MV_TRFVLDP", ,"1") = "2" //Utiliza amarração Prod. x Fornecedor
          //_cFilial := alltrim(FWCodFil())
          //Cleber(23/09/21)->Considerando que o ponto de entrada M310FILIAL está filtrando filial origem e destino através dos parametros MV_PAR04 e MV_PAR03, descobrindo a filial origem desta maneira
          cFornec := ""
          cLojafor := ""
          cCliente := ""
          cLojacli := ""
          _cFilial := alltrim(FWCodFil())

          If ExistBlock("M310FILIAL") .AND. !empty(ALLTRIM(MV_PAR03)) .and. !empty(ALLTRIM(MV_PAR04)) .and. ((ALLTRIM(MV_PAR04) ==  _cFilial) .or.(ALLTRIM(MV_PAR03) == _cFilial))
               //MsgAlert(_cFilial, "Filial")

                _cFilOrig := _cFilial //ALLTRIM(MV_PAR04)
                cFildest := iif(ALLTRIM(MV_PAR03) == _cFilial,ALLTRIM(MV_PAR04),ALLTRIM(MV_PAR03))
                /*
                cQuery := "SELECT A2_COD,A2_LOJA FROM SYS_COMPANY EMPR "+;
               "LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (A2_FILIAL = '"+xFilial("SA2")+"') AND (A2_MSBLQL <> '1') AND (A2_CGC = EMPR.M0_CGC) "+;
               "WHERE (EMPR.D_E_L_E_T_ <> '*') AND (EMPR.M0_CODFIL = '"+_cFilOrig+"') "
               */
                cQuery := "SELECT A2_COD,A2_LOJA FROM SYS_COMPANY EMPR "+;
               "LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 WITH (NOLOCK) ON (SA2.D_E_L_E_T_ <> '*') AND (A2_FILIAL = '"+xFilial("SA2")+"') AND (A2_MSBLQL <> '1') AND (A2_CGC = EMPR.M0_CGC) "+;
               "WHERE (EMPR.D_E_L_E_T_ <> '*') AND (EMPR.M0_CODFIL = '"+cFildest+"') "
               IF SELECT("TCQ") > 0
                    TCQ->(dbCloseArea())
               EndIf

               TCQUERY cQuery ALIAS "TCQ" NEW
               
               DbSelectArea("TCQ")
               DbGoTop()

   		     If !TCQ->(eof())
                    cFornec := TCQ->A2_COD
                    cLojafor := TCQ->A2_LOJA
               endif 
               TCQ->(dbCloseArea())
               /*

                cQuery := "SELECT A1_COD,A1_LOJA FROM SYS_COMPANY EMPR "+;
               "LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON (SA1.D_E_L_E_T_ <> '*') AND (A1_FILIAL = '"+xFilial("SA1")+"') AND (A1_MSBLQL <> '1') AND (A1_CGC = EMPR.M0_CGC) "+;
               "WHERE (EMPR.D_E_L_E_T_ <> '*') AND (EMPR.M0_CODFIL = '"+ _cFilOrig+"') "
               TCQUERY cQuery ALIAS "TCQ" NEW

   		     If !TCQ->(eof())
                    cCliente := TCQ->A1_COD
                    cLojacli := TCQ->A1_LOJA
               endif 
               */
               TCQ->(dbCloseArea())

               if !empty(cFornec)

                    /*
                    cAux := "FROM "+RetSqlName("SA5")+" SA5 "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = '"+MV_PAR03+"') AND (SB1.B1_COD = A5_PRODUTO) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1ORG ON (SB1ORG.D_E_L_E_T_ <> '*') AND (SB1ORG.B1_FILIAL = '"+_cFilOrig+"') AND (SB1ORG.B1_COD = A5_CODPRF) "+;
                    "WHERE (SA5.D_E_L_E_T_ <> '*') AND (A5_FILIAL = '"+xFilial("SA5")+"') AND (A5_FORNECE = '"+cFornec+"') AND (A5_LOJA = '"+cLojafor+"') AND "+;
                    "(A5_CODPRF > '') AND (A5_PRODUTO > '') AND (SB1.B1_MSBLQL <> '1') AND (SB1ORG.B1_MSBLQL <> '1')"
                    //_cRet := " ( B1_COD IN (SELECT DISTINCT A5_CODPRF AS CODPRO "+cAux+" UNION SELECT DISTINCT A5_PRODUTO AS CODPRO "+cAux+ " ))"
                    cQuery := "SELECT DISTINCT A5_CODPRF AS CODPRO "+cAux+" UNION SELECT DISTINCT A5_PRODUTO AS CODPRO "+cAux //+" ORDER BY CODPRO"
                    */

                 /*   cQuery := "SELECT DISTINCT A5_CODPRF AS CODPRO,A5_PRODUTO FROM "+RetSqlName("SA5")+" SA5 WITH (NOLOCK) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+_cFilOrig+"') AND (B2_COD = A5_CODPRF) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = '"+_cFilOrig+"') AND (SB1.B1_COD = A5_CODPRF) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1D WITH (NOLOCK) ON (SB1D.D_E_L_E_T_ <> '*') AND (SB1D.B1_FILIAL = '"+cFildest+"') AND (SB1D.B1_COD = A5_PRODUTO) "+;
                    "WHERE (SA5.D_E_L_E_T_ <> '*') AND (A5_FILIAL = '"+xFilial("SA5")+"') AND (A5_FORNECE = '"+cFornec+"') AND (A5_LOJA = '"+cLojafor+"') AND (A5_CODPRF > '') AND "+;
                    "(A5_PRODUTO > '') AND (B2_QATU > 0.0) AND (SB2.R_E_C_N_O_ IS NOT NULL) AND "+;
                    "(A5_CODPRF BETWEEN '"+ALLTRIM(MV_PAR01)+"' AND '"+ALLTRIM(MV_PAR02)+"') AND "+;
                    "(SB1.B1_TIPO BETWEEN '"+ALLTRIM(MV_PAR07)+"' AND '"+ALLTRIM(MV_PAR08)+"') AND "+;
                    "(SB1.R_E_C_N_O_ IS NOT NULL) AND (SB1.B1_MSBLQL <> '1') AND (SB1D.R_E_C_N_O_ IS NOT NULL) AND (SB1D.B1_MSBLQL <> '1') " */

                    cQuery := "SELECT DISTINCT A5_CODPRF AS CODPRO,A5_PRODUTO FROM "+RetSqlName("SA5")+" SA5 WITH (NOLOCK) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB2")+" SB2 WITH (NOLOCK) ON (SB2.D_E_L_E_T_ <> '*') AND (B2_FILIAL = '"+_cFilOrig+"') AND (B2_COD = A5_PRODUTO) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = '"+_cFilOrig+"') AND (SB1.B1_COD = A5_PRODUTO) "+;
                    "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1D WITH (NOLOCK) ON (SB1D.D_E_L_E_T_ <> '*') AND (SB1D.B1_FILIAL = '"+cFildest+"') AND (SB1D.B1_COD = A5_CODPRF) "+;
                    "WHERE (SA5.D_E_L_E_T_ <> '*') AND (A5_FILIAL = '"+_cFilOrig+"') AND (A5_FORNECE = '"+cFornec+"') AND (A5_LOJA = '"+cLojafor+"') AND (A5_CODPRF > '') AND "+;
                    "(A5_PRODUTO > '') AND (B2_QATU > 0.0) AND (SB2.R_E_C_N_O_ IS NOT NULL) AND "+;
                    "(A5_PRODUTO BETWEEN '"+ALLTRIM(MV_PAR01)+"' AND '"+ALLTRIM(MV_PAR02)+"') AND "+;
                    "(SB1.B1_TIPO BETWEEN '"+ALLTRIM(MV_PAR07)+"' AND '"+ALLTRIM(MV_PAR08)+"') AND "+;
                    "(SB1.R_E_C_N_O_ IS NOT NULL) AND (SB1.B1_MSBLQL <> '1') AND (SB1D.R_E_C_N_O_ IS NOT NULL) AND (SB1D.B1_MSBLQL <> '1') " 


                    /*
                    cInicio := dtos(date()-90)
                    cQuery := "SELECT DISTINCT D2_COD AS CODPRO FROM "+RetSqlName("SD2")+" SD2 "+;
                    "LEFT OUTER JOIN "+RetSqlName("SD1")+" SD1 ON (SD1.D_E_L_E_T_ <> '*') AND (D1_FILIAL = '"+cFildest+"') AND (D1_FORNECE = '"+cFornec+"') AND (D1_LOJA = '"+cLojafor+"') AND (CAST(D1_DOC AS INT) = CAST(D2_DOC AS INT)) AND (D1_SERIE = D2_SERIE) "+;
                    "WHERE (SD2.D_E_L_E_T_ <> '*') AND (D2_FILIAL = '"+_cFilOrig+"') AND (D2_CLIENTE = '"+cCliente+"') AND (D2_LOJA = '"+cLojacli+"') AND (D2_EMISSAO >= '"+cInicio+"') "
                    IF !empty(MV_PAR13)
                         cQuery += "AND (D2_TES = '"+MV_PAR13+"') "
                    ENDIF
                    cQuery += "AND (SD1.R_E_C_N_O_ IS NULL) "
                    dbselectarea("SA5")
                    DbOrderNickName("FORPROD") // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF                                                                                                                          
                    */
//                    MsgAlert(cQuery, "query")
                    TCQUERY cQuery ALIAS "TCQ" NEW
                    DbSelectArea("TCQ")
                    DbGoTop()
                    nCont := 0
                    do while !eof()
                         nCont++ 
                         if nCont == 1
                              _cRet := " ( B1_COD IN ("
                         endif 
                         if nCont > 1
                              _cRet += ","
                         endif 
                         _cRet += "'"+alltrim(TCQ->CODPRO)+"'"
                         if !(ALLTRIM(TCQ->CODPRO) == ALLTRIM(TCQ->A5_PRODUTO))
                              _cRet += ",'"+ALLTRIM(TCQ->A5_PRODUTO)+"'"
                         endif 
                         /*
                         dbselectarea("SA5")
                         MsSeek(cFildest+cFornec+cLojafor+TCQ->CODPRO)
                         if found() .and. !empty(SA5->A5_PRODUTO)
                              _cRet += ",'"+ALLTRIM(SA5->A5_PRODUTO)+"'"
                         endif 
                         */
                         DbSelectArea("TCQ")
                         dbskip()
                    enddo 
                    if nCont > 0
                         _cRet := _cRet + "))"
                    endif 
                    TCQ->(dbCloseArea())
                    
               Endif

          endif 
     ENDIF
Endif

Return(_cRet)
