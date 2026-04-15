function plotStatisticalData(data1, data2, factor, x_values)
    % plotStatisticalData - 计算两组数据的统计量并在同一图中绘制带误差棒的曲线
    %
    % 输入:
    %   data1, data2 - 矩阵，每行是一次测量，每列是一个自变量点
    %   factor, 为了使方差清晰显示，乘上一个因子
    %   x_values     - (可选) 自变量的向量。如果未提供，则默认为列索引
    
    % 获取列数（自变量点的个数）
    num_points = size(data1, 2);
    
    % 如果没有提供自变量，则生成默认索引
    if nargin < 4 || isempty(x_values)
        x_values = 1:num_points;
    end
    
    % --- 统计计算 ---
    % 计算第一组数据的均值和标准差 (dimension 1 表示按列计算)
    mu1 = mean(data1, 1);
    sigma1 = std(data1, 0, 1) * factor;
    
    % 计算第二组数据的均值和标准差
    mu2 = mean(data2, 1);
    sigma2 = std(data2, 0, 1) * factor;
    
    % --- 绘图 ---
    figure('Color', 'w');
    hold on; grid on;
    
    % 绘制第一组数据：蓝色，圆圈标记
    e1 = errorbar(x_values, mu1, sigma1, '-o', 'Color', [0 0.4470 0.7410], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0 0.4470 0.7410]);
    
    % 绘制第二组数据：红色，方块标记
    e2 = errorbar(x_values, mu2, sigma2, '-s', 'Color', [0.8500 0.3250 0.0980], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
    
    % 设置误差棒的透明度（可选，MATLAB R2020a+ 支持）
    % 若版本较旧，可注释掉下面两行
    e1.CapSize = 8;
    e2.CapSize = 8;
    
    % 美化图形
    
    set(gca, 'FontSize', 12);
    
    hold off;
end