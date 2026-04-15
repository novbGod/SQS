% =========================================================================
% SQS 序列 Kronig-Penney 模型电子结构与输运计算程序
% =========================================================================
clear;

%% 1. 系统参数设置 (使用原子单位制/有效单位以简化数值)
% 物理常数 (近似值，以 eV 和 Angstrom 为单位)
hbar_sq_2m = 1/2; % hbar^2 / (2m_e) in eV*A^2

% SQS 序列设定 (示例序列，由 0, 1, 2... 组成)
% 你可以将你的 SQS 算法生成的序列粘贴在这里
sqs_seq = gen_deBrujin_seqs(2,5,1); 
N_cells = length(sqs_seq);

% 空间几何参数
a = 1;          % 每个晶格点(site)的宽度 (Angstrom)
grid_points_per_site = 100; % 每个site划分的网格点数 (精度控制)
dx = a / grid_points_per_site;        % 空间离散步长 (Angstrom)
x_cell = 0:dx:a-dx; % 单个元胞内的坐标点
N_points_per_cell = length(x_cell);
N = length(sqs_seq) * grid_points_per_site;%整个SQS的坐标点数


% 势能参数
U = 5;          % 基础势能台阶高度 (eV). V = n * U

%% 2. 构建全空间势能 V(x)
V_total = [];
X_total = [];

for i = 1:N_cells
    type = sqs_seq(i);
    V_local = ones(1, N_points_per_cell) * (type * U);
    V_total = [V_total, V_local];
    X_total = [X_total, (i-1)*a + x_cell];
end

N_total = length(V_total);
L_total = N_total * dx; % 总长度

% % 绘制势能分布示意图
% figure('Name', 'Potential Profile');
% plot(X_total, V_total, 'LineWidth', 1.5);
% xlabel('Position (\AA)'); ylabel('Potential V(x) (eV)');
% title('SQS Potential Profile');
% grid on; axis tight;
% ylim([0, max(V_total)*1.2 + 0.1]);

%% 3. 计算电子结构 (周期性边界条件 PBC) - 有限差分法
fprintf('正在构建哈密顿矩阵并求解本征值...\n');

% 离散化系数 t = hbar^2 / (2m * dx^2)
t = hbar_sq_2m / (dx^2);

% 构建哈密顿矩阵 H (稀疏矩阵以节省内存)
% H = -t * (psi_{i+1} + psi_{i-1} - 2psi_i) + V_i * psi_i
% 对角线元素: 2t + V_i
diag_main = 2*t * ones(N_total, 1) + V_total';
% 次对角线元素: -t
diag_off = -t * ones(N_total, 1);

H = spdiags([diag_off, diag_main, diag_off], [-1, 0, 1], N_total, N_total);

% 应用周期性边界条件 (PBC): psi(N+1) = psi(1), psi(0) = psi(N)
H(1, N_total) = -t;
H(N_total, 1) = -t;

% 对角化求解 (获取前 N_eigs 个低能态，或者全部)
% 如果矩阵很大，使用 eigs；如果较小(<2000)，使用 eig
if N_total < 2000
    [Psi, E_diag] = eig(full(H));
    E = diag(E_diag);
else
    num_modes = min(200, N_total); % 仅计算最低的200个能级
    [Psi, E_diag] = eigs(H, num_modes, 'sm'); % 'sm' = smallest magnitude
    E = diag(E_diag);
end

% 排序能级
[E_sorted, idx] = sort(real(E(E < 2*U*max(sqs_seq))));
Psi_sorted = Psi(:, idx);

% 归一化波函数 (int |psi|^2 dx = 1)
for i = 1:length(E_sorted)
    norm_factor = sqrt(sum(abs(Psi_sorted(:, i)).^2) * dx);
    Psi_sorted(:, i) = Psi_sorted(:, i) / norm_factor;
end

%% 4. 可视化：波函数与模方
figure('Name', 'Wavefunctions');
subplot(2,2,1)
num_plot_start = 1;
num_plot_end = 5; % 绘制前几个态
hold on;
% 为了展示清晰，将波函数加上能级值作为偏移量
scale_factor = 0.1 * U; % 缩放系数
plot(X_total, V_total, 'k-', 'LineWidth', 1, 'DisplayName', 'Potential');
for i = num_plot_start:1:num_plot_end
    psi_sq = abs(Psi_sorted(:, i)).^2;
    % 绘制波函数模方 (实线)
    plot(X_total, psi_sq * scale_factor * 10 + E(i), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('n=%d, E=%.3f eV', i, E(i)));
    % 绘制基准能级 (虚线)
    yline(E(i), '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
end
title('Probability Density |\psi|^2 shifted by Energy');
xlabel('Position x (\AA)'); ylabel('Energy / Probability (arb. units)');
legend('Location','best');
hold off;

%% 5. 可视化：能量随量子数变化 & 态密度 (DOS)
% figure('Name', 'Electronic Structure');
subplot(2, 2, 2);
plot(1:length(E_sorted), E_sorted, 'o-', 'MarkerSize', 4);
xlabel('Quantum Number n'); ylabel('Energy E_n (eV)');
title('Energy Spectrum'); grid on;



subplot(2, 2, 4);
% 使用直方图近似计算 DOS
% histogram(E_sorted, 20, 'Normalization', 'pdf');
% xlabel('Energy E (eV)'); ylabel('DOS (arb. units)');
% title('Density of States'); grid on;

% 态密度 (DOS) - 使用高斯展宽
deltaE = (max(E_sorted) - min(E_sorted))/N;
sigma = 0.5; % 高斯展宽宽度
E_grid = linspace(min(E_sorted), max(E_sorted), 500000);
DOS = zeros(size(E_grid));
for i = 1:length(E_sorted)
    DOS = DOS + (1/(sigma*sqrt(2*pi))) * exp(-(E_grid - E(i)).^2 / (2*sigma^2));
end
plot(E_grid, DOS, 'k-', 'LineWidth', 1.5);
title('电子态密度 (DOS)');
xlabel('Energy'); ylabel('DOS (a.u.)');
grid on;



%% 6. 计算透射系数 T 和反射系数 R (转移矩阵法 TMM)
% 注意：此处假设电子从左侧入射，散射区域为 SQS 序列，两端为自由空间(V=0)
fprintf('正在计算透射系数...\n');

E_scan = linspace(0.01, max(V_total)*1.5, 500); % 能量扫描范围
T_coeff = zeros(size(E_scan));
R_coeff = zeros(size(E_scan));

% 每一个小 dx 片段视为一个势垒，使用转移矩阵连乘
% 矩阵 M_j 关联 j 和 j+1 处的波函数系数
% 为提高效率，我们将每个拥有相同电势的“原子”视为一个大块计算
% 但为了通用性，这里直接对离散的势能 V_total 进行逐点 TMM (简单但较慢)
% 或者使用解析解连接边界 (更快)。这里采用解析解连接各分段常数势区域。

% 重新整理势能段：找出 V 变化的节点
segments_V = [];
segments_L = [];
current_V = V_total(1);
current_L = 0;
for i = 1:length(V_total)
    if V_total(i) == current_V
        current_L = current_L + dx;
    else
        segments_V = [segments_V, current_V];
        segments_L = [segments_L, current_L];
        current_V = V_total(i);
        current_L = dx;
    end
end
segments_V = [segments_V, current_V];
segments_L = [segments_L, current_L];

% 物理常数换算 k = sqrt(2mE)/hbar
const_k = sqrt(1/hbar_sq_2m); 

for ie = 1:length(E_scan)
    E_val = E_scan(ie);
    
    % 初始化总转移矩阵为单位矩阵
    M_total = eye(2);
    
    % 入射区波矢量 (假设 V=0)
    k0 = const_k * sqrt(E_val);
    
    for j = 1:length(segments_V)
        V_j = segments_V(j);
        L_j = segments_L(j);
        
        % 区域内的波矢量
        if E_val > V_j
            k_j = const_k * sqrt(E_val - V_j);
            % 传播矩阵 P (在恒定势能区传播 L_j)
            P = [exp(1i * k_j * L_j), 0; 0, exp(-1i * k_j * L_j)];
        else
            % 隧穿区 (E < V)
            kappa_j = const_k * sqrt(V_j - E_val);
            P = [exp(-kappa_j * L_j), 0; 0, exp(kappa_j * L_j)];
            k_j = 1i * kappa_j; % 用于界面矩阵公式通用性
        end
        
        % 界面矩阵 D (从 j 到 j+1)
        % 下一个区域的 k (如果 j 是最后一个，下一个是出射区 V=0)
        if j < length(segments_V)
            V_next = segments_V(j+1);
        else
            V_next = 0; % 出射区
        end
        
        if E_val > V_next
            k_next = const_k * sqrt(E_val - V_next);
        else
            k_next = 1i * const_k * sqrt(V_next - E_val);
        end
        
        % 界面匹配矩阵 (Derivative matching)
        % M_interface = 0.5 * [1+k_j/k_next, 1-k_j/k_next; 1-k_j/k_next, 1+k_j/k_next]
        % 注意：这是从 j 射向 next。
        % 标准 TMM 顺序通常是： 界面(in->1) * 传播(1) * 界面(1->2) * ...
        % 这里简化处理：我们已经把空间切分为常数势能段。
        % M_total = D_{j->next} * P_j * ... 
        
        D = 0.5 * [1 + k_j/k_next, 1 - k_j/k_next; ...
                   1 - k_j/k_next, 1 + k_j/k_next];
               
        % 累乘：注意顺序，新矩阵在左
        M_total = D * P * M_total;
    end
    
    % 入射界面 (Free space -> Segment 1)
    % 我们上面的循环是从 Segment 1 的传播开始的，漏了 0->1 的界面
    % 补上第一个界面
    V1 = segments_V(1);
    if E_val > V1
        k1 = const_k * sqrt(E_val - V1);
    else
        k1 = 1i * const_k * sqrt(V1 - E_val);
    end
    D_start = 0.5 * [1 + k0/k1, 1 - k0/k1; 1 - k0/k1, 1 + k0/k1];
    
    M_total = M_total * D_start;
    
    % 计算 T 和 R
    % M_total * [1; r] = [t; 0] (定义不同可能有差异，标准形式为 [A; B]_in = M [C; D]_out)
    % 标准 TMM 定义： [Psi_L(+); Psi_L(-)] = M [Psi_R(+); Psi_R(-)]
    % 设入射 1, 反射 r, 透射 t, 右侧无入射 0
    % [1; r] = [M11 M12; M21 M22] * [t; 0]
    % => 1 = M11 * t  => t = 1/M11
    % => r = M21 * t  => r = M21 / M11
    
    t_amp = 1 / M_total(1,1);
    r_amp = M_total(2,1) / M_total(1,1);
    
    T_coeff(ie) = abs(t_amp)^2;
    R_coeff(ie) = abs(r_amp)^2;
end

% figure('Name', 'Transmission & Reflection');
subplot(2,2,3);
plot(E_scan, T_coeff, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Transmission T');
hold on;
plot(E_scan, R_coeff, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Reflection R');
xlabel('Energy (eV)'); ylabel('Coefficient');
title('Transmission and Reflection Coefficients');
legend; grid on; ylim([-0.1 1.1]);