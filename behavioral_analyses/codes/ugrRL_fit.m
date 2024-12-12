% created 12/11/2024 by Jen Yang
% last modified 12/11/2024 by Jen Yang
% code to fit ug_delta per subject

clear
clc

%% set up directory and load data
data_dir = "/Users/momocco/Documents/GitHub/srndna-ug/behavioral_analyses/data";
computer_dir = fullfile(data_dir, "computer_filtered.txt");
computer_mat = readtable(computer_dir);

sub_list = readtable(fullfile(data_dir, "sub_include.csv"));
[N_sub,~] = size(sub_list);

%% prepare cell to save fits
% row - each iteration
% columns - exitflag, alpha0, tau0, epsilon0, norm0, alpha_i, tau_i, epsilon_i, norm_i,
colnames = {'exitflag', 'alpha0', 'tau0', 'epsilon0', 'norm0', ...
    'alpha_i', 'tau_i', 'epsilon_i', 'norm_i'};
coltypes = {'double','double','double','double', 'double', ...
    'double', 'double', 'double', 'double'};
N_iter = 5000;

full_tbl = cell(N_sub,2);

for s = 1:N_sub
    s = 1; %%% for testing purpose. to comment out.
    sub_name = sub_list{s,1};
    computer_sub_mat = computer_mat(...
        strcmp(computer_mat.subjID, sub_name) == 1,:);

    % find initial norm by finding the min accept and max reject
    norm_ub = min(computer_sub_mat.offer(...
        computer_sub_mat.accept == 1));

    norm_lb = max(computer_sub_mat.offer(...
        computer_sub_mat.accept == 0));

    % norm0_mu = (norm_ub + norm_lb)/2;

    full_tbl{s,1} = sub_name;
    
    % make empty table for current sut
    init_tbl_sub = table('Size',[N_iter,length(colnames)],...
    'VariableTypes', coltypes, 'VariableNames', colnames);
    
    accept_sub = computer_sub_mat.accept;
    offer_sub = computer_sub_mat.offer;

    for iter = 1:N_iter
        iter = 1; %%% for testing purpose. to comment out.
        % re-initialize optimization for each iteration
        % x0 = [0.1, 0.1, 0.1];  % Initial values [alpha, tau, epsilon]
        lb_sub = [0, 0, 0];      % Lower bounds
        ub_sub = [1, 10, 1];     % Upper bounds
        x0_sub = [unifrnd(0,ub_sub(1)), ...
            unifrnd(0,ub_sub(2)), ...
            unifrnd(0,1)];  % Initial values [alpha, tau, epsilon]
        
        % norm0 = unifrnd(0,20);
        % generate rand num~normal(10,4) and >0
        accept_min = min(computer_sub_mat.offer(computer_sub_mat.accept == 1));
        reject_max = max(computer_sub_mat.offer(computer_sub_mat.accept == 0));

        norm0_mu = (accept_min + reject_max)/2;
        norm0_sigma = 2;
        norm0_lb = 0;
        norm0_ub = 20;

        while true % Generate random numbers until one falls within bounds
            norm0_sub = normrnd(norm0_mu, norm0_sigma);
            if norm0_sub >= norm0_lb && norm0_sub <= norm0_ub
                break;
            end
        end
        
        % fit model
        [params, exitflag] = ...
            ugrRL_fun(accept_sub, offer_sub, ...
            norm0_sub, x0_sub, ...
            lb_sub, ub_sub);

        % Extract parameters
        %%% initials
        init_tbl_sub(iter, 'alpha0') = {x0_sub(1)};
        init_tbl_sub(iter, 'tau0')= {x0_sub(2)};
        init_tbl_sub(iter, 'epsilon0') = {x0_sub(3)};
        init_tbl_sub(iter, 'norm0') = {norm0_sub};

        init_tbl_sub(iter, 'exitflag') = {exitflag};
        
        init_tbl_sub(iter, 'alpha_i') = {params(1)};  % envy parameter
        init_tbl_sub(iter, 'tau_i') = {params(2)};   % inverse temperature
        init_tbl_sub(iter, 'epsilon_i') = {params(3)}; % learning rate

    end
end


