%% Calculate Organizational Measures

%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

Calculate graph theory measures 

%}

%% Add paths and load data
clear;clc;

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file

% Load networks
load('harmonized_data.mat');
% Load small worldness (choose which types of networks network)
load('density_controlled_sigma.mat')

% Choose which networks to use
weighted_networks = harmonized_data.connectomes.controlled_density.normalized_weighted; % Weighted networks
binarized_networks = harmonized_data.connectomes.controlled_density.binarized;          % Binarized networks
% Define data
nsub = length(harmonized_data.demographics.ages);                                       % Number of participants      
nnodes = width(weighted_networks);                                                      % Number of nodes


%% Calculate graph theory measures for networks

% Initialize
local_statistics   = zeros(nsub,nnodes,length(localmeasures));
global_statistics  = zeros(nsub,length(globalmeasures));

% Loop over participants
for sub = 1:nsub
    % Take single participant's networks
    wconn = squeeze(weighted_networks(sub,:,:));
    bconn = squeeze(binarised_networks(sub,:,:));
     
    %%% Local statistics %%%
    local_statistics(sub,:,1) = strengths_und(wconn);                          % Strength
    local_statistics(sub,:,2) = efficiency_wei(wconn,1);                       % Local efficiency
    local_statistics(sub,:,3) = clustering_coef_wu(wconn);                     % Clustering coefficient
    local_statistics(sub,:,4) = betweenness_wei(wconn);                        % Betweenness centrality
    local_statistics(sub,:,5) = subgraph_centrality(bconn);                    % Subgraph centrality

    %%% Global statistics %%%
    global_statistics(sub,1) = density_und(wconn);                             % Density
    [global_statistics(sub,3), global_statistics(sub,2)] = charpath(dist,0,0); % Charactersistic path length & global efficiency
    [~,global_statistics(sub,6)] = modularity_und(wconn);                      % Modularity 
    dist = distance_bin(wconn);
    [~, global_statistics(sub,7)] = core_periphery_dir(wconn);                 % Core/periphery structure
    [~,global_statistics(sub,8)] = kcore_bu(bconn,6);                          % K-core 
    [~,global_statistics(sub,9)] = score_wu(wconn,0.6);                        % S-core 
    fprintf('Finished Participant %g\n',sub)
end

% Add small worldness
global_statistics(:,4) = density_controlled_sigma;                             % Set to sigma

%% Calculate average local statistics

mean_local_statistics = squeeze(mean(local_statistics,2));

%% Save 

% Organized to be general 'integration', 'segregation' and 'centrality' metrics
graph_theory_measure_labels = string({'Density','Global Efficiency','Characteristic Path Length','Small Worldness','Strength'...
    'Modularity','Core/Periphery Structure','K-core','S-core','Local Efficiency','Clustering Coefficient',...
    'Betweenness Centrality','Subgraph Centrality'});

density_controlled_organizational_measures = [global_statistics(:,1:4) mean_local_statistics(:,1)...
    global_statistics(5:end) mean_local_statistics(2:end)];


