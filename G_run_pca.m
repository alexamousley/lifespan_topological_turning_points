%% Conduct Principal Components Analysis

%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

Run PCA on GAM age-predicted values 

%}

%% Load data
clear;clc;

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file

% Load data
load('umap_input_data');

%% Set up data

% Concatenate fields into one array
fieldNames = fieldnames(mat);                          % Pull field names
numFields = numel(fieldNames);                         % Number of fields
numSubjects = length(mat.(fieldNames{1}));             % Length of data in each field
data = zeros(numSubjects,numFields);                   % Initialize data matrix
for i = 1:numFields
    currentField = mat.(fieldNames{i});                % Get field data
    data(:,i) = currentField;                          % Store in row of data matrix
end

% Define age
ages = data(:,1);
% Remove age column
data(:,1) = []; 

% Standardized data
data = zscore(data);

%% Run Initial PCA 

% Perform PCA and save variables
[loadings, score, eigenvalues, ~, explained] = pca(data);

%% Conduct Parallel Analysis

num_iterations = 1000;                                      % Number of iterations for parallel analysis
num_variables = size(data, 2);                              % Find number of variables
random_eigenvalues = zeros(num_iterations, num_variables);  % Initialize randomized eigenvalues

% Loop through iterations
for i = 1:num_iterations
    random_data = zscore(randn(size(data, 1), num_variables)); % Create standardised random data
    [~, ~, random_eigenvalues(i,:),~, ~] = pca(random_data);   % Run PCA and only save eigenvalues
end

% Calculate the 95th percentile for each column
simulated_eigenvalues = zeros(1, size(random_eigenvalues, 2));
for i = 1:size(random_eigenvalues, 2)
    simulated_eigenvalues(i) = prctile(random_eigenvalues(:, i), 95);
end

% Plot actual and simulated eigenvalues on the same plot
figure;
hold on;
plot(1:num_variables, eigenvalues, 'bo-', 'LineWidth', 2, 'DisplayName', 'Observed');
plot(1:num_variables, simulated_eigenvalues, 'k*--', 'LineWidth', 2, 'DisplayName', 'Simulated');
xlabel('Principal Component', 'FontName', 'Arial');
ylabel('Eigenvalue', 'FontName', 'Arial');
legend('show', 'FontName', 'Arial');
% Set the font of legend items to Arial
legend('FontName', 'Arial');
% Set thefont of the axis ticks to Arial
set(gca, 'FontName', 'Arial');
hold off;

%% Re-run PCA with 3 Components

% Run PCA constrained to 3 components
[loadings, score, eigenvalues, ~, explained] = pca(data,'NumComponents',3);

% Perform orthogonal rotation on PCA loadings
rotated_loadings = rotatefactors(loadings, 'Method', 'varimax');

% Display the original and rotated loadings
disp('Original Loadings:');
disp(loadings);
disp('Rotated Loadings:');
disp(rotated_loadings);

% Plot original PC1/PC2
figure;
subplot(1, 2, 1);
scatter(loadings(:, 1), loadings(:, 2));
title('Original PC1/PC2');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
grid on;

% Plot rotated PC1/PC2
subplot(1, 2, 2);
scatter(rotated_loadings(:,1),rotated_loadings(:,2));
title('Rotated PC1/PC2');
xlabel('Principal Component 1 (Rotated)');
ylabel('Principal Component 2 (Rotated)');
grid on;

% Calculate the cumulative variance explained
cumulative_variance_explained = cumsum(eigenvalues) / sum(eigenvalues);

% Plot the cumulative variance explained
figure;
plot(cumulative_variance_explained, 'LineWidth', 2);
title('Cumulative Variance Explained');
xlabel('Principal Components');
ylabel('Cumulative Variance Explained');
grid on;

