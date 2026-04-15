clear;
n = 10;               
num = 4;
N = n;%子串长度
A = generate_debruijn_sequence(2,n)
a = A - '0';

% 3. 构造匿名函数句柄，绑定额外的参数
% 关键：check_func 现在只接受一个参数 sub，但内部调用了所有参数。
check_func = @(sub) my_actual_check(sub, num); 

% 4. 调用主函数
result = count_filtered_dihedral_subsequences(a, N, check_func);

o = 0;
for i = 1:size(result,1)
appearTimes(i) = result{i,2};
o = o + result{i,2};
end

figure
bar(appearTimes);

disp('筛选后的循环/反转子串统计结果:');
disp(result);



function is_valid = my_actual_check(sub,n)
    if sum(sub) == n
        is_valid = true;  % 通过判断
    else
        is_valid = false; % 未通过判断
    end
end

function result = compare_subsequences_lex(A, B)
% 比较两个 0-1 数组的字典序
% result < 0 : A < B (A更小)
% result = 0 : A = B
% result > 0 : A > B
    for k = 1:length(A)
        if A(k) < B(k)
            result = -1;
            return;
        elseif A(k) > B(k)
            result = 1;
            return;
        end
    end
    result = 0;
end

function min_sub = get_min_representation_dihedral(sub, n)
% 找到一个长度为 n 的子串在循环平移和反向反转意义下的字典序最小表示

    min_sub = sub;
    
    % 集合A: 原始串及其 n-1 次循环平移
    temp_sub = sub;
    for k = 1:n
        % 比较
        if compare_subsequences_lex(temp_sub, min_sub) < 0
            min_sub = temp_sub;
        end
        % 平移
        temp_sub = [temp_sub(2:end), temp_sub(1)]; 
    end

    % 集合B: 反转串及其 n 次循环平移
    rev_sub = fliplr(sub); % 反转
    temp_sub = rev_sub;
    for k = 1:n
        % 比较
        if compare_subsequences_lex(temp_sub, min_sub) < 0
            min_sub = temp_sub;
        end
        % 平移
        temp_sub = [temp_sub(2:end), temp_sub(1)];
    end
end

function result_cell = count_filtered_dihedral_subsequences(arr, n, check_func)
% COUNT_FILTERED_DIHEDRAL_SUBSEQUENCES 统计通过判断函数的循环和反转意义下不同子串的出现次数。
%
% 输入:
%   arr:        包含0和1的行向量或列向量 (即01数组)。
%   n:          子串的长度 (n >= 1)。
%   check_func: 用于判断子串是否通过筛选的函数句柄 (支持匿名函数绑定额外参数)。
%
% 输出:
%   result_cell: 一个元胞数组，每行包含 {代表性子串(数组), 出现次数(整数)}。

if n <= 0 || mod(n, 1) ~= 0
    error('n 必须是大于0的整数。');
end
if isempty(arr) || length(arr) < n
    result_cell = {};
    return;
end

L = length(arr);
counts_map = containers.Map();

% 1. 循环提取、筛选和规范化子串
for i = 1:L
    % 提取子串 (使用循环索引)
    indices = mod((i : i + n - 1) - 1, L) + 1;
    current_sub = arr(indices);

    % 2. 经过判断函数筛选
    % check_func 必须在外部被设置为匿名函数句柄以处理多余的参数
    if check_func(current_sub) 
        
        % 3. 规范化子串 (找到二面体群下的最小表示)
        % 考虑了循环平移和反向反转
        min_sub = get_min_representation_dihedral(current_sub, n);
        
        % 4. 统计
        % 将规范化子串转换为字符串作为 Map 的 Key
        key = num2str(min_sub);

        if isKey(counts_map, key)
            counts_map(key) = counts_map(key) + 1;
        else
            counts_map(key) = 1;
        end
    end
end

% 5. 格式化输出结果为元胞数组
keys = counts_map.keys;
result_cell = cell(counts_map.Count, 2);

for i = 1:counts_map.Count
    key_str = keys{i};
    sub_array = str2num(key_str); 
    result_cell{i, 1} = sub_array;       % 代表性子串
    result_cell{i, 2} = counts_map(key_str); % 出现次数
end

end