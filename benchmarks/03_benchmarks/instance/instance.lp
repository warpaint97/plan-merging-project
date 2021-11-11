%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grid size X: 3
%Grid size Y: 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

% init

% nodes
init(object(node,1),value(at,(2,1))).
init(object(node,2),value(at,(2,2))).
init(object(node,3),value(at,(2,3))).
init(object(node,5),value(at,(3,2))).
init(object(node,6),value(at,(1,2))).


% robots
init(object(robot,1),value(at,(2,3))).
init(object(robot,2),value(at,(2,1))).
init(object(robot,3),value(at,(1,2))).

% shelves
init(object(shelf,1),value(at,(2,2))).

% products
init(object(product,1),value(on,(2,2))).

% orders
init(object(order,1),value(line,(1,1))).
