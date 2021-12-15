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
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING WAITING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,R,0,1) :- position(R,C,0), isRobot(R).

% calculate the earliest switching spot
intersect(R,R',C,T) :- isRobot(R), isRobot(R'), position(R,C,T), position(R',C,T'), R!=R'.

not_early_intersect(R,R',C,T) :- intersect(R,R',C,T), intersect(R,R',C',T'), T>T'.

earliest_intersect(R,R',C,T) :- intersect(R,R',C,T), not not_early_intersect(R,R',C,T).

% for each pair of robots decide to swich or not.
{switch(R,R')} :- isRobot(R), isRobot(R').
switch(R',R) :- switch(R,R').

% find switching positions
switch(R,R',T,T'):- switch(R',R), earliest_intersect(R,R',C,T), position(R',C,T').


% create final positions recursively
final_position(R,C',T+1,R',N+1,1) :- position(R',C',N+1), final_position(R,C,T,R',N,1), not switch(R',_,N,_).
final_position(R,C',T+1,R'',D+1,1) :- switch(R',R'',N,D),not switch(R'',_,D,_), position(R'',C',D+1), final_position(R,C,T,R',N,_).
final_position(R,C,T,R'',D,0) :- switch(R',R'',N,D), switch(R'',R''',D,D'), final_position(R,C,T,R',N,_).
% ----------------------------------------------------------------------------------------------

% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% Switch twice, same pair.
:- switch(R,R',T,D), switch(R,R',T',D'), T'>T.

% Switch twice in one timestep.
%:- switch(R,R',T,D),switch(R',R'',T,D'), R!=R''.

% Switch to different robots in one timestep.
:- switch(R,R',T,D),switch(R,R'',T',D), R'!=R''.

% can't switch on removed steps
:- switch(R,R',T,D), switch(R',R,T',D'), switch(R,R'',T'',D''), T''>T, T''<D'.

% can't become same robot
:- switch(R,R',T,D), switch(R'',R',T',D), R!=R''.

% Exclusive switching
%:- switch(R,R'),switch(R,R''), R'!=R''.

%edge colision
:-final_position(R,C,T,B,D,K), final_position(R,C',T+1,B',D',K'), final_position(R',C',T,B'',D'',K''), final_position(R',C,T+1,B''',D''',K''').
% ----------------------------------------------------------------------------------------------


% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
%save_steps(T_later-T,R):- switch(R,R',T,T'_later), switch(R',R,T',T_later).
%#maximize{X@1,R : save_steps(X,R)}.

%optimizing for short paths is enough
horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,X,Y,K)}.
#minimize{T@2 : horizon(T)}.
#minimize {1@1,T,R : final_position(R,C,T,R',D,K)}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,X,Y,K), final_position(R,(C2X,C2Y),T+1,X',Y',K).

% show statements
#show.
%#show switch/4.
%#show final_position/6.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
