clear;
count = 0;
for i =3:2:11
    count = count+1;
    a = generate_symmetric_debruijn(i);
    aStr = sprintf('%g', a);
[runs,l] = analyze_runs_matrix(num2str(aStr(1:end/2)));
runs0(count,1:l) = runs(1,:);
end

function symmetric_db_sequence = generate_symmetric_debruijn(n)
% GENERATE_SYMMETRIC_DEBRUIJN 生成满足互换-翻转对称性的二元De Bruijn序列
%
% 输入: n (序列的阶数，子串长度)
% 输出: symmetric_db_sequence (长度为 2^n 的向量)
%
% 物理意义背景: 这种对称性类似于物理系统中的CPT对称或自旋链中的某些对偶性质。
%
% 算法原理: 构造序列的前半部分 P，令全序列 S = [P, NOT(Flip(P))]。
% 在搜索 P 时，同时锁定当前元组及其“互换反序”对偶元组。

    if n <= 0
        error('n must be a positive integer.');
    end

    % 基本参数
    total_len = 2^n;
    half_len = total_len / 2;
    
    % 预分配数组
    % visited 记录 n 元组的十进制值是否被占用 (0 到 2^n - 1)
    visited = false(1, total_len); 
    
    % 我们尝试寻找前半段序列 path (0/1 数组)
    % 为了打破对称性并固定起点，通常由 n 个 0 开始，
    % 但考虑到对称性，我们从全0开始尝试，注意全0的对偶是全1。
    % 这里采用 DFS 递归搜索。
    
    % 初始化路径，预分配内存
    path = zeros(1, half_len);
    
    % 计时开始
    tic;
    fprintf('正在搜索 n=%d 的对称 De Bruijn 序列 (搜索深度 %d)...\n', n, half_len);
    
    % 调用核心递归函数
    [success, result_path] = dfs_build(1, path, visited, n, half_len);
    
    if success
        % 构造全序列: S = [P, ~P_reversed]
        P = result_path;
        P_complement_reversed = ~P(end:-1:1); % 逻辑非 + 左右翻转
        symmetric_db_sequence = [P, P_complement_reversed];
        
        fprintf('成功找到序列! 耗时: %.4f 秒\n', toc);
        
        % 验证结果 (Self-Check)
        validate_sequence(symmetric_db_sequence, n);
    else
        error('未能找到符合该对称性的序列 (对于某些奇数 n 可能不存在此类严格对称)。');
    end
end

function [success, final_path] = dfs_build(idx, current_path, visited, n, target_len)
% DFS_BUILD 深度优先搜索构建前半部分
% idx: 当前正在填写的 current_path 的索引 (从1开始)
    
    % --- 基准情形：前半部分已填满 ---
    if idx > target_len
        % 此时需要检查"缝合处"的有效性。
        % 我们构造了 P，全序列是 S = [P, ~P_rev]。
        % 序列是循环的，需要检查:
        % 1. P 的尾部连接 ~P_rev 的头部 (中间接缝)
        % 2. ~P_rev 的尾部连接 P 的头部 (循环接缝)
        % 但由于构造的强对称性，只需要检查产生的元组是否与 visited 冲突即可。
        
        % 构建完整序列进行最终快速校验
        P = current_path;
        S = [P, ~P(end:-1:1)];
        
        % 简单起见，我们直接检查生成的全序列是否包含所有唯一的 n 元组
        % 在回溯过程中我们已经避开了大部分冲突，这里主要检查边界转换是否合法
        if check_debruijn_property(S, n)
            success = true;
            final_path = current_path;
        else
            success = false;
            final_path = [];
        end
        return;
    end

    % --- 递归步骤 ---
    % 尝试填充 0 或 1
    % 既然是物理系同学，我们用随机化贪心或者固定顺序。固定顺序 0 -> 1 更易复现。
    candidates = [0, 1]; 
    
    % 如果是第一步，由于 De Bruijn 序列的循环平移不变性，我们可以强制前 n 位为 0 
    % 来减少搜索空间 (但要注意全0的对偶是全1，不能在前半截同时出现)。
    % 为了通用性，这里不做过强的剪枝，仅从一位开始。
    
    for bit = candidates
        current_path(idx) = bit;
        
        % 如果当前长度不足 n，还不能形成完整的 n 元组，继续填
        if idx < n
            [success, final_path] = dfs_build(idx + 1, current_path, visited, n, target_len);
            if success, return; end
            continue;
        end
        
        % --- 约束检查 ---
        % 提取刚刚形成的 n 元组 (位于 current_path 的结尾)
        tuple_bits = current_path(idx-n+1 : idx);
        tuple_val = bi2de_fast(tuple_bits); % 转为十进制索引
        
        % 计算该元组的“互换反序”对偶 (Reverse-Complement)
        % 例如 n=4, tuple=0001 -> not=1110 -> rev=0111
        dual_bits = ~tuple_bits(end:-1:1);
        dual_val = bi2de_fast(dual_bits);
        
        % 关键剪枝逻辑：
        % 1. 当前元组 tuple_val 不能已经被访问过。
        % 2. 其对偶 dual_val 也不能已经被访问过 (因为它必须留给后半截序列)。
        % 3. 特例：如果 n 是偶数，可能存在 tuple_val == dual_val (自对偶)。
        %    自对偶元组只能出现在前半截和后半截的“接缝”处。
        %    在前半截的“内部”生成过程中，不允许出现自对偶，否则后半截对应位置也会是它，导致重复。
        
        if visited(tuple_val + 1) || visited(dual_val + 1)
            continue; % 跳过此 bit，回溯
        end
        
        % 如果 tuple_val == dual_val，这在前半段内部是不允许的
        % (除非它正好跨越了中点，但这由外部逻辑保证，内部生成不应产生)
        if tuple_val == dual_val
             continue;
        end

        % 标记占用
        visited(tuple_val + 1) = true;
        visited(dual_val + 1) = true; % 同时也锁死对偶位
        
        % 递归下一层
        [success, final_path] = dfs_build(idx + 1, current_path, visited, n, target_len);
        
        if success
            return;
        end
        
        % 回溯：撤销标记
        visited(tuple_val + 1) = false;
        visited(dual_val + 1) = false;
    end
    
    % 所有分支都失败
    success = false;
    final_path = [];
end

function valid = check_debruijn_property(seq, n)
    % 最终校验：确保序列是合法的 De Bruijn 序列
    len = length(seq);
    expected_len = 2^n;
    if len ~= expected_len
        valid = false; 
        return; 
    end
    
    seen = false(1, 2^n);
    % 扩展序列以处理循环 (append first n-1 bits)
    aug_seq = [seq, seq(1:n-1)];
    
    for i = 1:len
        sub = aug_seq(i : i+n-1);
        val = bi2de_fast(sub);
        if seen(val + 1)
            valid = false;
            return;
        end
        seen(val + 1) = true;
    end
    valid = true;
end

function d = bi2de_fast(b)
    % 简单的二进制转十进制，避免调用工具箱以保证兼容性
    % b 是行向量，最低位在右 (Matlab standard usually, but let's define clearly)
    % 这里假设 b(1) 是高位 (MSB), b(end) 是低位 (LSB) -> 对应书写习惯
    % 例如 [1 0 1] -> 5
    pow2 = 2 .^ (length(b)-1 : -1 : 0);
    d = sum(b .* pow2);
end

function validate_sequence(seq, n)
    % 打印和验证结果的辅助函数
    disp('------------------------------------------------');
    disp(['生成序列 (长度 ' num2str(length(seq)) '):']);
    disp(num2str(seq, '%d'));
    
    % 验证对称性
    S = seq;
    S_bar = ~S; % 01互换
    S_rev = S(end:-1:1); % 原序列翻转
    
    % 检查 S_bar 是否等于 S_rev (无需平移的情况)
    if isequal(S_bar, S_rev)
        disp('对称性验证: 完美通过 (S_bar == S_rev)');
    else
        % 如果不直接相等，检查是否通过循环移位相等
        % 构造 S_rev 的所有移位
        found_shift = false;
        for k = 0:length(S)-1
            S_rev_shift = circshift(S_rev, [0, k]);
            if isequal(S_bar, S_rev_shift)
                disp(['对称性验证: 通过 (S_bar == S_rev 左移 ' num2str(k) ' 位)']);
                found_shift = true;
                break;
            end
        end
        if ~found_shift
            warning('对称性验证: 失败');
        end
    end
    disp('------------------------------------------------');
end