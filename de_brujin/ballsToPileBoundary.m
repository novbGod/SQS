%输入一个个小球排列的01数组，将其归类为堆，然后输出每个堆最后一个小球的索引，并按堆的大小分类
function boundary_points = ballsToPileBoundary(arr)
% 找到相邻元素不同的位置
% diff(arr) 会生成一个新数组，如果相邻元素相等，差值为 0；不相等，差值为 1 或 -1
diff_arr = diff(arr);

% 使用 find 函数找出所有不为 0 的位置
% 相当于找到了所有分界线
transition_points = find(diff_arr ~= 0);

% 在找到的分界点前后加上数组的起始和结束位置
% 这样可以完整地表示所有区间
boundary_points = [0, transition_points, length(arr)];

end

