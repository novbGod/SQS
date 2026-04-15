function A1 = constructType1(A, alpha, n)
    % A: 原 (r, s; m, n) 数组
    % alpha: 跨度为 n 的 de Bruijn 序列去掉第一个 0 后的序列 (长度 2^n - 1)
    % n: 跨度 (span)

    [r, s] = size(A);
    
    % 1. 构造 B 向量 [cite: 37]
    % 前 s 个元素为 0，后面跟随 s 组 alpha 序列
    B = zeros(1, 2^n * s);
    for k = 0:(s-1)
        start_idx = s + 1 + k * (2^n - 1);
        end_idx = start_idx + (2^n - 1) - 1;
        B(start_idx:end_idx) = alpha;
    end

    % 2. 构造 Z 矩阵 (水平平铺 A 以匹配 B 的长度) [cite: 38]
    Z = repmat(A, 1, 2^n);

    % 3. 构造新数组 A1 的每一行 [cite: 39]
    % 行公式: Row_h = B + sum_{i=1}^{h-1} Z_{i*}
    A1 = zeros(r, 2^n * s);
    A1(1, :) = mod(B + Z(1, :), 2); % 修正：根据式 2.1 逻辑
    
    current_sum = B;
    for i = 1:r
        current_sum = mod(current_sum + Z(i, :), 2);
        A1(i, :) = current_sum;
    end
    % 注意：根据论文(2.1)，第一行起始为 B + Z_{1*}
end