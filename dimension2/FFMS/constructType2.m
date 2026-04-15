function A11 = constructType2(A, beta_seq, n)
    % A: 原 (r, s; m, n) 数组
    % beta_seq: 跨度为 n-1 的 de Bruijn 序列 (包含起始的 n-1 个 0)
    % n: 目标跨度

    [r, s] = size(A);
    kind = length(unique(beta_seq)); %识别元素数
    % 1. 计算累加序列 c 
    % c_j = a_0 + ... + a_{j-1} (mod 2)
    c = mod(cumsum(beta_seq(1:end-1)), 2); 
    
    % 2. 构造 B 向量 [cite: 48, 50]
    B = zeros(1, 2^(n-1) * s);
    

    if n >= 3
        for k = 0:(s-1)
            start_idx = s + 1 + k * (kind^(n-1) - 1);
            end_idx = start_idx + (kind^(n-1) - 1) - 1;
            B(start_idx:end_idx) = c;
        end
    elseif n == 2
        for k = 1: kind
        B(s + k:kind:end) = k;
        end
    elseif n == 1
        
    end

    % 3. 构造 Z 矩阵 (2r 行, 2^(n-1)*s 列) [cite: 52]
    Z = repmat(A, 2, 2^(n-1));

    % 4. 构造新数组 A11 (2r 行) [cite: 53]
    % 每一行是 B 与 Z 矩阵前 h-1 行累加之和
    A11 = zeros(2*r, 2^(n-1) * s);
    current_row_sum = B;
    for h = 1:(2*r)
        current_row_sum = mod(current_row_sum + Z(h, :), 2);
        A11(h, :) = current_row_sum;
    end
end