% clear;%用de brujin图生成2^n个原子组成的序列中，符合n体作用约束的序列n=3~16
%同时数每个结构的二体各级近邻和多体作用
n = 8;
a = generateDeBruijnSequence_v2(n);
    array = a - '0';
    array = ballsToPile(array);
    arrayAll(n-2,1:length(array)) = array;
    for i = 3:n%验算n阶是否满足n-1及以下的多体近邻
        adjacent{1,i-2} = num2str(countAdjacentNbody(array,i));
    end
    disp(adjacent);
    for i = 1:n+2%验算n阶是否满足2体的n及以下级的近邻
        adjacent2{1,i} = num2str(countAdjacent(array,i));
    end
    disp(adjacent2);
    disp(a)
% count = 0;
% for n = 4:2:16
%     count = count + 1;
%     a = generateDeBruijnSequence_v2(n);
%     array{count} = arrayfun(@(x) str2double(x), a);
%     % array1 = ballsToPile(array);
%     % arrayAll(n-2,1:length(array)) = array;
%     % for i = 3:n%验算n阶是否满足n-1及以下的多体近邻
%     %     adjacent{n-2,i-2} = num2str(countAdjacentNbody(array,i));
%     % end
%     % 
%     % for i = 1:n+2%验算n阶是否满足2体的n及以下级的近邻
%     %     adjacent2{n-2,i} = num2str(countAdjacent(array,i));
%     % end
% end



function deBruijnSequence = generateDeBruijnSequence_v2(n)
% generateDeBruijnSequence_v2 使用修改后的 Hierholzer 算法生成 n 阶 De Bruijn 序列。
%
%   输入:
%     n - De Bruijn 序列的阶数。
%
%   输出:
%     deBruijnSequence - 长度为 2^n 的 De Bruijn 二进制字符串。

if n <= 0
    error('阶数 n 必须是正整数。');
end

% --- 1. 构建 De Bruijn 图 ---
numNodes = 2^(n-1); 
numEdges = 2^n;

s = zeros(numEdges, 1);
t = zeros(numEdges, 1);
edgeRepresentations = cell(numEdges, 1); 

edgeIdx = 1;
for i = 0 : numNodes - 1
    current_prefix_bin = dec2bin(i, n-1); 

    n_bit_str_0 = [current_prefix_bin, '0'];
    next_node_dec_0 = bin2dec(n_bit_str_0(2:end));
    s(edgeIdx) = i + 1;
    t(edgeIdx) = next_node_dec_0 + 1;
    edgeRepresentations{edgeIdx} = n_bit_str_0;
    edgeIdx = edgeIdx + 1;

    n_bit_str_1 = [current_prefix_bin, '1'];
    next_node_dec_1 = bin2dec(n_bit_str_1(2:end));
    s(edgeIdx) = i + 1;
    t(edgeIdx) = next_node_dec_1 + 1;
    edgeRepresentations{edgeIdx} = n_bit_str_1;
    edgeIdx = edgeIdx + 1;
end

G = digraph(s, t);
G.Edges.Label = edgeRepresentations;

% ---------------- 2. 寻找欧拉回路的边序列 ----------------

% 创建邻接列表，存储每条边的索引，方便后续操作
adjList = cell(numNodes, 1);
for k = 1:numEdges
    adjList{s(k)} = [adjList{s(k)}, k];
end

% 标记边是否被访问过
edgeVisited = false(numEdges, 1);

% 递归函数，用于查找并嵌入子回路
function path = findSubcircuit(startNode)
    path = [];
    currentNode = startNode;
    currentPath = []; % 存储当前子回路的边索引

    while ~isempty(adjList{currentNode})
        % 从当前节点的出边列表中找到一条未访问的边
        found_edge_idx = -1;
        for j = 1:length(adjList{currentNode})
            edge_id = adjList{currentNode}(j);
            if ~edgeVisited(edge_id)
                found_edge_idx = edge_id;
                break;
            end
        end

        if found_edge_idx ~= -1
            % 标记该边为已访问
            edgeVisited(found_edge_idx) = true;
            currentPath(end+1) = found_edge_idx;
            
            % 移除已访问的边，避免再次被选中
            adjList{currentNode} = adjList{currentNode}(adjList{currentNode} ~= found_edge_idx);
            
            % 移动到下一个节点
            currentNode = G.Edges.EndNodes(found_edge_idx, 2);
        else
            % 如果当前节点没有未访问的出边，说明子回路已经闭合
            break;
        end
    end
    
    % 在子回路中寻找有未访问出边的节点，并嵌入新的子回路
    for j = 1:length(currentPath)
        subPath = findSubcircuit(G.Edges.EndNodes(currentPath(j), 2));
        if ~isempty(subPath)
            % 将新子回路嵌入到当前子回路中
            currentPath = [currentPath(1:j), subPath, currentPath(j+1:end)];
        end
    end
    
    path = currentPath;
end

% 从节点 1 开始寻找欧拉回路
eulerPathEdges = findSubcircuit(1);

% ---------------- 3. 从欧拉回路中提取 De Bruijn 序列 ----------------
initial_prefix = dec2bin(0, n-1);
deBruijnSequence = initial_prefix;

for i = 1:length(eulerPathEdges)
    edge_id = eulerPathEdges(i);
    n_bit_str = G.Edges.Label{edge_id};
    deBruijnSequence = [deBruijnSequence, n_bit_str(end)];
end

deBruijnSequence = deBruijnSequence(1:2^n);

end