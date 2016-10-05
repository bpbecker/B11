function ejTabShow(sel,i)
{
	var obj=$(sel).data("ejTab");
   var h=obj.option("hiddenItemIndex");
   console.log("h");
   console.log(h);
   var j=h.indexOf(i);
   if (j>-1) {
       h.splice(j,1);
    /*   console.log("new value of h");
       console.log(h);   */
       obj.option("hiddenItemIndex",h);
       obj.showItem(i);
   }
}