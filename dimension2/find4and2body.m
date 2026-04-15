for o = 1:length(b1)
b = b1{o};
b(:,[1,3,5,7]) = b(:,1:4);
b(:,[2,4,6,8]) = zeros(8,4);
[b(2:2:8,1:2:7),b(2:2:8,2:2:8)] = deal(b(2:2:8,2:2:8),b(2:2:8,1:2:7));
crossMatrix{o} = b;
end

body2 = [];
body4 = {};
for i = 1:length(b1)
    jingbao = crossMatrix{i};
    body4{i,1} = sprintf('%d ', cross4bodyCount(jingbao));
    for j = 1:11
        temp = cross2bodyCount(jingbao,j);
        body2(j,4*i-3:4*i-1) = temp; 
        % if temp(1) ~= temp(3)/2
        %     break;
        % end
    end
end