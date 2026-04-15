%识别方形8体近邻，输入一个01三角形矩阵，以每个点为中心方形的左上角顶点，数近邻
%输出一个大小为矩阵总点数的数组

function subsquare_codes = square8bodyCount(matrix)
    matrix = body8triangleToSquare(matrix);%拼凑成完整的
    subsquare_codes = zeros(1, numel(matrix));
    count = 1;
    [row, column] = size(matrix);
    for i = 1:row
        for j = 1:column
            % 考虑周期性边界条件
            % top_left, top_right, bottom_left,c bottom_right
           
            t = matrix(i, j);
            tl = matrix(mod(i, row) + 1, j);
            tr = matrix(mod(i, row) + 1, mod(j, column) + 1);
            r = matrix(mod(i, row) + 1, mod(j+1, column) + 1);
            l = matrix(mod(i+1, row) + 1, mod(j-2,column) + 1);
            bl = matrix(mod(i+1, row) + 1, j);
            br = matrix(mod(i+1, row) + 1, mod(j, column) + 1);
            b = matrix(mod(i+2, row) + 1, mod(j, column) + 1);

            % 将2x2子矩阵编码为4位二进制数
            % 例如：[A B; C D] -> ABCD (二进制)
            subsquare_codes(count) = t*128 + r*64 + l*32 + b*16 + tl*8 + tr*4 + bl*2 + br;
            
            count = count + 1;
        end
    end
end