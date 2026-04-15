% plot_binary_matrix.m
%
% 这是一个MATLAB函数，用于将一个长度为2^n的01字符串
% 转换为一个sqrt(length) x sqrt(length)的矩阵，并在2D图中
% 将每个元素绘制成一个红色或蓝色的小球。
%
% 输入:
%   binary_string - 一个由'0'和'1'组成的字符串，其长度必须是
%                   一个平方数且是2的整数幂（例如4, 16, 64等）。
%
% 输出:
%   无。函数将直接绘制图像。

plot_binary_matrix(a)
function plot_binary_matrix(binary_string)

    % 1. 输入验证
    % 检查输入是否为字符串
    if ~ischar(binary_string)
        error('输入必须是一个字符串。');
    end

    % 检查字符串长度
    len = length(binary_string);

    % 检查长度是否为2的整数幂且是平方数
    if mod(log2(len), 1) ~= 0 || mod(sqrt(len), 1) ~= 0
        error('字符串长度必须是2的整数幂且是平方数（例如4, 16, 64, 256等）。');
    end

    % 2. 字符串转换
    % 将字符串转换为数值数组
    numeric_array = str2double(split(binary_string, ''));
    % split函数会在每个字符之间插入一个空字符，因此需要删除空值
    numeric_array = numeric_array(~isnan(numeric_array));

    % 3. 矩阵转换
    % 确定矩阵维度
    dim = sqrt(len);
    % 将一维数组重塑为二维矩阵，reshape默认按列填充
    matrix = reshape(numeric_array, [dim, dim])';

    % 4. 绘图
    % 创建一个新的绘图窗口
    figure;
    hold on;

    % 获取每个元素在矩阵中的坐标
    [rows, cols] = find(matrix >= 0); % 找到所有元素的索引
    values = matrix(sub2ind(size(matrix), rows, cols));

    % 找出值为0和1的元素的索引
    zero_indices = values == 0;
    one_indices = values == 1;

    % 定义小球的大小
    ball_size = 2;

    %画成方形
    colormapData = [
        1 0 0;  % Red
        0 0 1   % Blue
    ];

    % 使用 imagesc 进行绘图，并自动将数据值映射到色图范围
    matrix = -1*matrix + 1;
    imagesc(matrix);

    % 设置色图
    colormap(colormapData);

    %画成小球
    % % 绘制值为0的蓝色小球
    % scatter(cols(zero_indices), rows(zero_indices), ball_size, 'b', 'filled', 'DisplayName', '0');
    % 
    % % 绘制值为1的红色小球
    % scatter(cols(one_indices), rows(one_indices), ball_size, 'r', 'filled', 'DisplayName', '1');

    % 设置绘图属性
    title('01 矩阵可视化', 'FontSize', 16);
    xlabel('列 (x)', 'FontSize', 12);
    ylabel('行 (y)', 'FontSize', 12);
    
    % 调整坐标轴，使其以矩阵为中心
    axis equal;
    xlim([0.5, dim + 0.5]);
    ylim([0.5, dim + 0.5]);
    
    % 反转Y轴，使(1,1)位于左上角，符合常规矩阵显示
    set(gca, 'YDir', 'reverse');
    
    % 添加图例
    legend;

    % 保持绘图窗口，以便可以观察
    hold off;
end
