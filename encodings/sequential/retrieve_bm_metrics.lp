% - VALIDITY CHECKER ---------------------------------------------------------------------------
% check validity of the merged plans

% INPUT
% ----------------------------------------------------------------------------------------------
#include "./input.lp".
% ----------------------------------------------------------------------------------------------


% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading plans
move(robot(R),(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).

% calculate original positions recursively
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T), isRobot(R).
destination(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).
% ----------------------------------------------------------------------------------------------


% RETRIEVE METRICS
% ----------------------------------------------------------------------------------------------
% robots
n_r(R) :- isRobot(R).
% positions
n_p(R,C,T) :- position(R,C,T), isRobot(R).
% longest path
n_lp(0..T_MAX) :- T_MAX == #max{T : position(R,C,T)}.
% edge collision
n_ec(C,C',T) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C', isRobot(R), isRobot(R').
r_ec(R) :- position(R,C,T), position(R,C',T+1), position(R',C',T), position(R',C,T+1), R!=R', C!=C', isRobot(R), isRobot(R').
% vertex collision
n_vc(C,T) :- position(R,C,T), position(R',C,T), R!=R', isRobot(R), isRobot(R').
r_vc(R) :- position(R,C,T), position(R',C,T), R!=R', isRobot(R), isRobot(R').
% vertex collisions with arrived robots
n_vc(C,T) :- position(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R', isRobot(R), isRobot(R').
r_vc(R,R',T) :- position(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R', isRobot(R), isRobot(R').
% fake edge collision
n_fec(C,C',T) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C', isRobot(R), isRobot(R').
r_fec(R) :- position(R,C,T), position(R,C',T+2), position(R',C',T), position(R',C,T+2), R!=R', C!=C', isRobot(R), isRobot(R').
% ----------------------------------------------------------------------------------------------


% OUTPUT
% ----------------------------------------------------------------------------------------------
#show.
#show n_p/3.
#show n_lp/1.
#show n_ec/3.
#show r_ec/1.
#show n_vc/2.
#show r_vc/1.
#show n_r/1.
#show n_fec/3.
#show r_fec/1.
% ----------------------------------------------------------------------------------------------
