
function [is_unique, appearTimes] = is_debruijn_property(sequence,n)
% IS_DEBRUIJN_PROPERTY 验证一个三元字符串是否包含所有长度为 n 的子串（De Bruijn 性质）。
%
% 验证序列的长度是否为 3^n，并检查其所有长度为 n 的循环子串是否唯一。
%
% 输入:
%   sequence (char array): 待验证的三元字符串 (仅包含 '0', '1', '2')
%   n (int): 子串的阶数
%
% 输出:
%   is_unique (logical): 如果所有长度为 n 的循环子串都唯一，则为 true。
%   expected_length (int): 阶数 n 对应的 De Bruijn 序列的期望长度 (3^n)。
%   actual_length (int): 输入字符串的实际长度。

    % 1. 检查长度是否符合 De Bruijn 序列的要求
    actual_length = length(sequence);
    n_seq = log(actual_length)/log(3);
    if abs(n_seq-round(n_seq)) >= 0.0001
        is_unique = false;
        fprintf('错误: 字符串长度不符合要求。\n');
        appearTimes = 0;
        return;
    end

    % 2. 提取并检查所有长度为 n 的循环子串的唯一性
    
    % 使用 cell 数组来存储提取的 n 长度子串
    n_mers = cell(1, actual_length);
    
    % 序列的循环版本：为了提取最后的 n-1 个循环子串
    % 例如，对于序列 '0012' (n=2)，循环版本是 '00120'，
    % 这样可以得到子串 '00', '01', '12', '20'
    cyclic_sequence = [sequence, sequence(1:n-1)];

    % 遍历提取所有 n-mer (总共 actual_length 个)
    for i = 1:actual_length
        % 提取从位置 i 开始，长度为 n 的子串
        start_index = i;
        end_index = i + n - 1;
        n_mers{i} = cyclic_sequence(start_index:end_index);
    end

    % 3. 检查唯一性
    
    % 使用 unique 函数来检查 cell 数组中的元素是否重复
    unique_n_mers = unique(n_mers);
    [Values, ~, ix] = unique(n_mers); 

    % 2. 使用 accumarray 统计每个索引的出现次数
    % ix 是分组索引，1 是累加值（表示每次出现计数 1）
    Counts = accumarray(ix(:), 1); % ix(:) 确保是列向量
    % 如果 unique 元素的数量等于 n_mers 的总数，则所有子串唯一。
    if all(Counts(:) == Counts(1))
        is_unique = true;
        fprintf('验证通过: 字符串长度为 %d，且所有 %d 个长度为 %d 的子串的都出现 %d 次。\n', ...
                actual_length, actual_length, n, Counts(1));
        appearTimes = Counts(1);
    else
        is_unique = false;
        fprintf('验证失败: 字符串长度为 %d，但子串的出现次数不同。\n', actual_length);
        fprintf('  发现的唯一子串数量: %d\n', length(unique_n_mers));
        appearTimes = 0;
    end
end