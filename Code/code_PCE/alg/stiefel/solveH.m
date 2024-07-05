function [ O,G ] = solveH( H,v,A )
%SOLVEYSTAR 此处显示有关此函数的摘要
%   此处显示详细说明

B=bsxfun(@times,H-A,v);
O=sum(sum(B.^2));

G=bsxfun(@times,B,v);
G=2.*G;


end

