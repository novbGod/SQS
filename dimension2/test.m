matrix = [1:8;9:16;17:24;25:32;33:40;41:48;49:56;57:64];
row = 8;column = 8;
i = 8;j=8;
            t = matrix(i, j)
            tl = matrix(mod(i, row) + 1, j)
            tr = matrix(mod(i, row) + 1, mod(j, column) + 1)
            r = matrix(mod(i, row) + 1, mod(j+1, column) + 1)
            l = matrix(mod(i+1, row) + 1, mod(j-2,column) + 1)
            bl = matrix(mod(i+1, row) + 1, j)
            br = matrix(mod(i+1, row) + 1, mod(j, column) + 1)
            b = matrix(mod(i+2, row) + 1, mod(j, column) + 1)