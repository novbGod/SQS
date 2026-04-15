%输入一个N-1级次类数组，一个对应的可填B堆索引数组，以N级近邻约束排列N级次类数组
%输出基于这个N-1级次类数组，得到的N级次类数组组成的行元胞，N>=3,不适用于N=1、2
function arrayABN = adjacentN(inputArrayAB_N_minus1,inputIndexB_N_minus1,N)
if isempty(inputArrayAB_N_minus1) || isempty(inputIndexB_N_minus1)
    arrayABN = {};
    return;
end
L = length(inputArrayAB_N_minus1);
adjacent_N = countAdjacent(inputArrayAB_N_minus1,N);
numFillB = adjacent_N(1) - L/2;
if numFillB <= 0 %即不能再放球或需要往出拿球才能满足N级近邻
    arrayABN = {};
    return;
end

remainingB = L-sum(inputArrayAB_N_minus1(2:2:end));%计算还剩多少个没放进去的B
if remainingB < numFillB%如果剩余的B小于需要放进去的B，则此次类无法满足N级近邻
    arrayABN = {};
    return;
end

%找出所有在2B堆中继续放球的情况
fillB = balls_in_boxes_max1(numFillB,sum(inputIndexB_N_minus1));
%此时索引只包含可放球的2B堆，现将此索引转换为长度为L的加B球的数组
arrayABN = cell(1,length(fillB));
for i = 1:length(fillB)
    plusB = zeros(1,L);
    plusB(inputIndexB_N_minus1 == 1) = fillB{i};
    arrayABN{1,i} = inputArrayAB_N_minus1+plusB;
end

end