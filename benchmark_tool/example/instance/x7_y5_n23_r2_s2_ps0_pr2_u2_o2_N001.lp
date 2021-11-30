%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grid Size X:                      7
% Grid Size Y:                      5
% Number of Nodes:                  23
% Number of Highway Nodes:          0
% Number of Robots:                 2
% Number of Shelves:                2
% Number of Picking Stations:       0
% Number of Products:               2
% Number of Product Units in Total: 2
% Number of Orders:                 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#program base.

% init

% nodes
init(object(node,1),value(at,(1,1))).
init(object(node,2),value(at,(3,1))).
init(object(node,3),value(at,(4,1))).
init(object(node,4),value(at,(5,1))).
init(object(node,5),value(at,(6,1))).
init(object(node,6),value(at,(7,1))).
init(object(node,7),value(at,(1,2))).
init(object(node,8),value(at,(5,2))).
init(object(node,9),value(at,(7,2))).
init(object(node,10),value(at,(1,3))).
init(object(node,11),value(at,(2,3))).
init(object(node,12),value(at,(3,3))).
init(object(node,13),value(at,(5,3))).
init(object(node,14),value(at,(7,3))).
init(object(node,15),value(at,(1,4))).
init(object(node,16),value(at,(3,4))).
init(object(node,17),value(at,(5,4))).
init(object(node,18),value(at,(7,4))).
init(object(node,19),value(at,(1,5))).
init(object(node,20),value(at,(3,5))).
init(object(node,21),value(at,(4,5))).
init(object(node,22),value(at,(5,5))).
init(object(node,23),value(at,(7,5))).

% robots
init(object(robot,1),value(at,(1,1))).
init(object(robot,2),value(at,(1,5))).

% shelves
init(object(shelf,1),value(at,(3,1))).
init(object(shelf,2),value(at,(7,5))).

% products
init(object(product,1),value(on,(1,1))).
init(object(product,2),value(on,(2,1))).

% orders
init(object(order,1),value(line,(1,1))).
init(object(order,2),value(line,(2,1))).
