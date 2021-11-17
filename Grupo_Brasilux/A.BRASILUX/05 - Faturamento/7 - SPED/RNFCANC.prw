#include "rwmake.ch"
#INCLUDE "TOPCONN.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRLFSO   บAutor  ณ FERNANDO FERES     บ Data ณ    23/11/11   บฑฑ
ฑฑบPrograma  ณAdapta็ใo p/ Brasilux: Cleber Orati  บ Data ณ    15/04/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ       RELATำRIO DE NFS CANCELADAS E INUTILIZADAS           บฑฑ
ฑฑบ          ณ       FORMATO GRAFICO ( RETRATO )                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCliente       ณ                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑ  Observa็๕es                      	  |Data             Autor          ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RNFCANC()

Local 	oPrn
Local 	aCA        	:= {OemToAnsi("Confirma"),OemToAnsi("Abandona")}
Local 	cCadastro  	:= OemToAnsi("Impressao Fatura")
Local 	aSays      	:= {}
Local 	aButtons   	:= {}
Local 	nOpca    	:= 0

Private aReturn  	:= {OemToAnsi('Zebrado'), 1,OemToAnsi('Administracao'), 2, 2, 1, '',1 }
Private nLastKey 	:= 0
Private Modulo   	:= 11
Private Moeda    	:= "9"
Private cPerg   	:= PadR("RNFCANC", 10)
Private nValor 	  	:= 0 
PRIVATE MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04_MV_PAR05,MV_PAR06,MV_PAR07

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros                         ณ
//ณ mv_par01            // Prefixo                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//local MV_PAR01
//local MV_PAR02
//date MV_PAR03
//date MV_PAR04
//date MV_PAR05
//date MV_PAR06
//local MV_PAR07

ValidPerg()
            
pergunte("RNFCANC",.F.)
/*
MV_PAR01 := SF3->F3_SERIE
MV_PAR02 := SF3->F3_SERIE
MV_PAR03 := SF3->F3_EMISSAO
MV_PAR04 := SF3->F3_EMISSAO
MV_PAR05 := SF3->F3_DTCANC
MV_PAR06 := SF3->F3_DTCANC
MV_PAR07 := SF3->F3_CODRSEF
*/
AAdd(aSays,OemToAnsi( "  Este programa ira imprimir o relat๓rio de Notas Fiscais Canceladas"))

AAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AAdd(aButtons, { 1,.T.,{|| nOpca := 1,FechaBatch() }} )
AAdd(aButtons, { 2,.T.,{|| nOpca := 0,FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )
	
If nOpca == 1
	Processa( { |lEnd| ImpBol(oPrn) })
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPBOL    บAutor  ณMicrosiga           บ Data ณ  09/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
	
Static Function ImpBol(oPrn)
Local cCond,cQuery
nPag  := 1

oPrn:= TMSPrinter():New()
oPrn:SetPortrait()
oPrn:SetPaperSize(9) // A4
oPrn:Setup()
oPrn:StartPage()

//FONTES
oFont1:= TFont():New( "Courier New",,10,,.F.,,,,,.F. ) 
oFont2:= TFont():New( "Courier New",,10,,.T.,,,,,.F. ) // NEGRITO
oFont3:= TFont():New( "Courier New",,09,,.F.,,,,,.F. )
oFont4:= TFont():New( "Courier New",,21,,.T.,,,,,.F. ) // NEGRITO
oFont5:= TFont():New( "Courier New",,28,,.F.,,,,,.F. )
oFont6:= TFont():New( "Courier New",,16,,.T.,,,,,.F. ) // NEGRITO
oFont7:= TFont():New( "Courier New",,18,,.T.,,,,,.F. ) // NEGRITO

oFont8:= TFont():New( "Times New Roman",,10,,.T.,,,,.T.,.F. ) // NEGRITO
oFont9:= TFont():New( "Times New Roman",,16,,.T.,,,,.T.,.F. ) // NEGRITO
oFont10:= TFont():New( "Times New Roman",,11,,.F.,,,,,.F. )
                                                               	
cCond := "(SF3.D_E_L_E_T_ <> '*') AND (SF3.F3_FILIAL = '"+xFilial("SF3")+"') AND (SF3.F3_DTCANC > '') "

if !empty(alltrim(MV_PAR02))
	cCond += "AND (SF3.F3_SERIE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"') "
endif 

cCond += "AND (SF3.F3_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"') "
if !empty(MV_PAR06) .AND. (MV_PAR06 >= MV_PAR05)
	cCond += "AND (SF3.F3_DTCANC BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"') "
endif 
DO CASE
CASE MV_PAR07 == 1 //CANCELADAS
	cCond += "AND (SF3.F3_CODRSEF <> '102') "
CASE MV_PAR07 == 2 //INUTILIZADAS
	cCond += "AND (SF3.F3_CODRSEF =  '102') "
OTHERWISE // TODAS
	cCond += ""	
ENDCASE 	

cQuery := "SELECT F3_SERIE, F3_NFISCAL,F3_EMISSAO,F3_DTCANC,F3_CODRSEF,F3_VALCONT,F3_CLIEFOR,F3_CLIENT "
cQuery += "FROM "+RetSqlName("SF3")+" SF3 WITH (NOLOCK) "+ " 
cQuery += "WHERE "+cCond
cQuery += "ORDER BY F3_SERIE, F3_NFISCAL " 

      
	     	
  //			cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
			
		dbSelectArea("TMP")
		TMP->(DbGotop())
		

		If TMP->(Eof())
		   MsgInfo("Nao existem registros com o filtro escolhido!","Aten็ใo!")
		   set filter to
		   dbGotop()
		   TMP->(DbCloseArea())
		   Return
		EndIf

//ImpCabecP(oPrn)   

		cBitMap := GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + cFilAnt + ".BMP"
		If !File(cBitMap)
			cBitMap	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
			If !File(cBitMap)
				cBitMap:= "LGRL01.BMP"
			EndIf
		EndIf	

   		cBitIso:= ""
   		cBitSel:= "LOGO_TOPFIVE.BMP"
   		oPrn:Say(040,0750,ALLTRIM(SM0->M0_NOMECOM),oFont7,100) 
		oPrn:Say(120,0400,"NOTAS FISCAIS CANCELADAS E INUTILIZADAS",oFont7,100) 
		oPrn:SayBitmap(040,040,cBitMap,307,150 ) //700,300
		oPrn:Say(040,2000,"Emissใo .: "+ DtoC(Date()),oFont8,100) 
		oPrn:Say(080,2000,"Hora      .: "+ Time(),oFont8,100)
		oPrn:Say(120,2000,"Pแgina   .: "+ "01" ,oFont8,100) 
		oPrn:Box(040+0000,0040,185+0000,2370)
		oPrn:Box(040+0000,0345,185+0000,1990)

Impress(oPrn)

	If !Eof()
		oPrn:EndPage()
		oPrn:StartPage()
	Endif


Set Filter to

oPrn:EndPage()
oPrn:Preview()
MS_FLUSH()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpress   บAutor  ณMicrosiga           บ Data ณ  09/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ     INICIO DA IMPRESSีES                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
	
Static Function Impress(oPrn)
	
_nLin := 0
nPag  := 01

	//COLOCAR AS IMPRESSOES AQUI 
	
dbSelectArea("TMP")
TMP->(DbGotop())	
	
While TMP->(!Eof())     

	cNF      := TMP->F3_SERIE+TMP->F3_NFISCAL
	cValor   := transform(TMP->F3_VALCONT, "@E 999,999,999.99") 
	cNome    := ""
	cStatus  := "" 
	cCont    := ""
	cAviso   := TMP->F3_NFISCAL
	cClient  := ""//TMP->F3_CLIENT 
   	cEmiss   := Substr(TMP->F3_EMISSAO,7,2)+ "/" + Substr(TMP->F3_EMISSAO,5,2) + "/" + Substr(TMP->F3_EMISSAO,1,4)  
   	cCanc    := Substr(TMP->F3_DTCANC,7,2)+ "/" + Substr(TMP->F3_DTCANC,5,2) + "/" + Substr(TMP->F3_DTCANC,1,4)
   	
   	   If TMP->F3_CLIEFOR == TMP->F3_CLIENT
       	cClient  := TMP->F3_CLIENT
   	   
		   	   dbSelectArea("SA1")
		     	dbSetOrder(1)
			   If dbSeek(xFilial()+cClient)
			   		cNome    := SA1->A1_NOME	
		       Endif
       Endif
       
       If TMP->F3_CLIEFOR <>TMP->F3_CLIENT
       	cClient  := TMP->F3_CLIEFOR
   	   
		   	   dbSelectArea("SA2")
		     	dbSetOrder(1)
			   If dbSeek(xFilial()+cClient)
			   		cNome    := SA2->A2_NOME	
		       Endif
		       
		       	dbSelectArea("SA1")
			     	dbSetOrder(1)
				   If dbSeek(xFilial()+cClient)
				   		cNome    := SA1->A1_NOME	
			       Endif
       Endif
          	
   	If TMP->F3_CODRSEF = "102"
   	   cStatus := "NOTA INUTILIZADA" 
   	Else
   	   cStatus := "NOTA CANCELADA"
   	Endif  
    
	oPrn:Say(_nLin+0215,0320,"SษRIE.: " + TMP->F3_SERIE      ,oFont8,100) //0065
	oPrn:Box(_nLin+0210,0040,_nLin+0260,500)                              //0040
    
    oPrn:Say(_nLin+0215,0065,"N.F.: " + TMP->F3_NFISCAL       ,oFont8,100) //320
	//oPrn:Box(_nLin+0210,0040,_nLin+0260,600)                               //300
 
   	oPrn:Say(_nLin+0215,520,"CLIENTE/FORNECEDOR.: " + Transform(cNome, "@!")             ,oFont8,100) 
	oPrn:Box(_nLin+0210,500,_nLin+0260,2370)//1700
	
	//oPrn:Say(_nLin+0215,1720,"STATUS.: " + cStatus             ,oFont8,100) 
	//oPrn:Box(_nLin+0210,1700,_nLin+0260,2370)
	
	oPrn:Say(_nLin+0265,0065,"EMISSรO.: " + cEmiss          ,oFont8,100) 
	oPrn:Box(_nLin+0260,0040,_nLin+0310,500) 
	
	oPrn:Say(_nLin+0265,520,"CANCELAMENTO.: " + cCanc       ,oFont8,100) //cCanc
	oPrn:Box(_nLin+0260,500,_nLin+0310,1150)
	
	oPrn:Say(_nLin+0265,1170,"VALOR.: R$ " + cValor       ,oFont8,100) //cCanc
	oPrn:Box(_nLin+0260,1150,_nLin+0310,1700) 
	
	oPrn:Say(_nLin+0265,1720,"STATUS.: " + cStatus       ,oFont8,100) //cCanc
	oPrn:Box(_nLin+0260,1700,_nLin+0310,2370)
	  
     
TMP->(DbSkip())

_nLin += 0150
	If _nLin > 3100  //2700
	
	   oPrn:Say(_nLin+0200,600,"* * * * CONTINUA NA PRำXIMA PมGINA * * * *"       ,oFont8,100) //cCanc 
	   _nLin := 0000 
	   nPag  := nPag+1
	   oPrn:EndPage()
	   oPrn:StartPage()
       
		cBitMap := GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + cFilAnt + ".BMP"
		If !File(cBitMap)
			cBitMap	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
			If !File(cBitMap)
				cBitMap:= "LGRL01.BMP"
			EndIf
		EndIf	
   		cBitIso:= ""
   		cBitSel:= "LOGO_TOPFIVE.BMP"
   		oPrn:Say(040,0750,ALLTRIM(SM0->M0_NOMECOM),oFont7,100) 
		oPrn:Say(120,0375,"NOTAS FISCAIS CANCELADAS E INUTILIZADAS",oFont7,100) //	oPrn:Say(120,0775,"RELATำRIO DE NOTAS FISCAIS CANCELADAS E INUTILIZADAS",oFont7,100) 
		oPrn:SayBitmap(040,040,cBitMap,307,150 ) //700,300
		oPrn:Say(040,2000,"Emissใo .: "+ DtoC(Date()),oFont8,100) 
		oPrn:Say(080,2000,"Hora      .: "+ Time(),oFont8,100)
		oPrn:Say(120,2000,"Pแgina   .: "+ StrZero(nPag,2),oFont8,100)
		oPrn:Box(040+0000,0040,185+0000,2370)
		oPrn:Box(040+0000,0345,185+0000,1990)
	
    Endif 

EndDo    	 		    	 
	

TMP->(DbCloseArea())
SC5->(DbCloseArea())
SA1->(DbCloseArea())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpress   บAutor  ณMicrosiga           บ Data ณ  09/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ           CABEวALHO E LOGOTIPO                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function ImpCabecP(oPrn)

	cBitMap:= "LGRL01.BMP"
	cBitIso:= ""
	cBitSel:= "LOGO_TOPFIVE.BMP"
    oPrn:Say(040,0750,"ELETRิNICA SANTANA LTDA",oFont7,100) 
	oPrn:Say(120,0775,"ROMANEIO DE ENTREGAS",oFont7,100) 
	oPrn:SayBitmap(040,040,cBitMap,307,150 ) //700,300
	oPrn:Say(040,2000,"Emissใo .: "+ DtoC(Date()),oFont8,100) 
	oPrn:Say(080,2000,"Hora      .: "+ Time(),oFont8,100)
	oPrn:Say(120,2000,"Pแgina   .: "+"01" ,oFont8,100) 
	oPrn:Box(040+0000,0040,185+0000,2370)
	oPrn:Box(040+0000,0345,185+0000,1990)
	
	oPrn:Box(040+0200,0040,040+0275,1115) 
	oPrn:Say(045+0200,0065,"ROMANEIO.: " + TMP->ZRO_NUM	   ,oFont6,100) 
	oPrn:Say(045+0200,1120,"ENTREGADOR.: " + TMP->ZRO_ENTREG         ,oFont6,100)			
	oPrn:Box(040+0200,1115,040+0275,2370)
		
	
Return
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFINR02   บAutor  ณMicrosiga           บ Data ณ  09/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria SX1                                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

Private aRegs := {}

//Estrutura {Grupo	/Ordem	/Pergunta			/Pergunta Espanhol	/Pergunta Ingles	/Variavel	/Tipo	/Tamanho	/Decimal	/Presel	/GSC	/Valid	/Var01		/Def01		/DefSpa1	/DefEng1	/Cnt01	/Var02	/Def02		/DefSpa2	/DefEng2	/Cnt02	/Var03	/Def03	/DefSpa3	/DefEng3	/Cnt03	/Var04	/Def04	/DefSpa4	/DefEng4	/Cnt04	/Var05	/Def05	/DefSpa5	/DefEng5	/Cnt05	/F3		/PYME	/GRPSX6	/HELP	}
Aadd( aRegs,{ cPerg, "01","SษRIE DE.:                   ","               ","               ","mv_ch1","C", 3,0,0,"G",;
                      "                                                                     ",;
                      "mv_par01       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","      ","   " } )
Aadd( aRegs,{ cPerg, "02","SษRIE ATษ.:                  ","               ","               ","mv_ch2","C", 3,0,0,"G",;
                      "                                                                     ",;
                      "mv_par02       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","      ","   " } )
Aadd( aRegs,{ cPerg, "03","EMISSรO DE.:                 ","               ","               ","mv_ch3","D", 8,0,0,"G",;
                      "                                                                     ",;
                      "mv_par03       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","      ","   " } )
Aadd( aRegs,{ cPerg, "04","EMISSรO ATษ.:                ","               ","               ","mv_ch4","D", 8,0,0,"G",;
                      "                                                                     ",;
                      "mv_par04       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","      ","   " } )
Aadd( aRegs,{ cPerg, "05","CANCELAMENTO DE.:            ","               ","               ","mv_ch5","D", 8,0,0,"G",;
                      "                                                                     ",;
                      "mv_par05       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","      ","   " } )
Aadd( aRegs,{ cPerg, "06","CANCELAMENTO ATษ.:           ","               ","               ","mv_ch6","D", 8,0,0,"G",;
                      "                                                                     ",;
                      "mv_par06       ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","               ","               ","               ","               ","                                                            ",;
                      "               ","               ","               ","               ","                                                            ","      ","   " } )
Aadd( aRegs,{ cPerg, "07","STATUS.:                     ","               ","               ","mv_ch7","N", 1,0,0,"C",;
                      "                                                                     ",;
                      "mv_par07       ","1-CANCELADAS","1-CANCELADAS","1-CANCELADAS","                                                            ","               ","2-INUTILIZADAS","2-INUTILIZADAS","2-INUTILIZADAS","                                                            ",;
                      "               ","3-TODAS","3-TODAS","3-TODAS","                                                            ","               ","               ","               ","               ","                                                            ",;
ง                      "               ","               ","               ","               ","                                                            ","      ","   " } )
//Estrutura {Grupo	/Ordem	/Pergunta			/Pergunta Espanhol	/Pergunta Ingles	/Variavel	/Tipo	/Tamanho	/Decimal	/Presel	/GSC	/Valid	/Var01		/Def01		/DefSpa1	/DefEng1	/Cnt01	/Var02	/Def02		/DefSpa2	/DefEng2	/Cnt02	/Var03	/Def03	/DefSpa3	/DefEng3	/Cnt03	/Var04	/Def04	/DefSpa4	/DefEng4	/Cnt04	/Var05	/Def05	/DefSpa5	/DefEng5	/Cnt05	/F3		/PYME	/GRPSX6	/HELP	}


lValidPerg( aRegs )


Return

Static Function lValidPerg(aRegs)
Local i
for i := 1 to len(aRegs)
//				1	  2			3					4					5					6			7		8			9			10		11		12		13			14			15			16			17		18		19			20			21			22		23		24		25			26			27	  28		29		30			31			32		33		34		35			36			37	  38		39		40		41					
//Estrutura {Grupo	/Ordem	/Pergunta			/Pergunta Espanhol	/Pergunta Ingles	/Variavel	/Tipo	/Tamanho	/Decimal	/Presel	/GSC	/Valid	/Var01		/Def01		/DefSpa1	/DefEng1	/Cnt01	/Var02	/Def02		/DefSpa2	/DefEng2	/Cnt02	/Var03	/Def03	/DefSpa3	/DefEng3	/Cnt03	/Var04	/Def04	/DefSpa4	/DefEng4	/Cnt04	/Var05	/Def05	/DefSpa5	/DefEng5	/Cnt05	/F3		/PYME	/GRPSX6	/HELP	}
	u_xPutSX1(aRegs[i,1],aRegs[i,2],aRegs[i,3],aRegs[i,3],aRegs[i,3],aRegs[i,6], aRegs[i,7] ,aRegs[i,8],aRegs[i,9],aRegs[i,10],aRegs[i,11],aRegs[i,12],aRegs[i,38]," ",aRegs[i,39],;
	aRegs[i,13],aRegs[i,14],aRegs[i,15],aRegs[i,16],aRegs[i,17],;
	aRegs[i,19],aRegs[i,20],aRegs[i,21],;
	aRegs[i,24],aRegs[i,25],aRegs[i,26],; 
    aRegs[i,29],aRegs[i,30],aRegs[i,31],; 
    aRegs[i,34],aRegs[i,35],aRegs[i,36],; 
    aRegs[i,2],aRegs[i,2],aRegs[i,2],aRegs[i,1])

next
return
