%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grid Size X:                      12
% Grid Size Y:                      6
% Number of Nodes:                  54
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
init(object(node,2),value(at,(2,1))).
init(object(node,3),value(at,(3,1))).
init(object(node,4),value(at,(4,1))).
init(object(node,5),value(at,(6,1))).
init(object(node,6),value(at,(8,1))).
init(object(node,7),value(at,(9,1))).
init(object(node,8),value(at,(10,1))).
init(object(node,9),value(at,(11,1))).
init(object(node,10),value(at,(12,1))).
init(object(node,11),value(at,(1,2))).
init(object(node,12),value(at,(2,2))).
init(object(node,13),value(at,(3,2))).
init(object(node,14),value(at,(4,2))).
init(object(node,15),value(at,(6,2))).
init(object(node,16),value(at,(8,2))).
init(object(node,17),value(at,(9,2))).
init(object(node,18),value(at,(10,2))).
init(object(node,19),value(at,(11,2))).
init(object(node,20),value(at,(12,2))).
init(object(node,21),value(at,(1,3))).
init(object(node,22),value(at,(2,3))).
init(object(node,23),value(at,(3,3))).
init(object(node,24),value(at,(4,3))).
init(object(node,25),value(at,(5,3))).
init(object(node,26),value(at,(6,3))).
init(object(node,27),value(at,(7,3))).
init(object(node,28),value(at,(8,3))).
init(object(node,29),value(at,(12,3))).
init(object(node,30),value(at,(1,4))).
init(object(node,31),value(at,(2,4))).
init(object(node,32),value(at,(6,4))).
init(object(node,33),value(at,(10,4))).
init(object(node,34),value(at,(11,4))).
init(object(node,35),value(at,(12,4))).
init(object(node,36),value(at,(1,5))).
init(object(node,37),value(at,(2,5))).
init(object(node,38),value(at,(4,5))).
init(object(node,39),value(at,(6,5))).
init(object(node,40),value(at,(8,5))).
init(object(node,41),value(at,(9,5))).
init(object(node,42),value(at,(10,5))).
init(object(node,43),value(at,(11,5))).
init(object(node,44),value(at,(12,5))).
init(object(node,45),value(at,(1,6))).
init(object(node,46),value(at,(2,6))).
init(object(node,47),value(at,(3,6))).
init(object(node,48),value(at,(4,6))).
init(object(node,49),value(at,(6,6))).
init(object(node,50),value(at,(8,6))).
init(object(node,51),value(at,(9,6))).
init(object(node,52),value(at,(10,6))).
init(object(node,53),value(at,(11,6))).
init(object(node,54),value(at,(12,6))).

% robots
init(object(robot,2),value(at,(2,2))).
init(object(robot,1),value(at,(4,5))).

% shelves
init(object(shelf,2),value(at,(11,1))).
init(object(shelf,1),value(at,(8,6))).

% products
init(object(product,1),value(on,(1,1))).
init(object(product,2),value(on,(2,1))).

% orders
init(object(order,1),value(line,(1,1))).
init(object(order,2),value(line,(2,1))).
