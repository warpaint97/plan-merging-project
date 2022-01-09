% - plan merger encoding -----------------------------------------------------------------------
% implementing a plan switching method for robots of which are involved in an edge collision conflict


% CONSTANTS
% ----------------------------------------------------------------------------------------------
% to guarantee termination
#const max_layers=20.
layer(0..max_layers-2).
% ----------------------------------------------------------------------------------------------


% READING INSTANCE
% ----------------------------------------------------------------------------------------------
#include "./input_layers.lp".
% ----------------------------------------------------------------------------------------------


% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

%calculate original positions recursively
position(R,(X+DX,Y+DY),T+1,0) :- move(R,(DX,DY),T), position(R,(X,Y),T,0).
% ----------------------------------------------------------------------------------------------


% EDGE COLLISION
% ----------------------------------------------------------------------------------------------
edge_collision(R,R',T,L) :- position(R,C,T-1,L), position(R,C',T,L), position(R',C',T-1,L), position(R',C,T,L), R!=R', C!=C'.
% ----------------------------------------------------------------------------------------------


% CONFLICT RESOLUTION
% ----------------------------------------------------------------------------------------------
% reconstruct positions and incorporate plan switching
%before edge collision
position(R,C,T,L+1) :- position(R,C,T,L), edge_collision(R,_,T_SWITCH,L), T<T_SWITCH, layer(L).
%after edge collision
position(R,C,T,L+1) :- position(R',C,T+1,L), edge_collision(R,R',T_SWITCH,L), T>=T_SWITCH, layer(L).


% copy positions into new layer for unaffected robots
switched_plan(R,L) :- edge_collision(R,R',_,L).

conflict(R,L) :- switched_plan(R,L).
conflict(L) :- switched_plan(_,L).
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