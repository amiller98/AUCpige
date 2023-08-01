function bkg = baseliner(origSpec)
    y = log(log(sqrt(origSpec+1)+1)+1);
    lambda = 10^5;
    ratio = 10^-1;
    
    N = length(y);
    D = diff(speye(N),2);
    H = lambda*D'*D;
    w = ones(N,1);
    while true
        W = spdiags(w,0,N,N);
        C = chol(W+H);
        z = C \ (C'\(w.*y));
        d = y-z;
        dn = d(d<0);
        m = mean(dn);
        s = std(dn);
        wt = 1./(1+exp(2*(d-(2*s-m))/s));
        if norm(w-wt)/norm(w) < ratio, break
        end
        w = wt;
        % hold on
        % plot(z)
        % plot(y)
        % hold off
        % clf('reset')
%        
    end
    
    bkg = (exp(exp(z)-1)-1).^2-1;
end