
function sequences = gen_deBrujin_seqs(k, n, num_req)
% GEN_DEBRUIJN_SEQS 生成指定数量的不等价 De Bruijn 序列 B(k, n)
%   sequences = gen_debruijn_seqs(k, n, num_req)
%
%   输入:
%       k: 字母表大小 (例如: 2 表示二进制)
%       n: 子序列长度 (Order)
%       num_req: 需要生成的不同序列的数量
%
%   输出:
%       sequences: 一个矩阵，大小为 [num_req, k^n]。
%                  每一行是一个 De Bruijn 序列。
%
%   注意: 
%       对于较大的 k 和 n，De Bruijn 序列的数量是巨大的。
%       该算法使用递归回溯，对于特别大的 n (如 n > 12) 可能会遇到递归深度限制。

    % 1. 初始化参数
    num_nodes = k^(n-1);      % 节点数量 (状态空间大小)
    seq_length = k^n;         % 目标序列总长度 (边的数量)
    
    % 邻接矩阵/访问记录
    % visited(node_idx, edge_val) 
    % node_idx: 1 到 k^(n-1) (代表当前状态)
    % edge_val: 1 到 k (代表添加的下一个字符, 0->1, 1->2...)
    visited = false(num_nodes, k);
    
    % 结果存储
    sequences = zeros(num_req, seq_length);
    count = 0; % 当前找到的序列数
    
    % 临时路径存储 (存储边的值)
    current_path = zeros(1, seq_length);
    
    % 2. 开始深度优先搜索 (DFS)
    % 从全0状态开始 (节点索引 1)
    % 注意：De Bruijn 图是强连通且平衡的，欧拉回路一定存在。
    % 这里的 start_node = 0 (对应MATLAB索引1)
    dfs(0, 1);
    
    % 3. 内部递归函数
    function dfs(current_node, depth)
        % 如果已经找到足够数量的序列，停止搜索
        if count >= num_req
            return;
        end
        
        % Base Case: 如果路径长度达到目标长度
        if depth > seq_length
            % 检查是否能回到起点 (闭合回路)
            % 实际上对于欧拉图，只要遍历完所有边，必然回到起点。
            % 这里主要是一个终止条件。
            count = count + 1;
            sequences(count, :) = current_path;
            return;
        end
        
        % 尝试所有可能的转移 (即添加 0 到 k-1)
        for val = 0 : (k-1)
            % 检查该边是否已访问
            % MATLAB索引调整: node是0-based, val是0-based
            % visited矩阵索引: (node+1, val+1)
            if ~visited(current_node + 1, val + 1)
                
                % 计算下一个节点
                % 原理: 移位并添加新位
                % next_node = (current_node % k^(n-2)) * k + val
                if n > 1
                    mod_val = k^(n-2);
                    next_node = mod(current_node, mod_val) * k + val;
                else
                    next_node = 0; % 特殊情况 n=1
                end
                
                % 标记边为已访问
                visited(current_node + 1, val + 1) = true;
                current_path(depth) = val;
                
                % 递归下一步
                dfs(next_node, depth + 1);
                
                % 如果已满足数量要求，快速退出，不再回溯
                if count >= num_req
                    return;
                end
                
                % 回溯 (Unmark)
                visited(current_node + 1, val + 1) = false;
            end
        end
    end

    % 截断多余的预分配空间（如果没有找到足够的序列）
    if count < num_req
        sequences = sequences(1:count, :);
        warning('只找到了 %d 个序列，少于请求的 %d 个。', count, num_req);
    end
end