functor
import
   Utils at './utils.ozf'
   Browser
export
   newScorePort:NewScorePort

define
   fun {NewScorePort Board}
      ScorePort in
      ScorePort ={Utils.newPortObject
		  fun {$ Message Score}
		     case Message of newMan(state:State) then
			if State.color==a then
			   {Board score(a Score.teama+1)}
			   score(teama:Score.teama+1 teamb:Score.teamb)
			else
			   {Board score(b Score.teamb+1)}
			   score(teama:Score.teama teamb:Score.teamb+1)
			end
		     [] deadByTeammate(state:State) then %we remove 1 from team 
			if State.color==a then
			   {Board score(a Score.teama-1)}	   
			   score(teama:Score.teama-1 teamb:Score.teamb)
			else
			   {Board score(b Score.teamb-1)}	   
			   score(teama:Score.teama teamb:Score.teamb-1)
			end
		     [] deadByOther(state:State) then
			if State.color==a then
			   {Board score(a Score.teama-1)}
			   {Board score(b Score.teamb+1)}	   
			   score(teama:Score.teama-1 teamb:Score.teamb+1)% we remove 1 from team and add one to other team
			else
			   {Board score(a Score.teama+1)}
			   {Board score(b Score.teamb-1)}
			   score(teama:Score.teama+1 teamb:Score.teamb-1)
			end
		     else Score
		     end
		  end
		  score(teama:0 teamb:0)}
      ScorePort
   end
end
       