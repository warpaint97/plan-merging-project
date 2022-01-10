% - plan merger encoding -----------------------------------------------------------------------
% plan switching at first possible intersection

% READING INSTANCE
% ----------------------------------------------------------------------------------------------
#include "./input.lp".
% ----------------------------------------------------------------------------------------------


% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

%calculate original positions recursively
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING PLAN SWITCHING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
position(R,C,0,R,0,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
intersect(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.
not_early_intersect(R,R',C,T) :- intersect(R,R',C,T), intersect(R,R',C',T'), T>T'.
earliest_intersect(R,R',C,T) :- intersect(R,R',C,T), not not_early_intersect(R,R',C,T).

edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.
% fake edge collision
edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C'.

% find switching positions
{switch(R,R',T,T',L)} :- edge_collision(R',R,T'',L), earliest_intersect(R,R',C,T,L), position(R',C,T').
switch(R',R,T,T') :- switch(R,R',T'',T''',L), earliest_intersect(R',R,C,T,L), position(R,C,T').

:- switch(R,R',T,T',L), switch(R,R''',T'',T''',L).
:- switch(R',R,T,T',L), switch(R'',R,T'',T''',L).

layer(R,L,D) :- switch(R,R',T,T',L).

final_position(R,C',T+1,R',N+1) :- position(R',C',N+1), final_position(R,C,T,R',N), not switch(R',_,N,_).
final_position(R,C',T+1,R'',D+1) :- switch(R',R'',N,D), position(R'',C',D+1), final_position(R,C,T,R',N).
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,X,Y), final_position(R,(C2X,C2Y),T+1,X',Y').

% show statements
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
%#show switch/4.
