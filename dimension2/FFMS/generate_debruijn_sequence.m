
function db_sequence = generate_debruijn_sequence(k, n)
% GENERATE_DEBRUIJN_SEQUENCE 构造 k 进制、n 阶的 De Bruijn 序列 B(k, n)。
%
% 输入:
%   k (int): 字母表大小 (e.g., k=3, 字母表为 '0', '1', '2')
%   n (int): 序列的阶数
%
% 输出:
%   db_sequence (char array): 构造出的 De Bruijn 序列 (长度为 k^n)

    if k < 2 || n < 1
        error('k 必须大于等于 2，n 必须大于等于 1。');
    end

    % 1. 定义 De Bruijn 图的顶点 (V) 和边 (E)
    % ----------------------------------------------------
    
    % 图的阶数是 m = n-1
    m = n - 1;
    
    % 顶点总数 (N) = k^(n-1)
    N = k^m;
    
    % 欧拉环游的总边数 (E) = k^n
    E_total = k^n; 
    
    % 使用数字 0 到 N-1 来表示图的顶点。
    % 每个数字对应一个长度为 m 的 k 进制字符串。

    % 2. Hierholzer 算法: 寻找欧拉环游
    % ----------------------------------------------------
    
    % Graph 结构: 存储每个顶点的出边。
    % Graph{v+1} 存储的是从顶点 v 出发的下一个顶点列表。
    % k 进制下，顶点 v 对应的字符串 s, s 的 k 个后继是 s'0, s'1, ..., s'(k-1)
    % 其中 s' 是 s 去掉第一个字符。
    
    % 顶点的索引是 1 到 N (MATLAB 习惯)
    Graph = cell(N, 1);
    
    % 初始化图的边列表 (使用栈来管理欧拉环游路径)
    for v = 0:(N-1)
        % 从顶点 v (k进制字符串v) 出发，有 k 条边。
        % v 的 k 个后继顶点 u 对应于在 v 后面添加字符 '0' 到 'k-1'。
        
        % 计算 v 对应的字符串的前缀部分 (去掉第一个字符)
        % (v mod k^(m-1)) 是 v 的 (m-1) 长度后缀。
        % 下一个顶点 u = (v 的 m-1 后缀) * k + 新的字符 c
        % 或 u = (v mod k^(m-1)) * k + c
        
        % Graph{v+1} 存储的是出边对应的 '新字符' c 列表。
        % 我们使用 0 到 k-1 来表示字符 '0' 到 'k-1'。
        Graph{v+1} = (0:(k-1)); 
    end
    
    % 初始化欧拉路径
    euler_path = zeros(1, E_total); % 存储新加入的字符 (0到k-1)
    edge_count = 0; % 追踪当前找到的边数
    
    % 栈用于 DFS 遍历
    stack = 1; % 从顶点 0 (索引为 1) 开始
    
    % 核心欧拉环游查找
    while ~isempty(stack)
        u_idx = stack(end); % 当前顶点索引 (1 to N)
        u = u_idx - 1; % 实际顶点值 (0 to N-1)
        
        if isempty(Graph{u_idx})
            % 如果当前顶点没有可用的出边，则将此顶点从栈中移除，并记录路径。
            stack(end) = [];
        else
            % 找到一条边: 
            % 取出最后一条边 (新字符 c) - 栈操作的效率更高
            c = Graph{u_idx}(end);
            Graph{u_idx}(end) = []; 
            
            % 计算下一个顶点 v (0 to N-1)
            % u' 的后缀是 (u mod k^(m-1))
            % 下一个顶点 v = (u mod k^(m-1)) * k + c
            v = mod(u, k^(m-1)) * k + c;
            v_idx = v + 1; % 下一个顶点索引
            
            % 将新顶点压入栈
            stack = [stack, v_idx]; %#ok<AGROW>
            
            % 记录这条边对应的新字符
            edge_count = edge_count + 1;
            euler_path(edge_count) = c;
        end
    end
    
    % 3. 构造序列
    % ----------------------------------------------------
    
    % 将欧拉路径 (新字符 0 到 k-1) 转换为字符序列。
    % db_sequence 的长度是 k^n
    new_chars = char(euler_path + '0');
    
    % 序列的第一个 n-1 个字符由起始顶点 '0...0' 确定。
    prefix = repmat('0', 1, n-1);
    
    % 最终 De Bruijn 序列 = (起始 n-1 个字符) + (欧拉路径上的新字符)
    db_sequence = [prefix, new_chars];
    
    % 结果序列的长度是 n-1 + k^n。根据定义，De Bruijn 序列是循环的。
    % 线性表示通常取 k^n 个字符，其循环的闭合性质包含了前 n-1 个字符。
    % 所以我们只取前 k^n 个字符（欧拉路径上的边字符）即可。
    % 
    % 实际上，该方法生成的序列是: S = c_1 c_2 ... c_{k^n}
    % 序列中的第一个 n-mer 是 S[1..n] = prefix + c_1
    % 序列中的最后一个 n-mer (循环闭合) 是 S[k^n-n+2..k^n] + S[1..n-1]
    % 
    % 最终输出只包含欧拉环游上的 k^n 个字符，并假设它是循环的。
    % db_sequence = new_chars; % 实际上 new_chars 就是欧拉环游上的 k^n 个边标签
    % 但为了符合常见的线性表示形式，我们保持 [prefix, new_chars] 的形式
    db_sequence = [prefix, new_chars];
    db_sequence = db_sequence(1:E_total); % 仅取 k^n 个字符

end
