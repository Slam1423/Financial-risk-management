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
random_seed = 10220; %�̶��������
rng(random_seed)
Z = randn(b,m); %��׼��̬�ֲ������,�����Z(i, 1)�������������likelihood ratio��������Ҫ��Z_1��
%�������ǿ�������b�������˶�·����
S = zeros(b,m+1);
S(:,1) = S0;
for i = 1:b
    for j = 2:m+1
        S(i,j) = S(i,j-1)*exp((rf-sigma^2/2)/m+sigma*sqrt(1/m)*Z(i,j-1));
    end
end
%% �������������˱���ʲ��ļ۸�·�����������ǿ�������pathwise�������Delta��
thesum = 0;
for i = 1:b
    temp = mean(S(i, 2:m+1));
    if temp >= k
        thesum = thesum + temp*exp(-rf*T)/S0;
    end
end
Delta = thesum/b;
Delta
%% ����������Likelihood ratio�������Gamma��
thesum = 0;
for i = 1:b
    temp = mean(S(i, 2:m+1));
    if temp >= k
        thesum = thesum + exp(-rf*T)*temp*Z(i, 1)/(S0*S0*sigma*sqrt(1/m));
    end
end
Gamma = thesum/b;
Gamma
%% ����������pathwise�������Vega��
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