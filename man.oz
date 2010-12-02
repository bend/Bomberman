declare
%Ben
[Grid] = {Module.link ['/Users/benoitdaccache/Documents/Programation/OZ/Bomberman/grid.ozf']}
[Utils]= {Module.link ['/Users/benoitdaccache/Documents/Programation/OZ/Bomberman/utils.ozf']}
% Raph
%[Grid] = {Module.link ['grid.ozf']}
%[Utils]= {Module.link ['utils.ozf']}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To implement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {DelayFromStrength Strength}
   Strength*1000*3
end
fun {ChooseMove PossibleMoves}
   PossibleMoves.1
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End to implement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fun {NewMan Grid Id X Y Color}
   % Initialize state and man
   {Browse man#a}
   ManTimer = {Utils.timer}
   State =  man(color:Color strength:1 state:waiting grid:Grid pos:pos(x:X y:Y) id:Id man:Man)
   {Send Grid movingTo(currentState:State dest:pos(x:X y:Y))}
   Man = {Utils.newPortObject

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Man behaviour
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  fun {$ Msg State}
	     case Msg of hitByBomb(color:Color) then
      % from grid
		if Color==State.color then
		   {Send State.grid died(state: State)}
		   State
		else
		   {AdjoinList State [color#Color]}
		end
	     [] newManState(type:Type state:State) then
      % from grid
      % if update was due to a move, trigger new move request
		%if Type==move then
		   %{Send ManTimer startTimer(delay:{DelayFromStrength State.strength} port:Man response:canMove)}
		%end
		State
	     [] possibleMoves(moves:L) then
      % from grid
		{Browse Msg}
		{Browse L}
		{Send State.grid movingTo(currentState:State dest:{ChooseMove L})}
		State
	     [] canMove then
%		{Browse received_can_move}
%		{Send State.grid askPossibilities(State)}
		{Send State.grid placeBomb(manState:State)}
		{Send ManTimer startTimer(delay:{DelayFromStrength State.strength} port:Man response:canMove)}
		{Browse sent_place_bomb}
		State
	     else {Browse Msg}State
	     end
	  end
	  State }
   {Browse man#b}
   % Send request for first move
   {Send ManTimer startTimer(delay:{DelayFromStrength 1} port:Man response:canMove)}
in
  Man     
end

declare
{Browse a}
GameGrid={Grid.newGridPort 10 10}
{Browse GameGrid}
{Browse b}
Man = {NewMan GameGrid 1 5 5 blue}
