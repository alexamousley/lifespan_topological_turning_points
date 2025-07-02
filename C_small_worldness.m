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
    % take subject's networks
    conn = squeeze(lifespan_project_data.connectomes.controlled_density.normalised_weighted(sub,:,:));
    
    clust = clustering_coef_bu(conn); % Calculate clustering coefficient
    clust(clust==Inf) = NaN;          % Replace any Inf with NaN for averaging
    C = nanmean(clust);               % Take average clustering coefficient
    dist = distance_bin(conn);
    L = charpath(dist,0,0);           % Calculate characteristic path length
    
    % Random networks
    for i = 1:1000
        % Create random network
        rand = randmio_und(conn,50);

        % Calcuate properies 
        clust = mean(clustering_coef_bu(rand));
        clust(clust==Inf) = NaN;
        rand_C(i) = nanmean(clust);
        dist = distance_bin(rand);
        rand_L(i) = charpath(dist,0,0);
    end

    % Small-worldness metric (sigma > 1 indicates small worldnness)
    density_controlled_sigma(sub) = (C / mean(rand_C)) / (L / mean(rand_L)); % Ratio of the normalized clustering and the normalized characteristic path length
    disp(sprintf('Finsihed %d',sub))
end

% Variable density small worldness
for sub = 1:nsub
    % take subject's networks
    conn = squeeze(lifespan_project_data.connectomes.variable-density.normalised_weighted(sub,:,:));
    
    clust = clustering_coef_bu(conn); % Calculate clustering coefficient
    clust(clust==Inf) = NaN;          % Replace any Inf with NaN for averaging
    C = nanmean(clust);               % Take average clustering coefficient
    dist = distance_bin(conn);
    L = charpath(dist,0,0);           % Calculate characteristic path length
    
    % Random networks
    for i = 1:1000
        % Create random network
        rand = randmio_und(conn,50);

        % Calcuate properies 
        clust = mean(clustering_coef_bu(rand));
        clust(clust==Inf) = NaN;
        rand_C(i) = nanmean(clust);
        dist = distance_bin(rand);
        rand_L(i) = charpath(dist,0,0);
    end

    % Small-worldness metric (sigma > 1 indicates small worldnness)
    variable_density_sigma(sub) = (C / mean(rand_C)) / (L / mean(rand_L)); % Ratio of the normalized clustering and the normalized characteristic path length
    disp(sprintf('Finsihed %d',sub))
end

% Save             
save('variable_density_sigma.mat','variable_density_sigma');
save('density_controlled_sigma.mat','density_controlled_sigma');