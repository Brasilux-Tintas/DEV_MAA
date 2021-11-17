// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"

// UTILIZAÇÃO DO DICIONÁRIO DE DADOS SX3
User Function T190SX3()
    Local aSX3    := {}           // DADOS DA SX3 COM BASE NO VETOR AFIELDS
    Local aFields := GetColumns() // CAMPOS DA SX3 PARA ESTRUTURA

    // PREPARAÇÃO DO AMBIENTE (REMOVER SE VIA GUI)
    RPCSetEnv("99", "01")
        // EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO DE TRABALHO
        If (OpenDic())
            // PERCORRE A TABELA FILTRADA E MONTA ESTRUTURA
            DbEval({|| AAdd(aSX3, GenStruct(aFields))})

            // FECHA O ARQUIVO DE TRABALHO
            DbCloseArea()
        EndIf
    RPCClearEnv() // ENCERRA O AMBIENTE (REMOVER SE VIA GUI)
Return (NIL)

// CAMPOS QUE DESEJO UTILIZAR NA MINHA ESTRUTURA
Static Function GetColumns()
    Local aFields := {} // VETOR DE CAMPOS

    // ADIÇÃO DOS CAMPOS DESEJADOS
    AAdd(aFields, "X3_TITULO")
    AAdd(aFields, "X3_CAMPO")
    AAdd(aFields, "X3_PICTURE")
    AAdd(aFields, "X3_TAMANHO")
    AAdd(aFields, "X3_DECIMAL")
    AAdd(aFields, "X3_VALID")
    AAdd(aFields, "X3_USADO")
    AAdd(aFields, "X3_TIPO")
    AAdd(aFields, "X3_F3")
    AAdd(aFields, "X3_CONTEXT")
    AAdd(aFields, "X3_CBOX")
    AAdd(aFields, "X3_RELACAO")
    AAdd(aFields, "X3_WHEN")
    AAdd(aFields, "X3_VISUAL")
    AAdd(aFields, "X3_VLDUSER")
Return (aFields)

// EFETUA A ABERTURA E GERAÇÃO DO ARQUIVO TEMPORÁRIO
Static Function OpenDic()
    Local lOpen   := .F.                                             // VALIDAÇÃO DE ABERTURA DE TABELA
    Local cAlias  := GetNextAlias()                                  // APELIDO DO ARQUIVO DE TRABALHO
    Local cFilter := cAlias + "->" + "X3_ARQUIVO" + " == " + "'DIC'" // FILTRO PARA A TABELA SX3

    // ABERTURA DO DICIONÁRIO SX3
    OpenSXs(NIL, NIL, NIL, NIL, "99", cAlias, "SX3", NIL, .F.)
    lOpen := Select(cAlias) > 0

    // CASO ABERTO FILTRA O ARQUIVO PELO X3_ARQUIVO "DIC",
    // DEFINE COMO TABELA CORRENTE E POSICIONA NO TOPO
    If (lOpen)
        DbSelectArea(cAlias)
        DbSetFilter({|| &(cFilter)}, cFilter)
        DbGoTop()
    EndIf
Return (lOpen)

// RETORNA A ESTRUTURA DE UM CAMPO COM BASE NA SX3
Static Function GenStruct(aFields)
    Local aAux := {} // VETOR AUXILIAR PARA MONTAGEM DA ASX3

    // LAÇO DE REPETIÇÃO NOS CAMPOS DA SX3 PARA MONTAR A ESTRUTURA DE DIC
    AEval(aFields, {|cField| AAdd(aAux, &(cField))})
Return (aAux)