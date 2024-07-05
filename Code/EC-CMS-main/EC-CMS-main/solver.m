function [C,E,t] = solver(H,A,lambda)%HC矩阵，LWCA矩阵，希望生成的簇数，权衡参数lambda
n = size(A,1);%object的数目
t = 0;%循环计数器
e = 1e-2;%阈值，循环终止的条件
max_iter = 100;%防止无限递归
I = eye(n);%创建单位矩阵
C = zeros(n);%C为理想的CA矩阵
E = C;%矩阵的误差项
F = C;
r1 = 1;
r2 = 1;%ADMM的参数设置为1，即文中的伽马1和伽马2
Y1 = A;
Y2 = C;
D = H * ones(n,1);
phi = diag(D) - H;%Φ矩阵,Φ=D-H
inv_part = (2 * phi + (r1 + r2) * I) \ I;

while t < max_iter
    t = t + 1;
    
    % update C
    Ct = C;
    P1 = A - E + Y1 / r1;
    P2 = F - Y2 / r2;
    C = inv_part * (r1 * P1 + r2 * P2);
    
    % update E
    Et = E;
    E = r1 * (A - C) + Y1;
    E = E /(lambda + r1);
    E(H > 0) = 0;
    
    % update F
    Ft = F;
    F = C + Y2 / r2;
    F = min(max((F + F') / 2,0),1);
    
    % update Y
    Y1t = Y1;
    residual1 = A - C - E;
    Y1 = Y1t + r1 * residual1;
    
    Y2t = Y2;
    residual2 = C - F;
    Y2 = Y2t + r2 * residual2;
    
    diffC = abs(norm(C - Ct,'fro')/norm(Ct,'fro'));%计算Frobenius范数
    diffE = abs(norm(E - Et,'fro')/norm(Et,'fro'));
    diffF = abs(norm(F - Ft,'fro')/norm(Ft,'fro'));
    diffY1 = abs(norm(residual1,'fro')/norm(Y1t,'fro'));
    diffY2 = abs(norm(residual2,'fro')/norm(Y2t,'fro'));
    
    if max([diffC,diffE,diffF,diffY1,diffY2]) < e %判断终止条件
        break;
    end
end