#INCLUDE "rwmake.ch"
#INCLUDE "avprint.ch"
#INCLUDE "TOPCONN.CH"
          
/////////////////////////////////////////////////////////
//                                                     //
// Funçào....: BRFAT051     Data....: 30.01.02         //
// Autor.....: Marcos Cesar D.Vieira/Edmar R.Benedito  //
// Últ. Alteração: Cleber - 21/03/02. Mudar filtros p/ //
// contemplarem borderôs de pedidos aprovados.		   //
// Descriçao.: Etiquetas de Volume                     //
// Uso.......: Brasilux/Resina                         //
//                                                     //
///////////////////////////////////////////////////////// 
//                                                     //
// mv_par01 - Borderô  De:      - Caracter             //
// mv_par02 - Borderô Até:     - Caracter              //
// mv_par03 - Dt Borderô  De:      - Data             //
// mv_par04 - Dt Borderô Até:     - Data              //
// mv_par05 - Pedido De:         - Caracter            //
// mv_par06 - Pedido Ate:        - Caracter            //
// mv_par07 - Imprime Nro Pedido - Numerico 1-Sim 2-Nao//
//                                                     //
/////////////////////////////////////////////////////////

User Function BRFAT049()
     Local cQry    := ''
     Local aEtqExp := {}
     Local cEmpresa
     Local nLinha, nEtq
     Private cPerg := "BRFT51"
  
 if !u_VldAcesso(funname())
      MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
      return 
  endif 

     ValidPerg()                     
     Pergunte("BRFT51", .t.)

     oPrn := TMSPrinter():New("Etiqueta de Expedição")
     oPrn:SetPortrait()      // ou SetLandscape()

     AVPRINT oPrn NAME "Etiquetas para Volume"
             oFont1  := TFont():New("Arial"      , 9, 10, .F., .F., 5, .T., 5, .T., .F.)
             oFont4  := TFont():New("Arial"      , 9, 12, .F., .T., 5, .F., 5, .T., .F.) 
             oFont2  := TFont():New("Arial Black", 9, 12, .F., .F., 5, .T., 5, .T., .F.)
             oFont3  := TFont():New("Arial Black", 9, 14, .F., .F., 5, .T., 5, .T., .F.)
             AVPAGE
               cLinha1 := "Região.:"
               cLinha2 := "CLIENTE"
               cLinha4 := "CIDADE:"
               cLinha6 := "REDESPACHO"
               cLinha8 := "QTDE VOL.:"
               cLinha9 := "Pedido.:"
               nLin    := 080
               nCol    := 060      
               cEmpresa = Substr(cNumEmp, 1, 2)
               
               cQry := ""
               cQry += "SELECT * "
               cQry += "FROM "+RetSqlName("SZF")+" SZF WITH (NOLOCK) "
               cQry += "LEFT OUTER JOIN "+RetSqlName("SZG")+" SZG WITH (NOLOCK) ON SZF.ZF_FILIAL = SZG.ZG_FILIAL AND SZF.ZF_CODIGO = SZG.ZG_CODIGO AND SZG.D_E_L_E_T_ = '' "
               cQry += "LEFT OUTER JOIN "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) ON SZG.ZG_FILIAL = SC9.C9_FILIAL AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6) = SC9.C9_PEDIDO AND SC9.D_E_L_E_T_ = '' "
               cQry += "WHERE SZF.ZF_FILIAL  = '"+xFilial("SZF")+"' "
               cQry += "  AND SZF.D_E_L_E_T_ = '' "
               cQry += "  AND SZF.ZF_CODIGO  BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
               cQry += "  AND SZF.ZF_EMISSAO BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"' "
               cQry += "  AND SUBSTRING(SZG.ZG_PEDIDO, 3, 6) BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
               cQry += "  AND SC9.C9_BLOQUEI = '  ' "
               cQry += " ORDER BY SC9.C9_PEDIDO, SC9.C9_DTLCRED "
               
               /*
               cQry := " SELECT * FROM SC9" + cEmpresa + "0 SC9 WHERE"
               cQry += " (SC9.D_E_L_E_T_ <>  '*')"
               if !empty(mv_par06) .and. (mv_par06 >= mv_par05)
                  cQry += " AND SC9.C9_PEDIDO >= '"+mv_par05+"' AND SC9.C9_PEDIDO <= '"+mv_par06+"' "
               endif
               if !empty(mv_par02)
                  cQry += " AND C9_PEDIDO IN (SELECT SUBSTRING(ZG_PEDIDO,3,6) FROM SZG"+;
                  iif(cEmpresa == "02","01",cEmpresa)+"0 SZG WHERE (D_E_L_E_T_ <> '*') AND "+; 
                  "(ZG_FILIAL = '"+xFilial("SZG")+"') "+;
                  "AND (SUBSTRING(ZG_PEDIDO,1,2) = '"+cEmpresa+"') "+;
                  "AND ZG_CODIGO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"') "
               endif
               if !empty(mv_par04)
                  cQry += " AND C9_PEDIDO IN (SELECT SUBSTRING(ZG_PEDIDO,3,6) FROM SZG"+;
                  iif(cEmpresa == "02","01",cEmpresa)+"0 SZG LEFT OUTER JOIN SZF"+iif(cEmpresa == "02","01",cEmpresa)+"0 SZF "+;
                  "ON ((SZG.ZG_FILIAL+SZG.ZG_CODIGO) = (SZF.ZF_FILIAL+SZF.ZF_CODIGO)) "+;
                  "WHERE (SZG.D_E_L_E_T_ <> '*') AND (SZF.D_E_L_E_T_ <> '*') AND "+; 
                  "(SZG.ZG_FILIAL = '"+xFilial("SZG")+"') "+;
                  "AND (SUBSTRING(SZG.ZG_PEDIDO,1,2) = '"+substr(cnumemp,1,2)+"') " +;
                  "AND SZF.ZF_EMISSAO BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"')"
               endif
               cQry += " AND  (SC9.C9_FILIAL = '"+xFilial("SC9")+"') AND (SC9.C9_BLOQUEI = '  ') "  //AND SC9.C9_BLEST = '  ' AND SC9.C9_BLCRED = '  ' 
               cQry += " ORDER BY SC9.C9_PEDIDO,SC9.C9_DTLCRED"*/
               TCQuery cQry New Alias "TMP"

               cPedido := SPACE(06)
               DbSelectArea("TMP")
               While !EOF()         
                     If cPedido == TMP->C9_PEDIDO
                        DbSelectArea("TMP")
                        TMP->(DbSkip())            
                        loop
                     Endif            
                     cPedido := TMP->C9_PEDIDO

                     DbSelectArea("SC5")
                     DbSetOrder(1)
                     DbSeek(xFilial("SC5")+TMP->C9_PEDIDO)
                     cVolume := SC5->C5_VOLUME1
	
                     DbSelectArea("SA4")
                     DbSetOrder(1)
                     DbSeek(xFilial("SA4")+SC5->C5_REDESP)
                     cRedesp := SA4->A4_NOME
                     cRegiao := SA4->A4_REGIAO

                     DbSelectArea("SA1")
                     DbSetOrder(1)
                     DbSeek(xFilial("SA1")+TMP->C9_CLIENTE+TMP->C9_LOJA)
                     cNomeCli := ALLTRIM(SUBSTR(SA1->A1_NOME,1,35))
                     cCidCli  := AllTrim(SA1->A1_MUN) + "-" + AllTrim(SA1->A1_EST)

                     AADD(aEtqExp, {cNomeCli, cCidCli, cRedesp, cRegiao, cVolume, TMP->C9_PEDIDO})

                     DbSelectArea("TMP")
                     TMP->(DbSkip())
               EndDo
               nContEtq := 0

               For nEtq := 1 To Len(aEtqExp)     
                   For nLinha := 1 To aEtqExp[nEtq,5]
                       nContEtq := nContEtq + 1
                       nLinini  := nLin

                       If MV_PAR07 == 1
                          oPrn:Say (nLin,nCol,cLinha9,oFont2)
                          oPrn:Say (nLin,nCol+210,aEtqExp[nEtq,6],oFont2) // Pedido
                       EndIf    

                       oPrn:Say (nLin,nCol+700,cLinha1,oFont2)
                       oPrn:Say (nLin,nCol+910,aEtqExp[nEtq,4],oFont2)   // Região do Redespacho
                       nLin += 45

                       oPrn:Line(nLin,nCol,nLin,nCol+960)
                       nLin += 015

                       oPrn:Say(nLin,nCol,cLinha2,oFont1)
                       nLin += 30

                       oPrn:Say (nLin,nCol,aEtqExp[nEtq,1],oFont2) // Nome do Cliente
                       nLin += 060

                       oPrn:Line(nLin,nCol,nLin,nCol+960)
                       nLin += 015
	
	oPrn:Say (nLin,nCol,cLinha4,oFont4)
	oPrn:Say (nLin-4,nCol+190,aEtqExp[nEtq,2],oFont2) // Cidade do Cliente
	nLin += 060
	
	oPrn:Line(nLin,nCol,nLin,nCol+960)
	nLin += 010
	
	oPrn:Say (nLin,nCol,cLinha6,oFont1)
	nLin += 040
	
	oPrn:Say (nLin,nCol,aEtqExp[nEtq,3],oFont2) // Nome do Redespacho
	nLin += 060
	
	oPrn:Line(nLin,nCol,nLin,nCol+960)
	nLin += 015
	
	oPrn:Say (nLin,nCol,cLinha8,oFont4)
	oPrn:Say (nLin-10,nCol+260,Transform(aEtqExp[nEtq,5],"@R 9999"),oFont3) // Volume do Pedido
	
	IF nCol == 60
	  nCol := 1260
	  nLin := nLinIni
	Else          
     nCol := 60
	 nLin += 240
	Endif
	
	If ncontEtq == 12 
      AVNEWPAGE	       
      nLin     := 100
      nCol     := 060   
      nContEtq := 0
    Endif   
    	
                   Next          
               Next 
             AVENDPAGE

     AVENDPRINT

     oFont1:End()
     oFont2:End()
     oFont3:End()
     oFont4:End()

     MS_FLUSH() 

     DbSelectArea("TMP")
     DbCloseArea()

Return  
  
/*/
Programa  : VALIDPERG   Autor:  Marcos Cesar     
Data      : 28/01/02
Descricao : Grava Perguntas
/*/
Static Function ValidPerg()
       Local _sAlias := Alias()
       Local i, j
       DbSelectArea("SX1")
       DbSetOrder(1)
       cPerg := PADR(cPerg, 10)
       aRegs := {}

       // Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
       AADD(aRegs,{cPerg,"01","Bordero De ?          ","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"02","Bordero Até ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"03","Data Bordero De  ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"04","Data Bordero Ate ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"05","Pedido de ?          ","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"06","Pedido Ate ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
       AADD(aRegs,{cPerg,"07","Imprime No. Pedido  ?","","","mv_ch7","N",01,0,2,"C","","mv_par07","Sim","Si" ,"Yes","","","Nao","No" ,"No" ,"","","","","","","","","","","","","","","","","",""})

       For i:=1 to Len(aRegs)
           If !dbSeek(cPerg+aRegs[i][2])
              RecLock("SX1", .T.)
                 For j := 1 to FCount()
                     If j <= Len(aRegs[i])
                        FieldPut(j, aRegs[i][j])
                     Endif
                 Next
              MsUnlock()
           Endif
       Next
       DbSelectArea(_sAlias)
Return
