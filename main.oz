declare
[Grid] = {Module.link ['/Users/benoitdaccache/Documents/Programation/OZ/Bomberman/grid.ozf']}
[Man] = {Module.link ['/Users/benoitdaccache/Documents/Programation/OZ/Bomberman/man.ozf']}
% X Y Food Walls
GameGrid={Grid.newGridPort 10 10 5 10}
Man1 = {Man.newMan GameGrid 1 5 5 blue}
Man2 = {Man.newMan GameGrid 1 5 6 red}

