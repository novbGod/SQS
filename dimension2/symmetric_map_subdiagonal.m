
function new_indices = symmetric_map_subdiagonal(n, indices_row, indices_col)
    % 本函数实现方形矩阵中索引的周期性转换和副对角线对称映射。
    %
    % 输入:
    %   n: 方形矩阵的大小 (n x n)。
    %   indices: 原始多元素的行索引向量，列索引向量，要输入列向量
    %
    % 输出:
    %   new_indices: 对称映射后的新索引向量。

    % 1. 周期性转换 (确保索引在 1 到 n 之间)
    % 使用 mod 函数将索引周期性地映射到 1 到 n 的范围内。
    % MATLAB 的 mod(x, m) 结果范围是 0 到 m-1，所以需要 +1。
    % 这里使用 (x - 1) 来处理，确保当 x 是 n 的倍数时，结果为 n。
    row_orig = indices_row;
    col_orig = indices_col;

    row_period = mod(row_orig - 1, n) + 1;
    col_period = mod(col_orig - 1, n) + 1;

    % 2. 副对角线对称映射
    % 副对角线上的元素满足 i + j = n + 1。
    % 如果一个点是 (i, j)，它关于副对角线的对称点是 (n + 1 - j, n + 1 - i)。
    row_new = n + 1 - col_period;
    col_new = n + 1 - row_period;

    % 3. 将新索引打包成向量
    new_indices = [row_new, col_new];
end