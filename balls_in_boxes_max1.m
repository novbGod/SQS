%L<=A，每个箱子至多放一个小球,L为小球数量，A为箱子数量
%输入L、A，返回一个列元胞，储存所有情况
function cell_array = balls_in_boxes_max1(L, A)
    % 参数检查：A需为正整数，L范围需满足 0 ≤ L ≤ A
    if A <= 0 || L < 0 || L > A
        cell_array = cell(0, 1);
        return;
    end
    
    % 处理L=0的特殊情况（所有箱子为空）
    if L == 0
        cell_array = {zeros(1, A)};
        return;
    end
    
    % 生成所有组合的索引（从A个位置选L个放球）
    combinations = nchoosek(1:A, L);
    num_comb = size(combinations, 1);
    cell_array = cell(num_comb, 1);
    
    % 为每个组合生成对应的0-1分布向量
    for i = 1:num_comb
        vec = zeros(1, A);               % 初始化全0向量
        vec(combinations(i, :)) = 1;     % 选中位置置1
        cell_array{i} = vec;             % 存入元胞数组
    end
end
