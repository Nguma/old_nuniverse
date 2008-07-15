// UNOBTRUSIVE MOOTOOLSCRIPT
// An answer to not being able to use UJS without prototype...
// (c) 2008 --- Nguma LLC
// Please reuse freely, and update as much as possible.
//
// V.0.0.1
// Since UJS is sadly bound to Prototype, we can't use its magic here. 
// Instead, this method will go over all elements inside the defined root
// and assign whetever you want.
// 
// Right now, im still calling it manually at every ajax update. 
// Needs some more love to bypass this step.

var funcs = [];
function ums(func)
{
  funcs.push(func);
}

function umsOps(root)
{
  if(root == undefined) root = $(document.body);
  funcs.each(function(func)
  {
    func(root);
  });
}