

clc
clear all
rng(1234)


n = 1000;
T = 12*40;
sigma2_e = 0.2;
sigma_sq_e = sqrt(sigma2_e);
sigma_sq_u = 0.2; 
sigma_u = sqrt(sigma_sq_u);
beta = 0.99^(1/12); 
eta_1 = 1;
eta_2 = 2;
eta_4 = 4;
mu = 1;


theta = 0.6; 
ratio_yc = 1/0.25;
h_m = 28.5 * (30/7); 
kappa = theta * ratio_yc*(h_m)^(-1-(1/mu));

gm_m = [-0.147, -0.370, 0.141, 0.131, 0.090, 0.058, 0.036, 0.036, ...
    0.036, 0.002, -0.033, -0.082];
gm_h = [-0.293, -0.739, 0.282, 0.262, 0.180, 0.116, 0.072, 0.072, ...
    0.072, 0.004, -0.066, -0.164];
gm_l = [-0.073, -0.185, 0.071, 0.066, 0.045, 0.029, 0.018, 0.018, ... 
    0.018, 0.001, -0.017, -0.041];
sigma2_m_m = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, ...
    0.205, 0.188, 0.188, 0.171, 0.137];
sigma2_m_h = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, ...
    0.410, 0.376, 0.376, 0.341, 0.273];
sigma2_m_l = [ 0.043, 0.034, 0.145, 0.142, 0.137, 0.137, 0.119, ...
    0.102, 0.094, 0.094, 0.085, 0.068];

beta_m = zeros(1,12);
beta_y = zeros(1,12);
 for i = 1:12
     beta_m(1,i) = beta.^(i-1);
 end
 for i = 1:40 
     beta_y(1,i) = beta.^(12*i);
 end
B = ones(n,1)*kron(beta_y,beta_m);


s_l = exp(kron(ones(n,40),gm_l) );
s_m = exp( kron(ones(n,40),gm_m) );
s_h = exp( kron(ones(n,40),gm_h) );

sr_l = zeros(n,T);
lab_sr_l = zeros(n,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_m_l(1,i), 0.03; 0.03,sigma2_m_l(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        sr_l(k,i+j*12) = exp(-sigma2_m_l(1,i)/2) * exp(ln(1,1));
        lab_sr_l(k,i+j*12) = exp(-sigma2_m_l(1,i)/2) * exp(ln(1,2));
        end
    end
end
sr_m = zeros(n,T);
lab_sr_m = zeros(n,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_m_m(1,i), 0.03; 0.03,sigma2_m_m(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        sr_m(k,i+j*12) = exp(-sigma2_m_m(1,i)/2) * exp(ln(1,1));
        lab_sr_m(k,i+j*12) = exp(-sigma2_m_m(1,i)/2) * exp(ln(1,2));
        end
    end
end
sr_h = zeros(n,T);
lab_sr_h = zeros(n,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_m_h(1,i), 0.03; 0.03,sigma2_m_h(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        sr_h(k,i+j*12) = exp(-sigma2_m_h(1,i)/2) * exp(ln(1,1));
        lab_sr_h(k,i+j*12) = exp(-sigma2_m_h(1,i)/2) * exp(ln(1,2));
        end
    end
end

sr_l_neg = zeros(n,T);
lab_sr_l_neg = zeros(n,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_m_l(1,i), -0.03; -0.03,sigma2_m_l(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        sr_l_neg(k,i+j*12) = exp(-sigma2_m_l(1,i)/2) * exp(ln(1,1));
        lab_sr_l_neg(k,i+j*12) = exp(-sigma2_m_l(1,i)/2) * exp(ln(1,2));
        end
    end
end
sr_m_neg = zeros(n,T);
lab_sr_m_neg = zeros(n,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_m_m(1,i), -0.03; -0.03,sigma2_m_m(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        sr_m_neg(k,i+j*12) = exp(-sigma2_m_m(1,i)/2) * exp(ln(1,1));
        lab_sr_m_neg(k,i+j*12) = exp(-sigma2_m_m(1,i)/2) * exp(ln(1,2));
        end
    end
end
sr_h_neg = zeros(n,T);
lab_sr_h_neg = zeros(n,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_m_h(1,i), -0.03; -0.03,sigma2_m_h(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        sr_h_neg(k,i+j*12) = exp(-sigma2_m_h(1,i)/2) * exp(ln(1,1));
        lab_sr_h_neg(k,i+j*12) = exp(-sigma2_m_h(1,i)/2) * exp(ln(1,2));
        end
    end
end


ln_u = mvnrnd(zeros(n,1),eye(n) * sigma_sq_u).'; 
z = exp(-sigma_sq_u/2) * exp(ln_u); 
Z = z * ones(1,T); 

ln_e = zeros(n,T);
for i = 1:n
    for j = 0:39
        ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sigma_sq_e);
    end
end
E = exp(-sigma_sq_e/2) * exp(ln_e);



lab_ln_u = mvnrnd(zeros(n,1),eye(n) * sigma_sq_u).'; 
lab_z = exp(-sigma_sq_u/2) * exp(lab_ln_u); 
lab_Z = lab_z * ones(1,T); 

lab_ln_e = zeros(n,T);
for i = 1:n
    for j = 0:39
        lab_ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sigma_sq_e);
    end
end
lab_E = exp(-sigma_sq_e/2) * exp(lab_ln_e);



cl_s_sr_r = Z .* s_l .*  sr_l .* E; 
cm_s_sr_r = Z .* s_m .* sr_m .* E;
ch_s_sr_r = Z .* s_h .* sr_h .* E;
c_r = Z .* E; 

ll_s_sr_r = lab_Z .* s_l .*  lab_sr_l .* lab_E; 
lm_s_sr_r = lab_Z .* s_m .* lab_sr_m .* lab_E;
lh_s_sr_r = lab_Z .* s_h .* lab_sr_h .* lab_E;
l_r = lab_Z .* lab_E; 
cl_s_sr_r_neg = Z .* s_l .*  sr_l_neg .* E; 
cm_s_sr_r_neg = Z .* s_m .* sr_m_neg .* E;
ch_s_sr_r_neg = Z .* s_h .* sr_h_neg .* E;


ll_s_sr_r_neg = lab_Z .* s_l .*  lab_sr_l_neg .* lab_E; 
lm_s_sr_r_neg = lab_Z .* s_m .* lab_sr_m_neg .* lab_E;
lh_s_sr_r_neg = lab_Z .* s_h .* lab_sr_h_neg .* lab_E;



wgl_s_sr = zeros(n,1); 
wgm_s_sr = zeros(n,1);
wgh_s_sr = zeros(n,1);
for i = 1:n
    fl = @(gl) abs(sum(...
        (B(i,:).*(  log(cl_s_sr_r(i,:).*(1+gl))  -  kappa.*(ll_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgl_s_sr(i,1) = fminbnd(fl,-5,20);
    fm = @(gm) abs(sum(...
        (B(i,:).*(  log(cm_s_sr_r(i,:).*(1+gm))  -  kappa.*(lm_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgm_s_sr(i,1) = fminbnd(fm,-5,20);
    fh = @(gh) abs(sum(...
        (B(i,:).*(  log(ch_s_sr_r(i,:).*(1+gh))  -  kappa.*(lh_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgh_s_sr(i,1) = fminbnd(fh,-5,20);
end

wgl_s_sr_ce = zeros(n,1); 
wgm_s_sr_ce = zeros(n,1);
wgh_s_sr_ce = zeros(n,1);
for i = 1:n
    fl = @(gl) abs(sum(...
        (B(i,:).*(  log(cl_s_sr_r(i,:).*(1+gl))  -  kappa.*(ll_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(ll_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgl_s_sr_ce(i,1) = fminbnd(fl,-5,20);
    fm = @(gm) abs(sum(...
        (B(i,:).*(  log(cm_s_sr_r(i,:).*(1+gm))  -  kappa.*(lm_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(lm_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgm_s_sr_ce(i,1) = fminbnd(fm,-5,20);
    fh = @(gh) abs(sum(...
        (B(i,:).*(  log(ch_s_sr_r(i,:).*(1+gh))  -  kappa.*(lh_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(lh_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgh_s_sr_ce(i,1) = fminbnd(fh,-5,20);
end

wgl_s_sr_le = zeros(n,1); 
wgm_s_sr_le = zeros(n,1);
wgh_s_sr_le = zeros(n,1);
for i = 1:n
    fl = @(gl) abs(sum(...
        (B(i,:).*(  log(c_r(i,:).*(1+gl))  -  kappa.*(ll_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgl_s_sr_le(i,1) = fminbnd(fl,-5,20);

    fm = @(gm) abs(sum(...
        (B(i,:).*(  log(c_r(i,:).*(1+gm))  -  kappa.*(lm_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgm_s_sr_le(i,1) = fminbnd(fm,-5,20);

    fh = @(gh) abs(sum(...
        (B(i,:).*(  log(c_r(i,:).*(1+gh))  -  kappa.*(lh_s_sr_r(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:)) -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgh_s_sr_le(i,1) = fminbnd(fh,-5,20);
end


 
Results = [prctile(wgl_s_sr,10), prctile(wgm_s_sr,10), prctile(wgh_s_sr,10); ...
    prctile(wgl_s_sr,50), prctile(wgm_s_sr,50), prctile(wgh_s_sr,50); ...
    prctile(wgl_s_sr,90), prctile(wgm_s_sr,90), prctile(wgh_s_sr,90); ...
    mean(wgl_s_sr), mean(wgm_s_sr), mean(wgh_s_sr); ...
    std(wgl_s_sr), std(wgm_s_sr), std(wgh_s_sr)];
disp(' RESULTS PART A. TOTAL')
disp(Results)
disp('First row: 10th prctile. Second row: 50th prctile. Third row: 90th prctile. Fourth row: Means. Fifth row: sd')
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')
 
Results = [prctile(wgl_s_sr_ce,10), prctile(wgm_s_sr_ce,10), prctile(wgh_s_sr_ce,10); ...
    prctile(wgl_s_sr_ce,50), prctile(wgm_s_sr_ce,50), prctile(wgh_s_sr_ce,50); ...
    prctile(wgl_s_sr_ce,90), prctile(wgm_s_sr_ce,90), prctile(wgh_s_sr_ce,90); ...
    mean(wgl_s_sr_ce), mean(wgm_s_sr_ce), mean(wgh_s_sr_ce); ...
    std(wgl_s_sr_ce), std(wgm_s_sr_ce), std(wgh_s_sr_ce)];
disp(' RESULTS PART A. CONSUMPTION')
disp(Results)
disp('First row: 10th prctile. Second row: 50th prctile. Third row: 90th prctile. Fourth row: Means. Fifth row: sd')
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

Results = [prctile(wgl_s_sr_le,10), prctile(wgm_s_sr_le,10), prctile(wgh_s_sr_le,10); ...
    prctile(wgl_s_sr_le,50), prctile(wgm_s_sr_le,50), prctile(wgh_s_sr_le,50); ...
    prctile(wgl_s_sr_le,90), prctile(wgm_s_sr_le,90), prctile(wgh_s_sr_le,90); ...
    mean(wgl_s_sr_le), mean(wgm_s_sr_le), mean(wgh_s_sr_le); ...
    std(wgl_s_sr_le), std(wgm_s_sr_le), std(wgh_s_sr_le)];
disp(' RESULTS PART A. Labor effects')
disp(Results)
disp('First row: 10th prctile. Second row: 50th prctile. Third row: 90th prctile. Fourth row: Means. Fifth row: sd')
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

figure
subplot(3,1,1);
hold on
histogram(wgl_s_sr,16,'BinWidth',0.01);
hold on
histogram(wgl_s_sr_ce,16,'BinWidth',0.01);
hold on
histogram(wgl_s_sr_le,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Ind g')
ylabel('# ind')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Seasonality: Low, corr>0')
 
subplot(3,1,2);
hold on
histogram(wgm_s_sr,16,'BinWidth',0.01);
hold on
histogram(wgm_s_sr_ce,16,'BinWidth',0.01);
hold on
histogram(wgm_s_sr_le,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Ind g')
ylabel('# ind')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Seasonality: Medium, corr>0')
 
subplot(3,1,3);
hold on
histogram(wgh_s_sr,16,'BinWidth',0.01);
hold on
histogram(wgh_s_sr_ce,16,'BinWidth',0.01);
hold on
histogram(wgh_s_sr_le,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Ind g')
ylabel('# ind')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Seasonality: High, corr>0')
print('Question2_A','-dpng')



wgl_s_sr_neg = zeros(n,1); 
wgm_s_sr_neg = zeros(n,1);
wgh_s_sr_neg = zeros(n,1);
for i = 1:n
    fl = @(gl) abs(sum(...
        (B(i,:).*(  log(cl_s_sr_r_neg(i,:).*(1+gl))  -  kappa.*(ll_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgl_s_sr_neg(i,1) = fminbnd(fl,-5,20);
    fm = @(gm) abs(sum(...
        (B(i,:).*(  log(cm_s_sr_r_neg(i,:).*(1+gm))  -  kappa.*(lm_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgm_s_sr_neg(i,1) = fminbnd(fm,-5,20);
    fh = @(gh) abs(sum(...
        (B(i,:).*(  log(ch_s_sr_r_neg(i,:).*(1+gh))  -  kappa.*(lh_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgh_s_sr_neg(i,1) = fminbnd(fh,-5,20);
end

wgl_s_sr_ce_neg = zeros(n,1); 
wgm_s_sr_ce_neg = zeros(n,1);
wgh_s_sr_ce_neg = zeros(n,1);
for i = 1:n
    fl = @(gl) abs(sum(...
        (B(i,:).*(  log(cl_s_sr_r_neg(i,:).*(1+gl))  -  kappa.*(ll_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(ll_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgl_s_sr_ce_neg(i,1) = fminbnd(fl,-5,20);
    fm = @(gm) abs(sum(...
        (B(i,:).*(  log(cm_s_sr_r_neg(i,:).*(1+gm))  -  kappa.*(lm_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(lm_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgm_s_sr_ce_neg(i,1) = fminbnd(fm,-5,20);
    fh = @(gh) abs(sum(...
        (B(i,:).*(  log(ch_s_sr_r_neg(i,:).*(1+gh))  -  kappa.*(lh_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(lh_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgh_s_sr_ce_neg(i,1) = fminbnd(fh,-5,20);
end

wgl_s_sr_le_neg = zeros(n,1); 
wgm_s_sr_le_neg = zeros(n,1);
wgh_s_sr_le_neg = zeros(n,1);
for i = 1:n
    fl = @(gl) abs(sum(...
        (B(i,:).*(  log(c_r(i,:).*(1+gl))  -  kappa.*(ll_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgl_s_sr_le_neg(i,1) = fminbnd(fl,-5,20);
    fm = @(gm) abs(sum(...
        (B(i,:).*(  log(c_r(i,:).*(1+gm))  -  kappa.*(lm_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:))  -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgm_s_sr_le_neg(i,1) = fminbnd(fm,-5,20);
    fh = @(gh) abs(sum(...
        (B(i,:).*(  log(c_r(i,:).*(1+gh))  -  kappa.*(lh_s_sr_r_neg(i,:).^(1+1/mu)/(1+1/mu))  )).' - ... 
        (B(i,:).*(  log(c_r(i,:)) -  kappa.*(l_r(i,:).^(1+1/mu)/(1+1/mu))                      )).'   ));
    wgh_s_sr_le_neg(i,1) = fminbnd(fh,-5,20);
end

 
Results = [prctile(wgl_s_sr_neg,10), prctile(wgm_s_sr_neg,10), prctile(wgh_s_sr_neg,10); ...
    prctile(wgl_s_sr_neg,50), prctile(wgm_s_sr_neg,50), prctile(wgh_s_sr_neg,50); ...
    prctile(wgl_s_sr_neg,90), prctile(wgm_s_sr_neg,90), prctile(wgh_s_sr_neg,90); ...
    mean(wgl_s_sr_neg), mean(wgm_s_sr_neg), mean(wgh_s_sr_neg); ...
    std(wgl_s_sr_neg), std(wgm_s_sr_neg), std(wgh_s_sr_neg)];
disp(' RESULTS PART B. Total effects')
disp(Results)
disp('First row: 10th prctile. Second row: 50th prctile. Third row: 90th prctile. Fourth row: Means. Fifth row: sd')
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')
 
Results = [prctile(wgl_s_sr_ce_neg,10), prctile(wgm_s_sr_ce_neg,10), prctile(wgh_s_sr_ce_neg,10); ...
    prctile(wgl_s_sr_ce_neg,50), prctile(wgm_s_sr_ce_neg,50), prctile(wgh_s_sr_ce_neg,50); ...
    prctile(wgl_s_sr_ce_neg,90), prctile(wgm_s_sr_ce_neg,90), prctile(wgh_s_sr_ce_neg,90); ...
    mean(wgl_s_sr_ce_neg), mean(wgm_s_sr_ce_neg), mean(wgh_s_sr_ce_neg); ...
    std(wgl_s_sr_ce_neg), std(wgm_s_sr_ce_neg), std(wgh_s_sr_ce_neg)];
disp(' RESULTS PART B. CONSUMPTION')
disp(Results)
disp('First row: 10th prctile. Second row: 50th prctile. Third row: 90th prctile. Fourth row: Means. Fifth row: sd')
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

Results = [prctile(wgl_s_sr_le_neg,10), prctile(wgm_s_sr_le_neg,10), prctile(wgh_s_sr_le_neg,10); ...
    prctile(wgl_s_sr_le_neg,50), prctile(wgm_s_sr_le_neg,50), prctile(wgh_s_sr_le_neg,50); ...
    prctile(wgl_s_sr_le_neg,90), prctile(wgm_s_sr_le_neg,90), prctile(wgh_s_sr_le_neg,90); ...
    mean(wgl_s_sr_le_neg), mean(wgm_s_sr_le_neg), mean(wgh_s_sr_le_neg); ...
    std(wgl_s_sr_le_neg), std(wgm_s_sr_le_neg), std(wgh_s_sr_le_neg)];
disp(' RESULTS PART B. LABOR')
disp(Results)
disp('First row: 10th prctile. Second row: 50th prctile. Third row: 90th prctile. Fourth row: Means. Fifth row: sd')
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

figure
subplot(3,1,1);
hold on
histogram(wgl_s_sr_neg,16,'BinWidth',0.01);
hold on
histogram(wgl_s_sr_ce_neg,16,'BinWidth',0.01);
hold on
histogram(wgl_s_sr_le_neg,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Ind g')
ylabel('# ind')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Seasonality: Low, corr<0')
 
subplot(3,1,2);
hold on
histogram(wgm_s_sr_neg,16,'BinWidth',0.01);
hold on
histogram(wgm_s_sr_ce_neg,16,'BinWidth',0.01);
hold on
histogram(wgm_s_sr_le_neg,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Ind g')
ylabel('# ind')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Seasonality: Medium, corr<0')
 
subplot(3,1,3);
hold on
histogram(wgh_s_sr_neg,16,'BinWidth',0.01);
hold on
histogram(wgh_s_sr_ce_neg,16,'BinWidth',0.01);
hold on
histogram(wgh_s_sr_le_neg,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Seasonality: High, corr<0')
print('Question2_B','-dpng')