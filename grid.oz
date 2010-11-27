functor
export
   newGridPort:NewGridPort

define

   fun {NewGridPort X Y}
      {NewPortObject GridBehaviour {NewGrid X Y}}
   end

   fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
   in
      thread {MsgLoop Sin Init} end
      {NewPort Sin}
   end

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
      {Remove {GetItemAt Grid Pos}}
   end



   fun {AddPort Grid Pos Port}
      Port|{GetItemAt Grid Pos}
   end
   
   
   fun {ModifyGrid Grid OldPos NewPos Type Port}
      local GridTemp in
	 GridTemp= {SetItemAt Grid OldPos block(state:normal ports:{RemovePort Grid OldPos Port})}%remove man from pos
	 {SetItemAt GridTemp NewPos block(state:normal ports:{AddPort Grid NewPos Port})}%and add it here
      end
   end

   fun {PossibleMoves ManState}
      possibleMoves(moves:[pos(x:ManState.pos.x+1 y:ManState.pos.y+1) pos(x:ManState.pos.x-1 y:ManState.pos.y-1)])
   end

   fun {AddBombToGrid Grid ManState Pos}
      local Grid in
	 Grid  = {SetItemAt Grid Pos block(state:bomb ports:{GetItemAt Grid Pos})}
	 end
      
   end
   

  fun {GridBehaviour Message Grid}
      case Message of askPossibilities(ManState) then
	 {Send ManState.man {PossibleMoves ManState}}
	 Grid
      [] movingTo(currentState:ManState dest:Pos) then
	 {Send ManState.man newManState(type:move state:{AdjoinList ManState [pos#Pos]})}
	 {ModifyGrid Grid ManState.pos Pos normal ManState.man}
      [] placeBomb(ManState Pos) then
	 {AddBombToGrid Grid ManState Pos}
      end
 
   end
   fun {NewGrid X Y}
      {Array.new 0 X {Array.new 0 Y block( state:_ ports:nil)}}
   end
   
   fun {GetItemAt Arr Pos}
      {Array.get {Array.get Arr Pos.x} Pos.y}
   end
   
   fun {SetItemAt Arr Pos NewItem}
      {Array.put {Array.get Arr Pos.x} Pos.y NewItem}
      Arr
   end
end
