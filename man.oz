functor
export
   initMen:InitMen
import
   Utils at './utils.ozf'
   Grid at './grid.ozf'
   Browser


define

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To implement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {DelayFromStrength Strength}
      (Strength+5)*{Utils.tick}
   end
   fun {ChooseMove PossibleMoves}
      I= {Utils.random 1 {Length PossibleMoves}}
   in
      {Nth PossibleMoves I}
   end
   fun {DecideToPutBomb ManState}
      if ManState.strength>0 then
	 if {Utils.random 1 10}>9 then
	    true
	 else
	    false
	 end
      else
	 false
      end
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End to implement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   proc {InitMen X Y GameGrid}
      for I in 1..Y do
	 Man1 Man2 in 
	 Man1 = {NewMan GameGrid 1 1 I a}
	 Man2 = {NewMan GameGrid 1 X I b}
      end
      {Send GameGrid initComplete()}
   end

   
   fun {NewMan Grid Id X Y Color}
   % Initialize state and man
      ManTimer = {Utils.timer}
      State =  man(color:Color strength:0 state:waiting grid:Grid pos:pos(x:X y:Y) id:Id man:Man)
      {Send Grid newMan(currentState:State)}
      {Send Grid movingTo(currentState:State dest:pos(x:X y:Y))}
      Man = {Utils.newPortObject
	     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Man behaviour
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	     fun {$ Msg State}
		if State.state == dead then
		   State
		else
		   case Msg of hitByBomb(color:Color) then
		      if Color==State.color then
			 {Browser.browse deadByTeammate}
			 {Send Grid deadByTeammate(state:State)}
			 {AdjoinList State [state#dead]}
		      else
			 {Browser.browse deadByOther}
			 T in T = {AdjoinList State [color#Color]}
			 {Send Grid movingTo(currentState:T dest:T.pos)}
			 {Send Grid deadByOther(state:State)}
			 T
		      end
		   [] newManState(type:Type state:State) then
                      % from grid
                      % if update was due to a move, trigger new move request
                      %if Type==move then
		      %{Send ManTimer startTimer(delay:{DelayFromStrength State.strength} port:Man response:canMove)}
		      %end
		      State
		   [] possibleMoves(moves:L) then
		      {Send State.grid movingTo(currentState:State dest:{ChooseMove L})}
		      {Send ManTimer startTimer(delay:{DelayFromStrength State.strength} port:Man response:canMove)}
		      State
		   [] canMove then
		      if {DecideToPutBomb State} then NewState in
			 {Send State.grid placeBomb(manState:State)}
			 {Send ManTimer startTimer(delay:{DelayFromStrength State.strength} port:Man response:canMove)}
			 NewState = {AdjoinList State [strength#(State.strength-1)]}
			 NewState
		      else
			 {Send State.grid askPossibilities(State)}
			 State
		      end
		   else
		      {Browser.browse unknownMsg#Msg}
		      State
		   end
		end
	    end
      State }
      {Send ManTimer startTimer(delay:{DelayFromStrength 1} port:Man response:canMove)}% Send request for first move
   in
      Man     
   end
   
end