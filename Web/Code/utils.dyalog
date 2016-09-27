:Namespace utils
    (⎕IO ⎕ML ⎕WX)←1 1 3
    lc←('.*' ⎕R '\l0')        ⍝ lower case
    cis←{⍺←⊢⋄(lc ⍺)⍺⍺(lc ⍵)}  ⍝ case insensitive
    iotaz←{⍺{⍵×⍵≤⍴⍺}⍺⍳⍵}      ⍝ ⍳ but return 0 for item not found
    cutLast←{⍵↓⍨-⊥⍨~⍵∊⍺}      ⍝ cut last partition based on ⍺
    fmtDate←{(2 0⍕⍵[3]),'-','JanFebMarAprMayJunJulAugSepOctNovDec'[(3×⍵[2])-2 1 0],'-',(4 0⍕⍵[1])}
    fmtTime←{¯1↓,'3(ZI2,<:>)'⎕FMT 1 3⍴⍵}
    fmtTs←{(fmtDate 3↑⍵),' ',fmtTime 3↑3↓⍵}
    fmtCurrency←{,'P<$>CF12.2' ⎕FMT ⍵}
    hash←{#.Crypt.(HASH_SHA256 Hash ⍵)}
    salt←{#.Strings.stringToHex #.Crypt.Random ⍵}
    DateToIDN←{(2 ⎕NQ'.' 'DateToIDN'(3↑⍵))+(24 60 60 1000⊥4↑3↓⍵)÷86400000}
    IDNToDate←{(3↑2 ⎕NQ'.' 'IDNToDate'(⌊⍵)),⌊0.5+24 60 60 1000⊤86400000×1|⍵}
    genKey←{(⎕D,6↑⎕A)[?⍵⍴16]}
:EndNamespace
