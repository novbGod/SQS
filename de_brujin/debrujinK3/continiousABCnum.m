for n = 2:10
    seq = generate_debruijn_sequence(3,n)-'0';
    bPos = find(seq == 1);
    cPos = find(seq == 2);
    seq = [seq(max([bPos(end),cPos(end)])+1:end),seq(1:max([bPos(end),cPos(end)]))];
    aPos = find(seq == 0);
    bPos = find(seq == 1);
    cPos = find(seq == 2);
    
    a = ballsToPile(seq(aPos(1):end) == 0);
    b = ballsToPile(seq(bPos(1):end) == 1);
    c = ballsToPile(seq(cPos(1):end) == 2);

    [count0,ele0] = count_element_frequency(a(1:2:end));
    [count1,ele1] = count_element_frequency(b(1:2:end));
    [count2,ele2] = count_element_frequency(c(1:2:end));

    num0(n,ele0) = count0;
    num1(n,ele1) = count1;
    num2(n,ele2) = count2;
end


function [element_counts, unique_elements] = count_element_frequency(A)
%COUNT_ELEMENT_FREQUENCY 计算大型数组中每个元素的出现次数
%
% 输入:
%   A - 一个数值型数组（可以是单精度、双精度、整数等）。
%       数组可以是行向量、列向量或多维数组。
%
% 输出:
%   element_counts - 一个列向量，包含unique_elements中对应元素的出现次数。
%   unique_elements - 一个列向量，包含数组A中所有独特的元素。
%
% 示例:
%   A = [1 2 2 3 1 5 1 5 3 2 9];
%   [counts, elements] = count_element_frequency(A);
%   % elements 将是 [1; 2; 3; 5; 9]
%   % counts 将是 [3; 3; 2; 2; 1]
%

% 1. 扁平化数组并找出独特的元素及其索引
% 'rows' 选项对多维数组的每一行进行操作，但对于大型一维数组，
% 默认的 'sorted' 行为更高效。对于大型一维数组，`unique` 
% 提供了独特元素列表和它们在原数组中的位置。

% 将 A 转换为列向量，以便处理任何形状的输入
A = A(:);

% U: 独特的元素 (Unique elements)
% ~, J: J 是一个索引向量，表示 A 中每个元素在 U 中的位置
[U, ~, J] = unique(A, 'stable'); 

% 'stable' 选项保持了元素在原数组中首次出现的顺序，
% 这使得输出 `unique_elements` 的顺序是按首次出现确定的。
% 如果需要按数值大小排序，可以去掉 'stable' 选项。

% 2. 使用 accumarray 统计频率
% J 中的每个值都是 U 的一个索引。
% accumarray 将 J 中相同索引位置的元素 '累加' 起来。
% 这里的 'vals' 是一个和 A 大小相同的全 1 向量，代表每次出现一次。
% function handle @sum 是累加操作。

% 优点：对于大型数组，`accumarray` 比使用循环或 `histcounts` 更快。
counts = accumarray(J, 1, [], @sum);

% 3. 组织输出
unique_elements = U;
element_counts = counts;

end