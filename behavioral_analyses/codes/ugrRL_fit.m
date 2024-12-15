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

N_iter = 500000;

full_tbl = cell(N_sub,2);

% norm0_tbl = table('Size',[N_sub,4],...
%         'VariableTypes', {'string', 'double', 'double', 'double'}, ...
%         'VariableNames', ["subjID", "norm0_mu", "norm0_low", "norm0_high"]);


% for s = 1:N_sub
for s = 1:10
    % for s = 36 %%% for testing purpose. to delete.
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
        ,1 , "ascend"); % min offer accepted
    accept_descend = ...
        sort(unique(computer_sub_mat.offer(computer_sub_mat.accept == 1))...
        ,1 , "descend"); % max offer accepted

    accept_max = accept_descend(1);

    if isscalar(accept_ascend)
        accept_min = accept_ascend;
    else
        if accept_ascend(1) == 1 || accept_ascend(2) - accept_ascend(1)>1 % to prevend wrong button press affect norm0
            accept_min = accept_ascend(2);
        else
            accept_min = accept_ascend(1);
        end
    end

    reject_descend = ...
        sort(unique(computer_sub_mat.offer(computer_sub_mat.accept == 0)),...
        1, "descend"); % max offer rejected

    reject_ascend = ...
        sort(unique(computer_sub_mat.offer(computer_sub_mat.accept == 0)),...
        1, "ascend"); % max offer rejected

    reject_min = reject_ascend(1);

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

    norm0_extremes = [reject_min, reject_max, accept_min, accept_max];

    norm0_mu = (0.5*(reject_min+reject_max) + 0.5*(accept_min+accept_max))/2;
    norm0_width = abs(0.5*(reject_min+reject_max) - 0.5*(accept_min+accept_max));

    %     %%% only for collecting norm0 estimate info. to comment out
    %     norm0_tbl(s,"subjID") = {sub_name};
    %     norm0_tbl(s,"norm0_mu") = {norm0_mu};
    %     norm0_tbl(s,"norm0_low") = {norm0_mu - norm0_width*0.5};
    %     norm0_tbl(s,"norm0_high") = {norm0_mu + norm0_width*0.5};
    % end
    %     writetable(norm0_tbl, ...
    %         fullfile(fits_dir, "sub_include_norm0_guess.csv"))
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    norm0_sigma = min(norm0_width/6,1.5); % 10/6
    norm0_lb = 0;
    norm0_ub = 20;

    sub_name{1} + ...
        sprintf(", s=%d, norm0_lower=%.1f, norm0_higher=%.1f, norm0_mu=%.1f, norm0_sig=%.1f",...
        s, 0.5*(reject_min+reject_max), ...
        0.5*(accept_min+accept_max), ...
        norm0_mu, norm0_sigma)

    tic

    for iter = 1:N_iter
    % for iter = 1:2 %%% for testing purpose. to delete.

        % re-initialize optimization for each iteration
        lb_sub = [0, 0, 0];      % scaled Lower bounds
        ub_sub = [1, 1, 1];     % scaled Upper bounds
        x0_sub = [unifrnd(lb_sub(1),ub_sub(1)), ...
            unifrnd(lb_sub(2),ub_sub(2)), ...
            unifrnd(0,1)];  % Initial values [alpha, tau, epsilon]
        % params_scaling = [20, 10, 1]; % scaling factors
        params_scaling = [50, 20, 1]; % scaling factors

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
        "norm0informedUPDATED", ...
        "_ugrRL.csv")))
    full_tbl{s,2} = init_tbl_sub;
    toc
end

save(fullfile(fits_dir, append("subs_include", ...
    "_alpha", string(params_scaling(1)), ...
    "tau", string(params_scaling(2)), ...
    "norm0rnd", ...
    "_ugrRL.mat")), "full_tbl")

format shortG
clock
