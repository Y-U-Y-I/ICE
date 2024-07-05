clear

m1=10;
m2=10;
nn2=7;%共对nn2个数据集进行测试
gamma=1;%（离散共识嵌入的）旋转项的系数

%数据集中包含以下数据：
% Hi     1*100cell  100个基聚类器（cell为100*10的矩阵）
% idx_u  1*100cell  每个基聚类器中缺失的数据id（数据集1中cell为1*10，表示0.1的missing ratio）
% y      100*1  表示正确的聚类结果（？）

dataName = 'ALLAML'; % You can switch to other datasets

for j=1:nn2%依次选取数据集
    j%显示当前为第几个数据集
    filename = strcat('./',dataName,'/',num2str(j), '.mat');
    load(filename);
    %load(['./pixraw10P/' num2str(j),'.mat']);
    for iter=1:m1%循环m1=10次，每次处理10个基聚类器
        
        Yi={};
        for k=1:m2%依次选出参与的10个基聚类器
            idxi=(iter-1)*10+k;%基聚类器id号
            Hoi{k}=Hi{idxi};%%Hoi中的第k个元素取值为这10个基聚类器里的第k个
            idx_input{k}=idx_u{idxi};%idx_input中的第k个元素取值为这10个基聚类器里的第k个缺失id
        end

        %Hoi        10个基聚类器
        %idx_input  每个基聚类器缺失的id
        %gamma      离散共识嵌入的旋转项的系数
        ypred = PCE_orth2( Hoi,idx_input,gamma );
            
        res=ClusteringMeasure(y,ypred);%上传正确聚类y和PCE所得聚类结果，生成评价指标
        %第j个数据集的第iter次计算
        our_acc(j,iter)=res(1);%Accuracy(ACC)
        our_nmi(j,iter)=res(2);%Normalized Mutual Information(NMI)
        our_pur(j,iter)=res(3);%Purity
    end
end


x=1:7;
figure;
plot(x,mean(our_acc,2));%第x个数据集的ACC指数（均值）
figure;
plot(x,mean(our_nmi,2));%第x个数据集的NMI指数（均值）
figure;
plot(x,mean(our_pur,2));%第x个数据集的Purity指数（均值）
