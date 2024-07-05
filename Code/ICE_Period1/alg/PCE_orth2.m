%�������վ�����
function [ ypred ] = PCE_orth2( Hoi,idx_u ,gamma)
%Hoi        ��������
%idx_u      ÿ����������ȱʧ��id
%gamma      ��ɢ��ʶǶ�����ת���ϵ��

%�����Զ���� opts �ṹ��������ѡ��������Ա㴫�ݸ��Ż�����
opts.record = 0;
opts.mxitr  = 200;
opts.xtol = 1e-5;
opts.gtol = 1e-5;
opts.ftol = 1e-8;
opts.tau = 1e-3;


m=length(Hoi);%������������
[n,c]=size(Hoi{1});%n=instance���� c=������

%��ʼ������������Ȩalpha������Ϊ1/m
alpha=1./m.*ones(m,1);

%��ʼ����ʶǶ��H
%KCΪCA���󣨣���
KC=zeros(n,n);
for i=1:m
    KC=KC+Hoi{i}*Hoi{i}';
end
KC=KC./m;
%����CA�����ϣ���Ĵ��������ɹ�ʶǶ��H
H= mykernelkmeans(KC,c);%ʹ����������

%��ʼ�����վ�����Y��������ת����R
[CC,RR]=mydiscretisation(H,1);%(,1)��ʾ��H���й�һ��


opt=[];%������һ���յĽṹ����� opt
opt.Display='none';%�� opt �ṹ���д���һ����Ϊ Display ���ֶΣ�������ֵ����Ϊ 'none'

%R{i}Ϊ������ת����Yu{i}Ϊ��i������������ȱʧ��Ԫ��
for i=1:m
    %��ʼ��������ת����R{i}������Ϊ��λ����
    R{i}=eye(c);
    %��ʼ����i������������ȱʧ��Ԫ�أ������С=ȱʧԪ����*����������Ϊ0
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

maxiter=20;%Ԥ���������

%��ʼ��Ȩ�ؾ���
v=zeros(n,1);

opt=[];
opt.Display='none';

%��ʼ��lambda
B=zeros(n,c);
for j=1:m
    B=B+alpha(j).*Hoi{j}*R{j};
end
A=H-B;
 a=2.*sum(A.^2,2);
aa=sort(a,'ascend');%�����������a�������򣬲��������Ľ���洢���µı���aa��
lambda=aa(floor(n/10));%ѡȡ�ɿ���ǰ10%��ֵ����ֵ��lambda������ʹ��ǰ10%��instance�ʼȨ�ؼ�����1
if lambda==0
    lambda=0.001;
end


for i=1:maxiter%��������
    %update v ����Ȩ������������ÿ��instance��
    %�������A
    B=zeros(n,c);
    for j=1:m
        B=B+alpha(j).*Hoi{j}*R{j};
    end
    A=H-B;
    %����v����֤v<=1
    a=sum(A.^2,2);%A��Ԫ��ƽ���󣬰������
    v=lambda./(2.*a);
    v(v>1)=1;
    

    % update H ���¹�ʶǶ��
    CR=CC*RR';
    %����OptStiefelGBB����solveH2��Ϊ�������룩
    [H]= OptStiefelGBB(H, @solveH2, opts, v,B,gamma,CR); 

    
    %update Hu ���µ�i������������ȱʧ��Ԫ��Yu{i}
    for j=1:m%���α���ÿ����������
        %����Eu
        Vu=v(idx_u{j});%�û�������ȱʧ��instances��Ȩ��v
        Vu=Vu.^2;%����V^2 %(�˴��Ѹ��ģ�ԭΪVu=Vu.^2.*alpha(j);)
        Fu=zeros(n,c);%�����С=Ԫ����*����
        for k=1:m%���α���ÿ����������
            if k==j
                continue;
            else
                HH=Hoi{k};
                HH(idx_u{k},:)=Hu{k};%��ȱʧԪ��ֵ�������
                Fu=Fu+alpha(k).*HH*R{k};
            end
        end
        RH=R{j}*(Fu(idx_u{j},:)-H(idx_u{j},:))';%(�˴��Ѹ��ģ�ԭΪRH=R{j}*(-2.*H(idx_u{j},:)+2.*Fu(idx_u{j},:))';)
        RHV=bsxfun(@times,RH,Vu');%��Ԫ�س�
        %�Ѿ����Eu������������СԪ�أ�����Ӧ��λ�õ�Hu���������е�Yu����Ϊ1
        [~,idx_tmp]=min(RHV,[],1);%idx_tmp��Ϊÿ��ȱʧ����Ӧ�ñ��ֵ��Ĵ�
        HHu=zeros(size(Hu{j}));
        idx_nz=sub2ind(size(Hu{j}),1:length(idx_u{j}),idx_tmp);%�������С���У��У����±�ת��Ϊ��������
        HHu(idx_nz)=1;%ʹ��������������ȱʧԪ�ص���Ϣ����
        Hu{j}=HHu;%����Hu
    end
    %�ڽ��й�һ�ֵ�i������������ȱʧ��Ԫ��Yu{i}�ĸ���֮�󣬽����µĽ�������������Hoi��Ϊ��ֹ����ǰ������������ȱʧԪ��ʱӰ�����ĸ��£�
    for j=1:m
        HH=Hoi{j};
        HH(idx_u{j},:)=Hu{j};
        Hoi{j}=HH;
    end
    

    %update alpha ���»�����Ȩ��
    %QΪ����G��fΪ����f
    for j=1:m
        C{j}=Hoi{j}*R{j};%Y*R
        VC{j}=bsxfun(@times,C{j},v.^2);%Y*R*V^2
    end
    Q=-inf.*ones(m,m);%������СΪm*m����
    %���ȼ�����C��VC�İ�Ԫ�س�
    for j=1:m
        for k=j:m
            Q(j,k)=sum(sum(C{j}.*VC{k}));%������þ����ȫ��Ԫ�غ�
        end
    end
    Q=max(Q,Q');%���ش�Q��Q'����ȡ�����Ԫ�ص����飨��Ϊ������Qֻ�������°벿�֣�ͨ������������Ա����ظ����㣩
    f=zeros(m,1);%������СΪm*1����
    for j=1:m
        f(j)=-sum(sum(H.*VC{j}));%���︺����Ϊ������quadprog��ʽ
    end
    %ʹ�ö��ι滮�������
    %����Q f
    %alpha֮��Ϊ1
    %alpha��Χ��[0,1]֮��
    %������alpha��ʼ�������
    %ʹ��opt��ָ�����Ż�ѡ�������������
    alpha=quadprog(Q,f, [],[], ones(1,m),1, zeros(m,1),ones(m,1), alpha,opt);

    
    %update R ����������ת����R{i}
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
    
    [CC,RR]=mydiscretisation(H,0);%(,0)��ʾ����H���й�һ��
    %lambda���£���ǰʮ�ε����У�lambda��Ϊ��һ�ε�1.1��
    if i<10
        lambda=lambda*1.1;
    end
end
[~,ypred]=max(CC,[],2);

