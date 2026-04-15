% MATLAB 代码：绘制具有不同元素颜色的数列小球

% --- 1. 定义数据 ---
% 假设这是你的数列，包含 k 种元素。
% 这里的元素值（例如 1, 2, 3, 4）代表不同的类别（k=4）。
clear;
a = generate_debruijn_sequence(2,4);
sequence = a - '0';
sequence = [sequence(end),sequence(1:end-1)];
N = length(sequence); % 数列的长度

% --- 2. 准备绘图数据 ---
% X 坐标：将每个元素依次排列在一行，所以 X 坐标可以是 1, 2, 3, ... N
X = 1:N;
% Y 坐标：都在同一行，所以 Y 坐标都设为 1
Y = ones(1, N);

% C 颜色数据：用于 scatter 函数指定每个点的颜色。
% scatter(X, Y, S, C) 中的 C 可以是一个与 X 长度相同的向量，
% 它的值将映射到当前的颜色图 (colormap) 上。
C = sequence;

% S 大小数据：设置小球的大小（例如 100）。
markerSize = 300; 

% 示例：自定义颜色
unique_elements = unique(sequence);
k = length(unique_elements);
% 定义 k 种元素的 RGB 颜色
custom_colors = [
    255, 222, 89;  % 黄 (R=1, G=0, B=0) 给第一个类别
    152, 245, 249;  % 蓝 给第二个类别
    125, 218, 88;  % 绿 给第三个类别
    1 0.6 0; % 橙色 给第四个类别
    % ... 如果有更多类别，继续添加
]/255;

% 创建一个 N x 3 的颜色矩阵
ColorMatrix = zeros(N, 3);
for i = 1:k
    % 找到属于第 i 个类别的所有点的索引
    idx = (sequence == unique_elements(i));
    % 为这些点指定颜色
    ColorMatrix(idx, :) = repmat(custom_colors(i, :), sum(idx), 1);
end


% --- 3. 绘制图形 ---
figure; % 创建一个新的图形窗口
hold on; % 允许在同一坐标系上添加多个绘图元素 (虽然这里只用了一次 scatter)

% 使用 scatter 函数绘制小球
% 'filled' 选项确保小球是实心的
scatter(X, Y, markerSize, ColorMatrix, 'filled', 'MarkerEdgeColor', 'k');
% ... 之后的设置坐标轴和标题的代码保持不变 ...
% --- 4. 设置图形样式 ---

% 调整坐标轴：让小球位于视图中央
xlim([0.5, N + 0.5]); 
ylim([0.5, 1.5]);


% 移除不必要的元素以使图形更像“一行小球”
set(gca, 'YTick', []); % 移除 Y 轴刻度
xlabel('元素在数列中的位置');
title('具有不同元素颜色的数列可视化');


hold off;

