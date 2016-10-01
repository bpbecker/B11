:Namespace Test
    (⎕IO ⎕ML ⎕WX)←1 1 3

    :section Unit_Tests

    TestIf←{(30↑⍺),' - ',(1+⍵)⊃'Failed' 'Passed'}

    :section Client Tests

    ∇ r←GenerateClient name;salt;pwd
    ⍝ returns user name, userid, email, password, salt for hashing password, hashed password
      salt←#.utils.salt 32
      pwd←name,'password'
      r←name(name,'userid')(name,'@',name,'co.com')pwd salt(#.Strings.StringToHex #.utils.hash salt,pwd)
    ∇

    ∇ ClientTests;hpwd;salt;pwd;email;uid;name
      (name uid email pwd salt hpwd)←GenerateClient'bob'
      'empty userid'TestIf (1 'empty userid')≡2↑AddClient(name email''hpwd salt)
      'empty email'TestIf (2 'empty email')≡2↑AddClient(name''uid hpwd salt)
      'empty name'TestIf (3 'empty name')≡2↑AddClient(''email uid hpwd salt)
      'add new client'TestIf 0=AddClient(name email uid hpwd salt)
    ∇

    :EndSection

    :Section Portfolio Tests

    ∇ port←RandomPortfolio;cdir;n;inds;r;qty;dates;prices
      ⍝ generate a random portfolio
      :Access public shared
      cdir←3⊃#.App.GetCommodities
      n←⍬⍴⍴cdir
      inds←(r←?n)?n
      qty←100×?r⍴20
      dates←#.utils.IDNToDate(⌊#.utils.DateToIDN ⎕TS)-?(⍴inds)⍴365
      prices←2 #.utils.round{⍵×1+¯0.2+0.4×?(⍴,⍵)⍴0}cdir[inds;3] ⍝ random price +/- 20% "current"
      port←(cdir[inds;1],prices,[1.1]qty)[;1 3 2],dates
    ∇

    :endsection

    :section Scenario Tests
    :endsection



    :endsection

:EndNamespace
