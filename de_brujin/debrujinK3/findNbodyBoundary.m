function boundary = findNbodyBoundary(array,n,num)
%输入字符串array，找到array数组的所有含有num个1的n体的边界，返回边界数组
array = array - '0';
L = length(array);
array = [array,array(1:n-1)];
boundary = zeros(1,L);
for i = 1:L
    Nbody = array(i:i+n-1);
    if sum(Nbody) == num
        boundary(i:i+n-1) = 1;
    end
end
if length(boundary) > L
    boundary(1:length(boundary)-L) = max(boundary(1:length(boundary)-L),boundary(L+1:length(boundary)));
end

end

