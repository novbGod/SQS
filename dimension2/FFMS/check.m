function [isDeBruijn, duplicates] = check(A, r, s, k)
    % A: 待检测矩阵
    % r, s: 窗口大小
    % m, n: 矩阵大小 (应满足 k^(r*s) = m*n)
    % k: 字母表大小 (元素通常为 0 到 k-1)

    isDeBruijn = true;
    duplicates = struct('window', {}, 'positions', {});
    
    % 1. 维度检查
    [m, n] = size(A);
    if m*n ~= k^(r*s)
        fprintf('矩阵大小错误');
        return;
    end

    % 2. 存储窗口及其出现位置
    % key: 窗口序列化的字符串, value: 出现坐标列表
    windowMap = containers.Map();

    % 3. 遍历所有可能的窗口起始点 (i, j)
    for i = 1:m
        for j = 1:n
            % 周期性提取 r x s 窗口
            rowIdx = mod((i:i+r-1) - 1, m) + 1;
            colIdx = mod((j:j+s-1) - 1, n) + 1;
            window = A(rowIdx, colIdx);
            
            % 将窗口矩阵转换为一维数组/字符串作为唯一标识
            windowKey = strjoin(arrayfun(@num2str, window(:)', 'UniformOutput', false), ',');
            
            if isKey(windowMap, windowKey)
                isDeBruijn = false;
                windowMap(windowKey) = [windowMap(windowKey); [i, j]];
            else
                windowMap(windowKey) = [i, j];
            end
        end
    end

    % 4. 统计并提取重复的窗口
    allKeys = keys(windowMap);
    count = 1;
    for idx = 1:length(allKeys)
        pos = windowMap(allKeys{idx});
        if size(pos, 1) > 1
            % 解析回矩阵形式方便查看
            winVec = str2num(allKeys{idx});
            duplicates(count).window = reshape(winVec, [r, s]);
            duplicates(count).positions = pos;
            count = count + 1;
        end
    end

    % 5. 结果输出
    if isDeBruijn
        fprintf('验证通过：该矩阵是一个 (%d,%d;%d,%d)_%d De Bruijn 环面。\n', r, s, m, n, k);
    else
        fprintf('验证失败：发现重复窗口。\n');
        for i = 1:length(duplicates)
            fprintf('\n重复窗口类型 %d:\n', i);
            disp(duplicates(i).window);
            fprintf('出现位置 (行, 列):\n');
            disp(duplicates(i).positions);
        end
    end
end