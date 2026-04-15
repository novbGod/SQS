
function result = groupSubarrayBoundaries(inputArray)
%GROUPSUBARRAYBOUNDARIES_CELL 统计0/1数组中最大全0和全1子组的边界位置并按长度归类，使用 Cell 数组存储结果。
%
%   INPUT:
%       inputArray - 一个1xN或Nx1的0/1数组。
%
%   OUTPUT:
%       result - 一个 Cell 数组，包含两个 Cell 数组字段：
%                result{1} - 存储全0子组的结果。
%                result{2} - 存储全1子组的结果。
%
%                每个子 Cell 数组 (例如 result{1}) 的索引 k 对应子组的长度 k。
%                result{1}{k} 是一个 Nx2 的矩阵，每行 [start_index, end_index]，
%                存储长度为 k 的所有全0子组的边界。

    if isempty(inputArray)
        result = cell(1, 2); % 初始化为包含两个空 cell 的 cell 数组
        return;
    end

    inputArray = inputArray(:)';
    N = length(inputArray);
    
    % 初始化结果 Cell 数组：
    % result{1} 存储 0 组， result{2} 存储 1 组
    % 预估最大长度 N，创建大小为 N 的 cell 数组来存储不同长度 k 的数据
    result = cell(1, 2); 
    result{1} = cell(1, log2(N)); % 0 组 cell
    result{2} = cell(1, log2(N)); % 1 组 cell

    % --- 1. 寻找 0 子组的边界 ---
    nonZeroIdx = [0, find(inputArray ~= 0), N + 1];
    
    for i = 1:length(nonZeroIdx) - 1
        startIdx = nonZeroIdx(i) + 1;
        endIdx = nonZeroIdx(i+1) - 1;
        
        if startIdx <= endIdx % 存在一个全0子组
            len = endIdx - startIdx + 1;
            boundary = [startIdx, endIdx];
            
            % 将边界存入 result{1}{len}
            if isempty(result{1}{len})
                result{1}{len} = boundary;
            else
                result{1}{len} = [result{1}{len}; boundary];
            end
        end
    end

    % --- 2. 寻找 1 子组的边界 ---
    nonOneIdx = [0, find(inputArray ~= 1), N + 1];

    for i = 1:length(nonOneIdx) - 1
        startIdx = nonOneIdx(i) + 1;
        endIdx = nonOneIdx(i+1) - 1;

        if startIdx <= endIdx % 存在一个全1子组
            len = endIdx - startIdx + 1;
            boundary = [startIdx, endIdx];
            
            % 将边界存入 result{2}{len}
            if isempty(result{2}{len})
                result{2}{len} = boundary;
            else
                result{2}{len} = [result{2}{len}; boundary];
            end
        end
    end
end