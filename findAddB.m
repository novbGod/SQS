%识别经过N级筛选后可以继续加球的B堆的索引
%输入一个数组元胞，输出一个大小相同的索引数组元胞
function indexB2 = findAddB(adjacentAB2,N)
indexB2 = cell(size(adjacentAB2));
%找到第一个非零数组的长度赋值给L
for i = 1:length(adjacentAB2)
    currentArray = adjacentAB2{i};
    if any(currentArray ~= 0) % 检查当前数组是否包含非零元素
        L = length(currentArray); % 获取第一个非零数组的长度
        break; % 找到后退出循环
    end
end
    for j = 1:size(adjacentAB2,1)
        for i = 1:size(adjacentAB2,2)
            array = adjacentAB2{j,i};
            if isempty(array) == 0
            index = (array(2:2:L) == N);
            index = combineAB(zeros(1,L/2),index);
            else
                index = [];
            end
            indexB2{j,i} = index;
        end
    end
end