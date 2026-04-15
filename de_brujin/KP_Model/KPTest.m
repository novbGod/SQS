function SQS_Localization_Analysis()
    % ----------------参数设置----------------
    % 物理参数 (原子单位制: hbar=1, m=1)
    U = 50.0;           % 势垒高度 ("1"处的势能)
    a = 1.0;            % 单个原子格点宽度
    n = 15;
    num_cells = 2^n;   % 用于计算Lyapunov指数的序列长度 (需要很长以收敛)


    % 生成更长的 SQS 序列以保证统计收敛
    % 这里用随机序列演示，实际请替换为你的 SQS 生成算法

    sqs_seq = randi([0, 1], 1, num_cells); 

    sqs_seq = zeros(1,2^n); sqs_seq(1:2:end) = 1;
    % 能量扫描范围 (覆盖从 0 到超过势垒 U)
    E_scan = linspace(0.1, 80, 200); 
    
    % 初始化数组
    Lyapunov_Exp = zeros(size(E_scan));
    Loc_Length = zeros(size(E_scan));
    
    fprintf('正在使用传递矩阵法计算 Lyapunov 指数...\n');
    
    % ----------------主循环：扫描能量 E----------------
    for i = 1:length(E_scan)
        E = E_scan(i);
        gamma = calculate_lyapunov(E, sqs_seq, U, a);
        
        Lyapunov_Exp(i) = gamma;
        % 局域化长度是 Lyapunov 指数的倒数
        % 避免除以零：如果 gamma 极小，说明是扩展态，xi 趋向无穷
        if gamma < 1e-6
            Loc_Length(i) = NaN; % 或者设置为系统长度
        else
            Loc_Length(i) = 1 / gamma;
        end
    end
    
    % ----------------绘图----------------
    figure('Name', 'Localization Properties', 'Color', 'w');
    
    % 1. Lyapunov 指数
    subplot(2, 1, 1);
    plot(E_scan, Lyapunov_Exp, 'b-', 'LineWidth', 1.5);
    hold on;
    yline(0, 'k--');
    xline(U, 'r--', 'Label', 'Potential U');
    ylabel('Lyapunov Exponent \gamma (a.u.^{-1})');
    title('Lyapunov 指数 \gamma(E)');
    grid on;
    
    % 2. 局域化长度
    subplot(2, 1, 2);
    % 使用对数坐标，因为局域化长度变化范围很大
    semilogy(E_scan, Loc_Length, 'r-', 'LineWidth', 1.5);
    hold on;
    yline(num_cells * a, 'k--', 'Label', 'System Size');
    xlabel('Energy E (a.u.)');
    ylabel('Localization Length \xi (a.u.)');
    title('局域化长度 \xi(E) = 1/\gamma');
    grid on;
    
    fprintf('计算完成。\n');
end

% ---------------- 子函数：计算单个能量的 Lyapunov 指数 ----------------
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