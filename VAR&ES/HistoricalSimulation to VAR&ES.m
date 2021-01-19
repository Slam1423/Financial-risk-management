% Historical simulation
%% ��ȡ����
format long
DJIA = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\�����ݽ��ڷ��չ���\\homework3\\HistoricalSimulation.xlsx', 'D4:D504');
FTSE = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\�����ݽ��ڷ��չ���\\homework3\\HistoricalSimulation.xlsx', 'H4:H504');
CAC40 = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\�����ݽ��ڷ��չ���\\homework3\\HistoricalSimulation.xlsx', 'L4:L504');
Nikkei = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\�����ݽ��ڷ��չ���\\homework3\\HistoricalSimulation.xlsx', 'P4:P504');
indexes = [DJIA'; FTSE'; CAC40'; Nikkei'];
%% ���濼�Ǽ���vn*v_i/v_(i-1)��Ӧ���ܹ��õ�500��scenarios
N = 500;
m = 4;
Portfolio = zeros(m, N);
for i = 1:m
    for j = 1:N
        Portfolio(i, j) = indexes(i,N+1)*indexes(i, j+1)/indexes(i, j);
    end
end
%% ��������scenario�µ�portfolio value��Ȼ��loss�Ӵ�С���򣬲�ȡ�����Ϊ���ǵ�99%Var��Ȼ������99%ES
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