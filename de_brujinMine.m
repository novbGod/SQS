clear;%我自己的版本，但是没有ai函数版本好，可以画图
n = 3;
numNodes = 2^(n-1); % 节点数量为 4 (00, 01, 10, 11)

% 存储边的列表
s = [];
t = [];
edge_labels = {}; % 存储每条边代表的 n 位二进制字符串

% 构建图
for i = 0 : numNodes - 1
    current_prefix_bin = dec2bin(i, n-1);

    % 添加 '0'
    n_bit_str_0 = [current_prefix_bin, '0'];
    next_node_dec_0 = bin2dec(n_bit_str_0(2:end));
    s = [s, i+1]; % +1 因为 MATLAB 索引从 1 开始
    t = [t, next_node_dec_0+1];
    edge_labels{end+1} = n_bit_str_0;

    % 添加 '1'
    n_bit_str_1 = [current_prefix_bin, '1'];
    next_node_dec_1 = bin2dec(n_bit_str_1(2:end));
    s = [s, i+1];
    t = [t, next_node_dec_1+1];
    edge_labels{end+1} = n_bit_str_1;
end

% 使用边的列表创建 digraph 对象
G = digraph(s, t);

% 将 edge_labels 作为边的属性添加到图中
G.Edges.Label = edge_labels';

% 绘制 De Bruijn 图
figure;
plot(G, 'EdgeLabel', G.Edges.Label);
title(['De Bruijn 图, n=', num2str(n)]);

% ---------------- Hierholzer 算法 ----------------

% 1. 准备工作
numEdges = size(G.Edges, 1);
edgeVisited = false(numEdges, 1); % 标记每条边是否被访问过

% 存储欧拉回路中的边索引
eulerPathEdges = [];
% 用于 Hierholzer 算法的辅助栈
currentPathStack = 1; % 从节点 1 开始探索

% ---------------- 2. 主循环 ----------------
while ~isempty(currentPathStack)
    u = currentPathStack(end); % 获取栈顶节点

    % 找到从 u 出发的未访问的边
    % outedges(G, u) 返回从节点 u 出发的所有出边的索引
    outgoingEdges = outedges(G, u);
    
    foundNextEdge = false;
    nextEdgeIdx = -1;
    for k = 1:length(outgoingEdges)
        edge_id = outgoingEdges(k);
        if ~edgeVisited(edge_id)
            nextEdgeIdx = edge_id;
            foundNextEdge = true;
            break;
        end
    end

    if foundNextEdge
        % 如果找到未访问的边
        edgeVisited(nextEdgeIdx) = true; % 标记这条边为已访问
        v = G.Edges.EndNodes(nextEdgeIdx, 2); % 获取这条边的目标节点
        currentPathStack(end+1) = v; % 将目标节点推入栈
        eulerPathEdges(end+1) = nextEdgeIdx; % 将边的索引添加到欧拉回路
    else
        % 如果当前节点没有未访问的出边，将栈顶节点弹出
        currentPathStack(end) = []; 
        goBack = true;
    end
end

% ---------------- 3. 从欧拉回路中提取 De Bruijn 序列 ----------------

% 序列由起始节点的 (n-1) 位前缀和每条边的最后一个字符组成
% 起始节点我们是 1，对应于 '0...0'
initial_prefix = dec2bin(0, n-1);
deBruijnSequence = initial_prefix;

for i = 1:length(eulerPathEdges)
    edge_id = eulerPathEdges(i);
    n_bit_str = G.Edges.Label{edge_id}; % 获取 n 位二进制字符串
    deBruijnSequence = [deBruijnSequence, n_bit_str(end)]; % 拼接最后一个字符
end

% De Bruijn 序列的最终长度是 2^n，需要截取
deBruijnSequence = deBruijnSequence(1:2^n);

% 打印结果
disp(['De Bruijn 序列 (n=', num2str(n), '): ', deBruijnSequence]);

array = deBruijnSequence - '0';
array = ballsToPile(array);
adjacent = countAdjacentNbody(array,n);
disp(adjacent);