%识别×形5体近邻，输入一个矩阵，以每个点为×左上角顶点数近邻
%输出一个大小为矩阵总点数的数组

function subsquare_codes = cross5bodyCount(matrix)
% 提取五体近邻
    subsquare_codes = zeros(1, 32);
    count = 1;
    [row, column] = size(matrix);
    for i = 1:row
        for j = 1:column
            % 考虑周期性边界条件
            % top_left, top_right, bottom_left,c bottom_right
            tl = matrix(i, j);
            tr = matrix(i, mod(j, column) + 1);
            center = matrix(mod(i, row) + 1, j);
            bl = matrix(mod(i + 1, row) + 1, j);
            br = matrix(mod(i + 1, row) + 1, mod(j, column) + 1);
            
            % 将2x2子矩阵编码为4位二进制数
            % 例如：[A B; C D] -> ABCD (二进制)
            subsquare_codes(count) = tl*16 + tr*8 + center*4 + bl*2 + br;
            
            count = count + 1;
        end
    end
end