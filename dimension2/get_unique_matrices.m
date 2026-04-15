function unique_mats = get_unique_matrices(cell_of_matrices)
% 检查一个元胞数组中周期性边界条件下等价的矩阵，并返回唯一的集合。
%   cell_of_matrices: 包含大小相同的矩阵的元胞数组。
%   unique_mats: 包含所有唯一（不等价）矩阵的元胞数组。

% 1. 如果输入为空或只有一个矩阵，则没有需要处理的等价情况
if isempty(cell_of_matrices) || length(cell_of_matrices) == 1
    unique_mats = cell_of_matrices;
    return;
end

% 2. 初始化结果元胞数组，将第一个矩阵作为第一个唯一矩阵
unique_mats = {cell_of_matrices{1}};

% 3. 遍历元胞数组中的剩余矩阵
for i = 2:length(cell_of_matrices)
    current_matrix = cell_of_matrices{i};
    is_equivalent_found = false;
    
    % 4. 检查当前矩阵是否与已有的任何唯一矩阵等价
    for j = 1:length(unique_mats)
        unique_matrix = unique_mats{j};
        
        % 利用你之前提供的函数来检查等价性
        if check_periodic_equivalence(current_matrix, unique_matrix)
            is_equivalent_found = true;
            break; % 如果找到等价矩阵，跳出内层循环
        end
    end
    
    % 5. 如果当前矩阵与所有已有的唯一矩阵都不等价，则将其添加到结果中
    if ~is_equivalent_found
        unique_mats = [unique_mats, {current_matrix}];
    end
end

end