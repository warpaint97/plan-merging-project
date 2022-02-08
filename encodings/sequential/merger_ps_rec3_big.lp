% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
isRobot(R) :- position(R,_,_).

% set first final_position for recursion
final_position(R,C,0,R,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
intersect(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.

%not_early_intersect(R,R',C,T) :- intersect(R,R',C,T), intersect(R,R',C',T'), T>T'.

%earliest_intersect(R,R',C,T) :- intersect(R,R',C,T), not not_early_intersect(R,R',C,T).

%edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.
% fake edge collision
%fake_edge_collision(R,R',T) :- position(R,C,T), position(R,C',T+1), position(R',C',T-1), position(R',C,T), R!=R', C!=C'.
%ake_edge_collision(R,R',T) :- position(R,C,T), position(R',C',T+1), position(R,C',T-1), position(R',C,T), R!=R', C!=C'.
edge_collision_possible(R,R',T) :- intersect(R,R',C,T), intersect(R,R',C',T+1), position(R',C',T'), position(R',C,T'+1).

overtake_edge_collision(R,R',T,T') :- last_position(R,C,T), position(R',C,T'), R!=R', T'>T.

initial_intersect(R,R',C,T):- intersect(R,R',C,T), not intersect(R,R',_,T-1).

not_intersect_before_collision(R,R',C,T) :- edge_collision_possible(R,R',T'), initial_intersect(R,R',C,T), T<T',initial_intersect(R,R',_,T''), T''<=T', T<T''.

intersect_before_collision(R,R',C,T) :- edge_collision_possible(R,R',T'), initial_intersect(R,R',C,T), T<=T', not not_intersect_before_collision(R,R',C,T).

collision(R,R',T) :- edge_collision_possible(R,R',T).


{switch(R,R',T,T')}:- overtake_edge_collision(R,R',T,T').
switch(R',R,T',T):- overtake_edge_collision(R,R',T,T'), switch(R,R',T,T').

% for each pair of robots decide to swich or not.
{switch(R,R')} :- isRobot(R), isRobot(R'), collision(R,R',T).
switch(R',R) :- switch(R,R').

% find switching positions
switch(R,R',T,T'):- switch(R,R'), intersect_before_collision(R,R',C,T), position(R',C,T').

% resolve multiple switches at the same time
%recswitch(R,R',T,T'):- switch(R,R',T,T').
%recswitch(R,R'',T,T''):- recswitch(R,R',T,T'), recswitch(R',R'',T',T'').
%finalswitch(R,R',T,T'):- recswitch(R,R',T,T'), not recswitch(R',_,T',_), not recswitch(_,R,_,T) .

% RECURSION
% ----------------------------------------------------------------------------------------------
final_position(R,C',T+1,R',N+1) :- position(R',C',N+1), final_position(R,C,T,R',N), not switch(R',_,N,_).
final_position(R,C',T+1,R'',D+1) :- switch(R',R'',N,D), position(R'',C',D+1), final_position(R,C,T,R',N).
% ----------------------------------------------------------------------------------------------

% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% Switch twice, same pair.
:- switch(R,R',T,D), switch(R,R',T',D'), T'>T.

%exclusive switching
:- switch(R,R'), switch(R,R''), R'!=R''.

%no circle
%:- recswitch(R,R,T,T'').

%switch to different robots at the same time
:- switch(R,R',T,D), switch(R,R'',T,D'), R'!=R''.

%reach all shelfs
last_final_position(R,C,T) :-final_position(R,C,T,R',N), not final_position(R,_,T+1,_,_).
last_position(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

:- last_position(R,C,T), not last_final_position(_,C,_).

% can't switch on removed steps
:- switch(R,R',T,D), switch(R',R,T',D'), switch(R,R'',T'',D''), T''>T, T''<=D'.
% OPTIMIZATION
% ---------------------------------------------------------------------------------------------

horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,X,Y)}.
%#minimize{T@3 : horizon(T)}.

#minimize {1@4,T,R : final_move(R,C,T)}.

#minimize {1@1,R,R' : final_collision(R,R',T)}.

#minimize {1@3,R,R' : final_overtake_edge_collision(R,R',T,T'), overtake_edge_collision(R,R',T,T')}.

#minimize {1@2,R,R' : final_overtake_edge_collision(R,R',T,T')}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_intersect(R,R',C,T) :- isRobot(R), isRobot(R'), final_position(R,C,T,_,_), final_position(R',C,T',_,_), R!=R'.

%final_edge_collision(R,R',T+1) :- final_position(R,C,T,_,_), final_position(R,C',T+1,_,_), final_position(R',C',T,_,_), final_position(R',C,T+1,_,_), R!=R', C!=C'.

final_edge_collision_possible(R,R',T+1) :- final_intersect(R,R',C,T), final_intersect(R,R',C',T+1), final_position(R',C',T',_,_), final_position(R',C,T'+1,_,_), R!=R', C!=C'.
% fake edge collision
%final_fake_edge_collision(R,R',T) :- final_position(R,C,T,_,_), final_position(R,C',T+1,_,_), final_position(R',C',T-1,_,_), final_position(R',C,T,_,_), R!=R', C!=C'.
%final_fake_edge_collision(R,R',T) :- final_position(R,C,T,_,_), final_position(R',C',T+1,_,_), final_position(R,C',T-1,_,_), final_position(R',C,T,_,_), R!=R', C!=C'.

final_collision(R,R',T) :- final_edge_collision_possible(R,R',T).



final_overtake_edge_collision(R,R',T,T') :- last_final_position(R,C,T), final_position(R',C,T',_,_), R!=R', T'>T.

position_(R,C,T) :- final_position(R,C,T,X,Y).

% show statements
#show.
%#show collision/3.
%#show overtake_edge_collision/4.
%#show earliest_intersect/4.
%#show switch/4.
%#show recswitch/4.
%#show last_position/3.
%#show last_final_position/3.
%#show final_edge_collision/3.
%#show final_fake_edge_collision/3.
%#show overtake_edge_collision/4.
%#show final_overtake_edge_collision/4.
%#show final_position/5.
#show position_/3.
