declare
[Grid] = {Module.link ['./grid.ozf']}
[Man] = {Module.link ['./man.ozf']}
X Y 
% X Y Food Walls
X=4
Y=4
GameGrid={Grid.newGridPort X Y 2 3}
for I in 1..X do
   Man1 Man2 in 
   Man1 = {Man.newMan GameGrid 1 1 I a}
   Man2 = {Man.newMan GameGrid 1 Y I b}
end
