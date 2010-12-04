declare
[Grid] = {Module.link ['./grid.ozf']}
[Man] = {Module.link ['./man.ozf']}
% X Y Food Walls
GameGrid={Grid.newGridPort 10 10 20 10}
for I in 1..10 do
   {Man.newMan GameGrid 1 1 I a}
   {Man.newMan GameGrid 1 10 I b}
end

