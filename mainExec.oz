functor
import
   Application
   Utils at './utils.ozf'
   Grid at './grid.ozf'
   Man at './man.ozf'
   Browser 
define
   %Default Values
   HEIGHT   = 10
   WIDTH    = 10
   MURS    = 10
   BOUFFE    = 10
   Args = {Application.getArgs
	   record(
	      murs(single char:&m type:int default:MURS)
	      food(single char:&b type:int default:BOUFFE)
	      height(single char:&h type:int default:HEIGHT)
	      width(single char:&w type:int default:WIDTH)
	      
	      )}
% X Y Food Walls

GameGrid={Grid.newGridPort Args.width Args.height Args.murs Args.bouffe}
{Man.initMen Args.width Args.height GameGrid}
end
