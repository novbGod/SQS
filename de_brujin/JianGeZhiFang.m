clear;
n = 7;
a = generateDeBruijnSequence_v2(n);
A = ballsToPile(num2str(a));
A0 = A(1:2:end-1);
A1 = A(2:2:end);
% 数组长度为 10

% 2. 设置需要统计的最大值 n


% 3. 调用函数进行统计
stats0 = calculatePeriodicIntervals(A0, n);
stats1 = calculatePeriodicIntervals(A1, n);

% 4. 显示统计结果
% celldisp 函数可以清晰地展示元胞数组的内容
 fprintf('对于晶胞%s\n', strrep(num2str(A), ' ', '') );
 fprintf('A原子堆为%s\n', strrep(num2str(A0), ' ', '') );
 figure;
for k = 2:n
    fprintf('%dA的间隔: ', k);
    if isempty(stats0{k})
        fprintf('出现次数不足2次\n');
    else
        fprintf('[ %s ]\n', num2str(sort(stats0{k})));
    % subplot(ceil(sqrt(n-1)),ceil(sqrt(n-1)),k-1)
    % unique_vals = unique(stats0{k}); % 结果是 [2, 250]
    % N = histcounts(stats0{k}, [unique_vals, max(stats0{k})+1]); 
    % bar(unique_vals, N, 0.8);
    % title(sprintf('%dA间隔分布',k));
    % xlabel('间隔长度');
    % ylabel('频数');

    subplot(floor((n-1)/3),3,k-1)
    sgtitle(sprintf('n=%d',n));
    histogram(stats0{k});
    title(sprintf('%dA间隔分布',k));
    xlabel('间隔长度');
    ylabel('频数');
    end
   
end
fprintf('B原子堆为%s\n', strrep(num2str(A1), ' ', '') );
figure;
for k = 2:n
    fprintf('%dB的间隔: ', k);
    if isempty(stats1{k})
        fprintf('出现次数不足2次\n');
    else
        fprintf('[ %s ]\n', num2str(sort(stats1{k})));
    subplot(floor((n-1)/3),3,k-1)
    sgtitle(sprintf('n=%d',n));
    histogram(stats1{k});
    title(sprintf('%dB间隔分布',k));
    xlabel('间隔长度');
    ylabel('频数');
    end
    
end
function interval_stats = calculatePeriodicIntervals(A, n)
% calculatePeriodicIntervals: 统计数组中2~n元素的相邻相同元素的间隔（考虑周期性边界）
%
% 输入参数:
%   A - 输入的一维数组 (行向量或列向量)
%   n - 需要统计的最大元素值 (统计范围为 2 到 n)
%
% 输出参数:
%   interval_stats - 一个 n x 1 的元胞数组 (cell array)。
%                    其中，第 k 个元胞 (interval_stats{k}) 包含一个行向量，
%                    记录了数值 k 的所有相邻间隔。
%                    如果数值 k 出现次数小于2，则对应的元胞为空。

% --- 输入参数校验 ---
if ~isvector(A)
    error('输入参数 A 必须是一个向量。');
end
if ~isscalar(n) || floor(n) ~= n || n < 2
    error('输入参数 n 必须是一个大于等于2的整数。');
end

% 获取数组总长度
L = length(A);

% 初始化结果存储单元
interval_stats = cell(n, 1);

% --- 主循环，遍历 2 到 n ---
for k = 2:n
    % 找到数值 k 在数组 A 中的所有索引
    indices = find(A == k);
    
    % 获取 k 出现的次数
    num_occurrences = length(indices);
    
    % 至少需要出现两次才能形成间隔
    if num_occurrences < 2
        interval_stats{k} = []; % 如果次数不够，则记录为空数组
        continue; % 继续下一个k的循环
    end
    
    % --- 计算间隔 ---
    
    % 1. 计算内部间隔（非跨越边界的间隔）
    %    例如 indices = [3, 8, 12]，diff 结果为 [5, 4]
    internal_intervals = diff(indices);
    
    % 2. 计算周期性间隔（从最后一个到第一个的“环绕”间隔）
    periodic_interval = (L - indices(end)) + indices(1);
    
    % 3. 合并所有间隔
    all_intervals = [internal_intervals, periodic_interval];
    
    % 将结果存入元胞数组
    interval_stats{k} = all_intervals;
end

end