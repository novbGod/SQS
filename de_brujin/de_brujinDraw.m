clear;
clc;
close all;

n = 3;
numNodes = 2^(n-1); % 节点数量为 4 (00, 01, 10, 11)

% 存储边的列表
s = [];
t = [];

% 存储每条边的标签（0或1）
edge_labels_for_plot = {};

% 构建图
for i = 0 : numNodes - 1
    current_prefix_bin = dec2bin(i, n-1);
    
    % 添加 '0'
    n_bit_str_0 = [current_prefix_bin, '0'];
    next_node_dec_0 = bin2dec(n_bit_str_0(2:end));
    s = [s, i+1]; % +1 因为 MATLAB 索引从 1 开始
    t = [t, next_node_dec_0+1];
    edge_labels_for_plot{end+1} = '0'; % 将边的标签设为'0'
    
    % 添加 '1'
    n_bit_str_1 = [current_prefix_bin, '1'];
    next_node_dec_1 = bin2dec(n_bit_str_1(2:end));
    s = [s, i+1];
    t = [t, next_node_dec_1+1];
    edge_labels_for_plot{end+1} = '1'; % 将边的标签设为'1'
end

% 节点名称，例如 '00', '01', '10', '11'
node_labels = cell(numNodes, 1);
for i = 0:numNodes-1
    node_labels{i+1} = dec2bin(i, n-1);
end

% 使用边的列表创建 digraph 对象
G = digraph(s, t);

% 绘制 De Bruijn 图，只修改节点和边的标签，不改变布局
figure;
h = plot(G, 'NodeLabel', node_labels, ...  % 设置节点标签为 '00', '01', 等
         'EdgeLabel', edge_labels_for_plot); % 设置边标签为 '0' 或 '1'

title(['De Bruijn 图, n=', num2str(n)]);

% ---------------- Hierholzer 算法 ----------------
% 这部分代码不变，为了完整性保留
% 1. 准备工作
numEdges = size(G.Edges, 1);
edgeVisited = false(numEdges, 1); % 标记每条边是否被访问过
eulerPathEdges = []; % 存储欧拉回路中的边索引
currentPathStack = 1; % 从节点 1 开始探索

% 2. 主循环
while ~isempty(currentPathStack)
    u = currentPathStack(end);
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
        edgeVisited(nextEdgeIdx) = true;
        v = G.Edges.EndNodes(nextEdgeIdx, 2);
        currentPathStack(end+1) = v;
        eulerPathEdges(end+1) = nextEdgeIdx;
    else
        currentPathStack(end) = []; 
    end
end

% 3. 从欧拉回路中提取 De Bruijn 序列
initial_prefix = dec2bin(0, n-1);
deBruijnSequence = initial_prefix;
for i = 1:length(eulerPathEdges)
    edge_id = eulerPathEdges(i);
    % 原始代码中这里需要用到完整的n位字符串来构建序列
    % 所以我保留了完整的字符串信息
    s_full = G.Edges.EndNodes(edge_id, 1);
    t_full = G.Edges.EndNodes(edge_id, 2);
    
    % 这里需要根据边的起点和终点来判断这条边是'0'还是'1'
    % 例如，从'00' (节点1) 到 '00' (节点1)，其边的末尾是'0'
    % 从'00' (节点1) 到 '01' (节点2)，其边的末尾是'1'
    % 边的标签是根据你的for循环生成的，是'0'和'1'。
    % 所以可以直接使用 edge_labels_for_plot
    deBruijnSequence = [deBruijnSequence, edge_labels_for_plot{edge_id}];
end

% 确保序列长度为 2^n
deBruijnSequence = deBruijnSequence(1:2^n);

% 打印结果
disp(['De Bruijn 序列 (n=', num2str(n), '): ', deBruijnSequence]);

% 你的原始代码中还有这两行，为了保持完整性我保留了
% array = deBruijnSequence - '0';
% array = ballsToPile(array);
% adjacent = countAdjacentNbody(array,n);
% disp(adjacent);