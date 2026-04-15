function [isDeBruijn, repeatCount, report] = check2(A, m, n, k)
    % A: 输入矩阵
    % m, n: 子窗口的大小 (行, 列)
    % k: 元素种类数 (如元素为 0, 1, ..., k-1)
    %相比check函数，若所有子窗口出现次数相同，会算作de bruijn阵列，并且会输出重复的次数
    [R, C] = size(A);

    A = [A,A;A,A];
    % 计算滑动窗口的数量
    num_rows = R;
    num_cols = C;
    
    if num_rows <= 0 || num_cols <= 0
        error('矩阵尺寸小于窗口尺寸。');
    end

    % 使用 containers.Map 存储窗口频率
    % Key: 窗口展开后的字符串, Value: {出现次数, 顶点位置 [r, c]}
    windowMap = containers.Map();
    
    % 1. 遍历并统计所有子窗口
    for i = 1:num_rows
        for j = 1:num_cols
            % 提取窗口并转为字符串作为唯一键
            subWin = A(i:i+m-1, j:j+n-1);
            key = mat2str(subWin); 
            
            if isKey(windowMap, key)
                data = windowMap(key);
                data.count = data.count + 1;
                data.pos = [data.pos; i, j];
                windowMap(key) = data;
            else
                windowMap(key) = struct('count', 1, 'pos', [i, j]);
            end
        end
    end

    % 2. 获取统计数据
    allKeys = keys(windowMap);
    counts = cellfun(@(k) windowMap(k).count, allKeys);
    uniqueCounts = unique(counts);
    
    % 计算理论上应有的总模式数 k^(m*n)
    totalPossiblePatterns = k^(m*n);
    numFoundPatterns = length(allKeys);

    % 3. 判断逻辑
    % 条件：1. 发现的模式数等于理论总数； 2. 且所有模式出现次数一致
    if numFoundPatterns == totalPossiblePatterns && length(uniqueCounts) == 1
        isDeBruijn = true;
        repeatCount = uniqueCounts(1);
        report = sprintf('验证通过：该矩阵是一个 (%d,%d;%d,%d)_%d De Bruijn 环面,每种多体共重复%d次。\n', ...
            R, C, m, n, k, repeatCount);
        fprintf(report);
    else
        isDeBruijn = false;
        repeatCount = NaN;
        
        % 构造异常报告
        report = struct();
        if numFoundPatterns < totalPossiblePatterns
            report.issue = sprintf('缺失模式：应有 %d 种模式，实际仅发现 %d 种。', ...
                                    totalPossiblePatterns, numFoundPatterns);
            fprintf(report.issue);
        end
        
        % 找出出现次数异常的窗口
        % 如果 uniqueCounts 有多个值，记录每种频率对应的窗口
        anomalyList = [];
        for i = 1:length(allKeys)
            key = allKeys{i};
            data = windowMap(key);
            anomalyList = [anomalyList; struct('pattern', key, 'count', data.count, 'positions', data.pos)];
        end
        report.details = anomalyList;
    end
end