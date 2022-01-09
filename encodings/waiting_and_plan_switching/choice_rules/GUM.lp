% - plan merger encoding -----------------------------------------------------------------------
% grand unified merger (plan switching and waiting with choice rules)


% CONSTANTS
% ----------------------------------------------------------------------------------------------
% to guarantee termination
#const max_waits=20.
% ----------------------------------------------------------------------------------------------


% READING INSTANCE
% ----------------------------------------------------------------------------------------------
#include "./input.lp".
% ----------------------------------------------------------------------------------------------


% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).
% calculate original positions recursively
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS FOR PLAN SWITCHING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,R,0,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
intersect(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.
not_early_intersect(R,R',C,T) :- intersect(R,R',C,T), intersect(R,R',C',T'), T>T'.
earliest_intersect(R,R',C,T) :- intersect(R,R',C,T), not not_early_intersect(R,R',C,T).
% for each pair of robots decide to switch or not.
{switch(R,R')} :- isRobot(R), isRobot(R').
switch(R',R) :- switch(R,R').
% find switching positions
switch(R,R',T,T'):- switch(R',R), earliest_intersect(R,R',C,T), position(R',C,T').


% create final positions recursively
% either wait at the same position
{final_position(R,C,T+1,R',T',N+1)} :- final_position(R,C,T,R',T',N), position(R',C',T'+1), N<max_waits, not switch(R',_,T',_).
% or take the next step in plan
final_position(R,C',T+1,R',T'+1,N) :- position(R',C',T'+1), final_position(R,C,T,R',T',N), not final_position(R,C,T+1,R',T',N+1), not switch(R',_,T',_).

% not switching
%final_position(R,C',T+1,R',T'+1) :- position(R',C',T'+1), final_position(R,C,T,R',T'), not switch(R',_,T',_).
% switching
final_position(R,C',T+1,R'',T''+1,N) :- switch(R',R'',T',T''), position(R'',C',T''+1), final_position(R,C,T,R',T',N).
% ----------------------------------------------------------------------------------------------


% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% Switch twice, same pair.
:- switch(R,R',T,D), switch(R,R',T',D'), T'>T.
% Switch twice in one timestep.
:- switch(R,R',T,D),switch(R',R'',T,D'), R!=R''.
% Switch to different robots in one timestep.
:- switch(R,R',T,D),switch(R,R'',T,D'), R'!=R''.
% can't switch on removed steps
:- switch(R,R',T,D), switch(R',R,T',D'), switch(R,R'',T'',D''), T''>T, T''<=D'.
% Exclusive switching
%:- switch(R,R'),switch(R,R''), R'!=R''.
% edge collision
:- final_position(R,C,T,B,D,N), final_position(R,C',T+1,B',D',N'), final_position(R',C',T,B'',D'',N''), final_position(R',C,T+1,B''',D''',N'''), R!=R', C!=C'.
% vertex collision
:- final_position(R,C,T,B,D,N), final_position(R',C,T,B',D',N'), R!=R'.
% find last time step per robot.
max_time(R,T_MAX):- T_MAX == #max{T : final_position(R,C,T,X,Y,Z)}, isRobot(R).
% collision with a robot waiting at the shelf
:- final_position(R,C,T_MAX,X,Y,Z), final_position(R',C,T',X',Y',Z'), R!=R', T'>=T_MAX, max_time(R,T_MAX).
% ----------------------------------------------------------------------------------------------

% REDUNDANT CONSTRAINTS FOR PERFORMANCE
% ----------------------------------------------------------------------------------------------
% deviation from plan
:- final_position(R,C,T,R',Y,Z), not position(R',C,_).
% one robot can't be at different cells at the same time
:- final_position(R,C,T,X,Y,Z), final_position(R,C',T,X',Y',Z'), C!=C'.
% ----------------------------------------------------------------------------------------------



% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
save_steps(T_later-T,R):- switch(R,R',T,T'_later), switch(R',R,T',T_later).
#maximize{X@1,R : save_steps(X,R)}.
#minimize {1@2,T,R : final_position(R,C,T,X,Y,Z)}.
horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,X,Y,Z)}.
#minimize{T@3 : horizon(T)}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,X,Y,Z), final_position(R,(C2X,C2Y),T+1,X',Y',Z').

% show statements
#show.
%#show switch/4.
%#show final_position/6.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
