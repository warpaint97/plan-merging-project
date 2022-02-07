% - waiter sequential -----------------------------------------------------------------------

% init
isRobot(R) :- position(R,_,_).
destination(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

% find times for waitable positions
waitable(R,R',T) :- position(R,C,T+1), position(R',C,T'), R!=R'.
not_earliest_waitable(R,R',T) :- waitable(R,R',T), waitable(R,R',T'), T>T'.
earliest_waitable(R,R',T) :- not not_earliest_waitable(R,R',T), waitable(R,R',T).
% either wait at one waitable timestep or don't
{wait(R,T) : earliest_waitable(R,_,T)}1 :- isRobot(R).

% reconstruct positions
% before wait
position_(R,C,T) :- wait(R,T_WAIT), T<=T_WAIT, position(R,C,T).
% after wait
position_(R,C,T) :- wait(R,T_WAIT), T>T_WAIT, position(R,C,T-1).
% keep positions if no wait
wait(R) :- wait(R,T).
position_(R,C,T) :- not wait(R), position(R,C,T).

% find new vertex collisions
vertex_collision(R,C,T) :- position_(R,C,T), position_(R',C,T), R!=R'.
%n_vc(N,C,T) :- N == #count{R : vertex_collision()}.
%collision(R,R',C,T) :- isRobot(R), isRobot(R'), position_(R,C,T), position_(R',C,T), R!=R'.
%not_early_collsion(R,R',C,T) :- collision(R,R',C,T), collision(R,R',C',T'), T>T'.
%earliest_collision(R,R',C,T) :- collision(R,R',C,T), not not_early_collsion(R,R',C,T).

% INTEGRITY CONSTRAINTS
% ----------------------------------------------------------------------------------------------
% remove new edge collision
:- position_(R,C,T), position_(R,C',T+1), position_(R',C',T), position_(R',C,T+1), R!=R', C!=C'.
% remove new fake edge collision
:- position_(R,C,T), position_(R,C',T+2), position_(R',C',T), position_(R',C,T+2), R!=R', C!=C'.
% remove new vertex collisions with arrived robots
:- position_(R,C,T), destination(R',C,T_DEST), T>T_DEST, R!=R'.
% ----------------------------------------------------------------------------------------------

% OPTIMIZATION
% ---------------------------------------------------------------------------------------------
% minimize number of waits
#minimize {1@1,R : wait(R,T)}.
% minimize number of vertex_collisions
#minimize {1@2,R,C,T : vertex_collision(R,C,T)}.

% ----------------------------------------------------------------------------------------------

% output
#show.
#show position_/3.
