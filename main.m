clear; clc; close all;

% ABOUT: Simple driver to run an ode45 on a generalized N-Body problem
% using the NASA Horizons database ephemeris data in solar system
% barycentric coordinates

%% User Options
% Body to include
bodies = {'sun','earth','moon','mars','mercury','venus'};
numBodies = numel(bodies);

%     Integrate over two years (in seconds)
tspan =  [0:3600:365 * 24 * 60 * 60];
% tspan =  [0:6:86400];

plotData = true;
animateData = false; 

%%  Read in Ephemeris Data
% If we already loaded this once just load the MATLAB file, otherwise read
% in the data and create it.
if exist('EphemerisData.mat','file') == 2
    load('EphemerisData.mat','earthBenchmark','sunBenchmark','moonBenchmark','marsBenchmark','venusBenchmark','mercuryBenchmark');
else 
    sunBenchmark =      readEphemerisFile('EphemerisData\sol.txt',      48, 17568);
    earthBenchmark =    readEphemerisFile('EphemerisData\earth.txt',    55, 17575);
    moonBenchmark =     readEphemerisFile('EphemerisData\moon.txt',     49, 17569);
    marsBenchmark =     readEphemerisFile('EphemerisData\mars.txt',     50, 17570);
    mercuryBenchmark =  readEphemerisFile('EphemerisData\mercury.txt',  48, 17568);
    venusBenchmark =    readEphemerisFile('EphemerisData\venus.txt',    48, 17568);
    save('EphemerisData.mat','earthBenchmark','sunBenchmark','moonBenchmark','marsBenchmark','venusBenchmark','mercuryBenchmark');
end

%% Generate the Inital Position
% Lazy evaluation statements since its a quick enough operation and I dont
% care about performance for generating the initial vector
X = nan(numBodies*6,1);
for ii = 1:numBodies
    eval(sprintf( 'X(3*(ii-1)+1,1) = %sBenchmark.X(1);', bodies{ii}) ); % m
    eval(sprintf( 'X(3*(ii-1)+2,1) = %sBenchmark.Y(1);', bodies{ii}) ); % m
    eval(sprintf( 'X(3*(ii-1)+3,1) = %sBenchmark.Z(1);', bodies{ii}) ); % m
    
    eval(sprintf( 'X(numBodies*3 + 3*(ii-1)+1,1) = %sBenchmark.VX(1);', bodies{ii}) ); % m/s
    eval(sprintf( 'X(numBodies*3 + 3*(ii-1)+2,1) = %sBenchmark.VY(1);', bodies{ii}) ); % m/s
    eval(sprintf( 'X(numBodies*3 + 3*(ii-1)+3,1) = %sBenchmark.VZ(1);', bodies{ii}) ); % m/s
    eval(sprintf( 'bodyMasses(ii,1) = constants.mass_%s;', bodies{ii}));
end

%% Perform integration over a period of 2 earth years to match benchmark data
odeOpts = odeset('RelTol',1e-12,'AbsTol',1e-10);
[t,x ] = ode45(@(t,x) derivs(bodyMasses, x), tspan, X, odeOpts);

% %% Use this for super small time step saving
% for ii = 1:36
%     [t,x ] = ode45(@(t,x) derivs(bodyMasses, x), tspan, X, odeOpts);
%     if ii == 1
%         x_save = x([1,end],:);
%     else
%         x_save(end+1,:) = x(end,:);
%     end
%     X = x(end,:)';
% end
% 
% if exist('x_save','var') == 1
%     x = x_save;
% end

%% Compare values to the benchmark data 
plotOpts = { ...
                {'sun',     'NASA',  'Color',[0.9290 0.6940 0.1250], 'LineStyle', '--', 'DisplayName', 'NASA Sun'}, ...
                {'earth',   'NASA',  'Color',[0.4660 0.6740 0.1880], 'LineStyle', '--', 'DisplayName', 'NASA Earth'}, ...
                {'moon',    'NASA',  'Color',[0.0    0.0    0.0   ], 'LineStyle', '--', 'DisplayName', 'NASA Moon'}, ...
                {'mars',    'NASA',  'Color',[0.8500 0.3250 0.0980], 'LineStyle', '--', 'DisplayName', 'NASA Mars'}, ...
                {'venus',   'NASA',  'Color',[0.4940 0.1840 0.5560], 'LineStyle', '--', 'DisplayName', 'NASA Venus'}, ...
                {'mercury', 'NASA',  'Color',[0.6350 0.0780 0.1840], 'LineStyle', '--', 'DisplayName', 'NASA Mercury'}, ...
                ...
                {'sun',     'ODE',  'Color',[0.9290 0.6940 0.1250], 'LineStyle', '-', 'DisplayName', 'ODE Sun'}, ...
                {'earth',   'ODE',  'Color',[0.4660 0.6740 0.1880], 'LineStyle', '-', 'DisplayName', 'ODE Earth'}, ...
                {'moon',    'ODE',  'Color',[0.0    0.0    0.0   ], 'LineStyle', '-', 'DisplayName', 'ODE Moon'}, ...
                {'mars',    'ODE',  'Color',[0.8500 0.3250 0.0980], 'LineStyle', '-', 'DisplayName', 'ODE Mars'}, ...
                {'venus',   'ODE',  'Color',[0.4940 0.1840 0.5560], 'LineStyle', '-', 'DisplayName', 'ODE Venus'}, ...
                {'mercury', 'ODE',  'Color',[0.6350 0.0780 0.1840], 'LineStyle', '-', 'DisplayName', 'ODE Mercury'}, ...
           };
plotOpts = vertcat(plotOpts{:}); % convert to a row/col cell array not cell of cells
       
if plotData
    figure('Position', [240, 45, 1440, 900]); % 1440x900 figure centered(ish) on 1920x1080 screen
    hold on;
    
    % For each body go through and plot up the NASA Ephemeris data and the
    % integrator data
    for ii = 1:numel(bodies)
        
       % Check if the body exists in the plot options 
       plotOptInds = find(strcmpi(bodies{ii}, {plotOpts{:,1}})); % lower value is body, higher value is ODE
       if (numel(plotOptInds) == 2)
           % If NASA and ODE data exists do this
           nasa_data = eval( sprintf('[ %sBenchmark.X, %sBenchmark.Y, %sBenchmark.Z];', bodies{ii}, bodies{ii}, bodies{ii}) );
           plot3(nasa_data(:,1), nasa_data(:,2), nasa_data(:,3), plotOpts{plotOptInds(1),3:end});
           plot3(x(:,(ii-1)*3 + 1), x(:,(ii-1)*3 + 2), x(:,(ii-1)*3 + 3), plotOpts{plotOptInds(2),3:end});
       else
           % Plot the integrator body data only
           plot3(x(:,(ii-1)*3 + 1), x(:,(ii-1)*3 + 2), x(:,(ii-1)*3 + 3),'DisplayName', sprintf('Body %i',ii));
       end
       
    end
    grid on;
    xlabel('X-Distance [km]')
    ylabel('Y-Distance [km]')
    zlabel('Z-Distance [km]')
    legend('location','bestOutside');
    axis equal
end
