% - plan merger encoding -----------------------------------------------------------------------
% allow robots to wait or follow plan using choice rules and count the number of waits


% CONSTANTS
% ----------------------------------------------------------------------------------------------
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
position(R,(X+DX,Y+DY),T) :- move(R,(DX,DY),T), position(R,(X,Y),T-1).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,R,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
switch_pos(robot(X),robot(Y),T,T',T_later,T'_later) :-   position(robot(X),C,T), position(robot(Y),C,T'_later),
																												 position(robot(X),C',T_later), position(robot(Y),C',T'),
																												 X>Y,
																												 T_later>T,T'_later>T'.

not_best_switch_pos(R,R',T,T',T_later,T'_later) :-  switch_pos(R,R',T,T',T_later,T'_later),
																										switch_pos(R,R',D,D',D_later,D'_later),
																										T'>D',T>D,
																										T_later>D_later,T'_later>D'_later.

best_switch_pos(R,R',T,T',T_later,T'_later) :- switch_pos(R,R',T,T',T_later,T'_later), not not_best_switch_pos(R,R',T,T',T_later,T'_later).

% for each pair of robots decide to swich at a best position or not.
{switch(R,R',T,T'later): best_switch_pos(R,R',T,T',T_later,T'later)} :- isRobot(R), isRobot(R').
switch(R',R,T',T_later) :- switch(R,R',T,T'_later), best_switch_pos(R,R',T,T',T_later,T'later).

% create final positions recursively
%final_position(R,C',T+1,R',N+1) :- position(R',C',N+1), final_position(R,C,T,R',N), not switch(R',_,N,_).
%final_position(R,C',T+1,R'',D+1) :- switch(R',R'',N,D), position(R'',C',D+1), final_position(R,C,T,R',N).
% ----------------------------------------------------------------------------------------------


% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% Switch twice, same pair.
:- switch(R,R',T,D), switch(R,R',T',D'), T'>T.

% Switch twice in one timestep.
:- switch(R,R',T,D),switch(R',R'',T,D'), R!=R''.

% Exclusive switching
:- switch(R,R',T,D),switch(R,R'',T',D'), R'!=R''.
% ----------------------------------------------------------------------------------------------


% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
save_steps(T_later-T,R):- switch(R,R',T,T'_later), switch(R',R,T',T_later).
#maximize{X,R : save_steps(X,R)}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T+1) :- final_position(R,(C1X,C1Y),T,X,Y), final_position(R,(C2X,C2Y),T+1,X',Y').

% show statements
#show.
#show best_switch_pos/6.
#show switch/4.
%#show final_position/5.
%#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
