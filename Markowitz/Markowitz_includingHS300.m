[data,txt] = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\大数据金融风险管理\\homework1\\HW1.xlsx');
n = size(txt);
date = char(txt(1,:));

% date
% for i=3:n(2)
%     if length(date(i,:)) ~= 8
%         '格式不统一'
%     end
% end

edate = zeros(1,10);
sdate = zeros(1,10);
startdate = {'201001','201006','201101','201106','201201','201206','201301','201306','201401','201406'};
startdate = char(startdate);
enddate = {'201501','201506','201601','201606','201701','201706','201801','201806','201901','201906'};
enddate = char(enddate);
t = 1;
s = 1;
for i=3:n(2)
    if t<=10 && ~isempty(regexp(date(i,:),enddate(t,:)))
        edate(t)=i-2;
        t = t+1;
    end
    if s<=10 && ~isempty(regexp(date(i,:),startdate(s,:)))
        sdate(s) = i-2;
        s = s+1;
    end
end

%下面我们计算每一只股票五年内的收益率r向量
%首先判断是否有数据缺失
% for num=1:51
%     for i=1:10
%         if isnan(data(num,sdate(i))) || isnan(data(num,edate(i)))
%             '有缺失'
%         end
%     end
% end
%经判断，在关键日期上有数据缺失，对缺失值我们进行等距离插值
ReturnMatrix = zeros(size(data));
for num=1:51
    temp = find(~isnan(data(num,:)));
    temp2 = find(isnan(data(num,:)));
    data(num,temp2) = interp1(temp,data(num,temp),temp2,'pchip');
end
%% 这样，我们用插值的方法补齐了股票价格数据，下面我们正式进入求解阶段。
%首先，我们计算每一只股票的价格变化情况（即收益率情况）,考虑每天连续收益率r=ln(P(t+1)/P(t))，则其年连续收益率为(1+r)^365-1。
retSeries = price2ret(data');
%下面计算这51只股票之间的协方差矩阵以及它们各自的期望收益，但是注意，这是要以五年为期限的。也就是说，一共应该有10个协方差矩阵和10个期望收益。
Covariance = zeros(10,n(1)-1,n(1)-1);
meanRet = zeros(10,n(1)-1);
for i=1:10
    s = sdate(i);
    t = edate(i);
    curdata = retSeries(s:t,:);
    Covariance(i,:,:) = cov(curdata);
    for num=1:51
        meanRet(i,num) = mean(curdata(:,num));
    end
end
meanRet = (ones(size(meanRet))+meanRet).^365-ones(size(meanRet));%将上面算出的平均日连续收益率转化为平均年连续收益率。
%% 现在我们拥有了协方差矩阵Covariance和平均收益率meanRet，下面进行凸二次规划求解最优投资组合。
H = 2*Covariance;
f = zeros(51,1);
A = zeros(51,51);
b = zeros(51,1);
Aeq = zeros(10,2,51);
for i=1:10
    Aeq(i,:,:) = [meanRet(i,:);ones(1,51)];
end
beq = [0.1,1];
weight = zeros(10,51);
for i=1:10
    now_H = reshape(H(i,:,:),51,51);
    now_Aeq = reshape(Aeq(i,:,:),2,51);
    weight(i,:) = quadprog(now_H,f,A,b,now_Aeq,beq);
end
%% 至此，我们成功得到了各时间段内应该采用的投资组合权重weight。下面，我们考虑画出我们的投资组合的净值曲线，设初始资金为10000元。
%从2015年初开始投资，到2019年末结束。
netvalue = zeros(n(2)-2-edate(1),1);%共投资1219天。
curweight = zeros(n(2)-2-edate(1),51);
warehouse = zeros(size(curweight));
curTime = 1;
Money = 10000;
netvalue(1) = Money;
for day=1:n(2)-2-edate(1)
    curweight(day,:) = weight(curTime,:);
    if curTime < 10 && day>edate(curTime+1)-edate(1)
        curweight(day,:) = weight(curTime+1,:);
        warehouse(day,:) = netvalue(day-1)*curweight(day,:);
        netvalue(day) = sum(warehouse(day,:));
        curTime = curTime+1;
    else
        if day == 1
            warehouse(day,:) = netvalue(day)*curweight(day,:);
        else
            warehouse(day,:) = warehouse(day-1,:).*exp(retSeries(day+edate(1)-1,:));
            netvalue(day) = sum(warehouse(day,:));
        end
    end
end
netvalue = netvalue/10000;
%再与HS300比较
HS300 = zeros(size(netvalue));
HS300(1) = 1;
for day=2:n(2)-2-edate(1)
    HS300(day) = HS300(day-1)*exp(retSeries(day+edate(1)-1,1));
end
plot(HS300,'r');
hold on
plot(netvalue,'b');
legend('HS300','Markowitz Portfolio')
xlabel('时间');
ylabel('投资组合净值');
set(gca,'xtick',linspace(0,1219,6));
set(gca,'XTicklabel',{'2015','2016','2017','2018','2019','2019/12/31'});
grid on
title('Markowitz Portfolio与HS300净值曲线对比')