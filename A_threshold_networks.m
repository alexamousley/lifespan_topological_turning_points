%% Threshold Networks

%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

% (1) Threshold to target-density to create variable density networks
% (2) Threshold to an exact density to create density-controlled networks

%}


%% Add paths and load data
clear;clc;

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file

load('all_data.mat');

%% Remove outliers
all_data.connectomes(all_data.demographics.outlier_index == 1, :, :) = [];
reduced_demographics = all_data.demographics(all_data.demographics.outlier_index ~= 1, :);

%% (1) Preserve variable density networks
% Threshold each age group to the target density (determined by 70% raw density from generalized additive models)

thresholds = 1:max(all_data.connectomes(:));  % Create thresholds to loop through (set to max amount of streamlines across all participants)
nthr = length(thresholds);               % Length of thresholds
load('target_density.mat')               % Load target densities for each age (age is the index - 1 - e.g., row 1 is for age 0)

% Initialize
variable_density_thresholds = [];
variable_binarized_connectomes = zeros(size(all_data.connectomes)); 
variable_weighted_connectomes = zeros(size(all_data.connectomes)); 

% Loop through each target density
for i = 1:length(target_density)
    age = i-1;                    % Identify age group  
    den_goal = target_density(i); % Pull target density
    
    
    % Loop through each dataset
    for s = 1:length(unique(unharmonized_demographics.dataset))
        % Find index of participants in this age & dataset bin
        index = find(reduced_demographics.age == age & reduced_demographics.dataset == s);
        
        % Process only if networks are present in this age & dataset bin
        if ~isempty(index)
            connectomes = all_connectomes(index, :, :);  % Networks in this bin
            over = false;                                % Flag to track if threshold has exceeded target density
            
            % Loop through each threshold
            for t = 1:nthr
                if over, t = t - 1; end   % Repeat previous threshold if target density is exceeded
                
                % Calculate density and update connectomes for each participant
                density = zeros(1, length(index));
                for sub = 1:length(index)
                    W = squeeze(connectomes(sub, :, :));          % Unthresholded connectome
                    W_thr = threshold_absolute(W, thresholds(t)); % Apply absolute threshold (from Brain Connectivity Toolbox)
                    density(sub) = density_und(W_thr);            % Calculate density
                    
                    % Binarize and save connectomes
                    B = W_thr > 0;
                    variable_binarized_connectomes(index(sub), :, :) = B;
                    variable_weighted_connectomes(index(sub), :, :) = W_thr;
                end
                
                % Check if target density is reached or exceeded
                mean_density = round(mean(density), 3);
                if mean_density == den_goal || over            
                    variable_density_thresholds = [variable_density_thresholds, thresholds(t)]; % Save Threshold
                    break                                                                       % Move to the next age & dataset bin
                elseif mean_density < den_goal
                    disp(sprintf('Group age %g passed target density', age)); % Print that target density has been passed
                    over = true;                                              % Change 'over' to identify this bin as passing target 
                end
            end
        end
    end
    disp(sprintf('Finished age group %g', age));
end

%% (2) Density-controlled networks

thresholds = 1:max(all_data.connectomes(:));  % Create thresholds to loop through (set to max amount of streamlines across all participants)
nthr = length(thresholds);               % Length of thresholds
target_density = 0.100;                  % Set target density to 10%

% Initialize
density_controlled_thresholds = [];
controlled_thresholds = [];
controlled_binarized_connectomes = zeros(size(all_data.connectomes)); 
controlled_weighted_connectomes = zeros(size(all_data.connectomes)); 

% Loop through each participant
for sub = 1:length(all_data.connectomes)
    connectome = squeeze(all_data.connectomes(sub, :, :)); % Unthresholded connectome
    over = false;                                 % Flag to track if threshold has exceeded target density

    % Loop through each threshold
    for t = 1:nthr
        if over, t = t - 1; end   % Repeat previous threshold if target density is exceeded

        W_thr = threshold_absolute(connectome, thresholds(t)); % Apply absolute threshold
        sub_density = density_und(W_thr);                     % Calculate density

        if round(sub_density,3) == target_density || over
            % Binarize and save connectomes
            B = W_thr > 0;
            controlled_binarized_connectomes(sub, :, :) = B;
            controlled_weighted_connectomes(sub, :, :) = W_thr;
            % Save density & threshold
            density(sub) = sub_density;
            controlled_thresholds(sub) = thresholds(t);
            break   % Move onto next participant
        elseif round(sub_density,3) < target_density
            disp(sprintf('Group age %g passed target density', age)); % Print that target density has been passed
            over = true;                                              % Change 'over' to identify this bin as passing target 
        end
    end
    disp(sprintf('Finished Participant %g',(sub)));
end

%% Create normalized weighted networks 

for sub = 1:length(all_data.connectomes)
    % Variable density
    variable_norm_weighted_connectomes(sub,:,:) = weight_conversion(squeeze(variable_weighted_connectomes(sub,:,:)), 'normalize');
    % Density-controlled
    controlled_norm_weighted_connectomes(sub,:,:) = weight_conversion(squeeze(controlled_weighted_connectomes(sub,:,:)), 'normalize');
end

%% Save

thresholded_data = struct;
thresholded_data.info = 'This data has outliers removed and has been thresholded but not harmonized.';
thresholded_data.demographics = reduced_demographics;
thresholded_data.thresholds.variable = variable_density_thresholds;
thresholded_data.thresholds.controlled = controlled_density_thresholds;
thresholded_data.connectomes.controlled_binarized = controlled_binarized_connectomes;
thresholded_data.connectomes.controlled_weighted = controlled_weighted_connectomes;
thresholded_data.connectomes.controlled_normalized_weighted = controlled_norm_weighted_connectomes;
thresholded_data.connectomes.variable_binarized = variable_binarized_connectomes;
thresholded_data.connectomes.variable_weighted = variable_weighted_connectomes;
thresholded_data.connectomes.variable_normalized_weighted = variable_norm_weighted_connectomes;
