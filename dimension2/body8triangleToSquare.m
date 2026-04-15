%依照8体的要求，根据旋转对称，对角线对称，平分线对称，将其拼成矩形
function matrix = body8triangleToSquare(matrix)
matrix = triu(matrix) + triu(matrix,1)';
matrix = [matrix;flipud(matrix)];
matrix = [matrix,fliplr(matrix)];
end

