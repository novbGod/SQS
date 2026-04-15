function is_unique = body5Determine(matrix)
% 检查一个矩阵的所有×形五体是否唯一

    % 提取所有小正方形并将其编码
    subsquare_codes = cross5bodyCount(matrix);
    
    % 检查编码是否唯一
    is_unique = (length(unique(subsquare_codes)) == 32);
end



