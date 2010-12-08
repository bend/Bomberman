functor
import
   Utils at './utils.ozf'
   Grid at './grid.ozf'
   Man at './man.ozf'
   Browser 
define
% X Y Food Walls
X=5
Y=5
GameGrid={Grid.newGridPort X Y 5 5}
{Man.initMen X Y GameGrid}
end
