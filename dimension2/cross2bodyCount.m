%输入一个叉形五体矩阵，计算N阶二体近邻
function adjacent = cross2bodyCount(matrix,N)%a、b分别以1，2表示
aa = 0;bb = 0;ab = 0;
[l,m] = size(matrix);
matrix = [matrix;matrix;matrix];
matrix = [matrix,matrix,matrix];%周期性边界条件

if any([4,7,8,11] == N) 
    countPlaceN = cell(13,4);
    countPlaceN([4,7,8,11],:) = ...
     {[1,-3] [3,-1] [3,1] [1,3]; [2,-4] [4,-2] [4,2] [2,4];...
     [1,-5],[5,-1],[5,1],[1,5];[3,-5],[5,-3],[5,3],[3,5]};
        
    [place1,place2,place3,place4] = countPlaceN{N,:};
    for i = l+1:l*2
        for j = m+1:m*2
            if matrix(i,j) == 0
                continue;
            end
            v1 = matrix(i,j)*matrix(i+place1(1),j+place1(2));
            v2 = matrix(i,j)*matrix(i+place2(1),j+place2(2));
            v3 = matrix(i,j)*matrix(i+place3(1),j+place3(2));
            v4 = matrix(i,j)*matrix(i+place4(1),j+place4(2));
            if v1 == 1
                aa = aa + 1;
            elseif v1 == 2
                ab = ab + 1;
            elseif v1 == 4
                bb = bb + 1;
            end

            if v2 == 1
                aa = aa + 1;
            elseif v2 == 2
                ab = ab + 1;
            elseif v2 == 4
                bb = bb + 1;
            end

            if v3 == 1
                aa = aa + 1;
            elseif v3 == 2
                ab = ab + 1;
            elseif v3 == 4
                bb = bb + 1;
            end

            if v4 == 1
                aa = aa + 1;
            elseif v4 == 2
                ab = ab + 1;
            elseif v4 == 4
                bb = bb + 1;
            end
        end
    end
    adjacent = [aa,bb,ab];
    return;
end

    
    countPlaceN = cell(13,2);
    countPlaceN([1,2,3,5,6,9,10],:) = {[1,-1],[1,1];[2,0],[0,2];[2,-2],[2,2];...
        [4,0],[0,4];[-3,3],[3,3];[6,0],[0,6];[4,-4],[4,4]};

    place1 = countPlaceN{N,1};
    place2 = countPlaceN{N,2};

    for i = l+1:l*2
        for j = m+1:m*2
            if matrix(i,j) == 0
                continue;
            end
            v1 = matrix(i,j)*matrix(i+place1(1),j+place1(2));
            v2 = matrix(i,j)*matrix(i+place2(1),j+place2(2));
            if v1 == 1
                aa = aa + 1;
            elseif v1 == 2
                ab = ab + 1;
            elseif v1 == 4
                bb = bb + 1;
            end

            if v2 == 1
                aa = aa + 1;
            elseif v2 == 2
                ab = ab + 1;
            elseif v2 == 4
                bb = bb + 1;
            end
        end
    end

    adjacent = [aa,bb,ab];
end