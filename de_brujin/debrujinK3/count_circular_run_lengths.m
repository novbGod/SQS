
function outputCell = count_circular_run_lengths(inputStr)
% count_circular_run_lengths: 统计字符串中'0'-'9'数字的环形游程长度
%
% 输入:
%   inputStr: 一个字符串
%
% 输出:
%   outputCell: 1x10 的元胞数组。
%               outputCell{1} 对应 '0' 的游程计数
%               outputCell{2} 对应 '1' 的游程计数
%               ...
%               outputCell{10} 对应 '9' 的游程计数
%               
%               在每个元胞内，存储一个数组。例如：
%               如果 outputCell{2} = [1 0 2]，代表 '1'：
%               - 长度为 1 的游程 出现了 1 次
%               - 长度为 2 的游程 出现了 0 次
%               - 长度为 3 的游程 出现了 2 次
%
%               非数字字符会打断数字的游程，但它们自己不会被统计。

    % 初始化输出元胞数组，10个元素分别对应 '0' 到 '9'
    outputCell = cell(1, 10);
    
    n = length(inputStr);
    if n == 0
        return; % 如果输入为空，返回空的元胞数组
    end

    % --- 步骤 1: 执行标准游程编码 (RLE) ---
    runChars = char([]); % 存储游程的字符
    runLengths = [];      % 存储游程的长度
    
    i = 1;
    while i <= n
        currentChar = inputStr(i);
        currentLength = 1;
        j = i + 1;
        
        % 查找连续相同的字符
        while j <= n && inputStr(j) == currentChar
            currentLength = currentLength + 1;
            j = j + 1;
        end
        
        % 存储这个游程
        runChars = [runChars, currentChar];
        runLengths = [runLengths, currentLength];
        
        % 移动到下一个不同字符的开始位置
        i = j;
    end

    % --- 步骤 2: 处理环形逻辑 ---
    % 如果游程多于一个，并且第一个和最后一个游程的字符相同
    if length(runChars) > 1 && runChars(1) == runChars(end)
        % 合并第一个和最后一个游程
        mergedLength = runLengths(1) + runLengths(end);
        
        % 将合并后的长度更新到第一个游程
        runLengths(1) = mergedLength;
        
        % 移除最后一个游程 (现在它已经被合并了)
        runChars(end) = [];
        runLengths(end) = [];
    end

    % --- 步骤 3: 统计数字游程 ---
    digits = '0123456789';
    
    for k = 1:length(runChars)
        char_k = runChars(k);
        len_k = runLengths(k);
        
        % 检查当前字符是否为我们关心的数字
        % strfind 返回 '0123456789' 中 char_k 的位置
        digitIndex = strfind(digits, char_k);
        
        if ~isempty(digitIndex)
            % digitIndex 是 1 (对应 '0'), 2 (对应 '1'), ..., 10 (对应 '9')
            
            % 获取当前数字的计数数组
            counts = outputCell{digitIndex};
            
            % 确保计数数组足够长以存储 'len_k'
            if len_k > length(counts)
                % MATLAB 会自动用 0 填充到 counts(len_k - 1)
                counts(len_k) = 1;
            else
                % 数组已足够长，直接在对应位置+1
                counts(len_k) = counts(len_k) + 1;
            end
            
            % 将更新后的计数数组存回元胞
            outputCell{digitIndex} = counts;
        end
    end
    
    % --- 步骤 4: (可选) 清理空元胞 ---
    % 将没有出现过的数字的元胞从 '[]' 变为空的 1x0 数组 (double)
    % 这一步也可以省略，因为 '[]' 已经能很好地代表“没有数据”
    for i = 1:10
        if isempty(outputCell{i})
            outputCell{i} = []; % 或者 outputCell{i} = zeros(1,0);
        end
    end

end