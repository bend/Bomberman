declare
[Grid] = {Module.link ['./grid.ozf']}
[Man] = {Module.link ['./man.ozf']}
X Y 
% X Y Food Walls
X=6
Y=8
GameGrid={Grid.newGridPort X Y 2 4}
{Man.initMen X Y GameGrid}
