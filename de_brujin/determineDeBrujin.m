function [isDeBruijn, missingSequences] = determineDeBrujin(A)
% CHECKDEBRUIJN 检查一个01数组是否为de Bruijn序列的线性展开
%
% 输入:
%   A - 一个只包含0和1的行或列向量（数组）。
%
% 输出:
%   isDeBruijn - 逻辑值，如果A是某个阶k的de Bruijn序列的线性展开，则为true。
%   missingSequences - 如果不是de Bruijn序列，则返回缺少的长度为k的子序列的字符串元胞数组。

    % 检查输入是否为01数组
    if ~isvector(A) || any(~ismember(A, [0, 1]))
        error('输入必须是只包含0和1的向量（数组）。');
    end

    N = length(A);
    
    % --- 1. 确定可能的阶 k ---
    % De Bruijn序列 B(k, 2) 的长度 N 必须满足 N = 2^k。
    
    % 检查N是否为2的幂
    if N == 0
        isDeBruijn = false;
        missingSequences = {};
        return;
    end
    
    k_double = log2(N);
    % 检查 N 是否是 2 的正整数次幂
    if abs(k_double - round(k_double)) > 1e-9 || k_double < 1
        isDeBruijn = false;
        % 如果长度不满足 2^k，我们无法确定阶 k，所以无法统计缺少的子序列。
        missingSequences = {'长度不满足N=2^k，无法确定阶k，因此不符合de Bruijn序列的长度要求。'};
        return;
    end
    
    k = round(k_double); % 序列的阶
    
    % --- 2. 生成所有可能的长度 k 的子序列 ---
    % 所有可能的 2^k 个长度为 k 的子串
    all_k_sequences = cell(1, N);
    for i = 0:N-1
        % 使用 dec2bin 生成 k 位二进制数
        bin_str = dec2bin(i, k);
        all_k_sequences{i+1} = bin_str;
    end
    
    % --- 3. 提取输入数组 A 中的所有长度 k 的子序列 ---
    
    % De Bruijn序列的定义是循环的，因此最后一个子串是通过首尾相接得到的。
    % 线性展开的de Bruijn序列 B(k, 2) 的长度是 2^k，它包含 2^k 个子串。
    % 线性提取 (N-k+1) 个子串
    linear_sequences = cell(1, N - k + 1);
    for i = 1 : N - k + 1
        % 提取 A(i) 到 A(i+k-1)
        sub_array = A(i : i + k - 1);
        % 将数组转换为字符串
        linear_sequences{i} = num2str(sub_array, '%d');
    end

    % 循环产生的子串
    % B(k, 2) 的线性展开 A 的长度 N=2^k，根据定义，它还必须包含由 A 的末尾 k-1 位和开头的 1 位组成的循环子串
    % A(N-k+2), ..., A(N), A(1) 
    % A(N-k+3), ..., A(N), A(1), A(2) 
    % ... 
    % A(N), A(1), ..., A(k-1) 
    
    % 实际的循环子串数量应该是 N 个
    extracted_sequences = cell(1, N);
    
    for i = 1 : N
        % 提取 A(i) 到 A(i+k-1)，使用 (mod(j-1, N) + 1) 实现循环索引
        sub_array = zeros(1, k);
        for j = 1 : k
            idx = mod(i + j - 2, N) + 1;
            sub_array(j) = A(idx);
        end
        extracted_sequences{i} = num2str(sub_array, '%d');
    end
    
    
    % --- 4. 比较和判断 ---
    
    % 检查提取的子序列数量是否正确 (应为 N = 2^k 个)
    num_extracted = length(extracted_sequences);
    if num_extracted ~= N
        % 理论上不会发生，除非 N < k
        isDeBruijn = false;
        missingSequences = {'提取的子序列数量不等于预期的N=2^k。'};
        return;
    end

    % 检查 extracted_sequences 中是否有重复
    unique_extracted = unique(extracted_sequences);
    if length(unique_extracted) ~= N
        isDeBruijn = false;
        missingSequences = setdiff(all_k_sequences, unique_extracted);
        return;
    end
    
    % 检查 extracted_sequences 是否包含了所有可能的子序列
    % 排序后比较，如果两者相同，则说明包含所有子序列且没有重复
    if isequal(sort(unique_extracted), sort(all_k_sequences))
        isDeBruijn = true;
        missingSequences = {};
    else
        % 如果它们不相同，找出缺少的子序列
        isDeBruijn = false;
        missingSequences = setdiff(all_k_sequences, unique_extracted);
    end
    
end