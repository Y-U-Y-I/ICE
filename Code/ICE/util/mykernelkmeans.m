function [H_normalized,obj]= mykernelkmeans(K,cluster_count)

K = (K+K')/2;%对称化，但是本来就是对称的吧
opt.disp = 0;
%使用 'la'（largest algebraic）选项来计算矩阵 K 的前 cluster_count 个最大实部特征值和对应的特征向量
%特征向量存储在变量 H 中，而波浪线 ~ 表示不需要特征值的返回
[H,~] = eigs(K,cluster_count,'la',opt);
%obj = trace(H' * K * H) - trace(K);

H_normalized = H;%源代码采用的是这一段,在这个函数中没有归一化，而是将归一化的任务放进了mydiscretisation(H,1)里
%这样在计算CC,RR时可以使用归一化的H，但是后面在PCE_orth2中使用的H仍然是未归一化的H


%H_normalized = H ./ repmat(sqrt(sum(H.^2, 2)), 1,cluster_count);%这里是需要的吧？
%sqrt(sum(H.^2, 2))为每一行总和平方根的列向量
%repmat(sqrt(sum(H.^2, 2)),1,cluster_count)将该列向量复制cluster_count次，生成大小为instance数*cluster_count的矩阵
%最后按元素除，将行元素归一化


%我觉得要使得H'*H=I，也就是H的列向量彼此正交
%n=size(H,1);
%H_normalized = H ./ repmat(sqrt(sum(H.^2, 1)), n,1);
%sqrt(sum(H.^2, 1))为每一列总和平方根的列向量
%repmat(sqrt(sum(H.^2, 1)), n,1)将该行向量复制n次，生成大小为n*cluster_count的矩阵
%最后按元素除，将行元素归一化

%try1=H_normalized*H_normalized';%用于测试
%try2=H_normalized'*H_normalized;