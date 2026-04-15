%根据输入的主类arrayAB2为筛选到二阶近邻时满足比例的排序
%B未排满，B尽量少
%输入一个主类排列，返回一个包含所有在主类基础上满足二级紧邻的排列的行元胞
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
arrayAB2 = deleteSame(arrayAB2);%去重
end
