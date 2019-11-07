function [kernelOutputs, logKernelOutputs, logscale] = getScaledKernelVal(logkernelvals)
% scale kernel outputs
% logkernelvals: tstdatanum x trdatanum

logscale = max(logkernelvals, [], 2);
logKernelOutputs = logkernelvals - logscale*ones(1,size(logkernelvals,2)); %hv: subtract the max logkernelval from the whole list of values
kernelOutputs = exp(logKernelOutputs); %hv:values in the  logkerneloutputs are always smaller than 0