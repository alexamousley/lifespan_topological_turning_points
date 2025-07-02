%% Calculate optimial gamma for modularity calculation

%{

Written by Alexa Mousley, MRC Cognition and Brain Sciences Unit
Email: alexa.mousley@mrc-cbu.cam.ac.uk

Compare modularity at multiple gamma values (spatial resolution) and determine at which level the observed networks
are the most different than random networks

%}

%% Load data
clear;clc;

% Add paths
run('/path/to/set_paths.m');  % <<<<< Add path to set_paths file

%% Load data

% Load data
load('lifespan_project_data.mat'); 
load('random_networks.mat')

nsub = length(lifespan_project_data.sample.ages);      
neurogroup = lifespan_project_data.sample.neurogroup;                             
weighted_networks = lifespan_project_data.connectomes.variable_density.normalised_weighted; 

% Define gamma range
gamma_range=0:0.2:2;

%% Calculate modularity at multiple gamma levels

% Loop through participants
for sub = 1:nsub
    % Take single participant's networks
    wconn = squeeze(weighted_networks(sub,:,:));
    randconn = squeeze(random_networks(sub,:,:));
    
    % Iterate through gamma
    num=1; % Counter
    for i = gamma_range
        [~, randmodularity(sub,num)] = modularity_und(randconn,i);
        [~, modularity(sub,num)] = modularity_und(wconn,i);
        num=num+1;
    end
end
null_modularity = randmodularity(find(neurogroup==1),:);
obs_modularity = modularity(find(neurogroup==1),:);

%% Find means and differences between observed and random network modularity

% Loop through modularity levels
for col = 1:width(obs_modularity)

    % Perform two-sample KS test
    [h, p, ksstat] = kstest2(obs_modularity(:,col), null_modularity(:,col));

    % Display results
    fprintf('KS statistic: %.4f\n', ksstat);
    fprintf('p-value: %.10f\n', p);
    if h == 1
        disp('Distributions are significantly different.')
    else
        disp('No significant difference between distributions.')
    end
end

%% Variable density at 0.6 only

% Loop through participants
for sub = 1:nsub
    % Take single participant's networks
    wconn = squeeze(weighted_networks(sub,:,:));
    
    [~, modularity(sub)] = modularity_und(wconn,0.6);
end
obs_modularity = modularity(find(neurogroup==1),:)';


%% Supplementary figures

fig = figure(2);
hold on
h1 = histogram(obs_modularity(:,7),'FaceColor','black');
h2 = histogram(null_modularity(:,7),'FaceColor','red');
legend([h1, h2], {'Observed','Random'});
xticklabels([]);
yticklabels([]);
hold off
exportgraphics(fig,'1.4gamma.png','Resolution',400);



