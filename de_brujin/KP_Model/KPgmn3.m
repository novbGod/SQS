clear;
% ----------------参数设置----------------
% 物理参数 (原子单位制: hbar=1, m=1)
U = 5;           % 势垒高度 (对应序列"1"处的势能)
a = 1.0;            % 单个原子格点(site)的宽度
n = 4;
num = 1;        %计算同一个n的SQS的数量
StateNums = [40,40,40,80,160,320,400,400,400,400,400,400];%对于每一个SQS，计算量子态的数量

% 0代表势能为0，1代表势能为U

for ooo = 1:1
    for n = 2:6
        % sqs_seqs = pileToBalls([5,1,1,1,1,2,1,1,2,5,1,3,3,1,2,2]); StateNums = [50,50,50,50,50,50,50,50,50,40,40,400];
         sqs_seqs = generateTwoBodyOnly(2*n, num);StateNums = [15,15,25,25,25,320,400,400,400,400,400,400];
        % sqs_seqs = gen_deBrujin_seqs(2,n,num) ; 
        % sqs_seqs = generate_symmetric_debruijn_limited(n,num);
        % sqs_seqs = zeros(1,2^n); sqs_seqs(1:2:end) = 1;
        %  sqs_seqs = zeros(1,2^n); sqs_seqs(1:end/2) = 1;
        % base_array = [zeros(1, 2^n/2), ones(1, 2^n/2)];random_indices = randperm(2^n);sqs_seqs = base_array(random_indices);disp('random');

        StateNum = StateNums(n-1);
         
        for sqsi = 1:ceil(num/10):num
            sqs_seq = sqs_seqs(sqsi,:);
            num_sites = length(sqs_seq);

            % 离散化参数
            grid_points_per_site = 100; % 每个site划分的网格点数 (精度控制)
            dx = a / grid_points_per_site;
            N = num_sites * grid_points_per_site; % 总网格点数
            L = N * dx; % 系统总长度

            % ----------------构建势能 V(x)----------------
            V = zeros(N, 1);
            x = linspace(0, L, N)';

            for i = 1:num_sites
                % 找到当前site对应的网格索引范围
                idx_start = (i-1)*grid_points_per_site + 1;
                idx_end = i*grid_points_per_site;

                if sqs_seq(i) == 1
                    V(idx_start:idx_end) = U;
                else
                    V(idx_start:idx_end) = 0;
                end
            end

            % ----------------构建哈密顿量 H----------------
            % 动能项 T = -1/2 * d^2/dx^2
            % 使用稀疏矩阵以节省内存并提高速度
            e = ones(N, 1);
            % 二阶导数中心差分矩阵 [-2, 1, ..., 1]
            Laplacian = spdiags([e -2*e e], -1:1, N, N);

            % 周期性边界条件 (Periodic Boundary Conditions)
            Laplacian(1, N) = 1;
            Laplacian(N, 1) = 1;

            T = -(1/2) * Laplacian / (dx^2);

            % 势能项 (对角矩阵)
            V_matrix = spdiags(V, 0, N, N);

            % 总哈密顿量
            H = T + V_matrix;

            % ----------------对角化求解----------------
            fprintf('正在求解特征值 (矩阵大小: %dx%d)...\n', N, N);

            % 如果矩阵非常大，可以使用 eigs 求解部分特征值
            % 这里为了展示全谱，使用 full + eig (适用于 N < 3000 左右)
            if N < 0
                [Psi, E_diag] = eig(full(H));
                E = diag(E_diag);
            else
                % 求解前100个最低能级
                [Psi, E_diag] = eigs(H, StateNum, 'sm');
                E = diag(E_diag);
            end

            % 排序能级
            [E, idx] = sort(E);
            Psi = Psi(:, idx);
            
            % 归一化波函数 (数值积分 int |psi|^2 dx = 1)
            for i = 1:length(E)
                norm_factor = sqrt(trapz(x, abs(Psi(:,i)).^2));
                Psi(:,i) = Psi(:,i) / norm_factor;
            end

            % ----------------结果可视化与物理量计算----------------
            figure('Name', 'SQS Kronig-Penney Analysis', 'Color', 'w');
            num_states_plot = min(5, length(E));
            
            %1. 势场与前几个本征态
            subplot(2, 2, 1);
            scale = max(abs(Psi(:,1))) * 0.5; % 波函数缩放因子，便于显示
            plot(x, V, 'k-', 'LineWidth', 1.5); hold on;
            legend_str = {'Potential V(x)'};
            for i = 1:num_states_plot
                % 将波函数平移到对应的能级高度显示
                plot(x, Psi(:,i)*scale*10 + E(i), 'LineWidth', 1);
                legend_str{end+1} = sprintf('E_{%d}=%.2f', i, E(i));
            end
            title(sprintf('势场与波函数 (前5个态), 序列长度为%d', length(sqs_seq)));
            xlabel('Position x'); ylabel('Potential V(x)');
            ylim([min(V)-5, max(E(num_states_plot))+5]);
            grid on;

            % 2. 概率密度分布 (查看局域化)
            subplot(2, 2, 2);
            hold on;
            for i = 1:num_states_plot
                % 将波函数平移到对应的能级高度显示
                plot(x, abs(Psi(:,i)).^2, 'LineWidth', 1.5);
            end
            % title('概率密度 |\psi|^2(前5个态)');
            xlabel('Position x'); ylabel('Probability Density');
            %legend('Ground State', '1th Excited State', '2th Excited State', '3th Excited State', '4th Excited State');
            grid on;

            % 3. 能级分布 (Energy Spectrum)
            subplot(2, 2, 3);
            plot(1:length(E), E, 'bo-', 'MarkerSize', 3);
            title('能级谱 (Energy Spectrum)');
            xlabel('Quantum Number n'); ylabel('Energy E_n');
            grid on;

            % 4. 态密度 (DOS) - 使用高斯展宽
            subplot(2, 2, 4);
            deltaE = (max(E) - min(E))/N;
            sigma = 0.5; % 高斯展宽宽度
            E_grid = linspace(min(E), max(E), 500000);
            DOS = zeros(size(E_grid));
            for i = 1:length(E)
                DOS = DOS + (1/(sigma*sqrt(2*pi))) * exp(-(E_grid - E(i)).^2 / (2*sigma^2));
            end
            plot(E_grid, DOS, 'k-', 'LineWidth', 1.5);
            % title('电子态密度 (DOS)');
            xlabel('Energy'); ylabel('DOS');
            grid on;

            % E_scan = linspace(0.1, 80, 20000);
            % 
            % % 初始化数组
            % Lyapunov_Exp = zeros(size(E_scan));
            % Loc_Length = zeros(size(E_scan));
            % 
            % fprintf('正在使用传递矩阵法计算 Lyapunov 指数...\n');
            % 
            % % ----------------主循环：扫描能量 E----------------
            % for i = 1:length(E_scan)
            %     Escan = E_scan(i);
            %     gamma = calculate_lyapunov(Escan, sqs_seq, U, a);
            % 
            %     Lyapunov_Exp(i) = gamma;
            %     % 局域化长度是 Lyapunov 指数的倒数
            %     % 避免除以零：如果 gamma 极小，说明是扩展态，xi 趋向无穷
            %     if gamma < 1e-6
            %         Loc_Length(i) = NaN; % 或者设置为系统长度
            %     else
            %         Loc_Length(i) = 1 / gamma;
            %     end
            % end
            % 
            % % ----------------绘图----------------
            % 
            % % 1. Lyapunov 指数
            % subplot(2, 3, 3);
            % plot(E_scan, Lyapunov_Exp, 'b-', 'LineWidth', 1.5);
            % hold on;
            % yline(0, 'k--');
            % xline(U, 'r--', 'Label', 'Potential U');
            % ylabel('Lyapunov Exponent \gamma (a.u.^{-1})');
            % title('Lyapunov 指数 \gamma(E)');
            % grid on;
            % 
            % % 2. 局域化长度
            % subplot(2, 3, 6);
            % % 使用对数坐标，因为局域化长度变化范围很大
            % semilogy(E_scan, Loc_Length, 'r-', 'LineWidth', 1.5);
            % hold on;
            % yline(2^n * a, 'k--', 'Label', 'System Size');
            % xlabel('Energy E (a.u.)');
            % ylabel('Localization Length \xi (a.u.)');
            % title('局域化长度 \xi(E) = 1/\gamma');
            % grid on;

            fprintf('计算完成。\n');
        end
    end
    E0(ooo) = E(1);
end

disp(E0);
disp(sum(E0)/length(E0));


function gamma = calculate_lyapunov(E, seq, U, a)
% 初始波函数向量 [psi; psi']
% 我们不关心绝对值，只关心增长率，初始设为单位向量
v = [1; 0];

log_norm_sum = 0; % 用于累加模长的对数
N = length(seq);

for k = 1:N
    % 判断当前格点的势能
    if seq(k) == 1
        V = U;
    else
        V = 0;
    end

    % 根据 E 和 V 的关系构建传递矩阵 M
    % 薛定谔方程: psi'' + 2(E-V)psi = 0
    diff = 2 * (E - V);

    if diff > 0
        % 振荡解 (Classical Allowed Region)
        k_vec = sqrt(diff);
        cos_k = cos(k_vec * a);
        sin_k = sin(k_vec * a);
        % 传递矩阵 relating [psi(x+a); psi'(x+a)] to [psi(x); psi'(x)]
        M = [cos_k,        (1/k_vec)*sin_k;
            -k_vec*sin_k, cos_k];

    elseif diff < 0
        % 指数解 (Classical Forbidden Region / Tunneling)
        kappa = sqrt(-diff);
        cosh_k = cosh(kappa * a);
        sinh_k = sinh(kappa * a);
        M = [cosh_k,        (1/kappa)*sinh_k;
            kappa*sinh_k,  cosh_k];

    else % diff == 0
        M = [1, a;
            0, 1];
    end

    % 传递矩阵乘法
    v = M * v;

    % ---- 关键数值技巧：重归一化 (Renormalization) ----
    % 随着矩阵连乘，v 的数值会迅速溢出(变成Inf)或下溢(变成0)。
    % 我们每一步都将 v 归一化，并记录模长的对数。
    current_norm = norm(v);
    v = v / current_norm;
    log_norm_sum = log_norm_sum + log(current_norm);
end

% Lyapunov 指数定义: gamma = lim(N->inf) (1/L) * ln|M_total|
% L = N * a 是总长度
L_total = N * a;
gamma = log_norm_sum / L_total;


end

