% - plan merger encoding -----------------------------------------------------------------------
% Lets two robots switch goals, use as preprocessing


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
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T).
last_position(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,R,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
intersect(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.

not_early_intersect(R,R',C,T) :- intersect(R,R',C,T), intersect(R,R',C',T'), T>T'.

earliest_intersect(R,R',C,T) :- intersect(R,R',C,T), not not_early_intersect(R,R',C,T).

edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.
% fake edge collision
fake_edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C'.
overtake_edge_collision(R,R',T+1) :- last_position(R,C,T), position(R,C',T-1), position(R',C,T'), position(R',C',T'-1), R!=R', T'>=T.

collision(R,R',T) :- overtake_edge_collision(R,R',T).
collision(R,R',T) :- fake_edge_collision(R,R',T).
collision(R,R',T) :- edge_collision(R,R',T).




% for each pair of robots decide to swich or not.
{switch(R,R')} :- isRobot(R), isRobot(R'), collision(R,R',T).
switch(R',R) :- switch(R,R').

% find switching positions
switch(R,R',T,T'):- switch(R,R'), earliest_intersect(R,R',C,T), position(R',C,T').

% resolve multiple switches at the same time
recswitch(R,R',T,T'):- switch(R,R',T,T').
recswitch(R,R'',T,T''):- recswitch(R,R',T,T'), recswitch(R',R'',T',T'').
finalswitch(R,R',T,T'):- recswitch(R,R',T,T'), not recswitch(R',_,T',_), not recswitch(_,R,_,T) .

% RECURSION
% ----------------------------------------------------------------------------------------------
final_position(R,C',T+1,R',N+1) :- position(R',C',N+1), final_position(R,C,T,R',N), not finalswitch(R',_,N,_).
final_position(R,C',T+1,R'',D+1) :- finalswitch(R',R'',N,D), position(R'',C',D+1), final_position(R,C,T,R',N).
% ----------------------------------------------------------------------------------------------

% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% Switch twice, same pair.
:- switch(R,R',T,D), switch(R,R',T',D'), T'>T.

%no circles
:- recswitch(R,R,T,T'').

%reach all shelfs
last_final_position(R,C,N) :-final_position(R,C,T,R',N), not final_position(R,_,_,_,N+1).
last_position(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

:- last_position(R,C,T), not last_final_position(_,C,_).

% can't switch on removed steps
:- switch(R,R',T,D), switch(R',R,T',D'), switch(R,R'',T'',D''), T''>T, T''<=D'.

% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
%minimzing saved steps or number of final positions does the same thing for now.
%save_steps(T_later-T,R):- switch(R,R',T,T'_later), switch(R',R,T',T_later).
%#maximize{X@1,R : save_steps(X,R)}.

horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,X,Y)}.
#minimize{T@3 : horizon(T)}.

#minimize {1@1,T,R : final_position(R,C,T,R',D)}.

#minimize {1@2,R,T : final_overtake_edge_collision(R,R',T)}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_edge_collision(R,R',T+1) :- final_position(R,C,T,_,_), final_position(R,C',T+1,_,_), final_position(R',C',T,_,_), final_position(R',C,T+1,_,_), R!=R', C!=C'.
% fake edge collision
final_fake_edge_collision(R,R',T+1) :- final_position(R,C,T,_,_), final_position(R,C',T+2,_,_), final_position(R',C',T,_,_), final_position(R',C,T+2,_,_), R!=R', C!=C'.
final_overtake_edge_collision(R,R',T+1) :- last_final_position(R,C,T), final_position(R,C',T-1,_,_), final_position(R',C,T',_,_), final_position(R',C',T'-1,_,_), R!=R', T'>=T.


final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,X,Y), final_position(R,(C2X,C2Y),T+1,X',Y').



% show statements
#show.
%#show switch/4.
%#show recswitch/4.
%#show last_position/3.
%#show last_final_position/3.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
