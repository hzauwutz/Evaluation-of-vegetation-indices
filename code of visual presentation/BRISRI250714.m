clc; clear; close all;

% 设置路径和文件
file_path = 'D:\03 硕士第一阶段研究\结果图\03指数拟合结果\综合评价结果250714v3.xlsx';
output_dir = 'D:\03 硕士第一阶段研究\结果图\04精度评价指标\251208\';
bri_output = fullfile(output_dir, 'BSI_heatmap.jpg');
sri_output = fullfile(output_dir, 'SRI_heatmap.jpg');

% 加载自定义色阶 slanCM（256x3）
slanCM = slanCM(103);  % 自定义函数，需确保输出为256x3矩阵

% 分割色阶
bri_cmap = flipud(slanCM(1:128, :));  % ✅ 倒置色阶
sri_cmap = slanCM(129:256, :);        % 原样不变

% 读取数据
data = readtable(file_path);

% 筛选三个时期
periods = {'01时期无背景', '02时期无背景', '03时期无背景'};
data = data(ismember(data.Period, periods), :);

% 获取 VI 名称
VI_names = unique(data.VI_Name, 'stable');
idx = strcmp(VI_names, 'NDVI3re');
VI_names(idx) = {'NDVI_{3RE}'};
idx2 = strcmp(VI_names, 'CI3re');
VI_names(idx2) = {'CI_{3RE}'};
n_VI = length(VI_names);

% 初始化矩阵
BRI_matrix = zeros(3, n_VI);
SRI_matrix = zeros(3, n_VI);

% 填充矩阵
for i = 1:3
    for j = 1:n_VI
        idx = strcmp(data.Period, periods{i}) & strcmp(data.VI_Name, VI_names{j});
        if any(idx)
            BRI_matrix(i, j) = data.BRI(idx);
            SRI_matrix(i, j) = data.SRI(idx);
        else
            BRI_matrix(i, j) = NaN;
            SRI_matrix(i, j) = NaN;
        end
    end
end

% 绘图并保存
draw_heatmap(BRI_matrix, bri_cmap, bri_output, VI_names, 'BSI');
draw_heatmap(SRI_matrix, sri_cmap, sri_output, VI_names, 'SRI');

% ========== 函数定义 ==========
function draw_heatmap(matrix_data, cmap, save_path, VI_names, label)
    [n_row, n_col] = size(matrix_data);
    %figure('Position', [100 100 1400 400]);
    figure('Units','pixels','Position',[100 100 1650 300]);  % 宽高比更接近16:5


    % 设置主图区域位置，避免自动布局影响
    ax = axes('Position', [0.12 0.3 0.8 0.6]);

    imagesc(matrix_data);
    colormap(cmap);
    
    % 设置色阶范围（根据 label 区分）
    if strcmp(label, 'BSI')
        caxis([0, 3]);
    elseif strcmp(label, 'SRI')
        caxis([0, 1]);
    else
        max_val = ceil(nanmax(matrix_data(:)));
        caxis([0, max_val]);
    end

    % 设置 colorbar 位置
    cb = colorbar('Position', [0.93 0.3 0.015 0.6]);
    if strcmp(label, 'BSI')
        cb.Ticks = [0, 0.5,1,1.5, 2,2.5, 3];
        cb.TickLabels = {'0','0.5', '1','1.5', '2','2.5', '>3'};
        cb.Label.String = 'BSI×10';
    else
        cb.Label.String = label;
    end
   % cb.Label.String = label;
    cb.Label.FontSize = 14;
    cb.Label.FontName = 'Times New Roman';
    cb.Label.Rotation = 90;
    cb.Label.HorizontalAlignment = 'center';

    % 坐标轴设置
    set(gca, 'XTick', 1:n_col, 'XTickLabel', VI_names, ...
        'XTickLabelRotation', 45, 'TickLength', [0 0], ...
        'FontName', 'Times New Roman', 'FontSize', 14);
    set(gca, 'YTick', 1:3, ...
        'YTickLabel', {'Vegetative stage', 'Reproductive stage', 'Maturation stage'}, ...
        'FontName', 'Times New Roman', 'FontSize', 14);
    box on;
    ax.LineWidth = 0.8;

    % 添加黑色格子边框
    hold on;
    for i = 1:n_row
        for j = 1:n_col
            rectangle('Position', [j-0.5, i-0.5, 1, 1], ...
                'EdgeColor', 'k', 'LineWidth', 0.5);
        end
    end
    hold off;

    % 添加数值文字
    for i = 1:n_row
        for j = 1:n_col
            val = matrix_data(i, j);
            if ~isnan(val)
                text(j, i, sprintf('%.3f', val), ...
                    'HorizontalAlignment', 'center', ...
                    'FontSize', 11, ...
                    'FontName', 'Times New Roman', ...
                    'Color', 'k');
            end
        end
    end

    % 保存图像
    % 保存图像
    exportgraphics(gcf, save_path, 'Resolution', 600);
    close(gcf);
end







