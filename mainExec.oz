functor
import
   Utils at './utils.ozf'
   Grid at './grid.ozf'
   Man at './man.ozf'
   Browser 
define
% X Y Food Walls
X=10
Y=10
GameGrid={Grid.newGridPort X Y 30 15}
{Man.initMen X Y GameGrid}
end
