% =========================================================================
% 并行化版本的主脚本
% =========================================================================
clear;
close all;
clc;

fprintf('正在启动并行池...\n');
% 启动并行池（如果尚未启动）。MATLAB 将根据您的 CPU 核心数自动确定工作进程数量。
if isempty(gcp('nocreate'))
    parpool('local');
end

% --- 1. 初始化 ---
% 定义所有可能的 256 个八体形状 (1代表实体, 2代表空)
% 注意：原代码 body8 = 1 + de2bi(...) 会产生 1 和 2。这里假设 1 是实体，0 是空。
% 为了与逻辑匹配，我们直接使用 0 和 1，并在放置时再处理数值。
body8 = de2bi(0:2^8-1, 8, 'left-msb');

% 初始矩阵 (0 代表未填充)
matrix = [2,2,0,0,0,0,0,0;
    2,0,0,0,0,0,0,0;
    0,0,0,0,0,0,0,0;
    0,0,0,0,0,0,0,0;
    0,0,0,0,0,0,0,0;
    0,0,0,0,0,0,0,0;
    0,0,0,0,0,0,0,1;
    0,0,0,0,0,0,1,1];
matrix = uint8(matrix);
% 所有可填的位置的顶点坐标
accessibleIndex = [1,3;1,4;1,5;1,6;1,7;1,8;2,8;3,8;4,8;5,8;6,8;...
    2,2;3,3;4,4;5,5;6,6;7,7;2,3;2,4;2,5;2,6;2,7;3,4;3,5;3,6;3,7;4,5;4,6;4,7;5,6;5,7;6,7;...
    1,8;2,8;3,8;4,8;5,8;6,8] ;

% --- 2. 并行求解 ---
fprintf('开始并行搜索...\n');
tic; % 开始计时

% 提取第一个要尝试的位置和剩余位置
current_accessible_idx = accessibleIndex(1,:);
remaining_idx = accessibleIndex(2:end,:);

% 定义八体相对于顶点的所有8个点的相对坐标
allIdx_offset = [0,0;1,0;1,1;1,2;2,-1;2,0;2,1;3,1];
allIdx = current_accessible_idx + allIdx_offset;

num_shapes = size(body8, 1);
solution_found = false;
final_mat = [];

% 为了在 parfor 中存储结果，我们使用一个 cell 数组
% parfor 要求 sliced output variable 在每次迭代中都被赋值
result_matrices = cell(1, num_shapes);
success_flags = false(1, num_shapes);

% 使用 parfor 并行处理第一层的搜索
parfor i = 1:num_shapes
    current_shape_binary = body8(i,:);
    % 将形状从 0/1 转换为 1/2 (假设 1:实体, 2:空)
    current_shape = current_shape_binary + 1;

    % 获取当前形状在矩阵中的所有坐标
    current_coords = symmetric_map_subdiagonal(size(matrix,1), allIdx(:,1), allIdx(:,2));
    current_coords = [current_coords; fliplr(current_coords)]; % 根据对称性延拓

    % 检查对称延拓后是否自相冲突
    [~, ~, row_mapping] = unique (current_coords, 'rows');
    grouped_b_values = accumarray(row_mapping, [current_shape, current_shape], [], @(x) {x});
    is_consistent = all(cellfun(@(x) isscalar(unique(x)), grouped_b_values));

    % 如果此位置可以无冲突地填入
    if is_consistent && ~check_conflicts(matrix, current_coords(:,1), current_coords(:,2), [current_shape, current_shape])
        % 填入此形状，创建新矩阵
        temp_matrix = matrix;
        rows = mod(current_coords(:,1) - 1, size(matrix,1)) + 1;
        cols = mod(current_coords(:,2) - 1, size(matrix,2)) + 1;
        temp_matrix(sub2ind(size(matrix), rows, cols)) = [current_shape, current_shape];

        % 准备用于递归的剩余形状列表
        % 注意：body8 在 parfor 中是 broadcast variable，不能直接修改
        % 我们需要创建一个新的变量
        remaining_shapes = body8([1:i-1, i+1:end], :);

        % === 调用串行递归求解器 ===
        [child_success, result_matrix] = solve_recursive(temp_matrix, remaining_idx, remaining_shapes);

        if child_success
            success_flags(i) = true;
            result_matrices{i} = result_matrix; % 存储结果
        end
    end
end

% --- 3. 收集结果 ---
% 在所有并行任务完成后，检查是否找到了解
for i = 1:num_shapes
    if success_flags(i)
        final_mat = result_matrices{i};
        solution_found = true;
        fprintf('成功找到一个解！\n');
        break; % 找到第一个解后立即退出
    end
end

if ~solution_found
    fprintf('未找到满足条件的解。\n');
end

toc; % 结束计时

% --- 4. 显示结果 ---
if solution_found
    mat = final_mat;
    mat_90 = flipud(mat)';
    mat_180 = rot90(mat,2);
    mat_270 = fliplr(mat)';
    Big_Matrix = [mat, mat_90;
        mat_270, mat_180];
    disp(Big_Matrix);
    % figure;
    % imagesc(Big_Matrix);
    % title('找到的解');
    % axis equal tight;
    % colorbar;
end

% --- 5. 清理 ---
fprintf('关闭并行池。\n');
delete(gcp('nocreate'));

quit

% =========================================================================
% 递归求解函数（您的原始 solve 函数，已重命名）
% =========================================================================
function [success, new_matrix] = solve_recursive(matrix, accessibleIndex, shapes_to_fill)

% 1. 基本情况 (Base Case)
if isempty(accessibleIndex) % 如果所有可访问位置都已填完
    % 检查最终矩阵是否满足特定条件
    mat_90 = flipud(matrix)';
    mat_180 = rot90(matrix,2);
    mat_270 = fliplr(matrix)';
    Big_Matrix = [matrix, mat_90; mat_270, mat_180];
    count = square8bodyCount(Big_Matrix); % 假设此函数用于最终校验
    if length(count) == length(unique(count))
        success = true;
        new_matrix = matrix;
        return;
    end
end

% 默认输出
success = false;
new_matrix = matrix;

% 如果没有剩余位置了，但上面的校验没通过，则失败
if isempty(accessibleIndex)
    return;
end

% 2. 递归调用
current_idx = accessibleIndex(1,:);
remaining_idx = accessibleIndex(2:end,:);

allIdx_offset = [0,0;1,0;1,1;1,2;2,-1;2,0;2,1;3,1];
allIdx = current_idx + allIdx_offset;

for i = 1:size(shapes_to_fill, 1)
    current_shape_binary = shapes_to_fill(i, :);
    current_shape = current_shape_binary + 1; % 转换为 1/2

    current_coords = symmetric_map_subdiagonal(size(matrix,1), allIdx(:,1), allIdx(:,2));
    current_coords = [current_coords; fliplr(current_coords)];

    [~, ~, row_mapping] = unique(current_coords, 'rows');
    grouped_b_values = accumarray(row_mapping, [current_shape, current_shape], [], @(x) {x});
    is_consistent = all(cellfun(@(x) isscalar(unique(x)), grouped_b_values));


    % 在 solve_recursive 函数的 for 循环内部
    % ...
    if is_consistent && ~check_conflicts(matrix, current_coords(:,1), current_coords(:,2), [current_shape, current_shape])
            % 4. 前进 (在原矩阵上直接修改)

        % 保存需要修改位置的原始值，以便回溯
        rows = mod(current_coords(:,1) - 1, size(matrix,1)) + 1;
        cols = mod(current_coords(:,2) - 1, size(matrix,2)) + 1;
        linear_indices = sub2ind(size(matrix), rows, cols);
        original_values = matrix(linear_indices);

        % 直接修改 matrix
        matrix(linear_indices) = uint8([current_shape, current_shape]);

        new_shapes = shapes_to_fill([1:i-1, i+1:end], :);

        [child_success, result_matrix] = solve_recursive(matrix, remaining_idx, new_shapes);

        if child_success
            success = true;
            new_matrix = result_matrix;
            return; % 找到解，立即返回
        end

        % 5. 回溯 (撤销修改，恢复 matrix 到进入此循环之前的状态)
        matrix(linear_indices) = uint8(original_values);
    end
    % ...
    
end
% 6. 如果所有形状都尝试失败，则返回默认的 success = false
end

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

%依照8体的要求，根据旋转对称，对角线对称，平分线对称，将其拼成矩形
function matrix = body8triangleToSquare(matrix)
matrix = triu(matrix) + triu(matrix,1)';
matrix = [matrix;flipud(matrix)];
matrix = [matrix,fliplr(matrix)];
end

%识别方形8体近邻，输入一个01三角形矩阵，以每个点为中心方形的左上角顶点，数近邻
%输出一个大小为矩阵总点数的数组

function subsquare_codes = square8bodyCount(matrix)
    matrix = body8triangleToSquare(matrix);%拼凑成完整的
    subsquare_codes = zeros(1, numel(matrix));
    count = 1;
    [row, column] = size(matrix);
    for i = 1:row
        for j = 1:column
            % 考虑周期性边界条件
            % top_left, top_right, bottom_left,c bottom_right
           
            t = matrix(i, j);
            tl = matrix(mod(i, row) + 1, j);
            tr = matrix(mod(i, row) + 1, mod(j, column) + 1);
            r = matrix(mod(i, row) + 1, mod(j+1, column) + 1);
            l = matrix(mod(i+1, row) + 1, mod(j-2,column) + 1);
            bl = matrix(mod(i+1, row) + 1, j);
            br = matrix(mod(i+1, row) + 1, mod(j, column) + 1);
            b = matrix(mod(i+2, row) + 1, mod(j, column) + 1);

            % 将2x2子矩阵编码为4位二进制数
            % 例如：[A B; C D] -> ABCD (二进制)
            subsquare_codes(count) = t*128 + r*64 + l*32 + b*16 + tl*8 + tr*4 + bl*2 + br;
            
            count = count + 1;
        end
    end
end


function new_indices = symmetric_map_subdiagonal(n, indices_row, indices_col)
    % 本函数实现方形矩阵中索引的周期性转换和副对角线对称映射。
    %
    % 输入:
    %   n: 方形矩阵的大小 (n x n)。
    %   indices: 原始多元素的行索引向量，列索引向量，要输入列向量
    %
    % 输出:
    %   new_indices: 对称映射后的新索引向量。

    % 1. 周期性转换 (确保索引在 1 到 n 之间)
    % 使用 mod 函数将索引周期性地映射到 1 到 n 的范围内。
    % MATLAB 的 mod(x, m) 结果范围是 0 到 m-1，所以需要 +1。
    % 这里使用 (x - 1) 来处理，确保当 x 是 n 的倍数时，结果为 n。
    row_orig = indices_row;
    col_orig = indices_col;

    row_period = mod(row_orig - 1, n) + 1;
    col_period = mod(col_orig - 1, n) + 1;

    % 2. 副对角线对称映射
    % 副对角线上的元素满足 i + j = n + 1。
    % 如果一个点是 (i, j)，它关于副对角线的对称点是 (n + 1 - j, n + 1 - i)。
    row_new = n + 1 - col_period;
    col_new = n + 1 - row_period;

    % 3. 将新索引打包成向量
    new_indices = [row_new, col_new];
end