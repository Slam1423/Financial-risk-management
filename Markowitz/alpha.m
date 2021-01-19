%% ���ȣ�����֮ǰ�Ĺ�������
load HW1_1;
%% ���ǿ���ѡȡǰ��ֻ��Ʊ������֤ȯ����ͬúҵ������ʵҵ�����ֹɷݡ����������
stocks = {'����֤ȯ','��ͬúҵ','����ʵҵ','���ֹɷ�','�������'};
select_stocks = retSeries(:,2:6);
HS300 = retSeries(:,1)-log(1.03)/365*ones(size(select_stocks(:,1)));
%% ���棬�ֱ�ÿһֻ��Ʊ�뻦��300ָ�����ع鲢����t������alpha���������䡣
b = zeros(2,5);
bint = zeros(5,2,2);
for i=1:5
    curstock = select_stocks(:,i)-log(1.03)/365*ones(size(select_stocks(:,1)));
    curstock = 365*curstock;
    X = [ones(size(HS300)),HS300*365];
    [b(:,i),bint(i,:,:),r,rint,states] = regress(curstock,X,0.05);
end
%% �������Ǵ�ӡ��ÿһֻ��Ʊ��HS300���ع�õ���alpha��0.95���Ŷ�ˮƽ���������䡣
for i=1:5
    estimate = b(1,i);
    lb = bint(i,1,1);
    ub = bint(i,1,2);
    sprintf('%s��betaֵΪ%.4f��alpha����ֵΪ%.4f��alpha��0.95���Ŷ�ˮƽ�µ���������Ϊ[%.4f,%.4f]\n',char(stocks(i)),b(2,i),estimate,lb,ub)
end
%���Ƿ��֣����˴�ͬúҵ��alpha�����������Ϊ-0.0001��û�дﵽ0�⣬����4ֻ��Ʊ����������ȫ������0����Ҳӡ֤��CAPMģ�͵���Ч�ԡ�