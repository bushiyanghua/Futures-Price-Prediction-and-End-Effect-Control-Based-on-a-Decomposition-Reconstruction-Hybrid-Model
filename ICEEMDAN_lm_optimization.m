clear all
clc

shuru=xlsread('大豆期货价格.xlsx',1);  



N=length(shuru)

%x=shuru(1:N-251)'         %务必确保x 为1*N 的向量，不然后续代码是需要调整的
x=shuru(1:N)' 

N=length(x);  %原油5777 玉米
t=1/N:1/N:1;

figure(1)
subplot(1,1,1);
%plot(t,x);xlabel('时间');ylabel('价格');title('WTI原油期货价格波动序列');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NR=100 %50    100,0,05
Nstd=0.05
MaxIter=7
SNRFlag=2
 
x=x(:)';                      % x 1*2048
desvio_x=std(x);
x=x/desvio_x;

modes=zeros(size(x));
temp=zeros(size(x));
aux=zeros(size(x));
iter=zeros(NR,round(log2(length(x))+5));



for i=1:NR
    rng(i+500) %设置随机数种子
    white_noise{i}=randn(size(x));%creates the noise realizations   %1*2048
end;

for i=1:NR
    modes_white_noise{i}=emd(white_noise{i});%calculates the modes of white gaussian noise 50个序列 又拆分成9列imf值
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%此处大改
for i=1:NR   %calculates the first mode
    mi=modes_white_noise{i}(:,1); %此处原为(1,:)，所以报错，仔细探究原理后发现源代码此处写错，故修改之
    xi=x+Nstd*mi(:)'/std(mi);  %第二处错误是向量问题，修改后mi是2048*1的向量，mi
    [temp, o1, it1]=emd(xi,'MaxNumIMF',MaxIter,'MaxNumExtrema',1);
    temp=temp(:,1);               %temp为2048行6列  ；x为1行2048列;此处原为(1,:)，所以报错
    
    aux=aux+(xi-temp(:)')/NR;      %xi为1*2048 ，temp为2048*1 # 所有循环后此处得到的aux是iceemdan中，50个序列的总局部均值
    %iter(i,1)=it1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

modes= x-aux; %saves the first mode  ；aux为第一次的总局均值 ；modes是真正意义上的imf1
medias = aux; %medias是第二次处理的“原序列”，将aux的值赋予之
k=1;
aux=zeros(size(x)); %将aux归零
es_imf = min(size(emd(medias(end,:),'MaxNumIMF',MaxIter,'MaxNumExtrema',1)));  %返回在50个序列中imf最少的那个序列的imf个数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%上面这个end是干啥的？有什么特殊目的吗，为什么不用1？


while es_imf>1 %calculates the rest of the modes  ；如果“原序列”仍能被emd分解出超过两个及以上imf；
 % 此处大胆修改，原来是>1,后来被我放松到2,减少了imf个数
    for i=1:NR
        tamanio=size(modes_white_noise{i});   %tomanio[2048,9] 白噪声序列的规格
        if tamanio(2)>=k+1        % 如果白噪声被emd分解出的emd大于等于k+1；即如果k+1小于等于9的时候运行  因为有的白噪声只有5个imf分量，此时若原序列已经计算到imf6，则没有对应的白噪声imf6与之相加，因此这个x序列就要被抛弃
            noise=modes_white_noise{i}(:,k+1);  %修改 ； 则提取出白噪声序列的第2项，即，求imf2的时候加的是白噪声的imf2项
            if SNRFlag == 2
                noise=noise/std(noise); %adjust the std of the noise
            end;          
            noise=Nstd*noise; % 形成新一轮的白噪声
            noise=noise(:)' %这一条是我增加的，目的是将向量medias和noise行列对齐
            try
                [temp,o,it]=emd(medias(end,:)+noise,'MaxNumIMF',MaxIter,'MaxNumExtrema',1);
    %大胆修改输入emd的x，原来是medias(end,:)+std(medias(end,:))*noise，
            catch    
                it=0; disp('catch 1 '); disp(num2str(k))
                temp=emd(medias(end,:)+noise,'MaxNumIMF',MaxIter,'MaxNumExtrema',1);
    %大胆修改输入emd的x，原来是medias(end,:)+std(medias(end,:))*noise，
            end;
            temp=temp(:,1);      %此处修改，行列对调 temp 2048行，6列 ;此处提取出来了emd分解后新的imf1
   %%%此处有一个冒险的改动，将end改成了1
        else
            try
                [temp, o, it]=emd(medias(end,:),'MaxNumIMF',MaxIter,'MaxNumExtrema',1);
            catch
                temp=emd(medias(end,:),'MaxNumIMF',MaxIter,'MaxNumExtrema',1);
                it=0; disp('catch 2 sin ruido')
            end;
            temp=temp(:,1);   %此处修改，行列对调 temp 2048行，6列;此处提取出来了emd分解后的趋势项
   %%%此处有一个冒险的改动，将end改成了1
        end;
        aux=aux+(medias(end,:)-temp(:)')/NR;        %aux是局部均值的平均——残差
   %%%此处有大修改，原来是 aux=aux+temp/NR ，存有重大原理错误
    %iter(i,k+1)=it;    
    end;
    modes=[modes;medias(end,:)-aux]; %原残差-局部均值的平均=imf2   modes储存的是imf
    medias = [medias;aux]; %变成2行，2048列                       medias储存的是每一次的残差
    aux=zeros(size(x));
    k=k+1;
    es_imf = min(size(emd(medias(end,:),'MaxNumIMF',MaxIter,'MaxNumExtrema',1)));
end;

modes = [modes;medias(end,:)]; %加上最后的残差项 即所有imf＋残差
modes=modes*desvio_x;



testdata_imf=modes
%mmmm_gaopin=testdata_imf(1,:)+testdata_imf(2,:)+testdata_imf(3,:)             %此处为高频优化部分    %modesf(1,:)+  +modesf(4,:)   modesf(1,:)+
%mmmm_zhongpin=testdata_imf(4,:)+testdata_imf(5,:)+testdata_imf(6,:)+testdata_imf(7,:)
%mmmm_dipin=testdata_imf(8,:)+testdata_imf(9,:)
%modesf=[] 
%modesf=[mmmm_gaopin',mmmm_zhongpin',mmmm_dipin']


figure(10)
subplot(10,1,1);
  plot(t,modes(1,:));axis([0 1 -10 10]);
subplot(10,1,2);
  plot(t,modes(2,:));axis([0 1 -10 10]);
subplot(10,1,3);
  plot(t,modes(3,:));axis([0 1 -10 10]);
subplot(10,1,4);
  plot(t,modes(4,:));axis([0 1 -10 10]);
subplot(10,1,5);
  plot(t,modes(5,:));axis([0 1 -20 20]);
subplot(10,1,6);
  plot(t,modes(6,:));axis([0 1 -30 30]);
subplot(10,1,7);
  plot(t,modes(7,:));axis([0 1 -30 30]);
subplot(10,1,8);
  plot(t,modes(8,:));axis([0 1 -30 30]);
%subplot(10,1,9);
  %plot(t,modes(9,:));axis([0 1 -30 30]);
%subplot(10,1,10);
  %plot(t,modes(10,:));axis([0 1 0 100]);
  
  
  
  
  %%for i=1:9
      %%figure(i);
      %%subplot(1,1,1);
      %%plot(t,modes(i,:));
  %%end;
    
  
  