y = sort(weight,2,'descend');
y = y(1:2:9,1:3);
b=bar(y,'r','g','y');
ch = get(b,'children');
grid on;
set(gca,'XTickLabel',{'2015/01','2016/01','2017/01','2018/01','2019/01'})
xlabel('ʱ��');
ylabel('Ȩ��');
set(ch{1},'FaceColor',[1 0 0])
set(ch{2},'FaceColor',[0 1 0])
set(ch{3},'FaceColor',[0 0 1])
legend([ch{1},ch{2},ch{3}],'HS300Ȩ��ֵ','�ڶ��ߵ�Ȩ��ֵ','�����ߵ�Ȩ��ֵ');