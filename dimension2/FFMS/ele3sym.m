% 求解 9x9 三进制 2D De Bruijn Torus (平移-色彩轮换对称)
clear; clc;

N = 9; % 网格大小

% 创建优化问题 (纯约束满足问题)
prob = optimproblem;

% 定义决策变量
% X(i,j,v) = 1 表示网格 (i,j) 填入数字 v (v=1,2,3)
X = optimvar('X', N, N, 3, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);
% Y(i,j,p) = 1 表示以 (i,j) 为左上角的 2x2 子网格是第 p 种四体 (p=1~81)
Y = optimvar('Y', N, N, 81, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

%% 约束 1：每个网格只能填入一个数字
prob.Constraints.cell_single = sum(X, 3) == 1;

%% 约束 2：每个 2x2 位置只能是一种四体
prob.Constraints.block_single = sum(Y, 3) == 1;

%% 约束 3：81 种四体，每种在整个网格中必须出现且仅出现一次
prob.Constraints.pattern_once = squeeze(sum(sum(Y, 1), 2)) == 1;

%% 生成 81 种所有的 2x2 四体模式
patterns = zeros(81, 4);
idx = 1;
for v1 = 1:3
    for v2 = 1:3
        for v3 = 1:3
            for v4 = 1:3
                patterns(idx,:) = [v1, v2, v3, v4];
                idx = idx + 1;
            end
        end
    end
end

%% 约束 4：建立 Y (四体) 和 X (网格点) 之间的逻辑绑定
% Y(i,j,p)=1 必须推出该 2x2 区域的四个角对应 p 的四个值
cons1 = optimconstr(N, N, 81);
cons2 = optimconstr(N, N, 81);
cons3 = optimconstr(N, N, 81);
cons4 = optimconstr(N, N, 81);

for i = 1:N
    for j = 1:N
        ni = mod(i, N) + 1;     % 下一行 (周期边界)
        nj = mod(j, N) + 1;     % 右一列 (周期边界)
        for p = 1:81
            v1 = patterns(p,1); v2 = patterns(p,2);
            v3 = patterns(p,3); v4 = patterns(p,4);
            
            % 线性化逻辑: Y <= X
            cons1(i,j,p) = Y(i,j,p) <= X(i,  j,  v1);
            cons2(i,j,p) = Y(i,j,p) <= X(i,  nj, v2);
            cons3(i,j,p) = Y(i,j,p) <= X(ni, j,  v3);
            cons4(i,j,p) = Y(i,j,p) <= X(ni, nj, v4);
        end
    end
end
prob.Constraints.link1 = cons1;
prob.Constraints.link2 = cons2;
prob.Constraints.link3 = cons3;
prob.Constraints.link4 = cons4;

%% 约束 5：施加高阶对称性 (平移-色彩轮换对称)
% A(i+3, j) = A(i,j) + 1 (mod 3)
sym_cons = optimconstr(N, N, 3);
for i = 1:N
    ni = mod(i - 1 + 3, N) + 1; % 向下平移3格
    for j = 1:N
        for v = 1:3
            v_next = mod(v, 3) + 1; % 颜色 +1
            sym_cons(i,j,v) = X(i,j,v) == X(ni, j, v_next);
        end
    end
end
prob.Constraints.sym = sym_cons;

%% 求解
disp('正在构建并求解模型，由于存在极强的对称性约束，求解将非常迅速...');
options = optimoptions('intlinprog', 'Display', 'off');
[sol, ~, exitflag] = solve(prob, 'Options', options);

%% 提取结果并验证
if exitflag > 0
    grid_result = zeros(N, N);
    X_val = round(sol.X);
    for i = 1:N
        for j = 1:N
            for v = 1:3
                if X_val(i,j,v) == 1
                    grid_result(i,j) = v;
                end
            end
        end
    end
    
    disp('==== 成功找到对称解！====');
    disp(grid_result);
    
    % 验证逻辑
    blocks = zeros(81, 4);
    count = 1;
    for i = 1:N
        for j = 1:N
            ni = mod(i, N) + 1;
            nj = mod(j, N) + 1;
            blocks(count, :) = [grid_result(i,j), grid_result(i,nj), grid_result(ni,j), grid_result(ni,nj)];
            count = count + 1;
        end
    end
    num_unique = size(unique(blocks, 'rows'), 1);
    fprintf('验证：网格中包含 %d 种不重复的 2x2 四体 (目标为81种)。\n', num_unique);
    fprintf('1的个数: %d, 2的个数: %d, 3的个数: %d\n', sum(grid_result(:)==1), sum(grid_result(:)==2), sum(grid_result(:)==3));
else
    disp('未能找到解。');
end