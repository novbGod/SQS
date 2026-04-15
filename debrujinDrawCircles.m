
% PLOTCONCENTRICBINARYSECTORS 绘制七个长度为 2^4 到 2^16 的同心二进制扇环。
%
% 0 绘制为红色扇环，1 绘制为蓝色扇环。圆环之间无缝隙。
% 最内圈 (2^4) 是一个完整的圆盘。
%
% 示例用法 (直接在 MATLAB 命令窗口运行):
%   plotConcentricBinarySectors

    % --- 1. 定义参数和数据生成 ---

    % 七个数组的长度：2^4, 2^6, 2^8, 2^10, 2^12, 2^14, 2^16
    dataExponents = 4:2:16;
    dataLengths = 2.^dataExponents;
    numRings = length(dataLengths);
    
    % 定义每个圆环的内外半径 (相邻圆环之间没有缝隙)
    % 环 k 的内半径是 k-1，外半径是 k。
    % 环 1 (最内圆盘): 内半径 0, 外半径 1
    radii_in = (0:numRings-1);
    radii_out = (1:numRings);
    maxRadius = numRings;
    
    % 生成随机二进制数据
    binaryDataCell = array;
    % for k = 1:numRings
    %     L = dataLengths(k);
    %     % 生成随机的 0 或 1 数组
    %     binaryDataCell{k} = randi([0, 1], 1, L);
    % end

    % --- 2. 初始化绘图 ---

    figure('Color', 'w', 'Position', [100, 100, 800, 800]); % 白色背景
    hold on;
    
    titleText = '七个同心二进制扇环可视化 (0: 红色, 1: 蓝色)';
    title(titleText, 'FontSize', 16); 
    
    % 调整坐标轴，确保所有圆环可见且为正圆
    axis([-maxRadius, maxRadius, -maxRadius, maxRadius]);
    axis equal; 
    axis off;   % 隐藏坐标轴
    
    % --- 3. 循环绘制每个扇环 ---

    for k = 1:numRings
        L = dataLengths(k);
        R_in = radii_in(k);
        R_out = radii_out(k);
        data = binaryDataCell{k};
        
        % 计算每个元素的角度范围 (弧度)
        delta_theta = 2*pi / L;

        for i = 1:L
            % 当前扇区/扇环的起始和结束角度
            theta_start = (i - 1) * delta_theta;
            theta_end = i * delta_theta;
            
            % 确定颜色: '0' -> Red (红), '1' -> Blue (蓝)
            if data(i) == 0
                sector_color = [1, 0, 0]; % 红色
            else
                sector_color = [0, 0, 1]; % 蓝色
            end
            
            % --- 绘制扇环段 (四边形) ---
            % 扇环的四个极坐标点 (R, theta) 转换为笛卡尔坐标 (X, Y)
            
            % P1: 外弧起始点 (R_out, theta_start)
            X1 = R_out * cos(theta_start);
            Y1 = R_out * sin(theta_start);
            
            % P2: 外弧结束点 (R_out, theta_end)
            X2 = R_out * cos(theta_end);
            Y2 = R_out * sin(theta_end);
            
            % P3: 内弧结束点 (R_in, theta_end)
            X3 = R_in * cos(theta_end);
            Y3 = R_in * sin(theta_end);
            
            % P4: 内弧起始点 (R_in, theta_start)
            X4 = R_in * cos(theta_start);
            Y4 = R_in * sin(theta_start);
            
            % 组合点的 X 和 Y 坐标 (注意顺序，以正确形成四边形)
            X_patch = [X1, X2, X3, X4];
            Y_patch = [Y1, Y2, Y3, Y4];
            
            % 使用 patch 函数绘制
            % EdgeColor 设置为 'none' 确保扇环之间没有黑线，实现无缝连接
            patch(X_patch, Y_patch, sector_color, 'EdgeColor', 'none'); 
        end
    end

    hold off;
