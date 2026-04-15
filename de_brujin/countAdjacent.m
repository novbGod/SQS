%计算n级近邻数
% function adjacent = countAdjacent(piles,N)
%     N = N - 1;
%     pairCounter = buildPairCounter(piles);
%     [N_AA, N_BB, N_AB] = pairCounter(N);
%     N_AA = round(N_AA);
%     N_BB = round(N_BB);
%     N_AB = round(N_AB);
%     adjacent = [N_AA, N_BB, N_AB];
% end
% 
% function queryPairCounts = buildPairCounter(piles)
% % buildPairCounter   构造一个函数句柄，用于高效查询任意间隔 N 的配对数
% % 输入：
% %   piles — 长度为 2*M 的数组，
% %           奇数位置 piles(2*i-1) = 第 i 堆 A 原子数，
% %           偶数位置 piles(2*i)   = 第 i 堆 B 原子数
% % 输出：
% %   queryPairCounts — 函数句柄，调用方式：
% %       [cntAA, cntBB, cntAB] = queryPairCounts(N)
% %     返回间隔 N 个“中间原子”时 A–A、B–B、A–B 配对数。
% 
%   % 1) 展开二值序列
%   isA = repmat([1 0], 1, numel(piles)/2);    % [1 0 1 0 …]
%   counts = piles(:).';                        % 行向量
%   S = repelem(isA, counts);                   % 1 表示 A，0 表示 B
%   L = numel(S);
% 
%   % 2) FFT 预处理
%   FA = fft(double(S));
%   FB = fft(double(~S));
% 
%   % 3) 计算自相关
%   CAA = real(ifft(FA .* conj(FA)));
%   CBB = real(ifft(FB .* conj(FB)));
% 
%   % 4) 返回查询函数
%   queryPairCounts = @(N) localQuery(N, L, CAA, CBB);
% end
% 
% function [cntAA, cntBB, cntAB] = localQuery(N, L, CAA, CBB)
%   % N: “中间原子”个数
%   k = mod(N+1, L) + 1;       % MATLAB 下标从 1 开始
%   cntAA = CAA(k);
%   cntBB = CBB(k);
%   cntAB = L - cntAA - cntBB;
% end

function adjacent = countAdjacent(arr,n)
    % 生成原子类型序列（A和B交替）
    types = zeros(1,sum(arr));
    k = 1;%记录这每个球堆中第一个小球加入type的位置
    for i = 1:length(arr)
        if mod(i, 2) == 1  % 奇数堆为A，用1代表，偶数堆为B，用-1代表
            types(k:(k+arr(i)-1)) = ones(1,arr(i));
        else
            types(k:(k+arr(i)-1)) = -ones(1,arr(i));
        end
        k = k + arr(i);
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

% function adjacent = countAdjacent(arr, n)
% % 转化过高级近邻，放置后续程序出错
%     if n >= length(arr)
%         n = mod(n,length(arr));
%     end
% L = length(arr);
% arr = [arr,arr];
% AA = 0;
% BB = 0;
% AB = 0;
% for i = 1:L
%     for j = 1:arr(i)%计算大于1的堆
%         addIndex = 0;%代表插入addSum个球后下一个目标的索引
%         addSum = 0;%代表中间间隔的小球数
%         addSum = addSum - j;%补足堆内的原子数
%         if addSum + arr(i) >= n
%             AA = AA + mod(i,2);
%             BB = BB + mod(i+1,2);
%             continue;
%         end
%         while addSum < n
%             addSum = addSum + arr(addIndex + i);
%             addIndex = addIndex + 1;
%         end
%         addIndex = addIndex - 1;
%         addSum = addSum - arr(addIndex + i);
%         if mod(addIndex + i,2) == 1 && mod(i,2) == 1
%             AA = AA + 1;
%             continue;
%         end
%         if mod(addIndex + i,2) == 0 && mod(i,2) == 0
%             BB = BB + 1;
%             continue;
%         end
%         if mod(addIndex + i,2) == 1 && mod(i,2) == 0
%             AB = AB + 1;
%         end
%         if mod(addIndex + i,2) == 0 && mod(i,2) == 1
%             AB = AB + 1;
%         end
%     end
% end
% adjacent = [AA,BB,AB];
% end
