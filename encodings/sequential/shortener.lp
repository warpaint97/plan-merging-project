% - INPUT -------------------------------------------------------------------------------
% REPRESENTATION

robot(R)		:- init(object(robot,R),          _).
shelf(S)		:- init(object(shelf,S),          _).
product(A)		:- init(object(product,A),        _).

isRobot(robot(R))	:- robot(R).
isShelf(shelf(S))	:- shelf(S).
isProduct(product(A))	:- product(A).
isOrder(order(O))	:- order(O).

order(O)		     :- init(object(order,O),          _).
ordered(order(O),product(A)) :- init(object(order,O),          value(line,(A,_))).      % IGNORING QUANTITIES

shelved(shelf(S),product(A)) :- init(object(product,A),        value(on,(S,_))).        % IGNORING QUANTITIES

position((X,Y))		     :- init(object(node,_),           value(at,(X,Y))).

position(robot(R),(X,Y),0) :- init(object(robot,R),          value(at,(X,Y))).
position(shelf(S),(X,Y),0)   :- init(object(shelf,S),          value(at,(X,Y))).




% READING PLANS
% ----------------------------------------------------------------------------------------------
% reading plans
position(robot(R),(X,Y),0) :- init(object(robot,R),value(at,(X,Y))).
move(robot(R),(DX,DY),T) :- occurs(object(robot,R),action(move,(DX,DY)),T).

% calculate original positions recursively
position(R,(X+DX,Y+DY),T+1) :- move(R,(DX,DY),T), position(R,(X,Y),T).
%lastposition(R,C,T) :- position(R,C,T), not position(R,,T+1), isRobot(R).

processed(A,R,T) :- ordered(O,A), shelved(S,A), isRobot(R), position(S,C,0), position(R,C,T).
processed(A) :- processed(A,R,T).

horizon(0..T_MAX) :- T_MAX == #max{T : position(R,C,T)}.
pending(0..T) :- not processed(_,_,T), horizon(T).
%:- ordered(O,A), not processed(A).
% ----------------------------------------------------------------------------------------------

% OUTPUT
% ----------------------------------------------------------------------------------------------
% reconstruct final moves for output.
final_move(R,(C2X-C1X,C2Y-C1Y),T) :- position(R,(C1X,C1Y),T), position(R,(C2X,C2Y),T+1), pending(T).

% show statements
#show.
#show init/2.
#show occurs(object(robot,R), action(move,D),T) : final_move(robot(R),D,T).
