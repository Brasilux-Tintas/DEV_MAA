#Include "protheus.ch"
#Include "fileio.ch"

/*/{Protheus.doc} BRSPEDC100
Extrai dados do SPED C100 e soma C190
Identificando cliente (SA1) ou fornecedor (SA2)
Autor: ChatGPT
/*/

User Function BRSPEDC100()

Local cArquivo := ""
Local cSaida   := ""
Local nHandle  := 0
Local cLinha   := ""
Local aCampos  := {}
Local a0150    := {} // mapa COD_PART -> CNPJ

Local cTipo    := ""
Local cChave   := ""
Local cNF      := ""
Local cCodPart := ""
Local cCNPJ    := ""
Local cCodigo  := ""

Local nVlNF    := 0
Local nVlC190  := 0

Local nOut := 0
Local nPos

// selecionar arquivo
cArquivo := cGetFile("*.txt","Selecione SPED")

If Empty(cArquivo)
    Return
EndIf

cSaida := StrTran(cArquivo,".txt","_AUDITORIA.csv")

nHandle := FOpen(cArquivo)

nOut := FCreate(cSaida)

FWrite(nOut,"TIPO;CODIGO;CHAVE_NFE;NUM_NF;VL_NF_C100;VL_TOTAL_C190"+CRLF)

While !FEOF(nHandle)

    cLinha := AllTrim(FReadLine(nHandle))
    aCampos := StrTokArr(cLinha,"|")

    If Len(aCampos) < 2
        Loop
    EndIf

    // -------------------------
    // REGISTRO 0150
    // -------------------------

    If aCampos[2] == "0150"

        // COD_PART / CNPJ
        AAdd(a0150,{aCampos[3],aCampos[5]})

    EndIf


    // -------------------------
    // REGISTRO C100
    // -------------------------

    If aCampos[2] == "C100"

        // grava anterior
        If !Empty(cChave)

            FWrite(nOut,;
                cTipo+";"+;
                cCodigo+";"+;
                cChave+";"+;
                cNF+";"+;
                cValToChar(nVlNF)+";"+;
                cValToChar(nVlC190)+CRLF)

        EndIf

        nVlC190 := 0

        // tipo
        If aCampos[3] == "0"
            cTipo := "FORNECEDOR"
        Else
            cTipo := "CLIENTE"
        EndIf

        cCodPart := aCampos[5]
        cNF      := aCampos[9]
        nVlNF    := Val(aCampos[12])
        cChave   := aCampos[23]

        // buscar CNPJ do 0150
        cCNPJ := ""

        For nPos := 1 To Len(a0150)
            If a0150[nPos][1] == cCodPart
                cCNPJ := a0150[nPos][2]
                Exit
            EndIf
        Next

        // localizar no Protheus
        cCodigo := ""

        If cTipo == "CLIENTE"

            DbSelectArea("SA1")
            DbSetOrder(3) // A1_CGC

            If DbSeek(xFilial("SA1")+cCNPJ)
                cCodigo := SA1->A1_COD
            EndIf

        Else

            DbSelectArea("SA2")
            DbSetOrder(3) // A2_CGC

            If DbSeek(xFilial("SA2")+cCNPJ)
                cCodigo := SA2->A2_COD
            EndIf

        EndIf

    EndIf


    // -------------------------
    // REGISTRO C190
    // -------------------------

    If aCampos[2] == "C190"

        nVlC190 += Val(aCampos[7])

    EndIf

EndDo


// grava último

If !Empty(cChave)

    FWrite(nOut,;
        cTipo+";"+;
        cCodigo+";"+;
        cChave+";"+;
        cNF+";"+;
        cValToChar(nVlNF)+";"+;
        cValToChar(nVlC190)+CRLF)

EndIf


FClose(nHandle)
FClose(nOut)

MsgInfo("Arquivo gerado:"+CRLF+cSaida)

Return
