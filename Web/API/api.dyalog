:namespace API

    ∇ R←CallAPI arg;exec;id;⎕TRAP
      ⎕TRAP←0 'S'  ⍝ disable all trapping in outer fns...
      (id arg)←arg
      exec←((3=⍴⍴arg)/'(3⊃arg)'),('iAPI.',1⊃arg),(1<⍴arg)/' 2⊃arg'
      :Trap Trapping/0
          :With id
              ⎕←R←⍎exec
          :EndWith
      :Else
          ⎕←R←1(⎕DM)
      :EndTrap
    ∇
:endnamespace
