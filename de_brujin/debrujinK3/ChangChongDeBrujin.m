% 例：生成 B(4,2)
seq = cw_debruijn_ga(10,3);
disp(seq)


function seq_best = cw_debruijn_ga(n, w)
% 使用遗传算法生成一个常重 De Bruijn 序列 B(n, w)
%
% seq_best = cw_debruijn_ga(n, w)
%
% 输出:
%   seq_best : 一个二进制行向量（0/1），表示循环序列
%
% 注意:
%   该方法为启发式优化搜索（非精确构造），
%   适合 n <= 6 或 7 的情形。

    % ==== 基本参数 ====
    L = nchoosek(n, w);      % 理论上窗口总数 = 序列长度
    fprintf('目标长度 L = %d\n', L);

    % ==== 定义目标函数 ====
    fitnessFcn = @(x) cost_constant_weight(x, n, w);

    % ==== 遗传算法选项 ====
    opts = optimoptions('ga', ...
        'PopulationSize', 100, ...
        'MaxGenerations', 300, ...
        'CrossoverFraction', 0.8, ...
        'MutationFcn', {@mutationuniform, 0.1}, ...
        'UseParallel', false, ...
        'PlotFcn', {@gaplotbestf}, ...
        'Display', 'iter');

    % ==== 调用 GA ====
    nVars = L;
    IntCon = 1:nVars;
    lb = zeros(1, nVars);
    ub = ones(1, nVars);

    [seq_best, fval] = ga(fitnessFcn, nVars, [], [], [], [], lb, ub, [], IntCon, opts);
    seq_best = round(seq_best); % 确保为 0/1
    fprintf('优化完成。最优适应度 = %.4f\n', fval);

    % ==== 检查结果 ====
    verify_seq(seq_best, n, w);
end


% === 代价函数 ===
function f = cost_constant_weight(seq, n, w)
    seq = round(seq);
    L = numel(seq);
    patterns = containers.Map('KeyType','char','ValueType','int32');
    wrong_weight = 0;

    for i = 1:L
        idx = mod((i-1)+(0:n-1), L) + 1;
        window = seq(idx);
        if sum(window) ~= w
            wrong_weight = wrong_weight + 1;
            continue
        end
        key = num2str(window);
        if isKey(patterns, key)
            patterns(key) = patterns(key) + 1;
        else
            patterns(key) = 1;
        end
    end

    % 计算缺失和重复数
    all_patterns = generate_patterns(n, w);
    all_keys = cellfun(@(x) num2str(x), all_patterns, 'UniformOutput', false);
    missing = sum(~isKey(patterns, all_keys));
    duplicates = sum(cellfun(@(k) max(0, patterns(k)-1), keys(patterns)));

    % 惩罚函数
    lambda = 10;
    f = missing + duplicates + lambda * wrong_weight;
end


% === 生成所有长度-n、weight=w 的模式 ===
function pats = generate_patterns(n, w)
    combos = nchoosek(1:n, w);
    pats = cell(size(combos,1),1);
    for i = 1:size(combos,1)
        x = zeros(1,n);
        x(combos(i,:)) = 1;
        pats{i} = x;
    end
end


% === 检查结果 ===
function verify_seq(seq, n, w)
    L = numel(seq);
    pats = {};
    for i = 1:L
        idx = mod((i-1)+(0:n-1), L) + 1;
        s = seq(idx);
        if sum(s) == w
            pats{end+1} = num2str(s);
        end
    end
    unique_pats = unique(pats);
    fprintf('覆盖窗口数: %d / %d\n', numel(unique_pats), nchoosek(n,w));
end
