﻿:Class B11_Regular : MiPage
⍳
    :Field Public nl←⎕ucs 13
    :Field public RequiresLogin←1
    :field public title←'' ⍝ server.Config.Name would have been nicer, but we can't do that

    :include #.Strings
    :include #.HtmlUtils

    :field private theme←'default-theme' ⍝ 'azure'
    ⍝ themes @ http://js.syncfusion.com/demos/web/
    ⍝ stored in:
    ⍝ MiServer\PlugIns\Syncfusion-14.2.0.26\assets\css\web\



∇ z←PreFlightCheck
:access public
z←1

      :If RequiresLogin
      :AndIf ~IfInstance'login'
      :AndIf 0=2⊃⎕VFI⍕'0'SessionGet'UID'   ⍝ Session-Variable "UID" will hold a (numeric) UserId (or 0 if user if not logged in)
          _Request.Session.UID←z←0
          _Request.Redirect'/login.mipage'
      :EndIf
'PreFlightCheck=',z

∇

    ∇ {r}←Wrap;lang;server;mn
      :Access Public
      server←_Request.Server
      :If '###'≡'###'SessionGet'showMsg'
          _Request.Session.showMsg←⍬     ⍝ vector with ⊂(type)(text)    where type=0=nothing, ¯2: error, ¯1=warning, 1=info, 2=success and text is a VECTOR with the text of the msg
      :EndIf
     
      :If title≡'' ⋄ title←server.Config.Name ⋄ :EndIf  ⍝ set a default

    ⍝ useful in dev: append ?fakeit=1 to URLs to get access despite not being signed in. (Remove in production)
      :If 0<2⊃⎕VFI⍕'0'Get'fakeit'
      :AndIf server.Config.Production=0      ⍝ better safe than sorry - make sure this is disabled in production!
          _Request.Session.UID←1
      :EndIf
      ⍝ when page other than login is called: check if user is logged in,
      ⍝ otherwise redirect to index immediately (replacing all HTML of the response...)
     
      Use'⍕/Styles/reset.css'
      Use'JQuery'
      ⍝ FA, Panel & jBox required for showMsg to display stuff, potentially via callbacks. So make sure they are always there.
      Use'faIcons'
      Use'jBox'
      Use'dcPanel'
      Use'⍕/Styles/style.css'                  ⍝ add a link to our CSS stylesheet
      Use'⍕/Syncfusion/assets/css/web/',theme,'/ej.widgets.all.min.css'
      Use'⍕/Syncfusion/assets/css/web/',theme,'/ej.theme.min.css'
      Add _.link 'href="https://fonts.googleapis.com/css?family=Open+Sans+Condensed:300" rel="stylesheet"'
     
    ⍝ set the title display in the browser to the name of the application defined in Config/Server.xml
      Add _.title title ⍝ we do that on the individual MiPages!
     
    ⍝ set a meta tag to make it explicitly UTF-8
      (Add _.meta).SetAttr'http-equiv="content-type" content="text/html;charset=UTF-8"'
      (Add _.meta).SetAttr'name="viewport" content="width=device-width, initial-scale=1"'
     
      hd←New _.noscript
      hd.Add _.div'Limited functionality w/o JavaScript!' 'class="class=col-lg-10 noscript"'
      ⍝ hd,←'#title'New _.h1 (5↓server.Config.Name)
      hd,←tit←'#title'New _.h1
      ⍝ Sorry, hardcoding name here so that it can be made responsive
      '.show-md' tit.Add _.span'B11: '
      tit.Add _.span'Best British Bond Broker Business'
      '.show-md'tit.Add _.span' By'
      '.show-lg'tit.Add _.span' Bold Brian'
      '.show-md'tit.Add _.span' Becker'
      '.show-md'tit.Add _.span' &amp;'
      '.show-lg'tit.Add _.span' Brave Biene''s Busy '
      '.show-md'tit.Add _.span'Baas'
      '.show-lg'tit.Add _.span'i'
      hd,←'#logo'New _.div(('B11'New _.span '<b>B11</b>')('#slogan'New _.p 'More Bang for the Buck'))
      :While 0<⍴_Request.Session.showMsg
          :If 0>⊃1⊃_Request.Session.showMsg   ⍝ there is an errormsg (or a warning) to show!
              OnLoad,←_.jBox.Modal(New _.Panel((,2⊃t)(t[1]⊃'warn' 'error')))
          :ElseIf 0<⊃t←1⊃_Request.Session.showMsg
⍝              OnLoad,←('blue' 'green')[1⊃t]_.jBox.Notice(New _.Icon('fa-info-circle' 'fa-check')[1 2⍳1⊃t],2⊃t)
⍝25:SYNTAX ERROR
⍝New[4] r._PageRef←⎕THIS
⍝      ∧
⍝ [*Question*]: Brian, code above caused error. Variant below works. OK for u?
              OnLoad,←('blue' 'green')[1⊃t]_.jBox.Notice((#.HtmlElement.New _.Icon(t[1]⊃'fa-info-circle' 'fa-check')),2⊃t)
          :EndIf
          _Request.Session.showMsg←1↓_Request.Session.showMsg
      :EndWhile
      :If 0<2⊃⎕VFI⍕'0'SessionGet'UID'
          lgOut←'#logout' '.primBtn e-recuredit floatRight'New _.button((New _.Icon'fa-sign-out'),'Log out')
          lgOut.On'click' 'Logout'
          hd,←lgOut
      :EndIf
    ⍝ wrap the content of the <body> element in a div
      Body.Push hd
     
    ⍝ add the footer to the bottom of the page
        ⍝  Add #.Files.GetText server.Config.Root,'Styles\footer.txt'
     
    ⍝ set the language for the page
      lang←server.Config.Lang ⍝ use the language specified in Server.xml
      Set'lang="',lang,'" xml:lang="',lang,'" xmlns="http://www.w3.org/1999/xhtml"'
      Body.SetAttr'lang="',lang,'" xml:lang="',lang,'" xmlns="http://www.w3.org/1999/xhtml"'
     
    ⍝ call the base class Wrap function
      :Trap 991
          r←⎕BASE.Wrap
      :Else
          .
      :EndTrap
     end:
    ∇


    ∇ R←Logout
      :Access Public
      _Request.(Server.SessionHandler.KillSessions Session.ID)
      R←Execute('window.location="/index";')
    ∇

    ∇ R←IfInstance nam
      A1←#.Strings.uc'[',nam,']'
      A2←#.Strings.uc⍕⎕NSI
⍝      ∘∘∘
      R←∨/A1⍷A2
    ∇


    ∇ R←CatchAPIErrors R
      :Access public
⍝ simplistic mechanism to handle API-Errors and Warning:
⍝ any return-code ≠0 will ⎕SIGNAL and get out of the stack,
⍝ so the result returned in case of successfull operations
⍝ will be the 3d element of the calls result.
      :If 0=⊃R
          R←3⊃R
      :Else
          ('API-Warning/Error-Msg: ',2⊃R)⎕SIGNAL 2
      :EndIf
     
    ∇

:EndClass
