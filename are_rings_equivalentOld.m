%检测数组环形等价（顺逆时针遍历）（可能存在更好算法，如booth？）
function equivalent = are_rings_equivalentOld(arr1, arr2)
% 检查数组长度
n = length(arr1);
if n ~= length(arr2)
    equivalent = false;
    return;
end

% 处理空数组
if n == 0
    equivalent = true;
    return;
end

% 将数组转为行向量以确保一致性
arr1 = arr1(:).';
arr2 = arr2(:).';

% 检查所有顺时针旋转
for k = 0:n-1
    rotated = circshift(arr1, [0, k]);
    if isequal(rotated, arr2)
        equivalent = true;
        return;
    end
end

% 检查逆序后的所有顺时针旋转（相当于逆时针旋转原数组）
reversed_arr = fliplr(arr1);
for k = 0:n-1
    rotated = circshift(reversed_arr, [0, k]);
    if isequal(rotated, arr2)
        equivalent = true;
        return;
    end
end

equivalent = false;
end
