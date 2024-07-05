% Incomplete Clustering Ensemble 不完全聚类集成

RUN

datasetnum=9;   %Number of datasets                     共对datasetnum个数据集进行测试
cntTimes=10;    %How much times each dataset data run   每个数据集数据运行次数
M=100;          %Ensemble size                          每次运行选取100个基聚类器进行集成

dataName = 'lung_cd'; % You can switch to other datasets 选择数据集

% 每个数据集中包含以下数据
% Hi     1*1000cell  1000个基聚类器（cell为100*10的矩阵）
% idx_u  1*1000cell  每个基聚类器中缺失的数据id（数据集1中cell为1*10，表示0.1的missing ratio）
%                   （缺失的数据在Hi中的那一行为全0）
% y      样例数*1    表示正确的聚类结果

for datasetid=1:datasetnum%依次选取数据集
    
    disp('Select the dataset id:');%显示开始运行第几个数据集
    disp(datasetid);
    filename = strcat('./',dataName,'/',num2str(datasetid), '.mat');
    load(filename);
    %load(['./pixraw10P/' num2str(datasetid),'.mat']);
    
    for runIdx=1:cntTimes%循环cntTimes=10次
        for i=1:M%依次选出本次循环中参与计算的100个基聚类器
            idxi=(runIdx-1)*cntTimes+i;%基聚类器id号
            Hoi{i}=Hi{idxi};%Hoi中的第i个元素取值为这10个基聚类器里的第i个
            idx_input{i}=idx_u{idxi};%idx_input中的第i个元素取值为第i个基聚类器的缺失id
        end

        % disp('runIdx:');
        % disp(runIdx);

        %Hoi        1*10cell 10个基聚类器
        %idx_input  1*10cell 每个基聚类器缺失的id
        ypred = run_ICE(Hoi,idx_input);

        res=ClusteringMeasure(y,ypred);%上传正确聚类y和PCE所得聚类结果，生成评价指标
        %第datasetid个数据集的第runIdx次计算
        our_acc(datasetid,runIdx)=res(1);%Accuracy(ACC)
        our_nmi(datasetid,runIdx)=res(2);%Normalized Mutual Information(NMI)
        our_pur(datasetid,runIdx)=res(3);%Purity
    end
end


% m1=10;
% m2=10;
% nn2=7;%共对nn2个数据集进行测试
% gamma=1;%（离散共识嵌入的）旋转项的系数
% 
% for j=1:nn2%依次选取数据集
%     j%显示当前为第几个数据集
%     filename = strcat('./',dataName,'/',num2str(j), '.mat');
%     load(filename);
%     %load(['./pixraw10P/' num2str(j),'.mat']);
%     for iter=1:m1%循环m1=10次，每次处理10个基聚类器
% 
%         Yi={};
%         for k=1:m2%依次选出参与的10个基聚类器
%             idxi=(iter-1)*10+k;%基聚类器id号
%             Hoi{k}=Hi{idxi};%%Hoi中的第k个元素取值为这10个基聚类器里的第k个
%             idx_input{k}=idx_u{idxi};%idx_input中的第k个元素取值为这10个基聚类器里的第k个缺失id
%         end
% 
%         %Hoi        10个基聚类器
%         %idx_input  每个基聚类器缺失的id
%         %gamma      离散共识嵌入的旋转项的系数
%         ypred = PCE_orth2( Hoi,idx_input,gamma );
% 
%         res=ClusteringMeasure(y,ypred);%上传正确聚类y和PCE所得聚类结果，生成评价指标
%         %第j个数据集的第iter次计算
%         pce_acc(j,iter)=res(1);%Accuracy(ACC)
%         pce_nmi(j,iter)=res(2);%Normalized Mutual Information(NMI)
%         pce_pur(j,iter)=res(3);%Purity
%     end
% end


x=1:datasetnum;

figure;
plot(x,mean(our_acc,2),'s-','color', 'red', 'DisplayName', 'ICE');%第x个数据集的ACC指数（均值）
xlabel('数据缺失率（×10%）');  % 设置横坐标描述
ylabel('ACC');  % 设置纵坐标描述
title(dataName);  % 设置图像标题
legend('Location', 'best');  % 创建图例，并指定位置为最佳位置

figure;
plot(x,mean(our_nmi,2),'s-','color', 'red', 'DisplayName', 'ICE');%第x个数据集的NMI指数（均值）
xlabel('数据缺失率（×10%）');  % 设置横坐标描述
ylabel('NMI');  % 设置纵坐标描述
title(dataName);  % 设置图像标题
legend('Location', 'best');  % 创建图例，并指定位置为最佳位置

figure;
plot(x,mean(our_pur,2),'s-','color', 'red', 'DisplayName', 'ICE');%第x个数据集的Purity指数（均值）
xlabel('数据缺失率（×10%）');  % 设置横坐标描述
ylabel('Purity');  % 设置纵坐标描述
title(dataName);  % 设置图像标题
legend('Location', 'best');  % 创建图例，并指定位置为最佳位置


% x=1:7;
% 
% figure;
% plot(x,mean(our_acc,2),'s-','color', 'red', 'DisplayName', 'ICE');%第x个数据集的ACC指数（均值）
% hold on;
% plot(x,mean(pce_acc,2),'o-','color', 'green', 'DisplayName', 'PCE');%第x个数据集的ACC指数（均值）
% xlabel('数据缺失率（×10%）');  % 设置横坐标描述
% ylabel('ACC');  % 设置纵坐标描述
% title(dataName);  % 设置图像标题
% legend('Location', 'best');  % 创建图例，并指定位置为最佳位置
% 
% figure;
% plot(x,mean(our_nmi,2),'s-','color', 'red', 'DisplayName', 'ICE');%第x个数据集的NMI指数（均值）
% hold on;
% plot(x,mean(pce_nmi,2),'o-','color', 'green', 'DisplayName', 'PCE');%第x个数据集的NMI指数（均值）
% xlabel('数据缺失率（×10%）');  % 设置横坐标描述
% ylabel('NMI');  % 设置纵坐标描述
% title(dataName);  % 设置图像标题
% legend('Location', 'best');  % 创建图例，并指定位置为最佳位置
% 
% figure;
% plot(x,mean(our_pur,2),'s-','color', 'red', 'DisplayName', 'ICE');%第x个数据集的Purity指数（均值）
% hold on;
% plot(x,mean(pce_pur,2),'o-','color', 'green', 'DisplayName', 'PCE');%第x个数据集的Purity指数（均值）
% xlabel('数据缺失率（×10%）');  % 设置横坐标描述
% ylabel('Purity');  % 设置纵坐标描述
% title(dataName);  % 设置图像标题
% legend('Location', 'best');  % 创建图例，并指定位置为最佳位置

