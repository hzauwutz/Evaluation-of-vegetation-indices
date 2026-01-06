%评价指标的绘制
% 读取Excel文件
file_path = 'D:\03 硕士第一阶段研究\结果图\03指数拟合结果\综合评价结果250714v3.xlsx';
data = readtable(file_path);

% 获取列数据
scenes = data{:, 1};          % 场景设置
VI_names = data{:, 2};        % 植被指数名字
idx = strcmp(VI_names, 'NDVI3re');
VI_names(idx) = {'NDVI_{3RE}'};
idx2 = strcmp(VI_names, 'CI3re');
VI_names(idx2) = {'CI_{3RE}'};



best_fit = data{:, 3};        % 最佳拟合形式
R2_values = data{:, 9};       % R2
RMSE_values = data{:, 10};     % RMSE
    % RRMSE
Bias_values = data{:, 11};     % Bias
BRI_values = data{:, 12};      % BRI
SRI_values = data{:, 13};      % SRI

R2_values2 = data{:, 4};       % R2
RMSE_values2 = data{:, 5};     % RMSE
Bias_values2 = data{:, 6};     % Bias
RRMSE_values2 = data{:, 15};
BRI_values2=data{:,7};
SRI_values2=data{:,8};
% 定义场景名称
unique_scenes = {'01时期有背景', '01时期无背景', '02时期有背景', '02时期无背景', '03时期有背景', '03时期无背景'};
output_dir = 'D:\03 硕士第一阶段研究\结果图\04精度评价指标\251208';  % 图像存储路径
%%
% 循环遍历每个场景开始画图
for s = 1:length(unique_scenes)
    current_scene = unique_scenes{s};
    
    % 提取当前场景的数据
    scene_idx = strcmp(scenes, current_scene);
    
    % 获取当前场景的各个评价指标值
    current_names = VI_names(scene_idx);
    current_R2 = R2_values(scene_idx);
    current_RMSE = RMSE_values(scene_idx);
    %current_RRMSE = RRMSE_values(scene_idx);
%     current_Bias = Bias_values(scene_idx);
    current_BRI = BRI_values(scene_idx);
    current_SRI = SRI_values(scene_idx);
  
    % 半径设置（可以调整）
    radii = [10, 9, 8, 7,6]; % 对应R2, RMSE, BRI, SRI的半径，最里面一个空白
    %radii = [6, 5, 4]; % 对应 BRI, SRI的半径，最里面一个空白
    % 定义圆心，并将角度范围旋转90度，即从π/2到2π
    theta = linspace(pi/2, 2*pi, 31);  % 四分之三圆，从90度到360度，总共30个点
    theta(end) = [];  % 移除最后一个点以避免重复

    % 开始绘制图形
    figure('Units', 'centimeters', 'Position', [5,5, 12, 12]);  % 设置图形窗口大小和位置
    set(gcf, 'Color', 'w');  % 将整个图像背景设置为白色
    set(gcf, 'DefaultTextFontName', 'Times New Roman');  % 设置全局文本字体为新罗马
    set(gca, 'FontName', 'Times New Roman');  % 设置坐标轴字体为新罗马
    hold on;

    % 定义唯一色带
    cmap = slanCM(100,30);   % 色带

    % 循环绘制每个指标（R2, RMSE, BRI, SRI），排除最里面的空白
    for i = 1:4
        if i == 3
            values = current_R2;
            indicator_name = 'R^2';  % 名称
            [~, sort_idx] = sort(values, 'ascend'); % 升序排序
            sorted_values = linspace(0, 1, length(values)); % 归一化到 0-1
        elseif i == 4
            values = current_RMSE;
            indicator_name = 'RMSE';  % 名称
            [~, sort_idx] = sort(values, 'ascend'); % 升序排序
            sorted_values = linspace(0, 1, length(values)); % 归一化到 0-1
%         elseif i == 3
%             values = current_Bias;
%             indicator_name = 'Bias';  % 名称
        elseif i == 1
            values = current_BRI;
            indicator_name = 'BSI';  % 名称
                    % 对 values 进行排序并获取索引
            [~, sort_idx] = sort(values, 'ascend'); % 升序排序
            sorted_values = linspace(0, 1, length(values)); % 归一化到 0-1
        elseif i == 2
            values = current_SRI;
            indicator_name = 'SRI';  % 名称
                    % 对 values 进行排序并获取索引
            [~, sort_idx] = sort(values, 'ascend'); % 升序排序
            sorted_values = linspace(0, 1, length(values)); % 归一化到 0-1
        end

        % 每个圆弧分为30块，表示30种VI
        for j = 1:length(values)
            % 获取当前圆弧的起点和终点角度
            t_start = theta(j);
            t_end = t_start + (3*pi/2)/30;  % 固定角度步长

            % 获取每一块圆弧的坐标
            x1_start = radii(i) * cos(t_start);
            y1_start = radii(i) * sin(t_start);
            x2_end = radii(i) * cos(t_end);
            y2_end = radii(i) * sin(t_end);

            % 使用归一化值选择颜色
            color_idx = round(sorted_values(sort_idx == j) * 29) + 1;
            color = cmap(color_idx, :);  % 选择相应颜色

            % 绘制每个扇形
            fill([0, x1_start, x2_end], [0, y1_start, y2_end], color, 'EdgeColor', 'none');
        end
        % 在每个圆弧的第一块格子的右边添加指标名称
        t_first = theta(1);
        x_name = radii(i) * cos(t_first) + 0.5;  % 适当偏移
        y_name = radii(i) * sin(t_first)-0.5;
        text(x_name, y_name, indicator_name, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'FontSize', 10, 'FontName', 'Times New Roman');
    end



    % 添加外圈刻度线和VI名称
    outer_radius = radii(1) + 0.2;  % 刻度线外圈半径
    text_offset = 1;  % 偏移量，增加VI名称与刻度线的距离
    for j = 1:length(current_names)
        % 获取刻度线起点和终点的坐标
        t_start = theta(j);
        t_end = t_start + (3*pi/2)/30; 
        x_start = radii(1) * cos(t_start);
        y_start = radii(1) * sin(t_start);
        t_middle = (t_start + t_end) / 2;  % 圆弧的中间角度
        x_end = outer_radius * cos(t_start);
        y_end = outer_radius * sin(t_start);

        % 绘制刻度线
        plot([x_start, x_end], [y_start, y_end], 'k', 'LineWidth', 0.5);

        % 在刻度线的末端显示VI名称
        text((outer_radius + text_offset) * cos(t_middle), (outer_radius + text_offset) * sin(t_middle), current_names{j}, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 7,'FontWeight' ,'bold','Rotation',0); %rad2deg(t_middle) - 90);
    end

    % 添加最里面的空白圆弧
    theta_fill = linspace(pi/2, 2*pi, 100);  % 更多点用于平滑圆弧
    x_fill = radii(5) * cos(theta_fill);%如果是5个指标就是radii(6)
    y_fill = radii(5) * sin(theta_fill);
    fill([0, x_fill, 0], [0, y_fill, 0], 'w', 'EdgeColor', 'none');  % 白色填充


    % 设置轴范围和比例
    axis equal;
    axis off; % 隐藏轴


    % 添加色柱图例并将标题设置在色柱上方
    colormap(cmap);  % 确保 colorbar 使用新 colormap
    c = colorbar('Location', 'eastoutside', 'Position', [0.8, 0.55, 0.015, 0.15]);  % 调整色柱位置和大小
    c.Ticks = linspace(0, 1,2);  % 设置刻度
    c.TickLabels = {'1','30'};  % 设置刻度标签
    % 使用ylabel设置色柱标题，并手动调整位置
    ylabel(c, 'Rank', 'FontSize', 10, 'Rotation', 0,'FontName', 'Times New Roman');  % 取消旋转使标题横向显示

    % 手动调整位置：将位置偏移至色柱的上方
    c.Label.Position = [0.5, 1.3, 0];  % 0.5水平居中，1.2表示在色柱上方，调大可以进一步提升位置

    % 添加图形中央的标题
    title_text = sprintf('A Comprehensive Ranking of \n 30 VIs for Rice LAI Estimation');
    text(0, 0, title_text, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 12, 'FontName', 'Times New Roman');


    hold off;

    % 保存图像为JPG格式，分辨率600 DPI
    output_filename = fullfile(output_dir, [current_scene, '.tif']);
    print(output_filename, '-dtiff', '-r600');
end








