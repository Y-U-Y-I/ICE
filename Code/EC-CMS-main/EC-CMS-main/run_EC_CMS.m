function results = run_EC_CMS(A,B,k,lambda)%HC矩阵，LWCA矩阵，希望生成的簇数，权衡参数lambda

N = size(B,1);%object数目
n = numel(k);%=1？
results = zeros(N,n);%记录聚类集成结果
A = A - diag(diag(A));%对角元素置为0

[C,~,~] = solver(A,B,lambda);

for i = 1:n
    K = k(i);
    
    %squareform函数 将原始矩阵转换为一维向量或方阵
    s = squareform(C - diag(diag(C)),'tovector');
    d = 1 - s;
    %linkage函数执行层次聚类，生成聚集层次聚类树，但并未指定最终的聚类数
    %cluster函数结合 maxclust 参数来指定最终的聚类数K，从聚类树中选择最佳的聚类划分，将数据集分配到K个聚类中
    results(:,i) = cluster(linkage(d,'average'),'maxclust',K);
    
    disp(['Obtain ',num2str(K),' clusters.']);
end