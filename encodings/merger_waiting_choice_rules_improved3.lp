% - plan merger encoding -----------------------------------------------------------------------
% allow robots to wait or follow plan using choice rules and count the number of waits


% CONSTANTS
% ----------------------------------------------------------------------------------------------
% to guarantee termination
#const max_waits=20.
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
final_position(R,C,0,0) :- position(R,C,0), isRobot(R).

% create final positions recursively
% either wait at the same position
{final_position(R,C,T+1,N+1)} :- final_position(R,C,T,N), position(R,C',T-N+1), N<max_waits.
% or take the next step in plan
final_position(R,C',T+1,N) :- position(R,C',T-N+1), not final_position(R,C,T+1,N+1), final_position(R,C,T,N).
% ----------------------------------------------------------------------------------------------


% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% vertex collision
:- final_position(R,C,T,N), final_position(R',C,T,N'), R!=R'.

% find last time step per robot.
max_time(R,T_MAX):- T_MAX == #max{T : final_position(R,C,T,N)}, isRobot(R).

% collision with a robot waiting at the shelf
:- final_position(R,C,T_MAX,N), final_position(R',C,T',N'), R!=R', T'>=T_MAX, max_time(R,T_MAX).
% ----------------------------------------------------------------------------------------------


% REDUNDANT CONSTRAINTS FOR PERFORMANCE
% ----------------------------------------------------------------------------------------------
% deviation from plan
:- final_position(R,C,T,N), not position(R,C,_).

% one robot can't be at different cells at the same time
:- final_position(R,C,T,N), final_position(R,C',T,N'), C!=C'.
% ----------------------------------------------------------------------------------------------


% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,N)}.

%#minimize{T@1 : horizon(T)}.
#minimize {1@1,T,R : final_position(R,C,T,N)}.
#minimize{T@2 : horizon(T)}.
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,N), final_position(R,(C2X,C2Y),T+1,N').

% show statements
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
