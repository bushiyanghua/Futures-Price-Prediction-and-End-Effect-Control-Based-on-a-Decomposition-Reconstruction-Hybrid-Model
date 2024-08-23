function [IW,B,LW,TF,TYPE] = elmtrain(P,T,N,TF,TYPE,lambda)
% ELM训练，带L2正则化
% [IW,B,LW,TF,TYPE] = elmtrain(Pn_train,Tn_train,30,'sig',0,0.01);
% Description
% Input
% P      - Input Matrix of Training Set  (R*Q)
% T      - Output Matrix of Training Set (S*Q)
% N      - Number of Hidden Neurons (default = Q)
% TF     - Transfer Function:
%          'sig' for Sigmoidal function (default)
%          'sin' for Sine function
%          'hardlim' for Hardlim function
% TYPE   - Regression (0,default) or Classification (1)
% lambda - Regularization parameter (default = 0)
% Output
% IW     - Input Weight Matrix (N*R)
% B      - Bias Matrix (N*1)
% LW     - Output Weight Matrix (S*N)
% TF     - Transfer Function
% TYPE   - Regression or Classification

if nargin < 2
    error('ELM:Arguments','Not enough input arguments.');
end
if nargin < 3
    N = size(P,2);
end

if nargin < 4
    TF = 'sig';
end

if nargin < 5
    TYPE = 0;
end

if nargin < 6
    lambda = 0;
end

if size(P,2) ~= size(T,2)
    error('ELM:Arguments','The columns of P and T must be same.');
end

[R,Q] = size(P);
if TYPE == 1
    T = ind2vec(T);
end

[S,Q] = size(T);
% 随机产生输入权重矩阵
IW = rand(N,R) * 2 - 1;
% 随机产生偏置矩阵
B = rand(N,1);
BiasMatrix = repmat(B,1,Q);
% 计算隐藏层输出矩阵
tempH = IW * P + BiasMatrix;
switch TF
    case 'sig'
        H = 1 ./ (1 + exp(-tempH));
    case 'sin'
        H = sin(tempH);
    case 'hardlim'
        H = hardlim(tempH);
end

% 加入正则化项计算输出权重矩阵
I = eye(size(H,1)); % 单位矩阵，用于正则化
LW = (H * H' + lambda * I) \ (H * T');

end
