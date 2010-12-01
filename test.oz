declare
fun {NewGrid X Y}
      T in
      T = {MakeTuple grid X}
      for I in 1..X  do
	 for J in 1..Y do
	    T.I = {MakeTuple grid Y}
	    T.I.J = block(type:_ bombs:_ foods:_ ports:_)
	 end
      end
      T
   end


 fun {GetItemAt Grid Pos}
    X Y in X= Pos.x
    Y =Pos.y
    Grid.X.Y
 end

   fun {UpdateItemAt Grid Pos Updates}
      {SetItemAt Grid Pos {AdjoinList {GetItemAt Grid Pos} Updates }}
   end
 
   fun {SetItemAt T Pos NewItem}
      {Browse {Width T}}
      {Browse {Width T.1}}
      Temp in Temp = {NewGrid {Width T} {Width T.1}}
      for I in 1..{Width T} do
	 for J in 1..{Width T.1} do
	    if Pos.x==I andthen Pos.y==J then
	       Temp.I.J = NewItem
	    else
	       Temp.I.J = T.I.J
	    end
	 end
      end
      Temp
end

local T T2 in
   T = {NewGrid 10 10}
   {Browse T}
  % T.1.2 = salut(1 2 3)
   %{Browse T}
   T2 = {UpdateItemAt T pos(x:1 y:2) [bombs#1]}
   T3 = {UpdateItemAt T pos(x:1 y:2) [bombs#2]}

   {Browse T2}
   {Browse T3}
end










