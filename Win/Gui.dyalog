:Namespace Gui
    (⎕IO ⎕ML ⎕WX)←1 1 3

    ∇ r←Init
      r←#.App.Init('/\'#.utils.cutLast ⎕WSID),'../App/Data/'
    ∇

    ∇ Run;frm
      {}Init
      '.'⎕WS'Coord' 'Pixel'
      frm←⎕NEW,⊂'Form'
      frm.(tabs←⎕NEW,⊂'TabControl')
      tab1←frm.tabs.⎕NEW'TabButton'(,⊂'Caption' '    Portfolios    ')
      tab2←frm.tabs.⎕NEW'TabButton'(,⊂'Caption' '    Scenarios     ')
      tab3←frm.tabs.⎕NEW'TabButton'(,⊂'Caption' '    Settings      ')
      sub1←frm.tabs.⎕NEW'SubForm'(,⊂'TabObj'tab1)
      addPortBtn←sub1.⎕NEW'Button' (('Caption' 'New')('Size' (20 40))('Posn' (10 10)))

      sub2←frm.tabs.⎕NEW'SubForm'(,⊂'TabObj'tab2)

      sub3←frm.tabs.⎕NEW'SubForm'(,⊂'TabObj'tab3)
          
    ∇

:EndNamespace
