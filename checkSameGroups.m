for i = 1:length(get)
    cellA = arrayAB_Column(1,6);
    cellB = get(i);
% 找出 cellA 中存在但 cellB 中不存在的数组
    checkSameGroups1(cellA, cellB);
end

function commonCells = checkSameGroups1(cellA, cellB)
commonCells = {};
uniqueToA = {};
for i = 1:length(cellA)
    found = false;
    for j = 1:length(cellB)
        if are_rings_equivalent(cellA{i}, cellB{j})
            found = true;
            break;
        end
    end
    if ~found
        uniqueToA{end+1} = cellA{i};
        I = i;
    end
end

% 找出 cellB 中存在但 cellA 中不存在的数组
uniqueToB = {};
for j = 1:length(cellB)
    found = false;
    for i = 1:length(cellA)
        if are_rings_equivalent(cellB{j}, cellA{i})
            found = true;
            break;
        end
    end
    if ~found
        uniqueToB{end+1} = cellB{j};
    end
end

% 合并所有不相同的数组
allUnique = [uniqueToA, uniqueToB];

% % 显示结果
% disp('cellA 中独有的数组：');
% disp(uniqueToA);
% disp('cellB 中独有的数组：');
% disp(uniqueToB);
% disp('所有不相同的数组：');
% disp(allUnique);
% 显示结果
disp('相同的数列有：');
disp(commonCells);
end