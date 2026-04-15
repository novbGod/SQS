%输入一个行向量堆数组，自动展开为小球排列计算N体排列，输出一个按二进制排列的
%近邻数组，以N=3为例，近邻数组的下标从1到8对应为[BBB,BBA,BAB,BAA,ABB,ABA,AAB,AAA]
%N=4时，1-16对应
%[BBBB1,BBBA1,BBAB,BBAA1,BABB,BABA,BAAB,BAAA1,
% ABBB,ABBA,ABAB,ABAA,AABB,AABA,AAAB,AAAA]
function allCounts = countAdjacentNbody(array,N)
if isempty(array) == 1
    allCounts = [];
    return;
end
arrayAB = [];
L1 = length(array);
for i = 1:L1
    arrayAB = [arrayAB,ones(1,array(i))-mod(i-1,2)];
end%将堆数组展开为小球数组
arrayAB = [arrayAB,arrayAB(1:N-1)];%接尾
L2 = length(arrayAB);
codes = zeros(1,L2-N+1);
for i = 1:N
    codes = codes + arrayAB(N-i+1:L2-i+1)*2^(i-1); %按二进制计算
end
allCounts = accumarray(codes'+1, 1, [2^N, 1]); %按二进制顺序排列
allCounts = allCounts';
%按自定顺序排列
if N == 3 %[BBB,BBA,BAB,BAA,ABA,AAA]
allCounts = [allCounts(1),allCounts(2)+allCounts(4),allCounts(3),...
   allCounts(5)+allCounts(7),allCounts(6),allCounts(8)];
end
% if N == 4 %[BBBB4,BBBA3,BBAB2,BBAA2,BABA2,BAAB2,BAAA2,ABBA3,ABAA2,AAAA2]
%     allCounts = [allCounts(1),allCounts(2)+allCounts(9),...
%     allCounts(3)+allCounts(5),allCounts(4)+allCounts(13)...
%     ,allCounts(6)+allCounts(11),allCounts(7),...
%     allCounts(8)+allCounts(15),allCounts(10),...
%     allCounts(12)+allCounts(14),allCounts(16)];
% end
%N=5 [BBBBB5,BBBBA4,BBBAB3,BBBAA3,BBABB2,BBABA2,BBAAB2,BBAAA2,BABBB3,BABBA3,BABAB2,
%     BABAA2,BAABB2,BAABA2,BAAAB2,BAAAA2,ABBBB4,ABBBA4,ABBAB3,ABBAA3,ABABB2,ABABA2,
%     ABAAB2,ABAAA2,AABBB3,AABBA3,AABAB2,AABAA2,AAABB2,AAABA2,AAAAB2,AAAAA2]
% if N == 5
%     allCounts = [allCounts(5:8),allCounts(11:16),allCounts(21:24),allCounts(27:32)];
% end
end