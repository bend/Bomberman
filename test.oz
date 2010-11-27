declare [Test] = {Module.link ['/Users/benoitdaccache/Documents/Programation/OZ/Bomberman/grid.ozf']}
local X in
    X={Test.newGrid 10 10}
   {Array.put {Array.get X 1} 1 block( state:1 ports:[1 3 4])}
   {Browse {Test.getItemAt X 1 1}}

   {Array.put {Array.get X 1} 1 block( state:2 ports:[1 2 3 4])}

   {Browse {Test.getItemAt X 1 1}}
end

