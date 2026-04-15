function [panDuan,cArray] = symmetry01(array)
%输入一个01数组，在周期性边界条件下，判断此数组在将01互换之后，
% 是否能经平移、水平翻转操作后与原数组等效

    a01 = array;
    a10 = abs(a01 - 1);
    n = round(log(length(array))/log(2)-1);
    if are_rings_equivalent(a01,a10) == 1
        center = sum(find(array == n))/2;
        L = length(array);
        temp = [array,array,array];
        cArray = [temp(L/2+ceil(center):L+ceil(center)-1),temp(L+ceil(center):L+ceil(center)+L/2-1)];
        panDuan = 1;
    else
        panDuan = 0;
        cArray = [];
    end
end

