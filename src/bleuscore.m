function [uni, bi, tri] = bleuscore( references, candidate )
% Calculate the unigram, bigram, and trigram precision
% scores for the candidate given the referencess

grams = struct();

% Exclude SENTSTART and SENTEND tokens.
candidate_length = length(candidate - 2);
diff = Inf;
split_candidate = textscan(candidate, '%s');

bi_ind = 2;
bi_count = 0;

tri_ind = 3;
tri_count = 0;

for ref=1:length(references)
    % Exclude SENTSTART and SENTEND tokens.
    reference_length = length(references{ref});
    reference = strsplit(references{ref}, ' ');
    
    % Find the nearest length among the references.
    if abs(candidate_length - reference_length) < diff
        diff = abs(candidate_length - reference_length);
        nearest_ref_length = reference_length;
    end
    
    % Do not consider SENTSTART and SENTEND as words.
    % Get the words in each reference.
    for word=2:length(reference) - 1
        uni_word = reference{word};
        bi_word = reference{bi_ind};
        tri_word = reference{tri_ind};
        
        if ~isfield(grams, (uni_word))
           grams.(uni_word) = struct();
        end
        
        if bi_ind < length(ref) && ~isfield(grams.(uni_word), (bi_word))
           grams.(uni_word).(bi_word) = struct();
           bi_count = 1;
        else
           bi_count = bi_count + 1;
        end
        
        if tri_ind < length(ref) && ~isfield(grams.(uni_word).(bi_word), ...
                                             (tri_word))
           grams.(uni_word).(bi_word).(tri_word) = struct();
           tri_count = 1;
        else
           tri_count = tri_count + 1;
        end
        
        bi_ind = bi_bind + 1;
        tri_ind = tri_ind + 1;
    end
end


C_uni = cellfun(@(x) sum(ismember(fieldnames(grams), x)), split_candidate);
N_uni = candidate_length;

p_uni = C_uni / N_uni;
p_bi = bi_count / (N_uni - 1);
p_tri = tri_count / (N_uni - 2);

% Calculate the brevity penalty.
brevity = nearest_ref_length / candidate_length;
if (brevity < 1)
    BP = 1;
else
    BP = exp(1 - brevity) ;
end

uni = BP * (p_uni);
bi  = BP * ((p_uni*p_bi)^(1/2));
tri = BP * ((p_uni*p_bi*p_tri)^(1/3));

end


