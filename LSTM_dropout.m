clear
close all

%% 数据读取
% 设置验证集个数
yanzheng = 243;

% 初始化预测结果存储
forecastdata = [];
rng(501);

% 读取数据
price = xlsread('大豆期货价格.xlsx', 2);
shuchu_all = price;

% 超参数网格
numLagsGrid = [1, 5, 10, 15, 20, 25, 30];     %numLagsGrid = [1, 5, 10, 15, 20, 25, 30];
numHiddenUnitsGrid = [64,128,200,256,512];  % LSTM单元数网格 numHiddenUnitsGrid = [50, 100,128, 150,200]; 
dropoutRateGrid = [0.1, 0.2];   % dropout率网格 dropoutRateGrid = [0.1, 0.2, 0.3, 0.4]; 

% 变量初始化
best_rmse = Inf;
best_numLags = 0;
best_numHiddenUnits = 0;
best_dropoutRate = 0;

% 计算总的网格搜索次数
total_combinations = length(numLagsGrid) * length(numHiddenUnitsGrid) * length(dropoutRateGrid);
current_combination = 0;

for numLags = numLagsGrid
    shuchu = shuchu_all(numLags + 1:end);  % 根据当前numLags提取输出数据
    
    % 预分配输入矩阵
    shuru = zeros(length(price) - numLags, numLags);

    % 构建滞后时间特征矩阵
    for lag = 1:numLags
        shuru(:, lag) = price((numLags - lag + 1):(end - lag));
    end

    % 划分数据集
    geshu = length(shuchu) - yanzheng;

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

    %% 样本输入输出数据归一化
    [aa, bb] = mapminmax([input_train input_val input_test]);
    [cc, dd] = mapminmax([output_train output_val output_test]);
    global inputn outputn shuru_num shuchu_num

    [inputn, inputps] = mapminmax('apply', input_train, bb);
    [inputn_val, ~] = mapminmax('apply', input_val, bb);
    [inputn_test, ~] = mapminmax('apply', input_test, bb);

    [outputn, outputps] = mapminmax('apply', output_train, dd);
    [outputn_val, ~] = mapminmax('apply', output_val, dd);
    [outputn_test, ~] = mapminmax('apply', output_test, dd);

    shuru_num = size(input_train, 1);  % 输入维度
    shuchu_num = 1;  % 输出维度

    %% 网格搜索超参数
    for numHiddenUnits = numHiddenUnitsGrid
        for dropoutRate = dropoutRateGrid
            current_combination = current_combination + 1;
            progress = (current_combination / total_combinations) * 100;
            fprintf('网格搜索进度：%.2f%%\n', progress);

            layers = [
                sequenceInputLayer(shuru_num)  % 输入层
                lstmLayer(numHiddenUnits, 'OutputMode', 'sequence')  % LSTM层
                dropoutLayer(dropoutRate)  % Dropout层
                fullyConnectedLayer(shuchu_num)  % 全连接层
                regressionLayer];

            options = trainingOptions('adam', ...
                'MaxEpochs', 100, ...
                'GradientThreshold', 1, ...
                'InitialLearnRate', 0.005, ...
                'LearnRateSchedule', 'piecewise', ...
                'LearnRateDropPeriod', 50, ...
                'LearnRateDropFactor', 0.2, ...
                'Verbose', 0, ...
                'Plots', 'none');  %'Plots', 'training-progress'

            % 训练LSTM
            net = trainNetwork(inputn, outputn, layers, options);

            % 验证集预测
            net = resetState(net);
            [~, Yval] = predictAndUpdateState(net, inputn_val);
            Yval = mapminmax('reverse', Yval, dd);  % 反归一化
            val_rmse = sqrt(mean((Yval - output_val).^2));  % 验证集RMSE

            % 更新最佳超参数
            if val_rmse < best_rmse
                best_rmse = val_rmse;
                best_numLags = numLags;
                best_numHiddenUnits = numHiddenUnits;
                best_dropoutRate = dropoutRate;
                
            end
        end
    end
end










