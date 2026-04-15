%不再注重二体，看看多体是否可以
clear;
n = 32;%每种小球数量
Nb = 6;%计算N体排列
Nmax = 15;%要约束的最高级近邻的级数
a = integer_partitions(n);%不同分堆
arrayA = {};
firstZero = findFirstZeroInRow(a); %截取a的非0堆，即识别堆数
arrayAB_Column = {};%储存经过近邻约束筛选后的类，第N列代表经N级约束筛选后的类
indexB_Column = {};%同上，储存对应的可加B的B堆的索引
index = [];%储存符合多体条件的结构的索引，方便查找
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
    arrayA = [arrayA,generate_circular_permutations_with_duplicates(elements)];
end

allPossArray = [arrayA;cell(length(arrayA)*length(arrayA{1}),length(arrayA))];
nBody = cell(length(arrayA)*length(arrayA{1})+1,length(arrayA));
L = length(arrayA{1});
for i = 1:size(allPossArray,2)
    for j = 1:size(allPossArray,1)-1
        tem(1:2:2*L) = arrayA{1,i};
        tem(2:2:2*L) = circshift(arrayA{1,ceil(j/L)},mod(j,L)-1);
        allPossArray{j+1,i} = tem;
        temN = countAdjacentNbody(tem,Nb);
        if isequal(temN,ones(1,64))
            nBody{j+1,i} = tem;
            index(end+1,:) = [j+1,i]; 
        end
    end
end

