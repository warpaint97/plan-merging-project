% - plan merger encoding -----------------------------------------------------------------------
% implementing plan switching with choice rules


% CONSTANTS
% ----------------------------------------------------------------------------------------------
% to guarantee termination
time(0..3).
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

{intersect(R,R',T,FT,FT')}=1 :- final_position(R,C,T,_,_), position(R',C,FT), final_position(R',C',T,_,_), position(R,C',FT'), R!=R', isRobot(R), isRobot(R').
intersect(R',R,T,FT',FT) :- intersect(R,R',T,FT,FT').

% plan switch
final_position(R,C,T,FR',FT'+1) :- final_position(R,_,T-1,FR,_), position(FR',C,FT'+1), intersect(FR,FR',T-1,FT,FT'), time(T).
% follow assigned plan
final_position(R,C,T,FR,FT) :- final_position(R,_,T-1,FR,FT-1), position(FR,C,FT), not intersect(FR,_,T-1,_,_), time(T).
% ----------------------------------------------------------------------------------------------


% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
horizon(T_MAX) :- T_MAX == #max{T : final_position(R,C,T,FR,FT)}.

#minimize{T@1 : horizon(T)}.
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