function estL = getMetricForNWKernelRegression(tstPt, trYs, trData, regMultiplier)

%hv: nargin: num of function input arguments
if nargin < 4
    regMultiplier = -3;
end

[Dim,datanum] = size(trData);
% obtain estL
estMean = mean([trYs;trData],2);
estMeanx = estMean(2:end);
estSig = [trYs;trData]*[trYs;trData]'/datanum - estMean*estMean';
estSig = estSig + eye(Dim + 1)*trace(estSig)*10^-6;  % regularize both x and y
invEstSigx = inv(estSig(2:end,2:end)); %hv: end automatically (built-in) gives the index of the last element.
Met = invEstSigx*(tstPt - estMeanx)*estSig(1,2:end)*invEstSigx;Met = Met + Met';
dim = size(Met,1);
[V,D] = eig(Met);
Evals = diag(D)'; % makes row vector with the eigenvalues in D (diagonal matrix)
% only two nonzero eigenvalues
[AbsEvals, sortedIndex] = sort(abs(Evals));
%     V = V(:,sortedIndex); %%%%%%%%%%%%%%%%%%%%%
PosEvalIndex = [];
NegEvalIndex = [];

regR = max(AbsEvals)*10^regMultiplier; %hv: experiment section 3rd paragarph
if Evals(sortedIndex(end)) > 0
    PosEvalIndex = sortedIndex(end);
else
    NegEvalIndex = sortedIndex(end);
end
if Evals(sortedIndex(end - 1)) > 0
    PosEvalIndex = [PosEvalIndex sortedIndex(end - 1)];
else
    NegEvalIndex = [NegEvalIndex sortedIndex(end - 1)];
end
OtherIndexes = sortedIndex(1:end-2);

PosEvalNum = size(PosEvalIndex, 2);
NegEvalNum = size(NegEvalIndex, 2);

estL = [V(:,PosEvalIndex)*diag(sqrt(Evals(PosEvalIndex)*PosEvalNum + regR)) ...    % 2 ***
    V(:,NegEvalIndex)*diag(sqrt(Evals(NegEvalIndex)*NegEvalNum*(-1) + regR)) ...
    V(:,OtherIndexes)*diag(sqrt(regR))];
estL = estL/max(max(estL,[],1),[],2); %hv: this seems like to just
% preventing the numbers in estL getting too big. Acutally this line is
% redundant due to the line of code written right below this.
estL = estL/det(estL*estL')^(1/(2*dim)); % hv: corresponds to dividing by T (determinant of kernel metric matrix A which is all the eigen values of A multiplied) in the paper
