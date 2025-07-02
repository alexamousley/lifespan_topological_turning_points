%% Local organizational analysis
%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

Explore local-level correlation between orgnaisation and age across epochs

%}

%% Load data
clear;clc;

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file
addpath('/Add/Path/For/FDR/Correlction/'); %% To FDR correction

% Load data
demographics = readtable('demographics.csv');
load('density-controlled_local_measures.mat');
load('aal90_details.mat')

%% Data

age = demographics{:,1};

% Define predictors
predictors = {'Strength', 'Local Efficiency','Clustering Coefficient',...
    'Betweenness Centrality', 'Subgraph Centrality'};

% Define epoch ranges
r1 = [0 9];
r2 = [9 32];
r3 = [32 66];
r4 = [66 83];
r5 = [83 90];
epoch_range = [r1; r2; r3; r4; r5];

% Define colors for plotting 
colors = {'#D4356F';'#5EA4E2';'#CC9C0B';'#004D40';'#3F2DEA'};
rgb_colors = {[212,53,11];[94,164,226];[204,156,11];[0,77,64];[63,45,234]};
normalized_rgb_colors = cellfun(@(c) c / 255, rgb_colors, 'UniformOutput', false);

%%

n_epochs = size(epoch_range, 1);
n_regions = width(local_statistics);
n_stats = length(predictors);

% Preallocate correlations
r_values = NaN(n_stats, n_regions, n_epochs);
p_values = NaN(n_stats, n_regions, n_epochs);

% Loop over statistics, regions, and epochs
for s = 1:n_stats
    for r = 1:n_regions
        stat_values = squeeze(local_statistics(:, r, s));
        for e = 1:n_epochs
            range = epoch_range(e, :);
            idx = age >= range(1) & age < range(2); % participants in epoch
            [r_val, p_val] = corr(age(idx), stat_values(idx), 'rows', 'complete');
    
            r_values(s, r, e) = r_val;  % Save R values per statistic, per region, per epoch
            p_values(s, r, e) = p_val;  % Save P values per statistic, per region, per epoch
        end
    end
end

% FDR correction and mask insignificant values
alpha = 0.05; % Significance level
adj_p_values = NaN(n_stats, n_regions, n_epochs); % Store corrected p-values
for s = 1:n_stats
    p_flat = squeeze(p_values(s, :, :));

    [~, ~, ~, adj_p] = fdr_bh(p_flat, alpha, 'pdep', 'yes');

    % Store for later use
    adj_p_values(s, :, :) = adj_p;
end

%% Plotting

% Remove the '_L' and '_R' suffixes from lobe names
%region_names = cellfun(@(x) strrep(strrep(x, '_L', ''), '_R', ''), aal90.region_labels, 'UniformOutput', false);
% Remove the underscores and convert to cell array
region_names = cellfun(@(x) strrep(x, '_', ' '),  aal90.region_labels, 'UniformOutput', false);
% Delete all even row indices
%region_names(2:2:end) = [];

epoch_labels = {'0-9','9-32','32-66','66-83','83-90'};
r_reduced = r_values;

% Loop through statistics
for s = 1:n_stats
    
    p=figure('Units', 'pixels', 'Position', [100, 400, 2000, 400]); 

    hold on;
    for e = 1:n_epochs
        pvals_select = squeeze(adj_p_values(s,:,e));
        
        % Mask non-significant correlations
        r_mask = pvals_select > alpha | isnan(pvals_select);
        r_reduced(s, r_mask, e) = NaN;
        
        % Count significant values per epoch
        fprintf('--- Statistic %s ---\n', predictors{s});
        sig_count = nnz(~isnan(r_reduced(s, :, e)));
        fprintf('Epoch %d (%s): %d significant regions\n', e, epoch_labels{e}, sig_count);
        
        r_plot = squeeze(r_reduced(s, :, e));
        
        scatter(1:n_regions, r_plot, 50, ...
                'MarkerFaceColor', normalized_rgb_colors{e}, ...
                'MarkerEdgeColor', normalized_rgb_colors{e},...
                'DisplayName', epoch_labels{e});
    end
    xlabel('Brain Region');
    ylabel('Correlation (r)');
    title(sprintf('%s: Age Correlation', predictors{s}));
    set(gca, 'XTick', 1:1:90, 'XTickLabels',region_names);
    legend('Location','northwest')
    xtickangle(45);
    xtick_positions = get(gca, 'XTick');
    xtick_positions_shifted = xtick_positions - 0.8;
    ylim([-0.4 0.4]);
    xlim([0 n_regions+1]);
    grid on;
    
    % Save the figure
    exportgraphics(p, sprintf('scatter_%s.png', s), 'Resolution', 400);
end





