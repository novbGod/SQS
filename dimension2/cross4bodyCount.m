
function newArray = cross4bodyCount(matrix)
% 提取四体近邻,返回按二进制排列的各个四体的出现次数
    subsquare_codes = zeros(1, 32);
    count = 1;
    [row, column] = size(matrix);
    matrix = [matrix,matrix,matrix];
    matrix = [matrix;matrix;matrix];
    for i = row+1:2*row
        for j = column+1:2*column
            if matrix(i, j) == 0
                continue;
            end
            % 考虑周期性边界条件
            % top_left, top_right, bottom_left,c bottom_right
            tl = matrix(i, j) - 1;
            tr = matrix(i+1,j-1) - 1;
            bl = matrix(i+1,j+1) - 1;
            br = matrix(i+2,j) - 1;
            
            % 将2x2子矩阵编码为4位二进制数
            % 例如：[A B; C D] -> ABCD (二进制)
            subsquare_codes(count) = tl*8 + tr*4 + bl*2 + br;
            
            count = count + 1;
        end
    end
    % 识别每个四体出现的次数
    indices = subsquare_codes + 1;
    valuesToAccumulate = ones(size(subsquare_codes));
    newArray = accumarray(indices', valuesToAccumulate', [max(indices), 1]);
end