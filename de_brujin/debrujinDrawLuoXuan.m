plotSpiralBinarySquare(a); 
function plotSpiralBinarySquare(binaryString)
% PLOTSPIRALBINARYSQUARE 将一个 01 字符串按顺时针向内螺旋顺序绘制成一个正方形。
%
% 输入:
%   binaryString - 仅包含 '0' 和 '1' 字符的字符串。
%                  其长度 L 必须满足 L = 2^n 且 n 为偶数。
%
% 示例用法:
%   % 长度 L=16 (n=4, M=4). 
%   plotSpiralBinarySquare('1001101101001110'); 
%
%   % 长度 L=64 (n=6, M=8).
%   plotSpiralBinarySquare('0110101001101010011010100110101001101010011010100110101001101010');

    % --- 输入验证和维度计算 ---
    
    if ~ischar(binaryString)
        error('输入必须是一个01字符串 (char array)。');
    end

    if any(~ismember(binaryString, ['0', '1']))
        error('输入字符串只能包含字符 ''0'' 或 ''1''。');
    end

    L = length(binaryString);
    
    % 检查长度 L 是否为 2^n
    n = log2(L);
    if n ~= floor(n)
        error('输入字符串的长度 L 必须是 2 的幂 (2^n)。');
    end

    % 检查 n 是否为偶数
    if mod(n, 2) ~= 0
        error('长度 L = 2^n，n 必须为偶数。');
    end

    % 计算正方形边长 M = 2^(n/2)
    M = 2^(n/2);
    
    % 将 '0'/'1' 字符串转换为数值数组 (0s and 1s)
    % data(i) = 0 或 1
    data = arrayfun(@(x) str2double(x), binaryString);

    % --- 螺旋填充算法 ---

    % 初始化 M x M 矩阵。我们将 '0' 存储为 1, '1' 存储为 2，以便使用自定义 colormap。
    imageMatrix = zeros(M, M);
    
    % 螺旋边界和数据索引
    min_row = 1;
    max_row = M;
    min_col = 1;
    max_col = M;
    data_idx = 1; % 数据索引，从1到 L

    % 只要还有数据未填充，就继续螺旋
    while data_idx <= L
        
        % 1. 向右 (Right - Top Row)
        % 从 (min_row, min_col) 到 (min_row, max_col)
        for c = min_col:max_col
            if data_idx > L, break; end
            imageMatrix(min_row, c) = data(data_idx) + 1; % 0 -> 1 (Red), 1 -> 2 (Blue)
            data_idx = data_idx + 1;
        end
        min_row = min_row + 1; % 缩小上边界
        if data_idx > L, break; end

        % 2. 向下 (Down - Right Column)
        % 从 (min_row, max_col) 到 (max_row, max_col)
        if min_col <= max_col % 检查是否还有有效的列范围
            for r = min_row:max_row
                if data_idx > L, break; end
                imageMatrix(r, max_col) = data(data_idx) + 1;
                data_idx = data_idx + 1;
            end
            max_col = max_col - 1; % 缩小右边界
        end
        if data_idx > L, break; end

        % 3. 向左 (Left - Bottom Row)
        % 从 (max_row, max_col) 逆序到 (max_row, min_col)
        if min_row <= max_row % 检查是否还有有效的行范围
            for c = max_col:-1:min_col
                if data_idx > L, break; end
                imageMatrix(max_row, c) = data(data_idx) + 1;
                data_idx = data_idx + 1;
            end
            max_row = max_row - 1; % 缩小下边界
        end
        if data_idx > L, break; end

        % 4. 向上 (Up - Left Column)
        % 从 (max_row, min_col) 逆序到 (min_row, min_col)
        if min_col <= max_col % 检查是否还有有效的列范围
            for r = max_row:-1:min_row
                if data_idx > L, break; end
                imageMatrix(r, min_col) = data(data_idx) + 1;
                data_idx = data_idx + 1;
            end
            min_col = min_col + 1; % 缩小左边界
        end
        
    end % while data_idx <= L

    % --- 绘图和可视化 ---
    
    % 创建自定义色图: [R G B]
    % 颜色索引 1 (对应原始 0) -> 红色
    % 颜色索引 2 (对应原始 1) -> 蓝色
    colormapData = [
        1 0 0;  % Red
        0 0 1   % Blue
    ];
    
    figure('Color', 'w'); % 创建一个白色背景的新图窗
    
    % 使用 imagesc 进行绘图，并自动将数据值映射到色图范围
    imagesc(imageMatrix);
    
    % 设置色图
    colormap(colormapData);
    
    % 调整坐标轴，使其看起来是正方形的小格子
    axis equal; 
    axis tight;
    
    % 隐藏坐标轴刻度和标签
    axis off;
    
    % 确保每个小格子的边缘清晰可见
    hold on;
    % 绘制 M x M 的网格线
    % for k = 1:M
    %     plot([0.5, M + 0.5], [k + 0.5, k + 0.5], 'k-', 'LineWidth', 0.5); % 水平线
    %     plot([k + 0.5, k + 0.5], [0.5, M + 0.5], 'k-', 'LineWidth', 0.5); % 垂直线
    % end
    hold off;
    
    % 添加标题
    titleText = sprintf('边长为 %d 的顺时针向内螺旋正方形 (n=%d)\n', M, n);
    title(titleText, 'FontSize', 14);
end
