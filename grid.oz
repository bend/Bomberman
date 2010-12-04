functor
export
   newGridPort:NewGridPort
import
   Utils at './utils.ozf'
   GUI at './gui.ozf'
   Browser 

define
   Board
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Creates a new grid port and then excutes actions depending on the value received on the port
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {NewGridPort X Y Foods Walls}
      GridPort T in
      Board = {GUI.newBoard init(X Y)}
      T = {Utils.timer}
      GridPort= {Utils.newPortObject
		 fun {$ Message Grid}
		    case Message of askPossibilities(ManState) then
		       {Send ManState.man {PossibleMoves Grid ManState X Y}}
		       Grid
		    [] movingTo(currentState:ManState dest:Pos) then
		       NewGrid OldPos=ManState.pos in
		       {Browser.browse movingFrom#ManState.color#OldPos#to#Pos}
		       {Send ManState.man newManState(type:move state:{AdjoinList ManState [pos#Pos]})}		     
		       NewGrid = {MovePort Grid ManState.pos Pos ManState}
		       {Redraw NewGrid OldPos}
		       {Redraw NewGrid Pos}
		       NewGrid
		    [] placeBomb(manState:ManState) then
		       {AddBombToGrid Grid ManState T GridPort}
		    []bombs#timer(pos:Pos params:Params) then
		       {Browser.browse detonate_bomb_at#Pos}
		       {DetonateBomb Grid Pos Params}
		    []foods#timer(pos:Pos) then
		       {AddFoodToGrid {UpdateItemAt Grid Pos [foods#{GetItemAt Grid Pos}.foods -1]} {RandomFoodPos Grid} Timer GridPort}
		    else
		       {Browser.browse got_unmanaged_message#Message}
		       Grid
		    end
		 end
		 {InitiateFoods {NewGrid X Y Walls} Foods T GridPort}}
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Detonates the bomb, kills player that are affected
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {DetonateBomb Grid Pos Params}
%      {Browser.browse 'Boummmmmmmmmm'}
      fun {DetonateBombAux Grid LPos}
	 case LPos of H|T then
	    Item in Item= {GetItemAt Grid H}
	    if Item.type == normal then
	       {SendToAll {GetItemAt Grid H}.ports hitByBomb(color:Params.color)}
	       {DetonateBombAux {UpdateItemAt Grid H [foods#0 bombs#0 ports#nil]} T}
	    else
	       Grid
	    end
	 else
	    Grid
	 end
      end
   in
      local T in
	 T = {DetonateBombAux Grid {GetAffectedPos Grid Pos Params.power}}
	 T
      end
   end

   fun {InitiateFoods Grid Foods Timer GridPort}
      if Foods == 0 then
	 Grid
      else
	 {InitiateFoods {AddFoodToGrid Grid {RandomFoodPos Grid} Timer GridPort} Foods-1 Timer GridPort}
      end
   end

   fun {RandomFoodPos Grid}
      X Y in
      X = {Utils.rand 1 {Width Grid}}
      Y = {Utils.rand 1 {Width Grid.1}}
      if {GetItemAt Grid pos(x:X y:Y)}.type \= normal then
	 {RandomFoodPos Grid}
      else pos(x:X y:Y)
      end
   end
   
   
      
   proc {SendToAll L M}
      case L of H|T then
	 {Send H.port M}
	 {SendToAll T M}
      else skip
      end
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
      %{Remove {GetItemAt Grid Pos}.ports}
      nil
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
   fun {MovePort Grid OldPos NewPos ManState}
      GridTemp in
      GridTemp = {UpdateItemAt Grid OldPos [ports#{RemovePort Grid OldPos ManState.man}]}
      %GridTemp = {UpdateItemAt Grid OldPos [ports#nil]}
      {UpdateItemAt GridTemp NewPos  [ports#{AddPort GridTemp NewPos man(port:ManState.man color:ManState.color)}]}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns a list of possoble moves to the player depending on his position
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {PossibleMoves Grid ManState MaxX MaxY}
      L1 L2 L3 L4
      fun {MovesListInDir Pos Axis Dir}
	 NewPos
	 Max=max(x:MaxX y:MaxY)
	 Dest
	 Index
      in
	 if Dir==plus then
	    Index=ManState.pos.Axis+1
	 else
	    Index=ManState.pos.Axis-1
	 end
	 if Index==0 orelse Index>Max.Axis then
	    nil
	 else
	    NewPos={AdjoinList ManState.pos [Axis#Index]}
	    Dest = {GetItemAt Grid NewPos}
	    if Dest.ports==nil andthen Dest.type==normal then
	       [NewPos]
	    else
	       nil
	    end
	 end
      end
   in
      L1 = {MovesListInDir ManState.pos x plus}
      L2 = {MovesListInDir ManState.pos x minus}
      L3 = {MovesListInDir ManState.pos y plus}
      L4 = {MovesListInDir ManState.pos y minus}
      possibleMoves(moves: {AppendAll L1 L2 L3 L4})
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Adds the bomb to the grid and stats a timer.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {AddBombToGrid Grid ManState Timer GridPort}
      {GenericAdder Grid ManState.pos Timer GridPort bombs params(power:ManState.strength color:ManState.color delay:{Utils.tick}*10)}
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
      {Send Timer startTimer(delay:Params.delay port:GridPort response:Type#timer(pos:Pos params:Params))}
      GridTemp
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Updates the Item At Pos with the list of Updates
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {UpdateItemAt Grid Pos Updates}
      {SetItemAt Grid Pos {AdjoinList {GetItemAt Grid Pos} Updates}}
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns a new Grid depending of X*Y
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {NewGrid X Y Walls}
      T List in
      T = {MakeTuple grid X}
      for I in 1..X do
	 for J in 1..Y do
	    T.I = {MakeTuple grid Y}
	    T.I.J = block(type:normal bombs:0 foods:0 ports:nil)
	 end
      end
      {SetWallsInGrid T {RandomPositions Walls X Y}}
   end

   fun {NewEmptyGrid X Y}
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


   fun {SetWallsInGrid Grid L}
      case L of H|T then
	 Z in
	 Z = {UpdateItemAt Grid H [type#wall]}
	 {Redraw Z H}
	 {SetWallsInGrid Z T}	 
      else Grid end
   end

   fun {RandomPositions N XMax YMax}
      if N==0 then nil
      else
	 pos(x:{Utils.random 1 XMax} y:{Utils.random 1 YMax})|{RandomPositions N-1 XMax YMax}
      end
   end


   

   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Returns the item (record) that is located on the block X Y of the grid
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {GetItemAt Grid Pos}
      X Y in X= Pos.x
      Y =Pos.y
      Grid.X.Y
   end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Sets the Item on the block grid X Y
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {SetItemAt T Pos NewItem}
      Temp in Temp = {NewEmptyGrid {Width T} {Width T.1}}
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

   proc {Redraw Grid Pos}
      Item={GetItemAt Grid Pos}
   in
      {Board reset(Pos.x Pos.y)}
      if Item.type==normal then
	 if Item.ports\=nil then
	    {Board player(Item.ports.1.color Pos.x Pos.y)}
	 else
	    if Item.foods\=0 then
	       {Board food(Pos.x Pos.y)}
	    else
		  if Item.bombs\=0 then
		     {Board bomb(Pos.x Pos.y)}
		  end
	    end		  
	 end
      else
	 {Board wall(Pos.x Pos.y)}
      end
   end



   
end





