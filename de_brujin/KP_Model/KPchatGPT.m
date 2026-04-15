% KP_realspace.m
% Kronig-Penney 风格一维数值计算（有限差分）
% 输入：binary sequence (0/1), potential U, physical params, grid
% 输出：能谱、DOS、波函数、IPR，以及可选的带结构（若将序列当作周期单元）

clear; close all; clc;

%% ------------------- 用户参数 -------------------
% 二进制序列，可以是字符如 '0101101' 或向量 [0 1 0 ...]
seq = '0101001101';      % <- 这里替换为你的序列（任意长度）
% seq = [0 1 0 1 1 0 0 1]; % <- 或者使用数值向量

U = 5.0;                 % 势能高度（能量单位，见下面单位说明）
a = 1.0;                 % 每个“原子/格点”的宽度（空间单位）
points_per_site = 40;    % 每个 site 内离散网格点数（越大越精确，越慢）
m = 1.0;                 % 电子有效质量（质量单位）
hbar = 1.0;              % 约化普朗克常数（单位选择导致哈密顿中常数）
BC_type = 'open';        % 边界条件：'open'（开边界） 或 'periodic'（周期）
compute_band_structure = true; % 若将序列作为一个周期单元，是否计算带结构（k 扫描）
num_k = 121;             % 带结构中 k 点数
num_eig_plot = 6;        % 绘制最低 num_eig_plot 个本征态

%% ------------------- 预处理 -------------------
% 统一序列格式为 0/1 数值向量
if ischar(seq)
    seq = seq(:)'; % row
    seq = arrayfun(@(c) str2double(c), seq);
end
Lsites = length(seq);
Nx = Lsites * points_per_site;   % 总网格点数
dx = a / points_per_site;
x = (0:Nx-1) * dx;               % 网格坐标
V = zeros(Nx,1);

% 构造势：每个格点上分配该 site 的 V (块状势)
for i = 1:Lsites
    ix0 = (i-1)*points_per_site + 1;
    ix1 = i*points_per_site;
    if seq(i) == 1
        V(ix0:ix1) = U;
    else
        V(ix0:ix1) = 0;
    end
end

%% ------------------- 构造有限差分哈密顿量 -------------------
% 二阶中心差分： - (hbar^2 / (2m)) d^2/dx^2  -> 离散为三对角矩阵
coef = hbar^2 / (2*m) / dx^2;
main_diag = (2*coef + V);            % 注意： kinetic contributes +2coef on diagonal if we define -coef*[-2 ..]
off_diag = -coef * ones(Nx,1);

H = spdiags([off_diag main_diag off_diag], -1:1, Nx, Nx);

% 周期性带相位的连接（用于带结构计算）：我们保留原 H_open，然后在 k 扫描时添加相位
H_open = H;
if strcmpi(BC_type,'periodic')
    % 将首尾连边改为周期（相位为 1）
    H(1,Nx) = -coef;
    H(Nx,1) = -coef;
end

%% ------------------- 求本征能与本征态（有限体系） -------------------
% 求全部本征值可能较慢；如果 Nx 适中可用 eigs 找前若干个
num_eigs = min(Nx, 400); % 若 Nx 很大，只取前 num_eigs（调整）
% 为稳妥，先用 eigs 求最低一部分能级
opts.isreal = true;
opts.issym = true;
nev = min(Nx, 200); % 求前 200 个本征值（或 Nx）
try
    [Psi, Evec] = eigs(H_open, nev, 'smallestabs', opts);
    E = diag(Evec);
    [E, idx] = sort(E);
    Psi = Psi(:, idx);
catch
    % 若 eigs 失败（矩阵小可以直接用 eig）
    [Vfull, Dfull] = eig(full(H_open));
    E = diag(Dfull);
    [E, idx] = sort(E);
    Psi = Vfull(:, idx);
end

%% ------------------- 密度态（DOS）与谱图 -------------------
% 简单 DOS: 将求得的能量用高斯平滑成连续曲线
Emin = min(E) - 0.1*abs(min(E));
Emax = max(E) + 0.1*abs(max(E));
NE = 1000;
Egrid = linspace(Emin, Emax, NE);
sigma = (Emax-Emin)/200; % Gaussian broadening
DOS = zeros(size(Egrid));
for j = 1:length(E)
    DOS = DOS + exp(-(Egrid - E(j)).^2/(2*sigma^2));
end
DOS = DOS / (sqrt(2*pi)*sigma);

%% ------------------- IPR（Inverse Participation Ratio）局域化度量 -------------------
% IPR_n = sum_i |psi_n(i)|^4  （规范化波函数）
num_modes_IPR = min(nev, 200);
IPR = zeros(num_modes_IPR,1);
for n = 1:num_modes_IPR
    psi = Psi(:,n);
    psi = psi / norm(psi);
    IPR(n) = sum(abs(psi).^4);
end
PR = 1 ./ IPR; % Participation ratio ~ 有效占据格点数

%% ------------------- 若需要：把序列当作周期单元，计算带结构（k 扫描） -------------
if compute_band_structure
    % 使用 twisted BC：跨越边界的跃迁项乘以 exp(i*k*L)
    L_phys = Lsites * a;  % 单元格长度
    ks = linspace(-pi/L_phys, pi/L_phys, num_k);
    bands = zeros(num_k, min(Nx,100)); % 存储若干本征能
    for ik = 1:num_k
        k = ks(ik);
        % 构造 H_k：在 H_open 基础上加上边界耦合项 with phase
        Hk = H_open;
        phase = exp(1i * k * L_phys);
        Hk(1,Nx) = Hk(1,Nx) - (-coef) + (-coef)*phase; % remove open link (zero) and add phased link
        Hk(Nx,1) = conj(Hk(1,Nx));
        % 求本征值（只前 few）
        try
            Ek = eigs(Hk, min(80, Nx-1), 'smallestabs', opts);
            Ek = sort(real(Ek));
        catch
            Ek = eig(full(Hk));
            Ek = sort(real(Ek));
        end
        bands(ik,1:length(Ek)) = Ek(:)';
    end
end

%% ------------------- 绘图 -------------------
figure('Position',[100 100 1100 700]);

subplot(2,2,1);
plot(x, V, 'k','LineWidth',1.5);
xlabel('x'); ylabel('V(x)');
title('块状势 V(x)（黑色）');
xlim([x(1) x(end)]);

subplot(2,2,2);
plot(Egrid, DOS, 'LineWidth',1.4);
xlabel('Energy'); ylabel('DOS (arb)');
title('近似密度态 (DOS)');

subplot(2,2,3);
plot(E(1: min(200,length(E))), '.');
xlabel('Mode index (sorted)'); ylabel('Energy');
title('有限体系能谱（按升序）');

subplot(2,2,4);
plot(PR(1: min(200,length(PR))), '.-');
xlabel('Mode index'); ylabel('Participation ratio ~ 1/IPR');
title('Participation ratio (越小表示越局域)');

% 绘制若干本征态
figure('Position',[200 120 900 600]);
for n = 1:min(num_eig_plot, size(Psi,2))
    subplot(num_eig_plot,1,n);
    psi = real(Psi(:,n));
    psi = psi / max(abs(psi));
    plot(x, psi, 'b'); hold on;
    plot(x, V/max(V+eps)*max(psi), 'k--'); % 同一个图中画出势的相对位置（归一化显示）
    ylabel(sprintf('psi_%d',n));
    if n==1, title('前若干本征态（实部）与势示意'); end
end
xlabel('x');

% 若计算了带结构，画图
if compute_band_structure
    figure('Position',[250 150 800 500]);
    hold on;
    for n = 1:size(bands,2)
        plot(ks*L_phys, bands(:,n), '.-'); % 用 kL 为横轴（规范化）
    end
    xlabel('k * L_{unit}'); ylabel('Energy');
    title('周期重复的单元格的带结构（k 扫描，若有多个能带）');
    xlim([min(ks*L_phys) max(ks*L_phys)]);
end

%% ------------------- 结果摘要输出 -------------------
fprintf('--- 计算完成 ---\n');
fprintf('总格点数 Nx = %d, 网格间距 dx = %.4e\n', Nx, dx);
fprintf('计算了 %d 个本征值（最低）用于分析。\n', length(E));
fprintf('能量范围: [%.4g, %.4g]\n', min(E), max(E));
fprintf('IPR（前10 modes） =\n'); disp(IPR(1:min(10,length(IPR))));
if compute_band_structure
    fprintf('带结构已计算，k 点数 = %d (k*L 单位化显示)。\n', num_k);
end

