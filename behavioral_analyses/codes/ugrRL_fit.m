% created 12/11/2024 by Jen Yang
% last modified 12/11/2024 by Jen Yang
% code to fit ug_delta per subject

clear
clc

%% set up directory and load data
data_dir = "/Users/momocco/Documents/GitHub/srndna-ug/behavioral_analyses/data";
fits_dir = "/Users/momocco/Documents/GitHub/srndna-ug/behavioral_analyses/fits";
computer_dir = fullfile(data_dir, "computer_filtered.txt");
computer_mat = readtable(computer_dir);

sub_list = readtable(fullfile(data_dir, "sub_include.csv"));
[N_sub,~] = size(sub_list);

%% prepare cell to save fits
% row - each iteration
% columns - exitflag, alpha0, tau0, epsilon0, norm0, alpha_i, tau_i, epsilon_i, norm_i,
colnames = {'exitflag', 'negLL', 'norm0', 'alpha0', 'alpha_i', ...
    'epsilon0', 'epsilon_i', 'tau0', 'tau_i'};
coltypes = {'double','double', 'double', 'double','double', 'double', ...
    'double', 'double', 'double'};
N_iter = 10000;

full_tbl = cell(N_sub,2);

for s = 1:N_sub
    % s = 3; %%% for testing purpose. to delete.
    sub_name = sub_list{s,1};
    computer_sub_mat = computer_mat(...
        strcmp(computer_mat.subjID, sub_name) == 1,:);

    full_tbl{s,1} = sub_name;
    
    % make empty table for current sut
    init_tbl_sub = table('Size',[N_iter,length(colnames)],...
    'VariableTypes', coltypes, 'VariableNames', colnames);
    
    % set initial norm based on choice information
    accept_sub = computer_sub_mat.accept;
    offer_sub = computer_sub_mat.offer;

    accept_min = min(computer_sub_mat.offer(computer_sub_mat.accept == 1)); % min offer accepted,
    reject_max = max(computer_sub_mat.offer(computer_sub_mat.accept == 0)); % max offer rejected
    
    norm0_mu = (accept_min + reject_max)/2;
    norm0_sigma = max(abs(accept_min - reject_max)/3,1);
    norm0_lb = 1;
    norm0_ub = 20;

    sub_name{1}

    for iter = 1:N_iter
    % for iter = 1:2
        % iter = 1; %%% for testing purpose. to delete.
        % sprintf("sub %d iter %d", s, iter) %%% for testing purpose. to delete.

        % re-initialize optimization for each iteration
        lb_sub = [0, 0, 0];      % Lower bounds
        ub_sub = [10, 10, 1];     % Upper bounds
        x0_sub = [unifrnd(lb_sub(1),ub_sub(1)), ...
            unifrnd(lb_sub(2),ub_sub(2)), ...
            unifrnd(0,1)];  % Initial values [alpha, tau, epsilon]
        

        %%%%% fixed norm0 = 10 or rand norm0
        % norm0_sub = 7.5;
        while true % Generate random numbers until one falls within bounds
            norm0_sub = normrnd(norm0_mu, norm0_sigma);
            if norm0_sub >= norm0_lb && norm0_sub <= norm0_ub
                break;
            end
        end
        %%%%% fixed norm0 = 10 or rand norm0
        
        % fit model
        [params, negLL, exitflag] = ...
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
        init_tbl_sub(iter, 'negLL') = {negLL};
        
        init_tbl_sub(iter, 'alpha_i') = {params(1)};  % envy parameter
        init_tbl_sub(iter, 'tau_i') = {params(2)};   % inverse temperature
        init_tbl_sub(iter, 'epsilon_i') = {params(3)}; % learning rate
    end
    writetable(init_tbl_sub, ...
        fullfile(data_dir, append(sub_name{1}, "_ugrRL.csv")))
    full_tbl{s,2} = init_tbl_sub;
end
save(fullfile(fits_dir, append("subs_include", "_ugrRL.mat")), "full_tbl")

