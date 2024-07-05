%返回最终聚类结果
function [ ypred ] = PCE_orth2( Hoi,idx_u ,gamma)
%Hoi        基聚类器
%idx_u      每个基聚类器缺失的id
%gamma      离散共识嵌入的旋转项的系数

%创建自定义的 opts 结构体来设置选项参数，以便传递给优化函数
opts.record = 0;
opts.mxitr  = 200;
opts.xtol = 1e-5;
opts.gtol = 1e-5;
opts.ftol = 1e-8;
opts.tau = 1e-3;


m=length(Hoi);%基聚类器数量
[n,c]=size(Hoi{1});%n=instance数量 c=聚类数

%初始化基聚类器加权alpha，均设为1/m
alpha=1./m.*ones(m,1);

%初始化共识嵌入H
%KC为CA矩阵（？）
KC=zeros(n,n);
for i=1:m
    KC=KC+Hoi{i}*Hoi{i}';
end
KC=KC./m;
%传入CA矩阵和希望的簇数，生成共识嵌入H
H= mykernelkmeans(KC,c);%使用特征向量

%初始化最终聚类结果Y和正交旋转矩阵R
[CC,RR]=mydiscretisation(H,1);%(,1)表示对H进行归一化


opt=[];%创建了一个空的结构体变量 opt
opt.Display='none';%在 opt 结构体中创建一个名为 Display 的字段，并将其值设置为 'none'

%R{i}为正交旋转矩阵，Yu{i}为第i个基聚类器中缺失的元素
for i=1:m
    %初始化正交旋转矩阵R{i}，设置为单位矩阵
    R{i}=eye(c);
    %初始化第i个基聚类器中缺失的元素，矩阵大小=缺失元素数*簇数，设置为0
    Hu{i}=zeros(length(idx_u{i}),c);
end
%
for i=1:m
    G=-2./m*H'*Hoi{i};
    for j=1:m
        if j==i
            continue;
        else
            G=G+2./(m*m).*R{j}'*(Hoi{j}'*Hoi{i});
        end
    end
    [U,~,V]=svd(-G');
    R{i}=U*V';
end

maxiter=20;%预设迭代次数

%初始化权重矩阵
v=zeros(n,1);

opt=[];
opt.Display='none';

%初始化lambda
B=zeros(n,c);
for j=1:m
    B=B+alpha(j).*Hoi{j}*R{j};
end
A=H-B;
 a=2.*sum(A.^2,2);
aa=sort(a,'ascend');%按升序对数组a进行排序，并将排序后的结果存储在新的变量aa中
lambda=aa(floor(n/10));%选取可靠度前10%的值，赋值给lambda。这样使得前10%的instance最开始权重即到达1
if lambda==0
    lambda=0.001;
end


for i=1:maxiter%迭代次数
    %update v 更新权重向量（对于每个instance）
    %计算矩阵A
    B=zeros(n,c);
    for j=1:m
        B=B+alpha(j).*Hoi{j}*R{j};
    end
    A=H-B;
    %更新v，保证v<=1
    a=sum(A.^2,2);%A中元素平方后，按行相加
    v=lambda./(2.*a);
    v(v>1)=1;
    

    % update H 更新共识嵌入
    CR=CC*RR';
    %调用OptStiefelGBB（将solveH2作为参数传入）
    [H]= OptStiefelGBB(H, @solveH2, opts, v,B,gamma,CR); 

    
    %update Hu 更新第i个基聚类器中缺失的元素Yu{i}
    for j=1:m%依次遍历每个基聚类器
        %计算Eu
        Vu=v(idx_u{j});%该基聚类器缺失的instances的权重v
        Vu=Vu.^2;%计算V^2 %(此处已更改，原为Vu=Vu.^2.*alpha(j);)
        Fu=zeros(n,c);%矩阵大小=元素数*簇数
        for k=1:m%依次遍历每个基聚类器
            if k==j
                continue;
            else
                HH=Hoi{k};
                HH(idx_u{k},:)=Hu{k};%将缺失元素值补入矩阵
                Fu=Fu+alpha(k).*HH*R{k};
            end
        end
        RH=R{j}*(Fu(idx_u{j},:)-H(idx_u{j},:))';%(此处已更改，原为RH=R{j}*(-2.*H(idx_u{j},:)+2.*Fu(idx_u{j},:))';)
        RHV=bsxfun(@times,RH,Vu');%按元素乘
        %已经求得Eu，现找列中最小元素，将对应的位置的Hu（即论文中的Yu）改为1
        [~,idx_tmp]=min(RHV,[],1);%idx_tmp即为每个缺失数据应该被分到的簇
        HHu=zeros(size(Hu{j}));
        idx_nz=sub2ind(size(Hu{j}),1:length(idx_u{j}),idx_tmp);%（矩阵大小，行，列）将下标转换为线性索引
        HHu(idx_nz)=1;%使用线性索引，将缺失元素的信息补入
        Hu{j}=HHu;%更新Hu
    end
    %在进行过一轮第i个基聚类器中缺失的元素Yu{i}的更新之后，将更新的结果填入基聚类器Hoi（为防止更新前几个基聚类器缺失元素时影响后面的更新）
    for j=1:m
        HH=Hoi{j};
        HH(idx_u{j},:)=Hu{j};
        Hoi{j}=HH;
    end
    

    %update alpha 更新基聚类权重
    %Q为文中G，f为文中f
    for j=1:m
        C{j}=Hoi{j}*R{j};%Y*R
        VC{j}=bsxfun(@times,C{j},v.^2);%Y*R*V^2
    end
    Q=-inf.*ones(m,m);%创建大小为m*m矩阵
    %求秩即是求C和VC的按元素乘
    for j=1:m
        for k=j:m
            Q(j,k)=sum(sum(C{j}.*VC{k}));%计算求得矩阵的全部元素和
        end
    end
    Q=max(Q,Q');%返回从Q或Q'中提取的最大元素的数组（因为上述的Q只更新了下半部分，通过这个方法可以避免重复计算）
    f=zeros(m,1);%创建大小为m*1矩阵
    for j=1:m
        f(j)=-sum(sum(H.*VC{j}));%这里负号是为了满足quadprog公式
    end
    %使用二次规划函数求解
    %传入Q f
    %alpha之和为1
    %alpha范围在[0,1]之间
    %从向量alpha开始求解问题
    %使用opt中指定的优化选项求解上述问题
    alpha=quadprog(Q,f, [],[], ones(1,m),1, zeros(m,1),ones(m,1), alpha,opt);

    
    %update R 更新正交旋转矩阵R{i}
    E=bsxfun(@times,H,v);
    for j=1:m
        Fi{j}=alpha(j).*bsxfun(@times,Hoi{j},v);
    end
    for j=1:m
        G=-2.*E'*Fi{j};
        for k=1:m
            if k==j
                continue;
            else
                G=G+2.*R{k}'*(Fi{k}'*Fi{j});
            end
        end
        [U,~,V]=svd(-G');
        R{j}=U*V';
    end
    
    [CC,RR]=mydiscretisation(H,0);%(,0)表示不对H进行归一化
    %lambda更新，在前十次迭代中，lambda都为上一次的1.1倍
    if i<10
        lambda=lambda*1.1;
    end
end
[~,ypred]=max(CC,[],2);

