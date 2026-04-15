%对一种分堆情况，列出所有可能顺序组合
function unique_perms = generate_circular_permutations_with_duplicates(elements)
    if length(elements) <= 1 %筛去单元素
        unique_perms = {elements};
        return;
    end
    
    fixed = elements(1); %固定首个堆
    remaining = elements(2:end);
    
    % 为防止存在相同元素导致生成相同排列，生成唯一排列并去重
    [unique_perms_temp, ~] = unique(perms(remaining), 'rows', 'stable');
    
    unique_perms = {};
    for i = 1:size(unique_perms_temp, 1)%去除镜像排列
        current_perm = unique_perms_temp(i, :);
        full_perm = [fixed, current_perm];
        
        if current_perm(1)<=current_perm(end)
            unique_perms{end+1} = full_perm;
        end
    end
    
    % 最终去重（防止因重复元素导致残留重复）
    if ~isempty(unique_perms)
        [~, idx] = unique(cell2mat(unique_perms'), 'rows', 'stable');
        unique_perms = unique_perms(idx);
    end
end
