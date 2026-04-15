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

