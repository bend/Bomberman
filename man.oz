functor
export
   newMan:NewMan
import
   Utils at './utils.ozf'
   Grid at './grid.ozf'
   Browser


define

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To implement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {DelayFromStrength Strength}
      Strength*1000*3
   end
   fun {ChooseMove PossibleMoves}
      PossibleMoves.2.1
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End to implement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {NewMan Grid Id X Y Color}
   % Initialize state and man
      ManTimer = {Utils.timer}
      State =  man(color:Color strength:1 state:waiting grid:Grid pos:pos(x:X y:Y) id:Id man:Man)
      {Browser.browse settingup}
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
			 {AdjoinList State [state#dead]}
		      else
			 {Browser.browse deadByOther}
			 T in T = {AdjoinList State [color#Color]}
			 {Send Grid movingTo(currentState:T dest:T.pos)}
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
		      {Browser.browse received_can_move}
		      %{Send State.grid placeBomb(manState:State)}
		      {Send State.grid askPossibilities(State)}
		      %{Send ManTimer startTimer(delay:{DelayFromStrength State.strength} port:Man response:canMove)}
		      %{Browser.browse sent_place_bomb}
		      {Delay 1000}
		      State
		   else
		      {Browser.browse Msg}
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