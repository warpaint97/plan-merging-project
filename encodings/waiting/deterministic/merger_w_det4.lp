% - plan merger encoding -----------------------------------------------------------------------
% make robots wait before a collsion so that the one with longest path ahead goes first.
% in case of same length the one with higher nuber goes first.
% this only works for groups of robots on overlapping paths oving in the sae direction.
% such a siplified proble can be created using plan switching.


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
% ----------------------------------------------------------------------------------------------

% GET INTERSECTS AND COLLISIONS OF ORIGINAL PLANS
% ----------------------------------------------------------------------------------------------
collision(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T), R!=R'.

not_early_collsion(R,R',C,T) :- collision(R,R',C,T), collision(R,R',C',T'), T>T'.

earliest_collision(R,R',C,T) :- collision(R,R',C,T), not not_early_collsion(R,R',C,T).

intersect(R,R',C,T,T') :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.

not_early_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), intersect(R,R',C',T',D'), T>T'.

earliest_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), not not_early_intersect(R,R',C,T,D).

not_last_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), intersect(R,R',C',T',D'), T<T'.

last_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), not not_last_intersect(R,R',C,T,D).

later_at_collision(R,R',C,T',T) :- earliest_collision(R',R'',C,T'), position(R,C,T), T>T'.
%at_collision(R,R',C,T) :- earliest_collision(A,B,C,T), position(R,C,T'), position(R',C,T'').

do_wait(R',T'+A'-1,T+A-T'-A') :- earliest_intersect(R,R',_,T,T'), not earliest_collision(R,R',_,_), waited_so_far(R,T,A), waited_so_far(R',T',A'), T<T', T+A>=T'+A'.
do_wait(R',C',T'+A'-1,1) :- intersect(R,R',C',T,T'), not earliest_collision(R,R',_,_), waited_so_far(R,T,A), waited_so_far(R',T'-1,A'), T<T',  T+A+1=T'+A', wait(R,C,T).

%not_early_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), intersect(R,R',C',T',D'), T>T'.

%earliest_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), not not_early_intersect(R,R',C,T,D).

%not_latest_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), intersect(R,R',C',T',D'), T<T'.

%latest_intersect(R,R',C,T,D) :- intersect(R,R',C,T,D), not not_latest_intersect (R,R',C,T,D).

% save last timestep for each robots to check priority
last_time(R,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

waited_so_far(R,0,0):- isRobot(R).

waited_so_far(R,T+1,A):- waited_so_far(R,T,A), position(R,_,T+1), not do_wait(R,_,T,_).

waited_so_far(R,T+1,A+B):- waited_so_far(R,T,A), position(R,_,T+1), do_wait(R,C,T,B).

% sort robots that collide
higher(R,R'):- earliest_collision(R,R',C,T), last_time(R,D), last_time(R',D'), D-T<D'-T.
higher(robot(A),robot(B)):- earliest_collision(robot(A),robot(B),C,T), last_time(robot(A),D), last_time(robot(B),D'), D-T=D'-T, A<B.


prio(R,C,T,A) :- earliest_collision(R,R'',C,T),  A == #count{1,R' : collision(R,R',C,T), higher(R,R')}.

new_robots_ahead(R,C,T,A) :- earliest_collision(R,R'',C,T),  A == #count{1,R' : earliest_collision(R,R',C,T), higher(R,R')}.

wait_for(R,C,T,W'-P'+B'+P) :- earliest_collision(R,R',C,T), prio(R',C,T,P'), prio(R,C,T,P) , new_robots_ahead(R',C,T,B'), waited_so_far(R',T-1,W'), P'<P.

not_wait_for(R,C,T,P) :- wait_for(R,C,T,P), wait_for(R,C,T,P'), P<P'.

% set number of waits before each collsion.
do_wait(R,C,T-1,A-W) :- waited_so_far(R,T-1,W), wait_for(R,C,T,A), not not_wait_for(R,C,T,A), A-W>=0.

do_wait(R,C,T-1,A-W) :- later_at_collision(R,R',C,T,T'), prio(R',C,T,P), not prio(_,C,T,P+1), waited_so_far(R',T,A), waited_so_far(R,T-1,W).

%wait(R',C,T..T+A-1) :- do_wait(R,C,T,A), synced(R,R').

%find waits that occur after next do_wait
overwait(R,T,T'):- do_wait(R,C,T,A), do_wait(R,C',T',A'), T'<T+A, T'>T.

overwait(R,T,T'):- do_wait(R,C,T,A), overwait(R,T'',T), do_wait(R,C,T',A'), T'<T+A+T-T'', T'>T.

%calclate waits
wait(R,C,T..T+A-1):- do_wait(R,C,T,A), not overwait(R,T,_), not overwait(R,_,T).

wait(R,C,T..T'-1):- do_wait(R,C,T,A), overwait(R,T,T').

wait(R,C,T..T+A+T-T'-1):- do_wait(R,C,T,A), overwait(R,T',T), not overwait(R,T,_).



% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,0) :- position(R,C,0), isRobot(R).
% create final positions recursively
% either wait at the same position
final_position(R,C,T+1,N+1) :- final_position(R,C,T,N), wait(R,_,T).
% or take the next step in plan
final_position(R,C',T+1,N) :- position(R,C',T-N+1), not wait(R,_,T), final_position(R,C,T,N).
% ----------------------------------------------------------------------------------------------


% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% vertex collision, as a fact for debugging
final_vertex(R,R',C,T):- final_position(R,C,T,N), final_position(R',C,T,N'), R!=R'.

% collision with a robot waiting at the shelf
%:- final_position(R,C,T_MAX,N), final_position(R',C,T',N'), R!=R', T'>=T_MAX, last_final_time(R,T_MAX).
% ----------------------------------------------------------------------------------------------

% REDUNDANT CONSTRAINTS FOR PERFORMANCE
% ----------------------------------------------------------------------------------------------
% deviation from plan
%:- final_position(R,C,T,N), not position(R,C,_).

% one robot can't be at different cells at the same time
%:- final_position(R,C,T,N), final_position(R,C',T,N'), C!=C'.
% ----------------------------------------------------------------------------------------------

% OPTIMIZATION
% ---------------------------------------------------------------------------------------------

%horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,N)}.
%#minimize{T@3 : horizon(T)}.

%#minimize {1@2,T,R : final_position(R,C,T,N)}.

%#minimize {1@1,R,T : wait(R,T)}.
% ----------------------------------------------------------------------------------------------

% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,N), final_position(R,(C2X,C2Y),T+1,N').

% show statements
#show.
%#show final_position/4.
%#show overwait/3.
#show do_wait/4.
%#show prio/4.
%#show wait_for/4.
%#show wait/3.
%#show waited_so_far/3.
%#show next/4.
#show final_vertex/4.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
