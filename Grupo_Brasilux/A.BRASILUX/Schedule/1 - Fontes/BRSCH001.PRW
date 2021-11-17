#include 'tbiconn.ch'
#include 'error.ch'
#include 'topconn.ch'
#INCLUDE "PROTHEUS.CH"
/*#INCLUDE "TBICODE.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"    */

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BRSCH001 º Autor ³ Microsiga          º Data ³  06/17/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Programa utilizado para Calculo de Liquidez de Clientes.   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ Schedule AP7 - BRASILUX TINTAS TÉCNICAS LTDA>              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function BRSCH001(aParm)
     Local bErro := {|e| SCH001_1(e)}
     Local cEmp,cFil

  	 DEFAULT aParm := {{"01"},{"010101"}}
  	   

     cEmp  := Alltrim(Transform(aParm[1],'@!'))
     cFil  := Alltrim(Transform(aParm[2],'@!'))
    
     lEndThread := .f.
     RpcMyErro()
     ErrorBlock(bErro)
     
     While !KillApp() .and. !lEndThread
           SCH001_3(aParm[1], aParm[2])
     Enddo
Return(Nil)

/**************************************************************************************/
/*** SCH001_1 - Tratamento dos erros ocorridos.                                     ***/
/**************************************************************************************/
STATIC Function SCH001_1(e)
       If KillApp() .or. lEndThread
          Return
       Endif
       If e:GenCode == EG_JOB
          Sleep(60000)
          Break
       Else
          If (e:GenCode == EG_ZERODIV)
             Return(0)
          ElseIf (e:GenCode == EG_NOALIAS)
                 //LGS#20200212 - Adequação de release 12.1.25 e posteriores
                 //ConOut("   *** Alias does not exist "+e:Operation)
                 FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "   *** Alias does not exist "+e:Operation, 0 )
                 Return
          Endif
       Endif
       //LGS#20200212 - Adequação de release 12.1.25 e posteriores
       //ConOut("   ***"+SCH001_2(e))
       FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "   ***"+SCH001_2(e), 0 )
       __QUIT()
Return(Nil)

/**************************************************************************************/
/*** SCH001_2 - Exibe a mensagem de erro na tela do server.                         ***/
/**************************************************************************************/
STATIC Function SCH001_2(e)
       Local cMessage := If( Empty(e:osCode), If(e:Severity > ES_WARNING, "Error ", "Warning "), "DOS Error "+nTrim(e:osCode)+" )" )
       cMessage += If( ValType(e:SubSystem) == "C", e:SubSystem, "???")
       If ValType(e:Description) == "C"
          cMessage += " "+e:Description
       Endif
       cMessage += If( !Empty(e:FileName), ": "+e:FileName, If( !Empty(e:Operation), ": "+e:Operation, "") )
Return(cMessage)

/**************************************************************************************/
/*** SCH001_3 - Faz o calculo da liquidez para cada cliente.                        ***/
/**************************************************************************************/
STATIC Function SCH001_3(cEmp, cFil)
       //Local cTime     := ""  	
       
       If ValType(cEmp) == "U" .or. ValType(cFil) == "U"
          lEndThread := .t.
          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
          //ConOut("   *** Erro na Empresa/Filial !!!")
          FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "   ***"+SCH001_2(e), 0 )
       Endif
       If !lEndThread .and. ( Empty(Left(cEmp, 2)) .or. Empty(Left(cFil, 6)) )
          lEndThread := .t.
          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
          //ConOut("   *** Erro na Empresa e/ou Filial !!!")
          FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "   *** Erro na Empresa e/ou Filial !!!", 0 )
       Endif
       If lEndThread
          //LGS#20200212 - Adequação de release 12.1.25 e posteriores
          //ConOut("   *** Erro na Inicialização do ambiente Local"+GetEnvServer()+".")
          FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "   *** Erro na Inicialização do ambiente Local"+GetEnvServer()+".", 0 )
          Return(Nil)
       Endif
       tIni := Time()   // Hora de inicio do processamento
       dIni := MSDate() // Data de inicio do processamento
       //LGS#20200212 - Adequação de release 12.1.25 e posteriores
       //ConOut("BRSCH001 - Thread iniciada com sucesso as: "+tIni+" - "+dToc(dIni))
       FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "BRSCH001 - Thread iniciada com sucesso as: "+tIni+" - "+dToc(dIni), 0 )
       //ConOut("BRSCH001 - Empresa: "+cEmp+" - Filial: "+cFil)
       FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "BRSCH001 - Empresa: "+cEmp+" - Filial: "+cFil, 0 )
       PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil TABLES "SA1"  

/*
LOCAL cQuery
cQuery := "; INSERT INTO PULARTRIGGER (TABELA ,SPID , BypassTrigger) VALUES ('SA1010',@@SPID,1); "+;
"UPDATE SA1010 SET A1_NOME = 'LUISA MARTHA OLIVEIRAX' WHERE R_E_C_N_O_ = 35791"
TCSQLEXEC(cQuery)

*/


		//Índice de Liquidez:
		cQry := "; INSERT INTO PULARTRIGGER (TABELA ,SPID , BypassTrigger) VALUES ('SA1010',@@SPID,1); "+;
		"WITH TMPPGTOS AS ("+;
	  	"SELECT SE11.E1_CLIENTE AS CLIENTE,"+;
       	"SUM( DATEDIFF( DAY, CASE WHEN convert(varchar,GETDATE(),112) >= SE11.E1_VENCTO THEN CAST(SE11.E1_VENCTO AS DATETIME) ELSE GETDATE() END ,GETDATE() ) * E1_SALDO ) AS TOTAL, "+;
       	"SUM(SE11.E1_SALDO) AS SALDO "+;
       	"FROM "+RetSqlName("SE1")+" SE11 WITH (NOLOCK) "+;
       	"WHERE (SE11.E1_SALDO > 0) "+;
  		"AND (E1_VENCTO < convert(varchar,GETDATE(),112)) "+;
    	"AND (SE11.E1_TIPO NOT IN('RA','NCC')) "+;
     	"AND (SE11.D_E_L_E_T_ <> '*') "+;
       	"GROUP BY SE11.E1_CLIENTE "+;
       	"UNION ALL "+;
       	"SELECT SE51.E5_CLIFOR AS CLIENTE,"+;
       	"SUM( DATEDIFF( DAY, CASE WHEN SE51.E5_DATA >= SE11.E1_VENCTO THEN CAST(SE11.E1_VENCTO AS DATETIME) ELSE CAST(SE51.E5_DATA AS DATETIME) END, CAST(SE51.E5_DATA AS DATETIME) ) * SE51.E5_VALOR) AS TOTAL, "+;
       	"SUM(SE51.E5_VALOR) AS SALDO "+;
       	"FROM "+RetSqlName("SE5")+" SE51 WITH (NOLOCK) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SE1")+" SE11 WITH (NOLOCK) ON "+;
       	"(E5_FILIAL = E1_FILIAL) AND (E5_PREFIXO = E1_PREFIXO) AND (E5_NUMERO = E1_NUM) AND (E5_PARCELA = E1_PARCELA) AND (E5_CLIFOR = E1_CLIENTE) AND (SE11.D_E_L_E_T_ <> '*') "+;
       	"WHERE (SE51.D_E_L_E_T_ <> '*') "+;
		"AND (E5_VALOR > 0) "+;
		"AND (SE51.E5_RECPAG = 'R') "+;
		"AND (E5_TIPO NOT IN('RA','NCC')) "+;
        "AND (E5_MOTBX NOT IN('LIQ','DAC','CMP','DEV')) "+;
        "AND (E5_TIPODOC NOT IN('JR','TX','EC','TR','ES','MT')) "+;
       	"GROUP BY SE51.E5_CLIFOR "
       	if cEmp = "01"
       		cQry += "UNION ALL "+;
	       	"SELECT SE13.E1_CLIENTE AS CLIENTE,"+;
    	   	"SUM( DATEDIFF( DAY, CASE WHEN convert(varchar,GETDATE(),112) >= SE13.E1_VENCTO THEN CAST(SE13.E1_VENCTO AS DATETIME) ELSE GETDATE() END, GETDATE() ) * SE13.E1_SALDO) AS TOTAL, "+;
	       	"SUM(SE13.E1_SALDO) AS SALDO "+;
    	   	"FROM SE1030 SE13 WITH (NOLOCK) "+;
       		"WHERE (SE13.E1_SALDO > 0) "+;
	  		"AND convert(varchar,GETDATE(),112) > SE13.E1_VENCTO "+;
    		"AND (SE13.E1_TIPO NOT IN('RA','NCC')) "+;
     		"AND (SE13.D_E_L_E_T_ <> '*') "+;
	       	"GROUP BY SE13.E1_CLIENTE "+;
       		"UNION ALL "+;
       		"SELECT SE53.E5_CLIFOR AS CLIENTE,SUM( DATEDIFF( DAY, CASE WHEN SE53.E5_DATA >= SE13.E1_VENCTO THEN CAST(SE13.E1_VENCTO AS DATETIME) ELSE CAST(SE53.E5_DATA AS DATETIME) END, CAST(SE53.E5_DATA AS DATETIME) ) * SE53.E5_VALOR) AS TOTAL, "+;
        	"SUM(SE53.E5_VALOR) AS SALDO "+;
       		"FROM SE5030 SE53 WITH (NOLOCK) "+;
       		"LEFT OUTER JOIN SE1030 SE13 WITH (NOLOCK) ON "+;
       		"(E5_FILIAL = E1_FILIAL) AND (E5_PREFIXO = E1_PREFIXO) AND (E5_NUMERO = E1_NUM) AND (E5_PARCELA = E1_PARCELA) AND (E5_CLIFOR = E1_CLIENTE) AND (SE13.D_E_L_E_T_ <> '*') "+;
       		"WHERE (SE53.D_E_L_E_T_ <> '*') "+;
			"AND (E5_VALOR > 0) "+;
        	"AND (SE53.E5_RECPAG = 'R') "+;
			"AND (E5_TIPO NOT IN('RA','NCC')) "+;
        	"AND (E5_MOTBX NOT IN('LIQ','DAC','CMP','DEV')) "+;
        	"AND (E5_TIPODOC NOT IN('JR','TX','EC','TR','ES','MT')) "+;
       		"GROUP BY SE53.E5_CLIFOR "
   		endif 
       	cQry += "), TMPCLI AS ( "+;
       	"SELECT CLIENTE,SUM(SALDO) AS SALDO,SUM(TOTAL) AS TOTAL FROM TMPPGTOS GROUP BY CLIENTE) "+;
       	"UPDATE "+RetSqlName("SA1")+" SET A1_DTLIQ = convert(varchar,GETDATE(),112),A1_LIQUID = (CASE WHEN ISNULL(TMPCLI.SALDO,0) > 0 THEN "+;
       	"CASE WHEN (ISNULL(TMPCLI.TOTAL,0)/TMPCLI.SALDO) >= 30 THEN 0 "+;
       	"WHEN (ISNULL(TMPCLI.TOTAL,0)/TMPCLI.SALDO) >= 15 THEN 50 "+;
       	"WHEN (ISNULL(TMPCLI.TOTAL,0)/TMPCLI.SALDO) >= 5 THEN 70 "+;
       	"ELSE 100 END ELSE 0 END) FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "+;
       	"LEFT OUTER JOIN TMPCLI ON (SA1.D_E_L_E_T_ <> '*') AND (TMPCLI.CLIENTE = SA1.A1_COD) "+;
       	"WHERE (SA1.D_E_L_E_T_ <> '*')"
		TCSQLEXEC(cQry)       
		
		//Tendência de Liquidez nos últimos 3 títulos
		cQry := "; INSERT INTO PULARTRIGGER (TABELA ,SPID , BypassTrigger) VALUES ('SA1010',@@SPID,1); "+; 
		"WITH TMPAGLUT AS ("+;
       	"SELECT SE11.E1_CLIENTE AS CLIENTE,"+;
       	"SE11.E1_VENCTO AS VENCTO, "+;
       	"DATEDIFF( DAY, CAST(SE11.E1_VENCTO AS DATETIME),GETDATE() ) * E1_SALDO AS TOTAL, "+;
       	"SE11.E1_SALDO AS SALDO, "+;
       	"RANK() over (partition by E1_CLIENTE order by E1_VENCTO desc,SE11.R_E_C_N_O_ DESC) as HR_Rank "+;
      	"FROM "+RetSqlName("SE1")+" SE11 WITH (NOLOCK) "+;
       	"WHERE (SE11.E1_SALDO > 0) "+;
       	"AND (SE11.E1_VENCTO < convert(varchar,GETDATE(),112)) "+;
       	"AND (SE11.E1_TIPO NOT IN('RA','NCC')) "+;
		"AND (SE11.D_E_L_E_T_ <> '*') "+;
       	"UNION ALL "+;
       	"SELECT SE51.E5_CLIFOR AS CLIENTE,"+;
       	"E1_VENCTO AS VENCTO,"+;
       	"DATEDIFF( DAY, CASE WHEN SE51.E5_DATA >= SE11.E1_VENCTO THEN CAST(SE11.E1_VENCTO AS DATETIME) ELSE CAST(SE51.E5_DATA AS DATETIME) END, CAST(SE51.E5_DATA AS DATETIME) ) * SE51.E5_VALOR AS TOTAL, "+;
       	"SE51.E5_VALOR AS SALDO, "+;
       	"RANK() over (partition by E5_CLIFOR order by E1_VENCTO desc,SE51.R_E_C_N_O_ DESC) as HR_Rank "+;
       	"FROM "+RetSqlName("SE5")+" SE51 WITH (NOLOCK) "+;
       	"LEFT OUTER JOIN "+RetSqlName("SE1")+" SE11 WITH (NOLOCK) ON "+;
       	"(E5_FILIAL = E1_FILIAL) AND (E5_PREFIXO = E1_PREFIXO) AND (E5_NUMERO = E1_NUM) AND (E5_PARCELA = E1_PARCELA) AND (E5_CLIFOR = E1_CLIENTE) AND (SE11.D_E_L_E_T_ <> '*')  "+;
       	"WHERE (SE51.D_E_L_E_T_ <> '*') "+;
		"AND (E5_VALOR > 0) "+;
        "AND (SE51.E5_RECPAG = 'R') "+;
		"AND (E5_TIPO NOT IN('RA','NCC')) "+;
        "AND (E5_MOTBX NOT IN('LIQ','DAC','CMP','DEV')) "+;
        "AND (E5_TIPODOC NOT IN('JR','TX','EC','TR','ES','MT')) "
        IF cEmp = "01"
	       	cQry += "UNION ALL "+;
    	   	"SELECT SE13.E1_CLIENTE AS CLIENTE,"+;
       		"E1_VENCTO AS VENCTO, "+;
	       	"DATEDIFF( DAY, CAST(SE13.E1_VENCTO AS DATETIME), GETDATE() ) * SE13.E1_SALDO AS TOTAL, "+;
    	   	"SE13.E1_SALDO AS SALDO,"+;
       		"RANK() over (partition by E1_CLIENTE order by E1_VENCTO desc,SE13.R_E_C_N_O_ DESC) as HR_Rank "+;
	       	"FROM SE1030 SE13 WITH (NOLOCK) "+;
    	   	"WHERE (SE13.E1_SALDO > 0) "+;
	  		"AND SE13.E1_VENCTO > convert(varchar,GETDATE(),112) "+;
			"AND (SE13.E1_TIPO NOT IN('RA','NCC')) "+;
			"AND (SE13.D_E_L_E_T_ <> '*') "+;
    	   	"UNION ALL "+;
	       	"SELECT SE53.E5_CLIFOR AS CLIENTE,"+;
    	   	"E1_VENCTO AS VENCTO, "+;
	       	"DATEDIFF( DAY, CASE WHEN SE53.E5_DATA >= SE13.E1_VENCTO THEN CAST(SE13.E1_VENCTO AS DATETIME) ELSE CAST(SE53.E5_DATA AS DATETIME) END, CAST(SE53.E5_DATA AS DATETIME) ) * SE53.E5_VALOR AS TOTAL, "+;
    	   	"SE53.E5_VALOR AS SALDO,"+;
	       	"RANK() over (partition by E5_CLIFOR order by E1_VENCTO desc,SE53.R_E_C_N_O_ DESC) as HR_Rank "+;
    	   	"FROM SE5030 SE53 WITH (NOLOCK) "+;
	       	"LEFT OUTER JOIN SE1030 SE13 WITH (NOLOCK) ON "+;
	       	"(E5_FILIAL = E1_FILIAL) AND (E5_PREFIXO = E1_PREFIXO) AND (E5_NUMERO = E1_NUM) AND (E5_PARCELA = E1_PARCELA) AND (SE53.E5_CLIFOR = E1_CLIENTE) AND (SE13.D_E_L_E_T_ <> '*') "+;
	       	"WHERE (SE53.D_E_L_E_T_ <> '*') "+;
			"AND (E5_VALOR > 0) "+;
        	"AND (SE53.E5_RECPAG = 'R') "+;
			"AND (E5_TIPO NOT IN('RA','NCC')) "+;
	        "AND (E5_MOTBX NOT IN('LIQ','DAC','CMP','DEV')) "+;
    	    "AND (E5_TIPODOC NOT IN('JR','TX','EC','TR','ES','MT')) "
   		endif 
   		cQry += "), TMPPGTOS AS (SELECT CLIENTE,SALDO,TOTAL,RANK() OVER (PARTITION BY CLIENTE ORDER BY VENCTO DESC,SALDO DESC,TOTAL) AS RANQUE "+;
       	"FROM TMPAGLUT WHERE HR_Rank <= 3),  "+;
       	"TMPCLI AS ( "+;
       	"SELECT CLIENTE,SUM(SALDO) AS SALDO,SUM(TOTAL) AS TOTAL FROM TMPPGTOS  WHERE RANQUE <= 3 GROUP BY CLIENTE) "+;
       	"UPDATE "+RetSqlName("SA1")+" SET A1_DTLIQ = convert(varchar,GETDATE(),112),A1_TENLIQ = (CASE WHEN ISNULL(TMPCLI.SALDO,0) > 0 THEN "+;
       	"CASE WHEN (ISNULL(TMPCLI.TOTAL,0)/TMPCLI.SALDO) >= 30 THEN 0 "+;
       	"WHEN (ISNULL(TMPCLI.TOTAL,0)/TMPCLI.SALDO) >= 15 THEN 50 "+;
       	"WHEN (ISNULL(TMPCLI.TOTAL,0)/TMPCLI.SALDO) >= 5 THEN 70 "+;
       	"ELSE 100 END ELSE 0 END) FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) "+;
       	"LEFT OUTER JOIN TMPCLI ON (SA1.D_E_L_E_T_ <> '*') AND (TMPCLI.CLIENTE = SA1.A1_COD) "+;
       	"WHERE (SA1.D_E_L_E_T_ <> '*')"
		TCSQLEXEC(cQry)       

               tFim      := Time()   // Hora de fim do processamento
               dFim      := MSDate() // Data de fim do processamento
               //LGS#20200212 - Adequação de release 12.1.25 e posteriores
               //ConOut("BRSCH001 - Finalizando Thread do Calculo de Liquidez as "+tFim+" - "+dToc(dFim))
               FwLogMSG( "ERROR", , 'SIGAFAT', funname(), '', '01', "BRSCH001 - Empresa: "+cEmp+" - Filial: "+cFil, 0 )
               lEndThread := .t.
       RESET ENVIRONMENT
Return(Nil)

