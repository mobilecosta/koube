#INCLUDE "protheus.Ch"
//--------------------------------------------
/*/{Protheus.doc} RFAT001
RELATORIO cUSTOMIZADO PICK LIST
@type function
@version 1.0
@author Flavio Luiz Vicco   
@since 30/06/2006
@alterado por: Roberto R. Mezzalira - 02/02/2024
/*/
//--------------------------------------------
User Function RFAT001
Local wnrel   := "RFAT001"
Local tamanho := "G"
Local titulo  := "Pick-List  (Expedicao)"
Local cDesc1  := "Emissao de produtos a serem separados pela expedicao, para"
Local cDesc2  := "determinada faixa de pedidos."
Local cDesc3  := ""
Local cString := "SC9"
Local cPerg   := "MTR777"

PRIVATE aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 2, "",0 }
PRIVATE nomeprog := "RFAT001"
PRIVATE nLastKey := 0
PRIVATE nBegin   := 0
PRIVATE aLinha   := {}
PRIVATE li       := 80
PRIVATE limite   := 132
PRIVATE lRodape  := .F.
PRIVATE m_pag    := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                      ³
//³ mv_par01  De Pedido                                       ³
//³ mv_par02  Ate Pedido                                      ³
//³ mv_par03  Imprime pedidos ? 1 - Estoque                   ³
//³                             2 - Credito                   ³
//³                             3 - Estoque/Credito           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,.T.)

If nLastKey == 27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| C777Imp(@lEnd,wnRel,cString,cPerg,tamanho,@titulo,@cDesc1,@cDesc2,@cDesc3)},Titulo)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C777IMP  ³ Autor ³ Flavio Luiz Vicco     ³ Data ³ 30.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR777                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C777Imp(lEnd,WnRel,cString,cPerg,tamanho,titulo,cDesc1,cDesc2,cDesc3)

Local cFilterUser := aReturn[7]
Local lUsaLocal  := (SuperGetMV("MV_LOCALIZ") == "S")
Local cbtxt      := SPACE(10)
Local cbcont	 := 0
Local lQuery     := .F.
Local lRet       := .F.
Local cEndereco  := ""
Local nQtde      := 0
Local cAliasNew  := "SC9"
Local aStruSC9   := {}
Local cName      := ""
Local cQryAd     := ""
Local nX         := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li := 80
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := "PICK-LIST"

// "Codigo          Desc. do Material              UM Quantidade  Amz Endereco       Lote      SubLote  Dat.de Validade Potencia"
//            1         2         3         4         5         6         7         8         9        10        11        12        13
//  0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
cAliasNew:= GetNextAlias()
aStruSC9 := SC9->(dbStruct())
lQuery := .T.
cQuery := "SELECT SC9.R_E_C_N_O_ SC9REC,"
cQuery += "SC9.C9_PEDIDO,SC9.C9_FILIAL,SC9.C9_QTDLIB,SC9.C9_PRODUTO, "
cQuery += "SC9.C9_LOCAL,SC9.C9_LOTECTL,"
cQuery += "SC9.C9_NUMLOTE,SC9.C9_DTVALID,SC9.C9_NFISCAL"
If cPaisLOC <> "BRA" 	
	cQuery += ",SC9.C9_REMITO " 
EndIf	

If lUsaLocal
	cQuery += ",SDC.DC_LOCALIZ,SDC.DC_QUANT,SDC.DC_QTDORIG"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta rotina foi escrita para adicionar no select os campos do SC9 usados no filtro do usuario ³
//³quando houver, a rotina acrecenta somente os campos que forem adicionados ao filtro testando  ³
//³se os mesmo ja existem no selec ou se forem definidos novamente pelo o usuario no filtro.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aReturn[7])
	For nX := 1 To SC9->(FCount())
		cName := SC9->(FieldName(nX))
		If AllTrim( cName ) $ aReturn[7]
			If aStruSC9[nX,2] <> "M"
				If !cName $ cQuery .And. !cName $ cQryAd
					cQryAd += ",SC9."+ cName
				EndIf
			EndIf
		EndIf
	Next nX
EndIf 
		
cQuery += cQryAd
cQuery += " FROM "
cQuery += RetSqlName("SC9") + " SC9 "
If lUsaLocal
	cQuery += "LEFT JOIN "+RetSqlName("SDC") + " SDC "
	cQuery += "ON SDC.DC_PEDIDO=SC9.C9_PEDIDO AND SDC.DC_ITEM=SC9.C9_ITEM AND SDC.DC_SEQ=SC9.C9_SEQUEN AND SDC.D_E_L_E_T_ = ' '"
EndIf
cQuery += "WHERE SC9.C9_FILIAL  = '"+xFilial("SC9")+"'"
cQuery += " AND  SC9.C9_PEDIDO >= '"+mv_par01+"'"
cQuery += " AND  SC9.C9_PEDIDO <= '"+mv_par02+"'"
If mv_par03 == 1 .Or. mv_par03 == 3
	cQuery += " AND SC9.C9_BLEST  = '  '"
EndIf
If mv_par03 == 2 .Or. mv_par03 == 3
	cQuery += " AND SC9.C9_BLCRED = '  '"
EndIf
If cPaisLOC <> "BRA"
	cQuery += " AND SC9.C9_REMITO = '" +Space(Len(SC9->C9_REMITO))+"' "
EndIf	
cQuery += " AND SC9.D_E_L_E_T_ = ' '"
cQuery += "ORDER BY SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_CLIENTE,SC9.C9_LOJA, SDC.DC_LOCALIZ, SC9.C9_PRODUTO,SC9.C9_LOTECTL,"
cQuery += "SC9.C9_NUMLOTE,SC9.C9_DTVALID"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasNew,.T.,.T.)
For nX := 1 To Len(aStruSC9)
	If aStruSC9[nX][2] <> "C" .and.  FieldPos(aStruSC9[nX][1]) > 0
		TcSetField(cAliasNew,aStruSC9[nX][1],aStruSC9[nX][2],aStruSC9[nX][3],aStruSC9[nX][4])
	EndIf
Next nX

SetRegua(RecCount())
(cAliasNew)->(dbGoTop())
While (cAliasNew)->(!Eof())

	If!Empty(cFilterUser) .AND. !(&cFilterUser)
		dbSelectArea(cAliasNew)
		dbSkip()
		Loop
	EndIf

	If lUsaLocal
		cEndereco := (cAliasNew)->DC_LOCALIZ
		nQtde     := Iif((cAliasNew)->DC_QUANT>0,(cAliasNew)->DC_QUANT,(cAliasNew)->C9_QTDLIB)
	Else
		cEndereco := ""
		nQtde     := (cAliasNew)->C9_QTDLIB
	EndIf
	lRet := C777ImpDet(cAliasNew,lQuery,nQtde,cEndereco,@lEnd,titulo,cDesc1,cDesc2,cDesc3,tamanho)

	If !lRet
		Exit
	EndIf
	(cAliasNew)->(dbSkip())
EndDo

If lRodape
	roda(cbcont,cbtxt,"M")
EndIf

If lQuery
	dbSelectArea(cAliasNew)
	dbCloseArea()
	dbSelectArea("SC9")
Else
	RetIndex("SC9")
	Ferase(cIndexSC9+OrdBagExt())
	dbSelectArea("SC9")
	dbClearFilter()
	dbSetOrder(1)
	dbGotop()
EndIf

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf
MS_FLUSH()
Return NIL

Static Function C777ImpDet(cAliasNew,lQuery,nQtde,cEndereco,lEnd,titulo,cDesc1,cDesc2,cDesc3,tamanho)
Local cabec1  := "Codigo          Desc. do Material                                  UM     Quantidade       2a.UM      QTD  2a.UM            Amz   Endereco         Lote            Validade     Pedido"

/*
          1         2         3         4         5         6         7         8         9         10        11        12        13         			
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Codigo          Desc. do Material              UM Quantidade  2a.UM   QTD  2a.UM   Amz   Endereco     Lote       Validade    Pedido
*/


Local cabec2  := ""
Local cProd   := ''
Local cProd1  := ''
Local cProd2  := ''
Local cQuant  := ''
Local cQuant1 := ''
Local cQuant2 := ''
Local lQuebra := .F.
Static lFirst := .T.
If lEnd
	@PROW()+1,001 Psay "CANCELADO PELO OPERADOR"
	Return .F.
EndIf
If !lQuery
	IncRegua()
EndIf
If li > 55 .or. lFirst
	lFirst  := .F.
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	lRodape := .T.
EndIf
cProd := (cAliasNew)->C9_PRODUTO
SB1->(dbSeek(xFilial("SB1")+cProd))
// ----

//Tratamento para quebra do código do produto
If Len(AllTrim(cProd)) > 15
	cProd1 := SubStr(cProd, 1,  15)
	cProd2 := SubStr(cProd, 16, 15)
	lQuebra := .T.
Else
	cProd1 := AllTrim(cProd)
	cProd2 := ''
EndIf

//Tratamento para quantidade
cQuant := AllTrim(Transform(nQtde, PesqPict("SC9","C9_QTDLIB")))

//Caso o cliente tenha customizado o tamanho do campo quantidade
If Len(AllTrim(cQuant)) > 11
	cQuant1 := SubStr(cQuant, 1,   11)
	cQuant2 := SubStr(cQuant, 12,  11)
	lQuebra := .T.
Else
	cQuant1 := cQuant
	cQuant2 := ''
EndIf

@ li, 00 Psay cProd1                    Picture "@!"
@ li, 16 Psay ALLTRIM(SB1->B1_DESC)  	Picture "@!" //Subs(SB1->B1_DESC,1,50)
@ li, 67 Psay SB1->B1_UM   				Picture "@!" //47
@ li, 70 Psay Transform(nQtde, "@E 999,999,999.99") //Picture "@!" 50PadL(cQuant1, 11)

@ li, 94 Psay SB1->B1_SEGUM	

if (SB1->B1_TIPCONV == 'D')
	@ li, 98 Psay Transform((nQtde / SB1->B1_CONV), "@E 999,999,999.99")  //nQtde / SB1->B1_CONV
else
	@ li, 98 Psay Transform((nQtde * SB1->B1_CONV), "@E 999,999,999.99")//nQtde * SB1->B1_CONV
endif
	
@ li, 125 Psay (cAliasNew)->C9_LOCAL //83

@ li, 130 Psay cEndereco //89
@ li, 147 Psay (cAliasNew)->C9_LOTECTL	Picture "@!" //102
@ li, 163 Psay (cAliasNew)->C9_DTVALID	Picture PesqPict("SC9","C9_DTVALID")//113
@ li, 176 Psay (cAliasNew)->C9_PEDIDO	Picture "@!"//125
li++

If lQuebra
	@ li, 00 Psay cProd2                      Picture "@!"
	//@ li, 50 Psay PadR(cQuant2, 11)           Picture "@!"
	li++
EndIf

Return .T.
