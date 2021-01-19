% Pricing American put option.
%% The input parameters
k = 30;
S0 = 30;
T = 1;
sigma = 0.35;
rf = 0.03;
b = 10000;
m = 252;
Order = 4;
%% Second, we  generate the b Geometric Brownian Motion paths that we need.
random_seed = 1112; %固定随机种子
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
H = k-S;
%% Third, we consider using backward induction to calculate the American put option price.
V = zeros(b,m+1);
V(:,m+1) = max(k-S(:,m+1),0);
for t = m:-1:2
    %先取出t时刻in the money的那些期权。
    good_paths = find(H(:,t)>0);
    %对于非good_paths的暂时不予考虑。
    %对于good_paths的要考虑是否exercise
    response = V(good_paths,t+1)*exp(-rf/m);
    explain = H(good_paths,t);
    p = polyfit(explain,response,Order);
    C = polyval(p,explain);
    exercise = logical(zeros(length(good_paths),1));
    exercise(good_paths) = H(good_paths,t)>C;
    V(exercise,t) = H(exercise,t);
    V(exercise,t+1:m+1) = 0;
    %t时刻等于0的V从后往前折现。
    discount_paths = find(V(:,t)==0);
    V(discount_paths, t) = V(discount_paths,t+1)*exp(-rf/m);
end
mean_V = mean(V(:,2));
AmericanPutPrice = mean_V*exp(-rf/m);
AmericanPutPrice