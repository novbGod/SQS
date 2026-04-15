function ballsArray = pileToBalls(pileArray, i)
%输入一个堆数组，将其拆解为01小球数组并输出,i=1代表仅满足二体作用，i=2代表满足多体作用
n = log(length(pileArray))/log(2) + 1;
ballsArray = zeros(1,2^n);
index = 1;
for i = 1:length(pileArray)
    ballsArray(index:pileArray(i)+index-1) = mod(i,2);
    index = pileArray(i)+index;
end
ballsArray = abs(ballsArray - 1);
end