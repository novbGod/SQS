A1 =[0 1 0 0;
    0 1 1 1;
    1 1 1 0;
    0 0 1 0];

A2 =[0 1 0 0;
    0 1 1 1;
    1 1 1 0;
    0 0 1 0];

A1 = to; A2 = to;

alternateTwo(A1,A2)

function A = alternateTwo(A1, A2)
row = size(A1,1);
col = size(A1,2);
k = length(unique(A1));
for rot = 1:3
    A2_rot = rot90(A2,rot);
    for i = 1:row
        for j = 1:col
            A2temp = circshift(A2_rot,[i,j]);
            A = zeros(size(A1,1)*2, size(A1,2));
            A(1:2:end,:) = A1;
            A(2:2:end,:) = A2temp;
            disp(A);

            [isDeBruijn, repeatCount, report] = check2AnyShape(A, 3, 2, k, [1,1,1,1,0,1]);
            if isDeBruijn
                disp(A);
                return;
            end
        end
    end
end

fprintf('failed');
A = [];
end