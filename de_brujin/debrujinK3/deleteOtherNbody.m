
n = 10;
num = 5;
figure;


a = generate_debruijn_sequence(2,n);
boundary = findNbodyBoundary(a,n,num);
aDel = a(boundary == 1);
subplot(1,2,1);
r1 = countAnumInNbody(aDel,n);
bar(0:n,r1);
title(sprintf('仅保留含有%d个A原子的%d体,长度为%d',num,n,length(aDel)));
subplot(1,2,2);
r2 = countAnumInNbody(a,n);
bar(0:n,r2);
title(sprintf('原始序列,长度为%d',length(a)));