% --- 步骤 1: 定义参数和生成示例数据 ---

n = log2(length(a)); % 假设 n 为 10 (偶数)，您可以根据实际情况修改
array_length = 2^n;
side_length = 2^(n/2); % 转换后的正方矩阵边长：2^(n/2) = 2^5 = 32

% 生成一个长度为 2^n 的示例 0/1 数组 (随机生成，实际中请用您的数据)
binary_array = a; 

% 小矩阵的边长 (small_side_length)：2^(n/2 - 3)
small_side_length = 2^(n/2 - 3); % 例如：2^(10/2 - 3) = 2^2 = 4

% 划分后的大矩阵的行/列数 (应为 8x8)
map_side = side_length / small_side_length; % 32 / 4 = 8

if map_side ~= 8
    error('根据您提供的公式， n 的值无法得到 8x8 的映射矩阵。请检查 n 的值是否满足 n/2 - 3 得到一个整数，且 2^(n/2) / 2^(n/2 - 3) 等于 8 (即 n >= 6)。');
end

fprintf('n = %d\n', n);
fprintf('正方矩阵边长: %d\n', side_length);
fprintf('小矩阵边长: %d\n', small_side_length);
fprintf('映射矩阵边长: %d x %d\n', map_side, map_side);

% --- 步骤 2: 数组重塑 ---

% 按行转换 (默认是按列，所以需要转置)
square_matrix = reshape(binary_array, side_length, side_length)';

% --- 步骤 3: 矩阵划分与统计 ---

mapping_matrix = zeros(map_side, map_side);

% 遍历 8x8 的划分
for row_idx = 1:map_side % i in 1 to 8
    for col_idx = 1:map_side % j in 1 to 8
        % 计算当前小矩阵的行和列的起始/结束索引
        start_row = (row_idx - 1) * small_side_length + 1;
        end_row = row_idx * small_side_length;
        start_col = (col_idx - 1) * small_side_length + 1;
        end_col = col_idx * small_side_length;
        
        % 提取小矩阵
        sub_matrix = square_matrix(start_row:end_row, start_col:end_col);
        
        % 统计 0 和 1 的数量
        count_onesAll(row_idx,col_idx) = sum(arrayfun(@(x) str2double(x), sub_matrix(:)) == 1);
        count_zerosAll(row_idx,col_idx) = sum(arrayfun(@(x) str2double(x), sub_matrix(:)) == 0);
    end
end

fprintf('映射矩阵 (8x8) 已生成。\n');

% --- 步骤 4: 可视化 (修改版，离散颜色) ---

figure;
hold on;
axis equal;
axis([0, 8, 0, 8]); % 设置坐标轴范围
set(gca, 'YDir', 'reverse'); % 使得矩阵的 (1,1) 在左上角
xticks(0:8); yticks(0:8); % 网格线
grid on;
title(['8x8 映射矩阵可视化 (n=', num2str(n), ') - 离散颜色']);

% 小矩阵的总元素数
total_elements = small_side_length^2;

for row = 1:map_side
    for col = 1:map_side
       
        count_ones = count_onesAll(row,col);
        count_zeros = count_zerosAll(row,col); % 或者 total_elements - count_ones
        
        % 根据 0 和 1 的数量决定颜色
        if count_ones > count_zeros
            color = [1, 0, 0]; % 1 更多，红色
        elseif count_zeros > count_ones
            color = [0, 0, 1]; % 0 更多，蓝色
        else
            color = [0, 0, 0]; % 数量相等，黑色
        end

        % 绘制小球 (圆心在单元格中心，坐标轴从 0 到 8)
        center_x = col - 0.5;
        center_y = row - 0.5;
        
        % 绘制一个填充的圆
        plot(center_x, center_y, 'o', 'MarkerFaceColor', color, ...
             'MarkerEdgeColor', 'k', 'MarkerSize', 30); 
    end
end

hold off;

% 
% % --- 步骤 4: 可视化 ---
% 
% figure;
% hold on;
% axis equal;
% axis([0, 8, 0, 8]); % 设置坐标轴范围
% set(gca, 'YDir', 'reverse'); % 使得矩阵的 (1,1) 在左上角
% xticks(0:8); yticks(0:8); % 网格线
% grid on;
% title(['8x8 映射矩阵可视化 (n=', num2str(n), ')']);
% 
% % 小矩阵的总元素数
% total_elements = small_side_length^2;
% 
% for row = 1:map_side
%     for col = 1:map_side
%         % 解码映射矩阵，获取 1 的数量
%         encoded_value = mapping_matrix(row, col);
%         count_ones = floor(encoded_value / 2^8);
% 
%         % 计算 1 的比例
%         proportion_ones = count_ones / total_elements;
% 
%         % 根据比例设置颜色: 0比例 -> 纯蓝， 1比例 -> 纯红
%         % 使用 HSV 或 RGB 插值。这里使用简单的 RGB 线性插值。
%         % Blue: [0, 0, 1], Red: [1, 0, 0]
%         % Color = (1 - P) * Blue + P * Red
%         % Color = [P, 0, 1-P]
%         color = [proportion_ones, 0, 1 - proportion_ones]; 
% 
%         % 绘制小球 (圆心在单元格中心，坐标轴从 0 到 8)
%         center_x = col - 0.5;
%         center_y = row - 0.5;
% 
%         % 绘制一个填充的圆 (使用 'filled' 标记和适当的 MarkerSize)
%         % MarkerSize 设置为例如 30，使得圆圈能够填充大部分单元格
%         plot(center_x, center_y, 'o', 'MarkerFaceColor', color, ...
%              'MarkerEdgeColor', 'k', 'MarkerSize', 30); 
%     end
% end
% 
% hold off;