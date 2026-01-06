% 定义生育时期
periods = {'01', '02', '03'};
% for i = 1:length(VI_struct)
%     % 计算当前植被指数的最小值和最大值
%     VI_min = min(VI_struct(i).formula(:));
%     VI_max = max(VI_struct(i).formula(:));
%     
%     % 避免除以零的情况
%     if VI_max == VI_min
%         VI_struct(i).normalized_formula = zeros(size(VI_struct(i).formula));
%     else
%         % 对植被指数进行归一化
%         VI_struct(i).normalized_formula = (VI_struct(i).formula - VI_min) / (VI_max - VI_min);
%     end
%     
%     % 输出归一化信息
%     fprintf('已归一化：%s\n', VI_struct(i).name);
% end
% 初始化结果存储
results_all = {};
weights_all = {};  % 存储六种情景下的权重

for p = 1:length(periods)
    % 文件路径
    file_bg = sprintf('D:\\03 硕士第一阶段研究\\结果图\\03指数拟合结果\\%s\\有背景_0828\\精度评价.xlsx', periods{p});
    file_nobg = sprintf('D:\\03 硕士第一阶段研究\\结果图\\03指数拟合结果\\%s\\无背景_0828\\精度评价.xlsx', periods{p});

    % 读取Excel文件
    data_bg = readtable(file_bg);
    data_nobg = readtable(file_nobg);

    % 提取VI和精度指标
    VI_names = data_bg{:, 1};  % 第一列是VI名称
    fitting_form_bg = string(data_bg{:, 2}); % 确保为字符串
    fitting_form_nobg = string(data_nobg{:, 2}); % 确保为字符串
    R2_bg_original = data_bg{:, 3};
    %R2_bg = 1 - R2_bg_original;  % 越小越好
    RMSE_bg = data_bg{:, 4};
    RRMSE_bg= data_bg{:, 5};
    Bias_bg = data_bg{:, 6};
    Bias_bg = abs(Bias_bg);
    
    R2_nobg_original = data_nobg{:, 3};
    %R2_nobg = 1 - R2_nonbg_original;
    RMSE_nobg = data_nobg{:, 4};
    RRMSE_nobg= data_nobg{:, 5};
    Bias_nobg = data_nobg{:, 6};
    Bias_nobg = abs(Bias_nobg);

    % 计算BRI，注意注释掉的两句话是针对归一化植被指数而言的！！！
    %n = 500;  % 500
    %valid_mask = (data_nobg{:, 7:506} > 0) & (data_nobg{:, 7:506} < 1);
    %relative_diff = abs((data_bg{:, 7:506} - data_nobg{:, 7:506})) ./ data_nobg{:, 7:506};
    %relative_diff(~valid_mask) = 0; % 忽略0和1
    %BRI = sum(relative_diff, 2) / n;
%     BRI = (abs(RMSE_bg - RMSE_nobg)).* (RMSE_bg + RMSE_nobg);
%     BRI=BRI*10;
% 设置当前时期的平均 LAI
    if p == 1
        LAI_avg = 1.23;
    elseif p == 2
        LAI_avg = 6.07;
    elseif p == 3
        LAI_avg = 4.55;
    end
    k = 1;
       % 计算 BSI
    RMSE_diff = abs(RMSE_bg - RMSE_nobg);           % 分子：有无背景 RMSE 差值
    RMSE_sum  = RMSE_bg + RMSE_nobg;                % 分母前项：有无背景 RMSE 之和
    LAI_sat   = 1 - exp(-k * LAI_avg);              % 冠层饱和度（背景可见度）
   % BSI = (RMSE_diff ./ LAI_sat) .* (1 + alpha * RMSE_sum ./ (k * LAI_avg));
    BSI = (RMSE_diff ./ LAI_sat) .* exp(RMSE_sum ./ (k * LAI_avg^2));
    % 替换原 BRI，用 BSI 名义继续参与熵权分析
    BRI = BSI;  % 沿用原变量名，保持后续代码不变
    BRI=BRI*10;
    % 提取LAI
    LAI_measured = data_nobg{:, 507:1006};  % 实测LAI（500列）
    % 计算SRI
    SRI = zeros(length(VI_names), 1);

    % 根据 p 值设置 LAI 范围和区间个数
    if p == 1
        LAI_range = 0:0.5:4; % 第一个时期
    elseif p == 2
        LAI_range = 3:0.5:7; % 第二个时期
    elseif p == 3
        LAI_range = 2:0.5:5; % 第三个时期
    else
        error('p 值无效，应为 1、2 或 3');
    end

    m = length(LAI_range) - 1; % 区间个数
    R2_sub = zeros(length(VI_names), m); % 存储每个 VI 在每个区间的 R²
    for j = 1:length(VI_names)
        % 该 VI 对应的估算 LAI
        LAI_estimated = data_nobg{j, 7:506};

        for i = 1:m
            % 当前 LAI 子区间范围
            LAI_min = LAI_range(i);
            LAI_max = LAI_range(i+1);

            % 筛选当前区间的样本索引
            idx = find(LAI_measured(j,:) >= LAI_min & LAI_measured(j,:) < LAI_max);

            % 如果该区间数据充足（至少两个点）
            if length(idx) >= 2
                % 实测与估算 LAI
                x = LAI_measured(j, idx)';
                y = LAI_estimated(idx)';

                % 计算 R²
                R = corrcoef(x, y);
                R2_sub(j, i) = R(1,2)^2;
            else
                R2_sub(j, i) = NaN;  % 数据不足则设为 NaN
            end
        end

        % 去除 NaN 后计算 SRI
        valid_R2 = R2_sub(j, ~isnan(R2_sub(j,:)));

        if ~isempty(valid_R2)
            R2_mean = mean(valid_R2);
            R2_std = std(valid_R2);
            R2_nobg_original2=R2_nobg_original(j);
            SRI(j) = R2_mean;  % 加 eps 防止除零
        else
            SRI(j) = 0; % 若全为 NaN，则设为 0
        end
    end
        % 对 SRI 进行归一化，确保最大值不会超过 1
   % SRI = SRI / max(SRI);  % 归一化至 [0, 1] 范围内
%     % 计算SRI
%     SRI = zeros(length(VI_names), 1);
%     for j = 1:length(VI_names)
%         % 计算最大和最小值
%         VI_max = max(data_bg{j, 7:506});
%         VI_min = min(data_bg{j, 7:506});
%         LAI_max = max(LAI_measured(j, :));
%         LAI_min = min(LAI_measured(j, :));
%         
%         % 计算分子
%         numerator = abs(VI_max - VI_min) / abs(LAI_max - LAI_min);
%         
%         % 计算分母
%         slope_sum = 0;
%         for i = 1:n/50
%             idx_start = (i-1)*50 + 1;  % 开始索引
%             idx_end = i*50;            % 结束索引
%             
%             % 计算斜率
%             if idx_end <= 500  % 确保不超出范围
%                 slope = (data_bg{j, idx_end + 6} - data_bg{j, idx_start + 6}) / (LAI_measured(j, idx_end) - LAI_measured(j, idx_start));
%                 slope_sum = slope_sum + abs(slope);  % 绝对值
%             end
%         end
%         
%         % 计算SRI
%         if slope_sum ~= 0
%             SRI(j) = numerator / slope_sum;
%         else
%             SRI(j) = NaN;  % 避免除以零
%         end
%     end

    % 对R2、RMSE、Bias、BRI和SRI进行归一化
    R2_bg_min = min(R2_bg_original);
    R2_bg_max = max(R2_bg_original);
    R2_bg_normalized = (R2_bg_max-R2_bg_original) / (R2_bg_max - R2_bg_min);
    
    R2_nobg_min = min(R2_nobg_original);
    R2_nobg_max = max(R2_nobg_original);
    R2_nobg_normalized = (R2_nobg_max-R2_nobg_original) / (R2_nobg_max - R2_nobg_min);
    
    RMSE_bg_min = min(RMSE_bg);
    RMSE_bg_max = max(RMSE_bg);
    RMSE_bg_normalized = (RMSE_bg - RMSE_bg_min) / (RMSE_bg_max - RMSE_bg_min);
    
    RMSE_nobg_min = min(RMSE_nobg);
    RMSE_nobg_max = max(RMSE_nobg);
    RMSE_nobg_normalized = (RMSE_nobg - RMSE_nobg_min) / (RMSE_nobg_max - RMSE_nobg_min);
    
    RRMSE_bg_min = min(RRMSE_bg);
    RRMSE_bg_max = max(RRMSE_bg);
    RRMSE_bg_normalized = (RRMSE_bg - RRMSE_bg_min) / (RRMSE_bg_max - RRMSE_bg_min);
    
    RRMSE_nobg_min = min(RRMSE_nobg);
    RRMSE_nobg_max = max(RRMSE_nobg);
    RRMSE_nobg_normalized = (RRMSE_nobg - RRMSE_nobg_min) / (RRMSE_nobg_max - RRMSE_nobg_min);
    
    Bias_bg_min = min(Bias_bg);
    Bias_bg_max = max(Bias_bg);
    Bias_bg_normalized = (Bias_bg - Bias_bg_min) / (Bias_bg_max - Bias_bg_min);
    
    Bias_nobg_min = min(Bias_nobg);
    Bias_nobg_max = max(Bias_nobg);
    Bias_nobg_normalized = (Bias_nobg - Bias_nobg_min) / (Bias_nobg_max - Bias_nobg_min);
    
    BRI_min = min(BRI);
    BRI_max = max(BRI);
    BRI_normalized = (BRI - BRI_min) / (BRI_max - BRI_min);
    
    SRI_min = min(SRI);
    SRI_max = max(SRI);
    SRI_normalized = (SRI_max-SRI) / (SRI_max - SRI_min);

    % 创建有背景和无背景的数据矩阵
    data_matrix_bg = [ BRI_normalized, SRI_normalized];
    data_matrix_nobg = [ BRI_normalized, SRI_normalized];

    % 计算熵权法权重
    weights_bg = calculate_entropy_weights(data_matrix_bg);
    weights_nobg = calculate_entropy_weights(data_matrix_nobg);

    % 将权重存入weights_all
    weights_all{end + 1, 1} = sprintf('%s时期有背景', periods{p});
    weights_all(end, 2:3) = num2cell(weights_bg);
    
    weights_all{end + 1, 1} = sprintf('%s时期无背景', periods{p});
    weights_all(end, 2:3) = num2cell(weights_nobg);

    % 计算综合评价指标OPI并存储结果
    for j = 1:length(VI_names)
        OPI_bg = sum(data_matrix_bg(j, :) .* weights_bg);
        OPI_nobg = sum(data_matrix_nobg(j, :) .* weights_nobg);
        
        results_all{end + 1, 1} = sprintf('%s时期有背景', periods{p});
        results_all{end, 2} = VI_names{j};
        results_all{end, 3} = fitting_form_bg(j);
        results_all{end, 4} = R2_bg_original(j);
        results_all{end, 5} = RMSE_bg(j);
        results_all{end, 6} = Bias_bg(j);
        results_all{end, 7} = BRI(j);
        results_all{end, 8} = SRI(j);
        results_all{end, 9} = R2_bg_normalized(j);
        results_all{end, 10} = RMSE_bg_normalized(j);
        results_all{end, 11} = Bias_bg_normalized(j);
        results_all{end, 12} = BRI_normalized(j);
        results_all{end, 13} = SRI_normalized(j);
        results_all{end, 14} = OPI_bg;
        results_all{end, 15} = RRMSE_bg(j);
        results_all{end, 16} = RRMSE_bg_normalized(j);
        
        results_all{end + 1, 1} = sprintf('%s时期无背景', periods{p});
        results_all{end, 2} = VI_names{j};
        results_all{end, 3} = fitting_form_nobg(j);
        results_all{end, 4} = R2_nobg_original(j);
        results_all{end, 5} = RMSE_nobg(j);
        results_all{end, 6} = Bias_nobg(j);
        results_all{end, 7} = BRI(j);
        results_all{end, 8} = SRI(j);
        results_all{end, 9} = R2_nobg_normalized(j);
        results_all{end, 10} = RMSE_nobg_normalized(j);
        results_all{end, 11} = Bias_nobg_normalized(j);
        results_all{end, 12} = BRI_normalized(j);
        results_all{end, 13} = SRI_normalized(j);
        results_all{end, 14} = OPI_nobg;
        results_all{end, 15} = RRMSE_nobg(j);
        results_all{end, 16} = RRMSE_nobg_normalized(j);
    end
end

% 将综合结果保存到Excel
results_table = cell2table(results_all, 'VariableNames', ...
    {'Period', 'VI_Name', 'Best_Fit', 'R2', 'RMSE', 'Bias', 'BRI', 'SRI', ...
    'R2_normalized', 'RMSE_normalized', 'Bias_normalized', 'BRI_normalized', 'SRI_normalized', 'OPI','RRMSE','RRMSE_normlized'});
writetable(results_table, 'D:\03 硕士第一阶段研究\结果图\04精度评价指标\251208\综合评价结果251208.xlsx');

% % 将权重结果保存到Excel
% weights_table = cell2table(weights_all, 'VariableNames', {'Period', 'BRI', 'SRI'});
% writetable(weights_table, 'D:\\03 硕士第一阶段研究\\结果图\\03指数拟合结果\\熵权法权重250714v2.xlsx');

disp('综合评价结果和熵权法权重已保存到Excel文件中。');
function weights = calculate_entropy_weights(data_matrix)
    % 仅基于BRI和SRI两个指标的方差计算熵权法权重
    % 假设 data_matrix 是一个 n × 2 的矩阵，列分别是 BRI 和 SRI

    % 1. 检查输入维度
    if size(data_matrix, 2) ~= 2
        error('输入数据应为 n × 2，列分别为 BRI 和 SRI');
    end

    % 2. 计算每个指标的方差
    variances = var(data_matrix, 0, 1); % 对每一列求方差

    % 3. 根据方差归一化分配权重
    weights = variances / sum(variances); % 方差越大，权重越大
end
