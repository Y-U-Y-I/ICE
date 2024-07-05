function [EigenvectorsDiscrete,R]=mydiscretisation(EigenVectors,flag)
% 将连续的特征向量（EigenVectors）离散化，并返回离散化后的特征向量（EigenvectorsDiscrete）
%
% EigenvectorsDiscrete=discretisation(EigenVectors)
% 
% Input: EigenVectors = 连续的Ncut特征向量continuous Ncut vector, size = ndata x nbEigenvectors 
% Output EigenvectorsDiscrete = 离散化的Ncut特征向量discrete Ncut vector, size = ndata x nbEigenvectors
% 返回值分别为最终聚类结果Y和正交旋转矩阵R

% 获取特征向量的大小,n个instance,k个cluster
[n,k]=size(EigenVectors);

%如果 flag 为1，进行将行元素归一化处理，使得每行元素的平方和都为1（为什么要这样做，不是要让列正交吗）
if flag==1
    vm = max(sqrt(sum(EigenVectors.*EigenVectors,2)),eps);
    %eps是一个很小的正数，通常表示为计算机可以表示的最小非零浮点数。它被用作一个阈值，以避免在计算过程中出现除以零的情况。
    EigenVectors = EigenVectors./repmat(vm,1,k);
    try1=EigenVectors'*EigenVectors;
    try2=EigenVectors*EigenVectors';
end

R=zeros(k);%k*k矩阵
%初始化R的第一列为从EigenVectors中随机选择的一行
R(:,1)=EigenVectors(1+round(rand(1)*(n-1)),:)';
c=zeros(n,1);
for j=2:k
    % 计算每个样本与离散化后特征向量乘积（即与上一次计算的R的一列相乘）的绝对值之和
    c=c+abs(EigenVectors*R(:,j-1));
    % 找到 c 中的最小值及其对应的索引 i，将 EigenVectors 中第 i 行的特征向量作为 R 的第 j 列
    [minimum,i]=min(c);
    R(:,j)=EigenVectors(i,:)';%将EigenVectors的该行赋值给R的该列
end

%IterationsDiscretisation迭代离散化
lastObjectiveValue=0;
exitLoop=0;%标识是否循环完成
nbIterationsDiscretisation = 0;%当前迭代次数
nbIterationsDiscretisationMax = 20;%voir % 最大迭代次数

while exitLoop== 0 
    nbIterationsDiscretisation = nbIterationsDiscretisation + 1 ;   
    % 离散化特征向量数据
    EigenvectorsDiscrete = discretisationEigenVectorData(EigenVectors*R);
    % 对离散化特征向量和原始特征向量进行奇异值分解（SVD）计算
    [U,S,V] = svd(EigenvectorsDiscrete'*EigenVectors,0);    
    % 计算 Ncut 值
    NcutValue=2*(n-trace(S));
    
    % 检查 Ncut 值与上一次迭代的目标函数值之间的差异是否小于阈值 eps，
    % 或者当前迭代次数是否超过最大迭代次数
    if abs(NcutValue-lastObjectiveValue) < eps | nbIterationsDiscretisation > nbIterationsDiscretisationMax
        exitLoop=1;%结束迭代
    else
        lastObjectiveValue = NcutValue;
        % 更新 R
        R=V*U';
    end
end