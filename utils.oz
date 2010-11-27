functor 
export
  newPortObject:NewPortObject
  newPortObject2:NewPortObject2
  timer:Timer
define

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

fun {NewPortObject2 Proc}
   Sin in
   thread for Msg in Sin do {Proc Msg} end end
   {NewPort Sin}
end

% send a message starttime(Delay MyPort ReplyMessageToSend)
fun {Timer}
   {NewPortObject2
    proc {$Msg}
       case Msg of starttimer(delay:T port:P response:Reply) then
	  thread {Delay T} {Send P Reply} end
       end
    end
   }
end
end   
