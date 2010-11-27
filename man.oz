declare
[Grid] = {Module.link ['grid.ozf']}
[Utils]= {Module.link ['utils.ozf']}

fun {ManBehaviour Msg State}
   case Msg of explode(Color) then
      % from grid
      if Color==State.color then
	 {Send State.grid died(state: State)}
	 State
      else
	 {AdjoinList State [color#Color]}
      end
   [] newManState(type:Type state:State) then
      % from grid
      {Browse new#State}
      {Browse pos#State.pos}
      % if update was due to a move, trigger new move request
      if Type==move then
	 {Send State.timer startTimer(delay:{DelayFromStrength State.strength} port:State.man response:canMove)}
      end
      State
   [] possibleMoves(moves:L) then
      % from grid
      {Browse Msg}
      {Browse L}
      {Send State.grid movingTo(currentState:State dest:{ChooseMove L})}
      State
   [] canMove then
      {Send State.grid askPossibilities(State)}
      State
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To implement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {DelayFromStrength Strength}
   Strength*1000
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
   State =  man(color:Color strength:1 state:waiting grid:Grid pos:pos(x:X y:Y) id:Id man:Man timer:ManTimer)
   Man = {Utils.newPortObject ManBehaviour State }
   {Browse man#b}
   % Send request for first move
   {Send ManTimer startTimer(delay:{DelayFromStrength 1} port:Man response:canMove)}
in
  Man     
end

declare
{Browse a}
GameGrid={Grid.newGridPort 40 40}
{Browse GameGrid}
{Browse b}
Man = {NewMan GameGrid 1 0 0 blue}