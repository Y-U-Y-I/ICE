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

function resultsLWEA = runLWEA(S, ks)%S为LWCA矩阵,ks为希望最终生成的簇的个数
% Input: the co-association matrix
%        and the numbers of clusters.
% Output: clustering results by LWEA-AL（平均链路）.

N = size(S,1);%元素数量

d = stod2(S); %convert similarity matrix to distance vector 将相似性矩阵转换为距离向量
% average linkage 聚集层次聚类树
Zal = linkage(d,'average'); clear d

resultsLWEA = zeros(N, numel(ks));%大小为N*1 ？？？感觉不需要用循环
% disp('.');
 for i = 1:numel(ks)
     K = ks(i);
    disp(['Obtain ',num2str(K),' clusters by LWEA.']); 
    % tic;
    resultsLWEA(:,i) = cluster(Zal,'maxclust',K);
    % toc;
 end
% disp('.');
 
function d = stod2(S)
%==========================================================================
% FUNCTION: d = stod(S)
% DESCRIPTION: This function converts similarity values to distance values
%              and change matrix's format from square to vector (input
%              format for linkage function)
%              此函数将相似度值转换为距离值，并将矩阵的格式从方阵更改为向量（linkage function的输入格式）
%
% INPUTS:   S = N-by-N similarity matrix
%
% OUTPUT:   d = a distance vector
%==========================================================================
% copyright (c) 2010 Iam-on & Garrett
%==========================================================================

N = size(S,1);%元素个数
s = zeros(1,N*(N-1)/2);%距离向量
nextIdx = 1;
for a = 1:N-1 %change matrix's format to be input of linkage fn
    s(nextIdx:nextIdx+(N-a-1)) = S(a,a+1:end);
    nextIdx = nextIdx + N - a;
end
d = 1 - s; %compute distance (d = 1-sim) 将相似性属性转换为距离向量（可以理解为全1矩阵-CA矩阵=距离矩阵）