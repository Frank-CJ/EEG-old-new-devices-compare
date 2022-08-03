
function data = Preprocessing(sourcedata, samplingrate_original, samplingFrequency2Use)
    median_width = 5;
    nRow= size(sourcedata,1);
    resamplingRate = samplingrate_original/samplingFrequency2Use;
    order = 1;
    cut_off_highpass_freq = 0.1; 

    tmp = highpass_simple(sourcedata,order,cut_off_highpass_freq,samplingrate_original);
    tmp = double(tmp(resamplingRate:resamplingRate:nRow,1));
    data = medfilt1(tmp,median_width); 
end