%% LASSO Regularized Regression
%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

Run LASSO regressions per epochs

%}
%% Load data
clear;clc;

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file

% Load data
load('umap_input_data');

%% Format data

% Concatenate fields into one array
data = [];
fieldNames = fieldnames(mat);
for i = 1:numel(fieldNames)
    currentField = mat.(fieldNames{i});
    data = [data, currentField(:)];
end

% Define age and remove it from the array
ages = data(:,1);
data(:,1) = [];

% Standardize data
data = zscore(data);

% Define predictors
predictors = {'Global Efficiency', 'Path Length', 'Small -Worldness',...
    'Strength','Modularity', 'Core/Periphery', 'S-Core', 'Local Efficiency', ...
    'Clustering Coefficient', 'Betweenness Centrality', 'Subgraph Centrality'};

% Define epoch ranges
r1 = [0 8];
r2 = [8 32];
r3 = [32 62];
r4 = [62 85];
r5 = [85 90];
epoch_range = [r1; r2; r3; r4; r5];

% Define colors for plotting 
colors = {'#D4356F';'#5EA4E2';'#CC9C0B';'#004D40';'#3F2DEA'};
rgb_colors = {[212,53,11];[94,164,226];[204,156,11];[0,77,64];[63,45,234]};
normalized_rgb_colors = cellfun(@(c) c / 255, rgb_colors, 'UniformOutput', false);

%% Run LASSO

% Loop through epochs
for i = 1:length(epoch_range)
    % Choose epoch
    r = epoch_range(i,:);
    disp(sprintf('Epoch: %g - %g',r(1),r(2)));
    % Pull data for this epoch
    rangeidx = find(ages >= r(1) & ages <= r(2));
    % Define variables
    y = ages(rangeidx);
    x = data(rangeidx,:);
  
    % Run LASSO
    [B fit] = lasso(x,y,'CV',10,'PredictorNames',predictors);

    if i < 5
        % Display 
        disp(['Epoch ' num2str(r), ' - Sample size:' num2str(length(y)), '; Lambda = ' num2str(fit.Lambda1SE)]);
  
        % Pull coefficients
        B_optimal = abs(B(:,fit.Index1SE));
        % Save coefficients
        all_coefs(i,:) = B_optimal;
        
        % Display plots for each iteration
        if i == 1
            figure(i);
            set(gca, 'Position', [0.15 0.45 0.65 0.5]); 
            bar(B_optimal,'FaceColor',colors{i})
            set(findall(gcf, 'type', 'text'), 'FontName', 'Arial');
            set(gca, 'FontSize', 20); 
            xticklabels(predictors);xtickangle(45);
            ylabel('\beta','FontSize',30,'FontWeight', 'bold');
            box off;
        else
            figure(i); 
            set(gca, 'Position', [0.15 0.45 0.65 0.5]);
            bar(B_optimal,'FaceColor',colors{i})
            set(findall(gcf, 'type', 'text'), 'FontName', 'Arial');
            set(gca, 'FontSize', 20); 
            xticklabels(predictors);xtickangle(45);
            ylabel('\beta','FontSize',30,'FontWeight', 'bold');
            box off;
        end
    else
        % Display 
        disp(['Epoch ' num2str(r), ' - Sample size:' num2str(length(y)), '; Lambda = ' num2str(fit.LambdaMinMSE)]);
  
        % Pull coefficients
        B_optimal = abs(B(:,fit.IndexMinMSE)); %% No optimal lambda, so pick the one that allows at least 1 coefficient
        % Save coefficients
        all_coefs(i,:) = B_optimal;
        
        % Display plot
        figure(i);
        set(gca, 'Position',  [0.15 0.45 0.65 0.5]);
        bar(B_optimal,'FaceColor',colors{i})
        set(findall(gcf, 'type', 'text'), 'FontName', 'Arial');
        set(gca, 'FontSize', 20); 
        xticklabels(predictors);xtickangle(45);
        ylabel('\beta','FontSize',30,'FontWeight', 'bold');
        box off;
    end
end

