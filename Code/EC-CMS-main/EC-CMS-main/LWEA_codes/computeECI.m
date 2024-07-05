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

%bcs为对簇的编号处理后的各基聚类器的数据
%baseClsSegs为类簇矩阵（即CE矩阵）的转置，大小为nCls*N
function ECI = computeECI(bcs, baseClsSegs, para_theta)

M = size(bcs,2);%行数，即基聚类器的总数
ETs = getAllClsEntropy(bcs, baseClsSegs);%计算熵
ECI = exp(-ETs./para_theta./M);%按元素除，最终得到每个簇的ECI值



function Es = getAllClsEntropy(bcs, baseClsSegs)%计算所有簇的熵
% Get the entropy of each cluster w.r.t. the ensemble

baseClsSegs = baseClsSegs';%转置，大小为元素个数N*簇数量nCls
[~, nCls] = size(baseClsSegs);%获取总簇数nCls的值

Es = zeros(nCls,1);
for i = 1:nCls%遍历每一个簇
    %找出在这个簇的元素，在bcs中把这些元素的行选出来，可获得这些元素在其他基聚类器里的分类情况
    partBcs = bcs(baseClsSegs(:,i)~=0,:);%大小为 这个簇所含元素个数*基聚类器数量
    %计算这个簇的熵，放入Es中
    Es(i) = getOneClsEntropy(partBcs);
end



function E = getOneClsEntropy(partBcs)%计算一个簇的熵
% Get the entropy of one cluster w.r.t the ensemble

% The total entropy of a cluster is computed as the sum of its entropy
% w.r.t. all base clusterings.

E = 0;
for i = 1:size(partBcs,2)%基聚类器数量，每次循环计算这个簇相对于一个基聚类器的熵，再进行累加
    tmp = sort(partBcs(:,i));%选出partBcs的第i列，即选出这个簇的元素在第i个基聚类器里的分布情况
    uTmp = unique(tmp);%去重并进行排序
    
    if numel(uTmp) <= 1%如果这一列的元素全部都属于同一簇，那么熵计算为0
        continue;
    end
    % else
    cnts = zeros(size(uTmp));
    for j = 1:numel(uTmp)%在这个基聚类器中，这些元素被分为numel(uTmp)个簇中
        %这个簇的元素在当前基聚类器中元素分布（基聚类器中每个簇所含元素个数）
        cnts(j)=sum(sum(tmp==uTmp(j)));%这里是不是可以少用一个sum？ 生成当前簇与其他簇的相交元素个数
    end
    
    cnts = cnts./sum(cnts(:));%按元素除，得到p
    E = E-sum(cnts.*log2(cnts));%用累计的熵再减去该簇相对于当前基聚类器的熵
end
%得到这个簇相较于所有基聚类器的熵

