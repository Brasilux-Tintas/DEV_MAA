#INCLUDE "rwmake.ch"

///////////////////////////////////////////////////////////
//                                                       //
// Função....: BRCON001     Data....: 25.02.03           //
// Autor.....: Marcos Cesar D.Vieira                     //
// Descrição.: Lancamento Padrao(Folha de Pgto)          //
// Uso.......: EXECBLOCK no Lancamento Padrao.           //
//                                                       //
///////////////////////////////////////////////////////////              
User Function BRCON001

//===========================//
// Declaracao de Variaveis   //
//===========================//
        
Local nArea,nRecno,nIndex,cContaDeb
                                        
nArea     := Alias()
nRecno    := Recno()
nIndex    := IndexOrd()
cContaDeb := Space(9)


If SRZ->RZ_PD $ "101_110_119_142_181_206_239_240_244_260_262_297_422_434_457_458" // Verbas
  If  Substr(SRZ->RZ_CC,1,2)=="02" .OR. Substr(SRZ->RZ_CC,1,4)=="0302".OR. Substr(SRZ->RZ_CC,1,4)=="0307" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0308" .OR. Substr(SRZ->RZ_CC,1,4)=="0305" 
    cContaDeb := "41101001"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0401"
    cContaDeb := "41102001"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0101".OR. Substr(SRZ->RZ_CC,1,4)=="0102"
    cContaDeb := "51101001" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
    cContaDeb := "51102001"  
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0303" .OR. Substr(SRZ->RZ_CC,1,4)=="0306" .OR. Substr(SRZ->RZ_CC,1,4)=="0900"
    cContaDeb := "51103001"   
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0501"
    cContaDeb := "51104001" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0301" .OR. Substr(SRZ->RZ_CC,1,4)=="0304"
    cContaDeb := "51105001"  
  EndIf
ElseIf SRZ->RZ_PD $ "107_298_744_745_746"  // Verba INSS
  If Substr(SRZ->RZ_CC,1,4)=="0201" .OR. Substr(SRZ->RZ_CC,1,4)=="0202" .OR. Substr(SRZ->RZ_CC,1,4)=="0203" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0204" .OR. Substr(SRZ->RZ_CC,1,4)=="0205" .OR. Substr(SRZ->RZ_CC,1,4)=="0206" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0302" .OR. Substr(SRZ->RZ_CC,1,4)=="0307" .OR. Substr(SRZ->RZ_CC,1,4)=="0207" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0308" .OR. Substr(SRZ->RZ_CC,1,4)=="0305" 
    cContaDeb := "41101002"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0401"
      cContaDeb := "41102002" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0101" .OR. Substr(SRZ->RZ_CC,1,4)=="0102"
      cContaDeb := "51101002"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
      cContaDeb := "51102002"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0303" .OR. Substr(SRZ->RZ_CC,1,4)=="0306" .OR. Substr(SRZ->RZ_CC,1,4)=="0900"
      cContaDeb := "51103002"         
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0501"
      cContaDeb := "51104002"            
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0301" .OR. Substr(SRZ->RZ_CC,1,4)=="0304"
      cContaDeb := "51105002"                
  Endif  
ElseIf SRZ->RZ_PD $ "706_735_747"  // Verbas FGTS
  If Substr(SRZ->RZ_CC,1,4)=="0201" .OR. Substr(SRZ->RZ_CC,1,4)=="0202" .OR. Substr(SRZ->RZ_CC,1,4)=="0203" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0204" .OR. Substr(SRZ->RZ_CC,1,4)=="0205" .OR. Substr(SRZ->RZ_CC,1,4)=="0206" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0302" .OR. Substr(SRZ->RZ_CC,1,4)=="0307" .OR. Substr(SRZ->RZ_CC,1,4)=="0207" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0208" .OR. Substr(SRZ->RZ_CC,1,4)=="0308" .OR. Substr(SRZ->RZ_CC,1,4)=="0305"
    cContaDeb := "41101003"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0401"
      cContaDeb := "41102003" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0101" .OR. Substr(SRZ->RZ_CC,1,4)=="0102"
      cContaDeb := "51101003"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
      cContaDeb := "51102003"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0303" .OR. Substr(SRZ->RZ_CC,1,4)=="0306"
      cContaDeb := "51103003"         
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0501"
      cContaDeb := "51104003"            
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0301" .OR. Substr(SRZ->RZ_CC,1,4)=="0304"
      cContaDeb := "51105003"                
  Endif  
ElseIf SRZ->RZ_PD $ "448_108_299_469"  // Verbas Alimentacao
  If Substr(SRZ->RZ_CC,1,4)=="0201" .OR. Substr(SRZ->RZ_CC,1,4)=="0202" .OR. Substr(SRZ->RZ_CC,1,4)=="0203" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0204" .OR. Substr(SRZ->RZ_CC,1,4)=="0205" .OR. Substr(SRZ->RZ_CC,1,4)=="0206" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0302" .OR. Substr(SRZ->RZ_CC,1,4)=="0307" .OR. Substr(SRZ->RZ_CC,1,4)=="0308" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0305"
    cContaDeb := "41101007"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0401"
      cContaDeb := "41102007" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0101" .OR. Substr(SRZ->RZ_CC,1,4)=="0102"
      cContaDeb := "51101007"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
      cContaDeb := "51102007"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0303" .OR. Substr(SRZ->RZ_CC,1,4)=="0306"
      cContaDeb := "51103007"         
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0501"
      cContaDeb := "51104007"            
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0301" .OR. Substr(SRZ->RZ_CC,1,4)=="0304"
      cContaDeb := "51105007"                
  Endif  
ElseIf SRZ->RZ_PD $ "414_416_415"  // Verbas Assit.Med./Odont/Farmacia.
  If Substr(SRZ->RZ_CC,1,4)=="0201" .OR. Substr(SRZ->RZ_CC,1,4)=="0202" .OR. Substr(SRZ->RZ_CC,1,4)=="0203" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0204" .OR. Substr(SRZ->RZ_CC,1,4)=="0205" .OR. Substr(SRZ->RZ_CC,1,4)=="0206" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0302" .OR. Substr(SRZ->RZ_CC,1,4)=="0307" .OR. Substr(SRZ->RZ_CC,1,4)=="0207" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0208" .OR. Substr(SRZ->RZ_CC,1,4)=="0308" .OR. Substr(SRZ->RZ_CC,1,4)=="0305"
    cContaDeb := "41101008"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0401"
      cContaDeb := "41102008" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0101" .OR. Substr(SRZ->RZ_CC,1,4)=="0102"
      cContaDeb := "51101008"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
      cContaDeb := "51102008"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0303" .OR. Substr(SRZ->RZ_CC,1,4)=="0306"
      cContaDeb := "51103008"         
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0501"
      cContaDeb := "51104008"            
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0301" .OR. Substr(SRZ->RZ_CC,1,4)=="0304"
      cContaDeb := "51105008"                
  Endif    
ElseIf SRZ->RZ_PD == "106"  // Verbas Pro-Labore
  If Substr(SRZ->RZ_CC,1,4)=="0201" .OR. Substr(SRZ->RZ_CC,1,4)=="0202" .OR. Substr(SRZ->RZ_CC,1,4)=="0203" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0204" .OR. Substr(SRZ->RZ_CC,1,4)=="0205" .OR. Substr(SRZ->RZ_CC,1,4)=="0206" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0302" .OR. Substr(SRZ->RZ_CC,1,4)=="0307" .OR. Substr(SRZ->RZ_CC,1,4)=="0308" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0305"
    cContaDeb := "41101011"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0401"
      cContaDeb := "41102011" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0101" .OR. Substr(SRZ->RZ_CC,1,4)=="0102"
      cContaDeb := "51101011"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
      cContaDeb := "51102011"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0303" .OR. Substr(SRZ->RZ_CC,1,4)=="0306"
      cContaDeb := "51103011"         
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0501"
      cContaDeb := "51104011"            
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0301" .OR. Substr(SRZ->RZ_CC,1,4)=="0304"
      cContaDeb := "51105011"                
  Endif     
ElseIf SRZ->RZ_PD == "127"  // Verbas Aviso Previo/Indenizacao
  If Substr(SRZ->RZ_CC,1,4)=="0201" .OR. Substr(SRZ->RZ_CC,1,4)=="0202" .OR. Substr(SRZ->RZ_CC,1,4)=="0203" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0204" .OR. Substr(SRZ->RZ_CC,1,4)=="0205" .OR. Substr(SRZ->RZ_CC,1,4)=="0206" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0302" .OR. Substr(SRZ->RZ_CC,1,4)=="0307" .OR. Substr(SRZ->RZ_CC,1,4)=="0308" .OR. ;
     Substr(SRZ->RZ_CC,1,4)=="0305"
    cContaDeb := "41101038"
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0401"
      cContaDeb := "41102038" 
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0101" .OR. Substr(SRZ->RZ_CC,1,4)=="0102"
      cContaDeb := "51101038"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0103"
      cContaDeb := "51102038"    
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0303" .OR. Substr(SRZ->RZ_CC,1,4)=="0306"
      cContaDeb := "51103038"         
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0501"
      cContaDeb := "51104038"            
  ElseIf Substr(SRZ->RZ_CC,1,4)=="0301" .OR. Substr(SRZ->RZ_CC,1,4)=="0304"
      cContaDeb := "51105038"                
  Endif      
EndIf                                                                   
dbSelectArea(nArea)
dbSetorder(nIndex)
dbGoto(nRecno)

Return(cContaDeb)