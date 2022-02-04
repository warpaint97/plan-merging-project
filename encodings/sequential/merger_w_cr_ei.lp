%init
isRobot(R) :- position(R,_,_).
destination(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

% find times for waitable positions
waitable(R,T) :- position(R,C,T+1), position(R',C,T'), R!=R'.
not_earliest_waitable(R,T) :- waitable(R,T), waitable(R,T'), T>T'.
earliest_waitable(R,T) :- not not_earliest_waitable(R,T), waitable(R,T).

% how often should the robot wait at his earliest intersect position
steps(R,T_MAX-1) :- T_MAX == #count{T : position(R,C,T)}, isRobot(R).
seq(0..T_MAX) :- T_MAX == #max{T : steps(R,T)}.
1{wait(R,N) : seq(N)}1 :- isRobot(R).

% reconstruct positions
time(R,0..T_MAX+N) :- steps(R,T_MAX), isRobot(R), wait(R,N).
% before wait
position_(R,C,T) :- earliest_waitable(R,T_WAIT), T<=T_WAIT, position(R,C,T), time(R,T).
% during wait
position_(R,C,T) :- earliest_waitable(R,T_WAIT), wait(R,N), T>T_WAIT, T<=T_WAIT+N, position(R,C,T_WAIT), time(R,T).
% after wait
position_(R,C,T) :- earliest_waitable(R,T_WAIT), wait(R,N), T>T_WAIT+N, position(R,C,T-N), time(R,T).
% if there no waitable position
has_waitable(R) :- earliest_waitable(R,T).
position_(R,C,T) :- not has_waitable(R), position(R,C,T).

% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% remove vertex collisions
:- position_(R,C,T), position_(R',C,T), R!=R'.
% remove edge collision
:- position_(R,C,T), position_(R,C',T+1), position_(R',C',T), position_(R',C,T+1), R!=R', C!=C'.
% remove vertex collisions with arrived robots
:- position_(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R'.
% ----------------------------------------------------------------------------------------------

% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
#minimize {1@1,R,T : position_(R,C,T)}.
horizon(T_MAX) :- T_MAX == #max{T : position_(R,C,T)}.
#minimize{T@2 : horizon(T)}.
% ----------------------------------------------------------------------------------------------

% show statements
#show.
#show position_/3.
