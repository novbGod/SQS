clear;
row = 8;
column = 4;

fillPlace = [0,row,1,2,2+row];%顶点加上此数组则得到此顶点对应的五体的索引

matrix = zeros(row,column);
coords_vec = [1,1]+[0,0;0,1;1,0;2,0;2,1];
matrix(sub2ind(size(matrix), coords_vec(:, 1), coords_vec(:, 2))) = 1;
%1代表A，2代表B，0代表空，初始化矩阵，固定全A五体在最开始
body5 = 1 + de2bi(0:31, 5, 'left-msb');
[X, Y] = meshgrid(1:8, 1:4);
accessibleIndex = zeros(row*column,2);
accessibleIndex(:) = [X(:),Y(:)] ;
accessibleIndex(1,:) = [];
body5(1,:) = [];
b1 = solve_two(matrix,accessibleIndex,body5);
side_length = ceil(sqrt(length(b1)));
b2 = b1;
b1 = get_unique_matrices(b1);

%检验是否均符合五体
for i = 1:length(b1)
    count5body(i) = body5Determine(b1{i});
end

plot_matrix_balls(b1);

%分别画图
for o = 1:1
b = b1{116};
b(:,[1,3,5,7]) = b(:,1:4);
b(:,[2,4,6,8]) = zeros(8,4);
[b(2:2:8,1:2:7),b(2:2:8,2:2:8)] = deal(b(2:2:8,2:2:8),b(2:2:8,1:2:7));

A = b;
A = [A,A,A;A,A,A;A,A,A];

% 获取矩阵的维度
[rows, cols] = size(A);

% 2. 创建一个新的图形窗口
figure;
hold on; % 允许在同一张图上绘制多个对象
grid on; % 添加网格
% 3. 遍历矩阵并绘制小球
for i = 1:rows
    for j = 1:cols
        % 获取当前元素的值
        value = A(i, j);

        % 根据值选择颜色和标记样式
        if value == 1
            color = 'b';  % 蓝色
            marker = 'o'; % 圆圈
        elseif value == 2
            color = 'r';  % 红色
            marker = 'o'; % 圆圈
        else 
            continue;
        end

        % 绘制小球
        plot(j, i, 'Marker', marker, 'MarkerSize', 15, 'MarkerFaceColor', color, 'MarkerEdgeColor', color);
    end
end
end

% 4. 设置图表属性
title('矩阵的方格图（小球形式）');
xlabel('列索引');
ylabel('行索引');

% 设置坐标轴范围和刻度，以确保图表清晰
xlim([0.5, cols + 0.5]);
ylim([0.5, rows + 0.5]);
set(gca, 'YDir', 'reverse'); % 使Y轴方向与矩阵索引一致（从上到下）

% 添加图例
legend('值=1', '值=2');

hold off; % 结束多

% 
% function [success, new_matrix] = solve(matrix, accessibleIndex, shapes_to_fill)
% % 1. 基本情况（Base Case）
% %   如果所有形状都已成功填入，则返回 true
% if isempty(shapes_to_fill)
%     success = true;
%     new_matrix = matrix; % 必须为 new_matrix 赋值
%     return;
% end
% 
% % 在函数开头为输出参数赋一个默认值
% success = false;
% new_matrix = matrix;
% 
% % 2. 递归调用
% %   获取当前要处理的形状
% current_shape = shapes_to_fill(1,:);
% remaining_shapes = shapes_to_fill(2:end,:);
% 
% % 按顺序遍历每一个可能的顶点位置
% for i = 1:length(accessibleIndex)
%     % 3. 判断是否满足条件
%     %   检查此形状在当前顶点位置是否可以填入（不冲突）
%     idx = accessibleIndex(i,:);
%     shape = idx+[0,0;0,1;1,0;2,0;2,1];%填入所有点的坐标
% 
%     % 假设 check_conflicts 能够正确处理 current_shape
%     if ~check_conflicts(matrix, shape(:,1), shape(:,2), current_shape)
% 
%         % 4. 做出选择（前进）
%         %   填入此形状，创建一个新的矩阵
%         temp_matrix = matrix;
%         % 1. 将超出边界的索引按周期性转化
%         rows = shape(:,1);
%         cols = shape(:,2);
%         [m, n] = size(matrix);
%         rows = mod(rows - 1, m) + 1;
%         cols = mod(cols - 1, n) + 1;
%         % 4. 使用有效索引进行赋值
%         temp_matrix(sub2ind(size(matrix),rows,cols)) = current_shape; 
% 
%         new_accessibleIndex = accessibleIndex([1:i-1,i+1:end],:);
% 
%         %   递归调用，解决剩下的问题
%         [child_success, result_matrix] = solve(temp_matrix, new_accessibleIndex, remaining_shapes);
% 
%         if child_success
%             %   如果子调用成功，将它的结果赋值给本函数的输出，并返回
%             success = true;
%             new_matrix = result_matrix;
%             return;
%         end
%         % 5. 回溯（撤销选择）
%         %   如果上一步的递归调用失败，我们什么也不做，for 循环会自动尝试下一个位置
%     end
% end
% 
% % 6. 如果所有顶点都尝试失败，函数会保持默认值并返回
% end

%寻找所有可行结构
function solutions = solve_all(matrix, accessibleIndex, shapes_to_fill)
% 初始化一个空的元胞数组来存储所有找到的解决方案
solutions = {};

% 1. 基本情况（Base Case）
%   如果所有形状都已成功填入，则说明我们找到了一个完整的解决方案
if isempty(shapes_to_fill)
    solutions = {matrix};
    return;
end

% 2. 递归调用
%   获取当前要处理的形状
current_shape = shapes_to_fill(1,:);
remaining_shapes = shapes_to_fill(2:end,:);

% 按顺序遍历每一个可能的顶点位置
for i = 1:size(accessibleIndex,1)
    % 3. 判断是否满足条件
    idx = accessibleIndex(i,:);
    shape = idx + [0,0;0,1;1,0;2,0;2,1];

    % 假设 check_conflicts 能够正确处理 current_shape
    if ~check_conflicts(matrix, shape(:,1), shape(:,2), current_shape)
        % 4. 做出选择（前进）
        temp_matrix = matrix;
        rows = shape(:,1);
        cols = shape(:,2);
        [m, n] = size(matrix);
        rows = mod(rows - 1, m) + 1;
        cols = mod(cols - 1, n) + 1;
        temp_matrix(sub2ind(size(matrix),rows,cols)) = current_shape;
        
        % 从 accessibleIndex 中移除当前使用的索引
        new_accessibleIndex = accessibleIndex([1:i-1,i+1:end],:);

        %   递归调用，解决剩下的问题
        %   获取所有可能的子解
        child_solutions = solve_all(temp_matrix, new_accessibleIndex, remaining_shapes);

        % 5. 处理子解
        %   如果子调用返回了解决方案，将它们添加到我们的 solutions 列表中
        if ~isempty(child_solutions)
            solutions = [solutions, child_solutions];
        end
        % 6. 无需回溯，因为 temp_matrix 是一个新的副本
        %    for 循环会自动尝试下一个位置
    end
end
end

function solutions = solve_two(matrix, accessibleIndex, shapes_to_fill)
% 初始化一个空的元胞数组来存储找到的解决方案
solutions = {};
solution_count = 0; % 解决方案计数器

% 1. 基本情况（Base Case）
% 如果所有形状都已成功填入，则说明我们找到了一个完整的解决方案
if isempty(shapes_to_fill)
    solutions = {matrix};
    return;
end

% 2. 递归调用
% 获取当前要处理的形状
current_shape = shapes_to_fill(1,:);
remaining_shapes = shapes_to_fill(2:end,:);

% 按顺序遍历每一个可能的顶点位置
for i = 1:size(accessibleIndex, 1) % 使用 size(..., 1) 确保正确遍历行数
    % 3. 判断是否满足条件
    idx = accessibleIndex(i,:);
    shape = idx + [0,0;0,1;1,0;2,0;2,1];

    % 假设 check_conflicts 能够正确处理 current_shape
    if ~check_conflicts(matrix, shape(:,1), shape(:,2), current_shape)
        % 4. 做出选择（前进）
        temp_matrix = matrix;
        rows = shape(:,1);
        cols = shape(:,2);
        [m, n] = size(matrix);
        rows = mod(rows - 1, m) + 1;
        cols = mod(cols - 1, n) + 1;
        temp_matrix(sub2ind(size(matrix),rows,cols)) = current_shape;
        
        % 从 accessibleIndex 中移除当前使用的索引
        new_accessibleIndex = accessibleIndex([1:i-1,i+1:end],:);

        % 递归调用，解决剩下的问题
        child_solutions = solve_two(temp_matrix, new_accessibleIndex, remaining_shapes);

        % 5. 处理子解
        if ~isempty(child_solutions)
            % 如果子调用返回了解决方案，将它们添加到我们的 solutions 列表中
            solutions = [solutions, child_solutions];
            solution_count = length(solutions);

            % 如果已经找到两个解，则立即返回
            if solution_count >= 17
               pause;
                % return;
            end
        end
    end
end
end