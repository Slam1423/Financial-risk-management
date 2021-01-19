% Pricing Asian call option.
%% The input parameters
k = 30;
S0 = 30;
T = 1;
sigma = 0.35;
rf = 0.03;
b = 10000;
m = 252;
%% Second, we  generate the b Geometric Brownian Motion paths that we need.
random_seed = 1000; %固定随机种子
rng(random_seed)
Z = randn(b,m); %标准正态分布随机数
%下面我们考虑生成b个布朗运动路径。
S = zeros(b,m+1);
S(:,1) = S0;
for i = 1:b
    for j = 2:m+1
        S(i,j) = S(i,j-1)*exp((rf-sigma^2/2)/m+sigma*sqrt(1/m)*Z(i,j-1));
    end
end
%% Then we move on to calculate the discounted value on each path.
netvalue = zeros(b,1);
for i = 1:b
    mean_s = mean(S(i,2:m+1));
    netvalue(i) = exp(-rf*T)*max(mean_s-k,0);
end
%% Finally we calculate its price and 95% confidence interval.
expected_value = mean(netvalue);
stdd = std(netvalue);
z = norminv(0.975,0,1);
lb = expected_value-z*stdd/sqrt(b);
ub = expected_value+z*stdd/sqrt(b);
sprintf('The Asian call option price is %.4f, with the 95 percent confidence interval [%.4f,%.4f].',expected_value,lb,ub)