clear;
tic;
% ----------------参数设置----------------
% 物理参数 (原子单位制: hbar=1, m=1)
U = 10;           % 势垒高度 (对应序列"1"处的势能)
a = 1.0;            % 单个原子格点(site)的宽度
num = 4096;   interve = 1;     %计算同一个n的SQS的数量
StateNum = 70;
nmin = 5;
nmax = 5;
factor = 10;%方差绘画放大系数
% 0代表势能为0，1代表势能为U

for n = nmin:nmax

    sqs_seqs = gen_deBrujin_seqs(2,n,num) ;
    %sqs_seqs = ManyRandom(num,2^n);

    for sqsi = 1:interve:num
        sqs_seq = sqs_seqs(sqsi,:);
        num_sites = length(sqs_seq);
        grid_points_per_site = 1000; % 每个site划分的网格点数 (精度控制)
        dx = a / grid_points_per_site;
        N = num_sites * grid_points_per_site; % 总网格点数
        L = N * dx; % 系统总长度
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
        e = ones(N, 1);
        Laplacian = spdiags([e -2*e e], -1:1, N, N);
        Laplacian(1, N) = 1;
        Laplacian(N, 1) = 1;
        T = -(1/2) * Laplacian / (dx^2);
        V_matrix = spdiags(V, 0, N, N);
        H = T + V_matrix;
        if N < 0
            [Psi, E_diag] = eig(full(H));
            E = diag(E_diag);
        else
            % 求解前100个最低能级
            [Psi, E_diag] = eigs(H, StateNum, 'sm');
            E = diag(E_diag);
        end
        [E, idx] = sort(E);
        Psi = Psi(:, idx);
        % subplot(2, 3, 4);
        % plot(1:length(E), E, 'bo-', 'MarkerSize', 3);
        % title('能级谱 (Energy Spectrum)');
        % xlabel('Quantum Number n'); ylabel('Energy E_n');
        % grid on;
        %
        % % 4. 态密度 (DOS) - 使用高斯展宽
        % subplot(2, 3, 5);
        % deltaE = (max(E) - min(E))/N;
        % sigma = 0.5; % 高斯展宽宽度
        % E_grid = linspace(min(E), max(E), 500000);
        % DOS = zeros(size(E_grid));
        % for i = 1:length(E)
        %     DOS = DOS + (1/(sigma*sqrt(2*pi))) * exp(-(E_grid - E(i)).^2 / (2*sigma^2));
        % end
        % plot(E_grid, DOS, 'k-', 'LineWidth', 1.5);
        % title('电子态密度 (DOS)');
        % xlabel('Energy'); ylabel('DOS (a.u.)');
        % grid on;
        Esqs(sqsi,:) = E(:);

    end

end

for n = nmin:nmax

    %sqs_seqs = gen_deBrujin_seqs(2,n,num) ;
    sqs_seqs = ManyRandom(num,2^n);

    for sqsi = 1:interve:num
        sqs_seq = sqs_seqs(sqsi,:);
        num_sites = length(sqs_seq);
        grid_points_per_site = 1000; % 每个site划分的网格点数 (精度控制)
        dx = a / grid_points_per_site;
        N = num_sites * grid_points_per_site; % 总网格点数
        L = N * dx; % 系统总长度
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
        e = ones(N, 1);
        Laplacian = spdiags([e -2*e e], -1:1, N, N);
        Laplacian(1, N) = 1;
        Laplacian(N, 1) = 1;
        T = -(1/2) * Laplacian / (dx^2);
        V_matrix = spdiags(V, 0, N, N);
        H = T + V_matrix;
        if N < 0
            [Psi, E_diag] = eig(full(H));
            E = diag(E_diag);
        else
            % 求解前100个最低能级
            [Psi, E_diag] = eigs(H, StateNum, 'sm');
            E = diag(E_diag);
        end
        [E, idx] = sort(E);
        Psi = Psi(:, idx);
        Erand(sqsi,:) = E(:);
    end

end

ErandSum = cumsum(Erand,2);
EsqsSum = cumsum(Esqs,2);

for i = 1:StateNum
    Erandvar(i) = sqrt(var(Erand(:,i)));
    ErandSumvar(i) = sqrt(var(ErandSum(:,i)));
    racioRand(i) = Erandvar(i)/Erand(1,i);
    Esqsvar(i) = sqrt(var(Esqs(:,i)));
    EsqsSumvar(i) = sqrt(var(EsqsSum(:,i)));
    racioSQS(i) = Erandvar(i)/Esqs(1,i);
    fprintf('sigma E0 = %d, State = %d, ratio = %d\n', Erandvar(i), i, racioRand(i));
end

plotPhysicalAnalysis(Esqs,Erand);
toc
% xlabel('Quantum number');
% ylabel(sprintf('Ground State Energy (Mean \\pm Std, Std has been multiplied by %d for clarity)',factor));
% title(sprintf('Statistical Comparison of SQS and random structure under potential U = %d, n = %d', U, nmin:nmax));
% legend({'SQS','Random structure' }, 'Location', 'best');



% M = [Erandvar', Esqsvar']; % 注意：bar函数要求每一列是一个数据组
% 
% figure; 
% bar(M);
% 
% % 设置图表属性
% % title(sprintf('n = %d 的随机结构和SQS的能量波动对比', n));
% xlabel('Quantum number');
% ylabel(sprintf('Standard Deviation of Energy at Each Level'));
% legend('Random structure', 'SQS', 'Location', 'northwest'); % 添加图例
% grid on;

% M = [ErandSumvar', EsqsSumvar']; % 注意：bar函数要求每一列是一个数据组
% 
% figure; % 创建新的图窗
% bar(M);
% 
% % 设置图表属性
% title(sprintf('n = %d 的随机结构和SQS的能量累计波动对比', n));
% xlabel('量子数');
% ylabel(sprintf('%d 个结构的各级能量的标准差', num));
% legend('随机结构', 'SQS', 'Location', 'northwest'); % 添加图例
% grid on;