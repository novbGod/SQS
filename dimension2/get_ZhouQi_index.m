
function idx = get_ZhouQi_index(matrix_size, row_indices, col_indices)
% GET_WRAPPED_LINEAR_INDEX 周期性地将行/列索引转换为线性索引。
%
%   linear_indices = get_wrapped_linear_index(matrix_size, row_indices, col_indices)
%
%   输入参数:
%     matrix_size   - 矩阵的大小，例如 [m, n]。
%     row_indices   - 行索引向量。
%     col_indices   - 列索引向量。
%
%   输出参数:
%     linear_indices - 对应的线性索引向量。
%
%   用法示例:
%     % 创建一个 3x4 矩阵
%     A = reshape(1:12, 3, 4); 
%     % 假设我们想找到 (1,5) 和 (4,-1) 的元素
%     wrapped_indices = get_wrapped_linear_index(size(A), [1, 4], [5, -1]);
%     % wrapped_indices 将是 [1, 9]
%     disp(wrapped_indices);
%     % 访问这些元素
%     disp(A(wrapped_indices));

% 提取矩阵的行和列大小
m = matrix_size(1);
n = matrix_size(2);

% 使用模运算来处理周期性（环绕）
% MATLAB的mod函数对于负数行为特殊，mod(x, n)的结果与n同号
% 因此，我们需要在处理负索引时添加一个周期，以确保结果在 [1, m] 或 [1, n] 范围内
wrapped_rows = mod(row_indices - 1, m) + 1;
wrapped_cols = mod(col_indices - 1, n) + 1;

% 使用 sub2ind 将处理后的行/列索引转换为线性索引
idx = [wrapped_rows,wrapped_cols];

end