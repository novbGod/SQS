
% A12_4_4_k4 = [     0     0     3     2
%                    0     1     2     1
%                    0     2     2     3
%                    1     1     3     3];
%
% check2(A12_4_4_k4, 1, 2, 4);

% 参数设置
R = 4; C = 4;
wr = 1; wc = 2;
k = 4;
target_K = 1; % 你可以修改 K 为 0, 1, 2, 或 3
max_solutions = 5; % 想要寻找的解的数量

global solutions;
solutions = {};
grid = -1 * ones(R, C);

fprintf('正在搜索列和 mod 4 = %d 的 (4,4; 1,2)_4 阵列...\n', target_K);

backtrack_with_sum(grid, 1, R, C, wr, wc, k, target_K, max_solutions);

if isempty(solutions)
    disp('未找到满足条件的解。');
else
    fprintf('共找到 %d 个满足条件的解：\n', length(solutions));
    for n = 1:length(solutions)
        fprintf('\n--- 解 #%d ---\n', n);
        disp(solutions{n});
        % 验证列和
        col_sums = mod(sum(solutions{n}, 1), 4);
        fprintf('每列和 mod 4: [%s]\n', num2str(col_sums));
    end
end


function finished = backtrack_with_sum(grid, pos, R, C, wr, wc, k, K, limit)
global solutions;
finished = false;

if length(solutions) >= limit
    finished = true;
    return;
end

if pos > R * C
    if checkFullGrid(grid, R, C, wr, wc, k)
        solutions{end+1} = grid;
    end
    return;
end

% 计算坐标 (r, c) - 按行填充
r = ceil(pos / C);
c = mod(pos - 1, C) + 1;

% 如果是最后一行，尝试的值受列和 K 约束
if r == R
    val = mod(K - sum(grid(1:R-1, c)), k);
    % 检查这个强制值是否合法
    grid(r, c) = val;
    if isPartiallyValid(grid, r, c, R, C, wr, wc, k)
        if backtrack_with_sum(grid, pos + 1, R, C, wr, wc, k, K, limit)
            finished = true; return;
        end
    end
    grid(r, c) = -1;
else
    % 非最后一行，遍历 0-3
    for val = 0:k-1
        grid(r, c) = val;
        if isPartiallyValid(grid, r, c, R, C, wr, wc, k)
            if backtrack_with_sum(grid, pos + 1, R, C, wr, wc, k, K, limit)
                finished = true; return;
            end
        end
        grid(r, c) = -1;
    end
end
end

% 局部有效性检查（检查当前行中已生成的 1x2 窗口是否重复）
function ok = isPartiallyValid(grid, r, c, R, C, wr, wc, k)
% 提取当前行中已经填充的部分
currentRow = grid(r, 1:c);
% 检查行内非循环窗口
windows = [];
for i = 1 : r
    row_data = grid(i, :);
    filled_indices = find(row_data ~= -1);
    for j = 1 : length(filled_indices) - 1
        if filled_indices(j+1) == filled_indices(j) + 1
            sub = row_data(filled_indices(j):filled_indices(j+1));
            idx = sub(1) + sub(2)*k;
            if any(windows == idx)
                ok = false; return;
            end
            windows = [windows, idx];
        end
    end
end
ok = true;
end

% 完整性检查（含周期性边界）
function ok = checkFullGrid(grid, R, C, wr, wc, k)
seen = false(1, k^(wr*wc));
extended = [grid, grid(:, 1)]; % 仅横向循环
for i = 1 : R
    for j = 1 : C
        sub = extended(i, j:j+1);
        idx = sub(1) + sub(2)*k;
        if seen(idx+1)
            ok = false; return;
        end
        seen(idx+1) = true;
    end
end
ok = all(seen);
end