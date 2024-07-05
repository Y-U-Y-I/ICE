% %更新说明
% %V1 第一版
% %V2 第二版：添加了Hu{i}表示第i个基聚类器中缺失元素，实现:一个基聚类器一个基聚类器更新->完成之后再一起更新
% %           效果：完全一样，没有区别
% %           并且发现，每次运行结果完全一样，而PCE并不是，是哪里出现了随机？
% %V3 第三版：将sigma矩阵中lamda更改为:总和为1->均值为1
% %           效果：基本上全部都有提升，只有缺失率20%处下降，总体仍然低于PCE
% %           每次运行结果仍然一致
% %V4 第四版：将每次更新缺失值更改为:每个元素都是0~1之间的连续值->只有最大元素为1，其余为0
% %           效果：比V3、V2、V1提升不少，全面比V3好，对于V1、V2只有缺失率20%处下降
% %           少数缺失率情况超过PCE，大部分低于PCE
% %           tip:在V4情况下取消V3中sigma矩阵中lamda的更改为（总和为1->均值为1），采用总和为1
% %               对比于V4，有的缺失率情况下更低，有的更高，并不是全部降低
% %           tip:将迭代次数由20->40，可以发现20次迭代下基本收敛了，只有高缺失率的情况下有少量增长
% %               ->高缺失率下需要更多迭代次数才能收敛，可以设定个迭代终止条件 或 高缺失率人为给更多迭代次数？
% %           tip:若使用未初始化的缺失行更新A 效果很差！不宜采取
% %           tip:V4的acc指数在缺失率20%处有个异常下降，缺失率20%是一个很特殊的情况
% 
% %另一个优势：可以处理簇数不一致情况，在这个样本集中没有体现
% 
% %返回最终推测聚类
% function [ ypred ] = run_ICE(Hoi,idx_u)
% %Hoi        1*10cell 10个基聚类器
% %idx_input  1*10cell 每个基聚类器缺失的id
% 
% ensemblesize = length(Hoi);%选取基聚类器的数目
% datasize=size(Hoi{1}, 1);%数据的数量
% cnum = zeros(ensemblesize, 1);%基聚类器各自的簇数
% for i=1:ensemblesize
%     cnum(i)=size(Hoi{i}, 2);
% end
% 
% %初始化第i个基聚类器中缺失的元素Yu{i}，矩阵大小=缺失元素数*簇数，设置为1/簇数
% %后续可以考虑下初始化CA时要不要使用这个初始值（即现在就把Hu{i}赋值给Hoi or 在更新时再赋值给Hoi）
% %这一步是必须的，否则缺失行的数值全部为0，则根据更新公式，后续永远不会有值
% for i=1:ensemblesize
%     Hu{i}=zeros(length(idx_u{i}),cnum(i));
%     Hu{i}(:) = 1/cnum(i);%对于一个基聚类器，每一个缺失行的元素都应该赋值为1/该基聚类器簇数
% end
% % %将缺失值初始值填入基聚类器Hoi
% for i=1:ensemblesize
%     HH=Hoi{i};
%     HH(idx_u{i},:)=Hu{i};
%     Hoi{i}=HH;
% end
% 
% %初始化A，CA矩阵
% %计算10个基聚类器得到的CA矩阵的平均，作为A的初始值
% A = zeros(datasize, datasize);%创建全零数组,大小100*100
% for i=1:ensemblesize
%     A=A+Hoi{i}*Hoi{i}';
% end
% A=A./ensemblesize;
% 
% %初始化alpha，对基聚类器的加权
% %初始时设置每个基聚类器的权重都相同（后续可以按照不同基聚类器的缺失率大小进行处理？）
% alpha=(1/ensemblesize).*ones(ensemblesize,1);
% 
% %初始化sigma(lamda)，对基聚类器中簇的加权
% %初始时设置基聚类器中簇的加权都相同
% lamda = cell(ensemblesize, 1);%创建一个大小为 1x基聚类器数 的空cell数组
% for i = 1:ensemblesize
%     % 创建第 i 个向量
%     vector=(1/cnum(i)).*ones(1, cnum(i));
%     lamda{i} = vector;  % 将向量存储在 cell 数组的第 i 个元素中
% end
% 
% opt=[];%创建了一个空的结构体变量 opt
% opt.Display='none';%在 opt 结构体中创建一个名为 Display 的字段，并将其值设置为 'none'
% 
% maxiter=20;%预设迭代次数
% for iternum=1:maxiter%迭代次数
%     %update A
%     A = zeros(size(A));
%     for i=1:ensemblesize
%         A=A+alpha(i)*Hoi{i}*diag(lamda{i})*Hoi{i}';
%     end
% 
%     %update Hu
%     %依次更新各个基聚类器缺失值（每次更新要不要离散化？ 采用0~1连续取值，还是00..01000..00？）
%     for i=1:ensemblesize
%         %计算当前B取值
%         B=zeros(datasize, datasize);
%         %遍历j!=i的基聚类器
%         for j=1:ensemblesize
%             if j==i
%                 continue
%             else
%                 B=B+alpha(j)*Hoi{j}*diag(lamda{j})*Hoi{j}';
%             end
%         end
% 
%         X1=A*Hoi{i};
%         X2=B*Hoi{i};
%         X3=Hoi{i}*(diag(lamda{i})*(Hoi{i}'*Hoi{i}));
% 
%         %依次更新每个缺失行的值
%         currentrow=0;%当前计算的是Hu{i}中的哪一行
%         for j = idx_u{i}%选取第i个基聚类器中的缺失行
%             currentrow=currentrow+1;
%             for k=1:cnum(i)%遍历缺失行的元素
%                 if Hoi{i}(j,k)==0
%                     continue
%                 else
%                     numerator=X1(j,k);%分子
%                     denominator=(X2(j,k)*Hoi{i}(j,k)^3 + alpha(i)*X3(j,k));%分母
%                     res=((numerator/denominator)^(1/4));
%                     Hu{i}(currentrow,k)=Hoi{i}(j,k)*res;
%                 end
%             end
%             %每次都取0、1离散值
% 
%             %如果最大值不止一个呢？？
% 
%             % 找到最大值及其索引
%             [maxValue, maxIndex] = max(Hu{i}(currentrow, :));
%             % 将最大值所在的位置赋值为 1，其他位置赋值为 0
%             Hu{i}(currentrow, :) = (Hu{i}(currentrow, :) == maxValue);
%         end
%     end
%     %在进行过一轮缺失的元素Yu{i}的更新之后，将更新的结果填入基聚类器Hoi（为防止更新前几个基聚类器缺失元素时影响后面的更新）
%     for i=1:ensemblesize
%         HH=Hoi{i};
%         HH(idx_u{i},:)=Hu{i};
%         Hoi{i}=HH;
%     end
% 
%     %update sigma(lamda)
%     %依次更新各个基聚类器簇的权重 (是一个基聚类器一个基聚类器更新，还是完成之后再一起更新？)
%     for i=1:ensemblesize
%         %计算当前B取值
%         B=zeros(datasize, datasize);
%         %遍历j!=i的基聚类器
%         for j=1:ensemblesize
%             if j==i
%                 continue
%             else
%                 B=B+alpha(j)*Hoi{j}*diag(lamda{j})*Hoi{j}';
%             end
%         end
% 
%         %只需要计算对角线的取值(后续这里可以优化复杂度)
%         X1=Hoi{j}'*A*Hoi{j};
%         X2=Hoi{j}'*B*Hoi{j};
%         X3=0.5*alpha(i)*Hoi{j}'*Hoi{j}*diag(lamda{i})*Hoi{j}'*Hoi{j};
% 
%         for j=1:cnum(i)
%             lamda{i}(j)=X1(j,j)/(X2(j,j)+X3(j,j));
%         end
% 
%         %归一化，使得簇的权重和均值为1
%         lamda_sum = sum(lamda{i});
%         lamda{i} = cnum(i) * lamda{i} ./ lamda_sum;
%         %lamda{i} = lamda{i} ./ lamda_sum;
%     end
% 
%     %update alpha 更新基聚类权重
%     for i=1:ensemblesize
%         C{i}=Hoi{i}*diag(lamda{i})*Hoi{i}';%Y*sigma*Y'
%     end
%     G=-inf.*ones(ensemblesize,ensemblesize);%创建大小为ensemblesize*ensemblesize矩阵
%     %求秩即是求C和C的按元素乘
%     for i=1:ensemblesize
%         for j=i:ensemblesize
%             G(i,j)=sum(sum(C{i}.*C{j}));%计算求得矩阵的全部元素和
%         end
%     end
%     G=max(G,G');%返回从G或G转置中提取的最大元素的数组（因为上述的G只更新了下半部分，通过这个方法可以避免重复计算）
%     f=zeros(ensemblesize,1);%创建大小为ensemblesize*1矩阵
%     for j=1:ensemblesize
%         f(j)=-sum(sum(A.*C{j}));%这里负号是为了满足quadprog公式
%     end
%     %使用二次规划函数求解
%     %传入G f
%     %alpha之和为1
%     %alpha范围在[0,1]之间
%     %从向量alpha开始求解问题
%     %使用opt中指定的优化选项求解上述问题
%     alpha=quadprog(G,f, [],[], ones(1,ensemblesize),1, zeros(ensemblesize,1),ones(ensemblesize,1), alpha,opt);
% end
% 
% %已得到预测CA矩阵 A
% K=10;%希望得到的簇数(?)
% s = squareform(A - diag(diag(A)),'tovector');%squareform函数 将原始矩阵转换为一维向量（对角线元素处理为0）
% d = 1 - s;%转化为距离矩阵
% 
% %linkage函数执行层次聚类，生成聚集层次聚类树，但并未指定最终的聚类数
% %cluster函数结合 maxclust 参数来指定最终的聚类数K，从聚类树中选择最佳的聚类划分，将数据集分配到K个聚类中
% results = zeros(datasize,1);%记录聚类集成结果
% results = cluster(linkage(d,'average'),'maxclust',K);
% 
% ypred=results;
% 
% end


