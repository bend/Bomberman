functor
import
   Utils at './utils.ozf'
   Browser
export
   newScorePort:NewScorePort

define
   fun {NewScorePort Board Grid}
      ScorePort in
      ScorePort ={Utils.newPortObject
		  fun {$ Message Score}
		     SF in 
		     case Message of newMan(state:State) then
			if State.color==a then
			   {Board score(a Score.teama+1)}
			   SF = score(teama:Score.teama+1 teamb:Score.teamb init:Score.init)
			else
			   {Board score(b Score.teamb+1)}
			   SF = score(teama:Score.teama teamb:Score.teamb+1 init:Score.init)
			end
		     [] deadByTeammate(state:State) then %we remove 1 from team 
			if State.color==a then
			   {Board score(a Score.teama-1)}	   
			   SF = score(teama:Score.teama-1 teamb:Score.teamb init:Score.init)
			else
			   {Board score(b Score.teamb-1)}	   
			   SF = score(teama:Score.teama teamb:Score.teamb-1 init:Score.init)
			end
		     [] deadByOther(state:State) then
			if State.color==a then
			   {Board score(a Score.teama-1)}
			   {Board score(b Score.teamb+1)}	   
			   SF = score(teama:Score.teama-1 teamb:Score.teamb+1 init:Score.init)% we remove 1 from team and add one to other team
			else
			   {Board score(a Score.teama+1)}
			   {Board score(b Score.teamb-1)}
			   SF = score(teama:Score.teama+1 teamb:Score.teamb-1 init:Score.init)
			end
		     [] initComplete() then
			SF = score(teama:Score.teama teamb:Score.teamb init:finish)
		     else SF=Score
		     end
		     {Browser.browse SF.teama#SF.teamb#SF.init}
		     if ((SF.teama==0 andthen SF.teamb>0) orelse (SF.teamb==0 andthen SF.teama>0)) andthen SF.init==finish then
			{Send Grid endOfGame()}
		     end
		     SF
		  end
		  score(teama:0 teamb:0 init:notFinish)}
      ScorePort
   end
end
       