% === 在 MATLAB 命令行中运行 ===

% 1. 定义参数
k = 2; % 二进制
n = 5; % B(2,4) 序列, 长度为 2^4 = 16

% 2. 获取你的判断函数的句柄
%    (确保 myJudgment.m 在你的 MATLAB 路径中)
judgeHandle = @symmetry01;

% 3. 运行主函数
%    它将持续生成 B(2,4) 序列，直到 myJudgment 返回 true
validSeq = findValidDeBruijn(k, n, judgeHandle);

% 
% for i = 1:size(ballsArray,1)
%     if are_rings_equivalent(str2num(ballsArray{i,1}),validSeq)
%         disp('yes');disp(i);break;
%     elseif i == size(array,1)
%         disp('no');
%     end
% end

function valid_sequence = findValidDeBruijn(k, n, judgmentFunction)
% findValidDeBruijn: 查找一个通过自定义判断函数的 B(k,n) De Bruijn 序列。
%
% 输入:
%   k (scalar): 字母表的大小 (例如, k=2 表示二进制)
%   n (scalar): 子序列的长度 (阶数)
%   judgmentFunction (function_handle): 你的判断函数句柄。
%       这个函数必须接受一个 1x(k^n) 的序列向量作为输入，
%       并返回一个 logical 值 (true 或 false)。
%
% 输出:
%   valid_sequence (1x(k^n) vector): 找到的第一个通过判断的 De Bruijn 序列。
%
% 示例 (在命令行中):
%   % 1. 先定义一个判断函数 (见下文示例)
%   % 2. k = 2; n = 3;
%   % 3. judgeHandle = @myJudgment;
%   % 4. seq = findValidDeBruijn(k, n, judgeHandle);

    disp('开始搜索有效的 De Bruijn 序列...');
    
    % 使用一个无限循环，直到找到满足条件的序列
    while true
        % 1. 生成一个 *随机* 的 B(k,n) 序列
        %    每次循环调用都会生成一个可能不同的序列
        try
            candidate_seq = generateRandomB(k, n);
            
            % 2. 将生成的序列输入你的判断函数
            isValid = 1;
            % isValid = judgmentFunction(candidate_seq);
            
            % 3. 检查结果
            if isValid
                % 如果为 true，返回此序列并退出
                valid_sequence = candidate_seq;
                disp('成功找到一个有效的序列:');
                disp(valid_sequence);
                return; % 退出函数
            else
                % 如果为 false，循环继续，生成下一个
                disp('序列未通过... 正在生成下一个...');
            end
            
        catch ME
            % 捕获生成器可能发生的错误 (虽然不太可能)
            warning('序列生成时出错: %s. 正在重试...', ME.message);
        end
    end
end


% --- 本地函数 (Local Function) ---
% 这个函数与 findValidDeBruijn 在同一个 .m 文件中
function seq = generateRandomB(k, n)
% generateRandomB: 使用随机欧拉路径法生成一个 B(k,n) 序列。
%
% 算法:
% 1. 构建一个 n-1 阶 De Bruijn 图。
%    - 节点: 0 到 k^(n-1)-1，代表所有长度为 n-1 的前缀。
%    - 边: 从节点 u 出发，有 k 条边 (数字 0 到 k-1)。
%    - 边 (digit) 从 u 到达 v = mod(u*k + digit, k^(n-1))。
% 2. 使用 Hierholzer 算法的随机深度优先搜索 (DFS) 变体来查找一条欧拉回路。
% 3. 随机化体现在: 在 DFS 的每一步，随机打乱 "下一个可用数字" 的顺序。

    num_nodes = k^(n-1);
    len = k^n; % De Bruijn 序列的总长度

    % 邻接表: adj{u+1} 存储节点 u (0-indexed) 的所有可用出边 (数字 0..k-1)
    % (MATLAB cell 索引是 1-based, 所以用 u+1)
    adj = cell(num_nodes, 1);
    for i = 1:num_nodes
        adj{i} = 0:(k-1); % 初始时，所有边都可用
    end

    % 存储最终序列的数字 (Hierholzer 算法会反向构建路径)
    path_digits = zeros(1, len);
    path_idx = 1;

    % 调用嵌套的 DFS 函数，它共享 adj, path_digits, k, num_nodes 等变量
    dfs(0); % 从节点 0 开始

    % 算法得到的是反向路径，需要翻转
    seq = fliplr(path_digits);

    % --- 嵌套的 DFS 函数 (Nested Function) ---
    function dfs(u)
        % u 是当前节点的索引 (0-indexed)
        
        % --- 随机化关键步骤 ---
        % 获取当前节点 u 的可用出边 (数字)
        adj_list_u = adj{u+1};
        
        % 随机打乱这些边的顺序
        adj_list_u_shuffled = adj_list_u(randperm(length(adj_list_u)));
        
        % 按照这个随机顺序尝试遍历
        for digit = adj_list_u_shuffled
            
            % 检查这条边是否 *仍然* 可用
            % (因为 adj{u+1} 可能会在递归中被修改)
            original_list = adj{u+1};
            idx = find(original_list == digit, 1);
            
            if ~isempty(idx)
                % 边是可用的，使用它
                adj{u+1}(idx) = []; % 从可用列表中移除 (标记为已访问)
                
                % 计算下一个节点 v
                v = mod(u * k + digit, num_nodes);
                
                % 递归进入下一个节点
                dfs(v);
                
                % --- Hierholzer 算法 ---
                % 当从递归调用返回时 (即 v 的路径已探索完毕)，
                % 将导致该路径的 "digit" 添加到 *末尾*
                path_digits(path_idx) = digit;
                path_idx = path_idx + 1;
            end
        end
    end
end