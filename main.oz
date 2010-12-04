declare
[Grid] = {Module.link ['./grid.ozf']}
[Man] = {Module.link ['./man.ozf']}


GameGrid={Grid.newGridPort 10 10}
Man1 = {Man.newMan GameGrid 1 5 5 a}
Man2 = {Man.newMan GameGrid 1 5 6 b}