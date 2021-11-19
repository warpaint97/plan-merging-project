% plan merger encoding
% implementing a plan switching method for robots of which are involved in an edge collision conflict

%reading instance
#include "./input.lp".


% read renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

%calculate original positions recursively
position(R,(X+DX,Y+DY),T,0) :- move(R,(DX,DY),T), position(R,(X,Y),T-1,0).


% edge collision
edge_collision(R,R',T,D) :- position(R,C,T-1,D), position(R,C',T,D), position(R',C',T-1,D), position(R',C,T,D), R!=R', C!=C'.



% reconstruct positions and incorporate plan switching
%before edge collision
position(R,C,T,D+1) :- position(R,C,T,D), edge_collision(R,_,T_SWITCH,D), T<T_SWITCH.
%after edge collision
position(R,C,T,D+1) :- position(R',C,T+1,D), edge_collision(R,R',T_SWITCH,D), T>=T_SWITCH.



% determine the max conflict depth for each robot
max_conflict_depth(R,MAX_D-1) :- MAX_D == #sum{1,D : position(R,(X_,Y_),T_,D)}, isRobot(R).


% final plan
final_position(R,C,T) :- position(R,C,T,D), max_conflict_depth(R,D).
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T-1), final_position(R,(C2X,C2Y),T).



% output plan
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).