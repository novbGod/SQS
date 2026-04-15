function seqs = ManyRandom(numArray,l)
%生成一个矩阵，每一行是指定长度的01数量相等的随机数组
base_array = [zeros(1, l/2), ones(1, l/2)];
for i = 1:numArray
    random_indices = randperm(l);
    seqs(i,:) = base_array(random_indices);
end
end

