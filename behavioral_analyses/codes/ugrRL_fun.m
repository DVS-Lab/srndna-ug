function [params, exitflag] = ...
    ugrRL_fun(accept_sub, offer_sub, ...
    norm0_sub, x0_sub, ...
    lb_sub, ub_sub)

choices = accept_sub;
rewards = offer_sub;
norm0 = norm0_sub;
x0 = x0_sub;

lb = lb_sub;
ub = ub_sub;


options = optimset('Display', 'on');
[params, LL, exitflag] = ...
    fmincon(@(x) ugrRL_neg_LL_fun(x, choices, rewards, norm0), ...
    x0, [], [], [], [], lb, ub, [], options);

    function nLL = ugrRL_neg_LL_fun(params, choices, rewards, norm)
        alpha = params(1);
        tau = params(2);
        epsilon = params(3);

        % Initialize values
        % norm = 10.0;        % Initial norm value

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

            %%%%%%%
            % Update log-likelihood,
            % log_lik = accept(i,t) * (-log(p)) + (1-accept(i,t)) * (-log(1 - p));
            if choices(t) == 1
                LL = LL + log(p);
            else
                LL = LL + log(1-p);
            end
            %%%%%%%

            % % Update log-likelihood,
            % % log_lik = accept(i,t) * (-log(p)) + (1-accept(i,t)) * (-log(1 - p));
            % if norm < 0 || norm > 20
            %     continue;
            % else
            %     if choices(t) == 1
            %         LL = LL + log(p);
            %     else
            %         LL = LL + log(1-p);
            %     end
            % end
            % %%%%%
        end

        nLL = -LL;  % Return negative log-likelihood
    end
end