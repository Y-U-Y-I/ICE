function [ O,G ] = solveH( H,v,A )
%SOLVEYSTAR �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

B=bsxfun(@times,H-A,v);
O=sum(sum(B.^2));

G=bsxfun(@times,B,v);
G=2.*G;


end

