to = generateDeBruijnTorus(1,2);
[a,b,c] = check2(to, 2, 2, 4);
plotMatrixBlocks(to)

function torus = generateDeBruijnTorus(s, t)
    % 参数说明:
    % s, t: 自然数输入
    % 输出: (4st^2, 4s^3t^2; 2, 2)_{2st} de Bruijn 环面
    
    k = 2 * s * t; % 基数 k 
    
    % 1. 构造基础序列 c = (0, 1, -2, 3, -4, ..., k-1) [cite: 89]
    c = zeros(1, k);
    for p = 2:k
        if mod(p, 2) == 0
            c(p) = p - 1;
        else
            c(p) = -(p - 1);
        end
    end
    
    % 2. 生成所有 alpha_i 和 beta_j 序列 [cite: 91, 94]
    % 序列长度为 2k = 4st 
    alpha = cell(1, s*t);
    beta = cell(1, s*t);
    
    for i = 0:(s*t - 1)
        % alpha_i 由 c(2i) 生成，起始值为 2i 
        c_shift_alpha = circshift(c, -2*i);
        alpha{i+1} = generateSequence(2*i, c_shift_alpha, 2*k, k);
        
        % beta_i 由 c(-2i) 生成，起始值为 0 [cite: 91]
        c_shift_beta = circshift(c, 2*i);
        beta{i+1} = generateSequence(0, c_shift_beta, 2*k, k);
    end
    
    % 3. 按照论文第 4 节的布局拼接矩阵 
    % R = 4st^2, S = 4s^3t^2
    Q = [];
    for j = 1:s*t
        Qj = [];
        for r = 0:s-1
            Gamma_rj = [];
            for m = 0:t-1
                % 计算索引 i = tr + m
                idx_i = t * r + m + 1;
                % 生成 Mesh(alpha_i, beta_j) 
                M_ij = mesh_op(alpha{idx_i}, beta{j});
                % 纵向拼接 
                Gamma_rj = [Gamma_rj; M_ij]; 
            end
            % 横向拼接 
            Qj = [Qj, Gamma_rj];
        end
        % 最终横向拼接所有 Qj 
        Q = [Q, Qj];
    end
    
    torus = Q;
end

function seq = generateSequence(start_val, c_vec, len, k)
    % 根据 a_{j+1} = a_j + c_j (mod k) 生成序列 [cite: 82]
    seq = zeros(1, len);
    seq(1) = mod(start_val, k);
    for j = 1:(len-1)
        % c_vec 循环使用
        c_val = c_vec(mod(j-1, length(c_vec)) + 1);
        seq(j+1) = mod(seq(j) + c_val, k);
    end
end

function M = mesh_op(a, b)
    % 定义 Mesh(a, b) = [cij]
    % cij = bj (i+j 为偶数), ai (i+j 为奇数) 
    % 注意: MATLAB 索引从 1 开始，需调整奇偶判断
    n = length(a);
    M = zeros(n, n);
    for i = 1:n
        for j = 1:n
            % 论文中 i,j 从 0 开始，i+j even 对应 MATLAB (i+j) 为偶数
            if mod(i + j, 2) == 0
                M(i,j) = b(j);
            else
                M(i,j) = a(i);
            end
        end
    end
end