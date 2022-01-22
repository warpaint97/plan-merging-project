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

% FIND WAITING POSITIONS
% ----------------------------------------------------------------------------------------------
collision(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T), R!=R'.

not_early_collsion(R,R',C,T) :- collision(R,R',C,T), collision(R,R',C',T'), T>T'.

earliest_collision(R,R',C,T) :- collision(R,R',C,T), not not_early_collsion(R,R',C,T).

% save last timestep for each robots to check priority
last_time(R,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

% sort robots that collide
higher(R,R'):- earliest_collision(R,R',C,T), last_time(R,D), last_time(R',D'), D-T<D'-T.
higher(robot(A),robot(B)):- earliest_collision(robot(A),robot(B),C,T), last_time(robot(A),D), last_time(robot(B),D'), D-T=D'-T, A<B.

% set number of waits before each collsion. Transfer waits to next collsion if they would overlap
do_wait(R,C,T-1,A) :- A == #count{1,R' : earliest_collision(R,R',C,T), higher(R,R')}, earliest_collision(R,R'',C,T).

do_wait(R,C,T-1,A) :- A == #count{1,R''' : earliest_collision(R',R''',C,T)}, earliest_collision(R',R'',C,T), position(R,C,T'), T<T', R!=R'.

overwait(R,T,T'):- do_wait(R,C,T,A), do_wait(R,C',T',A'), T'<T+A, T'>T.

wait(R,C,T..T+A-1):- do_wait(R,C,T,A), not overwait(R,T,_), not overwait(R,_,T).

wait(R,C,T..T'-1):- do_wait(R,C,T,A), overwait(R,T,T').

wait(R,C,T..T+A+T-T'-1):- do_wait(R,C,T,A), overwait(R,T',T), not overwait(R,T,_).

overwait(R,T,T'):- do_wait(R,C,T,A), overwait(R,T'',T), do_wait(R,C,T',A'), T'<T+A+T-T'', T'>T.

wait(R',C',T):- wait(R,C,T), position(R',C',T+1), position(R',C'',T), position(R,C,T+1), position(R,C',T).

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
%#show init/2.
%#show final_position/4.
%#show overwait/3.
%#show wait/3.
%#show higher/2.
%#show final_vertex/4.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
