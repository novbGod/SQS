%计算n级近邻数
function adjacent = countAdjacentOld(arr,n)
    % 生成原子类型序列（A和B交替）
    types = [];
    for i = 1:length(arr)
        if mod(i, 2) == 1  % 奇数堆为A，用1代表，偶数堆为B，用-1代表
            types = [types, ones(1,arr(i))];
        else
            types = [types, -ones(1,arr(i))];
        end
    end
    AA = 0; BB = 0; AB = 0;
    %转化过高级近邻，放置后续程序出错
    if n >= length(types)
        n = mod(n,length(types));
    end
    %遍历识别n级近邻
    for i = 1:length(types)-n
        if types(i) + types(i+n) == 2
            AA = AA + 1;
        elseif types(i) + types(i+n) == -2
            BB = BB + 1;
        else
            AB = AB + 1;
        end
    end
    %补足首尾衔接
    for i = n-1:-1:0
        if types(end-i) + types(-i+n) ==2
            AA = AA + 1;
        elseif types(end-i) + types(-i+n) == -2
            BB = BB + 1;
        else
            AB = AB + 1;
        end
    end
    adjacent = [AA,BB,AB];
end
