:class B11_Session
    :field public sessionId←''
    :field public APIConnection
    :field public APIProcess  ⍝ when running inSitu this is the API-Instance used in this session. When API is
                              ⍝ executed in sep. process, it is a ref to the APLProcess that is used to run the API.
    :field public Trapping←0   ⍝ enable error-trapping (1=catch errors (still rudimentary), 0=stop on errors)
    :field private APIToken
    :field private UID   ⍝ a numeric userid (possibly index into user-table)
    :field private tUID  ⍝ UserId in text-format (might be the "real" Userid or name, just something for the UI)

    ∇ MakeNewSession arg;runtime;parms;wsid;fl
      :Access public
      :Implements constructor
      ⍝ arg=(server)(port)
      ⍝ server ≡ 'inSitu' run stuff in same DWS!
      (server port)←arg
      sessionId←#.HtmlElement.GenId
     
      APIToken←'abc' ⍝  [*ToDo*]: should be an MD5 of something. Integrate & validate this in all exchange with APLProcesses!
      :If server≡'inSitu'
          APIConnection←sessionId,'.inSitu'
          :If 0=#.⎕NC'API'  ⍝ if #.API does not exist, create it and fill with ws as required
              ⎕SE.SALT.Load #.Boot.ms.Config.Application.APIHomeDir,'API',' -target=#'
              #.API.⎕CY #.Boot.ms.Config.Application.APIHomeDir,'API_Link'
            ⍝ Load configured API either from DWS or .dyalog-file (should do .dyapp, too - probably... [*Question*])
              :If '.dws'≡⎕SE.Dyalog.Utils.lcase 3⊃#.Files.SplitFilename #.Boot.ms.Config.Application.API
                  #.API.⎕CY #.Boot.ms.Config.Application.API
              :Else
                  ⎕SE.SALT.Load #.Boot.ms.Config.Application.API,' -target=#.API'
              :EndIf
            ⍝ Load utilities etc. from {APIDirectory}\AutoLoad\*.dyalog
              :For fl :In 'f'⎕SE.SALTUtils.Dir #.Boot.ms.Config.Application.APIHomeDir,'AutoLoad/*.dyalog'
                  ⎕SE.SALT.Load #.Boot.ms.Config.Application.APIHomeDir,'AutoLoad/',fl,' -target=#'
              :EndFor
          :EndIf
          ('#.API.',sessionId)⎕NS''
          :With #.API⍎sessionId
              iAPI←⎕NEW #.API⍎#.Boot.ms.Config.Application.APIClassName  ⍝ create a new instance
              inSitu←1
          :EndWith
      :Else
      ⍝[*ToDo* rewrite, so that API is initialised in CallAPI (when it is actually used - and found not be there)]
      ⍝ Otherwise every random request to the site will automatically create a new Process (and thus consume resources...)
          :If 0=#.⎕NC'API'  ⍝ if #.API does not exist, create it and fill with ws as required
              '#.API'⎕NS''
          :EndIf
          wsid←#.Boot.ms.Config.Application.APIHomeDir,'api_link'
          runtime←#.Boot.ms.Config.Debug≠2  ⍝ when Debugging is enabled, use interpreter, RT otherwise
          parms←'-slave=yes -Port=',⍕port
          parms,←#.HtmlUtils.enlist(' -API=' ' -APIPath=' ' -APIClassName=' ' -APIHomeDir=',¨#.Boot.ms.Config.Application.(API APIPath APIClassName APIHomeDir))
          parms,←' -autoshut=0 -Trapping=',(⍕Trapping),' -sessionId=',sessionId
          ('#.API.',sessionId)⎕NS''
          :With #.API⍎sessionId
              APIProcess←⎕NEW #.APLProcess(wsid parms runtime)
              inSitu←0
          :EndWith
          ⎕DL 10  ⍝ allow some time for the start...
          r←0
     TryAgain:
          :If 0=1⊃r←#.DRC.Clt''server port  ⍝ Connect
              APIConnection←2⊃r
          :Else
              ⎕SE.Dyalog.Utils.display r
              ⎕←'→TryAgain   ⍝ if there is no client-connection...!'
              ..No client!...
          :EndIf
      :EndIf
      ('#.API.',sessionId)⎕NS'APIToken'
      #.API.Trapping←Trapping
     
      CallAPI('Init'#.Boot.ms.Config.Application.APIDataDir)
    ∇



    ∇ {R}←CallAPI arg;exec;r;sess
      :Access public
          ⍝ arg=
          ⍝   [1] Name of fn
          ⍝   [2] right argument
          ⍝   [3] left argument
          ⍝ R=(RetCode)(Result from API)
          ⍝ RetCode:
          ⍝   0=No problems
          ⍝   1=Error executing API-CallAPI'arg
          ⍝   2=Error returned by API
     
     
      :Trap Trapping/0
          :If arg≡'∇CloseAPI∇'      ⍝ [*Question*] Explicit command to close API - or use class-destructor instead?
              r←0
              :If '.inSitu'≡¯7↑APIConnection
                  #.API.⎕EX'sessionId'
                  R←0
              :Else
                  R←RPCGet APIConnection('#.API.CallAPI'(sessionId arg))
              :EndIf
          :ElseIf '.inSitu'≡¯7↑APIConnection
              sess←{(∧\~'.inSitu'⍷⍵)/⍵}sessionId
              R←#.API.CallAPI(sess arg)
          :Else
              R←RPCGet APIConnection('#.API.CallAPI'(sessionId arg))
              :If 0=⍬⍴R
                  R←4 2⊃R
              :EndIf
          :EndIf
      :Else
          R←1(⎕DM)
      :EndTrap
    ∇

    ∇ {r}←RPCGet(client cmd);c;done;wr;z
   ⍝ Send a command to an RPC server (on an existing connection) and wait for the answer.
     
      res←#.DRC.Send client cmd
      :If 2≠⍴res
          ⎕TRAP←0 'S'
      :EndIf
      :If 0=1⊃(r c)←res
          :Repeat
              :If ~done←∧/100 0≠1⊃r←#.DRC.Wait c 10000 ⍝ Only wait 10 seconds
     
                  :Select 3⊃r
                  :Case 'Error'
                      done←1
                  :Case 'Progress'
  ⍝ progress report - update your GUI with 4⊃r?
                      ⎕←'Progress: ',4⊃r
                  :Case 'Receive'
                      done←1
                  :EndSelect
              :EndIf
          :Until done
      :EndIf
    ∇


:endclass
