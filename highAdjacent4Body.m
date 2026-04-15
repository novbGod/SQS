%对n，生成所有主类
clearvars -except arrayAB_Column8 arrayAB_Column12 arrayAB_Column10 array12;
tic;
n = 8;%每种小球数量
Nb = 4;%计算N体排列
Nmax = 15;%要约束的最高级近邻的级数
a = integer_partitions(n);%不同分堆
arrayA = {};
firstZero = findFirstZeroInRow(a); %截取a的非0堆，即识别堆数
arrayAB_Column = {};%储存经过近邻约束筛选后的类，第N列代表经N级约束筛选后的类
indexB_Column = {};%同上，储存对应的可加B的B堆的索引
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
% o = 2;
% while o <= size(a,1)%根据经验，一般满足多紧邻的，最大数字在[n/2-1,n/2+1]
%     if a(o,1) ~= ceil(a(1,1)/2)%筛除数字排列以加快计算
%         a(o,:) = [];
%         firstZero(o) = [];
%         o = o-1;
%     end
%     o = o+1;
% end

for i = 1:size(a,1) %对每一种分堆，列出所有可能的顺序
    elements = a(i,1:firstZero(i)-1); 
    arrayA = [arrayA,generate_circular_permutations_with_duplicates(elements)];
end
arrayA_Column = turnToColumnDeleteBlank(arrayA);
arrayA_Column = deleteSame(arrayA_Column);
arrayAB_Column(1:length(arrayA_Column),1) = arrayA_Column;
indexB_Column(1:length(arrayA_Column),1) = cell(length(arrayA_Column),1);
arrayAB2 = {};%储存二级次类
%以二级紧邻为约束最少量地插入B
for i = 1:length(arrayA)
    tempAdjacent2 = adjacent2(arrayA{i});%临时变量避免重复运算
    j = 1;
    while j <= length(tempAdjacent2)
        tempNbody = countAdjacentNbody(tempAdjacent2{j},Nb);
        if ~isequal([tempNbody(3:end-3),tempNbody(end-1:end)], [2,2,2,1,2,2,1]*(round(n/8)))
            tempAdjacent2(j) = [];
            j = j-1;
        end
        j = j+1;
    end
    arrayAB2(i,1:length(tempAdjacent2)) = tempAdjacent2;
end
clear tempAdjacent2 ;
%识别需要继续加球的B堆的索引，二阶

%转为列元胞
arrayAB2Column = turnToColumnDeleteBlank(arrayAB2);
% arrayAB2Column = deleteSame(arrayAB2Column);%去重可删
indexB2Column = findAddB(arrayAB2Column,2);
arrayAB_Column(1:length(arrayAB2Column),2) = arrayAB2Column;
indexB_Column(1:length(arrayAB2Column),2) = indexB2Column;
arrayAB3 = {};%储存三级次类
% %以三级近邻为约束插入B
% for i = 1:length(arrayAB2Column)
%     tempAdjacent3 = adjacentN(arrayAB2Column{i},indexB2Column{i},3);%临时变量避免重复运算
%     arrayAB3(i,1:length(tempAdjacent3)) = tempAdjacent3;
% 
% end
% clear tempAdjacent3;
% %识别需要继续加球的B堆的索引
% indexB3 = findAddB(arrayAB3,3);
% 
% %转为列元胞
% arrayAB3Column = turnToColumnDeleteBlank(arrayAB3);
% indexB3Column = turnToColumnDeleteBlank(indexB3);
% arrayAB_Column(1:length(arrayAB3Column),3) = arrayAB3Column;
% indexB_Column(1:length(arrayAB3Column),3) = indexB3Column;

%以四到Nmax级近邻为约束
for N = 3:Nmax
    for j = 1:length(arrayAB_Column(:,N-1))
        tempArrayAB = arrayAB_Column{j,N-1};%通过N-1级约束推得N级约束下数组
        tempIndexB = indexB_Column{j,N-1};
        tempAdjacentN = adjacentN(tempArrayAB,tempIndexB,N);
        arrayABN(j,1:length(tempAdjacentN)) = tempAdjacentN;
    end
    % indexBN = findAddB(arrayABN,N);
    arrayABNColumn = turnToColumnDeleteBlank(arrayABN);
    arrayABN = {};
    % arrayABNColumn = deleteSame(arrayABNColumn);%去重可删
    indexBNColumn = findAddB(arrayABNColumn,N);
    arrayAB_Column(1:length(arrayABNColumn),N) = arrayABNColumn;
    indexB_Column(1:length(arrayABNColumn),N) = indexBNColumn;
end

% %将最高级约束去重
% arrayABNColumn = deleteSame(arrayABNColumn);
%     indexBNColumn = findAddB(arrayABNColumn,N);
%     arrayAB_Column(1:length(arrayABNColumn),N) = arrayABNColumn;
%     indexB_Column(1:length(arrayABNColumn),N) = indexBNColumn;

%数N体近邻
adjacentABnBody = cell(size(arrayAB_Column));
for i = 2:size(arrayAB_Column,2)
    for j = 1:size(arrayAB_Column,1)
        adjacentABnBody{j,i} = countAdjacentNbody(arrayAB_Column{j,i},Nb);
    end
end

disp(n);
disp(toc);