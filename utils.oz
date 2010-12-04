functor 
export
   newPortObject:NewPortObject
   newPortObject2:NewPortObject2
   timer:Timer
   random:Random
   tick:Tick
import
   OS
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

% send a message starttime(delay:Delay port:MyPort response:ReplyMessageToSend)
   fun {Timer}
      {NewPortObject2
       proc {$Msg}
	  case Msg of startTimer(delay:T port:P response:Reply) then
	     thread {Delay T} {Send P Reply} end
	  end
       end
      }
   end

   fun {Random Min Max}
      Min + {OS.rand } mod (Max+1-Min)
   end
   
   fun {Tick}
      1000
   end
end   
