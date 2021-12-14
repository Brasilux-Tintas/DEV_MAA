/*----------------------------------------------------------------------------//
!short: SAY  */
#xcommand REDEFINE SAY [<oSay>] ;
				 [ <label: PROMPT, VAR> <cText> ] ;
				 [ PICTURE <cPict> ] ;
				 [ ID <nId> ] ;
				 [ <dlg: OF,WINDOW,DIALOG > <oWnd> ] ;
				 [ <color: COLOR,COLORS > <nClrText> [,<nClrBack> ] ] ;
				 [ <update: UPDATE > ] ;
				 [ FONT <oFont> ] ;
		 => ;
			 [ <oSay> := ] TSay():ReDefine( <nId>, <{cText}>, <oWnd>, ;
								<cPict>, <nClrText>, <nClrBack>, <.update.>, <oFont> )

#xcommand @ <nRow>, <nCol> SAY [ <oSay> <label: PROMPT,VAR > ] <cText> ;
				 [ PICTURE <cPict> ] ;
				 [ <dlg: OF,WINDOW,DIALOG > <oWnd> ] ;
				 [ FONT <oFont> ]  ;
				 [ <lCenter: CENTERED, CENTER > ] ;
				 [ <lRight:  RIGHT > 	] ;
				 [ <lBorder: BORDER >	] ;
				 [ <lPixel: PIXEL, PIXELS > ] ;
				 [ <color: COLOR,COLORS > <nClrText> [,<nClrBack> ] ] ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ <design: DESIGN >  ] ;
				 [ <update: UPDATE >  ] ;
				 [ <lShaded: SHADED, SHADOW > ] ;
				 [ <lBox:	 BOX	 >  ] ;
				 [ <lRaised: RAISED > ] ;
		=> ;
			 [ <oSay> := ] TSay():New( <nRow>, <nCol>, <{cText}>,;
				 [<oWnd>], [<cPict>], <oFont>, <.lCenter.>, <.lRight.>, <.lBorder.>,;
				 <.lPixel.>, <nClrText>, <nClrBack>, <nWidth>, <nHeight>,;
				 <.design.>, <.update.>, <.lShaded.>, <.lBox.>, <.lRaised.> )

/*----------------------------------------------------------------------------//
!short: BOX - GROUPS */
#xcommand @ <nTop>, <nLeft> [ GROUP <oGroup> ] TO <nBottom>, <nRight > ;
				 [ <label:LABEL,PROMPT> <cLabel> ] ;
				 [ OF <oWnd> ] ;
				 [ COLOR <nClrFore> [,<nClrBack>] ] ;
				 [ <lPixel: PIXEL> ] ;
				 [ <lDesign: DESIGN> ] ;
		 => ;
			 [ <oGroup> := ] TGroup():New( <nTop>, <nLeft>, <nBottom>, <nRight>,;
				 <cLabel>, <oWnd>, <nClrFore>, <nClrBack>, <.lPixel.>,;
				 [<.lDesign.>] )

#xcommand REDEFINE GROUP [ <oGroup> ] ;
				 [ <label:LABEL,PROMPT> <cLabel> ] ;
				 [ ID <nId> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ COLOR <nClrFore> [,<nClrBack>] ] ;
		 => ;
			 [ <oGroup> := ] TGroup():ReDefine( <nId>, <cLabel>, <oWnd>,;
				 <nClrFore>, <nClrBack> )

/*----------------------------------------------------------------------------//
!short: BITMAP */

#xcommand @ <nRow>, <nCol> BITMAP [ <oBmp> ] ;
				 [ <resource: NAME, RESNAME, RESOURCE> <cResName> ] ;
				 [ <file: FILE, FILENAME, DISK> <cBmpFile> ] ;
				 [ <NoBorder:NOBORDER, NO BORDER> ] ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <lClick: ON CLICK, ON LEFT CLICK> <uLClick> ] ;
				 [ <rClick: ON RIGHT CLICK> <uRClick> ] ;
				 [ <scroll: SCROLL> ] ;
				 [ <adjust: ADJUST> ] ;
				 [ CURSOR <oCursor> ] ;
				 [ <pixel: PIXEL>   ] ;
				 [ MESSAGE <cMsg>   ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
				 [ VALID <uValid> ] ;
				 [ <lDesign: DESIGN> ] ;
		 => ;
			 [ <oBmp> := ] TBitmap():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
				 <cResName>, <cBmpFile>, <.NoBorder.>, <oWnd>,;
				 [\{ |nRow,nCol,nKeyFlags| <uLClick> \} ],;
				 [\{ |nRow,nCol,nKeyFlags| <uRClick> \} ], <.scroll.>,;
				 <.adjust.>, <oCursor>, <cMsg>, <.update.>,;
				 <{uWhen}>, <.pixel.>, <{uValid}>, <.lDesign.> )

#xcommand REDEFINE BITMAP [ <oBmp> ] ;
				 [ ID <nId> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <resource: NAME, RESNAME, RESOURCE> <cResName> ] ;
				 [ <file: FILE, FILENAME, DISK> <cBmpFile> ] ;
				 [ <lClick: ON ClICK, ON LEFT CLICK> <uLClick> ] ;
				 [ <rClick: ON RIGHT CLICK> <uRClick> ] ;
				 [ <scroll: SCROLL> ] ;
				 [ <adjust: ADJUST> ] ;
				 [ CURSOR <oCursor> ] ;
				 [ MESSAGE <cMsg>   ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
				 [ VALID <uValid> ] ;
		 => ;
			 [ <oBmp> := ] TBitmap():ReDefine( <nId>, <cResName>, <cBmpFile>,;
				 <oWnd>, [\{ |nRow,nCol,nKeyFlags| <uLClick> \}],;
							[\{ |nRow,nCol,nKeyFlags| <uRClick> \}],;
				 <.scroll.>, <.adjust.>, <oCursor>, <cMsg>, <.update.>,;
				 <{uWhen}>, <{uValid}> )

#xcommand DEFINE BITMAP [<oBmp>] ;
				 [ <resource: NAME, RESNAME, RESOURCE> <cResName> ] ;
				 [ <file: FILE, FILENAME, DISK> <cBmpFile> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
		 => ;
			 [ <oBmp> := ] TBitmap():Define( <cResName>, <cBmpFile>, <oWnd> )

/*----------------------------------------------------------------------------//
!short: RADIOBUTTONS */

#xcommand @ <nRow>, <nCol> RADIO [ <oRadMenu> VAR ] <nVar> ;
				 [ <prm: PROMPT, ITEMS> <cItems,...> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <help:HELPID, HELP ID> <nHelpId,...> ] ;
				 [ <change: ON CLICK, ON CHANGE> <uChange> ] ;
				 [ COLOR <nClrFore> [,<nClrBack>] ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ VALID <uValid> ] ;
				 [ <lDesign: DESIGN> ] ;
				 [ <lLook3d: 3D> ] ;
				 [ <lPixel: PIXEL> ] ;
		 => ;
			 [ <oRadMenu> := ] TRadMenu():New( <nRow>, <nCol>, {<cItems>},;
				 [bSETGET(<nVar>)], <oWnd>, [{<nHelpId>}], <{uChange}>,;
				 <nClrFore>, <nClrBack>, <cMsg>, <.update.>, <{uWhen}>,;
				 <nWidth>, <nHeight>, <{uValid}>, <.lDesign.>, <.lLook3d.>,;
				 <.lPixel.> )

#xcommand REDEFINE RADIO [ <oRadMenu> VAR ] <nVar> ;
				 [ ID <nId,...> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <help:HELPID, HELP ID> <nHelpId,...> ] ;
				 [ <change: ON CLICK, ON CHANGE> <uChange> ] ;
				 [ COLOR <nClrFore> [,<nClrBack>] ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
				 [ VALID <uValid> ] ;
		 => ;
			 [ <oRadMenu> := ] TRadMenu():Redefine( [bSETGET(<nVar>)],;
				 <oWnd>, [{<nHelpId>}], \{ <nId> \}, <{uChange}>, <nClrFore>,;
				 <nClrBack>, <cMsg>, <.update.>, <{uWhen}>, <{uValid}> )

/*----------------------------------------------------------------------------//
!short: ButtonBar Commands */

#xcommand DEFINE BUTTONBAR [ <oBar> ] ;
				 [ <size: SIZE, BUTTONSIZE, SIZEBUTTON > <nWidth>, <nHeight> ] ;
				 [ <_3d: 3D, 3DLOOK> ] ;
				 [ <mode: TOP, LEFT, RIGHT, BOTTOM, FLOAT> ] ;
				 [ <wnd: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ CURSOR <oCursor> ] ;
		=> ;
			[ <oBar> := ] TBar():New( <oWnd>, <nWidth>, <nHeight>, <._3d.>,;
				 [ Upper(<(mode)>) ], <oCursor> )

#xcommand @ <nRow>, <nCol> BUTTONBAR [ <oBar> ] ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ BUTTONSIZE <nBtnWidth>, <nBtnHeight> ] ;
				 [ <_3d: 3D, 3DLOOK> ] ;
				 [ <mode: TOP, LEFT, RIGHT, BOTTOM, FLOAT> ] ;
				 [ <wnd: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ CURSOR <oCursor> ] ;
		=> ;
			[ <oBar> := ] TBar():NewAt( <nRow>, <nCol>, <nWidth>, <nHeight>,;
				 <nBtnWidth>, <nBtnHeight>, <oWnd>, <._3d.>, [ Upper(<(mode)>) ],;
				 <oCursor> )

#xcommand DEFINE BUTTON [ <oBtn> ] ;
				 [ <bar: OF, BUTTONBAR > <oBar> ] ;
				 [ <resource: NAME, RESNAME, RESOURCE> <cResName1> ;
					 [,<cResName2>[,<cResName3>] ] ] ;
				 [ <file: FILE, FILENAME, DISK> <cBmpFile1> ;
					 [,<cBmpFile2>[,<cBmpFile3>] ] ] ;
				 [ <action:ACTION,EXEC> <uAction,...> ] ;
				 [ <group: GROUP > ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <adjust: ADJUST > ] ;
				 [ WHEN <WhenFunc> ] ;
				 [ TOOLTIP <cToolTip> ] ;
				 [ <lPressed: PRESSED> ] ;
				 [ ON DROP <bDrop> ] ;
				 [ AT <nPos> ] ;
				 [ PROMPT <cPrompt> ] ;
				 [ FONT <oFont> ] ;
				 [ <lNoBorder: NOBORDER> ] ;
		=> ;
			[ <oBtn> := ] TBtnBmp():NewBar( <cResName1>, <cResName2>,;
				<cBmpFile1>, <cBmpFile2>, <cMsg>, [{|This|<uAction>}],;
				<.group.>, <oBar>, <.adjust.>, <{WhenFunc}>,;
				<cToolTip>, <.lPressed.>, [\{||<bDrop>\}], [\"<uAction>\"], <nPos>,;
				<cPrompt>, <oFont>, [<cResName3>], [<cBmpFile3>], [!<.lNoBorder.>] )

#xcommand REDEFINE BTNBMP [<oBtn>] ;
				 [ ID <nId> ] ;
				 [ <bar: OF, BUTTONBAR > <oBar> ] ;
				 [ <resource: NAME, RESNAME, RESOURCE> <cResName1> ;
					 [,<cResName2>[,<cResName3>] ] ] ;
				 [ <file: FILE, FILENAME, DISK> <cBmpFile1> ;
					 [,<cBmpFile2>[,<cBmpFile3>] ] ] ;
				 [ <action:ACTION,EXEC> <uAction,...> ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <adjust: ADJUST > ] ;
				 [ WHEN <uWhen> ] ;
				 [ <lUpdate: UPDATE> ] ;
				 [ TOOLTIP <cToolTip> ] ;
				 [ PROMPT <cPrompt> ] ;
				 [ FONT <oFont> ] ;
		=> ;
			[ <oBtn> := ] TBtnBmp():ReDefine( <nId>, <cResName1>, <cResName2>,;
				<cBmpFile1>, <cBmpFile2>, <cMsg>, [{|Self|<uAction>}],;
				<oBar>, <.adjust.>, <{uWhen}>, <.lUpdate.>, <cToolTip>,;
				<cPrompt>, <oFont>, [<cResName3>], [<cBmpFile3>] )

#xcommand @ <nRow>, <nCol> BTNBMP [<oBtn>] ;
				 [ <resource: NAME, RESNAME, RESOURCE> <cResName1> [,<cResName2>] ] ;
				 [ <file: FILE, FILENAME, DISK> <cBmpFile1> [,<cBmpFile2>] ] ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ ACTION <uAction,...> ] ;
				 [ <of:OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ WHEN <uWhen> ] ;
				 [ <adjust: ADJUST> ] ;
				 [ <lUpdate: UPDATE> ] ;
		=> ;
			[ <oBtn> := ] TBtnBmp():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
				<cResName1>, <cResName2>, <cBmpFile1>, <cBmpFile2>,;
				[{|Self|<uAction>}], <oWnd>, <cMsg>, <{uWhen}>, <.adjust.>,;
				<.lUpdate.> )

