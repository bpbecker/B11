:Namespace Gui
    (⎕IO ⎕ML ⎕WX)←1 1 3

    ∇ r←Init
      r←#.App.Init('/\'#.utils.cutLast ⎕WSID),'../App/Data/'
      ClientID←¯1
      ClientName←''
      Commodities←3⊃#.App.GetCommodities
    ∇

    ∇ Run
      {}Init
      BuildGUI
      ManagePortfolios
    ∇

    ∇ BuildGUI;width
     Start:
      '.'⎕WS'Coord' 'Pixel'
      'Bold'⎕WC'Font'('Pname' 'Arial')('Size' 14)('Weight' 700)
      'frm'⎕WC'Form'('Caption' 'Portfolio Projection Project')('Size'(600 1200))
     
 ⍝ Login dialog
      'frm.login'⎕WC'Subform'('Size'(150 300))('Posn'(225 450))('Border' 1)('EdgeStyle' 'Plinth')
      'frm.login.lblWelcome'⎕WC'Label'('Size'(18 250))('Posn'(20 25))('Justify' 'Center')('Caption' 'Welcome to the Portfolio Projection Project')('FontObj' 'Bold')
      'frm.login.lblUser'⎕WC'Label'('Size'(18 60))('Posn'(50 60))('Caption' 'Userid: ')('Justify' 'Right')
      'frm.login.lblPwd'⎕WC'Label'('Size'(18 60))('Posn'(80 60))('Caption' 'Password: ')('Justify' 'Right')
      'frm.login.editUser'⎕WC'Edit'('Size'(18 150))('Posn'(50 120))
      'frm.login.editPwd'⎕WC'Edit'('Size'(18 150))('Posn'(80 120))('Password' '*')
      'frm.login.btnLogin'⎕WC'Button'('Caption' 'Login')('Size'(20 60))('Posn'(115 120))('Event' 'Select' 'doLogin')
     
 ⍝ Tabs creation
      'frm.tabs'⎕WC'TabControl'('Visible' 0)
      'frm.tabs.portBtn'⎕WC'TabButton'('Caption' '    Portfolios    ')
      'frm.tabs.scenBtn'⎕WC'TabButton'('Caption' '    Scenarios     ')
      'frm.tabs.setBtn'⎕WC'TabButton'('Caption' '    Settings      ')
     
 ⍝ Portfolios Tab
      'frm.tabs.portTab'⎕WC'SubForm'('TabObj' 'frm.tabc.portbtn')
     
 ⍝ Portfolios Summary Grid
      'frm.tabs.portTab.lblPort'⎕WC'Label'('Caption' 'Your portfolios')('FontObj' 'Bold')('Posn'(15 10))('Size'(18 200))
      'frm.tabs.portTab.portGrid'⎕WC'Grid'('Posn'(50 10))('HScroll' 0)('VScroll' ¯1)('Event' 'CellDblClick' 'checkClickPortfolio')('Event' 'CellChanged' 'updatePortfolio')('Event' 'CellUp' 'checkDeletePortfolio')
      'frm.tabs.portTab.portGrid.editPortName'⎕WC'Edit'
      'frm.tabs.portTab.portGrid.lblDelete'⎕WC'Label'('Justify' 'center')
      frm.tabs.portTab.portGrid.TitleWidth←0
      frm.tabs.portTab.portGrid.ColTitles←'Portfolio' 'Created' 'Last Update' '# Commodities' '# Scenarios' 'Delete'
      frm.tabs.portTab.portGrid.Size[2]←width←2++/frm.tabs.portTab.portGrid.CellWidths←120 120 120 80 80 50
      frm.tabs.portTab.portGrid.Input←'' 'frm.tabs.portTab.portGrid.editPortName' 'frm.tabs.portTab.portGrid.lblDelete'
      frm.tabs.portTab.portGrid.FCol←(0 0 0)(0 0 0)(255 0 0)
      'frm.tabs.portTab.btnAddPort'⎕WC'Button'('Caption' 'Add new portfolio')('Size'(20 150))('Posn'(15,width+10-150))('Event' 'Select' 'addPortfolio')
     
 ⍝ Portfolio Details Grid
     
      'frm.tabs.portTab.lblPostDetails'⎕WC'Label'('FontObj' 'Bold')('Posn'(15 610))('Size'(18 200))('Caption' 'Contents of portfolio')('Visible' 0)
      'frm.tabs.portTab.portDetails'⎕WC'Grid'('Posn'(50 610))('HScroll' 0)('VScroll' ¯3)('Event' 'CellUp' 'checkDeleteCommodity')('Visible' 0)('Event' 'CellChanged' 'updateDetails')
      'frm.tabs.portTab.portDetails.comboCommodities'⎕WC'Combo'((3⊃#.App.GetCommodities)[;4])
      'frm.tabs.portTab.portDetails.editNum'⎕WC'Edit'('FieldType' 'Numeric')
      'frm.tabs.portTab.portDetails.editDate'⎕WC'Edit'('FieldType' 'Date')
      'frm.tabs.portTab.portDetails.lblDelete'⎕WC'Label'('Justify' 'center')
      'frm.tabs.portTab.portDetails.editCurrency'⎕WC'Edit'('FieldType' 'Currency')
      'frm.tabs.portTab.portDetails.lblCurrency'⎕WC'Label'('FieldType' 'Currency')
      frm.tabs.portTab.portDetails.TitleWidth←0
      frm.tabs.portTab.portDetails.ColTitles←'Commodity' 'Purchase Date' 'Shares' 'Purchase Price' 'Basis' 'Delete'
      frm.tabs.portTab.portDetails.Size[2]←width←20++/frm.tabs.portTab.portDetails.CellWidths←150 90 80 80 80 50
      frm.tabs.portTab.portDetails.Input←(⊂''),'frm.tabs.portTab.portDetails.'∘,¨'comboCommodities' 'editNum' 'editDate' 'lblDelete' 'editCurrency' 'lblCurrency'
      frm.tabs.portTab.portDetails.FCol←4 1/(0 0 0)(255 0 0)
      'frm.tabs.portTab.btnAddCommodity'⎕WC'Button'('Caption' 'Add commodity')('Size'(20 150))('Posn'(15,width+610-150))('Event' 'Select' 'addCommodity')('Visible' 0)
     
     
      →0
     
     
     
      sub2←frm.tabs.⎕NEW'SubForm'(,⊂'TabObj'tab2)
     
      sub3←frm.tabs.⎕NEW'SubForm'(,⊂'TabObj'tab3)
     
    ∇

    ∇ {r}←{type}MsgBox args;msg;caption;btns;tmp
      type←{6::⍵ ⋄ type}'Msg'
      args←#.utils.eis args
      (msg caption btns)←3↑args,(⍴args)↓'' '' ''
      'tmp'⎕WC'MsgBox'('Text'msg)('Style'type)('Caption'caption)('Event'(61 62 63)1)
      :If ~0∊⍴btns ⋄ tmp.Btns←btns ⋄ :EndIf
      :If 2=⍴⍴btns←tmp.Btns ⋄ btns←{⍵↓⍨-⊥⍨⍵=' '}¨↓btns ⋄ :EndIf
      r←(¯60+2⊃⎕DQ'tmp')⊃btns
    ∇

    ∇ ManagePortfolios
      frm.(login tabs).Visible←1 0
      ⎕DQ'frm'
    ∇

    ∇ LoadPortfolios
      :If ~0∊⍴Portfolios←3⊃#.App.ClientSummary ClientID
          frm.tabs.portTab.portGrid.Values←Portfolios[;1],(#.utils.fmtTs¨Portfolios[;4 5]),Portfolios[;2 3],(⎕UCS 10007)
      :Else
          frm.tabs.portTab.portGrid.Values←0 6⍴'' '' '' 0 0 ''
      :EndIf
      frm.tabs.portTab.portGrid.(CellTypes←(⍴Values)⍴2 1 1 1 1 3)
    ∇

    ∇ checkClickPortfolio msg;row;col
      (row col)←msg[7 8]
      showPortfolio Portfolios[row;6]
    ∇

    ∇ r←checkDeletePortfolio msg;row;col
      (row col)←msg[7 8]
      :If ¯1≠row   ⍝ didn't click the column header?
      :AndIf 6=col ⍝ clicked the Delete column?
      :AndIf 'OK'≡'Warn'MsgBox'Delete portfolio "',(⊃Portfolios[row;1]),'"?'
          {}#.App.DeletePortfolio Portfolios[row;6]
          LoadPortfolios
          ClearPortfolioDetails
      :EndIf
    ∇

    ∇ updatePortfolio msg;col;row;name;pid
      (row col name)←msg[3 4 5]
      {}#.App.UpdatePortfolio(pid←Portfolios[row;6])name
      LoadPortfolios
      showPortfolio pid
    ∇

    ∇ addPortfolio
      {}#.App.AddPortfolio ClientID'New Portfolio'(3⊃#.App.PortfolioPrototype)
      LoadPortfolios
      ClearPortfolioDetails
    ∇

    ∇ addCommodity;cfrm
      Details⍪⍨←(⊃Commodities[1;1])0 0 ⎕TS
      UpdatePortfolio
    ∇

    ∇ r←checkDeleteCommodity msg;row;col;pid
      (row col)←msg[7 8]
      :If ¯1≠row   ⍝ didn't click the column header?
      :AndIf 6=col ⍝ clicked the Delete column?
      :AndIf 'OK'≡'Warn'MsgBox'Delete commodity "',(⊃Commodities[Commodities[;1]⍳Details[row;1];4]),'"?'
          Details←(row≠⍳⍬⍴⍴Details)⌿Details
          UpdatePortfolio
      :EndIf
    ∇

    ∇ UpdatePortfolio;pid
      {}#.App.UpdatePortfolio(pid←1⊃Portfolio)(4⊃Portfolio)Details
      LoadPortfolios
      showPortfolio pid
    ∇

    ∇ updateDetails msg;row;col;value
      (row col value)←msg[3 4 5]
      :Select col
      :Case 1 ⍝ commodity
          Details[row;1]←⊂{{⍵/⍨∧\⍵≠')'}⍵/⍨⌽~∨\'('=⌽⍵}value
      :Case 2
          Details[row;4]←⊂#.utils.IDNToDate value
      :CaseList 3 4
          Details[row;col-1]←value
      :EndSelect
      {}#.App.UpdatePortfolio(pid←1⊃Portfolio)(4⊃Portfolio)Details
      LoadPortfolios
      showPortfolio pid
    ∇

    ∇ ClearPortfolioDetails
      PortfolioDetails←0 6⍴'' 0 0 0 0 ''
      frm.tabs.portTab.portDetails.Values←PortfolioDetails
      frm.tabs.portTab.portDetails.(CellTypes←(⍴Values)⍴2 4 3 6 7 5)
      frm.tabs.portTab.lblPostDetails.Caption←'No portfolio selected'
      frm.tabs.portTab.lblPostDetails.Visible←0
      frm.tabs.portTab.portDetails.Visible←0
      frm.tabs.portTab.btnAddCommodity.Visible←0
    ∇

    ∇ showPortfolio pid
      (Portfolio Details)←3⊃#.App.GetPortfolio pid
      :If ~0∊⍴Details
          PortfolioDetails←Commodities[Commodities[;1]⍳Details[;1];4],(⌊#.utils.DateToIDN¨Details[;4]),({⍵,×/⍵}Details[;2 3]),⎕UCS 10007
      :Else
          PortfolioDetails←0 6⍴'' 0 0 0 0 ''
      :EndIf
      frm.tabs.portTab.portDetails.Values←PortfolioDetails
      frm.tabs.portTab.portDetails.(CellTypes←(⍴Values)⍴2 4 3 6 7 5)
      frm.tabs.portTab.lblPostDetails.Caption←'Contents of portfolio "',(4⊃Portfolio),'"'
      frm.tabs.portTab.lblPostDetails.Visible←1
      frm.tabs.portTab.portDetails.Visible←1
      frm.tabs.portTab.btnAddCommodity.Visible←1
    ∇

    ∇ doLogin;user;pwd;pwdsalt;tmpsalt;hashpwd;tmphash;msg;rc;cust
      :If 0∊⍴user←frm.login.editUser.Value
          'Warn'MsgBox'Please enter your userid'
      :ElseIf 0∊⍴pwd←frm.login.editPwd.Value
          'Warn'MsgBox'Please enter your password'
      :Else
          (pwdsalt tmpsalt)←3⊃#.App.Login1 user
          hashpwd←#.Strings.stringToHex #.utils.hash pwdsalt,pwd
          tmphash←#.Strings.stringToHex #.utils.hash tmpsalt,hashpwd
          (rc msg cust)←#.App.Login2 user tmphash tmpsalt
          :If 0≠rc
              'Warn'MsgBox'Invalid credentials'
          :Else
              (ClientID ClientName)←cust
              frm.(login tabs).Visible←0 1
              LoadPortfolios
          :EndIf
      :EndIf
    ∇

:EndNamespace
