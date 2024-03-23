function dXdt = derivs(mvec, X)
%
%   ABOUT: Calculates the derivatives for M bodies for use in ode45.
% 
%   INPUTS: 
%           mvec        <double>    Nx1 vector for masses of the bodies
%           X           <double>    6Nx1 vector representing the x,y,z pos.
%                                   and vel. for each body N by body and
%                                   type [R1;V1;R2;V2;R3;V3;...;RN;VN]
%           
%   OPTIONAL INPUT (ordered): 
%
%   OUTPUTS:
%           dXdt       <double>    6Nx1 vector representing the
%                                   derivatives used for ode45
%
%   SYNTAX:
%           dXdt = derivs(X)
%
%   NOTES: Assumes values are in order listed by bodies provided in
%   "Constants.m" to calculate forces 
%
% 
% Step 01: Calculate the change in position due to velocity at time step
%

numBodies = numel(X)/6;
Position = reshape(X(1:3*numBodies), 3, numBodies)';

% Mass Matrix
% Calculate G*m_i*m_j
Gmass = constants.grav_constant * mvec .* mvec'; 

% Vector operations to calculate dX, dY and dZ for body i on j
% This returns a MxM array with the distance of each component of the
% cartesian distance
dX = Position(:,1)' - Position(:,1);
dY = Position(:,2)' - Position(:,2);
dZ = Position(:,3)' - Position(:,3);

% Total magnitude of distance 
magDist = sqrt(dX.^2 + dY.^2 + dZ.^2);

% Calculate the unit normals of the forces
cx = dX ./ magDist;
cy = dY ./ magDist;
cz = dZ ./ magDist;

% Calcualte the force on I due to J
% Solve Gmm/r^2 and add the unit vector component to each direction
Fx = Gmass ./ magDist.^2 .* cx; % Calculate the force and multiply by normal component
Fy = Gmass ./ magDist.^2 .* cy; % Calculate the force and multiply by normal component
Fz = Gmass ./ magDist.^2 .* cz; % Calculate the force and multiply by normal component

% Calculate accelerations 
Ax = Fx ./ mvec; 
Ay = Fy ./ mvec;
Az = Fz ./ mvec;

% Null and Sum Accelerations on body ii due to jj
Ax(isnan(Ax)) = 0;
Ay(isnan(Ay)) = 0;
Az(isnan(Az)) = 0;

Ax = sum(Ax,2); % Sums all Ax due to jj on ii
Ay = sum(Ay,2); % Sums all Ax due to jj on ii
Az = sum(Az,2); % Sums all Ax due to jj on ii

% Generate derivative vector [dR, dV];
dXdt = [X(3*numBodies+1:end); reshape([Ax, Ay, Az]',[],1)];

end