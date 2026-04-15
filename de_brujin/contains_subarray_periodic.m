function [is_contained, position, is_reversed] = contains_subarray_periodic(main_array, sub_array)
% CONTAINS_SUBARRAY_PERIODIC 检查一个数组在周期性边界条件下是否包含另一个数组的正序或倒序。
%
% 语法:
%   [is_contained, position, is_reversed] = contains_subarray_periodic(main_array, sub_array)
%
% 输入参数:
%   main_array - 主数组 (N x 1 或 1 x N)
%   sub_array  - 子数组 (M x 1 或 1 x M)
%
% 输出参数:
%   is_contained - 逻辑值，如果包含则为 true，否则为 false。
%   position     - 如果包含，返回子数组匹配起始元素在 main_array 中的索引。
%                  如果未包含，则返回 0。
%   is_reversed  - 如果是倒序匹配，则为 true；如果是正序匹配，则为 false。
%                  如果未包含，则返回 false。
%
% 示例:
%   A = [10, 20, 30, 40, 50];
%   B_forward = [40, 50, 10];
%   [found, pos, rev] = contains_subarray_periodic(A, B_forward)
%   % 结果: found=true, pos=4, rev=false
%
%   B_reverse = [30, 20];
%   [found, pos, rev] = contains_subarray_periodic(A, B_reverse)
%   % 结果: found=true, pos=3, rev=true
%
%   B_no_match = [10, 30];
%   [found, pos, rev] = contains_subarray_periodic(A, B_no_match)
%   % 结果: found=false, pos=0, rev=false

    % 确保输入是行向量，方便后续操作
    main_array = main_array(:).'; % 转换为行向量
    sub_array = sub_array(:).';   % 转换为行向量

    N = length(main_array);
    M = length(sub_array);

    % 初始化输出
    is_contained = false;
    position = 0;
    is_reversed = false;

    % 检查子数组长度是否大于主数组长度 (周期性匹配中，子数组不能比主数组长)
    if M > N
        warning('子数组长度 (%d) 大于主数组长度 (%d)。在周期性边界条件下，不可能匹配。', M, N);
        return;
    end
    
    % 1. 构建周期性扩展的主数组
    % 扩展长度为 N + M - 1，以确保所有可能的周期性起始点都能匹配完整的子数组
    extended_main_array = [main_array, main_array(1:M-1)];

    % 2. 定义正序和倒序的子数组
    sub_array_forward = sub_array;
    sub_array_reverse = fliplr(sub_array); % 倒序

    % 3. 搜索正序匹配
    for k = 1:N % 遍历 main_array 的所有 N 个起始位置
        % 从扩展数组中取出长度为 M 的切片
        current_slice = extended_main_array(k : k + M - 1);

        % 检查正序匹配
        if isequal(current_slice, sub_array_forward)
            is_contained = true;
            position = k;
            is_reversed = false;
            return; % 找到第一个匹配即返回
        end
    end

    % 4. 搜索倒序匹配
    for k = 1:N % 遍历 main_array 的所有 N 个起始位置
        % 从扩展数组中取出长度为 M 的切片
        current_slice = extended_main_array(k : k + M - 1);

        % 检查倒序匹配
        if isequal(current_slice, sub_array_reverse)
            is_contained = true;
            position = k;
            is_reversed = true;
            return; % 找到第一个匹配即返回
        end
    end

end