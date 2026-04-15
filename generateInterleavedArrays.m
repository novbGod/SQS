% 生成所有两两交错拼接数组（含相位偏移）
function result = generateInterleavedArrays(C)
% 输入：
%   C - 元胞数组，每个元素为长度为i的数组
% 输出：
%   result - 元胞数组，包含所有生成的拼接数组
    % 预处理：确保所有数组为行向量
    n = numel(C);
    for m = 1:n
        if iscolumn(C{m})
            C{m} = C{m}.'; % 列向量转置为行向量
        end
    end
    i = numel(C{1}); % 所有数组长度相同
    
    % 初始化结果元胞
    idx = 1; % 结果索引
   result = cell(n*(n+1)/2 * i, 1);
    % 遍历所有数组对（包括自己与自己）
    for a_idx = 1:n
        a = C{a_idx};
        for b_idx = a_idx:n
            b = C{b_idx};
            % 生成所有相位偏移（循环右移 0 到 i-1 位）
            for k = 0:i-1
                % 循环右移k位
                b_shifted = circshift(b, k, 2);
                % 交错拼接
                interleaved = reshape([a; b_shifted], 1, []);
                % 存储结果
                result{idx} = interleaved;
                idx = idx + 1;
            end
        end
    end
end
