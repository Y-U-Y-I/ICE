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

function [bcs, baseClsSegs] = getAllSegs(baseCls)
%baseCls为此次集成选取的基聚类器
[N,M] = size(baseCls);
% N:    the number of data points.数据点的数量=3780
% M:    the number of base clusterings.基聚类器数=20
% nCls: the number of clusters (in all base clusterings).总簇数（所选基聚类器里的簇数之和）

bcs = baseCls;%大小N*M
nClsOrig = max(bcs,[],1);%返回每一列（即每一个基聚类）的最大值的行向量，每个基聚类器里面有多少簇
C = cumsum(nClsOrig);%累积和，仍为行向量，对簇的数目进行累加
bcs = bsxfun(@plus, bcs,[0 C(1:end-1)]);%大小N*M
%对两个数组应用按元素运算，使得每个基聚类器中的簇都加上对应的数字，因此使得每个簇的编号都不相同
nCls = nClsOrig(end)+C(end-1);%所有的基聚类器中的总簇数
baseClsSegs=sparse(bcs(:),repmat((1:N)',1,M), 1,nCls,N);
%repmat重复数组副本 生成一个N*M的矩阵，每一列元素都是从1~N
%sparse创建稀疏矩阵，对应元素组合为坐标，赋值为1，矩阵大小为nCls*N=641*3780
%bcs(:)和repmat([1:N]',1,M)均为N*M的矩阵
%前者取值范围1~nCls
%后者取值范围1~N
