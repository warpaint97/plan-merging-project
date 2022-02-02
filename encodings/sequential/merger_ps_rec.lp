% CALCULATE FINAL POSITIONS
% ----------------------------------------------------------------------------------------------
isRobot(R) :- position(R,_,_).

% set first final_position for recursion
final_position(R,C,0,R,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
intersect(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.

not_early_intersect(R,R',C,T) :- intersect(R,R',C,T), intersect(R,R',C',T'), T>T'.

earliest_intersect(R,R',C,T) :- intersect(R,R',C,T), not not_early_intersect(R,R',C,T).

edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.
% fake edge collision
edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C'.
edge_collision(R,R',T) :- last_position(R,C,T), position(R',C,T), R!=R'.


% for each pair of robots decide to swich or not.
{switch(R,R')} :- isRobot(R), isRobot(R'), edge_collision(R,R',T).
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

% can't switch on removed steps
:- finalswitch(R,R',T,D), finalswitch(R',R,T',D'), finalswitch(R,R'',T'',D''), T''>T, T''<D'.

%reach all shelfs
last_final_position(R,C,N) :-final_position(R,C,T,R',N), not final_position(R,_,_,_,N+1).
last_position(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

:- last_position(R,C,T), not last_final_position(_,C,_).


% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
%minimzing saved steps or number of final positions does the same thing for now.
%save_steps(T_later-T,R):- switch(R,R',T,T'_later), switch(R',R,T',T_later).
%#maximize{X@1,R : save_steps(X,R)}.

horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,X,Y)}.
#minimize{T@3 : horizon(T)}.

#minimize {1@2,T,R : final_position(R,C,T,R',D)}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------

% show statements
#show.
%#show switch/4.
%#show recswitch/4.
%#show last_position/3.
%#show last_final_position/3.
#show position_(robot(R),D,T) : final_position(robot(R),D,T,R',D').
%#show edge_collision/3.
