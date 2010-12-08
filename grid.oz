functor
export
   newGridPort:NewGridPort
import
   Utils at './utils.ozf'
   Score at './score.ozf'
   GUI at './gui.ozf'
   Browser 

define
   Board
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Creates a new grid port and then excutes actions depending on the value received on the port
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {NewGridPort X Y Foods Walls}
      GridPort T S in
      Board = {GUI.newBoard init(X Y)}
      T = {Utils.timer}
      S = {Score.newScorePort Board GridPort}
      GridPort= {Utils.newPortObject
		 fun {$ Message Grid}
		    case Message of askPossibilities(ManState) then
		       {Send ManState.man {PossibleMoves Grid ManState X Y}}
		       Grid
		    [] endOfGame() then
		       {Browser.browse gameFinish}
		       _
		    [] initComplete() then
		       {Send S Message}
		       Grid
		    [] newMan(currentState:ManState pos:Pos) then
		       {Send S newMan(state:ManState)}
		       %{UpdateItemAt Grid Pos [ports#ManState.man]}
		       Grid
		    [] deadByTeammate(state:State) then
		       {Send S Message}
		       Grid
		    [] deadByOther(state:State) then
		       {Send S Message}
		       Grid
		    [] movingTo(currentState:ManState dest:Pos) then
		       if ManState.pos == Pos then
			  Grid
		       else	
			  OldPos=ManState.pos
			  StrengthIncrement={GetItemAt Grid Pos}.foods + {GetItemAt Grid OldPos}.foods
			  GridTemp NewGrid 
		       in
			  GridTemp={UpdateItemAt Grid OldPos [foods#0]}
			  NewGrid={UpdateItemAt Grid Pos [foods#0]}
			  {Send ManState.man newManState(type:move state:{AdjoinList ManState [pos#Pos strength#ManState.strength+StrengthIncrement]})}
			  {MovePort NewGrid ManState.pos Pos ManState}
		       end
		    [] placeBomb(manState:ManState) then
		       {AddBombToGrid Grid ManState T GridPort}
		    []bombs#timer(pos:Pos params:Params) then
		       % only handle the timer mesage if bomb not yet detonated, eg by string of explosion
		       if {GetItemAt Grid Pos}.bombs\=nil then
			  {DetonateBomb Grid Pos Params}
		       else
			  Grid
		       end
		    []foods#timer(pos:Pos params:Params) then TempGrid in
		       % only decrement the number of food if there is some food! If there's no food there, it's been eaten yet.
		       if {GetItemAt Grid Pos}.foods>0 then 
			  TempGrid = {UpdateItemAt Grid Pos [foods#{GetItemAt Grid Pos}.foods -1]}
		       else
			  TempGrid = Grid
		       end
		       {StartPutFoodTimer {RandomFoodPos TempGrid} T GridPort {Utils.tick}*5}
		       TempGrid
		    []putFood#timer(pos:Pos params:Params) then
		       {AddFoodToGrid Grid Pos  T GridPort}
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
      fun {DetonateBombAux Grid LPos}
	 case LPos of H|T then
	    thread {ExpolodesBombAt Grid H} end
	    Item in Item= {GetItemAt Grid H}
	    if Item.type == normal then
	       if Item.bombs\=nil andthen H\=Pos then % if there's a bomb, explods it it
		  GridTemp in GridTemp = {DetonateBombChain Grid H {GetItemAt Grid H}}
		  {SendToAll {GetItemAt GridTemp H}.ports hitByBomb(color:Params.color)}
		  {DetonateBombAux {UpdateItemAt GridTemp H [foods#0 bombs#nil ports#nil]} T}
	       else
		  {SendToAll {GetItemAt Grid H}.ports hitByBomb(color:Params.color)}
		  {DetonateBombAux {UpdateItemAt Grid H [foods#0 bombs#nil ports#nil]} T}
	       end
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
   %b(power:ManState.strength color:ManState.color pos:ManState.pos)
   fun {DetonateBombChain Grid Pos Block}
      fun {DetonateBombAux Grid LPos}
	 case LPos of H|T then
  	    thread {ExpolodesBombAt Grid H} end
	    It in It={GetItemAt Grid H}
	    if It.type == normal then
	       if It.bombs\=nil andthen H\=pos then
		  GridTemp in GridTemp = {DetonateBombChain Grid H {GetItemAt Grid H}}
		  {SendToAll {GetItemAt GridTemp H}.ports hitByBomb(color:It.bombs.1.color)}
		  {DetonateBombAux {UpdateItemAt GridTemp H [foods#0 bombs#nil ports#nil]} T}
	       else
		  {SendToAll {GetItemAt Grid H}.ports hitByBomb(color:It.bombs.1.color)}
		  {DetonateBombAux {UpdateItemAt Grid H [foods#0 bombs#nil ports#nil]} T}
	       end
	    else
	       Grid
	    end
	 else
	    Grid
	 end
      end
   in
      %{DetonateBombAux Grid {GetAffectedPos Grid Pos Block.bombs.1.power}}
      Grid
   end

   proc {ExpolodesBombAt Grid Pos}
      {Board explosion(Pos.x Pos.y)}
      {Delay 200}
      {Board reset(Pos.x Pos.y)}
   end
   
   
   fun {InitiateFoods Grid Foods Timer GridPort}
      if Foods == 0 then
	 Grid
      else
	 {StartPutFoodTimer {RandomFoodPos Grid} Timer GridPort {Utils.tick}*(2*Foods)}
	 {InitiateFoods Grid Foods-1 Timer GridPort}
      end
   end

   fun {RandomFoodPos Grid}
      X Y in
      X = {Utils.random 1 {Width Grid}}
      Y = {Utils.random 1 {Width Grid.1}}
      if {GetItemAt Grid pos(x:X y:Y)}.type \= normal then
	 {RandomFoodPos Grid}
      else pos(x:X y:Y)
      end
   end

   proc {StartPutFoodTimer Pos Timer GridPort Delay}
      {Send Timer startTimer(delay:Delay port:GridPort response:putFood#timer(pos:Pos params:params()))}
   end
   
      
   proc {SendToAll L M}
      case L of H|T then
	 {Send H.port M}
	 {SendToAll T M}
      else skip
      end
   end 
      


   fun {GetAffectedPos Grid Pos Power}
      L1 L2 L3 L4 Temp in
      {Browser.browse start_list_affected_pos}
      thread L1 = Pos|{ListAffectedPos Grid pos(x:Pos.x+1 y:Pos.y) x plus Power-1} end %we add the current position
      thread L2 = {ListAffectedPos Grid pos(x:Pos.x-1 y:Pos.y) x minus Power-1} end
      thread L3 = {ListAffectedPos Grid pos(x:Pos.x y:Pos.y+1) y plus Power-1} end
      thread L4 = {ListAffectedPos Grid pos(x:Pos.x y:Pos.y-1) y minus Power-1} end
      Temp = {AppendAll L1 L2 L3 L4}
      Temp
   end

   fun {AppendAll L1 L2 L3 L4}
      {Append L1 {Append L2 {Append L3 L4}}}
   end

   fun {ListAffectedPos Grid Pos Axis Dir Power}
      if Power < 0 orelse Pos.x>{Width Grid} orelse Pos.x<1 orelse Pos.y>{Width Grid.1} orelse Pos.y<1 then
	 nil
      else
	 if {GetItemAt Grid Pos}.type == wall then  nil
	 else
	    NewCoord in 
	    if Dir == minus then NewCoord = Pos.Axis -1 else NewCoord = Pos.Axis +1 end
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
      % Include current position in list of possible moves, in case man is blocked by other men.
      possibleMoves(moves: {Append [ManState.pos] {AppendAll L1 L2 L3 L4 }})
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Adds the bomb to the grid and stats a timer.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {AddBombToGrid Grid ManState Timer GridPort}
      GridTemp Params in
      Params = params(power:ManState.strength color:ManState.color)
      GridTemp = {UpdateItemAt Grid ManState.pos [bombs#[b(power:ManState.strength color:ManState.color pos:ManState.pos) {GetItemAt Grid ManState.pos}.bombs]]}
      {Send Timer startTimer(delay:{Utils.tick}*30 port:GridPort response:bombs#timer(pos:ManState.pos params:Params))}
      GridTemp
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Adds the food to the grid and stats a timer.
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {AddFoodToGrid Grid Pos Timer GridPort}
      {GenericAdder Grid Pos Timer GridPort foods params(delay:{Utils.tick}*20)}
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
      NewGrid in
      NewGrid = {SetItemAt Grid Pos {AdjoinList {GetItemAt Grid Pos} Updates}}
      {Redraw NewGrid Pos}
      NewGrid
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
	    T.I.J = block(type:normal bombs:nil foods:0 ports:nil)
	 end
      end
      {SetWallsInGrid T {RandomWallPositions Walls X Y}}
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
	 {SetWallsInGrid Z T}	 
      else Grid end
   end

   fun {RandomWallPositions N XMax YMax}
      if N==0 then nil
      else
	 pos(x:{Utils.random 2 XMax-1} y:{Utils.random 1 YMax})|{RandomWallPositions N-1 XMax YMax}
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
	    if Item.foods>0 then
	       {Board food(Pos.x Pos.y)}
	    else
	       if Item.bombs\=nil then
		  {Board bomb(Pos.x Pos.y)}
%	       else {Board reset(Pos.x Pos.y)}
	       end
	    end		  
	 end
      else
	 {Board wall(Pos.x Pos.y)}
      end
   end
end





