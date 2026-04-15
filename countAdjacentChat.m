% 使用示例：
P = [6	1	1	1	1	2	1	2	2	4	1	3	3	1	1	2];        % 三堆：AABBB | AAAAA B | AA BBBB
 ansN10 = countAdjacentChat(P,4);
% 计算 N=10 时的 A–A 对数
function adjacent = countAdjacent(arr,n)
    [pos, occ] = buildAIndex(arr);
    adjacent = countPairs(pos, occ, n);
end
function [pos, occ] = buildAIndex(P)
    % P: 1×(2M) 数组，奇数位为 A 原子数，偶数位为 B 原子数
    M = numel(P)/2;
    % 计算总原子数 T
    T = sum(P);
    
    % 1) 构造 A 原子全局位置 pos
    pos = zeros(sum(P(1:2:end)),1);
    idx = 1;
    cursor = 1;
    for pile = 1:M
        nA = P(2*pile-1);
        nB = P(2*pile);
        if nA>0
            pos(idx:idx+nA-1) = cursor : cursor+nA-1;
            idx = idx + nA;
        end
        cursor = cursor + nA + nB;
    end
    
    % 2) 建立环上 A 原子的哈希表（逻辑向量）
    occ = false(T,1);
    occ(pos) = true;
end

function countAA = countPairs(pos, occ, N)
    % 给定偏移 N，返回对数
    T = numel(occ);
    % 注意：相隔 N 个“原子”意为 index 差 (N+1)
    shifted = mod(pos-1 + (N+1), T) + 1;
    countAA = sum( occ(shifted) );
end
