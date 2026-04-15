%对n，生成所有主类
clear;
tic;
n = 6;%每种小球数量
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
for i = 1:length(resultABdiff)
    for k = 1:kmax
        adjacent{i,k+1} = countAdjacent(resultABdiff{i},k);
    end
end

%按近邻数排序
adjacent_new = sequence(adjacent,kmax);
adjacentAB = pickAB(adjacent_new);
adjacent3AB = cell(size(adjacentAB,1),1);

%数三体近邻
for i = 1:size(adjacentAB,1)
    % temp = countAdjacent3(adjacentAB{i,1});
    % temp = [temp(8),temp(7),temp(6),temp(2),temp(3),temp(1)];
    adjacent3AB{i} = countAdjacentNbody(adjacentAB{i,1},3);
end

adjacentAB = [adjacentAB(:,1),adjacent3AB,adjacentAB(:,2:end)];
disp(toc);