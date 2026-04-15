%去重,resultABdiff存储去重后结果
%输入一个元胞，输出一个去重后的列元胞
function resultABdiff = deleteSame(resultAB)
%resultABdiff = resultAB;
resultABdiff = reshape(resultAB.', [], 1);%转化成列向量
i = 1;
while i <= size(resultABdiff,1)
    j = i+1;
    while j <= size(resultABdiff,1)%去重
        if max(resultABdiff{i}) == max(resultABdiff{j}) %先识别最大数是否相同以节省算力
            if are_rings_equivalent(resultABdiff{i},resultABdiff{j})
            resultABdiff(j) = [];
            j = j-1;
            end
        end
        j = j+1;
    end
    i = i+1;
end
end

%输入两个需要判断是否环形等价的数组，输出逻辑值
   function tf = are_rings_equivalent(A, B)
% ISCIRCEQ   判断 A 是否与 B 循环等价（正序或逆序）
%   tf = iscircEq(A,B) 返回逻辑值，若 A 是 B 的某种循环移位
%   或 A 是 B 逆序的某种循环移位，则 tf = true。

    % 快速长度判断
    if numel(A) ~= numel(B)
        tf = false;
        return;
    end

    % 将 B 正序和反序都拼接两遍
    B2 = [B, B];
    Br = B(end:-1:1);
    Br2 = [Br, Br];

    % 用 strfind 找 A 在 B2 或 Br2 中的位置
    % strfind 对数字也有效，底层已做优化 (大约 KMP)
    if ~isempty(strfind(B2, A)) || ~isempty(strfind(Br2, A))
        tf = true;
    else
        tf = false;
    end
end

