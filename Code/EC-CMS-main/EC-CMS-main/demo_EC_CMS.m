% Ensemble Clustering via Co-association Matrix Self-enhancement
% This framework is based on the source code of
% TCYB--Locally Weighted Ensemble Clustering

clear;clc
dataName = 'FCT'; % You can switch to other datasets 选择数据集
M = 20; % Ensemble size 每次运行选取20个基聚类器进行集成
cntTimes = 1; % How many times will be run. 运行次数
alpha = 0.75;% 设置超参数 alpha
lambda = 0.01;% 设置超参数 lambda

rng(1)%控制随机数生成器
addpath(genpath(pwd))%结合使用genpath和addpath将文件夹及其子文件夹添加到搜索路径。

para_theta = 0.4; % Parameter of LWEA

load([dataName,'.mat'],'members','gt');%载入数据集 gt为实际上正确的聚类（？）
clsNums = length(unique(gt));%unique得到gt原数据但是进行了去重和排序，length返回其最大数组维度的长度（簇的个数）
[N, poolSize] = size(members);%N为members的行数, poolSize为members的列数

% For each run, M base clusterings will be randomly drawn from the pool.
% Each row in bcIdx corresponds to an ensemble of M base clusterings.
%（生成随机数，用于每次运行时选取基聚类器）
bcIdx = zeros(cntTimes, M);%cntTimes行M列的矩阵
for i = 1:cntTimes%给bcIdx的一行赋值为从1-poolSize的随机排列
    tmp = randperm(poolSize);%从1-poolSize的随机排列
    bcIdx(i,:) = tmp(1:M);%给bcIdx的一行赋值，选取前M个元素
end

% Scores 评价指标
NMI_LWEA = zeros(cntTimes, 1);%创建全零数组,大小20*1
NMI = NMI_LWEA; % NMI of our model 评价指标-NMI
ARI_LWEA = NMI_LWEA;%创建全零数组
ARI = NMI_LWEA; % ARI of our model 评价指标-ARI
F_LWEA = NMI_LWEA;%创建全零数组
F = NMI_LWEA; % F-score of our model 评价指标-F

for runIdx = 1:cntTimes %运行次数  runIdx表示当前执行到第几次
    % Construct the ensemble of M base clusterings
    % baseCls is an N x M matrix, each row being a base clustering.
    baseCls = members(:,bcIdx(runIdx,:));%使用生成的随机数，效果为选取members的M=20列（列号在1-100之间随机生成）
    
    %执行LWCA代码
    % Get all clusters in the ensemble
    [bcs, baseClsSegs] = getAllSegs(baseCls);%将选取的基聚类器进行输入
    %bcs为对簇的编号处理后的各基聚类器的数据
    %baseClsSegs为类簇矩阵（即CE矩阵）的转置，大小为nCls*N（若第i簇中有第j个object，则CE(i,j)=1）
    
    % Compute ECI for LWEA 得到每个簇的ECI值
    ECI = computeECI(bcs, baseClsSegs, para_theta);
    % Compute LWCA 计算LWCA
    LWCA = computeLWCA(baseClsSegs, ECI, M);%M为基聚类器数量（集成规模）
    
    % Perform LWEA 执行LWEA
    resultsLWEA = runLWEA(LWCA, clsNums);%clsNums为希望最终生成的簇的个数
    %LWCA代码执行结束并评价
    NMI_LWEA(runIdx) = compute_nmi(resultsLWEA,gt);%评价指标-NMI
    ARI_LWEA(runIdx) = RandIndex(resultsLWEA,gt);%评价指标-ARI
    F_LWEA(runIdx) = compute_f(resultsLWEA,gt);%评价指标-ARI
    
    
    %执行CA矩阵自增强代码
    % Perform our model
    CA = getCA(baseClsSegs, M);%传统CA矩阵
    A = getHC(CA,alpha);%构建HC矩阵
    results = run_EC_CMS(A,LWCA,clsNums,lambda);%运行优化算法
    if min(results) == 0
        results = results + 1;
    end
    %CA矩阵自增强代码结束并评价
    NMI(runIdx) = compute_nmi(results,gt);%评价指标-NMI
    ARI(runIdx) = RandIndex(results,gt);%评价指标-ARI
    F(runIdx) = compute_f(results,gt);%评价指标-F
end

%计算运算的效果并与LWCA进行对比
nmi=mean(NMI);%数组的均值
varnmi=std(NMI);%标准差
nmiLWEA=mean(NMI_LWEA);%LWEA方法的数组的均值
varnmiLWEA=std(NMI_LWEA);%LWEA方法的标准差

ari=mean(ARI);
varari=std(ARI);
ariLWEA=mean(ARI_LWEA);
varariLWEA=std(ARI_LWEA);

f=mean(F);
varf=std(F);
fLWEA=mean(F_LWEA);
varfLWEA=std(F_LWEA);

% save(['results_',dataName,'.mat']); 保存数据结果
disp('**************************************************************');
disp(['** Average Performance over ',num2str(cntTimes),' runs on the ',dataName,' dataset **']);
disp(['Data size: ', num2str(N)]);
disp(['Ensemble size: ', num2str(M)]);
disp('Average NMI/ARI/F scores:');
disp(['EC_CMS : ',num2str(nmi),'  ',num2str(ari),...
    '  ',num2str(f)]);
disp(['LWEA   : ',num2str(nmiLWEA),'  ',num2str(ariLWEA),...
    '  ',num2str(fLWEA)]);
disp('**************************************************************');
disp('**************************************************************');