functor
import
   GridPort at './grid.ozf'
   Utils at './utils.ozf'
   Browser
export
   possibleMoves:PossibleMoves

define
 
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
	    Dest = {GridPort.getItemAt Grid NewPos}
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
      possibleMoves(moves: {ChooseBestMove Grid {Append [ManState.pos] {Utils.appendAll L1 L2 L3 L4 }}})
   end

   fun {ChooseBestMove Grid LPos}
      
      LPos
   end
   
end