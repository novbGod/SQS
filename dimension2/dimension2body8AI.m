%我的八体是这样定义的：在4*4胞中，8个格点的位置为(1,2)(2,2)(2,3)(2,4)(3,1)(3,2)(3,3)(4,3)。每个八体的顶点设置为(1,2)
%即[0,1,0,0
%   0,1,1,1
%   2,2,2,0
%   0,0,2,0]是一种八体
%我的计算逻辑是：我需要生成16*16格点内每个八体只出现一次的晶胞。由于16*16的格点计算量过大，我假设存在满足沿对角线对称和沿边平分线对称的矩阵，这样我只需填充一个8*8矩阵的上三角。 
%当我填满了整个上三角后，我再按照对称性延拓，检测得到的大矩阵是否满足要求。
clear;
body8 = 1 + de2bi(0:2^8-1, 8, 'left-msb');
matrix = [2,2,0,0,0,0,0,0;2,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0;...
0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,1;0,0,0,0,0,0,1,1];%初始矩阵
accessibleIndex = [1,2;1,3;1,4;1,5;1,6;1,7;1,8;2,8;3,8;4,8;5,8;6,8;...
2,2;3,3;4,4;5,5;6,6;7,7;2,3;2,4;2,5;2,6;2,7;3,4;3,5;3,6;3,7;4,5;4,6;4,7;5,6;5,7;6,7];%顶点所有可填的位置
[success,mat] = solve(matrix,accessibleIndex,body8,0);
mat_90 = flipud(mat)';
mat_180 = rot90(mat,2);
mat_270 = fliplr(mat)';
Big_Matrix = [mat, mat_90;
mat_270, mat_180];
% figure;
% imagesc(Big_Matrix);
disp(Big_Matrix);

function [success, new_matrix] = solve(matrix, accessibleIndex, shapes_to_fill,count)
shapeKind = shapes_to_fill;
count = count + 1;%记录目前递归计算的层数
% 1. 基本情况（Base Case）
% 如果所有位点都已成功填入，则检查对称延拓后是否所有八体出现且仅出现一次，若是，则返回 true
if all(matrix ~= 0)
    mat_90 = flipud(matrix)';
    mat_180 = rot90(matrix,2);
    mat_270 = fliplr(matrix)';
    Big_Matrix = [matrix, mat_90;
    mat_270, mat_180];
    count8Body = square8bodyCount(Big_Matrix);
    if length(count8Body) == length(unique(count8Body))
        success = true;
        new_matrix = matrix; % 必须为 new_matrix 赋值
        return;
    else 
        success = false;
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
idxKan = current_idx;%方便查看计算到了哪一步
allIdx = current_idx + [0,0;1,0;1,1;1,2;2,-1;2,0;2,1;3,1];
remaining_idx = accessibleIndex(2:end,:);
% 按顺序在此格点遍历每一个八体
for i = 1:length(shapeKind)
    % 3. 判断是否满足条件
    % 检查此形状在当前顶点位置是否可以填入（不冲突）
    current_shape = shapeKind(i,:);
    current_idx = [min(allIdx(:,1), 17 - allIdx(:,1)),min(allIdx(:,2), 17 - allIdx(:,2))];%填入所有点的坐标,根据8.5边平分线对称，将超出8*8格点的坐标镜像回来
    current_idx = [current_idx; fliplr(current_idx)];%根据对角线对称性延拓
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
            % 4. 使用有效索引进行赋值
            temp_matrix(sub2ind(size(matrix),rows,cols)) = [current_shape,current_shape];
            %删除所有元胞shapes_to_fill中所有矩阵中的current_shape去除
            new_shapes = shapeKind([1:i-1,i+1:end],:);
            % 递归调用，解决剩下的问题
            [child_success, result_matrix] = solve(temp_matrix, remaining_idx, new_shapes,count);
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
% 6. 如果所有顶点都尝试失败，函数会保持默认值并返回，并输出当前运算位点
    if count <= 3
        disp(matrix);
        disp(sprintf('%d %d',count, idxKan));
    elseif count <= 7
        disp(sprintf('%d %d',count, idxKan));
    end
end


%识别方形8体近邻，输入一个01三角形矩阵，以每个点为中心方形的左上角顶点，数近邻
%输出一个大小为矩阵总点数的数组

function subsquare_codes = square8bodyCount(matrix)
    matrix = matrix - 1;
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

            % 将8体子矩阵编码为8位二进制数
            subsquare_codes(count) = t*128 + r*64 + l*32 + b*16 + tl*8 + tr*4 + bl*2 + br;
            
            count = count + 1;
        end
    end
end


function has_conflict = check_conflicts(matrix, row_indices, col_indices, new_elements)
% CHECK_CONFLICTS_OPTIMIZED 检测在指定位置填入新元素是否与矩阵现有元素冲突，使用向量化方法。
%输入参数依次为原有矩阵，填入元素的行索引，列索引，要填入的元素
% 使用线性索引将行和列转换为单个索引

% 1. 强制将所有输入向量转换为列向量，确保维度一致
row_indices = row_indices(:);
col_indices = col_indices(:);
new_elements = new_elements(:);

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

