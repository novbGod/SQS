
clear;

body8 = 1 + de2bi(0:2^8-1, 8, 'left-msb');
matrix = [2,2,0,0,0,0,0,0;2,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0;...
0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,1;0,0,0,0,0,0,1,1];%初始矩阵
accessibleIndex = [1,3;1,4;1,5;1,6;1,7;1,8;2,8;3,8;4,8;5,8;6,8;...
2,2;3,3;4,4;5,5;6,6;7,7;2,3;2,4;2,5;2,6;2,7;3,4;3,5;3,6;3,7;4,5;4,6;4,7;5,6;5,7;6,7;...
1,8;2,8;3,8;4,8;5,8;6,8] ;%以八体的最上面的点为顶点，所有可填的位置
[success,mat] = solve(matrix,accessibleIndex,body8);
mat_90 = flipud(mat)';
mat_180 = rot90(mat,2);
mat_270 = fliplr(mat)';
Big_Matrix = [mat, mat_90;
mat_270, mat_180];
% figure;
% imagesc(Big_Matrix);
disp(Big_Matrix);

function [success, new_matrix] = solve(matrix, accessibleIndex, shapes_to_fill)
shapeKind = shapes_to_fill;

% 1. 基本情况（Base Case）
% 如果所有形状都已成功填入，则返回 true
if all(matrix(triu(true(size(matrix)))) ~= 0)
    mat_90 = flipud(matrix)';
    mat_180 = rot90(matrix,2);
    mat_270 = fliplr(matrix)';
    Big_Matrix = [matrix, mat_90;
    mat_270, mat_180];
    count = square8bodyCount(Big_Matrix);
    if length(count) == length(unique(count))
        success = true;
        new_matrix = matrix; % 必须为 new_matrix 赋值
        return;
    end
end

% 在函数开头为输出参数赋一个默认值
success = false;
new_matrix = matrix;

% 2. 递归调用
% 获取当前要填入的索引
current_idx = accessibleIndex(1,:);
idxKan = current_idx;
allIdx = current_idx + [0,0;1,0;1,1;1,2;2,-1;2,0;2,1;3,1];
remaining_idx = accessibleIndex(2:end,:);
% 按顺序遍历每一个八体
for i = 1:length(shapeKind)
    % 3. 判断是否满足条件
    % 检查此形状在当前顶点位置是否可以填入（不冲突）
    current_shape = shapeKind(i,:);
    current_idx = symmetric_map_subdiagonal(size(matrix,1),allIdx(:,1),allIdx(:,2));%填入所有点的坐标
    current_idx = [current_idx; fliplr(current_idx)];%根据对称性延拓
    % 识别8体在对称性延拓后会不会自我冲突
    [~, ~, row_mapping] = unique(current_idx, 'rows');
    % 根据行映射对 B 进行分组
    grouped_b_values = accumarray(row_mapping, [current_shape,current_shape], [], @(x) {x});
    % 检查每个分组中的元素是否都相同
    is_consistent = all(cellfun(@(x) isscalar(unique(x)), grouped_b_values));
    % 判定此位置是否能无冲突地填入
    if is_consistent
        if ~check_conflicts(matrix, current_idx(:,1), current_idx(:,2), [current_shape,current_shape])
            % 4. 做出选择（前进）
            % 填入此形状，创建一个新的矩阵
            temp_matrix = matrix;
            % 1. 将超出边界的索引按周期性转化
            rows = current_idx(:,1);
            cols = current_idx(:,2);
            [m, n] = size(matrix);
            rows = mod(rows - 1, m) + 1;
            cols = mod(cols - 1, n) + 1;
            % 4. 使用有效索引进行赋值
            temp_matrix(sub2ind(size(matrix),rows,cols)) = [current_shape,current_shape];
            %删除所有元胞shapes_to_fill中所有矩阵中的current_shape去除
            new_shapes = shapeKind([1:i-1,i+1:end],:);
            % 递归调用，解决剩下的问题
            [child_success, result_matrix] = solve(temp_matrix, remaining_idx, new_shapes);
            if child_success
                % 如果子调用成功，将它的结果赋值给本函数的输出，并返回
                success = true;
                new_matrix = result_matrix;
                return;
            end
            % 5. 回溯（撤销选择）
            % 如果上一步的递归调用失败，我们什么也不做，for 循环会自动尝试下一个位置
        end
    end
end
% 6. 如果所有顶点都尝试失败，函数会保持默认值并返回
end