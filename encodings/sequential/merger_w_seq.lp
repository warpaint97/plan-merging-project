% - waiter sequential -----------------------------------------------------------------------

% init
isRobot(R) :- position(R,_,_).
destination(R,C,T) :- position(R,C,T), not position(R,_,T+1), isRobot(R).

% find times for waitable positions
waitable(R,T) :- position(R,C,T+1), position(R',C,T'), R!=R'.
% either wait at one waitable timestep or don't
{wait(R,T) : waitable(R,T)}1 :- isRobot(R).

% reconstruct positions
% before wait
position_(R,C,T) :- wait(R), wait(R,T_WAIT), T<=T_WAIT, position(R,C,T).
% after wait
position_(R,C,T) :- wait(R), wait(R,T_WAIT), T>T_WAIT, position(R,C,T-1).
% keep positions if no wait
wait(R) :- wait(R,T).
position_(R,C,T) :- not wait(R), position(R,C,T).

% find new vertex collisions
vertex_collision(C,T) :- position_(R,C,T), position_(R',C,T), R!=R'.

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
#minimize {1@2,C,T : vertex_collision(C,T)}.
% ----------------------------------------------------------------------------------------------

% output
#show.
#show position_/3.
