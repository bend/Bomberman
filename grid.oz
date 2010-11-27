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

   fun {RemovePort Grid X Y Port}
      fun {Remove L}
	 case L of H|T then
	    if H==Port then {Remove T}
	    else H|{Remove T}
	    end
	 else nil
	 end
      end
   in
      {Remove {GetItemAt Grid X Y}}
   end



   fun {AddPort Grid X Y Port}
      Port|{GetItemAt Grid X Y}
   end
   
   
   fun {ModifyGrid Grid OldPos NewPos Type Port}
      local GridTemp in
	 GridTemp= {SetItemAt Grid OldPos.x OldPos.y block(state:normal ports:{RemovePort Grid OldPos.x OldPos.y Port})}
	 {SetItemAt GridTemp NewPos.x NewPos.y block(state:normal ports:{AddPort Grid NewPos.x NewPos.y Port})}
      end
   end      


   fun {GridBehaviour Message Grid}
      case Message of askPossibilities(ManState) then
	 {Send ManState.man possibleMoves(moves:[pos(ManState.pos.x+1 ManState.pos.y+1) pos(ManState.pos.x-1 ManState.pos.y-1)])}
	 Grid
      [] movingTo(ManState Pos) then
	 {Send ManState.man newManState(type:move state:{AdjoinList ManState [pos#Pos]})}
	 {ModifyGrid Grid ManState.pos Pos normal ManState.port}
      [] placeBomb(ManState Pos) then nil
      end
 
   end
   fun {NewGrid X Y}
      {Array.new 0 X {Array.new 0 Y block( state:_ ports:nil)}}
   end
   
   fun {GetItemAt Arr X Y}
      {Array.get {Array.get Arr X} Y}
   end
   
   fun {SetItemAt Arr X Y NewItem}
      {Array.put {Array.get Arr X} Y NewItem}
      Arr
   end
end
