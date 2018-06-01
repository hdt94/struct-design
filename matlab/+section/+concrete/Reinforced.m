classdef Reinforced < section.Concrete
    
    properties (SetAccess = private)
        %
        InferiorRebar = material.Steel.empty;
        % material.Steel scalar (1,1). Steel material (superior and inferior rebars).
        MSteel = material.Steel.empty;
        %
        SuperiorRebar = material.Steel.empty;
    end
    
    methods
        function Obj = Reinforced(MConcrete, Height, Width, MSteel, Inferior, Superior)
            Obj@section.Concrete(MConcrete, Height, Width);
            validateattributes(MSteel, {'material.Steel'}, {'scalar'}, '', 'MSteel');
            validateattributes(Inferior, {'section.Rebar'}, {'scalar'}, '', 'Inferior');
            validateattributes(Superior, {'section.Rebar'}, {'scalar'}, '', 'Superior');
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
    end
end