
function arrays = generateTwoBodyOnly(n, num)
kmax = 13;%要计算的最高级近邻的级数
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

%插入B堆
resultAB = generateInterleavedArrays(result);
resultABdiff = deleteSame(resultAB);
%计算kmax级及以下近邻数,adjacent元胞中每行存储一个排列及其各级近邻数
adjacent = resultABdiff;
adjacent = [adjacent,cell(length(resultABdiff),kmax)];
for o = 1:length(resultABdiff)
    for k = 1:kmax
        adjacent{o,k+1} = countAdjacent(resultABdiff{o},k);
    end
end

%按近邻数排序
adjacent_new = sequence(adjacent,kmax);
adjacentAB = pickAB(adjacent_new);
adjacent3AB = cell(size(adjacentAB,1),1);

adjacentAB = [adjacentAB(:,1),adjacent3AB,adjacentAB(:,2:end)];

for ippp = 1:num
    arrays(ippp,:) = pileToBalls(adjacent_new{ippp,1});
end

function S = integer_partitions(n,count)
if nargin == 1
    count = n;
end
if n < 0 || n ~= round(n)
    error('Only nonnegative integers allowed!');
elseif n == 0
    if count == 0
        S = 0;
    else
        S = zeros(1,count);
    end
else
    x = ones(1,n);
    x(1) = n;
    m = 1;
    h = 1;
    M = [x(1:m) zeros(1,n-m)];
    while x(1) ~= 1
        if x(h) == 2 
           m = m + 1;
           x(h) = 1;
           h = h - 1;
        else
           r = x(h) - 1;
           t = m - h + 1;
           x(h) = r;
           while t >= r
               h = h + 1;
               x(h) = r;
               t = t - r;
           end
           if t == 0
               m = h;
           else
               m = h + 1;
               if t > 1
                   h = h + 1;
                   x(h) = t;
               end
           end
        end
        M = cat(1,M,[x(1:m) zeros(1,n-m)]);
    end
    if count > n
        M = cat(2,M,zeros(size(M,1),count-n));
    end
    S = [];
    for i = 1:size(M,1)
        if(sum(M(i,1:count)) == n)
            S = cat(1,S,M(i,1:count));
        end
    end
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
%去重,resultABdiff存储去重后结果
%输入一个元胞，输出一个去重后的列元胞
function resultABdiff = deleteSame(resultAB)
%resultABdiff = resultAB;
resultABdiff = reshape(resultAB.', [], 1);%转化成列向量
i = 1;
while i <= size(resultABdiff,1)
    j = i+1;
    while j <= size(resultABdiff,1)%去重
        if max(resultABdiff{i}) == max(resultABdiff{j}) %先识别最大数是否相同以节省算力
            if are_rings_equivalent(resultABdiff{i},resultABdiff{j})
            resultABdiff(j) = [];
            j = j-1;
            end
        end
        j = j+1;
    end
    i = i+1;
end
end

%输入两个需要判断是否环形等价的数组，输出逻辑值
   function tf = are_rings_equivalent(A, B)
% ISCIRCEQ   判断 A 是否与 B 循环等价（正序或逆序）
%   tf = iscircEq(A,B) 返回逻辑值，若 A 是 B 的某种循环移位
%   或 A 是 B 逆序的某种循环移位，则 tf = true。

    % 快速长度判断
    if numel(A) ~= numel(B)
        tf = false;
        return;
    end

    % 将 B 正序和反序都拼接两遍
    B2 = [B, B];
    Br = B(end:-1:1);
    Br2 = [Br, Br];

    % 用 strfind 找 A 在 B2 或 Br2 中的位置
    % strfind 对数字也有效，底层已做优化 (大约 KMP)
    if ~isempty(strfind(B2, A)) || ~isempty(strfind(Br2, A))
        tf = true;
    else
        tf = false;
    end
end


function adjacent = countAdjacent(arr,n)
    % 生成原子类型序列（A和B交替）
    types = zeros(1,sum(arr));
    k = 1;%记录这每个球堆中第一个小球加入type的位置
    for i = 1:length(arr)
        if mod(i, 2) == 1  % 奇数堆为A，用1代表，偶数堆为B，用-1代表
            types(k:(k+arr(i)-1)) = ones(1,arr(i));
        else
            types(k:(k+arr(i)-1)) = -ones(1,arr(i));
        end
        k = k + arr(i);
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
function ballsArray = pileToBalls(pileArray)

index = 1;
for iav = 1:length(pileArray)
    ballsArray(index:pileArray(iav)+index-1) = mod(iav,2);
    index = pileArray(iav)+index;
end
ballsArray = abs(ballsArray - 1);
end

end