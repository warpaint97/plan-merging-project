% - plan merger encoding -----------------------------------------------------------------------
% plan switching plus waiting to avoid new conflicts

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
final_position(R,C,0,R) :- position(R,C,0), isRobot(R).

% create final positions recursively
edge_collision(R,R',T+1) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C'.

final_position(R,C,T,FR') :- final_position(R,C,T-1,FR), edge_collision(FR,FR',T).
final_position(R,C,T,R') :- final_position(R,_,T-1,R'), position(R',C,T), not edge_collision(R',_,T).
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T,_), final_position(R,(C2X,C2Y),T+1,_).

% show statements
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
%#show final_position/4.