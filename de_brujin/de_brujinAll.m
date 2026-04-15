clear;
% 找到所有不环形等价的 n=3 的 De Bruijn 序列
n = 4;
all_unique_seqs_n3 = findAllUniqueDeBruijnSequences(n);
for i = 1:length(all_unique_seqs_n3)
    array{i} = all_unique_seqs_n3{i} - '0';
    array{i} = ballsToPile(array{i});
end
array = array(end:-1:1);
array = deleteSame(array);
for i = 1:length(array)
    adjacent{i} = countAdjacentNbody(array{i},n);
end
% disp(['n=', num2str(n), ' 的所有不环形等价 De Bruijn 序列数量: ', num2str(length(array))]);
% % 预期输出: 2 (例如 '00010111' 和 '00011101')
% 
% % 打印所有序列
% for i = 1:length(array)
%     disp(['序列 ', num2str(i), ': ', num2str(array{i})]);
% end

%转换为矩阵方便复制粘贴
for i = 1:length(array)
array1(i,:) = array{i};
end

%转换为字符串方便查看
% for i = 1:length(array)
% array{i} = num2str(array{i});
% adjacent{i} = num2str(adjacent{i});
% end
% adjacent = adjacent';

%检查所有结构的各级2体近邻
for i = 1:size(array,1)
    for j = 2:7
        array{i,j} = countAdjacent(array{i,1},j);
    end
end

%将所有堆数组拆解为小球数组,并检查是否有经01兑换后保持不变的数组
count = 0;
for i = 1:size(array,1)
    ballsArray{i,1} = num2str(pileToBalls(array{i,1}));
    a01 = str2num(ballsArray{i,1});
    a10 = abs(a01 - 1);
    
    if are_rings_equivalent(a01,a10) == 1
        count = count + 1;
        betterArray{1,count} = ballsArray{i,1};
        ballsArray{i,2} = 1;
        center = sum(find(array{i,1} == n))/2;
        L = length(array{i,1});
        temp = [array{i,1},array{i,1},array{i,1}];
        cArray = [temp(L/2+ceil(center):L+ceil(center)-1),temp(L+ceil(center):L+ceil(center)+L/2-1)];
        betterArray{2,count} = num2str(pileToBalls(cArray));
    end
end


function allUniqueDeBruijnSequences = findAllUniqueDeBruijnSequences(n)
% findAllUniqueDeBruijnSequences 找到所有不环形等价的 n 阶 De Bruijn 序列。
%
%   输入:
%     n - De Bruijn 序列的阶数 (即子串长度)。
%
%   输出:
%     allUniqueDeBruijnSequences - 包含所有不环形等价 De Bruijn 序列的元胞数组。

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

% ---------------- 2. 递归回溯寻找所有不环形等价的欧拉回路 ----------------
allUniqueDeBruijnSequences = {}; % 存储所有不环形等价的序列
edgeVisited = false(numEdges, 1);
adjList = cell(numNodes, 1);

for k = 1:numEdges
    adjList{s(k)} = [adjList{s(k)}, k];
end

% 用于检查一个序列是否是另一个序列的循环移位
function isCyclicEquivalent = isCyclicEquivalent(seq1, seq2)
    if length(seq1) ~= length(seq2)
        isCyclicEquivalent = false;
        return;
    end
    
    seq2_doubled = [seq2, seq2];
    isCyclicEquivalent = contains(seq2_doubled, seq1);
end

% 递归回溯函数
function findPaths(currentNode, currentPath)
    % 遍历当前节点的所有出边
    for k_edge_idx = 1:length(adjList{currentNode})
        edge_id = adjList{currentNode}(k_edge_idx);
        if ~edgeVisited(edge_id)
            % 标记该边为已访问
            edgeVisited(edge_id) = true;
            nextPath = [currentPath, edge_id];
            
            if length(nextPath) == numEdges
                % 如果找到完整的欧拉回路，将其转换为 De Bruijn 序列
                initial_prefix = dec2bin(0, n-1);
                deBruijnSequence = initial_prefix;
                for i = 1:numEdges
                    n_bit_str = G.Edges.Label{nextPath(i)};
                    deBruijnSequence = [deBruijnSequence, n_bit_str(end)];
                end
                deBruijnSequence = deBruijnSequence(1:numEdges);
                
                % 检查该序列是否已存在于结果集中
                isNew = true;
                for i = 1:length(allUniqueDeBruijnSequences)
                    if isCyclicEquivalent(deBruijnSequence, allUniqueDeBruijnSequences{i})
                        isNew = false;
                        break;
                    end
                end
                
                if isNew
                    % 如果是新的，则添加到结果集
                    allUniqueDeBruijnSequences{end+1} = deBruijnSequence;
                end
            else
                % 否则，继续递归探索
                nextNode = G.Edges.EndNodes(edge_id, 2);
                findPaths(nextNode, nextPath);
            end
            
            % 回溯：移除该边，以便探索其他路径
            edgeVisited(edge_id) = false;
        end
    end
end

% 从固定起点 '0...0' (即节点 1) 开始探索所有回路
findPaths(1, []);

end