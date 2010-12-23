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
   NBWALLS  = 10
   FOOD     = 10
   Args = {Application.getArgs
	   record(
	      nbwalls(single char:&n type:int default:NBWALLS)
	      food(single char:&f type:int default:FOOD)
	      height(single char:&h type:int default:HEIGHT)
	      width(single char:&w type:int default:WIDTH)
	      )}
% X Y Food Walls

GameGrid={Grid.newGridPort Args.width Args.height Args.food Args.nbwalls}
{Man.initMen Args.width Args.height GameGrid}
end
