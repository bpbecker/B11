:Class App
    (⎕IO ⎕ML ⎕WX)←1 1 3

⍝∇:require =/utils.dyalog
⍝∇:require =/Crypt.dyalog
⍝∇:require =/Strings.dyalog


⍝ Note: Holding is being done both with ⎕FHOLD and :Hold
⍝       so that things are properly synchronized no matter if
⍝       the application run in multiple threads in the workspace (:Hold)
⍝       or across multiple APL processes (⎕FHOLD)


    ∇ (rc msg data)←Init dir
      :Access public shared
      ⍝ dir is the folder containing the "database", '' → defaults to same folder as workspace
      :If 0∊⍴dir ⋄ dir←'/\'#.utils.cutLast ⎕WSID ⋄ :EndIf
      ⎕FUNTIE ⎕FNUMS
      clientTn portfolioTn commodityTn scenarioTn←dir∘{(⍺,⍵)⎕FSTIE 0}¨'clients' 'portfolios' 'commodities' 'scenarios'
      rc←0
      data←''
      msg←'Initialized from folder ',dir
    ∇

    ∇ r←Documentation
      :Access public shared
      {}Init''
      {}⎕SE.UCMD'box on'
      r←(↓⎕FNAMES)⍪⍉⍪⎕FREAD¨⎕FNUMS,¨1
    ∇

    ∇ (rc msg data)←GetCommodities
      :Access public shared
      (rc msg)←0 ''
      data←getCommodityDir
    ∇

    ∇ (rc msg pid)←AddPortfolio(cid pname port);dir;ptr
      :Access public shared
      (rc msg)←0 ''
      :Hold 'client' 'portfolio'
          ⎕FHOLD clientTn,portfolioTn
          :If ~cid∊getClientDir[;1]
              (rc msg)←8 'client id not found' ⋄ →Done
          :EndIf
          dir←getPortfolioDir
          pid←nextPortfolioId
          ptr←nextPortfolioSlot dir
          putPortfolioDir dir⍪pid cid ptr pname 0 ⎕TS ⎕TS
          port putPortfolio ptr
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ (rc msg sid)←AddScenario(pid sname params);sdir;sptr
      :Access public shared
      (rc msg)←0 ''
      :Hold 'portfolio' 'scenario'
          ⎕FHOLD portfolioTn,scenarioTn
          sdir←getScenarioDir
          sid←nextScenarioId
          sptr←nextScenarioSlot sdir
          params putScenarioParameters sptr
          putScenarioDir sdir⍪sid pid sptr sname ⎕TS
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ (rc msg data)←DeleteClient cid;pdir;mask;portfolios;p;sdir;s;cdir;cmask
      :Access public shared
      (rc msg data)←0 ''cid
      :Hold 'client' 'portfolio' 'scenario'
          ⎕FHOLD clientTn,portfolioTn,scenarioTn
     
          cdir←getClientDir
          :If ∨/cmask←cid=cdir[;1]
              DeletePortfolioScenarios DeleteClientPortfolios clientId
              putClientDir cdir⌿⍨~cmask
          :Else
              (rc msg)←¯1 'client not found'
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ {r}←DeleteClientPortfolios cid;pdir;mask;portfolios;p;putPortfolioDir
    ⍝ note - file holds are done in calling environment
      pdir←getPortfolioDir
      :If ∨/mask←cid=pdir[;2]
          portfolios←mask⌿pdir
          :For p :In portfolios[;3]
              ⍬ putPortfolio p
          :EndFor
          putPortfolioDir pdir⌿⍨~mask
      :EndIf
      r←mask/pdir[;1] ⍝ return deleted portfolio ids
    ∇


    ∇ (rc msg data)←DeletePortfolio pid;dir;mask
      :Access public shared
      (rc msg data)←0 ''pid
      :Hold 'portfolio' 'scenario'
          ⎕FHOLD portfolioTn,scenarioTn
          dir←getPortfolioDir
          :If ∨/mask←dir[;1]=pid
              DeletePortfolioScenarios pid
              ⍬ putPortfolio mask/dir[;3]
              putPortfolioDir dir⌿~mask
          :Else
              (rc msg)←¯2 'portfolio not found'
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ DeletePorfolioScenarios pids;sdir;mask;s
    ⍝ ⎕FHOLD is done in calling environment
      sdir←getScenarioDir
      :If ∨/mask←sdir[;2]∊pids
          :For s :In mask/sdir[;3]
              ⍬ putScenarioParameters s
              ⍬ putScenarioResults s
          :EndFor
          putScenarioDir(~mask)⌿sdir
      :EndIf
    ∇

    ∇ (rc msg data)←DeleteScenario sid;sdir;mask;ptr
      :Access public shared
      (rc msg data)←0 ''sid
      :Hold 'scenario'
          ⎕FHOLD scenarioTn
          sdir←getScenarioDir
          :If ∨/mask←sdir[;1]=sid
              :For ptr :In mask/sdir[;3]
                  ⍬ putScenarioParameters ptr
                  ⍬ putScenarioResult ptr
              :EndFor
              putScenarioDir(~mask)⌿sdir
          :Else
              (rc msg)←¯3 'scenario not found'
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ (rc msg data)←UpdateClient(cid name email uid pwd salt);dir;ind;inds
      :Access public shared
      (rc msg data)←0 ''cid
      :Hold 'client'
          ⎕FHOLD clientTn
          dir←getClientDir
          (rc msg)←1 ''
          :If 0≠ind←dir[;1]#.utils.iotaz cid
              inds←ind~⍨⍳⊃⍴dir
              :If dir[inds;4]∊⍨⊂email ⋄ (rc msg)←1 'Userid in use' ⋄ →Done ⋄ :EndIf
              :If dir[inds;3]∊⍨⊂email ⋄ (rc msg)←2 'Email in use' ⋄ →Done ⋄ :EndIf
              dir[ind;2 3 4 5 6]{0∊⍴⍵:⍺ ⋄ ⍵}←name email uid pwd salt
              putClientDir dir
          :Else
              (rc msg)←3 'client not found'
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ (rc msg pid)←UpdatePortfolio(pid pname port);dir;ind
      :Access public shared
      (rc msg)←0 ''
      :Hold 'portfolio' 'scenario'
          ⎕FHOLD portfolioTn,scenarioTn
          dir←getPortfolioDir
          :If 0≠ind←dir[;1]#.utils.iotaz pid
              DeletePortfolioScenarios pid
              port putPortfolio dir[ind;3]
              dir[ind;4]←⊂pname
              dir[ind;5]←⊃⍴port
              dir[ind;7]←⊂⎕TS
              putPortfolioDir dir
          :Else
              (rc msg)←4 'portfolio not found'
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ (rc msg sid)←UpdateScenario(sid params);dir;ind;ptr
      :Access public shared
      (rc msg)←0 ''
      :Hold 'scenario'
          ⎕FHOLD scenarioTn
          dir←getScenarioDir
          :If 0≠ind←dir[;1]#.utils.iotaz sid
              params putScenarioParameters ptr←⊃dir[ind;3]
              ⍬ port putScenarioResults ptr
              dir[ind;5]←⊂⎕TS
              putScenarioDir dir
          :Else
              (rc msg)←5 'scenario not found'
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ (rc msg data)←ClientSummary cid;pdir;sdir
         ⍝ returns [;1] portfolio name [;2] number commodities [;3] number scenarios [;4] created [;5] last update [;6] pid [;7] pdet
      :Access public shared
      (rc msg data)←0 ''(0 7⍴'' 0 0 '' '')
      :Hold 'portfolio' 'scenario'
          ⎕FHOLD portfolioTn,scenarioTn
          :If cid∊getClientDir[;1]
              pdir←cid{⍵⌿⍨⍵[;2]∊⍺}getPortfolioDir ⍝ portfolios for client
              sdir←pdir[;1]{⍵⌿⍨⍵[;2]∊⍺}getScenarioDir ⍝ scenarios for portfolios
          :Else
              (rc msg data)←3 'client not found'cid
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
      :If ~0∊⍴pdir
          data←pdir[;4 5],({¯1+≢⍵}⌸pdir[;1],sdir[;2]),#.utils.fmtTs¨pdir[;6 7]
          data,←pdir[;1 3]  ⍝ MBaas: added pid & details
      :EndIf
    ∇

    ∇ (rc msg data)←PortfolioSummary(cid pid);pdir;mask;ind;port
      :Access public shared
      :Hold 'portfolio' 'scenario'
          ⎕FHOLD portfolioTn,scenarioTn
          pdir←getPortfolioDir
          :If ∨/mask←pdir[;2]=cid
              :If ∨/mask←mask∧pdir[;1]=pid
                  ind←mask/⍳⍴mask
                  port←getPortfolio pdir[ind;3]
     
              :Else
                  (rc msg data)←4 'portfolio not found'pid
              :EndIf
          :Else
              (rc msg data)←3 'client not found'cid
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇


    ∇ (rc msg r)←RunScenario sid;today;scen;port;max;dates;days;portfolio;data
      :Access public shared
      (rc msg r)←0 '' ''
      :Hold 'portfolio' 'scenario'
          ⎕FHOLD portfolioTn,scenarioTn
          scen←GetScenario sid
          port←GetPortfolio(1⊃3⊃scen)[2]
          today←⌊#.utils.DateToIDN ⎕TS
          max←⌈/dates←#.utils.DateToIDN¨(2⊃3⊃scen)[;1]
          days←max-today
          data←↑(1↓{⍵,(¯1↑⍵)+.01×⌊.5+100×¯.5+?0}⍣days)¨(portfolio←2⊃3⊃port)[;3]
          data,⍨←portfolio[;1 3]
          data⍪⍨←(⊂'Commodity'), {3↑#.utils.IDNToDate ⍵}¨today,today+⍳days
          data putScenarioResults (1⊃3⊃scen)[3]
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    :section Authentication

⍝ This section handles user registration, login, and password reset

⍝ login for a web app takes several steps
⍝ 1 - when the userid is filled in on the browser, a callback is made to retrieve the salt (origSalt) used to hash the password at enrollment time
⍝     if the userid is not found, generate some "fake" salt
⍝     send this salt and a new random salt (newSalt) as hidden inputs (or javascript variables)
⍝ 2 - in the browser, once the password is entered, compute hash(newSalt,hash(origSalt,password)) and send that and NOT the entered password
⍝ 3 - in the server, compare what was received from the browser with hash(newSalt,storedHashedPassword)

    ∇ (rc msg data)←Login1 userid;cdir;notfound;ind
    ⍝ Login step 1 - called from a callback when the userid is filled in
    ⍝ data is [1] the salt used to hash the password [2] random salt used for this login
    ⍝ if the userid isn't found, we send fake salt generated from the userid
      :Access public shared
      cdir←getClientDir
      ind←cdir[;4]⍳⊂userid
      rc←5×notfound←ind>⊃⍴cdir
      msg←(1+notfound)⊃'' 'userid not found'
      data←(⊃(cdir[;6],⊂#.utils.hash userid)[ind])(#.utils.salt 32)
    ∇

    ∇ (rc msg data)←Login2(userid hashpass newsalt);cdir;ind;notfound
      :Access public shared
      cdir←getClientDir
      ind←cdir[;4]⍳⊂userid
      :If notfound←ind>⊃⍴cdir
          (rc msg data)←5 'userid not found' ''
      :ElseIf hashpass≢#.Strings.stringToHex #.utils.hash newsalt,⊃cdir[ind;5]
          (rc msg data)←6 'password mismatch' ''
      :Else
          (rc msg data)←0 ''(cdir[ind;1 4])  ⍝ MB: return client ID & name!
      :EndIf
    ∇

⍝ registration involves
⍝ 1 - send (and remember) random original salt (origSalt) using #.utils.salt
⍝ 2 - user fills out form, hashPass is computed as hash(origSalt,password) - send this value and NOT the actual password

    ∇ (rc msg cid)←AddClient(name email userid pwd salt);dir
      :Access public shared
     ⍝ rc= 1 userid in use, 2 email in use
      (rc msg cid)←0 '' 0
      :Hold 'client'
          ⎕FHOLD clientTn
          dir←getClientDir
          :If 0∊⍴userid ⋄ (rc msg)←1 'empty userid' ⋄ →Done ⋄ :EndIf
          :If 0∊⍴email ⋄ (rc msg)←2 'empty email' ⋄ →Done ⋄ :EndIf
          :If 0∊⍴name ⋄ (rc msg)←3 'empty name' ⋄ →Done ⋄ :EndIf
          :If ~0∊⍴dir
          :If (⊂userid)∊dir[;4] ⋄ (rc msg)←1 'userid in use' ⋄ →Done ⋄ :EndIf
          :If (⊂email)(∊#.utils.cis)dir[;3] ⋄ (rc msg)←2 'email in use' ⋄ →Done ⋄ :EndIf
          :EndIf
          cid←nextClientId
          putClientDir dir⍪cid name email userid pwd salt''⍬
     Done:⎕FHOLD ⍬
      :EndHold
    ∇


⍝ password reset involves
⍝ 1 - validate email address, generate resetKey, and url to email address
⍝ 2 - when the user enters the new password, compute hash(salt,newPassword) and send the email, hashKey, hashPass and resetKey and call ResetPassword

    ∇ (rc msg resetKey)←InitiateResetPassword email;dir;ind
      :Access public shared
      (rc msg resetKey)←0 '' ''
      :Hold 'client'
          ⎕FHOLD clientTn
          dir←getClientDir
          :If 0=ind←dir[;3](#.utils.(iotaz cis))⊂email ⋄ (rc msg)←2 'email not found' ⋄ →Done ⋄ :EndIf
          resetKey←#.utils.genKey 64
          dir[ind;7 8]←(⊂resetKey)(#.utils.DateToIDN ⎕TS)
          putClientDir dir
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    ∇ (rc msg data)←ResetPassword(email resetKey hashPass salt);dir;ind;rkey
    ⍝ validate reset request
      :Access public shared
      (rc msg data)←0 '' ''
      :Hold 'client'
          ⎕FHOLD clientTn
          dir←getClientDir
          :If 0=ind←dir[;3](#.utils.(iotaz cis))⊂email ⋄ (rc msg)←2 'email not found' ⋄ →Done ⋄ :EndIf
          :If 0∊⍴rkey←⊃dir[ind;7] ⋄ (rc msg)←6 'no reset key' ⋄ →Done ⋄ :EndIf
          :If rkey≢resetKey ⋄ (rc msg)←7 'reset key mismatch' ⋄ →Done ⋄ :EndIf
          :If (⊃dir[ind;8])≥#.utils.DateToIDN ⎕TS+0 0 0 1 0 0 0 ⋄ (rc msg)←6 'reset request expired' ⋄ →Done ⋄ :EndIf ⍝ allow reset within 1 hour
          dir[ind;5 6 7 8]←hashPass salt''⍬
          putClientDir dir
     Done:⎕FHOLD ⍬
      :EndHold
    ∇


    :endsection

    :Section File Access Utilities

    ∇ r←getClientDir
      r←⎕FREAD clientTn,2
    ∇

    ∇ r←getCommodityDir
      r←⎕FREAD commodityTn,2
    ∇

    ∇ putClientDir dir
      dir ⎕FREPLACE clientTn,2
    ∇

    ∇ r←getPortfolioDir
      r←⎕FREAD portfolioTn,2
    ∇

    ∇ putPortfolioDir dir
      dir ⎕FREPLACE portfolioTn,2
    ∇

    ∇ r←getScenarioDir
      r←⎕FREAD scenarioTn,2
    ∇

    ∇ putScenarioDir dir
      dir ⎕FREPLACE scenarioTn,2
    ∇

    ∇ p putPortfolio ptr
      p ⎕FREPLACE portfolioTn,ptr
    ∇

    ∇ p←getPortfolio ptr
      p←⎕FREAD portfolioTn,ptr
    ∇

    ∇ p←getScenarioParameters ptr
      p←⎕FREAD scenarioTn,ptr
    ∇

    ∇ r←getScenarioResults ptr
      r←⎕FREAD scenarioTn,ptr+1
    ∇

    ∇ p putScenarioParameters ptr
      p ⎕FREPLACE scenarioTn,ptr
    ∇

    ∇ r putScenarioResults ptr
      r ⎕FREPLACE scenarioTn,ptr+1
    ∇

    ∇ r←nextClientId
      (r←1+⎕FREAD clientTn,3)⎕FREPLACE clientTn,3
    ∇

    ∇ r←nextPortfolioId
      (r←1+⎕FREAD portfolioTn,3)⎕FREPLACE portfolioTn,3
    ∇

    ∇ r←nextPortfolioSlot dir;n
      r←⊃dir[;3]~⍨5↓⍳n←2⊃⎕FSIZE portfolioTn
      :If r=n ⋄ (0 5⍴'' 2 2 3.1 ⎕TS)⎕FAPPEND portfolioTn ⋄ :EndIf
    ∇

    ∇ r←nextScenarioId
      (r←1+⎕FREAD scenarioTn,3)⎕FREPLACE scenarioTn,3
    ∇

    ∇ r←nextScenarioSlot dir;n
      r←⊃dir[;3]~⍨{⍵/⍨~2|⍵}5↓⍳n←2⊃⎕FSIZE scenarioTn
      :If r=n
          (0 2⍴2)⎕FAPPEND scenarioTn
          (0 0⍴2)⎕FAPPEND scenarioTn
      :EndIf
    ∇

    ∇ (rc msg data)←GetScenario sid;dir
      :Access public shared
      (rc msg data)←0 '' ''
      :Trap 3
          dir←sid{⍵[⍵[;1]⍳⊃⍺;]}getScenarioDir
          data←dir(getScenarioParameters dir[3])(getScenarioResults dir[3])
      :Else
          (rc msg)←9 'scenario not found'
      :EndTrap
    ∇

    ∇ (rc msg data)←GetPortfolio pid;dir
      :Access public shared
      (rc msg data)←0 '' ''
      :Trap 3
          dir←pid{⍵[⍵[;1]⍳⊃⍺;]}getPortfolioDir
          data←dir(getPortfolio dir[3])
      :Else
          (rc msg)←9 'scenario not found'
      :EndTrap
    ∇


    :endsection

    :section Misc

    ∇ port←RandomPortfolio;cdir;n;inds;r;qty
      ⍝ generate a random portfolio
      :Access public shared
     
      cdir←getCommodityDir
      n←⍬⍴⍴cdir
      inds←(r←?n)?n
      qty←100×?r⍴20
      port←(cdir[inds;1 3],qty)[;1 3 2],⊂⎕TS
    ∇

    ∇ CleanupFiles;mask;comps
      ⍝ Cleanup orphaned data during testing
      :Access public shared
     
      :Hold 'client' 'portfolio' 'scenario'
          ⎕FHOLD clientTn,portfolioTn,scenarioTn
          :If ~∧/mask←getPortfolioDir[;2]∊getClientDir[;1] ⍝ orphaned portfolios
              putPortfolioDir mask⌿getPortfolioDir
              comps←(5↓⍳¯1+2⊃⎕FSIZE portfolioTn)~getPortfolioDir[;3]
              ''∘putPortfolio¨comps
          :EndIf
          :If ~∧/mask←getScenarioDir[;2]∊getPortfolioDir[;1] ⍝ orphaned scenarios
              putPortfolioDir mask⌿getPorfolioDir
              comps←(5↓⍳¯1+2⊃⎕FSIZE scenarioTn)~getScenarioDir[;3]∘.+0 1
              ''∘putScenarioParameters¨comps
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    :endsection

    :section Unit_Tests

    :endsection

:EndClass
