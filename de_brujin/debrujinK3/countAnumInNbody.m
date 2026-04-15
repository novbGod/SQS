function results = countAnumInNbody(array, n)
results = zeros(1,n+1);
array = array - '0';
array = [array,array(1:n)];
kind = zeros(1,floor(length(array)/n));
    for i = 1:length(array)-n
        kind(i) = sum(array(i:i+n-1));
    end
[unique_elements, ~, indices] = unique(kind);

% 2. 使用 accumarray 统计出现次数
% indices 是分组数组，@length 是应用函数（计算每组的长度，即次数）
counts = accumarray(indices, 1, [], @length);
results(unique_elements + 1) = counts;
end

