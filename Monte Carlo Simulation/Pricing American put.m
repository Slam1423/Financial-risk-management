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
random_seed = 1112; %�̶��������
rng(random_seed)
Z = randn(b,m); %��׼��̬�ֲ������
%�������ǿ�������b�������˶�·����
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
    %��ȡ��tʱ��in the money����Щ��Ȩ��
    good_paths = find(H(:,t)>0);
    %���ڷ�good_paths����ʱ���迼�ǡ�
    %����good_paths��Ҫ�����Ƿ�exercise
    response = V(good_paths,t+1)*exp(-rf/m);
    explain = H(good_paths,t);
    p = polyfit(explain,response,Order);
    C = polyval(p,explain);
    exercise = logical(zeros(length(good_paths),1));
    exercise(good_paths) = H(good_paths,t)>C;
    V(exercise,t) = H(exercise,t);
    V(exercise,t+1:m+1) = 0;
    %tʱ�̵���0��V�Ӻ���ǰ���֡�
    discount_paths = find(V(:,t)==0);
    V(discount_paths, t) = V(discount_paths,t+1)*exp(-rf/m);
end
mean_V = mean(V(:,2));
AmericanPutPrice = mean_V*exp(-rf/m);
AmericanPutPrice