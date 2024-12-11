% created 12/11/2024 by Jen Yang
% last modified 12/11/2024 by Jen Yang
% code to fit ug_delta per subject

data_dir = "/Users/momocco/Documents/GitHub/srndna-ug/behavioral_analyses/data";
computer_dir = fullfile(data_dir, "computer_filtered.txt");
computer_mat = readtable(computer_dir);

sub_list = readtable(fullfile(data_dir, "sub_include.csv"));
[N_sub,~] = size(sub_list);

sub_name = sub_list{2,1};
sub_name

computer_sub_mat = computer_mat(...
    strcmp(computer_mat.subjID, sub_name) == 1,:);

function nLL = neg_LL(params, choices, rewards, norm)
alpha = params(1);
beta = params(2);
epsilon = params(3);

% Initialize values
% norm = 10.0;        % Initial norm value

% Calculate likelihood
LL = 0;
for t = 1:length(choices)
    % Calculate prediction error
    PE = rewards(t) - norm;

    % Calculate utility including envy
    util = rewards(t) - alpha * max(norm - rewards(t), 0);

    % Softmax probability
    p = 1 / (1 + exp(-beta * util));

    % Update log-likelihood
    if choices(t) == 1
        LL = LL + log(p);
    else
        LL = LL + log(1-p);
    end


    %%%%%%% to continue
    z = util * tau(i);
    log_lik = accept(i,t) * (-log(1 + exp(-z))) + ...
        (1-accept(i,t)) * (-log(1 + exp(z)));
    %%%%%%% to continue

    % Update norm
    norm = norm + epsilon * PE;
end

nLL = -LL;  % Return negative log-likelihood
end


% Initialize optimization
% x0 = [0.1, 0.1, 0.1];  % Initial values [alpha, tau, epsilon]
lb = [0, 0, 0];      % Lower bounds
ub = [20, 10, 1];     % Upper bounds
x0 = [unifrnd(0,ub(1)), unifrnd(0,ub(2)), unifrnd(0,1)];  % Initial values [alpha, tau, epsilon]
norm0 = unifrnd(0,20);


[x0, norm0]

choices = computer_sub_mat.accept;
rewards = computer_sub_mat.offer;

options = optimset('Display', 'off');
[params, LL, exitflag] = fmincon(@(x) neg_LL(x, choices, rewards, norm0), ...
    x0, [], [], [], [], lb, ub, [], options);
[params, exitflag]

% Extract parameters
alpha = params(1);  % envy parameter
beta = params(2);   % inverse temperature
epsilon = params(3); % learning rate

