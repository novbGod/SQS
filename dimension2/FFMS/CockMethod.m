clear

%可直接生成(k^2,k^2;2,2)_k,k必须为奇数
k = 23;
d1k3n2 = generate_debruijn_sequence(k,2) - '0';
d1k3n2 = [d1k3n2(end), d1k3n2(1:end-1)];
b = 0:k^2-1;

A22_9_9_k3(:,1) = d1k3n2;
d1k3n2new = d1k3n2;
    
for i = 2:k^2
    d1k3n2new = circshift(d1k3n2new, -b(i-1));
    A22_9_9_k3(:,i) = d1k3n2new;
end

[a,b,c] = check2(A22_9_9_k3, 2, 2, k);
plotMatrixBlocks(A22_9_9_k3)