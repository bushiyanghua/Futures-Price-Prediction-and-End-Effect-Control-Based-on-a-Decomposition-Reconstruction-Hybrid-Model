clear
close all

%% 数据读取
% 设置验证集个数
yanzheng = 243;
ceshi=243

% 初始化预测结果存储
forecastdata = [];
rng(501);

% 读取数据
price = xlsread('铜期货价格.xlsx', 3);
shuchu_all = price;

% 变量初始化
best_rmse = Inf;
best_numLags = 4;
best_numHiddenUnits = 100;
best_dropoutRate = 0;



%% 使用最佳超参数重新训练模型
% 重新构建输入矩阵和输出数据
shuchu = shuchu_all(best_numLags + 1:end);
shuru = zeros(length(price) - best_numLags, best_numLags);
for lag = 1:best_numLags
    shuru(:, lag) = price((best_numLags - lag + 1):(end - lag));
end

% 划分数据集
geshu = length(shuchu) - yanzheng-ceshi;

nn = 1:size(shuru, 1);  % 正常排序，不打乱数据顺序

input_train = shuru(nn(1:geshu), :);  % 训练集输入
input_train = input_train';  % 转置训练集输入

output_train = shuchu(nn(1:geshu), :);  % 训练集输出
output_train = output_train';  % 转置训练集输出

input_val = shuru(nn((geshu+1):(geshu+yanzheng)), :);  % 验证集输入
input_val = input_val';  % 转置验证集输入

output_val = shuchu(nn((geshu+1):(geshu+yanzheng)), :);  % 验证集输出
output_val = output_val';  % 转置验证集输出

input_test = shuru(nn((geshu+yanzheng+1):end), :);  % 测试集输入
input_test = input_test';  % 转置测试集输入

output_test = shuchu(nn((geshu+yanzheng+1):end), :);  % 测试集输出
output_test = output_test';  % 转置测试集输出

% 样本输入输出数据归一化
[aa, bb] = mapminmax([input_train input_val input_test]);
[cc, dd] = mapminmax([output_train output_val output_test]);

[inputn, inputps] = mapminmax('apply', input_train, bb);
[inputn_val, ~] = mapminmax('apply', input_val, bb);
[inputn_test, ~] = mapminmax('apply', input_test, bb);

[outputn, outputps] = mapminmax('apply', output_train, dd);
[outputn_val, ~] = mapminmax('apply', output_val, dd);
[outputn_test, ~] = mapminmax('apply', output_test, dd);

shuru_num = size(input_train, 1);  % 输入维度
shuchu_num = 1;  % 输出维度

% 模型建立与训练
layers = [
    sequenceInputLayer(shuru_num)  % 输入层
    lstmLayer(best_numHiddenUnits, 'OutputMode', 'sequence')  % LSTM层
    dropoutLayer(best_dropoutRate)  % Dropout层
    fullyConnectedLayer(shuchu_num)  % 全连接层
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs', 251, ...
    'GradientThreshold', 1, ...
    'InitialLearnRate', 0.005, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 125, ...
    'LearnRateDropFactor', 0.2, ...
    'Verbose', 0, ...
    'Plots', 'training-progress');

net = trainNetwork(inputn, outputn, layers, options);

%% 预测
net = resetState(net);  % 重置网络状态
[~, Ytrain] = predictAndUpdateState(net, inputn);
test_simu = mapminmax('reverse', Ytrain, dd);  % 反归一化
rmse = sqrt(mean((test_simu - output_train).^2));  % 训练集RMSE

% 测试集预测
[net, an] = predictAndUpdateState(net, inputn_test);
test_simu1 = mapminmax('reverse', an, dd);  % 反归一化
error1 = test_simu1 - output_test;  % 预测误差
rmse1 = sqrt(mean((test_simu1 - output_test).^2));  % 测试集RMSE

%% 画图
figure
plot(output_train)
hold on
plot(test_simu1, '.-')
hold off
legend(["真实值" "预测值"])
xlabel("样本")
title("训练集")

figure
plot(output_test)
hold on
plot(test_simu1, '.-')
hold off
legend(["真实值" "预测值"])
xlabel("样本")
title("测试集")

% 计算误差指标
T_sim_optimized = test_simu1;
num = size(output_test, 2);
error = T_sim_optimized - output_test;
mae = sum(abs(error)) / num;  % 平均绝对误差
me = sum(error) / num;  % 平均误差
mse = sum(error.^2) / num;  % 均方误差
rmse = sqrt(mse);  % 均方根误差

% 计算R2
tn_sim = T_sim_optimized';
tn_test = output_test';
N = size(tn_test, 1);
R2 = (N * sum(tn_sim .* tn_test) - sum(tn_sim) * sum(tn_test))^2 / ...
    ((N * sum(tn_sim.^2) - (sum(tn_sim))^2) * (N * sum(tn_test.^2) - (sum(tn_test))^2));

% 输出误差指标
disp(' ')
disp('----------------------------------------------------------')
disp(['平均绝对误差mae为： ', num2str(mae)])
disp(['平均误差me为： ', num2str(me)])
disp(['均方误差根rmse为： ', num2str(rmse)])
disp(['相关系数R2为： ', num2str(R2)])

test_simu1=test_simu1'
% 保存预测结果
forecastdata = [forecastdata; test_simu1];
