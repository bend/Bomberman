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

   fun {GridBehaviour Message Grid}
      nil
   end
   fun {NewGrid X Y}
      {Array.new 0 X {Array.new 0 Y block( state:_ ports:nil)}}
   end
   
   fun {GetItemAt Arr X Y}
      {Array.get {Array.get Arr X} Y}
   end
   
   proc {SetItemAt Arr X Y NewItem}
      {Array.put {Array.get Arr X} Y NewItem}
   end
   
end
