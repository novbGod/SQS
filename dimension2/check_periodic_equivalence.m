function are_equivalent = check_periodic_equivalence(matrix1, matrix2)
% 检查两个相同大小的矩阵在周期性边界条件下是否等价。
%   matrix1, matrix2: 输入的两个矩阵，必须大小相同。
%   are_equivalent: 如果等价，则为 true；否则为 false。

% 1. 确保两个矩阵大小相同
if ~isequal(size(matrix1), size(matrix2))
    error('输入矩阵的大小必须相同。');
end

% 2. 获取矩阵的维度
[rows, cols] = size(matrix1);

% 3. 遍历所有可能的行和列的平移
%   对 matrix1 进行所有可能的周期性移位
for row_shift = 0:rows-1
    for col_shift = 0:cols-1
        % 使用 circshift 函数进行周期性移位
        % circshift(A, [r, c]) 将矩阵 A 向上/下移动 r 行，左/右移动 c 列
        shifted_matrix = circshift(matrix1, [row_shift, col_shift]);
        
        % 检查移位后的矩阵是否与 matrix2 相同
        if isequal(shifted_matrix, matrix2)
            are_equivalent = true;
            return; % 找到一个匹配，立即返回
        end
    end
end

% 4. 如果所有移位都尝试过了，但没有找到匹配，则它们不等价
are_equivalent = false;

end