:Namespace Gui
    (⎕IO ⎕ML ⎕WX)←1 1 3

    ∇ r←Init
      r←#.App.Init('/\'#.utils.cutLast ⎕WSID),'../App/Data/'
      ClientID←¯1
      ClientName←''
    ∇

    ∇ Run
      {}Init
      BuildGUI
      ManagePortfolios
    ∇

    ∇ BuildGUI
      RED←⊂255 0 0
     Start:
      '.'⎕WS'Coord' 'Pixel'
      'frm'⎕WC'Form'('Caption' 'Portfolio Projection Project')('Size'(600 1200))
     
 ⍝ Login dialog
      'frm.login'⎕WC'Subform'('Size'(150 300))('Posn'(225 450))('Border' 1)('EdgeStyle' 'Plinth')
      'frm.login.lblUser'⎕WC'Label'('Size'(18 60))('Posn'(40 60))('Caption' 'Userid: ')('Justify' 'Right')
      'frm.login.lblPwd'⎕WC'Label'('Size'(18 60))('Posn'(70 60))('Caption' 'Password: ')('Justify' 'Right')
      'frm.login.editUser'⎕WC'Edit'('Size'(18 150))('Posn'(40 120))
      'frm.login.editPwd'⎕WC'Edit'('Size'(18 150))('Posn'(70 120))('Password' '*')
      'frm.login.btnLogin'⎕WC'Button'('Caption' 'Login')('Size'(20 60))('Posn'(105 120))('Event' 'Select' 'doLogin')
     
 ⍝ Tabs creation
      'frm.tabs'⎕WC'TabControl' ⍝ ('Visible' 0)
      'frm.tabs.portBtn'⎕WC'TabButton'('Caption' '    Portfolios    ')
      'frm.tabs.scenBtn'⎕WC'TabButton'('Caption' '    Scenarios     ')
      'frm.tabs.setBtn'⎕WC'TabButton'('Caption' '    Settings      ')
     
 ⍝ Portfolios Tab
      'frm.tabs.portTab'⎕WC'SubForm'('TabObj' 'frm.tabc.portbtn')
      'frm.tabs.portTab.addPortBtn'⎕WC'Button'('Caption' 'New')('Size'(20 60))('Posn'(15 10))('Event' 'Select' 'addPortfolio')
 ⍝ Portfolios Summary Grid
      'frm.tabs.portTab.portGrid'⎕WC'Grid'⍝('HScroll' 0)('VScroll' ¯1)
      :With frm.tabs.portTab.portGrid
          TitleWidth←0
          ColTitles←'Portfolio' 'Created' 'Last Update' '# Commodities' '# Scenarios' 'Delete'
          Size[2]←+/CellWidths←120 120 120 80 80 50
          Posn←50 10
          'editPortName'⎕WC'Edit'
          'lblDelete'⎕WC'Label'('Justify' 'center')
          Input←'' 'frm.tabs.portTab.portGrid.editPortName' 'frm.tabs.portTab.portGrid.lblDelete'
      :EndWith
     
      →0
     
     
      Grid
     
      sub2←frm.tabs.⎕NEW'SubForm'(,⊂'TabObj'tab2)
     
      sub3←frm.tabs.⎕NEW'SubForm'(,⊂'TabObj'tab3)
     
    ∇

    ∇ {r}←{type}MsgBox args;msg;caption;btns;tmp
      type←{6::⍵ ⋄ type}'Msg'
      args←#.utils.eis args
      (msg caption btns)←3↑args,(⍴args)↓'' '' 'OK'
      'tmp'⎕WC'MsgBox'('Text'msg)('Style'type)('Caption'caption)('Btns'btns)
      r←⎕DQ tmp
    ∇

    ∇ ManagePortfolios
      frm.(login tabs).Visible←1 0
      ⎕DQ'frm'
    ∇

    ∇ LoadPortfolios
      Portfolios←3⊃#.App.ClientSummary ClientID
      frm.tabs.portTab.portGrid.Values←Portfolios[;1],(#.utils.fmtTs¨Portfolios[;4 5]),Portfolios[;2 3],(⎕UCS 10007)
      frm.tabs.portTab.portGrid.(CellTypes←(⍴Values)⍴2 1 1 1 1 3)
      frm.tabs.portTab.portGrid.FCol←(0 0 0)(0 0 0)(255 0 0)
    ∇

    ∇ addPortfolio
      CellTypes
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
