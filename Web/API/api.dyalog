:namespace API

    ∇ R←CallAPI arg;exec;id;⎕TRAP
      ⎕TRAP←0 'S'  ⍝ disable all trapping in outer fns...
      ⎕SE.Dyalog.Utils.disp arg
      (id arg)←arg
      exec←((3=⍴⍴arg)/'(3⊃arg)'),('iAPI.',1⊃arg),(1<⍴arg)/' 2⊃arg'
      :Trap Trapping/0
          :With id
              ⎕←R←⍎exec
          :EndWith
      :Else
          ⎕←R←1(⎕DM)
      :EndTrap
      ⎕SE.Dyalog.Utils.disp R
    ∇


    ∇ mode InitAPI(APIHomeDir API APIClassName APIType APIToken sessionId trapping);loadRes
      ⎕←'*** Initialising API NOW'
      :If mode≡'inSitu'
          #.API.⎕CY APIHomeDir,'API_Link'
            ⍝ Load configured API either from DWS or .dyalog-file (should do .dyapp, too - probably... [*Question*])
          :If '.dws'≡⎕SE.Dyalog.Utils.lcase 3⊃#.Files.SplitFilename API
              #.API.⎕CY API
              loadRes←#.API⍎APIClassName
          :Else
              loadRes←⎕SE.SALT.Load API,' -target=#.API'
          :EndIf
            ⍝ Load utilities etc. from {APIDirectory}\AutoLoad\*.dyalog
          :For fl :In 'f'⎕SE.SALTUtils.Dir APIHomeDir,'AutoLoad/*.dyalog'
              ⎕SE.SALT.Load APIHomeDir,'AutoLoad/',fl,' -target=#'
          :EndFor
     
          (ns←'#.API.',sessionId)⎕NS''
          #.API.Trapping←trapping
              :If APIType≡'Instance'            ⍝ when running API in instance-mode:
                  ⍎ns,'.iAPI←⎕NEW #.API⍎loadRes'⍝ --> create a new instance
              :ElseIf APIType≡'Class'           ⍝ for Class (with shared methods)
              :OrIf APIType≡'Namespace'         ⍝ or namespace
                  ⍎ns,'.iAPI←loadRes'           ⍝ --> a ref to the loaded "thing" will be enough :-)
              :Else
                  ('Unknow APIType: ',APIType)⎕SIGNAL 11
              :EndIf
              inSitu←1
      :Else
     
          ∘∘∘
      :EndIf
    ∇
:endnamespace
