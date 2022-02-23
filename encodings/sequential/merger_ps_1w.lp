% - plan merger encoding -----------------------------------------------------------------------
% plan switching plus waiting to avoid new conflicts

isRobot(R) :- position(R,_,_).
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
position_(R,C,T) :- final_position(R,C,T,_).

% show statements
#show.
#show position_/3.
%#show final_position/4.
