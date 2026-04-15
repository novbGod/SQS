clear;

% 寻找一个满足×形五体约束的晶格
% 填充物为A和B，各占一半。

    clc;
    disp('开始寻找满足条件的五体×形约束的晶体填充方案...');

    % 定义晶格大小
    row = 8;
    column = 4;
    total_positions = row*column;
    
    % 需要填充的A原子数量（B原子数量也相同）
    num_A = total_positions / 2;
    
    % 生成所有可能的填充方案
    % 这将生成一个矩阵，每一行代表一种填充方案
    % 1代表A，0代表B
    disp('正在生成所有可能的填充方案...');
    all_arrangements = nchoosek(1:total_positions, num_A);
    disp(['共有 ' num2str(size(all_arrangements, 1)) ' 种填充方案需要检查。']);
    figure;
    num = 0;%可行矩阵的数量
    % 遍历每一种填充方案
    for k = 1:size(all_arrangements, 1)
        
        % 将当前方案转化为4x4矩阵
        arrangement = zeros(row, column);
        arrangement(all_arrangements(k, :)) = 1;
        
        % 提取所有2x2小正方形，并检查其唯一性
        is_unique = checkSubsquares(arrangement);
        
        % 如果找到满足条件的方案，则显示并结束程序
        if is_unique
            disp(' ');
            disp('--------------------------------------');
            disp('  (1代表A，0代表B)');
            num = num + 1;
            % 将0和1替换成'B'和'A'以方便查看
            solution_matrix = zeros(N, N);
            for i = 1:N
                for j = 1:N
                    if arrangement(i, j) == 1
                        solution_matrix(i, j) = 0;
                    else
                        solution_matrix(i, j) = 1;
                    end
                end
            end
            disp(solution_matrix);
            subplot(6, 6, num);  % 自适应子图布局
    imshow(solution_matrix);
    title(['Matrix ', num2str(k)]);
            
            % 显示数字编码的子矩阵
            disp('其所有2x2子矩阵的编码为：');
            subsquare_codes = body5Determine(arrangement);
            disp(reshape(subsquare_codes, N, N));
            
            %return;
        end
    end
    
    % 如果遍历所有方案后仍未找到
    disp(' ');
    disp('未找到满足条件的填充方案。');


