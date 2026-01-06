function fig = scatter3(R2_1,Bias1,RMSE1,RRMSE1,x,y,VIvalue,Laimeasured,x_inition,x_radius,y_inition,y_radius,VI_name)
%交叉验证结果散点图,对应zhishufa.m
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
ylabel('LAI simulated','fontsize',5.5,'FontName','Times New Roman','FontWeight','bold');
box on;%周围有边框
hold on;
%%  开始画图，先画拟合线
% a = 0:0.01:8;
% b = 1./(1.1562+15.1875.*exp(-a));
%plot(a,b,'-','Color','#0164FF','LineWidth',0.5);
%plot(x, y,'k-','LineWidth',1);
%plot(x,yfit,'-','Color','#0164FF','LineWidth',0.5);
%hold on;
%%  再画1:1的线
%plot([0:x_radius],[0:4],'k--','LineWidth',0.5); %k代表黑色，-代表实线
%%  最后画散点
%%  使用核密度估计计算 LAI 和 VI 的二维密度
% 使用 ksdensity 对二维数据进行核密度估计
[f,xi] = mvksdensity([VIvalue, Laimeasured], [VIvalue, Laimeasured], 'Bandwidth', 0.1);  % 你可以根据需要调整带宽
% 归一化 f 值到 1~256 之间
f_min = min(f);
f_max = max(f);
idx = round((f - f_min) / (f_max - f_min) * 255) + 1;  % 归一化到 1~256
idx = min(max(idx, 1), 256);  % 防止超出索引范围
% 获取 256 色的 colormap
colors=slanCM(100);
color_map = colors(idx, :);  % 选取对应的 RGB 颜色

% 绘制散点图
scatter(VIvalue, Laimeasured, 2, color_map,'HandleVisibility', 'off');
plot(x, y,'LineWidth',1,'Color', '#FF5A6B','DisplayName', 'Fitting line');
h1 = legend('Location', 'NorthWest'); % 直接创建图例，自动获取拟合线的DisplayName
h1.AutoUpdate = 'off'; % 防止后续元素覆盖图例
h1.ItemTokenSize = [10,10]; % 调整图例线段长度
set(h1, 'Box', 'off'); % 去掉图例边框
%plot(VIvalue,Laimeasured,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#497BC6','MarkerFaceColor','w');
% plot(x1,y1,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#F79B12','MarkerFaceColor','w');
% plot(x2,y2,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#0164FF','MarkerFaceColor','w');
% plot(x3,y3,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#840000','MarkerFaceColor','w');
% plot(x4,y4,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#00E71D','MarkerFaceColor','w');
% plot(x5,y5,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#FF2160','MarkerFaceColor','w');
% plot(x6,y6,'ko',  'MarkerSize',2, 'MarkerEdgeColor','#672CC6','MarkerFaceColor','w');
hold on;
%%  一些标注
%定义一下Bias可能出现-0.000的情况
Bias1=round(Bias1,3);
if abs(Bias1)==0
    Bias1=0.000;
end
str0=sprintf('N=500');
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

end

