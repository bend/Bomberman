functor
export
   newGridPort:NewGridPort
import
   Utils at 'file://Users/benoitdaccache/Documents/Programation/OZ/Bomberman/utils.ozf'
   Browser 

define
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Creates a new grid port and then excutes actions depending on the value received on the port
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {NewGridPort X Y}
      GridPort T in
      T = {Utils.timer}
      GridPort= {Utils.newPortObject
		 
		 fun {$ Message Grid}
		    case Message of askPossibilities(ManState) then
		       {Send ManState.man {PossibleMoves ManState}}
		       Grid
		    [] movingTo(currentState:ManState dest:Pos) then
		       {Send ManState.man newManState(type:move state:{AdjoinList ManState [pos#Pos]})}
		       {ModifyGrid Grid ManState.pos Pos normal ManState.man}
		    [] placeBomb(manState:ManState) then
		       {AddBombToGrid Grid ManState T GridPort}
		    []bombTimeout(pos:Pos) then
		       {DetonateBomb Grid Pos}
		    end
		 end
		 {NewGrid X Y}}
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Detonates the bomb, kills player that are affected
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {DetonateBomb Grid Pos}
      {Browser.browse 'bouuuum'#Pos}
      Grid
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Removes the port from the list of ports contained in the grid record.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {RemovePort Grid Pos Port}
      fun {Remove L}
	 case L of H|T then
	    if H==Port then {Remove T}
	    else H|{Remove T}
	    end
	 else nil
	 end
      end
   in
      {Remove {GetItemAt Grid Pos}.ports}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Adds a port to the list of port contained in the grid record
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {AddPort Grid Pos Port}
      Port|{GetItemAt Grid Pos}.ports
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Modifies the grid by removing the 'man' from his oldPos and adds it to his newPos
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {ModifyGrid Grid OldPos NewPos Type Port}
      local GridTemp in
	 GridTemp= {SetItemAt Grid OldPos block(state:normal ports:{RemovePort Grid OldPos Port})}%remove man from pos
	 {SetItemAt GridTemp NewPos block(state:normal ports:{AddPort Grid NewPos Port})}%and add it here
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns a list of possoble moves to the player depending on his position
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {PossibleMoves ManState}
      possibleMoves(moves:[pos(x:ManState.pos.x+1 y:ManState.pos.y+1) pos(x:ManState.pos.x-1 y:ManState.pos.y-1)])
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Adds the bomb to the grid and stats a timer.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {AddBombToGrid Grid ManState Timer GridPort}
      local Grid in
	 Grid  = {SetItemAt Grid ManState.pos block(state:bomb ports:{GetItemAt Grid ManState.pos})}
      end
      {Send Timer startTimer(delay:1000 port:GridPort response:bombTimeout(pos:ManState.pos))}
      Grid
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns a new Grid depending of X*Y
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {NewGrid X Y}
      {Array.new 0 X {Array.new 0 Y block( state:_ ports:nil)}}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns the item (record) that is located on the block X Y of the grid
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {GetItemAt Arr Pos}
      {Array.get {Array.get Arr Pos.x} Pos.y}
   end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Sets the Item on the block grid X Y
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {SetItemAt Arr Pos NewItem}
      {Array.put {Array.get Arr Pos.x} Pos.y NewItem}
      Arr
   end
end

