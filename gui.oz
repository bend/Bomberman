functor
import
   Application % Allows to terminate the application
   System 
   QTk at 'x-oz://system/wp/QTk.ozf'
   Utils at './utils.ozf'
   OS
export
  newBoard:NewBoard
define

   %% Default values
   HEIGHT   = 16
   WIDTH    = 12
   
   %% Posible arguments
   Args = {Application.getArgs
	   record(
	      height(single char:&h type:int default:HEIGHT)
	      width(single char:&w type:int default:WIDTH)
	      )}
   
   fun {NewActive Class Init}
      Obj = {New Class Init}
      P
   in
      thread S in
	 {NewPort S P}
	 for M in S do {Obj M} end
      end
	 proc {$ M} {Send P M} end
   end

   class Gui
      attr grid
	 scorea scoreb
	 playera playerb bomb food beer bg wall
      meth init(H W)
	 CD = {OS.getCWD}
	 Grid ScoreA ScoreB
      in
	 {{QTk.build td(
			grid(handle:Grid bg:white)
			lr(label(text:"Team A:") label(text:"0" handle:ScoreA)
			   label(text:"Team B:") label(text:"0" handle:ScoreB)
			   button(text:"Quit" action:proc {$} {Application.exit 0} end)
			  )
			)} show}
	 for I in 1..H-1 do
	    {Grid configure(lrline column:1 columnspan:W+W-1 row:I*2 sticky:we)}
	 end
	 for I in 1..W-1 do
	    {Grid configure(tdline  row:1 rowspan:H+H-1 column:I*2 sticky:ns)}
	 end
	 for I in 1..W do
	    {Grid columnconfigure(I+I-1 minsize:43)}
	 end
	 for I in 1..H do
	    {Grid rowconfigure(I+I-1 minsize:43)}
	 end
	 grid := Grid
	 scorea := ScoreA
	 scoreb := ScoreB
	 playera :=  {QTk.newImage photo(file:CD#'/playerA.gif')}
	 playerb := {QTk.newImage photo(file:CD#'/playerB.gif')}
	 food := {QTk.newImage photo(file:CD#'/food.gif')}
	 beer:= {QTk.newImage photo(file:CD#'/beer.gif')}
	 wall := {QTk.newImage photo(file:CD#'/wall.gif')}
	 bomb := {QTk.newImage photo(file:CD#'/bomb.gif')}
	 bg := {QTk.newImage photo(file:CD#'/white.gif')}
      end

      meth player(Team X Y) Img in
	 if Team == 'a' then
	    Img = @playera
	 else
	    Img = @playerb
	 end
	 {@grid configure(label(image:Img) row:X+X-1 column:Y+Y-1)}
      end
      
      meth score(Team X) S in
	 if Team == 'a' then
	    S = @scorea
	 else
	    S = @scoreb
	 end
	 {S set(""#X)}
      end
      
      
      meth bomb(X Y) Img in
	 {@grid configure(label(image:@bomb) row:X+X-1 column:Y+Y-1)}
      end
      meth food(X Y) Img in
	local A in A={Utils.random 1 2}
	 if A==1 then
	    {@grid configure(label(image:@food) row:X+X-1 column:Y+Y-1)}
	 else
	    {@grid configure(label(image:@beer) row:X+X-1 column:Y+Y-1)}
	 end
	end
      end
      meth wall(X Y) Img in
	 {@grid configure(label(image:@wall) row:X+X-1 column:Y+Y-1)}
      end

      meth reset(X Y)
	 {@grid configure(label(image:@bg) row:X+X-1 column:Y+Y-1)}
      end
   end
fun {NewBoard Init}
   {NewActive Gui Init}
end

   %% create the GUI object
%   G = {NewActive Gui init(Args.height Args.width)}
%   {G player(a 5 5)}
%   {G bomb(5 5)}
%   {G reset(5 5)}
%   {G score(a 4)}
end
