#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#Include "TopConn.ch"


User Function apcpet001() 
 
	If ValidPerg()
		MsAguarde({|| ImpEtiq() },"Impressão de etiqueta","Aguarde...")
	EndIf
 
Return 



   
Static Function ImpEtiq()
	Local cQuery	:= ""
	Local _cCodPro	:= MV_PAR01
	Local _cCodPro2	:= MV_PAR02
	Local nQuant	:= MV_PAR03
	Local cImpress  := MV_PAR04 //"Microsoft Print to PDF" //Alltrim(MV_PAR04) //pego o nome da impressora
	//Local cLogo 	:= "\system\logo.jpg"
	Local oFont16	:= TFont():New('Arial',16,16,,.F.,,,,.T.,.F.,.F.)
	Local oFont13	:= TFont():New('Arial',13,13,,.F.,,,,.T.,.F.,.F.)
	Local oFont10	:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
	Local oFont45	:= TFont():New('Arial',45,45,,.F.,,,,.T.,.F.,.F.)
	Local oFont16N	:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.,.F.)
	Local oFont13N	:= TFont():New('Arial',13,13,,.T.,,,,.T.,.F.,.F.)
	Local oFont10N	:= TFont():New('Arial',10,10,,.T.,,,,.T.,.F.,.F.)
	Local oFont45N	:= TFont():New('Arial',45,45,,.T.,,,,.T.,.F.,.F.)

	Local cLote		:= "001"
	//Local _cCodPro := ""
	Local dData := STOD("  /  /  ")
 
	Local lAdjustToLegacy 	:= .F.
	Local lDisableSetup  	:= .T.
 
	Local nLin		:= 0
	Local nCol		:= 0
	Local nLinC		:= 0
	Local nColC		:= 0
	Local nWidth	:= 0
	Local nHeigth   := 0
	Local lBanner	:= .T.		//Se imprime a linha com o código embaixo da barra. Default .T.
	Local nPFWidth	:= 0
	Local nPFHeigth	:= 0
	Local lCmtr2Pix	:= .T.		//Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.
 
	MsProcTxt("Identificando a impressora...")
 
	//Private oPrinter := FWMSPrinter():New("produto"+Alltrim(__cUserID)+".etq",IMP_SPOOL,lAdjustToLegacy,"/spool/",lDisableSetup,,,Alltrim(cImpress) /*parametro que recebe a impressora*/)
	Private oPrinter := FWMSPrinter():New("Produto"+Alltrim(_cCodPro)+".etq",IMP_SPOOL,lAdjustToLegacy,"/spool/",lDisableSetup,,,Alltrim(cImpress) /*parametro que recebe a impressora*/)

 		cQuery := "SELECT B1_COD, B1_DESC, B1_CODGTIN, DY3_DESCRI, DY3_NRISCO, B1_PRVALID, C2_DATPRI, D3_LOTECTL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_OP, DY3_ONU, DY3_DESCRI FROM " + RetSqlName("SB1") + " B1 "
		cQuery += "LEFT JOIN " + RetSqlName("SB5") + " B5 ON B5.B5_COD = B1.B1_COD AND B5.B5_FILIAL = '" + xFilial("SB1") + "' AND B5.D_E_L_E_T_ = '' "
		cQuery += "LEFT JOIN " + RetSqlName("DY3") + " DY3 ON DY3_ONU = B5.B5_ONU AND DY3.DY3_FILIAL = '" +substr(xFilial("SB1"),1,4) + "'  AND DY3.D_E_L_E_T_ = '' "
		cQuery += "LEFT JOIN " + RetSqlName("SC2") + " C2 ON C2.C2_PRODUTO = B1.B1_COD AND C2_FILIAL = '" + xFilial("SB1") + "'  AND C2.D_E_L_E_T_ = '' "
		cQuery += "LEFT JOIN " + RetSqlName("SD3") + " D3 ON D3.D3_COD = B1.B1_COD AND D3_FILIAL = '" + xFilial("SB1") + "'  AND D3.D_E_L_E_T_ = '' "
		cQuery += "WHERE B1.B1_COD between  '" + alltrim(_cCodPro) + "' AND '" + alltrim(_cCodPro2) + "' AND B1.D_E_L_E_T_ = '' "

	TcQuery cQuery New Alias "QRYTMP"
	QRYTMP->(DbGoTop())
 
	oPrinter:SetMargin(001,001,001,001)
 
	While QRYTMP->(!Eof())
		For nR := 1 to nQuant
			nLin := 10
			nCol := 22
 
			MsProcTxt("Imprimindo "+alltrim(QRYTMP->B1_CODGTIN) + " - " + alltrim(QRYTMP->B1_DESC)+"...")

			dData := Valid(QRYTMP->C2_DATPRI, QRYTMP->B1_PRVALID)
			cLote := QRYTMP->D3_LOTECTL
			If cLote = "" 
				cLote := "xxxxxx"
			Endif	

			oPrinter:StartPage()
 
			//oPrinter:SayBitmap(nLin,nCol,cLogo,100,030)
 
			nLin+= 45
			//oPrinter:Say(nLin,nCol,QRYTMP->B1_COD,oFont13)
 
			nLinC		:= 4.95		//Linha que será impresso o Código de Barra
			nColC		:= 1.6		//Coluna que será impresso o Código de Barra
			nWidth	 	:= 0.0164	//Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta é 0.0164
			nHeigth   	:= 0.6		//Numero da Altura da barra. Default 1.5 --- limite de altura é 0.3
			lBanner		:= .T.		//Se imprime a linha com o código embaixo da barra. Default .T.
			nPFWidth	:= 0.8		//Número do índice de ajuste da largura da fonte. Default 1
			nPFHeigth	:= 0.9		//Número do índice de ajuste da altura da fonte. Default 1
			lCmtr2Pix	:= .T.		//Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.
			
			oPrinter:Box(150, 130, 90, 290, "-3")//  alltrim(QRYTMP->B1_CODGTIN)                               .f.                                                            testar arial lltrim(QRYTMP->B1_CODGTIN)                                                                      
			//oPrinter:FWMSBAR("CODE128" , nLinC , nColC, alltrim(QRYTMP->B1_CODGTIN) , oPrinter,/*lCheck*/,/*Color*/, /*lHorz*/, nWidth, nHeigth,.T./*teste vertical*/,/*cFont*/,/*cMode*/,/*lPrint*/,nPFWidth,nPFHeigth,lCmtr2Pix)
 
			

			oPrinter:Say(nLin,nCol + 150, "ONU " + alltrim(QRYTMP->DY3_ONU),oFont16)

			oPrinter:Say(nLin + 10, nCol + 150, alltrim(QRYTMP->DY3_DESCRI) + "   RISCO " +  QRYTMP->DY3_NRISCO	 ,oFont16)
			nLin+= 40
			oPrinter:Say(nLin + 35, nCol + 165, alltrim(QRYTMP->DY3_NRISCO) ,oFont45)
			nLin+= 40
			//linha coluna
			
			//coluna linha tamanho - Não informado onde buscar o a sequencia do lote, Opção D3_LOTECTL
			oPrinter:DataMatrix(320,160,alltrim(QRYTMP->C2_NUM + " " + QRYTMP->C2_ITEM  + " " +  QRYTMP->C2_SEQUEN), 80)

			nLin+= 40
			oPrinter:Say(nLin + 10,nCol + 100, alltrim(QRYTMP->B1_DESC) ,oFont16)
			nLin+= 10
			oPrinter:Say(nLin + 10,nCol + 100,"Ordem de Produção: " + alltrim(QRYTMP->C2_NUM + " " + QRYTMP->C2_ITEM  + " " +  QRYTMP->C2_SEQUEN) ,oFont10)
			nLin+= 10
			oPrinter:Say(nLin + 10,nCol + 100,"Lote: " + alltrim(cLote) ,oFont10)
			nLin+= 10
			oPrinter:Say(nLin + 10,nCol + 100,"Validade: " + dData ,oFont10)

            //MSBAR("CODE128",0.7,0.8,alltrim(QRYTMP->B1_CODGTIN),oPrinter,.F.,,.F.,0.013,0.7,,,,.F.)
			MSBAR("CODE128",0.5,0.6,alltrim(QRYTMP->B1_CODGTIN),oPrinter,.F.,,.F.,0.05,0.7,.F.,,,.F.)
/*			| 01 cTypeBar String com o tipo do codigo de barras               |
|    "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"                    |
|    "INT25","MAT25,"IND25","CODABAR","CODE3_9"                    |
| 02 nRow           Numero da Linha em centimentros               |
| 03 nCol           Numero da coluna em centimentros               |
| 04 cCode          String com o conteudo do codigo               |
| 05 oPr            Objeto Printer                                 |
| 06 lcheck        Se calcula o digito de controle               |
| 07 Cor            Numero da Cor, utilize a "common.ch"           |
| 08 lHort          Se imprime na Horizontal                      |
| 09 nWidth        Numero do Tamanho da barra em centimetros      |
| 10 nHeigth        Numero da Altura da barra em milimetros        |
| 11 lBanner        Se imprime o linha em baixo do codigo          |
| 12 cFont          String com o tipo de fonte                     |
| 13 cMode          String com o modo do codigo de barras CODE128 |/*/
			//oPrinter:FWMSBAR("CODE128" , nLinC , nColC, alltrim(QRYTMP->B1_CODGTIN) , oPrinter,/*lCheck*/,/*Color*/,/*lHorz*/, nWidth, nHeigth,/*teste vertical*/,/*cFont*/,/*cMode*/,/*lPrint*/,nPFWidth,nPFHeigth,lCmtr2Pix)
			//oPrinter:Box( 100,70,200,70,"-1" )
 
			oPrinter:EndPage()
		Next
		QRYTMP->(DbSkip())
	EndDo
	oPrinter:Print()
	QRYTMP->(DbCloseArea())
 
Return
 
/*Montagem da tela de perguntas*/
Static Function ValidPerg()
	Local aRet 		:= {}
	Local aParamBox	:= {}
	Local lRet 		:= .F.
	Local aOpcoes	:= {"Microsoft Print to PDF"}
	Local cProdDe	:= ""
	Local cProdAte	:= ""
	Local cLocal	:= Space(99)
	Local nQuant    := 1
 
	//If Empty(getMV("ZZ_IMPRESS")) //se o parametro estiver vazio, ja o defino com a impressora PDFCreator 
	//	aOpcoes := {"PDFCreator"}
	//Else
	//	aOpcoes := Separa(getMV("ZZ_IMPRESS"),";")
	//Endif
 
	cProdDe := space(TamSX3("B1_COD")[1])
	cProdAte:= REPLICATE("Z",TAMSX3("B1_COD")[1])
 
	aAdd(aParamBox,{01,"Produto de"	  			,cProdDe 	,""					,"","SB1"	,"", 60,.F.})	// MV_PAR01
	aAdd(aParamBox,{01,"Produto ate"	   		,cProdAte	,""					,"","SB1"	,"", 60,.T.})	// MV_PAR02
	aAdd(aParamBox,{01,"Quantidade Etiqueta"	,nQuant		,"@E 9999"			,"",""		,"", 60,.F.})	// MV_PAR03
	aadd(aParamBox,{02,"Imprimir em"			,"Microsoft Print to PDF" /*Space(50)*/	,aOpcoes			,100,".T.",.T.,".T."})		// MV_PAR04
 
	If ParamBox(aParamBox,"Etiqueta Produto",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,FUNNAME(),.T.,.T.)
 
		If ValType(MV_PAR04) == "N" //Algumas vezes ocorre um erro de ao invés de selecionar o conteúdo, seleciona a ordem, então verifico se é numerico, se for, eu me posiciono na impressora desejada para pegar o seu nome
			MV_PAR04 := aOpcoes[MV_PAR04]
		EndIf
 
		lRet := .T.
	EndIf
Return lRet

Static Function Valid(dData1, dValid)

Local _aArea := FWGetArea()
Local _cCodPro := " "
Local _lRet := .T.
Local _cQuery := ""
lOCAL _dDvalid := stod("//")
/*
Para fins de identificação dos produtos produzidos como Produtos Intermediários (PI’s) e Produtos Acabados
(PA’s) deverá ser emitida a etiqueta de produção.
Esta etiqueta deve ser emitida na rotina MATA650, (na tela de ordem de produção) diretamente no browser,
através do botão outras ações – Etiqueta Produção. Ao clicar neste botão, deverá ser exibida tela de parâmetros,
permitindo o usuário definir alguns dos dados que serão impressos, conforme detalhamento a seguir:
a) Código de Barras: A partir do C2_PRODUTO, consultar B1_CODGTIN e imprimir código de barras
b) Código do Produto: C2_PRODUTO; “12” (Apesar do Protheus permitir até 15 caracteres, o cliente
atualmente utiliza apenas 4 caracteres, prever layout para 5).
c) Descrição Produto: A partir do C2_PRODUTO, consultar B1_DESC;
d) Código ONU: A partir do C2_PRODUTO, Consultar B5_ONU;(se não tiver dados da ONU, retornar vazio)
e) Descrição ONU: A partir do C2_PRODUTO, Consultar B5_ONU, e obter DY3_DESCRI
f) Risco ONU: A partir do C2_PRODUTO, Consultar B5_ONU, e obter DY3_NRISCO
g) OP: C2_NUM+C2_ITEM+C2_SEQUEN;
h) Lote: C2_NUM+C2_ITEM+C2_SEQUEN+“001” (Sabe-se que o lote é gerado somente no apontamento,
porém no projeto da Koube o lote terá o mesmo número da ordem de produção, acrescido de uma
sequência numérica de três caracteres a começar por 001.) Neste caso na etiqueta será apenas uma
representação gráfica do lote.
i) Validade: A partir da data da C2_DATPRI, calcular validade conforme B1_PRVALID, retornando apenas
mês e ano. Exemplo, se a C2_DATPRI for 16/11/2024 – e no B1_PRVALID estiver com 15 dias, o resultado
é 01/12/2024 – neste caso imprimir apenas 12/24
j) QRCode: Concatenar Código do Produto + Lote + Validade (MMAA)
*/

_dDvalid := DaySum( stod(dData1), dValid )
//_dDvalid := DaySum( stod(substr(dData1,7,2) + "/" + substr(dData1,4,2)+ "/" + substr(dData1,1,2)), dValid ) 	
//substr(dData1,7,2) + "/" + substr(dData1,4,2)+ "/" + substr(dData1,1,2)
_dDvalid := substr(anomes(_dDvalid),5,2) + substr(anomes(_dDvalid),1,4)




Return _dDvalid
