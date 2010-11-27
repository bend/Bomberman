declare
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
fun {ManBehaviour Msg State}
   case Msg of explode(Color) then
      if Color==State.color then
	 {Send State.grid died(state: State)}
	 State
      else
	 {AdjoinList State [color#Color]}
      end
   [] newState(State) then
      State
   end
end

fun {NewMan Grid Id X Y Color}
   % Initialize state and man
   State =  man(color:Color strength:1 state:waiting grid:Grid pos:pos(x:X y:Y) id:Id man:Man)
   Man = {NewPortObject ManBehaviour State }
   % Send request for first move
   thread
%      {Delay {DelayForStrength Man}}
      {Send Grid askPossibilities(State)}      
   end
in
  Man     
end