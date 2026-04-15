function has_conflict = check_conflicts(matrix, row_indices, col_indices, new_elements)
% CHECK_CONFLICTS_OPTIMIZED 检测在指定位置填入新元素是否与矩阵现有元素冲突，使用向量化方法。
%输入参数依次为原有矩阵，填入元素的行索引，列索引，要填入的元素
% 使用线性索引将行和列转换为单个索引

% 1. 强制将所有输入向量转换为列向量，确保维度一致
row_indices = row_indices(:);
col_indices = col_indices(:);
new_elements = new_elements(:);

matrix = [matrix,matrix;matrix,matrix];%周期性延拓
linear_indices = sub2ind(size(matrix), row_indices, col_indices);

% 获取旧值
old_elements = matrix(linear_indices);

% 找到非零的旧值
non_zero_old_values = old_elements(old_elements ~= 0);
new_values_for_comparison = new_elements(old_elements ~= 0);

% 比较非零旧值与对应的新值
if ~isempty(non_zero_old_values)
    % 检查是否有任何不相等的情况
    if any(non_zero_old_values ~= new_values_for_comparison)
        has_conflict = true;
    else
        has_conflict = false;
    end
else
    % 如果所有旧值都是0，则无冲突
    has_conflict = false;
end

end