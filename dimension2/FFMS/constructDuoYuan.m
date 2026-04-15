clear;
asym = [     3     2     3     2     3     3     1     3     3
             3     2     1     3     1     3     3     2     2
             3     1     2     2     1     1     2     2     3
             1     3     1     3     1     1     2     1     1
             1     3     2     1     2     1     1     3     3
             1     2     3     3     2     2     3     3     1
             2     1     2     1     2     2     3     2     2
             2     1     3     2     3     2     2     1     1
             2     3     1     1     3     3     1     1     2 ] - 1;

d1k3n2 = generate_debruijn_sequence(3,2) - '0';
d1k3n2(end) = [];
d1k3n3 = generate_debruijn_sequence(3,3) - '0';
d1k3n3(end) = [];

A3 = eleK_constructType1(asym, d1k3n2, 2, 3);
sum1 = mod(sum(A3,1),3);
check2(A3, 3, 2, 3);

A4 = eleK_constructType1(A3, d1k3n3, 3, 3);
check2(A4, 4, 2, 3)

a = [3     2     1     3     3     3     2     3     1
     2     2     3     1     3     1     3     2     3
     1     2     1     1     2     2     3     1     1
     3     2     2     2     2     3     3     3     1
     3     3     3     1     1     2     1     1     3
     2     3     3     2     3     1     1     2     2
     1     3     2     3     1     2     1     2     2
     1     3     2     3     1     1     3     3     2
     2     1     2     2     1     1     1     2     1] - 1;