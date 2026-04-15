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
