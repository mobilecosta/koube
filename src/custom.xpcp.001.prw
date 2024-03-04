#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#Include "TopConn.ch"
#INCLUDE "msobject.ch"
//--------------------------------------------
/*/{Protheus.doc} CUSTOM.XPCP.001
RELATORIO IMPRESSAO DE ETIQUETA
@type function
@version 1.0
@author:
@since:
@alterado por: Roberto R. Mezzalira - 23/02/2024
/*/
//--------------------------------------------

User Function APCPET001()

	If ValidPerg()
		MsAguarde({|| ImpEtiq() },"Impressão de etiqueta","Aguarde...")
	EndIf
 
Return 

   
Static Function ImpEtiq()
	Local cQuery	:= ""
	Local _cCodPro	:= MV_PAR03
	Local nQuant	:= MV_PAR05
	Local cImpress  := MV_PAR06 //"Microsoft Print to PDF" //Alltrim(MV_PAR04) //pego o nome da impressora
	Local oFont16	:= TFont():New('Arial',16,16,,.F.,,,,.T.,.F.,.F.)
	Local oFont10	:= TFont():New('Arial',10,10,,.F.,,,,.T.,.F.,.F.)
	Local oFont45	:= TFont():New('Arial',45,45,,.F.,,,,.T.,.F.,.F.)
	Local oFont14	:= TFont():New('Arial',14,14,,.F.,,,,.T.,.F.,.F.)

	Local cLote		:= "001"
	Local cData     := STOD("  /  /  ")
	Local cDatav    := " "
 	Local lAdjustToLegacy 	:= .F.
	Local lDisableSetup  	:= .F.
 
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

    Local oSqlMov      := Nil
	Local cAliasTmp    := " "
	Local nR           := 0
	Local cLocal       := "c:\temp\"
	Local nPrintType   := 6
    Local cFile        := 'ETQOP'+ALLTRIM(MV_PAR01)+'.PDF'
	Local oPrinter     := Nil
	Local oSetup	   := Nil
	Local cRelName	   := "APCPET001"
	Local nFlags	   := PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION
	Local aDevice	   := {"PDF"}//{"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
	Local cDevice	   := "PDF"
	Local cSession	:= GetPrinterSession()

	MsProcTxt("Identificando a impressora...")
	cDevice	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
    //nPrintType	:= aScan(aDevice,{|x| x == cDevice })     
    oPrinter	:= FWMSPrinter():New(cFile, 6, lAdjustToLegacy ,cLocal, .T.)
   /* oSetup		:= FWPrintSetup():New (nFlags,cRelName)
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrient)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
*/
	oPrinter:SetPaperSize(0,60,100)

	cAliasTmp	:= GetNextAlias()
 	cQuery := " SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_OP,C2_PRODUTO,C2_DATPRI, "+CRLF 
	cQuery += "        B1_DESC ,B1_CODGTIN ,B1_PRVALID ,B5_ONU ,DY3_ONU ,DY3_DESCRI , DY3_NRISCO"+CRLF 
	cQuery += " FROM " + RetSqlName("SC2") + " SC2 "+CRLF 
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "+CRLF 
	cQuery += " ON SB1.B1_FILIAL='" + xFilial("SB1")+"' AND B1_COD=C2_PRODUTO AND SB1.D_E_L_E_T_ = ' '"+CRLF 
	cQuery += " LEFT JOIN " + RetSqlName("SB5") + " SB5"+CRLF 
	cQuery += " ON SB5.B5_FILIAL = '" + xFilial("SB1") + "'AND SB5.B5_COD = SC2.C2_PRODUTO AND SB5.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " LEFT JOIN " + RetSqlName("DY3") + " DY3 "+CRLF
	cQuery += " ON DY3.DY3_FILIAL = '"+SUBSTR(xFilial("SB1"),1,4)+"'AND DY3.DY3_ONU = SB5.B5_ONU AND DY3_ITEM ='01' AND DY3.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " WHERE SC2.C2_FILIAL ='" + xFilial("SC2")+"' AND "+CRLF
	cQuery += "       SC2.C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "+CRLF 
	cQuery += "       SC2.C2_PRODUTO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "+CRLF 
    cQuery += "       SC2.D_E_L_E_T_=' '"+CRLF  
      
	oSqlMov:= FWPreparedStatement():New()
	oSqlMov:SetQuery(cQuery)
	cQry:= oSqlMov:GetFixQuery()
	cAliasTmp := MpSysOpenQuery(cQry)	
	Dbselectarea((cAliasTmp))

	(cAliasTmp)->(DbGoTop())
 
	oPrinter:SetMargin(001,001,001,001)
 
	DO While (cAliasTmp)->(!Eof())

		For nR := 1 to nQuant

			nLin := 10
			nCol := 15 // 22
 
			MsProcTxt("Imprimindo "+alltrim((cAliasTmp)->B1_CODGTIN) + " - " + alltrim((cAliasTmp)->B1_DESC)+"...")

			oPrinter:StartPage()
			nLinC		:= 4.95		//Linha que será impresso o Código de Barra
			nColC		:= 1.6		//Coluna que será impresso o Código de Barra
			nWidth	 	:= 0.0164	//Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta é 0.0164
			nHeigth   	:= 0.6		//Numero da Altura da barra. Default 1.5 --- limite de altura é 0.3
			lBanner		:= .T.		//Se imprime a linha com o código embaixo da barra. Default .T.
			nPFWidth	:= 0.8		//Número do índice de ajuste da largura da fonte. Default 1
			nPFHeigth	:= 0.9		//Número do índice de ajuste da altura da fonte. Default 1
			lCmtr2Pix	:= .T.		//Utiliza o método Cmtr2Pix() do objeto Printer.Default .T.
			
			oPrinter:Box(60, 90, 90, 180, "-3")                                                               

			oPrinter:Say(80,nCol + 90, alltrim((cAliasTmp)->C2_PRODUTO) ,oFont10)

 			oPrinter:Say(nLin,nCol +195, "ONU " + alltrim((cAliasTmp)->DY3_ONU),oFont10)
			oPrinter:Say(nLin + 10, nCol + 040, alltrim((cAliasTmp)->DY3_DESCRI) + "  RISCO " + (cAliasTmp)->DY3_NRISCO ,oFont10)
			nLin+= 5
			nLin+= 5
			//linha coluna
			cData := DTOC(DaySum( stod((cAliasTmp)->C2_DATPRI), (cAliasTmp)->B1_PRVALID ))
			cDatav:= SUBSTR(cData,4,2)+"/"+SUBSTR(cData,9,2)//validade

			//coluna linha tamanho - Não informado onde buscar o a sequencia do lote, Opção D3_LOTECTL
			oPrinter:Say(210, 120, alltrim((cAliasTmp)->DY3_NRISCO) ,oFont45)
			oPrinter:DataMatrix(190,110,alltrim((cAliasTmp)->C2_NUM + " " + (cAliasTmp)->C2_ITEM  + " " +  (cAliasTmp)->C2_SEQUEN)+" "+cDatav, 80)

			nLin+= 95

			oPrinter:Say(nLin + 10,nCol + 50, alltrim((cAliasTmp)->B1_DESC) ,oFont16)
			nLin+= 12
			oPrinter:Say(nLin + 10,nCol + 50,"Ordem de Produção: " + alltrim((cAliasTmp)->C2_NUM + " " + (cAliasTmp)->C2_ITEM  + " " + (cAliasTmp)->C2_SEQUEN) ,oFont10)
			nLin+= 12

			cLote := (cAliasTmp)->C2_NUM+(cAliasTmp)->C2_ITEM+(cAliasTmp)->C2_SEQUEN+'001'
			If cLote = " " 
				cLote := "xxxxxx"
			Endif	
			oPrinter:Say(nLin + 10,nCol + 50,"Lote: " + alltrim(cLote) ,oFont10)
			nLin+= 12
   			oPrinter:Say(nLin + 10,nCol + 50,"Validade: " + cDatav ,oFont10)
			// FWMsPrinter():FWMsBar(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz, nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
            oPrinter:FwMsBar(	"CODE128" /* cTypeBar */, 0.8 /* nRow */, 1 /* nCol */,(cAliasTmp)->B1_CODGTIN /* cCode */, oPrinter /* oPrint */,;
								.T. /* lCheck */, NIL /* Color */, .f. /* lHorz */, 0.02 /* nWidth */, 0.8 /* nHeigth */, .F. /* lBanner */,;
								"Arial" /* cFont */ , NIL /* cMode */, .F. /* lPrint */, 0.8 /* nPFWidth */, 0.9 /*nPFHeigth */, .F. /*lCmtr2Pix*/)
          
			oPrinter:EndPage()

		Next
		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())
	
	oPrinter:Preview()
	//oPrinter:Print()
	
 
Return
 
/*Montagem da tela de perguntas*/
Static Function ValidPerg()
	Local aParamBox	:= {}
	Local lRet 		:= .F.
	Local aOpcoes	:= {"Microsoft Print to PDF"}
	Local cProdDe	:= ""
	Local cProdAte	:= ""
	Local nTamop    := (TamSX3("C2_NUM")[1])+(TamSX3("C2_ITEM")[1])+(TamSX3("C2_SEQUEN")[1])
	Local cOpde	    := SPACE(nTamop)
	Local cOpate	:= SPACE(nTamop)
	Local nQuant    := 1
	
	cProdDe := space(TamSX3("B1_COD")[1])
	cProdAte:= REPLICATE("Z",TAMSX3("B1_COD")[1])
    
	aAdd(aParamBox,{01,"Ordem Produção de"	 	,cOpde 	    ,""					,"","SC2KOB","", 60,.F.})	// MV_PAR01
	aAdd(aParamBox,{01,"Ordem Produção ate"	  	,cOpate   	,""					,"","SC2KOB","", 60,.T.})	// MV_PAR02
	aAdd(aParamBox,{01,"Produto de"	  			,cProdDe 	,""					,"","SB1"	,"", 60,.F.})	// MV_PAR03
	aAdd(aParamBox,{01,"Produto ate"	   		,cProdAte	,""					,"","SB1"	,"", 60,.T.})	// MV_PAR04
	aAdd(aParamBox,{01,"Quantidade Etiqueta"	,nQuant		,"@E 9999"			,"",""		,"", 60,.F.})	// MV_PAR05
	aadd(aParamBox,{02,"Imprimir em"			,"Microsoft Print to PDF" /*Space(50)*/	,aOpcoes,100,".T.",.T.,".T."})	// MV_PAR06
  	
	IF ParamBox(aParamBox,"Etiqueta Produto",/*aRet*/,/*bOk*/,/*aButtons*/,.T.,,,,FUNNAME(),.T.,.T.)
 
		If ValType(MV_PAR06) == "N" //Algumas vezes ocorre um erro de ao invés de selecionar o conteúdo, seleciona a ordem, então verifico se é numerico, se for, eu me posiciono na impressora desejada para pegar o seu nome
			MV_PAR06 := aOpcoes[MV_PAR06]
		EndIf
 
		lRet := .T.
	EndIf

Return lRet
