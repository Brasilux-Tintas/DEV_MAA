/*
Ponto de Entrada para incluir tabelas em Conhecimentos
*/
//30/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function FTMSREL()
     Local aEntidade := {}

     If FWCodEmp() <> '11' //Empresas que não são do grupo 11(Tecpolpa).
        aAdd( aEntidade, { "SZQ", { "ZQ_NUM" },     { || SZQ->ZQ_NUM } } )
        aAdd( aEntidade, { "Z06", { "Z06_NUMCHA" }, { || Z06->Z06_NUMCHA } } )    
        aAdd( aEntidade, { "Z10", { "Z10_CODIGO" }, { || Z10->Z10_CODIGO } } )
     Endif    
return(aEntidade)
