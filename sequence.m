%将结果按近邻数排列(忽略最近邻）
function new = sequence(old,kmax)
check = ones(size(old,1),kmax+1);
m = size(old,1);
    for i = 3:kmax+1
        for j = 1:size(old,1)
            array = old{j,i}; 
            if 2*array(1)==array(3) && 2*array(2)==array(3) && check(j,i)
                % 构造新索引
            new_order = [j, 1:j-1, j+1:m];
            % 重新排列行
            old = old(new_order, :);
            check = check(new_order, :);
            else
                check(j,i:kmax+1) = 0;
            end
        end
    end
    new = old;
end
