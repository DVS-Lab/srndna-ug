function [params, negLL, exitflag] = ...
    ugrRL_fun(accept_sub, offer_sub, ...
    norm0_sub, x0_sub, ...
    lb_sub, ub_sub, params_scaling)

choices = accept_sub;
rewards = offer_sub;
norm0 = norm0_sub;
x0 = x0_sub;

lb = lb_sub;
ub = ub_sub;


options = optimset('Display', 'off', 'MaxIter', 1000);
[params, nLL, exitflag] = ...
    fmincon(@(x) ugrRL_neg_LL_fun(x.*params_scaling, choices, rewards, norm0), ...
    x0, [], [], [], [], lb, ub, [], options);

negLL = nLL;
end

function nLL = ugrRL_neg_LL_fun(params, choices, rewards, norm0)
        alpha = params(1);
        tau = params(2);
        epsilon = params(3);

        % Initialize values
        norm = norm0;        % Initial norm value

        % Calculate likelihood
        LL = 0; % initial likelihood

        for t = 1:length(choices)
            % Calculate prediction error
            PE = rewards(t) - norm;

            % Calculate utility including envy
            util = rewards(t) - alpha * max(norm - rewards(t), 0);

            % % Update norm
            norm = norm + epsilon * PE;

            % Softmax probability
            p = 1 / (1 + exp(-tau * util));

            % Update log-likelihood,
            % log_lik = accept(i,t) * (-log(p)) + (1-accept(i,t)) * (-log(1 - p));
            if choices(t) == 1
                LL = LL + log(max(p, 1e-100)); % to go around p = 0
                % LL = LL + log(p);
            else
                LL = LL + log(max(1-p, 1e-100)); % to go around 1-p = 0
                % LL = LL + log(1-p);
            end
        end

        nLL = -LL;  % Return negative log-likelihood

        % if isnan(LL) || isinf(LL)
        %     nLL = 1e10;  % Return large finite number
        % else
        %     nLL = -LL;
        % end
    end