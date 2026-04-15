% 清空环境
clear; clc;

n = 5;

seq_binary = double(generateDeBruijnSequence_v2(n)) - '0';
%seq_binary = gen_deBrujin_seqs(2,n,1);
n_val = n;

analyze_pattern_evolution(seq_binary, n_val);

% --- 核心设置：全局字体与字号 ---
set(gca, 'FontName', 'Times New Roman', 'FontSize', 15);

% 如果你想让 Legend 的字体也同步变大，可以单独设置：
lgd = findobj(gcf, 'Type', 'Legend');
set(lgd, 'FontName', 'Times New Roman', 'FontSize', 15);

% 取消注释运行下面这一行
% analyze_debruijn_evolution(seq_random, n_rand);
function analyze_pattern_evolution(seq, n)
% ANALYZE_PATTERN_EVOLUTION 统计子串构型随序列增长的演化并绘制热力图
%
% 输入:
%   seq - 整数数列 (向量)
%   n   - 子串 (构型) 的长度
%
% 输出:
%   生成一个热力图，横轴为序列长度(时间)，纵轴为构型索引

% 1. 数据预处理
seq = seq(:)'; % 确保是行向量
L = length(seq);

if n > L
    error('子串长度 n 不能大于序列总长度。');
end

% 2. 构建构型空间的基底 (Basis Set)
% 理论上，任何在演化过程中出现的构型，最终都会包含在
% "全长序列 + 周期性边界" 的集合中。
% 因此，我们先提取全序列在周期性边界下的所有子串，以此建立纵轴坐标。

seq_periodic = [seq, seq(1:n-1)]; % 构造周期性延拓
all_possible_windows = zeros(L, n);

for i = 1:L
    all_possible_windows(i, :) = seq_periodic(i : i+n-1);
end

% 获取所有唯一的构型，并排序，作为纵轴的刻度
[unique_patterns, ~, ~] = unique(all_possible_windows, 'rows', 'sorted');
num_patterns = size(unique_patterns, 1);

% 3. 演化过程模拟
% 时间步数 = (L - n + 1) 个线性增长步 + 1 个最终周期性步
% 但实际上，题目要求的是"加入下一个数"，意味着序列长度从 n 涨到 L
steps_range = n:L;
num_steps = length(steps_range);

% 初始化统计矩阵: 行=构型, 列=时间步(序列当前长度)
heatmap_data = zeros(num_patterns, num_steps);

fprintf('开始统计演化过程...\n');

for idx = 1:num_steps
    current_len = steps_range(idx);

    % 获取当前的子数列
    current_seq = seq(1:current_len);

    current_windows = [];

    if current_len < L
        % === 开放边界条件 (Open Boundary Condition) ===
        % 提取所有长度为 n 的线性子串
        num_wins = current_len - n + 1;
        current_windows = zeros(num_wins, n);
        for k = 1:num_wins
            current_windows(k, :) = current_seq(k : k+n-1);
        end

    else
        % === 周期性边界条件 (Periodic Boundary Condition) ===
        % 当所有数均加入时 (current_len == L)
        extended_seq = [current_seq, current_seq(1:n-1)];
        current_windows = zeros(L, n);
        for k = 1:L
            current_windows(k, :) = extended_seq(k : k+n-1);
        end
    end

    % 统计当前步骤中各构型的数量
    % 使用 ismember 找到当前窗口在基底中的索引
    [~, loc] = ismember(current_windows, unique_patterns, 'rows');

    % 累加数量
    % accumarray 类似于物理中的直方图统计
    if ~isempty(loc)
        step_counts = accumarray(loc, 1, [num_patterns, 1]);
        heatmap_data(:, idx) = step_counts;
    end
end

% 4. 绘图 (Visualization)
figure('Name', 'Configuration Evolution Heatmap', 'Color', 'w');

% 1. 定义你想要的颜色 (RGB 分量)
% 比如：0 对应白色 [1 1 1]，1 对应深蓝色 [0 0.2 0.6]
color_0 = [0.9, 0.9, 0.9] ;	
color_1 = [0.2, 0.2, 0.2]; % MATLAB 默认的简洁蓝色

% 2. 创建自定义 colormap 矩阵
my_colormap = [color_0; color_1];

% 3. 绘图
imagesc(steps_range, 1:num_patterns, heatmap_data);

% 4. 应用自定义颜色
colormap(my_colormap);
pt = 15;%字号

% 5. 调整 colorbar (既然只有0和1，建议设置刻度让它更美观)
h = colorbar;
set(h, 'Ticks', [0.25, 0.75], 'TickLabels', {'0', '1'});
ylabel(h, 'Atom (0 or 1)');
set(h, 'FontName', 'Times New Roman', 'FontSize', 18);
% 其他美化
xlabel('The instantaneous number of atoms in the sequence.', 'FontSize', pt, 'FontWeight', 'bold');
ylabel('Configuration Space Index', 'FontSize', pt, 'FontWeight', 'bold');
% title(['Evolution of ' num2str(n) '-Substring Configurations'], 'FontSize', 14);
% 设置坐标轴方向，通常矩阵绘图Y轴是倒置的，这里改为正常方向
set(gca, 'YDir', 'normal');

% 如果构型数量不多，可以在Y轴显示具体的构型模式（可选）
if num_patterns <= 20000
    ytick_labels = cell(num_patterns, 1);
    for i = 1:num_patterns
        ytick_labels{i} = mat2str(unique_patterns(i, :));
    end
    set(gca, 'YTick', 1:num_patterns, 'YTickLabel', ytick_labels, 'FontSize', pt);
end

fprintf('绘图完成。共发现 %d 种不同构型。\n', num_patterns);
end