% Historical simulation
%% 读取数据
format long
DJIA = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\大数据金融风险管理\\homework3\\HistoricalSimulation.xlsx', 'D4:D504');
FTSE = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\大数据金融风险管理\\homework3\\HistoricalSimulation.xlsx', 'H4:H504');
CAC40 = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\大数据金融风险管理\\homework3\\HistoricalSimulation.xlsx', 'L4:L504');
Nikkei = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\大数据金融风险管理\\homework3\\HistoricalSimulation.xlsx', 'P4:P504');
indexes = [DJIA'; FTSE'; CAC40'; Nikkei'];
%% 下面考虑计算vn*v_i/v_(i-1)，应该能够得到500个scenarios
N = 500;
m = 4;
Portfolio = zeros(m, N);
for i = 1:m
    for j = 1:N
        Portfolio(i, j) = indexes(i,N+1)*indexes(i, j+1)/indexes(i, j);
    end
end
%% 下面计算各scenario下的portfolio value，然后将loss从大到小排序，并取第五个为我们的99%Var，然后计算出99%ES
Initial = 1e7;
values = zeros(N, 1);
loss = zeros(N, 1);
w = [5000, 2000, 2000, 1000]*1e3;
for i = 1:N
    cur = Portfolio(:, i)./indexes(:, N+1);
    values(i) = w*cur;
    loss(i) = Initial - values(i);
end
loss = sort(loss, 'descend');
prc = ceil(prctile(1:N, 99));
tail = loss(1:N-prc+2);
VaR = tail(length(tail));
ES = mean(tail);
TenDayVaR = VaR*sqrt(10);
TenDayES = ES*sqrt(10);
sprintf('The 10-day 99 percent VaR is $%.4f and the 10-day 99 percent ES is $%.4f.',TenDayVaR,TenDayES)