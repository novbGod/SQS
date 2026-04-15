%将A、B数组交错排放，A、B长度必须相同
function AB = combineAB(A,B)
L = length(A);
AB = zeros(1,2*L);
AB(1:2:end) = A;
AB(2:2:end) = B;
end
