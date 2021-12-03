% - plan merger encoding -----------------------------------------------------------------------
% Only store current depth of each robot in layer

% CONSTANTS
% ----------------------------------------------------------------------------------------------
% to guarantee termination
#const max_time=20.
time(0..max_time-2).

#const max_wait=20.
wait(0..max_wait-2).
% ----------------------------------------------------------------------------------------------


% READING INSTANCE
% ----------------------------------------------------------------------------------------------
#include "./input.lp".
% ----------------------------------------------------------------------------------------------


% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

%calculate original positions recursively
position(R,(X+DX,Y+DY),T) :- move(R,(DX,DY),T), position(R,(X,Y),T-1).

%first final position
final_position(R,C,0,0) :- position(R,C,0), isRobot(R).

% Create final positions recursively. Either wait at the same position or take the next step in plan
{final_position(R,C,T+1,D+1)} :- final_position(R,C,T,D), wait(D).
final_position(R,C',T+1,D) :- position(R,C',T-D), not final_position(R,C,T+1,D+1), final_position(R,C,T,D), time(T-D).

%if another robot is still moving wait so that conflicts can still be detected.
final_position(R,C,T+1,D+1) :- final_position(R,C,T,D), not position(R,C',T-D), final_position(R',C',T+1,D'), R'!=R.

%constraints
:- final_position(R,C,T,D), not position(R,C,_).
:- final_position(R,C,T,D), final_position(R',C,T,D'), R!=R'.
:- final_position(R,C,T,D), final_position(R,C',T,D'), C!=C'.

%reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,D), final_position(R,(C2X,C2Y),T+1,D').

%optimization
horizon(T_max) :- T_max == #max{T : final_position(R,C,T,D)}.

#minimize{T: horizon(T)}.

%show statements
#show.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).




