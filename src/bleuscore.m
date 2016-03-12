function scores = bleuscore( references, cand )
% Calculate the unigram, bigram, and trigram precision
% scores for the candidate given the referencess
warning('off', 'all');

% Bluemix and decode2 were giving us serious problems.
% This is our very hacky fix.
cand = strsplit(' ', cand);
cand = strjoin(cand(2:end-1));
cand = regexprep(cand, ' SENTSTART', '');
cand = ['SENTSTART ' cand ' SENTEND'];
cand = strsplit(' ', cand);

% A struct to keep track of unigrams, bigrams, and trigrams in
% the given reference sentences and candidate sentence.
ref_n_grams = struct();
cand_n_grams = struct();


% Variables to determine brevity constants.
diff = Inf;
r = 0;
N = length(cand) - 2;

% C values for unigrams, bigrams, and trigrams.
c_u = 0;
c_b = 0;
c_t = 0;

% Build the reference n-gram struct.
for k=1:length(references)
    % Index counters. We start one word into the sentence and end
    % one word early to avoid the SENTSTART and SENTEND markers.
    u_i = 2;
    b_i = 3;
    ref = strsplit(' ', references{k});
    
    % Check if the current reference sentences is the nearest in length
    % to the candidate.
    if abs(length(ref) - N) < diff
        r = length(ref);
        diff = length(ref) - N;
    end
    
    for t_i=4:length(ref) - 1
        ref_n_grams.(ref{u_i}).(ref{b_i}).(ref{t_i}) = 1;
        ref_n_grams.(ref{b_i}) = (ref{t_i});
        ref_n_grams.(ref{t_i}) = struct();
        
        u_i = b_i;
        b_i = t_i;
    end
end

% Build the candidate n-gram struct and calculate precisions.
u_i = 2;
b_i = 3;

for t_i=4:length(cand) - 1
    cand_n_grams.(cand{u_i}).(cand{b_i}).(cand{t_i}) = 1;
    cand_n_grams.(cand{b_i}) = (cand{t_i});
    cand_n_grams.(cand{t_i}) = struct();
    
    if isfield(ref_n_grams, (cand{u_i}))
        c_u = c_u + 1;
        if isfield(ref_n_grams.(cand{u_i}), (cand{b_i}))
            c_b = c_b + 1;
            if isfield(ref_n_grams.(cand{u_i}).(cand{b_i}), (cand{t_i}))
                c_t = c_t + 1;
            end
        end
    end
    u_i = b_i;
    b_i = t_i;
end

% Calculate the brevity penalty.
brevity = r / N;
if brevity < 1
    BP = 1;
else
    BP = exp(1 - brevity);
end

% Precision values.
p_u = c_u / N;
p_b = c_b / (N - 1);
p_t = c_t / (N - 2);

% BLEU scores.
uni = ( BP ) * ( (p_u) );
bi  = ( BP ) * (((p_u)*(p_b))^(1/2));
tri = ( BP ) * (((p_u)*(p_b)*(p_t))^(1/3));

scores = [uni, bi, tri];

end


