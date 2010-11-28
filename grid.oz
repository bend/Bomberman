functor
export
   newGridPort:NewGridPort
import
% Raph
%   Utils at 'file:///home/rb/etudes/Bomberman/utils.ozf'
% Ben   
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
		    %{BrowseGrid Grid}
		    {Delay 15000}
		    case Message of askPossibilities(ManState) then
		       {Send ManState.man {PossibleMoves ManState}}
		       Grid
		    [] movingTo(currentState:ManState dest:Pos) then
		       {Send ManState.man newManState(type:move state:{AdjoinList ManState [pos#Pos]})}
		       {MovePort Grid ManState.pos Pos ManState.man}
		    [] placeBomb(manState:ManState) then
		       {AddBombToGrid Grid ManState T GridPort}
		    []bombs#timer(pos:Pos params:Params) then
		       {Browser.browse got_bombs_event}
		       {DetonateBomb Grid Pos Params}
		    else
		       {Browser.browse got_unmanaged_message#Message}
		       Grid
		    end
		 end
		 {NewGrid X Y}}
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Detonates the bomb, kills player that are affected
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {DetonateBomb Grid Pos Params}      
      {Browser.browse boom#Pos}
      {Browser.browse {GetAffectedPos Grid Pos Params.power}}
      Grid
   end

   fun {GetAffectedPos Grid Pos Power}
      L1 L2 L3 L4 in
      thread L1 = Pos|{ListAffectedPos Grid pos(x:Pos.x+1 y:Pos.y) x plus Power-1} end %we add the current position
      thread L2 = {ListAffectedPos Grid pos(x:Pos.x-1 y:Pos.y) x minus Power-1} end
      thread L3 = {ListAffectedPos Grid pos(x:Pos.x y:Pos.y+1) y plus Power-1} end
      thread L4 = {ListAffectedPos Grid pos(x:Pos.x y:Pos.y-1) y minus Power-1} end
      {AppendAll L1 L2 L3 L4}
   end

   fun {AppendAll L1 L2 L3 L4}
      {Append L1 {Append L2 {Append L3 L4}}}
   end

   fun {ListAffectedPos Grid Pos Axis Dir Power}
      if Power < 0 then nil
      else
	 if {GetItemAt Grid Pos}.type == wall then  nil
	 else
	    NewCoord in 
	    if Dir == minus then NewCoord = Pos.Axis -1
	    else NewCoord = Pos.Axis +1 end    
	    Pos|{ListAffectedPos Grid {AdjoinList Pos [Axis#NewCoord]} Axis Dir Power-1}
	 end
      end
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
   fun {MovePort Grid OldPos NewPos Port}
      GridTemp in
      GridTemp = {UpdateItemAt Grid OldPos [ports#{RemovePort Grid OldPos Port}]}
      {UpdateItemAt Grid NewPos  [ports#{AddPort GridTemp NewPos Port}]}
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
      {GenericAdder Grid ManState.pos Timer GridPort bombs params(power:ManState.strength color:ManState.color)}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Adds the food to the grid and stats a timer.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {AddFoodToGrid Grid Pos Timer GridPort}
      {GenericAdder Grid Pos Timer GridPort foods nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Adds the Type to the grid and stats a timer.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {GenericAdder Grid Pos Timer GridPort Type Params}
      GridTemp in
      GridTemp = {UpdateItemAt Grid Pos [Type#{GetItemAt Grid Pos}.Type+1]}
      {Send Timer startTimer(delay:1000 port:GridPort response:Type#timer(pos:Pos params:Params))}
      GridTemp
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Updates the Item At Pos with the list of Updates
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {UpdateItemAt Grid Pos Updates}
      {SetItemAt Grid Pos {AdjoinList {GetItemAt Grid Pos} Updates }}
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns a new Grid depending of X*Y
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {NewGrid X Y}
      Grid in
      Grid = {Array.new 0 X {Array.new 0 Y block( type:normal bombs:0 foods:0 ports:nil)}}
      %{Browser.browse {RandomPositions 1 X Y}}
      {SetWallsInGrid Grid {RandomPositions 1 X Y}}
   end

   fun {SetWallsInGrid Grid L}
      case L of H|T then
	 {Browser.browse setting_wall_at#H}
	 Tep in Tep={SetWallsInGrid {UpdateItemAt Grid H [type#wall]} T}
	 {BrowseGrid Tep}
	 Tep
      else Grid end
   end

   fun {RandomPositions N XMax YMax}
      if N==0 then nil
      else
	 pos(x:{Utils.random 0 XMax} y:{Utils.random 0 YMax})|{RandomPositions N-1 XMax YMax}
      end
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

   proc {BrowseGrid Grid}
      for I in 0..{Array.high Grid} do
	 for J in 0.. {Array.high Grid.I} do
	    {Browser.browse {GetItemAt Grid pos(x:I y:J)}}
	 end
      end
   end
   
      
end



