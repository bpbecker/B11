function ejTabShow(sel,i)
{// ejTabShow("#maintabs",1); // should be useable to make Scenario-Tab visible - but it does not do that...
	// however, the following will do:
	// $("#maintabs").data("ejTab").option("hiddenItemIndex",[2]);
  var obj=$(sel).data("ejTab");
  var h=obj.option("hiddenItemIndex");
  console.log("h");
  console.log(h);
  var j=h.indexOf(i);
  if (j>-1) {
    h.splice(j,1);
    obj.option("hiddenItemIndex",h);
    obj.showItem(i);
  }
}