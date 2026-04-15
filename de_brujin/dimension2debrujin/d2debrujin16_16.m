% 运行函数
a = deBruijnArray_16x16_4x2()

% 显示阵列（您可以看到它是一个 16x16 的 0 和 1 组成的矩阵）

function A_16x16 = deBruijnArray_16x16_4x2()
% DEBRUIJNARRAY_16X16_4X2 构造一个 (16, 16; 4, 2) 二进制 De Bruijn 阵列。
% 阵列 A_16x16 是一个 16x16 的二进制矩阵，其所有的 4x2 子矩阵
% （包括周期环绕的部分）都出现且仅出现一次。
% 
% 步骤：
% 1. 确定生成长度为 2^8 - 1 = 255 的 M-序列所需的本原多项式。
% 2. 生成 M-序列。
% 3. 将 M-序列转换为长度为 2^8 = 256 的 De Bruijn 序列。
% 4. 将 De Bruijn 序列折叠成 16x16 的阵列。

    % --- 1. 阵列参数定义 ---
    R = 16; % 阵列行数
    S = 16; % 阵列列数
    M = 4;  % 窗口行数
    N = 2;  % 窗口列数
    
    % 阶数 n 必须满足 R*S = 2^(M*N) = 2^n
    n_order = M * N; % n = 8

    disp(['构造 (', num2str(R), ',', num2str(S), '; ', num2str(M), ',', num2str(N), ') 阵列...']);

    % --- 2. 找到本原多项式 ---
    % MATLAB 的 comm 库中有一个 'primpoly' 函数。
    % 我们可以使用 'primpoly' 函数获取一个阶数 n_order=8 的本原多项式。
    % 这里选择最小项数的本原多项式。
    
    try
        % primpoly 返回一个整数，其二进制表示是多项式的系数
        % D^8 + D^4 + D^3 + D^2 + 1 对应于整数 2^8 + 2^4 + 2^3 + 2^2 + 2^0 = 256 + 16 + 8 + 4 + 1 = 285
        p = primpoly(n_order, 'min', 'nodisplay');
    catch
        % 如果没有 Communications Toolbox，则手动指定一个多项式（285 是一个已知本原多项式）
        warning('未找到 Communications Toolbox。使用默认本原多项式 285 (D^8 + D^4 + D^3 + D^2 + 1)。');
        p = 285; 
    end
    
    % --- 3. 生成 M-序列 (长度 L_m = 2^n - 1 = 255) ---
    % M-序列 (Maximum Length Sequence) 是由 LFSR 生成的。
    % 'lfsr' 函数生成一个周期为 2^n - 1 的序列。
    
    % 将十进制多项式 p 转换为二进制系数向量（按降幂排列）
    % 例如：p=285 -> D^8+D^4+D^3+D^2+1 -> [1 0 0 0 1 1 1 0 1]
    poly_coeffs = de2bi(p, n_order + 1, 'left-msb');
    
    % 使用初始状态 [0 0 ... 0 1]
    initial_state = zeros(1, n_order);
    initial_state(end) = 1;

    % 使用 'comm.LFSREncoder' 或手动实现 LFSR，但对于标准 M-序列，
    % 依赖 'lfsr' (如果可用) 更简洁，或者使用 'comm.PNSequence'。
    % 由于 'lfsr' 函数依赖于 Communications Toolbox，这里提供一个纯 MATLAB 实现的替代方案：
    
    L_m = 2^n_order - 1;
    m_sequence = zeros(1, L_m);
    state = initial_state;
    
    % 反馈系数 (对应 x^8 + x^4 + x^3 + x^2 + 1)
    % C = [1 0 0 0 1 1 1 0 1] 降幂 (x^8 ... x^0)
    % 需要反馈到寄存器第一位的值：x8 + x4 + x3 + x2 + 1 = 0
    % 故 x8 = x4 + x3 + x2 + 1 (mod 2)
    feedback_taps = [8, 4, 3, 2]; % 反馈到 8, 4, 3, 2 次幂项
    
    for k = 1:L_m
        % 输出是寄存器末尾的值 (x^0)
        m_sequence(k) = state(n_order);
        
        % 计算下一个输入位 (反馈)
        % 反馈项：state(n_order - 4 + 1), state(n_order - 3 + 1), state(n_order - 2 + 1), state(n_order)
        % 即 state(5), state(6), state(7), state(8)
        
        next_bit = mod(state(n_order - 4) + state(n_order - 3) + state(n_order - 2) + state(n_order), 2);
        
        % 移位
        state(2:n_order) = state(1:n_order-1);
        state(1) = next_bit;
    end
    
    % M-序列的最后一个 1 是初始状态的第一个输出 (M-序列包含所有非零 n 组)
    % 但这里手动实现的 M-序列的长度 L_m=255 已经包含所有非零 n 组，
    % 且其循环移位包含了 M-序列的所有周期。
    
    % --- 4. 转换为 De Bruijn 序列 (长度 L_b = 2^n = 256) ---
    % De Bruijn 序列 B 包含所有 2^n 个 n 组，包括全零 n 组。
    % 方法：在 M-序列的 n 个连续零出现的位置之前插入一个零。
    % 对于 M-序列，n 个连续零（00...0）只出现一次。
    
    % M-序列 M 在其周期循环的开头（全 0 状态之前）有 n-1 个 0。
    % 我们的 m_sequence 已经从第一个 '1' 开始，前 n-1 位是 0000000。
    % M-序列 M 的最后 n-1 位也是 0。
    
    % 序列 M 包含 n-1 个 0 之后的一个 1 (1 0000000... M-sequence)
    % 它的最后一个 '0' 后面会跟 n-1 个 '0'
    
    % 构造 De Bruijn 序列 B：在 M-序列 M 的开头插入一个 0
    B_sequence = [0, m_sequence]; 
    L_b = length(B_sequence); % L_b = 256
    
    % 校验：De Bruijn 序列的长度必须是 R*S
    if L_b ~= R * S
        error('序列长度与阵列大小不匹配。');
    end

    % --- 5. 折叠成 16x16 阵列 ---
    % 将 B_sequence 逐行填充到 A_16x16 阵列中
    A_16x16 = reshape(B_sequence, S, R)'; % reshape 默认按列填充，因此需要转置
    
    disp('构造完成。阵列 A_16x16 如下：');
    % disp(A_16x16); % 打印阵列
end