function s = synthese(z,alpha,D,n,l,beta);
%s = synthese(z,alpha,D,n,l,beta) re-synth�tise le signal � partir des param�tres estim�s
%
% Copyright (C) 2004-2008 Roland Badeau
% Send bugs and requests to roland.badeau@telecom-paristech.fr
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>. 

% INITIALISATIONS
r = size(z,1); % ordre du mod�le
N = n+l-1; % longueur de l'horizon d'observation
N8 = floor(N/8);
win_n2 = hanning(N*D,'periodic'); win_n2 = win_n2(end:-1:1); % fen�tre de synth�se
t = l*D; % premier instant de synth�se
s = zeros(D*N8*(size(z,2)+7),1); % signal resynth�tis�
w = zeros(size(s)); % fen�tre de pond�ration � inverser � la fin
V = zeros(N*D,r); % matrice de Vandermonde

% SYNTHESE
for k=1:size(z,2), % pour chaque fen�tre de synth�se
   alpha0 = alpha(:,k); % extraction des amplitudes complexes
   for k2=1:r,
      z0 = z(k2,k);
      if abs(angle(z0))*beta < pi,
         scale = exp(i*angle(z0)*(beta-1)); % d�phasage en cas de modification de hauteur
         z0 = z0 * scale; % d�placement du p�le en cas de modification de hauteur
   		if abs(z0) < 1, % cas o� le p�le est � l'int�rieur du cercle unit�
         	V(:,k2) = z0.^((0:N*D-1)'); % calcul de la colonne de la matrice de Vandermonde
            V(:,k2) = V(:,k2) / norm(V(1:D:end,k2)); % normalisation
            alpha0(k2) = alpha0(k2) * scale^(t-l*D); % ajustement de la phase
	   	else, % cas o� le p�le est � l'ext�rieur du cercle unit�
         	V(:,k2) = z0.^((-(N-1)*D:D-1)'); % calcul de la colonne de la matrice de Vandermonde
            V(:,k2) = V(:,k2) / norm(V(1:D:end,k2)); % normalisation
            alpha0(k2) = alpha0(k2) * scale^(t+(n-2)*D); % ajustement de la phase
         end;
      end;
   end;
   x = V * alpha0; % segment synth�tis�
   s(t-l*D+1:t+(n-1)*D) = s(t-l*D+1:t+(n-1)*D) + x.*win_n2; % overlap-add du signal
   w(t-l*D+1:t+(n-1)*D) = w(t-l*D+1:t+(n-1)*D) + win_n2; % overlap-add de la fen�tre de pond�ration
   t = t + N8*D;
end;
s(1:end-1) = s(1:end-1) ./ w(1:end-1); % inversion de la fen�tre de pond�ration