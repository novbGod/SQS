%输入矩阵、元胞，将其一行一行地转化成列向量、元胞并清除空元素、去重
%输出列向量、元胞
function matrixColumn = turnToColumnDeleteBlank(matrix)
matrixColumn = reshape(matrix.', [], 1);%转化成列元胞
matrixColumn = matrixColumn(~cellfun('isempty', matrixColumn));%去除空元素
end