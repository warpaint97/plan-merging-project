% plan merger encoding
% implementing a waiting statement for robots of lower priority in the case of a vertex conflict


%reading instance
#include "./input_layers.lp".


% read renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

%calculate original positions recursively
position(R,(X+DX,Y+DY),T,0) :- move(R,(DX,DY),T), position(R,(X,Y),T-1,0).



% vertex collision
vertex_collision(C,T,D) :- position(R1,C,T,D), position(R2,C,T,D), R1!=R2.

%conflicts
conflict(R,T,D) :- vertex_collision(C,T,D), position(R,C,T,D).

%wait
wait(R2,T,D) :- conflict(R1,T,D), conflict(R2,T,D), R1<R2.



% reconstruct positions and incorporate waiting
%before wait
position(R,(X,Y),T,D+1) :- position(R,(X,Y),T,D), wait(R,T_WAIT,D), T<T_WAIT.
%after wait
position(R,(X,Y),T,D+1) :- position(R,(X,Y),T-1,D), wait(R,T_WAIT,D), T>=T_WAIT.



% determine the max conflict depth for each robot
max_conflict_depth(R,MAX_D-1) :- MAX_D == #count{D : position(R,_C,_T,D)}, isRobot(R).


% final plan
final_position(R,C,T) :- position(R,C,T,D), max_conflict_depth(R,D).
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T), final_position(R,(C2X,C2Y),T+1).



% output plan
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
