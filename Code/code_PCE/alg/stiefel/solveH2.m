function [ O,G ] = solveH2( H,v,A,lambda,CR )
%SOLVEYSTAR �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

B=bsxfun(@times,H-A,v);
O=sum(sum(B.^2))+lambda.*sum(sum(H.^2))-2.*lambda.*sum(sum(H.*CR));

G=bsxfun(@times,B,v);

G=2.*G+2.*lambda.*H-2.*lambda.*CR;


end

