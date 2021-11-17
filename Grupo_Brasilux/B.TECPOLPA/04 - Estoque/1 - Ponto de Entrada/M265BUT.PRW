#include 'TOTVS.CH'

//26/09/2019 - Luís Gustavo - Adequação para release 12.1.25
User Function M265BUT()
     Local aButUsr   := {}
     //Local nOpc      := ParamIxb[1]   

     If FWCodEmp() == '11' //Empresas que são do grupo 11(Tecpolpa).
        // 2=Visualizar   3=Endereçar   4=Estornar

        aAdd(aButUsr,{'LIBERAR ESTORNO',{||U_AltParam(1)},'Liberar Estorno','Liberar Estorno' } )
        aAdd(aButUsr,{'LIBERAR ETIQUETA',{||U_AltParam(2)},'Liberar Etiqueta','Liberar Etiqueta' } )
        //aAdd(aButUsr,{'PRODUTO',{||U_Funcao3()},'Botao 07','Botao 07' } )
        // Detalhando:// 
        //aButUsr := { {x,y,z}}
        // Onde x: BITMAP DO BOTAO// Y: BLOCO DE CODIGO ASSOCIADO// z: HINT DO BOTAO
     Endif
Return (aButUsr)

User Function AltParam(iOpc)
     If (iOpc == 1)
        PUTMV("MV_ACDCB0","")
     Elseif (iOpc == 2)
            PUTMV("MV_ACDCB0","01*02*")
     Endif
Return