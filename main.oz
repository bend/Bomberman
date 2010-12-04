declare
[Grid] = {Module.link ['/Users/benoitdaccache/Documents/Programation/OZ/Bomberman/grid.ozf']}
[Man] = {Module.link ['/Users/benoitdaccache/Documents/Programation/OZ/Bomberman/man.ozf']}

GameGrid={Grid.newGridPort 10 10}
Man1 = {Man.newMan GameGrid 1 5 5 a}
Man2 = {Man.newMan GameGrid 1 5 6 b}

