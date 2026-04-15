function plot_matrix_balls(matrices_cell)%输入8*4矩阵
% 在一个窗口的不同子图中绘制元胞数组中的矩阵。
% 0 的位置不绘制，1 和 2 的位置分别用不同颜色的小球表示。
b1 = matrices_cell;
for i = 1:length(matrices_cell)
b = b1{i};
b(:,[1,3,5,7]) = b(:,1:4);
b(:,[2,4,6,8]) = zeros(8,4);
[b(2:2:8,1:2:7),b(2:2:8,2:2:8)] = deal(b(2:2:8,2:2:8),b(2:2:8,1:2:7));
matrices_cell{i} = b;
end


% 1. 确定子图布局
num_matrices = length(matrices_cell);
if num_matrices == 0
    warning('输入元胞数组为空，没有矩阵可供绘制。');
    return;
end

% 自动计算一个接近正方形的子图网格
rows = ceil(sqrt(num_matrices));
cols = ceil(num_matrices / rows);

% 2. 创建图形窗口
figure;
set(gcf, 'Color', 'w'); % 设置窗口背景为白色

% 3. 遍历并绘制每个矩阵
for i = 1:num_matrices
    current_matrix = matrices_cell{i};
    
    % 激活或创建第 i 个子图
    subplot(rows, cols, i);
    
    % 获取矩阵大小
    [m, n] = size(current_matrix);
    
    % 4. 提取值为 1 和 2 的坐标
    % 使用 find 函数，它返回元素的线性索引
    [row_1, col_1] = find(current_matrix == 1);
    [row_2, col_2] = find(current_matrix == 2);
    
    % 5. 绘制小球
    hold on; % 允许在同一坐标系上叠加绘图
    
    % 绘制值为 1 的小球（例如，蓝色）
    scatter(col_1, row_1, 150, 'filled', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
    
    % 绘制值为 2 的小球（例如，红色）
    scatter(col_2, row_2, 150, 'filled', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    
    hold off;
    
    % 设置坐标轴和标题
    axis([0.5, n + 0.5, 0.5, m + 0.5]); % 调整坐标轴范围，使小球居中
    set(gca, 'YDir', 'reverse'); % 使 y 轴从上到下增长，符合矩阵的索引习惯
    xticks(1:n);
    yticks(1:m);
    grid on;
    axis equal;
    title(['矩阵 #', num2str(i)]);
end

end