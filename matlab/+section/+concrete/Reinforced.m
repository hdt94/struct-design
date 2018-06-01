classdef Reinforced < section.Concrete
    %
    % Example:
    %   MConcrete = material.Concrete();
    %   MConcrete.initialize(3, 0.003, 'ksi');
    %	MSteel = material.Steel();
    %   MSteel.initialize(29e3, 60);
    %
    %   As = 2 * 1; % Three #8 bars
    %   R1 = section.Rebar(As, 14);
    %   R2 = section.Rebar(As,2);
    %   Reinforced = section.concrete.Reinforced();
    %   Reinforced.initialize(MConcrete, 16, 14, MSteel, R1, R2);
        
    properties (SetAccess = private)
        %
        InferiorRebar = material.Steel.empty;
        % material.Steel scalar (1,1). Steel material (superior and inferior rebars).
        MSteel = material.Steel.empty;
        %
        SuperiorRebar = material.Steel.empty;
    end
    
    methods
                        
        function initialize(Obj, MConcrete, Height, Width, MSteel, Inferior, Superior)
            initialize@section.Concrete(Obj, MConcrete, Height, Width);
            validateattributes(MSteel, {'material.Steel'}, {'scalar'}, '', 'MSteel');
            validateattributes(Inferior, {'section.Rebar'}, {'scalar'}, '', 'Inferior');
            validateattributes(Superior, {'section.Rebar'}, {}, '', 'Superior');
            Obj.MSteel = MSteel;
            Obj.InferiorRebar = Inferior;
            Obj.SuperiorRebar = Superior;
        end
        
        function [Curvature, Moment] = getMomentCurvature(Obj)
            
            NSections = numel(Obj);
            Curvature = zeros(3, NSections);
            Moment = zeros(3, NSections);
            
            % Steel properties
            MSteel = [Obj(:).MSteel];
            Es = [MSteel(:).Young];
            fy = [MSteel(:).Yielding];
            
            % Concrete properties
            MConcrete = [Obj(:).MConcrete];
            Ec = [MConcrete(:).Young];
            fr = [MConcrete(:).Cracking];
            fc = [MConcrete(:).Compression];
            cu = [MConcrete(:).Strain_Ultimate];
            
            % Gross section
            h = [Obj(:).Height];
            b = [Obj(:).Width];
            Ig = [Obj(:).Ig];
            
            % Superior steel
            SuperiorRebar = [Obj(:).SuperiorRebar];
            As_ = [SuperiorRebar(:).Area];
            d_ = [SuperiorRebar(:).Depth];
            
            % Inferior steel
            InferiorRebar = [Obj(:).InferiorRebar];
            As = [InferiorRebar(:).Area];
            d = [InferiorRebar(:).Depth];
            
            % Cracking
            Moment(1,:) = fr .* Ig ./ (0.5*h);
            Curvature(1,:) = Moment(1,:) ./ (Ec.*Ig);
            
            % Yielding
            n = round(Es ./ Ec); % Modular ratios
            B = b ./ (n.*As);
            r = (n-1).*As_ ./ (n.*As);
            Kd = (sqrt(2*d.*B.*(1+r.*d_./d) + (1+r).^2) - (1+r)) ./ B;
            Moment(2,:) = As .* fy .* (d-Kd/3);
            Curvature(2,:) = (fy./Es) ./ (d-Kd);
            
            % Ultimate
            a = As .* fy ./ (0.85 * fc .* b);
            Moment(3,:) = As .* fy .* (d - 0.5*a);
            c = a / 0.85;
            Curvature(3,:) = cu ./ c;
        end
        
        function [Rotation, Moment] = getMomentRotation(Obj, L, db)
            %
            % Input:
            %   L: numeric vector (1xNSections). Length of sections.
            %   db: numeric vector (1xNSections). Rebar diameters.
            %
            % Glossary:
            %   NSections: number of sections.
            
            % Moment-curvature values
            [Curvature, Moment] = Obj.getMomentCurvature();
            
            % Output initialization
            Rotation = zeros(size(Curvature));
            
            % Friction coefficient
            U = 0.3; 
            
            % Steel properties
            MSteel = [Obj(:).MSteel];
            Es = [MSteel(:).Young];
            fy = [MSteel(:).Yielding];
            
             % Concrete properties
            MConcrete = [Obj(:).MConcrete];
            Ec = [MConcrete(:).Young];
            
            % Gross section
            I = [Obj(:).Ig];
            
            % Superior steel
            SuperiorRebar = [Obj(:).SuperiorRebar];
            d_ = [SuperiorRebar(:).Depth];
            
             % Inferior steel
            InferiorRebar = [Obj(:).InferiorRebar];
            d = [InferiorRebar(:).Depth];
            
            % Common expressions
            EcI = Ec .* I;
            exp1 = db .* (fy.^2) / (8 * U * Es .* (d-d_));
            exp2 = L ./ (6 .* EcI);
            
            % Cracking rotation
            Rot_cr_bs = exp1 .* (Moment(1,:).^2) / (Moment(2,:).^2); % [rad]
            Rotation(1,:) = Rot_cr_bs;
            
            % Yielding rotation
            Rot_y_el = Moment(2,:) .* exp2;
            alpha = Moment(1,:) ./ Moment(2,:);
            Rot_y_curv = (L/6) .* ((alpha.^2).*Curvature(1,:) + (1-alpha.^3).*Curvature(2,:));
            Rot_y_bs = exp1;
            Rotation(2,:) = - Rot_y_el + Rot_y_curv + Rot_y_bs;
            
            % Ultimate rotation
            Rot_u_el = Moment(3,:) .* exp2;
            alpha1 = Moment(1,:) ./ Moment(3,:);
            alpha2 = Moment(2,:) ./ Moment(3,:);
            mu = ((Moment(3,:)-Moment(2,:))./(Curvature(3,:)-Curvature(2,:))) .* (Curvature(2,:)./Moment(2,:));
            num = (2+alpha2) .* (1-alpha2) .* (mu.*alpha2+1-alpha2) ./ mu;
            Rot_u_curv = (L/12) .* ((num + alpha2.*(1+alpha2) - 2*(alpha1.^3)).*(Curvature(2,:)./alpha2) + 2*(alpha1.^2).*Curvature(1,:));
            Rot_u_bs = exp1 .* (Moment(3,:).^2) / (Moment(2,:).^2);
            Rotation(3,:) = - Rot_u_el + Rot_u_curv + Rot_u_bs;
        end
    end
end