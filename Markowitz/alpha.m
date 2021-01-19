%% 首先，加载之前的工作区。
load HW1_1;
%% 我们考虑选取前五只股票：招商证券、大同煤业、晋亿实业、柳钢股份、重庆钢铁。
stocks = {'招商证券','大同煤业','晋亿实业','柳钢股份','重庆钢铁'};
select_stocks = retSeries(:,2:6);
HS300 = retSeries(:,1)-log(1.03)/365*ones(size(select_stocks(:,1)));
%% 下面，分别将每一只股票与沪深300指数做回归并利用t检验求alpha的置信区间。
b = zeros(2,5);
bint = zeros(5,2,2);
for i=1:5
    curstock = select_stocks(:,i)-log(1.03)/365*ones(size(select_stocks(:,1)));
    curstock = 365*curstock;
    X = [ones(size(HS300)),HS300*365];
    [b(:,i),bint(i,:,:),r,rint,states] = regress(curstock,X,0.05);
end
%% 下面我们打印出每一只股票与HS300做回归得到的alpha的0.95置信度水平的置信区间。
for i=1:5
    estimate = b(1,i);
    lb = bint(i,1,1);
    ub = bint(i,1,2);
    sprintf('%s的beta值为%.4f，alpha估计值为%.4f，alpha的0.95置信度水平下的置信区间为[%.4f,%.4f]\n',char(stocks(i)),b(2,i),estimate,lb,ub)
end
%我们发现，除了大同煤业的alpha置信区间最高为-0.0001，没有达到0外，其它4只股票的置信区间全部包含0。这也印证了CAPM模型的有效性。