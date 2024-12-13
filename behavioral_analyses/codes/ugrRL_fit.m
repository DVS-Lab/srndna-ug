% created 12/11/2024 by Jen Yang
% last modified 12/11/2024 by Jen Yang
% code to fit ug_delta per subject

clear

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
    'epsilon0', 'epsilon_i', 'tau0', 'tau_i', ...
    'alpha0_s', 'alpha_i_s', ...
    'epsilon0_s', 'epsilon_i_s', 'tau0_s', 'tau_i_s'};
coltypes = {'double', 'double', 'double', 'double','double', ...
    'double', 'double', 'double', 'double',...
    'double','double', ...
    'double', 'double', 'double', 'double'};

N_iter = 10000;

full_tbl = cell(N_sub,2);

for s = 1:N_sub
    % for s = 1:2 %%% for testing purpose. to delete.
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

    % sub might press the wrong button
    accept_ascend = ...
        sort(unique(computer_sub_mat.offer(computer_sub_mat.accept == 1))...
        ,1 , "ascend"); % min offer accepted,

    if isscalar(accept_ascend) == 1
        accept_min = accept_ascend;
    else
        if accept_ascend(1) == 1 | accept_ascend(2) - accept_ascend(1)>1 % to prevend wrong button press affect norm0
            accept_min = accept_ascend(2);
        else
            accept_min = accept_ascend(1);
        end
    end

    reject_descend = ...
        sort(unique(computer_sub_mat.offer(computer_sub_mat.accept == 0)),...
        1, "descend"); % max offer rejected

    % sub might press the wrong button
    if isscalar(reject_descend)
        reject_max = reject_descend;
    else
        if reject_descend(1) == 10 || reject_descend(1) - reject_descend(2) > 1
            reject_max = reject_descend(2);
        else
            reject_max = reject_descend(1);
        end
    end

    norm0_mu = (accept_min + reject_max)/2;
    norm0_sigma = max(abs(accept_min - reject_max)/3,1);
    norm0_lb = 1;
    norm0_ub = 20;

    sub_name{1} + sprintf(", s=%d, accept_min=%d, reject_max=%d, norm0_mu=%d",...
        s, accept_min, reject_max, norm0_mu)

    tic

    for iter = 1:N_iter
        % for iter = 1:2 %%% for testing purpose. to delete.

        % re-initialize optimization for each iteration
        lb_sub = [0, 0, 0];      % scaled Lower bounds
        ub_sub = [1, 1, 1];     % scaled Upper bounds
        x0_sub = [unifrnd(lb_sub(1),ub_sub(1)), ...
            unifrnd(lb_sub(2),ub_sub(2)), ...
            unifrnd(0,1)];  % Initial values [alpha, tau, epsilon]
        params_scaling = [100, 20, 1]; % scaling factors

        %%% informed variable norm initial
        while true % Generate random numbers until one falls within bounds
            norm0_sub = normrnd(norm0_mu, norm0_sigma);
            if norm0_sub >= norm0_lb && norm0_sub <= norm0_ub
                break;
            end
        end

        %%% random norm initial
        % norm0_sub = unifrnd(0,20); % can use this to compare model, e.g. informed variable norm0 vs uninformed variable norm 0

        % record initials
        init_tbl_sub(iter, 'alpha0') = {x0_sub(1) * params_scaling(1)}; % real
        init_tbl_sub(iter, 'tau0')= {x0_sub(2) * params_scaling(2)};
        init_tbl_sub(iter, 'epsilon0') = {x0_sub(3) * params_scaling(3)};
        init_tbl_sub(iter, 'norm0') = {norm0_sub};

        init_tbl_sub(iter, 'alpha0_s') = {x0_sub(1)}; % scaled
        init_tbl_sub(iter, 'tau0_s')= {x0_sub(2)};
        init_tbl_sub(iter, 'epsilon0_s') = {x0_sub(3)};

        % fit model
        [params, negLL, exitflag] = ...
            ugrRL_fun(accept_sub, offer_sub, ...
            norm0_sub, x0_sub, ...
            lb_sub, ub_sub, params_scaling);

        % record estimates
        init_tbl_sub(iter, 'exitflag') = {exitflag};
        init_tbl_sub(iter, 'negLL') = {negLL};

        init_tbl_sub(iter, 'alpha_i') = {params(1) * params_scaling(1)};  % envy parameter, real
        init_tbl_sub(iter, 'tau_i') = {params(2) * params_scaling(2)};   % inverse temperature
        init_tbl_sub(iter, 'epsilon_i') = {params(3) * params_scaling(3)}; % learning rate

        init_tbl_sub(iter, 'alpha_i_s') = {params(1)};  % envy parameter, scaled
        init_tbl_sub(iter, 'tau_i_s') = {params(2)};   % inverse temperature
        init_tbl_sub(iter, 'epsilon_i_s') = {params(3)}; % learning rate

    end
    writetable(init_tbl_sub, ...
        fullfile(fits_dir, append(sub_name{1}, ...
        "_alpha", string(params_scaling(1)), ...
        "tau", string(params_scaling(2)), ...
        "_ugrRL.csv")))
    full_tbl{s,2} = init_tbl_sub;
    toc
end
tic
save(fullfile(fits_dir, append("subs_include", ...
    "_alpha", string(params_scaling(1)), ...
    "tau", string(params_scaling(2)), ...
    "_ugrRL.mat")), "full_tbl")
toc
