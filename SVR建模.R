setwd("D:/桌面文件/中南财经政法/期刊论文/基于分解-重构策略的神经网络预测大宗商品期货价格方法/20240613修改工程")
library(openxlsx)
library(e1071)

# 读取数据
dataset <- read.xlsx('SVR.xlsx', sheet = 7)    # 

stepahead = 243

# 定义参数网格
cost_values <- c(0.001, 0.01, 0.1, 1, 10,50,100,150,200,1000)
n_values <- 2:31  # 输入维度参数，从2到31

best_mse <- Inf
best_params <- list()

# 网格搜索循环
for (cost in cost_values) {
  for (n in n_values) {
    # 截取前 n 列作为输入特征
    data_subset <- dataset[, 1:n]
    
    # 数据分割
    data_trn <- head(data_subset, round(nrow(data_subset) - stepahead - 1))
    data_test <- tail(data_subset, stepahead)
    
    # 训练模型
    model <- svm(Y ~ ., data = data_trn, cost = cost, type = 'eps-regression', kernel = 'linear')
    
    # 预测并计算MSE
    predictions <- predict(model, data_test)
    mse <- mean((data_test$Y - predictions)^2)
    
    # 更新最优参数
    if (mse < best_mse) {
      best_mse <- mse
      best_params <- list(cost = cost, n = n)
    }
  }
}

# 输出最优参数
print(best_params)

# 使用最优参数训练最终模型
final_data_subset <- dataset[, 1:best_params$n]
data_trn <- head(final_data_subset, round(nrow(final_data_subset) - stepahead - 1))
data_test <- tail(final_data_subset, stepahead)

regressor <- svm(Y ~ ., data = data_trn, cost = best_params$cost, type = 'eps-regression', kernel = 'linear')

# 预测并绘图
y_pred <- predict(regressor, data_test)
plot(data_test$Y, type = 'l', col = 'blue', main = 'SVR Prediction', xlab = 'Time', ylab = 'Y')
lines(ts(y_pred), type = 'l', col = 'red')

forecastdata <- data.frame(y_pred)







setwd("D:/桌面文件/中南财经政法/期刊论文/基于分解-重构策略的神经网络预测大宗商品期货价格方法/20240613修改工程")
library(openxlsx)
library(e1071)

# 读取数据
dataset <- read.xlsx('SVR.xlsx', sheet = 8)    #

stepahead = 243
# 定义参数网格
n=22
data_subset <- dataset[, 1:n]
    
    # 数据分割
data_trn <- head(data_subset, round(nrow(data_subset) - stepahead - 1))
data_test <- tail(data_subset, stepahead)
    
    # 训练模型
model <- svm(Y ~ ., data = data_trn, cost = 1, type = 'eps-regression', kernel = 'linear')
    
    # 预测并计算MSE
predictions <- predict(model, data_test)
mse <- mean((data_test$Y - predictions)^2)
    

# 预测并绘图
y_pred <- predictions
plot(data_test$Y, type = 'l', col = 'blue', main = 'SVR Prediction', xlab = 'Time', ylab = 'Y')
lines(ts(y_pred), type = 'l', col = 'red')

forecastdata <- data.frame(y_pred)

# 指定要保存的Excel文件名
excel_file <- "SVR测试集预测结果20240808.xlsx"
# 使用write.xlsx函数将数据框导出为Excel文件
write.xlsx(forecastdata, file = excel_file)
# 提示导出成功
cat("数据已成功导出到", excel_file, "\n")


