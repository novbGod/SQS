

function sequences = generate_symmetric_debruijn_limited(n, max_solutions)
% GENERATE_SYMMETRIC_DEBRUIJN_LIMITED 生成指定数量的互换反序对称 De Bruijn 序列
%
% 输入: 
%   n             - 序列阶数 (建议奇数)
%   max_solutions - 需要生成的解的最大数量 (例如 10, 100, 1000)
%
% 输出: 
%   sequences     - 结果矩阵 (行数为实际找到的解数 <= max_solutions)
%
% 算法: 
%   带有计数截断的深度优先搜索 (DFS)。
%   一旦找到足够数量的解，搜索树会立即剪枝并返回。

    % --- 检查输入 ---
    if nargin < 2
        max_solutions = 1; % 默认找 1 个
    end
    
    if mod(n, 2) == 0 && n > 2
        warning('对于偶数 n > 2，严格对称解通常不存在。');
    end

    % --- 初始化参数 ---
    total_len = 2^n;
    half_len = total_len / 2;
    
    % 状态记录
    visited = false(1, total_len);
    path = zeros(1, half_len);
    
    % 结果容器 (使用 cell 动态存储)
    found_solutions = {};
    count = 0; % 当前找到的解的数量
    
    % --- 初始锁定 ---
    % 锁定 00..0 和 11..1
    visited(0 + 1) = true;
    visited((2^n - 1) + 1) = true;
    path(1:n) = 0; % 固定前缀
    
    fprintf('正在搜索 n=%d 的解 (目标数量: %d)...\n', n, max_solutions);
    tic;
    
    % --- 启动嵌套递归 ---
    dfs_search(n + 1);
    
    % --- 整理输出 ---
    if count > 0
        sequences = vertcat(found_solutions{:});
        fprintf('搜索结束。已找到 %d 个解。耗时: %.4f 秒\n', count, toc);
    else
        sequences = [];
        fprintf('搜索结束。未找到符合条件的解。\n');
    end

    % ============================================================
    % 嵌套函数: 递归搜索核心
    % (可以直接访问父函数的变量: visited, found_solutions, count)
    % ============================================================
    function dfs_search(idx)
        % 1. 检查是否已达到目标数量 (全局截断)
        if count >= max_solutions
            return;
        end
        
        % 2. 基准情形: 前半段填满
        if idx > half_len
            % 检查连接处 (Bridge Check)
            % P(end) -> ~P(end)
            bridge_prefix = path(half_len-n+2 : half_len);
            bridge_bit = ~path(half_len); % 连接到 ~P_rev 的头部
            
            bridge_tuple = [bridge_prefix, bridge_bit];
            bridge_val = bi2de_fast(bridge_tuple);
            
            % 如果连接处没有冲突
            if ~visited(bridge_val + 1)
                % 构造全序列
                P = path;
                S = [P, ~P(end:-1:1)];
                
                % 保存结果
                found_solutions{end+1} = S;
                count = count + 1;
                
                % 简单的进度显示
                if mod(count, 100) == 0
                    fprintf('  已收集 %d / %d 个解...\n', count, max_solutions);
                end
            end
            return;
        end
        
        % 3. 递归分支
        % 尝试 1 和 0
        candidates = [1, 0];
        
        for bit = candidates
            % 再次检查截断 (防止在兄弟分支中浪费时间)
            if count >= max_solutions
                return;
            end
            
            path(idx) = bit;
            
            % 获取当前 n 元组
            tuple_bits = path(idx-n+1 : idx);
            val = bi2de_fast(tuple_bits);
            
            % 获取对偶元组
            dual_bits = ~tuple_bits(end:-1:1);
            dual_val = bi2de_fast(dual_bits);
            
            % 剪枝
            if visited(val + 1) || visited(dual_val + 1)
                continue;
            end
            
            % 标记
            visited(val + 1) = true;
            visited(dual_val + 1) = true;
            
            % 下一层
            dfs_search(idx + 1);
            
            % 回溯
            visited(val + 1) = false;
            visited(dual_val + 1) = false;
        end
    end

end

function d = bi2de_fast(b)
    % 辅助函数: 二进制转十进制
    pow2 = 2 .^ (length(b)-1 : -1 : 0);
    d = sum(b .* pow2);
end
