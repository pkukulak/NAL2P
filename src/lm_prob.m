function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);
  
  logProb = 0;
  for i=1:(length(words)-1) % check off by one error
     
     % Initialize the second part of the bigram if we haven't seen it.
     if ( ~isfield(LM.bi, (words{i}))) 
            LM.bi.(words{i}) = struct((words{i+1}), 0);
     end
     
     % Initialize the bigram count if we haven't seen it.
     if ( ~isfield(LM.bi.(words{i}), (words{i+1}))) 
            LM.bi.(words{i}).(words{i+1}) = 0;
     end
     
     % Initialize the unigram count if we haven't seen it.
     if (~isfield(LM.uni, (words{i}))) 
            LM.uni.(words{i}) = 0;
     end
            
     top_count = LM.bi.(words{i}).(words{i+1}) + delta;
     bot_count = LM.uni.(words{i}) + (delta * vocabSize);
     
     % Zero divided by zero error.
     if (~(bot_count || top_count))
         pr = 0;
     else
         pr = (top_count / bot_count);
     end
     logProb = logProb + log2(pr);
  end
  
return