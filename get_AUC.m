function [AUC, error, realtime, livetime] = get_AUC(spectrum,peaksOI)

num_peaks = length(peaksOI);
AUC = zeros(1,num_peaks);
error = zeros(1,num_peaks);
unbackgrounded = spectrum.counts;
hold on
trimmedBackground = baseliner(unbackgrounded(71:end)); % removing low energy drop off
filler = zeros(70,1);
background = vertcat(filler, trimmedBackground);
counts = unbackgrounded-background;
plot(unbackgrounded,'k')
for i = 1:num_peaks
    meanCN = peaksOI(i);
    
% sub-protocol to adjust mean_cn to reflect actual location of peak
% Checks to make sure peak actually exists.
    searchWidth = 20; % 20 channel width search
    range = (meanCN-searchWidth):(meanCN+searchWidth);
    [maxValue,maxIndex]= max(counts(range));
    
    % adjust peak location center
    if maxValue > 10
        meanCN = range(maxIndex);
    end
    halfMax = counts(meanCN)/2;
    
    scatter(meanCN, -10)
    mask = counts((meanCN-15):(15+meanCN))>= halfMax;
    FWHM = sum(mask);
    if counts(meanCN) > 50
        idxHigh = floor(meanCN+3*FWHM);
        idxLow = floor(meanCN-3*FWHM);
        idxRng = [idxLow:idxHigh];
        errorBelow = std(counts(round(idxLow-FWHM):idxLow));
        errorAbove = std(counts(idxHigh:round(idxHigh+FWHM)));
        stdev = (errorBelow+errorAbove)/2;

    else
        idxHigh = meanCN+7;
        idxLow = meanCN-7;
        idxRng = [idxLow:idxHigh];
        errorBelow = std(counts(idxLow-5:idxLow));
        errorAbove = std(counts(idxHigh:idxHigh+5));
        stdev = (errorBelow+errorAbove)/2;
    end

    
%     x = [round(meanCN-4.5*FWHM) round(meanCN+4.5*FWHM)];
%     y = [low_counts high_counts];
%     fit = polyfit(x,y,1);
%     background = polyval(fit,idxRng);
%     

% remove all negative values from the region
    subCounts = counts(idxRng);
    subCounts(subCounts<0) = 0;
    AUC(1,i) = sum(subCounts);
    error(1,i) = sqrt(abs(AUC(1,i)) + (2*stdev)^2);
    %plot(idxRng,counts(idxRng) - background');
    %plot(idxRng,background)
    plot(idxRng,counts(idxRng));
    
end

hold off
livetime = spectrum.livetime;
realtime = spectrum.realtime;
end

