a = [    3     2     1     3     3     3     2     3     1
     2     2     3     1     3     1     3     2     3
     1     2     1     1     2     2     3     1     1
     3     2     2     2     2     3     3     3     1
     3     3     3     1     1     2     1     1     3
     2     3     3     2     3     1     1     2     2
     1     3     2     3     1     2     1     2     2
     1     3     2     3     1     1     3     3     2
     2     1     2     2     1     1     1     2     1] - 1;

[ok, msg] = checkDeBruijn2D(a, 2, 2);
disp(msg);
%a = [a,a,a]; a = [a;a;a];
plotMatrixBlocks(a)

asym = [     3     2     3     2     3     3     1     3     3
     3     2     1     3     1     3     3     2     2
     3     1     2     2     1     1     2     2     3
     1     3     1     3     1     1     2     1     1
     1     3     2     1     2     1     1     3     3
     1     2     3     3     2     2     3     3     1
     2     1     2     1     2     2     3     2     2
     2     1     3     2     3     2     2     1     1
     2     3     1     1     3     3     1     1     2 ] - 1;

[ok, msg] = checkDeBruijn2D(asym, 2, 2);
disp(msg);

%asym = [asym,asym,asym]; asym = [asym;asym;asym];
plotMatrixBlocks(asym)


function plotMatrixBlocks(A)
    % plotMatrixBlocks: 将矩阵中的不同整数值映射为颜色方块并绘图
    % 输入: A - 任意大小的整数矩阵
    
    % 1. 获取矩阵中所有不重复的元素并排序
    unique_vals = unique(A);
    num_colors = length(unique_vals);
    
    % 2. 创建一个离散的颜色映射表 (Colormap)
    % 使用 lines, jet 或 hsv 等预设，这里 lines 颜色对比度较高
    cmap = lines(num_colors); 
    
    % 3. 将矩阵元素映射到 1 到 num_colors 的索引空间
    % 这是为了防止矩阵元素是非连续整数（如 0, 10, 100）
    mappedA = zeros(size(A));
    for i = 1:num_colors
        mappedA(A == unique_vals(i)) = i;
    end
    
    % 4. 绘图
    figure;
    % 使用 image 函数，并设置 CDataMapping 为 'direct'
    h = image(mappedA);
    colormap(cmap);
    
    % 5. 图形美化
    axis equal;          % 保持方块为正方形
    axis tight;          % 紧凑布局
    set(gca, 'XTick', 1:size(A,2), 'YTick', 1:size(A,1)); % 显示行列刻度
    grid off;             % 开启网格辅助观察方块边界
    set(gca, 'Layer', 'top'); % 让网格线显示在方块上方
    
    % 6. 添加颜色条说明
    cb = colorbar;
    % 将颜色条的刻度对准颜色块中心，并标记原始数值
    cb.Ticks = 1:num_colors;
    cb.TickLabels = string(unique_vals);
    title('Matrix Value Visualization');
end