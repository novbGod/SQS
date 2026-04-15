function is_de_bruijn = checkDeBrujin(sequence)
%CHECKDEBRUIJN 检查一个01数组是否是二元de Bruijn序列 B(2, n)。
%
% 输入:
%   sequence - 一个由 0 和 1 组成的行或列向量。
%
% 输出:
%   is_de_bruijn - 逻辑值 (true 或 false)。

    % 确保输入是行向量且元素是0或1
    sequence = sequence(:)'; 
    if any(sequence ~= 0 & sequence ~= 1)
        warning('输入序列包含非0或非1的元素。');
        is_de_bruijn = false;
        return;
    end

    L = length(sequence); % 序列长度
    
    %% 1. 长度校验
    % de Bruijn序列 B(2, n) 的长度 L 必须是 2^n。
    % 检查 L 是否是 2 的幂次。
    
    n = log2(L);
    if n ~= floor(n) || L < 2
        % 如果 log2(L) 不是整数，说明长度 L 不是 2 的整数幂
        fprintf('序列长度 L = %d。不是 2^n 的形式，因此不是 de Bruijn 序列。\n', L);
        is_de_bruijn = false;
        return;
    end
    
    % n 是子串的长度
    fprintf('序列长度 L = %d。对应的子串长度 n = %d。\n', L, n);
    
    %% 2. 子串校验 (核心)
    % 序列中必须恰好包含所有 2^n 个长度为 n 的子串，且每个出现一次。
    
    num_substrings = 2^n;
    % 初始化一个逻辑数组，用于记录每个 n-子串是否已被找到
    found_substrings = false(1, num_substrings); 
    
    % 为了考虑 de Bruijn 序列的循环性，我们在序列末尾添加前 n-1 个元素
    % 这样才能捕获到循环回来的 n-子串
    circular_sequence = [sequence, sequence(1:n-1)];
    
    % 遍历所有 L 个可能的起始位置，提取 n-子串
    for i = 1:L
        % 提取当前 n-子串
        current_substring_vector = circular_sequence(i : i + n - 1);
        
        % 将 n-子串 (01向量) 转换为其对应的十进制索引
        % 例如: [0 0 1] -> 1, [1 1 1] -> 7
        % 注意: MATLAB通常从1开始索引。0-7 对应 1-8。
        
        % 计算十进制值 (从 0 到 2^n - 1)
        % polyval([1 0], 2) 计算 x+0 在 x=2 时的值，即 2。
        % current_substring_vector: [d_n, d_{n-1}, ..., d_1]
        % decimal_value = d_n*2^{n-1} + ... + d_1*2^0
        
        decimal_value = bin2dec(num2str(current_substring_vector));
        
        % 转换为 MATLAB 索引 (从 1 到 2^n)
        index = decimal_value + 1; 
        
        % 检查这个子串是否已经出现过
        if found_substrings(index) == true
            fprintf('子串 "%s" (十进制 %d) 出现了两次或更多次。不是 de Bruijn 序列。\n', ...
                    num2str(current_substring_vector), decimal_value);
            is_de_bruijn = false;
            return; 
        else
            % 标记这个子串为已找到
            found_substrings(index) = true;
        end
    end
    
    %% 3. 最终确认
    % 如果循环结束，所有子串都只出现了一次，那么 found_substrings 应该全为 true
    if all(found_substrings)
        fprintf('序列成功包含了所有 %d 个长度为 %d 的子串，且每个恰好一次。\n', L, n);
        is_de_bruijn = true;
    else
        % 理论上不应该到达这里，除非代码逻辑有误
        fprintf('错误：循环结束后发现并非所有子串都被找到。\n');
        is_de_bruijn = false;
    end

end