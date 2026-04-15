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
