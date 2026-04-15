%输入n*2的边界矩阵，在所有边界间填充1，其他位置为0,长度为n，输出填充数组
function array = fillBoundary(boundarys,n)
    array = zeros(1,n);
    for i = 1:size(boundarys,1)
        start = boundarys(i,1);
        enD = boundarys(i,2);
        array(start:enD) = 1;
    end
end

