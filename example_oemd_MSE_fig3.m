%%
% Plot the mean squared error of Online EMD
%%





%% Input data

  samp  = pi/2:.5:10000;
  comp1 = sin(samp);
  comp2 = sin(linspace(pi/2,10000/10,length(samp)));
  comp3 = sin(linspace(pi/2,10000/30,length(samp)));
  trend = linspace(0,10,length(samp));
  x = comp1 + comp2 + comp3 + trend;


%% Parameters
%% Online EMD
nbExtremaList = 10:30;  % Size of the sliding window (number of extrema per window) (must be higher than 6?)
nbMaxIMF = -1;  % Number of IMFs to extract (-1 for unlimited)

%% mean squared error 
sampErr = 2000:7000;
mse0 = zeros(1,length(nbExtremaList));
mse1 = zeros(1,length(nbExtremaList));
mse2 = zeros(1,length(nbExtremaList));

imf = emd(x,'FIX_H',4,'MAXMODES',3);
Q1 = 1/length(sampErr)*sum((comp1(sampErr)-imf(1,sampErr)).^2);
Q2 = 1/length(sampErr)*sum((comp2(sampErr)-imf(2,sampErr)).^2);
Q3 = 1/length(sampErr)*sum((comp3(sampErr)-imf(3,sampErr)).^2);
Q4 = 1/length(sampErr)*sum((trend(sampErr)-imf(4,sampErr)).^2);

mse_emd = Q1+Q2+Q3+Q4;

imf = emdc([],x,[],3);
Q1 = 1/length(sampErr)*sum((comp1(sampErr)-imf(1,sampErr)).^2);
Q2 = 1/length(sampErr)*sum((comp2(sampErr)-imf(2,sampErr)).^2);
Q3 = 1/length(sampErr)*sum((comp3(sampErr)-imf(3,sampErr)).^2);
Q4 = 1/length(sampErr)*sum((trend(sampErr)-imf(4,sampErr)).^2);

mse_rilling = Q1+Q2+Q3+Q4;

% 
%  imf = emd_local(x);
% % make sure we have only 3 IMFs and one residual
% size(imf,1)
% if size(imf,1) > 4
%        imf(4,:) = sum(imf(4:end,:));
% end
% 
% Q1 = 1/length(sampErr)*sum((comp1(sampErr)-imf(1,sampErr)).^2);
% Q2 = 1/length(sampErr)*sum((comp2(sampErr)-imf(2,sampErr)).^2);
% Q3 = 1/length(sampErr)*sum((comp3(sampErr)-imf(3,sampErr)).^2);
% Q4 = 1/length(sampErr)*sum((trend(sampErr)-imf(4,sampErr)).^2);
% 
% mse_local = Q1+Q2+Q3+Q4;
% 
% ['Error for local EMD: ' num2str(mse_local)]


%% EMD online with Rilling stopping criterion
run = 1;
for nbExtrema = nbExtremaList
    % Initialization
    stage = oemd_init(nbMaxIMF,nbExtrema,0); %Initializate data structures

    % Execution
    stage(1).data = x;
    stage = oemd_iter(stage); %iterate

    Q1 = 1/length(sampErr)*sum((comp1(sampErr)-stage(1).imf(sampErr)).^2);
    Q2 = 1/length(sampErr)*sum((comp2(sampErr)-stage(2).imf(sampErr)).^2);
    Q3 = 1/length(sampErr)*sum((comp3(sampErr)-stage(3).imf(sampErr)).^2);
    Q4 = 1/length(sampErr)*sum((trend(sampErr)-stage(4).data(sampErr)).^2);

    mse0(run) = Q1+Q2+Q3+Q4;
    
    run = run+1;

end

%% EMD online with fix sifting
run = 1;
for nbExtrema = nbExtremaList
    % Initialization
    stage = oemd_init(nbMaxIMF,nbExtrema,1); %Initializate data structures

    % Execution
    stage(1).data = x;
    stage = oemd_iter(stage); %iterate

    Q1 = 1/length(sampErr)*sum((comp1(sampErr)-stage(1).imf(sampErr)).^2);
    Q2 = 1/length(sampErr)*sum((comp2(sampErr)-stage(2).imf(sampErr)).^2);
    Q3 = 1/length(sampErr)*sum((comp3(sampErr)-stage(3).imf(sampErr)).^2);
    Q4 = 1/length(sampErr)*sum((trend(sampErr)-stage(4).data(sampErr)).^2);

    mse1(run) = Q1+Q2+Q3+Q4;

    run = run+1;

end

%% EMD online with central limit stopping criterion
run = 1;
for nbExtrema = nbExtremaList
    % Initialization
    stage = oemd_init(nbMaxIMF,nbExtrema,2); %Initializate data structures

    % Execution
    stage(1).data = x;
    stage = oemd_iter(stage); %iterate

    Q1 = 1/length(sampErr)*sum((comp1(sampErr)-stage(1).imf(sampErr)).^2);
    Q2 = 1/length(sampErr)*sum((comp2(sampErr)-stage(2).imf(sampErr)).^2);
    Q3 = 1/length(sampErr)*sum((comp3(sampErr)-stage(3).imf(sampErr)).^2);
    Q4 = 1/length(sampErr)*sum((trend(sampErr)-stage(4).data(sampErr)).^2);

    mse2(run) = Q1+Q2+Q3+Q4;

    run = run+1;

end

%%
figure;
line([nbExtremaList(1)  nbExtremaList(end)],[mse_rilling mse_rilling],'color',[.5,.5,.5],'LineStyle','-.','LineWidth',2);
hold on;
line([nbExtremaList(1)  nbExtremaList(end)],[mse_emd mse_emd],'color',[.5,.5,.5],'LineStyle','--','LineWidth',2);
% line([nbExtremaList(1)  nbExtremaList(end)],[mse_local mse_local],'color',[.5,.5,.5],'LineStyle','-','LineWidth',2);
plot(nbExtremaList,mse0,'-r*','LineWidth',2,'MarkerSize',9);
plot(nbExtremaList,mse2,'-bo','LineWidth',2,'MarkerSize',9);
plot(nbExtremaList,mse1,'-k+','LineWidth',2,'MarkerSize',9);
legend('EMD (Rilling  stop. criterion)','EMD (conf. limit stop. criterion)', 'Online EMD (Rilling  stop. criterion)', 'Online EMD (conf. limit stop. criterion)', 'Online EMD (10 siftings)','Location','SouthEast');
xlabel('Window Size (nb. extrema)','FontSize',12);
ylabel('Mean Squared Error','FontSize',12);
set(gca,'FontSize',12);
axis auto

print('figure_mse.eps','-depsc');

