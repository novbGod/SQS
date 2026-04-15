clear
%%文章示例尝试
A32=[0  0  0  0  0  1  0  1
    0  0  1  0  0  1  1  1
    0  0  1  1  0  1  1  0
    0  1  0  0  0  0  0  1
    1  1  1  1  1  0  1  0
    1  1  0  1  1  0  0  0
    1  1  0  0  1  0  0  1
    1  0  1  1  1  1  1  0];
% 

A22 = [0 0 1 0
      0 0 0 1
      0 1 1 1
      1 0 1 1];

A23_4_16 = [0 0 0 0 1 0 1 0 0 0 1 1 0 1 0 1
            0 0 0 1 1 0 1 1 0 0 1 1 1 1 1 0
            1 1 1 1 0 1 0 1 1 1 0 0 1 0 1 0
            1 1 1 0 0 1 0 0 1 1 0 0 0 0 0 1];

load("A44_256_256.mat");
check2(A44_256_256, 4, 4, 2);

% [a,b] = check(A23,2,3,2);

%%构造函数验证
%  A23 = constructType2([0 0 0 1; 1 1 1 0],[0,0,1,1], 3);
% % 
%  check(A23, 2, 3, 2);
% % 
% A33_4_128 = eleK_constructType1(A23, [0,0,1,1,1,0,1], 3, 2);
% 
% check(A22, 3, 3, 2);

%%三元构造函数验证
asym = [     3     2     3     2     3     3     1     3     3
             3     2     1     3     1     3     3     2     2
             3     1     2     2     1     1     2     2     3
             1     3     1     3     1     1     2     1     1
             1     3     2     1     2     1     1     3     3
             1     2     3     3     2     2     3     3     1
             2     1     2     1     2     2     3     2     2
             2     1     3     2     3     2     2     1     1
             2     3     1     1     3     3     1     1     2 ] - 1;
% 
% d1k3 = generate_debruijn_sequence(3,2) - '0';
% d1k3(end) = [];
% 
% A3 = eleK_constructType1(asym, d1k3, 2, 3);
% 
% check(A3, 3, 2, 3);
% 
a = [3     2     1     3     3     3     2     3     1
     2     2     3     1     3     1     3     2     3
     1     2     1     1     2     2     3     1     1
     3     2     2     2     2     3     3     3     1
     3     3     3     1     1     2     1     1     3
     2     3     3     2     3     1     1     2     2
     1     3     2     3     1     2     1     2     2
     1     3     2     3     1     1     3     3     2
     2     1     2     2     1     1     1     2     1] - 1;

%% 检测check2函数
% A = [0 1 0 0; 
%      0 1 1 1; 
%      1 1 1 0; 
%      0 0 1 0];
% 
% [isDB, cnt, info] = check2AnyShape(A11, 2, 3, 2, [1 1 1 1 1 0 ]);
% 
% if isDB
% 
%     fprintf(info);
% else
%     disp('非 de Bruijn 阵列。异常详细信息：');
%     disp(info);
% end


%%由(4,4;2,2)生成(8,8;3,2) 失败

% A22 = [A22(end,:);A22(1:end-1,:)];A22 = [A22(end,:);A22(1:end-1,:)];
% 
% A32 = constructType2(A22, [0, 1], 2);
% [isDB, cnt, info] = check2AnyShape(A32, 3, 2, 2, [1,1,1,1,1,1]);
% 
% if isDB
%     fprintf(info);
% else
%     disp('非 de Bruijn 阵列。异常详细信息：');
%     disp(info);
% end


%% 由(8,8;3,2)→(8,8;2,3)生成(8,64;3,3) 
d1k2n3 = generate_debruijn_sequence(2,3) - '0';
d1k2n3(end) = [];
A23 = A32';
A33_8_64 = constructType1(A23, d1k2n3, 3);
%check(A33_8_64, 3, 3, 2);
sumA33_8_64 = mod(sum(A33_8_64,1),2);

A33_64_8 = A33_8_64';
sumA33_64_8 = mod(sum(A33_64_8,1),2);

A43_64_64 = constructType1(A33_64_8, d1k2n3, 3);
check(A43_64_64, 4, 3, 2);
sumA43_64_64 = mod(sum(A43_64_64,1),2);

A34_64_64 = A43_64_64';
sumA34_64_64 = mod(sum(A34_64_64,1),2);

d1k2n4 = generate_debruijn_sequence(2,4) - '0';
d1k2n4(end) = [];
A44_64_1024 = constructType1(A34_64_64, d1k2n4, 4);
check(A44_64_1024, 4, 4, 2);
sumA44_64_1024 = mod(sum(A44_64_1024,1),2);

A43_8_512 = constructType1(A33_8_64, d1k2n3, 3);
check(A43_8_512, 4, 3, 2);
sumA43_8_512 = mod(sum(A43_8_512,1),2);

A34_512_8 = A43_8_512';
sumA34_512_8 = mod(sum(A34_512_8,1),2);

A44_512_128 = constructType1(A34_512_8, d1k2n4, 4);
check2(A44_512_128, 4, 4, 2);

