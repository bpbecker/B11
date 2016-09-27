:Namespace Gui
    (⎕IO ⎕ML ⎕WX)←1 1 3
 
    ∇ r←Init
    r←#.App.Init ('/\'#.utils.cutLast ⎕WSID),'../App/Data/'
    ∇

:EndNamespace
