% ----------------------------------------------------------------------------------------------
% reading renamed plans (occurs -> occurs_)
move(robot(R),(DX,DY),T) :- occurs_(object(robot,R),action(move,(DX,DY)),T).

%calculate original positions recursively
position(R,(X+DX,Y+DY),T+1,0) :- move(R,(DX,DY),T-1), position(R,(X,Y),T-1,0).

%set first layer
layer(0,R,0) :- isRobot(R).
% ----------------------------------------------------------------------------------------------


% VERTEX COLLISION
% ----------------------------------------------------------------------------------------------
vertex_collision(C,T,L) :- position(R,C,T,D), position(R',C,T,D'), R!=R', layer(L,R,D), layer(L,R',D').
not_first_vertex_collision(T,L) :- vertex_collision(C,T,L), vertex_collision(C',T',L), T>T'.
first_vertex_collision(T,L) :- not not_first_vertex_collision(T,L), vertex_collision(C,T,L).

% choose highest priority robot
{notwait(R,C,T,L): position(R,C,T,D), layer(L,R,D)}=1 :- first_vertex_collision(T,L), vertex_collision(C,T,L).

notwait(R,C,T,L) :- position(R,C,T,D), first_vertex_collision(T,L), vertex_collision(C,T,L), layer(L,R,D), position(R,C,T,D-1).

% other robots in the same conflict wait
wait(R,T,L) :- first_vertex_collision(T,L), vertex_collision(C,T,L), position(R,C,T,D), layer(L,R,D), not notwait(R,C,T,L).

%check waited
waited(R,L) :- wait(R,_,L).
conflict(R,L) :- waited(R,L).
conflict(L) :- waited(_,L).
% ----------------------------------------------------------------------------------------------

% CONFLICT RESOLUTION
% ----------------------------------------------------------------------------------------------
% reconstruct positions and incorporate waiting
%before wait
%position(R,C,T,D+1) :- position(R,C,T,D), wait(R,T_WAIT,L), T<T_WAIT, layer(L,R,D).
%after wait
position(R,C,T,D+1) :- position(R,C,T-1,D), wait(R,T_WAIT,L), T>=T_WAIT, layer(L,R,D).

%set new depth for robot that waited.
layer(L+1,R,D+1):- waited(R,L), layer(L,R,D), layer(L).

%keep old depth for unaffected robot.
layer(L+1,R,D):- conflict(L), not conflict(R,L), layer(L,R,D), layer(L).
% ----------------------------------------------------------------------------------------------


% FINALIZING PLANS
% ----------------------------------------------------------------------------------------------
% determine the top layer
top_layer(L_TOP-1) :- L_TOP == #count{L : layer(L,robot(1),D)}.

% final plan
final_position(R,C,T) :- position(R,C,T,D), layer(L,R,D), top_layer(L).

final_move(R,(C2X-C1X,C2Y-C1Y),T) :- final_position(R,(C1X,C1Y),T), final_position(R,(C2X,C2Y),T+1).
% ----------------------------------------------------------------------------------------------

% OPTIMIZATION
% ----------------------------------------------------------------------------------------------
#minimize{L : top_layer(L)}.



% OUTPUT PLAN
% ----------------------------------------------------------------------------------------------
#show.
%#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
% ----------------------------------------------------------------------------------------------
