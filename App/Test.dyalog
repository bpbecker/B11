:Namespace Test
    (⎕IO ⎕ML ⎕WX)←1 1 3

    :section Unit_Tests

    TestIf←{(30↑⍺),' - ',(1+⍵)⊃'Failed' 'Passed'}

    :section Misc

    ∇ RandomizeDatabase;clients;inds;i;pid;portfolios;sid
      :Access public shared
      ResetDatabase
      {}AddClient∘{5↑⍵}∘GenerateClient¨'bob' 'carol' 'ted' 'alice'
      clients←getClientDir[;1]
      inds←?(4+?10)⍴⍴clients
      :For i :In ⍳⍴inds
          pid←3⊃AddPortfolio(inds[i]⊃clients)('portfolio',⍕i)RandomPortfolio
      :EndFor
      portfolios←getPortfolioDir[;1]
      inds←?(5+?15)⍴⍴portfolios
      :For i :In ⍳⍴inds     
          sid←3⊃AddScenario (inds[i]⊃portfolios)('scenario',⍕i)MakeScenarioParameters
          :If ¯1+?2 ⍝ run the scenario?
              {}RunScenario sid
          :EndIf
      :EndFor
    ∇

    IPYN←{⍞←⍵ ⋄ 'Yy'∊⍨¯1↑(⍴⍵)↓⍞}

    ∇ ResetDatabase
      :Access public shared
      ⎕←'This function will wipe out all data in the database...'
      :If IPYN'Proceed? '
          :Hold 'client' 'portfolio' 'scenario'
              ⎕FHOLD clientTn,portfolioTn,scenarioTn
              putClientDir 0⌿getClientDir ⍝ wipe out directory
              0 ⎕FREPLACE clientTn,3      ⍝ reset last client number
     
              putPortfolioDir 0⌿getPortfolioDir ⍝ wipe out directory
              0 ⎕FREPLACE portfolioTn,3         ⍝ reset last portfolio number
              ⎕FDROP portfolioTn,5+-/2↑⎕FSIZE portfolioTn ⍝ drop off data components
     
              putScenarioDir 0⌿getScenarioDir ⍝ wipe out directory
              0 ⎕FREPLACE scenarioTn,3        ⍝ reset last portfolio number
              ⎕FDROP scenarioTn,5+-/2↑⎕FSIZE scenarioTn ⍝ drop off data components
     
     Done:    ⎕FHOLD ⍬
          :EndHold
      :EndIf
    ∇

    ∇ CleanupFiles;mask;comps
      ⍝ Cleanup orphaned data during testing
      :Access public shared
      :Hold 'client' 'portfolio' 'scenario'
          ⎕FHOLD clientTn,portfolioTn,scenarioTn
          :If ~∧/mask←getPortfolioDir[;2]∊getClientDir[;1] ⍝ orphaned portfolios
              putPortfolioDir mask⌿getPortfolioDir
              :If ~0∊⍴comps←(5↓⍳¯1+2⊃⎕FSIZE portfolioTn)~getPortfolioDir[;3]
                  ''∘putPortfolio¨comps
              :EndIf
          :EndIf
          :If ~∧/mask←getScenarioDir[;2]∊getPortfolioDir[;1] ⍝ orphaned scenarios
              putScenarioDir mask⌿getScenarioDir
              :If ~0∊⍴comps←(5↓⍳¯1+2⊃⎕FSIZE scenarioTn)~getScenarioDir[;3]∘.+0 1
                  ''∘putScenarioParameters¨comps
              :EndIf
          :EndIf
     Done:⎕FHOLD ⍬
      :EndHold
    ∇

    :endsection

    :section Client Tests

    ∇ r←GenerateClient args;salt;pwd;name;email;userid;password
    ⍝ returns user name, userid, email, password, salt for hashing password, hashed password
    ⍝ args - name email userid password
      salt←#.utils.salt 32
      args←eis args
      name←1⊃args
      (name email userid password)←4↑args,(⍴args)↓name(name,'@',name,'.com')name name
      r←name email userid(#.Strings.stringToHex #.utils.hash salt,password)salt password
    ∇

    ∇ ClientTests;hpwd;salt;pwd;email;uid;name;t;clientDir;n
      :Access public shared
      n←⍬⍴⍴clientDir←getClientDir
      (name email uid hpwd salt pwd)←GenerateClient'bob' 'bob@bobco.com' 'bobuid' 'bobpwd'
      'empty userid'TestIf(1 'empty userid')≡2↑AddClient(name email''hpwd salt)
      'empty email'TestIf(2 'empty email')≡2↑AddClient(name''uid hpwd salt)
      'empty name'TestIf(3 'empty name')≡2↑AddClient(''email uid hpwd salt)
      'add client "bob"'TestIf 0=⊃t←AddClient(name email uid hpwd salt)
      'duplicate uid'TestIf(1 'userid in use')≡2↑AddClient(name'other@other.com'uid hpwd salt)
      'duplicate email'TestIf(2 'email in use')≡2↑AddClient(name email'other'hpwd salt)
      'client directory check'TestIf(n+1)=⍬⍴⍴getClientDir
    ∇

    :EndSection

    :Section Portfolio Tests

    ∇ port←RandomPortfolio;cdir;n;inds;r;qty;dates;prices;t
      ⍝ generate a random portfolio
      :Access public shared
      cdir←3⊃#.App.GetCommodities
      n←⍬⍴⍴cdir
      inds←(r←?n)?n
      qty←100×?r⍴20
      dates←#.utils.IDNToDate(⌊#.utils.DateToIDN ⎕TS)-t←?(⍴inds)⍴365
      prices←2 #.utils.round{⍵×1+¯0.2+0.4×?(⍴,⍵)⍴0}cdir[inds;3] ⍝ random price +/- 20% "current"
      port←(cdir[inds;1],prices,[1.1]qty)[;1 3 2],dates
    ∇

    :endsection

    :section Scenario Tests

    ∇ params←MakeScenarioParameters;n
      :Access public shared
      n←⍬⍴⍴params←⍪#.utils.IDNToDate(⌊#.utils.DateToIDN ⎕TS)++\7×?(?10)⍴5 ⍝ up to 10 time period up to 5 weeks each
      params,←¯2+?n⍴5 ⍝ outlook
      params,←?n⍴5    ⍝ volatility
    ∇




    :endsection



    :endsection

:EndNamespace
