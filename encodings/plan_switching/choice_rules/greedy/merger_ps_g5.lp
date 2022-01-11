% - plan merger encoding -----------------------------------------------------------------------
% Lets two robots switch goals. Currently not ble to resolve all edge collisions

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


% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,R,0) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
intersect(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.

not_early_intersect(R,R',C,T) :- intersect(R,R',C,T), intersect(R,R',C',T'), T>T'.

earliest_intersect(R,R',C,T) :- intersect(R,R',C,T), not not_early_intersect(R,R',C,T).

%edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.
% fake edge collision
%edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C'.


% for each pair of robots decide to swich or not.
{switch(R,R')} :- isRobot(R), isRobot(R').
% optional, only allowed to switch when there is an edge collision. makes it faster.
% {switch(R,R')} :- isRobot(R), isRobot(R'), edge_collision(R,R',T).

switch(R',R) :- switch(R,R').

% find switching positions
switch(R,R',T,T'):- switch(R',R), earliest_intersect(R,R',C,T), position(R',C,T').

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
