#INCLUDE 'TOTVS.CH'

//--------------------------------------------
/*/{Protheus.doc} MATUCOMP
Atualiza campos na tabela CD6

@type function
@version 1.0
@author Mauricio Silva

@since 15/03/2022
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
	Local _cItem

	SB1->(dbSetOrder(1))
	
   Z01->(dbSetOrder(1))
	
   CD6->(dbSetOrder(1))
	
   SD2->(dbSetOrder(3))
	if SD2->(dbSeek(xFilial("SD2") + _cDoc + _cSerie + _cClieFor + _cLoja))
      Do While ! SD2->(Eof()) .And. xFilial("SD2") + _cDoc + _cSerie + _cClieFor + _cLoja == SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA
         If SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
            If AllTrim(SB1->B1_GRUPO) $ _cGrupos .and. Z01->(dbSeek(xFilial("Z01") + SB1->B1_CODANP))
               _cItem := Padr(SD2->D2_ITEM, Len(CD6->CD6_ITEM), " ")
               CD6->(dbSeek(xFilial("CD6") + _cEntSai + _cSerie + _cDoc + _cClieFor + _cLoja + _cItem + SD2->D2_COD))
               If !CD6->(Eof()) .And. xFilial("CD6") + _cEntSai + _cSerie + _cDoc + _cClieFor + _cLoja + _cItem + SD2->D2_COD == CD6->CD6_FILIAL + CD6->CD6_TPMOV + CD6->CD6_SERIE + CD6->CD6_DOC + CD6->CD6_CLIFOR + CD6->CD6_LOJA + CD6->CD6_ITEM + CD6->CD6_COD
                  RecLock("CD6", .F.)
               else
                  RecLock("CD6", .T.)
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
               EndIf
               CD6->CD6_CODANP := SB1->B1_CODANP
               CD6->CD6_DESANP := Z01->Z01_DESANP
               MsUnLock()
            EndIf
         EndIf
         SD2->(DbSkip())
      EndDo
   endif

	RestArea(_aArea)

Return
