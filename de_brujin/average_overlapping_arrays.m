function mean_array = average_overlapping_arrays(cell_of_arrays)
% AVERAGE_OVERLAPPING_ARRAYS 对一组长度不一的数组的重合部分取平均。
%
% 输入:
%   cell_of_arrays - 包含要平均的数组（行向量或列向量）的元胞数组。
%                    例如：{[1 2 3], [4 5], [6 7 8 9]}
%
% 输出:
%   mean_array - 新生成的平均数组，其长度等于输入数组中的最大长度。
%
% 注意: 缺失的位置默认为 NaN，不会参与平均计算。

% 1. 确定最长数组的长度
max_len = 0;
for i = 1:length(cell_of_arrays)
    current_len = length(cell_of_arrays{i});
    if current_len > max_len
        max_len = current_len;
    end
end

% 2. 创建一个 '垫高' (Pad) 矩阵，将所有数组统一长度
%    使用 NaN (Not a Number) 来填充缺失值，NaN 不会参与 sum/mean 运算。
data_matrix = NaN(length(cell_of_arrays), max_len);

for i = 1:length(cell_of_arrays)
    current_array = cell_of_arrays{i};
    data_matrix(i, 1:length(current_array)) = current_array;
end

% 3. 计算每个位置的元素个数 (Count)
%    '~isnan(data_matrix)' 返回一个逻辑矩阵，其中非 NaN 元素为 1。
%    sum(..., 1) 沿着第一维（行）求和，得到每列有多少个有效元素。
valid_counts = sum(~isnan(data_matrix), 1);

% 4. 计算每个位置的元素总和 (Sum)
%    'nansum' 函数会自动忽略 NaN 值进行求和。
total_sum = nansum(data_matrix, 1);

% 5. 计算平均值
%    将总和除以有效元素的个数。
%    如果 valid_counts 中有 0（即某一列所有输入数组都没有元素），
%    除法结果将是 NaN，这是正确的，因为它没有数据可平均。
mean_array = total_sum ./ valid_counts;

% 6. (可选) 清理：将可能出现的 Inf 替换为 0 或 NaN (通常不会出现 Inf)
% mean_array(isinf(mean_array)) = NaN; 
% mean_array(isnan(mean_array) & valid_counts == 0) = 0; 

end