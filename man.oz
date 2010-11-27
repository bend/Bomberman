declare
[Grid] = {Module.link ['/home/rb/etudes/Bomberman/grid.ozf']}



   fun {NewGridPort X Y}
{Browse g1}
      {NewPortObject GridBehaviour {NewGrid X Y}}
{Browse g2}
   end

   fun {NewPortObject Behaviour Init}
{Browse g3}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
         {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
   in
{Browse g4}
      thread {MsgLoop Sin Init} end
{Browse g5}
      {NewPort Sin}
   end

   fun {GridBehaviour Message Grid}
{Browse g6}
      case Message of askPossibilities(ManState) then
         {Send ManState.man possibleMoves(moves:[pos(ManState.pos.x+1 ManState.pos.y+1) pos(ManState.pos.x-1 ManState.pos.y-1)])}
         Grid
      [] movingTo(ManState Pos) then nil

      [] placeBomb(ManState Pos) then nil
      end

   end
   fun {NewGrid X Y}
{Browse g7}
      {Array.new 0 X {Array.new 0 Y block( state:_ ports:nil)}}
   end

   fun {GetItemAt Arr X Y}
      {Array.get {Array.get Arr X} Y}
   end

   proc {SetItemAt Arr X Y NewItem}
      {Array.put {Array.get Arr X} Y NewItem}
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
   [] possibleMoves(moves:L) then
      {Browse Msg}
      {Browse L}
      State
   end
end

fun {NewMan Grid Id X Y Color}
   % Initialize state and man
   {Browse man#a}
   State =  man(color:Color strength:1 state:waiting grid:Grid pos:pos(x:X y:Y) id:Id man:Man)
   Man = {NewPortObject ManBehaviour State }
   {Browse man#b}
   % Send request for first move
   thread
%      {Delay {DelayForStrength Man}}
      {Send Grid askPossibilities(State)}      
   end
in
  Man     
end

declare
{Browse a}
Grid={Grid.newGridPort 4 4}
{Browse Grid}
{Browse b}
Man = {NewMan Grid 1 0 0 blue}