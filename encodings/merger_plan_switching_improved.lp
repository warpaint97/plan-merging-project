% - plan merger encoding -----------------------------------------------------------------------
% implementing a plan switching method for robots of which are involved in an edge collision conflict


% CONSTANTS
% ----------------------------------------------------------------------------------------------
% to guarantee termination
#const max_switches=10.
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
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T).
% ----------------------------------------------------------------------------------------------


% CALCULATE FINAL POSITIONS INCLUDING PLAN SWITCHING
% ----------------------------------------------------------------------------------------------
% set first final_position for recursion
final_position(R,C,0,R,0) :- position(R,C,0), isRobot(R).

% create final positions recursively

edge_collision(R,R',T) :- final_position(R,C,T,FR,N), position(FR,C',T+N+1), final_position(R',C',T,FR',N'), position(FR',C,T+N'+1), R!=R', C!=C'.

final_position(R,C,T+1,FR,N+1) :- final_position(R,_,T,_,_), final_position(R',_,T,FR,N), position(FR,C,T+N+2), edge_collision(R,R',T), N<max_switches.
final_position(R,C,T+1,R',N) :- final_position(R,_,T,R',N), position(R',C,T+N+1), not edge_collision(R,_,T).
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,_,_), final_position(R,(C2X,C2Y),T+1,_,_).

% show statements
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
%#show final_position/5.