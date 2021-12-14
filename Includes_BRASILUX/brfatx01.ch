#Command @ <nRow>,<nCol> GET <cVar> [PICTURE <cPicture>] [VALID <bValid>] [WHEN <bWhen>] [F3 <cF3>] [SIZE <nW>,<nH>] [OBJECT <oGet>] [<lMemo: MEMO>] [<lPass: PASSWORD>];
	=> [ <oGet> := ] IW_Edit(<nRow>,<nCol>,<(cVar)>,[<cPicture>],<nW>,<nH>,[\{||<bValid>\}],[\{||<bWhen>\}],[<cF3>],[<.lMemo.>],[<.lPass.>],[{|x| iif(PCount()>0,<cVar> := x,<cVar>) }])

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
!short: CHECKBOX */
#xcommand REDEFINE CHECKBOX [ <oCbx> VAR ] <lVar> ;
				 [ ID <nId> ] ;
				 [ <of:OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <help:HELPID, HELP ID> <nHelpId> ] ;
				 [ <click:ON CLICK, ON CHANGE> <uClick> ];
				 [ VALID <uValid> ] ;
				 [ <color: COLOR, COLORS> <nClrFore> [,<nClrBack>] ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
		 => ;
			 [ <oCbx> := ] TCheckBox():ReDefine( <nId>, bSETGET(<lVar>),;
				 <oWnd>, <nHelpId>, [<{uClick}>], <{uValid}>, <nClrFore>,;
				 <nClrBack>, <cMsg>, <.update.>, <{uWhen}> )

#xcommand @ <nRow>, <nCol> CHECKBOX [ <oCbx> VAR ] <lVar> ;
				 [ PROMPT <cCaption> ] ;
				 [ <of:OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ <help:HELPID, HELP ID> <nHelpId> ] ;
				 [ FONT <oFont> ] ;
				 [ <change: ON CLICK, ON CHANGE> <uClick> ] ;
				 [ VALID   <ValidFunc> ] ;
				 [ <color: COLOR, COLORS> <nClrFore> [,<nClrBack>] ] ;
				 [ <design: DESIGN> ] ;
				 [ <pixel: PIXEL> ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <WhenFunc> ] ;
		=> ;
			[ <oCbx> := ] TCheckBox():New( <nRow>, <nCol>, <cCaption>,;
				 [bSETGET(<lVar>)], <oWnd>, <nWidth>, <nHeight>, <nHelpId>,;
				 [<{uClick}>], <oFont>, <{ValidFunc}>, <nClrFore>, <nClrBack>,;
				 <.design.>, <.pixel.>, <cMsg>, <.update.>, <{WhenFunc}> )

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

/*----------------------------------------------------------------------------//
!short: Icons */

#xcommand @ <nRow>, <nCol> ICON [ <oIcon> ] ;
				 [ <resource: NAME, RESOURCE, RESNAME> <cResName> ] ;
				 [ <file: FILE, FILENAME, DISK> <cIcoFile> ] ;
				 [ <border:BORDER> ] ;
				 [ ON CLICK <uClick> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
				 [ COLOR <nClrFore> [,<nClrBack>] ] ;
		 => ;
			 [ <oIcon> := ] TIcon():New( <nRow>, <nCol>, <cResName>,;
				 <cIcoFile>, <.border.>, <{uClick}>, <oWnd>, <.update.>,;
				 <{uWhen}>, <nClrFore>, <nClrBack> )

#xcommand REDEFINE ICON <oIcon> ;
				 [ ID <nId> ] ;
				 [ <resource: NAME, RESOURCE, RESNAME> <cResName> ] ;
				 [ <file: FILE, FILENAME, DISK> <cIcoFile> ] ;
				 [ ON CLICK <uClick> ] ;
				 [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
		 => ;
			 [ <oIcon> := ] TIcon():ReDefine( <nId>, <cResName>, <cIcoFile>,;
				 <{uClick}>, <.update.>, <oWnd>, <{uWhen}> )

#xcommand DEFINE ICON <oIcon> ;
				 [ <resource: NAME, RESOURCE, RESNAME> <cResName> ] ;
				 [ <file: FILE, FILENAME, DISK> <cIcoFile> ] ;
				 [ WHEN <WhenFunc> ] ;
		 => ;
			 <oIcon> := TIcon():New( ,, <cResName>, <cIcoFile>, <{WhenFunc}> )

/*----------------------------------------------------------------------------//
!short: PUSHBUTTON */

#xcommand @ <nRow>, <nCol> BUTTON [ <oBtn> PROMPT ] <cCaption> ;
				 [ SIZE <nWidth>, <nHeight> ] ;
				 [ ACTION <uAction> ] ;
				 [ <default: DEFAULT> ] ;
				 [ <of:OF, WINDOW, DIALOG> <oWnd> ] ;
				 [ <help:HELP, HELPID, HELP ID> <nHelpId> ] ;
                 [ FONT <oFont> ] ;
				 [ <pixel: PIXEL> ] ;
				 [ <design: DESIGN> ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <WhenFunc> ] ;
				 [ VALID <uValid> ] ;
				 [ <lCancel: CANCEL> ] ;
		=> ;
			[ <oBtn> := ] TButton():New( <nRow>, <nCol>, <cCaption>, <oWnd>,;
				<{uAction}>, <nWidth>, <nHeight>, <nHelpId>, <oFont>, <.default.>,;
				<.pixel.>, <.design.>, <cMsg>, <.update.>, <{WhenFunc}>,;
				<{uValid}>, <.lCancel.> )

#xcommand REDEFINE BUTTON [ <oBtn> ] ;
				 [ ID <nId> <of:OF, WINDOW, DIALOG> <oDlg> ] ;
				 [ ACTION <uAction,...> ] ;
				 [ <help:HELP, HELPID, HELP ID> <nHelpId> ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <WhenFunc> ] ;
				 [ VALID <uValid> ] ;
				 [ PROMPT <cPrompt> ] ;
				 [ <lCancel: CANCEL> ] ;
		 => ;
			 [ <oBtn> := ] TButton():ReDefine( <nId>, [\{||<uAction>\}], <oDlg>,;
				 <nHelpId>, <cMsg>, <.update.>, <{WhenFunc}>, <{uValid}>,;
				 <cPrompt>, <.lCancel.> )

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
!short: GET  */

#command @ <nRow>, <nCol> GET [ <oGet> VAR ] <uVar> ;
    [ <dlg: OF, WINDOW, DIALOG> <oWnd> ] ;
    [ <memo: MULTILINE, MEMO, TEXT> ] ;
    [ <color:COLOR,COLORS> <nClrFore> [,<nClrBack>] ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ FONT <oFont> ] ;
    [ <hscroll: HSCROLL> ] ;
    [ CURSOR <oCursor> ] ;
    [ <pixel: PIXEL> ] ;
    [ MESSAGE <cMsg> ] ;
    [ <update: UPDATE> ] ;
    [ WHEN <uWhen> ] ;
    [ <lCenter: CENTER, CENTERED> ] ;
    [ <lRight: RIGHT> ] ;
    [ <readonly: READONLY, NO MODIFY> ] ;
    [ VALID <uValid> ] ;
    [ ON CHANGE <uChange> ] ;
    [ <lDesign: DESIGN> ] ;
    [ <lNoBorder: NO BORDER, NOBORDER> ] ;
    [ <lNoVScroll: NO VSCROLL> ] ;
     => ;
   [ <oGet> := ] TMultiGet():New( <nRow>, <nCol>, bSETGET(<uVar>),;
     [<oWnd>], <nWidth>, <nHeight>, <oFont>, <.hscroll.>,;
     <nClrFore>, <nClrBack>, <oCursor>, <.pixel.>,;
     <cMsg>, <.update.>, <{uWhen}>, <.lCenter.>,;
     <.lRight.>, <.readonly.>, <{uValid}>,;
     [\{|nKey, nFlags, Self| <uChange>\}], <.lDesign.>,;
     [<.lNoBorder.>], [<.lNoVScroll.>] )

#command @ <nRow>, <nCol> GET [ <oGet> VAR ] <uVar> ;
    [ <dlg: OF, WINDOW, DIALOG> <oWnd> ] ;
    [ PICTURE <cPict> ] ;
    [ VALID <ValidFunc> ] ;
    [ <color:COLOR,COLORS> <nClrFore> [,<nClrBack>] ] ;
    [ SIZE <nWidth>, <nHeight> ]  ;
    [ FONT <oFont> ] ;
    [ <design: DESIGN> ] ;
    [ CURSOR <oCursor> ] ;
    [ <pixel: PIXEL> ] ;
    [ MESSAGE <cMsg> ] ;
    [ <update: UPDATE> ] ;
    [ WHEN <uWhen> ] ;
    [ <lCenter: CENTER, CENTERED> ] ;
    [ <lRight: RIGHT> ] ;
    [ ON CHANGE <uChange> ] ;
    [ <readonly: READONLY, NO MODIFY> ] ;
    [ <pass: PASSWORD> ] ;
    [ <lNoBorder: NO BORDER, NOBORDER> ] ;
    [ <help:HELPID, HELP ID> <nHelpId> ] ;
     => ;
   [ <oGet> := ] TGet():New( <nRow>, <nCol>, bSETGET(<uVar>),;
     [<oWnd>], <nWidth>, <nHeight>, <cPict>, <{ValidFunc}>,;
     <nClrFore>, <nClrBack>, <oFont>, <.design.>,;
     <oCursor>, <.pixel.>, <cMsg>, <.update.>, <{uWhen}>,;
     <.lCenter.>, <.lRight.>,;
     [\{|nKey, nFlags, Self| <uChange>\}], <.readonly.>,;
     <.pass.>, [<.lNoBorder.>], <nHelpId> )

/*----------------------------------------------------------------------------//
!short: LISTBOX - BROWSE */
// Warning: SELECT <cField>  ==> Must be the Field key of the current INDEX !!!

#xcommand REDEFINE LISTBOX [ <oLbx> ] FIELDS [<Flds,...>] ;
				 [ ALIAS <cAlias> ] ;
				 [ ID <nId> ] ;
				 [ <dlg:OF,DIALOG> <oDlg> ] ;
				 [ <sizes:FIELDSIZES, SIZES, COLSIZES> <aColSizes,...> ] ;
				 [ <head:HEAD,HEADER,HEADERS,TITLE> <aHeaders,...> ] ;
				 [ SELECT <cField> FOR <uValue1> [ TO <uValue2> ] ] ;
				 [ ON CHANGE <uChange> ] ;
				 [ ON [ LEFT ] CLICK <uLClick> ] ;
				 [ ON [ LEFT ] DBLCLICK <uLDblClick> ] ;
				 [ ON RIGHT CLICK <uRClick> ] ;
				 [ FONT <oFont> ] ;
				 [ CURSOR <oCursor> ] ;
				 [ <color: COLOR, COLORS> <nClrFore> [,<nClrBack>] ] ;
				 [ MESSAGE <cMsg> ] ;
				 [ <update: UPDATE> ] ;
				 [ WHEN <uWhen> ] ;
				 [ VALID <uValid> ] ;
				 [ ACTION <uAction,...> ] ;
		 => ;
				  [ <oLbx> := ] TWBrowse():ReDefine( <nId>, ;
				  [\{|| \{ <Flds> \} \}], <oDlg>,;
				  [ \{<aHeaders>\}], [\{<aColSizes>\}],;
				  <(cField)>, <uValue1>, <uValue2>,;
				  [<{uChange}>],;
				  [\{|nRow,nCol,nFlags|<uLDblClick>\}],;
				  [\{|nRow,nCol,nFlags|<uRClick>\}],;
				  <oFont>, <oCursor>, <nClrFore>, <nClrBack>, <cMsg>, <.update.>,;
				  <cAlias>, <{uWhen}>, <{uValid}>,;
				  [\{|nRow,nCol,nFlags|<uLClick>\}], [\{<{uAction}>\}] )

#xcommand @ <nRow>, <nCol> LISTBOX [ <oBrw> ] FIELDS [<Flds,...>] ;
					[ ALIAS <cAlias> ] ;
					[ <sizes:FIELDSIZES, SIZES, COLSIZES> <aColSizes,...> ] ;
					[ <head:HEAD,HEADER,HEADERS,TITLE> <aHeaders,...> ] ;
					[ SIZE <nWidth>, <nHeigth> ] ;
					[ <dlg:OF,DIALOG> <oDlg> ] ;
					[ SELECT <cField> FOR <uValue1> [ TO <uValue2> ] ] ;
					[ ON CHANGE <uChange> ] ;
					[ ON [ LEFT ] CLICK <uLClick> ] ;
					[ ON [ LEFT ] DBLCLICK <uLDblClick> ] ;
					[ ON RIGHT CLICK <uRClick> ] ;
					[ FONT <oFont> ] ;
					[ CURSOR <oCursor> ] ;
					[ <color: COLOR, COLORS> <nClrFore> [,<nClrBack>] ] ;
					[ MESSAGE <cMsg> ] ;
					[ <update: UPDATE> ] ;
					[ <pixel: PIXEL> ] ;
					[ WHEN <uWhen> ] ;
					[ <design: DESIGN> ] ;
					[ VALID <uValid> ] ;
					[ ACTION <uAction,...> ] ;
		=> ;
			 [ <oBrw> := ] TWBrowse():New( <nRow>, <nCol>, <nWidth>, <nHeigth>,;
									[\{|| \{<Flds> \} \}], ;
									[\{<aHeaders>\}], [\{<aColSizes>\}], ;
									<oDlg>, <(cField)>, <uValue1>, <uValue2>,;
									[<{uChange}>],;
									[\{|nRow,nCol,nFlags|<uLDblClick>\}],;
									[\{|nRow,nCol,nFlags|<uRClick>\}],;
									<oFont>, <oCursor>, <nClrFore>, <nClrBack>, <cMsg>,;
									<.update.>, <cAlias>, <.pixel.>, <{uWhen}>,;
									<.design.>, <{uValid}>, <{uLClick}>,;
									[\{<{uAction}>\}] )
