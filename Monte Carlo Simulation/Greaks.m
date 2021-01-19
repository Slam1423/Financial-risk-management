% Computing Asian call option's Greeks.
%% The input parameters
k = 30;
S0 = 30;
T = 1;
sigma = 0.35;
rf = 0.03;
b = 10000;
m = 252;
%% Second, we  generate the b Geometric Brownian Motion paths that we need.
random_seed = 10220; %固定随机种子
rng(random_seed)
Z = randn(b,m); %标准正态分布随机数,这里的Z(i, 1)就是我们下面的likelihood ratio方法中需要的Z_1。
%下面我们考虑生成b个布朗运动路径。
S = zeros(b,m+1);
S(:,1) = S0;
for i = 1:b
    for j = 2:m+1
        S(i,j) = S(i,j-1)*exp((rf-sigma^2/2)/m+sigma*sqrt(1/m)*Z(i,j-1));
    end
end
%% 以上我们生成了标的资产的价格路径，下面我们考虑利用pathwise方法求解Delta。
thesum = 0;
for i = 1:b
    temp = mean(S(i, 2:m+1));
    if temp >= k
        thesum = thesum + temp*exp(-rf*T)/S0;
    end
end
Delta = thesum/b;
Delta
%% 下面我们用Likelihood ratio方法求解Gamma。
thesum = 0;
for i = 1:b
    temp = mean(S(i, 2:m+1));
    if temp >= k
        thesum = thesum + exp(-rf*T)*temp*Z(i, 1)/(S0*S0*sigma*sqrt(1/m));
    end
end
Gamma = thesum/b;
Gamma
%% 下面我们用pathwise方法求解Vega。
thesum = 0;
for i = 1:b
    S_bar = 0;
    temp = mean(S(i, 1:m+1));
    for j =2:m+1
        if temp >= k
            curz = (log(S(i, j))-log(S(i, 1))-(rf-sigma^2/2)*(j-1)/m)/(sigma*sqrt((j-1)/m));
            cur = S(i, j)*(-sigma*(j-1)/m+sqrt((j-1)/m)*curz);
            %partial_S_sigma = S(i, j)*(-sigma*(j-1)/m+sqrt(1/m)*sum(Z(i, 1:j-1)));
            %cur = S(i, 1)
            S_bar = S_bar + cur;
        end
    end
    S_bar = S_bar/m;
    thesum = thesum + S_bar;
end
Vega = thesum/b;
Vega