/*/{Protheus.doc} IREPORTX1
//TODO  Informações Complementares a Relatórios.
@author 
@since   /  /    
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function IREPORTX1()
     Local aValores := {}
     /*aAdd(aValores, {"DATABASE", dDataBase})
       aAdd(aValores, {"HORA", Time()} )*/                
     /*if !u_VldAcesso(funname())
          MsgBox("Acesso não autorizado!---->"+funname(),"Atenção","Alert")
          Return 
       Endif*/

       //ConOut( "cUsername: "+cUsername+". cUsuario: "+cUsuario+". __CUSERID: "+__CUSERID)
       aAdd(aValores, {"XFILIAL", paramixb[3]})

Return(aValores)