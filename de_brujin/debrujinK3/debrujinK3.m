nmax = 10;
tic
for i = 2:nmax
    k3{i-1} = generate_debruijn_sequence(3, i)
    for j = 1:i
        [is,appearTimes(i,j)] = is_debruijn_property(k3{i-1},j);
    end
end
% B_3_3 长度为 3^3 = 27。
toc

