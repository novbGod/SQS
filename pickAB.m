%将近邻排列中的A、B原子排列挑出来放到2、3列
function adjacentAB = pickAB(adjacent_new)
     N = size(adjacent_new,1);
    AB = cell(N,2);
    for i = 1:N
        array = adjacent_new{i,1};
        AB{i,1} = array(1:2:end);
        AB{i,2} = array(2:2:end);
    end
    adjacentAB = [adjacent_new(:,1),AB,adjacent_new(:,2:end)];

end
