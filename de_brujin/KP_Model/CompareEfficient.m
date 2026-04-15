% De Bruijn 序列生成算法对比：图论贪心法 vs 模拟退火
% User Context: Physics Major (Phase Space/Energy Landscape analogy)

clear; clc; close all;

%% 参数设置
n = 5;              % 子序列长度 (n-gram)
k = 2;              % 字母表大小 (二进制)
total_len = k^n;    % 目标序列长度
max_sa_iter = 1500; % 模拟退火最大迭代次数

%% 1. 图论法 (贪心/Eulerian Path 变种)
% 物理类比：受约束的确定性运动
% 方法：Prefer-ones algorithm (贪心策略，优先填1，不行则填0)
% 这种方法利用了De Bruijn图的性质，几乎不需要回溯，等同于完美剪枝

fprintf('正在运行图论法...\n');
seq_graph = zeros(1, n); % 初始状态 (n个0)
visited = containers.Map('KeyType', 'char', 'ValueType', 'logical');
visited(num2str(seq_graph, '%d')) = true;

graph_history = []; % 记录每一步的“能量” (缺失的n-gram数量)
current_seq = seq_graph;

% 初始化能量：总共有 total_len 个可能的 n-gram
% 图论法是从 0 个 n-gram 开始积累，为了对比，我们定义:
% Energy = Target_Count - Current_Unique_Count
% 随着序列增长，Energy 从 total_len 降到 0

for i = 1:total_len
    % 记录当前能量 (剩余未找到的 n-gram 数量)
    % 注意：图论法每一步增加1位，就确切找到一个新的 n-gram
    missing_count = total_len - i; 
    graph_history = [graph_history, missing_count];
    
    % 尝试添加 1
    next_node_1 = [current_seq(2:end), 1];
    key_1 = num2str(next_node_1, '%d');
    
    % 尝试添加 0
    next_node_0 = [current_seq(2:end), 0];
    key_0 = num2str(next_node_0, '%d');
    
    if ~isKey(visited, key_1)
        current_seq = next_node_1;
        visited(key_1) = true;
    elseif ~isKey(visited, key_0)
        current_seq = next_node_0;
        visited(key_0) = true;
    else
        % 这种情况在简单的贪心法可能会遇到死胡同，
        % 但对于 n=6 的 prefer-ones 实际上能很好工作到最后
        break; 
    end
end

% 补齐数据长度以便绘图 (图论法很快就结束了)
graph_plot_x = 1:length(graph_history);
graph_plot_y = graph_history;

%% 2. 模拟退火算法 (Simulated Annealing)
% 物理类比：热力学系统寻找基态 (Ground State Search)
% 目标函数 (Hamiltonian): H = 缺失的 n-gram 数量
% 我们希望 H -> 0

fprintf('正在运行模拟退火...\n');
% 随机初始化一个长度为 total_len 的序列
current_sa_seq = randi([0 1], 1, total_len + n - 1); 
% 注意：为了处理循环边界，通常由于线性存储，我们需要额外长度或循环索引
% 这里简化处理：我们生成长一点的线性序列来覆盖 n-gram

sa_history = [];
T = 100;       % 初始温度
alpha = 0.995; % 冷却系数

% 计算初始能量
current_energy = calculate_energy(current_sa_seq, n, total_len);

for iter = 1:max_sa_iter
    sa_history = [sa_history, current_energy];
    
    if current_energy == 0
        break; % 找到基态
    end
    
    % 产生扰动 (Mutation): 随机翻转一个位
    idx = randi(length(current_sa_seq));
    new_sa_seq = current_sa_seq;
    new_sa_seq(idx) = 1 - new_sa_seq(idx); % Flip 0<->1
    
    % 计算新能量
    new_energy = calculate_energy(new_sa_seq, n, total_len);
    
    % Metropolis 准则
    delta_E = new_energy - current_energy;
    if delta_E < 0 || rand() < exp(-delta_E / T)
        current_sa_seq = new_sa_seq;
        current_energy = new_energy;
    end
    
    % 降温
    T = T * alpha;
end

%% 3. 绘图与可视化
figure('Color', 'w', 'Position', [100, 100, 1000, 600]);

% 子图 1: 能量下降曲线 (收敛性对比)
hold on;
plot(1:length(sa_history), sa_history, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Simulated Annealing');
% 图论法的步数很少，我们将其画在同一尺度下
plot(graph_plot_x, graph_plot_y, 'b-o', 'LineWidth', 2, 'MarkerSize', 4, 'DisplayName', 'Many Body Constrained Algorithm');

% 设置标签
xlabel('Step Count / Iteration Number');
ylabel('Number of Missing n-body Configurations', 'Interpreter', 'latex');
% 设置图例
legend('Location', 'Best');
grid on;
xlim([0, min(max_sa_iter, length(sa_history)*1.2)]);

% --- 核心设置：全局字体与字号 ---
set(gca, 'FontName', 'Times New Roman', 'FontSize', 18);

% 如果你想让 Legend 的字体也同步变大，可以单独设置：
lgd = findobj(gcf, 'Type', 'Legend');
set(lgd, 'FontName', 'Times New Roman', 'FontSize', 18);


%% 辅助函数：计算能量 (缺失的 n-gram 数量)
function E = calculate_energy(seq, n, target_total)
    % 提取所有 n-gram
    num_sub = length(seq) - n + 1;
    patterns = zeros(num_sub, 1);
    
    % 将二进制转为十进制索引以便快速查重
    for i = 1:num_sub
        sub = seq(i : i+n-1);
        % 二进制转十进制
        val = 0;
        for j = 1:n
            val = val * 2 + sub(j);
        end
        patterns(i) = val;
    end
    
    % 计算唯一数量
    unique_count = length(unique(patterns));
    
    % 能量 = 目标数量 - 当前唯一数量
    % 注意：如果序列过长产生重复并不增加能量，但我们希望正好是 target_total
    % 这里简化为最大化覆盖率
    E = target_total - unique_count;
end