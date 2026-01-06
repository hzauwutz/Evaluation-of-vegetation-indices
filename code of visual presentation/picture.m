clc; clear;

% 文件路径
imgPath = 'D:\03 硕士第一阶段研究\结果图\03指数拟合结果\01\无背景_0828';
ResultSavePath = 'D:\03 硕士第一阶段研究\结果图\03指数拟合结果\01\无背景_0828';
Name = '01 无背景';

% 读取植被指数顺序 --------------------------------------------------
file_path = 'D:\03 硕士第一阶段研究\结果图\03指数拟合结果\01\无背景_0828\精度评价.xlsx';
data = readtable(file_path);
VI_names = data{:, 1};   % 获取植被指数名称列
VI_names = cellstr(VI_names);  % 确保为细胞数组
%------------------------------------------------------------------
imgFile = dir(sprintf('%s/*.tif', imgPath));
% 提取文件名（不含扩展名）
imgFileNames = arrayfun(@(x) erase(x.name, '.tif'), imgFile, 'UniformOutput', false);

% 检查名称匹配性
if numel(imgFile) ~= numel(VI_names)
    error('植被指数数量与图像文件数量不匹配');
end

% 生成排序索引
[~, sortIdx] = ismember(VI_names, imgFileNames);
if any(sortIdx == 0)
    error('以下植被指数未找到对应文件: %s', strjoin(VI_names(sortIdx==0), ', '));
end

% 按指定顺序排序文件
imgFile = imgFile(sortIdx);


% 创建图形
%figure('position', [300, 80, 650, 800])  % 调整图形大小以适应30张图像
figure('position', [0, 0, 600, 757])  % 调整图形大小以适应30张图像
% 设置子图的行和列数
nRows = 6;
nCols = 5;

% 设置子图之间的间距
hGap = 0; % 水平间距
vGap = 0; % 垂直间距
marg_top = 0;    % 上边距
marg_bottom = 0.05; % 下边距
marg_w = 0; % 左右边距
total_height = 1 - marg_top - marg_bottom;  % 除去上下边距后的可用高度

% 读取并展示每张图像
for i = 1:numel(imgFile)
    % 计算当前子图的位置
    row = floor((i-1) / nCols);
    col = mod(i-1, nCols);
    left = marg_w + col * (1 - 2 * marg_w) / nCols + col * hGap;
    bottom = 1 - marg_top - (row + 1) * total_height / nRows - row * vGap;
    width = (1 - 2 * marg_w) / nCols - hGap;
    height = total_height / nRows - vGap;
    
    % 创建子图并调整位置
    subplot('Position', [left, bottom, width, height]);
    
    % 读取图像文件
    img = imread(fullfile(imgPath, imgFile(i).name));

    imshow(img, []);  % 显示图像，保持原先的颜色映射

    % 获取文件名（不带路径和扩展名）
    %[~, name, ~] = fileparts(imgFile(i).name);
    
    % 使用 text 函数添加标题，位置稍微调整到子图上方
%     text(size(img, 2) / 2, -60, name, 'Interpreter', 'tex', 'FontName', 'Times New Roman','FontWeight', 'bold', ...
%          'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 11);  
end
%% 修正后的色柱标注部分
% 调整色柱轴位置和尺寸
colorbar_ax = axes('Position', [0.15 0.05 0.7 0.015]); % 加宽并降低位置

% 颜色映射设置（保持不变）
cmap = slanCM(100);
colormap(colorbar_ax, cmap);

% 创建色柱
cbar = colorbar('southoutside');
caxis([0 1]);
set(cbar, 'Ticks',[], 'LineWidth', 0.8); % 压缩色柱主体

%% 添加标注（精确坐标控制）
% MTFF标题（色柱正上方）
annotation('textbox',...
    [0.25 0.03 0.5 0.03],...  % [左, 下, 宽, 高] 
    'String','2D Kernel Density Estimation',...
    'FontSize',12,...
    'FontName','Times New Roman',...
    'FontWeight','bold',...
    'HorizontalAlignment','center',...
    'EdgeColor','none');

% denes标注（左下）
annotation('textbox',...
    [0.15 0.005 0.1 0.02],...
    'String','Separateness',...
    'FontSize',10,...
    'FontName','Times New Roman',...
    'FontWeight','bold',...
    'HorizontalAlignment','left',...
    'EdgeColor','none');

% dsef标注（右下）
annotation('textbox',...
    [0.75 0.005 0.1 0.02],...
    'String','Denseness',...
    'FontSize',10,...
    'FontName','Times New Roman',...
    'FontWeight','bold',...
    'HorizontalAlignment','right',...
    'EdgeColor','none');

% 隐藏色柱坐标系
axis(colorbar_ax, 'off');
% 保存整体图像
print('-djpeg', '-r600', fullfile(ResultSavePath, Name));


