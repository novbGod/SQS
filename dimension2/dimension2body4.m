clear;

% 寻找一个4x4晶胞的填充方案，使得所有相邻2x2小正方形的组合互不相同。
% 填充物为A和B，各占一半。

    clc;
    disp('开始寻找满足条件的4x4晶体填充方案...');

    % 定义晶格大小
    N = 4;
    total_positions = N * N;
    
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
        arrangement = zeros(N, N);
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
            subsquare_codes = getSubsquareCodes(arrangement);
            disp(reshape(subsquare_codes, N, N));
            
            %return;
        end
    end
    
    % 如果遍历所有方案后仍未找到
    disp(' ');
    disp('未找到满足条件的填充方案。');


function is_unique = checkSubsquares(matrix)
% 检查一个4x4矩阵的所有2x2小正方形是否唯一

    % 提取所有小正方形并将其编码
    subsquare_codes = getSubsquareCodes(matrix);
    
    % 检查编码是否唯一
    is_unique = (length(unique(subsquare_codes)) == 16);
end

function subsquare_codes = getSubsquareCodes(matrix)
% 提取4x4矩阵的所有2x2小正方形并将其编码为唯一的整数
    N = 4;
    subsquare_codes = zeros(1, N*N);
    count = 1;
    
    for i = 1:N
        for j = 1:N
            % 考虑周期性边界条件
            % top_left, top_right, bottom_left, bottom_right
            tl = matrix(i, j);
            tr = matrix(i, mod(j, N) + 1);
            bl = matrix(mod(i, N) + 1, j);
            br = matrix(mod(i, N) + 1, mod(j, N) + 1);
            
            % 将2x2子矩阵编码为4位二进制数
            % 例如：[A B; C D] -> ABCD (二进制)
            subsquare_codes(count) = tl*8 + tr*4 + bl*2 + br;
            
            count = count + 1;
        end
    end
end