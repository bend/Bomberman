functor
import
   Utils at './utils.ozf'
   Grid at './grid.ozf'
   Man at './man.ozf'
   Browser 
define
% X Y Food Walls
GameGrid={Grid.newGridPort 5 5 5 5}
for I in 1..2 do
   Man1 Man2 in 
   Man1 = {Man.newMan GameGrid 1 1 I a}
   Man2 = {Man.newMan GameGrid 1 5 I b}
end
end
