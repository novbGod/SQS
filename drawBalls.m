figure;
for o = 1:4
% 奇数位置是A原子数，偶数位置是B原子数，末尾有很多0
atomic_piles = arrayAll(o,:);

% --- 第1步：剔除末尾的零 ---
% 找到最后一个非零元素的位置
last_nonzero_index = find(atomic_piles ~= 0, 1, 'last');

% 截取有效数据
atomic_piles_trimmed = atomic_piles(1:last_nonzero_index);

% --- 第2步：将堆转换为单个原子的排列 ---
% 初始化一个空数组，用于存放最终的原子排列
atomic_arrangement = [];

% 遍历处理后的数组
for i = 1:length(atomic_piles_trimmed)
    % 获取当前堆的原子数
    num_atoms = atomic_piles_trimmed(i);
    
    % 根据位置的奇偶性来判断原子类型
    if mod(i, 2) == 1 % 如果是奇数位置（A原子堆）
        % 创建 num_atoms 个0，并追加到最终数组
        atomic_arrangement = [atomic_arrangement, zeros(1, num_atoms)];
    else % 如果是偶数位置（B原子堆）
        % 创建 num_atoms 个1，并追加到最终数组
        atomic_arrangement = [atomic_arrangement, ones(1, num_atoms)];
    end
end




array = atomic_arrangement;

% 数组的长度，即小球的数量
n = length(array);

% 创建x坐标，小球会沿着x轴排列
x = 1:n;

% 创建y坐标，所有小球都在同一行，所以y坐标都设为0
y = zeros(1, n)-o;

% 创建一个颜色数组，0为蓝色，1为红色
% MATLAB的颜色是用RGB值表示的
% 红色 [1, 0, 0]
% 蓝色 [0, 0, 1]
colors = zeros(n, 3);
for i = 1:n
    if array(i) == 0
        colors(i, :) = [0, 0, 1]; % 蓝色
    else
        colors(i, :) = [1, 0, 0]; % 红色
    end
end

% 绘制小球
% 'filled' 表示小球是实心的
% 'MarkerFaceColor' 表示小球的填充颜色
% 'SizeData' 控制小球的大小
hold on;
scatter(x, y, 200, colors, 'filled', 'MarkerEdgeColor', 'k');

% 设置图形标题和坐标轴标签
title('01数组小球表示');
xlabel('小球位置');
ylabel(''); % y轴为空，因为所有小球都在同一行

% 隐藏y轴，让图形更简洁
set(gca, 'YTick', []);
set(gca, 'XTick', []);
% 设置x轴的显示范围，使其更美观
xlim([0.5, n + 0.5]);
end