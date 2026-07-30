#INCLUDE "rwmake.ch"

/*/
Programa PEDBRA Autor  Murilo Patriota           Data   13/02/08   
Descricao  Pedido de venda especifico Brasemba                                                                     
Uso        Especifico Brasemba                                        
/*/
User Function PEDBRA
//
// Declaracao de Variaveis                                             
//

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := ""
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "PEDBRA" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "PED"+SC5->C5_NUM // 
Private cPerg	     := ""
Private cString      := "SC5"
Private cprod        := ""
Private VTP          :={{"M","MALETA     "},;
                             {"C","CORTE-VINCO"},;
                             {"A","ABA TRANSP."},;
                             {"I","ABA INF.   "},;
                             {"S","ABA SUP.   "},;
                             {"T","S/ ABA INF."},;
                             {"F","S/ ABA SUP."},;
                             {"B","BOBINA     "}}

Private _aArea:=GetArea()
If SC5->C5_LIBEROK <> 'S' .AND. !(RetCodUsr() $ GetMV("BR_APROVA"))
   Msgstop("Pedido nao Liberado. Nao pode ser Impresso")
   RestArea(_aArea)
   Return
EndIf   


dbSelectArea("SC5")
dbSetOrder(1)

_lImpFicha := MsgYesNo("Imprime O.S. ?")
mv_par01:=SC5->C5_NUM                            

If Empty(SC5->C5_TRANSP)
	Return
End	


x:="1;0;1;Pedido De Venda BRASEMBA"
CALLCRYS("PVBRAS",MV_PAR01,x)   

If _lImpFicha
	mv_par01:=SC5->C5_NUM                            
	x:="1;0;1;Ordem Servico BRASEMBA"
	CALLCRYS("os",mv_par01,x)   
End
/*/
_lImpAcess := MsgYesNo("Imprime fichas para acess¢rios ? Se houver ? ")

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	RestArea(_aArea)
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	RestArea(_aArea)
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//
// Processamento. RPTSTATUS monta janela com a regua de processamento. 
//

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
/*/
RestArea(_aArea)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea(cString)
dbSetOrder(1)

//
// SETREGUA -> Indica quantos registros serao processados para a regua 
//
SetRegua(RecCount())

SC6->(dbseek(xfilial("SC6")+SC5->C5_NUM))

_cTraco := "|"
_cIt    := "01"
_nTotPED:= 0

If nLin > 55
   CabPED()
   nLin := 25
EndIf   	


_cTraco := "|"

If lAbortPrint
	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	RestArea(_aArea)
	Return
Endif
	
If nLin > 55
   @ nLin,02 PSAY "*====*=========*=====*=================*======*=======*=======*=======*===========*=========*=============*===============*"
   CabPED()
   nLin := 25
EndIf   			

dbSelectArea("SB1")
dbSetOrder(1)
	
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xfilial("SA1")+SC5->C5_CLIENTE)	
	
	
dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xfilial("SC6")+SC5->C5_NUM)
	
_nRegIt := SC6->(Recno())		
_nTotPed := _nTotqtd := totipi:=0	

While SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM) .and. !eof()   

		 SB1->(dbSeek(xfilial("SB1")+SC6->C6_PRODUTO))
		                               
		 SZ1->(dbSeek(xFilial("SZ1")+SB1->B1_TPPAP))
		
		 cprod :=Subs(SB1->B1_COD,9,3)
	
    
         @ nLin,01 PSAY _cTraco+" "+SC6->C6_ITEM
         @ nLin,06 PSAY _cTraco+TRANS(SC6->C6_QTDVEN,"@Z 999999")+" "+SB1->B1_UM
         @ nLin,16 PSAY _cTraco+" "+cProd
         @ nLin,22 PSAY _cTraco+" "+LEFT(SC6->C6_DESCRI,15)
         @ nLin,40 PSAY _cTraco+" "+SZ1->Z1_COD
         @ nLin,47 PSAY _cTraco+" "+TRANS(SB1->B1_COMPR,"@ER 9.999")
         @ nLin,55 PSAY _cTraco+" "+TRANS(SB1->B1_LARG,"@ER 9.999")
         @ nLin,63 PSAY _cTraco+" "+TRANS(SB1->B1_ALTURA,"@ER 9.999")
         @ nLin,71 PSAY _cTraco+" "+LEFT(SB1->B1_ESPCOR,10)
         @ nLin,83 PSAY _cTraco+" "+If(SB1->B1_TPFECH='C','COLA',If(SB1->B1_TPFECH='G','GRAMPO',;
	                           If(SB1->B1_TPFECH='F','FITA',"S/FECH")))

//         @ nLin,93 PSAY _cTraco+TRANS(SC6->C6_PRCVEN,"@ER 9,999,999.999")
         @ nLin,93 PSAY _cTraco+TRANS(SC6->C6_PRCmix,"@ER 9,999,999.999")
//         @ nLin,107 PSAY _cTraco+" "+TRANS(SC6->C6_VALOR,"@ER 99,999,999.99")+" "+_cTraco
         @ nLin,107 PSAY _cTraco+" "+TRANS((SC6->C6_PRCMIX*sc6->c6_qtdven),"@ER 99,999,999.99")+" "+_cTraco

//         TOTIPI+=(SC6->C6_VALOR*SB1->B1_IPI)/100
         TOTIPI+=((SC6->C6_PRCMIX*sc6->c6_qtdven)*SB1->B1_IPI)/100
//         _nTotPed+= SC6->C6_VALOR
         _nTotPed+= SC6->C6_PRCMIX*sc6->c6_qtdven
         _nTotQtd+= SC6->C6_QTDVEN

         dbSKIP()

         nLin++
         IF nLin>32
            @ nLin,01 PSAY "*====*=========*=====*=================*======*=======*=======*=======*===========*=========*=============*===============*"
            nLin+=2
            @ nLin,02 PSAY "*** CONTINUACAO NA PAGINA SEGUINTE ........."         
//          NPAG++
            CABPED()
         ENDIF
	                     
End	 
	
@ nLin,01 PSAY "*====*=========*=====*=================*======*=======*=======*=======*===========*=========*=============*===============*"

Nlin++

@ nLin,56  PSAY "VALOR TOTAL         => "
@ nLin,109 PSAY TRANS(_nTotPed,"@ER 99,999,999.99")
nLin++
@ nLin,56 PSAY "VALOR TOTAL DO PEDIDO C/ IPI => "

@ nLin,109 PSAY TRANS(TOTIPI+_nTotPed,"@ER 99,999,999.99")
                            
/*
   OBS->(DBSETORDER(1))
   OBS->(DBSEEK(STRZERO(PED->ANO,4)+"P"+STRZERO(PED->NUMERO,6)))

   nLin+=2
   IF !OBS->(EOF())
      @ ct,01 say "OBS.: "
      @ CT+2,00 SAY +IF(OBS->(EOF()),REPL("_",79),;
      LEFT(OBS->OBS,75))
      @ CT+4,00 SAY IF(OBS->(EOF()),REPL("_",79),SUBS(OBS->OBS,76,75))
      @ CT+6,00 SAY IF(OBS->(EOF()),REPL("_",79),SUBS(OBS->OBS,151,75))
      CT+=6
   ENDIF
*/   

SE1->(dbSetOrder(8))  
SE1->(DBSEEK(xFilial("SE1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
_lFin := .F.
WHILE SE1->(E1_CLIENTE+E1_LOJA)==SC5->(C5_CLIENTE+C5_LOJACLI) .AND. !SE1->(BOF())
      IF SE1->E1_VENCTO < (dDataBase-1)
         _lFin := .T.
         Exit
      EndIf   
      SE1->(dbSkip())
End      

nLin+=2
@ nLin,02 PSAY "** EXISTE PENDENCIA **"

WHILE nLin<39
      nLin++
END

@ nLin,01 PSAY REPL("_",35)

@ nLin,45 PSAY REPL("_",35)

nLin++
@ nLin,01 PSAY PADC("vendedor",35)
@ nLin,45 PSAY PADC("Nome por Extenso Comprador",35)

dbSelectArea("SC5")

nLin++
@ nLin,50 PSAY "ASSINATURA E CARIMBO"

nLin++
      
@ nLin,01 PSAY "Emitido por : "//+;
          //RetUserName(RetCodUsr())+"  Hs.: "+time()

@ nLin++,01 PSAY "Conferencia : "//+ALLTRIM(RESPLIB)

@ nLin,73 PSAY "* DECLARO ESTAR DE ACORDO COM TODOS OS DADOS"

@ nLin+2,01 PSAY "Analise Critica Brasemba : _______________ Visto :_____________"

@ nLin+2,73 PSAY "  DESCRITOS ACIMA PARA A FABRICACAO DO PEDIDO."

@ nLin+3,73 PSAY "  E EVENTUAIS MUDANCAS FICO SUJEITO A CUSTOS EXTRAS."
@ nLin+4,01 PSAY "FAX => "+SA1->A1_FAX

/*
IF EMPTY(CLI->ANIVCOMP)
   @ CT+5,01 SAY "** "+ALLTRIM(CLI->CONTATO)+" PREENCHA  => "+;
                       "DIA/MES ANIVERSARIO : _____/_____"
ENDIF
*/

@ nLin+6 ,01 PSAY "*======================================================C O N D I C O E S  DA  V E N D A===================================*"
@ nLin+7 ,01 PSAY "|1 - FAVOR CONFIRMAR OU CANCELAR VIA FAX DENTRO DE 24 HORAS DA DATA DE RECEBIMENTO DESTE PEDIDO.                          |"
@ nLin+8 ,01 PSAY "|2 - A BRASEMBA NAO SE RESPONSABILIZA POR QUAISQUER PROMESSAS OU CONSIDERACOES VERBAIS DOS VENDEDORES. TODOS OS DADOS E   |"
@ nLin+9 ,01 PSAY "|    DEMAIS PARTICULARIDADES DEVEM SER REGISTRADAS POR ESCRITO NESTE PEDIDO, SEM EXCESSOES.                               |"
@ nLin+10,01 PSAY "|3 - O PEDIDO NAO PODERA SER CANCELADO EM HIPOTESE ALGUMA, UMA VEZ QUE GERA SERVICOS ESPECIFICOS E MERCADORIAS FABRICADAS |"
@ nLin+11,01 PSAY "|    SOB MEDIDA E DE USO EXCLUSIVO DE SUA EMPRESA.                                                                        |"
@ nLin+12,01 PSAY "|4 - SO ACEITAMOS DEVOLUCOES DE PRODUTOS POR DEFEITO DE FABRICACAO NO PRAZO DE 7 DIAS,RESSALVADOS AS CONDICOES DE         |"
@ nLin+13,01 PSAY "|    ARMAZENAGEM DOS MESMOS.                                                                                              |"
@ nLin+14,01 PSAY "|5 - PRODUTOS SUJEITOS A VARIACOES CLIMATICAS.                                                                            |"
@ nLin+15,01 PSAY "|6 - AS QUANTIDADES SOLICITADAS PODERAO OSCILAR EM 10% A MAIS OU A MENOS                                                  |"
@ nLin+16,01 PSAY "*=========================================================================================================================*"

IF _lImpFicha
   SC6->(DBGOTO(_nRegIT))    
   While SC6->(C6_FILIAL+C6_NUM) == SC5->(C5_FILIAL+C5_NUM) .and. !eof()                                  
   
         SB1->(dbSeek(xFilial('SB1')+SC6->C6_PRODUTO))
		 SZ1->(dbSeek(xFilial("SZ1")+SB1->B1_TPPAP))                   
		 _cFecha := If(SB1->B1_TPFECH='C','COLA',If(SB1->B1_TPFECH='G','GRAMPO',;
	                           If(SB1->B1_TPFECH='F','FITA',"S/FECH")))
		 
         U_IMP_FICHA("SC6","SC6->C6_PRODUTO","SC6->C6_QTDVEN",.F.,.T.,.F.,_lImpAcess,0,"SC6->C6_DESCRI","SZ1->Z1_COD","SB1->B1_MONTAG","SB1->B1_ESPCOR",;
								                                                       "_cFecha","SB1->B1_COMPR","SB1->B1_LARG","SB1->B1_ALTURA")
         SC6->(dbSkip())
   End                                      
    
EndIf

SET DEVICE TO SCREEN

//
// Se impressao em disco, chama o gerenciador de impressao...          
//

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
RestArea(_aArea)
Return

      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CABPED    ºAutor  ³Murilo Patriota     º Data ³  17/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cabecalho Pedido de Venda                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Brasemba                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cabped
			
@ 006,001 PSAY PADC("BRASEMBA INDUSTRIA DE EMBALAGENS LTDA",80)
@ 007,001 PSAY "Caixas, Chapas e Bobinas de Papelo Ondulado"
@ 008,001 PSAY "Rua Monte Azul Paulista, 389 - Parada de Taipas - SP - Capital
@ 009,001 PSAY "CEP 02883-050 Telefone (011) 39722182  Fax (011) 39713419
@ 010,001 PSAY "Home Page: www.brasemba.com.br e-mail:grupobrasemba@brasemba.com.br
@ 012,045 PSAY "Pedido :  "+SC5->C5_NUM
@ 014,001 PSAY "Cliente:   "+SA1->A1_NOME
@ 014,060 PSAY "Data:  "+DTOC(SC5->C5_EMISSAO)
@ 015,001 PSAY "Endereo:  "+SA1->A1_END
@ 015,043 PSAY "CEP:  "+TRANS(SA1->A1_CEP,"@R 99999-999")
@ 016,001 PSAY "Bairro:  "+SA1->A1_BAIRRO
@ 016,025 PSAY "Cidade:  "+SA1->A1_MUN
@ 016,051 PSAY "Estado:  "+SA1->A1_ESTADO
@ 017,001 PSAY "CNPJ/CPF:  "+TRANS(SA1->A1_CGC,"@R 99.999.999/9999-99")
@ 017,030 PSAY "Inscr. Est. :  "+SA1->A1_INSCR
@ 017,051 PSAY "Fone:  "+SA1->A1_TEL	
	
@ 019,001 PSAY "Local Entr. :  "+SA1->A1_ENDENT
@ 020,001 PSAY "Local Cobr. :  "+SA1->A1_ENDCOB


@ 21,01 PSAY "*====*=========*=====*=================*======*=======================*===========*=========*=============*===============*"
@ 22,01 PSAY "|ITEM|   QTD   | COD |     PRODUTO     | PAP. |   MEDIDAS DA CAIXA    |   IMPR.   | FECHAM. | VALOR UNIT. |  VALOR TOTAL  |"
@ 23,01 PSAY "|    |         |     |                 |      | COMPR | LARG. | ALT.  |           |         |  DA CAIXA   |               |"
@ 24,01 PSAY "*====*=========*=====*=================*======*=======*=======*=======*===========*=========*=============*===============*"
			
nLin := 25

RETURN

  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMP_FICHA ºAutor  ³Murilo Patriota     º Data ³  04/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao da Ficha                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Brasemba                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User FUNCTION IMP_FICHA(_cAlias,_cCod,QUANT,P1,PED,TEL,ACES,nLin,pDesc,pTippap,pMontag,pImpres,pFecha,pCompr,pLargura,pAltura)
LOCAL OP:=0,FIRST:=FIRST1:=.T.,TEL:=.F.,HP:=.F.
PRIVATE CAMPO1:=CAMPO2:=CAMPO3:=CAMPO4:=CAMPO5:=CAMPO6:=CAMPO7:="0"

                                                                                                                             
pDesc   :=&pDesc                   
pTipPap :=&pTippap
pMontag :=&pMontag
pImpres :=&pImpres
pFecha  :=&pFecha
pCompr  :=&pCompr
pLargura:=&pLargura
pAltura :=&pAltura

_cCod:=&_cCod
QUANT:=&QUANT

IF !PED

Private cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2         := "de acordo com os parametros informados pelo usuario."
Private cDesc3         := ""
Private cPict          := ""
Private titulo         := ""
Private nLin           := 80

Private Cabec1         := ""
Private Cabec2         := ""
Private imprime        := .T.
Private aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "IMPFIC" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "" 
Private cPerg	     := ""
Private cString      := "SC5"
Private cprod        := ""
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private VTP          :={{"M","MALETA     "},;
                             {"C","CORTE-VINCO"},;
                             {"A","ABA TRANSP."},;
                             {"I","ABA INF.   "},;
                             {"S","ABA SUP.   "},;
                             {"T","S/ ABA INF."},;
                             {"F","S/ ABA SUP."},;
                             {"B","BOBINA     "}}

//Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//
// Processamento. RPTSTATUS monta janela com a regua de processamento. 
//

RptStatus({|| FichaReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)   
EndIf   

ct:= nLin

CT:= 0
//DO WHILE &P1                                          
   SB1->(dbSeek(xfilial("SB1")+_cCod))
   SZ1->(dbSeek(xFilial("SZ1")+pTippap))
   
   cprod :=Subs(_cCod,9,3)

   IF PED
      IF (SB1->B1_ACESSOR="S" .AND. !ACES .AND. SB1->B1_QTCORTE==0) .OR.;
         SB1->B1_MONTAG=="B"
         dbSKIP()
//         Loop
      ENDIF
   ENDIF

   IF PED 
      @ CT,05 PSAY ">>>   ORDEM DE SERVICO (O.S.)   >>>"
      CT+=2
   ENDIF

   IF !PED .AND. !TEL  
      @ CT,40 PSAY "C U S T O"
      CT+=2
   ENDIF

   @ CT,01 PSAY "Cliente: "+SA1->A1_NOME

   IF PED
      @ CT,60 PSAY "Pedido  "+SC5->C5_NUM
   ENDIF
   CT++

   IF PED
      CT++
      IF SB1->B1_ACESSOR="S"
            QTACESS:=0
            REGACE:=RECNO()
            DO WHILE ITP->NUMERO==PED->NUMERO .AND. !BOF()
               DBSKIP(-1)
               IF QUANT>0
                  QTACESS:=QUANT
                  EXIT
               ENDIF
            ENDDO
            DBGOTO(REGACE)
      ENDIF

      IF SB1->B1_ACESSOR="S" .AND. SB1->B1_QTCAIXA>0
             QTCALC:=QTACESS*(IF(SB1->B1_QTCAIXA>0,SB1->B1_QTCAIXA,1))
             @ CT,01 PSAY "Quant. : "+LTRIM(TRANS(QTCALC+(QTCALC*0.10),;
                         "999999"))
      ELSE
             @ CT,01 PSAY "Quant. : "+LTRIM(TRANS(SC6->C6_QTDVEN+(SC6->C6_QTDVEN*0.10),"999999"))

      ENDIF     
      _cImpr :=''
      For _nc:=1 to 4        
          _cVar := "SB1->B1_COR"+STR(_nc,1)
          _cImpr+= If(!Empty(&_cVar),Tabela("70",&_cVar),'')
      Next                          
    
      @ CT,24 PSAY "Impr.  : "+If(Empty(_cImpr),LEFT(SB1->B1_ESPCOR,10),_cImpr) //IMPRESSAO

      @ CT,59 PSAY "Fech.: "+If(SB1->B1_TPFECH='C','COLA',If(SB1->B1_TPFECH='G','GRAMPO',;
                             If(SB1->B1_TPFECH='F','FITA',  If(SB1->B1_TPFECH='S','S/ FECH.',''))))

   ENDIF

   CT++
   @ CT,01 PSAY "Cod CX.: "+pDesc 

   IF PED
      @ CT,26 PSAY "F.IMP.: "+SB1->B1_CODFICH+;
      "  CLICHE: "+SB1->B1_CXCLICH+;
      "  FILA: "+SB1->B1_NFILFAC+;
      "  FACA: "+SB1->B1_NFACA
   ENDIF
   CT++

   IF TEL
      @ CT,01 SAY "Especificacao Pap. "+PAP->TIPO
   ELSE
      CT++
      @ CT,01 PSAY "Esp.Pap: "+pTippap // SB1->B1_TPPAP
                                       
      @ CT,22 PSAY "C  P  D: "+Subs(_cCod,9,3)+;
                  " No.ESBOCO: "+If(PED,SB1->B1_ESBOCO,'')+;
                  IF(PED," Prog Ent. : "+DTOC(SC6->C6_ENTREG)," ")
   ENDIF
   CT++


   CT++
   @ CT,01 PSAY "Med.Int: "+"C => "+TRANS(pCOMPR,"@ER 9.999")+;
                   "      L => "+TRANS(pLARGura,"@ER 9.999")+;
                   "      A => "+IF(pMONTAG $ "MAISTF",TRANS(pALTURA,"@ER 9.999"),;
               "     ")
   MONTC(pMontag,pCompr,pLargura,pAltura)

   LARGT:=IF(pMONTAG=="C",VAL(CAMPO1),VAL(CAMPO2))
   COMPT:=IF(pMONTAG$"MAISTF",VAL(CAMPO7),VAL(CAMPO2))

   VCOMP:={}
   VLARG:={}

   CALCSUG(pMontag)

   IF TEL .AND. LEN(VLARG)>0

      @ 00,55 SAY "SUGESTOES"

      FOR K=1 TO LEN(VLARG)
         LCOMP:=IF(K>LEN(VCOMP),VCOMP[LEN(VCOMP),1],VCOMP[K,1])
         LQTD :=IF(K>LEN(VCOMP),VCOMP[LEN(VCOMP),2],VCOMP[K,2])

         @ K,50 SAY STR(VLARG[K,1],5,3)+" X "+;
                STR(LCOMP,5,3)+" => "+STR(VLARG[K,2]*LQTD,4,1)+" P/ FL."
      NEXT

   ENDIF
          
   /*
   OBS->(DBSETORDER(2))
   OBS->(DBSEEK("E"+STRZERO(CLI->CODCLI,6)+STRZERO(PCLI->CODIGO,3)))
   
   VERIFICAR OBSERVACOES
   */

   IF .F. //!OBS->(EOF())

      LT:=1
      CT++
      FOR K=1 TO 10
          @ CT+K,04 SAY SUBS(OBS->OBS,LT,70)
          LT+=70
      NEXT

      CT+=K

      OBS->(DBSETORDER(2))
      OBS->(DBSEEK("T"+STRZERO(CLI->CODCLI,6)+STRZERO(PCLI->CODIGO,3)))

   ELSE

      //OBS->(DBSETORDER(2))
      //OBS->(DBSEEK("T"+STRZERO(CLI->CODCLI,6)+STRZERO(PCLI->CODIGO,3)))

      IF pMONTAG # "C"
          CT++
          @ CT,1 PSAY "            *========* *================* *========* *================*"
          CT++

          //@ CT,1 PSAY "
//          |        | |                | |        | |               >|"
            
            
          @ CT,1 PSAY "            |"+VTP[ASCAN(VTP,{|X|X[1]==SB1->B1_MONTAG}),2]+"| |                | |"+;
                      VTP[ASCAN(VTP,{|X|X[1]==pMONTAG}),2]+"| |"

          //@ CT,14 PSAY VTP[ASCAN(VTP,{|X|X[1]==SB1->B1_MONTAG}),2]
          //@ CT,44 PSAY VTP[ASCAN(VTP,{|X|X[1]==SB1->B1_MONTAG}),2]

          IF pMONTAG $ "MAIST"
             @ CT,63 PSAY "C="+CAMPO1
          ENDIF                                                      
          @ CT,70 PSAY ">|"
          CT++
          @ CT,1 PSAY "            |        | |                | |        | |               ||"
          CT++
          @ CT,1 PSAY " larg.|     |--------|||----------------|||--------|||----------------|====*"
          CT++
          @ CT,1 PSAY " total|     |         :                  :          :                 :    |"
          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,1,57)
          ENDIF
          */
          CT++
          @ CT,1 PSAY "      |     |         :                  :          :                |:    |"

          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,58,57)
          ENDIF
          */
          
          CT++
          
//    |     |         :                  :          :                |:    |"

          IF pMONTAG $ "MAISTF"
             @ CT,0 PSAY "A="+CAMPO2
          ENDIF                                      
          @ CT,7 PSAY "|     |         :                  :          :"
          IF pMONTAG $ "MAISTF"
             @ CT,57 PSAY "D = "+CAMPO3+" -->"
          ENDIF            
          @ CT,70 PSAY "|:    |""
          CT++
          IF HP
             @ CT,1 PSAY "      ³     ³         :                  :          :                ³:   ³"
          ELSE
             @ CT,1 PSAY "      |     |         :                  :          :                |:    |"
          ENDIF
          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,115,57)
          ENDIF
          */
          CT++
//        IF HP
//           @ CT,1 PSAY "      ³     ³         :                  :          :                ³:   ³"
//        ELSE
             @ CT,1 PSAY "      |     |"
             
//    |     |         :                  :          :                |:    |"             
//                    23                 42         53               70    76
//        ENDIF
          IF pMONTAG $ "MAISTF"
             @ CT,14 PSAY "F="+CAMPO5   
             @ CT,23 PSAY ":"
             @ CT,28 PSAY "G="+CAMPO4
             @ CT,42 PSAY ":"
             @ CT,44 PSAY "F="+CAMPO5
             @ CT,53 PSAY ":"
             @ CT,57 PSAY "G = "+CAMPO4
             @ CT,70 PSAY "|:"
             @ CT,72 PSAY "H=30"
             @ CT,76 PSAY "|"
          ELSE
             @ CT,19 PSAY CAMPO1
             @ CT,23 PSAY ":"
             @ CT,36 PSAY "X"
             @ CT,42 PSAY ":"             
             @ CT,50 PSAY CAMPO2
             @ CT,53 PSAY ":" 
             @ CT,70 PSAY "|:"
             @ CT,76 PSAY "|"                
                                      
          ENDIF

          CT++
          IF HP
             @ CT,1 PSAY "      ³     Ã--------ÂÁÂ----------------ÂÁÂ--------ÂÁÂ----------------ÅÄÄÄÙ"
          ELSE
             @ CT,1 PSAY "      |     |--------|||----------------|||--------|||----------------|====*"
          ENDIF
          CT++
          IF HP
             @ CT,1 PSAY "            ³        ³ ³                ³ ³        ³ ³                ³"
          ELSE
             @ CT,1 PSAY "            |        | |                | |        | |                |"
          ENDIF
          /*
          IF PED
             IF !EMPTY(ITP->OBSIT)
                @ CT,14 PSAY "* "+LEFT(ITP->OBSIT,46)
             ENDIF
          ENDIF
          */

          CT++
          
          /*
          IF PED
             IF !EMPTY(ITP->OBSIT)
                @ CT,14 PSAY "* "+SUBS(ITP->OBSIT,47,46)
             ENDIF
          ENDIF
          */   
          
          IF !PED .AND. !TEL .AND. OP#2
             IF HP
                @ CT,1 PSAY "            ³        ³ ³  A M O S T R A ³ ³        ³ ³                ³"
             ELSE
                @ CT,13 PSAY "|        | |  A M O S T R A | |        | |"
//          |        | |  A M O S T R A | |        | |                |"
             ENDIF
          ELSE
             IF HP
                @ CT,1 PSAY "            ³        ³ ³                ³ ³        ³ ³                ³"
             ELSE
                @ CT,13 PSAY "|        | |                | |        | |"
             ENDIF
          ENDIF
          IF pMONTAG $ "MAISF"
             @ CT,57 PSAY "B = "+CAMPO6                               
             @ CT,71 PSAY "|"
          ENDIF
          CT++
          IF HP
             @ CT,1 PSAY    "            ÀÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
          ELSE
             @ CT,1 PSAY    "            *========* *================* *========* *================*"
          ENDIF

      ELSE
      
          /*
          OBS->(DBSETORDER(2))
          OBS->(DBSEEK("T"+STRZERO(PCLI->CODCLI,6)+STRZERO(PCLI->CODIGO,3)))
          */

          CT++
          IF HP
             @ CT,1 PSAY "            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
          ELSE
             @ CT,1 PSAY "            *=========================================================*"
          ENDIF
          CT++
          IF HP
             @ CT,1 PSAY "            ³                                                         ³"
          ELSE
             @ CT,1 PSAY "            |                                                         |"
          ENDIF
            
          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,1,57)
          ENDIF
          */
          CT++
          IF HP
             @ CT,1 PSAY "            ³                                                         ³"
          ELSE
             @ CT,1 PSAY "            |                                                         |"
          ENDIF
          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,58,57)
          ENDIF
          */
          CT++
          IF HP
             @ CT,1 PSAY " larg.³     ³                                                         ³"
          ELSE
             @ CT,1 PSAY " larg.|     |                                                         |"
          ENDIF
          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,115,57)
          ENDIF
          */
          CT++
          IF HP
             @ CT,1 PSAY " total³     ³                                                         ³"
          ELSE
             @ CT,1 PSAY " total|     |                                                         |"
          ENDIF
          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,172,57)
          ENDIF
          */
          CT++
          IF HP
             @ CT,1 PSAY "      ³     ³                                                         ³"
          ELSE
             @ CT,1 PSAY "      |     |                                                         |"
          ENDIF
          /*
          IF PCLI->ACESS="S" .AND. PCLI->QTCORTE>0
             @ CT,14 PSAY CORTES
          ELSE
    
             IF !OBS->(EOF())
                @ CT,14 PSAY SUBS(OBS->OBS,229,57)
             ENDIF
          ENDIF
          */
          CT++
          @ CT,0 PSAY "I="+CAMPO1
          IF HP
             @ CT,7 PSAY "³     ³                                                         ³"
          ELSE
             @ CT,7 PSAY "|     |                                                         |"
          ENDIF
          /*
          IF !OBS->(EOF())
             @ CT,14 PSAY SUBS(OBS->OBS,286,57)
          ENDIF
          */

          CT++
          IF HP
             @ CT,1 PSAY "      ³     ³                                                         ³"
          ELSE
             @ CT,1 PSAY "      |     |                                                         |"
          ENDIF
          /*
             IF !OBS->(EOF())
                @ CT,14 PSAY SUBS(OBS->OBS,343,57)
             ENDIF
          */
          CT++
          IF HP
             @ CT,1 PSAY "      ³     ³                                                         ³"
          ELSE
             @ CT,1 PSAY "      |     |                                                         |"
          ENDIF
          /*
             IF !OBS->(EOF())
                @ CT,14 PSAY SUBS(OBS->OBS,400,57)
             ENDIF
          */   
          CT++
          IF HP
             @ CT,1 PSAY "      ³     ³                                                         ³"
          ELSE
             @ CT,1 PSAY "      |     |                                                         |"
          ENDIF
          /*
             IF !OBS->(EOF())
                @ CT,14 PSAY SUBS(OBS->OBS,457,57)
             ENDIF
          */
          CT++
          IF HP
             @ CT,1 PSAY "            ³                                                         ³    "
          ELSE
             @ CT,1 PSAY "            |                                                         |    "
          ENDIF
          /*
             IF !OBS->(EOF())
                @ CT,14 PSAY SUBS(OBS->OBS,514,57)
             ENDIF
          */
          CT++
          IF HP
             @ CT,1 PSAY "            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
          ELSE
             @ CT,1 PSAY "            *=========================================================*"
          ENDIF
          IF !PED .AND. !TEL .AND. OP#2
             CT++
             @ CT,1 PSAY "               A M O S T R A                A M O S T R A              "
          ENDIF

      ENDIF

   ENDIF

   CT++
   IF pMONTAG="C" //.AND. PCLI->ACESS="N"
      @ CT,01 PSAY "CORTE-VINCO"
      @ CT,50 PSAY "J = "+CAMPO2
   ENDIF
   IF pMONTAG $ "MAISTF"
      IF HP
         @ CT,7 PSAY "<ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ E="+CAMPO7+" ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>"
      ELSE
         @ CT,7 PSAY "<------------------------------ E="+CAMPO7+" ---------------------------->"
      ENDIF
   ELSE
      CT++
      IF HP
         @ CT,7 PSAY "<ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>"
      ELSE
         @ CT,7 PSAY "<------------------------------------------------------------------>"
      ENDIF
   ENDIF
   IF PED
      
      /*
      if !empty(pcli->obs)
         CT++
         @ CT,01 PSAY (&(IMP->EXPA_ON))+"FACA => "+(&(IMP->EXPA_OF))+(&(IMP->NEGR_ON))+PCLI->OBS+(&(IMP->NEGR_OF))
      endif
      */

      CT+=2
      @ CT,1 PSAY "Entr. 1-______2-______3-______ Qtd. Fabr._______ Amarrados ______C/______cxs."
      CT++
         
      /*
      IF PCLI->ACESS="N" .AND. PCLI->CODACESS1#0
         @ CT,01 PSAY REPL(IF(HP,"±","#"),77)
         CT+=1
         @ CT,01 PSAY IF(HP,"±","#")
         @ CT,25 PSAY (&(IMP->EXPA_ON))+"ACESSORIOS    OBS."+(&(IMP->EXPA_OF))
         @ CT,76 PSAY IF(HP,"±","#")
         CT+=1
         REGPCLI:=PCLI->(RECNO())
         XCODACESS1:=PCLI->CODACESS1
         XCODACESS2:=PCLI->CODACESS2
         XCODACESS3:=PCLI->CODACESS3
         XCODACESS4:=PCLI->CODACESS4

         FOR K:=1 TO 4
             VARIA:="XCODACESS"+STR(K,1)
             IF &VARIA#0
                PCLI->(DBSEEK(STRZERO(CLI->CODCLI,6)+STRZERO(&VARIA,3)))
                @ CT,01 PSAY IF(HP,"±","#")+"* QUANT :"+;
                TRANS(PCLI->QTCAIXA*(ITP->QUANT+(ITP->QUANT*0.10)),"999999")+;
                 "  "+IF(PCLI->QTCAIXA#0,TRANS(PCLI->QTCAIXA,"999")," ")+;
                     " P/ CAIXA"+;
                     "  MED. "+STR(PCLI->COMPR,5,3)+" x "+;
                     STR(PCLI->LARGURA,5,3)+"  "+;
                IF(PCLI->QTCORTE#0,TRANS(PCLI->QTCORTE,"999")+"  CORTES ","")+;
                IF(!EMPTY(PCLI->OBS),(&(IMP->COMP1))+LEFT(PCLI->OBS,48)+;
                  (&(IMP->NORMAL)),"")
                @ CT,77 PSAY IF(HP,"±","#")
                CT++
             ELSE
                EXIT
             ENDIF
         NEXT

         PCLI->(DBGOTO(REGPCLI))
         @ CT,01 PSAY IF(HP,"±","#")
         @ CT,77 PSAY IF(HP,"±","#")

         @ CT,01 PSAY REPL(IF(HP,"±","#"),77)

      ENDIF
      */

      IMP_CH:=.F.
      ULT_CH:=.F.


         K=1
         CT++
         LCOMP:=IF(K>LEN(VCOMP),VCOMP[LEN(VCOMP),1],VCOMP[K,1])
         IF LEN(VLARG)>0
            LLARG:=VLARG[K,1]
            LQTD :=IF(K>LEN(VCOMP),VCOMP[LEN(VCOMP),2],VCOMP[K,2])
            QTFL :=VAL(STR(VLARG[K,2]*LQTD,4,1))

            // Nao calcula 10 % nas chapas para compra
            // Sr. Emerson 02/02/98

            //*QTCH :=(ITP->QUANT+(ITP->QUANT*0.10)) / VAL(STR(VLARG[K,2]*LQTD,4,1))

            QTCH :=SC6->C6_QTDVEN / VAL(STR(VLARG[K,2]*LQTD,4,1))

            PESO :=(VAL(STR(VLARG[K,1],5,3))*LCOMP)*(SZ1->Z1_PESO / 1000) * ;
                 QTCH
         ELSE
            LLARG:=LQTD:=QTFL:=QTCH:=PESO:=0
         ENDIF

      
      ESTSN:=.F.
      
      /*
      IF ESTO->(DBSEEK(STRZERO(LLARG,5,3)+STRZERO(LCOMP,5,3)+PCLI->TIPO))
         IF ESTO->QUANT>=QTCH
            ESTSN:=.T.
         ENDIF
      ENDIF

      ITFOR->(DBSEEK(STRZERO(ITP->FORNEC,5)+PCLI->TIPO))
      PRET :=(PESO*ITFOR->PRECO)

      // INCLUINDO PEDIDO DE COMPRAS

      IF ALTCOMP
         CMP->(DBSEEK(STRZERO(PED->ANO,4)+"1"+STRZERO(PED->NUMERO,6)))
         IF CMP->(EOF())
            CMP->(DBAPPEND())
            CMP->STATUS:="1"
            CMP->NUMERO:=PED->NUMERO
            CMP->DATA  :=TDAT(T__DATA)
            CMP->CODCLI:=PED->CODCLI
            CMP->ANO   :=YEAR(TDAT(T__DATA))
         ELSE
            CMP->(RLOCK())
         ENDIF

         IF FIRST
            CMP->VALTOT :=0
            CMP->TOTPESO:=0
            CMP->QTDTOT :=0
            FIRST:=.F.
         ENDIF

         CMP->VALTOT :=CMP->VALTOT+PRET
         CMP->TOTPESO:=CMP->TOTPESO+PESO
         CMP->QTDTOT :=CMP->QTDTOT+QTCH
         CMP->(DBUNLOCK())

         ICMP->(DBSEEK(STRZERO(PED->ANO,4)+STRZERO(PED->NUMERO,6)+STRZERO(ITP->CODPROD,3)))
         ICMPFIM:=.F.
         IF ICMP->(EOF())
            ICMPFIM:=.T.
            ICMP->(DBAPPEND())
            ICMP->STATUS :="1"
            ICMP->NUMERO :=PED->NUMERO
            ICMP->CODPROD:=ITP->CODPROD
            ICMP->ANO    :=PED->ANO
         ELSE
            ICMP->(RLOCK())
         ENDIF
         IF ICMPFIM
            ICMP->CODCLI :=PED->CODCLI
            //ICMP->FORN   :=IF(ESTSN,5,FOR->COD)
            ICMP->QUANT  :=QTCH
            ICMP->CHAPA1 :=LLARG
            ICMP->CHAPA2 :=LCOMP
            ICMP->QTFOLHA:=QTFL
            ICMP->NCOD   :=IF(ESTSN,ESTO->TIPPAP,PAP->TIPO)
            ICMP->FCOD   :=IF(ESTSN,SPACE(5),ITFOR->FCOD)
            ICMP->PREUNIT:=IF(ESTSN,ESTO->PREUNIT,ITFOR->PRECO)
            IF ESTSN
               ICMP->KG  :=ESTO->KG
            ELSE
               ICMP->KG     :=IF(!EMPTY(PCLI->QTDCHAPA),PCLI->ULTCHAP1*PCLI->ULTCHAP2,;
                   (VAL(STR(LLARG,5,3))*LCOMP))*(PAP->GRAMATURA / 1000)
            ENDIF
            ICMP->PESOTOT:=PESO
            IF ESTSN
               ICMP->PRETOT:=PESO*ESTO->PREUNIT
            ELSE
               ICMP->PRETOT :=PRET
            ENDIF
            //ICMP->PAGTO  :=IF(ESTSN,SPACE(10),FOR->FORMAPAG)
            ICMP->ENTREGA:=IF(ESTSN,TDAT(T__DATA),TDAT(T__DATA)+5)
         ENDIF
         ICMP->(DBUNLOCK())

         IF ICMPFIM
            PCLI->(RLOCK())

            PCLI->ULTCHAP1:=LLARG
            PCLI->ULTCHAP2:=LCOMP
            PCLI->QTDCHAPA:=IF(!EMPTY(PCLI->QTDCHAPA),PCLI->QTDCHAPA,;
                         QTFL)
            PCLI->(DBUNLOCK())
         ENDIF

      ENDIF
      */

      @ CT,20 PSAY ">>==== CONTROLE DE INSPECAO ====<<"

      CT++

         @ CT+1 ,01 PSAY "*################## I N S P E C A O  D E  R E C E B I M E N T O ###############* ################ INSPECAO  DE  PROCESSO ###################"
         @ CT+2 ,01 PSAY "|-----*------------*----------*---------*--------------------------------------| PROCESSOS     Cod.Func Situacao        Data        Visto  "
         @ CT+3 ,01 PSAY "| Cod.| Nome       |   Data   |  Visto  |Ocorrencias/Providencias              | Vincada       [______] [____________]  ___/___/___ _______ "
         @ CT+4 ,01 PSAY "|     |            |  /   /   |         |                                      | Riscador      [______] [____________]  ___/___/___ _______ "
         @ CT+5 ,01 PSAY "|-----*------------*----------*---------*--------------------------------------| Impressora    [______] [____________]  ___/___/___ _______ "
         @ CT+06,01 PSAY "|######################### I N S P E C A O   F I N A L ########################| Serra         [______] [____________]  ___/___/___ _______ "
         @ CT+07,01 PSAY "|-----*------------*----------*---------*--------------------------------------| Corte e Vinco [______] [____________]  ___/___/___ _______ "
         @ CT+08,01 PSAY "| Cod.| Nome       |   Data   |  Visto  |Ocorrencias/Providencias              | Grampo        [______] [____________]  ___/___/___ _______ "
         @ CT+09,01 PSAY "|     |            |  /   /   |         |                                      | Cola          [______] [____________]  ___/___/___ _______ "
         @ CT+10,01 PSAY "*-----*------------*----------*---------*--------------------------------------* Amarracao     [______] [____________]  ___/___/___ _______ "

      CT+=11
      
         @ CT+1,01 PSAY "*=====*=======>> R E Q U I S I C A O   D E   C O M P R A <<====*=====*========*"
         @ CT+2,01 PSAY "| COD |FORNECEDOR |  QUANT  |QT p/ FL|    CHAPA    |Folha Vinc.|NCOD |  FCOD  |"
         @ CT+3,01 PSAY "*=====*===========*=========*========*=============*===========*=====*========*"

      CT+=4
      @ CT,01 PSAY _cTraco+" "+Substr(SB1->B1_COD,9,3)
      //@ CT,07 PSAY _cTraco+" "+LEFT(FOR->DESCRICAO,10)
      @ CT,19 PSAY _cTraco+" "+IF(ULT_CH,STR(QTCH,5)," ")
      @ CT,29 PSAY _cTraco+" "+IF(ULT_CH,STR(QTFL,5,1)," ")
      @ CT,38 PSAY _cTraco+IF(ULT_CH,STR(LLARG,5,3)+" x "+STR(LCOMP,5,3)," ")
      @ CT,52 PSAY _cTraco+" S[ ] N[ ]"
      //@ CT,64 PSAY _cTraco+ITFOR->NCOD
      //@ CT,70 PSAY _cTraco+ITFOR->FCOD
      @ ct,79 PSAY _cTraco
      ct++
      IF HP
         @ CT,01 PSAY "ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´"
      ELSE
         @ CT,01 PSAY "*-----*-----------*---------*--------*-------------*-----------*-----*--------*"
      ENDIF
                   
      CT++
      IF HP
         @ CT,01 PSAY "³     ³           ³         ³        ³             ³           ³     ³        ³"
      ELSE
         @ CT,01 PSAY "|     |           |         |        |             |"
//|     |           |         |        |             |           |     |        |"
      ENDIF
      IF SB1->B1_MONTAG#"C"         
         @ CT,53 PSAY CAMPO1+"x"+CAMPO3+"x"+CAMPO6
         @ CT,79 PSAY _cTraco
      Else                           
		 @ CT,64 PSAY "|     |        |"      
      ENDIF                                                                     
      CT++
      IF HP
         @ CT,01 PSAY "ÔÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¾"
      ELSE
         @ CT,01 PSAY "*-----*-----------*---------*--------*-------------*-----------*-----*--------*"
      ENDIF
      CT++
      @ CT,00 PSAY REPL("-",80)
      CT++

         @ CT,11   PSAY "*============*=========*==============*============*=========*"
         @ CT+1,11 PSAY "|Pr.Un.      |   Peso  |     P. Total |      Pagto | P. Entr |"
         @ CT+2,11 PSAY "*============*=========*==============*============*=========*"
      

      CT+=3
      
      /*
      @ CT,11 PSAY _cTraco+" "+TRANS(ITFOR->PRECO,"@ZER 999,999.99")
      @ CT,24 PSAY _cTraco+" "+STR(PESO,7)
      @ CT,34 PSAY _cTraco+" "+TRANS(PRET,"@ZER 9,999,999.99")
      @ CT,49 PSAY _cTraco+" "//+FOR->FORMAPAG
      @ CT,62 PSAY _cTraco
      @ CT,72 PSAY _cTraco
      */

      CT++
      IF HP
         @ CT,11 PSAY "ÔÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¾"
      ELSE
         @ CT,11 PSAY "*============*=========*==============*============*==========*"
      ENDIF
      CT++
      @ CT  ,09 PSAY "*==>> FOLHA EXTRA P/ ESTOQUE (DIGITAR NO PEDIDO DE COMPRA) <<==*"
      @ CT+1,09 PSAY "|FORNECEDOR |  QUANT  |    CHAPA    |Folha Vinc.|NCOD |  FCOD  |"
      @ CT+2,09 PSAY "*===========*=========*=============*===========*=====*========*"
      
      CT+=3

      @ CT,09 PSAY _cTraco
      @ CT,21 PSAY _cTraco
      @ CT,31 PSAY _cTraco
      @ CT,45 PSAY _cTraco+" S[ ] N[ ]"
      @ CT,57 PSAY _cTraco
      @ CT,63 PSAY _cTraco
      @ ct,72 PSAY _cTraco

      CT++
      IF HP
         @ CT,09 PSAY "ÔÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¾"
      ELSE
         @ CT,09 PSAY "*===========*=========*=============*===========*=====*========*"
      ENDIF

   ELSE

      CT+=2

      @ CT,1 PSAY "Ficha de Impressao No.. "+LTRIM(SB1->B1_CODFICH)
      @ CT,30 PSAY "Caixa do Cliche    No.. "+LTRIM(SB1->B1_CXCLICH)
      CT++
      @ CT,1 PSAY "Peso da Caixa.......... "+TRANS(SB1->B1_PESO,"@ER 9,999.99")
      @ CT,40 PSAY "=> .................... "+;
                                 LTRIM(TRANS(SB1->B1_CUSTD,"@ER 99,999.999"))

      IF !TEL .AND. LEN(VLARG)>0
         CT+=2

         @ CT,32 PSAY "SUGESTOES PARA CHAPAS"

         CT+=2
         FOR K=1 TO LEN(VLARG)
            LCOMP:=IF(K>LEN(VCOMP),VCOMP[LEN(VCOMP),1],VCOMP[K,1])
            LQTD :=IF(K>LEN(VCOMP),VCOMP[LEN(VCOMP),2],VCOMP[K,2])

            @ CT++,29 PSAY STR(VLARG[K,1],5,3)+" X "+;
                   STR(LCOMP,5,3)+" => "+STR(VLARG[K,2]*LQTD,4,1)+" CX P/ FL."
         NEXT

      ENDIF

   ENDIF

//   (_cAlias)->(dbSKIP())

//   CT:=0

//ENDDO   


IF !PED

	SET DEVICE TO SCREEN
	//
	// Se impressao em disco, chama o gerenciador de impressao...          
	//
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()
EndIf

RETURN .T.

*******************************************************************************
STATIC FUNCTION IMP_FAC(P1)
*******************************************************************************
LOCAL OP:=0,FIRST:=FIRST1:=.T.

HP:=IF(AT("HP",IMP->IMPRESSORA)#0,.T.,.F.)

IMP:=0

CT:=01

SELE PED
DBCLEARREL()

ORDPEDE:=PED->(INDEXORD())
REGPEDE:=PED->(RECNO())


SELE ITP

ORDITP:=INDEXORD()
REGPEG:=RECNO()


DO WHILE &P1 

   IF SB1->B1_MONTAG#"C" .OR. (PCLI->NFILA=0.AND.PCLI->NFACA=0)
      DBSKIP()
      LOOP
   ENDIF


   @ CT,19 PSAY &(IMP->EXPA_ON)+">>> FICHA DE FACA >>>"+(&(IMP->EXPA_OF))

   CT+=2

   @ CT,01 PSAY (&(IMP->NEGR_ON))+"Faca n§    : "+(&(IMP->NEGR_of))+;
               STRZERO(PCLI->NFACA,4)+" Fila : "+STRZERO(PCLI->NFILA,2)+;
               (&(IMP->NEGR_ON))+"Fabrica‡„o : "+(&(IMP->NEGR_OF))+DTOC(FAC->DTFABRIC)+;
               (&(IMP->NEGR_ON))+"  Pedido : "+(&(IMP->NEGR_OF))+;
                  TRANS(PED->NUMERO,"@R 99/9999")

   CT+=2
   @ CT,01 PSAY (&(IMP->NEGR_ON))+"Cliente    : "+(&(IMP->NEGR_OF))+LEFT(CLI->NOME,30)

   @ CT,40 PSAY (&(IMP->NEGR_ON))+"C.P.D.: "+(&(IMP->NEGR_OF))+;
               STRZERO(ITP->CODPROD,3)

   @ CT,65 PSAY (&(IMP->NEGR_ON))+"Produto : "+PCLI->DESCRICAO+;
               (&(IMP->NEGR_OF))

   CT+=2

   FAC->(DBSEEK(PCLI->NFACA))

   @ CT,01 PSAY (&(IMP->NEGR_ON))+"Med. Corte : "+;
              (&(IMP->NEGR_OF))+;
               TRANS(FAC->MEDIDA1,"@ER 9.999")+" X "+;
               TRANS(FAC->MEDIDA2,"@ER 9.999")+;
               (&(IMP->NEGR_ON))+" Medidas Internas : "+(&(IMP->NEGR_OF))+;
               TRANS(FAC->MEDINT1,"@ER 9.999")+" X "+;
               TRANS(FAC->MEDINT2,"@ER 9.999")+" X "+TRANS(FAC->MEDINT3,"@ER 9.999")

   CT+=2
   @ CT,01 PSAY (&(IMP->NEGR_ON))+" Previsao de Batidas : "+(&(IMP->NEGR_OF))+;
               TRANS(FAC->PREVQUANT,"99999")+;
               (&(IMP->NEGR_ON))+" Total Acumulado : "+(&(IMP->NEGR_OF))+;
               TRANS(FAC->QUANTBAT,"99999")+;
               (&(IMP->NEGR_ON))+" Saldo : "+(&(IMP->NEGR_OF))+;
               TRANS(FAC->PREVQUANT-FAC->QUANTBAT,"99999")

   CT+=2

   @ CT,01 PSAY (&(IMP->NEGR_ON))+"Revis„o em : "+(&(IMP->NEGR_OF))+;
                  "__/__/__"+(&(IMP->NEGR_ON))+;
                  "  Aprovado Por : "+(&(IMP->NEGR_OF))+;
                  "______________ Visto _______"

   CT+=2


   PED->(DBSETORDER(5))

   ORDITP:=INDEXORD()
   REGPEG:=RECNO()

   DBSETORDER(6)
   DBSEEK(STRZERO(FAC->NUMERO,4))

   IF  !EOF()

       TOTACU:=ITP->QUANT

       @ CT  ,01 PSAY "ÕÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸"
       @ CT+1,01 PSAY "³  Data  ³ Pedido ³Cliente                                 ³ Caixas Produzidas³"
       @ CT+2,01 PSAY "ÆÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ"

       CT+=3

       DO WHILE PCLI->NFACA==ITP->NFACA .AND. !EOF()

          CLI->(DBSEEK(ITP->CODCLI))
          PED->(DBSEEK(STRZERO(ITP->ANO,4)+STRZERO(ITP->NUMERO,6)))

          @ CT,01 PSAY "³"+DTOC(PED->DATA)
          @ CT,10 PSAY "³ "+TRANS(PED->NUMERO,"@R 99/9999")
          @ CT,19 PSAY "³"+LEFT(CLI->NOME,40)
          @ CT,60 PSAY "³"+SPACE(13)+TRANS(ITP->QUANT,"99999")+"³"
          CT++

          DBSKIP()

       ENDDO

       @ CT,01 PSAY "ÔÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾"

   ENDIF

   SELE ITP
   SKIP
   CT:=1

ENDDO

PED->(DBSETORDER(ORDPEDE))
PED->(DBGOTO(REGPEDE))

DBSETORDER(ORDITP)
DBGOTO(REGPED)

SELE PED
DBSETORDER(IF(VENDAS,7,1))

DBSETRELATION("ITP",{||STRZERO(PED->ANO,4)+STRZERO(PED->NUMERO,6)},;
                      "STRZERO(PED->ANO,4)+STRZERO(PED->NUMERO,6)")

DBSETRELATION("OBS",{||STRZERO(PED->ANO,4)+"P"+STRZERO(PED->NUMERO,6)},;
             "STRZERO(PED->ANO,4)+'P'+STRZERO(PED->NUMERO,6)")

DBSETRELATION("VEN",{||PED->VENDEDOR},"PED->VENDEDOR")

DBSETRELATION("CLI",{||PED->CODCLI}, "PED->CODCLI")

SELE ITP

RETURN .T.


*******************************************************************************
STATIC FUNCTION MONTC(pMontag,pCompr,pLargura,pAltura)
*******************************************************************************

CPES:= SZ1->Z1_AJUSTE / 1000 //PAP->CALCPESO/1000  VERIFICAR UTILIZACAO

IF pMONTAG $ "MAISTF"

   IF pMONTAG $ "MATF"
      IF pMONTAG=="M" .OR. pMONTAG=="T"
         CAMPO1:=STR((pLARGURA/2)+CPES,5,3)
      ELSEIF pMONTAG=="A"
//         CAMPO1:=STR(pMONTAG+CPES,5,3)
         CAMPO1:=STR(1+CPES,5,3)
      ELSEIF pMONTAG=="F"
         CAMPO1:="0"
      ENDIF

      IF pMONTAG $ "TF"
         CAMPO2:=STR((pLargura/2)+(2*CPES)+(pALTURA+CPES+0.001),5,3)
      ELSE
         CAMPO2:=STR((pLargura)+(2*CPES)+IF(pMONTAG=="A",;
                  pLARGura,0)+(pALTURA+CPES+0.001),5,3)
      ENDIF
      CAMPO3:=STR((pALTURA+CPES+0.001),5,3)
      CAMPO4:=STR(pCOMPR+CPES,5,3)
      CAMPO5:=STR(pLARGURA+CPES,5,3)

      CAMPO6:=IF(pMONTAG=="T","0",IF(pMONTAG=="M" .OR. ;
                 pMONTAG=="F",STR((pLARGura/2)+CPES,5,3),;
                 CAMPO1))
      CAMPO7:=STR( ((pCOMPR+CPES)*2)+((pLargura+CPES)*2)+0.030,5,3)
   ELSE
      IF pMONTAG=="S"
         CAMPO1:=STR(pLARGura+CPES,5,3)

         CAMPO2:=STR(pLARGura+(2*CPES)+;
                 (pALTURA+CPES+0.001)+(pLARGura/2),5,3)
         CAMPO3:=STR((pALTURA+CPES+0.001),5,3)
         CAMPO4:=STR(pCOMPR+CPES,5,3)
         CAMPO5:=STR(pLARGura+CPES,5,3)

         CAMPO6:=STR((pLARGura/2)+CPES,5,3)
         CAMPO7:=STR( ((pCOMPR+CPES)*2)+((pLARGura+CPES)*2)+0.030,5,3)

      ELSE

         CAMPO1:=STR((pLargura/2)+CPES,5,3)
         CAMPO2:=STR(pLargura+(2*CPES)+(pAltura+CPES+0.001)+;
                 (pLargura/2),5,3)
         CAMPO3:=STR((pAltura+CPES+0.001),5,3)
         CAMPO4:=STR(pCOMPR+CPES,5,3)
         CAMPO5:=STR(pLargura+CPES,5,3)

         CAMPO6:=STR(pLargura+CPES,5,3)
         CAMPO7:=STR( ((pCompr+CPES)*2)+((pLargura+CPES)*2)+0.030,5,3)

      ENDIF

   ENDIF                        
   
   /*
   CAMPO1:=IF(!EMPTY(PCLI->MEDIDA1),STR(PCLI->MEDIDA1,5,3),CAMPO1)
   CAMPO2:=IF(!EMPTY(PCLI->MEDIDA2),STR(PCLI->MEDIDA2,5,3),CAMPO2)
   CAMPO3:=IF(!EMPTY(PCLI->MEDIDA3),STR(PCLI->MEDIDA3,5,3),CAMPO3)
   CAMPO4:=IF(!EMPTY(PCLI->MEDIDA4),STR(PCLI->MEDIDA4,5,3),CAMPO4)
   CAMPO5:=IF(!EMPTY(PCLI->MEDIDA5),STR(PCLI->MEDIDA5,5,3),CAMPO5)
   CAMPO6:=IF(!EMPTY(PCLI->MEDIDA6),STR(PCLI->MEDIDA6,5,3),CAMPO6)
   CAMPO7:=IF(!EMPTY(PCLI->MEDIDA7),STR(PCLI->MEDIDA7,5,3),CAMPO7)
   */
   
ELSE
         
   
   //   inibido em 20/08/08 - Murilo 
   
   CAMPO1:=IF(!EMPTY(SB1->B1_MEDIDA1),STR(SB1->B1_MEDIDA1,5,3),;
           STR(SB1->B1_COMPR+IF(SB1->B1_AJUSTE="S",0.030,0),5,3))
   CAMPO2:=IF(!EMPTY(SB1->B1_MEDIDA2),STR(SB1->B1_MEDIDA2,5,3),;
           STR(SB1->B1_LARG+IF(SB1->B1_AJUSTE="S",0.030,0),5,3))
                             
   
  // CAMPO1:=STR(pCOMPR,5,3)
  // CAMPO2:=STR(pLargura,5,3)
   
   IF(!EMPTY(SB1->B1_MEDIDA2),STR(SB1->B1_MEDIDA2,5,3),;
           STR(SB1->B1_LARG+IF(SB1->B1_AJUSTE="S",0.030,0),5,3))
            
ENDIF

RETURN NIL

******************************************************************************
STATIC FUNCTION CALCSUG(pMontag)
******************************************************************************

VCOMP:={}
VLARG:={}

IF LARGT<=0.800

   IF LARGT*2>0.800 .AND. LARGT>=0.800
      AADD(VLARG,{0.900,IF(LARGT*2 <= 0.90,2,1)})
   ENDIF

   FOR Y=1 TO 5
      IF LARGT*Y>=0.900
         EXIT
      ENDIF
   NEXT

   TT:=Y

   IF Y>1

      FOR K=Y TO 5
          IF (LARGT*TT)>1.600
             EXIT
          ENDIF
          CALC:=(LARGT*TT)+IF(pMONTAG=="C",0.030,0)
          CALC:=IF(VAL(SUBS(STR(CALC,5,3),4,1))#0,;
                ROUND(VAL(SUBS(STR(CALC,5,3),1,3)+"5"+;
                      SUBS(STR(CALC,5,3),5,1)),1),;
                      VAL(SUBS(STR(CALC,5,3),1,4)+"0"))
          AADD(VLARG,{CALC,TT})
          TT++
      NEXT

   ENDIF

ELSE

   IF LARGT<=0.907
      AADD(VLARG,{0.900,1})
   ELSE

      IF LARGT>1.600
         VLARG:={}
      ELSE
         CALC:=LARGT+IF(pMONTAG=="C",0.030,0)
         CALC:=IF(VAL(SUBS(STR(CALC,5,3),4,1))#0,;
              ROUND(VAL(SUBS(STR(CALC,5,3),1,3)+"5"+;
                  SUBS(STR(CALC,5,3),5,1)),1),CALC)
         AADD(VLARG,{CALC,1})
      ENDIF

   ENDIF

ENDIF

IF COMPT<0.720

   IF COMPT>=0.800
      CALC:=(COMPT*2)+IF(pMONTAG=="C",0.030,0)
      CALC:=IF(VAL(SUBS(STR(CALC,5,3),5,1))<8,;
            VAL(SUBS(STR(CALC,5,3),1,4)+"0"),;
            CALC)
      AADD(VCOMP,{CALC,2})
   ELSE
      CALC:=(COMPT*3)+IF(pMONTAG=="C",0.030,0)
      CALC:=IF(VAL(SUBS(STR(CALC,5,3),5,1))<8,;
            VAL(SUBS(STR(CALC,5,3),1,4)+"0"),;
            CALC)
      AADD(VCOMP,{CALC,3})
   ENDIF

ELSE

   IF COMPT<=2.700
      CALC:=(COMPT + IF(pMONTAG#"C",0.030,0))
      CALC:=IF(VAL(SUBS(STR(CALC,5,3),5,1))<8,;
            VAL(SUBS(STR(CALC,5,3),1,4)+"0"),;
            CALC)
      AADD(VCOMP,{CALC,1})

   ELSE
      CALC:=((COMPT /2) + IF(pMONTAG#"C",0.045,0))
      CALC:=IF(VAL(SUBS(STR(CALC,5,3),5,1))<8,;
            VAL(SUBS(STR(CALC,5,3),1,4)+"0"),;
            CALC)
      AADD(VCOMP,{CALC,0.5})
   ENDIF

ENDIF

RETURN NIL


Static Function IniImpr

Return


Static Function FichaReport(Cabec1,Cabec2,Titulo,nLin)
//
// SETREGUA -> Indica quantos registros serao processados para a regua 
//
SetRegua(RecCount())
Return