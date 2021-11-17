#include "rwmake.ch"        
#include "topconn.ch"

/*/
Programa: BRFAT086  Autor:  Cleber Orati Domingues     
Data:     27/01/2002
Descricao:Rel Tabela de PRecos
Ajuste: Para impressЦo nos representantes - 13/01/04 - Gustavo

/*/
User Function BRFAT086() 

     Private mv_par01,mv_par02
     mv_par02 = 1

     SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
     SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
     SetPrvt("CCABEC,CCABPRO,CNATUREZA,ARETURN,NOMEPROG,CPERG")
     SetPrvt("NLASTKEY,LCONTINUA,NLIN,NCOL,WNREL,NTIPO")
     SetPrvt("M_PAG,CCABEC1,CCABEC2,CCABEC3,NTAMNF,CSTRING")
     SetPrvt("CQUERY,_TOTALG,_TOTFIN,_TOTESTE,_TOTESTS,LIMPEST")
     SetPrvt("LIMPFIN,_DTGERAD,_NRAVAR,_TOTAL,_SALIAS,AREGS")

     CbTxt    := ""
     CbCont   := 0
     nOrdem   := 0
     Alfa     := 0
     Z        := 0
     M        := 0
     tamanho  := "G"
     limite   := 132
     titulo   := "TABELA DE PRECOS"
     cDesc1   := PADC("Este programa ira emitir a Tabela de Precos",74)
     cDesc2   := ""
     cDesc3   := PADC(" ",74)
     cCabec   := PADC("Tabela de Precos",27)
     cCabPro  := ""
     cNatureza:= ""
     aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
     nomeprog := "BRFAT086"
     cPerg    := "BRFT86"
     nLastKey := 0
     lContinua:= .T.
     wnrel    := "BRFAT086"
     nTipo    := 15
     m_pag    := 01
     cCabec1  := "CODIGO        NOME DO PRODUTO                CATALISADOR"
     cCabec2  := ""   
     cCabec3  := ""

     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Verifica as perguntas selecionadas, busca o padrao                      Ё
     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

     cString  :="SB1"

     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Envia controle para a funcao SETPRINT                        Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     
     if !u_VldAcesso(funname())
     	MsgBox("Acesso nЦo autorizado!---->"+funname(),"AtenГЦo","Alert")
     	return 
     endif 

     //ValidPerg() DESABILITADA RELEASE 12.1.25
     Pergunte("BRFT32",.F.)   

     wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,,,Tamanho)

     If nLastKey == 27
        Return
     Endif
     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Verifica Posicao do Formulario na Impressora                 Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

     SetDefault(aReturn,cString)

     If nLastKey == 27
        Return
     Endif


     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Inicio do Processamento do Relatorio                         Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     RptStatus({|| RptDetail()})
     
Return

Static Function RptDetail()

     Local  cAux,cQuery
     Private cArqCab := ""
     @ 000, 001 PSAY Chr(15)                  // Compressao de Impressao

     dbSelectArea("SZ5")
     dbsetorder(1)

     ImprCols := {} // Vetor c/ Nros das Colunas a IMprimir
     AADD(ImprCols,059)
     AADD(ImprCols,071)
     AADD(ImprCols,083)
     AADD(ImprCols,095)
     AADD(ImprCols,107)
     AADD(ImprCols,119)      
     cQuery = "WITH TMP AS (SELECT DISTINCT SZ1.Z1_LINHA,SUBSTRING(B.B1_COD,6,2) AS COR,"+;
     "SUBSTRING(B.B1_COD,8,3) AS VARICOR,"+;
     "SUBSTRING(B.B1_COD,1,3) AS CARAC, SZ1.Z1_DESCR, SUBSTRING(B.B1_COD,1,10) AS CODPI, "+;
     "LTRIM(B.B1_DESC) AS DESCR,"+;
     "B.B1_CATALIS,B.B1_RELCAT1 AS RELCAT "+;
     "FROM "+RetSqlName("SB1")+" B WITH (NOLOCK) "+;
     "LEFT OUTER JOIN "+RetSqlName("SZ1")+" SZ1 WITH (NOLOCK) ON (SZ1.D_E_L_E_T_ <> '*') AND (SZ1.Z1_FILIAL = '"+xFilial("SZ1")+"') AND (SUBSTRING(B.B1_COD,4,2) = SZ1.Z1_LINHA) "+;
     "WHERE (B.B1_FILIAL = '"+xFilial("SB1")+"') "
     cAux := U_ParamSql("SUBSTRING(B.B1_COD,4,2)",MV_PAR01)
     if !empty(cAux)
     	cQuery += "AND "+cAux+" "
     endif 
     cQuery += "AND (LEN(B.B1_COD) = 12) AND (B1_TIPO = 'PA') "+;
     "AND (B.D_E_L_E_T_ <> '*')) "+;
     "SELECT TMP.*,SB1.B1_ESTOQUE,PRECO = CASE WHEN SB1.B1_ESTOQUE = 'S' THEN SB1.B1_PRV1 ELSE SB5.B5_PRV2 END,SB1.B1_COD AS CODPRO,Z5_DESCR FROM TMP "+;
     "LEFT OUTER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON (SB1.D_E_L_E_T_ <> '*') AND "+;
     "(SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND (TMP.CODPI = SUBSTRING(SB1.B1_COD,1,10)) "+;
     "LEFT OUTER JOIN "+RetSqlName("SB5")+" SB5 WITH (NOLOCK) ON (SB5.D_E_L_E_T_ <> '*') AND (SB1.B1_FILIAL = SB5.B5_FILIAL) AND (SB1.B1_COD = SB5.B5_COD) "+;
     "LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') AND (SZ5.Z5_FILIAL = '"+xFilial("SZ5")+"') AND (SUBSTRING(SB1.B1_COD,11,2) = Z5_EMB) "+;
     "WHERE (SB1.B1_VEND <> 'N') AND (SB1.B1_MSBLQL <> '1') AND (LEN(SB1.B1_COD) = 12) AND (SB1.B1_TIPO = 'PA') "
     if mv_par02 == 1
     	cQuery += "AND (SB1.B1_ESTOQUE = 'S') "
     endif 
     cQuery = cQuery+"ORDER BY Z1_LINHA,DESCR,COR,CODPRO"

     TCQUERY cQuery NEW ALIAS "TMP"

	cQuery := "WITH TMP AS (SELECT SUBSTRING(B1_COD,4,2) AS LINHA,SUBSTRING(B1_COD,11,2) AS EMBA,COUNT(R_E_C_N_O_) AS QTDE,"+;
	"RANK() OVER (PARTITION BY SUBSTRING(B1_COD,4,2) ORDER BY SUBSTRING(B1_COD,11,2),COUNT(R_E_C_N_O_) DESC) AS R "+;
	"FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) "+;
	"WHERE (SB1.D_E_L_E_T_ <> '*') AND (B1_FILIAL = '"+xFilial("SB1")+"') AND (SB1.B1_VEND <> 'N') AND (SB1.B1_MSBLQL <> '1') AND (LEN(B1_COD) = 12) AND (B1_TIPO = 'PA') "
     cAux := U_ParamSql("SUBSTRING(SB1.B1_COD,4,2)",MV_PAR01)
     if !empty(cAux)
     	cQuery += "AND "+cAux+" "
     endif 

     if mv_par02 == 1
     	cQuery += "AND (SB1.B1_ESTOQUE = 'S') "
     endif 
	cQuery += "GROUP BY SUBSTRING(B1_COD,4,2),SUBSTRING(B1_COD,11,2)) "+;
	"SELECT TMP.*,Z5_DESCR FROM TMP "+;
	"LEFT OUTER JOIN "+RetSqlName("SZ5")+" SZ5 WITH (NOLOCK) ON (SZ5.D_E_L_E_T_ <> '*') AND (TMP.EMBA = Z5_EMB) "+;
	"WHERE TMP.R < 7 "+;
	"ORDER BY LINHA,EMBA"         
	
     TCQUERY cQuery NEW ALIAS "TMPC"
     dbSelectArea("TMPC")
     dbgotop()


     dbSelectArea("TMP")
     dbgotop()

     //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Inicializa  regua de impressao                            Ё
     //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     SetRegua(Reccount())
  
     iNroLin = 9
     nNroPag = 0

     Cabecalho()
//     GeraCols()
     cabecalho2()
     LinhaProd()
     cTipo := TMP->Z1_LINHA
     DbSelectArea("SB1")
     DbSetOrder(1)
     DbSelectArea("TMP")
     DbGoTop()
  
     SetRegua(Reccount())

     While ! Eof()      
           If iNroLin >= 50
                iNroLin := iNroLin + 1
              @ iNroLin,000 psay replicate("=",limite)
              Cabecalho()  
              Cabecalho2()
           Endif
           ImprReg()
           DbSelectArea("TMP")	            
           If !Eof() .AND. (cTipo != TMP->Z1_LINHA)
              cTipo := TMP->Z1_LINHA              
              iNroLin = iNroLin+1
              @iNroLin,00 psay replicate("=",limite)
              If iNroLin >= 50
                 cabecalho()
              Endif
              Cabecalho2()   
              LinhaProd()
           Endif
           DbSelectArea("TMP")              
           IncRegua()
     EndDo
     iNroLin := iNroLin+1
     @iNroLin,00 psay replicate("=",limite)

     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё                      FIM DA IMPRESSAO                        Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

     DbSelectArea("TMP")
     DbCloseArea()
     DbSelectArea("TMPC")
     DbCloseArea()

     /*
     If File(cArqCab+".dtc")
        cAux = cArqCab+".dtc"
        Delete File &cAux
     Endif
     If File(cArqCab+".cdx")
        cAux = cArqCab+".cdx"
        Delete file &cAux
     Endif
     */
     DbSelectArea("SB1")
     Set Device To Screen
     If aReturn[5] == 1
        Set Printer TO
        DbCommitAll()
        OurSpool(wnrel)
     Endif

Return

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё                   FUNCOES ESPECIFICAS                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

/*/
Programa: VALIDPERG   Autor:  Fernando Roquete     
Data:     05/06/01
Descricao:Grava Perguntas
/*/
/*
Static Function ValidPerg()
        Local aHelp := {}
       _sAlias := Alias()
       dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs:={}
 AAdd(aHelp, {{"Informe a Linha de Produto"},  {"Informe a Linha de Produto"}, {"Informe a Linha de Produto"}})
 AAdd(aHelp, {{"Apenas Prod Estoque?"},  {"Apenas Prod Estoque?"}, {"Apenas Prod Estoque?"}})
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
PutSX1(cPerg,"01","Linha(s) Produto"    ,"Linha(s) Produto"    ,"Linha(s) Produto"     ,"mv_ch1" ,"C",99,00,00,"G","","","","","mv_Par01",""   ,""  ,""   ,"" ,""   ,""  ,""  ,"","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")
PutSx1(cPerg,"02","Apenas Prod Estoque?","Apenas Prod Estoque?", "Apenas Prod Estoque?", "mv_ch2","C", 1, 0, 2,"C","","","","","mv_par02","Sim","Si","Yes","1","Nao","No","No","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

dbSelectArea(_sAlias)

Return
*/
Static Function LinhaProd()
       cAux := rtrim(TMP->Z1_DESCR)
         iNroLin := iNroLin + 1
       @ iNroLin,064-(Len(cAux)/2) psay cAux
         iNroLin := iNroLin+1
       @ iNroLin,000 PSay Replicate("=",limite)
Return          


Static Function ImprReg() 
       Local cPreco, cAux, nCont, cLinha, cPict
       iNroLin := iNroLin + 1
       @ iNroLin,000 PSay SubStr(TMP->CODPRO,1,10)
       @ iNroLin,012 PSay RTrim(SubStr(TMP->DESCR,1,30))
       @ iNroLin,043 PSay SubStr(TMP->B1_CATALIS,1,10)
         cAux := RTrim(Iif(!Empty(TMP->RELCAT),"("+RTrim(TMP->RELCAT)+")",""))
         cAux := LTrim(cAux)
       @ iNroLin,053 PSay SubStr(cAux,1,5)
         cProd := SubStr(TMP->CODPRO,1,10)
         cLinha := SubStr(cProd,4,2)
/*       DbSelectArea("SB1")
       _cFilial := xFilial("SB1")
       DbSeek(_cFilial+TMP->CODPRO)  
       if !Eof() .and. (_cFilial = SB1->B1_FILIAL) .and. (SubStr(SB1->B1_COD,1,10) == cProd) .and. (SubStr(SB1->B1_COD,11,2) == '00')
       		DbSkip()
       endif  */
		cPict := iif(cNumEmp = "05","@E 99,999,999","@E 999,999.99")
		nCont := 0
		DbSelectArea("TMPC")         
		dbgotop()
		locate for TMPC->LINHA == cLinha
		while !eof() .and. (TMPC->LINHA == cLinha)
			nCont++
	       	DbSelectArea("TMP")
	       	While !Eof() .and. (SubStr(TMP->CODPRO,1,10) == cProd) .and. (SubStr(TMP->CODPRO,11,2) < TMPC->EMBA) 
    	   		dbskip()
  			enddo 
  			if !Eof() .and. (SubStr(TMP->CODPRO,1,10) == cProd) .and. (SubStr(TMP->CODPRO,11,2) == TMPC->EMBA) 
  				cPreco := iif(TMP->B1_ESTOQUE == 'S',"*","")+Alltrim(Transform(TMP->PRECO,cPict))
      			@ iNroLin,ImprCols[nCont] psay padl(cPreco,11)
		       	DbSelectArea("TMP")
		       	dbskip()
      		endif 
			dbselectarea("TMPC")
			dbskip()
		enddo 

       	DbSelectArea('TMP')
		while !Eof() .and. (SubStr(TMP->CODPRO,1,10) == cProd)
       		DbSkip()
  		enddo 
Return

Static Function Cabecalho()
       nNroPag = nNroPag + 1
       cNroPag = rtrim(str(nNroPag,3))
       cNroPag = replicate("0",3-len(cNroPag))+cNroPag

         iNroLin := 1
       @ iNroLin,000 PSay Replicate("-",limite)
         iNroLin := iNroLin + 1
       @ iNroLin,000 PSay PADC("T A B E L A    D E    P R E C O S  (* -> Prod. ESTOQUE)",096)
       @ iNroLin,098 PSay "EXPEDICAO : "
       @ iNroLin,110 PSay DTOC(DATE())
         iNroLin := iNroLin + 1
       @ iNroLin,000 PSay ALLTRIM(SM0->M0_NOMECOM)
       @ iNroLin,098 PSay "PAGINA....: "
       @ iNroLin,115 PSay cNroPag
         iNroLin := iNroLin + 1
       @ iNroLin,000 PSay Replicate("-",limite)
         iNroLin := iNroLin + 1
       @ iNroLin,000 psay replicate("=",limite)
Return

Static Function cabecalho2() 
Local nTam
	nTam = 11 // Qtde de caracteres usados para os valores
       cLinha = SubStr(TMP->CODPRO,4,2)
       	DbSelectArea("TMPC") 
		dbgotop()
		locate for TMPC->LINHA == cLinha
       	nContEmba = 0
       	While !Eof() .AND. (TMPC->LINHA == cLinha)
             nContEmba++
             cAux = "cEmba"+str(nContEmba,1)
             &cAux = space(nTam)
             &cAux = rtrim(substr(TMPC->Z5_DESCR,1,nTam))
             DbSelectArea("TMPC")
             DbSkip()
       EndDo

         iNroLin := iNroLin + 1
       @ iNroLin,000 PSay "CODIGO"
       @ iNroLin,012 PSay "NOME DO PRODUTO"
       @ iNroLin,043 PSay "CATAL."
       If nContEmba >= 1
          @ iNroLin,ImprCols[1] PSay padl(cEmba1,nTam) //Space(9-Len(cEmba1))+cEmba1
       Endif
       If nContEmba >= 2
		  @ iNroLin,ImprCols[2] PSay padl(cEmba2,nTam) //Space(9-Len(cEmba2))+cEmba2
       Endif
       If nContEmba >= 3
          @ iNroLin,ImprCols[3] PSay padl(cEmba3,nTam) //Space(9-Len(cEmba3))+cEmba3
       Endif
	   If nContEmba >= 4
          @ iNroLin,ImprCols[4] PSay padl(cEmba4,nTam) //Space(9-Len(cEmba4))+cEmba4
       Endif
       If nContEmba >= 5
          @ iNroLin,ImprCols[5] PSay padl(cEmba5,nTam) //Space(9-Len(cEmba5))+cEmba5
       Endif
       If nContEmba >= 6
          @ iNroLin,ImprCols[6] PSay padl(cEmba6,nTam) //Space(9-Len(cEmba6))+cEmba6
       Endif
         iNroLin := iNroLin + 1
       @ iNroLin,000 psay replicate("=",limite)
Return
/*
Static Function GeraCols()  

       Local _aCampos, cQuery
       Private oTempTable
       
       cQuery := "SELECT SUBSTRING(B1_COD,4,2) AS LINHA,SUBSTRING(B1_COD,11,2) AS EMBA FROM "
       cQuery := cQuery+RetSqlName("SB1")+" A "
       cQuery := cQuery+"WHERE A.B1_FILIAL = '"+xFilial("SB1")+"' "
       cQuery := cQuery+"AND (A.D_E_L_E_T_ <> '*') "
       cQuery := cQuery+"AND (A.B1_TIPO = 'PA') "
       cQuery := cQuery+"AND (A.B1_VEND <> 'N') "
       cQuery := cQuery+"AND (SUBSTRING(B1_COD,11,2) <> '00') "+;
       Iif(mv_par02 == 1," AND (A.B1_ESTOQUE = 'S') ","")
       cQuery := cQuery+"GROUP BY SUBSTRING(B1_COD,4,2),SUBSTRING(B1_COD,11,2) "
       cQuery := cQuery+"ORDER BY SUBSTRING(B1_COD,4,2),SUBSTRING(B1_COD,11,2) "

       TCQUERY cQuery NEW ALIAS "TMPCC"

       _aCampos = {}    
       AADD(_aCampos,{"LINHA","C",2,0})
       AADD(_aCampos,{"EMBA","C",2,0})


//     cArqCab = criatrab(_aCampos,.t.)

	   
	   //cArqCab := U_NovoArqTrab("dtc")
	   //dbcreate(cArqCab+".dtc",_aCampos,"CTREECDX")     
	   //USE (cArqCab+".dtc") ALIAS TMPC VIA "CTREECDX" NEW
       //cInd01  := SubStr(cArqCab, 1, 10) //"SC"+SubStr(cNomArq, 8, 6)+"_1"
        
       //DbCreateIndex(cInd01+".cdx", "LINHA", {||"LINHA"} )
       //DbSetIndex(cInd01)
       //DbSetOrder(1)

       oTempTable := FWTemporaryTable():New( "TMPCC" )
       oTemptable:SetFields( _aCampos )
       oTempTable:AddIndex( "cInd01", { "LINHA" } )
       oTempTable:Create()
       DbSelectArea("TMPCC")
       DbSetOrder(1)
       DbGoTop()

       While !Eof()
             DbSelectArea("TMPC")
             RecLock("TMPC",.T.)
                TMPC->LINHA := TMPCC->LINHA
                TMPC->EMBA  := TMPCC->EMBA
             MsUnlock()
             DbSelectArea("TMPCC")
             DbSkip()
       Enddo

       DbSelectArea("TMPCC")
       DbCloseArea()
       
       DbSelectArea("TMPC")
       DbGoTop()
Return
*/