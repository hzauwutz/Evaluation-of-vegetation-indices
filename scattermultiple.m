function fig = scattermultiple(R2_1,Bias1,RMSE1,RRMSE1,x,y,x_inition,x_radius,y_inition,y_radius,VI_name,number1,LAI1,LAI2,LAI3,VIvalue1,VIvalue2,VIvalue3)
%交叉验证结果散点图,对应zhishufa.m
%%  首先进行线性拟合，得到拟合后的yfit
% p=polyfit(x,y,1);
% yfit=polyval(p,x);
%%  设置画布一些属性
set(0,'ScreenPixelsPerInch',400);
fig=figure('Color','white','Position',[0 0 2400 2400],'PaperSize',[4 4],'PaperPosition',[0,0,2.5,2.5],'Visible','off');
axes('pos',[0.15 0.18 0.75 0.75]); %posx,posy,width,height
hold on;
%%  设置具体一些刻度
set(gca,'fontsize',4.5);%整体字体的大小
axis([x_inition x_radius y_inition y_radius]);      %xy轴的范围
step1=(x_radius-x_inition)/5;
step2=step1/2;
set(gca,'xtick',(x_inition:step1:x_radius),'FontName','Times New Roman');
set(gca,'ytick',(y_inition:1:y_radius),'FontName','Times New Roman');
set(gca,'xminortick','on','yminortick','on');%打开副刻度
ax=gca;
ax.XAxis.MinorTickValues=x_inition:step2:x_radius;  %设置副刻度的间隔
ax.YAxis.MinorTickValues=y_inition:0.5:y_radius;
xlabel(VI_name,'fontsize',5.5,'FontName','Times New Roman','FontWeight','bold')%,'fontsize',3);%加粗的话是fonweight bold
ylabel('LAI measured','fontsize',5.5,'FontName','Times New Roman','FontWeight','bold');
box on;%周围有边框
hold on;
%%  开始画图，先画拟合线
% a = 0:0.01:8;
% b = 1./(1.1562+15.1875.*exp(-a));
%plot(a,b,'-','Color','#0164FF','LineWidth',0.5);
% plot(x, y,'k-','LineWidth',1);
% %%  再画1:1的线
% h1=legend('Fitting line','Location','NorthWest');
% h1.AutoUpdate = 'off';%不然它自动更新图例了，把前面的线加上去以后再画散点
% h1.ItemTokenSize = [10,10];%调整图例的线段长短
% set(h1,'Box','off');%去掉边框
%%  最后画散点
%plot(VIvalue,Laimeasured,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#497BC6','MarkerFaceColor','w');
plot(VIvalue1,LAI1,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#E56F47','MarkerFaceColor','w','HandleVisibility','off');
plot(VIvalue2,LAI2,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#FCEEA7','MarkerFaceColor','w','HandleVisibility','off');
plot(VIvalue3,LAI3,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#9EC3DE','MarkerFaceColor','w','HandleVisibility','off');
% plot(x4,y4,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#00E71D','MarkerFaceColor','w');
% plot(x5,y5,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#FF2160','MarkerFaceColor','w');
% plot(x6,y6,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#672CC6','MarkerFaceColor','w');
plot(x, y,'k-','LineWidth',0.5,'DisplayName', 'Fitting line');
h1 = legend('Location', 'NorthWest'); % 直接创建图例，自动获取拟合线的DisplayName
h1.AutoUpdate = 'off'; % 防止后续元素覆盖图例
h1.ItemTokenSize = [10,10]; % 调整图例线段长度
set(h1, 'Box', 'off'); % 去掉图例边框
hold on;
%%  一些标注
%定义一下Bias可能出现-0.000的情况
Bias1=round(Bias1,3);
if abs(Bias1)==0
    Bias1=0.000;
end
str0=sprintf('N=%d',number1);
str1=sprintf('R^2=%0.3f',R2_1);%表示小数点后保留三位
str2=sprintf('Bias=%0.3f',Bias1);
str3=sprintf('RMSE=%0.3f',RMSE1);
str4=sprintf('RRMSE=%0.1f%%',RRMSE1);

x_text = x_radius * 0.99;
y_text_start = y_inition+0.3; % 右下角开始的y坐标
y_text_step = 0.33;  % 每个标注之间的间隔
text(0.98, 0.06, str4, 'FontSize', 5,'Units','normalized', 'HorizontalAlignment', 'right','FontName','Times New Roman');
text(0.98, 0.15, str3, 'FontSize', 5,'Units','normalized', 'HorizontalAlignment', 'right','FontName','Times New Roman');
text(0.98, 0.24, str2, 'FontSize', 5,'Units','normalized', 'HorizontalAlignment', 'right','FontName','Times New Roman');
text(0.98, 0.33, str1, 'FontSize', 5, 'Units','normalized','HorizontalAlignment', 'right','FontName','Times New Roman');
text(0.98, 0.42, str0, 'FontSize', 5,'Units','normalized', 'HorizontalAlignment', 'right','FontName','Times New Roman');

% text(x_text, y_text_start, str4, 'FontSize', 5, 'HorizontalAlignment', 'right','FontName','Times New Roman');
% text(x_text, y_text_start + y_text_step, str3, 'FontSize', 5, 'HorizontalAlignment', 'right','FontName','Times New Roman');
% text(x_text, y_text_start + 2 * y_text_step, str2, 'FontSize', 5, 'HorizontalAlignment', 'right','FontName','Times New Roman');
% text(x_text, y_text_start + 3 * y_text_step, str1, 'FontSize', 5, 'HorizontalAlignment', 'right','FontName','Times New Roman');
% text(x_text, y_text_start + 4 * y_text_step, str0, 'FontSize', 5, 'HorizontalAlignment', 'right','FontName','Times New Roman');
% if Bias1<0
%     text(x_radius*0.81,3*0.39,str0,'FontSize',5,'FontName','Times New Roman');
%     text(x_radius*0.75,3*0.31,str1,'FontSize',5,'FontName','Times New Roman');
%     text(x_radius*0.69,3*0.23,str2,'FontSize',5,'FontName','Times New Roman');%Bias为负
%     text(x_radius*0.65,3*0.15,str3,'FontSize',5,'FontName','Times New Roman');
%     text(x_radius*0.59,3*0.07,str4,'FontSize',5,'FontName','Times New Roman');
% else
%     text(x_radius*0.81,3*0.39,str0,'FontSize',5,'FontName','Times New Roman');
%     text(x_radius*0.75,3*0.31,str1,'FontSize',5,'FontName','Times New Roman');
%     text(x_radius*0.71,3*0.23,str2,'FontSize',5,'FontName','Times New Roman');%Bias为正
%     text(x_radius*0.65,3*0.15,str3,'FontSize',5,'FontName','Times New Roman');
%     text(x_radius*0.59,3*0.07,str4,'FontSize',5,'FontName','Times New Roman');
end
%set(h1,'Orientation','horizon','Box','off');
%title('NDVI','FontSize',6,'FontName','Times New Roman');
