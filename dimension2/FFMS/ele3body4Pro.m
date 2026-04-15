function solve_de_bruijn_torus()
    disp('正在构建整数线性规划模型...');
    
    % 辅助函数：处理周期性边界条件
    nxt = @(idx) mod(idx-1, 9) + 1;
    
    % 1. 生成所有 81 种 2x2 模式
    % patterns 每一行代表: [左上, 右上, 左下, 右下]
    patterns = zeros(81, 4);
    idx = 1;
    for tl = 1:3
        for tr = 1:3
            for bl = 1:3
                for br = 1:3
                    patterns(idx, :) = [tl, tr, bl, br];
                    idx = idx + 1;
                end
            end
        end
    end
    
    % 变量总数：
    % x 变量: 9 * 9 * 3 = 243
    % y 变量: 9 * 9 * 81 = 6561
    % 总计 = 6804 个二进制变量
    num_vars = 243 + 6561;
    
    % 辅助函数：将多维索引转换为一维变量索引
    x_idx = @(i, j, v) (i-1)*27 + (j-1)*3 + v;
    y_idx = @(i, j, p) 243 + (i-1)*729 + (j-1)*81 + p;
    
    % 构建稀疏等式约束矩阵 Aeq * var = beq
    I = []; J = []; V = [];
    row_idx = 1;
    
    % 约束 1: 每个坐标 (i,j) 只能填入一个数字 v
    for i = 1:9
        for j = 1:9
            for v = 1:3
                I(end+1) = row_idx; J(end+1) = x_idx(i,j,v); V(end+1) = 1;
            end
            row_idx = row_idx + 1;
        end
    end
    
    % 约束 2: 每个坐标 (i,j) 作为左上角，只能是 1 种模式
    for i = 1:9
        for j = 1:9
            for p = 1:81
                I(end+1) = row_idx; J(end+1) = y_idx(i,j,p); V(end+1) = 1;
            end
            row_idx = row_idx + 1;
        end
    end
    
    % 约束 3: 81 种模式每种必须在全网格中出现且仅出现 1 次
    for p = 1:81
        for i = 1:9
            for j = 1:9
                I(end+1) = row_idx; J(end+1) = y_idx(i,j,p); V(end+1) = 1;
            end
        end
        row_idx = row_idx + 1;
    end
    
    % 约束 4-7: 模式 y 必须与网格上的实际数字 x 匹配 (含周期性边界)
    for i = 1:9
        for j = 1:9
            for v = 1:3
                % 左上角匹配
                I(end+1) = row_idx; J(end+1) = x_idx(i,j,v); V(end+1) = -1;
                valid_p = find(patterns(:,1) == v)';
                for p = valid_p
                    I(end+1) = row_idx; J(end+1) = y_idx(i,j,p); V(end+1) = 1;
                end
                row_idx = row_idx + 1;
                
                % 右上角匹配
                I(end+1) = row_idx; J(end+1) = x_idx(i,nxt(j+1),v); V(end+1) = -1;
                valid_p = find(patterns(:,2) == v)';
                for p = valid_p
                    I(end+1) = row_idx; J(end+1) = y_idx(i,j,p); V(end+1) = 1;
                end
                row_idx = row_idx + 1;
                
                % 左下角匹配
                I(end+1) = row_idx; J(end+1) = x_idx(nxt(i+1),j,v); V(end+1) = -1;
                valid_p = find(patterns(:,3) == v)';
                for p = valid_p
                    I(end+1) = row_idx; J(end+1) = y_idx(i,j,p); V(end+1) = 1;
                end
                row_idx = row_idx + 1;
                
                % 右下角匹配
                I(end+1) = row_idx; J(end+1) = x_idx(nxt(i+1),nxt(j+1),v); V(end+1) = -1;
                valid_p = find(patterns(:,4) == v)';
                for p = valid_p
                    I(end+1) = row_idx; J(end+1) = y_idx(i,j,p); V(end+1) = 1;
                end
                row_idx = row_idx + 1;
            end
        end
    end
    
    % 生成稀疏矩阵
    Aeq = sparse(I, J, V, row_idx-1, num_vars);
    
    % beq 向量：前 81+81+81 个约束等号右边为 1，其余匹配约束等号右边为 0
    beq = [ones(243, 1); zeros(972, 1)];
    
    % 设置 ILP 参数
    f = zeros(num_vars, 1); % 我们只需要可行解，不需要优化目标函数
    intcon = 1:num_vars;    % 所有变量均为整数
    lb = zeros(num_vars, 1);
    ub = ones(num_vars, 1); % 所有变量界于 0 和 1 之间
    
    % 调用求解器
    disp('模型构建完成，开始求解...');
    options = optimoptions('intlinprog', 'Display', 'iter', 'Heuristics', 'advanced');
    tic;
    [sol, ~, exitflag] = intlinprog(f, intcon, [], [], Aeq, beq, lb, ub, options);
    time_taken = toc;
    
    % 解析并展示结果
    if exitflag > 0
        fprintf('\n成功找到可行解！耗时 %.2f 秒。\n', time_taken);
        grid_sol = zeros(9, 9);
        for i = 1:9
            for j = 1:9
                for v = 1:3
                    if round(sol(x_idx(i,j,v))) == 1
                        grid_sol(i,j) = v;
                    end
                end
            end
        end
        disp('9x9 周期性网格解:');
        disp(grid_sol);
    else
        disp('未找到可行解或求解过程被中断。');
    end
end