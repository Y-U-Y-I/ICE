function [ O,G ] = solveH2( H,v,A,lambda,CR )
%SOLVEYSTAR 此处显示有关此函数的摘要
%   此处显示详细说明

B=bsxfun(@times,H-A,v);
O=sum(sum(B.^2))+lambda.*sum(sum(H.^2))-2.*lambda.*sum(sum(H.*CR));

G=bsxfun(@times,B,v);

G=2.*G+2.*lambda.*H-2.*lambda.*CR;


end

