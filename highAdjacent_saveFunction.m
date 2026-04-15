%对n，生成所有主类
clear;
n = 8;%每种小球数量
kmax = 10;%要计算的最高级近邻的级数
a = integer_partitions(n);%不同分堆
result = {};
firstZero = findFirstZeroInRow(a); %截取a的非0堆，即识别堆数


%去除不合比例的主类
o = 1;
while o <= size(a,1)
    if n-(firstZero(o)-1) ~= firstZero(o)-1
        a(o,:) = [];
        firstZero(o) = [];
        o = o-1;
    end
    o = o+1;
end

for i = 1:size(a,1) %对每一种分堆，列出所有可能的顺序
    elements = a(i,1:firstZero(i)-1); 
    result = [result,generate_circular_permutations_with_duplicates(elements)];
end

arrayAB2 = {};
%以二级紧邻为约束最少量地插入B
for i = 1:length(result)
    tempAdjacent2 = adjacent2(result{i});%临时变量避免重复运算
    arrayAB2(i,1:length(tempAdjacent2)) = tempAdjacent2;
end

%识别需要继续加球的B堆的索引
indexB = findAddB(arrayAB2);

%对一种分堆情况，列出所有可能顺序组合
function unique_perms = generate_circular_permutations_with_duplicates(elements)
    if length(elements) <= 1 %筛去单元素
        unique_perms = {elements};
        return;
    end
    
    fixed = elements(1); %固定首个堆
    remaining = elements(2:end);
    
    % 为防止存在相同元素导致生成相同排列，生成唯一排列并去重
    [unique_perms_temp, ~] = unique(perms(remaining), 'rows', 'stable');
    
    unique_perms = {};
    for i = 1:size(unique_perms_temp, 1)%去除镜像排列
        current_perm = unique_perms_temp(i, :);
        full_perm = [fixed, current_perm];
        
        if current_perm(1)<=current_perm(end)
            unique_perms{end+1} = full_perm;
        end
    end
    
    % 最终去重（防止因重复元素导致残留重复）
    if ~isempty(unique_perms)
        [~, idx] = unique(cell2mat(unique_perms'), 'rows', 'stable');
        unique_perms = unique_perms(idx);
    end
end

%查找矩阵每行第一个0元素的索引
function first_zero_col = findFirstZeroInRow(A)
    % 提取第i行的所有元素
    first_zero_col = zeros(1,size(A,1));
 for i = 1:size(A,1)
    row = A(i, :);
    
    % 查找第一个0的列索引
    zero_indices = find(row == 0, 1); % 仅返回第一个匹配的索引
    
    % 处理无0的情况
    if isempty(zero_indices)
        first_zero_col(i) = size(A,2) + 1; % 可替换为 NaN 或其他标识符
    else
        first_zero_col(i) = zero_indices;
    end
 end
end

%检测数组环形等价（顺逆时针遍历）（可能存在更好算法，如booth？）
function equivalent = are_rings_equivalent(arr1, arr2)
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


% 生成所有两两交错拼接数组（含相位偏移）
function result = generateInterleavedArrays(C)
% 输入：
%   C - 元胞数组，每个元素为长度为i的数组
% 输出：
%   result - 元胞数组，包含所有生成的拼接数组
    % 预处理：确保所有数组为行向量
    n = numel(C);
    for m = 1:n
        if iscolumn(C{m})
            C{m} = C{m}.'; % 列向量转置为行向量
        end
    end
    i = numel(C{1}); % 所有数组长度相同
    
    % 初始化结果元胞
    idx = 1; % 结果索引
   result = cell(n*(n+1)/2 * i, 1);
    % 遍历所有数组对（包括自己与自己）
    for a_idx = 1:n
        a = C{a_idx};
        for b_idx = a_idx:n
            b = C{b_idx};
            % 生成所有相位偏移（循环右移 0 到 i-1 位）
            for k = 0:i-1
                % 循环右移k位
                b_shifted = circshift(b, k, 2);
                % 交错拼接
                interleaved = reshape([a; b_shifted], 1, []);
                % 存储结果
                result{idx} = interleaved;
                idx = idx + 1;
            end
        end
    end
end

%计算n级近邻数
function adjacent = countAdjacent(arr,n)
    % 生成原子类型序列（A和B交替）
    types = [];
    for i = 1:length(arr)
        if mod(i, 2) == 1  % 奇数堆为A，用1代表，偶数堆为B，用-1代表
            types = [types, ones(1,arr(i))];
        else
            types = [types, -ones(1,arr(i))];
        end
    end
    AA = 0; BB = 0; AB = 0;
    %转化过高级近邻，放置后续程序出错
    if n >= length(types)
        n = mod(n,length(types));
    end
    %遍历识别n级近邻
    for i = 1:length(types)-n
        if types(i) + types(i+n) == 2
            AA = AA + 1;
        elseif types(i) + types(i+n) == -2
            BB = BB + 1;
        else
            AB = AB + 1;
        end
    end
    %补足首尾衔接
    for i = n-1:-1:0
        if types(end-i) + types(-i+n) ==2
            AA = AA + 1;
        elseif types(end-i) + types(-i+n) == -2
            BB = BB + 1;
        else
            AB = AB + 1;
        end
    end
    adjacent = [AA,BB,AB];
end

%将结果按近邻数排列(忽略最近邻）
function new = sequence(old,kmax)
check = ones(size(old,1),kmax+1);
m = size(old,1);
    for i = 3:kmax+1
        for j = 1:size(old,1)
            array = old{j,i}; 
            if 2*array(1)==array(3) && 2*array(2)==array(3) && check(j,i)
                % 构造新索引
            new_order = [j, 1:j-1, j+1:m];
            % 重新排列行
            old = old(new_order, :);
            check = check(new_order, :);
            else
                check(j,i:kmax+1) = 0;
            end
        end
    end
    new = old;
end

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

%根据输入的主类arrayAB2为筛选到二阶近邻时满足比例的排序
%B未排满，B尽量少
function arrayAB2 = adjacent2(arrayA)
L = length(arrayA);
arrayB = ones(1,L);%每个B堆至少有一个球，先在此基础上计算二级近邻
arrayNew = combineAB(arrayA,arrayB);
adjacent2 = countAdjacent(arrayNew,2);
numFillB = adjacent2(1) - L;%应该一定是正数或0吧？
if numFillB == 0
    arrayAB2 = {};
    return;
end
fillB = balls_in_boxes_max1(numFillB,L);%要在arrayB的基础上额外添加的B，以满足二级紧邻
B2 = cell(1,length(fillB));

for i = 1:length(fillB)%添加B
    B2{i} = fillB{i} + arrayB;
end
arrayAB2 = cell(1,length(fillB));
for i = 1:length(fillB)%将添加后的B与A结合
    arrayAB2{i} = combineAB(arrayA,B2{i});
end
arrayAB2 = deleteSame(arrayAB2);%去重，测试几例感觉不用去重？
end

%将A、B数组交错排放，A、B长度必须相同
function AB = combineAB(A,B)
L = length(A);
AB = zeros(1,2*L);
AB(1:2:end) = A;
AB(2:2:end) = B;
end

%L<=A，每个箱子至多放一个小球
function cell_array = balls_in_boxes_max1(L, A)
    % 参数检查：A需为正整数，L范围需满足 0 ≤ L ≤ A
    if A <= 0 || L < 0 || L > A
        cell_array = cell(0, 1);
        return;
    end
    
    % 处理L=0的特殊情况（所有箱子为空）
    if L == 0
        cell_array = {zeros(1, A)};
        return;
    end
    
    % 生成所有组合的索引（从A个位置选L个放球）
    combinations = nchoosek(1:A, L);
    num_comb = size(combinations, 1);
    cell_array = cell(num_comb, 1);
    
    % 为每个组合生成对应的0-1分布向量
    for i = 1:num_comb
        vec = zeros(1, A);               % 初始化全0向量
        vec(combinations(i, :)) = 1;     % 选中位置置1
        cell_array{i} = vec;             % 存入元胞数组
    end
end

%去重,resultABdiff存储去重后结果
function resultABdiff = deleteSame(resultAB)
resultABdiff = resultAB;
i = 1;
while i <= size(resultABdiff,1)
    j = i+1;
    while j <= size(resultABdiff,1)%去重
        if are_rings_equivalent(resultABdiff{i},resultABdiff{j})
            resultABdiff(j) = [];
            j = j-1;
        end
        j = j+1;
    end
    i = i+1;
end
end

%识别经过二级筛选后可以继续加球的B堆的索引
function indexB2 = findAddB(adjacentAB2)
indexB2 = cell(size(adjacentAB2));
L = length(adjacentAB2{1});
    for j = 1:size(adjacentAB2,1)
        for i = 1:size(adjacentAB2,2)
            array = adjacentAB2{j,i};
            if isempty(array) == 0
            index = (array(2:2:L) ~= 1);
            index = combineAB(zeros(1,L/2),index);
            else
                index = [];
            end
            indexB2{j,i} = index;
        end
    end
end