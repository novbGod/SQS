function [run_matrix, max_length] = analyze_runs_matrix(sequence)
% ANALYZE_RUNS_MATRIX 统计字符串中字符 '0', '1', '2' 的游程长度及其出现次数，
% 在周期性边界条件（循环序列）下进行分析，并以矩阵形式返回结果。
%
% 输入:
%   sequence (char array): 待分析的字符串 (仅包含 '0', '1', '2')
%
% 输出:
%   run_matrix (matrix): 3 x L_max 矩阵。
%       - 第 1 行: '0' 的游程计数
%       - 第 2 行: '1' 的游程计数
%       - 第 3 行: '2' 的游程计数
%       - 第 j 列: 长度为 j 的游程的出现次数
%   max_length (int): 序列中出现的最长游程的长度。

    L_original = length(sequence);
    if L_original == 0
        run_matrix = zeros(3, 0);
        max_length = 0;
        fprintf('输入序列为空。\n');
        return;
    end
    
    % 1. 识别并提取所有线性游程
    
    % 在序列末尾添加一个独特的字符 (如 '#')，以确保最后一个游程能够被检测到。
    sequence_padded = [sequence, '#']; 

    current_char = sequence_padded(1);
    current_run_length = 0;
    
    % 存储所有检测到的游程: {字符, 长度}
    all_runs = {}; 

    for i = 1:length(sequence_padded)
        char_i = sequence_padded(i);
        
        if char_i == current_char
            % 字符相同，游程长度累加
            current_run_length = current_run_length + 1;
        else
            % 字符发生变化，当前游程结束
            
            % 只有当长度大于 0 且字符为 '0', '1', 或 '2' 时才记录
            if current_run_length > 0 && ismember(current_char, '012')
                all_runs{end+1} = {current_char, current_run_length}; %#ok<AGROW>
            end
            
            % 开启一个新的游程
            current_char = char_i;
            current_run_length = 1; % 新游程的长度从 1 开始
        end
    end
    
    % 2. 周期性边界条件调整 (Cyclic Adjustment)
    
    % 检查序列首尾是否相同，如果相同，则需要合并第一个和最后一个线性游程
    if L_original > 1 && sequence(1) == sequence(L_original)
        
        % 检查全同序列的情况 (例如 '000')
        if length(all_runs) == 1
            % 如果只有一个游程，说明整个序列已经是一个 Run，无需调整
            
        elseif length(all_runs) >= 2
            % 序列首尾字符相同，且序列包含多个游程，需要合并第一个和最后一个游程
            
            first_run = all_runs{1};
            last_run = all_runs{end};
            
            L_start = first_run{2};
            L_end = last_run{2};
            
            % 合并游程的长度
            L_combined = L_start + L_end;
            run_char = first_run{1};
            
            % 从列表中移除第一个和最后一个线性游程
            % all_runs(2:end-1) 保留中间游程
            all_runs = all_runs(2:end-1);
            
            % 添加合并后的循环游程
            all_runs{end+1} = {run_char, L_combined}; %#ok<AGROW>
        end
    end
    
    % 3. 确定最大游程长度和初始化矩阵
    
    if isempty(all_runs)
        % 序列中没有有效的 '0', '1', '2' 游程
        run_matrix = zeros(3, 0);
        max_length = 0;
        fprintf('序列中未发现有效游程。\n');
        return;
    end
    
    % 重新计算 (或首次计算) 最大游程长度
    max_length = max(cellfun(@(x) x{2}, all_runs));
    
    % 初始化结果矩阵
    % 3 行 (0, 1, 2) x L_max 列 (长度 1 到 L_max)
    run_matrix = zeros(3, max_length);
    
    % 4. 统计并填充矩阵
    
    % 字符到矩阵行的映射
    char_to_row = containers.Map({'0', '1', '2'}, {1, 2, 3});
    
    for i = 1:length(all_runs)
        run_char = all_runs{i}{1};
        run_len = all_runs{i}{2};
        
        % 获取字符对应的行索引
        row_idx = char_to_row(run_char);
        
        % 长度 run_len 对应矩阵的第 run_len 列 (MATLAB 索引从 1 开始)
        col_idx = run_len;
        
        % 计数加 1
        run_matrix(row_idx, col_idx) = run_matrix(row_idx, col_idx) + 1;
    end
    
    fprintf('成功分析周期性游程长度，结果存储在 3x%d 矩阵中。\n', max_length);
    fprintf('矩阵 (行: 0, 1, 2 | 列: 长度 1, 2, ...):\n');
    disp(run_matrix);
end
