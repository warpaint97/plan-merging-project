% ----------------------------------------------------------------------------------------------
% reading renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

% calculate original positions recursively
position(R,(X+DX,Y+DY),T) :- move(R,(DX,DY),T), position(R,(X,Y),T-1).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,R,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
switch_pos(R,R',T,T',T_later,T'_later) :-  position(R,C,T), position(R',C,T'_later), position(R,C',T_later), position(R',C',T'),
					R!=R',
					T_later>T,T'_later>T'.

%not_best_switch_pos(R,R',T,T_later,L) :- switch_pos(R,R',T,T',T_later,T'_later), switch_pos(R,R',D,D',D_later,D'_later), T_later-T<D_later-D.
best_switch_pos(R,R',T,T',D,D') :- switch_pos(R,R',T,T',D), not not_best_switch_pos(R,R',T,T',D,D').

% for each best switch position decide to switch or not.
{switch(R,R',T,D)} :- best_switch_pos(R',R,T,D).
switch(R,R',T',D') :- switch(R',R,T,D), best_switch_pos(R,R',T',D').

% create final positions recursively
final_position(R,C',T+1,R,N+1) :- position(R',C',N+1), final_position(R,C,T,R',N), not switch(R',_,T,_).
final_position(R,C',T+1,R'',D+1) :- switch(R',R'',T,D), position(R'',C',D+1), final_position(R,C,T,R',N).
% ----------------------------------------------------------------------------------------------


% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% Switch twice, same pair.
:- switch(R,R',T,D), switch(R,R',T',D'), T'!=T.

% Switch twice in one timestep.
:- switch(R,R',T,D),switch(R',R'',T,D'), R!=R''.

% Switch twice with same robot.
:- switch(R,R',T,D),switch(R,R'',T,D'), R'!=R''.
% ----------------------------------------------------------------------------------------------


% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,R',N)}.
#minimize{T@1 : horizon(T)}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T+1) :- final_position(R,(C1X,C1Y),T,X,Y), final_position(R,(C2X,C2Y),T+1,X',Y').

% show statements
#show.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
