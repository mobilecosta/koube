#INCLUDE 'TOTVS.CH'

//--------------------------------------------
/*/{Protheus.doc} MATUCOMP
Atualiza campos na tabela CD6

@type function
@version 1.0
@author Mauricio Silva
@since 15/03/2022
@alterado por: Roberto R. Mezzalira - 02/02/2024
/*/
//--------------------------------------------
User Function MATUCOMP()

	Local _aArea	 := GetArea()
	Local _cEntSai  := ParamIXB[1]
	Local _cSerie   := ParamIXB[2]
	Local _cDoc     := ParamIXB[3]
	Local _cClieFor := ParamIXB[4]
	Local _cLoja    := ParamIXB[5]
	Local _cGrupos  := AllTrim(GetMv("MV_COMBUS"))
	Local _cItem    := '01'
   Local cCODANP   := ' '
   Local cDESANP   := ' '

   SD2->(dbSetOrder(3))
   SD2->(dbgotop())
   IF SD2->(dbSeek(xFilial("SD2") + _cDoc + _cSerie + _cClieFor + _cLoja))

      Do While ! SD2->(Eof()) .And. xFilial("SD2") + _cDoc + _cSerie + _cClieFor + _cLoja == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA
         
        IF AllTrim(SD2->D2_GRUPO) $ _cGrupos //.and. Z01->(dbSeek(xFilial("Z01") + SB1->B1_CODANP))
              
              _cItem := Padr(SD2->D2_ITEM, Len(CD6->CD6_ITEM), " ")
              SB1->(dbSetOrder(1))
              SB1->(dbgotop()) 
              IF SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
                  cCODANP   := SB1->B1_XCODANP
                  cDESANP   := SB1->B1_XDESANP
               ELSE
                  cCODANP   := ' '
                  cDESANP   := ' ' 
               ENDIF

               CD6->(dbSetOrder(1))//CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE                                                                
	            CD6->(dbgotop())
               CD6->(dbSeek(xFilial("CD6") + _cEntSai + _cSerie + _cDoc + _cClieFor + _cLoja + _cItem + SD2->D2_COD))
               IF !CD6->(Eof()) .And. xFilial("CD6") + _cEntSai + _cSerie + _cDoc + _cClieFor + _cLoja + _cItem + SD2->D2_COD == CD6->CD6_FILIAL + CD6->CD6_TPMOV + CD6->CD6_SERIE + CD6->CD6_DOC + CD6->CD6_CLIFOR + CD6->CD6_LOJA + CD6->CD6_ITEM + CD6->CD6_COD
                  
                  RecLock("CD6", .F.)

               ELSE
                  RecLock("CD6", .T.)

               ENDIF

                  CD6->CD6_FILIAL := xFilial("CD6")
                  CD6->CD6_TPMOV  := _cEntSai
                  CD6->CD6_DOC    := _cDoc
                  CD6->CD6_SERIE  := _cSerie
                  CD6->CD6_CLIFOR := _cClieFor
                  CD6->CD6_LOJA   := _cLoja
                  CD6->CD6_ITEM   := _cItem
                  CD6->CD6_COD    := SD2->D2_COD
                  CD6->CD6_HORA   := Left(StrTran(Time(), ":", ""), 4)
                  CD6->CD6_UFCONS := SD2->D2_EST
                  CD6->CD6_SDOC   := _cSerie
                  CD6->CD6_QTDE   := SD2->D2_QUANT
                  CD6->CD6_CODANP := cCODANP  
                  CD6->CD6_DESANP := cDESANP  

                  MsUnLock()
         EndIf

         SD2->(DbSkip())

      EndDo

   Endif

	RestArea(_aArea)

Return
