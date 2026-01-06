%%此代码功能为，验证不同植被指数联合全生育期反演LAI的结果，根据RMSE最小原则，找到每种植被指数联合多生育期的最佳拟合方式，并绘制结果图
%%
%01 导入数据路径，以及结果图保存的路径
clear;clc;
dataPath='D:\03 硕士第一阶段研究\中间过程数据\03查找表生成\01simulation_results\0828\01Directional_reflectance_bg_0828_Sentinel-2.txt';
OutPathName='D:\03 硕士第一阶段研究\结果图\03指数拟合结果\01\有背景_0828';
%%
%02 导入相关数据，提取反射率
T = readtable(dataPath, 'Delimiter', ',', 'ReadVariableNames', false);
A = table2array(T);%原始LAI、反射率的数据
A=A';
LAI=A(2:end,2);
number=length(LAI);%LAI实测数据的个数
blue=A(2:end,5);
green=A(2:end,6);
red=A(2:end,7);
re1=A(2:end,8);
re2=A(2:end,9);
re3=A(2:end,10);
nir=A(2:end,11);
re4=A(2:end,12);
sw1=A(2:end,15);
sw2=A(2:end,16);
%%
%03 准备30种植被指数矩阵
%第一类
VI_struct = struct('name', {}, 'formula', {});
VI_struct(1).name='RVI';VI_struct(1).formula=nir./red;
VI_struct(2).name='GRVI';VI_struct(2).formula=nir./green;
VI_struct(3).name='DVI';VI_struct(3).formula=nir-red;
VI_struct(4).name='CIgreen';VI_struct(4).formula=nir./green-1;
VI_struct(5).name='NGI';VI_struct(5).formula=green./(green+red+blue);
VI_struct(6).name='NDVI';VI_struct(6).formula=(nir-red)./(nir+red);
VI_struct(7).name='GNDVI';VI_struct(7).formula=(nir-green)./(nir+green);
VI_struct(8).name='RDVI';VI_struct(8).formula=(nir-red)./sqrt(nir+red);
VI_struct(9).name='SWIRR';VI_struct(9).formula=sw1./sw2;
VI_struct(10).name='NDWI';VI_struct(10).formula=(nir-sw2)./(nir+sw2);
%第二类
VI_struct(11).name='CIre1';VI_struct(11).formula=nir./re1-1;
VI_struct(12).name='CIre2';VI_struct(12).formula=nir./re2-1;
VI_struct(13).name='CI3re';VI_struct(13).formula=(re3-(0.3*re1+0.7*re2))./(0.3*re1+0.7*re2);
VI_struct(14).name='NDVIre1';VI_struct(14).formula=(nir-re1)./(nir+re1);
VI_struct(15).name='NDVIre2';VI_struct(15).formula=(nir-re2)./(nir+re2);
VI_struct(16).name='NDVI3re';VI_struct(16).formula=(re3-(0.3*re1+0.7*re2))./(re3+(0.3*re1+0.7*re2));
VI_struct(17).name='REDVI';VI_struct(17).formula=nir-re1;
VI_struct(18).name='MEVI';VI_struct(18).formula=(2.5*(nir-re1))./(nir+6*re1-7.5*blue+1);
VI_struct(19).name='MSRre';VI_struct(19).formula=(nir./re1-1)./sqrt(nir./re1+1);
VI_struct(20).name='CIVI';VI_struct(20).formula=((nir - red) .* (nir - re1) .* (re2 - red))./((nir + red) .* (re2 - re1));
%第三类
VI_struct(21).name='SAVI';VI_struct(21).formula=1.5*(nir-red)./(nir+red+0.5);
VI_struct(22).name='MSAVI';VI_struct(22).formula=1.5*(nir-red)./(nir+red)+0.5;
VI_struct(23).name='EVI';VI_struct(23).formula=2.5*(nir-red)./(nir+6*red-7.5*blue+1);
VI_struct(24).name='EVI2';VI_struct(24).formula=2.5*(nir-red)./(nir+2.4*red+1);
VI_struct(25).name='OSAVI';VI_struct(25).formula=1.16*(nir-red)./(nir+red+0.16);
VI_struct(26).name='SARVI';VI_struct(26).formula=1.5*(nir-2*red+blue)./(nir+2*red-blue+0.5);
VI_struct(27).name='SARE';VI_struct(27).formula=(1.25*(nir-re1))./(nir+re1+0.25);
VI_struct(28).name='SAVIgreen';VI_struct(28).formula=1.5*(nir-green)./(red+green+0.5);
VI_struct(29).name='MTVI1';VI_struct(29).formula=1.2*(1.2*(nir-green)-2.5*(red-green));
VI_struct(30).name='MTVI2';VI_struct(30).formula=(1.5*(1.2*(nir-green)-2.5*(red-green)))./sqrt((2*nir+1).^2-(6*nir-5*sqrt(red))-0.5);
num_indices=length(VI_struct);

%查询一下有没有负数的
VI_search = struct('name', {}, 'index', {});
for i=1:num_indices
    currentname=VI_struct(i).name;
    currentformula=VI_struct(i).formula;
    negativeindices=find(currentformula<=0);
    if ~isempty(negativeindices)
        VI_search(i).name=currentname;
        VI_search(i).index=negativeindices;
    end
end
finalresults = struct( 'VI',{},'fittingform', {}, 'R2', [], 'RMSE', [], 'RRMSE', [], 'Bias', [],'VIvalue',[],'Laimeasured',[],'Laiestimated',[]);
%%
%04 开始拟合循环
for idx=1:num_indices
    VI_name=VI_struct(idx).name;
    VI=VI_struct(idx).formula;
    %%
    %05 拟合形式以及初始参数设置
    % 2. 指数拟合
    exponential_model = @(beta, x) beta(1) * exp(beta(2) * x);
    exponential_start = [1, 0.1]; % 初始参数估计
    % 3. 对数拟合
    logarithmic_model = @(beta, x) beta(1) * log(beta(2) * x);
    logarithmic_start = [1,10]; % 初始参数估计对于无背景的范围是：[1,5]
    % 4. 幂拟合
    power_model = @(beta, x) beta(1) * x.^beta(2);
    power_start = [1, 1]; % 初始参数估计
    %%
    %06 开始进行留一法交叉验证
    cv = cvpartition(length(LAI), 'LeaveOut');% 创建一个用于留一法验证的交叉验证分区
    results = cell(cv.NumTestSets, 1);% 初始化用于存储每次留一验证结果的单元格数组
    fittingforms={'线性拟合', '指数拟合', '对数拟合', '幂拟合'};
    % 初始化用于存储拟合结果的数组
    linear_rmse = zeros(cv.NumTestSets, 1);
    exponential_rmse = zeros(cv.NumTestSets, 1);
    logarithmic_rmse = zeros(cv.NumTestSets, 1);
    power_rmse = zeros(cv.NumTestSets, 1);
    % 进行留一法验证
    for i = 1:cv.NumTestSets
        trainIdx = cv.training(i);
        testIdx = cv.test(i);
        % 分割数据
        VI_train = VI(trainIdx);
        LAI_train = LAI(trainIdx);
        VI_test = VI(testIdx);
        LAI_test = LAI(testIdx);
        % 计算拟合结果
        linear_fit_i = fitlm(VI_train, LAI_train);
        exponential_fit_i = fitnlm(VI_train, LAI_train, exponential_model, exponential_start);
        logarithmic_fit_i = fitnlm(VI_train, LAI_train, logarithmic_model, logarithmic_start);
        power_fit_i = fitnlm(VI_train, LAI_train, power_model, power_start);
        % 保存每次留一验证的结果
        result.VI_test = VI_test;
        result.LAI_test = LAI_test;
        result.linear_predictions = predict(linear_fit_i, VI_test);
        result.exponential_predictions = predict(exponential_fit_i, VI_test);
        result.logarithmic_predictions = predict(logarithmic_fit_i, VI_test);
        result.power_predictions = predict(power_fit_i, VI_test);
        % 将结果存储在单元格数组中
        results{i} = result;
        % 计算RMSE
        linear_rmse(i) = sqrt(mean((LAI_test - result.linear_predictions).^2));
        exponential_rmse(i) = sqrt(mean((LAI_test - result.exponential_predictions).^2));
        logarithmic_rmse(i) = sqrt(mean((LAI_test - result.logarithmic_predictions).^2));
        power_rmse(i) = sqrt(mean((LAI_test - result.power_predictions).^2));
    end
    %%
    %07 计算一些指标
    % 计算每种拟合形式的平均RMSE
    avg_linear_rmse = mean(linear_rmse);
    avg_exponential_rmse = mean(exponential_rmse);
    avg_logarithmic_rmse = mean(logarithmic_rmse);
    avg_power_rmse = mean(power_rmse);
    % 输出结果
    disp('线性拟合结果:');
    disp(['平均RMSE: ', num2str(avg_linear_rmse)]);
    disp('指数拟合结果:');
    disp(['平均RMSE: ', num2str(avg_exponential_rmse)]);
    disp('对数拟合结果:');
    disp(['平均RMSE: ', num2str(avg_logarithmic_rmse)]);
    disp('幂拟合结果:');
    disp(['平均RMSE: ', num2str(avg_power_rmse)]);
    %%
    %08 将留一验证每次预测的结果保存，便于计算最终的R2以及RRMSE和Bias
    Leavout_predictions=zeros(number,10);
    Leavout_specficpredictions=zeros(number,3);
    Leavout_bestpredictions=zeros(number,3);
    for m=1:number
        Leavout_predictions(m,1)=results{m,1}.VI_test;
        Leavout_predictions(m,2)=results{m,1}.LAI_test;
        Leavout_predictions(m,3)=results{m,1}.linear_predictions;
        Leavout_predictions(m,4)=results{m,1}.exponential_predictions;
        Leavout_predictions(m,5)=results{m,1}.logarithmic_predictions;
        Leavout_predictions(m,6)=results{m,1}.power_predictions;
    end
    Leavout_predictions=sortrows(Leavout_predictions,2);%根据LAI实测值进行一次排序，第一列是VI值，第二列是LAI实测值，后面四列依次是四种拟合形式的留一预测值
    %%
    %10 如果确认无误，RMSE最小的同时R方也是最大的，那么就选择RMSE最小的拟合方式
    [min_rmse, min_rmse_index] = min([avg_linear_rmse, avg_exponential_rmse, avg_logarithmic_rmse, avg_power_rmse]);
    % 根据最小RMSE的拟合方式进行拟合
    switch min_rmse_index
        case 1
            chosen_fit = linear_fit_i;
        case 2
            chosen_fit = exponential_fit_i;
        case 3
            chosen_fit = logarithmic_fit_i;
        case 4
            chosen_fit = power_fit_i;
    end
    % 选择自变量范围，可以根据实际数据进行调整
    min_VI = min(VI);  % 自变量的最小值
    max_VI = max(VI);  % 自变量的最大值
    min_LAI=min(LAI);
    max_LAI=max(LAI);
    step = 0.01;       % 步长
    % 创建自变量向量
    VI_range = min_VI:step:max_VI;
    VI_range = VI_range';%因为是因变量，为了后面绘制拟合曲线所以需要转置一下
    % 计算拟合曲线的因变量值
    % 这里使用所选的拟合方式 chosen_fit
    LAI_estimated = predict(chosen_fit, VI_range);%为了绘制拟合曲线计算的因变量
    %%
    %11 准备一些原始数据，计算最优拟合方式精度评价结果
    Leavout_bestpredictions(:,1)=Leavout_predictions(:,1);
    Leavout_bestpredictions(:,2)=Leavout_predictions(:,2);
    Leavout_bestpredictions(:,3)=Leavout_predictions(:,min_rmse_index+2);%前两列已经有数据了
    %绘制结果图
    VIvalue=Leavout_bestpredictions(:,1);%初始植被指数值
    Laimeasured=Leavout_bestpredictions(:,2);%植被指数对应的LAI实际测量值
    Laiestimated=Leavout_bestpredictions(:,3);%最佳拟合方式的，对应的交叉验证的LAI预测值
    ya=sum(Laimeasured)/number;
    Bias=(sum(Laiestimated-Laimeasured))/number;
    RMSE=min_rmse;
    RRMSE=RMSE/ya*100;
    R=corrcoef(Laiestimated,Laimeasured);
    R2=R(1,2)^2;
    %设置一下横坐标的范围，方便后面绘图
    if max_VI>=1   %对于VI大于1的指数而言，直接向上取整即可
        x_inition=min_VI/1.1;
        x_inition=floor(x_inition*10)/10;
        x_radius=ceil(max_VI);%植被指数的范围，用作后面横轴的范围
    else            %对于VI小于1的指数而言，直接向上取整就是1了，所以需要多做一步
        x_inition=min_VI/1.1;
        x_inition=floor(x_inition*10)/10;
        x_radius=max_VI*1.1;%植被指数的范围，用作后面横轴的范围
        x_radius=ceil(x_radius * 10)/10;
    end
    %因为有三种LAI的情况，所以设置一下纵坐标的范围
    y_inition=floor(min_LAI)-1;
    y_radius=ceil(max_LAI)+1;
    %对于第一种情况，特殊定义一下
    if y_inition<0
        y_inition=0;
    end
    fig = scatter3(R2,Bias,RMSE,RRMSE,VI_range,LAI_estimated,VIvalue,Laimeasured,x_inition,x_radius,y_inition,y_radius,VI_name);
    print(fig,'-dtiff','-r600',sprintf('%s/%s.tif',OutPathName,VI_name));
    finalresults(idx).VI=VI_name;
    finalresults(idx).fittingform=fittingforms{min_rmse_index};
    finalresults(idx).R2=R2;
    finalresults(idx).RMSE=RMSE;
    finalresults(idx).RRMSE=RRMSE;
    finalresults(idx).Bias=Bias;
    finalresults(idx).VIvalue=VIvalue;
    finalresults(idx).Laimeasured=Laimeasured;
    finalresults(idx).Laiestimated=Laiestimated;
    %%
    %12 输出最小RMSE的拟合方式
    best_form=fittingforms{min_rmse_index};
    fprintf('%s: 最佳的拟合方式: %s\n', VI_name, best_form);
end
% 将finalresults写入Excel文件
finalresults_table = struct2table(finalresults);
writetable(finalresults_table, fullfile(OutPathName, '精度评价.xlsx'));