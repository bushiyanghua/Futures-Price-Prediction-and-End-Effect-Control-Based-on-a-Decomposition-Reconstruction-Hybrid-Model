clear all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
step= 1%设置预测步长
price=xlsread('大豆期货价格.xlsx',3);        %   3.预测建模.xlsx     xlsread('3.小麦期货建模数据.xlsx',1); 
num_test=251
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
forecastdata=[]
rng(501)
number_price=20
number_u=50
Lambda_value =[0,0.00000000001,0.0000000001,0.000000001,0.00000001,0.0000001,0.000001,0.00001,0.0001,0.001,0.01,0.1,1,10,100];
NRMSE=zeros(number_price,number_u);

price_shuchu=price(20+step:end,1);
octane=price_shuchu;
price_shuru1=price(20:end-step,1);
price_shuru2=price(19:end-step-1,1);
price_shuru3=price(18:end-step-2,1);
price_shuru4=price(17:end-step-3,1);
price_shuru5=price(16:end-step-4,1); 
price_shuru6=price(15:end-step-5,1); 
price_shuru7=price(14:end-step-6,1); 
price_shuru8=price(13:end-step-7,1); 
price_shuru9=price(12:end-step-8,1); 
price_shuru10=price(11:end-step-9,1); 
price_shuru11=price(10:end-step-10,1); 
price_shuru12=price(9:end-step-11,1); 
price_shuru13=price(8:end-step-12,1); 
price_shuru14=price(7:end-step-13,1); 
price_shuru15=price(6:end-step-14,1); 
price_shuru16=price(5:end-step-15,1); 
price_shuru17=price(4:end-step-16,1); 
price_shuru18=price(3:end-step-17,1); 
price_shuru19=price(2:end-step-18,1); 
price_shuru20=price(1:end-step-19,1); 

NIR1=[price_shuru1]
NIR2=[price_shuru1,price_shuru2]
NIR3=[price_shuru1,price_shuru2,price_shuru3]
NIR4=[price_shuru1,price_shuru2,price_shuru3,price_shuru4]
NIR5=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5]
NIR6=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6]
NIR7=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7]
NIR8=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8]
NIR9=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9]
NIR10=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10]
NIR11=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11]
NIR12=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12]
NIR13=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13]
NIR14=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13,price_shuru14]
NIR15=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13,price_shuru14,price_shuru15]
NIR16=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13,price_shuru14,price_shuru15,price_shuru16]
NIR17=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13,price_shuru14,price_shuru15,price_shuru16,price_shuru17]
NIR18=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13,price_shuru14,price_shuru15,price_shuru16,price_shuru17,price_shuru18]
NIR19=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13,price_shuru14,price_shuru15,price_shuru16,price_shuru17,price_shuru18,price_shuru19]
NIR20=[price_shuru1,price_shuru2,price_shuru3,price_shuru4,price_shuru5,price_shuru6,price_shuru7,price_shuru8,price_shuru9,price_shuru10,price_shuru11,price_shuru12,price_shuru13,price_shuru14,price_shuru15,price_shuru16,price_shuru17,price_shuru18,price_shuru19,price_shuru20]




for j = 1%:20 %:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %name2 = strcat('NIR', num2str(j))
    %NIR=eval([name2]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NIR=NIR1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i=1%:length(Lambda_value)       %:length(Lambda_value)    %:length(Lambda_value)  %number_u   
        rng(501)
        lambda=Lambda_value(7)
        %lambda=0.00001
    
        n=length(NIR)-num_test %
%%2.产生训练集和测试集
%temp = randperm(size(NIR,1));
%训练集-      
        P_train = NIR(1:n,:)';            
        T_train = octane(1:n,:)';

%测试集-251个样本
        P_test = NIR(n+1:n+num_test,:)';
        T_test = octane(n+1:n+num_test,:)';
        N = size(P_test,2);

%%3.归一化数据
% 3.1. 训练集
        [Pn_train,inputps] = mapminmax(P_train);
        Pn_test = mapminmax('apply',P_test,inputps);
% 3.2. 测试集
        [Tn_train,outputps] = mapminmax(T_train);
        Tn_test = mapminmax('apply',T_test,outputps);

%%4.ELM训练
        [IW1,B1,H1,TF1,TYPE1] = elmtrain_regularization(Pn_train,Tn_train,2,'sig',0,lambda);
%[IW2,B2,H2,TF2,TYPE2] = elmtrain(H1,Tn_train,20,'sig',0);
%[IW3,B3,H3,TF3,TYPE3] = elmtrain(H2,Tn_train,30,'sig',0);
%LW = pinv(H1') * Tn_train';
%%5.ELM仿真测试
        tn_sim01 = elmpredict(Pn_test,IW1,B1,H1,TF1,TYPE1);
%tn_sim02 = elmpredict(tn_sim01,IW2,B2,TF2,TYPE2);
%tn_sim03 = elmpredict(tn_sim02,IW3,B3,TF3,TYPE3);
%计算模拟输出
%tn_sim = (tn_sim01' * LW)';
%5.1. 反归一化
        T_sim = mapminmax('reverse',tn_sim01,outputps);

%%6.结果对比
        result = [T_test' T_sim'];
%6.1.均方误差
        E = mse(T_sim , T_test);
        rmse=sqrt(E)
        nrmse=rmse/mean(T_test)

%6.2 相关系数
        N = length(T_test);
    %R2 = (N*sum(T_sim.*T_test)-sum(T_sim)*sum(T_test))^2/((N*sum((T_sim).^2)-(sum(T_sim))^2)*(N*sum((T_test).^2)-(sum(T_test))^2));

%%7.成图
        figure(1);
        plot(1:N,T_test,'r-*',1:N,T_sim,'b:o');
        grid on 
        legend('真实值','预测值')
        xlabel('样本编号')
        ylabel('值')
    %string = {'预测结果对比(ELM)';['(mse = ' num2str(E) ' R^2 = ' num2str(R2) ')']};
    %title(string)
    %forecastdata{i}=T_sim
    %forecastdata=[forecastdata;T_sim]
    %forecastdata=forecastdata'
        T_sim =T_sim'
        NRMSE(j,i)=nrmse*100
    end
end