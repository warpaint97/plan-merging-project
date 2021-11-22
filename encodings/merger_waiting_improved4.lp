% - plan merger encoding -----------------------------------------------------------------------
% implementing a waiting statement for robots of lower priority in the case of a vertex conflict


% CONSTANTS
% ----------------------------------------------------------------------------------------------
% to guarantee termination
#const max_layers=20.
layer(0..max_layers-2).
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
position(R,(X+DX,Y+DY),T,0) :- move(R,(DX,DY),T), position(R,(X,Y),T-1,0).
% ----------------------------------------------------------------------------------------------


% VERTEX COLLISION
% ----------------------------------------------------------------------------------------------
vertex_collision(C,T,L) :- position(R,C,T,L), position(R',C,T,L), R!=R'.
not_first_vertex_collision(T,L) :- vertex_collision(C,T,L), vertex_collision(C',T',L), T>T'.
first_vertex_collision(T,L) :- not not_first_vertex_collision(T,L), vertex_collision(C,T,L).

% all but highest priority robot wait unless already waited before
wait(R,T,L) :- first_vertex_collision(T,L), position(R,C,T,L), position(R',C,T,L), R>R',
               not wait(R,T,L-1).
% highest priority robot will wait if other robot is already waiting before
wait(R,T,L) :- first_vertex_collision(T,L), position(R,C,T,L), position(R',C,T,L), R!=R',
               wait(R',T,L-1).
% ----------------------------------------------------------------------------------------------


% CONFLICT RESOLUTION
% ----------------------------------------------------------------------------------------------
% reconstruct positions and incorporate waiting
%before wait
position(R,C,T,L+1) :- position(R,C,T,L), wait(R,T_WAIT,L), T<T_WAIT, layer(L).
%after wait
position(R,C,T,L+1) :- position(R,C,T-1,L), wait(R,T_WAIT,L), T>=T_WAIT, layer(L).


% copy positions into new layer for unaffected robots
waited(R,L) :- wait(R,_T,L).

conflict(R,L) :- waited(R,L).
conflict(L) :- waited(_R,L).
position(R,C,T,L+1) :- position(R,C,T,L), conflict(L), not conflict(R,L), layer(L).
% ----------------------------------------------------------------------------------------------


% FINALIZING PLANS
% ----------------------------------------------------------------------------------------------
% determine the top layer
top_layer(L_TOP-1) :- L_TOP == #count{L : position(robot(1),_C,_T,L)}.

% final plan
final_position(R,C,T) :- position(R,C,T,L), top_layer(L).
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T), final_position(R,(C2X,C2Y),T+1).
% ----------------------------------------------------------------------------------------------


% OUTPUT PLAN
% ----------------------------------------------------------------------------------------------
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
% ----------------------------------------------------------------------------------------------