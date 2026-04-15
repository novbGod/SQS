function plotDualAxisStatisticalData(data1, data2, x_values)
    % plotDualAxisStatisticalData - 均值画左轴，标准差画右轴
    % 输入:
    %   data1, data2 - 矩阵，行对应重复实验，列对应不同自变量点
    %   x_values     - 自变量向量（可选）

    % --- 1. 预处理数据 ---
    num_points = size(data1, 2);
    if nargin < 3 || isempty(x_values)
        x_values = 1:num_points;
    end

    % 计算统计量
    mu1 = mean(data1, 1);
    sig1 = std(data1, 0, 1);
    mu2 = mean(data2, 1);
    sig2 = std(data2, 0, 1);

    % --- 2. 绘图配置 ---
    figure('Color', 'w', 'Position', [100, 100, 800, 500]);
    hold on;

    % --- 左侧 Y 轴：绘制均值 ---
    yyaxis left
    p1_mu = plot(x_values, mu1, '-o', 'LineWidth', 1.5, 'Color', [0 0.45 0.74]);
    p2_mu = plot(x_values, mu2, '-s', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.1]);
    
    ylabel('Mean Value (Average)');
    set(gca, 'YColor', 'k'); % 保持左轴颜色为黑色（可选）

    % --- 右侧 Y 轴：绘制标准差 ---
    yyaxis right
    p1_sig = plot(x_values, sig1, '--o', 'LineWidth', 1.2, 'Color', [0 0.45 0.74], 'MarkerSize', 4);
    p2_sig = plot(x_values, sig2, '--s', 'LineWidth', 1.2, 'Color', [0.85 0.33 0.1], 'MarkerSize', 4);
    
    ylabel('Standard Deviation (\sigma)');
    set(gca, 'YColor', 'k'); % 保持右轴颜色为黑色（可选）

    % --- 3. 美化与辅助说明 ---
    grid on;
    xlabel('Independent Variable');
    title('Statistical Comparison: Mean (Solid) vs Std Dev (Dashed)');
    
    % 图例说明
    legend([p1_mu, p2_mu, p1_sig, p2_sig], ...
        {'Data 1 Mean', 'Data 2 Mean', 'Data 1 Std', 'Data 2 Std'}, ...
        'Location', 'best', 'NumColumns', 2);

    hold off;
end