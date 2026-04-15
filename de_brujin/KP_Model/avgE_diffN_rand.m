clear;
tic;
% ----------------参数设置----------------
% 物理参数 (原子单位制: hbar=1, m=1)
U = 10.0;           % 势垒高度 (对应序列"1"处的势能)
a = 1.0;            % 单个原子格点(site)的宽度
n = 5;
num = 1;        %计算同一个n的SQS的数量
StateNums = [20,20,20,150,150,400,400,400,400,400,400,400];%对于每一个SQS，计算量子态的数量

% 0代表势能为0，1代表势能为U
for kkk = 1:1
    for ooo = 1:1
        for n = 2:9
            for uuu = 1:1000
                StateNum = 1;

                % sqs_seqs = gen_deBrujin_seqs(2,n,num) ;
                % sqs_seqs = generate_symmetric_debruijn_limited(n,num);
                % sqs_seqs = zeros(1,2^n); sqs_seqs(1:2:end) = 1;
                %  sqs_seqs = zeros(1,2^n); sqs_seqs(1:end/2) = 1;
                base_array = [zeros(1, 2^n/2), ones(1, 2^n/2)];random_indices = randperm(2^n);sqs_seqs = base_array(random_indices);%disp('random');

                for sqsi = 1:ceil(num/10):num
                    sqs_seq = sqs_seqs(sqsi,:);
                    num_sites = length(sqs_seq);

                    % 离散化参数
                    grid_points_per_site = 1000; % 每个site划分的网格点数 (精度控制)
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
                    % fprintf('正在求解特征值 (矩阵大小: %dx%d)...\n', N, N);

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
                    %
                    % % 归一化波函数 (数值积分 int |psi|^2 dx = 1)
                    % for i = 1:length(E)
                    %     norm_factor = sqrt(trapz(x, abs(Psi(:,i)).^2));
                    %     Psi(:,i) = Psi(:,i) / norm_factor;
                    % end
                    %
                    % % ----------------结果可视化与物理量计算----------------
                    % figure('Name', 'SQS Kronig-Penney Analysis', 'Color', 'w');
                    %
                    % % 1. 势场与前几个本征态
                    % subplot(2, 3, 1);
                    % scale = max(abs(Psi(:,1))) * 0.5; % 波函数缩放因子，便于显示
                    % plot(x, V, 'k-', 'LineWidth', 1.5); hold on;
                    % num_states_plot = min(5, length(E));
                    % legend_str = {'Potential V(x)'};
                    % for i = 1:num_states_plot
                    %     % 将波函数平移到对应的能级高度显示
                    %     plot(x, Psi(:,i)*scale*10 + E(i), 'LineWidth', 1);
                    %     legend_str{end+1} = sprintf('E_{%d}=%.2f', i, E(i));
                    % end
                    % title(sprintf('势场与波函数 (前5个态), 多体n = %d', n));
                    % xlabel('Position x'); ylabel('Energy / Amplitude');
                    % ylim([min(V)-5, max(E(num_states_plot))+5]);
                    % grid on;

                    % % 2. 概率密度分布 (查看局域化)
                    % subplot(2, 3, 2);
                    % hold on;
                    % for i = 1:num_states_plot
                    %     % 将波函数平移到对应的能级高度显示
                    %     plot(x, abs(Psi(:,i)).^2, 'LineWidth', 1.5);
                    % end
                    % title('概率密度 |\psi|^2(前5个态)');
                    % xlabel('Position x'); ylabel('Probability Density');
                    % %legend('Ground State', '1th Excited State', '2th Excited State', '3th Excited State', '4th Excited State');
                    % grid on;

                    % % 3. 能级分布 (Energy Spectrum)
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



                end
                E0(n,uuu) = E(1);
            end
                E0avg(n) = sum(E0(n,:))/size((E0),2);
                fprintf('average E = %d, n = %d\n', E0avg(n), n);
        end

        %disp(sprintf('average E = %d', sum(E0)/length(E0)));
        %AllE0(kkk,:) = E0;
    end
end

E0avgSum = cumsum(E0avg);
figure
plot(2:9,E0avg(2:end))
xlabel('n');ylabel('E0');title('random');

figure
plot(2:9,E0avgSum(2:end))
xlabel('n');ylabel('E0');title('randomSum');
toc