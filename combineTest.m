kmax = 15;
tic;

array1 = arrayAB_Column12(:,8-3:8);
array1 = reshape(array1.', [], 1);
array1 = array1(~cellfun('isempty', array1));
array2 = arrayAB_Column6(:,2:4);
array2 = reshape(array2.', [], 1);
array2 = array2(~cellfun('isempty', array2));
L1 = length(array1);
L2 = length(array2);
array12 = cell(L1*L2,1);

for i = 1:L1
    for j = 1:L2
        array12{(i-1)*L2+j} = [array1{i},array2{j}];
    end
    
end
array12 = array12(~cellfun('isempty', array12));

%计算kmax级及以下近邻数,adjacent元胞中每行存储一个排列及其各级近邻数
array12 = [array12,cell(size(array12,1),kmax)];
for i = 1:size(array12,1)
    for k = 1:kmax
        array12{i,k+1} = countAdjacent(array12{i,1},k);
    end
end

%按近邻数排序
array12 = sequence(array12,kmax);
array12AB = pickAB(array12);

disp(toc);