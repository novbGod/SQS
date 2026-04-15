function plotPhysicalAnalysis(data1, data2, x_values)
    % 1. 数据统计计算 (省略部分重复计算代码...)
    num_points = size(data1, 2);
    if nargin < 3 || isempty(x_values), x_values = 1:num_points; end
    mu1 = mean(data1, 1); sig1 = std(data1, 0, 1);
    mu2 = mean(data2, 1); sig2 = std(data2, 0, 1);
    
    color1 = [0, 0.447, 0.741]; color2 = [0.85, 0.325, 0.098]; pt = 18;
    
    figure('Color', 'w', 'Units', 'pixels', 'Position', [200, 200, 900, 600]);
    
    % --- 左侧 ---
    yyaxis left
    e1 = plot(x_values, mu1, '-s', 'LineWidth', 1.5, 'Color', color2, 'MarkerFaceColor', color2, 'MarkerSize', 8);
    hold on;
    e2 = plot(x_values, mu2, '--o', 'LineWidth', 1.5, 'Color', color2, 'MarkerFaceColor', 'none', 'MarkerSize', 8);
    ylabel('Mean State Energy (Average)', 'FontSize', pt);
    ax = gca;
    ax.YColor = color2;
    grid on;

    % --- 右侧 ---
    yyaxis right
    s1 = plot(x_values, sig1, '-s', 'Color', color1, 'LineWidth', 1.5, 'MarkerFaceColor', color1, 'MarkerSize', 6);
    s2 = plot(x_values, sig2, '--o', 'Color', color1, 'LineWidth', 1.5, 'MarkerFaceColor', 'none', 'MarkerSize', 6);
    ylabel('Standard Deviation (\sigma)', 'FontSize', pt);
    ax.YColor = color1;

    % --- 修饰 (解决上方坐标轴问题) ---
    xlabel('Quantum Number', 'FontSize', pt);
    
    % 关键设置：去掉上边框和右边框（右边框因为yyaxis right会自动补回来，从而达到只去掉顶部的效果）
    ax.Box = 'off'; 
    
    legend([e1, e2, s1, s2], ...
        {'$\mathrm{SQS: Mean }$', '$\mathrm{Random: Mean }$', ...
         '$\mathrm{SQS: \sigma}$', '$\mathrm{Random: \sigma}$'}, ...
        'Location', 'northoutside', 'NumColumns', 2, 'FontSize', pt, 'Interpreter', 'latex', 'Box', 'off');
    
    ax.LineWidth = 1.2;
    ax.XMinorTick = 'on';
    ax.YMinorTick = 'on';
    ax.FontName = 'Times New Roman';
    ax.FontSize = pt - 2;
    hold off;
end