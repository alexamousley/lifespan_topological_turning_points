%% Harmonization

%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

Harmonize networks across atlases, then harmonize networks across dataset

%}


%% Add paths and load data
clear;clc;

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file

% Load data
load('thresholded_data.mat');

%% Harmonization

%%% Harmonize across atlas %%%

% Setup data
networks = thresholded_data.connectomes.controlled_normalized_weighted;     % Define networks (Set which kind of networks to harmonize)
harmonize_variable = thresholded_data.demographics.atlas;                   % Define atlases to be harmonized
covariates = [thresholded_data.demographics.participant_id ...
    thresholded_data.demographics.age ...
    thresholded_data.demographics.sex thresholded_data.demographics.group]; % Define variables to keep variation across
nrois = width(networks);                                                    % Define number of ROIs
nsub = length(thresholded_data.demographics.age);                           % Number of participants

% Reshape networks from matrix to vectors 
for i=1:nsub
    network_vector(:,i)=reshape(squeeze(networks(i,:,:)),1,(nrois*nrois));
end

% Initialize 
zero_indexes = [];
% Remove empty rows
for i = 1:height(network_vector)
    row = squeeze(network_vector(i,:));   % Take one row
    if all(row == 0)                      % If row is empty
        zero_indexes = [zero_indexes, i]; % Save index
    end
end
% Delete rows with indexes in the list of zeros
harm_conns = network_vector; harm_conns(zero_indexes, :) = [];

% Run harmonization
harmonized_vector = combat(harm_conns,harmonize_variable,covariates,1);

% Insert zero connections where they belong
restored_network_vectors = zeros(size(network_vector));                                             % Initialize with zeros
restored_network_vectors(setdiff(1:size(network_vector, 1), zero_indexes), :) = harmonized_vector;  % Copy the non-zero rows
restored_network_vectors(zero_indexes, :) = zeros(length(zero_indexes), nsub);                      % Restore the all-zero rows

%%% Reshape vectors back into matrices %%%
% Initialize
unpacked = zeros(size(restored_network_vectors, 2), nrois,nrois);
% Loop through participants
for sub = 1:nsub
    unpacked(sub,:,:) = reshape(restored_network_vectors(:,sub),nrois,nrois);
end

%%% Apply mask (only keep connections that were present before harmonization and are positive) %%%
% Loop through participants
for sub = 1:nsub
    raw_conn = squeeze(networks(sub,:,:));  % Original networks
    harm_conn = squeeze(unpacked(sub,:,:)); % Harmonized networks
    % Create mask
    mask = raw_conn > 0;
    % Apply mask
    filtered_harm_conn = harm_conn .* mask; 
    % Delete negative connections
    filtered_harm_conn(filtered_harm_conn < 0) = 0;
    atlas_harmonized_connectomes(sub,:,:) = filtered_harm_conn;
end

%%% Harmonise across studies %%%
% Setup data
networks = atlas_harmonized_connectomes;                    % Define networks 
harmonize_variable = thresholded_data.demographics.dataset; % Define dataset to be harmonized

% Reshape networks from matrix to vectors 
for i=1:nsub
    network_vector(:,i)=reshape(squeeze(networks(i,:,:)),1,(nrois*nrois));
end

% Initialize 
zero_indexes = [];
% Remove empty rows
for i = 1:height(network_vector)
    row = squeeze(network_vector(i,:));   % Take one row
    if all(row == 0)                      % If row is empty
        zero_indexes = [zero_indexes, i]; % Save index
    end
end
% Delete rows with indexes in the list of zeros
harm_conns = network_vector; harm_conns(zero_indexes, :) = [];

% Run harmonization
harmonized_vector = combat(harm_conns,harmonize_variable,covariates,1);

% Insert zero connections where they belong
restored_network_vectors = zeros(size(network_vector));                                             % Initialize with zeros
restored_network_vectors(setdiff(1:size(network_vector, 1), zero_indexes), :) = harmonized_vector;  % Copy the non-zero rows
restored_network_vectors(zero_indexes, :) = zeros(length(zero_indexes), nsub);                      % Restore the all-zero rows

%%% Reshape vectors back into matrices %%%
% Initialize
unpacked = zeros(size(restored_network_vectors, 2), nrois,nrois);
% Loop through participants
for sub = 1:nsub
    unpacked(sub,:,:) = reshape(restored_network_vectors(:,sub),nrois,nrois);
end

%%% Apply mask (only keep connections that were present before harmonization and are positive) %%%
% Loop through participants
for sub = 1:nsub
    raw_conn = squeeze(networks(sub,:,:));  % Original networks
    harm_conn = squeeze(unpacked(sub,:,:)); % Harmonized networks
    % Create mask
    mask = raw_conn > 0;
    % Apply mask
    filtered_harm_conn = harm_conn .* mask; 
    % Delete negative connections
    filtered_harm_conn(filtered_harm_conn < 0) = 0;
    harmonized_connectomes(sub,:,:) = filtered_harm_conn;
end

%% Select analysis sample

load('crosssectional_index'); % Load index of to select cross-sectional sample

analysis_index = find(crosssectional_index==1 & thresholded_data.demographics.group == 1);
% Use this index to select harmonized networks and demographics data to
% obtain the sample used in the analysis (same as the harmonized_data.mat)












