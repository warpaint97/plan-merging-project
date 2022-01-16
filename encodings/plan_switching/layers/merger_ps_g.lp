% - plan merger encoding -----------------------------------------------------------------------
% plan switching at first possible intersection

% READING INSTANCE
% ----------------------------------------------------------------------------------------------
#include "./input_layers.lp".
% ----------------------------------------------------------------------------------------------

#const max_layers = 3.
layer(0..max_layers).

% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

%calculate original positions recursively
position(R,(X+DX,Y+DY),T+1,0) :- move(R,(DX,DY),T), position(R,(X,Y),T,0).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING PLAN SWITCHING
% ----------------------------------------------------------------------------------------------
edge_collision(R,R',T,L) :- position(R,C,T,L), position(R,C',T+1,L), position(R',C',T,L), position(R',C,T+1,L), R!=R', C!=C'.
% fake edge collision
edge_collision(R,R',T,L) :- position(R,C,T,L), position(R,C',T+2,L), position(R',C',T,L), position(R',C,T+2,L), R!=R', C!=C'.
%first edge_collision
earliest_edge_collision(R,R',T_MIN,L) :- T_MIN == #min{T : edge_collision(_,_,T,L)}, edge_collision(R,R',T_MIN,L).

% calculate the earliest switching spot
intersect(R,R',C,T,L) :- earliest_edge_collision(R,R',_,L), position(R,C,T,L), position(R',C,T',L), R!=R'.
not_early_intersect(R,R',C,T,L) :- intersect(R,R',C,T,L), intersect(R,R',C',T',L), T>T'.
earliest_intersect(R,R',C,T,L) :- intersect(R,R',C,T,L), not not_early_intersect(R,R',C,T,L).

% find switching positions
switch(R,R',T,T',L) :- earliest_edge_collision(R',R,T'',L), earliest_intersect(R,R',C,T,L), position(R',C,T',L).

%before switch
position(R,C,T,L+1) :- position(R,C,T,L), switch(R,_,T_SWITCH,_,L), T<T_SWITCH, layer(L).
%after switch
position(R,C,T,L+1) :- position(R,C',T,L), position(R',C,T+T_NEW-T_SWITCH,L), switch(R,R',T_SWITCH,T_NEW,L), T>=T_SWITCH, layer(L).
%copy old positions into new layer
position(R,C,T,L+1) :- position(R,C,T,L), earliest_edge_collision(_,_,_,L), not earliest_edge_collision(R,_,_,L), layer(L).
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% determine the top layer
top_layer(L_TOP-1) :- L_TOP == #count{L : position(robot(1),_C,_T,L)}.

% final plan
final_position(R,C,T) :- position(R,C,T,L), top_layer(L).
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T), final_position(R,(C2X,C2Y),T+1).

% show statements
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
%#show earliest_edge_collision/4.
