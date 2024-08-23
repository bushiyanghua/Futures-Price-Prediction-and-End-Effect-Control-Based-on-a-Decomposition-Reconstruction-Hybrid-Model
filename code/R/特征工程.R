
# 设置工作路径
setwd("D:/桌面文件/中南财经政法/期刊论文/基于分解-重构策略的神经网络预测大宗商品期货价格方法/20240613修改工程")

library(openxlsx)
credit.df <- read.xlsx('2.特征工程.xlsx')
colnames(credit.df) # 查看变量名


# 1. 数据处理
## data type transformations - factoring
to.factors <- function(df, variables){
  for (variable in variables){
    df[[variable]] <- as.factor(df[[variable]])
  }
  return(df)
}
scale.features<-function(df,variables){
  for(variable in variables){
    df[[variable]]<-scale(df[[variable]],center=T,scale=T)
  }
  return(df)
}

# factor variables
categorical.vars <- colnames(credit.df)
credit.df <- to.factors(df=credit.df, variables=categorical.vars)

# split data into training and test datasets in 60:40 ratio
#indexes <- sample(1:nrow(credit.df), size=0.8*nrow(credit.df))
x=200
indexes <- length(credit.df[,1])-x
train.data <- credit.df[1:indexes,]    
#test.data <- credit.df[-indexes,]
# 去除 traiz 缺失值
library(Rcpp)
library(Amelia)
#使用 missmap 函数绘制缺失值示意图
windows(height=3,width=4,points=8)
missmap(train.data,main = "MISSINGMAP")
#train.data <- train.data[complete.cases(train.data$新闻时事),] # 删除缺失的记录








#################################特征选择2.1 adapt-lasso for 高频项
# 设置工作空间
# 把“数据及程序”文件夹拷贝到 F 盘下，再用 setwd 设置工作空间
#setwd("D:/Download(新)/百度下载库/《R语言数据分析与挖掘实战》源数据和代码/R语言数据分析与挖掘实战/chapter13/示例程序/code")
# 设置工作路径
setwd("D:/桌面文件/中南财经政法/期刊论文/基于分解-重构策略的神经网络预测大宗商品期货价格方法/20240613修改工程")
library(openxlsx)
data1 <- read.xlsx('2.特征工程大豆.xlsx',sheet=1)
##################################################################
###数概括性度量
Min = sapply(data1,min)
Max = sapply(data1,max)
Mean = sapply(data1,mean)
SD = sapply(data1,sd)
cbind(Min,Max,Mean,SD)
#data1=(data1-Min)/(Max-Min)    # 无需归一化，数值大小只影响量纲，问题不大
# pearson 相关系数，保留两位小数
b=round(cor(data1,method = c('pearson')),3)
# 加载 adapt-lasso 源代码
source('./lasso.adapt.bic2.txt')                                               #  高频、中频：x=data1[,2:27]
out1<-lasso.adapt.bic2(x=data1[,2:31],y=data1[,1])  #  低频：x=data1[,2:14]
# adapt 输出结果名称                                            
names(out1)
# 变量选择输出结果序号
out1$x.ind
# 保留五位小数
IMF5=t(round(out1$coeff,4))
IMF5




numeric_df <- data.frame(rbind(IMF234567))

# 指定要保存的Excel文件名
excel_file <- "adaptivelasso特征结果20240806.xlsx"
# 使用write.xlsx函数将数据框导出为Excel文件
write.xlsx(numeric_df, file = excel_file)
# 提示导出成功
cat("数据已成功导出到", excel_file, "\n")




#################################特征选择2 adapt-lasso for 低频项
# 设置工作空间
# 把“数据及程序”文件夹拷贝到 F 盘下，再用 setwd 设置工作空间
#setwd("D:/Download(新)/百度下载库/《R语言数据分析与挖掘实战》源数据和代码/R语言数据分析与挖掘实战/chapter13/示例程序/code")
# 设置工作路径
setwd("D:/桌面文件/中南财经政法/期刊论文/基于分解-重构策略的神经网络预测大宗商品期货价格方法/20240613修改工程")
library(openxlsx)
data1 <- read.xlsx('2.特征工程螺纹钢.xlsx',sheet=1)
###数概括性度量
Min = sapply(data1,min)
Max = sapply(data1,max)
Mean = sapply(data1,mean)
SD = sapply(data1,sd)
cbind(Min,Max,Mean,SD)

#data1=(data1-Min)/(Max-Min)    # 无需归一化，数值大小只影响量纲，问题不大
# pearson 相关系数，保留两位小数
b=round(cor(data1,method = c('pearson')),10)
# 加载 adapt-lasso 源代码
#source('./lasso.adapt.bic2.txt')






x=data1[,2:31]
y=data1[,1]


require(lars)
ok<-complete.cases(x,y)
x<-x[ok,]                            # get rid of na's
y<-y[ok]                             # since regsubsets can't handle na's
m<-ncol(x)
n<-nrow(x)
x<-as.matrix(x)                      # in case x is not a matrix

#  standardize variables like lars does 
one <- rep(1, n)
meanx <- drop(one %*% x)/n
xc <- scale(x, meanx, FALSE)         # first subtracts mean
normx <- sqrt(drop(one %*% (xc^2)))
names(normx) <- NULL
xs <- scale(xc, FALSE, normx)        # now rescales with norm (not sd)

out.ls=lm(y~xs)                      # ols fit on standardized
beta.ols=out.ls$coeff[2:(m+1)]       # ols except for intercept

w=abs(beta.ols)                      # weights for adaptive lasso
xs=scale(xs,center=FALSE,scale=1/w)  # xs times the weights
#############################################################
library(dplyr) ### select_if() 函数
xs<-as.data.frame(xs)
xs <- xs %>% select_if(~!any(is.na(.)))##去除含有缺失值的列
xs<-as.matrix(xs)
#############################################################

object=lars(xs,y,type="lasso",normalize=FALSE)

# get min BIC
# bic=log(n)*object$df+n*log(as.vector(object$RSS)/n)   # rss/n version
sig2f=summary(out.ls)$sigma^2        # full model mse
bic2=log(n)*object$df+as.vector(object$RSS)/sig2f       # Cp version
step.bic2=which.min(bic2)            # step with min BIC

fit=predict.lars(object,xs,s=step.bic2,type="fit",mode="step")$fit
coeff=predict.lars(object,xs,s=step.bic2,type="coef",mode="step")$coefficients
coeff=coeff*w/normx                  # get back in right scale
##################################################################

for (i in 1:length(coeff)){
  coeff[i][is.na(coeff[i])] <- 0
} 

###################################################################
st=sum(coeff !=0)                    # number nonzero
mse=sum((y-fit)^2)/(n-st-1)          # 1 for the intercept

# this next line just finds the variable id of coeff. not equal 0
if(st>0) x.ind<-as.vector(which(coeff !=0)) else x.ind<-0
intercept=as.numeric(mean(y)-meanx%*%coeff)

out1<-list(fit=fit,st=st,mse=mse,x.ind=x.ind,coeff=coeff,intercept=intercept,object=object,
            bic2=bic2,step.bic2=step.bic2)


# adapt 输出结果名称
names(out1)
# 变量选择输出结果序号
out1$x.ind
# 保留五位小数
round(out1$coeff,4)

IMF8=t(round(out1$coeff,4))
IMF8



numeric_df <- data.frame(rbind(IMF1,))

# 指定要保存的Excel文件名
excel_file <- "adaptivelasso特征结果20240618.xlsx"
# 使用write.xlsx函数将数据框导出为Excel文件
write.xlsx(numeric_df, file = excel_file)
# 提示导出成功
cat("数据已成功导出到", excel_file, "\n")







###########################聚类 
setwd("D:/桌面文件/中南财经政法/期刊论文/基于分解-重构策略的神经网络预测大宗商品期货价格方法/20240613修改工程")
library(openxlsx)
data1 <- read.xlsx('聚类数据.xlsx',sheet=1)   


# 绘制8个IMF的相关系数矩阵图
library(corrplot)
m<-as.matrix(data1[,1:7])   #
r<-cor(m)
corrplot(r,order='AOE',addCoef.col='grey20')             

corrplot(r,type='upper',method='pie',order='AOE',tl.pos='d',cl.pos='b') # 上半角绘制圆
corrplot(r,add=TRUE,type='lower',method='number',order='AOE',diag=FALSE,tl.pos='n',cl.pos='n') # 下半角绘制相关系数

library(PerformanceAnalytics)#加载包
chart.Correlation(data1[,1:7], histogram=TRUE, pch=19)

# 聚类分析
cluster_month <- dist(scale(r[1:7]),method="euclidean")
hcluster_month <- hclust(cluster_month,method="ward.D2")
par(mai=c(0.6,0.8,0.5,0.8),cex=0.9)

plot(hcluster_month,cex=0.7,labels=c('IMF1','IMF2','IMF3','IMF4','IMF5','IMF6','Res'),hang=-0.1)
rect.hclust(hcluster_month,k=2)

x<-rect.hclust(hcluster_month,k=4)
x

# 根据聚类分析结果，对IMF进行重构，分为高中低频三项
## 此项工作在excel中完成，与直接输出没有太大差异，但由于如果只选择输出三项，则residual项没法很好的剥离趋势











