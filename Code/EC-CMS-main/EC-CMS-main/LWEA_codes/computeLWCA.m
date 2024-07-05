%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                   %
% This is a demo for the LWEA and LWGP algorithms. If you find this %
% code useful for your research, please cite the paper below.       %
%                                                                   %
% Dong Huang, Chang-Dong Wang, and Jian-Huang Lai.                  %
% "Locally weighted ensemble clustering."                           %
% IEEE Transactions on Cybernetics, 2018, 48(5), pp.1460-1473.      %
%                                                                   %
% The code has been tested in Matlab R2014a and Matlab R2015a on a  %
% workstation with Windows Server 2008 R2 64-bit.                   %
%                                                                   %
% https://www.researchgate.net/publication/316681928                %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%baseClsSegs为类簇矩阵（即CE矩阵）的转置
%ECI含有每个基聚类器的ECI值，大小nCls*1
%M为基聚类器数量（集成规模）
function LWCA=computeLWCA(baseClsSegs,ECI,M)
% Get locally weighted co-association matrix

baseClsSegs = baseClsSegs';%转置，CE矩阵，大小为元素个数N*簇数量nCls
N = size(baseClsSegs,1);%簇的总数

% LWCA = (baseClsSegs.*repmat(ECI',N,1)) * baseClsSegs' / M;
LWCA = (bsxfun(@times, baseClsSegs, ECI')) * baseClsSegs' / M;%按元素乘

LWCA = LWCA-diag(diag(LWCA))+eye(N);%diag(diag(LWCA))先返回对角元素的列向量再构造对角矩阵
%实际上是把对角元素全部置为1