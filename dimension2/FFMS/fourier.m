% % 1. 准备实空间矩阵 (假设为 N x N)
% N = 512; 
% % 创建一个示例矩阵：这里我们模拟一个带有某种周期性扰动的随机阵列
% % 你可以直接替换为你自己的 01 矩阵
% real_space = rand(N) > 0.8; % 基础随机分布
% [X, Y] = meshgrid(1:N, 1:N);
% % 人为加入一些周期性调制（模拟结构特征）
% real_space = real_space .* (sin(2*pi*X/10) > 0); \

real_space = A44_64_1024;

% 2. 计算倒空间 (二维傅里叶变换)
% 使用 fft2 进行变换
F = fft2(real_space);

% 使用 fftshift 将零频分量（倒格点原点）移到频谱中心
F_shifted = fftshift(F);

% 计算强度强度 (Intensity) |S(k)|^2
% 通常取对数以观察较弱的特征峰
intensity = abs(F_shifted).^2;

% 3. 可视化
figure('Color', 'w', 'Position', [100, 100, 1000, 400]);

subplot(1,2,1);
imagesc(real_space);
colormap(gray);
axis image;
title('实空间原子排布 (Real Space)');
xlabel('x'); ylabel('y');

subplot(1,2,2);
% 使用 log10 增强弱峰的可视化效果
imagesc(log10(intensity + 1)); 
axis image;
colorbar;
title('倒空间强度分布 (Reciprocal Space - Log Scale)');
xlabel('k_x'); ylabel('k_y');

% 调整配色方案，物理上通常用类似 'hot' 或 'jet'
colormap(gca, 'hot');