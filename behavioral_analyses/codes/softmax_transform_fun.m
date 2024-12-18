function epsilon = softmax_transform_fun(x)
    % Create a 2-element vector with x and 0
    % Apply softmax
    exp_scores = exp(x);
    p = exp_scores ./ sum(exp_scores);
    
    % Return first element as the transformed value
    epsilon = p(1);
end
