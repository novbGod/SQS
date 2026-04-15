T = [0 1; -1 0];
[V, D] = eig(T);

disp('Eigenvalues:');
disp(diag(D));
disp('Eigenvectors:');
disp(V);
