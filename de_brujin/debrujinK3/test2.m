n = 10;               
num = 3;
N = n;%子串长度
A = generate_debruijn_sequence(2,n)
a = A - '0';

% 调用函数，传入判断函数的句柄 @my_custom_check
check_func = @(sub) my_custom_check(sub, num);
result = count_filtered_circular_subsequences(a, N, check_func);

% 显示结果
disp('筛选后的循环子串统计结果 (元胞数组):');
disp(result);



% ============== 占位判断函数 (请替换为您的实际函数) ==============
function is_valid = my_custom_check(sub,n)
% 这是一个占位的判断函数。请将这里的逻辑替换为您实际的判断标准。
% 示例：判断子串中 1 的数量是否大于 1。
    if sum(sub) == n
        is_valid = true;  % 通过判断
    else
        is_valid = false; % 未通过判断
    end
end
% =============================================================


function result_cell = count_filtered_circular_subsequences(arr, n, check_func)
% COUNT_FILTERED_CIRCULAR_SUBSEQUENCES 统计通过判断函数的循环意义下不同子串的出现次数。
%
% 输入:
%   arr:        包含0和1的行向量或列向量 (即01数组)。
%   n:          子串的长度 (n >= 1)。
%   check_func: 用于判断子串是否通过筛选的函数句柄 (例如 @my_custom_check)。
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
    if feval(check_func, current_sub)
        
        % 3. 规范化子串 (找到最小表示)
        min_sub = get_min_representation(current_sub, n);
        
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
    
    % 将字符串 Key 转换回数字数组
    sub_array = str2num(key_str); 

    result_cell{i, 1} = sub_array;       % 代表性子串
    result_cell{i, 2} = counts_map(key_str); % 出现次数
end

end


% =============================================================
%                       辅助函数
% =============================================================

function min_sub = get_min_representation(current_sub, n)
% 找到一个长度为 n 的子串在循环平移意义下的字典序最小表示

    min_sub = current_sub;
    temp_sub = current_sub;

    % 循环平移 n 次
    for k = 1:n
        % 循环平移操作: [串的末尾元素, 串的前 n-1 个元素]
        shifted_sub = [temp_sub(2:end), temp_sub(1)];

        % 比较字典序
        if compare_subsequences_lex(shifted_sub, min_sub) < 0
            min_sub = shifted_sub;
        end
        temp_sub = shifted_sub; % 更新当前的串进行下一次平移
    end
end


function result = compare_subsequences_lex(A, B)
% 辅助函数：比较两个 0-1 数组的字典序
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