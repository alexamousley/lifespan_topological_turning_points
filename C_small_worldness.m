%% Calculate Small Worldness

%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

This function calculates small worldness sigma value.

Input
    sim = number of null models for simulations

Output
    sigma = ratio of the normalized clustering to normalized characteristic path length

%}

%% Small Wordlness Function 

function sigma = C_small_worldness(sim)

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file
% Set folder to save 
cd('/set/path/to/save');                                                                 % <<<<< Add path to save folder
% Load networks
load('harmonized_data.mat');
% Choose which networks to use
weighted_networks = harmonized_data.connectomes.controlled_density.normalized_weighted; 
% Define data
nsub = length(harmonized_data.demographics.ages);                                       % Number of participants   

% Density-controlled small worldness
for sub = 1:nsub
    % Take participant's networks
    conn = squeeze(harmonized_data.connectomes.controlled_density.normalized_weighted(sub,:,:));
    C = mean(clustering_coef_wu(conn)); % Calculate clustering coefficient
    L = charpath(conn);                 % Calculate characteristic path length
    % Create random networks
    for i = 1:sim
        rand = randmio_und(conn,50);
        rand_C(i) = mean(clustering_coef_bu(rand));
        rand_L(i) = charpath(rand);
    end
    % Calculate small wordlness (sigma > 1 indicates small worldnness)
    density_controlled_sigma(sub) = (C / mean(rand_C)) / (L / mean(rand_L)); % Ratio of the normalized clustering to normalized characteristic path length
end

% Variable density small worldness
for sub = 1:nsub
    % Take participant's networks
    conn = squeeze(harmonized_data.connectomes.variable_density.normalized_weighted(sub,:,:));
    C = mean(clustering_coef_wu(conn)); % Calculate clustering coefficient
    L = charpath(conn);                 % Calculate characteristic path length
    % Create random networks
    for i = 1:sim
        rand = randmio_und(conn,50);
        rand_C(i) = mean(clustering_coef_bu(rand));
        rand_L(i) = charpath(rand);
    end
    % Calculate small wordlness (sigma > 1 indicates small worldnness)
    variable_density_sigma(sub) = (C / mean(rand_C)) / (L / mean(rand_L)); % Ratio of the normalized clustering to normalized characteristic path length
end

% Save             
save('variable_density_sigma.mat','variable_density_sigma');
save('density_controlled_sigma.mat','density_controlled_sigma');