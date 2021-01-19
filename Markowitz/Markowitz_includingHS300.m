[data,txt] = xlsread('C:\\Users\\lenovo\\Desktop\\term1\\�����ݽ��ڷ��չ���\\homework1\\HW1.xlsx');
n = size(txt);
date = char(txt(1,:));

% date
% for i=3:n(2)
%     if length(date(i,:)) ~= 8
%         '��ʽ��ͳһ'
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

%�������Ǽ���ÿһֻ��Ʊ�����ڵ�������r����
%�����ж��Ƿ�������ȱʧ
% for num=1:51
%     for i=1:10
%         if isnan(data(num,sdate(i))) || isnan(data(num,edate(i)))
%             '��ȱʧ'
%         end
%     end
% end
%���жϣ��ڹؼ�������������ȱʧ����ȱʧֵ���ǽ��еȾ����ֵ
ReturnMatrix = zeros(size(data));
for num=1:51
    temp = find(~isnan(data(num,:)));
    temp2 = find(isnan(data(num,:)));
    data(num,temp2) = interp1(temp,data(num,temp),temp2,'pchip');
end
%% �����������ò�ֵ�ķ��������˹�Ʊ�۸����ݣ�����������ʽ�������׶Ρ�
%���ȣ����Ǽ���ÿһֻ��Ʊ�ļ۸�仯������������������,����ÿ������������r=ln(P(t+1)/P(t))������������������Ϊ(1+r)^365-1��
retSeries = price2ret(data');
%���������51ֻ��Ʊ֮���Э��������Լ����Ǹ��Ե��������棬����ע�⣬����Ҫ������Ϊ���޵ġ�Ҳ����˵��һ��Ӧ����10��Э��������10���������档
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
meanRet = (ones(size(meanRet))+meanRet).^365-ones(size(meanRet));%�����������ƽ��������������ת��Ϊƽ�������������ʡ�
%% ��������ӵ����Э�������Covariance��ƽ��������meanRet���������͹���ι滮�������Ͷ����ϡ�
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
%% ���ˣ����ǳɹ��õ��˸�ʱ�����Ӧ�ò��õ�Ͷ�����Ȩ��weight�����棬���ǿ��ǻ������ǵ�Ͷ����ϵľ�ֵ���ߣ����ʼ�ʽ�Ϊ10000Ԫ��
%��2015�����ʼͶ�ʣ���2019��ĩ������
netvalue = zeros(n(2)-2-edate(1),1);%��Ͷ��1219�졣
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
%����HS300�Ƚ�
HS300 = zeros(size(netvalue));
HS300(1) = 1;
for day=2:n(2)-2-edate(1)
    HS300(day) = HS300(day-1)*exp(retSeries(day+edate(1)-1,1));
end
plot(HS300,'r');
hold on
plot(netvalue,'b');
legend('HS300','Markowitz Portfolio')
xlabel('ʱ��');
ylabel('Ͷ����Ͼ�ֵ');
set(gca,'xtick',linspace(0,1219,6));
set(gca,'XTicklabel',{'2015','2016','2017','2018','2019','2019/12/31'});
grid on
title('Markowitz Portfolio��HS300��ֵ���߶Ա�')